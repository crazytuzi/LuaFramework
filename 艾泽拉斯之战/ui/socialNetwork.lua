local socialNetwork = class( "socialNetwork", layout );

global_event.SOCIALNETWORK_SHOW = "SOCIALNETWORK_SHOW";
global_event.SOCIALNETWORK_HIDE = "SOCIALNETWORK_HIDE";

global_event.SOCIALNETWORK_UPDATE_APPLYLIST = "SOCIALNETWORK_UPDATE_APPLYLIST";

global_event.SOCIALNETWORK_UPDATE_MSG = "SOCIALNETWORK_UPDATE_MSG";

global_event.SOCIALNETWORK_UPDATE_SEARCHRESULT = "SOCIALNETWORK_UPDATE_SEARCHRESULT";

global_event.SOCIALNETWORK_UPDATE = "SOCIALNETWORK_UPDATE";
--global_event.SOCIALNETWORK_SHOWMSG = "SOCIALNETWORK_SHOWMSG";


function socialNetwork:ctor( id )
	socialNetwork.super.ctor( self, id );
	self:addEvent({ name = global_event.SOCIALNETWORK_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.SOCIALNETWORK_HIDE, eventHandler = self.onHide});
 
	self:addEvent({ name = global_event.SOCIALNETWORK_UPDATE, eventHandler = self.Update});
 
	self:addEvent({ name = global_event.SOCIALNETWORK_UPDATE_APPLYLIST, eventHandler = self.onUpdateApplyList});
	self:addEvent({ name = global_event.SOCIALNETWORK_UPDATE_MSG, eventHandler = self.onUpdateMsg});
	self:addEvent({ name = global_event.SOCIALNETWORK_UPDATE_SEARCHRESULT, eventHandler = self.onUpdateSearchResult});
	self.page = 0 -- 0, 1 ,2
	self.searchOrReco = false  -- false 代表推荐
	
--	self:addEvent({ name = global_event.SOCIALNETWORK_SHOWMSG, eventHandler = self.onBeginChatMsg});
	self:addEvent({ name = global_event.CHATROOM_PRIVET_CHAT, eventHandler = self.onBeginpRrivetChat});
end



function socialNetwork:onBeginpRrivetChat(event)
	self:onHide()
end
function socialNetwork:onShow(event)
	if self._show then
		return;
	end
	--dataManager.buddyData:viewApplyList()	
	self:Show();

	self.socialNetwork_message = LORD.toRadioButton(self:Child( "socialNetwork-message" ));
	self.socialNetwork_new1 = LORD.toStaticImage(self:Child( "socialNetwork-new1" ));
	self.socialNetwork_add = LORD.toRadioButton(self:Child( "socialNetwork-add" ));
	self.socialNetwork_request = LORD.toRadioButton (self:Child( "socialNetwork-request" ));
	self.socialNetwork_new3 = LORD.toStaticImage(self:Child( "socialNetwork-new3" ));
	self.socialNetwork_pane = LORD.toScrollPane(self:Child( "socialNetwork-pane" ));
	self.socialNetwork_close = self:Child( "socialNetwork-close" );
	self.socialNetwork_find = self:Child( "socialNetwork-find" );
	self.socialNetwork_find_text = (self:Child( "socialNetwork-find-text" ));
	self.socialNetwork_find_edit = self:Child( "socialNetwork-find-edit" );
	
	self.socialNetwork_find_reflash = (self:Child( "socialNetwork-find-reflash" ));
	self.socialNetwork_del = (self:Child( "socialNetwork-del" ));
	self.socialNetwork_searching = (self:Child( "socialNetwork-searching" ));
	self.socialNetwork_searching:SetVisible(false)
	
	--self.socialNetwork_check = self:Child( "socialNetwork-check" );
	--self.socialNetwork_check_button = self:Child( "socialNetwork-check-button" );
	
	
	self.socialNetwork_add_button = self:Child( "socialNetwork-add-button" );
	self.socialNetwork_letter = LORD.toScrollPane(self:Child( "socialNetwork-letter" ));
	self.socialNetwork_letter_pane = LORD.toScrollPane(self:Child( "socialNetwork-letter-pane" ));
	self.socialNetwork_letter_send = (self:Child( "socialNetwork-letter-send" ));
	self.socialNetwork_letter_edit = self:Child( "socialNetwork-letter-edit" );
	self.socialNetwork_letter_title = self:Child( "socialNetwork-letter-title" );
	self.socialNetwork_letter_head = LORD.toStaticImage(self:Child( "socialNetwork-letter-head" ));
	self.socialNetwork_letter_close = self:Child( "socialNetwork-letter-close" );
	
	self.socialNetwork_friendnum = self:Child( "socialNetwork-friendnum" );
	
 
	self.socialNetwork_vigortext_dw = self:Child( "socialNetwork-vigortext-dw" );
	self.socialNetwork_vigortext_canreceive_num = self:Child( "socialNetwork-vigortext-canreceive-num" );
	self.socialNetwork_vigortext_cansend_num = self:Child( "socialNetwork-vigortext-cansend-num" );
	
	
	
 	self.socialNetwork_vigortext_dw:SetVisible(false) 
	self.socialNetwork_find:SetVisible(false)
	--self.socialNetwork_check:SetVisible(false) 
	self.socialNetwork_letter:SetVisible(false) 
	self.socialNetwork_new1:SetVisible(false)
	self.socialNetwork_new3:SetVisible(false)

	
	function onClicksocialNetworkMSgSend()
		local text = self.socialNetwork_letter_edit:GetText();
		if text ~= "" then
			 local list = dataManager.buddyData:getBuddyList()	
			 local f = list[self.selectFriendId]  
			 if(f)then
			  dataManager.buddyData:sendMsgToFriend(text,f)	
			  self.socialNetwork_letter_edit:SetText("");
			 else
				self.socialNetwork_letter:SetVisible(false) 
			 end
		end
	end
	
	function onClicksocialNetworkRefresh()
		self.searchOrReco  = false
		dataManager.buddyData:viewRecommendList()	
	end
	self.socialNetwork_letter_send:subscribeEvent("ButtonClick", "onClicksocialNetworkMSgSend"); 
	
	self.socialNetwork_find_reflash:subscribeEvent("ButtonClick", "onClicksocialNetworkRefresh");  
	
	function onClicksocialNetworkMSgClose()
		self.socialNetwork_letter:SetVisible(false) 
	end
	self.socialNetwork_letter_close:subscribeEvent("ButtonClick", "onClicksocialNetworkMSgClose"); 
	
	function onClicksocialNetworkClose()
		self:onHide()
	end

	
	self.socialNetwork_close:subscribeEvent("ButtonClick", "onClicksocialNetworkClose"); 
	
	
	function onClicksocialNetworkRequest(args)
 
		local window = LORD.toRadioButton(LORD.toWindowEventArgs(args).window);
	
		if window:IsSelected() then	
			--self.socialNetwork_searching:SetVisible(true)
			--self.socialNetwork_find:SetVisible(false)
			self.socialNetwork_pane:ClearAllItem()  
			--dataManager.buddyData:viewApplyList()	
			--self.socialNetwork_new3:SetVisible( false)
			self.page = 2
			self:Update()
		end	
	end
	
	self.socialNetwork_request:subscribeEvent("RadioStateChanged", "onClicksocialNetworkRequest"); 
	self.socialNetwork_request:SetSelected(false);
	
	self.socialNetwork_letter_pane:init();
	self.socialNetwork_pane:init();
	
	function onClicksocialNetworkAdd(args)		
		local window = LORD.toRadioButton(LORD.toWindowEventArgs(args).window);
	
		if window:IsSelected() then	
			self.page = 1
			self.searchOrReco  = false
			self.socialNetwork_pane:ClearAllItem()  
			self:Update()	
		end
	end
	self.socialNetwork_add:subscribeEvent("RadioStateChanged", "onClicksocialNetworkAdd"); 
	self.socialNetwork_add:SetSelected(false);
	
	
	
	function onClicksocialNetworkDel()	
			self.page = 0	
			local list = dataManager.buddyData:getBuddyList()	
			local f = list[self.selectFriendId]  
			if(f )then
				dataManager.buddyData:setSelBuddyId(f:getId())
				
				function confirmDelFriend()
					dataManager.buddyData:delFriends(f:getId())	
				end
				eventManager.dispatchEvent( {name = global_event.CONFIRM_SHOW, callBack = confirmDelFriend,text = "您确定要删除好友" ..f:getName().."^FFFFFF吗？" })	   
			 end		
	end
	self.socialNetwork_del:subscribeEvent("ButtonClick", "onClicksocialNetworkDel"); 
	
	
	
	function onClicksocialNetworkAddSend()		
		
			local text = self.socialNetwork_find_edit:GetText()
			if text ~= "" then
				self.searchOrReco  = true
				dataManager.buddyData:sendSearchFriend(text)
				--self.socialNetwork_find:SetVisible(false)
			else
				eventManager.dispatchEvent({name = global_event.WARNINGHINT_SHOW,tip = "请输入玩家昵称或ID"})	
			end
	end
	self.socialNetwork_find_text:subscribeEvent("ButtonClick", "onClicksocialNetworkAddSend"); 	
	
	
	function onClicksocialNetworkFreiends(args)		
		
		local window = LORD.toRadioButton(LORD.toWindowEventArgs(args).window);
	
		if window:IsSelected() then	
			 
			 self.page = 0
			 dataManager.buddyData:resetNewFriendflag()
			 self:Update()
			 eventManager.dispatchEvent({name = global_event.FRIEND_UPDATE})
		end	
	end
	
 
	
	self.socialNetwork_message:subscribeEvent("RadioStateChanged", "onClicksocialNetworkFreiends"); 	
	self.socialNetwork_message:SetSelected(true);
	
	self:Update()
	
end

function socialNetwork:Update(event)
	if not self._show then
		return;
	end
	self.socialNetwork_find:SetVisible(false)
	self.socialNetwork_vigortext_dw:SetVisible(false) 
	self.socialNetwork_searching:SetVisible(false)
	local ungetVigor = dataManager.buddyData:hasUnGetVigor()
	self.socialNetwork_new1:SetVisible( ungetVigor or dataManager.buddyData:hasNewFriend())
	local list = dataManager.buddyData:getApplicants()
	self.socialNetwork_new3:SetVisible( table.nums(list) > 0)
	self.socialNetwork_friendnum:SetText( dataManager.buddyData:getBuddyNum().."/"..100)

	if(self.page == 0) then
	
		if(event and event.updateStatusOnly)then
			self:UpdateFriendListStatus()
		else
			self:UpdateFriendList()
		end
	elseif(self.page == 1) then 
	
		if(event and event.applySendedUpDate)then
			self:UpdateSearchOrRecommandResultStatus()
		else
			self:UpdateSearchOrRecommandResult()
		end

	elseif(self.page == 2) then 
		self:onUpdateApplyList()
	end	

end	



function socialNetwork:UpdateFriendListStatus()	
	if not self._show then
		return;
	end
	self.socialNetwork_vigortext_dw:SetVisible(true) 
	self.socialNetwork_vigortext_canreceive_num:SetText(dataManager.playerData:getCounterData(enum.COUNTER_TYPE.COUNTER_TYPE_FRIEND_VIGOR_RECEIVE_TIMES).."/"..dataConfig.configs.ConfigConfig[0].friendsGetVigorTimes)
	self.socialNetwork_vigortext_cansend_num:SetText(dataManager.playerData:getCounterData(enum.COUNTER_TYPE.COUNTER_TYPE_FRIEND_VIGOR_GIFT_TIMES).."/"..dataConfig.configs.ConfigConfig[0].friendsGiftsVigorTimes)
	
	local list = dataManager.buddyData:getBuddyList()	
	local nums = #self.wnd 
	for i = 1,nums do
		
			if(self.wnd[i] and self.wnd[i].prew  )then
				local id =    self.wnd[i].prew:GetUserData()
				local v = list[id]  
				if(v)then
					self.wnd[i].power:SetVisible(false)
					self.wnd[i].vip:SetText("VIP "..v.vip)
					self.wnd[i].vip:SetVisible(v.vip ~= 0)
					self.wnd[i].accept:SetVisible(false)
					self.wnd[i].refuse:SetVisible(false)
					self.wnd[i].sendRequest:SetVisible(false)
					self.wnd[i].recieve:SetVisible(v:getrecvFromFriendFlags()) 
				    self.wnd[i].recieveNum:SetText("+"..dataConfig.configs.ConfigConfig[0].friendsVigorCount)
					local  getsendToFreinedFlags =   v:getsendToFreinedFlags()
					self.wnd[i].send:SetVisible( not getsendToFreinedFlags) 
					self.wnd[i].sendfinish:SetVisible(getsendToFreinedFlags)
					self.wnd[i].sendfinishimage:SetVisible(getsendToFreinedFlags)
					
					
					if(id == self.selectFriendId)then
						self.wnd[i].back:SetProperty("ImageName",  "set:login.xml image:container1")
					else
						self.wnd[i].back:SetProperty("ImageName",  "set:common.xml image:container1-chose")	
					end	
					self.wnd[i].icon:SetImage(global.getHeadIcon(v:getHeadIcon()))
					self.wnd[i].name:SetText(""..v:getName())
					self.wnd[i].id:SetText(v:getOnlineStatus())
					self.wnd[i].level:SetText("等级："..v:getLevel())
				end			
			end
   end
end
function socialNetwork:UpdateFriendList()
	self.socialNetwork_pane:ClearAllItem()  
 	self.socialNetwork_vigortext_dw:SetVisible(true) 
	self.socialNetwork_vigortext_canreceive_num:SetText(dataManager.playerData:getCounterData(enum.COUNTER_TYPE.COUNTER_TYPE_FRIEND_VIGOR_RECEIVE_TIMES).."/"..dataConfig.configs.ConfigConfig[0].friendsGetVigorTimes)
	self.socialNetwork_vigortext_cansend_num:SetText(dataManager.playerData:getCounterData(enum.COUNTER_TYPE.COUNTER_TYPE_FRIEND_VIGOR_GIFT_TIMES).."/"..dataConfig.configs.ConfigConfig[0].friendsGiftsVigorTimes)
	--enum.COUNTER_TYPE.COUNTER_TYPE_FRIEND_CONTEST_TIMES = 33;-- 好友切磋次数
	function onClicksocialNetworkCheck(args)
		local clickImage = LORD.toWindowEventArgs(args).window
 		local userdata = clickImage:GetUserData()
		local list = dataManager.buddyData:getBuddyList()
		if(list and  list[userdata] )then
 
			local rect = clickImage:GetUnclippedOuterRect();
			dataManager.chatData:setClickPosition(LORD.Vector2(rect.right+100, rect.top + 100 ));
			sendAskInspect( list[userdata]:getId());
		end
	end	
	
	function onClicksocialNetworkMsg(args)
		local clickImage = LORD.toWindowEventArgs(args).window
 		local userdata = clickImage:GetUserData()
		local list = dataManager.buddyData:getBuddyList()
		if(list and  list[userdata] )then
			self.selectFriendId = userdata
			self:openPrivetMsg(self.selectFriendId)
		end
		
	end	
	
	function onClicksocialNetworkrecieve(args)
		local clickImage = LORD.toWindowEventArgs(args).window
 		local userdata = clickImage:GetUserData()
		local list = dataManager.buddyData:getBuddyList()
		if(list and  list[userdata] )then
			dataManager.buddyData:ReciveFriend(list[userdata]:getId())
		end
	end	
	
	function onClicksocialNetworksend(args)
		local clickImage = LORD.toWindowEventArgs(args).window
 		local userdata = clickImage:GetUserData()
		local list = dataManager.buddyData:getBuddyList()
		if(list and  list[userdata] )then
			dataManager.buddyData:presentFriend(list[userdata]:getId())
		end
	end	
	 
	function onClicksocialNetworkIcon(args)
		local clickImage = LORD.toWindowEventArgs(args).window
 		local userdata = clickImage.icon:GetUserData()
		local list = dataManager.buddyData:getBuddyList()
		if(list and  list[userdata] )then
			----dataManager.buddyData:presentFriend(list[userdata]:getId())
			local rect = clickImage.icon:GetUnclippedOuterRect();
			self.selectFriendId = userdata
			eventManager.dispatchEvent({name = global_event.CONTACTLAYOUT_SHOW, rect = rect, id =  list[userdata]:getId(),from = "BUDDY" })
			
		end
	end	
	
	
	
	function onTouchDownFriend(args)	
			local clickImage = LORD.toWindowEventArgs(args).window
			local userdata = clickImage:GetUserData()
			for i,v in pairs (self.allPreView) do
				v:SetProperty("ImageName",  "set:login.xml image:container1-chose")
			end	
			if(clickImage and clickImage.back)then
				clickImage.back:SetProperty("ImageName",  "set:login.xml image:container1")	
			end
			if(userdata ~= -1)then
				 self.selectFriendId = userdata	 			 
			end				
		end	 
		function onTouchUpFriend(args)
			local clickImage = LORD.toWindowEventArgs(args).window;
			local userdata = clickImage:GetUserData()
	 
			if(userdata ~= -1)then
				local list = dataManager.buddyData:getBuddyList()	
				--local f = list[userdata]  
				self.selectFriendId = userdata
				--self:openPrivetMsg(self.selectFriendId)
						
			end
		end	 		
		function onTouchReleaseFriend(args)
			local clickImage = LORD.toWindowEventArgs(args).window;
			local userdata = clickImage:GetUserData()
			if(userdata == -1)then
				return
			end
		end	 		
	
	
	local xpos = LORD.UDim(0, 10)
	local ypos = LORD.UDim(0, 10)		
	self.allPreView = {}
	local list = dataManager.buddyData:getBuddyList()
	
	local temlist = {}
	for i, v in pairs(list) do
		if(v)then
			table.insert(temlist,v)
		end
	end
	table.sort(temlist,pack_sort_buddy)

	self.wnd = {}
	local nums = #temlist
	for i = 1,nums do
	--for i, v in pairs(list) do
		
			local v = temlist[i]
			self.wnd[i] = {}
			self.wnd[i].prew = LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("socialNetwork_"..i, "socialNetworkItem.dlg");
			self.wnd[i].icon = LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("socialNetwork_"..i.."_socialNetworkItem-icon"))
			self.wnd[i].name = LORD.GUIWindowManager:Instance():GetGUIWindow("socialNetwork_"..i.."_socialNetworkItem-name")
			self.wnd[i].level = LORD.GUIWindowManager:Instance():GetGUIWindow("socialNetwork_"..i.."_socialNetworkItem-level")
			self.wnd[i].id = LORD.GUIWindowManager:Instance():GetGUIWindow("socialNetwork_"..i.."_socialNetworkItem-chattext")
			self.wnd[i].back = LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("socialNetwork_"..i.."_socialNetworkItem-back"))
 
			local headFrame = LORD.toStaticImage(self:Child("socialNetwork_"..i.."_socialNetworkItem-head"));
			headFrame:SetImage(global.getMythsIcon(v.miracle));
			
			self.wnd[i].power = LORD.GUIWindowManager:Instance():GetGUIWindow("socialNetwork_"..i.."_socialNetworkItem-power")
			self.wnd[i].power:SetVisible(false)
			
			
			self.wnd[i].vip = LORD.GUIWindowManager:Instance():GetGUIWindow("socialNetwork_"..i.."_socialNetworkItem-vip")
			self.wnd[i].vip:SetText("VIP "..v.vip)
	        self.wnd[i].vip:SetVisible(v.vip ~= 0)
			
			
		
			self.wnd[i].accept = LORD.GUIWindowManager:Instance():GetGUIWindow("socialNetwork_"..i.."_socialNetworkItem-accept")
			self.wnd[i].refuse = LORD.GUIWindowManager:Instance():GetGUIWindow("socialNetwork_"..i.."_socialNetworkItem-deny")
			self.wnd[i].accept:SetVisible(false)
			self.wnd[i].refuse:SetVisible(false)
		 
			--self.wnd[i].check = LORD.GUIWindowManager:Instance():GetGUIWindow("socialNetwork_"..i.."_socialNetworkItem-check")
			--self.wnd[i].check:SetUserData(v.id)
			--self.wnd[i].check:SetVisible(true)
	 
			
			self.wnd[i].sendRequest = LORD.GUIWindowManager:Instance():GetGUIWindow("socialNetwork_"..i.."_socialNetworkItem-sendRequest")
			self.wnd[i].sendRequest:SetVisible(false)
			self.wnd[i].msg = LORD.GUIWindowManager:Instance():GetGUIWindow("socialNetwork_"..i.."_socialNetworkItem-messages")
			self.wnd[i].msg:SetUserData(v.id)
			self.wnd[i].messageCount = LORD.GUIWindowManager:Instance():GetGUIWindow("socialNetwork_"..i.."_socialNetworkItem-messageCount")
		 
		
			self.wnd[i].recieve = LORD.GUIWindowManager:Instance():GetGUIWindow("socialNetwork_"..i.."_socialNetworkItem-recieve")
			self.wnd[i].recieveNum = LORD.GUIWindowManager:Instance():GetGUIWindow("socialNetwork_"..i.."_socialNetworkItem-recievenum")
			self.wnd[i].send = LORD.GUIWindowManager:Instance():GetGUIWindow("socialNetwork_"..i.."_socialNetworkItem-send")
			self.wnd[i].sendfinish = LORD.GUIWindowManager:Instance():GetGUIWindow("socialNetwork_"..i.."_socialNetworkItem-sendfinish")
			self.wnd[i].sendfinishimage = LORD.GUIWindowManager:Instance():GetGUIWindow("socialNetwork_"..i.."_socialNetworkItem-sendfinishimage")
		
		    self.wnd[i].recieve:SetVisible(v:getrecvFromFriendFlags()) 
			self.wnd[i].recieveNum:SetText("+"..dataConfig.configs.ConfigConfig[0].friendsVigorCount)
			local  getsendToFreinedFlags =   v:getsendToFreinedFlags()
			self.wnd[i].send:SetVisible( not getsendToFreinedFlags) 
			self.wnd[i].sendfinish:SetVisible(getsendToFreinedFlags)
			self.wnd[i].sendfinishimage:SetVisible(getsendToFreinedFlags)
			self.wnd[i].recieve:SetUserData(v.id)
			self.wnd[i].send:SetUserData(v.id)
			self.wnd[i].recieve:subscribeEvent("WindowTouchUp", "onClicksocialNetworkrecieve"); 
		    self.wnd[i].send:subscribeEvent("ButtonClick", "onClicksocialNetworksend"); 			
			
			self.wnd[i].prew:subscribeEvent("WindowTouchUp", "onClicksocialNetworkIcon"); 
			self.wnd[i].icon:SetUserData(v.id)
			self.wnd[i].prew.icon = self.wnd[i].icon
			
			--self.wnd[i].check:subscribeEvent("ButtonClick", "onClicksocialNetworkCheck"); 
		    self.wnd[i].msg:subscribeEvent("WindowTouchDown", "onClicksocialNetworkMsg"); 
			
			self.wnd[i].prew.back = self.wnd[i].back
		 	self.wnd[i].prew:SetPosition(LORD.UVector2(xpos, ypos));											
		    self.socialNetwork_pane:additem(self.wnd[i].prew);
			
			
			self.wnd[i].prew:subscribeEvent("WindowTouchDown", "onTouchDownFriend")
	 		self.wnd[i].prew:subscribeEvent("WindowTouchUp", "onTouchUpFriend")
	 		self.wnd[i].prew:subscribeEvent("MotionRelease", "onTouchReleaseFriend")
			self.wnd[i].prew:SetUserData(v.id)
			table.insert(self.allPreView,self.wnd[i].back)
			
			if(i == self.selectFriendId)then
				self.wnd[i].back:SetProperty("ImageName",  "set:login.xml image:container1")
			else
				self.wnd[i].back:SetProperty("ImageName",  "set:common.xml image:container1-chose")	
			end	
			
		 
			self.wnd[i].icon:SetImage(global.getHeadIcon(v:getHeadIcon()))
			
	
			self.wnd[i].name:SetText(""..v:getName())
			self.wnd[i].id:SetText(v:getOnlineStatus())
			self.wnd[i].level:SetText("等级："..v:getLevel())
			
			local count = 	v:getMsgCountOffline()
			if(count <= 0 )then
				count = v:getUnreadcount()
			end
			--self.wnd[i].msg:SetVisible(count > 0  and v:getMsgReadFlag() == false )
			--self.wnd[i].msg:SetVisible(true)
			if(count >  0)then
				self.wnd[i].messageCount:SetText(count)
			else
				self.wnd[i].messageCount:SetText("")
			end
		 	--local width = prew:GetWidth()
		 	--xpos = xpos + width			
			--xpos = LORD.UDim(0, 10)
			ypos = ypos + self.wnd[i].prew:GetHeight() + LORD.UDim(0, 5)	
		end 
		
		
	
end

function socialNetwork:onUpdateRecommandResult(event)
	if not self._show then
		return;
	end
	self.searchOrReco  = true
	self:UpdateSearchOrRecommandResult( )	
end	
 
function socialNetwork:onUpdateSearchResult(event)
	if not self._show then
		return;
	end
	self.searchOrReco  = false
	self:UpdateSearchOrRecommandResult( )	
	
end	
function socialNetwork:UpdateSearchOrRecommandResultStatus(  )
	
	if not self._show then
		return;
	end	
	
	 self.socialNetwork_find:SetVisible(true)
		
	local list = {}
		
	if(self.searchOrReco )then
			list = 	dataManager.buddyData:getSearchFriendList()
	else
			list = 	dataManager.buddyData:getRecommend()		
	end
 
	for i, v in pairs(self.wnd2) do
			if(self.wnd2[i] and self.wnd2[i].prew  )then
				local id =    self.wnd2[i].prew:GetUserData()
				local v = list[id]  
				if(v)then
					self.wnd2[i].sendRequest:SetVisible(not dataManager.buddyData:isSendApply(v.id))
			
					if(v.id == dataManager.playerData:getPlayerId()   ) then
						self.wnd2[i].sendRequest:SetVisible(false)
					end
					if(dataManager.buddyData:isBuddy(v.id)   ) then
						self.wnd2[i].sendRequest:SetVisible(false)
					end
					self.wnd2[i].sended:SetVisible(dataManager.buddyData:isSendApply(v.id))
					self.wnd2[i].icon:SetImage(global.getHeadIcon(v.headicon))
					self.wnd2[i].name:SetText(""..v.name)
					self.wnd2[i].id:SetText("ID:"..v.id)
					self.wnd2[i].level:SetText("等级："..v.level)
				
				end
			end
	end	
			
end
function socialNetwork:UpdateSearchOrRecommandResult(  )
	
	function onClicksocialNetworkSendRequest(args)
		local clickImage = LORD.toWindowEventArgs(args).window
 		local userdata = clickImage:GetUserData()
	 
		dataManager.buddyData:applyFriend(userdata)
		--self:UpdateSearchOrRecommandResult( )	
	end		
	self.socialNetwork_find:SetVisible(true)

	function onClicksocialNetworkSearchOrRecomIcon(args)
		local clickImage = LORD.toWindowEventArgs(args).window
 		local userdata = clickImage.icon:GetUserData()
		
		if(userdata == dataManager.playerData:getPlayerId()  ) then
			return 
		end
		
		local list = {}
		local from = ""
		if(self.searchOrReco )then
			list = 	dataManager.buddyData:getSearchFriendList()
			from = "BUDDY_SERACH_LIST"
		else
			list = 	dataManager.buddyData:getRecommend()	
			from = "BUDDY_RECOMMEND_LIST"	
		end
		if(list and  list[userdata] )then
			local rect = clickImage.icon:GetUnclippedOuterRect();
			eventManager.dispatchEvent({name = global_event.CONTACTLAYOUT_SHOW, rect = rect, id =  userdata,from = from })
		end
	end		
	
	
	self.socialNetwork_pane:ClearAllItem()  
	local xpos = LORD.UDim(0, 10)
	local ypos = LORD.UDim(0, 10)		
		
		local list = {}
		
		if(self.searchOrReco )then
			list = 	dataManager.buddyData:getSearchFriendList()
		else
			list = 	dataManager.buddyData:getRecommend()		
		end
		self.wnd2 = {}
		for i, v in pairs(list) do
			self.wnd2[i] = {} 
			self.wnd2[i].prew = LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("socialNetwork_"..i, "socialNetworkItem.dlg");
			self.wnd2[i].icon = LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("socialNetwork_"..i.."_socialNetworkItem-icon"))
			self.wnd2[i].name = LORD.GUIWindowManager:Instance():GetGUIWindow("socialNetwork_"..i.."_socialNetworkItem-name")
			self.wnd2[i].level = LORD.GUIWindowManager:Instance():GetGUIWindow("socialNetwork_"..i.."_socialNetworkItem-level")
			self.wnd2[i].id = LORD.GUIWindowManager:Instance():GetGUIWindow("socialNetwork_"..i.."_socialNetworkItem-chattext")
			
			
			local headFrame = LORD.toStaticImage(self:Child("socialNetwork_"..i.."_socialNetworkItem-head"));
			headFrame:SetImage(global.getMythsIcon(v.miracle));
			
			self.wnd2[i].prew:subscribeEvent("WindowTouchUp", "onClicksocialNetworkSearchOrRecomIcon"); 
			self.wnd2[i].icon:SetUserData(v.id)
			self.wnd2[i].prew.icon = self.wnd2[i].icon
			--[[icon:SetUserData(v.id)--]]
			self.wnd2[i].prew:SetUserData(v.id)
			self.wnd2[i].accept = LORD.GUIWindowManager:Instance():GetGUIWindow("socialNetwork_"..i.."_socialNetworkItem-accept")
			self.wnd2[i].refuse = LORD.GUIWindowManager:Instance():GetGUIWindow("socialNetwork_"..i.."_socialNetworkItem-deny")
			self.wnd2[i].accept:SetVisible(false)
			self.wnd2[i].refuse:SetVisible(false)
			self.wnd2[i].power = LORD.GUIWindowManager:Instance():GetGUIWindow("socialNetwork_"..i.."_socialNetworkItem-power")
		    self.wnd2[i].power:SetVisible(false)
			
			self.wnd2[i].vip = LORD.GUIWindowManager:Instance():GetGUIWindow("socialNetwork_"..i.."_socialNetworkItem-vip")
			--vip:SetVisible(false)
			self.wnd2[i].vip:SetText("VIP "..v.vip)
			self.wnd2[i].recieve = LORD.GUIWindowManager:Instance():GetGUIWindow("socialNetwork_"..i.."_socialNetworkItem-recieve")
			self.wnd2[i].send = LORD.GUIWindowManager:Instance():GetGUIWindow("socialNetwork_"..i.."_socialNetworkItem-send")
			self.wnd2[i].recieve:SetVisible(false)
			self.wnd2[i].send:SetVisible(false)
		 
			self.wnd2[i].sended = LORD.GUIWindowManager:Instance():GetGUIWindow("socialNetwork_"..i.."_socialNetworkItem-sended")
			self.wnd2[i].sended:SetVisible(dataManager.buddyData:isSendApply(v.id))
	
			--local check = LORD.GUIWindowManager:Instance():GetGUIWindow("socialNetwork_"..i.."_socialNetworkItem-check")
			--check:SetVisible(false)
			self.wnd2[i].sendRequest = LORD.GUIWindowManager:Instance():GetGUIWindow("socialNetwork_"..i.."_socialNetworkItem-sendRequest")
			--sendRequest:SetVisible(true)
			self.wnd2[i].sendRequest:SetVisible(not dataManager.buddyData:isSendApply(v.id))
			
			if(v.id == dataManager.playerData:getPlayerId()   ) then
				self.wnd2[i].sendRequest:SetVisible(false)
			end
			if(dataManager.buddyData:isBuddy(v.id)   ) then
				self.wnd2[i].sendRequest:SetVisible(false)
			end
		 
			self.wnd2[i].sendRequest:SetUserData(v.id)
			self.wnd2[i].msg = LORD.GUIWindowManager:Instance():GetGUIWindow("socialNetwork_"..i.."_socialNetworkItem-messages")
			self.wnd2[i].msg:SetVisible(false)
			self.wnd2[i].sendRequest:subscribeEvent("ButtonClick", "onClicksocialNetworkSendRequest"); 
		 	self.wnd2[i].prew:SetPosition(LORD.UVector2(xpos, ypos));											
			self.socialNetwork_pane:additem(self.wnd2[i].prew);
			self.wnd2[i].icon:SetImage(global.getHeadIcon(v.headicon))
			self.wnd2[i].name:SetText(""..v.name)
			self.wnd2[i].id:SetText("ID:"..v.id)
			self.wnd2[i].level:SetText("等级："..v.level)
		 	--local width = self.wnd2[i].prew:GetWidth()
		 	--xpos = xpos + width			
			--xpos = LORD.UDim(0, 10)
			ypos = ypos + self.wnd2[i].prew:GetHeight() + LORD.UDim(0, 5)	
		end 
		
end 

function socialNetwork:onUpdateMsg(event)
	if not self._show then
		return;
	end
	local list = dataManager.buddyData:getBuddyList()	
	local f = list[event.user]  
	local msgs = f:getMsgOffline()
	local msgsOn = f:getMsgOnline()
		
	local countOffline = table.nums(msgs)
	local countOnline = table.nums(msgsOn)
	local all = countOffline + countOnline
		
	for i,v in pairs (	list )do
		if(v:getId() == event.user)then
		 
			self.wnd[i].msg:SetVisible(v:getUnreadcount() > 0 and v:getMsgReadFlag() == false )
			self.wnd[i].messageCount:SetText(v:getUnreadcount())
			break;
		end
	end	
	
	if(self.socialNetwork_letter:IsVisible() == false)then
		return
	end
	f:resetMsgReadFlag();
	
	for i,v in pairs (	list )do
		if(v:getId() == event.user)then
			--self.wnd[i].msg:SetVisible(  v:getUnreadcount() > 0 and v:getMsgReadFlag() == false )
			self.wnd[i].msg:SetVisible(true )
			local c = v:getUnreadcount()
			if(c >0 )then
				self.wnd[i].messageCount:SetText(c)
			else
				self.wnd[i].messageCount:SetText("")
			end
			
			break;
		end
	end	
	
	self.socialNetwork_letter_pane:ClearAllItem();
	--msgs = {"喂，草你吗，我日","我草，你谁啊？","我日啊","我草，你到底谁啊","我日啊，你草吧 ","TMD，你到底是谁啊，我草 ","我日，我日啊"}
	local xpos = LORD.UDim(0, 10)
	local ypos = LORD.UDim(0, 10)		
		local talker = nil
		for i = 1, all  do
			local v = nil
			if(i <= countOffline)then
				v = msgs[i][1]
				talker = msgs[i][2]
			else
				v = msgsOn[ i-countOffline][1]
				talker = msgsOn[i-countOffline][2]
			end
			
			local nameColor = "^AF15AF";
			local textColor = "^15AF15";
			if(not talker)then
				talker = dataManager.playerData
				nameColor = "^15FF15";
				textColor = "^00FF00";
			else
				talker = f	
			end
			
			
			local prew = LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("socialNetwork_"..i, "chatRoomItem.dlg");
			local icon = LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("socialNetwork_"..i.."_chatRoomItem-icon"))
			local name = LORD.GUIWindowManager:Instance():GetGUIWindow("socialNetwork_"..i.."_chatRoomItem-name")
			local text = LORD.GUIWindowManager:Instance():GetGUIWindow("socialNetwork_"..i.."_chatRoomItem-chattext")
			local textBack = LORD.GUIWindowManager:Instance():GetGUIWindow("socialNetwork_"..i.."_chatRoomItem-dialog")
			
			
		 	prew:SetPosition(LORD.UVector2(xpos, ypos));											
			self.socialNetwork_letter_pane:additem(prew);
			
			icon:SetImage(talker:getHeadIconImage() )
			name:SetText(nameColor..talker:getName())
			text:SetText(textColor..v)
			local textHeight = text:GetHeight();
			local font = LORD.GUIFontManager:Instance():GetFont("HT-26");
			local textWidth = font:GetTextExtent(v) + 20;
	
			textBack:SetHeight(textHeight + LORD.UDim(0, 20));
			local contentBackWidth = textBack:GetWidth();
			if textWidth < contentBackWidth.offset then
				textBack:SetWidth(LORD.UDim(0, textWidth));
			end
			
			 local heightOffset = textBack:GetUnclippedOuterRect().bottom - prew:GetUnclippedOuterRect().bottom;
			 prew:SetHeight(prew:GetHeight() + LORD.UDim(0, heightOffset));
		     ypos = ypos + prew:GetHeight() + LORD.UDim(0, 5)			
			
		end 	
		self.socialNetwork_letter_pane:SetVertScrollOffset(-1000)
end	

function socialNetwork:openPrivetMsg(selectFriendId)
	
	local list = dataManager.buddyData:getBuddyList()	
	local f = list[selectFriendId]  
	
	if(f) then
		self.socialNetwork_letter:SetVisible(true)	
		self.socialNetwork_letter_pane:init(); 
		self.socialNetwork_letter_pane:ClearAllItem();
		self.socialNetwork_letter_title:SetText(f:getName())
		self.socialNetwork_letter_head:SetImage(f:getHeadIconImage())
		
		if(f:getMsgCountOffline() > 0 ) then
			--dataManager.buddyData:viewFriendMsg(f:getId())
		else
			self:onUpdateMsg( {user = selectFriendId} )
		end
	end
end	

function socialNetwork:onBeginChatMsg(event)
	if not self._show then
		return;
	end
	self:openPrivetMsg(event.id)
end

	
function socialNetwork:onUpdateApplyList(event)
	if not self._show then
		return;
	end
	self:UpdateApplyList()	
end	

function socialNetwork:UpdateApplyList()
	self.socialNetwork_pane:ClearAllItem()  
	function onClicksocialNetworkaccept(args)
		local clickImage = LORD.toWindowEventArgs(args).window
 		local userdata = clickImage:GetUserData()
		dataManager.buddyData:addFriends(userdata)
		 
	end	
	
	function onClicksocialNetworkrefuse(args)
		local clickImage = LORD.toWindowEventArgs(args).window
 		local userdata = clickImage:GetUserData()
		dataManager.buddyData:setSelBuddyId(userdata)
		dataManager.buddyData:rejectFriends(userdata)
		
	end		
	
	function onClicksocialNetworkApplyIcon(args)
		local clickImage = LORD.toWindowEventArgs(args).window
 		local userdata = clickImage.icon:GetUserData()
		
		local list = dataManager.buddyData:getApplicants()
		local from = "BUDDY_APPLY"
		if(list and  list[userdata] )then
			local rect = clickImage.icon:GetUnclippedOuterRect();
			eventManager.dispatchEvent({name = global_event.CONTACTLAYOUT_SHOW, rect = rect, id =  userdata,from = from })
		end
	end		
		
	local xpos = LORD.UDim(0, 10)
	local ypos = LORD.UDim(0, 10)		
		self._wnds = {}
		local list = dataManager.buddyData:getApplicants()
	
		for i, v in pairs(list) do
			if(v)then
				self._wnds[i] = {}
				self._wnds[i].prew = LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("socialNetwork_"..i, "socialNetworkItem.dlg");
				self._wnds[i].icon = LORD.toStaticImage(LORD.GUIWindowManager:Instance():GetGUIWindow("socialNetwork_"..i.."_socialNetworkItem-icon"))
				self._wnds[i].name = LORD.GUIWindowManager:Instance():GetGUIWindow("socialNetwork_"..i.."_socialNetworkItem-name")
				self._wnds[i].level = LORD.GUIWindowManager:Instance():GetGUIWindow("socialNetwork_"..i.."_socialNetworkItem-level")
				self._wnds[i].id = LORD.GUIWindowManager:Instance():GetGUIWindow("socialNetwork_"..i.."_socialNetworkItem-chattext")
				
				self._wnds[i].accept = LORD.GUIWindowManager:Instance():GetGUIWindow("socialNetwork_"..i.."_socialNetworkItem-accept")
				self._wnds[i].refuse = LORD.GUIWindowManager:Instance():GetGUIWindow("socialNetwork_"..i.."_socialNetworkItem-deny")
				self._wnds[i].accept:SetUserData(v.id)
				self._wnds[i].refuse:SetUserData(v.id)
				self._wnds[i].accept:subscribeEvent("ButtonClick", "onClicksocialNetworkaccept"); 
				self._wnds[i].refuse:subscribeEvent("ButtonClick", "onClicksocialNetworkrefuse"); 
				
				local headFrame = LORD.toStaticImage(self:Child("socialNetwork_"..i.."_socialNetworkItem-head"));
				headFrame:SetImage(global.getMythsIcon(v.miracle));
			
				self._wnds[i].prew:subscribeEvent("WindowTouchUp", "onClicksocialNetworkApplyIcon"); 
			    self._wnds[i].icon:SetUserData(v.id)
				self._wnds[i].prew.icon = self._wnds[i].icon
				--[[icon:SetUserData(v.id)--]]			
				
				
				self._wnds[i].power = LORD.GUIWindowManager:Instance():GetGUIWindow("socialNetwork_"..i.."_socialNetworkItem-power")
				self._wnds[i].power:SetVisible(false)
				self._wnds[i].vip = LORD.GUIWindowManager:Instance():GetGUIWindow("socialNetwork_"..i.."_socialNetworkItem-vip")
				--vip:SetVisible(false)
				self._wnds[i].vip:SetText("VIP "..v.vip)
				self._wnds[i].recieve = LORD.GUIWindowManager:Instance():GetGUIWindow("socialNetwork_"..i.."_socialNetworkItem-recieve")
				self._wnds[i].send = LORD.GUIWindowManager:Instance():GetGUIWindow("socialNetwork_"..i.."_socialNetworkItem-send")
				self._wnds[i].recieve:SetVisible(false)
				self._wnds[i].send:SetVisible(false)

				--local check = LORD.GUIWindowManager:Instance():GetGUIWindow("socialNetwork_"..i.."_socialNetworkItem-check")
				--check:SetVisible(false)
				self._wnds[i].sendRequest = LORD.GUIWindowManager:Instance():GetGUIWindow("socialNetwork_"..i.."_socialNetworkItem-sendRequest")
				self._wnds[i].sendRequest:SetVisible(false)
				self._wnds[i].msg = LORD.GUIWindowManager:Instance():GetGUIWindow("socialNetwork_"..i.."_socialNetworkItem-messages")
				self._wnds[i].msg:SetVisible(false)

				self._wnds[i].prew:SetPosition(LORD.UVector2(xpos, ypos));											
				self.socialNetwork_pane:additem(self._wnds[i].prew);
				
				
				self._wnds[i].icon:SetImage(global.getHeadIcon(v.headID))
				self._wnds[i].name:SetText(""..v.nickname)
				self._wnds[i].id:SetText("ID:"..v.id)
				self._wnds[i].level:SetText("等级："..v.level)
			
				--local width = prew:GetWidth()
				--xpos = xpos + width			
				--xpos = LORD.UDim(0, 10)
				ypos = ypos + self._wnds[i].prew:GetHeight() + LORD.UDim(0, 5)	
			end	
		end 
end	

function socialNetwork:onHide(event)
	self:Close();
	self.wnd = nil
	self._wnds = nil
	self.wnd2 = nil
end

return socialNetwork;
