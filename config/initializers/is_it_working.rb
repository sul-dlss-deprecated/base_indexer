require 'is_it_working'
Rails.configuration.middleware.use(IsItWorking::Handler) do |h|

end
