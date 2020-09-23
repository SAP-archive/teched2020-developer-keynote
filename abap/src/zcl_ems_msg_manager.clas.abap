CLASS zcl_ems_msg_manager DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE .

  PUBLIC SECTION.

    CONSTANTS c_pause TYPE string VALUE 'pause'.
    CONSTANTS c_resume TYPE string VALUE 'resume'.

    CLASS-METHODS factory
      RETURNING
                VALUE(manager) TYPE REF TO zcl_ems_msg_manager
      RAISING   cx_http_dest_provider_error
                cx_web_http_client_error.

    METHODS publish_message_to_queue IMPORTING iv_queue_name     TYPE string
                                               iv_qos            type string default '0'
                                               iv_message        TYPE string
                                     RETURNING VALUE(r_response) TYPE string.
    METHODS publish_message_to_topic IMPORTING iv_topic_name     TYPE string
                                               iv_qos            type string default '0'
                                               iv_message        TYPE string
                                     RETURNING VALUE(r_response) TYPE string.
    METHODS consume_message_from_queue IMPORTING iv_queue_name     TYPE string
                                                 iv_qos            type string default '0'
                                       EXPORTING ev_message_id     TYPE string
                                       RETURNING VALUE(r_response) TYPE string.
    METHODS acknowledge_msg_consumption IMPORTING iv_queue_name     TYPE string
                                                  iv_message_id     TYPE string
                                        RETURNING VALUE(r_response) TYPE string.
    METHODS create_subscription IMPORTING iv_request_text   TYPE string
                                RETURNING VALUE(r_response) TYPE string.
    METHODS get_subscription  IMPORTING iv_subscription_name TYPE string
                              RETURNING VALUE(r_response)    TYPE string.
    METHODS get_subscriptions RETURNING VALUE(r_response) TYPE string.
    METHODS delete_subscription IMPORTING iv_subscription_name TYPE string
                                RETURNING VALUE(r_response)    TYPE string.
    METHODS trigger_subscription_handshake IMPORTING iv_subscription_name TYPE string
                                           RETURNING VALUE(r_response)    TYPE string.
    METHODS update_subscription_state IMPORTING iv_subscription_name TYPE string
                                                iv_request_text      TYPE string
                                      RETURNING VALUE(r_response)    TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA: gv_em_url TYPE string.
    DATA: gv_token_url TYPE string.
    DATA: gv_access_token TYPE string.
    DATA: gv_user TYPE string.
    DATA: gv_password TYPE string.

    METHODS execute_ems_request
      IMPORTING iv_uri_path       TYPE string
                iv_qos            TYPE string DEFAULT '0'
                iv_http_action    TYPE if_web_http_client=>method
                  DEFAULT if_web_http_client=>get
                iv_request_text   TYPE string OPTIONAL
      EXPORTING et_header_fields  TYPE if_web_http_request=>name_value_pairs
                es_status         TYPE if_web_http_response=>http_status
      RETURNING VALUE(r_response) TYPE string  " ref to IF_WEB_HTTP_RESPONSE
      RAISING   cx_web_message_error.

ENDCLASS.


CLASS zcl_ems_msg_manager IMPLEMENTATION.
  METHOD factory.
    CREATE OBJECT manager.

    manager->gv_em_url = zcl_ems_connection=>get_em_url(  ).
    manager->gv_token_url = zcl_ems_connection=>get_token_url(  ).
    manager->gv_user = zcl_ems_connection=>get_user( ).
    manager->gv_password = zcl_ems_connection=>get_password(  ).

  ENDMETHOD.

  METHOD publish_message_to_queue.   "test done

    r_response = execute_ems_request(
                        iv_http_action = if_web_http_client=>post
                        iv_qos = iv_qos
                        iv_uri_path = |/messagingrest/v1/queues/{ iv_queue_name }/messages|
                        iv_request_text = iv_message ).

  ENDMETHOD.

  METHOD publish_message_to_topic.  "test done

    r_response = execute_ems_request(
                        iv_http_action = if_web_http_client=>post
                        iv_qos = iv_qos
                        iv_uri_path = |/messagingrest/v1/topics/{ iv_topic_name }/messages|
                        iv_request_text = iv_message ).

  ENDMETHOD.

  METHOD consume_message_from_queue.  "test done, works for consumption of queue and topic messages

    execute_ems_request(
                     EXPORTING
                         iv_http_action = if_web_http_client=>post
                         iv_qos = iv_qos
                         iv_uri_path = |/messagingrest/v1/queues/{ iv_queue_name }/messages/consumption|
                     IMPORTING
                        et_header_fields = DATA(lt_header_fields)
                     RECEIVING
                        r_response = r_response ).
    READ TABLE lt_header_fields REFERENCE INTO DATA(lr_message_id) WITH KEY name = 'x-message-id'.
    IF sy-subrc = 0.
      ev_message_id = lr_message_id->value.
    ENDIF.

  ENDMETHOD.

  METHOD acknowledge_msg_consumption.  "test done, works  must consume a qos=1 message.

    r_response = execute_ems_request(
                       iv_http_action = if_web_http_client=>post
                       iv_uri_path = |/messagingrest/v1/queues/{ iv_queue_name }/messages/{ iv_message_id }/acknowledgement| ).

  ENDMETHOD.

  METHOD create_subscription. "test done

    r_response = execute_ems_request(
                   EXPORTING
                     iv_uri_path      = |/messagingrest/v1/subscriptions|
                     iv_http_action   = if_web_http_client=>post
                     iv_request_text  = iv_request_text ).

  ENDMETHOD.

  METHOD get_subscription.  "test done

    r_response = execute_ems_request(
                        iv_uri_path = |/messagingrest/v1/subscriptions/{ iv_subscription_name }| ).

  ENDMETHOD.

  METHOD get_subscriptions. "test done

    r_response = execute_ems_request(
                        iv_uri_path = |/messagingrest/v1/subscriptions| ).

  ENDMETHOD.

  METHOD delete_subscription. "test done

    r_response = execute_ems_request(
                        iv_http_action   = if_web_http_client=>delete
                        iv_uri_path = |/messagingrest/v1/subscriptions/{ iv_subscription_name }| ).

  ENDMETHOD.

  METHOD trigger_subscription_handshake.  "test done

    r_response = execute_ems_request(
                        iv_http_action   = if_web_http_client=>post
                        iv_uri_path = |/messagingrest/v1/subscriptions/{ iv_subscription_name }/handshake| ).

  ENDMETHOD.

  METHOD update_subscription_state.  "test done

    r_response = execute_ems_request(
                        iv_http_action   = if_web_http_client=>put
                        iv_uri_path = |/messagingrest/v1/subscriptions/{ iv_subscription_name }/state|
                        iv_request_text  = iv_request_text ) .

  ENDMETHOD.

  METHOD execute_ems_request.

    TYPES: BEGIN OF ty_token,
             access_token TYPE string,
             token_type   TYPE string,
             expires_in   TYPE string,
           END OF ty_token.
    DATA: ls_token TYPE ty_token.

    TRY.

* First get access token
        DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination(
                                 i_destination = cl_http_destination_provider=>create_by_url( gv_token_url ) ).
        DATA(lo_request) = lo_http_client->get_http_request( ).
        lo_request->set_authorization_basic( i_username = gv_user i_password = gv_password ).
        lo_request->set_header_field( i_name = 'Content-Type' i_value = 'application/json' ).

        DATA(lo_response) = lo_http_client->execute( i_method = if_web_http_client=>post ).
        /ui2/cl_json=>deserialize( EXPORTING json = lo_response->get_text( )
                                   CHANGING data = ls_token ).
        gv_access_token = ls_token-access_token.


* Setup primary request
        lo_request->set_uri_path( i_uri_path = gv_em_url && iv_uri_path ).
        lo_request->set_header_field( i_name = 'Content-Type' i_value = 'application/json' ).
        lo_request->set_header_field( i_name = 'Authorization' i_value = |Bearer { gv_access_token }| ).
        lo_request->set_header_field( i_name  = 'x-qos' i_value = iv_qos ).
        IF iv_request_text IS SUPPLIED.
          lo_request->set_text( iv_request_text ).
        ENDIF.

* Execute request
        DATA ls_status TYPE if_web_http_response=>http_status.
        CASE iv_http_action.
          WHEN if_web_http_client=>get OR if_web_http_client=>post.
            lo_response = lo_http_client->execute( i_method = iv_http_action ).
            IF lo_response->get_text( ) IS INITIAL.
              ls_status = lo_response->get_status( ).
              r_response = |Response is: { ls_status-code } { ls_status-reason }.| .
            ELSE.
              r_response = lo_response->get_text( ).
            ENDIF.

            IF et_header_fields IS REQUESTED.
              et_header_fields = lo_response->get_header_fields( ).
            ENDIF.
            IF es_status IS REQUESTED.
              es_status = lo_response->get_status( ).
            ENDIF.

          WHEN if_web_http_client=>patch OR
               if_web_http_client=>delete OR
               if_web_http_client=>put.
            lo_response = lo_http_client->execute( i_method = iv_http_action ).
            ls_status = lo_response->get_status( ).
            r_response = |Response is: { ls_status-code } { ls_status-reason }.| .
          WHEN OTHERS.
            r_response = |Response is: 405 Method Not Allowed.| .
        ENDCASE.

        lo_http_client->close( ).

      CATCH cx_http_dest_provider_error cx_web_http_client_error INTO DATA(lx_error).
        r_response =  lx_error->get_text( ).
    ENDTRY.

  ENDMETHOD.

ENDCLASS.
