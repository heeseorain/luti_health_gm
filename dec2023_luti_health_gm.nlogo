;; Copyright @ 2023 Heeseo Rain Kwon.
;; LUTI-Health-GM. Land use-transport interaction (LUTI) simulation for Greater Manchester focusing on health (non-communicable disease) and health inequality.
;; The development of this pilot model is funded by the Population Health Agent-based Simulation nEtwork (PHASE),
;; a network funded by the UK Prevention Research Partnership (UKPRP).

extensions [gis csv]

; ##################################################################
; Global variables
; ##################################################################
globals [
  borough_dataset
  land_nat_bui_cent_sep2022_dataset
  resi_height_sep2022_dataset
  retail_height_sep2022_dataset
  office_height_sep2022_dataset
  water_bodies_dataset
  citycentre_localcentre_suburb_dataset

  multiple_dep_lsoa_2011_dataset

  coronary_prevalence_2022_dataset
  heart_failure_prevalence_2022_dataset
  hypertension_prevalence_2022_dataset
  stroke_prevalence_2022_dataset
  copd_prevalence_2022_dataset
  cancer_prevalence_2022_dataset
  obesity_prevalence_2022_dataset
  diabetes_prevalence_2022_dataset
  depression_prevalence_2022_dataset
  mental_health_prevalence_2022_dataset
  pm25_2021_dataset
  pm10_2021_dataset

  the-row  ;;used in export_data. It is the row being written.
  mode_share_car

; For observation
  num_car_turtle
  num_noncar_turtle
]

; ##################################################################
; patch attribute definitions
; ##################################################################
patches-own[
;  urban ;; 0=non-urban, 1=urban.
  borough ;; 1=Bolton, 2=Bury, 3=Manchester, 4=Oldham, 5=Rochdale, 6=Salford, 7=Stockport, 8=Tameside, 9=Trafford, 10=Wigan
  land_nat_bui_cent_sep2022 ;; 1=nature, 2=built, 3=centrality
;  buildings_nature_built_centrality ;; 1=nature, 2=built, 3=centrality
;  resi_retail_office ;; 1=resi or mainly resi, 2=retail or mainly retail, 3=office or mainly office
;  fmc_building_use ;; 1=resi or mainly resi.
                   ;; 2=healthcare. Community-health, community-emergency services.
                   ;; 3=education. Community-educational.
                   ;; 4=entertainment. Recreation and leisure.
                   ;; 5=retail or mainly retail.
                   ;; 6=office or mainly office.
;  places_of_employment ;; 0=no, 1=yes
;  mixed_use_building ;; 0=no, 1=yes
  nature ;; 0=no, 1=yes (green).
  resi_height_sep2022 ;; residential intensity in spectrum. General commercial mixed use (25% resi), mostly residential (e.g. with retail on ground floor) (80% resi),
               ;; residential only (100% resi). Multiplied by building height (metre). min=0, max=104
  retail_height_sep2022 ;; retail intensity in spectrum. General commercial mixed use (25% resi), mostly retail (e.g. with office/residential above) (80% resi),
               ;; retail only (100% resi). Multiplied by building height (metre). min=0, max=162
  office_height_sep2022 ;; office intensity in spectrum. General commercial mixed use (25% resi), mostly office (e.g. with retail on ground floor) (80% resi),
               ;; retail only (100% resi). Multiplied by building height (metre). min=0, max=134
  water_bodies ;; 0=non-water body, 1=water body
  citycentre_localcentre_suburb ;; 1=Manchester/borough city centres, 2=local centres, 3=suburban neighbourhoods, 4=

  multiple_dep_lsoa_2011 ;; Score. For example, if a Lower-layer Super Output Area (LSOA) has a score of 0.38, this means that 38% of the population is deprived in that area.

  pm25_2021 ;; PM2.5 concentration (microgram per cubic metre)
  pm10_2021 ;; PM10 concentration (microgram per cubic metre)

  coronary_prevalence_2022 ;; Coronary heart desease prevalence by GP practice (percentage). For example, if 4, this means that 4% of the population has coronary heart disease in that area.
  heart_failure_prevalence_2022
  hypertension_prevalence_2022
  stroke_prevalence_2022
  copd_prevalence_2022
  cancer_prevalence_2022
  obesity_prevalence_2022
  diabetes_prevalence_2022
  depression_prevalence_2022
  mental_health_prevalence_2022


;  built ;; 0=no, 1=yes (black).
  ;; possible alternative: 1=low density (light grey; 9), 2=medium density (dark grey; 5), 3=high density (black).
;  centrality ;; 0=no, 1=yes (white).
  nature_patch_cluster
  retail_patch_cluster
  office_patch_cluster
;  nature_cluster_id ;; for calculating nature cluster.

; Built environment, 15-minute city metric variables need to be added. Doesn't have to be patch attributes.
;  Can be turtle attributes calculating density/proximity/diversity characteristics of their neighbourhood in 2km radius for example.


; Attributes that change in simulation
  resi_height
  retail_height
  office_height
  building_height
  proportion_resi
  proportion_retail
  proportion_office
  mixed_use_diversity
]

; ##################################################################
; Agent attribute definitions (turtles)
; ##################################################################
turtles-own[
;; Used the UK 2011 Census Safeguarded Microdata Individual Sample (Grouped Local Authority) of Greater Manchester
;; https://www.ons.gov.uk/census/2011census/2011censusdata/censusmicrodata/safeguardedmicrodata
;; The 2021 data will be added when they become available.
;; https://www.ons.gov.uk/census/aboutcensus/censusproducts/microdatasamples
;; Microdata Sample for Greater Manchester has 46,948 Individuals. (2011 population=2.674 million so roughly 2%)
;; As the main mode of transport information is only collected for work, we extracted 21,430 individuals that work.

;; ## Behavioral (psycho/social/economic) variables ##
;; Values normalised to 0 to 100 (%). 0=Very low, 100=very high. or 0=no, 100=yes.
;; The variables link with the determinants of the theory of planned behaviour (TPB)
;; and the theory of interpersonal behaviour (TIB).
;; <Attitude (personal) - Attitude (TPB)>
  age_2011 ;; ageh. Age of individual (grouped). 1=0-4, 2=5-9, 3=10-15, 4=16-18, 5=19-24, 6=25-29, 7=30-34, 8=35-39, 9=40-44,
       ;; 10=45-49, 11=50-54, 12=55-59, 13=60-64, 14=65-69, 15=70-74, 16=75-79, 17=80-84, 18=85-89, 19=90+
  deprived_2011 ;; Household deprivation. 0=no data. 1=not deprived. 2=deprived in 1 dimension, 3=deprived in 2 dimensions,
       ;; 4=deprived in 3 dimensions, 5=deprived in 4 dimensions

;; <Attitude (personal) - Habit (TIB)>
  prev_address_2011 ;; add1yr. Address one year ago. 1=same, 2=other address within LA, 3=other address outside LA, within UK
       ;; 4=other address outside UK
  prev_region_2011 ;; moveregion. Region of origin 1 year ago (if moved). 1=migrant from outside UK, 2=North East, 3=North West, 4=Yorkshire and the Humber,
       ;; 5=East Midlands, 6=West Midlands, 7=East of England, 8=South East, 9=South West, 10=Inner London
       ;; 11=Outer London, 12=Scotland, 13=Wales, 14=Northern Ireland
  pre_car_2011 ;; inferred from prev_region_2011 (car dependency of the previous region lived).

;; <Attitude (personal) - Emotion (TIB)>
  reliability ;; hypothetical properties of bus/tram/cycle hire
  freq_connectivity ;; hypothetical properties of bus/tram/cycle hire
  safety ;; hypothetical properties of bus/tram/cycle hire

;; <Subjective norm (social) - Subjective norm (TPB)>
  nei_non_car ;; from neighbouring turtles within NetLogo
  fifty_nei_turtle ;; needed to calculate nei_non_car

;; <Perceived behavioural control (contextual) - Perceived behavioural control (TPB)>
  num_child_2011 ;; dpcfamuk11. Family dependent children. 1=no, 2/4/6=includes youngest aged 0-9, 3/5/7=includes youngest aged 10-18
  general_health_2011 ;; health. General health. 1=very good, 2=good, 3=fair, 4=bad, 5=very bad
  activity_limited_2011 ;; disabity. Long-term health problem. Day-to-day activities 1=limited a lot, 2=limited a little, 3=not limited
  patient_in_house_2011 ;; illhuk11g. ilIndividuals in household with long-standing illness/disability. 0=no, 1=1, 2=2+.

  ;; <Perceived behavioural control (contextual) - Facilitating conditions (TIB)>
  distance_work_2011 ;; aggdtwpew11g. Distance travelled to work. 1=less than 2km, 2=2 to <5km, 3=5 to <10km, 4=10 to <20km,
       ;; 5=20 to <40km, 6=40 to <60km, 7=60km+, 8=at home, 9=no fixed place, 10=work outwide England but within UK
       ;; 11=Work outside UK, 12=Works at offshore installation (within UK)
  num_car_own_2011 ;; carsnoc. No. of cars and vans. 1=1, 2=2, 3=3, 4=4 or more
  likely_office_desk_job_2011 ;; iscog 11-14=Managers; 24-25=Business/admin/ICT professionals; 33=Business/admin associate professionals
       ;; 35=Info and communication technicians; 41-44=Clerks
       ;; https://en.wikipedia.org/wiki/International_Standard_Classification_of_Occupations
  affordability ;; hypothetical properties of bus/tram/cycle hire
  density_twokm_radius
  proximity_twokm_radius
  mixed_use_twokm_radius ;; Using Shannon's diversity index (SHDI). Continuous. 0=min low mixed-use, 100=max high mixed-use.
  pm10_twokm_radius

;; ## Other variables calculated within NetLogo ##
  nei_patch ;; set an agentset of neighbouring patches within radius of 2km.
                 ;; this is small living zone reachable by walk, bicycle and neighbourhood bus (Oh, 2014).
  nei_turtle ;; set an agentset of neighbouring residents within radius of 2km.
  nature_cluster_in_twokm ;; 0=no, 1=yes.
  retail_cluster_in_twokm ;; 0=no, 1=yes.
  office_cluster_in_twokm ;; 0=no, 1=yes.
  proportion_resi_twokm_radius
  proportion_retail_twokm_radius
  proportion_office_twokm_radius

;; Importantly, current travel mode to work that gets updated every tick in the model as some turtles make mode switch.
  current_car_to_work
  likely_work_from_home

;; Variables normalised to 0-100 (%)
  age_2011_pc
  deprived_2011_pc
  pre_car_2011_pc

  reliability_pc
  freq_connectivity_pc
  safety_pc

  nei_non_car_pc

  num_child_2011_pc
  general_health_2011_pc
  activity_limited_2011_pc
  patient_in_house_2011_pc

  distance_work_2011_pc
  num_car_own_2011_pc
  likely_office_desk_job_2011_pc
  likely_work_from_home_pc

  affordability_pc
  density_twokm_radius_pc
  proximity_twokm_radius_pc
  mixed_use_twokm_radius_pc
  pm10_twokm_radius_pc

;; NCD variables
  coronary_2022 ;; Coronary heart disease estimated from the prevalence data. 0=no. 1=yes.
  heart_failure_2022
  hypertension_2022
  stroke_2022
  copd_2022
  cancer_2022
  obesity_2022
  diabetes_2022
  depression_2022
  mental_health_2022
  overall_ncd_2022



;; ## Other variables ##
  caseno_2011 ;; Census case no.
  id_2011 ;; Unique ID. Respondent ID on the survey.
  la_group_2011 ;; Local authority. 182=Bury, 183=Bolton, 184=Manchester, 185=Oldham,
       ;; 186=Rochdale, 187=Salford, 188=Stockport, 189=Tameside, 190=Trafford, 191=Wigan
  country_birth_2011 ;; cobg. Country of birth. 1-5=Europe: UK, 6-9=Europe: non-UK, 10-13=Non-Europe.
  ethnicity_2011 ;; Ethnic group. 1 to 3=White, 4-5=Mixed/multi eth group, 6-10=Asian/Asian British,
       ;; 11-12=Black/African/Carib./Black British, 13=Other.
  occupation_2011 ;; iscog. International Standard Classification of occupations. 1 = Commissioned armed forces officers
       ;; ... 96 = Refuse workers and other elementary workers
       ;; https://www.ons.gov.uk/file?uri=/census/2011census/2011censusdata/censusmicrodata/safeguardedmicrodata/codebooksafeguardedgroupedla_tcm77-398552.xls
  edu_2011 ;; hlqupuk11. Level of highest qualifications. 10=no, 11=level 1(0-4 GCSE), 12=level 2(5+ GCSE), 13=apprenticeship,
      ;; 14=level 3(2+ A levels), 15=level 4(degree), 16=other
  landlord_type_2011 ;; landlordew. Type of landlord. 1=housing assn/co-op, etc, 2=council, 3=private, 4=employer of a household member
       ;; 5=relative/friend of hosehold member, 6=other
  social_grade_2011 ;; scgpuk11c. Approximated social grade. 1=AB, 2=C1, 3=C2, 4=DE.
  sex_2011 ;; sex. 1=male, 2=female.
  tenure_2011 ;; tenduk. Tenure. 1=owns outright, 2=owns with mortgage/loan, 3=share ownership, 4=rents, 5=rent-free.
  travel_mode_to_work_2011 ;; transport. Method of travel to work. 1=work mainly at/from home, 2=underground/metro/light rail/tram, 3=train
       ;; 4=bus/minibus/coach, 5=taxi, 6=motorcycle/scooter/moped, 7=driving car/van, 8=passenger in car/van, 9=bicycle
       ;; 10=on foot, 11=other
  travel_mode_to_work_2001 ;; transport_2001. Method of travel to work (2001). 1=work mainly at/from home, 2=underground/metro/light rail/tram, 3=train
       ;; 4=bus/minibus/coach, 5=taxi, 6=motorcycle/scooter/moped, 7=driving car/van, 8=passenger in car/van, 9=bicycle
       ;; 10=on foot, 11=other
  work_from_home_2011 ;; derived from wkpladdewni. Mainly works at/from home. 0=no, 1=yes.
  place_of_work_2011 ;; wkpladdewni. 1=fixed location/reports to depot, 2=mainly works at/from home, 3=no fixed place,
       ;; 4=offshore installation, 5=outside UK
  live_near_work_2011 ;; wpzhome. Place of work. Comparison of where you live and work. 1=works at home,
       ;; 2=lives in same workplace zone/LGD as workplace, 3=lives outside zone, but within same LA/UA/district
       ;; 4=lives outside LA/UA/LGD area of workplace but within UK, 5=workplace outside UK
  workplace_2011 ;; wrkplaceew. 1=no fixed place. 2=work mainly at/from home, 3=inside LA area of residence, 4=outsidce LA area but inside GB
       ;; 5=Northern Ireland, 6=outside UK
  deprived_edu_2011 ;; depedhuk11. Education deprivation. 0=not deprived, 1=deprived.
  deprived_employ_2011 ;; depemhuk11. Employment deprivation. 0=not deprived, 1=deprived.
  deprived_health_2011 ;; dephdhuk11. Health/disability deprivation. 0=not deprived, 1=deprived.
  deprived_housing_2011 ;; dephshuk11. Housing deprivation (e.g. overcrowded). 0=not deprived, 1=deprived.

;; Probabilities for linking disease prevalence with the Census data.
  p_disease_age
  p_disease_general_health
  p_disease_health_activity_limited

  p_disease_with_age
  p_disease_without_age

;; Probabilities for change from car to non-car.
  p_age_2011
  p_deprived_2011
  p_pre_car_2011
  p_reliability
  p_freq_connectivity
  p_safety
  p_nei_non_car
  p_num_child_2011
  p_general_health_2011
  p_activity_limited_2011
  p_patient_in_house_2011
  p_distance_work_2011
  p_num_car_own_2011
  p_likely_office_desk_job_2011
  p_likely_work_from_home
  p_affordability
  p_density_twokm_radius
  p_proximity_twokm_radius
  p_mixed_use_twokm_radius
  p_pm10_twokm_radius


;; TPB
  attitude_2011
  sn_2011
  pbc_2011
  behavior_2011


]

; ##################################################################
; ###### Setup and Go
; ##################################################################

to setup
  clear-all
  reset-ticks
  resize-world 0 544 0 399
  set-patch-size 1.4

  load_gis_data
  show_citycentre_localcentre_suburb
  calculate_mixed_use_diversity

  print "running read_2011_residents_from_csv..."
  read_2011_residents_from_csv
  normalise

  setup_nei_patch
  setup_nat_ret_off_clusters
  calculate_building_height
  calculate_mixed_use_diversity

  calculate_density_twokm_radius
  calculate_proximity_twokm_radius
  calculate_mixed_use_twokm_radius
  calculate_pm10_twokm_radius

  set_resident_disease_prevalence
  set_hypoth_pub_tr_prop

  set mode_share_car count turtles with [current_car_to_work = 1] / count turtles * 100
  set num_car_turtle count turtles with [current_car_to_work = 1]
  set num_noncar_turtle count turtles with [current_car_to_work = 0]

  print (word " ticks: " ticks " mode_share_car: " mode_share_car
    " num_car_turtle: " num_car_turtle " num_noncar_turtle: " num_noncar_turtle)
end

to go
  random-seed random_seed

  ; Tick 0 = 2020, Tick 1 = 2021, Tick 2 = 2022 ... Tick 20 = 2040.
  if ticks >= 21 [stop]
  ;; If the current screen displays tick = 2, that means the simulation for 2022 has ended.

  if (ticks >= 2 and ticks <= 12) and wfh_scenario = "commute_5days_a_week_bau" [
    print "running commute_5days_a_week_bau..."
    commute_5days_a_week_bau
  ]

  if (ticks >= 2 and ticks <= 12) and wfh_scenario = "commute_3days_a_week" [
    print "running commute_3days_a_week..."
    commute_3days_a_week
  ]

  if (ticks >= 2 and ticks <= 12) and wfh_scenario = "commute_1day_a_week_or_less" [
    print "running commute_1day_a_week_or_less..."
    commute_1day_a_week_or_less
  ]

  if (ticks >= 2 and ticks <= 12) and wfh_scenario = "commute_3days_a_week_with_policy" [
    print "running commute_3days_a_week_with_policy..."
    commute_3days_a_week_with_policy
  ]

  setup_nei_patch
  setup_nat_ret_off_clusters
  calculate_building_height
  calculate_mixed_use_diversity

  calculate_density_twokm_radius
  calculate_proximity_twokm_radius
  calculate_mixed_use_twokm_radius
  calculate_pm10_twokm_radius

  setup_nei_turtle
  print "running switch_travel_mode..."
  switch_travel_mode
  ask turtles with [behavior_2011 > 0.203]
    [print (word " ticks: " ticks " turtle that switched from car to non-car: " who)]

  set mode_share_car count turtles with [current_car_to_work = 1] / count turtles * 100
  set num_car_turtle count turtles with [current_car_to_work = 1]
  set num_noncar_turtle count turtles with [current_car_to_work = 0]

  print (word " ticks: " ticks " mode_share_car: " mode_share_car
    " num_car_turtle: " num_car_turtle " num_noncar_turtle: " num_noncar_turtle
    " mean_behavior_score: " mean [behavior_2011] of turtles " max_behavior_score: " max [behavior_2011] of turtles
    " mean_diabetes: " mean [diabetes_2022] of turtles)

  tick
end


; ##################################################################
; ###### Procedures to set up turtle properties.
; ##################################################################
to setup_nei_patch
  ask turtles [
    set nei_patch patches in-radius 20 ;; set an agentset of neighbouring patches within radius of 2km.
                                            ;; this is small living zone reachable by walk, bicycle and neighbourhood bus (Oh, 2014).
  ]
end

to setup_nature_patch_cluster
  ask patches with [land_nat_bui_cent_sep2022 = 1] [
    ifelse count patches in-radius 4 with [land_nat_bui_cent_sep2022 = 1] >= 49 ;; if nature patch is at least the size of cluster of 49 patches (full of 400m radius).
    [set nature_patch_cluster 1][set nature_patch_cluster 0] ;; to set meaningful size of nature_patch_cluster
  ]
end

to setup_nature_cluster_in_twokm
  ask turtles [
    ifelse count nei_patch with [nature_patch_cluster = 1] > 0
    [set nature_cluster_in_twokm 1][set nature_cluster_in_twokm 0]
  ]
end

to setup_retail_patch_cluster
  ask patches with [retail_height > 0] [
    ifelse (count patches in-radius 1 with [retail_height > 0] >= 4) or (retail_height >= 18)
    ;; if retail patch is at least the size of cluster of 4 patches in the 100m radius or a patch has at least 18m of retail floor height.
    [set retail_patch_cluster 1][set retail_patch_cluster 0] ;; to set meaningful size of retail_patch_cluster
  ]
end

to setup_retail_cluster_in_twokm
  ask turtles [
    ifelse count nei_patch with [retail_patch_cluster = 1] > 0
    [set retail_cluster_in_twokm 1][set retail_cluster_in_twokm 0]
  ]
end

to setup_office_patch_cluster
  ask patches with [office_height > 0] [
    ifelse (count patches in-radius 1 with [office_height > 0] >= 4) or (office_height >= 18)
    ;; if office patch is at least the size of cluster of 4 patches in the 100m radius or a patch has at least 18m of office floor height.
    [set office_patch_cluster 1][set office_patch_cluster 0] ;; to set meaningful size of office_patch_cluster
  ]
end

to setup_office_cluster_in_twokm
  ask turtles [
    ifelse count nei_patch with [office_patch_cluster = 1] > 0
    [set office_cluster_in_twokm 1][set office_cluster_in_twokm 0]
  ]
end

to setup_nat_ret_off_clusters
  setup_nature_patch_cluster
  setup_nature_cluster_in_twokm
  setup_retail_patch_cluster
  setup_retail_cluster_in_twokm
  setup_office_patch_cluster
  setup_office_cluster_in_twokm
end

to setup_nei_turtle
  ask turtles [
    set nei_turtle turtles in-radius 20 ;; set an agentset of neighbouring turtles within radius of 2km.
                                        ;; this is small living zone reachable by walk, bicycle and neighbourhood bus (Oh, 2014).
  ]
end

to load_gis_data
  set borough_dataset gis:load-dataset "data/17nov2022_borough_100m.asc"
  set land_nat_bui_cent_sep2022_dataset gis:load-dataset "data/17nov2022_nature_built_centrality_100m.asc"
  set resi_height_sep2022_dataset gis:load-dataset "data/17nov2022_resi_height_100m.asc"
  set retail_height_sep2022_dataset gis:load-dataset "data/17nov2022_retail_height_100m.asc"
  set office_height_sep2022_dataset gis:load-dataset "data/17nov2022_office_height_100m.asc"
  set water_bodies_dataset gis:load-dataset "data/17nov2022_water_bodies_100m.asc"
  set citycentre_localcentre_suburb_dataset gis:load-dataset "data/28jun2023_citycentre_localcentre_suburb.asc"
  set multiple_dep_lsoa_2011_dataset gis:load-dataset "data/10feb2023_mul_dep_lsoa_2011.asc"
  set coronary_prevalence_2022_dataset gis:load-dataset "data/16feb2023_2021_22_doctors_surgeries_prevalence_coronary.asc"
  set heart_failure_prevalence_2022_dataset gis:load-dataset "data/16feb2023_2021_22_doctors_surgeries_prevalence_heart_failure.asc"
  set hypertension_prevalence_2022_dataset gis:load-dataset "data/16feb2023_2021_22_doctors_surgeries_prevalence_hypertension.asc"
  set stroke_prevalence_2022_dataset gis:load-dataset "data/16feb2023_2021_22_doctors_surgeries_prevalence_stroke.asc"
  set copd_prevalence_2022_dataset gis:load-dataset "data/16feb2023_2021_22_doctors_surgeries_prevalence_copd.asc"
  set cancer_prevalence_2022_dataset gis:load-dataset "data/16feb2023_2021_22_doctors_surgeries_prevalence_cancer.asc"
  set obesity_prevalence_2022_dataset gis:load-dataset "data/20feb2023_2021_22_doctors_surgeries_prevalence_obesity.asc"
  set diabetes_prevalence_2022_dataset gis:load-dataset "data/16feb2023_2021_22_doctors_surgeries_prevalence_diabetes.asc"
  set depression_prevalence_2022_dataset gis:load-dataset "data/16feb2023_2021_22_doctors_surgeries_prevalence_depression.asc"
  set mental_health_prevalence_2022_dataset gis:load-dataset "data/16feb2023_2021_22_doctors_surgeries_prevalence_mental_health.asc"
  set pm25_2021_dataset gis:load-dataset "data/18aug2023_pm25_1km_grid_gm.asc"
  set pm10_2021_dataset gis:load-dataset "data/18aug2023_pm10_1km_grid_gm.asc"

  ; ;;;;;;;;;;;;;;;;;;;;;;;;;
  ; Applying each of the loaded raster maps onto the world and as patch values
  ; ;;;;;;;;;;;;;;;;;;;;;;;;;
  gis:set-world-envelope gis:envelope-of borough_dataset
  gis:apply-raster borough_dataset borough
  gis:apply-raster land_nat_bui_cent_sep2022_dataset land_nat_bui_cent_sep2022
  gis:apply-raster resi_height_sep2022_dataset resi_height_sep2022
  gis:apply-raster retail_height_sep2022_dataset retail_height_sep2022
  gis:apply-raster office_height_sep2022_dataset office_height_sep2022
  gis:apply-raster water_bodies_dataset water_bodies
  gis:apply-raster citycentre_localcentre_suburb_dataset citycentre_localcentre_suburb
  gis:apply-raster multiple_dep_lsoa_2011_dataset multiple_dep_lsoa_2011
  gis:apply-raster coronary_prevalence_2022_dataset coronary_prevalence_2022
  gis:apply-raster heart_failure_prevalence_2022_dataset heart_failure_prevalence_2022
  gis:apply-raster hypertension_prevalence_2022_dataset hypertension_prevalence_2022
  gis:apply-raster stroke_prevalence_2022_dataset stroke_prevalence_2022
  gis:apply-raster copd_prevalence_2022_dataset copd_prevalence_2022
  gis:apply-raster cancer_prevalence_2022_dataset cancer_prevalence_2022
  gis:apply-raster obesity_prevalence_2022_dataset obesity_prevalence_2022
  gis:apply-raster diabetes_prevalence_2022_dataset diabetes_prevalence_2022
  gis:apply-raster depression_prevalence_2022_dataset depression_prevalence_2022
  gis:apply-raster mental_health_prevalence_2022_dataset mental_health_prevalence_2022
  gis:apply-raster pm25_2021_dataset pm25_2021
  gis:apply-raster pm10_2021_dataset pm10_2021

  ask patches with [resi_height_sep2022 > 0] [set resi_height resi_height_sep2022]
  ask patches with [retail_height_sep2022 > 0] [set retail_height retail_height_sep2022]
  ask patches with [office_height_sep2022 > 0] [set office_height office_height_sep2022]
end

to show_borough
  ask patches [if borough = 1 [set pcolor 1]]
  ask patches [if borough = 2 [set pcolor 2]]
  ask patches [if borough = 3 [set pcolor 3]]
  ask patches [if borough = 4 [set pcolor 4]]
  ask patches [if borough = 5 [set pcolor 5]]
  ask patches [if borough = 6 [set pcolor 6]]
  ask patches [if borough = 7 [set pcolor 7]]
  ask patches [if borough = 8 [set pcolor 8]]
  ask patches [if borough = 9 [set pcolor 9]]
  ask patches [if borough = 10 [set pcolor 9.9]]
end

to show_land_nat_bui_cent_sep2022
  ask patches [if land_nat_bui_cent_sep2022 = 1 [set pcolor 52]]
  ask patches [if land_nat_bui_cent_sep2022 = 2 [set pcolor black]]
  ask patches [if land_nat_bui_cent_sep2022 = 3 [set pcolor white]]
end

to show_resi_height
  ask patches [if resi_height = 0 [set pcolor black]]
  ask patches [if resi_height > 0 and resi_height < 18 [set pcolor grey]]
  ask patches [if resi_height >= 18 [set pcolor white]]
end

to show_retail_height
  ask patches [if retail_height = 0 [set pcolor black]]
  ask patches [if retail_height > 0 and retail_height < 18 [set pcolor grey]]
  ask patches [if retail_height >= 18 [set pcolor white]]
end

to show_office_height
  ask patches [if office_height = 0 [set pcolor black]]
  ask patches [if office_height > 0 and office_height < 18 [set pcolor grey]]
  ask patches [if office_height >= 18 [set pcolor white]]
end

to show_citycentre_localcentre_suburb
  ask patches [if citycentre_localcentre_suburb = 1 [set pcolor white]]
  ask patches [if citycentre_localcentre_suburb = 2 [set pcolor 4]]
  ask patches [if citycentre_localcentre_suburb = 3[set pcolor black]]
  ask patches [if citycentre_localcentre_suburb = 4[set pcolor 52]]
end

to show_multiple_dep_lsoa_2011
  ask patches [if multiple_dep_lsoa_2011 = 0 [set pcolor black]]
  ask patches [if multiple_dep_lsoa_2011 > 0 and multiple_dep_lsoa_2011 < 11.3 [set pcolor 8]]
  ask patches [if multiple_dep_lsoa_2011 >= 11.3 and multiple_dep_lsoa_2011 < 20.9 [set pcolor 6]]
  ask patches [if multiple_dep_lsoa_2011 >= 20.9 and multiple_dep_lsoa_2011 < 32 [set pcolor 4]]
  ask patches [if multiple_dep_lsoa_2011 >= 32 and multiple_dep_lsoa_2011 < 46.4 [set pcolor 2]]
  ask patches [if multiple_dep_lsoa_2011 >= 46.4 [set pcolor black]]
end

to show_mixed_use_diversity
  ask patches [if mixed_use_diversity < 0.002 [set pcolor black]]
  ask patches [if mixed_use_diversity > 0.002 and mixed_use_diversity < 1 [set pcolor grey]]
  ask patches [if mixed_use_diversity >= 1 [set pcolor white]]
end

to show_turtles_by_travel_mode
  ask turtles [ifelse travel_mode_to_work_2011 = 7 or travel_mode_to_work_2011 = 8 [set color blue][set color green]]
end

to show_turtles_by_prox_to_nature
  ask turtles [ifelse nature_cluster_in_twokm = 1 [set color green][set color blue]]
end

to show_turtles_by_prox_to_retail
  ask turtles [ifelse retail_cluster_in_twokm = 1 [set color green][set color blue]]
end

to show_turtles_by_prox_to_office
  ask turtles [ifelse office_cluster_in_twokm = 1 [set color green][set color blue]]
end

to show_turtles_by_mixed_use_twokm_radius
  ask turtles [ifelse mixed_use_twokm_radius >= 0.5 [set color green][set color blue]]
end

to show_turtles_by_prox_to_nat_ret_off
  ask turtles [ifelse nature_cluster_in_twokm = 1 and retail_cluster_in_twokm = 1 and office_cluster_in_twokm = 1 [set color green][set color blue]]
end

to show_turtles_by_deprivation
  ask turtles [ifelse deprived_2011 = 1 [set color green][set color blue]]
end

to show_turtles_by_health_dep
  ask turtles [ifelse deprived_health_2011 = 1 [set color blue][set color green]]
end

to show_turtles_by_social_grade
  ask turtles [ifelse social_grade_2011 = 1 or social_grade_2011 = 2 [set color green][set color blue]]
end

to show_turtles_by_general_health
  ask turtles [ifelse general_health_2011 = 1 [set color green][set color blue]]
end

to show_turtles_by_activity_limited
  ask turtles [ifelse activity_limited_2011 = 1 or activity_limited_2011 = 2 [set color blue][set color green]]
end

to show_turtles_by_work_from_home
  ask turtles [ifelse work_from_home_2011 = 1 [set color green][set color blue]]
end

to show_turtles_by_office_desk_job
  ask turtles [ifelse likely_office_desk_job_2011 = 1 [set color green][set color blue]]
end

; ##################################################################
; ###### Procedures to read resident turtle properties from a file.
; ##################################################################
to read_2011_residents_from_csv
  file-close-all ; close all open files

  if not file-exists? "data/2nov2022_21430_turtles_2011_gmca_input.csv" [
    user-message "No file '2nov2022_21430_turtles_2011_gmca_input.csv' exists!"
    stop
  ]

  file-open "data/10feb2023_21430_turtles_2011_gmca_input.csv" ; open the file with the turtle data

  ; We'll read all the data in a single loop
  while [ not file-at-end? ] [
    ; here the CSV extension grabs a single line and puts the read data in a list
    let data csv:from-row file-read-line
    ; now we can use that list to create a turtle with the saved properties
    create-turtles 1 [
      set xcor     random-xcor
      set ycor     random-ycor
      set size     3
      set shape    "circle"
      set caseno_2011           item 0 data  ;; 0=column A in excel. 1=column B. ... 29=colum AE.
      set id_2011               item 1 data
      set la_group_2011         item 2 data
      set prev_address_2011     item 3 data
      set age_2011              item 4 data
      set distance_work_2011 item 5 data
      set num_car_own_2011       item 6 data
      set country_birth_2011    item 7 data
      set deprived_edu_2011     item 8 data
      set deprived_employ_2011  item 9 data
      set deprived_health_2011  item 10 data
      set deprived_housing_2011  item 11 data
      set deprived_2011         item 12 data
      set activity_limited_2011 item 13 data
      set num_child_2011            item 14 data
      set ethnicity_2011        item 15 data
      set general_health_2011   item 16 data
      set edu_2011              item 17 data
      set patient_in_house_2011 item 18 data
      set likely_office_desk_job_2011    item 19 data
      set occupation_2011       item 20 data
      set landlord_type_2011 item 21 data
      set prev_region_2011      item 22 data
      set social_grade_2011     item 23 data
      set sex_2011              item 24 data
      set tenure_2011           item 25 data
      set color                 item 26 data  ;; 55=green(non-car), 105=blue(car)
      set travel_mode_to_work_2011 item 27 data
      set travel_mode_to_work_2001 item 28 data
      set work_from_home_2011 item 29 data
      set place_of_work_2011 item 30 data
      set live_near_work_2011 item 31 data
      set workplace_2011 item 32 data
    ]
  ]
  ; Randomly locate the residents by their deprivation scores. Five bins created for the 2011 multiple deprivation by LSOA.
      ask turtles with [ la_group_2011 = 182 and deprived_2011 = 0 ] [ move-to one-of patches with
        [ resi_height_sep2022 > 0 and borough = 1 ] ]
      ask turtles with [ la_group_2011 = 182 and deprived_2011 = 1 ] [ move-to one-of patches with
        [ resi_height_sep2022 > 0 and borough = 1 and multiple_dep_lsoa_2011 < 11.317 ] ]
      ask turtles with [ la_group_2011 = 182 and deprived_2011 = 2 ] [ move-to one-of patches with
        [ resi_height_sep2022 > 0 and borough = 1 and multiple_dep_lsoa_2011 >= 11.317 and multiple_dep_lsoa_2011 < 20.889 ] ]
      ask turtles with [ la_group_2011 = 182 and deprived_2011 = 3 ] [ move-to one-of patches with
        [ resi_height_sep2022 > 0 and borough = 1 and multiple_dep_lsoa_2011 >= 20.889 and multiple_dep_lsoa_2011 < 31.995 ] ]
      ask turtles with [ la_group_2011 = 182 and deprived_2011 = 4 ] [ move-to one-of patches with
        [ resi_height_sep2022 > 0 and borough = 1 and multiple_dep_lsoa_2011 >= 31.995 and multiple_dep_lsoa_2011 < 46.350 ] ]
      ask turtles with [ la_group_2011 = 182 and deprived_2011 = 5 ] [ move-to one-of patches with
        [ resi_height_sep2022 > 0 and borough = 1 and multiple_dep_lsoa_2011 >= 46.350 and multiple_dep_lsoa_2011 < 79.300 ] ]

      ask turtles with [ la_group_2011 = 183 and deprived_2011 = 0 ] [ move-to one-of patches with
        [ resi_height_sep2022 > 0 and borough = 2 ] ]
      ask turtles with [ la_group_2011 = 183 and deprived_2011 = 1 ] [ move-to one-of patches with
        [ resi_height_sep2022 > 0 and borough = 2 and multiple_dep_lsoa_2011 < 11.317 ] ]
      ask turtles with [ la_group_2011 = 183 and deprived_2011 = 2 ] [ move-to one-of patches with
        [ resi_height_sep2022 > 0 and borough = 2 and multiple_dep_lsoa_2011 >= 11.317 and multiple_dep_lsoa_2011 < 20.889 ] ]
      ask turtles with [ la_group_2011 = 183 and deprived_2011 = 3 ] [ move-to one-of patches with
        [ resi_height_sep2022 > 0 and borough = 2 and multiple_dep_lsoa_2011 >= 20.889 and multiple_dep_lsoa_2011 < 31.995 ] ]
      ask turtles with [ la_group_2011 = 183 and deprived_2011 = 4 ] [ move-to one-of patches with
        [ resi_height_sep2022 > 0 and borough = 2 and multiple_dep_lsoa_2011 >= 31.995 and multiple_dep_lsoa_2011 < 46.350 ] ]
      ask turtles with [ la_group_2011 = 183 and deprived_2011 = 5 ] [ move-to one-of patches with
        [ resi_height_sep2022 > 0 and borough = 2 and multiple_dep_lsoa_2011 >= 46.350 and multiple_dep_lsoa_2011 < 79.300 ] ]

      ask turtles with [ la_group_2011 = 184 and deprived_2011 = 0 ] [ move-to one-of patches with
        [ resi_height_sep2022 > 0 and borough = 3 ] ]
      ask turtles with [ la_group_2011 = 184 and deprived_2011 = 1 ] [ move-to one-of patches with
        [ resi_height_sep2022 > 0 and borough = 3 and multiple_dep_lsoa_2011 < 11.317 ] ]
      ask turtles with [ la_group_2011 = 184 and deprived_2011 = 2 ] [ move-to one-of patches with
        [ resi_height_sep2022 > 0 and borough = 3 and multiple_dep_lsoa_2011 >= 11.317 and multiple_dep_lsoa_2011 < 20.889 ] ]
      ask turtles with [ la_group_2011 = 184 and deprived_2011 = 3 ] [ move-to one-of patches with
        [ resi_height_sep2022 > 0 and borough = 3 and multiple_dep_lsoa_2011 >= 20.889 and multiple_dep_lsoa_2011 < 31.995 ] ]
      ask turtles with [ la_group_2011 = 184 and deprived_2011 = 4 ] [ move-to one-of patches with
        [ resi_height_sep2022 > 0 and borough = 3 and multiple_dep_lsoa_2011 >= 31.995 and multiple_dep_lsoa_2011 < 46.350 ] ]
      ask turtles with [ la_group_2011 = 184 and deprived_2011 = 5 ] [ move-to one-of patches with
        [ resi_height_sep2022 > 0 and borough = 3 and multiple_dep_lsoa_2011 >= 46.350 and multiple_dep_lsoa_2011 < 79.300 ] ]

      ask turtles with [ la_group_2011 = 185 and deprived_2011 = 0 ] [ move-to one-of patches with
        [ resi_height_sep2022 > 0 and borough = 4 ] ]
      ask turtles with [ la_group_2011 = 185 and deprived_2011 = 1 ] [ move-to one-of patches with
        [ resi_height_sep2022 > 0 and borough = 4 and multiple_dep_lsoa_2011 < 11.317 ] ]
      ask turtles with [ la_group_2011 = 185 and deprived_2011 = 2 ] [ move-to one-of patches with
        [ resi_height_sep2022 > 0 and borough = 4 and multiple_dep_lsoa_2011 >= 11.317 and multiple_dep_lsoa_2011 < 20.889 ] ]
      ask turtles with [ la_group_2011 = 185 and deprived_2011 = 3 ] [ move-to one-of patches with
        [ resi_height_sep2022 > 0 and borough = 4 and multiple_dep_lsoa_2011 >= 20.889 and multiple_dep_lsoa_2011 < 31.995 ] ]
      ask turtles with [ la_group_2011 = 185 and deprived_2011 = 4 ] [ move-to one-of patches with
        [ resi_height_sep2022 > 0 and borough = 4 and multiple_dep_lsoa_2011 >= 31.995 and multiple_dep_lsoa_2011 < 46.350 ] ]
      ask turtles with [ la_group_2011 = 185 and deprived_2011 = 5 ] [ move-to one-of patches with
        [ resi_height_sep2022 > 0 and borough = 4 and multiple_dep_lsoa_2011 >= 46.350 and multiple_dep_lsoa_2011 < 79.300 ] ]

      ask turtles with [ la_group_2011 = 186 and deprived_2011 = 0 ] [ move-to one-of patches with
        [ resi_height_sep2022 > 0 and borough = 5 ] ]
      ask turtles with [ la_group_2011 = 186 and deprived_2011 = 1 ] [ move-to one-of patches with
        [ resi_height_sep2022 > 0 and borough = 5 and multiple_dep_lsoa_2011 < 11.317 ] ]
      ask turtles with [ la_group_2011 = 186 and deprived_2011 = 2 ] [ move-to one-of patches with
        [ resi_height_sep2022 > 0 and borough = 5 and multiple_dep_lsoa_2011 >= 11.317 and multiple_dep_lsoa_2011 < 20.889 ] ]
      ask turtles with [ la_group_2011 = 186 and deprived_2011 = 3 ] [ move-to one-of patches with
        [ resi_height_sep2022 > 0 and borough = 5 and multiple_dep_lsoa_2011 >= 20.889 and multiple_dep_lsoa_2011 < 31.995 ] ]
      ask turtles with [ la_group_2011 = 186 and deprived_2011 = 4 ] [ move-to one-of patches with
        [ resi_height_sep2022 > 0 and borough = 5 and multiple_dep_lsoa_2011 >= 31.995 and multiple_dep_lsoa_2011 < 46.350 ] ]
      ask turtles with [ la_group_2011 = 186 and deprived_2011 = 5 ] [ move-to one-of patches with
        [ resi_height_sep2022 > 0 and borough = 5 and multiple_dep_lsoa_2011 >= 46.350 and multiple_dep_lsoa_2011 < 79.300 ] ]

      ask turtles with [ la_group_2011 = 187 and deprived_2011 = 0 ] [ move-to one-of patches with
        [ resi_height_sep2022 > 0 and borough = 6 ] ]
      ask turtles with [ la_group_2011 = 187 and deprived_2011 = 1 ] [ move-to one-of patches with
        [ resi_height_sep2022 > 0 and borough = 6 and multiple_dep_lsoa_2011 < 11.317 ] ]
      ask turtles with [ la_group_2011 = 187 and deprived_2011 = 2 ] [ move-to one-of patches with
        [ resi_height_sep2022 > 0 and borough = 6 and multiple_dep_lsoa_2011 >= 11.317 and multiple_dep_lsoa_2011 < 20.889 ] ]
      ask turtles with [ la_group_2011 = 187 and deprived_2011 = 3 ] [ move-to one-of patches with
        [ resi_height_sep2022 > 0 and borough = 6 and multiple_dep_lsoa_2011 >= 20.889 and multiple_dep_lsoa_2011 < 31.995 ] ]
      ask turtles with [ la_group_2011 = 187 and deprived_2011 = 4 ] [ move-to one-of patches with
        [ resi_height_sep2022 > 0 and borough = 6 and multiple_dep_lsoa_2011 >= 31.995 and multiple_dep_lsoa_2011 < 46.350 ] ]
      ask turtles with [ la_group_2011 = 187 and deprived_2011 = 5 ] [ move-to one-of patches with
        [ resi_height_sep2022 > 0 and borough = 6 and multiple_dep_lsoa_2011 >= 46.350 and multiple_dep_lsoa_2011 < 79.300 ] ]

      ask turtles with [ la_group_2011 = 188 and deprived_2011 = 0 ] [ move-to one-of patches with
        [ resi_height_sep2022 > 0 and borough = 7 ] ]
      ask turtles with [ la_group_2011 = 188 and deprived_2011 = 1 ] [ move-to one-of patches with
        [ resi_height_sep2022 > 0 and borough = 7 and multiple_dep_lsoa_2011 < 11.317 ] ]
      ask turtles with [ la_group_2011 = 188 and deprived_2011 = 2 ] [ move-to one-of patches with
        [ resi_height_sep2022 > 0 and borough = 7 and multiple_dep_lsoa_2011 >= 11.317 and multiple_dep_lsoa_2011 < 20.889 ] ]
      ask turtles with [ la_group_2011 = 188 and deprived_2011 = 3 ] [ move-to one-of patches with
        [ resi_height_sep2022 > 0 and borough = 7 and multiple_dep_lsoa_2011 >= 20.889 and multiple_dep_lsoa_2011 < 31.995 ] ]
      ask turtles with [ la_group_2011 = 188 and deprived_2011 = 4 ] [ move-to one-of patches with
        [ resi_height_sep2022 > 0 and borough = 7 and multiple_dep_lsoa_2011 >= 31.995 and multiple_dep_lsoa_2011 < 46.350 ] ]
      ask turtles with [ la_group_2011 = 188 and deprived_2011 = 5 ] [ move-to one-of patches with
        [ resi_height_sep2022 > 0 and borough = 7 and multiple_dep_lsoa_2011 >= 46.350 and multiple_dep_lsoa_2011 < 79.300 ] ]

      ask turtles with [ la_group_2011 = 189 and deprived_2011 = 0 ] [ move-to one-of patches with
        [ resi_height_sep2022 > 0 and borough = 8 ] ]
      ask turtles with [ la_group_2011 = 189 and deprived_2011 = 1 ] [ move-to one-of patches with
        [ resi_height_sep2022 > 0 and borough = 8 and multiple_dep_lsoa_2011 < 11.317 ] ]
      ask turtles with [ la_group_2011 = 189 and deprived_2011 = 2 ] [ move-to one-of patches with
        [ resi_height_sep2022 > 0 and borough = 8 and multiple_dep_lsoa_2011 >= 11.317 and multiple_dep_lsoa_2011 < 20.889 ] ]
      ask turtles with [ la_group_2011 = 189 and deprived_2011 = 3 ] [ move-to one-of patches with
        [ resi_height_sep2022 > 0 and borough = 8 and multiple_dep_lsoa_2011 >= 20.889 and multiple_dep_lsoa_2011 < 31.995 ] ]
      ask turtles with [ la_group_2011 = 189 and deprived_2011 = 4 ] [ move-to one-of patches with
        [ resi_height_sep2022 > 0 and borough = 8 and multiple_dep_lsoa_2011 >= 31.995 and multiple_dep_lsoa_2011 < 46.350 ] ]
      ask turtles with [ la_group_2011 = 189 and deprived_2011 = 5 ] [ move-to one-of patches with
        [ resi_height_sep2022 > 0 and borough = 8 and multiple_dep_lsoa_2011 >= 46.350 and multiple_dep_lsoa_2011 < 79.300 ] ]

      ask turtles with [ la_group_2011 = 190 and deprived_2011 = 0 ] [ move-to one-of patches with
        [ resi_height_sep2022 > 0 and borough = 9 ] ]
      ask turtles with [ la_group_2011 = 190 and deprived_2011 = 1 ] [ move-to one-of patches with
        [ resi_height_sep2022 > 0 and borough = 9 and multiple_dep_lsoa_2011 < 11.317 ] ]
      ask turtles with [ la_group_2011 = 190 and deprived_2011 = 2 ] [ move-to one-of patches with
        [ resi_height_sep2022 > 0 and borough = 9 and multiple_dep_lsoa_2011 >= 11.317 and multiple_dep_lsoa_2011 < 20.889 ] ]
      ask turtles with [ la_group_2011 = 190 and deprived_2011 = 3 ] [ move-to one-of patches with
        [ resi_height_sep2022 > 0 and borough = 9 and multiple_dep_lsoa_2011 >= 20.889 and multiple_dep_lsoa_2011 < 31.995 ] ]
      ask turtles with [ la_group_2011 = 190 and deprived_2011 = 4 ] [ move-to one-of patches with
        [ resi_height_sep2022 > 0 and borough = 9 and multiple_dep_lsoa_2011 >= 31.995 and multiple_dep_lsoa_2011 < 46.350 ] ]
      ask turtles with [ la_group_2011 = 190 and deprived_2011 = 5 ] [ move-to one-of patches with
        [ resi_height_sep2022 > 0 and borough = 9 and multiple_dep_lsoa_2011 >= 46.350 and multiple_dep_lsoa_2011 < 79.300 ] ]

      ask turtles with [ la_group_2011 = 191 and deprived_2011 = 0 ] [ move-to one-of patches with
        [ resi_height_sep2022 > 0 and borough = 10 ] ]
      ask turtles with [ la_group_2011 = 191 and deprived_2011 = 1 ] [ move-to one-of patches with
        [ resi_height_sep2022 > 0 and borough = 10 and multiple_dep_lsoa_2011 < 11.317 ] ]
      ask turtles with [ la_group_2011 = 191 and deprived_2011 = 2 ] [ move-to one-of patches with
        [ resi_height_sep2022 > 0 and borough = 10 and multiple_dep_lsoa_2011 >= 11.317 and multiple_dep_lsoa_2011 < 20.889 ] ]
      ask turtles with [ la_group_2011 = 191 and deprived_2011 = 3 ] [ move-to one-of patches with
        [ resi_height_sep2022 > 0 and borough = 10 and multiple_dep_lsoa_2011 >= 20.889 and multiple_dep_lsoa_2011 < 31.995 ] ]
      ask turtles with [ la_group_2011 = 191 and deprived_2011 = 4 ] [ move-to one-of patches with
        [ resi_height_sep2022 > 0 and borough = 10 and multiple_dep_lsoa_2011 >= 31.995 and multiple_dep_lsoa_2011 < 46.350 ] ]
      ask turtles with [ la_group_2011 = 191 and deprived_2011 = 5 ] [ move-to one-of patches with
        [ resi_height_sep2022 > 0 and borough = 10 and multiple_dep_lsoa_2011 >= 46.350 and multiple_dep_lsoa_2011 < 79.300 ] ]

  ; set current travel mode to work
  ask turtles [ifelse travel_mode_to_work_2011 = 7 or travel_mode_to_work_2011 = 8 [set current_car_to_work 1][set current_car_to_work 0]] ;; 0=non-car, 1=car.

  file-close ; make sure to close the file
end

to set_hypoth_pub_tr_prop ;; hypothetical properties of bus/tram/cycle hire
; Initial setting as the middle point. Can increase incrementally over the years via policy scenario.
  ask turtles [set reliability_pc 50] ;; Room for improvement: can input a map of public transport reliability if data is available.
  ask turtles [set freq_connectivity_pc 50]
  ask turtles [set safety_pc 50]
  ask turtles [set affordability_pc 50]
end

to normalise
; pc stands for percent. Translating the initial values of turtle variables from the input data (census and GIS) into percent.
; age_2011 ;; ageh. Age of individual (grouped). 1=0-4, 2=5-9, 3=10-15, 4=16-18, 5=19-24, 6=25-29, 7=30-34, 8=35-39, 9=40-44,
       ;; 10=45-49, 11=50-54, 12=55-59, 13=60-64, 14=65-69, 15=70-74, 16=75-79, 17=80-84, 18=85-89, 19=90+
  ask turtles with [age_2011 = 1][set age_2011_pc random 5]
  ask turtles with [age_2011 = 2][set age_2011_pc random 5 + 5] ; 0,1,2,3,4 -> 5,6,7,8,9
  ask turtles with [age_2011 = 3][set age_2011_pc random 6 + 10]
  ask turtles with [age_2011 = 4][set age_2011_pc random 3 + 16]
  ask turtles with [age_2011 = 5][set age_2011_pc random 6 + 19]
  ask turtles with [age_2011 = 6][set age_2011_pc random 5 + 25]
  ask turtles with [age_2011 = 7][set age_2011_pc random 5 + 30]
  ask turtles with [age_2011 = 8][set age_2011_pc random 5 + 35]
  ask turtles with [age_2011 = 9][set age_2011_pc random 5 + 40]
  ask turtles with [age_2011 = 10][set age_2011_pc random 5 + 45]
  ask turtles with [age_2011 = 11][set age_2011_pc random 5 + 50]
  ask turtles with [age_2011 = 12][set age_2011_pc random 5 + 55]
  ask turtles with [age_2011 = 13][set age_2011_pc random 5 + 60]
  ask turtles with [age_2011 = 14][set age_2011_pc random 5 + 65]
  ask turtles with [age_2011 = 15][set age_2011_pc random 5 + 70]
  ask turtles with [age_2011 = 16][set age_2011_pc random 5 + 75]
  ask turtles with [age_2011 = 17][set age_2011_pc random 5 + 80]
  ask turtles with [age_2011 = 18][set age_2011_pc random 5 + 85]
  ask turtles with [age_2011 = 19][set age_2011_pc random 11 + 90]

; deprived_2011 ;; Household deprivation. 0=no data. 1=not deprived. 2=deprived in 1 dimension, 3=deprived in 2 dimensions,
       ;; 4=deprived in 3 dimensions, 5=deprived in 4 dimensions
  ask turtles with [deprived_2011 = 1][set deprived_2011_pc 0]
  ask turtles with [deprived_2011 = 2][set deprived_2011_pc 25]
  ask turtles with [deprived_2011 = 3][set deprived_2011_pc 50]
  ask turtles with [deprived_2011 = 4][set deprived_2011_pc 75]
  ask turtles with [deprived_2011 = 5][set deprived_2011_pc 100]

; prev_region_2011 ;; moveregion. Region of origin 1 year ago (if moved). 1=migrant from outside UK, 2=North East, 3=North West, 4=Yorkshire and the Humber,
       ;; 5=East Midlands, 6=West Midlands, 7=East of England, 8=South East, 9=South West, 10=Inner London
       ;; 11=Outer London, 12=Scotland, 13=Wales, 14=Northern Ireland
; As a rough proxy of car dependency in each region, 2021 census "cars/van per household" is used
; with a caveat that car ownership does not give information about how often the car gets used.
; https://assets.publishing.service.gov.uk/government/uploads/system/uploads/attachment_data/file/1101073/nts9902.ods
  ask turtles with [prev_region_2011 = 2][set pre_car_2011_pc 1.14 / 1.43] ;; 1.43 is the highest value.
  ask turtles with [prev_region_2011 = 3][set pre_car_2011_pc 1.15 / 1.43]
  ask turtles with [prev_region_2011 = 4][set pre_car_2011_pc 1.15 / 1.43]
  ask turtles with [prev_region_2011 = 5][set pre_car_2011_pc 1.31 / 1.43]
  ask turtles with [prev_region_2011 = 6][set pre_car_2011_pc 1.24 / 1.43]
  ask turtles with [prev_region_2011 = 7][set pre_car_2011_pc 1.41 / 1.43]
  ask turtles with [prev_region_2011 = 8][set pre_car_2011_pc 0.31 / 1.43]
  ask turtles with [prev_region_2011 = 9][set pre_car_2011_pc 1.43 / 1.43]
  ask turtles with [prev_region_2011 = 10][set pre_car_2011_pc 0.77 / 1.43]
  ask turtles with [prev_region_2011 = 11][set pre_car_2011_pc 0.77 / 1.43]
  ask turtles with [prev_region_2011 = 12][set pre_car_2011_pc 1.20 / 1.43]
  ask turtles with [prev_region_2011 = 1 or prev_region_2011 = 12 or prev_region_2011 = 13 or prev_region_2011 = 14]
  [set pre_car_2011_pc 1.21 / 1.43] ;; 1.21 is the average of the above values.

; num_child_2011 ;; dpcfamuk11. Family dependent children.
; 1=no, 2=One dependent child aged 0-9, 3=One dependent child aged 10-18
; 4=Two dependent kids, youngest aged 0-9, 5=Two dependentkids, youngest aged 10-18
; 6=Three or more dependent kids, youngest 0-9, 7=Three or more dependent kids, youngest 10-18
; -9=Not applicable
; Turn into ordinal based on the likely level of responsibility to provide car ride.
  ask turtles with [num_child_2011 = 1][set num_child_2011_pc 0]
  ask turtles with [num_child_2011 = 3][set num_child_2011_pc 50]
  ask turtles with [num_child_2011 = 5][set num_child_2011_pc 60]
  ask turtles with [num_child_2011 = 7][set num_child_2011_pc 70]
  ask turtles with [num_child_2011 = 2][set num_child_2011_pc 80]
  ask turtles with [num_child_2011 = 4][set num_child_2011_pc 90]
  ask turtles with [num_child_2011 = 6][set num_child_2011_pc 100]
  ask turtles with [num_child_2011 = -9][set num_child_2011_pc 0]

; general_health_2011 ;; health. General health. 1=very good, 2=good, 3=fair, 4=bad, 5=very bad
  ask turtles with [general_health_2011 = 5][set general_health_2011_pc 0]
  ask turtles with [general_health_2011 = 4][set general_health_2011_pc 25]
  ask turtles with [general_health_2011 = 3][set general_health_2011_pc 50]
  ask turtles with [general_health_2011 = 2][set general_health_2011_pc 75]
  ask turtles with [general_health_2011 = 1][set general_health_2011_pc 100]

; activity_limited_2011 ;; disability. Long-term health problem. Day-to-day activities 1=limited a lot, 2=limited a little, 3=not limited
  ask turtles with [activity_limited_2011 = 3][set activity_limited_2011_pc 0]
  ask turtles with [activity_limited_2011 = 2][set activity_limited_2011_pc 50]
  ask turtles with [activity_limited_2011 = 1][set activity_limited_2011_pc 100]

; patient_in_house_2011 ;; illhuk11g. ilIndividuals in household with long-standing illness/disability. 0=no, 1=1, 2=2+.
  ask turtles with [patient_in_house_2011 = 0][set patient_in_house_2011_pc 0]
  ask turtles with [patient_in_house_2011 = 1][set patient_in_house_2011_pc 50]
  ask turtles with [patient_in_house_2011 = 2][set patient_in_house_2011_pc 100]

; distance_work_2011 ;; aggdtwpew11g. Distance travelled to work. 1=less than 2km, 2=2 to <5km, 3=5 to <10km, 4=10 to <20km,
       ;; 5=20 to <40km, 6=40 to <60km, 7=60km+, 8=at home, 9=no fixed place, 10=work outwide England but within UK
       ;; 11=Work outside UK, 12=Works at offshore installation (within UK)
       ;; Implication for car use is complicated therefore deal as categorical.

; num_car_own_2011 ;; carsnoc. No. of cars and vans. 1=1, 2=2, 3=3, 4=4 or more
  ask turtles with [num_car_own_2011 = 1][set num_car_own_2011_pc 0]
  ask turtles with [num_car_own_2011 = 2][set num_car_own_2011_pc 25]
  ask turtles with [num_car_own_2011 = 3][set num_car_own_2011_pc 50]
  ask turtles with [num_car_own_2011 = 4][set num_car_own_2011_pc 100]

; likely_office_desk_job_2011 ;; iscog 11-14=Managers; 24-25=Business/admin/ICT professionals; 33=Business/admin associate professionals
       ;; 35=Info and communication technicians; 41-44=Clerks
       ;; https://en.wikipedia.org/wiki/International_Standard_Classification_of_Occupations
  ask turtles [ifelse likely_office_desk_job_2011 = 11 or likely_office_desk_job_2011 = 12
    or likely_office_desk_job_2011 = 13 or likely_office_desk_job_2011 = 14
    or likely_office_desk_job_2011 = 24 or likely_office_desk_job_2011 = 25
    or likely_office_desk_job_2011 = 33 or likely_office_desk_job_2011 = 35
    or likely_office_desk_job_2011 = 41 or likely_office_desk_job_2011 = 42
    or likely_office_desk_job_2011 = 43 or likely_office_desk_job_2011 = 44
    [set likely_office_desk_job_2011_pc random 51 + 50] ;; generate a random number between 0 and 50 and shift the range to be between 50 and 100.
    [set likely_office_desk_job_2011_pc random 51] ;; if not one of the iscog jobs specified, generate a random number between 0 and 50.
  ]

end

; ##################################################################
; ###### Procedures to randomly distribute disease prevalence to turtles.
; ##################################################################
to set_resident_disease_prevalence
  ask turtles [
    set p_disease_age random-float age_2011_pc
    set p_disease_general_health random-float (100 - general_health_2011_pc)
    set p_disease_health_activity_limited random-float activity_limited_2011_pc
  ;; health deprivation variable not included because it is already covered by general health and health activity limited.
    set p_disease_with_age (p_disease_age + p_disease_general_health + p_disease_health_activity_limited) / 3
    set p_disease_without_age (p_disease_age + p_disease_general_health + p_disease_health_activity_limited) / 2
  ]

  ask max-n-of (count turtles * 0.2) turtles [p_disease_with_age][ ;; In 2011, count turtles * 0.2 = 4,286.
    if random-float 100 < ([coronary_prevalence_2022] of patch-here * 5)
    [set coronary_2022 1]] ;; 1 for yes.
  ;; if that patch's coronary heart disease prevalence is 3%, then the turtle has 3% chance of getting coronary heart disease.

  ask max-n-of (count turtles * 0.2) turtles [p_disease_with_age][
    if random-float 100 < ([heart_failure_prevalence_2022] of patch-here * 5)
    [set heart_failure_2022 1]] ;; 1 for yes.

  ask max-n-of (count turtles * 0.2) turtles [p_disease_with_age][
    if random-float 100 < ([hypertension_prevalence_2022] of patch-here * 5)
    [set hypertension_2022 1]] ;; 1 for yes.

  ask max-n-of (count turtles * 0.2) turtles [p_disease_with_age][
    if random-float 100 < ([stroke_prevalence_2022] of patch-here * 5)
    [set stroke_2022 1]] ;; 1 for yes.

  ask max-n-of (count turtles * 0.2) turtles [p_disease_with_age][
    if random-float 100 < ([copd_prevalence_2022] of patch-here * 5)
    [set copd_2022 1]] ;; 1 for yes.

  ask max-n-of (count turtles * 0.2) turtles [p_disease_with_age][
    if random-float 100 < ([cancer_prevalence_2022] of patch-here * 5)
    [set cancer_2022 1]] ;; 1 for yes.

  ask max-n-of (count turtles * 0.2) turtles [p_disease_without_age][
    if random-float 100 < ([obesity_prevalence_2022] of patch-here * 5)
    [set obesity_2022 1]] ;; 1 for yes.

  ask max-n-of (count turtles * 0.2) turtles [p_disease_with_age][
    if random-float 100 < ([diabetes_prevalence_2022] of patch-here)
    [set diabetes_2022 1]] ;; 1 for yes.

  ask max-n-of (count turtles * 0.2) turtles [p_disease_without_age][
    if random-float 100 < ([depression_prevalence_2022] of patch-here * 5)
    [set depression_2022 1]] ;; 1 for yes.

  ask max-n-of (count turtles * 0.2) turtles [p_disease_without_age][
    if random-float 100 < ([mental_health_prevalence_2022] of patch-here * 5)
    [set mental_health_2022 1]] ;; 1 for yes.
end

; ##################################################################
; ###### Procedures for land/building use change.
; ##################################################################
to calculate_building_height
  ask patches [
    set building_height (resi_height + retail_height + office_height)
  ]
end

to calculate_mixed_use_diversity
  ask patches with [resi_height > 0 or retail_height > 0 or office_height > 0] [
    set proportion_resi resi_height / (resi_height + retail_height + office_height)
    set proportion_retail retail_height / (resi_height + retail_height + office_height)
    set proportion_office office_height / (resi_height + retail_height + office_height)
  ]
;  ask patches with [resi_height > 0 or retail_height > 0 or office_height > 0 and proportion_resi = 0] [set proportion_resi 0.0001]
;  ask patches with [resi_height > 0 or retail_height > 0 or office_height > 0 and proportion_retail = 0] [set proportion_retail 0.0001]
;  ask patches with [resi_height > 0 or retail_height > 0 or office_height > 0 and proportion_office = 0] [set proportion_office 0.0001]
  ;pseudocount to make logarithm calculation possible for the Shannon's Diversity Index.

;  ask patches with [resi_height > 0 or retail_height > 0 or office_height > 0] [
;    set mixed_use_diversity (-(proportion_resi * ln proportion_resi
;    + proportion_retail * ln proportion_retail
;    + proportion_office * ln proportion_office))
;  ]

;  ask patches with [resi_height > 0 or retail_height > 0 or office_height > 0] [
;    set mixed_use_diversity mixed_use_diversity / 1.0986122886681096 ;; max [mixed_use_diversity] of patches
;  ]
end

to calculate_density_twokm_radius
  ask turtles [
    set density_twokm_radius mean [building_height] of nei_patch
  ]
  let max_density_twokm_radius max [density_twokm_radius] of turtles
  ask turtles [
    set density_twokm_radius density_twokm_radius / max_density_twokm_radius
    ;; Normalise. This model is not an urban growth model
    ;; therefore, no need to leave room for max density value becoming higher from further urban development.
    set density_twokm_radius_pc density_twokm_radius * 100
  ]
end

to calculate_proximity_twokm_radius
  ask turtles [
    if nature_cluster_in_twokm = 1 and retail_cluster_in_twokm = 1 and office_cluster_in_twokm = 1 [set proximity_twokm_radius 1]
    if nature_cluster_in_twokm != 1 and retail_cluster_in_twokm = 1 and office_cluster_in_twokm = 1 [set proximity_twokm_radius 0.5]
    if nature_cluster_in_twokm = 1 and retail_cluster_in_twokm != 1 and office_cluster_in_twokm = 1 [set proximity_twokm_radius 0.5]
    if nature_cluster_in_twokm = 1 and retail_cluster_in_twokm = 1 and office_cluster_in_twokm != 1 [set proximity_twokm_radius 0.5]
    if nature_cluster_in_twokm = 1 and retail_cluster_in_twokm != 1 and office_cluster_in_twokm != 1 [set proximity_twokm_radius 0.25]
    if nature_cluster_in_twokm != 1 and retail_cluster_in_twokm = 1 and office_cluster_in_twokm != 1 [set proximity_twokm_radius 0.25]
    if nature_cluster_in_twokm != 1 and retail_cluster_in_twokm != 1 and office_cluster_in_twokm = 1 [set proximity_twokm_radius 0.25]
    set proximity_twokm_radius_pc proximity_twokm_radius * 100
  ]
end

to calculate_pm10_twokm_radius
  ask turtles [
    set pm10_twokm_radius mean [pm10_2021] of nei_patch
  ]
  let max_pm10_twokm_radius max [pm10_twokm_radius] of turtles
  ask turtles [
    set pm10_twokm_radius pm10_twokm_radius / max_pm10_twokm_radius
    ;; Normalise. This model does not model the air quality worsening over time
    ;; therefore, no need to leave room for max pm10 value becoming higher from further pollution.
    set pm10_twokm_radius_pc pm10_twokm_radius * 100
  ]
end

to calculate_mixed_use_twokm_radius
  ; sum [resi_height_sep2022] of patches = 63245
  ; sum [retail_height_sep2022] of patches = 12904
  ; sum [office_height_sep2022] of patches = 7311
  ; Total = 83460 therefore resi takes up 75.78%, retail 15.46% and 8.76% of the use as of Sep2022.

;; For level of mixed_use: Shannon's diversity index (SHDI) = -sum(Pi * InPi),
;; where Pi = proportion of area occupied by patches of type i.
;; mixed_use_twokm_radius =
  ;; - (proportion_resi_twokm_radius * ln proportion_resi_twokm_radius
  ;; + proportion_retail_twokm_radius * ln proportion_retail_twokm_radius
  ;; + proportion_office_twokm_radius * ln proportion_office_twokm_radius)
;; The maximum value of the mixed_use is 50. Therefore, we multiply this by 2 to normalise the values between 0 and 100.

  ask turtles [
   let total_resi_twokm_radius sum [resi_height] of nei_patch with [resi_height > 0]
   let total_retail_twokm_radius sum [retail_height] of nei_patch with [retail_height > 0]
   let total_office_twokm_radius sum [office_height] of nei_patch with [office_height > 0]

   set proportion_resi_twokm_radius total_resi_twokm_radius / (total_resi_twokm_radius + total_retail_twokm_radius + total_office_twokm_radius)
   set proportion_retail_twokm_radius total_retail_twokm_radius / (total_resi_twokm_radius + total_retail_twokm_radius + total_office_twokm_radius)
   set proportion_office_twokm_radius total_office_twokm_radius / (total_resi_twokm_radius + total_retail_twokm_radius + total_office_twokm_radius)
  ]

  ask turtles with [proportion_resi_twokm_radius = 0] [set proportion_resi_twokm_radius 0.0001]
  ask turtles with [proportion_retail_twokm_radius = 0] [set proportion_retail_twokm_radius 0.0001]
  ask turtles with [proportion_office_twokm_radius = 0] [set proportion_office_twokm_radius 0.0001]
  ;pseudocount to make logarithm calculation possible for the Shannon's Diversity Index.

  ask turtles [
   set mixed_use_twokm_radius (-(proportion_resi_twokm_radius * ln proportion_resi_twokm_radius
   + proportion_retail_twokm_radius * ln proportion_retail_twokm_radius
      + proportion_office_twokm_radius * ln proportion_office_twokm_radius))
  ]

  ask turtles [
    set mixed_use_twokm_radius mixed_use_twokm_radius / 1.5 ;; max [mixed_use_twokm_radius] of turtles = 1.0973623681103433 as of the 2011 census data.
    ;; Divide by 1.50 to give room for this value to increase.

  set mixed_use_twokm_radius_pc mixed_use_twokm_radius * 100
  ]
end

; ##################################################################
; ###### Procedures for car to non-car mode switch.
; ##################################################################
to switch_travel_mode
;; Attitude (TPB)
  print "running switch_travel_mode for attitude (personal)..."
  ask turtles with [current_car_to_work = 1][ ;; will take longer but can ask all turtles for the sake of calculating these values for current non-car users as well.
    set p_age_2011 random (100 - age_2011_pc) ;; higher the age, lower the likelihood to switch from car to non-car.
    set p_deprived_2011 random deprived_2011_pc
    set p_pre_car_2011 random (100 - pre_car_2011_pc)
    set p_reliability random reliability_pc
    set p_freq_connectivity random freq_connectivity_pc
    set safety random safety_pc
  ]

  print "running switch_travel_mode for subjective norm (social)..."
  ask turtles with [current_car_to_work = 1][
    set nei_non_car count nei_turtle with [current_car_to_work = 0] / count nei_turtle
    set p_nei_non_car random nei_non_car
  ]

  print "running switch_travel_mode for perceived behavioural control (contextual)_1/4..."
  ask turtles with [current_car_to_work = 1][
    set p_num_child_2011 random (100 - num_child_2011_pc)
    set p_general_health_2011 random general_health_2011_pc
    set p_activity_limited_2011 random (100 - activity_limited_2011_pc)
    set p_patient_in_house_2011 random (100 - patient_in_house_2011_pc)
  ]

  print "running switch_travel_mode for perceived behavioural control (contextual)_2/4..."
;; distance_work_2011 ;; aggdtwpew11g. Distance travelled to work. 1=less than 2km, 2=2 to <5km, 3=5 to <10km, 4=10 to <20km,
    ;; 5=20 to <40km, 6=40 to <60km, 7=60km+, 8=at home, 9=no fixed place, 10=work outside England but within UK
    ;; 11=Work outside UK, 12=Works at offshore installation (within UK)
  ask turtles with [current_car_to_work = 1][
    if distance_work_2011 = 8 or distance_work_2011 = 1 [set p_distance_work_2011 random 100] ;; can switch from car to non-car (walk/cycle/bus)
    if distance_work_2011 = 2 [set p_distance_work_2011 random 100 * 0.75] ;; can switch from car to non-car (cycle/bus)
    if distance_work_2011 = 3 or distance_work_2011 = 4 or distance_work_2011 = 5 or distance_work_2011 = 6 or distance_work_2011 = 7
      [set p_distance_work_2011 random 100 * 0.5] ;; can switch from car to non-car (bus)
    if distance_work_2011 = 9 or distance_work_2011 = 10 or distance_work_2011 = 11 or distance_work_2011 = 12
      [set p_distance_work_2011 random 100 * 0.25] ;; more uncommon cases. more difficult to switch.

    set p_num_car_own_2011 random (100 - num_car_own_2011_pc)

    if work_from_home_2011 = 1 [set p_likely_work_from_home 100] ;; if work from home = yes from the census, then 100.
    if work_from_home_2011 = 0 [set p_likely_work_from_home random likely_office_desk_job_2011_pc];; if not work from home from the census, set the likelihood based on likely_office_desk_job
  ]

  print "applying the impact of commute_3days_a_week or commute_3days_a_week_with_policy..."
  if (ticks >= 2 and ticks <= 12) and wfh_scenario = "commute_3days_a_week" or wfh_scenario = "commute_3days_a_week_with_policy" [
  ask turtles with [current_car_to_work = 1][
      set p_likely_work_from_home p_likely_work_from_home * 3 ;; more work from home would inherently increase the swich of main mode of work transport to work to non-car.
      ask turtles with [p_likely_work_from_home > 100] [set p_likely_work_from_home 100]
      set distance_work_2011 1 ;; the effect to be reflected in the next tick
    ]
  ]
  if (ticks >= 2 and ticks <= 12) and wfh_scenario = "commute_5days_a_week" or wfh_scenario = "commute_3days_a_week_with_policy" [
  ask turtles with [current_car_to_work = 1][
      set p_likely_work_from_home p_likely_work_from_home * 5
      ask turtles with [p_likely_work_from_home > 100] [set p_likely_work_from_home 100]
      set distance_work_2011 1 ;; the effect to be reflected in the next tick
    ]
  ]

  print "running switch_travel_mode for perceived behavioural control (contextual)_3/4..."
  ask turtles with [current_car_to_work = 1 and deprived_2011_pc = 0] [set p_affordability random-float affordability * 0.5]
  ask turtles with [current_car_to_work = 1 and deprived_2011_pc > 0] [set p_affordability random-float affordability]

  ask turtles with [current_car_to_work = 1][
    set p_density_twokm_radius random density_twokm_radius_pc
    set p_proximity_twokm_radius random proximity_twokm_radius_pc
    set p_mixed_use_twokm_radius random mixed_use_twokm_radius_pc
    set p_pm10_twokm_radius random (100 - pm10_twokm_radius_pc)
  ]

  print "applying the impact of commute_3days_a_week_with_policy..."
  ask turtles with [current_car_to_work = 1][
  if (ticks >= 2 and ticks <= 12) and wfh_scenario = "commute_3days_a_week_with_policy" [
      set reliability_pc reliability_pc + 5
      ask turtles with [reliability_pc > 100] [set reliability_pc 100]
      set freq_connectivity_pc freq_connectivity_pc + 5
      ask turtles with [freq_connectivity_pc > 100] [set freq_connectivity_pc 100]
      set safety_pc safety_pc + 5
      ask turtles with [safety_pc > 100] [set safety_pc 100]
      set affordability_pc affordability_pc + 5
      ask turtles with [affordability_pc > 100] [set affordability_pc 100]
    ]
  ]
;; Give the weight of 1 for the variables mentioned at the stakeholder consultation as especially important,
;; 0.75 as moderately important and 0.5 as less important.
  print "running switch_travel_mode for perceived behavioural control (contextual)_4/4..."
  ask turtles with [current_car_to_work = 1][

  set attitude_2011 (p_age_2011 * 0.5 + p_deprived_2011 + p_pre_car_2011 * 0.75 + p_reliability
  + p_freq_connectivity + p_safety) / (0.5 + 1 + 0.75 + 1 + 1 + 1) / 100

    set sn_2011 p_nei_non_car * 0.75 / 100

    set pbc_2011 (p_num_child_2011 + p_general_health_2011 + p_activity_limited_2011
        + p_patient_in_house_2011 * 0.75 + p_distance_work_2011 + p_num_car_own_2011 * 0.5
        + p_likely_work_from_home + p_affordability + p_density_twokm_radius * 0.75
        + p_proximity_twokm_radius * 0.75 + p_mixed_use_twokm_radius * 0.75
        + p_pm10_twokm_radius * 0.5) / (1 + 1 + 1 + 0.75 + 1 + 0.5 + 1 + 1 + 0.75 + 0.75 + 0.75 + 0.5) / 100

    set behavior_2011 0.26 * attitude_2011 + 0.22 * sn_2011 + 0.32 * pbc_2011 - 0.05 * pbc_2011
    if behavior_2011 > 0.203 [set current_car_to_work 0 set color green
        set diabetes_2022 diabetes_2022 * (1 - 0.11)
    ]
  ]
end

; ##################################################################
; ###### Procedures to run work from home scenarios.
; ##################################################################

to commute_5days_a_week_bau
;; Business as usual. Stays the same.
end

to commute_3days_a_week
;; Once every year for 10 years.
;; Land/building use change
;; 1. In city/borough centres, decrease office/retail by 5% and replace with resi.
  print "running commute_3days_a_week for land/building use change..."
  let num_patches_office_citycentre count patches with [office_height > 0 and citycentre_localcentre_suburb = 1]
  ask n-of (num_patches_office_citycentre * 0.05) patches with [office_height > 0 and citycentre_localcentre_suburb = 1][
    set resi_height resi_height + office_height
    set office_height 0
  ]
  let num_patches_retail_citycentre count patches with [retail_height > 0 and citycentre_localcentre_suburb = 1]
  ask n-of (num_patches_retail_citycentre * 0.05) patches with [retail_height > 0 and citycentre_localcentre_suburb = 1][
    set resi_height resi_height + retail_height
    set retail_height 0
  ]

;; 2. In non-deprived local centres, decrease resi by 5% and replace with office/retail
  let num_patches_resi_localcentre_nondep count patches with [resi_height > 0 and citycentre_localcentre_suburb = 2 and multiple_dep_lsoa_2011 >= 31.995]
  ask n-of (num_patches_resi_localcentre_nondep * 0.05) patches with [resi_height > 0 and citycentre_localcentre_suburb = 2 and multiple_dep_lsoa_2011 >= 31.995][
    set office_height office_height + resi_height
    set retail_height retail_height + resi_height
    set resi_height 0
  ]

  print "running commute_3days_a_week for population movement 1/2..."
;; Population movement
;; 1. Move 5% of non-deprived residents aged 30+ in city/borough centres and local centres move to suburban neighbourhoods.
  let num_turtles_nondep_citycentre_30plus count (turtles-on patches with [citycentre_localcentre_suburb = 1 or citycentre_localcentre_suburb = 2]) with [deprived_2011 = 1 and age_2011_pc > 30]

  ask n-of (num_turtles_nondep_citycentre_30plus * 0.05) (turtles-on patches with [citycentre_localcentre_suburb = 1 or citycentre_localcentre_suburb = 2]) with [deprived_2011 = 1 and age_2011_pc > 30]
  [ move-to one-of patches with [citycentre_localcentre_suburb = 3 and resi_height > 0 or retail_height > 0 or office_height > 0]
  ]

  print "running commute_3days_a_week for population movement 2/2..."
;; 2. Move 5% of non-deprived residents aged 18-30 in local centres and suburbs move to city/borough centre.
  let num_turtles_nondep_localcentre_18_30 count (turtles-on patches with [citycentre_localcentre_suburb = 2 or citycentre_localcentre_suburb = 3]) with [deprived_2011 = 1 and age_2011_pc >= 18 and age_2011_pc <= 30]

  ask n-of (num_turtles_nondep_localcentre_18_30 * 0.05) (turtles-on patches with [citycentre_localcentre_suburb = 2 or citycentre_localcentre_suburb = 3]) with [deprived_2011 = 1 and age_2011_pc >= 18 and age_2011_pc <= 30]
  [ move-to one-of patches with [citycentre_localcentre_suburb = 1 and resi_height > 0 or retail_height > 0 or office_height > 0]
  ]
end

to commute_1day_a_week_or_less
;; Double the effect of 3days_a_week
commute_3days_a_week
commute_3days_a_week
end

to commute_3days_a_week_with_policy ;; hypothetical. to be developed further.
commute_3days_a_week
end

; ##################################################################
; ###### Procedures to link active travel with health benefits.
; ##################################################################

to active_travel_to_ncd_benefit


  ;; just give the benefit to the switched residents once. In reality it will take time for a person to get this benefit.
  ;; But this model is at a population-level. We're looking at the cohort of car-users and non-car users.

end

; ##################################################################
; ###### Procedures to export the map to asc file.
; ##################################################################
to export_data_current_map
    file-close
    file-delete "result.asc"
    file-open "result.asc"
    file-print "ncols         545"
    file-print "nrows         400"
    file-print "xllcorner     351654.4300"
    file-print "yllcorner     381122.6986"
    file-print  "cellsize      100"
    file-print  "NODATA_value  -99999"

    let pri 399
    while [pri > -1]
    [ set the-row []
      set the-row patches with [pycor = pri]
      if count the-row = 545 [
      foreach sort-on [pxcor] the-row [ z -> ask z  [file-write resi_height_sep2022] ]
      wait 0.001
      file-print "   "
      set pri (pri - 1)]
      wait 0.001
     ]
    file-print " "
    wait 1
    file-close
end
@#$#@#$#@
GRAPHICS-WINDOW
211
10
982
579
-1
-1
1.4
1
10
1
1
1
0
1
1
1
0
544
0
399
0
0
1
ticks
30.0

BUTTON
11
187
186
220
NIL
show_borough
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
10
99
65
132
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
69
99
124
132
NIL
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
128
99
183
132
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
11
150
186
183
NIL
show_land_nat_bui_cent_sep2022
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
997
11
1197
161
mode_share_car (%)
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot count turtles with [current_car_to_work = 1] / count turtles * 100"

PLOT
997
187
1157
307
density_dep
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot mean [density_twokm_radius] of turtles with [deprived_2011 > 1] * 100"

PLOT
1162
187
1322
307
proximity_dep
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot mean [proximity_twokm_radius] of turtles with [deprived_2011 > 1] * 100"

PLOT
1327
187
1487
307
mixed_use_dep
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot mean [mixed_use_twokm_radius] of turtles with [deprived_2011 > 1] * 100"

BUTTON
11
224
186
257
NIL
show_resi_height
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
12
448
187
481
hide-turtle
ask turtles [hide-turtle]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
11
335
186
368
show_citycent_localcent_suburb
show_citycentre_localcentre_suburb
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
10
61
184
94
random_seed
random_seed
0
100
0.0
1
1
NIL
HORIZONTAL

MONITOR
1206
11
1322
56
mode_share_car (%)
count turtles with [current_car_to_work = 1] / count turtles * 100
2
1
11

BUTTON
11
261
186
294
NIL
show_retail_height
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
11
298
186
331
NIL
show_office_height
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
11
585
128
618
travel mode
show_turtles_by_travel_mode
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
11
621
128
654
proximity_to_nature
show_turtles_by_prox_to_nature
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
132
585
250
618
proximity_to_retail
show_turtles_by_prox_to_retail
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
132
621
250
654
proximity_to_office
show_turtles_by_prox_to_office
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
389
621
507
654
social_grade
show_turtles_by_social_grade
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
511
621
629
654
general_health
show_turtles_by_general_health
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
633
585
750
618
activity_limited
show_turtles_by_activity_limited
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
753
585
870
618
work_from_home
show_turtles_by_work_from_home
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
511
585
629
618
health_deprivation
show_turtles_by_health_dep
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
753
621
870
654
office_desk_job
show_turtles_by_office_desk_job
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
12
485
186
518
show-turtle
ask turtles [show-turtle]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
1161
458
1321
503
coronary_heart_disease
(count turtles with [ coronary_2022 = 1 ] / count turtles) * 100
3
1
11

MONITOR
1161
507
1321
552
heart_failure
(count turtles with [ heart_failure_2022 = 1 ] / count turtles) * 100
3
1
11

MONITOR
1161
556
1321
601
hypertension
(count turtles with [ hypertension_2022 = 1 ] / count turtles) * 100
3
1
11

MONITOR
1161
605
1322
650
stroke
(count turtles with [ stroke_2022 = 1 ] / count turtles) * 100
3
1
11

TEXTBOX
999
441
1251
459
Non-communicable Disease Prevalence in 2022 (%)
11
0.0
1

MONITOR
1161
655
1322
700
chro_obst_pulm_dis (COPD)
(count turtles with [ copd_2022 = 1 ] / count turtles) * 100
3
1
11

MONITOR
1327
458
1484
503
cancer
(count turtles with [ cancer_2022 = 1 ] / count turtles) * 100
3
1
11

MONITOR
1326
508
1484
553
obesity
(count turtles with [ obesity_2022 = 1 ] / count turtles) * 100
3
1
11

MONITOR
1326
556
1484
601
depression
(count turtles with [ depression_2022 = 1 ] / count turtles) * 100
3
1
11

MONITOR
1326
605
1484
650
mental_health_issues
(count turtles with [ mental_health_2022 = 1 ] / count turtles) * 100
3
1
11

MONITOR
997
507
1157
552
diabetes_deprived
(count turtles with [ diabetes_2022 = 1 and deprived_2011 != 1 ] / count turtles with [ deprived_2011 != 1 ]) * 100
3
1
11

MONITOR
997
458
1157
503
diabetes
(count turtles with [ diabetes_2022 = 1 ] / count turtles) * 100
3
1
11

MONITOR
997
556
1157
601
diabetes_non-deprived
(count turtles with [ diabetes_2022 = 1 and deprived_2011 = 1 ] / count turtles with [ deprived_2011 = 1 ]) * 100
3
1
11

TEXTBOX
14
538
164
580
Show turtles by:\n- green = yes/positive\n- blue = no/negative
11
0.0
1

BUTTON
254
585
384
618
proximity_to_nat_ret_off
show_turtles_by_prox_to_nat_ret_off
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
389
585
507
618
deprivation
show_turtles_by_deprivation
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
11
372
186
405
show_mul_dep_losa_2011
show_multiple_dep_lsoa_2011
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
11
409
187
442
NIL
show_mixed_use_diversity
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
873
585
963
618
mixed_use
show_turtles_by_mixed_use_twokm_radius
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
998
169
1500
197
20-minute Neighbourhood variables (%). Average of the turtle variables (for patches within 2km radius)
11
0.0
1

CHOOSER
10
10
186
55
wfh_scenario
wfh_scenario
"commute_5days_a_week_bau" "commute_3days_a_week" "commute_1day_a_week_or_less" "commute_3days_a_week_with_policy"
3

PLOT
997
311
1157
431
density_non_dep
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot mean [density_twokm_radius] of turtles with [deprived_2011 = 1] * 100"

PLOT
1162
312
1322
432
priximity_non_dep
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot mean [proximity_twokm_radius] of turtles with [deprived_2011 = 1] * 100"

PLOT
1327
312
1487
432
mixed_use_non_dep
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot mean [mixed_use_twokm_radius] of turtles with [deprived_2011 = 1] * 100"

PLOT
1502
187
1662
307
office_h_citycentre
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot sum [office_height] of patches with [citycentre_localcentre_suburb = 1]"

PLOT
1502
312
1662
432
office_h_localcentre
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot sum [office_height] of patches with [citycentre_localcentre_suburb = 2]"

PLOT
1676
312
1836
432
turtles_cc_nd_30+
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot count (turtles-on patches with [citycentre_localcentre_suburb = 1]) with [deprived_2011 = 1 and age_2011_pc > 30]"

PLOT
1676
187
1836
307
turtles_cc_nd_18_30
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot count (turtles-on patches with [citycentre_localcentre_suburb = 1]) with [deprived_2011 = 1 and age_2011_pc >= 18 and age_2011_pc <= 30]"

PLOT
1502
458
1662
578
diabetes_dep
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot (count turtles with [ diabetes_2022 = 1 and deprived_2011 != 1 ] / count turtles with [ deprived_2011 != 1 ]) * 100"

PLOT
1675
459
1835
579
diabetes_non_dep
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot (count turtles with [ diabetes_2022 = 1 and deprived_2011 = 1 ] / count turtles with [ deprived_2011 = 1 ]) * 100"

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.2.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
