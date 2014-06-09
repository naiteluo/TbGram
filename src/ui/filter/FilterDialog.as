package ui.filter
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;
	
	import org.aswing.JSlider;
	import org.aswing.JTextField;
	
	import ui.basic.MyButton;
	import ui.basic.MyDialog;
	import ui.viewport.Viewport;
	import ui.viewport.ViewportLayer;

	public class FilterDialog extends MyDialog
	{
		public static const EVENT_OK:String = 'ok';
		public static const EVENT_CANCEL:String = 'cancel';
		
		private var _mixSlider:JSlider;
		private var _mixText:JTextField;
		
		private var _okBtn:MyButton;
		private var _cancelBtn:MyButton;
		
		private var _viewport:Viewport;
		private var _filterIdx:int;
		private var _backgroundIdx:int;
		
		
		public function FilterDialog(titleText:String='饰品属性', width:Number=285, height:Number=180)
		{
			super(titleText, width, height);
			_buildUIContent();
			super.setLocation(240, 305);
		}
		
		private function _buildUIContent():void
		{
			_mixText = _createSliderLabel('混合：0%');
			_mixSlider = new JSlider(0, 0, 100, 100);
			
			_bindSliderEvent();
			
			contentPane.append(_mixText);
			contentPane.append(_mixSlider);
			
			_okBtn = new MyButton('确定');
			_cancelBtn = new MyButton('取消');
			
			buttonPane.append(_okBtn);
			buttonPane.append(_cancelBtn);
			
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
			_mixSlider.addStateListener(_mixSliderChanged);
		}
		private function _unbindSliderEvent():void
		{
			_mixSlider.removeStateListener(_mixSliderChanged);
		}
		
		private function _bindButtonsEvent():void
		{
			_okBtn.addEventListener(MouseEvent.CLICK, _btnsClickHandler);
			_cancelBtn.addEventListener(MouseEvent.CLICK, _btnsClickHandler);
		}
		
		private function _unbindButtonsEvent():void
		{
			_okBtn.removeEventListener(MouseEvent.CLICK, _btnsClickHandler);
			_cancelBtn.removeEventListener(MouseEvent.CLICK, _btnsClickHandler);
		}
		
		private function _mixSliderChanged(evt:Event):void
		{
			_updateText();
			var filterLayer:ViewportLayer = _viewport.getLayerAt(_filterIdx);
			filterLayer.alpha = _mixSlider.getValue() / 100;
		}
		
		private function _btnsClickHandler(evt:MouseEvent):void
		{
			var btn:MyButton = evt.currentTarget as MyButton;
			switch(btn){
				case _okBtn:
					this.dispatchEvent(new Event(EVENT_OK));
					break;
				case _cancelBtn:
					this.dispatchEvent(new Event(EVENT_CANCEL));
					break;
			}
		}
		
		private function _updateText():void
		{
			_mixText.setText('混合：' + _mixSlider.getValue() + '%');
		}
		
		//___________getters_____________________
		
		public function getMixValue():Number
		{
			return _mixSlider.getValue();
		}
		
		//____________setters_____________________
		
		public function setMixValue(value:Number):void
		{
			_mixSlider.removeStateListener(_mixSliderChanged);
			_mixSlider.setValue(value);
			_updateText();
			_mixSlider.addStateListener(_mixSliderChanged);
		}
		
		
		/**
		 * 绑定viewport的两个图层，用做混合滤镜
		 */
		public function bindViewport(viewport:Viewport, filterLayerIndex:int, backgroundLayerIndex:int):void
		{
			_viewport = viewport;
			_filterIdx = filterLayerIndex;
			_backgroundIdx = backgroundLayerIndex;
		}
		
		public function unbindViewport():void
		{
			_viewport = null;
			_filterIdx = 0;
			_backgroundIdx = 0;
		}
	}
}



