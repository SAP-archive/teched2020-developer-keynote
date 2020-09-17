CLASS zcl_ems_api_tester DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_ems_api_tester IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    TRY.
        DATA(lo_ems_manager) =  zcl_ems_msg_manager=>factory(  ).
      CATCH: cx_http_dest_provider_error, cx_web_http_client_error INTO DATA(lx_exp).
        out->write( lx_exp->get_text(  ) ).
    ENDTRY.

* Write out subscriptions
*    out->write( lo_ems_manager->get_subscriptions( ) ).

* Write out a subscription
*    out->write( lo_ems_manager->get_subscription( 'whsub_rh' ) ).

*    out->write( lo_ems_manager->publish_message_to_topic(
*                  iv_topic_name = 'richtest'
*                  iv_message    = 'This is a test message for topic richteste'
*                ) ).

*    DO 1 TIMES.
*      out->write( lo_ems_manager->publish_message_to_queue(
*                    iv_queue_name = 'abaptestqueue'
*                    iv_message    = '{' && |\n|  &&
*                                    '  "data": {' && |\n|  &&
*                                    |    "customerid": "'{ sy-index }'",| && |\n|  &&
*                                    '    "customername": "Customer Number",' && |\n|  &&
*                                    '    "donationcredits": "1234"' && |\n|  &&
*                                    '  }' && |\n|  &&
*                                    '}'
*                  ) ).
*    ENDDO.


    DO 1 TIMES.

      data lv_message_id type string.
      out->write( lo_ems_manager->consume_message_from_queue( exporting
                                                                 iv_queue_name = 'abaptestqueue'
                                                              importing
                                                                 ev_message_id = lv_message_id ) ).
* Once you have processed the message acknowledge it.
      if lv_message_id  is not INITIAL.
      out->write( lo_ems_manager->acknowledge_msg_consumption(
                    iv_queue_name = 'abaptestqueue'
                    iv_message_id = lv_message_id
                  ) ).
      endif.

    ENDDO.

  ENDMETHOD.

ENDCLASS.
