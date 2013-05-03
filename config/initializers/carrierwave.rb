CarrierWave.configure do |config|
  config.fog_credentials = {
    :provider               => 'AWS',       # required
    :aws_access_key_id      => 'AKIAIY6YTR5CUMQ2NPEQ',       # required
    :aws_secret_access_key  => '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',       # required
    :region                 => 'eu-west-1',  # optional, defaults to 'us-east-1'
    :host                   => 'http://s3-eu-west-1.amazonaws.com',
  }
  config.fog_directory  = 'trainingsdiary' # required
  config.fog_public = true
  config.fog_attributes = {'Cache-Control' => 'max-age=315576000'}
  # see https://github.com/jnicklas/carrierwave#using-amazon-s3
  # for more optional configuration

end


