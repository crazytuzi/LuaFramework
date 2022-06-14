local changeplayericon = class( "changeplayericon", layout );

global_event.CHANGEPLAYERICON_SHOW = "CHANGEPLAYERICON_SHOW";
global_event.CHANGEPLAYERICON_HIDE = "CHANGEPLAYERICON_HIDE";

function changeplayericon:ctor( id )
	changeplayericon.super.ctor( self, id );
	self:addEvent({ name = global_event.CHANGEPLAYERICON_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.CHANGEPLAYERICON_HIDE, eventHandler = self.onHide});
	self.allPreView = nil
	self.selHeadId = nil
end

function changeplayericon:onShow(event)
	if self._show then
		return;
	end

	self:Show();

	self.changeplayericon_defau = LORD.toScrollPane(self:Child( "changeplayericon-defau" )) --LORD.toScrollPane
	self.changeplayericon_close = self:Child( "changeplayericon-close" );
	
	function onClickchangeplayericonClose(args)
		self:onHide();
	end	
	self.changeplayericon_close:subscribeEvent("ButtonClick", "onClickchangeplayericonClose");
    self.changeplayericon_defau:init();
	self:Update();
end

function changeplayericon:Update()
	if not self._show then
		return;
	end
	
	self.changeplayericon_defau:ClearAllItem();
	
		

	
	function onTouchDownPlayerHeadIcon(args)	
		local clickImage = LORD.toMouseEventArgs(args).window
 		local userdata = clickImage:GetUserData()
		for i,v in pairs (self.allPreView) do
			v:SetProperty("ImageName",  "set:itemcell.xml image:itemback3")
		end	
		clickImage:SetProperty("ImageName",  "set:itemcell.xml image:itemback3")
		if(userdata ~= -1)then
	 	
		end				
 	end	 
	function onTouchUpPlayerHeadIcon(args)
		local clickImage = LORD.toWindowEventArgs(args).window;
 		local userdata = clickImage:GetUserData()		
		if(userdata ~= -1)then
			self.selHeadId = userdata
			self:onHide()
			if(self.selHeadId ~= dataManager.playerData:getHeadIcon() )then
				sendChangeIcon(self.selHeadId)
			end
						
		end
 	end	 		
	function onTouchReleasePlayerHeadIcon(args)
		local clickImage = LORD.toWindowEventArgs(args).window;
 		local userdata = clickImage:GetUserData()		
		if(userdata == -1)then
			return
		end
 	end	 	
	if(self.allPreView)then
		for k,v in pairs (self.allPreView) do
			if(self.allPreView[k])then
				self.allPreView[k]:removeAllEvents();	
			end	
		end	
	end
	self.allPreView = {}
	self.tempUi  = {}
	local itemIndex = 0	
	local xpos = LORD.UDim(0, 15)
	local ypos = LORD.UDim(0, 15)

	if(self.selHeadId == nil)	then
		self.selHeadId = dataManager.playerData:getHeadIcon()
	end
	
	local configIcon = dataConfig.configs.iconConfig
	local unittableIcon = {}
	local cardList = cardData:getCardList()
	for i ,v in ipairs(cardList)do
		if(v)then
			local c = v:getConfig()
			if(c) then
				local t ={}
				t['id'] = c.id + UNIT_ICON_SATRT_INDEX
				t['icon'] = c.icon
				table.insert(unittableIcon,t)
			end
		end
	end	
	local sizeIconNormal = #configIcon
	local sizeIconUnit =   #unittableIcon
	
	local size = sizeIconNormal --   + sizeIconUnit
	 
	for i = 1, size do
		local v = nil 
		if(i <= sizeIconNormal)then
			v = configIcon[i]
		else
			v = unittableIcon[i-sizeIconNormal]
		end
		
		self.tempUi[i] ={}
	 			
	 	if v then						
			self.tempUi[i].prew = LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("changeplayericon_"..i, "changeplayericonitem.dlg");
			self.tempUi[i].head_image = LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("changeplayericon_"..i.."_changeplayericonitem-head"))
		 
		 
		 	self.tempUi[i].prew:SetPosition(LORD.UVector2(xpos, ypos));											
			self.changeplayericon_defau:additem(self.tempUi[i].prew);
			--self.changeplayericon_defau:AddChildWindow(self.tempUi[i].prew);
			
			
			self.tempUi[i].head_image:SetImage( v.icon   )
			
			print( i.." "..v.icon)
			
			--self.tempUi[i].head_image:SetImage( '21202.jpg'   )
		 	local width = self.tempUi[i].prew:GetWidth()
		 	xpos = xpos + width	+ LORD.UDim(0, 20)	
			itemIndex = itemIndex + 1
			if(itemIndex >= 6)then
				itemIndex = 0
				xpos = LORD.UDim(0, 15)
				ypos = ypos +  self.tempUi[i].prew:GetHeight() + LORD.UDim(0, 20)
			end				
	 	

		 	self.tempUi[i].prew:subscribeEvent("WindowTouchDown", "onTouchDownPlayerHeadIcon")
	 		self.tempUi[i].prew:subscribeEvent("WindowTouchUp", "onTouchUpPlayerHeadIcon")
	 		self.tempUi[i].prew:subscribeEvent("MotionRelease", "onTouchReleasePlayerHeadIcon")
	 		self.tempUi[i].prew:SetUserData(v.id)
			  
			table.insert(self.allPreView,self.tempUi[i].prew)
			if(i == self.selHeadId)then
				self.tempUi[i].prew:SetProperty("ImageName",  "set:itemcell.xml image:itemback3")
			else
				self.tempUi[i].prew:SetProperty("ImageName",  "set:itemcell.xml image:itemback3")	
			end	
  				
	 	end		
	end		
	
	

end

function changeplayericon:onHide(event)
	self:Close();
	self.allPreView = nil
end

return changeplayericon;
