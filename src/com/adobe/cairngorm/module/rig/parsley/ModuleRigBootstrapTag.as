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
package com.adobe.cairngorm.module.rig.parsley
{
    import org.spicefactory.lib.task.Task;
    import org.spicefactory.parsley.config.RootConfigurationElement;
    import org.spicefactory.parsley.core.builder.ObjectDefinitionBuilder;
    import org.spicefactory.parsley.core.registry.ObjectDefinitionRegistry;

    [DefaultProperty("tasks")]
    public class ModuleRigBootstrapTag implements RootConfigurationElement
    {

        [ArrayElementType("org.spicefactory.lib.task.Task")]
        public var tasks:Array;

        public var objectId:String;

        public function process( registry:ObjectDefinitionRegistry ):void
        {
            var builder:ObjectDefinitionBuilder = registry.builders.forClass(ModuleRigBootstrapBuilder);

            builder.constructorArgs([ registry.context, tasks ]);

            builder.asSingleton().id(objectId).register();
        }
    }
}