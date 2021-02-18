CLASS zcl_cdc_trigger_webhook_sim DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.

CLASS zcl_cdc_trigger_webhook_sim IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

   TRY.

        DATA(lo_cdc_service) = NEW zcl_cdc_rest_service(  ).

        DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination(
                      i_destination = cl_http_destination_provider=>create_by_url( |https://| && cl_abap_context_info=>get_system_url( ) ) ).
        DATA(lo_request) = lo_http_client->get_http_request( ).  " Get a request object
        DATA(lo_response) = lo_http_client->execute( i_method = if_web_http_client=>post ).  " Just generate dummy response object

        DATA(lv_payload) =  `{   "data": {` && |\r\n|  &&
                            `        "data": {` && |\r\n|  &&
                            `            "specversion": "1.0",` && |\r\n|  &&
                            `            "type": "z.internal.charityfund.increased.v1",` && |\r\n|  &&
                            `            "datacontenttype": "application/json",` && |\r\n|  &&
                            `            "id": "4c8f6699-f08f-4a3b-8fd6-0b4f26687091",` && |\r\n|  &&
                            `            "time": "2020-10-02T13:51:30.888Z",` && |\r\n|  &&
                            `            "source": "/default/cap.brain/1",` && |\r\n|  &&
                            `            "data": {` && |\r\n|  &&
                            `                "salesorder": "999999",` && |\r\n|  &&
                            `                "custid": "USCU-CUS10",` && |\r\n|  &&
                            `                "creationdate": "2021-02-15",` && |\r\n|  &&
                            `                "credits": 10.43,` && |\r\n|  &&
                            `                "salesorg": "1500"` && |\r\n|  &&
                            `            }` && |\r\n|  &&
                            `        }` && |\r\n|  &&
                            `    }` && |\r\n|  &&
                            `}`.

        lo_request->set_text( i_text = lv_payload ).
        lo_cdc_service->if_http_service_extension~handle_request( request = lo_request
                                                                  response = lo_response ).
        IF lo_response->get_text( ) IS INITIAL.
          data(ls_status) = lo_response->get_status( ).
          out->write( |Response is: { ls_status-code } { ls_status-reason }.| ) .
        ELSE.
          out->write( lo_response->get_text( ) ).
        ENDIF.

      CATCH cx_http_dest_provider_error cx_web_http_client_error INTO DATA(lx_error).
        out->write( lx_error->get_text( ) ).
    ENDTRY.

  ENDMETHOD.

ENDCLASS.
