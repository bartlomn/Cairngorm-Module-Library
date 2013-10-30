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
import flash.system.ApplicationDomain;

import org.spicefactory.lib.reflect.ClassInfo;
import org.spicefactory.lib.reflect.Property;
import org.spicefactory.parsley.config.RootConfigurationElement;
import org.spicefactory.parsley.core.builder.ObjectDefinitionBuilder;
import org.spicefactory.parsley.core.registry.ObjectDefinitionRegistry;
import org.spicefactory.parsley.inject.Inject;
import org.spicefactory.parsley.messaging.MessageHandler;

public class ModuleMessageInterceptor implements RootConfigurationElement
{
   public var type:Class;

   public var selector:String;

   public var moduleRef:String;

   private var target:Property;

   public function process( registry:ObjectDefinitionRegistry ):void
   {
      target = getModuleIdTargetProperty( registry.domain );

      var builder:ObjectDefinitionBuilder = registry.builders.forClass( ModuleMessageDispatcher );

      builder.constructorArgs( target );

      if ( moduleRef )
      {
         //builder.constructorArgs().injectById(moduleRef);

         //FIXME: This is a workaround until Jens come back to us with some more insights.
         //Doing this thru the constructor give an RTE, as a workaround we pass the value thru a public property.
         builder.property( "moduleManager" ).value( Inject.byId( moduleRef ));
      }

//      builder.method( "interceptModuleMessage" ).messageHandler().type( type ).selector( selector );
      MessageHandler.forMethod("interceptModuleMessage").type( type ).selector( selector ).apply( builder );
//      builder.method( "parsleyModuleMessageHandler" ).messageHandler().type( ParsleyModuleMessage );
      MessageHandler.forMethod( "parsleyModuleMessageHandler" ).type( ParsleyModuleMessage ).apply( builder );

      builder.asSingleton().register();
   }

   private function getModuleIdTargetProperty( domain:ApplicationDomain ):Property
   {
      var props:Array = ClassInfo.forClass( type, domain ).getProperties();

      for each ( var prop:Property in props )
      {
         if ( prop.hasMetadata( ModuleIdMetadata ))
         {
            return prop;
         }
      }

      return null;
   }
}
}
