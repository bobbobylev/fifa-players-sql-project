
--КОМАНДА СОЗДАНИЯ БАЗЫ ДАННЫХ
CREATE DATABASE footbal_db;
  --КОМАНДА СОЗДАНИЯ ТАБЛИЦЫ
CREATE TABLE
key_data (
    ID SERIAL PRIMARY KEY,
    Name VARCHAR (355),
    Age DECIMAL (2),
    Nationality VARCHAR (355),
    Club VARCHAR (355),
    Preferred_Foot VARCHAR (355) ,
    Position VARCHAR (355),
    Jersey_Number DECIMAL (2),
    Height_ft DECIMAL(3),
    Weight_lbs DECIMAL (4)
);
--КОМАНДА ЗАЛИВКИ ДАННЫХ В ТАБЛИЦу
COPY key_data FROM '/usr/local/share/netology/final/key_data.csv' DELIMITER ',';

CREATE TABLE
players_stats (
    ID SERIAL PRIMARY KEY,
    Overall_rating DECIMAL (2),
    Potential_raiting DECIMAL (2),
    Weak_Foot DECIMAL (2),
    Skill_Moves DECIMAL (2),
    Passing DECIMAL (2),
    Dribbling DECIMAL (2),
    Speed DECIMAL (2),
    Stamina DECIMAL (2),
    Shots DECIMAL (2),
    Interceptions DECIMAL (2),
    Positioning DECIMAL (2),
    Tackle DECIMAL (2)

);

COPY players_stats FROM '/usr/local/share/netology/final/players_stats.csv' DELIMITER ';';


CREATE TABLE
players_costs (
    ID SERIAL PRIMARY KEY,
    Contract_Valid_Until DECIMAL (4),
    Value DECIMAL (20),
    Wage DECIMAL (20),
    Release_Clause DECIMAL (20)

);

COPY players_costs FROM '/usr/local/share/netology/final/players_costs.csv' DELIMITER ';';

CREATE TABLE
clubs (
    Club VARCHAR (355),
    league VARCHAR (355)

);

COPY clubs FROM '/usr/local/share/netology/final/clubs.csv' DELIMITER ',';

-- показать 10 самых высоких игроков
  SELECT name, Height_ft
  FROM key_data
  ORDER by height_ft DESC
  LIMIT 10
  ;

--Средний возраст игроков из Бразилии
  SELECT AVG(age)
  FROM key_data
  WHERE Nationality = 'Brazil'
  ;

-- 10 сымых высокооплачеваемых цетральных защитников
  SELECT key_data.name, players_costs.wage
  FROM public.key_data
  LEFT JOIN public.players_costs
  ON key_data.ID = players_costs.ID
  WHERE key_data.Position='CB'
  ORDER By wage DESC
  Limit 10;


-- Топ 10 клубов. по тратам на зарплату игроков
  SELECT sum(wage) as club_total_wage, Club
  FROM public.key_data
  JOIN public.players_costs
  ON key_data.ID = players_costs.ID
  GROUP BY club
  Order by club_total_wage DESC
  limit 10
;

-- Сравнение показателя "паса" игрока по сравнению со средним показателем в его клубе, сортировка по игрокам с наилучим пасом
  SELECT name, club, passing, avg(passing) OVER (PARTITION BY club)
  FROM public.key_data
  JOIN public.players_stats
  ON key_data.ID = players_stats.ID
  ORDER BY PASSING DESC
  ;


-- Количество игроков возрастом более 40 лет
  SELECT COUNT(*)
  FROM key_data
  WHERE age > 40
  ;

-- Наибольший рейтинг игрока, играющего в каждом клубе
      SELECT DISTINCT club,
        MAX(Overall_rating) OVER (PARTITION BY key_data.club) AS Maxrating
      FROM public.key_data
      JOIN public.players_stats
      ON key_data.ID = players_stats.ID
      ORDER by Maxrating DESC
  ;

-- Топ три по количеству клубов находящихся в каждой из стран
  SELECT DISTINCT league,
    COUNT(Clubs.club) OVER (PARTITION BY clubs.league) AS clubscount
  FROM public.key_data
  JOIN public.clubs
  ON key_data.club = clubs.club
  ORDER by clubscount DESC
  LIMIT 3
;

-- Топ 5 игроков, у которых потенциальый рейтинг выше среднего и не равен рейтингу на данный момент (то есть ожидается дальнейшее развитие)
SELECT DISTINCT
    name, Potential_raiting
FROM public.key_data
JOIN public.players_stats
ON key_data.ID = players_stats.ID
WHERE
    Potential_raiting > (
            SELECT AVG(Potential_raiting)
            FROM public.players_stats
    )
    AND
    Potential_raiting <> Overall_rating
ORDER BY Potential_raiting DESC
LIMIT 5;


-- Клубы, в которых минмальная заработная плата игрока более 10000 евро
SELECT club, MIN(wage)
FROM public.key_data
JOIN public.players_costs
ON key_data.ID = players_costs.ID
GROUP BY club
HAVING MIN(wage) > 10000; 
