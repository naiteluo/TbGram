package ui.basic{
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Rectangle;
	import flash.text.TextFormat;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	
	import org.aswing.ASColor;
	import org.aswing.AsWingConstants;
	import org.aswing.BorderLayout;
	import org.aswing.FlowLayout;
	import org.aswing.Insets;
	import org.aswing.JPanel;
	import org.aswing.JPopup;
	import org.aswing.JTextField;
	import org.aswing.SoftBoxLayout;
	import org.aswing.border.EmptyBorder;
	import org.aswing.border.LineBorder;
	import org.aswing.border.SideLineBorder;
	
	/**
	 * MyDialog
	 */
	public class MyDialog extends Sprite{
		
		protected var popup:JPopup;
		protected var pane:JPanel;
		//members define
		protected var titlePane:JPanel;
		protected var title:JTextField;
		protected var centerPane:JPanel;
		protected var contentPane:JPanel;
		protected var buttonPane:JPanel;
		private var _dragAble:Boolean;
		private var _draging:Boolean;
		/**
		 * MyDialog Constructor
		 */
		public function MyDialog(
			titleText:String = '',
			width:Number = 220,
			height:Number = 400,
			dragAble:Boolean = true
		){
			super();
			
			_dragAble = dragAble;
			
			popup = new JPopup();
			popup.show();
			popup.setLayout(new BorderLayout);
			popup.setSizeWH(width + 2, height + 2);
			pane = new JPanel();
			pane.setLayout(new BorderLayout());
			pane.setBorder(new LineBorder(null, new ASColor(0x0, 1), 1, 0));
			pane.setOpaque(true);
			pane.setBackground(new ASColor(0x393a3c, 1));
			
			popup.append(pane);
			
			titlePane = new JPanel();
			
			titlePane.setPreferredHeight(40);
			titlePane.setSizeWH(width, 40);
			titlePane.setBorder(new SideLineBorder(null, 1, new ASColor(0x000000, 1), 1));
			titlePane.setLayout(new FlowLayout(AsWingConstants.LEFT, 15, 10, true));
			
			title = new JTextField();
			title.setDefaultTextFormat(new TextFormat('', 12, 0xb1b1b1, true));
			title.setSizeWH(120, 20);
			title.getTextField().autoSize = 'left';
			title.setOpaque(false);
			title.setBackground(null);
			title.setEnabled(false);
			title.setBorder(null);
			title.setText(titleText);
			title.setEditable(false);
			
			titlePane.append(title);
			
			contentPane = new JPanel();
			contentPane.setBorder(new EmptyBorder(null, new Insets(15, 15, 15, 15)));
			contentPane.setOpaque(false);
			contentPane.setLayout(new SoftBoxLayout(AsWingConstants.VERTICAL, 5, AsWingConstants.LEFT));
			contentPane.setBorder(new SideLineBorder(new EmptyBorder(null, new Insets(15, 15, 15, 15)), 1, new ASColor(0x353535, 1), 1));
			
			buttonPane = new JPanel();
			buttonPane.setBorder(new SideLineBorder(new EmptyBorder(null, new Insets(5, 10, 5, 10)), 4, new ASColor(0x585858, 1), 1));
			
			//component layoution
			pane.append(titlePane, BorderLayout.NORTH);
			pane.append(contentPane, BorderLayout.CENTER);
			pane.append(buttonPane, BorderLayout.SOUTH);
			
			this.addChild(pane);
			this.filters = [new DropShadowFilter(4, 45, 0, 0.7, 5, 5, 1, 2)];
			if(_dragAble){
				titlePane.addEventListener(MouseEvent.MOUSE_DOWN, dragStartHandler);
				titlePane.addEventListener(MouseEvent.ROLL_OVER, moveTitleHandler);
				titlePane.addEventListener(MouseEvent.ROLL_OUT, moveTitleHandler);
			}
		}
		
		//________________drag____________________
		private function moveTitleHandler(evt:MouseEvent):void
		{
			if(evt.type == MouseEvent.ROLL_OVER)
				Mouse.cursor = MouseCursor.HAND;
			else if(evt.type == MouseEvent.ROLL_OUT){
				(!_draging) && (Mouse.cursor = MouseCursor.AUTO);
			}
				
		}
		
		private function dragStartHandler(evt:MouseEvent):void
		{
			_draging = true;
			evt.stopImmediatePropagation();
			(evt.target as JPanel).removeEventListener(MouseEvent.MOUSE_DOWN, dragStartHandler);
			this.stage.addEventListener(MouseEvent.MOUSE_UP, dragEndHandler);
			this.startDrag(false, new Rectangle(0, 0, stage.stageWidth - this.width, stage.stageHeight - this.height));
		}
		
		private function dragEndHandler(evt:MouseEvent):void
		{
			evt.stopImmediatePropagation();
			this.stopDrag();
			_dragAble && titlePane.addEventListener(MouseEvent.MOUSE_DOWN, dragStartHandler);
			this.stage.removeEventListener(MouseEvent.MOUSE_UP, dragEndHandler);
			_draging = false;
			//Mouse.cursor = MouseCursor.AUTO;
		}
		
		//_________getters_________
		
		protected function getTitlePane():JPanel{
			return titlePane;
		}
		
		protected function getTitle():JTextField{
			return title;
		}
		
		protected function getContentPane():JPanel
		{
			return contentPane;
		}
		
		protected function getButtonPane():JPanel
		{
			return buttonPane;
		}
		
		protected function setLocation(x:Number, y:Number):void
		{
			this.x = x;
			this.y = y;
		}
		
		public function setTitleText(txt:String):void
		{
			title.setText(txt);
		}
		
	}
}
