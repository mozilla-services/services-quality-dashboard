God.watch do |w|
  w.name = "dashboard"
  w.log = "/var/log/dashboard.log"
  w.dir = "/services-quality-dashboard/"
  w.interval = 10.seconds
  w.start = "dashing start -p 80"
  w.keepalive
end
