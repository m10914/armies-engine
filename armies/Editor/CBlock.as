package {
	
	
	import flash.text.*;
	
	public class CBlock {
		
		public var name:String;
		public var text:String;
		
	
		public function CBlock()
		{
			name = "undefined";
			text = "undefined";
		}
		
		public function GetBlockByName(look_for_name:String, in_file:String)
		{
			var pattern:RegExp = new RegExp("\\["+look_for_name+"\\][^#]*#","g"); 
			var results:Array = in_file.match(pattern);
			if(results.length > 0)
			{
				var curres:String = String(results[0]);
				
				//get name
				var npat:RegExp = new RegExp("\\[([^\\]]*)\\]","g");
				var nres:Array = curres.match(npat);
				if(nres.length > 0)
				{
					name = nres[0].replace(new RegExp("[\\[\\]]\r","g"),"");
				}
				
				//get text
				npat = new RegExp("\\][^#]*","g");
				nres = curres.match(npat);
				if(nres.length > 0)
				{
					text = nres[0].replace(new RegExp("[\\[\\]\r]","g"),"");
				}
			}
		}
		
		public function GetBlockByNum(num:int, from_file:String)
		{
			var pattern:RegExp = /\n\[([^\]]*)\][^#]*#/g; 
			var results:Array = from_file.match(pattern);
			if(num < results.length)
			{
				var curres:String = String(results[num]);
				
				//get name
				var npat:RegExp = new RegExp("\\[([^\\]]*)\\]","g");
				var nres:Array = curres.match(npat);
				if(nres.length > 0)
				{
					name = nres[0].replace(new RegExp("[\\[\\]]\r","g"),"");
				}
				
				//get text
				npat = new RegExp("\\][^#]*","g");
				nres = curres.match(npat);
				if(nres.length > 0)
				{
					text = nres[0].replace(new RegExp("[\\[\\]\r]","g"),"");
				}
			}
		}
		
		
		//static
		public function GetNumBlocks(in_file:String):int
		{
			var pattern:RegExp = /\n\[[^\]]*\][^#]*#/g; 
			var results:Array = in_file.match(pattern);
			return results.length;
		}
		
		
	}
	
}