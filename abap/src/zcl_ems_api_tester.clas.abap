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
        DATA(lo_ems_manager) =  zcl_ems_manager=>factory(  ).
      CATCH: cx_http_dest_provider_error, cx_web_http_client_error into data(lo_exp).
      out->write( lo_exp->get_text(  ) ).
    ENDTRY.

* Write out subscription
    out->write( lo_ems_manager->get_subscriptions( ) ).


  ENDMETHOD.

ENDCLASS.
