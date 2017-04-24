# php useful stuff



## php unzipper
For webhost without  shell access
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
