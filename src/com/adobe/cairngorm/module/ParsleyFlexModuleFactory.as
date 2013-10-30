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
    import flash.display.LoaderInfo;
    import flash.events.EventDispatcher;
    import flash.utils.Dictionary;
    
    import mx.core.IFlexModule;
    import mx.core.IFlexModuleFactory;
    import mx.core.RSLData;
    import mx.modules.IModuleInfo;
    import mx.modules.Module;
    
    import org.spicefactory.parsley.core.context.Context;
    import org.spicefactory.parsley.core.events.ContextEvent;
    import org.spicefactory.parsley.flex.tag.builder.ContextBuilderTag;
    import org.spicefactory.parsley.flex.tag.builder.FlexContextEvent;

    public class ParsleyFlexModuleFactory extends EventDispatcher implements IFlexModuleFactory
    {
        private var factory:IFlexModuleFactory;

        private var context:Context;

        private var module:Module;

        private var moduleId:String;

        private var moduleInfo:IModuleInfo;

        public function ParsleyFlexModuleFactory(
            factory:IFlexModuleFactory, context:Context, moduleInfo:IModuleInfo)
        {
            this.factory = factory;
            this.context = context;
            this.moduleInfo = moduleInfo;
        }

        public function callInContext(
            fn:Function, thisArg:Object, argArray:Array, returns:Boolean = true):*
        {
            return factory.callInContext(fn, thisArg, argArray, returns);
        }

        public function getImplementation(interfaceName:String):Object
        {
            return factory.getImplementation(interfaceName);
        }

        public function registerImplementation(interfaceName:String, impl:Object):void
        {
            return factory.registerImplementation(interfaceName, impl);
        }

        public function get preloadedRSLs():Dictionary
        {
            return factory.preloadedRSLs;
        }

        public function allowDomain(... parameters):void
        {
            factory.allowDomain(parameters);
        }

        public function allowInsecureDomain(... parameters):void
        {
            factory.allowInsecureDomain(parameters);
        }

        public function create(... parameters):Object
        {
            var moduleObj:Object = factory.create(parameters);			
			IFlexModule(moduleObj).moduleFactory = factory;
			
			module = Module(moduleObj);

            if (parameters.length > 0 && parameters[0] != null)
            {
                moduleId = parameters[0].toString();
            }

            if (module is IParsleyModule)
            {
                registerModuleContext(module);
            }

            return module;
        }

        public function info():Object
        {
            return factory.info();
        }

        private function registerModuleContext(module:Module):void
        {
            var contextBuilder:ContextBuilderTag = IParsleyModule(module).contextBuilder;
            contextBuilder.addEventListener(FlexContextEvent.COMPLETE, moduleContextCompleteHandler);
        }

        private function moduleContextCompleteHandler(event:FlexContextEvent):void
        {
            event.context.addEventListener(ContextEvent.DESTROYED, context_destroyedHandler,
                                           false, 0, true);

            context.scopeManager.dispatchMessage(new ParsleyModuleMessage(module,
                                                                          moduleId,
                                                                          event.context,
                                                                          moduleInfo));
        }

        private function context_destroyedHandler(event:ContextEvent):void
        {
            context.scopeManager.dispatchMessage(new ParsleyModuleMessage(module,
                                                                          moduleId,
                                                                          null,
                                                                          moduleInfo));
        }

		public function addPreloadedRSL(loaderInfo:LoaderInfo, rsl:Vector.<RSLData>):void
		{
			factory.addPreloadedRSL(loaderInfo, rsl);
		}
		
		public function get allowDomainsInNewRSLs():Boolean
		{
			return factory.allowDomainsInNewRSLs;
		}
		
		public function set allowDomainsInNewRSLs(value:Boolean):void
		{
			factory.allowDomainsInNewRSLs = value;
		}
		
		public function get allowInsecureDomainsInNewRSLs():Boolean
		{
			return factory.allowInsecureDomainsInNewRSLs;
		}
		
		public function set allowInsecureDomainsInNewRSLs(value:Boolean):void
		{
			factory.allowInsecureDomainsInNewRSLs = value;
		}
	}
}