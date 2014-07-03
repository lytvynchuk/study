package com.towerdefence.levels
{
	
	public class LevelManager extends Object
	{
		//---------------------------------------
		// CLASS CONSTANTS
		//---------------------------------------
		public static const TOTAL_LEVELS:int = 1;
		
		//---------------------------------------
		// PRIVATE VARIABLES
		//---------------------------------------
		private var _completed:int = 1; // Кол-во пройденных уровней
		
		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		
		/**
		 * @constructor
		 */
		public function LevelManager()
		{
			
		}
		
		//---------------------------------------
		// PUBLIC METHODS
		//---------------------------------------
		
		/**
		 * Загружает указанный уровень
		 */
		public function getLevel(levelId:int):LevelBase
		{
			if (levelId < 0 || levelId > TOTAL_LEVELS)
			{
				trace("LevelManager::getLevel() - Уровня", levelId, "не существует!");
				return null;
			}
			
			switch (levelId)
			{
				case 1 :
					return new Level1();
				break;
				
				default :
					return null;
				break;
			}
		}

	}

}