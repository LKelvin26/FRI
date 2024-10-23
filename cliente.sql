CREATE DEFINER=`sucursal`@`%` PROCEDURE `cliente_sp_InsertaCliente`( IN p_username VARCHAR(150), IN p_idCliente INT, IN p_tipo_cliente INT, IN p_tipoVenta INT, IN p_clubComex CHAR(15), 
											 IN p_tarjVirtual TINYINT(1), IN p_nombre VARCHAR(100), IN p_primer_nombre VARCHAR(100), 
											 IN p_segundo_nombre VARCHAR(100), IN p_primer_apellido VARCHAR(100), IN p_segundo_apellido VARCHAR(100), 
											 IN p_alias CHAR(50), IN p_rfc CHAR(15), IN p_cedula VARCHAR(15), IN p_calle VARCHAR(100), 
                                             IN p_numExt CHAR(15), IN p_numInt CHAR(15), IN p_colonia VARCHAR(100), IN p_delegacion VARCHAR(100), 
                                             IN p_municipio VARCHAR(100), IN p_estado INT, IN p_cp CHAR(5), IN p_telefono CHAR(20), 
                                             IN p_contacto CHAR(30), IN p_rfcd TINYINT(1), IN p_email CHAR(50), IN p_giro CHAR(4), 
                                             IN p_subGiro CHAR(4), IN p_numPinta INT, IN p_claveBus CHAR(10), IN p_metodoPago CHAR(2), 
                                             IN p_cuentaPago CHAR(4), IN p_numCliePref CHAR(16), IN p_idConvenio INT, IN p_tipoAdenda CHAR(3), 
                                             IN p_infoAdenda TEXT, IN p_sucAlta INT, IN p_fecAlta CHAR(8), IN p_idTmpAlta INT, 
                                             IN p_observacion TEXT, IN p_categoria INT, IN p_impriFactura INT,
                                             IN p_NIT VARCHAR(17), IN p_NRC VARCHAR(10), IN p_ActivComer TEXT, In p_catContrib TINYINT(3))
BEGIN    
		
		DECLARE ci_0 INT DEFAULT 0;
        DECLARE ci_1 INT DEFAULT 1;
		DECLARE ci_2 INT DEFAULT 2;       
        DECLARE ci_1000000 INT DEFAULT 1000000;
        DECLARE cs_cliente CHAR(50) DEFAULT 'ULTIMO_CLIENTE';
        DECLARE cs_empty CHAR(1) DEFAULT '';        
        DECLARE _nombre CHAR(100) DEFAULT '';
        DECLARE id_cliente INT DEFAULT 0;
        DECLARE StatProc INT DEFAULT 0;
    
        
		DECLARE EXIT HANDLER FOR SQLEXCEPTION 
        BEGIN
			SELECT StatProc;
            ROLLBACK;
            RESIGNAL;
        END;
        
        
        START TRANSACTION;
        
		
		CALL util_sp_ObtieneBaseUser (p_username, cs_empty);
		
        

     
        
        IF p_tipo_cliente = ci_1 THEN
			SET _nombre = CONCAT( p_primer_nombre, ' ', p_segundo_nombre, ' ', p_primer_apellido, ' ', p_segundo_apellido);
		ELSE
			SET _nombre = p_nombre;
		END IF;

        
        IF p_idCliente <> ci_0 THEN        
			
			SET @vs_update = CONCAT('UPDATE ', @vg_shared, '.hclilocal SET Tipoventa = ', p_tipoVenta, ', TipoCliente = ', p_tipo_cliente, ', NumTarjCComex = \'', p_clubComex, '\', EsTarjetaV = ', p_tarjVirtual, ', 
										Nombre = \'', _nombre, '\', PrimerNombre = \'', p_primer_nombre, '\', SegundoNombre = \'', p_segundo_nombre, '\', PrimerApellido = \'', p_primer_apellido, '\', SegundoApellido = \'', p_segundo_apellido, '\',
										Alias = \'', p_alias, '\', Rfc = \'', p_rfc, '\', NumCedula = \'', p_cedula, '\', Callenum = \'', p_calle, '\', 
										NumExt = \'', p_numExt, '\', NumInt = \'', p_numInt, '\', Colonia = \'', p_colonia, '\', Delemuni = \'', p_delegacion, '\', 
										Municipio = \'', p_municipio, '\', Estado = ', p_estado, ', Cp = \'', p_cp, '\', Tel = \'', p_telefono, '\', Contacto = \'', p_contacto, '\', 
										Rfcd = ', p_rfcd, ', Email = \'', p_email, '\', Giro = \'', p_giro, '\', Subgiro = \'', p_subGiro, '\', Numpinta = ', p_numPinta, ',
										Clavebus = \'', p_claveBus, '\', MetodoPago = \'', p_metodoPago, '\', CuentaPago = \'', p_cuentaPago, '\', NumCliPref = \'', p_numCliePref, '\',
										IdConvenio = ', p_idConvenio, ', TipoAdenda = \'', p_tipoAdenda, '\', InfoAdenda = \'', p_infoAdenda, '\', SucAlta = ', p_sucAlta, ',
										FecAlta = \'', p_fecAlta, '\', IdTmpAlta = ', p_idTmpAlta, ', FecUltModif = \'', NOW(), '\', NIT = \'', p_NIT, ', NRC = \'', p_NRC, '\', 
                                        ActivComer = \'', p_ActivComer, '\', CatContrib = ', p_CatContrib, ' 
									WHERE Idcliente = ', p_idCliente,';');		
                                    
			
            
			PREPARE stmt FROM @vs_update;    
			
			EXECUTE stmt;    
			
			DEALLOCATE PREPARE stmt;
            
            SET StatProc = p_idCliente;  
        ELSE
			
			call venta_sp_ObtieneConsecutivo(cs_cliente, p_username);
			SET id_cliente = @vc_consec;
            
			IF id_cliente < 1000000 THEN
			  set id_cliente = (p_sucAlta * 1000000) + id_cliente;
			END IF;
            
            SET @vs_update = (select CONCAT('set @vc_consec = (select coalesce(IdCliente, 0) from ', @vg_shared, '.hclilocal where IdCliente = ' , id_cliente, ')'));
			PREPARE stmt FROM @vs_update;    
			EXECUTE stmt;    
			DEALLOCATE PREPARE stmt;
            
            IF @vc_consec > 0 THEN
              SET StatProc = 0;
            END IF;
			
			
			IF p_rfc IS NOT NULL OR p_rfc <> cs_empty THEN
				SET @vs_insert = CONCAT('INSERT IGNORE INTO ', @vg_shared, '.hclifiscal (Rfc, NumCedula, Nombre, Callenum, NumExt, NumInt, Colonia, Delemuni, Municipio, Estado, Cp, Tel, SucAlta, FecAlta, FecUltModif) '
										'VALUES (IF(\'', p_rfc, '\'<>\'\', TRIM(\'', p_rfc, '\'), DEFAULT(Rfc)), 
												 IF(\'', p_cedula, '\'<>\'\', TRIM(\'', p_cedula, '\'), DEFAULT(NumCedula)), 
												 IF(\'', _nombre, '\'<>\'\', TRIM(\'', _nombre, '\'), DEFAULT(Nombre)),
												 IF(\'', p_calle, '\'<>\'\', TRIM(\'', p_calle, '\'), DEFAULT(Callenum)), 
												 IF(\'', p_numExt, '\'<>\'\', TRIM(\'', p_numExt, '\'), DEFAULT(NumExt)),                    
												 IF(\'', p_numInt, '\'<>\'\', TRIM(\'', p_numInt, '\'), DEFAULT(NumInt)), 
												 IF(\'', p_colonia, '\'<>\'\', TRIM(\'', p_colonia, '\'), DEFAULT(Colonia)), 
												 IF(\'', p_delegacion, '\'<>\'\', TRIM(\'', p_delegacion, '\'), DEFAULT(Delemuni)), 
												 IF(\'', p_municipio, '\'<>\'\', TRIM(\'', p_municipio, '\'), DEFAULT(Municipio)), 
												 IF(', p_estado, '<> 0, ', p_estado, ', DEFAULT(Estado)), 
												 IF(\'', p_cp, '\'<>\'\', TRIM(\'', p_cp, '\'), DEFAULT(Cp)), 
												 IF(\'', p_telefono, '\'<>\'\', TRIM(\'', p_telefono, '\'), DEFAULT(Tel)), 
												 IF(', p_sucAlta, '<>0, ', p_sucAlta, ', DEFAULT(SucAlta)), 
												 IF(\'', p_fecAlta, '\'<>\'\', TRIM(\'', p_fecAlta, '\'), DEFAULT(FecAlta)), \'',
												 NOW(), '\');'); 	
				
                
                
				PREPARE stmt FROM @vs_insert;    
				
				EXECUTE stmt;    
				
				DEALLOCATE PREPARE stmt;
				
			END IF;
			
			
			SET @vs_query = CONCAT('INSERT INTO	', @vg_shared, '.hclilocal (Idcliente, TipoCliente, Tipoventa, NumTarjCComex, EsTarjetaV, Nombre, PrimerNombre, SegundoNombre, PrimerApellido, SegundoApellido, Alias, Rfc, NumCedula, Callenum, NumExt, NumInt, Colonia, Delemuni, Municipio, Estado, Cp, Tel, Contacto, Rfcd, Email, Giro, Subgiro, Numpinta, Clavebus, MetodoPago, CuentaPago, NumCliPref, IdConvenio, TipoAdenda, InfoAdenda, SucAlta, FecAlta, IdTmpAlta, FecUltModif, NIT, NRC, ActivComer, catContrib) '
								   'VALUES (IF(', id_cliente, '<> 0, ', id_cliente,', DEFAULT(Idcliente)),											
                                            IF(', p_tipo_cliente, '<> 0, ', p_tipo_cliente,', DEFAULT(TipoCliente)),                                                                                        
                                            IF(', p_tipoVenta, '<> 0, ', p_tipoVenta,', DEFAULT(Tipoventa)),
											IF(\'', p_clubComex, '\'<>\'\', TRIM(\'', p_clubComex, '\'), DEFAULT(NumTarjCComex)),
											IF(', p_tarjVirtual, '<> 0, ', p_tarjVirtual,', DEFAULT(EsTarjetaV)),											
											IF(\'', _nombre, '\'<>\'\', TRIM(\'', _nombre, '\'), DEFAULT(Nombre)),
											IF(\'', p_primer_nombre, '\'<>\'\', TRIM(\'', p_primer_nombre, '\'), DEFAULT(PrimerNombre)), 
											IF(\'', p_segundo_nombre, '\'<>\'\', TRIM(\'', p_segundo_nombre, '\'), DEFAULT(SegundoNombre)), 
											IF(\'', p_primer_apellido, '\'<>\'\', TRIM(\'', p_primer_apellido, '\'), DEFAULT(PrimerApellido)), 
											IF(\'', p_segundo_apellido, '\'<>\'\', TRIM(\'', p_segundo_apellido, '\'), DEFAULT(SegundoApellido)), 
											IF(\'', p_alias, '\'<>\'\', TRIM(\'', p_alias, '\'), DEFAULT(Alias)),
											IF(\'', p_rfc, '\'<>\'\', TRIM(\'', p_rfc, '\'), DEFAULT(Rfc)),
											IF(\'', p_cedula, '\'<>\'\', TRIM(\'', p_cedula, '\'), DEFAULT(NumCedula)),
											IF(\'', p_calle, '\'<>\'\', TRIM(\'', p_calle, '\'), DEFAULT(Callenum)),
											IF(\'', p_numExt, '\'<>\'\', TRIM(\'', p_numExt, '\'), DEFAULT(NumExt)),
											IF(\'', p_numInt, '\'<>\'\', TRIM(\'', p_numInt, '\'), DEFAULT(NumInt)),				
											IF(\'', p_colonia, '\'<>\'\', TRIM(\'', p_colonia, '\'), DEFAULT(Colonia)),
											IF(\'', p_delegacion, '\'<>\'\', TRIM(\'', p_delegacion, '\'), DEFAULT(Delemuni)),
											IF(\'', p_municipio, '\'<>\'\', TRIM(\'', p_municipio, '\'), DEFAULT(Municipio)),
											IF(', p_estado, '<> 0, ', p_estado,', DEFAULT(Estado)),
											IF(\'', p_cp, '\'<>\'\', TRIM(\'', p_cp, '\'), DEFAULT(Cp)),
											IF(\'', p_telefono, '\'<>\'\', TRIM(\'', p_telefono, '\'), DEFAULT(Tel)),
											IF(\'', p_contacto, '\'<>\'\', TRIM(\'', p_contacto, '\'), DEFAULT(Contacto)),
											IF(', p_rfcd, '<> 0, ', p_rfcd,', DEFAULT(Rfcd)),
											IF(\'', p_email, '\'<>\'\', TRIM(\'', p_email, '\'), DEFAULT(Email)),
											IF(\'', p_giro, '\'<>\'\', TRIM(\'', p_giro, '\'), DEFAULT(Giro)),
											IF(\'', p_subGiro, '\'<>\'\', TRIM(\'', p_subGiro, '\'), DEFAULT(Subgiro)),
											IF(', p_numPinta, '<> 0, ', p_numPinta,', DEFAULT(Numpinta)),           
											IF(\'', p_claveBus, '\'<>\'\', TRIM(\'', p_claveBus, '\'), DEFAULT(Clavebus)),
											IF(\'', p_metodoPago, '\'<>\'\', TRIM(\'', p_metodoPago, '\'), DEFAULT(MetodoPago)),
											IF(\'', p_cuentaPago, '\'<>\'\', TRIM(\'', p_cuentaPago, '\'), DEFAULT(CuentaPago)),
											IF(\'', p_numCliePref, '\'<>\'\', TRIM(\'', p_numCliePref, '\'), DEFAULT(NumCliPref)),
											IF(', p_idConvenio, '<> 0, ', p_idConvenio,', DEFAULT(IdConvenio)),
											IF(\'', p_tipoAdenda, '\'<>\'\', TRIM(\'', p_tipoAdenda, '\'), DEFAULT(TipoAdenda)),
											IF(\'', p_infoAdenda, '\'<>\'\', TRIM(\'', p_infoAdenda, '\'), DEFAULT(InfoAdenda)),
											IF(', p_sucAlta, '<> 0, ', p_sucAlta,', DEFAULT(SucAlta)),
											IF(\'', p_fecAlta, '\'<>\'\', TRIM(\'', p_fecAlta, '\'), DEFAULT(FecAlta)),
											IF(', p_idTmpAlta, '<> 0, ', p_idTmpAlta,', DEFAULT(IdTmpAlta)), \'',
											NOW(), '\',
                                            IF(\'', p_NIT, '\'<>\'\',TRIM(\'', p_NIT, '\'), DEFAULT(NIT)),
                                            IF(\'', p_NRC, '\'<>\'\',TRIM(\'', p_NRC, '\'), DEFAULT(NRC)),
                                            IF(\'', p_ActivComer, '\'<>\'\',TRIM(\'', p_ActivComer, '\'), DEFAULT(ActivComer)),
                                            IF(', p_catContrib, '<> 0, ', p_catContrib, ', DEFAULT(catContrib)))
                                            ;'); 
			
            
			PREPARE stmt FROM @vs_query;    
			
			EXECUTE stmt;    
			
			DEALLOCATE PREPARE stmt;
            IF StatProc = 0 then
				set @vg_pdvA = @vg_pdv;
				set @vg_pdvA = (select replace(@vg_pdvA, 'pdv', ''));
				If @vg_pdvA = '' THEN
				   set @vg_pdvA = 'pinta';
				END IF;            
				call pospinta.execSql(@vg_pdvA, concat(    
					'UPDATE @dbpdv.venta_cat_consecutivo SET num_consecutivo = ', id_cliente, ',', 'fch_consecutivo = ', @vd_fecha, 
					' WHERE id_consecutivo = ', @vi_idConsec, ' AND id_sucursal = ', @vg_sucursal));
				SET StatProc = id_cliente;  
            END IF;
            
        END IF;        
        
		
		COMMIT;
        SELECT StatProc;
END