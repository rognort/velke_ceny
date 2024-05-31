SELECT   jmeno_hrace as "Jméno hráče",
		 klub_hrace as "Klub",
					hodnoceni_alb as "Město Albrechtice",
					hodnoceni_rym as "Rýmařov",
					hodnoceni_bru as "Bruntál",
					hodnoceni_vrb as "Vrbno pod Pradědem",
					hodnoceni_krn as "Krnov", 
--vysledky
	COALESCE(hodnoceni_rym,0) + COALESCE(hodnoceni_bru,0) + 
	COALESCE(hodnoceni_alb,0) + COALESCE(hodnoceni_krn,0) + 
	COALESCE(hodnoceni_vrb,0) 
		-	
		LEAST(
    	COALESCE(hodnoceni_rym, 0),COALESCE(hodnoceni_bru, 0),
    	COALESCE(hodnoceni_alb, 0),COALESCE(hodnoceni_krn, 0),
    	COALESCE(hodnoceni_vrb, 0)
		) 	
					AS "Celkové hodnocení",
	
--vyselektování pořadí, velmi nepěkně podle vzorce výsledků	
	ROW_NUMBER() OVER (ORDER BY 	COALESCE(hodnoceni_rym,0) + COALESCE(hodnoceni_bru,0) + 
	COALESCE(hodnoceni_alb,0) + COALESCE(hodnoceni_krn,0) + 
	COALESCE(hodnoceni_vrb,0) 
		-	
		LEAST(
    	COALESCE(hodnoceni_rym, 0),COALESCE(hodnoceni_bru, 0),
    	COALESCE(hodnoceni_alb, 0),COALESCE(hodnoceni_krn, 0),
    	COALESCE(hodnoceni_vrb, 0)) DESC) 
					
					AS "Pořadí"

FROM
(
SELECT
    COALESCE( al.jmeno,  b.jmeno, r.jmeno, v.jmeno, kr.jmeno) AS jmeno_hrace,
	COALESCE( al.klub,  b.klub, r.klub, v.klub, kr.klub) AS klub_hrace,
	
    CASE 
	WHEN r.poradi = 1 THEN 20 + (0.0001 * 20 * (SELECT COUNT(*) FROM vc_rymarov_st))
	WHEN 20 - r.poradi <= 1 THEN 1 + (0.0001 * (20 - r.poradi) * (SELECT COUNT(*) FROM vc_rymarov_st))
	ELSE 20 - r.poradi + (0.0001 * (20 - r.poradi) * (SELECT COUNT(*) FROM vc_rymarov_st))
	END AS hodnoceni_rym,
    
	CASE 
	WHEN b.poradi = 1 THEN 20 + (0.0001 * 20 * (SELECT COUNT(*) FROM vc_bruntal_st))
	WHEN 20 - b.poradi <= 1 THEN 1 + (0.0001 * (20 - b.poradi) * (SELECT COUNT(*) FROM vc_bruntal_st))
	ELSE 20 - b.poradi + (0.0001 * (20 - b.poradi) * (SELECT COUNT(*) FROM vc_bruntal_st))
	END AS hodnoceni_bru,
	
	CASE 
	WHEN al.poradi = 1 	THEN 20 + (0.0001 * 20 * (SELECT COUNT(*) FROM vc_albrechtice_st))
	WHEN 20 - al.poradi <= 1 THEN 1 + (0.0001 * (20 - al.poradi) * (SELECT COUNT(*) FROM vc_albrechtice_st))
	ELSE 20 - al.poradi  + (0.0001 * (20 - al.poradi) * (SELECT COUNT(*) FROM vc_albrechtice_st))
	END AS hodnoceni_alb,
  	
	CASE 
	WHEN kr.poradi = 1 THEN 20 + (0.0001 * 20 * (SELECT COUNT(*) FROM vc_krnov_st)) 
	WHEN 20 - kr.poradi <= 1 THEN 1 + (0.0001 * (20 - kr.poradi) * (SELECT COUNT(*) FROM vc_krnov_st)) 
	ELSE 20 - kr.poradi + (0.0001 * (20 - kr.poradi) * (SELECT COUNT(*) FROM vc_krnov_st))
	END AS hodnoceni_krn,
    
	CASE 
	WHEN v.poradi = 1 THEN 20 + (0.0001 * 20 * (SELECT COUNT(*) FROM vc_vrbno_st))
	WHEN 20 - v.poradi <= 1 THEN 1 + (0.0001 * (20 - v.poradi) * (SELECT COUNT(*) FROM vc_vrbno_st)) 
	ELSE 20 - v.poradi + (0.0001 *  (20 - v.poradi) * (SELECT COUNT(*) FROM vc_vrbno_st))
	END AS hodnoceni_vrb
	
FROM
    vc_bruntal_st AS b
	
FULL JOIN
    vc_rymarov_st AS r
ON
    r.jmeno = b.jmeno

FULL JOIN
    vc_vrbno_st AS v
ON
    v.jmeno = COALESCE(b.jmeno, r.jmeno)
	
FULL JOIN
    vc_krnov_st AS kr
ON
    kr.jmeno = COALESCE(b.jmeno, r.jmeno, v.jmeno)

FULL JOIN
    vc_albrechtice_st AS al
ON
    al.jmeno = COALESCE(b.jmeno, r.jmeno, v.jmeno,kr.jmeno)

)

ORDER BY
    "Celkové hodnocení" desc;
