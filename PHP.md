# php useful stuff

## NextCloud php theming for multitenancy

Disable theming app, then create a file to case the domain:

```
# cat /var/www/your_nextcloud/config/domains.config.php
<?php

#error_reporting(E_ALL);
#ini_set('display_errors', TRUE);
#ini_set('display_startup_errors', TRUE);

if (isset($_SERVER['HTTP_HOST'])) {
    switch ($_SERVER['HTTP_HOST']) {
    case 'some.domain.com':
            $CONFIG['theme']='someTheme';
            break;
    case 'another.domain.com':
            $CONFIG['theme']='anotherTheme';
            break;
    }
}
```

Both `someTheme` and `anotherTheme` themes must be created in `/var/www/your_nextcloud/themes/`, copied from `example`

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
