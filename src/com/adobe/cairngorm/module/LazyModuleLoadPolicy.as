/**
 *  Copyright (c) 2007 - 2009 Adobe
 *  All rights reserved.
 *
 *  Permission is hereby granted, free of charge, to any person obtaining
 *  a copy of this software and associated documentation files (the "Software"),
 *  to deal in the Software without restriction, including without limitation
 *  the rights to use, copy, modify, merge, publish, distribute, sublicense,
 *  and/or sell copies of the Software, and to permit persons to whom the
 *  Software is furnished to do so, subject to the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included
 *  in all copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 *  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 *  THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
 *  IN THE SOFTWARE.
 */
package com.adobe.cairngorm.module
{
    import flash.events.EventDispatcher;
    import flash.utils.Dictionary;
    
    import org.spicefactory.lib.reflect.Property;
    import org.spicefactory.parsley.core.messaging.MessageProcessor;

    public class LazyModuleLoadPolicy extends EventDispatcher implements ILoadPolicy
    {
        private var loaders:Dictionary = new Dictionary();
        
        private var moduleIdProperty : Property;
		
		public var moduleManager:IModuleManager;
		
		private var preloader:Preloader;
        
        public function LazyModuleLoadPolicy(moduleIdProperty:Property)
        {
            this.moduleIdProperty=moduleIdProperty;		
			preloader = new Preloader(this);
        }
		
		private function get isInPreloadMode():Boolean
		{
			return moduleManager != null;
		}
        
        public function interceptModuleMessage(type:Object, processor:MessageProcessor):void
        {
			if(isInPreloadMode)
			{
				preloader.load(moduleManager);
			}
			else
			{
				loadFromViewLoader(processor.message);
			}
            
            processor.resume();
        }
		
		private function loadFromViewLoader(message:Object):void
		{
			var loader:IViewLoader = 
				loaders[ getModuleIdValueFromMessage(message) ] as IViewLoader;
			
			if( loader )
			{
				load(loader);
			}			
		}
        
        public function start(loader:IViewLoader):void
        {
            loaders[loader.moduleId]=loader;
			
			if(isInPreloadMode)
				preloader.registerView(loader);
        }
        
        public function stop(loader:IViewLoader):void
        {
            unload( loader );
        }
        
        public function load( loader:IViewLoader ):void
        {
            loader.loadModule();
        }
        
        public function unload( loader:IViewLoader ):void
        {
            loaders[loader.moduleId]=null;
            
            loader.unloadModule();
        }
        
        private function getModuleIdValueFromMessage( message:Object ) : String
        {
            var moduleId:String;
            
            if( moduleIdProperty )
            {
                moduleId = moduleIdProperty.getValue(message);
            }
            
            return moduleId;
        }
    }
}