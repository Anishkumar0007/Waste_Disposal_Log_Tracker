@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Waste Type Dropdown'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.resultSet.sizeCategory: #XS
define view entity ZCIT_VH_WTYP_22IT010 as 
  select from I_Language { key cast('Plastic' as abap.char(20)) as WasteType } where Language = 'E'
  union all select from I_Language { key cast('Metal' as abap.char(20)) as WasteType } where Language = 'E'
  union all select from I_Language { key cast('Chemical' as abap.char(20)) as WasteType } where Language = 'E'
  union all select from I_Language { key cast('Organic' as abap.char(20)) as WasteType } where Language = 'E'
