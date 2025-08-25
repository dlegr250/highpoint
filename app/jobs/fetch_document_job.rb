class FetchDocumentJob < ApplicationJob
  queue_as :default

  def perform(document)
    document.fetch_resources!
  end
end
