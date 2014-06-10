package ui.upload
{
    import flash.events.Event;
    import flash.events.MouseEvent;
    
    import org.aswing.JLabel;
    import org.aswing.JProgressBar;
    import org.aswing.border.EmptyBorder;
    
    import ui.basic.MyButton;
    import ui.basic.MyDialog;
    import org.aswing.Insets;
    
    public class UploadDialog extends MyDialog
    {
        public static const EVENT_OK:String = 'ok';
        public static const EVENT_CANCEL:String = 'cancel';
        
        private var _text:JLabel;
        
        private var _okBtn:MyButton;
        private var _cancelBtn:MyButton;
        private var _progressBar:JProgressBar;
        
        public function UploadDialog(titleText:String='上传', width:Number=400, height:Number=200)
        {
            super(titleText, width, height);
            _buildUIContent();
            super.setLocation(400, 280);
        }
        
        private function _buildUIContent():void
        {
            _text = new JLabel('>_< 正在努力上传中，请耐性等待');
            contentPane.append(_text);
            _progressBar = new JProgressBar();
            contentPane.append(_progressBar);
            
            _okBtn = new MyButton('确定');
            _okBtn.setVisible(false);
            _cancelBtn = new MyButton('取消');
            
            buttonPane.append(_okBtn);
            buttonPane.append(_cancelBtn);
            buttonPane.setBorder(new EmptyBorder(null, new Insets(10, 260, 10, 10)));
            
            _bindButtonsEvent();
        }
        
        private function _bindButtonsEvent():void
        {
            _okBtn.addEventListener(MouseEvent.CLICK, _btnsClickHandler);
            _cancelBtn.addEventListener(MouseEvent.CLICK, _btnsClickHandler);
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
        
        public function showOkBtn():void
        {
            _okBtn.setVisible(true);
        }
        
        public function setProgressBar(value:Number):void
        {
            _progressBar.setValue(value);
        }
		
		public function setText(value:String):void
		{
			_text.setText(value);
		}

    }
}