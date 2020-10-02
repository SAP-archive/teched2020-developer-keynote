using charity from '../db/schema';

service teched {

    function invoke() returns String;
    function convert() returns String;
    function readEntry(party : String) returns String;
    entity CharityEntry as projection on charity.CharityEntry;

}
