package ui.sticker
{
	import flash.events.MouseEvent;
	import flash.utils.setTimeout;
	
	import layout.FlowAutoHeightLayout;
	
	import org.aswing.ASColor;
	import org.aswing.Border;
	import org.aswing.BorderLayout;
	import org.aswing.BoxLayout;
	import org.aswing.Component;
	import org.aswing.FlowLayout;
	import org.aswing.Insets;
	import org.aswing.JPanel;
	import org.aswing.SoftBoxLayout;
	import org.aswing.border.EmptyBorder;
	import org.aswing.border.SideLineBorder;
	
	import ui.basic.MyScrollPane;
	
	public class StickerTabedPane extends JPanel
	{
		private var _configs:*;
		
		public var _tablist:Object;
		private var _titlelist:Array;
		public var _tabs:JPanel;
		private var _tabsContainer:JPanel;
		public var _containers:JPanel;
		private var _tabGap:Number = 10;
		private var _maxHeight:Number;
		
		public function StickerTabedPane(configs:*)
		{
			_configs = configs;
			
			_titlelist = [];
			_tablist = {};
			
			_tabs = new JPanel(new FlowLayout(2, 0, 0, false));
			_tabs.setBorder(new SideLineBorder(null, SideLineBorder.SOUTH, new ASColor(0x2f3031, 0.9), 2))
			
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
			var tab:StickerTab = new StickerTab(title);
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
			tab.changeStatus(StickerTab.STATUS_DEFAULT);
			container.setVisible(false);
			
			setTimeout(function():void{setActive(_titlelist[0]);},10);
		}
		public function removeTab(title:String):void
		{
			if(!_tablist.hasOwnProperty(title)) return;
			var tab:StickerTab = (_tablist[title]['handler'] as StickerTab);
			tab.removeEventListener(MouseEvent.CLICK, _tabClickHandler);
			_containers.remove(_tablist[title]['container'] as Component);
			_tabs.remove(tab);
			
			delete _tablist[title];
			var idx:int = _titlelist.indexOf(title);
			_titlelist.splice(idx, 1);
		}
		public function setActive(title:String):void
		{
			var curr:StickerTab = _tablist[title]['handler'] as StickerTab;
			if(!curr) return;
			for(var i:String in _tablist){
				var obj:Object = _tablist[i],
					handler:StickerTab = obj.handler,
					container:Component = obj.container;
				handler.changeStatus(StickerTab.STATUS_DEFAULT);
				container.setVisible(false);
			}
			curr.changeStatus(StickerTab.STATUS_ACTIVE);
			curr.target.setVisible(true);
			curr.target.setBorder(new EmptyBorder(null, new Insets(0, 0, 0, 0)));
			
			// 不熟悉aswing的情况下很trick的高度计算方法 by tanjiawei
			var itemCount:int = _addItems(title);
			var containerHeight:int = Math.ceil(itemCount / 3) * 74;
			containerHeight = containerHeight > 500 ? 500 : containerHeight;	
			container.setPreferredHeight(containerHeight);
			_containers.setPreferredHeight(curr.target.getPreferredHeight() + _tabs.getPreferredHeight());
			
			setPreferredHeight(curr.target.getPreferredHeight() + _tabs.getPreferredHeight());
			curr.target.setPreferredHeight(_containers.getPreferredHeight());
		}
		
		private function _addItems(title:String):int
		{
			var length:int = 0;
			var list:SticksListPanel = _tablist[title]['container'].getViewportView() as SticksListPanel;
			list.removeAll();
			list.doLayout();
			for (var i:int = 0; i < _configs.length; i++) {
				if (_configs[i].tabName == title) {
					length = _configs[i].tabContents.length;
					for(var j:int, len:int = _configs[i].tabContents.length; j < len; j ++){
						var item:StickItem = new StickItem(_configs[i].tabContents[j]);
						list.append(item);
					}
					
				}
			}
			list.doLayout();
			list.revalidate();
			return length;
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
			var curr:StickerTab = evt.currentTarget as StickerTab;
			setActive(curr.title);
		}
	}
}






