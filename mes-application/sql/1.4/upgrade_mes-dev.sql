-- Added field to PPS
-- last touched 01.06.2015 by kama

ALTER TABLE productionpershift_productionpershift ADD COLUMN orderfinishdate timestamp without time zone;

-- end


-- Changes in substitutes
-- last touched 12.05.2015 by kama

ALTER TABLE basic_substitutecomponent ADD COLUMN baseproduct_id bigint;
ALTER TABLE basic_substitutecomponent
  ADD CONSTRAINT substitutecomponent_baseproduct_fkey FOREIGN KEY (baseproduct_id)
      REFERENCES basic_product (id) DEFERRABLE;

-- end


-- Reworked menu, added category Company structure, added missing views to basic
-- last touched 13.05.2015 by kama

INSERT INTO qcadooview_category(
            id, pluginidentifier, name, succession)
    VALUES (nextval('hibernate_sequence'), 'basic', 'companyStructure', (
  SELECT MAX(succession) FROM qcadooview_category)+1);

INSERT INTO qcadooview_view(id,pluginidentifier, name, view)
  VALUES (nextval('hibernate_sequence'),'basic','factoriesList','factoriesList');
INSERT INTO qcadooview_view(id,pluginidentifier, name, view)
  VALUES (nextval('hibernate_sequence'),'basic','subassembliesList','subassembliesList');

INSERT INTO qcadooview_item(
            id, pluginidentifier, name, active, category_id, view_id, succession)
    VALUES (nextval('hibernate_sequence'), 'basic', 'subassemblies', TRUE,
  (SELECT id FROM qcadooview_category WHERE name='companyStructure'),
  (SELECT id FROM qcadooview_view WHERE name='subassembliesList'),6);

INSERT INTO qcadooview_item(
            id, pluginidentifier, name, active, category_id, view_id, succession)
    VALUES (nextval('hibernate_sequence'), 'basic', 'factories', TRUE,
  (SELECT id FROM qcadooview_category WHERE name='companyStructure'),
  (SELECT id FROM qcadooview_view WHERE name='factoriesList'), 1);


UPDATE qcadooview_item
   SET category_id= (
  SELECT id FROM qcadooview_category WHERE name='companyStructure'
   ),succession=2
 WHERE name='divisions';

UPDATE qcadooview_item
   SET category_id= (
  SELECT id FROM qcadooview_category WHERE name='companyStructure'
   ),succession=3
 WHERE name='productionLines';

 UPDATE qcadooview_item
   SET category_id= (
  SELECT id FROM qcadooview_category WHERE name='companyStructure'
   ),succession=4
 WHERE name='workstationTypes';
 
 UPDATE qcadooview_item
   SET category_id= (
  SELECT id FROM qcadooview_category WHERE name='companyStructure'
   ),succession=5
 WHERE name='workstations';

-- end


-- Added 'is default' field to delivered products in company
-- last touched 14.05.2015 by kama


ALTER TABLE deliveries_companyproduct ADD COLUMN isdefault boolean;
ALTER TABLE deliveries_companyproduct ALTER COLUMN isdefault SET DEFAULT false;
ALTER TABLE deliveries_companyproductsfamily ADD COLUMN isdefault boolean;
ALTER TABLE deliveries_companyproductsfamily ALTER COLUMN isdefault SET DEFAULT false;

-- end


-- Table: warehouseminimalstate_warehouseminimumstate

-- DROP TABLE warehouseminimalstate_warehouseminimumstate;

CREATE TABLE warehouseminimalstate_warehouseminimumstate
(
  id bigint NOT NULL,
  product_id bigint,
  location_id bigint,
  minimumstate numeric(12,5),
  optimalorderquantity numeric(12,5),
  createdate timestamp without time zone,
  updatedate timestamp without time zone,
  createuser character varying(255),
  updateuser character varying(255),
  CONSTRAINT warehouseminimalstate_warehouseminimumstate_pkey PRIMARY KEY (id),
  CONSTRAINT warehouseminimumstate_product_fkey FOREIGN KEY (product_id)
      REFERENCES basic_product (id) DEFERRABLE,
  CONSTRAINT warehouseminimumstate_location_fkey FOREIGN KEY (location_id)
      REFERENCES materialflow_location (id) DEFERRABLE
);

CREATE TABLE warehouseminimalstate_warehouseminimumstatemulti
(
  id bigint NOT NULL,
  location_id bigint,
  minimumstate numeric(12,5),
  optimalorderquantity numeric(12,5),
  createdate timestamp without time zone,
  updatedate timestamp without time zone,
  createuser character varying(255),
  updateuser character varying(255),
  CONSTRAINT warehouseminimalstate_warehouseminimumstatemulti_pkey PRIMARY KEY (id),
  CONSTRAINT warehouseminimumstatemulti_location_fkey FOREIGN KEY (location_id)
      REFERENCES materialflow_location (id) DEFERRABLE
);

CREATE TABLE jointable_product_warehouseminimumstatemulti
(
  product_id bigint NOT NULL,
  warehouseminimumstatemulti_id bigint NOT NULL,
  CONSTRAINT jointable_product_warehouseminimumstatemulti_pkey PRIMARY KEY (warehouseminimumstatemulti_id, product_id),
  CONSTRAINT warehouseminimalstate_warehouseminimumstatemulti_product_fkey FOREIGN KEY (warehouseminimumstatemulti_id)
      REFERENCES warehouseminimalstate_warehouseminimumstatemulti (id) DEFERRABLE,
  CONSTRAINT basic_product_warehouseminimumstatemulti_fkey FOREIGN KEY (product_id)
      REFERENCES basic_product (id) DEFERRABLE
);

-- end


-- Added updating cost norms for products
-- last touched 28.05.2015 by kama

CREATE TABLE materialflowresources_costnormsgenerator
(
  id bigint NOT NULL,
  costssource character varying(255) DEFAULT '01mes'::character varying,
  productstoupdate character varying(255) DEFAULT '01all'::character varying,
  CONSTRAINT materialflowresources_costnormsgenerator_pkey PRIMARY KEY (id)
);

CREATE TABLE materialflowresources_costnormslocation
(
  id bigint NOT NULL,
  costnormsgenerator_id bigint,
  location_id bigint,
  CONSTRAINT materialflowresources_costnormslocation_pkey PRIMARY KEY (id),
  CONSTRAINT costnormslocation_costnormsgenerator_fkey FOREIGN KEY (costnormsgenerator_id)
      REFERENCES materialflowresources_costnormsgenerator (id) DEFERRABLE,
  CONSTRAINT costnormslocation_location_fkey FOREIGN KEY (location_id)
      REFERENCES materialflow_location (id) DEFERRABLE
);

ALTER TABLE basic_product ADD COLUMN costnormsgenerator_id bigint;
ALTER TABLE basic_product
  ADD CONSTRAINT product_costnormsgenerator_fkey FOREIGN KEY (costnormsgenerator_id)
      REFERENCES materialflowresources_costnormsgenerator (id) DEFERRABLE;

-- end


-- Table: assignmenttoshift_staffassignmenttoshift
-- last touched 03.06.2015 by lupo

ALTER TABLE assignmenttoshift_staffassignmenttoshift ADD COLUMN masterorder_id bigint;

ALTER TABLE assignmenttoshift_staffassignmenttoshift
  ADD CONSTRAINT staffassignmenttoshift_masterorder_fkey FOREIGN KEY (masterorder_id)
      REFERENCES masterorders_masterorder (id) DEFERRABLE;

-- end

-- Added columns to work plans
-- last touched 11.06.2015 by kama

INSERT INTO workplans_columnforinputproducts(
            identifier, name, description, columnfiller, alignment)
    VALUES ('quantityPerUnitOperationProductColumn', 'workPlans.columnForInputProducts.name.value.quantityPerUnitOperationProductColumn',
	'workPlans.columnForInputProducts.description.value.quantityPerUnitOperationProductColumn', 'com.qcadoo.mes.workPlans.workPlansColumnExtension.WorkPlansColumnFiller', '02right');

INSERT INTO workplans_columnforinputproducts(
            identifier, name, description, columnfiller, alignment)
    VALUES ('unitOperationProductColumn', 'workPlans.columnForInputProducts.name.value.unitOperationProductColumn',
	'workPlans.columnForInputProducts.description.value.unitOperationProductColumn', 'com.qcadoo.mes.workPlans.workPlansColumnExtension.WorkPlansColumnFiller', '01left');

INSERT INTO workplans_columnforoutputproducts(
            identifier, name, description, columnfiller, alignment)
    VALUES ('unitOperationProductColumn', 'workPlans.columnForOutputProducts.name.value.unitOperationProductColumn',
	'workPlans.columnForOutputProducts.description.value.unitOperationProductColumn', 'com.qcadoo.mes.workPlans.workPlansColumnExtension.WorkPlansColumnFiller', '01left');

INSERT INTO workplans_parameterinputcolumn(
            parameter_id, columnforinputproducts_id, succession)
    VALUES (
	(SELECT MAX(id) FROM basic_parameter),
	(SELECT id FROM workplans_columnforinputproducts WHERE identifier='unitOperationProductColumn'),
	(SELECT MAX(succession) FROM workplans_parameterinputcolumn)+1);

INSERT INTO workplans_parameteroutputcolumn(
            parameter_id, columnforoutputproducts_id, succession)
    VALUES (
	(SELECT MAX(id) FROM basic_parameter),
	(SELECT id FROM workplans_columnforoutputproducts WHERE identifier='unitOperationProductColumn'),
	(SELECT MAX(succession) FROM workplans_parameteroutputcolumn)+1);

CREATE OR REPLACE FUNCTION insert_operationworkplancolumns() RETURNS VOID AS
$$
	DECLARE
		operation RECORD;

	BEGIN
		FOR operation IN SELECT * FROM technologies_operation LOOP
			EXECUTE 'INSERT INTO workplans_operationinputcolumn(operation_id, columnforinputproducts_id, succession) VALUES('
			|| operation."id" || ', '
			|| '(SELECT id FROM workplans_columnforinputproducts WHERE identifier=''unitOperationProductColumn'') ' || ', '
			|| '(SELECT MAX(succession) FROM workplans_operationinputcolumn)+1' || ');';

			EXECUTE 'INSERT INTO workplans_operationoutputcolumn(operation_id, columnforoutputproducts_id, succession) VALUES('
			|| operation."id" || ', '
			|| '(SELECT id FROM workplans_columnforoutputproducts WHERE identifier=''unitOperationProductColumn'') ' || ', '
			|| '(SELECT MAX(succession) FROM workplans_operationoutputcolumn)+1' || ');';
		END LOOP;
	END;
$$
LANGUAGE 'plpgsql';

SELECT * FROM insert_operationworkplancolumns();

DROP FUNCTION insert_operationworkplancolumns();


CREATE OR REPLACE FUNCTION insert_tocworkplancolumns() RETURNS VOID AS
$$
	DECLARE
		technologyoperationcomponent RECORD;

	BEGIN
		FOR technologyoperationcomponent IN SELECT * FROM technologies_technologyoperationcomponent LOOP
			EXECUTE 'INSERT INTO workplans_technologyoperationinputcolumn(technologyoperationcomponent_id, columnforinputproducts_id, succession) VALUES('
			|| technologyoperationcomponent."id" || ', '
			|| '(SELECT id FROM workplans_columnforinputproducts WHERE identifier=''unitOperationProductColumn'') ' || ', '
			|| '(SELECT MAX(succession) FROM workplans_technologyoperationinputcolumn)+1' || ');';

			EXECUTE 'INSERT INTO workplans_technologyoperationoutputcolumn(technologyoperationcomponent_id, columnforoutputproducts_id, succession) VALUES('
			|| technologyoperationcomponent."id" || ', '
			|| '(SELECT id FROM workplans_columnforoutputproducts WHERE identifier=''unitOperationProductColumn'') ' || ', '
			|| '(SELECT MAX(succession) FROM workplans_technologyoperationoutputcolumn)+1' || ');';
		END LOOP;
	END;
$$
LANGUAGE 'plpgsql';

SELECT * FROM insert_tocworkplancolumns();

DROP FUNCTION insert_tocworkplancolumns();

-- end

-- Change order of columns in work plans
-- last touched 12.06.2015 by kama

UPDATE workplans_columnforinputproducts SET identifier='unitOperationProductColumn_temp' WHERE identifier='unitOperationProductColumn';
UPDATE workplans_columnforinputproducts SET identifier='employeeSignatureOperationProductColumn_temp' WHERE identifier='employeeSignatureOperationProductColumn';
UPDATE workplans_columnforinputproducts SET identifier='effectiveQuantityOperationProductColumn_temp' WHERE identifier='effectiveQuantityOperationProductColumn';
UPDATE workplans_columnforinputproducts SET identifier='attentionOperationProductColumn_temp' WHERE identifier='attentionOperationProductColumn';
UPDATE workplans_columnforinputproducts SET identifier='quantityPerUnitOperationProductColumn_temp' WHERE identifier='quantityPerUnitOperationProductColumn';

UPDATE workplans_columnforinputproducts SET identifier='unitOperationProductColumn', name='workPlans.columnForInputProducts.name.value.unitOperationProductColumn',
	description='workPlans.columnForInputProducts.description.value.unitOperationProductColumn', alignment='01left'
	WHERE identifier='effectiveQuantityOperationProductColumn_temp';

UPDATE workplans_columnforinputproducts SET identifier='quantityPerUnitOperationProductColumn', name='workPlans.columnForInputProducts.name.value.quantityPerUnitOperationProductColumn',
	description='workPlans.columnForInputProducts.description.value.quantityPerUnitOperationProductColumn', alignment='02right'
	WHERE identifier='attentionOperationProductColumn_temp';

UPDATE workplans_columnforinputproducts SET identifier='effectiveQuantityOperationProductColumn', name='workPlans.columnForInputProducts.name.value.effectiveQuantityOperationProductColumn',
	description='workPlans.columnForInputProducts.description.value.effectiveQuantityOperationProductColumn', alignment='02right'
	WHERE identifier='employeeSignatureOperationProductColumn_temp';

UPDATE workplans_columnforinputproducts SET identifier='attentionOperationProductColumn', name='workPlans.columnForInputProducts.name.value.attentionOperationProductColumn',
	description='workPlans.columnForInputProducts.description.value.attentionOperationProductColumn', alignment='01left'
	WHERE identifier='unitOperationProductColumn_temp';

UPDATE workplans_columnforinputproducts SET identifier='employeeSignatureOperationProductColumn', name='workPlans.columnForInputProducts.name.value.employeeSignatureOperationProductColumn',
	description='workPlans.columnForInputProducts.description.value.employeeSignatureOperationProductColumn', alignment='01left'
	WHERE identifier='quantityPerUnitOperationProductColumn_temp';

UPDATE workplans_columnforoutputproducts SET identifier='unitOperationProductColumn_temp' WHERE identifier='unitOperationProductColumn';
UPDATE workplans_columnforoutputproducts SET identifier='employeeSignatureOperationProductColumn_temp' WHERE identifier='employeeSignatureOperationProductColumn';
UPDATE workplans_columnforoutputproducts SET identifier='effectiveQuantityOperationProductColumn_temp' WHERE identifier='effectiveQuantityOperationProductColumn';
UPDATE workplans_columnforoutputproducts SET identifier='attentionOperationProductColumn_temp' WHERE identifier='attentionOperationProductColumn';

UPDATE workplans_columnforoutputproducts SET identifier='unitOperationProductColumn', name='workPlans.columnForInputProducts.name.value.unitOperationProductColumn',
	description='workPlans.columnForInputProducts.description.value.unitOperationProductColumn', alignment='01left'
	WHERE identifier='effectiveQuantityOperationProductColumn_temp';

UPDATE workplans_columnforoutputproducts SET identifier='effectiveQuantityOperationProductColumn', name='workPlans.columnForInputProducts.name.value.effectiveQuantityOperationProductColumn',
	description='workPlans.columnForInputProducts.description.value.effectiveQuantityOperationProductColumn', alignment='02right'
	WHERE identifier='attentionOperationProductColumn_temp';

UPDATE workplans_columnforoutputproducts SET identifier='attentionOperationProductColumn', name='workPlans.columnForInputProducts.name.value.attentionOperationProductColumn',
	description='workPlans.columnForInputProducts.description.value.attentionOperationProductColumn', alignment='01left'
	WHERE identifier='employeeSignatureOperationProductColumn_temp';

UPDATE workplans_columnforoutputproducts SET identifier='employeeSignatureOperationProductColumn', name='workPlans.columnForInputProducts.name.value.employeeSignatureOperationProductColumn',
	description='workPlans.columnForInputProducts.description.value.employeeSignatureOperationProductColumn', alignment='01left'
	WHERE identifier='unitOperationProductColumn_temp';

-- end