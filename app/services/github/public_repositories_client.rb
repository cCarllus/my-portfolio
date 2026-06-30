require "json"
require "net/http"
require "uri"

module Github
  class PublicRepositoriesClient
    class Error < StandardError; end

    API_HOST = "api.github.com"
    PER_PAGE = 100
    MAX_PAGES = 10

    attr_reader :profile_url

    def initialize(profile_url:, token: ENV["GITHUB_TOKEN"])
      @username = extract_username(profile_url)
      @profile_url = "https://github.com/#{@username}"
      @token = token
    end

    def repositories
      (1..MAX_PAGES).each_with_object([]) do |page, records|
        batch = fetch_page(page)
        records.concat(batch)
        break records if batch.size < PER_PAGE
      end
    end

    private

    attr_reader :username, :token

    def extract_username(value)
      uri = URI.parse(value.to_s.strip)
      segments = uri.path.to_s.split("/").reject(&:blank?)
      valid_host = uri.is_a?(URI::HTTPS) && uri.host.to_s.downcase.in?(%w[github.com www.github.com])

      raise Error, I18n.t("admin.highlights.github.invalid_url") unless valid_host && segments.one?

      segments.first
    rescue URI::InvalidURIError
      raise Error, I18n.t("admin.highlights.github.invalid_url")
    end

    def fetch_page(page)
      uri = URI::HTTPS.build(
        host: API_HOST,
        path: "/users/#{URI.encode_www_form_component(username)}/repos",
        query: URI.encode_www_form(type: "public", sort: "updated", direction: "desc", per_page: PER_PAGE, page:)
      )
      request = Net::HTTP::Get.new(uri)
      request["Accept"] = "application/vnd.github+json"
      request["User-Agent"] = "my-portfolio-github-sync"
      request["X-GitHub-Api-Version"] = "2022-11-28"
      request["Authorization"] = "Bearer #{token}" if token.present?

      response = Net::HTTP.start(uri.host, uri.port, use_ssl: true, open_timeout: 5, read_timeout: 15) do |http|
        http.request(request)
      end

      raise Error, error_message(response) unless response.is_a?(Net::HTTPSuccess)

      JSON.parse(response.body)
    rescue JSON::ParserError, SocketError, SystemCallError, Timeout::Error => error
      raise Error, I18n.t("admin.highlights.github.connection_error", message: error.message)
    end

    def error_message(response)
      case response.code.to_i
      when 404 then I18n.t("admin.highlights.github.not_found")
      when 403, 429 then I18n.t("admin.highlights.github.rate_limited")
      else I18n.t("admin.highlights.github.request_failed", status: response.code)
      end
    end
  end
end
