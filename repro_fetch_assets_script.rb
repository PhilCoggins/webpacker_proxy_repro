require "json"
require "http"
require "connection_pool"

MAX_THREADS = ENV["MAX_THREADS"]&.to_i || 10
manifest = JSON(File.read("public/packs/manifest.json"))
paths = manifest.values.select { |value| value.is_a? String }
pool = ConnectionPool.new(size: 130, timeout: 30) { HTTP }
threads = []

while true
  (1..MAX_THREADS).each do |idx|
    threads << Thread.new do
      path = paths[idx - 1]

      puts "[Thread id=#{idx}] - #{Time.now} -  Starting Request for #{path}"
      res = nil
      begin
        pool.with do |http|
          res = http.get("http://localhost:3000#{path}").flush
          # res = http.get("http://localhost:3000/packs/js/vendors~galaxy-0~galaxy-1~galaxy-10~galaxy-100~galaxy-101~galaxy-102~galaxy-103~galaxy-104~galaxy-10~f7ef419f-3ef0f8342e800985dbec.chunk.js").flush
          [res.code, res.headers, res.body.to_str]
          # res = http.get("http://localhost:3035#{path}")
          # res = HTTP.get("http://localhost:3000#{path}").flush
        end
      rescue
        puts "[Thread id=#{idx}] - #{Time.now} -  Failed!"
        # raise
      end

      puts "[Thread id=#{idx}] - #{Time.now} -  Finished with response code #{res&.code}"
    end
  end

  threads.map(&:join)
  # sleep 5
end
