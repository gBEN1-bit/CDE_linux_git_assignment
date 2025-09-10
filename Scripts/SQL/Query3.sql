-- Company names starting with 'C' or 'W', primary_poc contains 'ana'OR'Ana' but not 'eana'
-- NOTE: ILIKE is case-insensitive while LIKE is case-sensitive

--USING ILIKE
SELECT name
FROM accounts
WHERE (name LIKE 'C%' OR name LIKE 'W%')
  AND (primary_poc ILIKE '%ana%')
  AND (primary_poc NOT ILIKE '%eana%');


  ---OR USING LIKE

  SELECT name
FROM accounts
WHERE (name LIKE 'C%' OR name LIKE 'W%')
  AND (primary_poc LIKE '%ana%' OR primary_poc LIKE '%Ana%')
  AND (primary_poc NOT LIKE '%eana%');
