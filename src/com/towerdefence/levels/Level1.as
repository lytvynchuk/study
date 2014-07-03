package com.towerdefence.levels
{
	
	public class Level1 extends LevelBase
	{

		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		
		/**
		 * @constructor
		 */
		public function Level1()
		{
			// Игровая сетка
			_mapMask = [ [ 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3], 
			[ 3, 4, 3, 3, 3, 3, 1, 1, 1, 1, 3, 3, 3, 3, 3, 1, 3, 3, 3, 3],
			[ 3, 1, 3, 1, 1, 1, 1, 3, 3, 1, 1, 1, 1, 1, 1, 1, 1, 3, 3, 3],
			[ 3, 1, 3, 1, 3, 3, 1, 1, 3, 1, 3, 3, 3, 1, 3, 3, 1, 1, 1, 3],
			[ 3, 1, 1, 1, 3, 3, 3, 1, 3, 1, 3, 1, 1, 1, 3, 3, 3, 3, 1, 3],
			[ 3, 1, 3, 3, 3, 5, 1, 1, 3, 1, 3, 1, 3, 1, 5, 3, 1, 1, 1, 3],
			[ 3, 1, 1, 1, 3, 3, 1, 3, 3, 3, 3, 1, 1, 1, 3, 3, 3, 3, 1, 3],
			[ 3, 1, 3, 1, 3, 3, 1, 1, 3, 1, 1, 1, 3, 3, 3, 1, 1, 1, 1, 3],
			[ 3, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 3, 3, 1, 1, 1, 3, 1, 3, 3],
			[ 3, 1, 3, 3, 1, 1, 3, 3, 3, 3, 3, 3, 1, 1, 3, 1, 1, 1, 3, 3],
			[ 3, 1, 3, 3, 3, 1, 3, 3, 3, 3, 3, 3, 1, 3, 3, 3, 3, 3, 3, 3],
			[ 3, 1, 3, 3, 3, 1, 3, 1, 1, 1, 1, 3, 1, 1, 3, 3, 3, 3, 3, 3],
			[ 3, 1, 1, 3, 3, 1, 1, 1, 3, 3, 1, 3, 3, 1, 1, 3, 1, 1, 1, 3],
			[ 3, 3, 1, 1, 1, 1, 1, 3, 3, 3, 5, 3, 3, 3, 1, 1, 1, 3, 4, 3],
			[ 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3] ];
			
			// Загрузка вражеских волн и других данных из xml документа
			/*loadXML("Level1.xml");*/
			
			// Чтобы встроить содержмиое xml документа непосредственно в код, достаточно
			// присвоить содержимое документа переменой _xmlData и вызвать наш метод readXML():
			
			
			_xmlData = <levelData>
				<waves>
					<wave startDelay="10" respawnX="1" respawnY="1" targetX="14" targetY="5">
						<enemy kind="pacman" count="10" interval="1.5"></enemy>
						<enemy kind="elephant" count="12" interval="3"></enemy>
						<enemy kind="jeep" count="15" interval="6"></enemy>
						<enemy kind="soldier" count="20" interval="2"></enemy>
					</wave>
					<wave startDelay="30" respawnX="18" respawnY="13" targetX="5" targetY="5">
						<enemy kind="jeep" count="14" interval="6"></enemy>
						<enemy kind="tank" count="6" interval="12"></enemy>
						<enemy kind="tank" count="3" interval="12" targetX="10" targetY="13"></enemy>
						<enemy kind="tank" count="6" interval="12"></enemy>
						<enemy kind="jeep" count="12" interval="6"></enemy>
					</wave>
				</waves>

			</levelData>
			
			readXML();
			//
		}

		/**
		 * @inheritDoc
		 */
		override protected function onLoadingFinish():void
		{
			// Здесь могут выполнятся еще какие-то вещи после того 
			// как загрузка уровня завершена и перед тем как начнется игра.
			// ...
			
			// Запускаем игру
			_universe.startGame();
		}

	}

}