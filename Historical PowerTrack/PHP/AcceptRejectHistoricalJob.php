<?php

$user = "ENTER_USERNAME";
$pass = "ENTER_PASSWORD";
$url = "ENTER_HISTORICAL_JOB_URL";

$choice = "accept"; // Switch to 'reject' if you want to reject the job.

$putData = "{\"status\":\"".$choice."\"}";

$ch   = curl_init($url);
curl_setopt_array($ch, array(
  CURLOPT_URL => $url,
  CURLOPT_HTTPAUTH => CURLAUTH_BASIC,
  CURLOPT_USERPWD => $user.":".$pass,
  CURLOPT_POST    => 1,
//  CURLOPT_VERBOSE => true  // Uncomment for curl verbosity
));

curl_setopt($ch, CURLOPT_HTTPHEADER, array('X-HTTP-Method-Override: PUT'));
curl_setopt($ch, CURLOPT_POSTFIELDS, $putData);

    $content = curl_exec( $ch );
    $err     = curl_errno( $ch );
    $errmsg  = curl_error( $ch );
    $header  = curl_getinfo( $ch );
    curl_close( $ch );

    $header['errno']   = $err;
    $header['errmsg']  = $errmsg;
    $header['content'] = $content;
    return $header;

print $content."\n";

?>
