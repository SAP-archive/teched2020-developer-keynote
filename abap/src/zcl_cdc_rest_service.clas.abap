CLASS zcl_cdc_rest_service DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_http_service_extension .
  PROTECTED SECTION.
  PRIVATE SECTION.
    METHODS: get_customer_name IMPORTING im_custid         TYPE zcstdoncredits-custid
                               RETURNING VALUE(r_custname) TYPE zcstdoncredits-custname.
  ENDCLASS.


CLASS zcl_cdc_rest_service IMPLEMENTATION.


  METHOD if_http_service_extension~handle_request.

* Expected payload
*
*{
*    "data": {
*        "data": {
*            "specversion": "1.0",
*            "type": "z.internal.charityfund.increased.v1",
*            "datacontenttype": "application/json",
*            "id": "4c8f6699-f08f-4a3b-8fd6-0b4f26687091",
*            "time": "2020-10-02T13:51:30.888Z",
*            "source": "/default/cap.brain/1",
*            "data": {
*                "custid": "USCU-CUS10",
*                "custname": "Customer Name",
*                "credits": 2.2749999999999995,
*                "salesorg": "1720"
*            }
*        }
*    }
*}

    TYPES: ts_custdata TYPE zcstdoncredits.
    TYPES: tt_custdata TYPE STANDARD TABLE OF ts_custdata WITH DEFAULT KEY.
    TYPES: BEGIN OF ts_custdata_node,
             data TYPE ts_custdata,
           END OF ts_custdata_node.
    TYPES: BEGIN OF ts_data_node,
             specversion     TYPE string,
             type            TYPE string,
             datacontenttype TYPE string,
             id              TYPE string,
             source          TYPE string,
             data            TYPE ts_custdata,
           END OF ts_data_node.
    TYPES: BEGIN OF ts_payload_data,
             data TYPE ts_data_node,
           END OF ts_payload_data.
    TYPES: BEGIN OF ts_payload,
             data TYPE ts_payload_data,
           END OF ts_payload.

    DATA: ls_payload TYPE ts_payload.
    DATA: lt_zcstdoncredits TYPE TABLE OF zcstdoncredits.

    DATA(lv_method) =  request->get_method( ) .

    CASE lv_method.
      WHEN 'GET'.

        DATA(lt_params) = request->get_form_fields(  ).
        READ TABLE lt_params REFERENCE INTO DATA(lr_params) WITH KEY name = 'custid'.
        IF sy-subrc = 0.
          SELECT *  FROM zcstdoncredits
                             WHERE custid = @lr_params->value
                                       INTO TABLE @lt_zcstdoncredits.
        ELSE.
          SELECT *  FROM zcstdoncredits
                                 INTO TABLE @lt_zcstdoncredits.
        ENDIF.
        response->set_status( i_code = 200 i_reason = 'Ok').
        response->set_text( /ui2/cl_json=>serialize(
                            EXPORTING
                                 data = lt_zcstdoncredits
                                 pretty_name = /ui2/cl_json=>pretty_mode-low_case ) ).

      WHEN 'OPTIONS'.

        response->set_header_field(
          EXPORTING
            i_name  = 'WebHook-Allowed-Origin'
            i_value = '*' " request->get_header_field( 'WebHook-Allowed-Origin' )
            ).
        response->set_status( i_code = 200 i_reason = 'Ok').

      WHEN 'POST'.

* Convert payload json to abap structures
        /ui2/cl_json=>deserialize( EXPORTING json = request->get_text(  )
                                             pretty_name = /ui2/cl_json=>pretty_mode-low_case
                                    CHANGING data = ls_payload ).

* if customer name is not passed, call the api to get it.
     if ls_payload-data-data-data-custname is INITIAL.
       ls_payload-data-data-data-custname = me->get_customer_name( im_custid = ls_payload-data-data-data-custid ).
     endif.

* Update table with data
        MODIFY zcstdoncredits FROM @ls_payload-data-data-data.
        IF sy-subrc = 0.
          response->set_status( i_code = 200 i_reason = 'Ok').
          response->set_text( | Database table updated successfully for customer number { ls_payload-data-data-data-custid } | ).
        ELSE.
          response->set_status( i_code = 500 i_reason = 'Error').
          response->set_text( 'Error occured when updating database table' ).
        ENDIF.

    ENDCASE.

  ENDMETHOD.

  METHOD get_customer_name.

    TYPES: BEGIN OF ts_metadata,
             id   TYPE string,
             uri  TYPE string,
             type TYPE string,
           END OF ts_metadata.
    TYPES: BEGIN OF ts_customername,
             __metadata   TYPE ts_metadata,
             customername TYPE string,
           END OF ts_customername.
    TYPES: BEGIN OF ts_d,
             d TYPE ts_customername,
           END OF ts_d.
    DATA: ls_customerdata TYPE ts_d.
    DATA: lv_url TYPE string VALUE 'https://sandbox.api.sap.com/s4hanacloud/sap/opu/odata/sap/'.
    DATA: lo_http_client TYPE REF TO  if_web_http_client.
    TRY.
        lo_http_client = cl_web_http_client_manager=>create_by_http_destination(
                    i_destination = cl_http_destination_provider=>create_by_url( lv_url ) ).
        DATA(lo_request) = lo_http_client->get_http_request( ).
        lo_request->set_header_fields( VALUE #(
           (  name = 'Content-Type' value = 'application/json' )
           (  name = 'Accept' value = 'application/json' )
           (  name = 'APIKey' value = 'FZs2WGAO7g6zGIi72SEo0iHsf0c3TKu1') ) ).  "<- REMOVE THIS KEY!!!
        lo_request->set_uri_path(
           i_uri_path = lv_url && |API_BUSINESS_PARTNER/A_BusinessPartner('{ im_custid }')/to_Customer?select=CustomerName |  ).
        DATA(lv_response) = lo_http_client->execute( i_method = if_web_http_client=>get )->get_text(  ).
        /ui2/cl_json=>deserialize( EXPORTING json = lv_response
                                            pretty_name = /ui2/cl_json=>pretty_mode-low_case
                                   CHANGING data = ls_customerdata ).
        IF ls_customerdata-d-customername IS NOT INITIAL.
          r_custname = ls_customerdata-d-customername.
        ENDIF.
      CATCH: cx_web_http_client_error, cx_http_dest_provider_error.
    ENDTRY.

  ENDMETHOD.

ENDCLASS.
