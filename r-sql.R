#load library
library("sqldf")

### Single Table manipulation ###

# Subset of all male employees #

male_employees <- sqldf("SELECT * FROM employees WHERE gender = 'm'")

# Count by first name #

name_counts <- sqldf("SELECT firstname, COUNT (firstname) as occurances FROM employees GROUP BY firstname")

# Exclude non-employees #
# i.e. do not work for company anymore #
# but still in dataset #

name_counts_emponly <- sqldf("SELECT firstname, COUNT(firstname) as occurances
                             FROM employees
                             WHERE firstname != 'rudi'
                             GROUP BY firstname")

# case statement for new data column of california employees,
# make sure names are lowercase for case insensitivity

employees_cali <- sqldf("SELECT *,
                        CASE
                         WHEN lower(firstname) = 'stewart' THEN 1
                         WHEN lower(firstname) = 'hila' THEN 1
                         WHEN lower(firstname) = 'jon' THEN 1
                         WHEN lower(firstname) = 'solon' THEN 1
                         ELSE 0
                        END as cali_emp
                        FROM employees
                        ")
# Sort employees_cali by cali_emp descending, first names ascending
#Easy to do in excel, One extra line here, last line.

employees_cali_sorted <- sqldf("SELECT *,
                        CASE
                         WHEN lower(firstname) = 'stewart' THEN 1
                         WHEN lower(firstname) = 'hila' THEN 1
                         WHEN lower(firstname) = 'jon' THEN 1
                         WHEN lower(firstname) = 'solon' THEN 1
                         ELSE 0
                        END as cali_emp
                        FROM employees
                        ORDER BY cali_emp DESC, firstname
                               ")

### Multi-Table Manipulation ###

# Combining employees to orders with left join
# left means "first" in queries

ljoin <- sqldf("SELECT *
               FROM employees a
               LEFT JOIN orders b ON a.id=b.id
               WHERE a.firstname != 'rudi'
               ")

#sqldf does not have a right join, 
#but changing orders of tables works well 

rjoin_equiv <- sqldf("SELECT *
                      FROM orders b
                     LEFT JOIN employees a ON a.id=b.id
                     ")

#inner join. Select records that match both tables

inner_join <- sqldf("SELECT *
                    FROM employees a, orders b
                    WHERE a.id=b.id
                    ")
### Good business examples ###

## The boss sees bill, wonders how bill can be so low ##

#Here we will combine orders to employees, 
#find who is ordering items less than 10 dollars,
#sorted by lowest cost

inexpensive_items <- sqldf("SELECT *
                           FROM orders a
                           LEFT JOIN employees b ON a.id=b.id
                           WHERE item_cost < 10
                           ORDER BY item_cost
                           ")

#Boss thinks this is inefficient, would be more helpful to 
#know who spent less than 20 dollars on any 
#one type of food

inexpensive_items_2 <- sqldf("SELECT *,
                            (item_cost * quantity_ordered) as item_level_cost
                             FROM orders a
                             LEFT JOIN employees b ON a.id=b.id
                             WHERE item_level_cost < 20
                             ORDER BY item_level_cost
                             ")
#Boss still wants more data, so figure out whose total lunch
#was less than 30 dollars
#similar to SUMPRODUCT in excel

lunch_under_30 <- sqldf("SELECT lastname, firstname,
                      SUM(item_cost * quantity_ordered) as lunch_cost
                      FROM orders a
                      LEFT JOIN employees b ON a.id=b.id
                      GROUP BY a.id
                      HAVING lunch_cost < 30
                      ")
#Boss wants to know who is eating 
#less than average per cost basis?

#The Subquery will show a single value for the average
#cost of lunch

lower_than_average <- sqldf("SELECT lastname, firstname,
                            SUM(item_cost * quantity_ordered) as lunch_cost
                            FROM orders a
                            LEFT JOIN employees b ON a.id=b.id
                            WHERE a.id != 'NA'
                            GROUP BY a.id
                            HAVING lunch_cost < (
                                                  SELECT SUM(item_cost * quantity_ordered)/COUNT(DISTINCT id) as avg_lunch_cost
                                                  FROM orders
                                                  WHERE id != 'NA'
                                                )
                                                     ")
