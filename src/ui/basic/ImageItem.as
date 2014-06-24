package ui.basic
{
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	
	import org.aswing.ASColor;
	import org.aswing.JPanel;
	import org.aswing.border.LineBorder;
	import org.aswing.geom.IntDimension;
	import org.bytearray.gif.player.GIFPlayer;
	
	public class ImageItem extends JPanel
	{
		public static const EVENT_LOADED:String = 'loaded';
		public static const INSERT_MODE_IN:String = 'in';
		public static const INSERT_MODE_OUT:String = 'out';
		/**
		 * 表示原图数据状态
		 */
		public static const STATUS_NONE:int = -1;		//没有原图			
		public static const STATUS_NOCHANGE:int = 0;	//有原图，没被修改过
		public static const STATUS_CHANGED:int = 1;		//被修改过
		
        private var _inputSource:*;
        
		protected var _width:Number = 60;
		protected var _height:Number = 60;
		protected var _round:Number = 10;
		protected var _borderWeight:Number = 2;
		protected var _borderColor:uint=0;
		protected var _borderColorHover:uint = 0;
		protected var _borderColorSelected:uint = 0;
		protected var _alpha:Number = 1;
		protected var _alphaHover:Number = 1;
		protected var _alphaSelected:Number = 1;
		protected var _bgColor:uint = 0;
		protected var _insertMode:String = 'in';
		protected var _previewWrap:Sprite;
		protected var _loader:Loader;
		protected var _preview:Bitmap;
		protected var _source:BitmapData;
		protected var _originalSource:BitmapData;		//原始图片数据
        protected var _originalSourceOfGIF:ByteArray;   //GIF使用的原图二进制数据
		protected var _review:Bitmap;
		protected var _status:Boolean;
		protected var _isLoaded:Boolean;
		protected var _isCacheOriginal:Boolean;
		protected var _sourceStatus:int = -1;				//标识原图是否被修改过 -1 无数据 
        protected var _isGIF:Boolean = false;                       //标识是否GIF
        
		
		public var index:int = 0;
		
		public function ImageItem(
			source:*,								//图片资源，BitmapData or String(url) or FileReference
			width:Number,							//宽度
			height:Number,							//高度
			isCacheOriginal:Boolean = false,			//是否缓存原图数据
			insertMode:String = 'in',				//图片嵌入模式
			bgColor:uint=0,							//底色
			borderWeight:int=0,						//边框粗细
			borderColor:uint=0,						//边框颜色
			borderColorHover:uint=0,				//hover边框颜色
			borderColorSelected:uint=0,				//selected边框颜色
			alpha:Number=1,							//透明度
			alphaHover:Number=1,					//hover透明度
			alphaSelected:Number=1,					//selected透明度
			round:int=0								//圆角
		)
		{
			super(null);
            
            _inputSource = source;
			
			_width = width;
			_height = height;
			_bgColor = bgColor;
			_borderWeight = borderWeight;
			_borderColor = borderColor;
			_borderColorHover = borderColorHover;
			_borderColorSelected = borderColorSelected;
			_alpha = alpha;
			_alphaHover = alphaHover;
			_alphaSelected = alphaSelected;
			_round = round;
			_insertMode = insertMode;
			_isCacheOriginal = isCacheOriginal;
			
			this.alpha = _alpha;
			
			this.buttonMode = true;
			this.setSizeWH(width, height);
			this.setPreferredSize(new IntDimension(width + borderWeight * 2, height + borderWeight * 2));
			if(_borderWeight > 0){
				this.setBorder(new LineBorder(null, new ASColor(borderColor), borderWeight, _round));
			}
			
			if(source is String){
				_loader = new Loader();
				_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, _imageLoaded);
                _inputSource = new URLRequest(source);
				_loader.load(_inputSource);
			}else if(source is BitmapData){
				var s:BitmapData = new BitmapData(source.width, source.height);
				s.copyPixels(source, new Rectangle(0, 0, source.width, source.height), new Point(0, 0));
				_build(s);
			}else if(source is FileReference){
				_loader = new Loader();
				_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, _imageLoaded);
				_fileReferenceLoad(source as FileReference);
			}
		}
		protected function _imageLoaded(evt:Event):void
		{
			_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, _imageLoaded);
            
            // todo 对gif的特殊处理
            if (_loader.contentLoaderInfo.contentType == 'image/gif') {
                _isGIF = true;
                if (_inputSource is FileReference) {
                    _originalSourceOfGIF = (_inputSource as FileReference).data;
                } else if (_inputSource is URLRequest) {
                    _originalSourceOfGIF = _loader.contentLoaderInfo.bytes;
                }
            }
            
			_build();
		}
		private function _fileReferenceLoad(fr:FileReference):void
		{
			fr.addEventListener(Event.COMPLETE, _fileReferenceLoaded);
			fr.load();
		}
		private function _fileReferenceLoaded(evt:Event):void
		{
			_loader.loadBytes((evt.target as FileReference).data);
		}
		
		protected function _build(source:BitmapData=null):void
		{
			_previewWrap = new Sprite();
			
			_previewWrap.graphics.beginFill(_bgColor);
			_previewWrap.graphics.drawRect(0, 0, _width, _height);
			_previewWrap.graphics.endFill();
			
			_previewWrap.x = _borderWeight;
			_previewWrap.y = _borderWeight;
			_previewWrap.mouseEnabled = false;
			_previewWrap.mouseChildren = false;
			this.addChild(_previewWrap);
			
			_preview = new Bitmap(null, 'auto', true);
			_previewWrap.addChild(_preview);
			
			setSource(source);
			
			this.addEventListener(MouseEvent.ROLL_OVER, _mouseenterHandler);
			this.addEventListener(MouseEvent.ROLL_OUT, _mouseleaveHandler);
			
			_isLoaded = true;
            
            if (_isGIF) {
                _preview.visible = false;
                var gifPlayer:GIFPlayer = new GIFPlayer();
                gifPlayer.loadBytes(_originalSourceOfGIF);
                _previewWrap.addChild(gifPlayer);
            }
			this.dispatchEvent(new Event(EVENT_LOADED));
		}
		protected function _mouseenterHandler(evt:MouseEvent):void
		{
			if(this.status == false){
				this.setBorder(new LineBorder(null, new ASColor(_borderColorHover), _borderWeight, _round));
				this.alpha = _alphaHover;
			}
		}
		protected function _mouseleaveHandler(evt:MouseEvent):void
		{
			if(this.status == false){
				this.setBorder(new LineBorder(null, new ASColor(_borderColor), _borderWeight, _round));
				this.alpha = _alpha;
			}
		}
		private function _getInsertMatrix(source:BitmapData):Matrix
		{
			
			var matrix:Matrix = new Matrix(),
				scale:Number = 1,
				w:Number = source.width,
				h:Number = source.height;
			
			if(_insertMode == INSERT_MODE_IN){
				if(w / h > _width / _height) scale = _width / w;
				else scale = _height / h;
			}else if(_insertMode == INSERT_MODE_OUT){
				if(w / h > _width / _height) scale = _height / h;
				else scale = _width / w;
			}
			
			matrix.translate(- w/2, - h/2);
			matrix.scale(scale, scale);
			matrix.translate(_width / 2, _height / 2);
			
			return matrix;
		}
		
		public function setSource(source:BitmapData=null):void
		{
			//更改原图状态
			if(_sourceStatus == STATUS_NONE)
				_sourceStatus = STATUS_NOCHANGE;
			else
				_sourceStatus = STATUS_CHANGED
			
			reset();
			_source = new BitmapData(_width, _height, true, 0x00000000);
			
			if(!source){
				var bm:Bitmap = _loader.contentLoaderInfo.content as Bitmap;
				_source.draw(bm, _getInsertMatrix(bm.bitmapData), null, null, null, true);
				if(_isCacheOriginal){
					_originalSource = bm.bitmapData;	//记录原图
				}else{
					bm.bitmapData.dispose();
					_loader.unload();
				}
			}else{
				_source.draw(source, _getInsertMatrix(source), null, null, null, true);
				if(_isCacheOriginal){
					_originalSource = source;
				}else{
					source.dispose();
				}
			}
			
			_preview.bitmapData = _source;
		}
		
		public function set status(isSelected:Boolean):void
		{
			if(isSelected){
				this.setBorder(new LineBorder(null, new ASColor(_borderColorSelected), _borderWeight, _round));
				this.alpha = _alphaSelected;
				_status = true;
			}else{
				this.setBorder(new LineBorder(null, new ASColor(_borderColor), _borderWeight, _round));
				this.alpha = _alpha;
				_status = false;
			}
		}
		public function get status():Boolean
		{
			return _status;
		}
		public function get isLoaded():Boolean
		{
			return _isLoaded;
		}
		public function get bitmapData():BitmapData
		{
			return _preview.bitmapData;
		}
		public function get originalBitmapData():BitmapData
		{
			return _originalSource;
		}
        public function get originalByteArray():ByteArray
        {
            return _originalSourceOfGIF;
        }
        public function get isGIF():Boolean
        {
            return _isGIF;
        }
		
		/**
		 * 获取图片数据状态 STATUS_NONE、STATUS_NOCHANGE、STATUS_CHANGED
		 */
		public function get sourceStatus():int
		{
			return _sourceStatus;
		}
		public function reset():void
		{
			_originalSource && _originalSource.dispose();
			_preview && _preview.bitmapData && _preview.bitmapData.dispose();
		}
	}
}