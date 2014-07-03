package com.towerdefence.editor
{
	import com.towerdefence.Universe;
	
	public class Brush extends Object
	{
		
		//---------------------------------------
		// PUBLIC VARIABLES
		//---------------------------------------
		public var drawMode:Boolean = false; // Вкл/выкл рисование
		public var kind:int = Universe.STATE_CELL_BUSY; // Вид ячейки в кисточке
		public var tileX:int = -1;
		public var tileY:int = -1;
		
		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		
		/**
		 * @constructor
		 */
		public function Brush()
		{
			
		}

	}

}