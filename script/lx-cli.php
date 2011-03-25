<?php

define('LX_HOME',       getenv('LX_HOME'));
define('T',             "\t");
define('SYS',           $argv[1]);
define('CURRENT',       $argv[2]);
define('DEBUG',         false);

function error($message)
{
  die('Error: ' . $message . PHP_EOL);
}

function execute_task($message,
                      $cmd,
                      $stdout   = false,
                      $stderr   = false)
{
  $r = 0;

  echo $message;

  if (!$stdout)
    $cmd .= ' > /dev/null';
  if (!$stderr)
    $cmd .= ' 2> /dev/null';

  if (DEBUG)
    echo N . $cmd . PHP_EOL;

  exec($cmd, &$cmd, &$r);

  if ($cmd && ($stdout || $stderr))
  {
    foreach ($cmd as $line)
      echo $line . PHP_EOL;
    echo $message;
  }

  echo ($r === 0 ? '[OK]' : '[KO]') . PHP_EOL;

  return $r === 0;
}

function copy_dir($src, $dst, $mkdir = false)
{
  $dir = opendir($src);
  if ($mkdir) { @mkdir($dst); }

  while (false !== ($file = readdir($dir)))
  {
    if (($file != '.') && ($file != '..'))
    {
      if (is_dir($src . '/' . $file))
        copy_dir($src  .  '/'  . $file, $dst . '/' . $file, true);
      else
        copy($src . '/' . $file, $dst . '/' . $file);
    }
  }

  closedir($dir);
}

function rm_rf($dir)
{
  if (is_dir($dir))
  {
    $objects = scandir($dir);

    foreach ($objects as $object)
    {
      if ($object != '.' && $object != '..')
      {
        if (filetype($dir . '/' . $object) == 'dir')
          rm_rf($dir . '/' . $object);
        else
          unlink($dir . '/' . $object);
      }
    }

    reset($objects);
    rmdir($dir);
  }
}

function copy_ext($src, $ext, $dst)
{
  if (!is_dir($src)) { die('ERROR: ' . $src); }

  $dir = opendir($src);

  while(false !== ($file = readdir($dir)))
  {
    if (!is_dir($file) && ($file != '.') && ($file != '..') && (substr($file, -strlen($ext)) == $ext))
    {
      copy($src . '/' . $file, $dst . '/' . $file);
    }
  }

  closedir($dir);
}

function create($path, $name, $archetype = null)
{
  $out = '';
  if (!is_dir($path))
    die('\'' . $path . '\' is not a valid directory.');

  @mkdir($path . '/' . $name);
  @mkdir($path . '/' . $name . '/bin');
  @mkdir($path . '/' . $name . '/bin/models');

  copy_dir(LX_HOME . '/archetype/default', $path . '/' . $name);
  if ($archetype && $archetype != 'default' && is_dir(LX_HOME . '/archetype/' . $archetype))
    copy_dir(LX_HOME . '/archetype/' . $archetype, $path . '/' . $name);

  @mkdir($path . '/' . $name . '/src/models');
  @mkdir($path . '/' . $name . '/lib');

  if (SYS === 'win')
  {
    @mkdir($path . '/' . $name . '/lib/lx');

    //windows does not support any ln -s so we have to copy all the lib right into the project
    copy_dir(LX_HOME, $path . '/' . $name . '/lib/lx');
    rm_rf($path . '/' . $name . '/lib/lx/project');

    copy_ext(LX_HOME . 'xsl/src', 'xsl', $path . '/' . $name . '/src/views');
  }
  else //any other unix based shell
  {
    exec('ln -s ' . LX_HOME . '/framework ' . $path . '/' . $name . '/lib/lx');
    exec('ln -s ' . LX_HOME . '/framework/xsl/src/*.xsl ' . $path . '/' . $name . '/src/views/');
  }

  exec('cd ' . $path . '/' . $name . ' && ' . LX_HOME . '/script/lx-cli update');

  return $out;
}

function update($feature)
{
  if (!file_exists(CURRENT . '/lx-project.xml'))
    error('the current directory is not an LX project');

  @mkdir(CURRENT . '/bin');
  @mkdir(CURRENT . '/bin/models');

  $out = '';

  switch($feature)
  {
    case 'lib':
      $out = lib();
      break;

    case 'config':
      $out = config();
      break;

    case 'models':
      $out = models();
      break;

    case 'all':
      $out = config();
      $out .= models();
      break;

    default:
      error('unknown parameter ' . $feature);
      break;
  }

  return $out;
}

function lib()
{
  $out = 'This undocumented feature is windows only';

  copy_dir(LX_HOME . '/framework/php', CURRENT . '/lib/lx');
}

function config($root = CURRENT)
{
  if (substr(exec('php --rc XSLTProcessor'), 0, 1) == 'E')
    error('XSLT PHP extension is not available');

  execute_task('Building configuration... ',
               'php '
               . LX_HOME . '/script/lx-project.php '
               . $root . '/lx-project.xml > ' . $root . '/bin/lx-project.php',
               true);
}

function models()
{
  $models       = array();
  $dir          = opendir(CURRENT . '/src/models');

  while(false !== ($file = readdir($dir)))
    if (($file != '.') && ($file != '..') && (substr($file, -3, 3) == 'xml'))
      array_push($models, substr($file, 0, -4));

  closedir($dir);

  foreach($models as $model)
  {
    execute_task('Building model \'' . $model . '\'... ',
                 'php -f '
                 . LX_HOME . '/script/lx-orm.php'
                 . ' src/models/' . $model . '.xml lx-php-orm.xsl'
                 . ' > bin/models/' . $model . '.php',
                 true);
  }
}

function export($project = CURRENT)
{
  if ($project && !(is_dir($project) && file_exists($project . '/lx-project.xml')))
    error('\'' . $project . '\' is not a valid LX project');

  config($project);
  require_once($project . '/bin/lx-project.php');

  // export databases
  if (count($_LX['databases']))
  {
    foreach ($_LX['databases'] as $db)
    {
      switch ($db['type'])
      {
        case 'mysql':
        default:
          export_mysql($db, $project);
        break;
      }
    }
  }
  else
  {
    echo 'No database to export' . PHP_EOL;
  }

  // export the project
  $basename = basename($project);
  $archive = $basename . '-' . date('Ymd') . '.tgz';
  execute_task('Exporting project to \'' . realpath($project . '/..') . '/' . $archive . '\'... ',
               'cd ' . realpath($project . '/..')
               . ' && tar czf ' . $archive . ' ' . $basename
               . ' --exclude-vcs');
}

function export_mysql($db, $root = CURRENT)
{
  execute_task('Exporting database \'' . $db['name'] . '.sql\'... ',
               'mysqldump'
               . ' -u ' . $db['user']
               . ' -h ' . $db['host']
               . (isset($db['password']) && $db['password'] ? ' -p' . $db['password'] : '')
               . ' --skip-extended-insert --skip-comments'
               . ' --databases ' . $db['name']
               . ' > ' . $root . '/' . $db['name'] . '.sql',
               true);
}

function import($archive = null)
{
  $dl = false;

  if ($archive)
  {
    if (!file_exists($archive))
    {
      if (preg_match('/^http:\/\/.*/', $archive) !== 0)
      {
        $tmp = tempnam(null, 'lx');
        $filename = substr($archive,
                           strrpos($archive, '/') + 1);

        echo 'Downloading archive \'' . $filename . '\' to '
          . '\'' . $tmp . '\'... ';

        $data = file_get_contents($archive);
        if ($data === false)
        {
          echo 'KO' . PHP_EOL;
          error('unable to download \'' . $archive . '\'');
        }
        else
        {
          echo 'OK' . PHP_EOL;
        }

        $file = fopen($tmp, 'w');
        fwrite($file, $data);
        fclose($file);

        $archive = $tmp;
        $dir = substr($filename, 0, strrpos($filename, '.'));
      }
      else
      {
        error('\'' . $archive . '\' does not exists.');
      }
    }
    else
    {
      $dir = substr($archive, 0, strrpos($archive, '.'));
    }

    $tar = execute_task('Extracting project from archive \'' . $archive . '\'... ',
                        'tar xvf ' . $archive);

    if ($dl)
      unlink($archive);

    if ($tar)
      echo exec('cd ' . $dir
                . ' && ' . LX_HOME . '/script/lx-cli.sh import') . PHP_EOL;
    else
      error('unable to extract');
  }
  else
  {
    config();
    require_once(CURRENT . '/bin/lx-project.php');

    foreach ($_LX['databases'] as $db)
    {
      switch ($db['type'])
      {
        case 'mysql':
        default:
          import_mysql($db);
        break;
      }
    }
  }
}

function import_mysql($db)
{
  $filename = CURRENT . '/' . $db['name'] . '.sql';
  if (!file_exists($filename))
    error('unable to import database: \'' . $filename . '\' is missing.');

  execute_task('Importing database \'' . $db['name'] . '.sql\'... ',
               'cat ' . $filename
               . ' | mysql'
               . ' -h ' . $db['host']
               . ' -u ' . $db['user']
               . (isset($db['password']) && $db['password'] ? ' -p' . $db['password'] : '')
               . ' --database ' . $db['name']);
}

function help()
{
  return 'Usage: lx-cli [%action=update]' . PHP_EOL
    . 'Actions:' . PHP_EOL
    . '  create %project [%archetype]' . T . 'Deploy a new project named %project in your current directory' . PHP_EOL
    . '  update' . T . T . T. 'Update all project files (configuration and models)' . PHP_EOL
    . '  update config' . T . T . T . 'Update configuration files only' . PHP_EOL
    . '  update models' . T . T . T . 'Update models only' . PHP_EOL
    . '  import [%archive]' . T . T . 'Import a project [from the %archive archive]' . PHP_EOL
    . '  export [%project]' . T . T . 'Export the %project project or the current directory project' . PHP_EOL
    . '  help' . T . T . T . T . 'Display this message' . PHP_EOL;
}

if (DEBUG)
  print_r($argv);

if (count($argv) < 4)
  die(update('all'));

switch($argv[3])
{
  case 'create':
    if (isset($argv[4]))
    {
      $name = $argv[4];
      $path = $argv[2];

      create($path, $name, isset($argv[5]) ? $argv[5] : null);
    }
    else
      die('error');
    break;

  case 'create-in':
    die(create(isset($argv[4]) ? $argv[4] : ''));
    break;

  case 'export':
    if (isset($argv[4]))
      export($argv[4]);
    else
      export();
    break;

  case 'import':
    import(isset($argv[4]) ? $argv[4] : null);
    break;

  case 'help':
    die(help());
  break;

  case 'update':
  default:
    die(update((isset($argv[4]) ? $argv[4] : 'all' )));
    break;
}

?>