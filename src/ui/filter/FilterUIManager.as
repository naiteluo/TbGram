package ui.filter
{
	import com.adobe.serialization.json.JSONDecoder;
	import com.greensock.TweenLite;
	import com.imagelib.FilterManager;
	import com.imagelib.filterEvent.FilterEvent;
	import com.imagelib.utils.FilterConfigParser;
	
	import flash.display.BitmapData;
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	import ui.viewport.Viewport;
	import ui.viewport.ViewportEvent;
	import ui.viewport.ViewportLayer;
	
	public class FilterUIManager
	{
		private var _setupDialog:FilterDialog;
		private var _viewport:Viewport;
		private var _filtersHandlers:FilterListPanel;
		private var _filterConfigURL:String;
		
		private var _hasFilter:Boolean;
		
		public function FilterUIManager(target:Viewport, handers:FilterListPanel, configURL:String)
		{
			_viewport = target;
			_setupDialog = new FilterDialog('滤镜属性');
			_filtersHandlers = handers;
			_filterConfigURL = configURL;
			
			_setupDialog.addEventListener(FilterDialog.EVENT_OK, _dialogEventHandler);
			_setupDialog.addEventListener(FilterDialog.EVENT_CANCEL, _dialogEventHandler);
			_viewport.addEventListener(ViewportEvent.BEFORE_CHANGE, _viewportBeforeChange);
			_viewport.addEventListener(ViewportEvent.CHANGE, _viewportChanged);
			
			_requestFiltersConfig();
		}
		
		//____________build handlers________________
		
		private function _requestFiltersConfig():void
		{
			var confLoader:URLLoader = new URLLoader();
			confLoader.addEventListener(Event.COMPLETE, _configLoaded);
			confLoader.load(new URLRequest(_filterConfigURL));
		}
		private function _configLoaded(evt:Event):void
		{
			var loader:URLLoader = evt.target as URLLoader;
			loader.removeEventListener(Event.COMPLETE, _configLoaded);
			
			var data:Object = new JSONDecoder(loader.data, false).getValue(),
				_reviewURL:String = data.previewer;	//预览图
			var filterConfigs:Array = data.filters as Array;
			
			for(var i:int, len:int = filterConfigs.length; i < len; i ++){
				var item:FilterItem = new FilterItem(_reviewURL, filterConfigs[i]);
				_filtersHandlers.append(item);
			}
			_filtersHandlers.doLayout();
			_filtersHandlers.addEventListener(FilterListPanel.ACTIVE_CHANGE, _filterSelectedHandler);
			
		}
		
		//____________filters work________________
		
		private function _filterPorcessComplete(evt:FilterEvent):void
		{
			(evt.target as FilterManager).removeEventListener(FilterEvent.PROCESS_COMPLETE, _filterPorcessComplete);
			_viewport.stopLoading();
			_displayFilter(evt.bitmapData);
		}
		
		private function _filterSelectedHandler(evt:Event):void
		{
			_disposeFilter();
			
			var activeItem:FilterItem = _filtersHandlers.activeItem;
			if(activeItem){
				var filtersConfig:Object = _filtersHandlers.activeItem.filtersConfig;
				var source:BitmapData = _viewport.getOriginalSourceCopyAt(0);
				_viewport.startLoading();
				FilterManager.instance.addEventListener(FilterEvent.PROCESS_COMPLETE, _filterPorcessComplete);
				FilterManager.instance.processor(source, FilterConfigParser.parse(filtersConfig));
			}else{
				var src:BitmapData = _viewport.getOriginalSourceCopyAt(0);
				_viewport.setSource(src, 0, src.width, src.height, true);
			}
		}
		/**
		 * 在背景图变化之前删除滤镜图层
		 */
		private function _viewportBeforeChange(evt:DataEvent):void
		{
			_disposeFilter();
		}
		/**
		 * 视口变化后，更新滤镜图标
		 */
		private function _viewportChanged(evt:Event):void
		{
			//希望在viewport更新后更新滤镜图标，不过太多图标会UI线程，再想办法
			//setTimeout(_rerenderFilterHandlers, 500);
		}
		
		private function _rerenderFilterHandlers():void
		{
			var layerSource:BitmapData = _viewport.getLayerAt(0).viewSourceCopy;
			var len:int = _filtersHandlers.getComponentCount(),
				sor:BitmapData = new BitmapData(40, 40);
			
			sor.draw(layerSource);
			
			for(var i:int = 0; i < len; i ++){
				var item:FilterItem = _filtersHandlers.getComponent(i) as FilterItem;
				item.setSource(sor.clone());
			}
			
			layerSource.dispose();
			sor.dispose();
		}
		
		/**
		 * 监听设置浮层的事件
		 */
		private function _dialogEventHandler(evt:Event):void
		{
			switch(evt.type){
				case FilterDialog.EVENT_OK:
					_doFilter();
					break;
				case FilterDialog.EVENT_CANCEL:
					_disposeFilter();
					break;
			}
		}
		
		/**
		 * 隐藏设置浮层
		 */
		private function _hideDialog():void
		{
			_setupDialog.unbindViewport();
			_viewport.stage.removeChild(_setupDialog);
		}
		/**
		 * 展现设置浮层
		 */
		private function _showDialog():void
		{
			_viewport.stage.addChild(_setupDialog);
			_setupDialog.bindViewport(_viewport, 1, 0);
			_setupDialog.setMixValue(100);
		}
		/**
		 * 移除滤镜展现
		 */
		private function _disposeFilter():void
		{
			if(_hasFilter){
				_viewport.removeLayerAt(1);
				_hideDialog();
				_hasFilter = false;
			}
		}
		/**
		 * 展现滤镜
		 */
		private function _displayFilter(filterSource:BitmapData):void
		{
			//在viewport新增一个图层 做滤镜混合展示
			_viewport.setSource(filterSource, 1, filterSource.width, filterSource.height, true);
			
			var layer:ViewportLayer = _viewport.getLayerAt(1);
			//动画效果
			TweenLite.killTweensOf(layer, true);
			layer.alpha = 0;
			TweenLite.to(layer, 1, {
				alpha : 1
			});
			
			_showDialog();
			_hasFilter = true;
		}
		/**
		 * 将滤镜应用到原图
		 */
		private function _doFilter():void
		{
			if(!_hasFilter) return;
			var backLayer:ViewportLayer = _viewport.getLayerAt(0),
				filterLayer:ViewportLayer = _viewport.getLayerAt(1),
				backSrc:BitmapData = backLayer.originalBackgroundSourceCopy,
				filterSrc:BitmapData = filterLayer.originalBackgroundSourceCopy;
			//删除滤镜浮层展现
			_disposeFilter();
			backSrc.draw(filterSrc, null, new ColorTransform(1, 1, 1, filterLayer.alpha));
			backLayer.setBackgroundSource(backSrc, true);
			//清空内存
			filterSrc.dispose();
			backSrc.dispose();
		}
		
		
	}
}