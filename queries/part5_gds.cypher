// =====================================================
// 5.1 PageRank
// =====================================================

// Очищення перед запуском
CALL gds.graph.drop('movieGraph', false);

MATCH ()-[co:CO_RATED]-()
DELETE co;


// Створення зв'язків між схожими фільмами
MATCH (m1:Movie)<-[r1:RATED]-(u:User)-[r2:RATED]->(m2:Movie)
WHERE r1.rating = 5
  AND r2.rating = 5
  AND id(m1) < id(m2)

WITH m1, m2, count(u) AS weight

WHERE weight >= 50

WITH m1, m2, weight
ORDER BY weight DESC
LIMIT 5000

MERGE (m1)-[co:CO_RATED]-(m2)
SET co.weight = weight;


// Перевірка кількості зв'язків
MATCH ()-[r:CO_RATED]-()
RETURN count(r) AS coRatedRelationships;


// Створення графа для PageRank
CALL gds.graph.project(
  'movieGraph',
  'Movie',
  {
    CO_RATED: {
      orientation: 'UNDIRECTED',
      properties: 'weight'
    }
  }
);


// Запуск PageRank
CALL gds.pageRank.stream('movieGraph', {
  relationshipWeightProperty: 'weight'
})
YIELD nodeId, score

RETURN
gds.util.asNode(nodeId).title AS movieTitle,
score

ORDER BY score DESC
LIMIT 10;


// Очищення після PageRank
CALL gds.graph.drop('movieGraph');

MATCH ()-[co:CO_RATED]-()
DELETE co;


// =====================================================
// 5.2 Louvain
// =====================================================

// Очищення перед запуском
CALL gds.graph.drop('userSimilarity', false);

MATCH ()-[sim:SIMILAR]-()
DELETE sim;


// Створення зв'язків між схожими користувачами
MATCH (u1:User)-[r1:RATED]->(m:Movie)<-[r2:RATED]-(u2:User)
WHERE r1.rating = 5
  AND r2.rating = 5
  AND id(u1) < id(u2)

WITH u1, u2, count(m) AS weight

WHERE weight >= 10

WITH u1, u2, weight
ORDER BY weight DESC
LIMIT 3000

MERGE (u1)-[sim:SIMILAR]-(u2)
SET sim.weight = weight;


// Перевірка кількості зв'язків
MATCH ()-[r:SIMILAR]-()
RETURN count(r) AS similarRelationships;


// Створення графа для Louvain
CALL gds.graph.project(
  'userSimilarity',
  'User',
  {
    SIMILAR: {
      orientation: 'UNDIRECTED',
      properties: 'weight'
    }
  }
);


// Запуск Louvain
CALL gds.louvain.stream('userSimilarity', {
  relationshipWeightProperty: 'weight'
})
YIELD nodeId, communityId

WITH
communityId,
count(*) AS userCount,
collect(gds.util.asNode(nodeId).userId)[0..10] AS sampleUsers

RETURN
communityId,
userCount,
sampleUsers

ORDER BY userCount DESC
LIMIT 10;


// Очищення після Louvain
CALL gds.graph.drop('userSimilarity');

MATCH ()-[sim:SIMILAR]-()
DELETE sim;


// =====================================================
// 5.3 Dijkstra
// =====================================================

// Очищення перед запуском
CALL gds.graph.drop('userGraph', false);

MATCH ()-[sim:SIMILAR]-()
DELETE sim;


// Створення графа користувачів
MATCH (u1:User)-[r1:RATED]->(m:Movie)<-[r2:RATED]-(u2:User)
WHERE r1.rating = 5
  AND r2.rating = 5
  AND id(u1) < id(u2)

WITH u1, u2, count(m) AS commonMovies

WHERE commonMovies >= 10

WITH u1, u2, commonMovies
ORDER BY commonMovies DESC
LIMIT 3000

MERGE (u1)-[sim:SIMILAR]-(u2)
SET sim.weight = 1.0 / commonMovies;


// Перевірка кількості зв'язків
MATCH ()-[r:SIMILAR]-()
RETURN count(r) AS similarRelationships;


// Створення графа для Dijkstra
CALL gds.graph.project(
  'userGraph',
  'User',
  {
    SIMILAR: {
      orientation: 'UNDIRECTED',
      properties: 'weight'
    }
  }
);


// Перевірка користувачів для пошуку шляху
MATCH (u1:User)-[sim:SIMILAR]-(u2:User)
RETURN
u1.userId AS sourceUser,
u2.userId AS targetUser,
sim.weight AS weight
ORDER BY weight ASC
LIMIT 5;


// Пошук найкоротшого шляху
MATCH (source:User {userId: 17})
MATCH (target:User {userId: 18})

CALL gds.shortestPath.dijkstra.stream(
  'userGraph',
  {
    sourceNode: source,
    targetNode: target,
    relationshipWeightProperty: 'weight'
  }
)
YIELD totalCost, nodeIds

RETURN
[nodeId IN nodeIds | gds.util.asNode(nodeId).userId] AS userPath,
totalCost,
size(nodeIds) AS pathLength;


// Очищення після Dijkstra
CALL gds.graph.drop('userGraph');

MATCH ()-[sim:SIMILAR]-()
DELETE sim;