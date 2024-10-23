CREATE DEFINER=`sucursal`@`%` PROCEDURE `venta_sp_ObtieneConsecutivo`(IN ps_typeMov CHAR(50), p_username VARCHAR(150))
BEGIN
    
	DECLARE ci_0 INT DEFAULT 0;
    DECLARE ci_1 INT DEFAULT 1;
    DECLARE ci_2 INT DEFAULT 2;     
    DECLARE cs_nueva_venta CHAR(50) DEFAULT 'ULT_MOV_DIA';
    DECLARE cs_cobranza CHAR(50) DEFAULT 'COBRANZA';
    DECLARE cs_fin_dia CHAR(50) DEFAULT 'FIN_DIA';
	DECLARE cs_empty CHAR(1) DEFAULT '';
    
	
	CALL util_sp_ObtieneBaseUser (p_username, cs_empty);
	
    
	
	
	CALL util_sp_ConsultaTabla('CASE WHEN COUNT(fch_consecutivo) = 0 THEN \'\' ELSE DATE_FORMAT(fch_consecutivo,\'%Y%m%d\') END', concat(@vg_pdv,'.venta_cat_consecutivo'), NULL, NULL, NULL, 'txt_consecutivo', cs_fin_dia, 'id_sucursal', @vg_sucursal, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'fch_consecutivo', @vd_fecha);		        		

	
	CALL util_sp_ConsultaTabla('CASE WHEN COUNT(fch_consecutivo) = 0 THEN \'\' ELSE DATE_FORMAT(fch_consecutivo,\'%Y%m%d\') END', concat(@vg_pdv, '.venta_cat_consecutivo'), NULL, NULL, NULL, 'txt_consecutivo', ps_typeMov, 'id_sucursal', @vg_sucursal, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'fch_consecutivo', @vd_fechaC);		        			

	
	CALL util_sp_ConsultaTabla('CASE WHEN COUNT(num_consecutivo) = 0 THEN 0 ELSE num_consecutivo END', concat(@vg_pdv, '.venta_cat_consecutivo'), NULL, NULL, NULL, 'txt_consecutivo', ps_typeMov, 'id_sucursal', @vg_sucursal, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'num_consecutivo', @vi_consec);        

	
	CALL util_sp_ConsultaTabla('CASE WHEN COUNT(id_consecutivo) = 0 THEN 0 ELSE id_consecutivo END', concat(@vg_pdv, '.venta_cat_consecutivo'), NULL, NULL, NULL, 'txt_consecutivo', ps_typeMov, 'id_sucursal', @vg_sucursal, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'id_consecutivo', @vi_idConsec);        

    IF ps_typeMov = cs_nueva_venta AND @vi_idConsec != ci_0 THEN	    
		
		IF @vd_fecha = @vd_fechaC THEN
			SET @vc_consec = @vi_consec + ci_1;        
		ELSE
			SET @vc_consec = ci_1;                
		END IF;		
    ELSE
		
		SET @vc_consec = @vi_consec + ci_1;        					
    END IF;    

	
    set @vg_pdvA = @vg_pdv;
    set @vg_pdvA = (select replace(@vg_pdvA, 'pdv', ''));
    If @vg_pdvA = '' THEN
       set @vg_pdvA = 'pinta';
	END IF;

	IF @vi_idConsec = ci_0 THEN
		call pospinta.execSql(@vg_pdvA, concat(
		'INSERT INTO @dbpdv.venta_cat_consecutivo (id_sucursal, txt_consecutivo, fch_consecutivo, num_consecutivo) 
		VALUES (' , @vg_sucursal, ',' , ps_typeMov, ',' , @vd_fecha , ',' , @vc_consec ,')'));
	ELSE
		call pospinta.execSql(@vg_pdvA, concat(    
		'UPDATE @dbpdv.venta_cat_consecutivo SET num_consecutivo = ', @vc_consec, ',', 'fch_consecutivo = ', @vd_fecha, 
		' WHERE id_consecutivo = ', @vi_idConsec, ' AND id_sucursal = ', @vg_sucursal));
	END IF;		

    
    SELECT @vc_consec;
    
END