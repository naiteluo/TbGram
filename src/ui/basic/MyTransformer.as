package ui.basic
{
	import com.imagelib.mouse.CustomMouse;
	import com.imagelib.utils.Transformer;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	
	public class MyTransformer extends Sprite
	{
		public static const EVENT_ACTIVE_CHANGE:String = 'active_change';
		public static const EVENT_SIZE_CHANGE:String = 'size_change';
		public static const EVENT_ANGLE_CHANGE:String = 'angle_change';
		
		public static const FLIP_DIRCTION_VERTICAL:String = 'vertical';			//垂直翻转
		public static const FLIP_DIRCTION_HORIZONTAL:String = 'horizontal';		//水平翻转
		//三个状态，表示当前是旋转模式还是缩放模式或者拖拽模式，或者none
		protected const MODE_RESIZE:String = 'resize';
		protected const MODE_ROTATE:String = 'rotate';
		protected const MODE_DRAG:String = 'drag';
		protected const MODE_NONE:String = 'none';
		
		protected const UI_BORDER_WEIGHT:Number = 1;
		protected const UI_COLOR:uint = 0xffffff;
		protected const UI_BORDER_COLOR:uint = 0x6f9cde;
		
		protected var _container:Sprite = new Sprite(); //裁剪UI容器
		protected var _parent:DisplayObjectContainer;
		protected var _minScale:Number;					//最小缩放比
		protected var _maxScale:Number;					//最大缩放比
		
		protected var _originalWidth:Number;				//原图宽度
		protected var _originalHeight:Number;				//原图高度
	
		protected var _target:DisplayObject;
		protected var _uilayer:Sprite;					//UI绘制层
		protected var _resizeNW:Sprite;
		protected var _resizeNE:Sprite;
		protected var _resizeSW:Sprite;
		protected var _resizeSE:Sprite;
		
		protected var _dragStartPoint:Point;				//开始拖拽时鼠标坐标
		protected var _rotateStartRadianInMouse:Number;	//开始旋转的时候鼠标和中心点连线的弧度
		protected var _resizeStartDaigLen:Number;			//开始缩放时，鼠标到中心点的距离
		
		protected var _currentScale:Number=1;				//当前相对原图的缩放比
		protected var _currentRotation:Number=0;			//目前素材旋转的角度
		protected var _currentRect:Rectangle = new Rectangle(); //当前裁剪框的rect
		
		protected var _mode:String = 'none';				//标识当前的模式 缩放还是旋转
		protected var _isFlipedH:Boolean = false;			//是否经过水平翻转
		protected var _isFlipedV:Boolean = false;			//是否经过垂直翻转
		protected var _isActive:Boolean = false;
		
		public function MyTransformer(
		) {
		}
		public function init(
			target:DisplayObject,
			targetWidth:Number,
			targetHeight:Number,
			viewport:DisplayObjectContainer,
			scale:Number=1,
			rotation:Number=0,
			minScale:Number=0,
			maxScale:Number=1
		):void
		{
			_target = target;
			_originalWidth = targetWidth;
			_originalHeight = targetHeight;
			_parent = viewport;
			_currentScale = scale;
			_currentRotation = rotation;
			_minScale = minScale;
			_maxScale = maxScale;
			
			//注册自定义鼠标
			CustomMouse.registerCursors([
				CustomMouse.CURSOR_NESW,
				CustomMouse.CURSOR_NWSE,
				CustomMouse.CURSOR_ROTATE_NW,
				CustomMouse.CURSOR_ROTATE_NE,
				CustomMouse.CURSOR_ROTATE_SW,
				CustomMouse.CURSOR_ROTATE_SE
			]);
			
			_buildUI();
		}
		/**
		 * 构建饰品操作ui
		 */
		protected function _buildUI():void
		{
			_uilayer = new Sprite;
			_uilayer.visible = _isActive;
			
			_resizeNW = _drawHitDot();
			_resizeNE = _drawHitDot();
			_resizeSW = _drawHitDot();
			_resizeSE = _drawHitDot();
			
			_container.addChild(_target);
			_container.addChild(_uilayer);
			this.addChild(_container);
			
			_updateCurrentRect();
			setTransform(_currentScale, _currentRotation, _isFlipedH, _isFlipedV);
			_bindEvents();
		}
		
		protected function _bindEvents():void
		{
			//拖拽
			_container.addEventListener(MouseEvent.MOUSE_DOWN, _initDrag);
			_parent.addEventListener(MouseEvent.MOUSE_MOVE, _doDrag);
			_parent.addEventListener(MouseEvent.MOUSE_UP, _endDrag);
			//缩放
			_parent.addEventListener(MouseEvent.MOUSE_DOWN, _initResize);
			_parent.addEventListener(MouseEvent.MOUSE_MOVE, _resizeParentMoveHandler);
			_parent.addEventListener(MouseEvent.MOUSE_UP, _resizeParentUpHandler);
			//旋转
			_parent.addEventListener(MouseEvent.MOUSE_DOWN, _rotateMouseDownHandler);
			_parent.addEventListener(MouseEvent.MOUSE_UP, _rotateMouseUpHandler);
			_parent.addEventListener(MouseEvent.MOUSE_MOVE, _rotateMouseMoveHandler);
			
			//_parent.addEventListener(Event.CHANGE, _targetChangeHandler);
			_parent.addEventListener(MouseEvent.MOUSE_MOVE, _changeCursorHandler);
			_parent.addEventListener(MouseEvent.ROLL_OUT, _outCursorHandler);
		}
		
		/**
		 * 绘制操作柄
		 */
		protected function _drawHitDot():Sprite
		{
			var obj:Sprite = new Sprite;
			with(obj.graphics){
				lineStyle(UI_BORDER_WEIGHT, UI_BORDER_COLOR);
				beginFill(UI_COLOR, 1);
				drawRect(0, 0, 10, 10);
				endFill();
			}
			_uilayer.addChild(obj);
			return obj;
		}
		
		/**
		 * 获取鼠标相对中心点的位置
		 */
		protected function _getMousePosAtCenterPoint(mouseX:Number, mouseY:Number):String
		{
			var pos:String = '';
			var cp:Point = _getCenterPoint();
			var dx:Boolean = (mouseX - cp.x >= 0);
			var dy:Boolean = (mouseY - cp.y >= 0);
			
			pos += (dy ? 'S' : 'N');
			pos += (dx ? 'E' : 'W');
			
			return pos;
		}
		
		protected function _changeCursorHandler(evt:MouseEvent):void
		{
			if((_mode != MODE_NONE && _mode != MODE_ROTATE) || !_isActive) return;
			var target:DisplayObject = evt.target as DisplayObject;
			var mouseOffset:Object = _getOffset({x:evt.stageX, y:evt.stageY}, _parent);
			var pos:String = _getMousePosAtCenterPoint(mouseOffset.x, mouseOffset.y);
			
			if(_mode == MODE_NONE){
				if([_resizeNW, _resizeSE, _resizeSW, _resizeNE].indexOf(target) >= 0){
					if(['NW', 'SE'].indexOf(pos) >= 0)
						CustomMouse.showCursor(CustomMouse.CURSOR_NWSE);
					else if(['SW', 'NE'].indexOf(pos) >= 0)
						CustomMouse.showCursor(CustomMouse.CURSOR_NESW);
				}else if(this.contains(target)){
					Mouse.cursor = MouseCursor.HAND;
				}
			}
			if(_mode == MODE_ROTATE || _mode == MODE_NONE){
				
				if(target == _parent){
					switch(pos){
						case 'NW':
							CustomMouse.showCursor(CustomMouse.CURSOR_ROTATE_NW);
							break;
						case 'SE':
							CustomMouse.showCursor(CustomMouse.CURSOR_ROTATE_SE);
							break;
						case 'SW':
							CustomMouse.showCursor(CustomMouse.CURSOR_ROTATE_SW);
							break;
						case 'NE':
							CustomMouse.showCursor(CustomMouse.CURSOR_ROTATE_NE);
							break;
						default:
							Mouse.cursor = MouseCursor.AUTO;
							break;
					}
				}
			}
			
		}
		protected function _outCursorHandler(evt:MouseEvent):void
		{
			Mouse.cursor = MouseCursor.AUTO;
		}
		
		
		/**********************************************************
		 ********************** 缩放和移动 start *******************
		 *********************************************************/
		
		protected function _initResize(evt:MouseEvent):void
		{
			if(!_isActive || _mode != MODE_NONE) return;
			if([_resizeNE, _resizeNW, _resizeSE, _resizeSW].indexOf(evt.target) < 0) return;
			_mode = MODE_RESIZE;
			_container.mouseEnabled = false;
			_container.mouseChildren = false;
			_parent.mouseChildren = false;
			//鼠标相对图片容器的坐标
			var offset:Object = _getOffset({x:evt.stageX, y:evt.stageY}, _parent);
			//计录鼠标到中心点距离
			_resizeStartDaigLen = _getDistance(new Point(offset.x, offset.y), _getCenterPoint());
			evt.stopImmediatePropagation();
		}
		
		protected function _resizeParentMoveHandler(evt:MouseEvent):void
		{
			if(_mode != MODE_RESIZE)
				return;
			//evt.stopImmediatePropagation();
			
			var offset:Object = _getOffset({x:evt.stageX, y:evt.stageY}, _parent);
			var daiglen:Number = _getDistance(new Point(offset.x, offset.y), _getCenterPoint());
			var k:Number = Math.max(0, daiglen / _resizeStartDaigLen);
			//限制缩放比在阈值范围内
			if(_currentScale * k <= _minScale) {
				k = _minScale / _currentScale;
				_currentScale = _minScale;
			}else if(_currentScale * k >= _maxScale){
				k = _maxScale / _currentScale;
				_currentScale = _maxScale;
			}else{
				_currentScale *= k;		//计算当前缩放比例	
			}
			//_currentRect = _rectScaleByCenterPoint(_currentRect, k);
			_updateCurrentRect();
			setTransform(_currentScale, _currentRotation, _isFlipedH, _isFlipedV);
			_resizeStartDaigLen = daiglen;
			
			this.dispatchEvent(new Event(EVENT_SIZE_CHANGE));
		}
		
		protected function _resizeParentUpHandler(event:MouseEvent):void
		{
			if (_mode == MODE_RESIZE) {
				_mode = MODE_NONE;
				event.preventDefault();
				_container.mouseEnabled = true;
				_container.mouseChildren = true;
				_parent.mouseChildren = true;
				event.stopImmediatePropagation();
			}
		}
		
		protected function _initDrag(event:MouseEvent):void
		{
			if(!_isActive) return;
			if(_mode != MODE_NONE || [_resizeNE, _resizeNW, _resizeSE, _resizeSW].indexOf(event.target) >= 0) return;
			_mode = MODE_DRAG;
			
			_dragStartPoint = new Point(event.stageX, event.stageY);
			_container.mouseEnabled = false;
			_container.mouseChildren = false;
			_parent.mouseChildren = false;
			event.stopImmediatePropagation();
		}
		protected function _doDrag(event:MouseEvent):void
		{
			if (_mode != MODE_DRAG) return;
			
			_container.x += event.stageX - _dragStartPoint.x;
			_container.y += event.stageY - _dragStartPoint.y;
			_dragStartPoint = new Point(event.stageX, event.stageY);
			_updateCurrentRect();
			event.stopImmediatePropagation();
		}
		protected function _endDrag(event:MouseEvent):void
		{
			if(_mode != MODE_DRAG) return
			_mode = MODE_NONE;
			_container.mouseEnabled = true;
			_container.mouseChildren = true;
			_parent.mouseChildren = true;
			event.stopImmediatePropagation();
		}
		protected function _updateCurrentRect():void {
			_currentRect.x = _container.x - _originalWidth / 2 * _currentScale;
			_currentRect.y = _container.y - _originalHeight / 2 * _currentScale;
			_currentRect.width = _originalWidth * _currentScale;
			_currentRect.height = _originalHeight * _currentScale ;
		}
		
		/**********************************************************
		 ********************** 缩放和移动 end *******************
		 *********************************************************/
		
		
		/**********************************************************
		 ********************** 旋转 start *******************
		 *********************************************************/
		protected function _rotateMouseDownHandler(evt:MouseEvent):void
		{
			if(!_isActive) return;
			if(evt.target != _parent || _mode != MODE_NONE) return;
			_mode = MODE_ROTATE;
			_container.mouseEnabled = false;
			_container.mouseChildren = false;
			_parent.mouseChildren = false;
			//记录开始旋转的时候鼠标和中心点连线弧度
			_rotateStartRadianInMouse = _getRadianToCenterPoint(new Point(evt.localX, evt.localY), _getCenterPoint());
			evt.stopImmediatePropagation();
		}
		
		protected function _rotateMouseUpHandler(evt:MouseEvent):void
		{
			if(_mode != MODE_ROTATE) return;
			var radian:Number = _getRadianToCenterPoint(new Point(evt.localX - _parent.x, evt.localY - _parent.y), _getCenterPoint());
			_mode = MODE_NONE;
			_container.mouseEnabled = true;
			_container.mouseChildren = true;
			_parent.mouseChildren = true;
			evt.stopImmediatePropagation();
		}
		
		protected function _rotateMouseMoveHandler(evt:MouseEvent):void
		{
			if(_mode != MODE_ROTATE) return;
			
			var radian:Number = _getRadianToCenterPoint(new Point(evt.localX - _parent.x, evt.localY - _parent.y), _getCenterPoint());
			
			var rk:Number = radian - _rotateStartRadianInMouse,
				ra:Number = Transformer.radianToAngle(rk);
			
			_currentRotation += ra;
			
			if(_currentRotation > 180){
				_currentRotation = _currentRotation - 360;
			}else if(_currentRotation < -180){
				_currentRotation = 360 + _currentRotation;
			}
			
			setTransform(_currentScale, _currentRotation, _isFlipedH, _isFlipedV);
			_rotateStartRadianInMouse = radian;
			//evt.stopImmediatePropagation();
			this.dispatchEvent(new Event(EVENT_ANGLE_CHANGE));
		}
		
		//获取中心点
		protected function _getCenterPoint():Point
		{
			return new Point(_container.x, _container.y);
		}
		
		//获取鼠标和中心点连线的弧度
		protected function _getRadianToCenterPoint(mousePoint:Point, centerPoint:Point):Number
		{
			var dx:Number = mousePoint.x - centerPoint.x,
				dy:Number = mousePoint.y - centerPoint.y,
				d:Number = Math.sqrt(dx * dx + dy * dy),
				result:Number;
			
			if(dx >= 0){
				result = Math.asin(dy / d);
			}else{
				result = Math.PI - Math.asin(dy / d);
			}
			return result;
		}
		
		/**********************************************************
		 ********************** 旋转 end *******************
		 *********************************************************/
		
		/**
		 * 绘制操作ui
		 */
		protected function _renderUI():void
		{
			
			var x:int = _currentRect.x;
			var y:int = _currentRect.y;
			var w:int = _currentRect.width;
			var h:int = _currentRect.height;
			
			_resizeNW.x = - 5;
			_resizeNW.y = - 5;
			
			_resizeNE.x = w - 5;
			_resizeNE.y = - 5;
			
			_resizeSW.x = - 5;
			_resizeSW.y = h - 5;
			
			_resizeSE.x = w - 5;
			_resizeSE.y = h - 5;
			
			with(_uilayer.graphics){
				clear();
				lineStyle(UI_BORDER_WEIGHT, UI_BORDER_COLOR, 1);
				beginFill(UI_COLOR, 0);
				drawRect(0, 0, w, h);
				endFill();
			}
		}
		
		/**
		 * 变换
		 */
		public function setTransform(currentScale:Number, currentRotation:Number, flipH:Boolean=false, flipV:Boolean=false):void
		{			
			var m1:Matrix = _target.transform.matrix,
				m2:Matrix = _uilayer.transform.matrix,
				radion:Number = Transformer.angleToRadian(currentRotation),
				scale:Number = currentScale;
			
			//清楚数据，防止叠加计算误差
			m1.identity();
			m2.identity();
			
			m1.translate(-_originalWidth / 2, -_originalHeight / 2);
			//水平翻转
			flipH && m1.scale(-1, 1);
			//垂直翻转
			flipV && m1.scale(1, -1);
			m1.rotate(radion);
			m1.scale(scale, scale);
			
			m2.translate(-_originalWidth / 2 * scale, -_originalHeight / 2 * scale);
			m2.rotate(radion);
			
			_target.transform.matrix = m1;
			_uilayer.transform.matrix = m2;
			_renderUI();
		}
		
		/**
		 * 两点之间距离
		 */
		protected function _getDistance(p1:Point, p2:Point):Number
		{
			var dx:Number = p2.x - p1.x;
			var dy:Number = p2.y - p1.y;
			return Math.sqrt(dx * dx + dy * dy);
		}
		
		/**
		 * 获取一个点相对一个显示对象的坐标
		 */
		protected function _getOffset(stageOffset:Object, obj:DisplayObject):Object
		{
			if(!obj.parent) return stageOffset;
			
			var result:Object = stageOffset,
				parent:DisplayObject = obj.parent;
			
			result.x -= parent.x;
			result.y -= parent.y;
			
			return arguments.callee(result, parent);
		}
		/**
		 * 翻转
		 */
		public function flip(direction:String):void
		{
			if(direction === FLIP_DIRCTION_HORIZONTAL){
				_isFlipedH = !_isFlipedH;
			}else if(direction === FLIP_DIRCTION_VERTICAL){
				_isFlipedV = !_isFlipedV;
			}
			setTransform(_currentScale, _currentRotation, _isFlipedH, _isFlipedV);
		}
		
		/**
		 * 获取旋转角度
		 */
		public function get currentRotation():Number
		{
			return _currentRotation;
		}
		/**
		 * 获取缩放比例
		 */
		public function get currentScale():Number
		{
			return _currentScale;
		}
		public function get currentAlpha():Number
		{
			return _target.alpha || 1;
		}
		/**
		 * 设置旋转角度
		 */
		public function set currentRotation(rotation:Number):void
		{
			_currentRotation = rotation;
			setTransform(_currentScale, _currentRotation, _isFlipedH, _isFlipedV);
		}
		/**
		 * 设置缩放比
		 */
		public function set currentScale(scale:Number):void
		{
			scale = Math.max(_minScale, Math.min(scale, _maxScale));
			_currentScale = scale;
			_updateCurrentRect();
			setTransform(_currentScale, _currentRotation, _isFlipedH, _isFlipedV);
		}
		/**
		 * 设置透明度
		 */
		public function set currentAlpha(alpha:Number):void
		{
			_target.alpha = alpha;
		}
		/**
		 * 设置激活状态
		 */
		public function set active(isActive:Boolean):void
		{
			_uilayer && (_uilayer.visible = isActive);	//隐藏UI
			this.mouseChildren = isActive;				//非激活状态下，内部鼠标响应不可用
			if(_isActive != isActive){
				_isActive = isActive;
				this.dispatchEvent(new Event(EVENT_ACTIVE_CHANGE));
			}
		}
		/**
		 * 获取激活状态
		 */
		public function get active():Boolean
		{
			return _isActive;
		}
		/**
		 * 获取是否水平翻转
		 */
		public function get isFlipedH():Boolean
		{
			return _isFlipedH;
		}
		/**
		 * 获取是否垂直翻转
		 */
		public function get isFlipedV():Boolean
		{
			return _isFlipedV;
		}
		
		/**
		 * 销毁
		 */
		public function dispose():void
		{
			this.active = false;
			//拖拽
			_container.removeEventListener(MouseEvent.MOUSE_DOWN, _initDrag);
			_parent.removeEventListener(MouseEvent.MOUSE_MOVE, _doDrag);
			_parent.removeEventListener(MouseEvent.MOUSE_UP, _endDrag);
			//缩放
			_parent.removeEventListener(MouseEvent.MOUSE_DOWN, _initResize);
			_parent.removeEventListener(MouseEvent.MOUSE_MOVE, _resizeParentMoveHandler);
			_parent.removeEventListener(MouseEvent.MOUSE_UP, _resizeParentUpHandler);
			//旋转
			_parent.removeEventListener(MouseEvent.MOUSE_DOWN, _rotateMouseDownHandler);
			_parent.removeEventListener(MouseEvent.MOUSE_UP, _rotateMouseUpHandler);
			_parent.removeEventListener(MouseEvent.MOUSE_MOVE, _rotateMouseMoveHandler);
			
			_parent.removeEventListener(MouseEvent.MOUSE_MOVE, _changeCursorHandler);
			_parent.removeEventListener(MouseEvent.ROLL_OUT, _outCursorHandler);
		}
	}
}


