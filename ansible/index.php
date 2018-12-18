<?php
phpinfo();


$dbcnx = mysqli_connect (getenv('DB_NAME'), getenv('DB_USER'), getenv('DB_PASSWORD'),getenv('DB_HOST')); 


$result = mysqli_query($dbcnx,"SHOW DATABASES"); 
while ($row = mysqli_fetch_array($result)) { 
	echo $row[0]."<br>"; 
}


?>