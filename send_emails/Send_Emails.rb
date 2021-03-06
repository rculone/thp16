require 'gmail'
require 'rubygems'
require 'google_drive'
require 'csv'

#à partir de la liste d'emails scrappés sur les sites internet des villes
#On envoi un mail à chaque adresse

def get_emails  #methode d envoi d emails aux mairies

email = ""  #creation d une variable vide de type chaine de caractere pour stocker les emails
ville = ""  #creation d une variable vide de type chaine de caractere pour stocker les noms des villes

CSV.foreach('data.csv') do |row| #pour chaque ligne du fichier csv data.csv on crée une variable row

    ville = "#{row[0]}" #on recupére la valeur de la ligne traitée en colonne 0 (1 ére colonne) qui corespond à la ville
    email = "#{row[2]}" #on recupére la valeur de la ligne traitée en colonne 2 (3eme colonne) qui correspond à l' email

        #Connectez-vous avec les identifiants de votre boite email Gmail
        gmail = Gmail.connect("xxxxxxx@gmail.com", "password")


        email = gmail.compose do #pour chaque ligne du tableau csv donc pour chaque ville , on envoi le smail ci-dessous.
            to "email"           #adresse de destination
            subject "Apprendre à coder Gratuitement!"#sujet de l email
            #message
            body  "Bonjour,
            nous sommes un groupe d éleves , nous sommes élèves à The Hacking Project, une formation au code gratuite, sans locaux, sans sélection, sans restriction géographique. La pédagogie de ntore école est celle du peer-learning, où nous travaillons par petits groupes sur des projets concrets qui font apprendre le code. Le projet du jour est d'envoyer (avec du codage) des emails aux mairies pour qu'ils nous aident à faire de The Hacking Project un nouveau format d'éducation pour tous.
            Déjà 300 personnes sont passées par The Hacking Project. Est-ce que la mairie de #{ville} veut changer le monde avec nous ?
            Charles, co-fondateur de The Hacking Project pourra répondre à toutes vos questions : 06.95.46.60.80."

        end
        email.deliver!  #envoi de l email

        gmail.logout    #deconnexion de Gmail

end
end

get_emails #appel de la methode d envoi d emails
