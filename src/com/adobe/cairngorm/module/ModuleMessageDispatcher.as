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
    import org.spicefactory.lib.reflect.Property;
    import org.spicefactory.parsley.core.context.Context;
    import org.spicefactory.parsley.core.messaging.MessageProcessor;
    import org.spicefactory.parsley.core.scope.ScopeName;

    public class ModuleMessageDispatcher
    {

        [ArrayElementType("com.adobe.cairngorm.module.ParsleyModuleMessage")]
        private var moduleContextInfoMap:Array = new Array();

        [ArrayElementType("Object")]
        private var messageQueueMap:Array = new Array();

        private var moduleIdProperty:Property;

        //FIXME: This is a workaround until Jens come back to us with some more insights.
        //Doing this thru the constructor give an RTE, as a workaround we pass the value thru a public property.
        public var moduleManager:IModuleManager;

        public function ModuleMessageDispatcher(moduleIdProperty:Property, moduleManager:IModuleManager = null)
        {
            this.moduleIdProperty = moduleIdProperty;

            //FIXME: This is a workaround until Jens come back to us with some more insights.
            //Doing this thru the constructor give an RTE, as a workaround we pass the value thru a public property.
            //this.moduleManager = moduleManager;
        }

        /**
         * This method is called each time a message registered as an inter-communcation message thru the
         * ModuleMessageInterceptor decorator is dispatched.
         *
         * The message is intercepted then kept into a queue until the destination module(s) are loaded,instantiated
         * and ready to catch messages.
         *
         * All messages dispatched thru this mechanism are redirected to the appropriate module using the LOCAL scope
         * to prevent a message to be handled by more than one module.
         */
        public function interceptModuleMessage(type:Object, processor:MessageProcessor):void
        {
            var moduleRootContexts:Array = getModuleRootContexts(processor.message);

            if (moduleRootContexts && moduleRootContexts.length > 0)
            {
                for each (var moduleRootContext:Context in moduleRootContexts)
                {
                    moduleRootContext.scopeManager.getScope(ScopeName.LOCAL).dispatchMessage(processor.message);
                }
            }
            else
            {
                addMessageToQueue(processor.message)
            }

            processor.resume();
        }

        /**
         * This method is called once per module instance as soon as the module is loaded, instanciated and
         * ready to catch messages.
         *
         * If there are messages available in the queue for this specific module they are dispatched and removed
         * from the queue.
         */
        public function parsleyModuleMessageHandler(parsleyModule:ParsleyModuleMessage):void
        {
            //Removing the parsleyModuleMessage from the map
            if (parsleyModule.context == null)
            {
                for (var x:int = 0; x < moduleContextInfoMap.length; x++)
                {
                    var message:ParsleyModuleMessage = moduleContextInfoMap[x];

                    if (message.moduleInfo == parsleyModule.moduleInfo)
                    {
                        moduleContextInfoMap.splice(x, 1);
                    }
                }

                return;
            }

            moduleContextInfoMap.push(parsleyModule);

            var messagesInQueue:Array = getMessagesToDispatch(parsleyModule);

            if (messagesInQueue.length > 0)
            {
                for each (var messageToDispatch:Object in messagesInQueue)
                {
                    parsleyModule.context.scopeManager.getScope(ScopeName.LOCAL).dispatchMessage(messageToDispatch);
                }

                clearMessagesFromQueue(parsleyModule);
            }
        }

        private function clearMessagesFromQueue(parsleyModule:ParsleyModuleMessage):void
        {
            for (var x:int = 0; x < messageQueueMap.length; x++)
            {
                var message:Object = messageQueueMap[x];

                var moduleId:String = getModuleIdValueFromMessage(message);

                if (moduleId && moduleIdProperty)
                {
                    if (moduleId == parsleyModule.moduleId)
                    {
                        messageQueueMap.splice(x, 1);
                    }
                }
                else if (moduleManager.contains(parsleyModule.moduleInfo))
                {
                    messageQueueMap.splice(x, 1);
                }
                else
                {
                    messageQueueMap.splice(x, 1);
                }
            }
        }

        private function getMessagesToDispatch(parsleyModule:ParsleyModuleMessage):Array
        {
            var messagesToDispatch:Array = new Array();

            for each (var message:Object in messageQueueMap)
            {
                var moduleId:String = getModuleIdValueFromMessage(message);

                if (moduleIdProperty && moduleId && moduleId.length > 0)
                {
                    if (moduleId == parsleyModule.moduleId)
                    {
                        messagesToDispatch.push(message);
                    }
                }
                else if (moduleManager.contains(parsleyModule.moduleInfo))
                {
                    messagesToDispatch.push(message);
                }
                else
                {
                    messagesToDispatch.push(message);
                }
            }

            return messagesToDispatch;
        }

        private function getModuleIdValueFromMessage(message:Object):String
        {
            var moduleId:String;

            if (moduleIdProperty)
            {
                moduleId = moduleIdProperty.getValue(message);
            }

            return moduleId;
        }

        private function getModuleRootContexts(message:Object):Array
        {
            var moduleId:String = getModuleIdValueFromMessage(message);

            // 1)   If the moduleDescriptor is defined (or not) in the ModuleMessageInterceptor and the moduleId is set
            //      -> Dispatch the message to the unique module Instance identified thru the moduleId property
            if (moduleIdProperty && moduleId && moduleId.length > 0)
            {
                var moduleContext:Context = getModuleRootContextByModuleId(moduleId);

                return moduleContext == null ? null : [ moduleContext ];
            }
            // 2)   If the moduleDescriptor is defined in the ModuleMessageInterceptor and moduleId is not set
            //      -> Dispatch the message to all instanciated modules defined by the Descriptor
            else if (moduleManager)
            {
                return getModuleRootContextsByModuleInfo(moduleManager);
            }
            // 3)   If the moduleDescriptor is not defined in the ModuleMessageInterceptor and the moduleId is not set
            //      -> Dispatch the message to all instanciated modules (broadcast to all modules)
            return getAllModuleRootContexts();
        }

        private function getModuleRootContextByModuleId(moduleId:String):Context
        {
            for each (var parsleyModule:ParsleyModuleMessage in moduleContextInfoMap)
            {
                if (parsleyModule.moduleId == moduleId)
                {
                    return parsleyModule.context;
                }
            }

            return null;
        }

        private function getModuleRootContextsByModuleInfo(manager:IModuleManager):Array
        {
            var moduleRootContexts:Array = new Array();

            for each (var parsleyModule:ParsleyModuleMessage in moduleContextInfoMap)
            {
                if (manager.contains(parsleyModule.moduleInfo))
                {
                    moduleRootContexts.push(parsleyModule.context);
                }
            }

            return moduleRootContexts;
        }

        private function getAllModuleRootContexts():Array
        {
            var moduleRootContexts:Array = new Array();

            for each (var parsleyModule:ParsleyModuleMessage in moduleContextInfoMap)
            {
                moduleRootContexts.push(parsleyModule.context);
            }

            return moduleRootContexts;
        }

        private function addMessageToQueue(message:Object):void
        {
            messageQueueMap.push(message);
        }

    }
}