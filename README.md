Description
===========

Objection is a lightweight dependency injection framework for Objective-C for MacOS X and iOS. For those of you that have used Guice objection will feel familiar. Objection was built to stay out of your way and alleviate the need to maintain a large XML container or manually construct objects.

Features
==============

* "Annotation" Based Dependency Injection
* Seamless support for integrating custom and external dependencies
  * Custom Object Providers
  * Meta Class Bindings
  * Protocol Bindings
  * Instance Bindings
* Lazily instantiates dependencies
* Eager Singletons

Using Objection
========

### Basic Usage

A class can be registered with objection using the macros *objection_register* or *objection_register_singleton*. The *objection_requires* macro can be used to declare what dependencies objection should provide to all instances it creates of that class. *objection_requires* can be used safely with inheritance.

#### Example

      @class Engine, Brakes;
    
      @interface Car : NSObject
      {
        Engine *engine;
        Brakes *brakes;
        BOOL awake;  
      }

      // Will be filled in by objection
      @property(nonatomic, retain) Engine *engine;
      // Will be filled in by objection
      @property(nonatomic, retain) Brakes *brakes;
      @property(nonatomic) BOOL awake;
    
      @implementation Car
      objection_register(Car)
      objection_requires(@"engine", @"brakes")
      @synthesize engine, brakes, awake;
      @end


### Fetching Objects from Objection

An object can be fetched from objection by creating an injector and then asking for an instance of a particular class or protocol. An injector manages its own object context. Which means that a singleton is per injector and is not necessarily a *true* singleton.

    - (void)someMethod {
      ObjectionInjector *injector = [Objection createInjector];
      id car = [injector getObject:[Car class]];
    }

A global injector can be registered with Objection which can be used throughout your application or library.
    
    - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
      ObjectionInjector *injector = [Objection createInjector];
      [Objection setGlobalInjector:injector];
    }
    
    - (void)viewDidLoad {
      id myModel = [[Objection globalInjector] getObject:[MyModel class]];
    }

### Integrating external and custom objects

Objection supports associating an object outside the context of Objection by configuring an ObjectionModule.

#### Instance and Protocol Bindings

You can bind a type to a specific instance of that type. This is useful when an object exists or is constructed outside of Objection.

#### Example
      @interface MyAppModule : ObjectionModule {
        
      }
      @end
      
      @implementation MyAppModule
      - (void)configure {
        [self bind:[UIApplication sharedApplication] toClass:[UIApplication class]];
        [self bind:[UIApplication sharedApplication].delegate toProtocol:@protocol(UIApplicationDelegate)];
      }
      
      @end
      - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
        ObjectionInjector *injector = [Objection createInjector:[[[MyAppModule alloc] init] autorelease]];
        [Objection setGlobalInjector:injector];
      }

#### Meta Class Bindings

There are times when a dependency -- usually external -- is implemented using only class methods. Objection can explicitly support binding to
the meta class instance through a protocol. This avoids having to unnecessarily create a wrapper class that passes through to the class
methods. The catch, of course, is that it requires a protocol definition so that Objection knows how to bind the meta class to objects
in the injector context.

#### Example

      @protocol ExternalUtility
        - (void)doSomething;
      @end
      
      @interface ExternalUtility
        + (void)doSomething;
      @end
      
      @implementation ExternalUtility
        + (void)doSomething {...}
      @end
      
      // Module Configuration
      - (void)configure {
        [self bindMetaClass:[ExternalUtility class] toProtocol:@protocol(ExternalUtility)];    
      }
      
      @interface SomeClass
      {
        ...
      }
      // Use 'assign' because a meta class is not subject to the normal retain/release lifecycle. 
      // It will exist until the application is terminated (Class Initialization -> Application Termination)
      // regardless of the number of objects in the runtime that reference it.
      @property (nonatomic, assign) id<ExternalUtility> externalUtility
      @end

#### Providers

Occasionally you'll want to manually construct an object within Objection. Providers allow you to use a custom mechanism for building objects that are bound to a type. You can create a class that _conforms_ to the ObjectionProvider protocol or you can use a _block_ to build the object.
      
#### Example

    @implementation CarProvider
    - (id)createInstance:(ObjectionInjector *)context {
      // Manually build object
      return car;
    }
    @end
    
    @implementation MyAppModule
    - (void)configure {
        [self bindProvider:[[[CarProvider alloc] init] autorelease] toClass:[Car class]];
        [self bindBlock:^(ObjectionInjector *context) {
          // Manually build object
          return car;          
        } toClass:[Car class]];
    }
    @end


### Eager Singletons

You can mark registered singleton classes as eager singletons. Eager singletons will be instantiated during the creation of the injector rather than being lazily instantiated.

### Example

    @implementation MyAppModule
    - (void)configure {
      [self registerEagerSingleton:[Car class]];
    }

    @end


### Awaking from Objection

If an object is interested in knowing when it has been fully instantiated by objection it can implement the method
*awakeFromObjection*.

#### Example
      @implementation Car
      //...
      objection_register_singleton(Car)
        - (void)awakeFromObjection {
          awake = YES;
        }
      @end  
      

## TODO

* Diagram class initialization and its relationship with Objection.
* Resolve circular dependencies.
* Cache results of property definitions.
* Create example project
* Add contribution section

Installation
=======

### iOS

1. git clone git://github.com/atomicobject/objection.git
2. rake artifact:ios or rake artifact:ios3 if you require iOS 3.0 compatibility
3. cp -R build/Release-iphoneuniversal/Objection-iOS.framework ${DEST_DIR}
4. Add -ObjC and -all_load to Other Link Flags in your project

#### Include framework
    #import <Objection-iOS/Objection.h>

### MacOS X

1. git clone git://github.com/atomicobject/objection.git
2. rake artifact:osx
3. cp -R build/Release/Objection.framework ${DEST_DIR}

#### Include framework
    #import <Objection/Objection.h>

### Installation Notes

* There is a glitch in XCode that will cause header files to not be copied properly. So, if you are building the iOS target you may have to run the build process a couple of times to get all of the proper header files copied.

Requirements
============

* MacOS X 10.6 +
* iOS 3.0 +

Authors
=======

* Justin DeWind (dewind@atomicobject.com)
* © 2009-2011 [Atomic Object](http://www.atomicobject.com/)
* More Atomic Object [open source](http://www.atomicobject.com/pages/Software+Commons) projects
