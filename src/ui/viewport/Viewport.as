package ui.viewport
{
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.filters.DropShadowFilter;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	
	import org.aswing.JPanel;
	
	import ui.viewport.ViewportLayer;
	
	public class Viewport extends JPanel
	{
		private static const _padding:Number = 30;
		
		[Embed(source="../../../images/tb_loading.swf")]
		private static var Loading:Class;		//loading图标
		private var _layersContainer:Sprite;
		
		private var _viewportScale:Number;
		private var _viewportRotation:Number;
		private var _loading:MovieClip;
		
		public function Viewport()
		{
			super(null);
			_build();
		}
		
		private function _build():void
		{
			_loading = new Loading();
			_layersContainer = new Sprite;
			_layersContainer.mouseChildren = false;
			_layersContainer.mouseEnabled = false;
			
			this.addChild(_layersContainer);
			
		}
		/**
		 * 重新定位所有图层
		 */
		private function _resetPosition():void
		{
			var layer:ViewportLayer = this.getLayerAt(0);
			if(!layer) return;
			var size:Rectangle = layer.layerSize;
			_layersContainer.x = (this.width - size.width) / 2;
			_layersContainer.y = (this.height - size.height) / 2;
		}
		/**
		 * 监听图层更改事件
		 */
		private function _layerChanged(evt:Event):void
		{
			var layer:ViewportLayer = evt.target as ViewportLayer;
			var idx:int = _layersContainer.getChildIndex(layer);
			//只有最下层更新会更改定位
			if(idx == 0)
				_resetPosition();
			
			this.dispatchEvent(new DataEvent(ViewportEvent.CHANGE, false, false, idx.toString()));
		}
		private function _layerBeforeChange(evt:Event):void
		{
			var layer:ViewportLayer = evt.target as ViewportLayer;
			var idx:int = _layersContainer.getChildIndex(layer);
			this.dispatchEvent(new DataEvent(ViewportEvent.BEFORE_CHANGE, false, false, idx.toString()));
		}
		/***
		 * @desc	设置图片资源
		 * @param	source			{BitmapData}	图片资源
		 * @param	layerIndex		{int}			所在图层
		 * @param	updateOriginal	{Boolean}		是否更新原图数据
		 */
		public function setSource(source:BitmapData, layerIndex:int, layersWidth:Number, layersHeight:Number, updateOriginal:Boolean = true):void
		{
			//不能插入0级
			var layer:ViewportLayer,
				_layerWidth:Number,
				_layerHeight:Number;
			
			if(layerIndex >= _layersContainer.numChildren){
				var idx:int = _layersContainer.numChildren;
				if(idx > 0){
					var layerBottom:ViewportLayer = this.getLayerAt(0),
						size:Rectangle = layerBottom.layerSize;
					_layerWidth = size.width;
					_layerHeight = size.height;
				}else{
					_layerWidth = source.width;
					_layerHeight = source.height;
				}
				layer = this.addLayerAt(_layersContainer.numChildren, _layerWidth, _layerHeight);
			}else{
				layer = this.getLayerAt(layerIndex);
			}
			
			layersWidth && (_layerWidth =  layersWidth);
			layersHeight && (_layerHeight = layersHeight);
			layer.setLayerSizeWH(layersWidth, layersHeight);
			layer.setBackgroundSource(source, updateOriginal);
		}
		/**
		 * 添加一个图层
		 * @return 添加的层级
		 */
		public function addLayerAt(index:int, layerWidth:Number, layerHeight:Number):ViewportLayer
		{
			var layer:ViewportLayer = new ViewportLayer(this.width - _padding * 2, this.height - _padding * 2, layerWidth, layerHeight);
			layer.addEventListener(ViewportEvent.CHANGE, _layerChanged);
			layer.addEventListener(ViewportEvent.BEFORE_CHANGE, _layerBeforeChange);
			index = Math.min(index, _layersContainer.numChildren);
			_layersContainer.addChildAt(layer, index);
			
			if(index == 0)
				layer.filters = [new DropShadowFilter(5, 45, 0, 0.7, 25, 25, 1, 2)];
			
			return layer;
		}
		public function removeLayerAt(index:int):void
		{
			var layer:ViewportLayer = getLayerAt(index);
			layer.removeEventListener(ViewportEvent.CHANGE, _layerChanged);
			layer.removeEventListener(ViewportEvent.BEFORE_CHANGE, _layerBeforeChange);
			layer.dispose();
			_layersContainer.removeChildAt(index);
		}
		public function getLayerAt(index:int):ViewportLayer
		{
			if(index >= _layersContainer.numChildren) return null;
			return _layersContainer.getChildAt(index) as ViewportLayer;
		}
		/**
		 * 交换两个图层层级
		 */
		public function swapLayer(index1:int, index2:int):void
		{
			_layersContainer.swapChildrenAt(index1, index2);
		}
		
		//__________________getters and setters___________________________
		/***
		 * @desc	获取原图数据的拷贝
		 */
		public function getOriginalSourceCopyAt(index:int=0):BitmapData
		{
			var layer:ViewportLayer = this.getLayerAt(index);
			return layer.originalBackgroundSourceCopy;
		}
		/**
		 * 获取视口预览图和原图尺寸比
		 */
		public function get viewportScale():Number
		{
			var layer:ViewportLayer = this.getLayerAt(0);
			if(!layer) return 0;
			return layer.viewportScale;
		}
		/**
		 * 获取视口图位置和尺寸
		 */
		public function get viewportRect():Rectangle{
			var layer:ViewportLayer = this.getLayerAt(0);
			var rect:Rectangle = layer.layerSize;
			rect.x = _layersContainer.x;
			rect.y = _layersContainer.y;
			return rect;
		}
		/**
		 * 获取图片旋转角度
		 */
		public function get viewportRotation():int
		{
			return _viewportRotation;
		}
		/**
		 * 获取所有层
		 */
		public function get layers():Vector.<ViewportLayer>
		{
			var ls:Vector.<ViewportLayer> = new Vector.<ViewportLayer>,
				len:int = _layersContainer.numChildren;
			
			for(var i:int = 0; i < len; i ++){
				ls.push(_layersContainer.getChildAt(i) as ViewportLayer);
			}
			return ls;
		}
		
		/**
		 * 执行旋转
		 * */
		public function set viewportRotation(rotation:int):void
		{
			var len:int = _layersContainer.numChildren;
			for(var i:int = 0; i < len; i ++){
				var layer:ViewportLayer = this.getLayerAt(i);
				if(!layer) break;
				layer.viewportRotation = rotation;
			}
		}
		/**
		 * 合并图层
		 * @param	startIndex		{int}		开始合并的图层层级
		 * @param	count			{int}		从startIndex向上合并的图层总数
		 */
		public function mergeLayers(startIndex:int, count:int=0):void
		{
			if(count < 0 || startIndex > _layersContainer.numChildren - 1) return;
			(!count) && (count = _layersContainer.numChildren - 1);
			
			var back:BitmapData = this.getLayerAt(startIndex).originalBackgroundSourceCopy,
				len:int = _layersContainer.numChildren;
			for(var i:int = startIndex + 1; i < count; i ++){
				if(startIndex + 1 > _layersContainer.numChildren - 1) break;
				var forelayer:ViewportLayer = this.getLayerAt(startIndex + 1);
				var fore:BitmapData = forelayer.originalBackgroundSourceCopy;
				back.draw(fore, null, new ColorTransform(1, 1, 1, forelayer.alpha));
				fore.dispose();
				this.removeLayerAt(startIndex + 1);
			}
			
			this.setSource(back, startIndex, back.width, back.height, true);
			back.dispose();
		}
		
		/**
		 * 剪裁图片
		 */
		public function clip(clipRect:Rectangle):void{
			var len:int = _layersContainer.numChildren;
			for(var i:int = 0; i < len; i ++){
				var layer:ViewportLayer = this.getLayerAt(i);
				layer.clipLayer(clipRect);
			}
		}
		
		public function startLoading():void
		{
			this.addChild(_loading);
			_loading.x = this.getWidth() / 2;
			_loading.y = this.getHeight() / 2;
		}
		
		public function stopLoading():void
		{
			this.contains(_loading) && this.removeChild(_loading);
		}
	}
}