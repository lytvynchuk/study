package com.towerdefence.towers {

public class GunBullet extends BulletBase {

    //---------------------------------------
    // CONSTRUCTOR
    //---------------------------------------

    /**
     * @constructor
     */
    public function GunBullet() {
        _sprite = new GunBullet_mc();
    }

    /**
     * @private
     */
    override public function free():void {
        if (!_isFree) {
            _universe.cacheGunBullet.set(this);
            super.free();
            _isFree = true;
        }
    }

}

}