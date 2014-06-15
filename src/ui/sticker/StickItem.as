package ui.sticker
{
	
	import ui.basic.ImageItem;

	public class StickItem extends ImageItem
	{
		private var _name:String;
		private var _config:Object;
		
		public function StickItem(config:Object)
		{
			_config = config;
			_name = config.name;
			
			super(config.url_preview, 65, 65, false, 'in', 0xb1b1b1, 1, 0, 0, 0, .8, .9, 1, 0);
		}
		
		public function get stickConfig():Object
		{
			return _config;
		}
		
	}
}