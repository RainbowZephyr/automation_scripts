# Team Formation Script
-----

## Requirements 

- Ruby

- CSV file for student IDs, ID must be the first column

- CSV file for team submissions

    

## Features

- Checks for students without a team
- Checks for duplicate submissions for student
- Randomly assigns students to teams

## How to use

> ruby -W0 team_checker.rb

**Note:**

You may need to change the minimum and maximum number of students per team, as well as the columns that map to student ids inside the file. A new file will be generated called ***new_teams.csv***. Make sure to pay attention to the console for students that **could not** be assigned to teams.

