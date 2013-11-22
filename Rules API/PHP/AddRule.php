<?php

$user = "ENTER_USERNAME_HERE";
$pass = "ENTER_PASSWORD_HERE";

$rule_value = "testRule";
$rule_tag = "testTag";

//	Expected Premium Stream URL Format:
//	https://api.gnip.com:443/accounts/<account>/publishers/<publisher>/streams/<stream>/<label>/rules.json

$url = "ENTER_RULES_API_URL_HERE";

$rules = "{\"rules\":[{\"value\":\"".$rule_value."\",\"tag\":\"".$rule_tag."\"}]}";

$ch   = curl_init($url);
curl_setopt_array($ch, array(
  CURLOPT_URL => $url,
  CURLOPT_ENCODING => "gzip",
  CURLOPT_HTTPAUTH => CURLAUTH_BASIC,
  CURLOPT_USERPWD => $user.":".$pass,
  CURLOPT_POST    => 1,
  CURLOPT_POSTFIELDS => $rules,
//  CURLOPT_VERBOSE => true  // Uncomment for curl verbosity
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
