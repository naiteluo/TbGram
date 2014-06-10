package ui
{
	import com.greensock.TweenLite;
	
	import flash.display.Bitmap;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.net.FileReferenceList;
	
	import ui.basic.ImageItem;

	public class ImageNav extends Sprite
	{
		public static const ACTIVE_CHANGE:String = 'active_change';
		private static const _FILE_FILTERS:String = "*.jpg;*.gif;*.png";
		
		[Embed (source="../../images/add_files_default.png")]
		private static var _addFilesDefaultSrc:Class;
		
		[Embed (source="../../images/add_files_over.png")]
		private static var _addFilesOverSrc:Class;
		
		private const _itemWidth:Number = 40;
		private const _itemHeight:Number = 40;
		private const _alpha:Number = 0.4;
		private const _alphaHover:Number = 0.8;
		private const _alphaActive:Number = 1;
		private const _itemGap:Number = 2;
		
		private var _list:Vector.<ImageItem>;
		private var _listWrap:Sprite;
		private var _activeIdx:int = -1;
		private var _maxLength:int = 0;
		private var _width:Number;
		private var _addFileBtn:SimpleButton;
		private var _frlist:FileReferenceList;
		
		public function ImageNav(
			width:Number,
			maxLength:int=0
		)
		{
			super();
			
			_width = width;
			_listWrap = new Sprite;
			this.addChild(_listWrap);
			_maxLength = maxLength;
			_addFileBtn = _createAddFilesBtn();
			_listWrap.addChild(_addFileBtn);
			_listWrap.x = _getOffsetByActive(0);
			_listWrap.y = _itemGap;
			
			_frlist = new FileReferenceList;
			_frlist.addEventListener(Event.SELECT, _frlistSelected);
		}
		
		public function setSourceList(sourceList:Array, activeIdx:int = 0):void
		{
			_clearList();
			
			var len:int = (_maxLength > 0) ? Math.min(_maxLength, sourceList.length) : sourceList.length;
			_list = new Vector.<ImageItem>;
			for(var i:int = 0; i < len; i ++){
				_createItem(sourceList[i], i);
			}
			
			this.active = activeIdx;
			_listWrap.addChild(_addFileBtn);
			_addFileBtn.x = (_itemWidth + _itemGap) * _list.length;
			_listWrap.x = _getOffsetByActive(this.active);
			
		}
		
		public function addSourceList(sourceList:Array):void
		{
			if(!_list) _list = new Vector.<ImageItem>;
			var oldlen:int = _list.length;
			var len:int = sourceList.length + oldlen;
			len = (_maxLength > 0) ? Math.min(_maxLength, len) : len;
			len -= oldlen;
			for(var i:int = 0; i < len; i ++){
				_createItem(sourceList[i], oldlen + i);
			}
			
			this.active = oldlen;
			_listWrap.addChild(_addFileBtn);
			_addFileBtn.x = (_itemWidth + _itemGap) * _list.length;
			_listWrap.x = _getOffsetByActive(this.active);
		}
		
		public function set active(idx:int):void
		{
			if(!_list || idx < 0 || idx > _list.length - 1) return;
			if(_activeIdx != idx){
				(_activeIdx >= 0 && _activeIdx <= _list.length - 1) && (_list[_activeIdx].status = false);
				_activeIdx = idx;
				
				var it:ImageItem = _list[idx] as ImageItem;
				it.status = true;
				
				if(it.isLoaded)
					_itemLoaded();
				else
					it.addEventListener(ImageItem.EVENT_LOADED, _itemLoaded);
			}
		}
		
		public function get active():int
		{
			return _activeIdx;
		}
        
        public function getListLength():int
        {
            return _list.length;
        }
		
		public function getItemAt(idx:int):ImageItem
		{
			return _list[idx];
		}
		
		public function scrollToIndex(idx:int):void
		{
			if(!_list || idx < 0 || idx > _list.length - 1) return;
			
			TweenLite.killTweensOf(_listWrap, true);
			TweenLite.to(_listWrap, 0.3, {
				x : _getOffsetByActive(idx)
			});
			
			this.active = idx;
		}
		
		private function _createItem(source:FileReference, idx:int):ImageItem
		{
			var it:ImageItem = 	new ImageItem(
				source as FileReference, _itemWidth, _itemHeight, true, ImageItem.INSERT_MODE_OUT, 
				0, 0, 0, 0, 0, _alpha, _alphaHover, _alphaActive);
			_list.push(it);
			it.index = idx;
			it.x = (_itemWidth + _itemGap) * idx;
			_listWrap.addChild(it);
			it.addEventListener(MouseEvent.CLICK, _itemClickHandler);
			return it;
		}
		
		private function _getOffsetByActive(idx:int):Number
		{
			return _width / 2 - (_itemWidth + _itemGap) * idx;
		}
		
		private function _itemLoaded(evt:Event = null):void
		{
			evt && evt.target.removeEventListener(ImageItem.EVENT_LOADED, _itemLoaded);
			this.dispatchEvent(new Event(ACTIVE_CHANGE));
		}
		
		private function _itemClickHandler(evt:MouseEvent):void
		{
			var it:ImageItem = evt.target as ImageItem;
			scrollToIndex(it.index);
		}
		
		private function _clearList():void
		{
			_activeIdx = -1;
			
			_list && (_list.length = 0);
			
			while(_listWrap.numChildren > 0){
				_listWrap.getChildAt(0).removeEventListener(MouseEvent.CLICK, _itemClickHandler);
				_listWrap.removeChildAt(0);
			}
		}
		/**
		 * 创建添加文件按钮
		 */
		private function _createAddFilesBtn():SimpleButton
		{
			var bit:Bitmap = new _addFilesDefaultSrc as Bitmap;
			var bito:Bitmap = new _addFilesOverSrc as Bitmap;
			var sbtn:SimpleButton = new SimpleButton(bit, bito, bit, bit);
			sbtn.addEventListener(MouseEvent.CLICK, _addFilesHandler);
			return sbtn;
		}
		
		//_____________file reference__________________
		
		private function _addFilesHandler(evt:MouseEvent):void
		{
			_frlist.browse([new FileFilter('images', _FILE_FILTERS)]);
		}
		
		private function _frlistSelected(evt:Event):void
		{
			this.addSourceList(_frlist.fileList);
		}
        
	}
}





