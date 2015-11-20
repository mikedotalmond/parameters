# Parameters
Using Haxe macro goodness to provide strongly typed Parameter/Observer stuff for Float/Int/Bool types

Requires / depends on `hxsignal` haxelib

Based on the Parameter/Mapping parts of the [Tonfall](https://code.google.com/p/tonfall/) library by [Andre Michelle](https://twitter.com/andremichelle).



```
ParameterBase<T,I>

	T - Float,Int,Bool
	I - InterpolationNone, InterpolationLinear, InterpolationExponential
	
	new Parameter<T,I>(name:String, min:T, max:T);
	
		.getValue(normalised:Bool = false):T;
		.setValue(value:T, normalised:Bool = false, forced:Bool = false):Void;
		
		.defaultValue:T;
		.setDefault(value:T, normalised:Bool = false):Void;
		.setToDefault():Void;
		
		.addObserver(callback:Parameter<T,I>->Void, triggerImmediately = false, once = false);
		.removeObserver(callback:Parameter<T,I>->Void);
```

## Usage

```
var myFloat	= new Parameter<Float, InterpolationLinear>('aLinearFloatParameter', .0, 2*Math.PI);
var myFloat	= new Parameter<Float, InterpolationExponential>('anExponentialFloatParameter', -Math.PI, Math.PI);
	
var myInt 	= new Parameter<Int, InterpolationLinear>('anLinearIntegerParameter', -64, 64);
var myInt 	= new Parameter<Int, InterpolationExponential>('anExponentialIntegerParameter', -64, 64);
	
var myBool 	= new Parameter<Bool, InterpolationNone>('aBooleanParameter', false, true);
	
myFloat.addObserver(function(p:Parameter) {
	trace(p.getValue());
		trace(p.getValue(true));
});

myFloat.setValue(Math.PI);
myFloat.setValue(.5,true);
```

##Todo
* add more interpolation types, or make easy to add custom ones
* haxelib release?
