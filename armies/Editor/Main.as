package  {
	
	import flash.filesystem.*;
	import flash.display.MovieClip;
	import flash.net.FileReference;
	import flash.events.*;  
    import flash.net.FileFilter;
	import CBlock;
	import CObject;
	import flashx.textLayout.formats.Float;
	
	
	public class Main extends MovieClip {
		
		var fref:FileReference;
		var blocks:Array = new Array();
		var objects:Array = new Array();
		
		var camera_x:Number = 0;
		var camera_y:Number = 0;
		
		var stageheight:Number = 800;
		
		var selectedObject:CObject = null;
		
		var oldMX:Number = 0;
		var oldMY:Number = 0;
		var bX:Boolean = false;
		var bY:Boolean = false;
		var bH:Boolean = false;
		var bW:Boolean = false;
		var bLMB:Boolean = false;
		var bR:Boolean = false;
		
		
		
		public function Main() {
			
			mypanel.mybtn_open.addEventListener(MouseEvent.CLICK, onBtnOpen);
			mypanel.mysubmit.addEventListener(MouseEvent.CLICK, onSubmit);
			mypanel.btn_add.addEventListener(MouseEvent.CLICK, onBtnAdd);
			mypanel.btn_del.addEventListener(MouseEvent.CLICK, onBtnDel);
			mypanel.btn_phy.addEventListener(MouseEvent.CLICK, onBtnPhy);
			mypanel.btn_trig.addEventListener(MouseEvent.CLICK, onBtnTrig);
			mypanel.btn_setcamera.addEventListener(MouseEvent.CLICK, onBtnSetcamera);
			
			mypanel.input_type.addEventListener(MouseEvent.CLICK, showTypes);
			mypanel.input_from_library.addEventListener(MouseEvent.CLICK, showLibrary);
			
			mypanel.btn_saveas.addEventListener(MouseEvent.CLICK, onBtnSave);
			
			addEventListener(Event.ENTER_FRAME, onFrameMove);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKey);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUpped);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMMove);
			
			stage.addEventListener(MouseEvent.MOUSE_DOWN, function(evt:MouseEvent){bLMB = true;});
			stage.addEventListener(MouseEvent.MOUSE_UP, function(evt:MouseEvent){bLMB = false;});
			
		}
		
		function showTypes(evt:MouseEvent)
		{
			mypanel.console.text = "PHY, TRG, DEC, CHR, ITM";
		}
		function showLibrary(evt:MouseEvent)
		{
			//load from library
			var file:File = File.applicationDirectory.resolvePath("Assets\\system\\chars.cfg");
			var fileStream:FileStream = new FileStream();
			fileStream.open(file, FileMode.READ);
			var library:String = fileStream.readUTFBytes(file.size);
			fileStream.close();
			
			mypanel.console.text = "";
			var ob:CBlock = new CBlock;
			var num = ob.GetNumBlocks(library);
			for(var i=0;i<num;i++)
			{
				ob.GetBlockByNum(i,library);
				mypanel.console.text += String(" " + ob.name);
			}
		}
		
		
		function order(a, b):Number {
			var a2:CObject = a;
			var b2:CObject = b;
			trace(a2.zindex + " " + b2.zindex);
			if(a2.zindex > b2.zindex) return 1;
			else if(a2.zindex < b2.zindex) return -1;
			else return 0;
		}
		function onFrameMove(evt:Event)
		{
			//redraw all objects
			while(mystage.numChildren > 0)
				mystage.removeChildAt(0);
			
			//resort objects
			objects.sort(order);
			
			for(var i=0;i<objects.length;i++)
			{
				mystage.addChild(objects[i]);
				objects[i].FrameMove(camera_x, camera_y, stageheight);
			}
			for(var i=0;i<objects.length;i++)
			{
				if(objects[i].bbframe)
					mystage.addChild(objects[i].bbframe);
			}
		}
		function onMMove(evt:MouseEvent)
		{
			var dx = evt.stageX - oldMX;
			var dy = evt.stageY - oldMY;
			
			if(selectedObject)
			{
				if(bX)
				{
					selectedObject.lx += dx;
					mypanel.input_x.text = String(selectedObject.lx);
				}
				if(bY)
				{
					selectedObject.ly += -dy;
					mypanel.input_y.text = String(selectedObject.ly);
				}
				if(bW)
				{
					selectedObject.bb_width += dx;
					mypanel.input_bb_width.text = String(selectedObject.bb_width);
				}
				if(bH)
				{
					selectedObject.bb_height += -dy;
					mypanel.input_bb_height.text = String(selectedObject.bb_height);
				}
				if(bR)
				{
					selectedObject.lrot += dx;
					mypanel.input_rotation.text = String(selectedObject.lrot);
				}
			}
			if(bLMB)
			{
				camera_x += dx;
				camera_y -= dy;
				mypanel.console.text = String(camera_x + ";" + camera_y);
			}
			
			oldMX = evt.stageX;
			oldMY = evt.stageY;
		}
		function onKey(evt:KeyboardEvent)
		{
			//trace(evt.keyCode);
			if(evt.keyCode == 88) //x
			{
				bX = true;
			}
			if(evt.keyCode == 67) //c
			{
				bY = true;
			}
			if(evt.keyCode == 86) //v
			{
				bW = true;
			}
			if(evt.keyCode == 66) //b
			{
				bH = true;
			}
			if(evt.keyCode == 82) //r
			{
				bR = true;
			}
			
			if(evt.keyCode == 37) //left
			{
				camera_x += 10.0;
			}
			else if(evt.keyCode == 38) //up
			{
				camera_y -= 10.0;
			}
			else if(evt.keyCode == 39) //right
			{
				camera_x -= 10.0;
			}
			else if(evt.keyCode == 40) //down
			{
				camera_y += 10.0;
			}
		}
		function onKeyUpped(evt:KeyboardEvent)
		{
			//trace(evt.keyCode);
			if(evt.keyCode == 88) //x
			{
				bX = false;
			}
			if(evt.keyCode == 67) //c
			{
				bY = false;
			}
			if(evt.keyCode == 86) //v
			{
				bW = false;
			}
			if(evt.keyCode == 66) //b
			{
				bH = false;
			}
			if(evt.keyCode == 82) //r
			{
				bR = false;
			}
		}
		
		
		function onObjSelected(evt:MouseEvent)
		{
			if(CObject.prototype.isPrototypeOf(evt.target))
				SelectObject((CObject)(evt.target));
			else
				SelectObject((CObject)((smallframe)(evt.target).parentObject));
		}
		function SelectObject(obj:CObject)
		{
			selectedObject = obj;
			
			//fill panel
			mypanel.input_objname.text = obj.lname;
			mypanel.input_graphics.text = obj.lgraphics;
			mypanel.input_type.text = obj.type;
			mypanel.input_bb_width.text = String(obj.bb_width);
			mypanel.input_bb_height.text = String(obj.bb_height);
			mypanel.input_x.text = String(obj.lx);
			mypanel.input_y.text = String(obj.ly);
			mypanel.input_z.text = String(obj.lz);
			mypanel.input_from_library.text = obj.fromlibrary;
			mypanel.input_health.text = String(obj.health);
			mypanel.input_onenter.text = obj.onenter;
			mypanel.input_onleave.text = obj.onleave;
			mypanel.input_active.text = obj.active;
			mypanel.input_triggeronce.text = obj.triggeronce;
			mypanel.input_zindex.text = String(obj.zindex);
			mypanel.input_rotation.text = String(obj.lrot);
			mypanel.input_ai.text = String(obj.ai);
		}
		
		
		function onSubmit(evt:MouseEvent)
		{
			if(selectedObject)
			{
				//discard existing events
				if(selectedObject.bbframe) mystage.removeChild(selectedObject.bbframe);
				
				 selectedObject.lname = mypanel.input_objname.text;
				 selectedObject.lgraphics = mypanel.input_graphics.text;
				 selectedObject.type = mypanel.input_type.text;
				 selectedObject.bb_width = int(mypanel.input_bb_width.text);
				 selectedObject.bb_height = int(mypanel.input_bb_height.text);
				 selectedObject.lx = int(mypanel.input_x.text);
				 selectedObject.ly = int(mypanel.input_y.text);
				 selectedObject.lz = Number(mypanel.input_z.text);
				 selectedObject.fromlibrary = mypanel.input_from_library.text;
				 selectedObject.health = int(mypanel.input_health.text);
				 selectedObject.onenter = mypanel.input_onenter.text;
				 selectedObject.onleave = mypanel.input_onleave.text;
				 selectedObject.active = mypanel.input_active.text;
				 selectedObject.triggeronce = mypanel.input_triggeronce.text;
				 selectedObject.zindex = int(mypanel.input_zindex.text);
				 selectedObject.lrot = int(mypanel.input_rotation.text);
				 selectedObject.ai = int(mypanel.input_ai.text);
				 
				 selectedObject.LoadFromPresent();
			}
		}
		
		function onBtnAdd(evt:MouseEvent)
		{
			var no:CObject = new CObject;
			selectedObject = no;
			onSubmit(evt);

			objects.push(no);
			no.FrameMove(camera_x, camera_y, stageheight);
			mystage.addChild(no);
			no.addEventListener(MouseEvent.CLICK, onObjSelected);
			
			if(no.bbframe)
			{
				mystage.addChild(no.bbframe);
				no.bbframe.addEventListener(MouseEvent.CLICK, onObjSelected);
			}
		}
		function onBtnDel(evt:MouseEvent)
		{
			for(var i=0; i<objects.length; i++)
			{
				if(objects[i] == selectedObject)
				{
					objects.splice(i,1);
					mystage.removeChild(selectedObject);
					if(selectedObject.bbframe) mystage.removeChild(selectedObject.bbframe);
					selectedObject = null;
					break;
				}
			}
		}
		
		function onBtnPhy(evt:MouseEvent)
		{
			mypanel.input_graphics.text = "gamedata/dummy";
			mypanel.input_type.text = "PHY";
			mypanel.input_bb_width.text = "100";
			mypanel.input_bb_height.text = "100";
			mypanel.input_x.text = "300";
			mypanel.input_y.text = "300";
			mypanel.input_z.text = "1";
			mypanel.input_from_library.text = "";
			mypanel.input_health.text = "0";
			mypanel.input_onenter.text = "";
			mypanel.input_onleave.text = "";
			mypanel.input_active.text = "1";
			mypanel.input_triggeronce.text = "";
			mypanel.input_zindex.text = "0";
			mypanel.input_rotation.text = "0";
			mypanel.input_ai.text = "0";
		}
		function onBtnTrig(evt:MouseEvent)
		{
			mypanel.input_graphics.text = "gamedata/dummy";
			mypanel.input_type.text = "TRG";
			mypanel.input_bb_width.text = "100";
			mypanel.input_bb_height.text = "100";
			mypanel.input_x.text = "300";
			mypanel.input_y.text = "300";
			mypanel.input_z.text = "1";
			mypanel.input_from_library.text = "";
			mypanel.input_health.text = "0";
			mypanel.input_onenter.text = "FUNCHERE1";
			mypanel.input_onleave.text = "FUNCHERE2";
			mypanel.input_active.text = "1";
			mypanel.input_triggeronce.text = "";
			mypanel.input_zindex.text = "0";
			mypanel.input_rotation.text = "0";
			mypanel.input_ai.text = "0";
		}
		
		public function onBtnOpen(evt:MouseEvent)
		{
			// constructor code
			fref = new FileReference;
			fref.addEventListener(Event.SELECT, onFileSelected);
			var textTypeFilter:FileFilter = new FileFilter("Level Files (*.lev)", "*.lev"); 
            fref.browse([textTypeFilter]);
		}
		public function onFileSelected(evt:Event):void 
        { 
            //fref.addEventListener(ProgressEvent.PROGRESS, onProgress); 
            fref.addEventListener(Event.COMPLETE, onComplete); 
            fref.load(); 
        }
		
		
		public function onBtnSetcamera(evt:MouseEvent)
		{
			mypanel.input_camera_max.text = String(camera_x);
		}
		
		public function onBtnSave(evt:MouseEvent)
		{
			var data:String = "\n[CONFIG]\n";
			data += "script " + mypanel.input_scriptname.text + "\n";
			data += "spellsallow "+mypanel.input_spells_allow.text+"\n";
			data += "cameraMax "+mypanel.input_camera_max.text+"\n";
			data += "#\n\n";
			
			for(var i=0;i<objects.length;i++)
			{
				data += objects[i].ToSave() + "\n\n";
			}
			
			fref = new FileReference;
			fref.save(data,"NewLev.lev"); 
		}
		
		
		public function onComplete(evt:Event):void 
        { 
			var i:int;
						
			//load smth from configs
			var tempo:CObject = new CObject;
			var obj:CBlock = new CBlock();
			obj.GetBlockByName("CONFIG",String(fref.data));
			mypanel.input_spells_allow.text = tempo.GetParamString("spellsallow",obj.text);
			mypanel.input_camera_max.text = tempo.GetParamString("cameraMax",obj.text);
			mypanel.input_scriptname.text = tempo.GetParamString("script",obj.text);
			
			//load blocks
			var numBlocks:int = obj.GetNumBlocks(String(fref.data));			
			blocks = new Array();
			for(i=1;i<numBlocks;i++) //skip config
			{
				var nb:CBlock = new CBlock();
				nb.GetBlockByNum(i,String(fref.data));
				blocks.push(nb);
			}
			
			//load objects from blocks
			objects = new Array();
			for(i=0;i<blocks.length;i++)
			{
				var no:CObject = new CObject;
				no.LoadFromString(blocks[i].text);
				objects.push(no);
				no.FrameMove(camera_x, camera_y, stageheight);
				mystage.addChild(no);
				no.addEventListener(MouseEvent.CLICK, onObjSelected);
			}
			for(i=0;i<objects.length;i++)
			{
				if(objects[i].bbframe)
				{
					mystage.addChild(objects[i].bbframe);
					objects[i].bbframe.addEventListener(MouseEvent.CLICK, onObjSelected);
				}
			}
			
			
        } 
	}
	
}
