package com.framework {
public class SimpleCache extends Object {
    //---------------------------------------
    // PRIVATE VARIABLES
    //---------------------------------------
    protected var _targetClass:Class;
    protected var _currentIndex:int;
    protected var _instances:Array;

    //---------------------------------------
    // CONSTRUCTOR
    //---------------------------------------

    /**
     * @constructor
     */
    public function SimpleCache(targetClass:Class, initialCapacity:uint) {
        _targetClass = targetClass; // Базовый класс всех объектов
        _currentIndex = initialCapacity - 1; // Базовая вместимость обоймы
        _instances = []; // Список объектов

        // Заполняем обойму
        for (var i:int = 0; i < initialCapacity; i++) {
            _instances[i] = getNewInstance();
        }
    }

    //---------------------------------------
    // PUBLIC METHODS
    //---------------------------------------

    /**
     * Берет свободный объект из кэша.
     */
    public function get():Object {
        if (_currentIndex >= 0) {
            // Возвращаем свободный объект из кэша
            _currentIndex--;
            return _instances[_currentIndex + 1];
        }
        else {
            // Если обойма опустошена то экстренно создаем новый объект
            return getNewInstance();
        }
    }

    /**
     * Возвращает отработавший объект в кэш.
     *
     * @param instance - освободившийся объект.
     */
    public function set(instance:Object):void {
        _currentIndex++;
        // Если обойма переполнена
        if (_currentIndex == _instances.length) {
            // То помещаем в конец массива как новый элемент
            _instances[_instances.length] = instance;
        }
        else {
            // Помещаем в свободную ячеку массива
            _instances[_currentIndex] = instance;
        }
    }

    //---------------------------------------
    // PROTECTED METHODS
    //---------------------------------------

    /**
     *    Создает новый объект.
     *    @return Object
     */
    protected function getNewInstance():Object {
        return (new _targetClass());
    }

    //---------------------------------------
    // GETTER / SETTERS
    //---------------------------------------

    /**
     * @private
     */
    public function get size():int {
        return _currentIndex + 1;
    }

}
}