
require 'twitter'
require 'google_drive'

def find_twitter_user
    rows = @worksheet.rows
    # récupération des rows du spreadsheet, ils sont stockés dans l'array rows. On obtien un array de array.
    @users_array = []
    # création d'un array vide qui contiendra les noms d'utilisateur récupéré sur le spreadsheet
    rows.each { |row|
        users = row[2]
        @users_array.push(users)
    }
    # pour chaque élément du array rows, on garde l'index correspondant à la colonne twitter_handle puis ils sont pushé dans le users array
end

def follow_twitter_user
    @users_array.shift
    @users_array.each { |user|
        user.to_s
        client.follow(user)
    }
    # on follow chaque utilisateur contenu dans le user array.
end

find_twitter_user
follow_twitter_user
