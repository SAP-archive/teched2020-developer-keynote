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
    METHODS publish_message_to_queue IMPORTING iv_queue_name     TYPE string
                                               iv_message        TYPE string
                                     RETURNING VALUE(r_response) TYPE string.
    METHODS publish_message_to_topic IMPORTING iv_topic_name     TYPE string
                                               iv_message        TYPE string
                                     RETURNING VALUE(r_response) TYPE string.
*    METHODS consume_message_from_queue.
*    METHODS acknowledge_msg_consumption.
*    METHODS create_subscription.
    METHODS get_subscription  IMPORTING iv_subscription_name TYPE string
                              RETURNING VALUE(r_response)    TYPE string.
    METHODS get_subscriptions RETURNING VALUE(r_response) TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA: gv_url TYPE string.
    DATA: gv_user TYPE string.
    DATA: gv_password TYPE string.
    DATA: go_http_client TYPE REF TO  if_web_http_client.

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
    manager->gv_url = '<insert messaging service here'.
    manager->gv_user = ''.
    manager->gv_password = ''.

    manager->go_http_client = cl_web_http_client_manager=>create_by_http_destination(
             i_destination = cl_http_destination_provider=>create_by_url( manager->gv_url ) ).

  ENDMETHOD.


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

  METHOD get_subscription.

    r_response = execute_ems_request(
                        iv_uri_path = |/messagingrest/v1/subscriptions/{ iv_subscription_name }| ).

  ENDMETHOD.

  METHOD get_subscriptions.

    r_response = execute_ems_request(
                        iv_uri_path = |/messagingrest/v1/subscriptions| ). "&$format=json

  ENDMETHOD.

  method execute_ems_request.

    try.

        data(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination(
                                 i_destination = cl_http_destination_provider=>create_by_url( gv_url ) ).
        data(lo_request) = lo_http_client->get_http_request( ).

        lo_request->set_authorization_basic( i_username = gv_user i_password = gv_password ).

        if iv_http_action <> if_web_http_client=>get.
          lo_request->set_header_field( i_name = 'X-CSRF-Token' i_value = 'Fetch' ).
          lo_request->set_header_field( i_name = 'Content-Type' i_value = 'application/json' ).
          data(lo_response) = lo_http_client->execute( i_method = if_web_http_client=>get ).
          lo_http_client->set_csrf_token( ).
        endif.

        lo_request->set_uri_path( i_uri_path = gv_url && iv_uri_path ).
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

      catch cx_http_dest_provider_error cx_web_http_client_error into data(lx_error).
        r_response =  lx_error->get_text( ).
    endtry.

  endmethod.

ENDCLASS.
