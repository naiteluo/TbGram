package ui.basic
{
	import org.aswing.Component;
	import org.aswing.JScrollBar;
	import org.aswing.plaf.basic.BasicScrollBarUI;
	import org.aswing.*;
	import org.aswing.plaf.basic.BasicScrollBarUI;
	import org.aswing.geom.*;

	public class MyScrollBarUI extends BasicScrollBarUI
	{
		protected var scrollBarHeight:int;
		
		public function MyScrollBarUI()
		{
			super();
			putDefault('ScrollBar.barWidth', 4);
			putDefault('ScrollBar.background', new ASColor(0, 0));
		}
		override protected function createArrowButton():JButton{
			var b:JButton = new JButton();
			b.setFocusable(false);
			b.setOpaque(false);
			b.setBackgroundDecorator(null);
			b.setBorder(null);
			b.setMargin(new Insets());
			return b;
		}	
		
		override protected function createIcons():void{
			
		}
		
		override protected function installComponents():void
		{
			super.installComponents();
			thumMC.alpha = 0.2;
		}
		
	}
}