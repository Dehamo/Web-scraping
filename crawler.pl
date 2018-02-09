#!/usr/bin/perl

use LWP::Simple;
use HTML::Entities;
use XML::Entities;
%HTML::Entities::char2entity = %{
	XML::Entities::Data::char2entity('all');
 };

# Ouverture des fichiers 
open my $outputTxt, ">:encoding(utf-8)", "data-italian.txt";
open my $outputXml,">:encoding(utf-8)", "data-italian.xml";

print $outputXml "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n\n";
print $outputXml "<?xml-stylesheet type=\"text/xsl\" href=\"xslt-html.xsl\"?>\n\n<corpus>\n\n"; 

# Liste des mois pour la normalisation de la date 
my @monthList = qw(gennaio febbraio marzo aprile maggio giugno luglio agosto settembre ottobre novembre dicembre); 

my %data; 
my $pagination = 0;
my $cptPage = 1; 

while ($pagination <= 8960) 
{
    # Cas où on veut les résultats dans plusieurs fichiers 
    # open my $outputTxt, ">:encoding(utf-8)", "data-italian-$cptPage.txt";
    # open my $outputXml,">:encoding(utf-8)", "data-italian-$cptPage.xml";

    # print $outputXml "<?xml version=\"1.0\" encoding=\"UTF-8\">\n\n<corpus>\n\n";

    # Téléchargement de la page 
    my $page = get("https://www.tripadvisor.it/ShowForum-g187147-i14-o$pagination-Paris_Ile_de_France.html");
        
    my $cptLien = 1;
    
    # Téléchargement des liens
    while ($page =~/<td class=\"\">\n<b>(.+?)<\/td>/gms) 
    {    
        my $review; 
        print "I'm working on the link number $cptLien on page number $cptPage\n";
        my $lien = $1;
        $lien =~/<a href="([^"]+)".+/;
        $review = "https://www.tripadvisor.it".$1;
        my $content = get($review);
        print "I downloaded : " . "$review\n\n";

        # Traitement du contenu des balises 
        while ($content=~/<div class='postDate'>(.+?)<\/div>\n<div class='postBody'>\n<div id=.+?><\/div>\n<div id=.+?><\/div>\n<div id=.+?><\/div>(.+?)<\/div>/gs) 
        {
            my $date = $1;
            my $text = $2;
            $text =~s/<[^>]+>//g;
            $text =~s/\n/ /g;

            # Nettoyage manuel
            # $text =~s/&quot;/"/g; 
            # $text =~s/&#39;/'/g;  
            # $text =~s/&#160;/ /g;  
            # $text =~s/&amp;/&/g;   

            # Normalisation de la date 
            if ($date =~/(\d+) (\w+) (\d+), (\d+):(\d+)/gs)
            {
                $month = $2; 
                my $cptMonth = 0; 

                while ($cptMonth <= 13)
                {
                    if ($monthList[$cptMonth] eq $month)
                    {
                        $month = $cptMonth +1; 
                        next; 
                    }
                        
                    $cptMonth++; 
                }
                    
                if ($month < 10)
                {
                    $month = "0".$month; 
                }

                $date = "$3/$month/$1";

                # Nettoyage automatique
                decode_entities($date);
		        decode_entities($text);

                # Ecriture des résultats dans les fichiers
                print $outputTxt "DATE : $date\nTEXT : $text\n\n" if (!(exists $data{$text}));  

                # Remplacement éventuel des caractères spéciaux par des entités
                # encode_entities($date);
		        # encode_entities($text);

                # Remplacement des caractères spéciaux manuellement
                $text =~s/</&lt;/g; 
                $text =~s/>/&gt;/g; 
                $text =~s/&/&amp;/g; 
                # $text =~s/'/&apos;/g; 
                # $text =~s/"/&quot;/g; 

                # Balisage pour l'affichage avec la feuille de style xslt
                $text =~s/ i Parigini / <mark>i Parigini<\/mark> /g; 
                $text =~s/ vero parigino / <mark>vero parigino<\/mark> /g;
                $text =~s/ un parigino / <mark>un parigino<\/mark> /g; 
                $text =~s/ i ragazzi parigini / <mark>i ragazzi parigini<\/mark> /g;  
                $text =~s/insolita/<mark>insolita<\/mark>/g; 
                $text =~s/insolite/<mark>insolite<\/mark>/g; 
                $text =~s/insoliti/<mark>insoliti<\/mark>/g; 
                $text =~s/insolito/<mark>insolito<\/mark>/g; 
                $text =~s/segreta/<mark>segreta<\/mark>/g; 
                $text =~s/segreti/<mark>segreti<\/mark>/g; 
                $text =~s/segreto/<mark>segreto<\/mark>/g; 
                $text =~s/autentica/<mark>autentica<\/mark>/g; 
                $text =~s/autentici/<mark>autentici<\/mark>/g; 
                $text =~s/autentico/<mark>autentico<\/mark>/g; 

                print $outputXml "\t<post date=\"$date\">\n\t\t<url page=\"$cptPage\">$review</url>\n\t\t<content>$text\t</content>\n\t</post>\n\n" if (!(exists $data{$text}));  
                $data{$text} = 1;
                
            }
        }

        $cptLien++; 
        #sleep(5);
    }

    # Cas où on veut les résultats dans plusieurs fichiers 
    # print $outputXml "</corpus>"; 
    # close $outputTxt; 
    # close $outputXml; 

    $cptPage++; 
    $pagination = $pagination+20;

    # Téléchargement d'un nombre important de données
    # if ($cptPage % 20 == 0)
    # {
        # sleep(5);
    # }

}

print $outputXml "</corpus>"; 
close $outputTxt; 
close $outputXml; 
