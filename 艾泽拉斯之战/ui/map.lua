local map = class( "map", layout );

global_event.MAP_SHOW = "MAP_SHOW";
global_event.MAP_HIDE = "MAP_HIDE";

global_event.MAP_UPDATE = "MAP_UPDATE";

local map_size_pixel = {w = 5312,h= 5229}

local ceil = {w = 1328,h= 747}


local row =    map_size_pixel.h/ceil.h --7 
local Column = map_size_pixel.w/ceil.w --4



function map:ctor( id )
	map.super.ctor( self, id );
	self:addEvent({ name = global_event.MAP_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.MAP_HIDE, eventHandler = self.onHide});
	self:addEvent({ name = global_event.MAP_UPDATE, eventHandler = self.onUpdate});
	
	self.mapMoveHandle = nil
	self.MapId = 1
	self.moveDisX = 0
	self.moveDisY =  0
end

function map:onShow(event)
	if self._show then
		return;
	end
	self:Show();

	self.map_map_view = self:Child("map-map_view");
	self.map_map_view:SetProperty("ClipChild","true")
	
	self.map_close = self:Child("map-close");
	function onclickCloseMap()
		self:onHide()
	end
		
	self.map_close:subscribeEvent("ButtonClick", "onclickCloseMap");
	
	self.MAP_NEXT = self:Child("map-NEXT");
	function onclickNextMap()
		if(self.mapMoveHandle)then
			return
		end
 
		 self.preMapId =  self.MapId
		 self.MapId = self.MapId  + 1
		if( self.MapId > #dataConfig.configs.mapsConfig )then
			self.MapId  = 1
		end
		
		--local config =  dataConfig.configs.mapsConfig[self.MapId]
		--local x = -config.mapPosition[1]
		--local y = -config.mapPosition[2]
		
		--self.mapRoot:SetPosition(LORD.UVector2(LORD.UDim(0,  x), LORD.UDim(0, y )));
		self:moveTo()	
	end
	self.MAP_NEXT:subscribeEvent("ButtonClick", "onclickNextMap");
 
	
	
	 
	self.mapRoot = engine.windowManager:CreateGUIWindow("DefaultWindow", "mapRootWindow");
	self.mapRoot:SetPosition(LORD.UVector2(LORD.UDim(0, 0), LORD.UDim(0, 0)));
	self.mapRoot:SetWidth(self.map_map_view:GetWidth()* LORD.UDim(1, 1) )
	self.mapRoot:SetHeight(self.map_map_view:GetHeight()* LORD.UDim(1,1) )
			
	self.map_map_view:AddChildWindow( self.mapRoot)	
	self.mapRoot:SetProperty("Touchable","false")

	local xpos = LORD.UDim(0, 0)
	local ypos = LORD.UDim(0, 0)
	self.tempUi = {}
	local index = 1
	
	local height = 0
	local width = 0
	for i = 1, row  do
		self.tempUi[i] = self.tempUi[i]  or {}
		xpos = LORD.UDim(0, 0)
		for j = 1, Column  do
			local w = 	LORD.toStaticImage(engine.windowManager:CreateGUIWindow("StaticImage", "map_ceil"..i..j))
			self.tempUi[i][j] = w	
			---w:SetWidth(self.mapRoot:GetWidth()* LORD.UDim(1, 0) )
			--w:SetHeight(self.mapRoot:GetHeight()* LORD.UDim(1, 0) )
			w:SetWidth( LORD.UDim(0,ceil.w) * LORD.UDim(1, 1))
			w:SetHeight( LORD.UDim(0, ceil.h) * LORD.UDim(1, 1))
			w:SetPosition(LORD.UVector2(xpos, ypos));											
		 	width = w:GetWidth()
		 	xpos = xpos + width		
			if(height == 0)then
				height = w:GetHeight()		
			end		
			local strFormat = "map%03d%03d%03d"
			local strImg = ""
			strImg = string.format(strFormat, (i-1) * Column  +(j-1),i,j)
			strImg = "set:"..strImg..".xml".." image:"..strImg 
			w:SetImage(strImg)
			self.mapRoot:AddChildWindow(w)	
			w:SetProperty("Touchable","false")
		end
		ypos = ypos + height
	end
	
	 
	local config =  dataConfig.configs.mapsConfig[self.MapId]
	local x = -config.mapPosition[1]
	local y = -config.mapPosition[2]
	self.mapRoot:SetPosition(LORD.UVector2(LORD.UDim(0,  x), LORD.UDim(0, y )));
end

function map:upDate( )
	if not self._show then
		return;
	end
end



function map:onUpdate(event)
	self:upDate();
end


function map:onHide(event)
	self:Close();
	if(self.mapMoveHandle ~= nil)then
		scheduler.unscheduleGlobal(self.mapMoveHandle)
		self.mapMoveHandle = nil
	end
	self.MapId  = 1
end


function map:onmoveChapter(dt) 
	
	local config =  dataConfig.configs.mapsConfig[self.MapId]
	local x = -config.mapPosition[1]
	local y = -config.mapPosition[2]
	
	local preconfig =  dataConfig.configs.mapsConfig[self.preMapId]
	local prex = -preconfig.mapPosition[1]
	local prey = -preconfig.mapPosition[2]
	
	local speedX =(x - prex)/2
	local speedY =(y - prey)/2
	
	self.moveDisX =  self.moveDisX + speedX*dt
	self.moveDisY =  self.moveDisY + speedY*dt 
	 
	if( math.abs(self.moveDisX)>=  math.abs(x -prex)  )then
		self.moveDisX = x -prex
	end
		
	if(   math.abs (self.moveDisY)  >= math.abs(y - prey) )then
		self.moveDisY = y - prey 
	end
	--[[
	print(self.preMapId)
	print(self.MapId)
	
	print("y - prey "..(y - prey))
	print("x -prex "..(x -prex ))
	
	print("self.moveDisY"..self.moveDisY)
	print("self.moveDisX"..self.moveDisX)
   ]]--

	self.mapRoot:SetPosition(LORD.UVector2(LORD.UDim(0,  prex + self.moveDisX), LORD.UDim(0, prey + self.moveDisY )));
 
	if( math.abs(self.moveDisX)>=  math.abs(x -prex)   and  math.abs (self.moveDisY)  >= math.abs(y - prey)  )then
		scheduler.unscheduleGlobal(self.mapMoveHandle) 
		self.mapMoveHandle = nil	
		self.moveDisX = 0
		self.moveDisY = 0							
	end
		
end

function map:moveTo()
 	self.moveDisX = 0
	self.moveDisY = 0	
	if(self.mapMoveHandle)then
		scheduler.unscheduleGlobal(self.mapMoveHandle) 
		self.mapMoveHandle = nil
	end
	self.mapMoveHandle =  scheduler.scheduleUpdateGlobal(handler(self,self.onmoveChapter))	
 
end 

return map;
