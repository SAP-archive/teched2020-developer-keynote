CLASS zcl_cdc_customer_master DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES: if_sadl_exit_calc_element_read.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_cdc_customer_master IMPLEMENTATION.

  METHOD if_sadl_exit_calc_element_read~calculate.

    DATA: lt_business_data TYPE TABLE OF zcdc_a_customers,
          lo_http_client   TYPE REF TO if_web_http_client,
          lo_client_proxy  TYPE REF TO /iwbep/if_cp_client_proxy,
          lo_request       TYPE REF TO /iwbep/if_cp_request_read_list,
          lo_response      TYPE REF TO /iwbep/if_cp_response_read_lst.

    "DATA: lo_filter_factory   TYPE REF TO /iwbep/if_cp_filter_factory,
    "      lo_filter_node_1    TYPE REF TO /iwbep/if_cp_filter_node,
    "      lo_filter_node_2    TYPE REF TO /iwbep/if_cp_filter_node,
    "      lo_filter_node_root TYPE REF TO /iwbep/if_cp_filter_node,
    "      lt_range_customer TYPE RANGE OF <element_name>,
    "      lt_range_authorizationgroup TYPE RANGE OF <element_name>.

    TRY.

        DATA: lv_url TYPE string VALUE 'https://s4mock.c210ab1.kyma.shoot.live.k8s-hana.ondemand.com'.
        lo_http_client = cl_web_http_client_manager=>create_by_http_destination(
                        i_destination = cl_http_destination_provider=>create_by_url( lv_url ) ).

        lo_client_proxy = cl_web_odata_client_factory=>create_v2_remote_proxy(
          EXPORTING
            iv_service_definition_name = 'ZCDC_BUPA'
            io_http_client             = lo_http_client
            iv_relative_service_root   = '/sap/opu/odata/sap/API_BUSINESS_PARTNER' ).

        " Navigate to the resource and create a request for the read operation
        lo_request = lo_client_proxy->create_resource_for_entity_set( 'A_CUSTOMER' )->create_request_for_read( ).

        " Create the filter tree
        "lo_filter_factory = lo_request->create_filter_factory( ).
        "
        "lo_filter_node_1  = lo_filter_factory->create_by_range( iv_property_path     = 'customer'
        "                                                        it_range             = lt_range_customer ).
        "lo_filter_node_2  = lo_filter_factory->create_by_range( iv_property_path     = 'authorizationgroup'
        "                                                        it_range             = lt_range_authorizationgroup ).
        "lo_filter_node_root = lo_filter_node_1->and( lo_filter_node_2 ).
        "
        "lo_request->set_filter( lo_filter_node_root ).

        "lo_request->set_top( 50 )->set_skip( 0 ).

        " Execute the request and retrieve the business data
        lo_response = lo_request->execute( ).
        lo_response->get_business_data( IMPORTING et_business_data = lt_business_data ).

        DATA lt_original_data TYPE STANDARD TABLE OF z_c_cstdoncredits WITH DEFAULT KEY.
        lt_original_data = CORRESPONDING #( it_original_data ).

        LOOP AT lt_original_data REFERENCE INTO DATA(lr_original_data).
          "read the data table from API call to get customer name by customer ID
          READ TABLE lt_business_data REFERENCE INTO DATA(lr_business_data)
                                 WITH KEY customer = lr_original_data->custid.
          IF sy-subrc = 0.
            lr_original_data->customername = lr_business_data->customername.
          ENDIF.

        ENDLOOP.
        ct_calculated_data = CORRESPONDING #( lt_original_data ).

      CATCH /iwbep/cx_cp_remote INTO DATA(lx_remote).
        " Handle remote Exception
        " It contains details about the problems of your http(s) connection

      CATCH /iwbep/cx_gateway INTO DATA(lx_gateway).
        " Handle Exception

     CATCH: cx_web_http_client_error, cx_http_dest_provider_error.
        " Handle Exception

    ENDTRY.


* Example calling straightaway without Service Consumption Model
*
*    TYPES: BEGIN OF ts_metadata,
*             id   TYPE string,
*             uri  TYPE string,
*             type TYPE string,
*           END OF ts_metadata.
*    TYPES: BEGIN OF ts_customername,
*             __metadata   TYPE ts_metadata,
*             customer     TYPE string,
*             customername TYPE string,
*           END OF ts_customername.
*    TYPES: BEGIN OF ts_results,
*             results TYPE STANDARD TABLE OF ts_customername WITH DEFAULT KEY,
*           END OF ts_results.
*    TYPES: BEGIN OF ts_d,
*             d TYPE ts_results,
*           END OF ts_d.
*    DATA: ls_customerdata TYPE ts_d.
*    DATA: lv_url TYPE string VALUE 'https://sandbox.api.sap.com/s4hanacloud/sap/opu/odata/sap/'.
*    DATA: lo_http_client TYPE REF TO  if_web_http_client.
*    TRY.
*        lo_http_client = cl_web_http_client_manager=>create_by_http_destination(
*                    i_destination = cl_http_destination_provider=>create_by_url( lv_url ) ).
*        DATA(lo_request) = lo_http_client->get_http_request( ).
*        lo_request->set_header_fields( VALUE #(
*           (  name = 'Content-Type' value = 'application/json' )
*           (  name = 'Accept' value = 'application/json' )
*           (  name = 'APIKey' value = '') ) ).  "<- NEED API KEY!!!
*        lo_request->set_uri_path(
*           i_uri_path = lv_url && |API_BUSINESS_PARTNER/A_Customer?select=Customer,CustomerName |  ).
*
*        DATA(lv_response) = lo_http_client->execute( i_method = if_web_http_client=>get )->get_text(  ).
*        /ui2/cl_json=>deserialize( EXPORTING json = lv_response
*                                            pretty_name = /ui2/cl_json=>pretty_mode-low_case
*                                   CHANGING data = ls_customerdata ).
*
*      CATCH: cx_web_http_client_error, cx_http_dest_provider_error.
*    ENDTRY.

*    DATA lt_original_data TYPE STANDARD TABLE OF z_c_cstdoncredits WITH DEFAULT KEY.
*    lt_original_data = CORRESPONDING #( it_original_data ).
*    LOOP AT lt_original_data REFERENCE INTO DATA(lr_original_data).
*      "read the data table from API call to get customer name by customer ID
*       READ TABLE lt_business_data REFERENCE INTO DATA(lr_business_data)
*                              WITH KEY customer = lr_original_data->custid.
*       IF sy-subrc = 0.
*         lr_original_data->customername = lr_business_data->customername.
*       ENDIF.
*    ENDLOOP.
*    ct_calculated_data = CORRESPONDING #( lt_original_data ).

  ENDMETHOD.

  METHOD if_sadl_exit_calc_element_read~get_calculation_info.

    IF iv_entity <> 'Z_C_CSTDONCREDITS'.
    " raise exception
    ENDIF.
    LOOP AT it_requested_calc_elements ASSIGNING FIELD-SYMBOL(<fs_calc_element>).
      CASE <fs_calc_element>.
        WHEN 'CUSTOMERNAME'.
          APPEND 'CUSTID' TO et_requested_orig_elements.
        WHEN OTHERS.
      ENDCASE.
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
