package ui.upload
{
    import com.imagelib.ImageDataUploaderGroup;
    
    import flash.display.BitmapData;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Rectangle;
    import flash.utils.ByteArray;
    
    import ui.ImageNav;
    import ui.basic.ImageItem;
    import ui.basic.MyButton;
    import ui.viewport.Viewport;

    public class UploaderUIManager
    {
        // ui 
        private var _viewport:Viewport;
        private var _imageNav:ImageNav;
        private var _uploadBtn:MyButton;
        private var _uploadDialog:UploadDialog;
        
        private var _uploaderGroup:ImageDataUploaderGroup;
        private var totalCount:int;
        private var uploadedCount:int;
      
        public function UploaderUIManager(target:Viewport, imageNav:ImageNav, uploadBtn:MyButton)
        {
            _viewport = target;
            _imageNav = imageNav;
            _uploadBtn = uploadBtn;
            _uploaderGroup = new ImageDataUploaderGroup();
            
            _initDialog();
            _initSubmitEvent();
        }
        
        private function _initDialog():void
        {
            _uploadDialog = new UploadDialog();
            _uploadDialog.addEventListener(UploadDialog.EVENT_OK, _okHandler);
            _uploadDialog.addEventListener(UploadDialog.EVENT_CANCEL, _cancelHandler);
        }
        
        private function _okHandler(evt:Event):void
        {
            _hideDialog();
        }
        
        private function _cancelHandler(evt:Event):void
        {
            _hideDialog();
            _uploaderGroup.removeAllUploaders();
        }
        
        private function _initSubmitEvent():void
        {
            _uploadBtn.addEventListener(MouseEvent.CLICK, _uploadHandler);
        }
        
        private function _uploadHandler(evt:Event):void
        {
            _initUpload();
            _showDialog();
        }
        
        /**
         * 隐藏浮层
         */
        private function _hideDialog():void
        {
            _viewport.stage.removeChild(_uploadDialog);
        }
        /**
         * 展现浮层
         */
        private function _showDialog():void
        {
            _viewport.stage.addChild(_uploadDialog);
            
        }
        
        private function _initUpload():void
        {
            var imageItem:ImageItem;
            var len:int = _imageNav.getListLength();
            totalCount = len;
            uploadedCount = 0;
            var imageData:BitmapData;
            var byteArray:ByteArray;
            for (var i:int = 0; i < len; i++) {
                imageItem = _imageNav.getItemAt(i);
                imageData = imageItem.originalBitmapData;
                byteArray = _convertImageData(imageData);
                _uploaderGroup.addUploader('file' + i, imageData, 'upload.php');
            }
            
            _uploaderGroup.addEventListener(ImageDataUploaderGroup.EVENT_ALL_COMPLETE, _uploadCompleteHandler);
            _uploaderGroup.startUpload();
        }
        
        private function _uploadCompleteHandler(evt:Event):void
        {
            _uploadDialog.showOkBtn();
        }
        
        private function _convertImageData(imageData:*):ByteArray
        {
            var _fileData:ByteArray = new ByteArray();
            if(imageData is BitmapData){
                var data:BitmapData = (imageData as BitmapData);
                imageData.copyPixelsToByteArray(new Rectangle(0, 0, data.width, data.height), _fileData);
            }else if(imageData is ByteArray){
                _fileData = imageData;
            }
            return _fileData;
        }
        
    }
}