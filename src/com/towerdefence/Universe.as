package com.towerdefence {

import com.framework.SimpleCache;
import com.framework.math.*;
import com.towerdefence.controllers.ObjectController;
import com.towerdefence.editor.Brush;
import com.towerdefence.enemies.*;
import com.towerdefence.towers.*;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.*;
import flash.utils.getTimer;

public class Universe extends Sprite {

    //---------------------------------------
    // CLASS CONSTANTS
    //---------------------------------------

    // Максимальный размер карты по ширине и высоте в клетках
    public static const MAP_WIDTH_MAX:int = 20;
    public static const MAP_HEIGHT_MAX:int = 15;

    // Размер ячейки в пикселях
    public static const MAP_CELL_SIZE:int = 32;
    public static const MAP_CELL_HALF:int = 16;

    // Состояние ячеек карты проходимости
    public static const STATE_CELL_FREE:int = 1;
    public static const STATE_CELL_BUSY:int = 2;
    public static const STATE_CELL_BUILD_ONLY:int = 3;
    public static const STATE_CELL_START:int = 4;
    public static const STATE_CELL_FINISH:int = 5;

    //---------------------------------------
    // PUBLIC VARIABLES
    //---------------------------------------
    public var mousePosX:int = 0;
    public var mousePosY:int = 0;

    public var cellPosX:int = 0;
    public var cellPosY:int = 0;

    public var towers:ObjectController;
    public var enemies:ObjectController;
    public var bullets:ObjectController;

    public var cacheEnemySoldier:SimpleCache;
    public var cacheEnemyJeep:SimpleCache;
    public var cacheEnemyTank:SimpleCache;
    public var cacheGunTower:SimpleCache;
    public var cacheGunBullet:SimpleCache;
    public var cacheEnemyElephant:SimpleCache;
    public var cacheEnemyPacman:SimpleCache;

    //---------------------------------------
    // PRIVATE VARIABLES
    //---------------------------------------
    private static var _instance:Universe;

    private var _mapMask:Array;
    private var _debugGrid:Bitmap;
    private var _currentCell:MovieClip;

    private var _startPoints:Array = [];
    private var _finishPoints:Array = [];

    private var _deltaTime:Number = 0; // Текущее delta время
    private var _lastTick:int = 0; // Последний тик таймера (для расчета нового delta времени)
    private var _maxDeltaTime:Number = 0.03;

    private var _isStarted:Boolean = false;
    private var _isEditor:Boolean = false;

    private var _waves:Array = []; // Список всех вражеских волн на текущем уровне
    private var _waveIndex:int = 0; // Индекс текущей вражеской волны в списке
    private var _currentWave:EnemyWave = null; // Указатель на экземпляр класса текущей вражеской волны

    //---------------------------------------
    // CONSTRUCTOR
    //---------------------------------------

    /**
     * @constructor
     */
    public function Universe() {
        // Класс мира создается в единственном экземпляре и
        // ссылка на него хранится в приватной статической переменной.
        // При попытки создать второй экземпляр мира сообщаем об ошибке.
        if (_instance != null) {
            throw new Error("Error: Мир уже существует. Используйте Universe.getInstance();");
        }

        // Ссылка на экземпляр мира
        _instance = this;

        _debugGrid = new Bitmap();
        addChild(_debugGrid);

        _currentCell = new CurrentCell_mc();
        addChild(_currentCell);

        towers = new ObjectController();
        enemies = new ObjectController();
        bullets = new ObjectController();

        cacheEnemySoldier = new SimpleCache(EnemySoldier, 50);
        cacheEnemyJeep = new SimpleCache(EnemyJeep, 10);
        cacheEnemyTank = new SimpleCache(EnemyTank, 10);
        cacheGunTower = new SimpleCache(GunTower, 20);
        cacheGunBullet = new SimpleCache(GunBullet, 50);
        cacheEnemyElephant = new SimpleCache(EnemyElephant, 50);
        cacheEnemyPacman = new SimpleCache(EnemyPacman, 45);
        /*var tower:GunTower = new GunTower();
         tower.init(2, 1);

         tower = new GunTower();
         tower.init(2, 3);*/

        // Временная инициализация двух вражеских волн
        /*var wave:EnemyWave = new EnemyWave();
         wave.startDelay = 10;
         wave.setRespawnPoint(1, 1);
         wave.setTargetPoint(14, 5);
         wave.addEnemy(EnemyBase.KIND_JEEP, 5 + 10, 6);
         wave.addEnemy(EnemyBase.KIND_SOLDIER, 10 + 10, 2);
         _waves.push(wave);

         wave = new EnemyWave();
         wave.startDelay = 30;
         wave.setRespawnPoint(18, 13);
         wave.setTargetPoint(5, 5);
         wave.addEnemy(EnemyBase.KIND_JEEP, 14, 6);
         wave.addEnemy(EnemyBase.KIND_TANK, 6, 12);
         wave.addEnemy(EnemyBase.KIND_TANK, 3, 12, new Avector(10, 13));
         wave.addEnemy(EnemyBase.KIND_TANK, 6, 12);
         wave.addEnemy(EnemyBase.KIND_JEEP, 12, 6);
         _waves.push(wave);
         _waveIndex = 0;*/

        // Добавляем основной обработчик мира
        addEventListener(Event.ENTER_FRAME, enterFrameHandler);
    }

    //---------------------------------------
    // PRIVATE METHODS
    //---------------------------------------

    /**
     * Создает отладочную сетку карты проходимости.
     */
    private function updateDebugGrid():void {
        // Графический образ ячейки
        var cellSprite:MovieClip = new DebugCell_mc();

        // Растровый холст для рисования сетки
        var bmpData:BitmapData = new BitmapData(MAP_CELL_SIZE * MAP_WIDTH_MAX,
                        MAP_CELL_SIZE * MAP_HEIGHT_MAX, true, 0x00000000);

        // Начальное положение текущей ячейки по высоте/ширине
        var matrix:Matrix = new Matrix();
        matrix.tx = MAP_CELL_HALF;
        matrix.ty = MAP_CELL_HALF;

        // Двигаемся по высоте карты
        for (var ay:int = 0; ay < MAP_HEIGHT_MAX; ay++) {
            // Двигаемся по ширине карты
            for (var ax:int = 0; ax < MAP_WIDTH_MAX; ax++) {
                // Переключаем состояние ячейки
                cellSprite.gotoAndStop(getCellState(ax, ay));

                // Рисуем текущую ячейку
                bmpData.draw(cellSprite, matrix);

                // Меняем положение текущей ячейки по ширине
                matrix.tx += MAP_CELL_SIZE;
            }

            // Меняем положение текущей ячейки по высоте
            matrix.ty += MAP_CELL_SIZE;
            // Обнуляем ширину
            matrix.tx = MAP_CELL_HALF;
        }

        // Передаем растровый холст в картинку
        _debugGrid.bitmapData = bmpData;

        cellSprite = null;
    }

    /**
     * Создает/очишает карту проходимости.
     */
    private function clearMapMask():void {
        // Создаем новый массив
        _mapMask = [];
        _mapMask.length = MAP_HEIGHT_MAX;

        // Двигаемся по высоте карты
        for (var ay:int = 0; ay < MAP_HEIGHT_MAX; ay++) {
            // Добавляем новую строку в массив
            _mapMask[ay] = [];
            _mapMask[ay].length = MAP_WIDTH_MAX;

            // Двигаемся по ширине карты
            for (var ax:int = 0; ax < MAP_WIDTH_MAX; ax++) {
                // Задаем ячеке свободное состояние
                _mapMask[ay][ax] = STATE_CELL_FREE;
            }
        }
    }

    //---------------------------------------
    // PUBLIC METHODS
    //---------------------------------------

    /**
     * Добавляет новую вражекскую волну в список волн.
     *
     * @param    wave     Вражеская волна.
     */
    public function addWave(wave:EnemyWave):void {
        _waves[_waves.length] = wave;
    }

    /**
     * Очищает список вражеских волн.
     */
    public function clearWaves():void {
        _waves.length = 0;
        _waveIndex = 0;
    }

    /**
     * Запускает игровой процесс.
     */
    public function startGame():void {
        if (!_isStarted) {
            _waveIndex = 0;
            _isStarted = true;
        }
    }

    /**
     * Останавливает игровой процесс.
     */
    public function stopGame():void {
        if (_isStarted) {
            _isStarted = false;
        }
    }

    /**
     * Обновляет координаты мышки.
     */
    public function updateMousePos(mouseX:int, mouseY:int):void {
        mousePosX = mouseX;
        mousePosY = mouseY;

        // Координаты тайла, над которым находится курсор мыши
        cellPosX = int(mouseX / MAP_CELL_SIZE);
        cellPosY = int(mouseY / MAP_CELL_SIZE);

        // Подсветка текущего тайла
        _currentCell.x = MAP_CELL_HALF + cellPosX * MAP_CELL_SIZE;
        _currentCell.y = MAP_CELL_HALF + cellPosY * MAP_CELL_SIZE;
    }

    /**
     * Возвращает состояние указанной
     * клетки в карте проходимости.
     */
    public function getCellState(ax:int, ay:int):int {
        // Проверка на выход за приделы массива
        if (ax >= 0 && ax < MAP_WIDTH_MAX &&
                ay >= 0 && ay < MAP_HEIGHT_MAX) {
            return _mapMask[ay][ax];
        }
        else {
            return STATE_CELL_BUSY;
        }
    }

    /**
     * Устанавливает состояние указанной
     * клетке в карте проходимости.
     */
    public function setCellState(ax:int, ay:int, state:int = STATE_CELL_FREE):void {
        // Проверка на выход за приделы массива
        if (ax >= 0 && ax < MAP_WIDTH_MAX &&
                ay >= 0 && ay < MAP_HEIGHT_MAX) {
            _mapMask[ay][ax] = state;
        }
    }

    /**
     * Создает нового врага (debug).
     */
    public function newEnemy(kind:int, respawn:Avector, target:Avector):void {
        // Создание врага в зависимости от указанного типа
        var enemy:EnemyBase = null;
        switch (kind) {
            case EnemyBase.KIND_SOLDIER :
                enemy = cacheEnemySoldier.get() as EnemySoldier;
                break;

            case EnemyBase.KIND_JEEP :
                enemy = cacheEnemyJeep.get() as EnemyJeep;
                break;

            case EnemyBase.KIND_TANK :
                enemy = cacheEnemyTank.get() as EnemyTank;
                break;

            case EnemyBase.KIND_ELEPHANT :
                enemy = cacheEnemyElephant.get() as EnemyElephant;
                break;

            case EnemyBase.KIND_PACMAN :
                enemy = cacheEnemyPacman.get() as EnemyPacman;
                break;
        }

        if (enemy != null) {
            // Выбираем случайную стартовую точку и финишную
            //var startPos:Avector = _startPoints[Amath.random(1, _startPoints.length) - 1];
            //var finishPos:Avector = _finishPoints[Amath.random(1, _finishPoints.length) - 1];

            // Инициализируем юнита с выбранными точками
            //enemy.init(startPos.x, startPos.y, finishPos.x, finishPos.y);
            enemy.init(respawn.x, respawn.y, target.x, target.y);
        }
    }

    /**
     * Переводит значение из пикселей в тайлы.
     */
    public static function toTile(value:Number):int {
        return int(value / MAP_CELL_SIZE);
    }

    /**
     * Переводит значение из тайлов в пиксели.
     */
    public static function toPix(value:int):Number {
        return MAP_CELL_HALF + value * MAP_CELL_SIZE;
    }

    /**
     * Применяет свойства кисточки к карте.
     */
    public function applyBrush(brush:Brush):void {
        // Рисуем только если изменилось положение кисти
        if (brush.tileX != cellPosX || brush.tileY != cellPosY) {
            // Если ячейка занята то освобождаем её
            var cellState:int = getCellState(cellPosX, cellPosY);
            if (cellState != STATE_CELL_FREE && cellState == brush.kind) {
                setCellState(cellPosX, cellPosY, STATE_CELL_FREE);
            }
            else {
                setCellState(cellPosX, cellPosY, brush.kind);
            }

            brush.tileX = cellPosX;
            brush.tileY = cellPosY;
            updateDebugGrid();
        }
    }

    /**
     * @private
     */
    public function buildTower():void {
        if (getCellState(cellPosX, cellPosY) != STATE_CELL_BUSY) {
            var tower:GunTower = cacheGunTower.get() as GunTower;
            tower.init(cellPosX, cellPosY);
            setCellState(cellPosX, cellPosY, STATE_CELL_BUSY);
            updateDebugGrid();
        }
    }

    //---------------------------------------
    // PRIVATE METHODS
    //---------------------------------------

    /**
     * Создает список стартовых и финишных
     * точек на основе карты проходимости.
     */
    public function preparePoints():void {
        // Очищаем списки
        _startPoints.length = 0;
        _finishPoints.length = 0;

        // Перебераем карту проходимости и создаем новые точки
        for (var ty:int = 0; ty < _mapMask.length; ty++) {
            for (var tx:int = 0; tx < _mapMask[0].length; tx++) {
                switch (_mapMask[ty][tx]) {
                    // Стартовая точка
                    case STATE_CELL_START :
                        _startPoints.push(new Avector(tx, ty));
                        if (!_isEditor) {
                            _mapMask[ty][tx] = STATE_CELL_FREE;
                        }
                        break;

                    // Финишная точка
                    case STATE_CELL_FINISH :
                        _finishPoints.push(new Avector(tx, ty));
                        if (!_isEditor) {
                            _mapMask[ty][tx] = STATE_CELL_FREE;
                        }
                        break;
                }
            }
        }

    }

    //---------------------------------------
    // EVENT HANDLERS
    //---------------------------------------

    /**
     * Обработка всех динамических объектов.
     */
    private function enterFrameHandler(event:Event):void {
        // Рассчет delta времени
        _deltaTime = (getTimer() - _lastTick) / 1000;
        _deltaTime = (_deltaTime > _maxDeltaTime) ? _maxDeltaTime : _deltaTime;

        if (_isStarted) {
            enemies.update(_deltaTime);
            towers.update(_deltaTime);
            bullets.update(_deltaTime);
            updateWaves(_deltaTime);
        }

        _lastTick = getTimer();
    }

    /**
     * @private
     */
    private function updateWaves(delta:Number):void {
        // Обновление текущей вражеской волны
        if (_currentWave == null) {
            // Если волна не задана, выбираем новую из списка по индексу
            _currentWave = _waves[_waveIndex] as EnemyWave;
            _currentWave.startWave();
        }
        else {
            // Обновляем вражескую волну
            _currentWave.update(_deltaTime);
            if (_currentWave.isFinished) {
                // Если текущая вражеская волна закончилась, увеличиваем индекс волны
                // и сбрасываем текущую волну. Если все волны в списке были выполнены,
                // то переходим в начало списка всех волн и процесс выполняется по кругу
                _waveIndex = (_waveIndex + 1 >= _waves.length) ? 0 : _waveIndex + 1;
                _currentWave = null;
            }
        }
    }

    //---------------------------------------
    // GETTER / SETTERS
    //---------------------------------------

    /**
     * Возвращает ссылку на экземпляр мира,
     * доступно в любом классе приложения.
     */
    public static function getInstance():Universe {
        return (_instance == null) ? new Universe() : _instance;
    }

    /**
     * Устанавливает режим редактора.
     */
    public function editorMode(value:Boolean):void {
        _isEditor = value;
    }

    /**
     * Возвращает карту проходимости.
     */
    public function get mapMask():Array {
        return _mapMask;
    }

    /**
     * Устанавливает карту проходимости.
     */
    public function set mapMask(value:Array):void {
        _mapMask = value;
        preparePoints();
        updateDebugGrid();
    }

}

}