<?php
//sleep(10);
if (move_uploaded_file($_FILES['file']['tmp_name'], './a.jpg')) {
	echo '{"no":"0","data":""}';
} else {
	echo '{"no":"1","data":"uploaderror"}';
}
	
?>