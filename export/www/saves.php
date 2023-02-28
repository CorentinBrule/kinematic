<?php 

header("Content-Type: application/json");
$save_dir = "save";
$files = array_diff(scandir($save_dir), array('.', '..'));
$datas = array();
foreach ($files as $file) {
    
    if (pathinfo($file)['extension'] == "json") {
        $json = file_get_contents($save_dir . "/" . $file);
        $json_data = json_decode($json, true);
        array_push($datas, $json_data);
    }
}
echo json_encode($datas);
?>
