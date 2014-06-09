package ui
{
	import flash.events.MouseEvent;
	import flash.utils.setTimeout;
	
	import layout.FlowAutoHeightLayout;
	
	import org.aswing.ASColor;
	import org.aswing.BorderLayout;
	import org.aswing.BoxLayout;
	import org.aswing.Component;
	import org.aswing.FlowLayout;
	import org.aswing.Insets;
	import org.aswing.JPanel;
	import org.aswing.SoftBoxLayout;
	import org.aswing.border.EmptyBorder;
	import org.aswing.border.LineBorder;
	
	import ui.SimpleTab;

	public class SimpleTabedPane extends JPanel
	{
		public var _tablist:Object;
		private var _titlelist:Array;
        public var _tabs:JPanel;
		private var _tabsContainer:JPanel;
        public var _containers:JPanel;
		private var _tabGap:Number = 10;
		private var _maxHeight:Number;
		
		public function SimpleTabedPane()
		{
			_titlelist = [];
			_tablist = {};
			
			_tabs = new JPanel(new FlowLayout(2, 0, 0, false));

			_tabsContainer = new JPanel(new FlowLayout(2, 0, 5, false));
			_tabsContainer.setBorder(new EmptyBorder(null, new Insets(0, 0, 0, 0)));
			_tabs.append(_tabsContainer);
			
			_containers = new JPanel();
			_containers.setBackground(new ASColor(0x393a3c, 0.9));
			_containers.setOpaque(true);
			_containers.setLayout(new SoftBoxLayout(SoftBoxLayout.Y_AXIS, 0, SoftBoxLayout.TOP));
			
			setLayout(new BorderLayout());
			setBorder(new EmptyBorder(null, new Insets(3, 0, 0, 0)));
			append(_tabs, BorderLayout.NORTH);
			append(_containers, BorderLayout.CENTER);
		}
		public function appendTab(container:Component, title:String):void
		{
			var tab:SimpleTab = new SimpleTab(title);
			tab.target = container;
			
			if(_titlelist.indexOf(title) >= 0){ //已经包含相同title
				removeTab(title);
			}
			
			_titlelist.push(title);
			_tablist[title] = {
				'container' : container,
				'handler' : tab
			};
			
			tab.addEventListener(MouseEvent.CLICK, _tabClickHandler);
			
			_tabsContainer.append(tab);
			_containers.append(container);
			tab.changeStatus(SimpleTab.STATUS_DEFAULT);
			container.setVisible(false);
			
			setTimeout(function():void{setActive(_titlelist[0]);},10);
		}
		public function removeTab(title:String):void
		{
			if(!_tablist.hasOwnProperty(title)) return;
			var tab:SimpleTab = (_tablist[title]['handler'] as SimpleTab);
			tab.removeEventListener(MouseEvent.CLICK, _tabClickHandler);
			_containers.remove(_tablist[title]['container'] as Component);
			_tabs.remove(tab);
			
			delete _tablist[title];
			var idx:int = _titlelist.indexOf(title);
			_titlelist.splice(idx, 1);
		}
		public function setActive(title:String):void
		{
			var curr:SimpleTab = _tablist[title]['handler'] as SimpleTab;
			if(!curr) return;
			for(var i:String in _tablist){
				var obj:Object = _tablist[i],
					handler:SimpleTab = obj.handler,
					container:Component = obj.container;
				handler.changeStatus(SimpleTab.STATUS_DEFAULT);
				container.setVisible(false);
			}
			curr.changeStatus(SimpleTab.STATUS_ACTIVE);
			curr.target.setVisible(true);
			
			setPreferredHeight(curr.target.getPreferredHeight() + _tabs.getPreferredHeight());
			curr.target.setPreferredHeight(_containers.getPreferredHeight());
			_containers.revalidate();
		}
		/***
		 * 比较恶心的做法，高度自适应
		 */
		override public function setPreferredHeight(preferredHeight:int):void
		{
			var height:int = Math.min(preferredHeight, _maxHeight);
			super.setPreferredHeight(height);
			_containers.setPreferredHeight(height - _tabs.getPreferredHeight());
		}
		override public function setMaximumHeight(maximumHeight:int):void
		{
			_maxHeight = maximumHeight;
		}
		private function _tabClickHandler(evt:MouseEvent):void
		{
			var curr:SimpleTab = evt.currentTarget as SimpleTab;
			setActive(curr.title);
		}
	}
}






