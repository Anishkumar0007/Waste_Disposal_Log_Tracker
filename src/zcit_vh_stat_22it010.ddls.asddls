@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Status Dropdown'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.resultSet.sizeCategory: #XS
define view entity ZCIT_VH_STAT_22IT010 as 
  select from I_Language { key cast('Pending' as abap.char(15)) as Status } where Language = 'E'
  union all select from I_Language { key cast('Approved' as abap.char(15)) as Status } where Language = 'E'
  union all select from I_Language { key cast('Completed' as abap.char(15)) as Status } where Language = 'E'
