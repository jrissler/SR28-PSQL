
DROP TABLE IF EXISTS nut_datas;
DROP TABLE IF EXISTS languals;
DROP TABLE IF EXISTS langdescs;
DROP TABLE IF EXISTS footnotes;
DROP TABLE IF EXISTS weights;
DROP TABLE IF EXISTS datsrclns;
DROP TABLE IF EXISTS data_srcs;
DROP TABLE IF EXISTS src_cds;
DROP TABLE IF EXISTS deriv_cds;
DROP TABLE IF EXISTS food_descs;
DROP TABLE IF EXISTS fd_groups;
DROP TABLE IF EXISTS nutr_defs;

CREATE TABLE fd_groups
(
  fdgrp_cd char(4) PRIMARY KEY,
  fdgrp_desc varchar(60) NOT NULL
);
COPY fd_groups FROM '~/code/SR28-PSQL/FD_GROUP.txt' QUOTE '~' DELIMITER '^' CSV ENCODING 'LATIN1';
--------------------------------------------------------
CREATE TABLE food_descs
(
  ndb_no char(5) PRIMARY KEY,
  fdgrp_cd char(4) NOT NULL REFERENCES fd_group,
  long_desc varchar(200) NOT NULL,
  shrt_desc varchar(60) NOT NULL,
  comname varchar(100),
  manufacname varchar(65),
  survey char(1),
  ref_desc varchar(135),
  refuse int,
  sciname varchar(65),
  n_factor numeric(6,2),
  pro_factor numeric(6,2),
  fat_factor numeric(6,2),
  cho_factor numeric(6,2)
);
COPY food_desc FROM '~/code/SR28-PSQL/FOOD_DES.txt' QUOTE '~' DELIMITER '^' CSV ENCODING 'LATIN1' ;
CREATE INDEX ON food_descs (lower(long_desc) ASC);psq
----------------------------------------------------------
CREATE TABLE langdescs
(
  factor_code char(5) PRIMARY KEY,
  description varchar(140) NOT NULL
);
COPY langdescs FROM '~/code/SR28-PSQL/LANGDESC.txt' QUOTE '~' DELIMITER '^' CSV ENCODING 'LATIN1';

CREATE TABLE src_cds
(
  src_cd char(2) PRIMARY KEY,
  srccd_desc varchar(60) NOT NULL
);
COPY src_cds FROM '~/code/SR28-PSQL/SRC_CD.txt' QUOTE '~' DELIMITER '^' CSV ENCODING 'LATIN1';

CREATE TABLE deriv_cds
(
  deriv_cd char(4) PRIMARY KEY,
  deriv_desc varchar(120) NOT NULL
);
COPY deriv_cds FROM '~/code/SR28-PSQL/DERIV_CD.txt' QUOTE '~' DELIMITER '^' CSV ENCODING 'LATIN1';

CREATE TABLE weights
(
  ndb_no char(5) NOT NULL REFERENCES food_desc,--A 5* N 5-digit Nutrient Databank number that uniquely identifies a food item.  If this field is defined as numeric, the leading zero will be lost.
  seq char(2) NOT NULL, --A 2* N Sequence number.
  amount numeric(8,3) NOT NULL, -- N Unit modifier (for example, 1 in “1 cup”).
  msre_desc varchar(84) NOT NULL, -- N Description (for example, cup, diced, and 1-inch pieces).
  gm_wgt numeric(8,1) NOT NULL, -- N Gram weight.
  num_data_pts int, --N 3 Y Number of data points.
  std_dev numeric(10,3), -- Y Standard deviation
  PRIMARY KEY (ndb_no, seq)
);
COPY weights FROM '~/code/SR28-PSQL/WEIGHT.txt' QUOTE '~' DELIMITER '^' CSV ENCODING 'LATIN1';

CREATE TABLE languals
(
  ndb_no char(5) NOT NULL REFERENCES food_desc,
  factor_code char(5) NOT NULL REFERENCES langdesc,
  primary key (ndb_no, factor_code)
);
COPY languals FROM '~/code/SR28-PSQL/LANGUAL.txt' QUOTE '~' DELIMITER '^' CSV ENCODING 'LATIN1';

CREATE TABLE nutr_defs
(
  nutr_no char(4) PRIMARY KEY, --Unique 3-digit identifier code for a nutrient.
  units varchar(7) NOT NULL, -- N Units of measure (mg, g, μg, and so on).
  tagname varchar(20), -- Y International Network of Food Data Systems (INFOODS) Tagnames.† A unique abbreviation for a nutrient/food component developed by INFOODS to aid in the interchange of data.
  nutrDesc varchar(60) NOT NULL,-- N Name of nutrient/food component.
  num_dec char(1) NOT NULL, -- N Number of decimal places to which a nutrient value is rounded.
  sr_order int NOT NULL
);
COPY nutr_defs FROM '~/code/SR28-PSQL/NUTR_DEF.txt' QUOTE '~' DELIMITER '^' CSV ENCODING 'LATIN1';

CREATE TABLE nut_datas
(
  ndb_no char(5) NOT NULL REFERENCES food_desc, --* N 5-digit Nutrient Databank number that uniquely identifies a food item.  If this field is defined as numeric, the leading zero will be lost.
  nutr_no char(3) NOT NULL REFERENCES nutr_def, -- 3* N Unique 3-digit identifier code for a nutrient.
  nutr_val numeric(13,3) NOT NULL, -- N Amount in 100 grams, edible portion †.
  num_data_pts numeric(5,0) NOT NULL,--N 5.0 N Number of data points is the number of analyses used to calculate the nutrient value. If the number of data points is 0, the value was calculated or imputed.
  std_error numeric(11,3), -- Y Standard error of the mean. Null if cannot be calculated. The standard error is also not given if the number of data points is less than three.
  src_cd char(2) REFERENCES src_cd, -- N Code indicating type of data.
  deriv_cd char(4) REFERENCES deriv_cd, --A 4 Y Data Derivation Code giving specific information on how the value is determined.  This field is populated only for items added or updated starting with SR14.  This field may not be populated if older records were used in the calculation of the mean value.
  ref_ndb_no char(5) REFERENCES food_desc, -- Y NDB number of the item used to calculate a missing value. Populated only for items added or updated starting with SR14.
  add_nutr_mark char(1), -- Y Indicates a vitamin or mineral added for fortification or enrichment. This field is populated for ready-toeat breakfast cereals and many brand-name hot cereals in food group 08.
  num_studies int, --N 2 Y Number of studies.
  min numeric(13,3), -- Y Minimum value.
  max numeric(13,3), -- Y Maximum value.
  df int, --N 4 Y Degrees of freedom.
  low_eb numeric(13,3), -- Y Lower 95% error bound.
  up_eb numeric(13,3), -- Y Upper 95% error bound.
  stat_cmt varchar(10), -- Y Statistical comments. See definitions below.
  addmod_date varchar(10), -- Y Indicates when a value was either added to the database or last modified.
  cc char(1), -- Y Confidence Code indicating data quality, based on evaluation of sample plan, sample handling, analytical method, analytical quality control, and number of samples analyzed. Not included in this release, but is planned for future releases.
  PRIMARY KEY (ndb_no, nutr_no)
);
COPY nut_datas FROM '~/code/SR28-PSQL/NUT_DATA.txt' QUOTE '~' DELIMITER '^' CSV ENCODING 'LATIN1';

CREATE TABLE footnotes
(
  ndb_no char(5) NOT NULL REFERENCES food_desc,-- N 5-digit Nutrient Databank number that uniquely identifies a food item.  If this field is defined as numeric, the leading zero will be lost.
  footnt_no char(4) NOT NULL, -- 4 N Sequence number. If a given footnote applies to more than one nutrient number, the same footnote number is used. As a result, this file cannot be indexed and there is no primary key.
  footnt_typ char(1) NOT NULL, -- N Type of footnote: D = footnote adding information to the food description;  M = footnote adding information to measure description;  N = footnote providing additional information on a nutrient value. If the Footnt_typ = N, the Nutr_No will also be filled in.
  nutr_no char(3) REFERENCES nutr_def, -- Y Unique 3-digit identifier code for a nutrient to which footnote applies.
  footnt_txt varchar(200) NOT NULL -- N Footnote text.
);
COPY footnotes FROM '~/code/SR28-PSQL/FOOTNOTE.txt' QUOTE '~' DELIMITER '^' CSV ENCODING 'LATIN1';

CREATE TABLE data_srcs
(
  datasrc_id char(6) PRIMARY KEY, --* N Unique ID identifying the reference/source.
  authors varchar(255), -- Y List of authors for a journal article or name of sponsoring organization for other documents.
  title varchar(255) NOT NULL,-- N Title of article or name of document, such as a report from a company or trade association.
  year char(4), -- Y Year article or document was published.
  journal varchar(135), -- Y Name of the journal in which the article was published.
  vol_city varchar(16), -- Y Volume number for journal articles, books, or reports; city where sponsoring organization is located.
  issue_state varchar(5),-- Y Issue number for journal article; State where the sponsoring organization is located.
  start_page varchar(5), -- Y Starting page number of article/document.
  end_page varchar(5) --Y Ending page number of article/document.
);
COPY data_srcs FROM '~/code/SR28-PSQL/DATA_SRC.txt' QUOTE '~' DELIMITER '^' CSV ENCODING 'LATIN1';

CREATE TABLE datsrclns
(
  ndb_no char(5) NOT NULL REFERENCES food_desc,--A 5* N 5-digit Nutrient Databank number that uniquely identifies a food item.  If this field is defined as numeric, the leading zero will be lost.
  nutr_no char(3) NOT NULL REFERENCES nutr_def, --A 3* N Unique 3-digit identifier code for a nutrient.
  datasrc_id char(6) NOT NULL REFERENCES data_src, --A 6* N Unique ID identifying the reference/source.
  PRIMARY KEY (ndb_no, nutr_no, datasrc_id)
);
COPY datsrclns FROM '~/code/SR28-PSQL/DATSRCLN.txt' QUOTE '~' DELIMITER '^' CSV ENCODING 'LATIN1';
