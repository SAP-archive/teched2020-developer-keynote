CLASS zcl_ems_manager DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE .

  PUBLIC SECTION.
    CLASS-METHODS factory
      RETURNING
                VALUE(manager) TYPE REF TO zcl_ems_manager
      RAISING   cx_http_dest_provider_error
                cx_web_http_client_error.
    methods get_token returning value(r_token) type string.
    METHODS publish_message_to_queue IMPORTING iv_queue_name     TYPE string
                                               iv_message        TYPE string
                                     RETURNING VALUE(r_response) TYPE string.
    METHODS publish_message_to_topic IMPORTING iv_topic_name     TYPE string
                                               iv_message        TYPE string
                                     RETURNING VALUE(r_response) TYPE string.
    METHODS consume_message_from_queue IMPORTING iv_queue_name     TYPE string
                                     RETURNING VALUE(r_response) TYPE string.
*    METHODS acknowledge_msg_consumption.
*    METHODS create_subscription.
    METHODS get_subscription  IMPORTING iv_subscription_name TYPE string
                              RETURNING VALUE(r_response)    TYPE string.
    METHODS get_subscriptions RETURNING VALUE(r_response) TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA: gv_em_url TYPE string.
    data: gv_token_url type string.
    data: gv_access_token type string.
    DATA: gv_user TYPE string.
    DATA: gv_password TYPE string.

    METHODS execute_ems_request
      IMPORTING iv_uri_path       TYPE string
                iv_http_action    TYPE if_web_http_client=>method
                  DEFAULT if_web_http_client=>get
                iv_request_text   TYPE string OPTIONAL
      RETURNING VALUE(r_response) TYPE string
      RAISING   cx_web_message_error.

  ENDCLASS.


CLASS zcl_ems_manager IMPLEMENTATION.
  METHOD factory.
    CREATE OBJECT manager.

    manager->gv_em_url = zcl_ems_connection=>get_em_url(  ).
    manager->gv_token_url = zcl_ems_connection=>get_token_url(  ).
    manager->gv_user = zcl_ems_connection=>get_user( ).
    manager->gv_password = zcl_ems_connection=>get_password(  ).

  ENDMETHOD.

  method get_token.

  endmethod.

  METHOD publish_message_to_queue.

    r_response = execute_ems_request(
                        iv_http_action = if_web_http_client=>post
                        iv_uri_path = |/messagingrest/v1/queues/{ iv_queue_name }/messages|
                        iv_request_text = iv_message ).

  ENDMETHOD.

  METHOD publish_message_to_topic.

    r_response = execute_ems_request(
                        iv_http_action = if_web_http_client=>post
                        iv_uri_path = |/messagingrest/v1/topics/{ iv_topic_name }/messages|
                        iv_request_text = iv_message ).

  ENDMETHOD.

 method consume_message_from_queue.

     r_response = execute_ems_request(
                        iv_http_action = if_web_http_client=>post
                        iv_uri_path = |/messagingrest/v1/queues/{ iv_queue_name }/messages/consumption| ).

 endmethod.

  METHOD get_subscription.

    r_response = execute_ems_request(
                        iv_uri_path = |/messagingrest/v1/subscriptions/{ iv_subscription_name }| ).

  ENDMETHOD.

  METHOD get_subscriptions.

    r_response = execute_ems_request(
                        iv_uri_path = |/messagingrest/v1/subscriptions| ).

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

* Set access token in header
        lo_request->set_header_field( i_name = 'Authorization' i_value = |Bearer { gv_access_token }| ).
        lo_request->set_header_field( i_name  = 'x-qos' i_value = '0' ).

        lo_request->set_uri_path( i_uri_path = gv_em_url && iv_uri_path ).
        if iv_request_text is supplied.
          lo_request->set_text( iv_request_text ).
        endif.

        data ls_status type if_web_http_response=>http_status.
        case iv_http_action.
          when if_web_http_client=>get or if_web_http_client=>post.
            r_response = lo_http_client->execute( i_method = iv_http_action )->get_text( ).
          when if_web_http_client=>patch or if_web_http_client=>delete.
            lo_response = lo_http_client->execute( i_method = iv_http_action ).
            ls_status = lo_response->get_status( ).
            r_response = |Response is: { ls_status-code } { ls_status-reason }.| .
          when others.
            r_response = |Response is: 405 Method Not Allowed.| .
        endcase.
        lo_http_client->close( ).

      CATCH cx_http_dest_provider_error cx_web_http_client_error INTO DATA(lx_error).
        r_response =  lx_error->get_text( ).
    ENDTRY.

  ENDMETHOD.

ENDCLASS.
