task :environment do
  $:.unshift 'lib'
  $:.unshift '.'
  require 'greek'
end

namespace :db do
  desc "auto_migrate the models"
  task :init => [:environment] do
    DataMapper.auto_migrate!
  end

  desc "create welcome Post"
  task :welcome => [:environment] do
    post = Post.create(:title => 'Welcome!', :summary => 'Read on my friend, feel welcome.', :body => 'Welcome to the very first post')
  end

  desc "add greek alpabets"
  task :greekify do
    grk_alphabet = %w(Alpha\ a Beta\ b Gamma\ g Delta\ d Epsilon\ e Zeta\ z Eta\ h Theta\ th Iota\ i Kappa\ k Lambda\ l Mu\ m Nu\ n Xi\ x Omicron\ o Pi\ p Rho\ r Sigma\ s Tau\ t Upsilon\ u Phi\ ph Chi\ ch Psi\ ps Omega\ o)
    grk_alphabet.each do |pc|
      pcname = pc.split
      GreekClass.create(:name => pcname[0], :slug => pcname[1])
    end
  end

  task :bootstrap => [:init, :welcome, :greekify]
end
