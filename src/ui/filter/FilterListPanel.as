package ui.filter
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import org.aswing.Component;
	import org.aswing.JPanel;
	import org.aswing.LayoutManager;

	public class FilterListPanel extends JPanel
	{
		public static const ACTIVE_CHANGE:String = 'active_change';
		private var _activeItem:FilterItem;
		public function FilterListPanel(layout:LayoutManager)
		{
			super(layout);
			
		}
		override public function append(component:Component, constraints:Object=null):void
		{
			super.append(component, constraints);
			component.addEventListener(MouseEvent.CLICK, _itemClickHandler);
			this.revalidate();
		}
		public function get activeItem():FilterItem
		{
			return _activeItem;
		}
		public function clearActive():void
		{
			/*_activeItem && (_activeItem.status = false);*/
			_activeItem = null;
			//this.dispatchEvent(new Event(ACTIVE_CHANGE));
		}
		private function _itemClickHandler(evt:MouseEvent):void
		{
			var item:FilterItem = evt.target as FilterItem;
			_activeItem = item;
			this.dispatchEvent(new Event(ACTIVE_CHANGE));
		}
	}
}