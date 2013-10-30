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
    import mx.modules.ModuleManager;

    import org.spicefactory.parsley.core.context.Context;

    public class ParsleyModuleManager extends EventDispatcher implements IModuleManager
    {
        private var context:Context;

        private var url:String;

        private var applicationDomain:ApplicationDomain;

        private var securityDomain:SecurityDomain;

        private var bytes:ByteArray;

        public var moduleFactory:IFlexModuleFactory;

        [ArrayElementType("com.adobe.cairngorm.module.ParsleyModuleInfoProxy")]
        private var infos:Array = new Array();

        public function ParsleyModuleManager(url:String, context:Context, domain:ApplicationDomain, securityDomain:SecurityDomain, bytes:ByteArray)
        {
            super();

            this.url = url;
            this.context = context;
            this.applicationDomain = domain;
            this.securityDomain = securityDomain;
            this.bytes = bytes;
        }

        public function getModule():IModuleInfo
        {
            var moduleInfo:IModuleInfo = ModuleManager.getModule(url);

            var info:ParsleyModuleInfoProxy = new ParsleyModuleInfoProxy(moduleInfo,
                                                                         context,
                                                                         applicationDomain,
                                                                         securityDomain,
                                                                         bytes);
            info.addEventListener(ModuleEvent.ERROR, handleErrorOrUnload, false,
                                  0, true);
            info.addEventListener(ModuleEvent.UNLOAD, handleErrorOrUnload, false,
                                  0, true);

            info.moduleFactory = moduleFactory;

            infos.push(info);

            return info;
        }
 
        public function contains(info:IModuleInfo):Boolean
        {
            return infos.indexOf(info) >= 0 ? true : false;
        }

        private function handleErrorOrUnload(event:ModuleEvent):void
        {
            var index:int = infos.indexOf(event.currentTarget);
            infos.splice(index, 1);
        }
    }
}