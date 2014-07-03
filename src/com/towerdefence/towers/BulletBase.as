package com.towerdefence.towers {
import com.framework.math.*;
import com.towerdefence.App;
import com.towerdefence.Universe;
import com.towerdefence.enemies.EnemyBase;
import com.towerdefence.interfaces.IGameObject;

import flash.display.Sprite;

public class BulletBase extends Sprite implements IGameObject {
    //---------------------------------------
    // PUBLIC VARIABLES
    //---------------------------------------
    public var damage:Number = 0.1;

    //---------------------------------------
    // PRIVATE VARIABLES
    //---------------------------------------
    protected var _universe:Universe = Universe.getInstance();
    protected var _sprite:Sprite;
    protected var _speed:Avector = new Avector;
    protected var _isFree:Boolean = true;

    //---------------------------------------
    // CONSTRUCTOR
    //---------------------------------------

    /**
     * @constructor
     */
    public function BulletBase() {
        // nothing
    }

    /**
     * @destructor
     */
    public function free():void {
        if (_sprite && contains(_sprite)) {
            removeChild(_sprite);
        }

        _universe.removeChild(this);
        _universe.bullets.remove(this);
    }

    //---------------------------------------
    // PUBLIC METHODS
    //---------------------------------------

    /**
     * Инициализация пули перед её использованием.
     */
    public function init(ax:int, ay:int, speed:Number, angle:Number):void {
        // Добавляем спрайт пули
        if (_sprite) {
            addChild(_sprite);
        }

        // Устанавливаем пулю
        this.x = ax;
        this.y = ay;

        // Устаналиваем скорость пули
        _speed.asSpeed(speed, Amath.toRadians(angle));

        // Добавляем пулю в игровой мир
        _universe.bullets.add(this);
        _universe.addChild(this);
        _isFree = false;
    }

    /**
     * Обновление пули.
     */
    public function update(delta:Number):void {
        this.x += _speed.x * delta;
        this.y += _speed.y * delta;

        // Если пуля улетела за приделы экрана
        if (this.x < 0 || this.x > App.SCREEN_WIDTH ||
                this.y < 0 || this.y > App.SCREEN_HEIGHT) {
            free();
            return;
        }

        // Список врагов
        var enemies:Array = _universe.enemies.objects;
        // Количество врагов
        var n:int = enemies.length;
        // Текущий враг
        var enemy:EnemyBase;
        // Дистанция между текущим врагом и пулей
        var dist:Number;

        for (var i:int = 0; i < n; i++) {
            enemy = enemies[i];
            dist = Amath.distance(this.x, this.y, enemy.x, enemy.y);
            // Если дистанция между врагом и пулей меньше или равна
            // сумме радиусов юнита и пули, значит они сталкиваются
            if (dist <= this.width * .5 + enemy.width * .5) {
                enemy.addDamage(damage); // Наносим урон врагу
                free(); // Удаляем пулю
                break;
            }
        }
    }

}

}