local contactLayout = class( "contactLayout", layout );

global_event.CONTACTLAYOUT_SHOW = "CONTACTLAYOUT_SHOW";
global_event.CONTACTLAYOUT_HIDE = "CONTACTLAYOUT_HIDE";

function contactLayout:ctor( id )
	contactLayout.super.ctor( self, id );
	self:addEvent({ name = global_event.CONTACTLAYOUT_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.CONTACTLAYOUT_HIDE, eventHandler = self.onHide});
end

function contactLayout:onShow(event)
	if self._show then
		return;
	end

	self:Show();

	self.contactLayout_check_dw = self:Child( "contactLayout-check-dw" );
	self.contactLayout_check = self:Child( "contactLayout-check" );
	self.contactLayout_whisper_dw = self:Child( "contactLayout-whisper-dw" );
	self.contactLayout_whisper = self:Child( "contactLayout-whisper" );
	self.contactLayout_add_dw = self:Child( "contactLayout-add-dw" );
	self.contactLayout_add = self:Child( "contactLayout-add" );
	self.contactLayout_del_dw = self:Child( "contactLayout-del-dw" );
	self.contactLayout_del = self:Child( "contactLayout-del" );
	self.contactLayout_pk_dw = self:Child( "contactLayout-pk-dw" );
	self.contactLayout_pk = self:Child( "contactLayout-pk" );
	self.id = event.id
	self.from = event.from
	self.userdate = event.userdate
	

	local y = event.rect.top - 30
	local layoutHeight = self._view:GetPixelSize().y;
	if(y + layoutHeight  > engine.rootUiSize.h ) then
		y = engine.rootUiSize.h - layoutHeight -5
	
	end
	 
	self._view:SetPosition( LORD.UVector2(     LORD.UDim(0,event.rect.right+50)  , LORD.UDim(0, y) )  )
	
	if self.from == "GUILD_MEMBER" or self.from == "GUILD_APPLY" then
		
	 self._view:SetPosition( LORD.UVector2(     LORD.UDim(0,event.rect.right-30)  , LORD.UDim(0, y) )  )
	end
	
	function onClickcontactLayoutCheck(args)
		self:onHide()
		
		local clickImage = LORD.toWindowEventArgs(args).window
 		local userdata = clickImage:GetUserData()
		if(self.id)then
			local rect = clickImage:GetUnclippedOuterRect();
			dataManager.chatData:setClickPosition(LORD.Vector2(rect.right+100, rect.top + 100 ));
			sendAskInspect( self.id);
		end
	end	
	
	
	function onClickcontactLayoutAdd(args)
			self:onHide()
			if(self.id )then
				dataManager.buddyData:applyFriend(self.id)
				eventManager.dispatchEvent({name = global_event.WARNINGHINT_SHOW,tip = "好友申请发送成功"})	
				
			end
	end	
	
	
	function onClickcontactLayoutDel(args)
			self:onHide()
			
			if self.from == "GUILD_MEMBER" then
				
				local player = dataManager.guildData:getPlayerByID(self.id);
				eventManager.dispatchEvent({name = global_event.CONFIRM_SHOW, 
							text = "是否将会长转让给"..player:getName(), callBack = function() 
								
								-- send message
								local property = enum.MEMBER_PROPERTY.MEMBER_PROPERTY_SET_WAR + 
														enum.MEMBER_PROPERTY.MEMBER_PROPERTY_NOTICE + 
														enum.MEMBER_PROPERTY.MEMBER_PROPERTY_ACCEPT_NEWER +
														enum.MEMBER_PROPERTY.MEMBER_PROPERTY_KICK_MEMBERS + 
														enum.MEMBER_PROPERTY.MEMBER_PROPERTY_APPOINT;
																		
								sendAskGuildAppoint(self.id, property);
								
							end});
				

				
				return;
			end
			
			
			local list = dataManager.buddyData:getBuddyList()
			local f = list[self.id]  
			if(f )then
				dataManager.buddyData:setSelBuddyId(f:getId())
				function confirmDelFriend()
					dataManager.buddyData:delFriends(f:getId())	
				end
				eventManager.dispatchEvent( {name = global_event.CONFIRM_SHOW, callBack = confirmDelFriend,text = "您确定要删除好友" ..f:getName().."^FFFFFF吗？" })	   
			 end
	end	
	
	
	function onClickcontactLayoutChat(args)
		self:onHide()
		local clickImage = LORD.toWindowEventArgs(args).window
 		local userdata = clickImage:GetUserData()
		if(self.id )then
			eventManager.dispatchEvent( {name = global_event.CHATROOM_PRIVET_CHAT,id = self.id,playeInfo = self.PlayeInfo})
		end
	end	
	
	
	function onClickcontactLayoutPk(args)
	
		 	self:onHide()	

			if self.from == "GUILD_MEMBER" then

  			local player = dataManager.guildData:getPlayerByID(self.id);
				if player:isMember() then

					local property = enum.MEMBER_PROPERTY.MEMBER_PROPERTY_SET_WAR + 
										enum.MEMBER_PROPERTY.MEMBER_PROPERTY_NOTICE + 
										enum.MEMBER_PROPERTY.MEMBER_PROPERTY_ACCEPT_NEWER +
										enum.MEMBER_PROPERTY.MEMBER_PROPERTY_KICK_MEMBERS;
															
					sendAskGuildAppoint(self.id, property);
					
				else
					
					sendAskGuildAppoint(self.id, enum.MEMBER_PROPERTY.MEMBER_PROPERTY_NULL);
					
				end
														
				return;
			end
			
			
			local clickImage = LORD.toWindowEventArgs(args).window
			local rect = clickImage:GetUnclippedOuterRect();
			dataManager.chatData:setClickPosition(LORD.Vector2(rect.right+100, rect.top + 100 ));
			dataManager.buddyData:setAskPkPlayerDetail(true)	
			dataManager.buddyData:setPkPlayer(self.id)	
			-----sendAskInspect( self.id);
			dataManager.buddyData:askPkInfo(self.id)
			
	end	
	
	function onClickcontactLayoutGuild(args)
		
		self:onHide();
		
		dataManager.guildData:onHandleKickPlayer(self.id);
		
	end
	
	local contactLayout_guild = self:Child("contactLayout-guild");
	contactLayout_guild:subscribeEvent("ButtonClick", "onClickcontactLayoutGuild"); 	
	
	self.contactLayout_check:subscribeEvent("ButtonClick", "onClickcontactLayoutCheck"); 	
	self.contactLayout_add:subscribeEvent("ButtonClick", "onClickcontactLayoutAdd"); 	
	self.contactLayout_del:subscribeEvent("ButtonClick", "onClickcontactLayoutDel"); 	
	self.contactLayout_whisper:subscribeEvent("ButtonClick", "onClickcontactLayoutChat"); 	
	self.contactLayout_pk:subscribeEvent("ButtonClick", "onClickcontactLayoutPk"); 	
	self:update()
end


function contactLayout:update()
	
	if not self._show then
		return;
	end
	
	
	self.contactLayout_check_dw:SetVisible(false)
	self.contactLayout_whisper_dw:SetVisible(false)
	self.contactLayout_add_dw:SetVisible(false)
 	
 	local contactLayout_guild_dw = self:Child("contactLayout-guild-dw");
	contactLayout_guild_dw:SetVisible(false);
	
	self.contactLayout_pk_dw:SetVisible(dataManager.buddyData:isBuddy(self.id))
	self.contactLayout_del_dw:SetVisible(dataManager.buddyData:isBuddy(self.id))
	self.list = nil
	
	self.PlayeInfo = {}
	if(self.from == "BUDDY" )then
			self.list = dataManager.buddyData:getBuddyList()
			local friend = self.list[self.id ]
			self.contactLayout_check_dw:SetVisible(true)
			self.contactLayout_whisper_dw:SetVisible(true)
			
			self.PlayeInfo.name = friend:getName()
			self.PlayeInfo.level = friend:getLevel()
			self.PlayeInfo.icon = friend:getHeadIcon()
			
	
	elseif(self.from == "BUDDY_RECOMMEND_LIST" )then
			self.list = dataManager.buddyData:getRecommend()
			local recommend = self.list[self.id ]
	
			self.contactLayout_check_dw:SetVisible(true)
			self.contactLayout_whisper_dw:SetVisible(true)
			
			self.PlayeInfo.name = recommend:getName()
			self.PlayeInfo.level = recommend:getLevel()
			self.PlayeInfo.icon = recommend:getHeadIcon()
	
	elseif(self.from == "BUDDY_SERACH_LIST" )then
	
			self.list = dataManager.buddyData:getSearchFriendList()
			local search = self.list[self.id ]
			self.contactLayout_check_dw:SetVisible(true)
			self.contactLayout_whisper_dw:SetVisible(true)
			
			self.PlayeInfo.name = search.name
			self.PlayeInfo.level = search.level
			self.PlayeInfo.icon = search.headicon
			
	elseif(self.from == "BUDDY_APPLY" )then
			self.list = dataManager.buddyData:getApplicants()
			local apply = self.list[self.id ]
			self.contactLayout_check_dw:SetVisible(true)
			self.contactLayout_whisper_dw:SetVisible(true)
			if(apply)then
				self.PlayeInfo.name = apply.nickname
				self.PlayeInfo.level = apply.level
				self.PlayeInfo.icon = apply.headID
			end
			
	elseif(self.from == "CHAT_MSG" )then
			 
			self.contactLayout_check_dw:SetVisible(true)
			self.contactLayout_whisper_dw:SetVisible(true)
			
			self.PlayeInfo.name = self.userdate:getTalker()
			self.PlayeInfo.level = self.userdate:getLevel()
			self.PlayeInfo.icon = self.userdate:getIcon()
			
			self.contactLayout_add_dw:SetVisible(not dataManager.buddyData:isBuddy(self.id))
  
  elseif self.from == "GUILD_MEMBER" then

		self.contactLayout_check_dw:SetVisible(true)
		self.contactLayout_whisper_dw:SetVisible(true)
		self.contactLayout_add_dw:SetVisible(not dataManager.buddyData:isBuddy(self.id));

		-- pk 降为会员或升为长老
		self.contactLayout_pk_dw:SetVisible(dataManager.guildData:isMyselfPrecident())
		local contactLayout_pk = self:Child( "contactLayout-pk" );
		
		
		-- del 升为会长
		self.contactLayout_del_dw:SetVisible(dataManager.guildData:isMyselfPrecident());
		local contactLayout_del = self:Child( "contactLayout-del" );
		contactLayout_del:SetText("升为会长");
		
  	local player = dataManager.guildData:getPlayerByID(self.id);
		
		
		if player:isMember() then
			contactLayout_pk:SetText("升为长老");
		else
			contactLayout_pk:SetText("降为会员");
		end
		
		self.PlayeInfo.name = player:getName();
		self.PlayeInfo.level = player:getLevel();
		self.PlayeInfo.icon = player:getHeadIcon();
		  	
  	if dataManager.guildData:isMyselfPrecident() or
  	   (dataManager.guildData:isMyselfElders() and player and player:isMember()) then
  		
  		contactLayout_guild_dw:SetVisible(true);
  	else
  		contactLayout_guild_dw:SetVisible(false);
  	end
  	
  elseif self.from == "GUILD_APPLY" then
  
		self.contactLayout_check_dw:SetVisible(true)
		self.contactLayout_whisper_dw:SetVisible(true)
		self.contactLayout_add_dw:SetVisible(not dataManager.buddyData:isBuddy(self.id));
		self.contactLayout_pk_dw:SetVisible(false)
		self.contactLayout_del_dw:SetVisible(false);

		local player = dataManager.guildData:getApplyPlayerByID(self.id);
		
		self.PlayeInfo.name = player:getName();
		self.PlayeInfo.level = player:getLevel();
		self.PlayeInfo.icon = player:getHeadIcon();
				
	end
 
	
	
	
	 
	local view = LORD.toLayout(self._view)
	view:LayoutChild()
end	





function contactLayout:onHide(event)
	self:Close();
end

return contactLayout;
