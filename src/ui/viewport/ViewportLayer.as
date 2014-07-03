package ui.viewport
{
	import com.imagelib.utils.Transformer;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	
	import ui.viewport.ViewportEvent;

	public class ViewportLayer extends Sprite
	{
		public static const ROTATION_MODE:Array = [0, 90, 180, 270];
		
		private var _viewportWidth:Number;							//视图宽度
		private var _viewportHeight:Number;							//视图高度
		private var _layerWidth:Number;
		private var _layerHeight:Number;
		
		private var _backgroundViewer:Bitmap;				//背景显示图
		private var _originalSource:BitmapData;				//原图数据
        private var _originalSourceOfGif:ByteArray;
		
		public function ViewportLayer(viewportwidth:Number, viewportHeight:Number, layerWidth:Number, layerHeight:Number)
		{
			_viewportWidth = viewportwidth;			//视图的宽度
			_viewportHeight = viewportHeight;		//视图高度
			_layerWidth = layerWidth;
			_layerHeight = layerHeight;
		}
		
		/**
		 * 获取在视口范围内自适应缩放后的结果
		 */
		private function _getAutoResize(size:Rectangle):Rectangle
		{
			var w:Number = size.width,
				h:Number = size.height,
				result:Rectangle = new Rectangle;
			
			if(w <= _viewportWidth && h <= _viewportHeight)
				return size;
			
			if(w / h > _viewportWidth / _viewportHeight){
				result.width = _viewportWidth;
				result.height = _viewportWidth / (w / h);
			}else{
				result.height = _viewportHeight;
				result.width = _viewportHeight * (w / h);
			}
			
			return result;
		}
		/**
		 * 重新渲染视口图层
		 * @param	source	{BitmapData}	渲染的图片数据
		 */
		private function _renderViewport(source:BitmapData):void
		{
			this.dispatchEvent(new Event(ViewportEvent.BEFORE_CHANGE));
			
			var size:Rectangle = _getAutoResize(new Rectangle(0, 0, source.width, source.height)),
				bitmapData:BitmapData,
				m:Matrix = new Matrix(),
				scale:Number = size.width / source.width;
			
			size = new Rectangle(0, 0, source.width * scale, source.height * scale);
			
			m.scale(size.width / source.width, size.width / source.width);
			
			this.clearViewportBackground();
			_backgroundViewer = new Bitmap();
			this.addChild(_backgroundViewer);
			
			bitmapData = new BitmapData(size.width, size.height);
			
			bitmapData.draw(source, m, null, null, null, true);
			_backgroundViewer.bitmapData = bitmapData;
			
			source.dispose();
			
			this.dispatchEvent(new Event(ViewportEvent.CHANGE));
		}
		/**
		 * 旋转原图
		 */
		private function _rotateOriginalSource(rotation:Number):void
		{
			if(!_originalSource || rotation == 0) return;
			if(ROTATION_MODE.indexOf(rotation) < 0 || !_originalSource) return;
			var m:Matrix = new Matrix,
				w:Number = _originalSource.width,
				h:Number = _originalSource.height,
				temp:BitmapData = _originalSource.clone();
			
			_originalSource.dispose();
			
			m.translate(- w / 2, - h / 2);
			m.rotate(Transformer.angleToRadian(rotation));
			if(rotation == 0 || rotation == 180){
				m.translate(w / 2, h / 2);
				_originalSource = new BitmapData(w, h);
			}else{
				m.translate(h / 2, w / 2);
				_originalSource = new BitmapData(h, w);
			}
			
			_originalSource.draw(temp, m, null, null, null, true);
			temp.dispose();
		}
		
		private function _getRenderSource(source:BitmapData):BitmapData
		{
			if(_layerWidth == source.width && _layerHeight == source.height) 
				return source;
			var result:BitmapData = new BitmapData(_layerWidth, _layerHeight);
			result.draw(source);
			return result;
		}
		
		//__________setters____________
		/**
		 * 设置背景图资源 如不更新原图数据则只作预览
		 */
		public function setBackgroundSource(source:BitmapData, updateOriginalSource:Boolean=true):void
		{
			var renderSource:BitmapData = _getRenderSource(source);
			
			if(updateOriginalSource){
				_originalSource && _originalSource.dispose();
				_originalSource = renderSource.clone();
			}
			_renderViewport(renderSource);
		}
        
        /**
         * 设置背景图资源 如不更新原图数据则只作预览 GIF
         */
        public function setBackgroundSourceGIF(sourceOfGIF:ByteArray, source:BitmapData, updateOriginalSource:Boolean=true):void
        {
            var renderSource:BitmapData = _getRenderSource(source);
            
            if(updateOriginalSource){
                _originalSource && _originalSource.dispose();
                _originalSource = renderSource.clone();
            }
            _renderViewport(renderSource);
        }
		
		/**
		 * 旋转，只支持4个角度 0, 90, 180, 270
		 */
		public function set viewportRotation(rotation:int):void
		{
			if(ROTATION_MODE.indexOf(rotation) < 0 || !_originalSource) return;
			_rotateOriginalSource(rotation);			//旋转原图
			_renderViewport(_originalSource.clone());	//渲染
		}
		
		//___________getters_____________
		
		public function get originalBackgroundSourceCopy():BitmapData
		{
			return _originalSource.clone();
		}
		
		public function get viewSourceCopy():BitmapData
		{
			return _backgroundViewer.bitmapData.clone();
		}
		
		public function get viewportScale():Number
		{
			if(!_backgroundViewer) return 0;
			return _backgroundViewer.width / _originalSource.width;
		}
		
		/**
		 * 获取视口尺寸
		 */
		public function get layerSize():Rectangle
		{
			if(!_backgroundViewer) return new Rectangle;
			return new Rectangle(0, 0, _backgroundViewer.width, _backgroundViewer.height);
		}
		
		//___________methods_____________
		/**
		 * 清空背景显示
		 */
		public function clearViewportBackground():void
		{
			if(_backgroundViewer){
				_backgroundViewer.bitmapData.dispose();
				this.removeChild(_backgroundViewer);
				this.dispatchEvent(new Event(ViewportEvent.CLEAR));
			}
		}
		/**
		 * 剪裁
		 */
		public function clipLayer(clipRect:Rectangle):void
		{
			var scale:Number = this.viewportScale;
			trace(scale);
			var originalClipRect:Rectangle = new Rectangle(
				clipRect.x / scale,
				clipRect.y / scale,
				clipRect.width / scale,
				clipRect.height / scale
			);
			
			var temp:BitmapData = new BitmapData(originalClipRect.width, originalClipRect.height);
			var m:Matrix = new Matrix;
			m.translate(- originalClipRect.x, - originalClipRect.y);
			temp.draw(_originalSource, m, null, null, null, false);
			_layerWidth = originalClipRect.width;
			_layerHeight = originalClipRect.height;
			this.setBackgroundSource(temp);
			temp.dispose();
		}
		public function setLayerSizeWH(width:Number, height:Number, update:Boolean=false):void
		{
			if(_layerWidth == width || _layerHeight == height) return;
			_layerWidth = width;
			_layerHeight = height;
			update && setBackgroundSource(_originalSource);
		}
		/**
		 * 销毁，清除内存
		 */
		public function dispose():void
		{
			clearViewportBackground();
			_originalSource && _originalSource.dispose();
			this.dispatchEvent(new Event(ViewportEvent.DISPOST));
		}
	}
}





