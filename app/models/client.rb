class Client
  def self.client
    @client ||= HTTPX
      .plugin(:retry, :follow_redirects)
      .with(
        ssl: {
          
        },
        timeout: {
          connect_timeout: 10,
          operation_timeout: 300
        },
        pool_max_size: 20
      )
  end

  def self.download_to(url, target_path)
    target_dir = File.dirname(target_path)
    FileUtils.mkdir_p(target_dir)

    response = client.get(url)

    if response&.body
      File.binwrite(target_path, response.body)
    end

    response
  end
end
