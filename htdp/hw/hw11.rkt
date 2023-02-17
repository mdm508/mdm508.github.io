#lang at-exp s-exp "hw.rkt"

@11 @'(11 18 2011)

@,p{This assignment builds on the information in @a["lab10.html"]{Lab 10}.}

@,p{Create a phone book application that includes one window for
    the phone company and one window for a customer who wants to find phone 
    numbers (i.e., starting the program creates two windows):}

@,ul{

 @li{@p{The phone-company window should have five elements:
     @ol{
       @li{A place to type a name.}
       @li{A place to type a phone number.}
       @li{An ``Add'' button that installs the name and number into a phone book.}
       @li{A place to type an area code.}
       @li{An ``Add Area Code'' button that changes all 7-digit phone numbers
           in the phone book to be 10-digit numbers using the specific area code.}}}}

 @li{@p{The customer window should have three elements:
     @ol{
      @li{A place to type a name.}
      @li{A ``Lookup'' button.}
      @li{A place for the phone number (if known) to appear for the given
          name after the ``Lookup'' button is pushed.}}}}

}

@,p{The phone-company and customer windows are separate views and controls for the same 
    model, where the shared model implements a phone book. That is, if you add
    a name with the phone-company window and then switch to the customer window,
    you should be able to lookup the name that was just registered by the phone-company window.}

@,p{The phone book should start out empty when you start the program.}
