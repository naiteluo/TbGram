package
{
    import com.imagelib.ImageDataUploader;
    import com.imagelib.ImageDataUploaderGroup;
    import com.imagelib.ui.Clipper;
    
    import flash.display.BitmapData;
    import flash.display.JPEGEncoderOptions;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.external.ExternalInterface;
    import flash.geom.Rectangle;
    import flash.net.FileReferenceList;
    import flash.system.Security;
    import flash.utils.ByteArray;
    import flash.utils.setTimeout;
    
    import layout.FlowAutoHeightLayout;
    
    import org.aswing.ASColor;
    import org.aswing.ASFont;
    import org.aswing.AsWingConstants;
    import org.aswing.AsWingManager;
    import org.aswing.BorderLayout;
    import org.aswing.Container;
    import org.aswing.FlowWrapLayout;
    import org.aswing.Insets;
    import org.aswing.JButton;
    import org.aswing.JLabelButton;
    import org.aswing.JList;
    import org.aswing.JPanel;
    import org.aswing.JScrollPane;
    import org.aswing.JWindow;
    import org.aswing.LoadIcon;
    import org.aswing.SoftBoxLayout;
    import org.aswing.border.EmptyBorder;
    import org.aswing.border.LineBorder;
    import org.aswing.border.SideLineBorder;
    
    import ui.ImageNav;
    import ui.SimpleTabedPane;
    import ui.basic.ImageItem;
    import ui.basic.MyButton;
    import ui.basic.MyScrollPane;
    import ui.filter.FilterListPanel;
    import ui.filter.FilterUIManager;
    import ui.sticker.StickerUIManager;
    import ui.sticker.SticksListPanel;
    import ui.upload.UploaderUIManager;
    import ui.viewport.Viewport;
    import ui.viewport.ViewportEvent;
    
    [SWF(backgroundColor="#ffffff", frameRate="48")]
    public class TbGram extends Sprite
    {
        
        
        private var _filterConfigURL:String;
        //private var _configURL:String = '/tb/static-common/htmlfilter/filterconf.js';
        
        private var _sticksConfigURL:String;
        //		private var _sticksConfigURL:String = '/tb/static-common/sticks/sticks_conf.js';
        
        private var _reviewURL:String;
        //private var _reviewURL:String = '/tb/static-common/htmlfilter/previewer.png';
        private var _iconPath:String;		//UI图标路径
        private var _maxSize:Number;		//允许上传的最大容量
        private var _maxWidth:Number;		//最大宽度
        private var _maxHeight:Number;		//最大高度
        private var _uploadURL:String;		//上传URL
        private var _imageURL:String;		//默认加载的图片
        
        private var _completeInterface:String;	//上传成功的页面接口
        private var _compressInterface:String;	//压缩完成的页面接口
        private var _errorInterface:String;		//上传错误的页面接口
        private var _loadErrorInterface:String;	//加载图片失败
        
        private var _mainWindow:JWindow;
        private var _center:JPanel;
        private var _left:JPanel;
        
        private var _btnBar:JPanel;
        private var _toolTabPanel:SimpleTabedPane;
        private var _okBtn:JButton;
        private var _cancelBtn:JButton;
        private var _toolPane:JPanel;
        private var _baseToolsWrap:JList;
        
        private var _handlePanel:JPanel;
        private var _viewport:Viewport;
        
        private var _clipper:Clipper;
        private var _uploader:ImageDataUploader;
        private var _uploadVariables:Object;
        private var _top:JPanel;
        private var _nav:ImageNav;
        
        /**
         * 上传 
         */
        private var _submitBar:JPanel;
        private var _submitBtn:MyButton;
        private var _uploaderGroup:ImageDataUploaderGroup;
        private var _uploadUIManager:UploaderUIManager;

        
        /**
         * 滤镜
         */
        private var _filtersScrollPanel:MyScrollPane;
        private var _filtersListWrap:FilterListPanel;
        private var _filterUIManager:FilterUIManager;
        /**
         * 饰品
         */
        private var _sticksTabContainer:JPanel;
        private var _sticksListWrap:SticksListPanel;
        private var _sticksScrollPanel:MyScrollPane;
        private var _stickerUIManager:StickerUIManager;
        
        /**
         * 文件列表
         */
        private var _frlist:FileReferenceList;
        
        public function TbGram()
        {
            stage.scaleMode = 'noScale';
            stage.align = 'LT';
            Security.allowDomain("*"); 
            
            //IE下 防止缓存导致UI渲染错误问题
            setTimeout(_addToStage, 100);
        }
        
        private function _addToStage(evt:Event=null):void
        {
            
            if(stage.stageWidth <= 0 || stage.stageHeight <= 0){
                setTimeout(arguments.callee, 50);
            }else{
                //配置文件
                _filterConfigURL = this.loaderInfo.parameters.configURL || '../filters/filters_conf.js';
                
                // 饰品配置文件
                _sticksConfigURL = this.loaderInfo.parameters.sticksConfigURL || '../sticks/sticks_tabs_conf.js';
                
                _maxSize = this.loaderInfo.parameters.maxSize || 5;
                _maxHeight = this.loaderInfo.parameters.maxHeight || 3000;
                _maxWidth = this.loaderInfo.parameters.maxWidth || 3000;
                _uploadURL = this.loaderInfo.parameters.uploadURL || '/upload';
                _imageURL = this.loaderInfo.parameters.imageURL || null;
                _iconPath = this.loaderInfo.parameters.iconPath || '../images/';
                
                _completeInterface = _interfaceFilter(this.loaderInfo.parameters.upload_complete) || 'upload_complete';
                _compressInterface = _interfaceFilter(this.loaderInfo.parameters.compress_complete) || 'compress_complete';
                _errorInterface = _interfaceFilter(this.loaderInfo.parameters.upload_error) || 'upload_error';
                _loadErrorInterface = _interfaceFilter(this.loaderInfo.parameters.load_error) || 'load_error';
                
                _buildLayout();
                _buildPreviewer();
                _buildSticks();
                _buildFiltersBar();
                _buildBaseTools();
                _buildNav();
                _buildSubmitBar();
                _buildTools();
                
                _viewport.addEventListener(ViewportEvent.CHANGE, _previewChangeHandler);
            }
        }
        
        //________________build ui___________________
        
        private function _buildLayout():void
        {
            var bgColor:ASColor = new ASColor(0x000000, 0.85);
            AsWingManager.initAsStandard( this);
            _mainWindow = new JWindow();
            
            var pane:Container = _mainWindow.getContentPane();
            pane.setLayout(new BorderLayout());
            
            _left = new JPanel(new BorderLayout);
            _left.setPreferredWidth(236);
            _left.setBackground(bgColor);
            _left.setOpaque(true);
            
            _top = new JPanel();
            _top.setWidth(stage.stageWidth);
            _top.setHeight(44);
            _top.setPreferredHeight(44);
            _top.setOpaque(true);
            _top.setBackground(bgColor);
            _top.setLayout(new BorderLayout());
            
            _center = new JPanel(new BorderLayout());
            _center.setBorder(new EmptyBorder(null, new Insets(0, 0, 0, 0)));
            _center.setBackground(bgColor);
            _center.setOpaque(true);
            pane.append(_top, BorderLayout.NORTH);
            pane.append(_center, BorderLayout.CENTER);
            pane.append(_left, BorderLayout.WEST);
            
            _mainWindow.setSizeWH(stage.stageWidth, stage.stageHeight);
            _mainWindow.show();
            
        }
        private function _buildPreviewer():void
        {
            _viewport = new Viewport();
            _center.append(_viewport, BorderLayout.CENTER);
            
            _clipper = new Clipper(_viewport, 100, 100, new Rectangle(0,0,200,200), true, false, true, _iconPath);
            _clipper.addEventListener(Event.COMPLETE, function(evt:Event):void{
                _viewport.clip(_clipper.getClipRect());
            });
        }
        
        private function _buildSubmitBar():void
        {
            _submitBar = new JPanel();
            _submitBar.setBackground(new ASColor(0x393a3c, 0.9));
            _submitBar.setOpaque(true);
            _submitBar.setBorder(new SideLineBorder(new EmptyBorder(null, new Insets(0, 0, 0, 0)), 4, new ASColor(0x585858, 1), 1));
            _submitBtn = new MyButton('上传');
            _submitBtn.setBorder(new EmptyBorder(null, new Insets(5, 75, 5, 10)));
            _submitBar.append(_submitBtn);
            
            _uploadUIManager = new UploaderUIManager(_viewport, _nav, _submitBtn);
        }
        
        /**
         * 构建图片导航
         */
        private function _buildNav():void
        {
            var navPane:JPanel = new JPanel(new BorderLayout);
            navPane.setOpaque(true);
            navPane.setBackground(new ASColor(0x393a3c, 0.9));
            _top.append(navPane);
            
            _nav = new ImageNav(stage.stageWidth);
            _nav.addEventListener(ImageNav.ACTIVE_CHANGE, _imageNavActiveChange);
            
            navPane.addChild(_nav);
        }
        
        /**
         * 构建饰品选择栏
         */
        private function _buildSticks():void
        {
            _sticksTabContainer = new JPanel();
            
            _sticksTabContainer.setPreferredWidth(238);
            _sticksTabContainer.setPreferredHeight(300);
            _sticksTabContainer.setHeight(200);
            _sticksTabContainer.setBorder(new LineBorder(null, new ASColor(0x000000), 2));
            
            
            //饰品管理
            _stickerUIManager = new StickerUIManager(_viewport, _sticksTabContainer, _sticksConfigURL);
            
        }
        
        private function _buildFiltersBar():void
        {
            _filtersListWrap = new FilterListPanel(new FlowAutoHeightLayout(FlowWrapLayout.LEFT, 7, 7, true));
            _filtersListWrap.setPreferredWidth(238);
            
            //滤镜管理
            _filterUIManager = new FilterUIManager(_viewport, _filtersListWrap, _filterConfigURL); 
            
            _filtersScrollPanel = new MyScrollPane(_filtersListWrap, JScrollPane.SCROLLBAR_ALWAYS, JScrollPane.SCROLLBAR_NEVER);
            _filtersScrollPanel.setPreferredWidth(238);
        }
        
        private function _buildTools():void
        {
            _toolTabPanel = new SimpleTabedPane();
            
            _toolTabPanel.appendTab(_sticksTabContainer, '饰品');
            _toolTabPanel.appendTab(_filtersScrollPanel, '滤镜');
            _toolTabPanel.appendTab(_handlePanel, '基本');
            
            _left.append(_toolTabPanel, BorderLayout.CENTER);
            _left.append(_submitBar, BorderLayout.SOUTH);
            //算高度，太恶心了
            _toolTabPanel.setMaximumHeight(stage.stageHeight - _top.getPreferredHeight() - 3);
        }
        private function _buildBaseTools():void
        {
            var font:ASFont = new ASFont('微软雅黑, arial', 12);
            var clipLabel:JLabelButton = new JLabelButton('裁剪', new LoadIcon(_iconPath + 'clip_link.png'));
            var rotateLeftLabel:JLabelButton = new JLabelButton('左转', new LoadIcon(_iconPath + 'rotateleft_link.png'));
            var rotateRightLabel:JLabelButton = new JLabelButton('右转', new LoadIcon(_iconPath + 'rotateright_link.png'));
            
            clipLabel.setHorizontalAlignment(AsWingConstants.LEFT);
            rotateLeftLabel.setHorizontalAlignment(AsWingConstants.LEFT);
            rotateRightLabel.setHorizontalAlignment(AsWingConstants.LEFT);
            
            clipLabel.setFont(font);
            rotateLeftLabel.setFont(font);
            rotateRightLabel.setFont(font);
            
            clipLabel.addEventListener(MouseEvent.CLICK, function():void{
                _clipper.initClipRect(_viewport.viewportRect);
                _clipper.begin();
            });
            rotateLeftLabel.addEventListener(MouseEvent.CLICK, function():void{
                _clipper.end();
                _viewport.viewportRotation = 270;
            });
            rotateRightLabel.addEventListener(MouseEvent.CLICK, function():void{
                _clipper.end();
                _viewport.viewportRotation = 90;
            });
            
            _handlePanel = new JPanel(new SoftBoxLayout(1, 10));
            
            clipLabel.setForeground(new ASColor(0xb1b1b1));
            clipLabel.setRollOverColor(new ASColor(0xcccccc));
            clipLabel.setRollOverIcon(new LoadIcon(_iconPath + 'clip_hover.png'));
            
            rotateLeftLabel.setForeground(new ASColor(0xb1b1b1));
            rotateLeftLabel.setRollOverColor(new ASColor(0xcccccc));
            rotateLeftLabel.setRollOverIcon(new LoadIcon(_iconPath + 'rotateleft_hover.png'));
            
            rotateRightLabel.setForeground(new ASColor(0xb1b1b1));
            rotateRightLabel.setRollOverColor(new ASColor(0xcccccc));
            rotateRightLabel.setRollOverIcon(new LoadIcon(_iconPath + 'rotateright_hover.png'));
            
            clipLabel.setHorizontalTextPosition(10);
            clipLabel.setWidth(10);
            
            _handlePanel.append(clipLabel);
            _handlePanel.append(rotateLeftLabel);
            _handlePanel.append(rotateRightLabel);
            _handlePanel.setPreferredWidth(165);
            _handlePanel.setBorder(new EmptyBorder(null, new Insets(10, 20, 10, 20)));
        }
        
        /***
         * 过滤接口参数 防止XSS
         */
        private function _interfaceFilter(str:String):String
        {
            if(!str || str == '') return null;
            return str.replace(/[^\w\$\.]/g, '');
        }
        
        /**
         * 图片渲染
         */
        
        private function _imageNavActiveChange(evt:Event):void
        {
            var activeItem:ImageItem = _nav.getItemAt(_nav.active);
            var bd:BitmapData = activeItem.originalBitmapData;
            _viewport.setSource(bd, 0, bd.width, bd.height, true);
        }
        /**
         * 监听图像预览区的图片数据变化
         */
        private function _previewChangeHandler(evt:Event):void
        {
            //改变图片列表中的数据存储
            var activeItem:ImageItem = _nav.getItemAt(_nav.active);
            activeItem.setSource(_viewport.getOriginalSourceCopyAt(0));
        }

    }
}

