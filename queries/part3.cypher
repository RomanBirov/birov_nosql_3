// part3.cypher

// Запит 1. Фільми жанру Thriller із середнім рейтингом вище 4.0
MATCH (m:Movie)-[:HAS_GENRE]->(:Genre {name: "Thriller"})
MATCH (m)<-[r:RATED]-(:User)
WITH m, avg(r.rating) AS avgRating, count(r) AS ratingCount
WHERE avgRating > 4.0 AND ratingCount >= 20
RETURN m.title AS movieTitle, round(avgRating * 100) / 100 AS avgRating, ratingCount
ORDER BY avgRating DESC, ratingCount DESC
LIMIT 10;


// Запит 2. Користувачі, які поставили оцінку 5 більш ніж 50 фільмам
MATCH (u:User)-[r:RATED]->(:Movie)
WHERE r.rating = 5
WITH u, count(r) AS fiveStarRatings
WHERE fiveStarRatings > 50
RETURN u.userId AS userId, fiveStarRatings
ORDER BY fiveStarRatings DESC
LIMIT 10;


// Запит 3. Фільми, які обидва користувачі 1 і 2 оцінили високо
MATCH (u1:User {userId: 1})-[r1:RATED]->(m:Movie)<-[r2:RATED]-(u2:User {userId: 2})
WHERE r1.rating >= 4 AND r2.rating >= 4
RETURN m.title AS movieTitle, r1.rating AS user1Rating, r2.rating AS user2Rating
ORDER BY r1.rating + r2.rating DESC
LIMIT 10;


// Запит 4. Жанри, які стабільно отримують високі оцінки
MATCH (g:Genre)<-[:HAS_GENRE]-(m:Movie)<-[r:RATED]-(:User)
WITH g.name AS genreName, avg(r.rating) AS avgRating, count(r) AS ratingCount
WHERE avgRating >= 3.5 AND ratingCount >= 1000
RETURN genreName, round(avgRating * 100) / 100 AS avgRating, ratingCount
ORDER BY avgRating DESC, ratingCount DESC
LIMIT 10;


// Запит 5. Рекомендації для користувача 1 через схожі смаки
MATCH (u:User {userId: 1})-[r1:RATED]->(m:Movie)<-[r2:RATED]-(other:User)
WHERE r1.rating >= 4 AND r2.rating >= 4
WITH u, other, count(m) AS commonMovies
WHERE commonMovies >= 3
MATCH (other)-[r:RATED]->(recMovie:Movie)
WHERE r.rating >= 4 AND NOT (u)-[:RATED]->(recMovie)
RETURN recMovie.title AS recommendation, avg(r.rating) AS avgRating, count(other) AS similarUsers
ORDER BY similarUsers DESC, avgRating DESC
LIMIT 10;


// Запит 6. Найкоротший ланцюжок між користувачами 1 і 46 через спільні фільми
MATCH path = shortestPath(
  (u1:User {userId: 1})-[:RATED*..6]-(u2:User {userId: 46})
)
RETURN path, length(path) AS pathLength;