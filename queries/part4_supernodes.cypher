// part4_supernodes.cypher

// 1. Пошук вузлів із найбільшою кількістю зв'язків
MATCH (n)
WITH n, labels(n) AS labels, count { (n)--() } AS degree
WHERE degree > 100
RETURN labels, n, degree
ORDER BY degree DESC
LIMIT 20;


// 2. Жанри з найбільшою кількістю фільмів
MATCH (g:Genre)<-[:HAS_GENRE]-(m:Movie)
RETURN g.name AS genre, count(m) AS movieCount
ORDER BY movieCount DESC;


// 3. Фільми з найбільшою кількістю оцінок
MATCH (m:Movie)<-[r:RATED]-(:User)
RETURN m.title AS movieTitle, count(r) AS ratingsCount
ORDER BY ratingsCount DESC
LIMIT 20;


// 4. Користувачі з найбільшою кількістю оцінок
MATCH (u:User)-[r:RATED]->(:Movie)
RETURN u.userId AS userId, count(r) AS ratingsCount
ORDER BY ratingsCount DESC
LIMIT 20;