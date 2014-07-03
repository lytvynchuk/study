package com.towerdefence.gui
{
	import flash.display.MovieClip;
	import com.framework.math.Amath;
	
	public class HealthBar extends MovieClip
	{
		//---------------------------------------
		// PRIVATE VARIABLES
		//---------------------------------------
		private var _fullHealth:Number;
		
		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		
		/**
		 * @constructor
		 */
		public function HealthBar()
		{
			super();
			
			this.stop();
		}
		
		/**
		 * @private
		 */
		public function free():void
		{
			//
		}
		
		//---------------------------------------
		// PUBLIC METHODS
		//---------------------------------------
		
		/**
		 * @private
		 */
		public function update(health:Number):void
		{
			var percent:Number = Amath.toPercent(health, _fullHealth);
			this.gotoAndStop(Math.round(Amath.fromPercent(percent, this.totalFrames)));
		}
		
		/**
		 * @private
		 */
		public function reset(fullHealth:Number):void
		{
			_fullHealth = fullHealth;
			this.gotoAndStop(this.totalFrames);
		}

	}

}