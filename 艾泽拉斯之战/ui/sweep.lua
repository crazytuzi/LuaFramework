local sweep = class( "sweep", layout );

global_event.SWEEP_SHOW = "SWEEP_SHOW";
global_event.SWEEP_HIDE = "SWEEP_HIDE";

function sweep:ctor( id )
	sweep.super.ctor( self, id );
	self:addEvent({ name = global_event.SWEEP_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.SWEEP_HIDE, eventHandler = self.onHide});
	self.sweepScrollHandle = nil
end

function sweep:onShow(event)
	self.stage = event.stage
	if self._show then
		--return;
	end

	self:Show();
	if(self.stage:getSweepCount() <=0)then
		return
	end

	self.sweep_button = self:Child( "sweep-button" );
	self.sweep_scroll = LORD.toScrollPane(self:Child( "sweep-scroll" ))
	self.sweep_scroll:init();
	self.sweep_scrollpos = self.sweep_scroll:GetPosition()
	function on_sweep_button_click()	
		self:onHide()
	end		
 	self.sweep_button:subscribeEvent("ButtonClick", "on_sweep_button_click");
	
	--[[
	function sweepTimeTick()
		self.showNum  = self.showNum  or 0 
		local sweepnums  = self.stage:getSweepCount()
		local SweepData = self.stage:getSweepData()	
		local xpos = LORD.UDim(0, 10)
		local ypos = LORD.UDim(0, 10)
	 
		self.showNum  = self.showNum + 1
		if( self.showNum >=  sweepnums and self.sweepScrollHandle ~= nil)then
			self.showNum  = sweepnums
			scheduler.unscheduleGlobal(self.sweepScrollHandle)
			self.sweepScrollHandle = nil
		end		
		self:upData()
	end		
	
	if(self.sweepScrollHandle == nil)then
		self.showNum = nil
		self.sweepScrollHandle = scheduler.scheduleGlobal(sweepTimeTick, dataConfig.configs.ConfigConfig[0].sweepCD)--global.goldMineInterval
	end	
	]]--
	--self:upDataAll()
	--self:NewupDataAll()
	self:NewupDataAll111()
end




function sweep:NewupDataAll111()
	 
		self:BuildSweepResult()
		for k ,v in ipairs (self.allAnimateTitleWnd) do	
			v:SetVisible(false)				
		end
		for k ,v in ipairs (self.allAnimateMoneyWnd) do	
			v:SetVisible(false)				
		end
		for k ,v in  pairs (self.allAnimateItemWnd) do	
			
			for _k ,_v in ipairs (v) do	
				_v:SetVisible(false)				
			end		
		end
		----第一次扫荡的标题出现动画
		function sweep_animateTitleFirst(window,endFuc)
			
				if not self._show then
					return;
				end
						function sweep_animateTitleEndFunc()
								self.sweepIndex =  self.sweepIndex or 1 
								do_itemSweepAnimate()
						end
						if window then
							local action = LORD.GUIAction:new();
							action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(0.1, 0.1, 0.1), 1, 0);
							action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 100);
							window:playAction(action);
							window:removeEvent("UIActionEnd");
							if(endFuc)then
								window:subscribeEvent("UIActionEnd", "sweep_animateTitleEndFunc");
							end
						end		
		end 
		
		----第一次以外的扫荡的标题出现动画
			function sweep_animateTitleOther(window,endFuc)
					
				if not self._show then
					return;
				end
						function sweep_animateTitleEndFuncother()
							--[[
								self.sweepIndex =  self.sweepIndex + 1 
								if(self.allOffset and self.sweepIndex )then
									local temoffset =  self.allOffset[self.sweepIndex]
									if(temoffset)then
										if (temoffset  >= self.sweep_scroll:GetPixelSize().y  )then
											self.sweep_scroll:SetVertScrollOffset( self.sweep_scroll:GetPixelSize().y - temoffset  )
										 end
									end
								end	
								]]--
								do_itemSweepAnimate()
						end
						
						if window then
							local action = LORD.GUIAction:new();
							action:addKeyFrame(LORD.Vector3(0, 200, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 0);
							action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 100);
							window:playAction(action);
							window:removeEvent("UIActionEnd");
							if(endFuc)then
								window:subscribeEvent("UIActionEnd", "sweep_animateTitleEndFuncother");
							end
						end		
		end 
		---物品动画
		function sweep_animateItem(window,endFuc)
			
				if not self._show then
					return;
				end
						function sweep_animateItemEndFunc() 
							do_itemSweepAnimate()
						end
						if window then
							local action = LORD.GUIAction:new();
							action:addKeyFrame(LORD.Vector3(400, -400, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(0.1, 0.1, 0.1), 1, 0);
							action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 300);
							window:playAction(action);
							window:removeEvent("UIActionEnd");
							if(endFuc)then
								window:subscribeEvent("UIActionEnd", "sweep_animateItemEndFunc");
							end
						end		
		end 
		
		--扫荡完成动画
		function sweep_animateEnd(window)
			
				if not self._show then
					return;
				end
						if window then
							self.sweep_scroll:SetVertScrollOffset(-10000)
							local action = LORD.GUIAction:new();
							action:addKeyFrame(LORD.Vector3(0, 400, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(0.1, 0.1, 0.1), 1, 0);
							action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 500);
							window:playAction(action);
							window:removeEvent("UIActionEnd");
							 
						end		
		end 
		function do_firsteSweepAnimate()
			
				if not self._show then
					return;
				end
			
			local wnd = self.allAnimateTitleWnd[1]
			local wnd1= self.allAnimateMoneyWnd[1]
			if(wnd)then
				table.remove(self.allAnimateTitleWnd,1)
				table.remove(self.allAnimateMoneyWnd,1)
				wnd:SetVisible(true)	
				wnd1:SetVisible(true)		
				sweep_animateTitleFirst(wnd,true)
				sweep_animateTitleFirst(wnd1,false)
		 
			end
		end	
		
		function do_otherSweepAnimate()
			
				if not self._show then
					return;
				end
			
			local wnd = self.allAnimateTitleWnd[1]
			local wnd1= self.allAnimateMoneyWnd[1]
			if(wnd)then
				table.remove(self.allAnimateTitleWnd,1)
				table.remove(self.allAnimateMoneyWnd,1)
				wnd:SetVisible(true)	
				wnd1:SetVisible(true)	
				

								self.sweepIndex =  self.sweepIndex + 1 
								if(self.allOffset and self.sweepIndex )then
									local temoffset =  self.allOffset[self.sweepIndex]
									if(temoffset)then
										if (temoffset  >= self.sweep_scroll:GetPixelSize().y  )then
											self.sweep_scroll:SetVertScrollOffset( self.sweep_scroll:GetPixelSize().y - temoffset  )
										 end
									end
								end									
				
				sweep_animateTitleOther(wnd,true)
				sweep_animateTitleOther(wnd1,false)
				
				
				
			else
				self.doned:SetVisible(true)	
				sweep_animateEnd(self.doned)
					
			end
		end	
		
		function do_itemSweepAnimate()
			
				if not self._show then
					return;
				end
			local wnds = self.allAnimateItemWnd[self.sweepIndex]
			if(wnds and #wnds >0 )then
				local wnd = wnds[1]
				table.remove(self.allAnimateItemWnd[self.sweepIndex],1)
				wnd:SetVisible(true)	
				sweep_animateItem(wnd,true)
			else
				scheduler.performWithDelayGlobal(do_otherSweepAnimate, 0.2)
			 
			end 
			
		end	
		self.sweep_scroll:SetVertScrollOffset(0) 	
		do_firsteSweepAnimate()
	
end

 

function sweep:BuildSweepResult()
		self.sweep_scroll:ClearAllItem()
		self.allAnimateTitleWnd = {}
		self.allAnimateMoneyWnd = {}
		self.allAnimateItemWnd = {}
		self.tmp = {}
		local sweepnums  = self.stage:getSweepCount()
		local SweepData = self.stage:getSweepData()	
		local xpos = LORD.UDim(0, 10)
		local ypos = LORD.UDim(0, 10)

		self.allOffset = {}
		
		for i = 1,sweepnums do	
			self.tmp[i] = self.tmp[i] or {}
	 	
				self.tmp[i].root = LORD.toLayout (LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("sweep"..i, "sweepitem.dlg"))				
				self.tmp[i].sweepitem_money1 = LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("sweep"..i.."_sweepitem-money1"));	
				self.tmp[i].sweepitem_money1_num = (LORD.GUIWindowManager:Instance():GetGUIWindow("sweep"..i.."_sweepitem-money1-num"));	
				self.tmp[i].sweepitem_money2 = LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("sweep"..i.."_sweepitem-money2"));	
				self.tmp[i].sweepitem_money2_num = (LORD.GUIWindowManager:Instance():GetGUIWindow("sweep"..i.."_sweepitem-money2-num"));	
				self.tmp[i].sweepitem_money3 = LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("sweep"..i.."_sweepitem-money3"));	
				self.tmp[i].sweepitem_money3_num = (LORD.GUIWindowManager:Instance():GetGUIWindow("sweep"..i.."_sweepitem-money3-num"));	
		
				self.tmp[i].sweepitem_text = LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("sweep"..i.."_sweepitem-text"));	
				self.tmp[i].sweepitem_item =  (LORD.GUIWindowManager:Instance():GetGUIWindow("sweep"..i.."_sweepitem-item"));		
				self.tmp[i].sweepitem_money = (LORD.GUIWindowManager:Instance():GetGUIWindow("sweep"..i.."_sweepitem-money"));	
				self.tmp[i].sweepitem_title = (LORD.GUIWindowManager:Instance():GetGUIWindow("sweep"..i.."_sweepitem-title"));	
				
				self.allAnimateMoneyWnd[i] = self.tmp[i].sweepitem_money 
				self.allAnimateTitleWnd[i] =  self.tmp[i].sweepitem_title 
					
		 		self.tmp[i].sweepitem_text:SetText("第"..i.."轮")						
				local gold = self.stage:getSweepRewardMoney(enum.MONEY_TYPE.MONEY_TYPE_GOLD,i)										
				self.tmp[i].sweepitem_money1_num:SetText(gold)
				self.tmp[i].sweepitem_money1:SetVisible(gold > 0)
				self.tmp[i].sweepitem_money1_num:SetVisible(gold > 0)
				local wood = self.stage:getSweepRewardMoney(enum.MONEY_TYPE.MONEY_TYPE_LUMBER,i)	
							
				
				self.tmp[i].sweepitem_money2_num:SetText(wood)
				self.tmp[i].sweepitem_money2:SetVisible(wood > 0)
				self.tmp[i].sweepitem_money2_num:SetVisible(wood > 0)
				 
				local exp = self.stage:getExp()
				self.tmp[i].sweepitem_money3_num:SetText(exp)
				self.tmp[i].sweepitem_money3:SetVisible(exp > 0)
				self.tmp[i].sweepitem_money3_num:SetVisible(exp > 0)
				
				self.tmp[i].sweepitem_item:CleanupChildren()
				local itemrootHeight = self.tmp[i].sweepitem_item:GetHeight()
				
				local noMoneyReward = self.stage:getStageSweepNormalMergerRandomReward(i)
				local  _itemnum = #noMoneyReward				
				local _xpos = LORD.UDim(0, 10)
				local _ypos = LORD.UDim(0, 10)
				local itemIndex = 0
				local itemNum = 0
				self.allAnimateItemWnd[i] = { }
				for k = 1,_itemnum do	
					local item = noMoneyReward[k]					
					if (item  and  item._type ~= enum.REWARD_TYPE.REWARD_TYPE_MONEY )then	
						itemNum = itemNum +1	
						local itemWind = LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("sweepreward_item"..i.."-"..k, "item.dlg");
						local itemStar  = LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("sweepreward_item"..i.."-"..k.."_item_item"));						
						local itemIcon = LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("sweepreward_item"..i.."-"..k.."_item-image"));	
						local itemName= LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("sweepreward_item"..i.."-"..k.."_item-num"));				
						local item_chose = LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("sweepreward_item"..i.."-"..k.."_item-chose"));	
						local item_stLevel = LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("sweepreward_item"..i.."-"..k.."_item-stLevel"));	
					
						 				
						itemIcon.item_chose = item_chose
						itemIcon.item_chose:SetVisible(false)			
						item_stLevel:SetVisible(false)	
						itemWind:SetPosition(LORD.UVector2(_xpos, _ypos));
					 
						itemWind:SetProperty("ImageName",itemManager.getBackImage(item._isDebris))
						item_chose:SetProperty("ImageName",itemManager.getSelectImage(item._isDebris) )							
						
						self.tmp[i].sweepitem_item:AddChildWindow(itemWind);			
						local width = itemWind:GetWidth()
						_xpos = _xpos + width								
						itemIndex = itemIndex + 1
						if(itemIndex %5 == 0)then
							itemIndex = 0
							_xpos = LORD.UDim(0, 10)
							_ypos = _ypos +  itemWind:GetHeight() + LORD.UDim(0, 5)
						end	
					 
						if itemIcon then
							itemIcon:SetImage(item._icon)
							global.setMaskIcon(itemIcon, item._maskicon);	
							itemIcon:SetUserData(item._id);
							if item._type == enum.REWARD_TYPE.REWARD_TYPE_MAGIC_EXP then
								itemIcon:SetUserData(dataManager.kingMagic:mergeIDLevel(item._id, item._star));
							end
							global.onItemTipsShow(itemIcon,item._type,"top")
							global.onItemTipsHide(itemIcon)
									
						end				
						if itemName  then
							if(item._num <=1 )then
								item._num  = ""
							end
							itemName:SetText(item._num)
						end		
			
						itemStar:SetImage(itemManager.getImageWithStar(item._star,item._isDebris))		
						table.insert(self.allAnimateItemWnd[i],itemWind)

					end		
				end			
				if(itemNum == 0)then
					itemrootHeight  = LORD.UDim(0, 0)
				end
			 
								
				self.tmp[i].sweepitem_item:SetHeight(_ypos + itemrootHeight )			 
				self.tmp[i].root:LayoutChild()
				self.tmp[i].root:SetPosition(LORD.UVector2(xpos, ypos));
				self.sweep_scroll:additem( self.tmp[i].root);		
				ypos = ypos +  self.tmp[i].root:GetHeight() --+ LORD.UDim(0, 5)
				table.insert(self.allOffset,ypos.offset)
		end	
		
		
		self.doned = LORD.toLayout (LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("sweep", "sweepDoned.dlg"))				
		self.doned:SetPosition(LORD.UVector2(xpos, ypos));
		self.sweep_scroll:additem( self.doned);	
		self.doned:SetVisible(false)	
		ypos =  ypos +  self.doned:GetHeight()   --+ LORD.UDim(0, 15)
		table.insert(self.allOffset,ypos.offset)
end	

















function sweep:buildAlllSweepItems()
	local sweepnums  = self.stage:getSweepCount()
	local SweepData = self.stage:getSweepData()
	
	self.allAnimateWnd = {}
	self.allOffset = {}
	self.tmp = {}
	local xpos = LORD.UDim(0, 10)
	local ypos = LORD.UDim(0, 0)
	local scrypos = LORD.UDim(0, 0)
	self.allOffset[0] = 0 
	for i = 1,sweepnums do	
				self.allAnimateWnd[i] = {}
				self.tmp[i] = self.tmp[i] or {}
				self.tmp[i].root = LORD.toLayout (LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("sweep"..i, "sweepitem.dlg"))				
				self.tmp[i].sweepitem_money = LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("sweep"..i.."_sweepitem-money"));	

				self.tmp[i].sweepitem_money1 = LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("sweep"..i.."_sweepitem-money1"));	
				self.tmp[i].sweepitem_money1_num = (LORD.GUIWindowManager:Instance():GetGUIWindow("sweep"..i.."_sweepitem-money1-num"));	
				self.tmp[i].sweepitem_money2 = LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("sweep"..i.."_sweepitem-money2"));	
				self.tmp[i].sweepitem_money2_num = (LORD.GUIWindowManager:Instance():GetGUIWindow("sweep"..i.."_sweepitem-money2-num"));	
				self.tmp[i].sweepitem_money3 = LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("sweep"..i.."_sweepitem-money3"));	
				self.tmp[i].sweepitem_money3_num = (LORD.GUIWindowManager:Instance():GetGUIWindow("sweep"..i.."_sweepitem-money3-num"));	
				
				self.tmp[i].sweepitem_text = LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("sweep"..i.."_sweepitem-text"));	
				self.tmp[i].sweepitem_item =  (LORD.GUIWindowManager:Instance():GetGUIWindow("sweep"..i.."_sweepitem-item"));				
		 		self.tmp[i].sweepitem_text:SetText("第"..i.."轮")						
				local gold = self.stage:getSweepRewardMoney(enum.MONEY_TYPE.MONEY_TYPE_GOLD,i)										
				self.tmp[i].sweepitem_money1_num:SetText(gold)
				self.tmp[i].sweepitem_money1:SetVisible(gold > 0)
				self.tmp[i].sweepitem_money1_num:SetVisible(gold > 0)
				local wood = self.stage:getSweepRewardMoney(enum.MONEY_TYPE.MONEY_TYPE_LUMBER,i)	
				
				table.insert(self.allAnimateWnd[i],{self.tmp[i].sweepitem_text })
				 
				if(gold > 0)then
					table.insert(self.allAnimateWnd[i],{self.tmp[i].sweepitem_money1, self.tmp[i].sweepitem_money1_num})
				end
		
				self.tmp[i].sweepitem_money2_num:SetText(wood)
				self.tmp[i].sweepitem_money2:SetVisible(wood > 0)
				self.tmp[i].sweepitem_money2_num:SetVisible(wood > 0)
				
				if(wood > 0)then
					table.insert(self.allAnimateWnd[i],{self.tmp[i].sweepitem_money2, self.tmp[i].sweepitem_money2_num})
				end
				
	
				local exp = self.stage:getExp()
				self.tmp[i].sweepitem_money3_num:SetText(exp)
				self.tmp[i].sweepitem_money3:SetVisible(exp > 0)
				self.tmp[i].sweepitem_money3_num:SetVisible(exp > 0)
				
				if(exp > 0)then
					table.insert(self.allAnimateWnd[i],{self.tmp[i].sweepitem_money3, self.tmp[i].sweepitem_money3_num})
				end
				
				self.tmp[i].sweepitem_item:CleanupChildren()
				local itemrootHeight = self.tmp[i].sweepitem_item:GetHeight()
				
				local noMoneyReward = self.stage:getStageSweepNormalMergerRandomReward(i)
				local  _itemnum = #noMoneyReward				
				local _xpos = LORD.UDim(0, 10)
				local _ypos = LORD.UDim(0, 10)
				local itemIndex = 0
				local itemNum = 0
				for k = 1,_itemnum do	
					local item = noMoneyReward[k]					
					if (item  and  item._type ~= enum.REWARD_TYPE.REWARD_TYPE_MONEY )then	
						itemNum = itemNum +1	
						local itemWind = LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("sweepreward_item"..i.."-"..k, "item.dlg");
						local itemStar  = LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("sweepreward_item"..i.."-"..k.."_item_item"));						
						local itemIcon = LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("sweepreward_item"..i.."-"..k.."_item-image"));	
						local itemName= LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("sweepreward_item"..i.."-"..k.."_item-num"));				
						local item_chose = LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("sweepreward_item"..i.."-"..k.."_item-chose"));							
						itemIcon.item_chose = item_chose
						itemIcon.item_chose:SetVisible(false)			
						
						itemWind:SetPosition(LORD.UVector2(_xpos, _ypos));
					 
						itemWind:SetProperty("ImageName",itemManager.getBackImage(item._isDebris))
						item_chose:SetProperty("ImageName",itemManager.getSelectImage(item._isDebris) )							
						
						self.tmp[i].sweepitem_item:AddChildWindow(itemWind);			
						local width = itemWind:GetWidth()
						_xpos = _xpos + width								
						itemIndex = itemIndex + 1
						if(itemIndex %5 == 0)then
							itemIndex = 0
							_xpos = LORD.UDim(0, 10)
							_ypos = _ypos +  itemWind:GetHeight() + LORD.UDim(0, 5)
						end	
					 
						if itemIcon then
							itemIcon:SetImage(item._icon)
							global.setMaskIcon(itemIcon, item._maskicon);	
						 
							itemIcon:SetUserData(item._id);
					
							if item._type == enum.REWARD_TYPE.REWARD_TYPE_MAGIC_EXP then
								itemIcon:SetUserData(dataManager.kingMagic:mergeIDLevel(item._id, item._star));
							end
	
							global.onItemTipsShow(itemIcon,item._type,"top")
							global.onItemTipsHide(itemIcon)
									
						end				
						if itemName  then
							if(item._num <=1 )then
								item._num  = ""
							end
							itemName:SetText(item._num)
						end		
						if( item._type == enum.REWARD_TYPE.REWARD_TYPE_ITEM)then
						
							itemStar:SetImage(itemManager.getImageWithStar(item._star,item._isDebris))		
						end	
						
						table.insert(self.allAnimateWnd[i],{itemWind})
				 
					end		
				end			
				if(itemNum == 0)then
					itemrootHeight  = LORD.UDim(0, 20)
				end
								
				self.tmp[i].sweepitem_item:SetHeight(_ypos + itemrootHeight )			 
				self.tmp[i].root:LayoutChild()
				self.tmp[i].root:SetPosition(LORD.UVector2(xpos, ypos));
				self.sweep_scroll:additem( self.tmp[i].root);	
				ypos = ypos +  self.tmp[i].root:GetHeight() ---  + LORD.UDim(0, 5)
				
				scrypos = self.tmp[i].root:GetPosition().y ---  + LORD.UDim(0, 5)
				--table.insert(self.allOffset,ypos.offset)
				self.allOffset[i] = scrypos.offset + self.tmp[i].root:GetHeight().offset
		end	
		local doned = LORD.toLayout (LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("sweep", "sweepDoned.dlg"))				
		doned:SetPosition(LORD.UVector2(xpos, ypos));
		self.sweep_scroll:additem( doned);	
		local doned_txt  = LORD.GUIWindowManager:Instance():GetGUIWindow("sweep".."-".."_sweepDoned_txt");	
		
		
		
		local size = #self.allAnimateWnd + 1
		self.allAnimateWnd[size] = {}
		table.insert(self.allAnimateWnd[size],{doned_txt})
		scrypos = doned:GetPosition().y
		local s = #self.allOffset
		self.allOffset[s + 1]  = scrypos.offset  + doned:GetHeight().offset
		local size = #self.tmp + 1
		self.tmp[size] = {} 
		self.tmp[size].root = doned
end



function sweep:NewupDataAll()
		if(self.sweepScrollHandle ~= nil)then
			scheduler.unscheduleGlobal(self.sweepScrollHandle)
			self.sweepScrollHandle = nil
		end
		self.sweep_scroll:ClearAllItem()
		self:buildAlllSweepItems()
		self.sweep_scroll:SetVertScrollOffset(0)
		
		
		self.allOffsetPos =    - self.allOffset[#self.allOffset]
		self.nowOffsetPos =   self.sweep_scroll:GetVertScrollOffset()
		
		for _i ,_v in ipairs (self.allAnimateWnd) do	
			
			for i ,v in ipairs (_v) do
				for k,z in ipairs (v) do
				 z:SetVisible(false)				
				end 
			end	
			
		end
		
 
		for i ,v in ipairs (self.tmp) do
		    v.root:SetVisible(false)			
		end	
		
		
		function sweep_fly_wnd(window)
				
						function sweep_fly_wndEndFunc()
						 
						end
						if window then
							 
							local action = LORD.GUIAction:new();
							action:addKeyFrame(LORD.Vector3(150, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1.0, 1.0, 1.0), 1, 0);
							action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 0.5, 200);
							action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 10, 0), LORD.Vector3(2, 2, 2), 1, 400);
							action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 600);
							window:playAction(action);
							
							window:removeEvent("UIActionEnd");
							window:subscribeEvent("UIActionEnd", "sweep_fly_wndEndFunc");
						end		
		end
		
			function sweep_fly_wnd2(window)
				
						function sweep_fly_wndEndFunc2()
							
						end
						if window then
							
							local action = LORD.GUIAction:new();
							action:addKeyFrame(LORD.Vector3(0, 100, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 0);
							action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 200);
							action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1.5, 1.5, 1.5), 1, 400);
							action:addKeyFrame(LORD.Vector3(0, 0, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 600);
							window:playAction(action);
							
							window:removeEvent("UIActionEnd");
							window:subscribeEvent("UIActionEnd", "sweep_fly_wndEndFunc2");
						end		
		end
		
		local spaceTime = 0.5
		local curspaceTime = 0.5
		function sweepAllTimeTick(dt)
			self.Animateindex = 	self.Animateindex or 1
			if(self.Animateindex > #self.tmp)then
					if(self.sweepScrollHandle ~= nil)then
						scheduler.unscheduleGlobal(self.sweepScrollHandle)
						self.sweepScrollHandle = nil
						return
					end
				
			end
			
			self.tmp[self.Animateindex ].root:SetVisible(true)	
			
			local onesweepRewars = self.allAnimateWnd[self.Animateindex]
			
			self.detaTime = self.detaTime or  spaceTime
			self.detaTime = self.detaTime + dt
			self.Animateindex_inner = self.Animateindex_inner or 1
			 
			if( onesweepRewars[self.Animateindex_inner ] == nil )then
		 
				self.Animateindex = 	self.Animateindex + 1
				self.Animateindex_inner  = 1
				self.detaTime = 0
				curspaceTime = spaceTime
		 
				return 
			end
			
			curspaceTime =  curspaceTime or  (self.Animateindex_inner - 1) * spaceTime
			
			
			if(self.detaTime >= curspaceTime)then
				for i, v in ipairs(onesweepRewars[self.Animateindex_inner ] )do
					v:SetVisible(true)
					
					if(self.Animateindex <= 2000)then
						sweep_fly_wnd(v)
					--else
						---sweep_fly_wnd2(v)
					end
			
				end
				curspaceTime = nil
				self.Animateindex_inner = self.Animateindex_inner + 1
			end
			
			local temoffset =     - self.allOffset[self.Animateindex-1]
			self.sweep_scroll:SetVertScrollOffset(temoffset)
			
		end	
		
		if(self.sweepScrollHandle == nil)then
			self.sweepScrollHandle = scheduler.scheduleGlobal(sweepAllTimeTick, 0)
		end	

	 
 
end




function sweep:upDataAll()
		self.sweep_scroll:ClearAllItem()
		self.tmp = {}
		local sweepnums  = self.stage:getSweepCount()
		local SweepData = self.stage:getSweepData()	
		local xpos = LORD.UDim(0, 10)
		local ypos = LORD.UDim(0, 10)
		for i = 1,sweepnums do	
			self.tmp[i] = self.tmp[i] or {}
	 	
				self.tmp[i].root = LORD.toLayout (LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("sweep"..i, "sweepitem.dlg"))				
				self.tmp[i].sweepitem_money1 = LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("sweep"..i.."_sweepitem-money1"));	
				self.tmp[i].sweepitem_money1_num = (LORD.GUIWindowManager:Instance():GetGUIWindow("sweep"..i.."_sweepitem-money1-num"));	
				self.tmp[i].sweepitem_money2 = LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("sweep"..i.."_sweepitem-money2"));	
				self.tmp[i].sweepitem_money2_num = (LORD.GUIWindowManager:Instance():GetGUIWindow("sweep"..i.."_sweepitem-money2-num"));	
				self.tmp[i].sweepitem_money3 = LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("sweep"..i.."_sweepitem-money3"));	
				self.tmp[i].sweepitem_money3_num = (LORD.GUIWindowManager:Instance():GetGUIWindow("sweep"..i.."_sweepitem-money3-num"));	
				
				self.tmp[i].sweepitem_text = LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("sweep"..i.."_sweepitem-text"));	
				self.tmp[i].sweepitem_item =  (LORD.GUIWindowManager:Instance():GetGUIWindow("sweep"..i.."_sweepitem-item"));				
		 		self.tmp[i].sweepitem_text:SetText("第"..i.."轮")						
				local gold = self.stage:getSweepRewardMoney(enum.MONEY_TYPE.MONEY_TYPE_GOLD,i)										
				self.tmp[i].sweepitem_money1_num:SetText(gold)
				self.tmp[i].sweepitem_money1:SetVisible(gold > 0)
				self.tmp[i].sweepitem_money1_num:SetVisible(gold > 0)
				local wood = self.stage:getSweepRewardMoney(enum.MONEY_TYPE.MONEY_TYPE_LUMBER,i)				
				
				self.tmp[i].sweepitem_money2_num:SetText(wood)
				self.tmp[i].sweepitem_money2:SetVisible(wood > 0)
				self.tmp[i].sweepitem_money2_num:SetVisible(wood > 0)
				 
				local exp = self.stage:getExp()
				self.tmp[i].sweepitem_money3_num:SetText(exp)
				self.tmp[i].sweepitem_money3:SetVisible(exp > 0)
				self.tmp[i].sweepitem_money3_num:SetVisible(exp > 0)
				
				self.tmp[i].sweepitem_item:CleanupChildren()
				local itemrootHeight = self.tmp[i].sweepitem_item:GetHeight()
				
				local noMoneyReward = self.stage:getStageSweepNormalMergerRandomReward(i)
				local  _itemnum = #noMoneyReward				
				local _xpos = LORD.UDim(0, 10)
				local _ypos = LORD.UDim(0, 10)
				local itemIndex = 0
				local itemNum = 0
				for k = 1,_itemnum do	
					local item = noMoneyReward[k]					
					if (item  and  item._type ~= enum.REWARD_TYPE.REWARD_TYPE_MONEY )then	
						itemNum = itemNum +1	
						local itemWind = LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("sweepreward_item"..i.."-"..k, "item.dlg");
						local itemStar  = LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("sweepreward_item"..i.."-"..k.."_item_item"));						
						local itemIcon = LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("sweepreward_item"..i.."-"..k.."_item-image"));	
						local itemName= LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("sweepreward_item"..i.."-"..k.."_item-num"));				
						local item_chose = LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("sweepreward_item"..i.."-"..k.."_item-chose"));							
						itemIcon.item_chose = item_chose
						itemIcon.item_chose:SetVisible(false)			
						
						itemWind:SetPosition(LORD.UVector2(_xpos, _ypos));
					 
						itemWind:SetProperty("ImageName",itemManager.getBackImage(item._isDebris))
						item_chose:SetProperty("ImageName",itemManager.getSelectImage(item._isDebris) )							
						
						self.tmp[i].sweepitem_item:AddChildWindow(itemWind);			
						local width = itemWind:GetWidth()
						_xpos = _xpos + width								
						itemIndex = itemIndex + 1
						if(itemIndex %5 == 0)then
							itemIndex = 0
							_xpos = LORD.UDim(0, 10)
							_ypos = _ypos +  itemWind:GetHeight() + LORD.UDim(0, 5)
						end	
					 
						if itemIcon then
							itemIcon:SetImage(item._icon)
							global.setMaskIcon(itemIcon, item._maskicon);	
						 
							
							itemIcon:SetUserData(item._id);
					
							if item._type == enum.REWARD_TYPE.REWARD_TYPE_MAGIC_EXP then
								itemIcon:SetUserData(dataManager.kingMagic:mergeIDLevel(item._id, item._star));
							end
	
							global.onItemTipsShow(itemIcon,item._type,"top")
							global.onItemTipsHide(itemIcon)
									
						end				
						if itemName  then
							if(item._num <=1 )then
								item._num  = ""
							end
							itemName:SetText(item._num)
						end		
						if( item._type == enum.REWARD_TYPE.REWARD_TYPE_ITEM)then
						
							itemStar:SetImage(itemManager.getImageWithStar(item._star,item._isDebris))		
						end	
   				
					end		
				end			
				if(itemNum == 0)then
					itemrootHeight  = LORD.UDim(0, 0)
				end
								
				self.tmp[i].sweepitem_item:SetHeight(_ypos + itemrootHeight )			 
				self.tmp[i].root:LayoutChild()
 
				self.tmp[i].root:SetPosition(LORD.UVector2(xpos, ypos));
				self.sweep_scroll:additem( self.tmp[i].root);		
				ypos = ypos +  self.tmp[i].root:GetHeight() + LORD.UDim(0, 5)
		end	
		
		self.allOffset =  -ypos.offset
		self.nowOffset =   self.sweep_scroll:GetVertScrollOffset()
			--local sposy = self.sweep_scrollpos.y  -  (  preHeight )
	
	    --self.sweep_scroll:SetPosition(LORD.UVector2(self.sweep_scrollpos.x, sposy))	
		function sweepAllTimeTick(dt)
		 
			self.detaTime = self.detaTime or 0
			self.detaTime = self.detaTime + dt
			local temoffset = (-self.nowOffset + self.allOffset)/dataConfig.configs.ConfigConfig[0].sweepCD * self.detaTime *0.1
			
			if( temoffset <= self.allOffset  )then
				temoffset = self.allOffset
				self.detaTime = 0
				scheduler.unscheduleGlobal(self.sweepScrollHandle)
				self.sweepScrollHandle = nil
			end
			self.sweep_scroll:SetVertScrollOffset(temoffset)
			
			-- 滚动的时候关闭tips
			eventManager.dispatchEvent({name = global_event.ITEMTIPS_HIDE});
				
		end	
		 
		if(self.sweepScrollHandle == nil)then
			self.sweepScrollHandle = scheduler.scheduleGlobal(sweepAllTimeTick, 0)
		end	
 
end

function sweep:upData()
	
		self.sweep_scroll:ClearAllItem()
		self.tmp = {}
		local sweepnums  = self.stage:getSweepCount()
		local SweepData = self.stage:getSweepData()	
		local xpos = LORD.UDim(0, 10)
		local ypos = LORD.UDim(0, 10)
  
		sweepnums = self.showNum or 1
		--local preHeight = LORD.UDim(0, 0)
		for i = 1,sweepnums do	
			self.tmp[i] = self.tmp[i] or {}
	 	
				self.tmp[i].root = LORD.toLayout (LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("sweep"..i, "sweepitem.dlg"))				
				self.tmp[i].sweepitem_money1 = LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("sweep"..i.."_sweepitem-money1"));	
				self.tmp[i].sweepitem_money1_num = (LORD.GUIWindowManager:Instance():GetGUIWindow("sweep"..i.."_sweepitem-money1-num"));	
				self.tmp[i].sweepitem_money2 = LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("sweep"..i.."_sweepitem-money2"));	
				self.tmp[i].sweepitem_money2_num = (LORD.GUIWindowManager:Instance():GetGUIWindow("sweep"..i.."_sweepitem-money2-num"));	
				self.tmp[i].sweepitem_money3 = LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("sweep"..i.."_sweepitem-money3"));	
				self.tmp[i].sweepitem_money3_num = (LORD.GUIWindowManager:Instance():GetGUIWindow("sweep"..i.."_sweepitem-money3-num"));	
				
				self.tmp[i].sweepitem_text = LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("sweep"..i.."_sweepitem-text"));	
				self.tmp[i].sweepitem_item =  (LORD.GUIWindowManager:Instance():GetGUIWindow("sweep"..i.."_sweepitem-item"));				
		 		self.tmp[i].sweepitem_text:SetText("第"..i.."轮")						
				local gold = self.stage:getSweepRewardMoney(enum.MONEY_TYPE.MONEY_TYPE_GOLD,i)										
				self.tmp[i].sweepitem_money1_num:SetText(gold)
				self.tmp[i].sweepitem_money1:SetVisible(gold > 0)
				self.tmp[i].sweepitem_money1_num:SetVisible(gold > 0)
				local wood = self.stage:getSweepRewardMoney(enum.MONEY_TYPE.MONEY_TYPE_LUMBER,i)				
				
				self.tmp[i].sweepitem_money2_num:SetText(wood)
				self.tmp[i].sweepitem_money2:SetVisible(wood > 0)
				self.tmp[i].sweepitem_money2_num:SetVisible(wood > 0)
				 
				local exp = self.stage:getExp()
				self.tmp[i].sweepitem_money3_num:SetText(exp)
				self.tmp[i].sweepitem_money3:SetVisible(exp > 0)
				self.tmp[i].sweepitem_money3_num:SetVisible(exp > 0)
				
				self.tmp[i].sweepitem_item:CleanupChildren()
				local itemrootHeight = self.tmp[i].sweepitem_item:GetHeight()
				
				local noMoneyReward = self.stage:getStageSweepNormalMergerRandomReward(i)
				local  _itemnum = #noMoneyReward				
				local _xpos = LORD.UDim(0, 10)
				local _ypos = LORD.UDim(0, 10)
				local itemIndex = 0
				local itemNum = 0
				for k = 1,_itemnum do	
					local item = noMoneyReward[k]					
					if (item  and  item._type ~= enum.REWARD_TYPE.REWARD_TYPE_MONEY )then	
						itemNum = itemNum +1	
						local itemWind = LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("sweepreward_item"..i.."-"..k, "item.dlg");
						local itemStar  = LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("sweepreward_item"..i.."-"..k.."_item"));						
						local itemIcon = LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("sweepreward_item"..i.."-"..k.."_item-image"));	
						local itemName= LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("sweepreward_item"..i.."-"..k.."_item-num"));				
						local item_chose = LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("sweepreward_item"..i.."-"..k.."_item-chose"));							
						itemIcon.item_chose = item_chose
						itemIcon.item_chose:SetVisible(false)			
						itemWind:SetPosition(LORD.UVector2(_xpos, _ypos));
						self.tmp[i].sweepitem_item:AddChildWindow(itemWind);			
						local width = itemWind:GetWidth()
						_xpos = _xpos + width								
						itemIndex = itemIndex + 1
						if(itemIndex %5 == 0)then
							itemIndex = 0
							_xpos = LORD.UDim(0, 10)
							_ypos = _ypos +  itemWind:GetHeight() + LORD.UDim(0, 5)
						end	
					 
						if itemIcon then
							itemIcon:SetImage(item._icon)
							global.setMaskIcon(itemIcon, item._maskicon);			
						end				
						if itemName then
							itemName:SetText(item._num)
						end		
						if( item._type == enum.REWARD_TYPE.REWARD_TYPE_ITEM)then
							itemStar:SetImage(itemManager.getImageWithStar(item._isDebris))		
						end	
   				
					end		
				end			
				if(itemNum == 0)then
					itemrootHeight  = LORD.UDim(0, 0)
				end
								
				self.tmp[i].sweepitem_item:SetHeight(_ypos + itemrootHeight )			 
				self.tmp[i].root:LayoutChild()
 
				self.tmp[i].root:SetPosition(LORD.UVector2(xpos, ypos));
				self.sweep_scroll:additem( self.tmp[i].root);	
				--preHeight = self.tmp[i].root:GetHeight()		
				ypos = ypos +  self.tmp[i].root:GetHeight() + LORD.UDim(0, 5)
 		
		end	
		self.sweep_scroll:SetVertScrollOffset(-ypos.offset)	
		--local sposy = self.sweep_scrollpos.y  -  (  preHeight )
	
	    --self.sweep_scroll:SetPosition(LORD.UVector2(self.sweep_scrollpos.x, sposy))	
 
		
end
	
function sweep:onHide(event)
	
	dataManager.playerData:checkLevelup();
	
	if(self.sweepScrollHandle ~= nil)then
		scheduler.unscheduleGlobal(self.sweepScrollHandle)
		self.sweepScrollHandle = nil
	end
	
	self.Animateindex = nil
	self.Animateindex_inner = nil
	self.detaTime = nil
	self.sweepIndex  = nil
	self:Close();
end

return sweep;
