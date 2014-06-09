package ui.basic
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.SimpleButton;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import lt.uza.ui.Scale9BitmapSprite;
	
	import org.aswing.JButton;

	public class MyButton extends JButton
	{
		[Embed (source="../../../images/btn_normal.png")]
		private static var BtnNormalBg:Class;
		
		[Embed (source="../../../images/btn_over.png")]
		private static var BtnOverBg:Class;
		
		[Embed (source="../../../images/btn_down.png")]
		private static var BtnDownBg:Class;
		
		public function MyButton(text:String)
		{
			super(text);
			
			var size:Number = _getTextWidth(text);
			var normal:Scale9BitmapSprite = _getBitmap(BtnNormalBg, size);
			var down:Scale9BitmapSprite = _getBitmap(BtnDownBg, size);
			var over:Scale9BitmapSprite = _getBitmap(BtnOverBg, size);
				
			var btn:SimpleButton = new SimpleButton(normal, over, down, normal);
			
			this.wrapSimpleButton(btn);
		}
		private function _getBitmap(obj:Class, size:Number):Scale9BitmapSprite
		{
			var s:BitmapData = ((new obj) as Bitmap).bitmapData;
			var rect:Rectangle = new Rectangle(4, 4, 52, 24);
			var o:Scale9BitmapSprite = new Scale9BitmapSprite(s, rect);
			o.width = size;
			return o;
		}
		private function _getTextWidth(txt:String):Number
		{
			var tf:TextField = new TextField();
			tf.text = txt;
			tf.defaultTextFormat = new TextFormat('微软雅黑, arial', 12);
			tf.autoSize = 'left';
			return tf.width + 20;
		}
	}
}



