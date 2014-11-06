namespace :rabbitmq do
  desc "Setup routing"
  task :setup do
    require "bunny"

    conn = Bunny.new
    conn.start

    ch = conn.create_channel

    # get or create exchange
    x = ch.fanout("kiwi.events")

    # get or create queue (note the durable setting)
    queue = ch.queue("id.parties", durable: true)

    # bind queue to exchange
    queue.bind("kiwi.events")

    conn.close
  end
end