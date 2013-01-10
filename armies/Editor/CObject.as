package {
	
	import flash.display.MovieClip;
	import flash.filesystem.*;
	import flash.events.*;
	import flash.net.*;
	import flash.display.*;
	import flash.utils.Timer;
	import flashx.textLayout.formats.Float;
	import flash.geom.Matrix;
		
	class CObject extends MovieClip
	{
		//vars
		public var lname:String = "Untitled";;
		public var type:String = "none";
		public var lx:int = 0;
		public var ly:int = 0;
		public var lz:Number = 1;
		public var lrot:Number = 0;
		public var health:int = 100;
		public var bb_width:int = 50;
		public var bb_height:int = 50;
		public var onenter:String = "";
		public var onleave:String = "";
		public var triggeronce:String = "";
		public var active:String = "";
		public var lgraphics:String = "";
		public var fromlibrary:String = "";
		public var zindex:int = 1;
		public var ai:int = 0;
		
		//graphics
		public var numFrames:Number;
		public var FrameRate:Number;
		public var frames:Array;
		
		//sys
		var loader:Loader;
		var curloading:Number;
		var animTimer:Timer;
		var curAnimFrame:Number = 0;
		var bbframe:smallframe;
		
		public function CObject()
		{
			frames = new Array();
		}
		
		
		public function ToSave()
		{
			var tempstr:String = "[OBJECT]\n";
			
			if(type == 'CHR')
			{
				if(fromlibrary.length <= 0)
				{
					tempstr += "Name " + lname + "\n";
					tempstr += "Type " + type + "\n";
					tempstr += "Graphics " + lgraphics + "\n";
					tempstr += "bb " + bb_width + " " + bb_height + "\n";
					tempstr += "Health " + health + "\n";
					if(lname != "player") tempstr += "ai " + ai + "\n";
				}
				else
				{
					tempstr += "FromLibrary " + fromlibrary + "\n";
				}
				tempstr += "x " + lx + "\n";
				tempstr += "y " + ly + "\n";
				tempstr += "z " + lz + "\n";
				tempstr += "Rotation " + lrot + "\n";
				tempstr += "zindex " + zindex + "\n";
				tempstr += "active " + active + "\n";
			}
			else if(type == 'PHY')
			{
				tempstr += "Name " + lname + "\n";
				tempstr += "Type " + type + "\n";
				tempstr += "Graphics " + lgraphics + "\n";
				tempstr += "x " + lx + "\n";
				tempstr += "y " + ly + "\n";
				tempstr += "z " + lz + "\n";
				tempstr += "Rotation " + lrot + "\n";
				tempstr += "bb " + bb_width + " " + bb_height + "\n";
				tempstr += "zindex " + zindex + "\n";
			}
			else if(type == 'TRG')
			{
				tempstr += "Name " + lname + "\n";
				tempstr += "Type " + type + "\n";
				tempstr += "Graphics " + lgraphics + "\n";
				tempstr += "x " + lx + "\n";
				tempstr += "y " + ly + "\n";
				tempstr += "z " + lz + "\n";
				tempstr += "Rotation " + lrot + "\n";
				tempstr += "bb " + bb_width + " " + bb_height + "\n";
				tempstr += "onenter " + onenter + "\n";
				tempstr += "onleave " + onleave + "\n";
				tempstr += "triggeronce " + triggeronce + "\n";
			}
			else if(type == 'DEC')
			{
				tempstr += "Name " + lname + "\n";
				tempstr += "Type " + type + "\n";
				tempstr += "Graphics " + lgraphics + "\n";
				tempstr += "x " + lx + "\n";
				tempstr += "y " + ly + "\n";
				tempstr += "z " + lz + "\n";
				tempstr += "Rotation " + lrot + "\n";
				tempstr += "zindex " + zindex + "\n";
			}
			else if(type == 'ITM')
			{
				/*unknown yet*/
			}
			
			return tempstr + "#\n";
		}
		
		
		public function LoadFromPresent()
		{
			var tempstr:String;
			
			tempstr = fromlibrary;
			if(tempstr.length > 0)
			{
				//load from library
				var file:File = File.applicationDirectory.resolvePath("Assets\\system\\chars.cfg");
				var fileStream:FileStream = new FileStream();
				fileStream.open(file, FileMode.READ);
				var library:String = fileStream.readUTFBytes(file.size);
				fileStream.close();
				
				var block:CBlock = new CBlock();
				//trace(tempstr);
				block.GetBlockByName(tempstr,library);
				library = block.text;
				
				lname = GetParamString("Name",library);
				type = GetParamString("Type",library);
				
				lgraphics = GetParamString("Graphics", library);
				tempstr = GetParamString("bb",library);
				if(tempstr.length > 2)
				{
					var bbs:Array = tempstr.split(" ");
					bb_width = int(bbs[0]);
					bb_height = int(bbs[1]);
					
					bbframe = new smallframe;
					bbframe.parentObject = this;
					bbframe.width = 1;
					bbframe.height = 1;
				}
				
				health = GetParamInt("Health",library);
				ai = GetParamInt("ai",library);
			}
			else
			{
				if(bb_width > 0 && bb_height > 0 && type != "DEC")
				{
					bbframe = new smallframe;
					bbframe.parentObject = this;
					bbframe.width = 1;
					bbframe.height = 1;
				}
			}
			if(lgraphics.length > 0)
				LoadGraphicsFromString(lgraphics);
		}
		public function LoadFromString(in_str:String)
		{
			var tempstr:String;
			
			fromlibrary = GetParamString("FromLibrary",in_str);
			if(fromlibrary.length > 0)
			{
				//load from library
				
				var file:File = File.applicationDirectory.resolvePath("Assets\\system\\chars.cfg");
				var fileStream:FileStream = new FileStream();
				fileStream.open(file, FileMode.READ);
				var library:String = fileStream.readUTFBytes(file.size);
				fileStream.close();
				
				var block:CBlock = new CBlock();
				trace(tempstr);
				block.GetBlockByName(fromlibrary,library);
				library = block.text;
				
				lname = GetParamString("Name",library);
				type = GetParamString("Type",library);
				
				lgraphics = GetParamString("Graphics", library);
				tempstr = GetParamString("bb",library);
				if(tempstr.length > 2)
				{
					var bbs:Array = tempstr.split(" ");
					bb_width = int(bbs[0]);
					bb_height = int(bbs[1]);
					
					bbframe = new smallframe;
					bbframe.parentObject = this;
					bbframe.width = 1;
					bbframe.height = 1;
				}
				
				health = GetParamInt("Health",library);
				ai = GetParamInt("ai",library);
			}
			else
			{
				//load from file
				lname = GetParamString("Name",in_str);
				type = GetParamString("Type",in_str);
				lgraphics = GetParamString("Graphics", in_str);
				tempstr = GetParamString("bb",in_str);
				if(tempstr.length > 3)
				{
					var bbs:Array = tempstr.split(" ");
					bb_width = int(bbs[0]);
					bb_height = int(bbs[1]);
					
					bbframe = new smallframe;
					bbframe.parentObject = this;
					bbframe.width = 1;
					bbframe.height = 1;
				}
				
				health = GetParamInt("Health",in_str);
				ai = GetParamInt("ai",in_str);
			}
			
			
			lx = GetParamInt("x",in_str);
			ly = GetParamInt("y",in_str);
			lz = GetParamFloat("z",in_str);
			zindex = GetParamInt("zindex",in_str);
			lrot = GetParamFloat("Rotation",in_str);
			onenter = GetParamString("onenter",in_str);
			onleave = GetParamString("onleave",in_str);
			triggeronce = GetParamString("triggeronce",in_str);
			active = GetParamString("active",in_str);
						
			if(lgraphics.length > 0)
				LoadGraphicsFromString(lgraphics);
		}
		
		public function LoadGraphicsFromString(in_str:String)
		{
			
			//main
			var file:File = File.applicationDirectory.resolvePath("Assets\\"+in_str.replace(/\//g,"\\")+"\\main.cfg");
			var fileStream:FileStream = new FileStream();
			fileStream.open(file, FileMode.READ);
			var str:String = fileStream.readUTFBytes(file.size);
			fileStream.close();
			
			
			numFrames = GetParamInt("NumFrames", str);
			FrameRate = GetParamInt("FrameRate", str);
			
			
			//sequental load of frame
			curloading = 0;
			frames = new Array;
			AddFrame(in_str + "/0.png");
		}
		public function AddFrame(in_str:String)
		{
			var file:File = File.applicationDirectory.resolvePath("Assets\\"+in_str.replace(/\//g,"\\"));
			
			loader = new Loader();
			var urlReq:URLRequest = new URLRequest(file.url);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, frameLoaded);
			loader.load(urlReq);
		}
		function frameLoaded(event:Event):void
		{
			var bmp:Bitmap = new Bitmap();
			bmp = loader.content as Bitmap;
			
			bmp.x = 0;
			bmp.y = -bmp.height;
						
			frames.push(bmp);
						
			curloading++;
			if(curloading < numFrames) AddFrame(lgraphics + "/" + curloading + ".png");
			else FinishLoad();
		}
		
		public function FinishLoad()
		{
			if(frames.length > 0) addChild(frames[0]);
			
			if(FrameRate <= 0) FrameRate = 1;
			
			if(animTimer)
			{
				animTimer.stop();
				animTimer.removeEventListener(TimerEvent.TIMER, onTimer);
			}
			
			animTimer = new Timer(1000.0/FrameRate);
			animTimer.stop();
			animTimer.addEventListener(TimerEvent.TIMER, onTimer);
			animTimer.start();
		}
		public function onTimer(evt:TimerEvent)
		{
			var childarr:Array = new Array();
			while(this.numChildren > 0)
				this.removeChildAt(0);
				
			addChild(frames[curAnimFrame]);
			curAnimFrame++;
			if(curAnimFrame == numFrames)
				curAnimFrame = 0;
		}
		
		
		
		//FrameMove
		public function FrameMove(cam_x:Number, cam_y:Number, totalheight:Number)
		{
			var matrix:Matrix;
			
			if(frames.length > 0)
			{
				matrix = new Matrix();
				matrix.translate(-frames[0].width/2, frames[0].height/2);
				matrix.rotate(lrot/180.0*3.14);
				matrix.translate(frames[0].width/2, -frames[0].height/2);
				matrix.translate(cam_x*lz + lx + 240, totalheight - cam_y*lz - ly - 160);
				this.transform.matrix = matrix;
			}
			
			if(bbframe)
			{
				matrix = new Matrix();
				matrix.scale(bb_width,bb_height);
				matrix.translate(-bb_width/2, -bb_height/2);
				matrix.rotate(lrot/180.0*Math.PI);
				matrix.translate(bb_width/2, bb_height/2);
				matrix.translate(cam_x*lz + lx + 240, totalheight - cam_y*lz - ly - 160 - bb_height);
				bbframe.transform.matrix = matrix;
				
				//bbframe.width = bb_width;
				//bbframe.height = bb_height;

			}
		}
		
		
		
		//static
		public function GetParamInt(param:String, from:String):int
		{
			var pattern:RegExp = new RegExp("\n"+param+"[^\n]*","g"); 
			var results:Array = from.match(pattern);
			if(results.length > 0)
			{
				var narr:Array = String(results[0]).split(' ');
				narr.shift();
				return Number(narr.join(' '));
			}
			return 0;
		}
		
		public function GetParamFloat(param:String, from:String):Number
		{
			var pattern:RegExp = new RegExp("\n"+param+"[^\n]*","g"); 
			var results:Array = from.match(pattern);
			if(results.length > 0)
			{
				var narr:Array = String(results[0]).split(' ');
				narr.shift();
				return Number(narr.join(' '));
			}
			return 0;
		}
		
		public function GetParamString(param:String, from:String):String
		{
			var pattern:RegExp = new RegExp("\n"+param+"[^\n]*","g"); 
			var results:Array = from.match(pattern);
			if(results.length > 0)
			{
				var narr:Array = String(results[0]).split(' ');
				narr.shift();
				return String(narr.join(' '));
			}
			return "";
		}
		
		
	}
	
	
}