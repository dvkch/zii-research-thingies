RSpec::Matchers.define :be_valid_email do |*expected|

  # We check if the email has the HTML content type header, contains both text and HTML variants, etc
  # This is needed to have a better spam score on SpamAssassin rules HTML_MESSAGE, HTML_MIME_NO_HTML_TAG, MIME_HTML_ONLY
  match do |email|
    @errors = []

    if email.nil?
      @errors << 'No email sent'
      return false
    end

    content_type_header = email.header['Content-Type'].value || ''
    body_text = email.text_part.to_s || ''
    body_html = email.html_part.to_s || ''

    @errors << 'Missing multipart header' unless content_type_header.start_with?('multipart/alternative') || content_type_header.start_with?('multipart/mixed')
    @errors << 'Missing text part' if body_text.blank?
    @errors << 'Missing html part' if body_html.blank?

    @errors.empty?
  end

  failure_message do |actual|
    "Invalid email: #{@errors.join(', ')}"
  end
end
