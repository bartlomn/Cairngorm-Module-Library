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
	import flash.events.IEventDispatcher;
	
	import mx.events.FlexEvent;
	import mx.events.ModuleEvent;
	import mx.modules.IModuleInfo;

	public class Preloader
	{
		private var source:IEventDispatcher;
		
		public function Preloader(source:IEventDispatcher)
		{
			this.source = source;
		}
		
		private var module:IModuleInfo;
		
		public function load(moduleManager:IModuleManager):void
		{
			source.dispatchEvent(new FlexEvent(FlexEvent.LOADING));
			
			module = moduleManager.getModule();
			module.addEventListener(ModuleEvent.PROGRESS, source.dispatchEvent);
			module.addEventListener(ModuleEvent.SETUP, source.dispatchEvent);
			module.addEventListener(ModuleEvent.READY, module_readyHandler);
			module.addEventListener(ModuleEvent.ERROR, source.dispatchEvent);
			module.addEventListener(ModuleEvent.UNLOAD, source.dispatchEvent);
			
			//use defaults, this should be specified in ParsleyModuleDescriptor
			module.load();			
		}
		
		private var loader:IViewLoader;
		
		public function registerView(loader:IViewLoader):void
		{
			this.loader = loader;
			
			if(module && module.loaded && module.ready)
			{
				loader.loadModule();
			}		
		}
		
		private function module_readyHandler(event:ModuleEvent):void
		{
			if(loader)
				loader.loadModule();
			
			source.dispatchEvent(event);
		}
	}
}