package ui.sticker
{
    import org.aswing.Component;
    
    import ui.SimpleTab;
    import ui.SimpleTabedPane;
    import org.aswing.border.EmptyBorder;
    import org.aswing.Insets;
    
    public class StickerTabedPane extends SimpleTabedPane
    {
        private var _configs:*;
        public function StickerTabedPane(configs:*)
        {
            super();
            _configs = configs;
        }
        
        public override function setActive(title:String):void
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
            curr.target.setBorder(new EmptyBorder(null, new Insets(0, 0, 0, 0)));
            
            _addItems(title);
            
			_containers.setPreferredHeight(500);
            setPreferredHeight(curr.target.getPreferredHeight() + _tabs.getPreferredHeight());
            curr.target.setPreferredHeight(_containers.getPreferredHeight());
            _containers.revalidate();
        }
        
        private function _addItems(title:String):void
        {
            var list:SticksListPanel = _tablist[title]['container'].getViewportView() as SticksListPanel;
            list.removeAll();
            list.doLayout();
            for (var i:int = 0; i < _configs.length; i++) {
                if (_configs[i].tabName == title) {
                    for(var j:int, len:int = _configs[i].tabContents.length; j < len; j ++){
        				var item:StickItem = new StickItem(_configs[i].tabContents[j]);
                        list.append(item);
        			}
                    list.doLayout();
//                    list.setPreferredHeight(300);
                }
            }
        }
    }
}