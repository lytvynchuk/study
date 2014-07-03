package com.towerdefence.gui {
import com.framework.math.Amath;

import flash.display.MovieClip;
import flash.display.Sprite;

public class HealthBar extends Sprite {
    //---------------------------------------
    // PRIVATE VARIABLES
    //---------------------------------------
    private var _fullHealth:Number;
    private var _source:MovieClip;

    //---------------------------------------
    // CONSTRUCTOR
    //---------------------------------------

    /**
     * @constructor
     */
    public function HealthBar() {
        _source = new UnitHealthBar_mc();
        _source.stop();
        addChild(_source);
    }

    /**
     * @private
     */
    public function free():void {
        //
    }

    //---------------------------------------
    // PUBLIC METHODS
    //---------------------------------------

    /**
     * @private
     */
    public function update(health:Number):void {
        var percent:Number = Amath.toPercent(health, _fullHealth);
        _source.gotoAndStop(Math.round(Amath.fromPercent(percent, _source.totalFrames)));
    }

    /**
     * @private
     */
    public function reset(fullHealth:Number):void {
        _fullHealth = fullHealth;
        _source.gotoAndStop(_source.totalFrames);
    }

}

}