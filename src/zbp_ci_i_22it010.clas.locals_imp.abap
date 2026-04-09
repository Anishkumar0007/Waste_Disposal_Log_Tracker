CLASS lhc_LogItm DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS update FOR MODIFY IMPORTING entities FOR UPDATE LogItm.
    METHODS delete FOR MODIFY IMPORTING keys FOR DELETE LogItm.
    METHODS read FOR READ IMPORTING keys FOR READ LogItm RESULT result.
    METHODS rba_Logheader FOR READ IMPORTING keys_rba FOR READ LogItm\_LogHeader FULL result_requested RESULT result LINK association_links.
    METHODS calculateCost FOR DETERMINE ON MODIFY
      IMPORTING keys FOR LogItm~calculateCost.
*    METHODS calculateValues FOR DETERMINE ON MODIFY
*      IMPORTING keys FOR LogItm~calculateValues.
ENDCLASS.

CLASS lhc_LogItm IMPLEMENTATION.
*  METHOD update.
*    DATA(lo_util) = zcl_util_22it010=>get_instance( ).
*    LOOP AT entities INTO DATA(ls_ent).
*      DATA(ls_db) = CORRESPONDING zcit_itm_22it010( ls_ent MAPPING FROM ENTITY ).
*      lo_util->set_itm( ls_db ).
*    ENDLOOP.
*  ENDMETHOD.

METHOD update.
    DATA(lo_util) = zcl_util_22it010=>get_instance( ).
    DATA ls_db TYPE zcit_itm_22it010.

    LOOP AT entities INTO DATA(ls_ent).
      " 1. ALWAYS read keys from %tky
      SELECT SINGLE * FROM zcit_itm_22it010
        WHERE log_id = @ls_ent-%tky-LogId AND waste_id = @ls_ent-%tky-WasteId
        INTO @ls_db.

      " 2. Guarantee the keys are never lost
      ls_db-log_id   = ls_ent-%tky-LogId.
      ls_db-waste_id = ls_ent-%tky-WasteId.

      " 3. Update ONLY the fields that were actually changed
      IF ls_ent-%control-WasteType = if_abap_behv=>mk-on.      ls_db-waste_type      = ls_ent-WasteType. ENDIF.
      IF ls_ent-%control-Category = if_abap_behv=>mk-on.       ls_db-category        = ls_ent-Category. ENDIF.
      IF ls_ent-%control-Quantity = if_abap_behv=>mk-on.       ls_db-quantity        = ls_ent-Quantity. ENDIF.
      IF ls_ent-%control-Unit = if_abap_behv=>mk-on.           ls_db-unit            = ls_ent-Unit. ENDIF.
      IF ls_ent-%control-DisposalMethod = if_abap_behv=>mk-on. ls_db-disposal_method = ls_ent-DisposalMethod. ENDIF.
      IF ls_ent-%control-Cost = if_abap_behv=>mk-on.           ls_db-cost            = ls_ent-Cost. ENDIF.
      IF ls_ent-%control-Currency = if_abap_behv=>mk-on.       ls_db-currency        = ls_ent-Currency. ENDIF.
      IF ls_ent-%control-VendorName = if_abap_behv=>mk-on.     ls_db-vendor_name     = ls_ent-VendorName. ENDIF.
      IF ls_ent-%control-Remarks = if_abap_behv=>mk-on.        ls_db-remarks         = ls_ent-Remarks. ENDIF.

      " 4. Push to save buffer
      lo_util->set_itm( ls_db ).
    ENDLOOP.
  ENDMETHOD.

  METHOD delete.
    DATA(lo_util) = zcl_util_22it010=>get_instance( ).
    LOOP AT keys INTO DATA(ls_key).
      lo_util->set_del_itm( VALUE #( log_id = ls_key-LogId waste_id = ls_key-WasteId ) ).
    ENDLOOP.
  ENDMETHOD.

*  METHOD read.
*    " Read active Item data from the database
*    IF keys IS NOT INITIAL.
*      SELECT * FROM zcit_itm_22it010 FOR ALL ENTRIES IN @keys
*        WHERE log_id = @keys-LogId AND waste_id = @keys-WasteId
*        INTO TABLE @DATA(lt_items).
*
*      result = CORRESPONDING #( lt_items MAPPING TO ENTITY ).
*    ENDIF.
*  ENDMETHOD.
*
*  METHOD rba_Logheader.
*    " Fetch Header associated with the Item
*    LOOP AT keys_rba INTO DATA(ls_key).
*      SELECT SINGLE * FROM zcit_hdr_22it010
*        WHERE log_id = @ls_key-LogId
*        INTO @DATA(ls_db).
*
*      IF sy-subrc = 0.
*        APPEND VALUE #( source-%tky = ls_key-%tky target-LogId = ls_db-log_id ) TO association_links.
*
*        IF result_requested = abap_true.
*          APPEND CORRESPONDING #( ls_db MAPPING TO ENTITY ) TO result.
*        ENDIF.
*      ENDIF.
*    ENDLOOP.
*  ENDMETHOD.


METHOD read.
    " Read active Item data from the database
    IF keys IS NOT INITIAL.
      SELECT * FROM zcit_itm_22it010 FOR ALL ENTRIES IN @keys
        WHERE log_id = @keys-LogId AND waste_id = @keys-WasteId
        INTO TABLE @DATA(lt_db).

      LOOP AT keys INTO DATA(ls_key).
        READ TABLE lt_db INTO DATA(ls_db) WITH KEY log_id = ls_key-LogId waste_id = ls_key-WasteId.
        IF sy-subrc = 0.
          APPEND VALUE #(
            %tky = ls_key-%tky
            LogId = ls_db-log_id
            WasteId = ls_db-waste_id
            WasteType = ls_db-waste_type
            Category = ls_db-category
            Quantity = ls_db-quantity
            Unit = ls_db-unit
            DisposalMethod = ls_db-disposal_method
            Cost = ls_db-cost
            Currency = ls_db-currency
            VendorName = ls_db-vendor_name
            Remarks = ls_db-remarks
            LocalLastChangedAt = ls_db-local_last_changed_at
          ) TO result.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD rba_Logheader.
    " Fetch Header associated with the Item
    LOOP AT keys_rba INTO DATA(ls_key).
      SELECT SINGLE * FROM zcit_hdr_22it010 WHERE log_id = @ls_key-LogId INTO @DATA(ls_db).

      IF sy-subrc = 0.
        APPEND VALUE #( source-%tky = ls_key-%tky
                        target-%is_draft = ls_key-%is_draft
                        target-LogId = ls_db-log_id ) TO association_links.

        IF result_requested = abap_true.
          APPEND VALUE #(
            %is_draft = ls_key-%is_draft
            LogId = ls_db-log_id
            DisposalDate = ls_db-disposal_date
            Location = ls_db-location
            Department = ls_db-department
            DisposalType = ls_db-disposal_type
            Vendor = ls_db-vendor
            TotalQty = ls_db-total_qty
            Unit = ls_db-unit
            Status = ls_db-status
            Remarks = ls_db-remarks
            LocalCreatedAt = ls_db-local_created_at
            LocalCreatedBy = ls_db-local_created_by
            LocalLastChangedAt = ls_db-local_last_changed_at
            LocalLastChangedBy = ls_db-local_last_changed_by
          ) TO result.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD calculateCost.
    " 1. Read the current items that were modified
    READ ENTITIES OF ZCIT_I_H_22IT010 IN LOCAL MODE
      ENTITY LogItm
      FIELDS ( Quantity WasteType ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_items).

    DATA lt_update TYPE TABLE FOR UPDATE ZCIT_I_H_22IT010\\LogItm.

    " 2. Calculate the Cost
    LOOP AT lt_items INTO DATA(ls_item).
      DATA(lv_rate) = 0.

      CASE ls_item-WasteType.
        WHEN 'Plastic'.  lv_rate = 1500.
        WHEN 'Metal'.    lv_rate = 500.
        WHEN 'Chemical'. lv_rate = 1000.
        WHEN 'Organic'.  lv_rate = 500.
        WHEN OTHERS.     lv_rate = 700. " Default for General waste
      ENDCASE.

      " 3. Prepare the update table
      APPEND VALUE #( %tky = ls_item-%tky
                      Cost = ls_item-Quantity * lv_rate
                      %control-Cost = if_abap_behv=>mk-on ) TO lt_update.
    ENDLOOP.

    " 4. Modify the buffer with the new Cost
    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF ZCIT_I_H_22IT010 IN LOCAL MODE
        ENTITY LogItm
        UPDATE FIELDS ( Cost ) WITH lt_update
        REPORTED DATA(lt_reported).
    ENDIF.
  ENDMETHOD.

*
*  METHOD calculateValues.
*    " 1. Read the modified items
*    READ ENTITIES OF ZCIT_I_H_22IT010 IN LOCAL MODE
*      ENTITY LogItm
*      FIELDS ( Quantity WasteType LogId ) WITH CORRESPONDING #( keys )
*      RESULT DATA(lt_items).
*
*    DATA lt_item_update TYPE TABLE FOR UPDATE ZCIT_I_H_22IT010\\LogItm.
*    DATA lt_hdr_update  TYPE TABLE FOR UPDATE ZCIT_I_H_22IT010\\LogHdr.
*
*    LOOP AT lt_items INTO DATA(ls_item).
*      " 2. Calculate Item Cost
*      DATA(lv_rate) = 0.
*      CASE ls_item-WasteType.
*        WHEN 'Plastic'.  lv_rate = 1500.
*        WHEN 'Metal'.    lv_rate = 500.
*        WHEN 'Chemical'. lv_rate = 1000.
*        WHEN 'Organic'.  lv_rate = 500.
*        WHEN OTHERS.     lv_rate = 700.
*      ENDCASE.
*
*      APPEND VALUE #( %tky = ls_item-%tky
*                      Cost = ls_item-Quantity * lv_rate
*                      %control-Cost = if_abap_behv=>mk-on ) TO lt_item_update.
*
*      " 3. Calculate Header Total Quantity
*      " Read all items for this specific Log ID to get the total sum
*      READ ENTITIES OF ZCIT_I_H_22IT010 IN LOCAL MODE
*        ENTITY LogHdr BY \_LogItem
*        FIELDS ( Quantity ) WITH VALUE #( ( %tky-LogId = ls_item-LogId ) )
*        RESULT DATA(lt_all_items).
*
*      DATA(lv_total_qty) = 0.
*      LOOP AT lt_all_items INTO DATA(ls_all).
*        lv_total_qty = lv_total_qty + ls_all-Quantity.
*      ENDLOOP.
*
*      " Add the updated sum to the Header update table
*      APPEND VALUE #( LogId = ls_item-LogId
*                      TotalQty = lv_total_qty
*                      %control-TotalQty = if_abap_behv=>mk-on ) TO lt_hdr_update.
*    ENDLOOP.
*
*    " 4. Apply Updates to Buffer
*    IF lt_item_update IS NOT INITIAL.
*      MODIFY ENTITIES OF ZCIT_I_H_22IT010 IN LOCAL MODE
*        ENTITY LogItm UPDATE FIELDS ( Cost ) WITH lt_item_update.
*    ENDIF.
*
*    IF lt_hdr_update IS NOT INITIAL.
*      " Remove duplicates in case multiple items belong to the same header
*      SORT lt_hdr_update BY LogId.
*      DELETE ADJACENT DUPLICATES FROM lt_hdr_update COMPARING LogId.
*
*      MODIFY ENTITIES OF ZCIT_I_H_22IT010 IN LOCAL MODE
*        ENTITY LogHdr UPDATE FIELDS ( TotalQty ) WITH lt_hdr_update.
*    ENDIF.
*
*  ENDMETHOD.
ENDCLASS.
