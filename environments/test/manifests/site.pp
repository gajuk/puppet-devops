node "test-site" {

 
  file { ['/var/www']:
    ensure => 'directory',
    owner   => root,
    group   => root,
    mode    => '755'
  }

  file {'/var/www/test-app/current/index.html':
    ensure => 'file',
    content => 'This is a sample app.',
    owner   => root,
    group   => root,
    mode    => '755'
  }

  class { 'nginx':
    client_max_body_size => '512M',
    worker_processes => 2,

  }
     file { ['/var/www/test-app', '/var/www/test-app/current', '/var/www/test-app/releases', '/var/www/test-app/shared']:
      ensure => 'directory',
      owner => 'root',
      group => 'root',
      mode => '0750',
 }

  # NGINX Configuration
  file { '/etc/nginx/ssl':
    ensure => directory,
    owner => 'root',
    group => 'root',
  }

  file { '/etc/nginx/ssl/example.com.crt':
    ensure => file,
    owner => 'root',
    group => 'root',
    mode => '0644',
    source => 'puppet:///modules/nginx/example.com.crt',
  }

  file { '/etc/nginx/ssl/example.com.key':
    ensure => file,
    owner => 'root',
    group => 'root',
    mode => '0644',
    source => 'puppet:///modules/nginx/example.com.key',
  }

  $server_name = "testapi.example.com"

  nginx::resource::server {"$server_name":
    ssl                  => true,
    ssl_port             => 443,
    ssl_redirect         => true,
    ssl_cert             => "/etc/nginx/ssl/example.com.crt",
    ssl_key              => "/etc/nginx/ssl/example.com.key",
    ssl_protocols        => 'TLSv1.2 TLSv1.1 TLSv1',
    ensure               => present,
    use_default_location => false,
    www_root             => "/var/www/test-app/current/",
  }

  nginx::resource::location {"/":
    server                => "$server_name",
    ensure                => present,
    ssl 		=> true,
    www_root             => "/var/www/test-app/current/",
    priority              => 401,
  }

  nginx::resource::location { "~* ^.+\.(jpg|jpeg|gif)$":
    server                => "$server_name",
    ensure                => present,
    ssl_only 		  => true,
    www_root             => "/var/www/test-app/current/",
    ssl 		=> true,
    index_files		=>  ['index.html', 'index.htm', 'index.php' ],
    expires		=> "30d",
  }


}
