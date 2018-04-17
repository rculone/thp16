require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'pry'
require 'csv'
require 'dotenv'

#session.upload_from_file("/Users/quentinberson/THP/Google_Drive/hello.txt", "hello.txt", convert: false)

#Il faut laisser tourner le script 1 minute. J'affiche tout d'un coup!

def mairie (lien_mairie)
  begin
    mairie_page = Nokogiri::HTML(open(lien_mairie))
    mairie_h1 = mairie_page.css("div[1]/main/section[1]/div/div/div/h1").text.split(" - ") #On cherche le H1 et on split pour séparer le nom et le Zip Code
    mairie_name = mairie_h1[0]
    mairie_postal_code = mairie_h1[1]
    mairie_email = mairie_page.css("div[1]/main/section[2]/div/table/tbody/tr[4]/td[2]").text
    h = Hash[:name => mairie_name,:zip_code => mairie_postal_code,:email => mairie_email]
    return h
    rescue OpenURI::HTTPError => e
      if e.message == '404 Not Found'
        # handle 404 error
      else
        raise e
      end
  end
end

def scan_list_mairie (lien)
  url_origin = "http://annuaire-des-mairies.com/"
  list_mairie = []
  page_origin = Nokogiri::HTML(open(lien))
  mairie_link = page_origin.css('a.lientxt')
  mairie_link.each {|x|
    puts x
    link = x['href']
    link_to_mairie = URI.join(url_origin, link).to_s
    list_mairie.push(mairie(link_to_mairie))
}
#puts list_mairie
return list_mairie
end

def pagination (url_origin)
  doc = Nokogiri::HTML(open(url_origin))
  array_page_origin = []
  element = doc.css('tr/td/p/a:not(.lientxt)')
  element.each { |x|
    link = x['href']
    link_page = URI.join(url_origin, link).to_s
    array_page_origin << link_page

  }
  return array_page_origin
end

def to_csv (hash_array)
  CSV.open("data2.csv", "wb") do |csv|
    csv << hash_array.first.keys # adds the attributes name on the first line
    hash_array.each do |hash|
      if hash == nil
      else
      csv << hash.values
      end
    end
  end
end

def perform
  url_origin = ["http://annuaire-des-mairies.com/charente.html", "http://annuaire-des-mairies.com/charente-maritime.html","http://annuaire-des-mairies.com/deux-sevres.html"]
  page_mairie = []
  page_mairie_full = []
  url_origin.each{ |page|
  page_mairie.push(*pagination(page))
  }
  page_mairie.each { |y|
  page_mairie_full.push(scan_list_mairie(y))
  }
  new_array = page_mairie_full.flatten
  to_csv(new_array)
end

perform
