# KeyPathBox
Wrapper of Object for adding Some Capability.

Now I provide FutureBox for Asynchronous Initialization of Object and Reference & Modification of that Object.

## FututeBox

FutureBox is inspired by Combine's *Future*. It adds feature to refer and modify initialized object itself in Box.

```swift

// It will be initialized on current thread
let futureBox = FutureBox<SomeObject, SomeError> { complete in
    complete(.success(SomeObject()))
}

futureBox[innerKeyPath: \.self] // Optional(SomeObject)
```

As Future does, It could be initlaized on background thread. It can be used to initialize large-scale object.

```swift

// It will be initialized on current thread
let futureBox = FutureBox<SomeLargeObject, SomeError> { complete in
    DispatchQueue.global().async {
        complete(.success(SomeLargeObject()))
    }
}

// before initialization Completed
futureBox[innerKeyPath: \.self] // nil

// waiting for initialization Complete

futureBox.sink { result in
    switch result {
    case .success(let largeOject): 
        // use object
    case .failure(let error):
        //user error
    }
}
```

## Requirement

*  Xcode 10.X and later
* Swift 4 and later

## Installation

KeyPathBox doesn't contain any external dependencies.

Now I provide CocoaPods Only

```ruby
# Podfile
use_frameworks!

target 'YOUR_TARGET_NAME' do
    pod 'KeyPathBox'
end

# RxTest and RxBlocking make the most sense in the context of unit/integration tests
target 'YOUR_TESTING_TARGET' do
    pod 'KeyPathBox'
end
```  

Replace YOUR_TARGET_NAME and then, in the Podfile directory, type:

```
$ pod install
```

## Reference

 [OpenCombine](https://github.com/broadwaylamb/OpenCombine)(For FutureBox Implementation, I used source code from this repository)

