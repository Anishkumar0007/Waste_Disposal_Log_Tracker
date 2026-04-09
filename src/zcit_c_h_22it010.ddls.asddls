@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Header Consumption View'
@Metadata.allowExtensions: true
@Search.searchable: true
define root view entity ZCIT_C_H_22IT010
  provider contract transactional_query
  as projection on ZCIT_I_H_22IT010
{
  @Search.defaultSearchElement: true
  key LogId,
  DisposalDate,
  Location,
  Department,
    @Consumption.valueHelpDefinition: [{ entity: { name: 'ZCIT_VH_DTYP_22IT010', element: 'DisposalType' } }]
  DisposalType,
  Vendor,
  TotalQty,
  Unit,

  Status,
  
  StatusCriticality,
  Remarks,
  LocalCreatedBy,
  LocalCreatedAt,
  LocalLastChangedBy,
  LocalLastChangedAt,
  
  _LogItem : redirected to composition child ZCIT_C_I_22IT010
}
