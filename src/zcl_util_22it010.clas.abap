CLASS zcl_util_22it010 DEFINITION PUBLIC FINAL CREATE PRIVATE.
PUBLIC SECTION.
    TYPES: tt_hdr TYPE STANDARD TABLE OF zcit_hdr_22it010,
           tt_itm TYPE STANDARD TABLE OF zcit_itm_22it010,

           BEGIN OF ty_del_hdr,
             log_id TYPE zcit_hdr_22it010-log_id,
           END OF ty_del_hdr,

           BEGIN OF ty_del_itm,
             log_id   TYPE zcit_itm_22it010-log_id,
             waste_id TYPE zcit_itm_22it010-waste_id,
           END OF ty_del_itm,

           tt_del_hdr TYPE STANDARD TABLE OF ty_del_hdr,
           tt_del_itm TYPE STANDARD TABLE OF ty_del_itm.

    CLASS-METHODS get_instance RETURNING VALUE(ro_instance) TYPE REF TO zcl_util_22it010.

    METHODS: set_hdr IMPORTING im_hdr TYPE zcit_hdr_22it010,
             get_hdr EXPORTING ex_hdr TYPE tt_hdr,
             set_itm IMPORTING im_itm TYPE zcit_itm_22it010,
             get_itm EXPORTING ex_itm TYPE tt_itm,
             set_del_hdr IMPORTING im_doc TYPE ty_del_hdr,
             get_del_hdr EXPORTING ex_docs TYPE tt_del_hdr,
             set_del_itm IMPORTING im_itm TYPE ty_del_itm,
             get_del_itm EXPORTING ex_items TYPE tt_del_itm,
             cleanup.

  PRIVATE SECTION.
    CLASS-DATA mo_instance TYPE REF TO zcl_util_22it010.
    DATA: gt_hdr TYPE tt_hdr,
          gt_itm TYPE tt_itm,
          gt_del_hdr TYPE tt_del_hdr,
          gt_del_itm TYPE tt_del_itm.
ENDCLASS.

CLASS zcl_util_22it010 IMPLEMENTATION.
  METHOD get_instance.
    IF mo_instance IS INITIAL. CREATE OBJECT mo_instance. ENDIF.
    ro_instance = mo_instance.
  ENDMETHOD.
  METHOD set_hdr. APPEND im_hdr TO gt_hdr. ENDMETHOD.
  METHOD get_hdr. ex_hdr = gt_hdr. ENDMETHOD.
  METHOD set_itm. APPEND im_itm TO gt_itm. ENDMETHOD.
  METHOD get_itm. ex_itm = gt_itm. ENDMETHOD.
  METHOD set_del_hdr. APPEND im_doc TO gt_del_hdr. ENDMETHOD.
  METHOD get_del_hdr. ex_docs = gt_del_hdr. ENDMETHOD.
  METHOD set_del_itm. APPEND im_itm TO gt_del_itm. ENDMETHOD.
  METHOD get_del_itm. ex_items = gt_del_itm. ENDMETHOD.
  METHOD cleanup. CLEAR: gt_hdr, gt_itm, gt_del_hdr, gt_del_itm. ENDMETHOD.
ENDCLASS.
