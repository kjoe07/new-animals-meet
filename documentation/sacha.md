#### Amis en commun

```GET /user/commonfriends```

##### Réponse:

```
{[
	"name": "Adrien Morel",
	"profilePicUrl": "http://xxx"
}]```

#### Ajout d’un ami (suivre):

```POST /user/{userid}/friend```

#### Suppression d'un ami:

```POST /user/{userid}/unfriend```

#### Description d'une image:

```POST /media/{mediaid}/description```

```text=la description```

#### A ajouter au modèle du profil utilisateur:

Nombre de like, de followers et de followed
Photo de profil

#### A ajouter pour les actualités:

Possibilité d'avoir des publications textuelles en plus des images. Je pense qu'il faut reprendre le modèle media avec la possiblité d'avoir du texte au lieu d'une image.
Il faut ajouter également au modèle media le nombre de commentaire.

#### Publications

```GET /user/{userid}/posts``` (paginé)

Obtenir toutes les publications d'un utilisateur.
Même genre de réponse que pour le feed d'actualité mais avec des objets post uniquement.

#### commentaires

```GET /media/{mediaid}/comments```

##### Réponse:

```
{[
	"id": "comment id",
	"author": {objet avec le nom et l'id},
	"text": "commentaire",
	"likeCount": 4,
]}```

```POST /comment/{commentid}/like```

```POST /comment/{commentid}/unlike```

#### Balade

```POST /balade```

-> Même modèle que pour la recherche

#### Autre

Ajouter des types de notifications
