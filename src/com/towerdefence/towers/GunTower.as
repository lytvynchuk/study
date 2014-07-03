package com.towerdefence.towers {
import com.framework.math.*;
import com.towerdefence.enemies.EnemyBase;

public class GunTower extends TowerBase {

    //---------------------------------------
    // PRIVATE VARIABLES
    //---------------------------------------

    private var _shootDelay:int = 0;

    //---------------------------------------
    // CONSTRUCTOR
    //---------------------------------------

    /**
     * @constructor
     */
    public function GunTower() {
        // Индивидуальные параметры текущего вида башни
        _attackRadius = 60;
        _attackInterval = 15;
        _attackDamage = 0.2;
        _bulletSpeed = 300;

        // Графический образ
        _body = new GunTowerBody_mc();
        _head = new GunTowerHead_mc();
    }

    /**
     * @private
     */
    override public function free():void {
        if (!_isFree) {
            // Возвращаем башню в кэш
            _universe.cacheGunTower.set(this);
            super.free();
            _isFree = true;
        }
    }

    //---------------------------------------
    // PUBLIC METHODS
    //---------------------------------------

    /**
     * Инициализация башни пушки.
     */
    override public function init(tileX:int, tileY:int):void {
        super.init(tileX, tileY);
        debugDraw();
    }

    /**
     * @private
     */
    override public function update(delta:Number):void {
        switch (_state) {
            //-----------------------------------------------------------------
            // Состояние наблюдения за врагами
            case TowerBase.STATE_IDLE :
                if (_idleDelay >= 5) {
                    // Указатель на список всех врагов
                    var enemies:Array = _universe.enemies.objects;
                    // Количество врагов в списке
                    var n:int = enemies.length;
                    // Текущий враг из списка
                    var enemy:EnemyBase;

                    // Перебираем всех врагов в списке
                    for (var i:int = 0; i < n; i++) {
                        enemy = enemies[i]; // Текущий враг

                        // Если дистанция от врага до башни меньше
                        // или равна радиусу атаки башни, значит атакуем врага!
                        if (Amath.distance(enemy.x, enemy.y, this.x, this.y) <= _attackRadius) {
                            // Устанавливаем атакуемую цель
                            _enemyTarget = enemy;
                            // Переключаемся в состояние атаки
                            _state = TowerBase.STATE_ATTACK;
                            break;
                        }
                    }
                }
                _idleDelay++;
                break;

            //-----------------------------------------------------------------
            // Атака!
            case TowerBase.STATE_ATTACK :
                if (_enemyTarget != null) {
                    // Поворачиваем башню в сторону врага
                    _head.rotation = Amath.getAngleDeg(this.x, this.y, _enemyTarget.x, _enemyTarget.y);

                    // Враг умер
                    if (_enemyTarget.isDead) {
                        //_enemyTarget.free();
                        _enemyTarget = null;
                        _state = TowerBase.STATE_IDLE;
                    }
                    // Враг убежал
                    else if (Amath.distance(_enemyTarget.x, _enemyTarget.y, this.x, this.y) > _attackRadius) {
                        _enemyTarget = null;
                        _state = TowerBase.STATE_IDLE;
                    }
                    // Атакуем
                    else {
                        _shootDelay--;
                        if (_shootDelay <= 0) {
                            shoot();
                            _shootDelay = _attackInterval;
                        }
                    }
                }
                else {
                    _state = TowerBase.STATE_IDLE;
                }
                break;
        }
    }

    //---------------------------------------
    // PRIVATE METHODS
    //---------------------------------------

    /**
     * @private
     */
    private function shoot():void {
        var bullet:GunBullet = _universe.cacheGunBullet.get() as GunBullet;
        bullet.damage = _attackDamage; // Передаем урон башней для пули
        bullet.init(this.x, this.y, _bulletSpeed, _head.rotation); // Инициализируем пулю
    }

    /**
     * Отладочный метод, рисует радиус действия башни.
     */
    private function debugDraw():void {
        graphics.lineStyle(1, 0x9fc635, .10);
        graphics.beginFill(0x9fc635, .02);
        graphics.drawCircle(0, 0, _attackRadius);
        graphics.endFill();
    }

}

}