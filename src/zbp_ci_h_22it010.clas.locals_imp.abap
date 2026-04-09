CLASS lhc_LogHdr DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION IMPORTING keys REQUEST requested_authorizations FOR LogHdr RESULT result.
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION IMPORTING REQUEST requested_authorizations FOR LogHdr RESULT result.
    METHODS create FOR MODIFY IMPORTING entities FOR CREATE LogHdr.
    METHODS update FOR MODIFY IMPORTING entities FOR UPDATE LogHdr.
    METHODS delete FOR MODIFY IMPORTING keys FOR DELETE LogHdr.
    METHODS read FOR READ IMPORTING keys FOR READ LogHdr RESULT result.
    METHODS lock FOR LOCK IMPORTING keys FOR LOCK LogHdr.
    METHODS rba_Logitem FOR READ IMPORTING keys_rba FOR READ LogHdr\_LogItem FULL result_requested RESULT result LINK association_links.
    METHODS cba_Logitem FOR MODIFY IMPORTING entities_cba FOR CREATE LogHdr\_LogItem.
    METHODS markasapproved
  FOR MODIFY
  IMPORTING keys
  FOR ACTION LogHdr~markAsApproved
  RESULT result.

ENDCLASS.

CLASS lhc_LogHdr IMPLEMENTATION.
  METHOD get_instance_authorizations. ENDMETHOD.
  METHOD get_global_authorizations. ENDMETHOD.
  METHOD lock. ENDMETHOD.

*  METHOD create.
*    DATA(lo_util) = zcl_util_22it010=>get_instance( ).
*    LOOP AT entities INTO DATA(ls_ent).
*      DATA(ls_db) = CORRESPONDING zcit_hdr_22it010( ls_ent MAPPING FROM ENTITY ).
*      lo_util->set_hdr( ls_db ).
*      APPEND VALUE #( %cid = ls_ent-%cid LogId = ls_ent-LogId ) TO mapped-loghdr.
*    ENDLOOP.
*  ENDMETHOD.

METHOD create.
    DATA(lo_util) = zcl_util_22it010=>get_instance( ).
    LOOP AT entities INTO DATA(ls_ent).
      DATA(ls_db) = CORRESPONDING zcit_hdr_22it010( ls_ent MAPPING FROM ENTITY ).

      " 1. Set Default Status
      IF ls_db-status IS INITIAL.
        ls_db-status = 'Pending'.
      ENDIF.

      " 2. Set Default Remarks
      IF ls_db-remarks IS INITIAL.
        ls_db-remarks = 'Awaiting for approval'.
      ENDIF.

      lo_util->set_hdr( ls_db ).
      APPEND VALUE #( %cid = ls_ent-%cid LogId = ls_ent-LogId ) TO mapped-loghdr.
    ENDLOOP.
  ENDMETHOD.
*
*  METHOD update.
*    DATA(lo_util) = zcl_util_22it010=>get_instance( ).
*    LOOP AT entities INTO DATA(ls_ent).
*      DATA(ls_db) = CORRESPONDING zcit_hdr_22it010( ls_ent MAPPING FROM ENTITY ).
*      lo_util->set_hdr( ls_db ).
*    ENDLOOP.
*  ENDMETHOD.

METHOD update.
    DATA(lo_util) = zcl_util_22it010=>get_instance( ).
    DATA ls_db TYPE zcit_hdr_22it010.

    LOOP AT entities INTO DATA(ls_ent).
      " 1. ALWAYS read the key from %tky, not the data fields!
      SELECT SINGLE * FROM zcit_hdr_22it010 WHERE log_id = @ls_ent-%tky-LogId INTO @ls_db.

      " 2. Guarantee the key is never lost
      ls_db-log_id = ls_ent-%tky-LogId.

      " 3. Update ONLY the fields that were actually changed
      IF ls_ent-%control-DisposalDate = if_abap_behv=>mk-on. ls_db-disposal_date = ls_ent-DisposalDate. ENDIF.
      IF ls_ent-%control-Location = if_abap_behv=>mk-on.     ls_db-location      = ls_ent-Location. ENDIF.
      IF ls_ent-%control-Department = if_abap_behv=>mk-on.   ls_db-department    = ls_ent-Department. ENDIF.
      IF ls_ent-%control-DisposalType = if_abap_behv=>mk-on. ls_db-disposal_type = ls_ent-DisposalType. ENDIF.
      IF ls_ent-%control-Vendor = if_abap_behv=>mk-on.       ls_db-vendor        = ls_ent-Vendor. ENDIF.
      IF ls_ent-%control-TotalQty = if_abap_behv=>mk-on.     ls_db-total_qty     = ls_ent-TotalQty. ENDIF.
      IF ls_ent-%control-Unit = if_abap_behv=>mk-on.         ls_db-unit          = ls_ent-Unit. ENDIF.
      IF ls_ent-%control-Status = if_abap_behv=>mk-on.       ls_db-status        = ls_ent-Status. ENDIF.
      IF ls_ent-%control-Remarks = if_abap_behv=>mk-on.      ls_db-remarks       = ls_ent-Remarks. ENDIF.

      " 4. Push to save buffer
      lo_util->set_hdr( ls_db ).
    ENDLOOP.
  ENDMETHOD.

  METHOD delete.
    DATA(lo_util) = zcl_util_22it010=>get_instance( ).
    LOOP AT keys INTO DATA(ls_key).
      lo_util->set_del_hdr( VALUE #( log_id = ls_key-LogId ) ).
    ENDLOOP.
  ENDMETHOD.



  METHOD cba_Logitem.
    DATA(lo_util) = zcl_util_22it010=>get_instance( ).
    LOOP AT entities_cba INTO DATA(ls_cba).
      LOOP AT ls_cba-%target INTO DATA(ls_target).
        DATA(ls_db) = CORRESPONDING zcit_itm_22it010( ls_target MAPPING FROM ENTITY ).
        ls_db-log_id = ls_cba-LogId.
        lo_util->set_itm( ls_db ).
        APPEND VALUE #( %cid = ls_target-%cid LogId = ls_cba-LogId WasteId = ls_target-WasteId ) TO mapped-logitm.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.
METHOD read.
    " Read active Header data from the database
    IF keys IS NOT INITIAL.
      SELECT * FROM zcit_hdr_22it010 FOR ALL ENTRIES IN @keys
        WHERE log_id = @keys-LogId
        INTO TABLE @DATA(lt_db).

      LOOP AT keys INTO DATA(ls_key).
        READ TABLE lt_db INTO DATA(ls_db) WITH KEY log_id = ls_key-LogId.
        IF sy-subrc = 0.
          " CRITICAL FIX: We must explicitly pass back the exact %tky requested
          APPEND VALUE #(
            %tky = ls_key-%tky
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
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD rba_Logitem.
    " Fetch Items associated with the Header
    LOOP AT keys_rba INTO DATA(ls_key).
      SELECT * FROM zcit_itm_22it010 WHERE log_id = @ls_key-LogId INTO TABLE @DATA(lt_db).

      LOOP AT lt_db INTO DATA(ls_db).
        " CRITICAL FIX: Match the %is_draft state perfectly
        APPEND VALUE #( source-%tky = ls_key-%tky
                        target-%is_draft = ls_key-%is_draft
                        target-LogId = ls_db-log_id
                        target-WasteId = ls_db-waste_id ) TO association_links.

        IF result_requested = abap_true.
          APPEND VALUE #(
            %is_draft = ls_key-%is_draft
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
    ENDLOOP.
  ENDMETHOD.

*  METHOD markAsApproved.
*    " 1. Update the record safely using EML (Handles both Draft and Active perfectly)
*    MODIFY ENTITIES OF ZCIT_I_H_22IT010 IN LOCAL MODE
*      ENTITY LogHdr
*        UPDATE FIELDS ( Status )
*        WITH VALUE #( FOR key IN keys ( %tky = key-%tky Status = 'Approved' ) ).
*
*    " 2. Read the updated record back via EML
*    READ ENTITIES OF ZCIT_I_H_22IT010 IN LOCAL MODE
*      ENTITY LogHdr
*        ALL FIELDS WITH CORRESPONDING #( keys )
*      RESULT DATA(lt_hdr).
*
*    " 3. Return the exact $self result to the UI so it turns Blue immediately!
*    result = VALUE #( FOR ls_hdr IN lt_hdr (
*      %tky   = ls_hdr-%tky
*      %param = ls_hdr
*    ) ).
*  ENDMETHOD.

METHOD markAsApproved.
    " 1. Update the record safely using EML
    MODIFY ENTITIES OF ZCIT_I_H_22IT010 IN LOCAL MODE
      ENTITY LogHdr
        UPDATE FIELDS ( Status )
        WITH VALUE #( FOR key IN keys (
          %tky = key-%tky
          LogId = key-LogId
          Status = 'Approved'
        ) ).

    " 2. Read the updated record back via EML
    READ ENTITIES OF ZCIT_I_H_22IT010 IN LOCAL MODE
      ENTITY LogHdr
        ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_hdr).

    " 3. Return the exact $self result to the UI so it turns Blue immediately!
    result = VALUE #( FOR ls_hdr IN lt_hdr (
      %tky   = ls_hdr-%tky
      %param = ls_hdr
    ) ).
  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZCIT_I_H_22IT010 DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS finalize REDEFINITION.
    METHODS check_before_save REDEFINITION.
    METHODS save REDEFINITION.
    METHODS cleanup REDEFINITION.
    METHODS cleanup_finalize REDEFINITION.
ENDCLASS.

CLASS lsc_ZCIT_I_H_22IT010 IMPLEMENTATION.
  METHOD finalize. ENDMETHOD.
  METHOD check_before_save. ENDMETHOD.
  METHOD cleanup_finalize. ENDMETHOD.

  METHOD save.
    DATA(lo_util) = zcl_util_22it010=>get_instance( ).
    lo_util->get_hdr( IMPORTING ex_hdr = DATA(lt_hdr) ).
    lo_util->get_itm( IMPORTING ex_itm = DATA(lt_itm) ).
    lo_util->get_del_hdr( IMPORTING ex_docs = DATA(lt_del_hdr) ).
    lo_util->get_del_itm( IMPORTING ex_items = DATA(lt_del_itm) ).

    IF lt_hdr IS NOT INITIAL. MODIFY zcit_hdr_22it010 FROM TABLE @lt_hdr. ENDIF.
    IF lt_itm IS NOT INITIAL. MODIFY zcit_itm_22it010 FROM TABLE @lt_itm. ENDIF.

    LOOP AT lt_del_hdr INTO DATA(ls_del).
      DELETE FROM zcit_hdr_22it010 WHERE log_id = @ls_del-log_id.
      DELETE FROM zcit_itm_22it010 WHERE log_id = @ls_del-log_id.
    ENDLOOP.

    LOOP AT lt_del_itm INTO DATA(ls_del_itm).
      DELETE FROM zcit_itm_22it010 WHERE log_id = @ls_del_itm-log_id AND waste_id = @ls_del_itm-waste_id.
    ENDLOOP.
  ENDMETHOD.

  METHOD cleanup.
    zcl_util_22it010=>get_instance( )->cleanup( ).
  ENDMETHOD.
ENDCLASS.
