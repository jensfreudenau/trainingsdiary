#AWS::S3::Base.establish_connection!(
ENV['AWS_ACCESS_KEY_ID']     = ENV['S3_KEY']
ENV['AWS_SECRET_ACCESS_KEY'] = ENV['S3_SECRET']
#)