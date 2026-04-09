@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Disposal Method Dropdown'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.resultSet.sizeCategory: #XS
define view entity ZCIT_VH_METH_22IT010 as 
  select from I_Language { key cast('Recycle' as abap.char(20)) as DisposalMethod } where Language = 'E'
  union all select from I_Language { key cast('Incineration' as abap.char(20)) as DisposalMethod } where Language = 'E'
  union all select from I_Language { key cast('Landfill' as abap.char(20)) as DisposalMethod } where Language = 'E'
