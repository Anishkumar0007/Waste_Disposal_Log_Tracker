@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Item Consumption View'
@Metadata.allowExtensions: true
define view entity ZCIT_C_I_22IT010
  as projection on ZCIT_I_I_22IT010
{
  key LogId,
  key WasteId,
    @Consumption.valueHelpDefinition: [{ entity: { name: 'ZCIT_VH_WTYP_22IT010', element: 'WasteType' } }]
  WasteType,
  Category,
  Quantity,
  Unit,
   @Consumption.valueHelpDefinition: [{ entity: { name: 'ZCIT_VH_METH_22IT010', element: 'DisposalMethod' } }]
  DisposalMethod,
  
  Cost,
  Currency,
  VendorName,
  Remarks,
  LocalCreatedBy,
  LocalCreatedAt,
  LocalLastChangedBy,
  LocalLastChangedAt,
  
  


 
  _LogHeader : redirected to parent ZCIT_C_H_22IT010
}
