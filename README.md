Chocolate is a library containing additions to Cocoa and Cocoa Touch that
simplify writing Objective C code for OSX/iOS. The things that Apple forgot.

Chocolate consists of three "sub-libraries":

1. Foundation Additions - Categories on the Foundation classes. These
   are intended to be useful for all Objective C code.

2. Core Data Additions - Categories on Core Data classes.

3. Testing Additions - Categories on Foundation classes that provide
   functionality useful when writing Unit Tests. These are not
   intended to be linked in the actual Application code.

## Usage

Chocolate is published as a [CocoaPod][CocoaPods], with each the
three "sub-libraries" above listed as a separate "subspec".

For example, to use the first public release of Chocolate's Foundation Additions, we will need to add the following to our `Podfile`

    pod 'TDTChocolate/FoundationAdditions', :git => 'git@github.com:talk-to/Chocolate', :tag => '1.0.0'

then run

    $ pod install

and finally import the public header for the Foundation Additions subspec

    #import <TDTChocolate/FoundationAdditions.h>

## Contributing

1. Go through the [Talk.to iOS Development Guidelines][ios-guides].

2. Open a pull request on this repository. Tests and documentation are
   not optional.

[CocoaPods]: http://cocoapods.org/
[ios-guides]: https://github.com/talk-to/ios-guides
