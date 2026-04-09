@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Header Interface View'
define root view entity ZCIT_I_H_22IT010
  as select from zcit_hdr_22it010 as LogHeader
  composition [0..*] of ZCIT_I_I_22IT010 as _LogItem
{
  key log_id as LogId,
  disposal_date as DisposalDate,
  location as Location,
  department as Department,
  disposal_type as DisposalType,
  vendor as Vendor,
  @Semantics.quantity.unitOfMeasure: 'Unit'
  total_qty as TotalQty,
  unit as Unit,
 status as Status,
  case status
    when 'Pending' then 1
    when 'Approved' then 5
    when 'Completed' then 3
    else 0
  end as StatusCriticality,
  remarks as Remarks,
  
  @Semantics.user.createdBy: true
  local_created_by as LocalCreatedBy,
  @Semantics.systemDateTime.createdAt: true
  local_created_at as LocalCreatedAt,
  @Semantics.user.lastChangedBy: true
  local_last_changed_by as LocalLastChangedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed_at as LocalLastChangedAt,
  
  _LogItem
}
