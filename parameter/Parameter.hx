/**
 * Parameter / Mapping
 * @author Mike Almond
 * 
 * Using Haxe macro goodness to provide strongly typed Parameter/Observer stuff for Float/Int/Bool types.
 * 
 * Uses / depends on hxsignal
 * 
 * Parameter/Mapping idea based on part of Andre Michelle's Tonfall library
 * https://code.google.com/p/tonfall/
 * 
 *	ParameterBase<T,I>
 * 
 *		T - Float,Int,Bool
 *		I - InterpolationNone, InterpolationLinear, InterpolationExponential
 *		
 *		new Parameter<T,I>(name:String, min:T, max:T);
 *		
 *			.getValue(normalised:Bool = false):T;
 *			.setValue(value:T, normalised:Bool = false, forced:Bool = false):Void;
 *			
 *			.defaultValue:T;
 *			.setDefault(value:T, normalised:Bool = false):Void;
 *			.setToDefault():Void;
 *			
 *			.addObserver(callback:Parameter<T,I>->Void, triggerImmediately = false, once = false);
 *			.removeObserver(callback:Parameter<T,I>->Void);
 *	
 *	
 *	Examples...
 *	
 *	var myFloat	= new Parameter<Float, InterpolationLinear>('aLinearFloatParameter', .0, 2*Math.PI);
 *	var myFloat	= new Parameter<Float, InterpolationExponential>('anExponentialFloatParameter', -Math.PI, Math.PI);
 *	
 *	var myInt 	= new Parameter<Int, InterpolationLinear>('anLinearIntegerParameter', -64, 64);
 *	var myInt 	= new Parameter<Int, InterpolationExponential>('anExponentialIntegerParameter', -64, 64);
 *	
 * 	var myBool 	= new Parameter<Bool, InterpolationNone>('aBooleanParameter', false, true);
 *	
 *	myFloat.addObserver(function(p:Parameter) {
 *		trace(p.getValue());
 *		trace(p.getValue(true));
 *	});
 * 
 *  myFloat.setValue(Math.PI);
 *  myFloat.setValue(.5,true);
 * 
 */

package parameter;

import hxsignal.Signal;
import parameter.Mapping;

typedef BoolParameter = ParameterBase<Bool,Interpolation>
typedef IntParameter = ParameterBase<Int,Interpolation>
typedef FloatParameter = ParameterBase<Float,Interpolation>

class ParameterBase<T,I> {

	public var name(default, null):String;

	public var defaultValue(default, null):T;

	public var normalisedValue(default, null):Float;
	public var normalisedDefaultValue(default, null):Float;
	
	public var mapping(default, null):Mapping<T,I>;
	public var change(default, null):Signal<Parameter<T,I>->Void>;
	
	@:allow(parameter.Parameter)
	private function new(name:String, mapping:Mapping<T,I>) {

		this.name = name;
		this.mapping = mapping;

		change = new Signal<Parameter<T,I>->Void>();

		setDefault(mapping.min);
	}
	
	/**
	 * 
	 * @param	value
	 * @param	normalised
	 */
	public function setDefault(value:T, normalised:Bool = false) {

		var normValue;

		if (normalised) {
			normValue = cast value;
			value = mapping.map(normValue);
		} else {
			normValue = mapping.mapInverse(value);
		}

		normalisedDefaultValue = normValue;
		defaultValue = value;

		setValue(cast normValue, true);
	}

	/**
	 * 
	 * @param	value
	 * @param	normalised
	 * @param	forced
	 */
	public function setValue(value:T, normalised:Bool = false, forced:Bool = false):Void {

		var normValue;

		if (normalised) normValue = cast value;
		else normValue = mapping.mapInverse(value);

		if (forced || normValue != normalisedValue) {
			normalisedValue = normValue;
			change.emit(cast this);
		}
	}

	public function setToDefault() {
		setValue(cast normalisedDefaultValue, true);
	}

	/**
	 * 
	 * @param	normalised
	 * @return
	 */
	public function getValue(normalised:Bool = false):T {
		if (normalised) return cast normalisedValue;
		return mapping.map(normalisedValue);
	}

	/**
	 * 
	 * @param	observers
	 * @param	triggerImmediately = false
	 * @param	once = false
	 */
	public function addObservers(observers:Array<Parameter<T,I>->Void>, triggerImmediately = false, once = false) {
		for (observer in observers) addObserver(observer, triggerImmediately, once);
	}
	
	/**
	 * 
	 * @param	callback
	 * @param	triggerImmediately = false
	 * @param	once = false
	 */
	public function addObserver(callback:Parameter<T,I>->Void, triggerImmediately = false, once = false) {
		if (!change.isConnected(callback)) {
			change.connect(callback, once ? ConnectionTimes.Once : ConnectionTimes.Forever);
		}
		if (triggerImmediately) change.emit(cast this);
	}
	
	/**
	 * 
	 * @param	callback
	 */
	public function removeObserver(callback:Parameter<T,I>->Void) {
		if (change.isConnected(callback)) change.disconnect(callback);
	}
	
	public function removeAllObservers() { change.disconnectAll(); }

	public function toString():String {
		return '[Parameter] ${name}, defaultValue:${defaultValue}, mapping:${mapping.toString()}';
	}
}


@:multiType
@:forward(name, defaultValue, normalisedValue, normalisedDefaultValue, mapping, change, setValue, getValue, setDefault, setToDefault, invert, addObservers, addObserver, removeObserver, removeAllObservers, toString)
abstract Parameter<T,I>(ParameterBase<T,I>) {
	
	/**
	 * Create a new Parameter using the type T (Float, Int, or Bool)
	 * @param	name
	 * @param	min
	 * @param	max
	 */
    public function new(name:String, min:T, max:T);

	@:to static inline function toBoolParameter<T,I>(t:ParameterBase<Bool,InterpolationNone>, name:String, min:Bool, max:Bool):BoolParameter {
		return new BoolParameter(name, getBool(min, max));
    }

    @:to static inline function toIntParameter<T,I>(t:ParameterBase<Int,InterpolationLinear>, name:String, min:Int, max:Int):IntParameter {
		return new IntParameter(name, getInt(min, max));
    }
	@:to static inline function toIntParameterExpo<T,I>(t:ParameterBase<Int,InterpolationExponential>, name:String, min:Int, max:Int):IntParameter {
		return new IntParameter(name, getIntExponential(min, max));
    }

	@:to static inline function toFloatParameter<T,I>(t:ParameterBase<Float,InterpolationLinear>, name:String, min:Float, max:Float):FloatParameter {
		return new FloatParameter(name, getFloat(min,max));
    }
	@:to static inline function toFloatParameterExpo<T,I>(t:ParameterBase<Float,InterpolationExponential>, name:String, min:Float, max:Float):FloatParameter {
		return new FloatParameter(name, getFloatExponential(min,max));
    }
	
	static function getBool(min,max) return cast new Mapping<Bool,InterpolationNone>(min, max);

	static function getFloat(min,max) return cast new Mapping<Float,InterpolationLinear>(min, max);
	static function getFloatExponential(min,max) return cast new Mapping<Float,InterpolationExponential>(min, max);

	static function getInt(min,max) return cast new Mapping<Int,InterpolationLinear>(min, max);
	static function getIntExponential(min,max) return cast new Mapping<Int,InterpolationExponential>(min, max);
}