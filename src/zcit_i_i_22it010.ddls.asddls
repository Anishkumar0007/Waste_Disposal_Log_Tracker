@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Item Interface View'
define view entity ZCIT_I_I_22IT010
  as select from zcit_itm_22it010 as LogItem
  association to parent ZCIT_I_H_22IT010 as _LogHeader 
    on $projection.LogId = _LogHeader.LogId
{
  key log_id as LogId,
  key waste_id as WasteId,
  waste_type as WasteType,
  category as Category,
  @Semantics.quantity.unitOfMeasure: 'Unit'
  quantity as Quantity,
  unit as Unit,
  disposal_method as DisposalMethod,
  @Semantics.amount.currencyCode: 'Currency'
  cost as Cost,
  currency as Currency,
  vendor_name as VendorName,
  remarks as Remarks,

  local_created_by as LocalCreatedBy,
  local_created_at as LocalCreatedAt,
  local_last_changed_by as LocalLastChangedBy,
  local_last_changed_at as LocalLastChangedAt,
  
  _LogHeader
}
