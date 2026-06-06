import csv
import os

os.makedirs("import", exist_ok=True)

# movies.dat: MovieID::Title::Genres
with open("movies.dat", encoding="latin-1") as source, \
     open("import/movies.csv", "w", newline="", encoding="utf-8") as target:
    writer = csv.writer(target)
    writer.writerow(["movieId", "title", "genres"])

    for line in source:
        parts = line.strip().split("::")
        if len(parts) == 3:
            writer.writerow(parts)

# ratings.dat: UserID::MovieID::Rating::Timestamp
with open("ratings.dat", encoding="latin-1") as source, \
     open("import/ratings.csv", "w", newline="", encoding="utf-8") as target:
    writer = csv.writer(target)
    writer.writerow(["userId", "movieId", "rating", "timestamp"])

    for line in source:
        parts = line.strip().split("::")
        if len(parts) == 4:
            writer.writerow(parts)

# users.dat: UserID::Gender::Age::Occupation::Zip-code
with open("users.dat", encoding="latin-1") as source, \
     open("import/users.csv", "w", newline="", encoding="utf-8") as target:
    writer = csv.writer(target)
    writer.writerow(["userId", "gender", "age", "occupation"])

    for line in source:
        parts = line.strip().split("::")
        if len(parts) >= 4:
            writer.writerow(parts[:4])

print("CSV files created:")
print("import/movies.csv")
print("import/ratings.csv")
print("import/users.csv")