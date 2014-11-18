class EventsWorker
  include Sneakers::Worker
  # This worker will connect to "dashboard.posts" queue
  # env is set to nil since by default the actuall queue name would be
  # "dashboard.posts_development"
  from_queue "id.event", env: nil

  # work method receives message payload in raw format
  # in our case it is JSON encoded string
  # which we can pass to RecentPosts service without
  # changes
  def work(raw_event)
    event = JSON.parse(raw_event)
    if event["event"] == "kiwi_identity"
      User.id_reference(event)
      ack! # we need to let queue know that message was received
    else
      ack!
    end
  end
end