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


* Create a subscription
*   out->write( lo_ems_manager->create_subscription( iv_request_text =  `{` && |\r\n|  &&
*                                                                        `   "name": "testrichsub",` && |\r\n|  &&
*                                                                        `   "address": "queue:abaptestqueue",` && |\r\n|  &&
*                                                                        `   "qos": 1,` && |\r\n|  &&
*                                                                        `   "pushConfig": {` && |\r\n|  &&
*                                                                        `       "type": "webhook",` && |\r\n|  &&
*                                                                        `       "endpoint": "https://mywebhook.com/messages",` && |\r\n|  &&
*                                                                        `       "exemptHandshake": true` && |\r\n|  &&
*                                                                        `   }` && |\r\n|  &&
*                                                                        `}`  ) ).

* Write out subscriptions
*    out->write( lo_ems_manager->get_subscriptions( ) ).

* Write out a subscription
*   out->write( lo_ems_manager->get_subscription( 'testrichsub' ) ).

* Trigger subscription handshake
*  out->write( lo_ems_manager->trigger_subscription_handshake( iv_subscription_name =  'testrichsub' ) ).

* Update subscription state
*  out->write( lo_ems_manager->update_subscription_state(
*                iv_subscription_name = 'testrichsub'
*                iv_request_text      = '{"action": "pause"}' ) ).

* delete a subscription
*   out->write( lo_ems_manager->delete_subscription( iv_subscription_name = 'testrichsub' ) ).


* Publish a message to a topic
*      out->write( lo_ems_manager->publish_message_to_topic(
*                    iv_topic_name = 'abaptopic'
*                    iv_qos        = '1'
*                    iv_message    = '{' && |\n|  &&
*                                    '  "data": {' && |\n|  &&
*                                    |    "customerid": "'{ sy-index }'",| && |\n|  &&
*                                    '    "customername": "Customer Number",' && |\n|  &&
*                                    '    "donationcredits": "1234"' && |\n|  &&
*                                    '    "topic": "abaptopic"' && |\n|  &&
*                                    '  }' && |\n|  &&
*                                    '}'
*                  ) ).


* Publish message to queue
*    DO 1 TIMES.
*      out->write( lo_ems_manager->publish_message_to_queue(
*                    iv_queue_name = 'abaptestqueue'
*                    iv_qos        = '1'
*                    iv_message    = '{' && |\n|  &&
*                                    '  "data": {' && |\n|  &&
*                                    |    "customerid": "'{ sy-index }'",| && |\n|  &&
*                                    '    "customername": "Customer Number",' && |\n|  &&
*                                    '    "donationcredits": "1234"' && |\n|  &&
*                                    '  }' && |\n|  &&
*                                    '}'
*                  ) ).
*    ENDDO.

* Consume the messages and acknowledge them
*    DO 1 TIMES.

      data lv_message_id type string.
      out->write( lo_ems_manager->consume_message_from_queue( exporting
                                                                 iv_queue_name = 'abaptestqueue'
                                                                 iv_qos = '1'
                                                              importing
                                                                 ev_message_id = lv_message_id ) ).
* Once you have processed the message acknowledge it.
      if lv_message_id  is not INITIAL.
      out->write( lo_ems_manager->acknowledge_msg_consumption(
                    iv_queue_name = 'abaptestqueue'
                    iv_message_id = lv_message_id
                  ) ).
      endif.

*    ENDDO.



  ENDMETHOD.

ENDCLASS.
