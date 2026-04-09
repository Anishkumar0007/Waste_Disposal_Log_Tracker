@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Disposal Type Dropdown'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.resultSet.sizeCategory: #XS
define view entity ZCIT_VH_DTYP_22IT010 as 
  select from I_Language { key cast('Recyclable' as abap.char(20)) as DisposalType } where Language = 'E'
  union all select from I_Language { key cast('Hazardous' as abap.char(20)) as DisposalType } where Language = 'E'
  union all select from I_Language { key cast('General' as abap.char(20)) as DisposalType } where Language = 'E'
