#!/usr/bin/env ruby

safe_mode = ARGV.include? '--safe'

linkables = Dir.glob('*{.symlink}')
linkables.each do |linkable|
  file = linkable.split('/').last.split('.symlink').last
  unless safe_mode and File.exists?("#{ENV['HOME']}/.#{file}")
    %x(ln -s -i -v $PWD/#{linkable} ~/.#{file})
    puts ".#{file} linked" if safe_mode
  end
end
