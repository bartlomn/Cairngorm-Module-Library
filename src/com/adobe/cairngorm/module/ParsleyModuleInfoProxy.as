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
    import flash.system.ApplicationDomain;
    import flash.system.SecurityDomain;
    import flash.utils.ByteArray;
    
    import mx.core.IFlexModuleFactory;
    import mx.events.ModuleEvent;
    import mx.modules.IModuleInfo;
    
    import org.spicefactory.parsley.core.context.Context;
    
    public class ParsleyModuleInfoProxy extends EventDispatcher implements IModuleInfo
    {		
        protected var info:IModuleInfo;
		protected var context:Context;
		
		protected var domain:ApplicationDomain;
		protected var securityDomain:SecurityDomain;
		protected var bytes:ByteArray;
		
		public var moduleFactory:IFlexModuleFactory;		
			
        public function ParsleyModuleInfoProxy(info:IModuleInfo, context:Context, domain:ApplicationDomain, securityDomain:SecurityDomain, bytes:ByteArray)
        {
            this.info=info;
            this.context=context;
			
			this.domain=domain;
			this.securityDomain=securityDomain;
			this.bytes=bytes;			
            
            info.addEventListener(ModuleEvent.SETUP, moduleEventHandler, false, 0, true);
            info.addEventListener(ModuleEvent.PROGRESS, moduleEventHandler, false, 0, true);
            info.addEventListener(ModuleEvent.READY, moduleEventHandler, false, 0, true);
            info.addEventListener(ModuleEvent.ERROR, moduleEventHandler, false, 0, true);
            info.addEventListener(ModuleEvent.UNLOAD, moduleEventHandler, false, 0, true);
        }
        
        public function get data():Object
        {
            return info.data;
        }
        
        public function set data(value:Object):void
        {
            info.data=value;
        }
        
        public function get error():Boolean
        {
            return info.error;
        }
        
        public function get factory():IFlexModuleFactory
        {
            var parsleyFactory:ParsleyFlexModuleFactory = new ParsleyFlexModuleFactory(info.factory,context,this);
            
            return parsleyFactory;
        }
        
        public function get loaded():Boolean
        {
            return info.loaded;
        }
        
        public function get ready():Boolean
        {
            return info.ready;
        }
        
        public function get setup():Boolean
        {
            return info.setup;
        }
        
        public function get url():String
        {
            return info.url;
        }
        
         public function load(applicationDomain:ApplicationDomain=null, securityDomain:SecurityDomain=null, bytes:ByteArray=null, moduleFactory:IFlexModuleFactory=null):void
        {
			applicationDomain = prefer(applicationDomain, domain);
			applicationDomain = createDefaultApplicationDomain(applicationDomain);
			securityDomain = prefer(securityDomain, this.securityDomain);
			bytes = prefer(bytes, this.bytes);
			moduleFactory = prefer(moduleFactory, this.moduleFactory);
			
			info.load(applicationDomain, securityDomain, bytes, moduleFactory);
        }
		
		//mimic Flex SDK ModuleLoader behaviour
		private function createDefaultApplicationDomain(applicationDomain:ApplicationDomain):ApplicationDomain
		{
			// If an applicationDomain has not been specified and we have a module factory,
			// then create a child application domain from the application domain
			// this module factory is in.
			// This is a change in behavior so only do it for Flex 4 and newer
			// applications.
			var tempApplicationDomain:ApplicationDomain = applicationDomain; 
			
			if (tempApplicationDomain == null && moduleFactory)
			{
				var currentDomain:ApplicationDomain = moduleFactory.info()["currentDomain"];
				tempApplicationDomain = new ApplicationDomain(currentDomain); 
			}
			
			return tempApplicationDomain;
		}	

 		
		private function prefer(override:*, overridden:*):*
		{
			return override != null ? override : overridden;
		}
        
        public function release():void
        {
            info.release();
        }
        
        public function unload():void
        {
            info.unload();

            info.removeEventListener(ModuleEvent.ERROR, moduleEventHandler);
            info.removeEventListener(ModuleEvent.PROGRESS, moduleEventHandler);
            info.removeEventListener(ModuleEvent.READY, moduleEventHandler);
            info.removeEventListener(ModuleEvent.SETUP, moduleEventHandler);
            info.removeEventListener(ModuleEvent.UNLOAD, moduleEventHandler);
        }
        
        public function publish(factory:IFlexModuleFactory):void
        {
            info.publish(factory);
        }
        
        private function moduleEventHandler(event:ModuleEvent):void
        {
            dispatchEvent(event);
        }
    }
}