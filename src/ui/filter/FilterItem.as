package ui.filter
{
	import com.imagelib.FilterManager;
	import com.imagelib.utils.FilterConfigParser;
	
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import ui.basic.ImageItem;

	public class FilterItem extends ImageItem
	{
		private const _iwidth:Number = 65;
		private const _iheight:Number = 65;
		private const _iround:Number = 0;
		private const _iborder:Number = 1;
		
		private var _label:Sprite;
		
		private var _mask:Shape;
		private var _filterConfig:Object;
		private var _name:String;
		
		public function FilterItem(source:String, filterConfig:Object)
		{
			_filterConfig = filterConfig;
			_name = filterConfig.name;
			super(source, _iwidth, _iheight, false, 'out', 0, _iborder, 0x000000, 0x000000, 0x000000, .8, .9, 1, _iround);
		}
		public function get filtersConfig():Object
		{
			return _filterConfig;
		}
		
		override public function setSource(source:BitmapData=null):void
		{
			super.setSource(source);
			FilterManager.instance.processor(_preview.bitmapData, FilterConfigParser.parse(_filterConfig));
		}
		
		override protected function _build(source:BitmapData=null):void
		{
			super._build(source);
			
			_label = new Sprite();
			
			with(_label){
				x = 0;
				y = _height - 18;
				graphics.beginFill(0x000000, 0.5);
				graphics.drawRect(0, 0, _width, 18);
				graphics.endFill();
			}
			
			var _labelTf:TextField = new TextField();
			_labelTf.width = _iwidth;
			_labelTf.y = -2;
			_labelTf.defaultTextFormat = new TextFormat('微软雅黑', 12, 0xffffff, null, null, null, null, null, 'center', null, null, null);
			_labelTf.text = _name;
			_label.addChild(_labelTf);
			
			_previewWrap.addChild(_label);
			
			_mask = new Shape();
			with(_mask){
				graphics.beginFill(0x000000);
				graphics.drawRoundRect(0, 0, _iwidth, _iheight, _iround, _iround);
				graphics.endFill();
			}
			_previewWrap.addChild(_mask);
			_previewWrap.mask = _mask;
		}
	}
}