<?php

$user = "ENTER_USERNAME";
$pass = "ENTER_PASSWORD";
$accountName = "ENTER_GNIP_CONSOLE_ACCOUNT_NAME";

$url = "https://historical.gnip.com/accounts/".$accountName."/jobs.json";

$publisher = "twitter";
$streamType = "track";
$dataFormat = "activity-streams";
$fromDate = "201301010000"; // This time is inclusive -- meaning the minute specified will be included in the data returned
$toDate = "201301010001"; // This time is exclusive -- meaning the data returned will not contain the minute specified, but will contain the minute immediately preceding it
$jobTitle = "my historical job php";
$serviceUsername = "your_twitter_handle"; // This is the Twitter username your company white listed with Gnip for access.
$rules = "[{\"value\":\"rule 1\",\"tag\":\"ruleTag\"},{\"value\":\"rule 2\",\"tag\":\"ruleTag\"}]";

$jobString = "{\"publisher\":\"$publisher\",\"streamType\":\"$streamType\",\"dataFormat\":\"$dataFormat\",\"fromDate\":\"$fromDate\",\"toDate\":\"$toDate\",\"title\":\"$jobTitle\",\"serviceUsername\":\"$serviceUsername\",\"rules\":$rules}";

$ch   = curl_init($url);
curl_setopt_array($ch, array(
  CURLOPT_URL => $url,
  CURLOPT_ENCODING => "gzip",
  CURLOPT_HTTPAUTH => CURLAUTH_BASIC,
  CURLOPT_USERPWD => $user.":".$pass,
  CURLOPT_POST    => 1,
  CURLOPT_RETURNTRANSFER => true,
  CURLOPT_POSTFIELDS => $jobString,
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
