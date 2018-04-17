require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'pry'
require 'csv'
require 'dotenv'
require 'google_drive'

# ATTENTION L UPLOAD SUR DRIVE DURE PLUS DE 3 MINUTES
# Scrap les informations sur l annuaire des "Mairie"s 
def mairie (lien_mairie)
  begin
    mairie_page = Nokogiri::HTML(open(lien_mairie))
    mairie_h1 = mairie_page.css("div[1]/main/section[1]/div/div/div/h1").text.split(" - ") # Get H1 and split it to have Name and Zip Code in an array
    mairie_name = mairie_h1[0] # First index of mairie_h1 is the name
    mairie_postal_code = mairie_h1[1] # Second index of mairie_h1 is the zip code
    mairie_email = mairie_page.css("div[1]/main/section[2]/div/table/tbody/tr[4]/td[2]").text # Get email on the page
    h = Hash[:name => mairie_name,:zip_code => mairie_postal_code,:email => mairie_email]
    return h # h here is for one Mairie. The hash is then push to an array in scan_list_mairie(35)
    rescue OpenURI::HTTPError => e # Some Mairie doesn't have email. To avoid Error with Nil value, we use rescue.
      if e.message == '404 Not Found' # If there is an error (ie: no email for the mairie) we skip it.
        # handle 404 error
      else
        raise e
      end
  end
end

# Scan for all mairie page on a departement page and return everything in an array of hash
def scan_list_mairie (lien)
  url_origin = "http://annuaire-des-mairies.com/" # Domain name to concatenate the href where it is missing with URI.join
  list_mairie = []
  page_origin = Nokogiri::HTML(open(lien)) # Open a page where all mairie are listed
  mairie_link = page_origin.css('a.lientxt') # Get all <a> balise with a class "lientxt"
  mairie_link.each {|x|
    puts x
    link = x['href'] # Only get the href value
    link_to_mairie = URI.join(url_origin, link).to_s # Join the URI. link = ./95/ableiges.html here, so we need the rest of the URL. See url_origin above.
    list_mairie.push(mairie(link_to_mairie)) # Call mairie to push the hash in an array of hash
}
return list_mairie # return an array of hash which contain all mairie from one list page (ie : http://annuaire-des-mairies.com/val-d-oise.html)
end

# Some departement page have a pagination, this handle it.
def pagination (url_origin)
  doc = Nokogiri::HTML(open(url_origin))
  array_page_origin = []
  element = doc.css('tr/td/p/a:not(.lientxt)') # Here we search for all <a> link basically, and only took those who arent a certain class. lientxt class are the link for mairie
  element.each { |x| # Same technic here as in scan_list_mairie to have proper URL to scan later on
    link = x['href']
    link_page = URI.join(url_origin, link).to_s
    array_page_origin << link_page

  }
  return array_page_origin # return all page, if there is, on a mairie list page (ie: http://annuaire-des-mairies.com/charente-maritime.html).
end

def send_to_spreadsheet (hash_array)
  session = GoogleDrive::Session.from_config("config.json")
  ws = session.spreadsheet_by_key("1IdENLO56DzWO-H7N2VQ2ychlexaOnVtP2QiYhjPBsdM").worksheets[0]
  # Set up the header
  ws[1, 1] = "Mairie"
  ws[1, 2] = "Zip Code"
  ws[1, 3] = "Email"
  i = 2 # to start after header
  hash_array.each{ |x|
  if x == nil
  else
    puts x
  ws[i, 1] = x[:name]
  ws[i, 2] = x[:zip_code]
  ws[i, 3] = x[:email]
  ws.save
  end
  i += 1 # Go to next line
  }
end

def perform
  # enter here the department you wanna scrap
  url_origin = ["http://annuaire-des-mairies.com/charente.html", "http://annuaire-des-mairies.com/charente-maritime.html","http://annuaire-des-mairies.com/deux-sevres.html"]
  page_mairie = []
  page_mairie_full = []
  url_origin.each{ |page|
  page_mairie.push(*pagination(page)) # here we push all page that exist (with pagination), see pagination method.
  }
  page_mairie.each { |y|
  page_mairie_full.push(scan_list_mairie(y)) # Scrap all the data for every mairie
  }
  new_array = page_mairie_full.flatten # We use flatten here because if not we are an array of array of hash
  send_to_spreadsheet(new_array) # We save everything to CSV
end

perform
