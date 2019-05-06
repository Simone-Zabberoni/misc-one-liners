# php useful stuff

## php unzipper

For webhost without shell access

```
<?php
  $unzip = new ZipArchive;
  $out = $unzip->open('somefile.zip');
  if ($out === TRUE) {
    $unzip->extractTo(getcwd());
    $unzip->close();
    echo 'Unzip OK';
  } else {
    echo 'Unzip ERR';
  }
?>
```

## simple mail send

```
<?PHP
$sender = 'szabberoni@tomware.it';
$recipient = 'simone.zabberoni@gmail.com';

$subject = "php mail test";
$message = "php test message";
$headers = 'From:' . $sender;

if (mail($recipient, $subject, $message, $headers))
{
    echo "Message accepted";
}
else
{
    echo "Error: Message not accepted";
}
?>
```
