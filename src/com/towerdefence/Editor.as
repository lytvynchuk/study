package com.towerdefence
{

	import flash.display.Sprite;
	import flash.display.SimpleButton;
	import flash.events.*;

	import com.towerdefence.levels.*;
	import com.towerdefence.editor.Brush;
	import com.towerdefence.Universe;

	public class Editor extends Sprite 
	{
		
		//---------------------------------------
		// PRIVATE METHODS
		//---------------------------------------
		private var _universe:Universe;
		private var _levelManager:LevelManager;
		private var _currentLevel:LevelBase;
		
		private var _btnSave:SimpleButton;
		private var _btnStart:SimpleButton;
		private var _btnFinish:SimpleButton;
		private var _btnBusy:SimpleButton;
		private var _btnBuildOnly:SimpleButton;
		
		private var _brush:Brush = new Brush();
	
		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		
		/**
		 * @constructor
		 */
		public function Editor()
		{
			if (stage)
			{
				init();
			}
			else
			{
				addEventListener(Event.ADDED_TO_STAGE, init);
			}
		}
		
		/**
		 * Инициализация редактора уровней
		 */
		private function init(event:Event = null):void
		{
			// Игровой мир
			_universe = new Universe();
			_universe.editorMode(true);
			_universe.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			_universe.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			addChild(_universe);
			
			// Создаем менеджер уровней
			_levelManager = new LevelManager();
			
			// Загружаем первый уровень
			_currentLevel = _levelManager.getLevel(1);
			_currentLevel.load();
			
			// Создаем кнопку "сохранить"
			_btnSave = new Save_btn();
			_btnSave.x = _btnSave.width / 2 + 10;
			_btnSave.y = App.SCREEN_HEIGHT - _btnSave.height / 2 - 10;
			_btnSave.addEventListener(MouseEvent.CLICK, saveClickHandler);
			addChild(_btnSave);
			
			// Создаем кнопку "занята"
			_btnBusy = new Busy_btn();
			_btnBusy.x = App.SCREEN_WIDTH - _btnBusy.width / 2 - 52;
			_btnBusy.y = _btnBusy.height / 2 + 10;
			_btnBusy.addEventListener(MouseEvent.CLICK, busyHandler);
			addChild(_btnBusy);
			
			// Создаем кнопку "только для строительства"
			_btnBuildOnly = new BuildOnly_btn();
			_btnBuildOnly.x = App.SCREEN_WIDTH - _btnBuildOnly.width / 2 - 10;
			_btnBuildOnly.y = _btnBuildOnly.height / 2 + 10;
			_btnBuildOnly.addEventListener(MouseEvent.CLICK, buildOnlyHandler);
			addChild(_btnBuildOnly);
			
			// Создаем кнопку "стартовая точка"
			_btnStart = new StartPoint_btn();
			_btnStart.x = App.SCREEN_WIDTH - _btnStart.width / 2 - 52;
			_btnStart.y = _btnStart.height / 2 + 52;
			_btnStart.addEventListener(MouseEvent.CLICK, startPointHandler);
			addChild(_btnStart);
			
			// Создаем кнопку "финишная точка"
			_btnFinish = new FinishPoint_btn();
			_btnFinish.x = App.SCREEN_WIDTH - _btnFinish.width / 2 - 10;
			_btnFinish.y = _btnFinish.height / 2 + 52;
			_btnFinish.addEventListener(MouseEvent.CLICK, finishPointHandler);
			addChild(_btnFinish);
			
			// Добавляем обработчик движения мышки
			addEventListener(MouseEvent.MOUSE_MOVE, mouseEventHandler);
			
			// Удаляем обработчик метода инициализации
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		//---------------------------------------
		// PRIVATE METHODS
		//---------------------------------------
		
		/**
		 * Экспорт карты проходимости в окно output.
		 */
		private function exportToOutput():void
		{
			var mapMask:Array = _universe.mapMask;
			var mapWidth:int = mapMask[0].length;
			var mapHeight:int = mapMask.length;
			var line:String = "";
			
			for (var ay:int = 0; ay < mapHeight; ay++)
			{
				for (var ax:int = 0; ax < mapWidth; ax++)
				{
					// Для последней ячейки в строчке не ставим запятую
					if (ax == mapWidth - 1)
					{
						line += mapMask[ay][ax].toString();
					}
					else
					{
						line += mapMask[ay][ax].toString() +", ";
					}
				}
				
				// Выводим маску проходимости в формате кода 
				// инициализации нового двумерного массива
				
				// Первая строка
				if (ay == 0)
				{
					trace("_mapMask = [ [", line + "], ");
				}
				// Последняя строка
				else if (ay == mapHeight - 1)
				{
					trace("[", line + "] ];");
				}
				// Промежуточные строки
				else
				{
					trace("[", line + "],");
				}
				
				line = "";
			}
		}
		
		//---------------------------------------
		// EVENT HANDLERS
		//---------------------------------------
		
		/**
		 * Перехват координат мыши
		 */
		private function mouseEventHandler(event:MouseEvent):void
		{
			_universe.updateMousePos(event.stageX, event.stageY);
			if (_brush.drawMode)
			{
				_universe.applyBrush(_brush);
			}
		}
		
		/**
		 * Обработка клика по кнопке "save".
		 */
		private function saveClickHandler(event:MouseEvent):void
		{
			exportToOutput();
		}
		
		/**
		 * Обработка клика по кнопке "busy".
		 */
		private function busyHandler(event:MouseEvent):void
		{
			_brush.kind = Universe.STATE_CELL_BUSY;
		}
		
		/**
		 * Обработка клика по кнопке "build only".
		 */
		private function buildOnlyHandler(event:MouseEvent):void
		{
			_brush.kind = Universe.STATE_CELL_BUILD_ONLY;
		}
		
		/**
		 * Обработка клика по кнопке "start point".
		 */
		private function startPointHandler(event:MouseEvent):void
		{
			_brush.kind = Universe.STATE_CELL_START;
		}
		
		/**
		 * Обработка клика по кнопке "finish point".
		 */
		private function finishPointHandler(event:MouseEvent):void
		{
			_brush.kind = Universe.STATE_CELL_FINISH;
		}
		
		/**
		 * Обработка нажатия кнопки мышки над игровой картой.
		 */
		private function mouseDownHandler(event:MouseEvent):void
		{
			_brush.drawMode = true;
			_universe.applyBrush(_brush);
		}
		
		/**
		 * Обработка отупскания кнопки мышки над игровой картой.
		 */
		private function mouseUpHandler(event:MouseEvent):void
		{
			_brush.drawMode = false;
			_brush.tileX = -1;
			_brush.tileY = -1;
		}
	
	}
	
}