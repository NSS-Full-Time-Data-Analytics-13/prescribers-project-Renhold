--Question 1a. + 1b.
-- #19120111792 w/ 4538 Claims.
--David Coffey, Family Practice, 4538

SELECT npi, nppes_provider_first_name, nppes_provider_last_org_name, specialty_description, total_claim_count
FROM prescription
INNER JOIN prescriber
	USING(npi)
ORDER BY total_claim_count desc;

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
SELECT specialty_description, count(drug_name)
FROM prescriber
LEFT JOIN prescription
USING(npi)
GROUP BY specialty_description
ORDER BY count(drug_name)
LIMIT 15;

--Question 2d. **Difficult Bonus**
--(Couldn't figure out how to divide the opioid count by total claims for percentage)

Select specialty_description, sum(total_claim_count) as opioid_count
FROM prescription
FULL JOIN drug
USING(drug_name)
FULL JOIN prescriber
Using(npi)
Where total_claim_count is not null AND opioid_drug_flag = 'Y'
Group BY specialty_description
ORDER BY sum(total_claim_count) DESC;

--Question 3a.
--Esbriet

SELECT drug_name, round(total_drug_cost, 2)::Money as total_cost
FROM prescription
ORDER BY total_drug_cost DESC;

--Question 3b.
--Esbriet, $7,751.16

SELECT drug_name, Round((total_drug_cost/365), 2)::money as cost_per_day
FROM prescription
ORDER BY total_drug_cost DESC;

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
--58

SELECT count(cbsaname) as TN_cbsa
FROM cbsa
WHERE cbsaname ILIKE '%TN%';

--Question 5b.
--Morristown, TN - 116,352

SELECT cbsaname, cbsa, SUM(population) as pop
FROM cbsa
RIGHT JOIN population
USING(fipscounty)
GROUP BY cbsaname, cbsa
ORDER BY pop DESC;

--Question 5c.
--Shelby, TN 937,847

SELECT county, state, fipscounty, sum(population) as population
FROM population
FULL JOIN fips_county
USING(fipscounty)
WHERE population IS NOT NULL
GROUP BY fipscounty, county, state
ORDER BY sum(population) desc;

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