CarrierWave.configure do |config|
  config.fog_credentials = {
    :provider               => 'AWS',       # required
    :aws_access_key_id      => '1234',       # required
    :aws_secret_access_key  => '123',       # required
    :region                 => 'eu-west-1',  # optional, defaults to 'us-east-1'
    :host                   => 's3-eu-west-1.amazonaws.com',
    #:endpoint               => 'http://s3-eu-west-1.amazonaws.com' # optional, defaults to nil
  }
  config.fog_directory  = 'trainingsdiary' # required
  config.fog_public = true
  config.fog_attributes = {'Cache-Control' => 'max-age=315576000'}
  # see https://github.com/jnicklas/carrierwave#using-amazon-s3
  # for more optional configuration

end


