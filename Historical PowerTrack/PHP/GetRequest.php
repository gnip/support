<?php

$user = "ENTER_USERNAME_HERE";
$pass = "ENTER_PASSWORD_HERE";
$url = "ENTER_API_URL_HERE";

$query = "gnip";

$queryString = $url."?publisher=twitter&query=".$query;

$ch   = curl_init($queryString);
curl_setopt_array($ch, array(
  CURLOPT_URL => $queryString,
  CURLOPT_ENCODING => "gzip",
  CURLOPT_HTTPAUTH => CURLAUTH_BASIC,
  CURLOPT_USERPWD => $user.":".$pass,
//  CURLOPT_VERBOSE => true

));

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
