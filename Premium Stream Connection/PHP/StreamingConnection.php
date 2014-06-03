<?php
/*

  Consume a premium gnip stream, with compression.

*/

$stream_url = "YOUR_STREAM_URL_HERE";
$user = "YOUR_USERNAME_HERE";
$pass = "YOUR_PASSWORD_HERE";

// WRITEFUNCTION callback
// required to return the length of the data passed to it

function print_out_data($ch, $data) {
  echo $data;
  return strlen($data);
}

//Timeout considerations: these two setting can be tuned from the settings below to tweak your 
//system if you are not properly timing out.  
//CURLOPT_LOW_SPEED_LIMIT: long
// -- Specify the transfer speed in bytes per second that the transfer should be  
// below during CURLOPT_LOW_SPEED_TIME seconds for the library to 
//consider it too slow and abort.
//CURLOPT_LOW_SPEED_TIME: long
//-- Specify the time in seconds that the transfer should be 
//below the CURLOPT_LOW_SPEED_LIMIT for the library to consider 
//it too slow and abort.
//NOTE: you do not want to use the CURLOPT_TIMEOUT for streaming connections.


$ch = curl_init();
curl_setopt_array($ch, array(
  CURLOPT_URL => $stream_url,
  CURLOPT_ENCODING => "gzip",
  CURLOPT_FOLLOWLOCATION => true,
  CURLOPT_HTTPAUTH => CURLAUTH_BASIC,
  CURLOPT_USERPWD => $user.":".$pass,
  CURLOPT_WRITEFUNCTION => "print_out_data",
  CURLOPT_BUFFERSIZE => 2000,
  CURLOPT_LOW_SPEED_LIMIT => 1,
  CURLOPT_LOW_SPEED_TIME => 60
//  CURLOPT_VERBOSE => true // uncomment for curl verbosity

));

$running = null;

$mh = curl_multi_init();
curl_multi_add_handle($mh, $ch);

// the event loop

do {
  curl_multi_select($mh, 1);      // wait for activity
  curl_multi_exec($mh, $running); // perform activity

} while($running > 0);

curl_multi_remove_handle($mh, $ch);
curl_multi_close($mh);
?>
