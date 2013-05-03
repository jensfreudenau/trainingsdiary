CarrierWave.configure do |config|
  config.root = Rails.root.join('tmp') # adding these...
  config.cache_dir = 'carrierwave' # ...two lines
  config.fog_credentials = {
    :provider               => 'AWS',       # required
    :aws_access_key_id      => 'AKIAIY6YTR5CUMQ2NPEQ',       # required
    :aws_secret_access_key  => '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',       # required
    :region                 => 'eu-west-1',  # optional, defaults to 'us-east-1'
    :host                   => 's3-eu-west-1.amazonaws.com',
    :endpoint               => 'http://s3-eu-west-1.amazonaws.com' # optional, defaults to nil
  }
  config.fog_directory  = 'trainingsdiary' # required
  config.cache_dir = "#{Rails.root}/tmp/uploads"
  # see https://github.com/jnicklas/carrierwave#using-amazon-s3
  # for more optional configuration
end

