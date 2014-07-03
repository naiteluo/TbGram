package ui.basic
{
    import flash.display.Sprite;

    public class GIFComponent extends Sprite 
    {
		private var suffixPatten:RegExp = /^.*?\.(gif)$/;
        
        public function GIFComponent()
        {
            
        }
		
		public function isGIFUrl(url:String):Boolean {
			return suffixPatten.test(url);;
		}
    }
}