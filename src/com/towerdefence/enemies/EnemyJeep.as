package com.towerdefence.enemies {
import com.framework.math.*;
import com.towerdefence.*;

public class EnemyJeep extends EnemyBase {
    //---------------------------------------
    // PRIVATE VARIABLES
    //---------------------------------------
    private var _isAttaked:Boolean = false;
    private var _calcDelay:uint = 0;

    //---------------------------------------
    // CONSTRUCTOR
    //---------------------------------------

    /**
     * @constructor
     */
    public function EnemyJeep() {
        _sprite = new Jeep_mc();
    }

    /**
     * @destructor
     */
    override public function free():void {
        if (!_isFree) {
            // Вовращаем юнита в кэш
            _universe.cacheEnemyJeep.set(this);
            super.free();
            _isFree = true;
        }
    }

    //---------------------------------------
    // PUBLIC METHODS
    //---------------------------------------

    /**
     * Инициализация врага перед его использованием.
     */
    override public function init(posX:int, posY:int, targetX:int, targetY:int):void {
        // Уникальные параметры врага
        _kind = EnemyBase.KIND_JEEP;
        _defSpeed = 70;
        _health = 1.5;
        _sprite.gotoAndStop(1);
        _isFree = false;

        super.init(posX, posY, targetX, targetY);
    }

    /**
     */
    override public function update(delta:Number):void {
        if (_isWay) {
            // Обновление угловой скорости
            /*if (_calcDelay > 10)
             {
             // Обновление угловой скорости
             var angle:Number = Amath.getAngle(x, y, _targetPos.x, _targetPos.y);
             _speed.asSpeed(_defSpeed, angle);
             _calcDelay = 0;
             }
             _calcDelay++;*/
            super.update(delta);

            // Двигаем юнита
            x += _speed.x * delta;
            y += _speed.y * delta;

            // Текущее положение
            var cp:Avector = new Avector(x, y);

            // Переходим к новому шагу если текущая цель достигнута
            // Внимание! Чем больше скорость движения врага тем больше должна быть погрешность
            if (cp.equal(_targetPos, _defSpeed / 4)) {
                // Обновляем текущие координаты в клеточках
                _position.x = Universe.toTile(x);
                _position.y = Universe.toTile(y);

                _wayIndex++;
                setNextTarget();
            }
        }

        if (_isAttaked) {
            if (_sprite.currentFrame == 1) {
                _sprite.stop();
                _isAttaked = false;
            }
        }

    }

    /**
     * @private
     */
    override public function addDamage(damage:Number):void {
        _health -= damage;

        // Вызываем метод родителя для обновления полосы жизни
        super.addDamage(damage);

        // Враг погиб
        if (_health <= 0) {
            isDead = true;
            free();
        }
        // Временный эффект атаки
        _sprite.gotoAndPlay(2);
        _isAttaked = true;
    }

}

}