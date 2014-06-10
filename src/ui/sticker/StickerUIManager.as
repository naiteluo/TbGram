package ui.sticker
{
	import com.adobe.serialization.json.JSONDecoder;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import layout.FlowAutoHeightLayout;
	
	import org.aswing.ASColor;
	import org.aswing.BorderLayout;
	import org.aswing.FlowWrapLayout;
	import org.aswing.JPanel;
	import org.aswing.JScrollPane;
	import org.aswing.border.LineBorder;
	
	import ui.basic.MyScrollPane;
	import ui.sticker.Sticker;
	import ui.sticker.StickerDialog;
	import ui.viewport.Viewport;

	public class StickerUIManager
	{
		private var _stickers:Vector.<Sticker>;
		private var _viewport:Viewport;
		private var _setupDialog:StickerDialog;
		private var _container:Sprite;
		private var _stickerHandlers:SticksListPanel;
        private var _sticksScrollPanel:MyScrollPane;
		private var _stickerConfigURL:String;
		private var _tabPanel:StickerTabedPane;
		private var _configs:*;
		private var _tabContainer:JPanel;
		
		public function StickerUIManager(target:Viewport, tabContainer:JPanel, configURL:String)
		{
			_viewport = target;
            _tabContainer = tabContainer;

			_stickerConfigURL = configURL;
			_stickers = new Vector.<Sticker>;
			_setupDialog = new StickerDialog();
			//sticker容器
			_container = new Sprite;
			_viewport.addChild(_container);
			
			_container.addEventListener(MouseEvent.CLICK, _itemClickHandler);
			_container.addEventListener(MouseEvent.MOUSE_OVER, _itemHoverHandler);
			_container.addEventListener(MouseEvent.MOUSE_OUT, _itemHoverHandler);
            
			_requestSticksConfig();
		}
        
        /**
         * 构建tab 
         */
        private function _buildTab():void
        {
            _stickerHandlers = new SticksListPanel(new FlowAutoHeightLayout(FlowWrapLayout.LEFT, 3, 3, true));            
            _stickerHandlers.setBorder(new LineBorder(null, new ASColor(0x000077), 1));
            
            _stickerHandlers.setPreferredHeight(500);
            _stickerHandlers.setPreferredWidth(224);
            
            _sticksScrollPanel = new MyScrollPane(_stickerHandlers, JScrollPane.SCROLLBAR_AS_NEEDED, JScrollPane.SCROLLBAR_NEVER);
            
            _sticksScrollPanel.setBorder(new LineBorder(null, new ASColor(0x007700), 1));
            
            
            _tabPanel = new StickerTabedPane(_configs);
                        
            for(var i:int, len:int = _configs.length; i < len; i ++){
                _tabPanel.appendTab(_sticksScrollPanel, _configs[i].tabName);
            }
            
            _tabPanel.setBorder(new LineBorder(null, new ASColor(0x660000), 2));
            _tabPanel.setPreferredHeight(500);
            _tabPanel.setHeight(500);
            _tabPanel.setMaximumHeight(600);
            
            _tabContainer.append(_tabPanel);
            
            _stickerHandlers.doLayout();
            
			_stickerHandlers.addEventListener(SticksListPanel.ITEM_CLICK, _stickActiveHandler);
            
        }
        
		/**
		 * 将sticker置顶
		 */
		private function _topItem(sticker:Sticker):void
		{
			if(!_container.contains(sticker)) return;
			var len:int = _container.numChildren,
				idx:int = _container.getChildIndex(sticker);
			
			if(idx == len - 1) return;
			for(var i:int = idx; i < len - 1; i ++){
				_container.swapChildrenAt(i, i + 1);
			}
			
		}
		
		private function _itemClickHandler(evt:MouseEvent):void
		{
			if(!(evt.target is Sticker)) return;
			var target:Sticker = evt.target as Sticker;
			this.setStickerActive(target);
		}
		
		private function _itemActiveChangeHandler(evt:Event):void
		{
			var sticker:Sticker = evt.target as Sticker;
			if(sticker.active){
				sticker.alpha = 1;
				_topItem(sticker);
				_setupDialog.bindSticker(sticker);
				_viewport.stage.addChild(_setupDialog);
			}else{
				sticker.alpha = 0.7;
				_setupDialog.unbindSticker();
				_viewport.stage.removeChild(_setupDialog);
			}
		}
		
		private function _itemDisposeHandler(evt:Event):void
		{
			_container.removeChild(evt.target as Sticker);
			var idx:int = this.deleteSticker(evt.target as Sticker);
			//如果在列表中还有其他的sticker，将其激活
			if(_stickers.length > 0){
				if(_stickers.length - 1 >= idx) 
					_stickers[idx].active = true;
				else
					_stickers[idx - 1].active = true;
			}
		}
		/**
		 * 鼠标经过没有激活的时候提示可以激活
		 */
		private function _itemHoverHandler(evt:MouseEvent):void
		{
			if(!(evt.target is Sticker)) return;
			var st:Sticker = evt.target as Sticker;
			if(st.active) return;
			if(evt.type == MouseEvent.MOUSE_OVER)
				st.alpha = 0.9;
			else if(evt.type == MouseEvent.MOUSE_OUT)
				st.alpha = 0.7;
		}
		
		/**
		 * 获取饰品配置
		 */
		private function _requestSticksConfig():void
		{
			var sticksConfLoader:URLLoader = new URLLoader();
			sticksConfLoader.addEventListener(Event.COMPLETE, _sticksConfigLoaded);
			sticksConfLoader.load(new URLRequest(_stickerConfigURL));
		}
		
		/**
		 * 饰品配置获取完成的回调
		 */
		private function _sticksConfigLoaded(event:Event):void
		{
			var loader:URLLoader = event.target as URLLoader;
			loader.removeEventListener(Event.COMPLETE, _sticksConfigLoaded);
			
			var data:Object = new JSONDecoder(loader.data, false).getValue();
			_configs = data.tabs as Array;
            _buildTab();

		}
		
		/**
		 * 饰品选择的回调
		 */
		private function _stickActiveHandler(evt:Event):void
		{
			var activeItem:StickItem = (evt.target as SticksListPanel).activeItem;
			if(activeItem){
				var stickConfig:Object = _stickerHandlers.activeItem.stickConfig;
				this.createSticker(stickConfig);
			}
		}
		
		/**
		 * 设置按序号激活
		 */
		public function set activeIndex(index:int):void
		{
			var idx:int = this.activeIndex;
			if(idx != index && index < _stickers.length){
				(idx != -1) && (_stickers[idx].active = false);
				_stickers[index].active = true;
			}
		}
		/**
		 * 获取激活序号
		 */
		public function get activeIndex():int
		{
			for(var i:int = 0, len:int = _stickers.length; i < len; i ++){
				if(_stickers[i].active)
					return i;
			}
			return -1;
		}
		/**
		 * 设置一个列表内的sticker的active状态
		 */
		public function setStickerActive(sticker:Sticker, isActive:Boolean=true):void
		{
			var idx:int = _stickers.indexOf(sticker);
			if(idx < 0) return;
			if(isActive){
				this.activeIndex = idx;
			}else{
				sticker.active = false;
			}
		}
		/**
		 * 创建并激活sticker
		 */
		public function createSticker(
			itemConfig:Object,
			minScale:Number=0.1
		):Sticker
		{
			var sticker:Sticker = new Sticker(_viewport, itemConfig, minScale);
			sticker.addEventListener(Sticker.EVENT_ACTIVE_CHANGE, _itemActiveChangeHandler);
			sticker.addEventListener(Sticker.EVENT_DISPOSE, _itemDisposeHandler);
			_stickers.push(sticker);
			_container.addChild(sticker);
			this.setStickerActive(sticker);
			return sticker;
		}
		/**
		 * 删除sticker
		 * @return	该sticker的索引
		 */
		public function deleteSticker(sticker:Sticker):int
		{
			var idx:int = _stickers.indexOf(sticker);
			if(idx >= 0){
				_stickers[idx].removeEventListener(Sticker.EVENT_ACTIVE_CHANGE, _itemActiveChangeHandler);
				_stickers[idx].removeEventListener(Sticker.EVENT_DISPOSE, _itemDisposeHandler);
				_stickers.splice(idx, 1);
				return idx;
			}else
				return -1;
		}
		/**
		 * 还原
		 */
		public function reset():void
		{
			for(var i:int = 0, len:int = _stickers.length; i < len; i ++)
				_stickers[i].dispose();
			
			_stickers.length = 0;
			_stickers = new Vector.<Sticker>;
		}
	}
}


