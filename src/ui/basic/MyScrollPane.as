package ui.basic
{
	import org.aswing.JScrollBar;
	import org.aswing.JScrollPane;
	import org.aswing.plaf.basic.BasicScrollBarUI;

	public class MyScrollPane extends JScrollPane
	{
		public function MyScrollPane(viewOrViewport:*=null, vsbPolicy:int=0, hsbPolicy:int=0)
		{
			super(viewOrViewport, vsbPolicy, hsbPolicy);
			var bar:JScrollBar = this.getVerticalScrollBar();
			var barui:BasicScrollBarUI = new MyScrollBarUI;
			
			bar.setUI(barui);
            
		}
		
	}
}