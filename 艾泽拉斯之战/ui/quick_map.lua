local quick_map = class( "quick_map", layout );

global_event.QUICK_MAP_SHOW = "QUICK_MAP_SHOW";
global_event.QUICK_MAP_HIDE = "QUICK_MAP_HIDE";

function quick_map:ctor( id )
	quick_map.super.ctor( self, id );
	self:addEvent({ name = global_event.QUICK_MAP_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.QUICK_MAP_HIDE, eventHandler = self.onHide});
	self:addEvent({ name = global_event.INSTANCEINFOR_HIDE_ON_MOVE, eventHandler = self.onActorMove});
	self:addEvent({ name = global_event.SUCCESS_SYSTEM_REWARD_CHAPTER, eventHandler = self.onChapterReward});
	self.allPreView = {}
end

function quick_map:onActorMove(event)
	 self:onHide()
end

function quick_map:onShow(event)
	if self._show then
		return;
	end
	self.selectChapter = event.chapter
	self.posChapter = event.chapter
	
	self.curSelStafeMode = event.curSelStafeMode
	self:Show();
	self.quick_map_close = self:Child( "quick_map-close" )
	
	
	function onClickClosequick_map()
		self:onHide()		
	end
		
	self.quick_map_close:subscribeEvent("ButtonClick", "onClickClosequick_map")	  
	
 
	self.quick_map_scrollablepane = LORD.toScrollPane(self:Child( "quick_map-scrollablepane" ));
	self.quick_map_scrollablepane:init();
	self:upDate()
end

function quick_map:onChapterReward()
	self:upDate()
end	


function quick_map:upDate()
	
	if not self._show then
		return
	end


	self.quick_map_scrollablepane:ClearAllItem() 		
	local xpos = LORD.UDim(0, 10)
	local ypos = LORD.UDim(0, 10)
	
	function onTouchDownQuick_map(args)	
		--[[
		local clickImage = LORD.toMouseEventArgs(args).window
		local rect = clickImage:GetUnclippedOuterRect();
 		local userdata = clickImage:GetUserData()
		for i,v in pairs (self.allPreView) do
			--v:SetProperty("ImageName",  "set:common.xml image:ditu6")
			if(v and v.choose)then
				v.choose:SetVisible(false);
			end
			
		end	
		if(clickImage and clickImage.choose)then
			clickImage.choose:SetVisible(true);
		end
		
		
		--clickImage:SetProperty("ImageName",  "set:maincontrol1.xml image:skillcontainer")
		if(userdata ~= -1)then
	 		self.selectChapter = userdata
		end		
		]]--		
 	end	 
	function onTouchUpQuick_map(args)
		local clickImage = LORD.toWindowEventArgs(args).window;
 		local userdata = clickImage:GetUserData()	
		if(userdata ~= -1)then
			 				 
			self:onHide()
			
			local zones = dataManager.instanceZonesData	
			local IncidentList = {}
			if(self.curSelStafeMode == enum.Adventure_TYPE.NORMAL)then
				local maxIncidentCount = dataManager.mainBase:getLingDiMaxCount(); 
				for i = 1, maxIncidentCount do
					local position = dataManager.mainBase:getIncidentPosition(i);
					local eventID = dataManager.mainBase:getPlayerIncidentIndex(i);
					local point = dataManager.mainBase:getIncidentPoint(i);
					local AdventureId = zones:serchAdventureIdWithPoint( point)
					table.insert(IncidentList,AdventureId)	
			   end
			end
			
			local AdventureId = nil
			
			local curChapter = zones:getAllChapter()[userdata]	
			local num ,all = curChapter:getPerfectProcess(self.curSelStafeMode)	
			local fullStar =  num >= all
			if(fullStar)then
				local bhasIncident,_id =   curChapter:hasAdventure(IncidentList)
				if(bhasIncident)then
					AdventureId = _id     ---前往事件关卡
				else
					local Adventure = curChapter:getAdventure()   --前往当前可以打的最靠后的那个关卡
					AdventureId = Adventure[curChapter:getLastCanBattleAdventure(self.curSelStafeMode)] 	
				end
			else
				local Adventure = curChapter:getAdventure()
					 for i,v in ipairs (Adventure) do
						local stage =  dataManager.instanceZonesData:getStageWithAdventureID(v,self.curSelStafeMode);
						if stage:isMissed() == false and (not stage:isFullStar()) then
							AdventureId = v
							 break 
						end
					end
					
				

			end		
			
			eventManager.dispatchEvent({name = global_event.INSTANCECHOICE_UPDATE, chapter = userdata ,AdventureId = AdventureId } )					
		end

 	end	 		
	function onTouchReleaseQuick_map(args)
		local clickImage = LORD.toWindowEventArgs(args).window;
 		local userdata = clickImage:GetUserData()		
		if(userdata == -1)then
			return
		end
	
 	end	 	
	
	local zones = dataManager.instanceZonesData
	local allChapter =  zones:getAllChapter()
	

	self.allPreView = {}
	self.tempUi  = {}  
	
	
	function quick_map_on_chapteraward_button_clickClose(args)
		eventManager.dispatchEvent({name =  global_event.WARNINGHINT_SHOW,tip = "获得该章节全部星级即可开启宝箱" })
	end
	
	
	function quick_map_on_chapteraward_button_click(args)

		if(global.tipBagFull())then
			return
		end		
		local rewardType = nil
		if(self.curSelStafeMode == enum.Adventure_TYPE.NORMAL )then
			rewardType = enum.SYSTEM_REWARD_TYPE.SYSTEM_REWARD_TYPE_CHAPTER_NORMAL
		elseif(self.curSelStafeMode == enum.Adventure_TYPE.ELITE )then
			rewardType	= enum.SYSTEM_REWARD_TYPE.SYSTEM_REWARD_TYPE_CHAPTER_ELITE
		end
		
		
		local clickImage = LORD.toWindowEventArgs(args).window;
 		local userdata = clickImage:GetUserData()	
		
		local zones = dataManager.instanceZonesData	
		local curChapter = zones:getAllChapter()[userdata]			
		sendSystemReward(rewardType, curChapter:getId())	
	end
	
	local stage = zones:getNewInstance(self.curSelStafeMode)
	local newMaxChapter = stage:getChapter():getId()	
	
	local IncidentList = {}
	if(self.curSelStafeMode == enum.Adventure_TYPE.NORMAL)then
		local maxIncidentCount = dataManager.mainBase:getLingDiMaxCount(); 
		for i = 1, maxIncidentCount do
			 
			local position = dataManager.mainBase:getIncidentPosition(i);
			local eventID = dataManager.mainBase:getPlayerIncidentIndex(i);
			local point = dataManager.mainBase:getIncidentPoint(i);
			local AdventureId = zones:serchAdventureIdWithPoint( point)
			table.insert(IncidentList,AdventureId)	
	   end
	end
		
	 for i,v in ipairs (allChapter) do
		if(v and v:haveAward(self.curSelStafeMode) == false ) then			
			local num ,all = v:getPerfectProcess(self.curSelStafeMode)	
			if(num >= all)then
				self.selectChapter = i
				break
			end	
		end
	end	
	
	
	self.allOffset ={}
	for i,v in ipairs (allChapter) do
		self.tempUi[i] ={}
	 	local player = v				
	 	if player then						
			self.tempUi[i].prew = LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("quick_map_"..i, "quick_map-chapter.dlg");
			 
			self.tempUi[i].chapterBack = LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("quick_map_"..i.."_quick_map-chapter-quick_map-chapter-itembg"))
			self.tempUi[i].chapterId =  (LORD.GUIWindowManager:Instance():GetGUIWindow("quick_map_"..i.."_quick_map-chapter-num"))
			self.tempUi[i].chapterName = LORD.GUIWindowManager:Instance():GetGUIWindow("quick_map_"..i.."_quick_map-chapter-name")
			self.tempUi[i].chapterChoose = LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("quick_map_"..i.."_quick_map-chapter-chose"))
			self.tempUi[i].chaptergofight = LORD.GUIWindowManager:Instance():GetGUIWindow("quick_map_"..i.."_quick_map-chapter-gofight")
			self.tempUi[i].chapterUnopen = LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("quick_map_"..i.."_quick_map-chapter-unopen"))
			
			self.tempUi[i].giftboxclose = LORD.GUIWindowManager:Instance():GetGUIWindow("quick_map_"..i.."_quick_map-chapter-giftboxclose")
			self.tempUi[i].giftboxopen = LORD.GUIWindowManager:Instance():GetGUIWindow("quick_map_"..i.."_quick_map-chapter-giftboxopen")
			self.tempUi[i].giftboxopenEffect = LORD.GUIWindowManager:Instance():GetGUIWindow("quick_map_"..i.."_quick_map-chapter-giftopeneffect")
			self.tempUi[i].chapter_star = LORD.GUIWindowManager:Instance():GetGUIWindow("quick_map_"..i.."_quick_map-chapter-star")
			self.tempUi[i].starnum = LORD.GUIWindowManager:Instance():GetGUIWindow("quick_map_"..i.."_quick_map-chapter-starnum")
			self.tempUi[i].starnumicon = LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("quick_map_"..i.."_quick_map-chapter-staricon"))
			
			
			self.tempUi[i].randomevent = LORD.GUIWindowManager:Instance():GetGUIWindow("quick_map_"..i.."_quick_map-chapter-randomevent")
			self.tempUi[i].money = {}
			self.tempUi[i].moneyIcon = {}
			
			self.normalmod = LORD.toStaticImage(self:Child("quick_map-normalmod"));
			self.jymod = LORD.toStaticImage(self:Child("quick_map-jymod"));
			for z= 1 ,3 do	
				self.tempUi[i].money[z] = LORD.GUIWindowManager:Instance():GetGUIWindow("quick_map_"..i.."_quick_map-chapter-money"..z.."-text") 
				self.tempUi[i].moneyIcon[z] = LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("quick_map_"..i.."_quick_map-chapter-money"..z.."-icon") )
		 
			end			
			
			self.tempUi[i].itemsp = LORD.GUIWindowManager:Instance():GetGUIWindow("quick_map_"..i.."_quick_map-chapter-giftinfo-itemsp")
			
			self.tempUi[i].chapter_gift = LORD.GUIWindowManager:Instance():GetGUIWindow("quick_map_"..i.."_quick_map-chapter-gift")
			
			if(self.curSelStafeMode == enum.Adventure_TYPE.NORMAL )then
				self.tempUi[i].starnumicon:SetImage("set:stage.xml image:star")
				self.normalmod:SetVisible(true);
				
			else
				self.tempUi[i].starnumicon:SetImage("set:battle1.xml image:star2")
				self.jymod:SetVisible(true);
			end

			
		 	self.tempUi[i].prew:SetPosition(LORD.UVector2(xpos, ypos));											
			self.quick_map_scrollablepane:additem(self.tempUi[i].prew);
		
		 	local width = self.tempUi[i].prew:GetWidth()
		 	xpos = xpos + width			
			xpos = LORD.UDim(0, 10)
			ypos = ypos + self.tempUi[i].prew:GetHeight() + LORD.UDim(0, 5)				
			table.insert(self.allOffset,ypos.offset)
		 	--self.tempUi[i].prew:subscribeEvent("WindowTouchDown", "onTouchDownQuick_map")
	 		--self.tempUi[i].prew:subscribeEvent("WindowTouchUp", "onTouchUpQuick_map")
	 		--self.tempUi[i].prew:subscribeEvent("MotionRelease", "onTouchReleaseQuick_map")
	 		self.tempUi[i].prew:SetUserData(i)
			self.tempUi[i].prew:SetEnabled(player:getId()<= newMaxChapter)
			self.tempUi[i].chapterBack:SetEnabled(player:getId()<= newMaxChapter)
			self.tempUi[i].chaptergofight:subscribeEvent("ButtonClick", "onTouchUpQuick_map")	  
			self.tempUi[i].chaptergofight:SetUserData(i)
			self.tempUi[i].chapterId:SetText(i)	
			self.tempUi[i].chapterName:SetText(player:getName())	
			
			table.insert(self.allPreView,self.tempUi[i].prew)
			self.tempUi[i].prew.choose = self.tempUi[i].chapterChoose 
			if(i == self.posChapter)then
				--self.tempUi[i].prew:SetProperty("ImageName",  "set:maincontrol1.xml image:skillcontainer")
				self.tempUi[i].chapterChoose:SetVisible(true);
				self.tempUi[i].chaptergofight:SetVisible(false);
			else
				--self.tempUi[i].prew:SetProperty("ImageName",  "set:common.xml image:ditu6")
				self.tempUi[i].chapterChoose:SetVisible(false);
				self.tempUi[i].chaptergofight:SetVisible(player:getId()<= newMaxChapter);
				self.tempUi[i].chapterUnopen:SetVisible(player:getId()> newMaxChapter);
				--self.tempUi[i].chaptergofight:SetVisible(true);
			end	
			
			
			local v = player:haveAward(self.curSelStafeMode)
			local num ,all = player:getPerfectProcess(self.curSelStafeMode)
			local VisibleOpenBox = num >= all
			
				self.tempUi[i].giftboxclose:SetVisible( not VisibleOpenBox)
				self.tempUi[i].giftboxopen:SetVisible(VisibleOpenBox)
				self.tempUi[i].giftboxopen:SetVisible(VisibleOpenBox and (not v))			
				if( v )then
					--self.tempUi[i].giftboxclose:SetVisible( false)
					--self.tempUi[i].giftboxopen:SetVisible(false)
					--self.tempUi[i].giftboxopenEffect:SetVisible(false)
					--self.tempUi[i].chapter_star:SetVisible(false)	
			 	
					self.tempUi[i].chapter_gift:SetVisible( false)
					local pos = self.tempUi[i].chapterName:GetPosition()
					pos =   LORD.UVector2(pos.x, pos.y + LORD.UDim(0, 40) )
					self.tempUi[i].chapterName:SetPosition(pos)	
					self.tempUi[i].chapterName:SetProperty("Font" , "HT-40")
				else
					self.tempUi[i].chapter_gift:SetVisible( true)	
				end	
				
				
				self.tempUi[i].giftboxopen:subscribeEvent("ButtonClick", "quick_map_on_chapteraward_button_click");	 
				
				self.tempUi[i].giftboxclose:subscribeEvent("ButtonClick", "quick_map_on_chapteraward_button_clickClose");	 				
					
				self.tempUi[i].giftboxopen:SetUserData(i)
				local pro =  num.."/"..all	
				self.tempUi[i].starnum:SetText(pro)
				local bhasIncident = player:hasAdventure(IncidentList)
				self.tempUi[i].randomevent:SetVisible(bhasIncident)	
				
				--local t = { enum.MONEY_TYPE.MONEY_TYPE_GOLD,enum.MONEY_TYPE.MONEY_TYPE_VIGOR, enum.MONEY_TYPE.MONEY_TYPE_LUMBER,enum.MONEY_TYPE.MONEY_TYPE_DIAMOND} 
				local moneyIndex = 0
				
				for z= 1 ,3 do	
						if(self.tempUi[i].money[z])then
							self.tempUi[i].money[z]:SetText( "" )
							self.tempUi[i].moneyIcon[z]:SetImage( "" )
						end
				end				
				
				local t = player:getChapterRewardConfig(self.curSelStafeMode)
				--['type'] = {1, 1, 1, 2},
				--['id'] = {2, 0, 1, 20},
				--['count'] = {30, 2000, 1000, 20},
				
				local tsize = #t.type
				for z= 1, tsize do	
					if( t.type[z] == enum.REWARD_TYPE.REWARD_TYPE_MONEY ) then
						local num = t.count[z]
						if(num > 0 )then
							moneyIndex = moneyIndex + 1
							if(self.tempUi[i].money[moneyIndex])then
								self.tempUi[i].money[moneyIndex]:SetText( num )
								self.tempUi[i].moneyIcon[moneyIndex]:SetImage(  enum.MONEY_ICON_STRING[ t.id[z] ])
							end	
						end
					end
			 
				end
				self.tempUi[i].itemsp:CleanupChildren()	
				
				
				local reward = player:getChapterReward(self.curSelStafeMode)
				local itemIndex = 0
				local nums = #reward
				local xpos = LORD.UDim(0, 5)
				local ypos = LORD.UDim(0, -10)
	
				for z = 1,nums do	
					local item = reward[z]			
					if (item  and  item._type ~= enum.REWARD_TYPE.REWARD_TYPE_MONEY )then		
							itemIndex = itemIndex + 1
								
							local itemWind = LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("quick_map_"..i.." "..z, "instanceawarditem.dlg");
							local itemStar  = LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("quick_map_"..i.." "..z.."_instanceawarditem-equity"));										
							local itemIcon = LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("quick_map_"..i.." "..z.."_instanceawarditem-item-image"));	
							local itemName= LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("quick_map_"..i.." "..z.."_instanceawarditem-num"));				
							local item_num= LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("quick_map_"..i.." "..z.."_instanceawarditem-num"));
							local instanceawarditem_rare= LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("quick_map_"..i.." "..z.."_instanceawarditem-rare"));
							local instanceawarditem_item = LORD.toStaticImage(self:Child("quick_map_"..i.." "..z.."_instanceawarditem-item"));
							instanceawarditem_rare:SetVisible(false);
							
							local uistars = {};
							for starIndex=1, 5 do
								uistars[starIndex] = self:Child("quick_map_"..i.." "..z.."_instanceawarditem-star"..starIndex);
								uistars[starIndex]:SetVisible(starIndex <= item._showstar);
							end
						
							itemWind:SetPosition(LORD.UVector2(xpos, ypos));
							itemWind:SetUserData(item._id);
							if item._type == enum.REWARD_TYPE.REWARD_TYPE_MAGIC_EXP then
								itemWind:SetUserData(dataManager.kingMagic:mergeIDLevel(item._id, item._star));
							end
								
							instanceawarditem_item:SetImage(item._backImage);
							
							global.onItemTipsShow(itemWind,item._type, "top");
							global.onItemTipsHide(itemWind);			
								
							global_scalewnd(itemWind,0.9, 0.9);

							item_num:GetPosition();
							local item_numPosition= item_num:GetPosition();
							item_num:SetPosition(LORD.UVector2(item_numPosition.x+LORD.UDim(0, -2),item_numPosition.y+LORD.UDim(0, -1)))
							
							local width = itemWind:GetWidth()  
							xpos = xpos + width + LORD.UDim(0, 25);
							
							if itemIcon then
								itemIcon:SetImage(item._icon)
								global.setMaskIcon(itemIcon, item._maskicon);			
							end
							
							if itemName then
								if(item._num > 1)then
									itemName:SetText(item._num)
								else
									itemName:SetText("")
								end
							end		
							itemStar:SetImage(itemManager.getImageWithStar(item._star, item._isDebris));
							self.tempUi[i].itemsp:AddChildWindow(itemWind)	 
				
							item_num:SetText("")		
							if item_num then
								if(item._num > 1)then
									item_num:SetText(item._num)
								else
									item_num:SetText("")
								end
							end									
																			
					end		
				end					
	 	end		
	end		
	
	
	local temoffset =  self.allOffset[self.selectChapter]
	if(temoffset)then
		self.quick_map_scrollablepane:SetVertScrollOffset( self.quick_map_scrollablepane:GetPixelSize().y - temoffset  )
	end
end	

function quick_map:onHide(event)
	self:Close();
	self.selectChapter = nil
	self.allPreView = nil
	self.allOffset = nil
end

return quick_map;
