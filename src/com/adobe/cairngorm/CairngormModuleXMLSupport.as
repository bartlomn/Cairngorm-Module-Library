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
package com.adobe.cairngorm
{
    import com.adobe.cairngorm.module.LazyModuleLoadPolicyTag;
    import com.adobe.cairngorm.module.ModuleMessageInterceptor;
    import com.adobe.cairngorm.module.ParsleyModuleDescriptor;
    
    import flash.system.ApplicationDomain;
    import flash.system.SecurityDomain;
    import flash.utils.ByteArray;
    
    import mx.core.IFlexModuleFactory;
    
    import org.spicefactory.parsley.core.bootstrap.BootstrapConfig;
    import org.spicefactory.parsley.core.bootstrap.BootstrapConfigProcessor;
    import org.spicefactory.parsley.xml.mapper.XmlConfigurationNamespaceRegistry;

    /**
     * Provides a static method to initalize the Module XML tag extension.
     * Can be used as a child tag of a <ContextBuilder/> tag in MXML alternatively.
     *
     */
    public class CairngormModuleXMLSupport implements BootstrapConfigProcessor
    {

        /**
         * The XML Namespace of the Module tag extension.
         */
        public static const NAMESPACE_URI:String = "http://ns.adobe.com/cairngorm";

        private static var initialized:Boolean = false;

        public static function initialize():void
        {
            if (initialized)
                return;

            initializeDescriptor();
            initializeInterceptor();
            initializeLazyLoadPolicy();

            initialized = true;
        }

        private static function initializeDescriptor():void
        {
            XmlConfigurationNamespaceRegistry.getNamespace(NAMESPACE_URI).mappedClasses(ParsleyModuleDescriptor,
                                                                                        ByteArray,
                                                                                        IFlexModuleFactory,
                                                                                        ApplicationDomain,
                                                                                        SecurityDomain);
        }

        private static function initializeInterceptor():void
        {
            XmlConfigurationNamespaceRegistry.getNamespace(NAMESPACE_URI).mappedClasses(ModuleMessageInterceptor);
        }

        private static function initializeLazyLoadPolicy():void
        {
            var name:QName = new QName(NAMESPACE_URI, "lazy-module-load-policy");
            XmlConfigurationNamespaceRegistry.getNamespace(NAMESPACE_URI).newMapperBuilder(LazyModuleLoadPolicyTag,
                                                                                           name);
        }

        /**
         * @private
         */
        public function processConfig(config:BootstrapConfig):void
        {
            initialize();
        }
    }
}

