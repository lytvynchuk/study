package com.towerdefence.controllers
{	
	import com.towerdefence.interfaces.IGameObject;
	import com.towerdefence.Universe;
	
	public class ObjectController extends Object
	{
		//---------------------------------------
		// PUBLIC VARIABLES
		//---------------------------------------
		public var objects:Array = [];
		
		//---------------------------------------
		// PRIVATE VARIABLES
		//---------------------------------------
		private var _universe:Universe = Universe.getInstance();
		
		//---------------------------------------
		// CONSTRUCTOR
		//---------------------------------------
		
		/**
		 * @constructor
		 */
		public function ObjectController()
		{
			// nothing
		}
		
		//---------------------------------------
		// PUBLIC METHODS
		//---------------------------------------
		
		/**
		 * Добавляет объект в контроллер.
		 */
		public function add(obj:IGameObject):void
		{
			objects[objects.length] = obj;
		}
		
		/**
		 * Удаляет объект из контроллера.
		 */
		public function remove(obj:IGameObject):void
		{
			for (var i:int = 0; i < objects.length; i++)
			{
				if (objects[i] == obj)
				{
					objects[i] = null;
					objects.splice(i, 1);
					break;
				}
			}
		}
		
		/**
		 * Удаляет все объекты.
		 */
		public function clear(obj:IGameObject):void
		{
			while (objects.length > 0)
			{
				objects[0].free();
			}
		}
		
		/**
		 * Процессит все объекты находящиеся в контроллере.
		 */
		public function update(delta:Number):void
		{
			for (var i:int = objects.length - 1; i >= 0; i--)
			{
				objects[i].update(delta);
			}
		}

	}
}