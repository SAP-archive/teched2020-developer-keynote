CLASS zcl_cdc_generate_data DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.

ENDCLASS.



CLASS zcl_cdc_generate_data IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    DATA: lt_zcstdoncredits TYPE TABLE OF zcstdoncredits.
    DATA: ls_zcstdoncredits TYPE zcstdoncredits.

    DELETE FROM zcstdoncredits.

    lt_zcstdoncredits = VALUE #(
                               ( custid = 'USCU-CUS01' salesorder = 190801 creationdate = '20201015' credits = 0 salesorg = '1710' )
                               ( custid = 'USCU-CUS01' salesorder = 190802 creationdate = '20201015' credits = 0 salesorg = '1710' )
                               ( custid = 'USCU-CUS01' salesorder = 190803 creationdate = '20201015' credits = 0 salesorg = '1710' )
                               ( custid = 'USCU-CUS01' salesorder = 191804 creationdate = '20201115' credits = 0 salesorg = '1710' )
                               ( custid = 'USCU-CUS01' salesorder = 191805 creationdate = '20201115' credits = 0 salesorg = '1710' )
                               ( custid = 'USCU-CUS01' salesorder = 191806 creationdate = '20201115' credits = 0 salesorg = '1710' )
                               ( custid = 'USCU-CUS01' salesorder = 192807 creationdate = '20201205' credits = 0 salesorg = '1710' )
                               ( custid = 'USCU-CUS01' salesorder = 192808 creationdate = '20201205' credits = 0 salesorg = '1710' )
                               ( custid = 'USCU-CUS01' salesorder = 192809 creationdate = '20201205' credits = 0 salesorg = '1710' )
                               ( custid = 'USCU-CUS01' salesorder = 192810 creationdate = '20201205' credits = 0 salesorg = '1710' )
                               ( custid = 'USCU-CUS02' salesorder = 190811 creationdate = '20201015' credits = 0 salesorg = '1710' )
                               ( custid = 'USCU-CUS02' salesorder = 190812 creationdate = '20201015' credits = 0 salesorg = '1710' )
                               ( custid = 'USCU-CUS02' salesorder = 190813 creationdate = '20201015' credits = 0 salesorg = '1710' )
                               ( custid = 'USCU-CUS02' salesorder = 191814 creationdate = '20201115' credits = 0 salesorg = '1710' )
                               ( custid = 'USCU-CUS02' salesorder = 191815 creationdate = '20201115' credits = 0 salesorg = '1710' )
                               ( custid = 'USCU-CUS02' salesorder = 191816 creationdate = '20201115' credits = 0 salesorg = '1710' )
                               ( custid = 'USCU-CUS02' salesorder = 192817 creationdate = '20201205' credits = 0 salesorg = '1710' )
                               ( custid = 'USCU-CUS02' salesorder = 192818 creationdate = '20201205' credits = 0 salesorg = '1710' )
                               ( custid = 'USCU-CUS02' salesorder = 192819 creationdate = '20201205' credits = 0 salesorg = '1710' )
                               ( custid = 'USCU-CUS02' salesorder = 192820 creationdate = '20201205' credits = 0 salesorg = '1710' )
                               ( custid = 'USCU-CUS04' salesorder = 190821 creationdate = '20201015' credits = 0 salesorg = '1710' )
                               ( custid = 'USCU-CUS04' salesorder = 190822 creationdate = '20201015' credits = 0 salesorg = '1710' )
                               ( custid = 'USCU-CUS04' salesorder = 190823 creationdate = '20201015' credits = 0 salesorg = '1710' )
                               ( custid = 'USCU-CUS04' salesorder = 191824 creationdate = '20201115' credits = 0 salesorg = '1710' )
                               ( custid = 'USCU-CUS04' salesorder = 191825 creationdate = '20201115' credits = 0 salesorg = '1710' )
                               ( custid = 'USCU-CUS04' salesorder = 191826 creationdate = '20201115' credits = 0 salesorg = '1710' )
                               ( custid = 'USCU-CUS04' salesorder = 192827 creationdate = '20201205' credits = 0 salesorg = '1710' )
                               ( custid = 'USCU-CUS04' salesorder = 192828 creationdate = '20201205' credits = 0 salesorg = '1710' )
                               ( custid = 'USCU-CUS04' salesorder = 192829 creationdate = '20201205' credits = 0 salesorg = '1710' )
                               ( custid = 'USCU-CUS04' salesorder = 192830 creationdate = '20201205' credits = 0 salesorg = '1710' )
                               ).

    LOOP AT lt_zcstdoncredits REFERENCE INTO DATA(lr_zcstdoncredits).

      TRY.
          DATA(lv_guid) = cl_system_uuid=>create_uuid_c32_static( ).
          TRANSLATE lv_guid USING 'A1B2C3D4E5F6G7H8I9J1K2L3M4N5O6P7Q8R9S1T2U3V4W5X6Y7Z8'.
        CATCH cx_uuid_error.
      ENDTRY.
      lr_zcstdoncredits->credits = cl_abap_random_int=>create( seed = CONV i( lv_guid+23(9) )
                                     min = 10000
                                     max = 50000 )->get_next( ) .
      MODIFY zcstdoncredits FROM @lr_zcstdoncredits->*.
      out->write( lr_zcstdoncredits->* ).
    ENDLOOP.

    out->write( 'Data generatred' ).

  ENDMETHOD.


ENDCLASS.
