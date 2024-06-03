--Question 1a. + 1b.
-- #1881634483 w/ 99707 Claims.
--Bruce Pendley, Family Practice

SELECT npi, nppes_provider_first_name, nppes_provider_last_org_name, specialty_description, sum(total_claim_count) as total_claims
FROM prescription
INNER JOIN prescriber
	USING(npi)
GROUP BY npi, nppes_provider_first_name, nppes_provider_last_org_name, specialty_description
ORDER BY SUM(total_claim_count) DESC;

--Question 2a.
--Family Practice

SELECT DISTINCT specialty_description, sum(prescription.total_claim_count) as total_per_specialty
FROM prescriber
INNER JOIN prescription
	USING(npi)
Group BY DISTINCT specialty_description
ORDER BY sum(prescription.total_claim_count) desc;

--Question 2b.
--Nurse Practitioner

SELECT DISTINCT specialty_description, count(opioid_drug_flag) as total_opioid_claims
FROM prescriber
INNER JOIN prescription
	USING(npi)
INNER JOIN drug
	Using(drug_name)
GROUP BY prescriber.specialty_description
ORDER BY count(opioid_drug_flag) desc;

--Question 2c. **Challenge Question**
SELECT specialty_description
FROM prescriber
LEFT JOIN prescription
USING(npi)
GROUP BY specialty_description
ORDER BY count(drug_name)
LIMIT 15;

--Question 2d. **Difficult Bonus**

Select specialty_description,
	ROUND((SUM(CASE WHEN opioid_drug_flag = 'Y' THEN total_claim_count END)/SUM(total_claim_count)), 2) * 100 as percent_opioids
FROM prescriber
INNER JOIN prescription
USING(npi)
INNER JOIN drug
Using(drug_name)
Group BY specialty_description
ORDER BY percent_opioids DESC NULLS LAST;

--Question 3a.
--Insulin

SELECT generic_name, sum(total_drug_cost)::money AS total_cost
FROM prescription INNER JOIN drug using (drug_name)
GROUP BY generic_name
ORDER BY total_cost DESC
LIMIT 1;

--Question 3b.
--C1 ESTERASE INHIBITOR, $3,495.22

SELECT generic_name, ROUND(sum(total_drug_cost)/SUM(total_day_supply), 2)::money AS daily_cost
FROM prescription INNER JOIN drug using (drug_name)
GROUP BY generic_name
ORDER BY daily_cost DESC;

--Question 4a.
Select drug_name,
CASE
	WHEN opioid_drug_flag = 'Y' THEN 'opioid'
	WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
	ELSE 'neither'
END AS drug_type
FROM drug;

--Question 4b.
--Opioids, $105,080,626.37

Select SUM(total_drug_cost)::money as group_cost,
CASE
	WHEN opioid_drug_flag = 'Y' THEN 'opioid'
	WHEN antibiotic_drug_flag = 'Y' THEN 'antibiotic'
	ELSE 'neither'
END AS drug_type
FROM drug
INNER JOIN prescription
USING(drug_name)
GROUP BY drug_type
ORDER BY SUM(total_drug_cost) DESC;

--Question 5a.
--10

SELECT count(DISTINCT cbsa) as TN_cbsa
FROM cbsa INNER JOIN fips_county USING (fipscounty)
WHERE state = 'TN';

--Question 5b.
--Largest: Nashville-Davidson-Murfreesboro-Franklin, TN 1,830,410
--Smallest: Morristown, TN - 116,352

SELECT cbsaname, cbsa, SUM(population) as total_pop
FROM cbsa
RIGHT JOIN population
USING(fipscounty)
GROUP BY cbsaname, cbsa
ORDER BY total_pop DESC;

--Question 5c.
--Sevier, TN 95,523 (I think this answer may be Shelby,TN - it has a highter pop and doesn't have a cbsa)

SELECT county, state, fipscounty, sum(population) as population
FROM population
FULL JOIN fips_county
USING(fipscounty)
WHERE population IS NOT NULL
GROUP BY fipscounty, county, state
ORDER BY sum(population) desc;

SELECT cbsa, cbsaname
from cbsa
ORDER BY cbsaname

--Question 6a. + 6b. + 6c.
SELECT nppes_provider_first_name, nppes_provider_last_org_name, drug_name, total_claim_count, opioid_drug_flag
FROM prescription
INNER JOIN drug
USING(drug_name)
INNER JOIN prescriber
USING(npi)
WHERE total_claim_count > 3000
ORDER BY total_claim_count DESC;

--Question 7a.
SELECT npi, nppes_provider_first_name, nppes_provider_last_org_name, drug_name, sum(total_claim_count) as claim_count_per_drug
FROM prescriber
FULL JOIN prescription
USING(npi)
FULL JOIN drug
USING(drug_name)
WHERE specialty_description = 'Pain Management'
	AND nppes_provider_city = 'NASHVILLE'
	AND opioid_drug_flag = 'Y'
GROUP BY npi, nppes_provider_first_name, nppes_provider_last_org_name, drug_name, total_claim_count
ORDER BY total_claim_count DESC;