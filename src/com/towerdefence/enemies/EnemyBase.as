package com.towerdefence.enemies {
/**
 * EnemyBase.as
 * - базовый класс для всех врагов в игре.
 */

import com.framework.PathFinder;
import com.framework.math.*;
import com.towerdefence.Universe;
import com.towerdefence.gui.HealthBar;
import com.towerdefence.interfaces.IGameObject;

import flash.display.MovieClip;
import flash.display.Sprite;
import flash.geom.Point;

public class EnemyBase extends Sprite implements IGameObject {
    //---------------------------------------
    // CLASS CONSTANTS
    //---------------------------------------

    // Разновидности врагов
    public static const KIND_NONE:int = -1;
    public static const KIND_SOLDIER:int = 0;
    public static const KIND_JEEP:int = 1;
    public static const KIND_TANK:int = 2;
    public static const KIND_ELEPHANT:int = 3;
    public static const KIND_PACMAN:int = 4;
    // ... по мере появления новых врагов список
    // констант будет пополнятся

    //---------------------------------------
    // PUBLIC VARIABLES
    //---------------------------------------
    public var isDead:Boolean = false;

    //---------------------------------------
    // PRIVATE VARIABLES
    //---------------------------------------
    protected var _universe:Universe = Universe.getInstance();

    // Уникальные характеристики врагов
    protected var _kind:int = KIND_NONE; // Разновидность
    protected var _sprite:MovieClip; // Графический спрайт
    protected var _health:Number = 1; // Здоровье
    protected var _defSpeed:Number = 50; // Скорость
    protected var _rotationSpeed:Number = 15;
    protected var _isFree:Boolean = true;

    protected var _position:Point; // Текущее положение врага
    protected var _target:Point; // Цель куда должен прийти враг
    protected var _speed:Avector = new Avector();
    protected var _newAngle:Number = 0;
    protected var _oldAngle:Number = 0;

    protected var _way:Array; // Маршрут врага
    protected var _isWay:Boolean = false; // Определяет существование маршрута
    protected var _wayIndex:int = 0; // Текущий индекс маршрута
    protected var _wayTarget:Point; // Текущая цель
    protected var _targetPos:Avector = new Avector();

    protected var _healthBar:HealthBar = null;

    //---------------------------------------
    // CONSTRUCTOR
    //---------------------------------------

    /**
     * @constructor
     */
    public function EnemyBase() {
        // nothing
    }

    /**
     * @destructor
     */
    public function free():void {
        if (_sprite != null && contains(_sprite)) {
            removeChild(_sprite);
        }

        if (_universe.contains(_healthBar)) {
            removeChild(_healthBar);
        }

        if (_universe.contains(this)) {
            _universe.removeChild(this);
        }
        _universe.enemies.remove(this);
    }

    //---------------------------------------
    // PUBLIC METHODS
    //---------------------------------------

    /**
     * Инициализация врага перед его использованием.
     */
    public function init(posX:int, posY:int, targetX:int, targetY:int):void {
        if (_sprite != null) {
            addChild(_sprite);
        }

        // Если полоса жизни не инициализирована, создаем её
        if (_healthBar == null) {
            _healthBar = new HealthBar();
        }
        addChild(_healthBar);
        _healthBar.reset(_health); // Устанавливаем максимальное здоровье

        // Обнуляем базовые параметры
        isDead = false;
        _isFree = false;
        _speed.set(0, 0);

        // Запоминаем положение и цель врага
        _position = new Point(posX, posY);
        _target = new Point(targetX, targetY);

        // Устанавливаем положение врага в пикселях
        x = Universe.toPix(posX);
        y = Universe.toPix(posY);

        // Устанавливаем врага на карте
        _universe.enemies.add(this);
        _universe.addChild(this);

        // Ищим маршрут
        var pathFinder:PathFinder = new PathFinder(_universe.mapMask);
        pathFinder.freeCell = Universe.STATE_CELL_FREE;
        _way = pathFinder.findWay(_position, _target);

        if (_way.length == 0) {
            trace("EnemyBase::init() - Путь не найден!");
        }
        else {
            // Путь найден!
            _isWay = true;
            _wayIndex = 0; // Текущий шаг
            setNextTarget(); // Устанавливаем цель
            _sprite.rotation = _newAngle;
        }
    }

    /**
     * Общий метод в котором производятся
     * расчеты для всех врагов.
     */
    public function update(delta:Number):void {
        // Разница между текущим и новым углом разворота
        var offsetAngle:Number = _sprite.rotation - _newAngle;

        // Нормализация разницы углов
        if (offsetAngle > 180) {
            offsetAngle = -360 + offsetAngle;
        }
        else if (offsetAngle < -180) {
            offsetAngle = 360 + offsetAngle;
        }

        // Плавный разворот еденицы
        if (Math.abs(offsetAngle) < _rotationSpeed) {
            _sprite.rotation -= offsetAngle;
        }
        else if (offsetAngle > 0) {
            _sprite.rotation -= _rotationSpeed;
        }
        else {
            _sprite.rotation += _rotationSpeed;
        }

        // Если поворот спрайта изменился, перерасчитываем векторную скорость
        if (_sprite.rotation != _oldAngle) {
            _speed.asSpeed(_defSpeed, Amath.toRadians(_sprite.rotation));
            _oldAngle = _sprite.rotation;
        }
    }

    /**
     * Добавляет урон юниту.
     */
    public function addDamage(damage:Number):void {
        _healthBar.update(_health);
    }

    //---------------------------------------
    // PROTECTED METHODS
    //---------------------------------------

    /**
     * Устанавливает цель юниту.
     */
    protected function setNextTarget():void {
        if (_wayIndex == _way.length) {
            // Вес маршрут пройден
            _isWay = false;
        }
        else {
            // Новая цель
            _wayTarget = _way[_wayIndex];
            _targetPos.set(Universe.toPix(_wayTarget.x), Universe.toPix(_wayTarget.y));
            _targetPos.x += Amath.random(-10, 10);
            _targetPos.y += Amath.random(-10, 10);

            // Расчет угла между текущими координатами и следующей точкой
            //var angle:Number = Amath.getAngle(x, y, _targetPos.x, _targetPos.y);
            _newAngle = Amath.toDegrees(Amath.getAngle(x, y, _targetPos.x, _targetPos.y));

            // Установка новой скорости
            //_speed.asSpeed(_defSpeed, angle);

            // Разворот спрайта
            //_sprite.rotation = Amath.toDegrees(angle);
        }
    }

    //---------------------------------------
    // GETTER / SETTERS
    //---------------------------------------

    /**
     * Возвращает разновидность врага.
     */
    public function get kind():int {
        return _kind;
    }

}

}