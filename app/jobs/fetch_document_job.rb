class FetchDocumentJob < ApplicationJob
  queue_as :legacy # override in calling code for system

  def perform(document)
    document.fetch_resources!
  end
end
