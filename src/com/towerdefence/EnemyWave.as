package com.towerdefence
{
	import com.framework.math.Avector;
	
	public class EnemyWave extends Object
	{
		//---------------------------------------
		// PUBLIC VARIABLES
		//---------------------------------------
		public var startDelay:Number = 0; // Задержка перед началом вражеской волны
		
		//---------------------------------------
		// PRIVATE VARIABLES
		//---------------------------------------
		private var _universe:Universe; // Указатель на игровой мир
		private var _enemies:Array = []; // Список типа врагов в волне
		private var _enemyIndex:int = 0; // Индекс текущего врага в волне
		private var _enemy:Object = null; // Указатель на текущий объект с информацией о враге
		private var _isStarted:Boolean = false; // Флаг определяющий выполняется ли волна сейчас
		private var _interval:Number = 0; // Пройденный интервал между респавном врагов
		
		private var _respawnPoint:Avector = new Avector(); // Точка появления врагов для волны
		private var _globalTarget:Avector = new Avector(); // Общая точка цели для волны
		
		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		
		/**
		 * @constructor
		 */
		public function EnemyWave()
		{
			super();
			_universe = Universe.getInstance();
		}
		
		/**
		 * Устанавливает точку появления врагов.
		 */
		public function setRespawnPoint(tx:int, ty:int):void
		{
			_respawnPoint.set(tx, ty);
		}
		
		/**
		 * Устанавливает общую точку цели для врагов.
		 */
		public function setTargetPoint(tx:int, ty:int):void
		{
			_globalTarget.set(tx, ty);
		}
		
		/**
		 * Запускает появление врагов из волны.
		 */
		public function startWave():void
		{
			if (!_isStarted)
			{
				_enemyIndex = 0;
				_interval = startDelay;
				_isStarted = true;
			}
		}
		
		/**
		 * Добавляет вид врага в волну.
		 * 
		 * @param	kind	 Вид врага.
		 * @param	count	 Количество единиц указанного вида.
		 * @param	respawnInterval	 Задержка между появлением вражеских единиц.
		 */
		public function addEnemy(kind:uint, count:int, respawnInterval:Number, uniqueTarget:Avector = null):void
		{
			_enemies[_enemies.length] = { kind:kind, count:count, respawn:respawnInterval, uniqueTarget:uniqueTarget };
		}
		
		/**
		 * @private
		 */
		public function update(delta:Number):void
		{
			if (_isStarted)
			{
				// Уменьшаем текущий интервал
				_interval -= 10 * delta;
				// Если интервал закончился вызываем следующего врага
				if (_interval <= 0)
				{
					// Если врага взывать не удалось, волна закончилась,
					// сбрасываем флаг работы волны
					if (!nextEnemy())
					{
						_isStarted = false;
					}
				}
			}
		}
		
		/**
		 * Метод вызывает следующего врага в списке всех врагов волны.
		 * 
		 * @return		Возвращает false если список врагов закончился.
		 */
		private function nextEnemy():Boolean
		{
			// Если список врагов не закончен
			if (_enemyIndex < _enemies.length)
			{
				// Извлекаем информацию о следующем виде врага
				if (_enemy == null)
				{
					var o:Object = _enemies[_enemyIndex];
					// Копируем информацию о виде и количестве единиц врагов в новый объект
					_enemy = { kind:o.kind, count:o.count, respawn:o.respawn, uniqueTarget:o.uniqueTarget };
				}
				
				// Враг имеет уникальную цель, используем её
				if (_enemy.uniqueTarget != null)
				{
					_universe.newEnemy(_enemy.kind, _respawnPoint, _enemy.uniqueTarget);
				}
				else
				// Иначе враг не имеет уникальной цели, используем глобальную
				{
					_universe.newEnemy(_enemy.kind, _respawnPoint, _globalTarget);
				}
				
				// Устанавливаем задержку до появления следующей еденицы врага
				_interval = _enemy.respawn;
				
				// Уменьшаем количество вышедшых врагов
				_enemy.count--;
				if (_enemy.count <= 0)
				{
					// Если все единицы врагов для текущего вида созданы,
					// переходим к следущему виду врагов
					_enemyIndex++;
					_enemy = null;
				}
				
				return true;
			}
			
			return false;
		}
		
		//---------------------------------------
		// GETTER / SETTERS
		//---------------------------------------
		
		/**
		 * @private
		 */
		public function get isFinished():Boolean
		{
			return !_isStarted;
		}
		
	}

}