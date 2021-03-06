SELECT
    i.ida AS patient_id,
    p.last_name,
    p.first_name,
    cpt.short_desc,
    LTRIM(RTRIM(c.inst_abrv)) AS inst,
    CASE t.diag_type
        WHEN 1 THEN 'ICD-9'
        WHEN 2 THEN 'ICD-10'
        WHEN 3 THEN 'Other'
        WHEN 4 THEN 'ICD-O-3'
    END AS diag_type,
    t.diag_code,
    LTRIM(RTRIM(t.description)) AS description,
    m.category,
    LTRIM(RTRIM(f2.last_name)) AS system,
    s.app_dttm AS date
FROM schedule s
LEFT JOIN staff f2 ON s.location = f2.staff_id
LEFT JOIN admin a ON s.pat_id1 = a.pat_id1
LEFT JOIN cpt ON s.activity = cpt.hsp_code
LEFT JOIN patient p ON s.pat_id1 = p.pat_id1
LEFT JOIN staff f1 ON s.staff_id = f1.staff_id
LEFT JOIN config c ON s.inst_id = c.inst_id
LEFT JOIN notes n ON s.note_id = n.note_id
LEFT JOIN multistf mul ON s.sch_id = mul.sch_id
LEFT JOIN ident i ON p.pat_id1 = i.pat_id1
LEFT JOIN schedule tip ON tip.sch_set_id = s.sch_set_id
LEFT JOIN staff f ON s.edit_id = f.staff_id
LEFT JOIN schedule_schedulestatus_mtm mtm ON s.sch_id = mtm.sch_id
LEFT JOIN schedulestatus ss ON mtm.schedulestatusid = ss.schedulestatusid
LEFT JOIN schedule_schedulestatus_mtm fil ON tip.sch_id = fil.sch_id
LEFT JOIN medical m ON tip.pat_id1 = m.pat_id1
LEFT JOIN topog t ON m.tpg_id = t.tpg_id
WHERE tip.version = 0
  AND ( ( i.ident_id IS NULL OR i.ident_id = 0 ) OR i.version = 0 )
  AND ( ( m.med_id IS NULL OR m.med_id = 0 ) OR m.seq = 1 )
  AND f2.last_name NOT LIKE '%ARZT%'
  AND f2.last_name NOT LIKE '%THERAPIE'
  AND i.ida NOT IN ('01', '123128v', '10000000000', '2000000000')
--  AND f2.last_name LIKE ?
  AND s.app_dttm > ?
  AND s.app_dttm < ?
--  AND t.diag_code LIKE ?
GROUP BY i.ida, p.last_name,p.first_name, cpt.short_desc,c.inst_abrv,t.diag_type,t.description, t.diag_code, m.category,f2.last_name,s.app_dttm
ORDER BY s.app_dttm;
