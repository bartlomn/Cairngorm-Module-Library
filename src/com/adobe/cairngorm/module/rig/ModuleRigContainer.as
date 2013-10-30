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
package com.adobe.cairngorm.module.rig
{
    import com.adobe.cairngorm.module.IModuleManager;
    
    import flash.events.ErrorEvent;
    import flash.events.Event;
    
    import mx.core.IVisualElement;
    import mx.events.FlexEvent;
    
    import org.spicefactory.lib.task.Task;
    import org.spicefactory.lib.task.events.TaskEvent;
    
    import spark.components.Group;
    import spark.components.SkinnableContainer;

    [SkinState("normal")]
    [SkinState("error")]

    public class ModuleRigContainer extends SkinnableContainer
    {

        [SkinPart(required="true")]
        public var headerBarContent:Group;

        [Bindable]
        [ArrayElementType("mx.core.IVisualElement")]
        public var rigHeaderPlaceholder:Array;

        [Bindable]
        public var title:String;

        [Bindable]
        public var moduleManager:IModuleManager;

        private var _bootstrap:Task;

        private var skinState:String;

        private static const NORMAL_STATE:String = "normal";

        private static const ERROR_STATE:String = "error";

        public function set bootstrap(value:Task):void
        {
            _bootstrap = value;

            _bootstrap.addEventListener(TaskEvent.COMPLETE, bootstrapperCompleteHandler);
            _bootstrap.addEventListener(ErrorEvent.ERROR, bootstrapperErrorHandler);
            _bootstrap.addEventListener(TaskEvent.CANCEL, bootstrapperErrorHandler);

            if (_bootstrap)
            {
                _bootstrap.start();
            }
        }

        override protected function getCurrentSkinState():String
        {
            return skinState;
        }

        protected function creationCompleteHandler(event:FlexEvent):void
        {
            for each (var element:IVisualElement in rigHeaderPlaceholder)
            {
                headerBarContent.addElement(element);
            }
        }

        private function bootstrapperCompleteHandler(event:TaskEvent):void
        {
            skinState = NORMAL_STATE;

            invalidateSkinState();
        }

        private function bootstrapperErrorHandler(event:Event):void
        {
            skinState = ERROR_STATE;

            invalidateSkinState();
        }
    }
}