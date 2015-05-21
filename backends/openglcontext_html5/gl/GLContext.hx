/*
 * Copyright (c) 2003-2015, GameDuell GmbH
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

package gl;

import js.html.webgl.ContextAttributes;
import msignal.Signal;

import js.Browser.document;
import js.html.*;
import js.html.webgl.RenderingContext;
import gl.GL;
import gl.GLInitialState;
import msignal.Signal;

class GLContext
{
	/// STATIC
	public static var onRenderOnMainContext : Signal0;

	private static var mainContext : GLContext;

    private static var canvas : CanvasElement;
    private static var body:Element;

    public static function getMainContext() : GLContext
    {
    	return mainContext;
    }


    public static function setupMainContext(finishedCallback : Void->Void) : Void
    {
        var doc = js.Browser.document;
        body = doc.body;

    	onRenderOnMainContext = new Signal0();

        //create Canvas
        var dom: Element = doc.createElement('Canvas');
        canvas  = cast dom;
        // grab the CanvasRenderingContext2D for drawing on
        var  webGLContext : RenderingContext =  canvas.getContextWebGL({alpha:false, antialias:true, depth:true, premultipliedAlpha:false, preserveDrawingBuffer:false, stencil:true});
        var contextAttributes = webGLContext.getContextAttributes();

        if (!contextAttributes.stencil)
        {
            trace("Warning No Stencil buffer attached:");
        }

        // style can be used for postioning/styling the div or canvas.
        var style = dom.style;
        // add the canvas to the body of the document
        body.appendChild( dom );
        // setup dimensions.
        canvas.width  = gl.GLInitialState.html5Width ;
        canvas.height = gl.GLInitialState.html5Height;
        canvas.id = "#duell-view";

    	mainContext = new GLContext(null);
        GL.context = webGLContext;
        mainContext.nativeContext = webGLContext;
    	mainContext.contextWidth = canvas.width;
    	mainContext.contextHeight = canvas.height;
        GL.viewport(0,0,canvas.width, canvas.height);


        var timer = new haxe.Timer(16); // 1000ms delay
        timer.run = function(){
            onRenderOnMainContext.dispatch();
        };

        finishedCallback();

    }

    public static function mainContextSizeChangedCallback()
    {
        GL.viewport(0,0,canvas.width, canvas.height);
    	mainContext.contextWidth = canvas.width;
    	mainContext.contextHeight = canvas.height;
    	mainContext.onContextSizeChanged.dispatch();
    }

    /// INSTANCE
    private var nativeContext : Dynamic;

    public var onContextSizeChanged : Signal0;
    public var contextWidth : Int;
    public var contextHeight : Int;

    private function new(params : GLContextParameters) : Void
    {
    	onContextSizeChanged = new Signal0();
    }

    public function bind() : Void
    {

    }

    public function destroy() : Void
    {

    }
}
