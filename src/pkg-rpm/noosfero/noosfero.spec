%define writable_dirs articles image_uploads thumbnails
%define cache_dirs javascripts/cache stylesheets/cache

Name:    noosfero
Version: 1.5.0+spb10
Release: 1
Summary: Social Networking Platform
Group:   Applications/Publishing
License: AGPLv3
URL:     http://noosfero.org
Source0: %{name}-%{version}.tar.gz
BuildArch: noarch
BuildRequires: noosfero-deps >= 1.5.1, gettext, po4a
Requires: noosfero-deps >= 1.5.1, po4a, tango-icon-theme, memcached,crontabs, nodejs

%description
Noosfero is a web platform for social and solidarity economy networks with blog,
e-Porfolios, CMS, RSS, thematic discussion, events agenda and collective
inteligence for solidarity economy in the same system! Get to know, use it,
participate and contribute to this free software project!

%prep
%setup -q

%build

ln -sf /usr/lib/noosfero/Gemfile .
ln -sf /usr/lib/noosfero/Gemfile.lock .
ln -sf /usr/lib/noosfero/.bundle .
ln -sfT /usr/lib/noosfero/vendor/bundle vendor/bundle
mkdir tmp
bundle exec rake -f Rakefile.release makemo
bundle exec rake -f Rakefile.release noosfero:translations:compile > build.log 2>&1 || (cat build.log; exit 1)
rm -f build.log Gemfile Gemfile.lock .bundle vendor/bundle
rm -rf tmp log

%install
mkdir -p %{buildroot}/usr/lib/noosfero

# install noosfero tree
cp -r * %{buildroot}/usr/lib/noosfero/
rm %{buildroot}/usr/lib/noosfero/{COPY*,Vagrantfile,*.md,gitignore.example,public/dispatch.fcgi,public/dispatch.cgi,public/dispatch.rb}
# no point in installing debian/ as part of the RPM
rm -rf %{buildroot}/usr/lib/noosfero/debian
# installed plugins should be in /etc
rm -rf %{buildroot}/usr/lib/noosfero/config/plugins

# install config files
mkdir -p %{buildroot}/etc/systemd/system
cat > %{buildroot}/etc/systemd/system/noosfero.service <<EOF
[Unit]
Description=Noosfero service

[Service]
Type=forking
User=noosfero
WorkingDirectory=/usr/lib/noosfero
ExecStart=/usr/lib/noosfero/script/production start
ExecStop=/usr/lib/noosfero/script/production stop
TimeoutSec=300

[Install]
WantedBy=multi-user.target
EOF

mkdir -p %{buildroot}/etc/noosfero/plugins
ln -sf /etc/noosfero/database.yml %{buildroot}/usr/lib/noosfero/config/database.yml
ln -sf /etc/noosfero/unicorn.rb %{buildroot}/usr/lib/noosfero/config/unicorn.rb
ln -sf /etc/noosfero/application.rb %{buildroot}/usr/lib/noosfero/config/application.rb

mkdir -p %{buildroot}/etc/noosfero/plugins
cp config/plugins/README %{buildroot}/etc/noosfero/plugins
ln -sfT /etc/noosfero/plugins %{buildroot}/usr/lib/noosfero/config/plugins

# symlink needed bits in public/
for dir in %{writable_dirs}; do
  ln -sfT /var/lib/noosfero/public/$dir %{buildroot}/usr/lib/noosfero/public/$dir
done
# symlink needed to cache
for dir in %{cache_dirs}; do
  ln -sfT /var/lib/noosfero/cache %{buildroot}/usr/lib/noosfero/public/$dir
done

ln -sfT /var/tmp/noosfero %{buildroot}/usr/lib/noosfero/tmp
ln -sfT /var/log/noosfero %{buildroot}/usr/lib/noosfero/log

# default themes
ln -sfT noosfero   %{buildroot}/usr/lib/noosfero/public/designs/themes/default
ln -sfT tango      %{buildroot}/usr/lib/noosfero/public/designs/icons/default


cat > %{buildroot}/etc/noosfero/unicorn.rb <<EOF
listen "127.0.0.1:3000"

worker_processes `nproc`.to_i
EOF

cat > %{buildroot}/etc/noosfero/database.yml <<EOF
production:
  adapter: postgresql
  encoding: unicode
  database: noosfero_production
  username: noosfero
  host: localhost

  port: 5432
EOF

cat > %{buildroot}/etc/noosfero/application.rb <<EOF
require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'active_support/dependencies'

# FIXME this silences the warnings about Rails 2.3-style plugins under
# vendor/plugins, which are deprecated. Hiding those warnings makes it easier
# to work for now, but we should really look at putting those plugins away.
ActiveSupport::Deprecation.silenced = true

Bundler.require(:default, :assets, Rails.env)

module Noosfero
  class Application < Rails::Application

    require 'noosfero/plugin'

    require 'noosfero/multi_tenancy'
    config.middleware.use Noosfero::MultiTenancy::Middleware

    config.action_controller.include_all_helpers = false

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W( #{config.root.join('app', 'sweepers')} )
    config.autoload_paths += Dir["#{config.root}/lib"]
    config.autoload_paths += Dir["#{config.root}/app/controllers/**/"]
    config.autoload_paths += %W( #{config.root.join('test', 'mocks', Rails.env)} )

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # Sweepers are observers
    # don't load the sweepers while loading the database
    ignore_rake_commands = %w[
      db:schema:load
      gems:install
      clobber
      noosfero:translations:compile
      makemo
    ]
    if \$PROGRAM_NAME =~ /rake$/ && (ignore_rake_commands.include?(ARGV.first))
      Noosfero::Plugin.should_load = false
    else
      config.active_record.observers = :article_sweeper, :role_assignment_sweeper, :friendship_sweeper, :category_sweeper, :block_sweeper
    end

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = nil

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable escaping HTML in JSON.
    ActiveSupport::JSON::Encoding.escape_html_entities_in_json = true

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    # config.active_record.schema_format = :sql

    # Enforce whitelist mode for mass assignment.
    # This will create an empty whitelist of attributes available for mass-assignment for all models
    # in your app. As such, your models will need to explicitly whitelist or blacklist accessible
    # parameters by using an attr_accessible or attr_protected declaration.
    config.active_record.whitelist_attributes = true

    # Asset pipeline
    config.assets.paths =
      Dir.glob("app/assets/plugins/*/{,stylesheets,javascripts}") +
      Dir.glob("app/assets/{,stylesheets,javascripts}") +
      # no precedence over core
      Dir.glob("app/assets/designs/{icons,themes,user_themes}/*")

    # disable strong_parameters before migration from protected_attributes
    config.action_controller.permit_all_parameters = true
    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    config.sass.preferred_syntax = :scss
    config.sass.cache = true
    config.sass.line_comments = false

    config.action_dispatch.session = {
      :key    => '_noosfero_session',
    }
    config.session_store :active_record_store, key: '_noosfero_session'

    config.paths['db/migrate'].concat Dir.glob("#{Rails.root}/{baseplugins,config/plugins}/*/db/migrate")
    config.i18n.load_path.concat Dir.glob("#{Rails.root}/{baseplugins,config/plugins}/*/locales/*.{rb,yml}")

    config.eager_load = true

    Noosfero::Plugin.setup(config)

  end
end
EOF

mkdir -p %{buildroot}/etc/default
cat > %{buildroot}/etc/default/noosfero <<EOF
NOOSFERO_DIR="/usr/lib/noosfero"
NOOSFERO_USER="noosfero"
NOOSFERO_DATA_DIR="/var/lib/noosfero"
EOF

%pre
if [ $1 -gt 1 ]; then
  echo 'Stopping noosfero'
  systemctl stop noosfero
fi

%post
groupadd noosfero || true
if ! id noosfero; then
  adduser noosfero --system -g noosfero --shell /bin/sh --home-dir /usr/lib/noosfero
fi

for dir in %{writable_dirs}; do
  mkdir -p /var/lib/noosfero/public/$dir
done
mkdir -p /var/lib/noosfero/cache

mkdir -p /var/lib/noosfero/cache

mkdir -p /var/log/noosfero/
mkdir -p /var/tmp/noosfero/
chown -R noosfero:root /var/tmp/noosfero
chown -R noosfero:root /var/log/noosfero

chown -R noosfero:noosfero /var/lib/noosfero
/etc/init.d/noosfero setup

cd /usr/lib/noosfero/

if [ -x /usr/bin/postgres ]; then
  if [ `systemctl is-active postgresql`!="active" ]; then
    postgresql-setup initdb || true
    systemctl start postgresql
  fi

  su postgres -c "createuser noosfero -S -d -R"
  su noosfero -c "createdb noosfero_production"

  cd /usr/lib/noosfero/
  su noosfero -c "RAILS_ENV=production bundle exec rake db:schema:load"
  su noosfero -c "RAILS_ENV=production SCHEMA=/dev/null bundle exec rake db:migrate"
  su noosfero -c "RAILS_ENV=production bundle exec rake db:data:minimal"
fi

if [ $1 -gt 1 ]; then
  echo 'Starting noosfero'
  systemctl daemon-reload
  systemctl start noosfero &
fi

%preun
service noosfero stop
systemctl disable noosfero

%files
/usr/lib/noosfero
/etc/systemd/system/noosfero.service
/etc/noosfero/plugins/README
%config(noreplace) /etc/default/noosfero
%config(noreplace) /etc/noosfero/database.yml
%config(noreplace) /etc/noosfero/unicorn.rb
%config(noreplace) /etc/noosfero/application.rb
%doc
