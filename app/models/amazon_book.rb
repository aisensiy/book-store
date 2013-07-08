require 'vacuum'
require 'multi_xml'

class AmazonBook
  include HTTParty
  debug_output

  def self.get_book(url)
    book = {}

    pn = %r{/(product|dp)/([^/\.]+)/}
    item_id = pn.match(url)[2]

    req = Vacuum.new
    req.configure(key: 'AKIAI4XUTXUV6BVMU45Q', secret: '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', tag: 'os0af-20')

    params = {
      'Operation'     => 'ItemLookup',
      'IdType'        => 'ASIN',
      'ItemId'        => item_id,
      'ResponseGroup' => 'Medium'
    }

    @res = req.get(query: params)

    result = MultiXml.parse(@res.body)
    item = result["ItemLookupResponse"]["Items"]["Item"]

    book['cover_url'] = item["LargeImage"]["URL"]
    if item["ItemAttributes"]["Author"]
      book['author'] = [item["ItemAttributes"]["Author"]]
    elsif item["ItemAttributes"]["Creator"].is_a? Array
      book['author'] = [item["ItemAttributes"]["Creator"][0]["__content__"]]
    else
      book['author'] = [item["ItemAttributes"]["Creator"]["__content__"]]
    end
    book['isbn'] = item["ItemAttributes"]["ISBN"]
    book['publisher'] = item['ItemAttributes']["Publisher"]
    # pp item["ItemAttributes"]["PublicationDate"]
    book['title'] = item["ItemAttributes"]["Title"]
    if item["EditorialReviews"]["EditorialReview"].is_a? Array
      book['summary'] = item['EditorialReviews']['EditorialReview'][0]["Content"]
    else
      book['summary'] = item["EditorialReviews"]["EditorialReview"]["Content"]
    end

    book
  end

end
