package ui.sticker
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	
	import org.aswing.ASColor;
	import org.aswing.Component;
	import org.aswing.JPanel;
	import org.aswing.LayoutManager;
	
	import ui.sticker.StickItem;
	
	public class SticksListPanel extends JPanel
	{
		public static const ITEM_CLICK:String = 'item_click';
		private var _activeItem:StickItem;
		public function SticksListPanel(layout:LayoutManager=null)
		{
			super(layout);
			this.addEventListener(MouseEvent.CLICK, _itemClickHandler);
			
			//this.setOpaque(true);
			//this.setBackground(new ASColor());
            
		}
		
		private function _itemClickHandler(evt:MouseEvent):void
		{
			if(!(evt.target is StickItem)) return;
			_activeItem = evt.target as StickItem;
			this.dispatchEvent(new Event(ITEM_CLICK));
		}
		public function get activeItem():StickItem
		{
			return _activeItem;
		}
	}
}