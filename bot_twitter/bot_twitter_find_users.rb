
require 'twitter'
require 'google_drive'

def find_user
    rows = @worksheet.rows
    # récupération des rows du spreadsheet
    search_array = []
    # création d'un array vide des recherches à faire sur twitter = maire de ville
    rows.each { |row|
        search = "Maire de #{row[0]}"
        search_array.push(search)
    }
    # pour chaque rows, on construit un string avec le prefixe maire de + le premier index du row ici la ville puis on le push dans l'array.
    @results = []
    #création d'un array vide pour stocker les résultats de la recherche (les noms des utilisateurs twitter)
    search_array.each { |ville|
        @search = client.user_search(ville).take(1)  
        @search.each { |user|
            user_tweet = user.screen_name
                @results.push(user_tweet)
            }
    }
    # on fait une recherche dans le champ utilisateur twitter pour chaque ville (on recherche maire de "ville") pour récupérer le premier uitlisateur qui ressort.
    # pour chaque user récupéré (1 par recherche) on garde le screen name de l'utilisateur et on le push dans l'array.
    # On se retouve avec un array de nom d'utilisateur 
end

def update_spreadsheet
    @results.delete_at(0)
    # on supprime la première entre de l'array qui correspond au header
    @worksheet[1,3] = "twitter_handle"
    x = 2
    @results.each { |user|
        @worksheet[x,3] = user
        x +=1
        @worksheet.save
    }
    # on update la spreadsheet avec les usernames récupérés + un header twitter_handle
end

find_user
update_spreadsheet
