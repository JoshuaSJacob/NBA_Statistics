-- NBA Player Statistics Analysis --

-- See all Table Elements of player_totals -- 

SELECT * 
FROM player_totals;
*/


-- See all Table Elements of player_totals -- 

SELECT * 
FROM player_award_shares;



-- Find All The Players That Have Played Every Game in a Season --

SELECT season, name, minutes_played
FROM player_totals
WHERE games_played = 82
ORDER BY minutes_played DESC;



-- Find The Top 25 Players Leading in Points --

SELECT player_id, name, SUM(points) as "Total Points"
FROM player_totals
GROUP BY player_id, name
ORDER BY "Total Points" DESC
LIMIT 25;



-- Find Which Position Commmits the Most Personal Fouls --

SELECT position, SUM(personal_fouls) AS fouls 
FROM player_totals
GROUP BY position
ORDER BY fouls DESC;



-- Find Which Position Commmits the Most Turnovers --

SELECT position, SUM(turnovers) AS t 
FROM player_totals
WHERE turnovers IS NOT NULL
GROUP BY position
ORDER BY t DESC;



-- Find the That Averages the Highest Field Goal Percentage in the Last Decade -- 

SELECT team, ROUND((SUM(field_goals) * 1.0 / NULLIF(SUM(field_goals_attempted), 0) * 100), 2) AS field_goal_percentage
FROM player_totals
WHERE season > 2014 AND
team != 'TOT'
GROUP BY team
ORDER BY field_goal_percentage DESC;


-- Find the 50 Youngest Players to Win an Award that is not ROTY --

SELECT season, award, name, age, team
FROM player_award_shares
WHERE winner = true 
AND award != 'nba roy'
ORDER BY age
LIMIT 50;


-- Find all the Players that are Currently in the NBA that have Won Awards -- 

SELECT PAS.season, PAS.name, PAS.age, PAS.award
FROM player_award_shares AS PAS
JOIN player_totals AS PT on pas.player_id = pt.player_id
WHERE pas.winner = TRUE
AND pt.season = 2025
ORDER BY AGE DESC;


-- Compare the Points, Assists, Rebounds, Steals, Blocks, PPG and Field Goal Percentage of LeBron and Jordan (Totals) -- 

SELECT player_totals.name,
SUM(player_totals.games_played) AS games_played,
SUM(player_totals.minutes_played) AS "Minutes Played",
SUM(player_totals.points) AS "Total Points", 
SUM(player_totals.assists) AS "Total Assists", 
SUM(player_totals.rebounds) AS "Total Rebounds", 
SUM(player_totals.steals) AS "Total Steals", 
SUM(player_totals.blocks) AS "Total Blocks",
ROUND(SUM(player_totals.points) * 1.0 / NULLIF(SUM(player_totals.games_played), 0), 2) AS "Points Per Game",
ROUND(SUM(player_totals.field_goals) * 1.0 / NULLIF(SUM(player_totals.field_goals_attempted), 0) * 100, 2) AS "Field Goal Percentage"
FROM player_totals
WHERE player_totals.name IN ('Michael Jordan', 'LeBron James')
GROUP BY player_totals.name;



-- Shows Player Totals and Awards Won During Every Season of Lebron and Jordan's Career -- 

SELECT totals.name, totals.season, totals."Games Played", totals."Minutes Played", totals."Total Points", totals."Total Assists", 
totals."Total Rebounds", totals."Total Steals", totals."Total Blocks", totals."Points Per Game", totals."Field Goal Percentage",
COALESCE(STRING_AGG(DISTINCT pas.award, ', '), 'No Award') AS "Awards Won"
FROM (
SELECT player_totals.name, player_totals.season, 
SUM(player_totals.games_played) AS "Games Played",
SUM(player_totals.minutes_played) AS "Minutes Played",
SUM(player_totals.points) AS "Total Points",
SUM(player_totals.assists) AS "Total Assists",
SUM(player_totals.rebounds) AS "Total Rebounds",
SUM(player_totals.steals) AS "Total Steals",
SUM(player_totals.blocks) AS "Total Blocks",
ROUND(SUM(player_totals.points) * 1.0 / NULLIF(SUM(player_totals.games_played), 0), 2) AS "Points Per Game",
ROUND(SUM(player_totals.field_goals) * 1.0 / NULLIF(SUM(player_totals.field_goals_attempted), 0) * 100, 2) AS "Field Goal Percentage"
FROM player_totals
WHERE player_totals.name IN ('Michael Jordan', 'LeBron James')
GROUP BY player_totals.name, player_totals.season
) AS totals
LEFT JOIN player_award_shares pas 
ON totals.name = pas.name AND totals.season = pas.season
GROUP BY totals.name, totals.season, totals."Games Played", totals."Minutes Played", totals."Total Points", totals."Total Assists", 
totals."Total Rebounds", totals."Total Steals", totals."Total Blocks", totals."Points Per Game", totals."Field Goal Percentage"
ORDER BY totals.season DESC;


-- Show the Evolution of 3 Pointers Since They Were Added to the NBA --

SELECT (season / 10 * 10) || 's' As Decade, 
SUM (three_pointers) as "Three Pointers", 
SUM (three_pointers_attempted) as "Attempted Threes",
ROUND(SUM(three_pointers) * 1.0 / NULLIF(SUM(three_pointers_attempted), 0) * 100, 2) AS "Three Point Percentage"
FROM player_totals
WHERE season > 1979
GROUP BY Decade
ORDER BY Decade DESC;


-- Find the 50 Most Efficient Passers (Minimum 1000 Assists)(Turnover Statistics Were Not Recorded Until 1978) --

SELECT name, 
SUM (assists) as Assists, 
SUM (turnovers) as "Turnovers", 
ROUND(SUM(assists) * 1.0 / NULLIF(SUM(turnovers), 0), 2) AS assist_to_turnover
FROM player_totals
WHERE season > 1977
GROUP BY name
HAVING SUM(assists) > 1000
ORDER BY assist_to_turnover DESC
LIMIT 50;


-- Find the Rookie of the Year that had the Most Impact  (NULL VALUE MEANS NOT RECORDED) --

SELECT pt.season, pt.team, pt.name, pt.age,
pt.rebounds, pt.assists, pt.steals,
pt.blocks, pt.turnovers, pt.points
FROM player_totals pt
LEFT JOIN player_award_shares pas
on pt.name = pas.name
AND pt.season = pas.season
WHERE award = 'nba roy'
AND winner = true
ORDER BY pt.points DESC;


-- Find all the Players that led in all Categories (Points, Assists, Rebounds, Steals, Blocks) for Their Team -- 

SELECT pt.season, pt.team, pt.name, pt.points, pt.assists, pt.rebounds, pt.steals, pt.blocks
FROM player_totals pt
JOIN (SELECT season, team,
MAX(points) AS max_points,
MAX(assists) AS max_assists,
MAX(rebounds) AS max_rebounds,
MAX(steals) AS max_steals,
MAX(blocks) AS max_blocks
FROM player_totals
GROUP BY season, team
) AS maxes
ON pt.season = maxes.season 
AND pt.team = maxes.team
AND pt.points = maxes.max_points
AND pt.assists = maxes.max_assists
AND pt.rebounds = maxes.max_rebounds
AND pt.steals = maxes.max_steals
AND pt.blocks = maxes.max_blocks
ORDER BY pt.season DESC;


-- Find all the Players that Performed Better After Being Traded (Points, Rebounds, Assists) --

SELECT season, name, 
COUNT(DISTINCT team) AS team_count,
ROUND(SUM(player_totals.points) * 1.0 / NULLIF(SUM(player_totals.games_played), 0), 2) AS "Points Per Game",
ROUND(SUM(player_totals.assists) * 1.0 / NULLIF(SUM(player_totals.games_played), 0), 2) AS "Assists Per Game",
ROUND(SUM(player_totals.rebounds) * 1.0 / NULLIF(SUM(player_totals.games_played), 0), 2) AS "Rebounds Per Game"
FROM player_totals
GROUP by name, season
HAVING COUNT(DISTINCT team) > 1
ORDER BY name DESC;


-- Find All the Players That Have Been Traded More than Twice in a Season --

SELECT name, season, COUNT(DISTINCT team) AS "Team Count"
FROM player_totals
GROUP BY name, season
HAVING COUNT(DISTINCT team) > 2
ORDER BY COUNT(DISTINCT team) DESC;


-- Find Players that took a Bigger Role After Being Traded -- 

SELECT old_team.name, old_team.season, 
old_team.team AS "Old Team", 
new_team.team AS "New Team",
ROUND(new_team.points * 1.0 / NULLIF(new_team.games_played, 0), 2) AS "PPG After Trade",
ROUND(old_team.points * 1.0 / NULLIF(old_team.games_played, 0), 2) AS "PPG Before Trade",
ROUND(new_team.rebounds * 1.0 / NULLIF(new_team.games_played, 0), 2) AS "RPG After Trade",
ROUND(old_team.rebounds * 1.0 / NULLIF(old_team.games_played, 0), 2) AS "RPG Before Trade",
ROUND(new_team.assists * 1.0 / NULLIF(new_team.games_played, 0), 2) AS "APG After Trade",
ROUND(old_team.assists * 1.0 / NULLIF(old_team.games_played, 0), 2) AS "APG Before Trade"
FROM player_totals old_team
JOIN player_totals new_team ON old_team.name = new_team.name 
AND old_team.season = new_team.season 
AND old_team.games_played < new_team.games_played 
WHERE (ROUND(new_team.points * 1.0 / NULLIF(new_team.games_played, 0), 2) > ROUND(old_team.points * 1.0 / NULLIF(old_team.games_played, 0), 2) 
AND ROUND(new_team.rebounds * 1.0 / NULLIF(new_team.games_played, 0), 2) > ROUND(old_team.rebounds * 1.0 / NULLIF(old_team.games_played, 0), 2) 
AND ROUND(new_team.assists * 1.0 / NULLIF(new_team.games_played, 0), 2) > ROUND(old_team.assists * 1.0 / NULLIF(old_team.games_played, 0), 2))
ORDER BY season DESC, name;

