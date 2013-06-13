require 'open-uri'

class UploadFile < BaseClient
  def self.upload(filename, filetype, filebody)
    headers = self.headers.merge({"Content-Type" => filetype})
    post("/1/files/#{URI::encode sanitize(filename)}", body: filebody, headers: headers)
  end

  private
  def self.sanitize(name)
    sanitize_regexp = /[^[:word:]\.\-\+]/
    name = name.gsub("\\", "/") # work-around for IE
    name = File.basename(name)
    name = name.gsub(sanitize_regexp, "_")
    name = "_#{name}" if name =~ /\A\.+\z/
    name = "unnamed" if name.size == 0
    return name.mb_chars.to_s
  end
end
