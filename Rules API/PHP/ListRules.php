<?php
// Instantiate an instance of cURL
$ch   = curl_init($url);
curl_setopt_array($ch, array(
  CURLOPT_RETURNTRANSFER => 1,
  // Add your account name and stream label to the URL below
  CURLOPT_URL => "https://gnip-api.twitter.com/rules/powertrack/accounts/{ACCOUNT_NAME}/publishers/twitter/{STEAM_LABEL}.json",
  CURLOPT_HTTPAUTH => CURLAUTH_BASIC,
  // Enter your username and password (basic auth)
  CURLOPT_USERPWD => "{USERNAME}".":"."{PASSWORD}",
  // CURLOPT_VERBOSE => true  // Uncomment for curl verbosity
));
    $response = curl_exec($ch);
    curl_close($ch);
print $response."\n";



?>