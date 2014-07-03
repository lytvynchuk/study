package com.towerdefence.levels {
import com.framework.math.Avector;
import com.towerdefence.EnemyWave;
import com.towerdefence.Universe;
import com.towerdefence.enemies.EnemyBase;

import flash.events.Event;
import flash.net.URLLoader;
import flash.net.URLRequest;

/**
 * Подробно про работу с XML в AS3 можно почитать здесь:
 * http://www.republicofcode.com/tutorials/flash/as3xml/
 */

public class LevelBase extends Object {

    //---------------------------------------
    // PROTECTED VARIABLES
    //---------------------------------------
    protected var _universe:Universe = Universe.getInstance();
    protected var _mapMask:Array;

    protected var _xmlData:XML; // Данные XML
    protected var _xmlLoader:URLLoader; // Загрузчик внешних файлов

    //---------------------------------------
    // CONSTRUCTOR
    //---------------------------------------

    /**
     * @constructor
     */
    public function LevelBase() {
        // ..
    }

    //---------------------------------------
    // PUBLIC METHODS
    //---------------------------------------

    /**
     * @private
     */
    public function loadXML(fileName:String):void {
        _xmlLoader = new URLLoader();
        _xmlLoader.load(new URLRequest(fileName));
        _xmlLoader.addEventListener(Event.COMPLETE, xmlLoadCompleteHandler);
    }

    /**
     * Обработчик завершения загрузки xml документа.
     */
    protected function xmlLoadCompleteHandler(event:Event):void {
        _xmlLoader.removeEventListener(Event.COMPLETE, xmlLoadCompleteHandler);

        // Парсинг загруженной информации
        _xmlData = new XML(event.target.data);

        // Чтение xml документа
        readXML();
    }

    /**
     * Разбор xml документа.
     */
    protected function readXML():void {
        // Количество вражеских волн на уровень
        var numWaves:int = _xmlData.waves.length() + 1;
        // Количество врагов в текущей волне
        var numEnemies:int = 0;
        // Переменная для новой волны
        var wave:EnemyWave;
        // Указатель на текущую волну в xml документе
        var xmlWave:XML;
        // Указатель на текущего врага в xml документе
        var xmlEnemy:XML;
        // Уникальная цель для отдельных врагов
        var uniqueTarget:Avector = null;

        // Перебираем все волны
        for (var i:int = 0; i < numWaves; i++) {
            // Сохраняем указатель на текущую волну
            xmlWave = _xmlData.waves.wave[i] as XML;

            // Создаем новую волну и устанавливаем данные из xml
            wave = new EnemyWave();
            wave.startDelay = int(xmlWave.@startDelay);
            wave.setRespawnPoint(int(xmlWave.@respawnX), int(xmlWave.@respawnY));
            wave.setTargetPoint(int(xmlWave.@targetX), int(xmlWave.@targetY));

            // Добавляем врагов из xml в волну
            numEnemies = xmlWave.*.length(); // Количество врагов в волне
            for (var j:int = 0; j < numEnemies; j++) {
                // Сохраняем указатель на текущего врага
                xmlEnemy = xmlWave.enemy[j] as XML;

                // Проверка наличия уникальной цели у текущего врага
                if (int(xmlEnemy.@targetX) != 0 && int(xmlEnemy.@targetY) != 0) {
                    uniqueTarget = new Avector(int(xmlEnemy.@targetX), int(xmlEnemy.@targetY));
                }
                else {
                    uniqueTarget = null;
                }

                wave.addEnemy(getKind(xmlEnemy.@kind), int(xmlEnemy.@count), int(xmlEnemy.@interval), uniqueTarget);
            }

            // Добавляем волну в игровой мир
            _universe.addWave(wave);
        }

        // Загрузка уровня завершена
        onLoadingFinish();
    }

    /**
     * Выполняется при завершении загрузки xml документа.
     */
    protected function onLoadingFinish():void {
        // Этот метод нужен для потомков чтобы они могли узнать когда
        // завершится загрузка уровня.
        // ...
    }

    /**
     * Конвертирует текстовое представление вражеской еденицы в числовое.
     *
     * @param kindName Текстовое представления вида вражеской еденицы.
     * @return Тип вражеской еденицы.
     */
    public function getKind(kindName:String):int {
        switch (kindName) {
            case "soldier" :
                return EnemyBase.KIND_SOLDIER;
                break;
            case "jeep" :
                return EnemyBase.KIND_JEEP;
                break;
            case "tank" :
                return EnemyBase.KIND_TANK;
                break;
            case "elephant" :
                return EnemyBase.KIND_ELEPHANT;
                break;
            case "pacman" :
                return EnemyBase.KIND_PACMAN;
                break;
        }

        return EnemyBase.KIND_SOLDIER;
    }

    /**
     * Загружает уровень в игровой мир.
     */
    public function load():void {
        _universe.mapMask = _mapMask;
    }

    /**
     * Выполняет рестарт уровня.
     */
    public function restart():void {

    }

}

}