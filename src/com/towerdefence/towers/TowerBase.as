package com.towerdefence.towers {

import com.framework.math.*;
import com.towerdefence.Universe;
import com.towerdefence.enemies.*;
import com.towerdefence.interfaces.IGameObject;

import flash.display.MovieClip;
import flash.display.Sprite;

public class TowerBase extends Sprite implements IGameObject {

    //---------------------------------------
    // CLASS CONSTANTS
    //---------------------------------------
    public static const STATE_IDLE:uint = 1;
    public static const STATE_ATTACK:uint = 2;

    //---------------------------------------
    // PRIVATE VARIABLES
    //---------------------------------------
    protected var _universe:Universe = Universe.getInstance(); // Ссылка на игровой мир

    protected var _body:MovieClip; // Графическое тело башни
    protected var _head:MovieClip; // Графическая пушка башни

    protected var _tilePos:Avector = new Avector(); // Позиция башни в тайлах
    protected var _state:uint = STATE_IDLE; // Текущее состояние башни
    protected var _idleDelay:int = 0; // Интервал для задержки между проверками на приближение врагов

    protected var _attackRadius:Number = 100; // Радиус атаки башни
    protected var _attackInterval:Number = 8; // В кадрах (?)
    protected var _attackDamage:Number = 0.2; // Наносимый урон одним выстрелом
    protected var _bulletSpeed:Number = 100; // Скорость пули
    protected var _enemyTarget:EnemyBase; // Ссылка на атакуемого юнита
    protected var _isFree:Boolean = true;

    //---------------------------------------
    // CONSTRUCTOR
    //---------------------------------------

    /**
     * @constructor
     */
    public function TowerBase() {
        // nothing
    }

    /**
     * @destructor
     */
    public function free():void {
        // Удаляем тело
        if (_body && contains(_body)) {
            removeChild(_body);
        }

        // Удаляем башню
        if (_head && contains(_head)) {
            removeChild(_head);
        }

        // Удаляем башню из игры
        _universe.removeChild(this);
        _universe.towers.remove(this);
    }

    //---------------------------------------
    // PUBLIC METHODS
    //---------------------------------------

    /**
     * Инициализация башни перед её использованием.
     */
    public function init(tileX:int, tileY:int):void {
        if (_body != null && _head != null) {
            addChild(_body);
            addChild(_head);
        }

        _isFree = false;

        // Запоминаем положение в тайлах
        _tilePos.set(tileX, tileY);

        // Устанавливаем графический образ башни
        x = Universe.toPix(tileX);
        y = Universe.toPix(tileY);

        // Добавляем башню в игру
        _universe.towers.add(this);
        _universe.addChild(this);
    }

    /**
     * Общий метод в котором производятся расчеты для всех башен.
     */
    public function update(delta:Number):void {

    }

}

}