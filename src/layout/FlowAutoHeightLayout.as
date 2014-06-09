package layout
{
	import org.aswing.Component;
	import org.aswing.Container;
	import org.aswing.FlowLayout;
	import org.aswing.geom.IntDimension;
	import org.aswing.geom.IntPoint;

	public class FlowAutoHeightLayout extends FlowLayout
	{
		public function FlowAutoHeightLayout(align:int=2, hgap:Number=5, vgap:Number=5, margin:Boolean=true)
		{
			super(align, hgap, vgap, margin);
		}
		override public function layoutContainer(target:Container):void
		{
			super.layoutContainer(target);
			var itemCount:int = target.getComponentCount();
			var height:Number = 0;
			for(var i:int = 0; i < itemCount; i ++){
				var item:Component = target.getComponent(i);
				var size:IntDimension = item.getPreferredSize();
				var pos:IntPoint = item.getLocation();
				height = Math.max(pos.y + size.height, height);
			}
			if(margin){
				height += vgap;
			}
			target.setPreferredHeight(height);
		}
	}
}