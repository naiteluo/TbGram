package ui.sticker
{
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.text.TextFormat;
    
    import org.aswing.JSlider;
    import org.aswing.JTextField;
    import ui.basic.MyButton;
    import ui.basic.MyDialog;

    public class StickerDialog extends MyDialog
    {
        
		private var _sticker:Sticker;			//绑定的Sticker
		
        private var sizeText:JTextField;
        private var sizeSlider:JSlider;
        private var angleText:JTextField;
        private var angleSlider:JSlider;
        private var alphaText:JTextField;
        private var alphaSlider:JSlider;
        private var verticalFlipBtn:MyButton;
        private var horizontalFlipBtn:MyButton;
        private var deleteBtn:MyButton;
		private var okBtn:MyButton;
        public function StickerDialog(titleText:String='饰品属性', width:Number=285, height:Number=260)
        {
            super(titleText, width, height);
			_buildUIContent();
            super.setLocation(240, 42);
        }
        
        private function _buildUIContent():void
        {
            sizeText = _createSliderLabel('缩放：0%');
            sizeSlider = new JSlider(0, 10, 100);
            
            angleText = _createSliderLabel('旋转：0度');
            angleSlider = new JSlider(0, -180, 180, 0);
            
            alphaText = _createSliderLabel('透明度：0%');
            alphaSlider = new JSlider(0, 0, 100, 0);
            
            _bindSliderEvent();
            
			contentPane.append(sizeText);
			contentPane.append(sizeSlider);
			contentPane.append(angleText);
			contentPane.append(angleSlider);
			contentPane.append(alphaText);
			contentPane.append(alphaSlider);
            
            verticalFlipBtn = new MyButton('垂直翻转');
            horizontalFlipBtn = new MyButton('水平翻转');
            deleteBtn = new MyButton('删除');
			okBtn = new MyButton('确认');
            
			buttonPane.append(verticalFlipBtn);
			buttonPane.append(horizontalFlipBtn);
			buttonPane.append(deleteBtn);
			buttonPane.append(okBtn);
            
			
			_bindButtonsEvent();
			
            
        }
        
		private function _createSliderLabel(text:String):JTextField
		{
			var txt:JTextField = new JTextField();
			var tf:TextFormat = new TextFormat('微软雅黑, arial', 12, 0xb1b1b1);
			txt.setDefaultTextFormat(tf);
			txt.setEnabled(false);
			txt.setText(text);
			txt.setOpaque(false);
			txt.getTextField().autoSize = 'left';
			
			return txt;
		}
		
        private function _bindSliderEvent():void
        {
            sizeSlider.addStateListener(_sizeSliderChanged);
            angleSlider.addStateListener(_angleSliderChanged);
            alphaSlider.addStateListener(_alphaSliderChanged);
			
        }
		private function _unbindSliderEvent():void
		{
			sizeSlider.removeStateListener(_sizeSliderChanged);
			angleSlider.removeStateListener(_angleSliderChanged);
			alphaSlider.removeStateListener(_alphaSliderChanged);
		}
		
		private function _bindButtonsEvent():void
		{
			verticalFlipBtn.addEventListener(MouseEvent.CLICK, _buttonClickHandler);
			horizontalFlipBtn.addEventListener(MouseEvent.CLICK, _buttonClickHandler);
			deleteBtn.addEventListener(MouseEvent.CLICK, _buttonClickHandler);
			okBtn.addEventListener(MouseEvent.CLICK, _buttonClickHandler);
		}
		
		private function _unbindButtonsEvent():void
		{
			buttonPane.removeEventListener(MouseEvent.CLICK, _buttonClickHandler);
		}
		
		private function _buttonClickHandler(evt:MouseEvent):void
		{
			switch(evt.currentTarget){
				case verticalFlipBtn:
					_sticker && _sticker.flip(Sticker.FLIP_DIRCTION_VERTICAL);
					break;
				case horizontalFlipBtn:
					_sticker && _sticker.flip(Sticker.FLIP_DIRCTION_HORIZONTAL);
					break;
				case deleteBtn:
					_sticker && _sticker.dispose();
					break;
				case okBtn:
					if(_sticker) {
						_sticker.merge();
						_sticker.dispose();
					}
					break;
			}
		}
        /**
		 * 更新slider文本
		 */
		private function _updateText():void
		{
			alphaText.setText('透明度：' + getAlphaValue().toString() + '%');
			angleText.setText('旋转：' + getAngleValue().toString() + '度');
			sizeText.setText('缩放：' + getSizeValue().toString() + '%');
		}
		/**
		 * 监听alpha改变
		 */
        private function _alphaSliderChanged(event:Event):void
        {
			_sticker && (_sticker.currentAlpha = getAlphaValue() / 100);
			_updateText();
        }
        /**
		 * 监听angle改变
		 */
        private function _angleSliderChanged(event:Event):void
        {
			_sticker && (_sticker.currentRotation = getAngleValue());
			_updateText();
        }
        /**
		 * 监听size改变
		 */
        private function _sizeSliderChanged(event:Event):void
        {
			_sticker && (_sticker.currentScale = getSizeValue() / 100);
			_updateText();
        }
        /**
		 * sticker资源加载完毕
		 */
		private function _stickerReadyHandler(evt:Event = null):void
		{
			evt && evt.target.removeEventListener(Sticker.EVENT_READY, _stickerReadyHandler);
			
			this.setCurrentAlpha(_sticker.currentAlpha * 100);
			this.setCurrentSize(_sticker.currentScale * 100);
			this.setCurrentAngle(_sticker.currentRotation);
		}
		/**
		 * 
		 */
        public function getCurrentSize():Number
        {
            return sizeSlider.getValue();
        }
        
        public function getCurrentAngle():Number
        {
            return angleSlider.getValue();
        }
        
        public function getCurrentAlpha():Number
        {
            return (100 - alphaSlider.getValue()) / 100;
        }
        
        public function getSizeValue():Number
        {
            return sizeSlider.getValue();
        }
        
        public function getAngleValue():Number
        {
            return angleSlider.getValue();
        }
        
        public function getAlphaValue():Number
        {
            return alphaSlider.getValue();
        }
        
        public function setCurrentSize(value:Number):void
        {
			sizeSlider.removeStateListener(_sizeSliderChanged);
            sizeSlider.setValue(value);
			_updateText();
			sizeSlider.addStateListener(_sizeSliderChanged);
        }
        
        public function setCurrentAngle(value:Number):void
        {
			angleSlider.removeStateListener(_angleSliderChanged);
            angleSlider.setValue(value);
			_updateText();
			angleSlider.addStateListener(_angleSliderChanged);
        }
        
        public function setCurrentAlpha(value:Number):void
        {
			alphaSlider.removeStateListener(_alphaSliderChanged);
            alphaSlider.setValue(value);
			_updateText();
			alphaSlider.addStateListener(_alphaSliderChanged);
        }
        
		public function bindSticker(sticker:Sticker):void
		{
			unbindSticker();
			_sticker = sticker;
			if(_sticker.isReady){
				_stickerReadyHandler();
			}else{
				_sticker.addEventListener(Sticker.EVENT_READY, _stickerReadyHandler);
			}
			
			_sticker.addEventListener(Sticker.EVENT_ANGLE_CHANGE, _stickerAngleChangeHandler);
			_sticker.addEventListener(Sticker.EVENT_SIZE_CHANGE, _stickerSizeChangeHandler);
		}
		
		public function unbindSticker():void
		{
			if(!_sticker) return;
			_sticker.removeEventListener(Sticker.EVENT_ANGLE_CHANGE, _stickerAngleChangeHandler);
			_sticker.removeEventListener(Sticker.EVENT_SIZE_CHANGE, _stickerSizeChangeHandler);
			_sticker = null;
		}
		
		private function _stickerAngleChangeHandler(evt:Event):void
		{
			this.setCurrentAngle((evt.target as Sticker).currentRotation);
		}
		
		private function _stickerSizeChangeHandler(evt:Event):void
		{
			this.setCurrentSize((evt.target as Sticker).currentScale * 100);
		}
    }
}