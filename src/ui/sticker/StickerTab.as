package ui.sticker
{
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	import org.aswing.ASColor;
	import org.aswing.Component;
	import org.aswing.Insets;
	import org.aswing.JPanel;
	import org.aswing.border.EmptyBorder;
	
	public class StickerTab extends JPanel
	{
		public static const STATUS_DEFAULT:int = 0;
		public static const STATUS_ACTIVE:int = 1;
		
		public var target:Component;
		
		private var _txtMargin:Insets = new Insets(4, 10, 9, 10);
		private var _status:int= -1;
		private var _bgColors:Object = {	//背景色
			'1' : new ASColor(0x2f3031, 0.9),
			'0' : new ASColor(0x393a3c, 0.9)
		};
		private var _txt:TextField;
		private var _title:String;
		
		public function StickerTab(title:String, status:int = STATUS_DEFAULT)
		{
			_title = title;
			
			var tf:TextFormat = new TextFormat('微软雅黑, arial', 12, 0xb1b1b1);
			tf.align = TextFormatAlign.LEFT;
			
			_txt = new TextField;
			_txt.autoSize = 'left';
			_txt.defaultTextFormat = tf;
			_txt.text = title;
			
			_txt.x = _txtMargin.left;
			_txt.y = _txtMargin.top;
			_txt.mouseEnabled = false;
			this.addChild(_txt);
			
			_drawByStatus(status);
			
			this.setOpaque(true);
			this.setPreferredWidth(this.realWidth);
			this.setPreferredHeight(this.realHeight);
		}
		public function changeStatus(status:int):void
		{
			_drawByStatus(status);
		}
		public function get realWidth():Number
		{
			return (_txt.textWidth + _txtMargin.left + _txtMargin.right); 
		}
		public function get realHeight():Number
		{
			return (_txt.textHeight + _txtMargin.top + _txtMargin.bottom);
		}
		public function get title():String
		{
			return _title;
		}
		private function _drawByStatus(status:int=STATUS_DEFAULT):void
		{
			if(_status == status || [STATUS_DEFAULT, STATUS_ACTIVE].indexOf(status) < 0) return;
			_status = status;
			this.setBackground(_bgColors[_status]);
			if(status == STATUS_DEFAULT){
				this.setBorder(new EmptyBorder(null, new Insets(1, 1, 1, 1)));
			}else{
				this.setBorder(null);
			}
			
			buttonMode = (_status == STATUS_DEFAULT);
		}
	}
}



