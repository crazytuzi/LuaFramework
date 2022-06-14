local pvprule = class( "pvprule", layout );

global_event.PVPRULE_SHOW = "PVPRULE_SHOW";
global_event.PVPRULE_HIDE = "PVPRULE_HIDE";

function pvprule:ctor( id )
	pvprule.super.ctor( self, id );
	self:addEvent({ name = global_event.PVPRULE_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.PVPRULE_HIDE, eventHandler = self.onHide});
	self.allPreView = {}
end

function pvprule:onShow(event)
	if self._show then
		return;
	end

	self:Show();

	self.pvprule_scroll = LORD.toScrollPane(self:Child( "pvprule-scroll" ));
	self.pvprule_close = self:Child( "pvprule-close" );
	self.pvprule_scroll:init();
	
	function onClickClosepvprule()
		self:onHide()		
	end
		
	self.pvprule_close:subscribeEvent("ButtonClick", "onClickClosepvprule")	 
	self:upDate();
end

function pvprule:onUpDate(event)
	self:upDate();
end

function pvprule:upDate()
	 if not self._show then
		return;
	end
	
	
	if not self._show then
		return;
	end
	self.pvprule_scroll:ClearAllItem() 
	
	
	local xpos = LORD.UDim(0, 10)
	local ypos = LORD.UDim(0, 10)
	
	function onTouchDownPvpruleRank(args)	
		local clickImage = LORD.toWindowEventArgs(args).window
		local rect = clickImage:GetUnclippedOuterRect();
 		local userdata = clickImage:GetUserData()
		for i,v in pairs (self.allPreView) do
			v:SetProperty("ImageName",  "set:common.xml image:ditu10")
		end	
		clickImage:SetProperty("ImageName",  "")
		if(userdata ~= -1)then
	 		self.selectPlayer = userdata
		end				
 	end	 
	function onTouchUpPvpruleRank(args)
		local clickImage = LORD.toWindowEventArgs(args).window;
 		local userdata = clickImage:GetUserData()	
		if(userdata ~= -1)then				
		end
 	end	 		
	function onTouchReleasePvpruleRank(args)
		local clickImage = LORD.toWindowEventArgs(args).window;
 		local userdata = clickImage:GetUserData()	
		if(userdata == -1)then
			return
		end
		 
		
 	end	 	
	 

	for k,v in pairs (self.allPreView) do
		self.allPreView[k].record:removeEvent("ButtonClick");		
	end		
	self.allPreView = {}
	self.tempUi  = {}
	
	
	local  info1 = LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("pvprule1_", "pvpruletext1.dlg");
    local  info1Rank =   (LORD.GUIWindowManager:Instance():GetGUIWindow("pvprule1_".."_pvpruletext1-rank-now-num"))
	local  info1gem =   (LORD.GUIWindowManager:Instance():GetGUIWindow("pvprule1_".."_pvpruletext1-reward1-num"))	
	local  info1HistroyRank =   (LORD.GUIWindowManager:Instance():GetGUIWindow("pvprule1_".."_pvpruletext1-rank-now-num_2"))
	local  warning =   (LORD.GUIWindowManager:Instance():GetGUIWindow("pvprule1_".."_pvpruletext1-reward-warning"))
	
	info1:SetPosition(LORD.UVector2(xpos, ypos));		
	self.pvprule_scroll:additem(info1);
	
	xpos = LORD.UDim(0, 10)
	ypos = ypos + info1:GetHeight() + LORD.UDim(0, 5)			
	local nowRanking,_nowRanking = dataManager.pvpData:getOfflineRanking()
	info1Rank:SetText(nowRanking)
	info1HistroyRank:SetText(dataManager.pvpData:getOfflinePlayerMaxRank())
	
	local rewars = {}
	for i = 1, 4 do
			rewars[i] = {}
			rewars[i].icon =  LORD.toStaticImage( (LORD.GUIWindowManager:Instance():GetGUIWindow("pvprule1_".."_pvpruletext1-reward"..i)))	
			rewars[i].num = (LORD.GUIWindowManager:Instance():GetGUIWindow("pvprule1_".."_pvpruletext1-reward"..i.."-num"))
			rewars[i].num:SetText(0)		 
	end
 
	local t = dataManager.pvpData:getOfflineRankReward(_nowRanking )
	
	for i = 1, 4 do
		if(t[i])then
		    rewars[i].icon:SetVisible(t[i].count ~= 0)
			warning:SetVisible(t[i].count == 0)
			rewars[i].icon:SetProperty("ImageName",  t[i].icon)
			rewars[i].num:SetText(t[i].count)
		end	
	end	

	local  info2 = LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("pvprule2_", "pvpruletext2.dlg");
	info2:SetPosition(LORD.UVector2(xpos, ypos));		
	self.pvprule_scroll:additem(info2);
	xpos = LORD.UDim(0, 150)
	ypos = ypos + info2:GetHeight() + LORD.UDim(0, 5)	
	
	
	local preRankLevel = nil
	for i,v in ipairs (dataManager.pvpData:getPvpOfflineRankConfig()) do
		self.tempUi[i] ={}
	 	local player = v				
	 	if v then						
			self.tempUi[i].prew = LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("pvprule3_"..i, "pvpruletext3.dlg");
			self.tempUi[i].rank = LORD.GUIWindowManager:Instance():GetGUIWindow("pvprule3_"..i.."_pvpruletext3-reward")
			self.tempUi[i].gem =   LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("pvprule3_"..i.."_pvpruletext3-reward1-num"))
			self.tempUi[i].prew :SetPosition(LORD.UVector2(xpos, ypos));								
			self.pvprule_scroll:additem(self.tempUi[i].prew);
			
			xpos = LORD.UDim(0, 150)
			ypos = ypos + self.tempUi[i].prew:GetHeight() + LORD.UDim(0, 5)				
		 	self.tempUi[i].prew:subscribeEvent("WindowTouchDown", "onTouchDownPvpruleRank")
	 		self.tempUi[i].prew:subscribeEvent("WindowTouchUp", "onTouchUpPvpruleRank")
	 		self.tempUi[i].prew:subscribeEvent("MotionRelease", "onTouchReleasePvpruleRank")
	 		self.tempUi[i].prew:SetUserData(i)
			
			if(preRankLevel)then
				if(v.rank - preRankLevel == 1)then
					self.tempUi[i].rank:SetText("第"..v.rank.."名")		
				else
					self.tempUi[i].rank:SetText("第"..(preRankLevel+1)  .."-"..v.rank.."名")	
				end	
			else
				self.tempUi[i].rank:SetText("第"..v.rank.."名")	
			end
			preRankLevel = v.rank

			table.insert(self.allPreView,self.tempUi[i].prew)
			if(i == self.selectPlayer)then
				self.tempUi[i].prew:SetProperty("ImageName",  "")
			else
				self.tempUi[i].prew:SetProperty("ImageName",  "set:common.xml image:ditu10")	
			end	
	 
			
			self.tempUi[i].rewars = {}
			for j = 1, 4 do
					self.tempUi[i].rewars[j] = {}
					self.tempUi[i].rewars[j].icon =  LORD.toStaticImage( (LORD.GUIWindowManager:Instance():GetGUIWindow("pvprule3_"..i.."_pvpruletext3-reward"..j)))	
					self.tempUi[i].rewars[j].num = (LORD.GUIWindowManager:Instance():GetGUIWindow("pvprule3_"..i.."_pvpruletext3-reward"..j.."-num"))
					self.tempUi[i].rewars[j].num:SetText("")	
					self.tempUi[i].rewars[j].icon:SetProperty("ImageName",  "")	 
			end
																			
			local t = dataManager.pvpData:getOfflineRankReward(v.rank )			
			for j = 1, 4 do
				if(t[j])then
					if(t[j].count > 0)then
						self.tempUi[i].rewars[j].icon:SetProperty("ImageName",  t[j].icon)
						self.tempUi[i].rewars[j].num:SetText(t[j].count)
					end
				end	
			end	
			
			
	 
	 	end		
	end		
 
end

function pvprule:onHide(event)
	self:Close()
	self.allPreView = {}
end

return pvprule;
