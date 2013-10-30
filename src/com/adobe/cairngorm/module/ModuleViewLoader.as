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
    import flash.events.Event;
    import flash.system.ApplicationDomain;
    import flash.system.SecurityDomain;
    import flash.utils.ByteArray;

    import mx.core.IVisualElement;
    import mx.events.FlexEvent;
    import mx.events.ModuleEvent;
    import mx.modules.IModule;
    import mx.modules.IModuleInfo;

    import org.spicefactory.parsley.core.context.Context;
    import org.spicefactory.parsley.flex.tag.builder.FlexContextEvent;

    import spark.components.SkinnableContainer;

    //--------------------------------------
    //  Events
    //--------------------------------------

    /**
     *  Dispatched by the backing ModuleInfo if there was an error during
     *  module loading.
     *
     *
     *  @eventType mx.events.ModuleEvent.ERROR
     */
    [Event(name="error", type="mx.events.ModuleEvent")]

    /**
     *  Dispatched by the backing ModuleInfo at regular intervals
     *  while the module is being loaded.
     *
     *  @eventType mx.events.ModuleEvent.PROGRESS
     */
    [Event(name="progress", type="mx.events.ModuleEvent")]

    /**
     *  Dispatched by the backing ModuleInfo once the module is sufficiently
     *  loaded to call the <code>IModuleInfo.factory()</code> method and the
     *  <code>IFlexModuleFactory.create()</code> method.
     *
     *  @eventType mx.events.ModuleEvent.READY
     */
    [Event(name="ready", type="mx.events.ModuleEvent")]

    /**
     *  Dispatched when the root parsley context of the module is initialized and configured.
     */
    [Event(name="contextReady", type="flash.events.Event")]

    /**
     *  Dispatched by the backing ModuleInfo once the module is sufficiently
     *  loaded to call the <code>IModuleInfo.factory()</code> method and
     *  the <code>IFlexModuleFactory.info()</code> method.
     *
     *  @eventType mx.events.ModuleEvent.SETUP
     */
    [Event(name="setup", type="mx.events.ModuleEvent")]

    /**
     *  Dispatched by the backing ModuleInfo when the module data is unloaded.
     *
     *  @eventType mx.events.ModuleEvent.UNLOAD
     */
    [Event(name="unload", type="mx.events.ModuleEvent")]

    //--------------------------------------
    //  Resource Bundle
    //--------------------------------------

    [ResourceBundle("containers")]
    [ResourceBundle("modules")]

    //--------------------------------------
    //  States
    //--------------------------------------

    [SkinState("normal")]
    [SkinState("loading")]
    [SkinState("error")]
    [SkinState("loaded")]

    /**
     * A container that loads and unloads a child view. The view may be a
     * conventional Flex module or anything else that implements thet
     * <code>IModuleManager</code> interface. The rules by which loading and unloading takes
     * place are controlled through the <code>ILoadPolicy</code> interface.
     */
    public class ModuleViewLoader extends SkinnableContainer implements IViewLoader
    {
        public var applicationDomain:ApplicationDomain;

        public var securityDomain:SecurityDomain;

        public var bytes:ByteArray;

        private static const NORMAL_STATE:String = "normal";

        private static const LOADING_STATE:String = "loading";

        private static const ERROR_STATE:String = "error";

        private static const LOADED_STATE:String = "loaded";

        private var skinState:String = NORMAL_STATE;

        private var module:IModuleInfo;

        private var _moduleId:String;

        private var _loadedModule:IModule;

        public function get loadedModule():IModule
        {
            return _loadedModule;
        }

        private var _moduleManager:IModuleManager;

        private var _loadPolicy:ILoadPolicy;

        private var _moduleRootContext:Context;

        public function ModuleViewLoader()
        {
            super();

            if (_loadPolicy)
            {
                _loadPolicy.start(this);
            }
        }

        public function get moduleRootContext():Context
        {
            return _moduleRootContext;
        }

        public function set moduleId(value:String):void
        {
            _moduleId = value;
        }

        public function get moduleId():String
        {
            return _moduleId;
        }

        public function get loadPolicy():ILoadPolicy
        {
            return _loadPolicy;
        }

        public function set loadPolicy(value:ILoadPolicy):void
        {
            if (_loadPolicy == value)
            {
                return;
            }

            if (_loadPolicy)
            {
                _loadPolicy.stop(this);
            }

            _loadPolicy = value;

            if (_loadPolicy)
            {
                _loadPolicy.start(this);
            }
        }

        public function set moduleManager(value:IModuleManager):void
        {
            if (value == _moduleManager)
                return;

            //First unload the current module if any
            unloadModule();

            _moduleManager = value;

            if (_moduleManager != null && _loadPolicy != null)
            {
                _loadPolicy.load(this);
            }
        }

        public function loadModule(manager:IModuleManager = null):void
        {
            if (manager != null)
            {
                _moduleManager = manager;
            }

            if (_moduleManager == null)
            {
                return;
            }

            if (module)
            {
                return;
            }

            dispatchEvent(new FlexEvent(FlexEvent.LOADING));

            module = _moduleManager.getModule();

            module.addEventListener(ModuleEvent.PROGRESS, module_progressHandler);
            module.addEventListener(ModuleEvent.SETUP, dispatchEvent);
            module.addEventListener(ModuleEvent.READY, module_readyHandler);
            module.addEventListener(ModuleEvent.ERROR, module_errorHandler);
            module.addEventListener(ModuleEvent.UNLOAD, module_unloadHandler);

            module.load(applicationDomain, securityDomain, bytes, moduleFactory);
        }

        public function unloadModule():void
        {
            if (_loadedModule)
            {
                removeElement(IVisualElement(_loadedModule));
                _loadedModule = null;
            }

            if (module)
            {
                module.removeEventListener(ModuleEvent.PROGRESS, module_progressHandler);
                module.removeEventListener(ModuleEvent.SETUP, dispatchEvent);
                module.removeEventListener(ModuleEvent.READY, module_readyHandler);
                module.removeEventListener(ModuleEvent.ERROR, module_errorHandler);

                module.unload();
                module.removeEventListener(ModuleEvent.UNLOAD, module_unloadHandler);
                module = null;
                _moduleRootContext = null;

                skinState = NORMAL_STATE;
                invalidateSkinState();
            }
        }

        override protected function getCurrentSkinState():String
        {
            return skinState;
        }

        private function addLoadedModuleToStage(event:ModuleEvent):void
        {
            if (!module)
            {
                return;
            }

            _loadedModule = module.factory.create(moduleId) as IModule;

            if (_loadedModule)
            {
                addElement(IVisualElement(_loadedModule));
            }

            dispatchEvent(event);
            setModuleRootContext();

            //Workaround to force the view to be rendered properly in some situations. 
            //It seems that when this class is used within a navigator container such as ViewStack or TabNavigator, 
            //it fail to render the first child for some reasons. (TO INVESTIGATE)
            this.visible = true;

            skinState = LOADED_STATE;
            invalidateSkinState();
        }

        protected function setModuleRootContext():void
        {
            if (_loadedModule is IParsleyModule)
            {
                if (IParsleyModule(_loadedModule).contextBuilder.context && IParsleyModule(_loadedModule).contextBuilder.context.configured)
                {
                    _moduleRootContext = IParsleyModule(_loadedModule).contextBuilder.context;

                    dispatchEvent(new Event("contextReady"));
                }
                else
                {
                    IParsleyModule(_loadedModule).contextBuilder.addEventListener(
                        FlexContextEvent.COMPLETE, loadedModule_flexContextEventCompleteHandler,
                        false, 0, true);
                }
            }
            else
            {
                _moduleRootContext = null;
            }
        }

        //--------------------------------------------------------------------------
        //
        //  Event handlers
        //
        //--------------------------------------------------------------------------

        private function loadedModule_flexContextEventCompleteHandler(event:FlexContextEvent):void
        {
            _moduleRootContext = event.context;

            IParsleyModule(_loadedModule).contextBuilder.removeEventListener(
                FlexContextEvent.COMPLETE, loadedModule_flexContextEventCompleteHandler);

            dispatchEvent(new Event("contextReady"));
        }

        private function module_progressHandler(event:ModuleEvent):void
        {
            dispatchEvent(event);

            if (_loadedModule == null && skinState != LOADING_STATE)
            {
                skinState = LOADING_STATE;
                invalidateSkinState();
            }
        }

        private function module_readyHandler(event:ModuleEvent):void
        {
            if (_loadedModule)
            {
                return;
            }

            if (!module)
            {
                return;
            }

            //Workaround to force the view to be rendered properly in some situations. 
            //It seems that when this class is used within a navigator container such as ViewStack or TabNavigator, 
            //it fail to render the first child for some reasons. (TO INVESTIGATE)
            this.visible = false;

            //Adding the module to stage is done one frame later to make sure 
            //that any public properties are sets as expected. 
            //The moduleId need to be passed to the module factory in order 
            //to make the intercommunication API to work.
            callLater(addLoadedModuleToStage, [ event ]);
        }

        private function module_errorHandler(event:ModuleEvent):void
        {
            unloadModule();
            dispatchEvent(event);

            skinState = ERROR_STATE;
            invalidateSkinState();
        }

        private function module_unloadHandler(event:ModuleEvent):void
        {
            dispatchEvent(event);
        }
    }

    
}