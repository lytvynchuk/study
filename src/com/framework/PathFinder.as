package com.framework
{
	
	import flash.geom.Point;
	
	public class PathFinder
	{
		
		//---------------------------------------
		// CLASS CONSTANTS
		//---------------------------------------
		// Уникальный номер воды которым заполняется копия маски проходимости
		private static const WATER_KEY:int = 999;
		
		//---------------------------------------
		// PRIVATE VARIABLES
		//---------------------------------------
		private var _mapMask:Array = []; // Копия маски карты
		private var _mapDirs:Array = []; // Направления
		private var _mapWidth:int = 0; // Ширина карты
		private var _mapHeight:int = 0; // Высота карты
		
		private var _freeCell:int = -1; // Вид свободной ячейки
		private var _maxIterations:int = 500; // Счетчик повторов
		
		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		
		/**
		 * @constructor
		 */
		public function PathFinder(mapArr:Array)
		{
			// Копируем маску мира
			// И заполняем массив направлений нулевыми координатами
			var rowMask:Array; // Строка для карты
			var rowDirs:Array; // Строка для направлений
			_mapWidth = mapArr[0].length; // Ширина карты
			_mapHeight = mapArr.length; // Высота карты
			
			for (var y:int = 0; y < _mapHeight; y++)
			{
				// Новые строки
				rowMask = []; 
				rowDirs = [];
				for (var x:int = 0; x < _mapWidth; x++)
				{
					rowMask.push(mapArr[y][x]); // Копируем состояние клетки
					rowDirs.push(new Point()); // Создаем нулевую коордианту направления
				}
				_mapMask.push(rowMask);
				_mapDirs.push(rowDirs);
			}
		}
		
		//---------------------------------------
		// PUBLIC METHODS
		//---------------------------------------
		
		/**
		 * Ищет путь и возвращает массив направлений.
		 */
		public function findWay(start:Point, end:Point):Array /* of Point */
		{
			// Устанавливаем точку куда льем "воду"
			_mapMask[end.y][end.x] = WATER_KEY;
			
			// info чтобы не тратить время потом на инвертирование направлений,
			// мы "льем воду" сразу в конец маршрута и таким образом у нас будет
			// массив направлений в нужном порядке
			
			var counter:int = 0; // Счетчик проходов по карте
			
			// Выполняем проходы по карте
			while (counter < _maxIterations)
			{
				// Ищим путь / размазываем воду по маске проходимости
				for (var y:int = 0; y < _mapHeight; y++)
				{
					for (var x:int = 0; x < _mapWidth; x++)
					{
						// Если в текущей ячейке вода 
						if (_mapMask[y][x] == WATER_KEY) 
						{
							goWater(x, y); // то распространяем её в соседние ячейки
						}
					}
				}
				
				// Проверяем не попала-ли вода в точку финиша
				if (_mapMask[start.y][start.x] == WATER_KEY)
				{
					// Ура путь найден!
					return getWay(start, end);
				}
				
				counter++;
			}
			
			// Количество проходов исчерпано, путь не найден
			// Возвращаем пустой массив
			return [];
		}
		
		//---------------------------------------
		// PRIVATE METHODS
		//---------------------------------------
		
		/**
		 * Распространяет воду из текущей клетки в соседнии.
		 */
		private function goWater(ax:int, ay:int):void
		{
			// Если клеточка сверху свободна
			if (inMap(ax, ay - 1) && _mapMask[ay - 1][ax] == _freeCell)
			{
				_mapMask[ay - 1][ax] = WATER_KEY; // Заполняем её водой
				// Запоминаем из какой клетки вода пришла
				(_mapDirs[ay - 1][ax] as Point).x = ax;
				(_mapDirs[ay - 1][ax] as Point).y = ay;
			}
			
			// Если клеточка слева свободна
			if (inMap(ax + 1, ay) && _mapMask[ay][ax + 1] == _freeCell)
			{
				_mapMask[ay][ax + 1] = WATER_KEY; // Заполняем её водой
				// Запоминаем из какой клетки вода пришла
				(_mapDirs[ay][ax + 1] as Point).x = ax;
				(_mapDirs[ay][ax + 1] as Point).y = ay;
			}
			
			// Если клеточка снизу свободна
			if (inMap(ax, ay + 1) && _mapMask[ay + 1][ax] == _freeCell)
			{
				_mapMask[ay + 1][ax] = WATER_KEY; // Заполняем её водой
				// Запоминаем из какой клетки вода пришла
				(_mapDirs[ay + 1][ax] as Point).x = ax;
				(_mapDirs[ay + 1][ax] as Point).y = ay;
			}
				
			// Есле клеточка справа свободна
			if (inMap(ax - 1, ay) && _mapMask[ay][ax - 1] == _freeCell)
			{
				_mapMask[ay][ax - 1] = WATER_KEY; // Заполняем её водой
				// Запоминаем из какой клетки вода пришла
				(_mapDirs[ay][ax - 1] as Point).x = ax;
				(_mapDirs[ay][ax - 1] as Point).y = ay;
			}
		}
		
		/**
		 * Проверяет выход за приделы карты.
		 */
		private function inMap(ax:int, ay:int):Boolean
		{
			if (ax >= 0 && ay < _mapWidth && ay >= 0 && ay < _mapHeight)
			{
				return true;
			}
			else
			{
				return false;
			}
		}
		
		/**
		 * Возвращает путь от точки start до точки end.
		 */
		private function getWay(start:Point, end:Point):Array /* of Point */
		{
			var way:Array = [];
			var p1:Point = new Point(start.x, start.y);
			var p2:Point = new Point();
			var errorCounter:int = 0;
			
			// Добавляем в маршрут первую точку
			//way.push(new Point(start.x, start.y));
			
			// Добавляем в маршрут все остальные точки
			// пока не дойдем до конца
			while (true)
			{
				p2.x = (_mapDirs[p1.y][p1.x] as Point).x; // Получаем новую точку из направления предыдущей
				p2.y = (_mapDirs[p1.y][p1.x] as Point).y;
				
				way.push(new Point(p2.x, p2.y)); // Добавляем новую точку в маршрут
				p1.x = p2.x;
				p1.y = p2.y;
				
				// Проверяем не добрались ли до конца
				if (p1.x == end.x && p1.y == end.y)
				{
					break;
				}
				
				errorCounter++;
				if (errorCounter > 1000)
				{
					throw new Error("Can't build reverse of the path.");
				}
			}
			return way;
		}
		
		//---------------------------------------
		// GETTER / SETTERS
		//---------------------------------------
				
		/**
		 * Устанавливает вид свободной ячейки.
		 */
		public function set freeCell(value:int):void
		{
			_freeCell = value;
		}
		
		/**
		 * Устанавливает кол-во проходов по карте.
		 */
		public function set maxIterations(value:int):void
		{
			_maxIterations = value;
		}

	}

}