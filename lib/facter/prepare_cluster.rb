# prepare_cluster.rb

Facter.add("prepare_cluster") do
  setcode do
    locks = 'tems:'
    Dir.glob('/etc/prepare_cluster/*') do |lock|
      locks += File.basename(lock) + ":"
    end
    locks
  end
end
