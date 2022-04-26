DROP TABLE IF EXISTS "election-csv";
CREATE TABLE "election-csv" (
"Code du département"           DECIMAL NOT NULL,
"Département"                   VARCHAR(5) NOT NULL,
"Code de la circonscription"    DECIMAL NOT NULL,
"Circonscription"               VARCHAR(21) NOT NULL,
"Code de la commune"            DECIMAL NOT NULL,
"Commune"                       VARCHAR(70) NOT NULL,
"Bureau de vote"                DECIMAL NOT NULL,
"Inscrits"                      DECIMAL NOT NULL,
"Abstentions"                   DECIMAL NOT NULL,
"% Abs/Ins"                     DECIMAL NOT NULL,
"Votants"                       DECIMAL NOT NULL,
"% Vot/Ins"                     DECIMAL NOT NULL,
"Blancs"                        DECIMAL NOT NULL,
"% Blancs/Ins"                  DECIMAL NOT NULL,
"% Blancs/Vot"                  DECIMAL NOT NULL,
"Nuls"                          DECIMAL NOT NULL,
"% Nuls/Ins"                    DECIMAL NOT NULL,
"% Nuls/Vot"                    DECIMAL NOT NULL,
"Exprimés"                      DECIMAL NOT NULL,
"% Exp/Ins"                     DECIMAL NOT NULL,
"% Exp/Vot"                     DECIMAL NOT NULL,
"N°Panneau"                     DECIMAL NOT NULL,
"Sexe"                          VARCHAR(1) NOT NULL,
"Nom"                           VARCHAR(13) NOT NULL,
"Prénom"                        VARCHAR(8) NOT NULL,
"Voix"                          DECIMAL NOT NULL,
"% Voix/Ins"                    DECIMAL NOT NULL,
"% Voix/Exp"                    DECIMAL NOT NULL,
"Code Insee"                    DECIMAL NOT NULL,
"Coordonnées"                   VARCHAR(19),
"Nom Bureau Vote"               VARCHAR(70),
"Adresse"                       VARCHAR(70),
"Code Postal"                   DECIMAL,
"Ville"                         VARCHAR(70),
uniq_bdv                        VARCHAR(85)
);

\************************************************************************************************\

DROP TABLE IF EXISTS "department_table";
create table "department_table" as
select distinct "Code du département", "Département"
from  "election-csv";

alter table "department_table" 
add primary key ("Code du département") ;
 
\************************************************************************************************\

drop table if exists "circonscription_table";
create table "circonscription_table" as
select distinct "Code du département", "Code de la circonscription", "Circonscription"
from "election-csv" ;

alter table "circonscription_table" 
add constraint "cir_cle" primary key ("Code du département", "Code de la circonscription");
alter table "circonscription_table" 
add foreign key ("Code du département") references "department_table" ("Code du département");

\************************************************************************************************\

drop table if exists "commune_table";
create table "commune_table" as
select distinct "Code du département", "Code de la commune", "Commune"
from "election-csv" ;

alter table "commune_table" 
add constraint "com_cle" primary key ("Code du département", "Code de la commune");
alter table "commune_table"
add foreign key ("Code du département") references "department_table" ("Code du département");

\************************************************************************************************\

drop table if exists  "bureau_table" ;
create table "bureau_table" as 
select distinct "Bureau de vote", "Code Insee", "Inscrits", "Abstentions", "% Abs/Ins",
"Votants", "% Vot/Ins", "Blancs", "% Blancs/Ins", "% Blancs/Vot", "Nuls",
"% Nuls/Ins", "% Nuls/Vot", "Exprimés", "% Exp/Ins", "% Exp/Vot", "Coordonnées",
"Nom Bureau Vote", "Adresse", "Code Postal","Ville", uniq_bdv
from "election-csv";

alter table "bureau_table"
add constraint "cle_bureau" primary key ("Bureau de vote","Code Insee");

\************************************************************************************************\

drop table if exists "candidat_table";
create table "candidat_table" as 
select distinct "N°Panneau", "Sexe", "Nom", "Prénom"
from "election-csv";

alter table "candidat_table"
add constraint "cle_candidat" primary key ("N°Panneau");

\************************************************************************************************\

drop table if exists "voter";
create table "voter" as
select distinct "Bureau de vote", "Code Insee", "N°Panneau", "Voix", "% Voix/Ins", "% Voix/Exp" 
from "election-csv";

alter table "voter"
add constraint "cle_voter" primary key ("Bureau de vote", "Code Insee", "N°Panneau");

alter table "voter"
add constraint "vot_cle-etranger_1" foreign key ("Bureau de vote", "Code Insee") 
references "bureau_table" ("Bureau de vote", "Code Insee");

alter table "voter"
add constraint "vot_cle-etranger_2" foreign key ("N°Panneau") 
references  "candidat_table" ("N°Panneau");

\************************************************************************************************\

drop table if exists "bureau_dans_circonscription";
create table "bureau_dans_circonscription" as 
select distinct "Bureau de vote", "Code Insee", "Code du d?partement", "Code de la circonscription"
from "election-csv";

alter table "bureau_dans_circonscription"
add constraint "cle_?tre_dans_cir" primary key ("Bureau de vote", "Code Insee");

alter table "bureau_dans_circonscription"
add constraint "bureau_dans_cle-etranger_1" foreign key ("Bureau de vote", "Code Insee") 
references "bureau_table" ("Bureau de vote", "Code Insee");

alter table "bureau_dans_circonscription"
add constraint "bureau_dans_cle-etranger_2" foreign key ("Code du d?partement", "Code de la circonscription") 
references "circonscription_table" ("Code du d?partement", "Code de la circonscription");

\************************************************************************************************\

drop table if exists "bureau_dans_commune";
create table "bureau_dans_commune" as 
select distinct "Bureau de vote", "Code Insee", "Code du d?partement","Code de la commune"
from "election-csv";

alter table "bureau_dans_commune"
add constraint "cle_?tre_dans_com" primary key ("Bureau de vote", "Code Insee");

alter table "bureau_dans_commune"
add constraint "bureau_dans_com-etranger_1" foreign key ("Bureau de vote", "Code Insee") 
references "bureau_table" ("Bureau de vote", "Code Insee");

alter table "bureau_dans_commune"
add constraint "bureau_dans_com-etranger_2" foreign key ("Code du d?partement", "Code de la commune") 
references "commune_table" ("Code du d?partement", "Code de la commune");

\************************************************************************************************\

select distinct "Ville", "Nom", "Voix"
	,rank() over  
    (PARTITION BY "Ville" ORDER BY "Voix" DESC) AS Rank
from "voter" join "candidat_table" on "candidat_table"."N°Panneau"="voter"."N°Panneau" 
join "bureau_table" on  "bureau_table"."Bureau de vote"="voter"."Bureau de vote"
and "bureau_table"."Code Insee"="voter"."Code Insee";

\************************************************************************************************\

select distinct "Ville", "Nom", "Voix"
,rank() over
(partition by "Ville" order by "Voix" desc) as rank 
from voter v join candidat_table ct on ct."N°Panneau" =v."N°Panneau" 
			 join bureau_table bt on bt."Bureau de vote" =v."Bureau de vote" 
			 		and bt."Code Insee"=v."Code Insee" ;

\************************************************************************************************\			 	
			 	
SELECT DISTINCT "Nom", "Voix", "Ville"
,rank() over  
    (ORDER BY "Voix" DESC) AS Rank
from "voter" join "candidat_table" on "candidat_table"."N°Panneau"="voter"."N°Panneau" 
join "bureau_table" on  "bureau_table"."Bureau de vote"="voter"."Bureau de vote"
and "bureau_table"."Code Insee"="voter"."Code Insee"
WHERE "Ville" = 'Neaux';
        