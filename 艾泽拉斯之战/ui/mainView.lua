

global_event.MAIN_UI_SHOW = "MAIN_UI_SHOW"
global_event.MAIN_UI_CLOSE= "MAIN_UI_CLOSE"
global_event.MAIN_UI_DAILY_REWARD_STATE = "MAIN_UI_DAILY_REWARD_STATE"
global_event.MAIN_UI_ACTIVITY_STATE = "MAIN_UI_ACTIVITY_STATE"
global_event.MAIN_UI_MAIL_STATE = "MAIN_UI_MAIL_STATE"
global_event.MAIN_UI_TUJIAN_STATE = "MAIN_UI_TUJIAN_STATE"
global_event.MAIN_UI_VIGOR_DELTA = "MAIN_UI_VIGOR_DELTA"
global_event.MAIN_UI_FULI_STATE = "MAIN_UI_FULI_STATE"
global_event.MAIN_UI_GUILD_STATE = "MAIN_UI_GUILD_STATE"

local mainViewclass = class("mainViewclass",layout)
local MAX_MSG_NUM = 4
local MAX_MSG_TEXTSIZE = 24
local MAX_MSG_SHOWTIME = 30
local MAX_MSG_FADETIME = 3

function mainViewclass:ctor( id )
	 mainViewclass.super.ctor(self,id)	
	 self:addEvent({ name = global_event.MAIN_UI_SHOW, eventHandler = self.onSHOW})	
	 self:addEvent({ name = global_event.MAIN_UI_CLOSE, eventHandler = self.onHide})	
 	 self:addEvent({ name = global_event.PLAYER_ATTR_SYNC, eventHandler = self.onUpdateKingData})
	 self:addEvent({ name = global_event.MAIN_UI_DAILY_REWARD_STATE, eventHandler = self.updateDailyTaskState})
	 self:addEvent({ name = global_event.MAIN_UI_ACTIVITY_STATE, eventHandler = self.updateActivityState})
	 self:addEvent({ name = global_event.MAIN_UI_MAIL_STATE, eventHandler = self.updateMailState})
	 self:addEvent({ name = global_event.MAIN_UI_TUJIAN_STATE, eventHandler = self.updateTuJianState})
	 self:addEvent({ name = global_event.CHATROOM_RECV_ONE_RECORD, eventHandler = self.onMainViewNewChat})
	 self:addEvent({ name = global_event.FRIEND_UPDATE, eventHandler = self.onFriendUpdate})
	 self:addEvent({ name = global_event.MAIN_UI_VIGOR_DELTA, eventHandler = self.onVigorDelta})
	 self:addEvent({ name = global_event.MAIN_UI_FULI_STATE, eventHandler = self.onUpateFuliState})
	 self:addEvent({ name = global_event.MAIN_UI_GUILD_STATE, eventHandler = self.onUpdateGuildState})
	 self.msgTimeHandle = nil	
end	

function mainViewclass:getMsgData()

	local msgData = {};
	local saveData = self:getSaveConfig();
	
	if saveData and type(saveData) == "table" and #saveData == MAX_MSG_NUM then
		msgData = clone(saveData);
	end
	
	return msgData;
end
				 
 function mainViewclass:createMsgsWnd()
	self.msgs = {}
	
	-- 保存在layout的saveconfig 里，这样保证关了界面，还可以看到
	local msgData = {};
	
	local height = 0
	for i = 1,MAX_MSG_NUM do
		self.msgs[i]	= LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("mainView_"..i, "chatItem.dlg");
		self.msgs[i]:SetUserData(i)
		msgData[i] = {}
		msgData[i].ShowTime = 0 
		msgData[i].free = true
		msgData[i].alapha = 0
		msgData[i].fade = false
		msgData[i].text = ""
		local pos =    LORD.UVector2(LORD.UDim(0, 10),LORD.UDim(0, 10 + height* (i -1) + (i-1)*12  ))
		self.msgs[i]:SetPosition( pos )
		height = self.msgs[i]:GetPixelSize().y
		--self.msgs[i]:SetText(i)
		self.maincontrol_chatInfo:AddChildWindow(self.msgs[i])
	end
	
	-- save config
	local saveData = self:getSaveConfig();
	--print("saveData  ")
	--dump(saveData);
	-- 如果数据格式正确的话，就把它作为数据，没有的话，就用上面的初始化数据
	if saveData and type(saveData) == "table" and #saveData == MAX_MSG_NUM then
		msgData = self:getMsgData();
	end
	
	self:setSaveConfig(msgData);
	
	function mainViewclass_msg_timeTick(dt)
		   if not self._show then
		   end
		   
		   local msgData = self:getMsgData();
			   
			 for i,v in ipairs (msgData)do
				 
					if(v.free == false)then
						v.ShowTime = v.ShowTime + dt
						if(v.fade == true)then
							v.alapha =   v.fadeAlapha - v.ShowTime/MAX_MSG_FADETIME * v.fadeAlapha						 
							
							if(v.alapha < 0)then
								v.alapha = 0
							end
							if(v.ShowTime >= MAX_MSG_FADETIME)then
								v.free = true
								v.alapha = 0
							end
						else
							if(v.ShowTime >= MAX_MSG_SHOWTIME )then
								v.ShowTime = 0
								v.fade = true
								v.fadeAlapha = 1
							end
						end
					else
							v.alapha = 0
					end
				 
			  end
			  
				for i,v in ipairs (self.msgs)do
					local d = msgData[i]
					v:SetAlpha(d.alapha)
					v:SetText(d.text)
					v:SetVisible(d.free == false)
					 
				end
		 
				self:setSaveConfig(msgData);
	end	
		
		
	if(self.msgTimeHandle == nil	) then
		self.msgTimeHandle = scheduler.scheduleGlobal(mainViewclass_msg_timeTick,0)	
	end
	
end
function mainViewclass:onSHOW(event)

	if self._show then
		return;
	end
	
	self:Show();
	
	
	-- 主界面打开的时候请求一次邮件数量
	--sendaskMailCount();
	
	dataManager.guildData:onAskServerGuildApplysInfo();
	
	self.vigorRefreshTick = -1;
		
	function onTouchDownMainVigor(args)
		local window = LORD.toWindowEventArgs(args).window;
		local rect = window:GetUnclippedOuterRect();
		eventManager.dispatchEvent({name = "SKILL_TIPS_SHOW", tipsType = "time", id = -1, tipXPosition = rect.left, tipYPosition = rect.top, dir = "left"});
	end
	
	function onTouchUpMainVigor()
		eventManager.dispatchEvent({name = "SKILL_TIPS_HIDE"});
	end
	
	function vigorRefreshTickFunction()
		self:refreshVigor();
	end
	
	function onClickRountine()
		
		local levelLimit = dataConfig.configs.ConfigConfig[0].dailyButtonLevelLimit;
		if dataManager.playerData:getLevel() < levelLimit then
			
			eventManager.dispatchEvent({name = global_event.NOTICE_SHOW, 
				messageType = enum.MESSAGE_BOX_TYPE.COMMON, 
				textInfo = levelLimit.."级开启任务系统"});
			return;
		end
		
		eventManager.dispatchEvent({name = "TASK_SHOW"});
	end
	
	function onClickFirstCharge()
		eventManager.dispatchEvent({name = "FIRSTCHARGE_SHOW"});
	end
	function onClickMainBug()
		 eventManager.dispatchEvent({name = "BUG_SHOW"});
 
	end
	
	function onClickMainGuild()
		
		guildData:onHandleClickGuildButton();
		
	end
	
	local maincontrol_gonghui = self:Child("maincontrol-gonghui");
	maincontrol_gonghui:subscribeEvent("ButtonClick", "onClickMainGuild");
	
	self.maincontrol_tili_delta = self:Child("maincontrol-tili-delta");
	self.maincontrol_jinbi_num = self:Child("maincontrol-jinbi-num");
	self.maincontrol_mucai_num = self:Child("maincontrol-mucai-num");
	self.maincontrol_zuanshi_num = self:Child("maincontrol-zuanshi-num");
	self.maincontrol_tili = self:Child("maincontrol-tili");
	self.maincontrol_expbar = self:Child("maincontrol-expbar");
	self.maincontrol_gmedit_dian = self:Child("maincontrol-gmedit-dian");
 
	self.maincontrol_gmedit_dian:SetVisible(  dataManager.chatData:hasPriveChatNewMsg())
	function onMainFuli(args)
		
		--[[
		if self.displayFuliObject then
			self.displayFuliObject:endPlay();
			
			self.displayFuliObject = nil;
		end
		
		self.displayFuliObject = displayFuli.new();
		
		self.displayFuliObject:setCameraParams(LORD.Vector3(homeland.buildCameraPosition[enum.HOMELAND_BUILD_TYPE.CARD].pos.x, homeland.buildCameraPosition[enum.HOMELAND_BUILD_TYPE.CARD].pos.y, homeland.buildCameraPosition[enum.HOMELAND_BUILD_TYPE.CARD].pos.z), LORD.Vector3(homeland.buildCameraPosition[enum.HOMELAND_BUILD_TYPE.CARD].dir.x, homeland.buildCameraPosition[enum.HOMELAND_BUILD_TYPE.CARD].dir.y, homeland.buildCameraPosition[enum.HOMELAND_BUILD_TYPE.CARD].dir.z));
																						
		self.displayFuliObject:setActorParams("cirijiangli.actor", "skill", LORD.Vector3(homeland.buildActors.pos[enum.HOMELAND_BUILD_TYPE.CARD].x, homeland.buildActors.pos[enum.HOMELAND_BUILD_TYPE.CARD].y+1.5 , homeland.buildActors.pos[enum.HOMELAND_BUILD_TYPE.CARD].z), LORD.Quaternion(1, 0, 0.4, -0.1), 4);
		
		self.displayFuliObject:setDarkParam(0.2);
		
		self.displayFuliObject:start();
		--]]
		
		eventManager.dispatchEvent({name = global_event.ACTIVITYS_SHOW,});
				
	end
	
	self.maincontrol_encourage = self:Child("maincontrol-encourage");
	self.maincontrol_encourage:subscribeEvent("ButtonClick", "onMainFuli");
	self.displayFuliObject = nil;
	
	function _onMainVigorTips(args)
	  local clickImage = LORD.toWindowEventArgs(args).window;
		local rect = clickImage:GetUnclippedOuterRect();
		
		eventManager.dispatchEvent({name = "SKILL_TIPS_SHOW", tipsType = "time", id = userdata, 
				windowRect = rect, dir = "right", offsetX = 0, offsetY = 0, });

	end
	
	function onMainViewUserCenter()
		local shellInterface = GameClient.CGame:Instance():getShellInterface();
		if shellInterface then
			shellInterface:enterUserCenter();
		end
	end
	
	self.maincontrol_gongneng_control = self:Child("maincontrol-gongneng1-control");
	self.maincontrol_gongneng_control:subscribeEvent("ButtonClick", "onMainViewUserCenter");

	local shellInterface = GameClient.CGame:Instance():getShellInterface();
	if shellInterface and shellInterface:getPlatformID() == "25pp" then
		self.maincontrol_gongneng_control:SetVisible(true);
	else
		self.maincontrol_gongneng_control:SetVisible(false);
	end
			
	self.maincontrol_tili:removeEvent("WindowTouchDown");
	self.maincontrol_tili:subscribeEvent("WindowTouchDown", "_onMainVigorTips");

	global.onTipsHide(self.maincontrol_tili);
	
	self.maincontrol_tili_num = self:Child("maincontrol-tili-num");
	--self.maincontrol_name = self:Child("maincontrol-name");	
	self.maincontrol_VIP_num = self:Child("maincontrol-VIP-num");	
	self.maincontrol_lv_1 = self:Child("maincontrol-lv_1");	
	
	self.maincontrol_touxiang_tu =  LORD.toStaticImage(self:Child("maincontrol-touxiang-tu"));	


	self.maincontrol_cangku = self:Child("maincontrol-cangku")
	self.maincontrol_cangku:subscribeEvent("ButtonClick", "onClickPack")
	
	self.maincontrol_bingzhong = self:Child("maincontrol-bingzhong");
	self.maincontrol_bingzhong_dian = self:Child("maincontrol-bingzhong-dian");
	
	self.maincontrol_zuanshi_jiahao = self:Child("maincontrol-zuanshi-jiahao");
	self.maincontrol_jinbi_jiahao = self:Child("maincontrol-jinbi-jiahao");
	self.maincontrol_mucai_jiahao = self:Child("maincontrol-mucai-jiahao");
	self.maincontrol_tili_jiahao = self:Child("maincontrol-tili-jiahao");
	
	self.maincontrol_zuanshi_jiahao:subscribeEvent("ButtonClick", "onClickBuyDiamond");
	
	self.maincontrol_jinbi_jiahao:subscribeEvent("ButtonClick", "onClickDiamondBuy");
	self.maincontrol_jinbi_jiahao:SetUserData(enum.BUY_RESOURCE_TYPE.GOLD);
	
	self.maincontrol_mucai_jiahao:subscribeEvent("ButtonClick", "onClickDiamondBuy");
	self.maincontrol_mucai_jiahao:SetUserData(enum.BUY_RESOURCE_TYPE.WOOD);
	
	self.maincontrol_tili_jiahao:subscribeEvent("ButtonClick", "onClickDiamondBuy");
	self.maincontrol_tili_jiahao:SetUserData(enum.BUY_RESOURCE_TYPE.VIGOR);
	
	--self.maincontrol_meiri = self:Child( "maincontrol-meiri" );
	--self.maincontrol_meiri:subscribeEvent("ButtonClick", "onClickMainDrawCard");
	
	self.maincontrol_gmedit_ok = self:Child( "maincontrol-gmedit-ok" );
	self.maincontrol_gmedit_ok:subscribeEvent("ButtonClick", "onClickGMOK");
	
	self.maincontrol_qiandao = self:Child( "maincontrol-qiandao" );
	self.maincontrol_qiandao:subscribeEvent("ButtonClick", "onClickRountine");
	self.maincontrol_qiandao_dian = LORD.toStaticImage(self:Child("maincontrol-qiandao-dian"));
	self.maincontrol_huodong_dian = LORD.toStaticImage(self:Child("maincontrol-huodong-dian"));
	self.maincontrol_youjian_dian = LORD.toStaticImage(self:Child("maincontrol-youjian-dian"));
	
	self.maincontrol_firstcharge = self:Child("maincontrol-firstcharge");
	self.maincontrol_firstcharge:subscribeEvent("ButtonClick", "onClickFirstCharge");
	self.maincontrol_firstcharge_dian = self:Child("maincontrol-firstcharge-dian");
	
	
	self.maincontrol_bug = self:Child("maincontrol-bug");
	self.maincontrol_bug:subscribeEvent("ButtonClick", "onClickMainBug");

	
	self.vigorRefreshTick = scheduler.scheduleGlobal(vigorRefreshTickFunction, 1);
	self.maincontrol_chatInfo = self:Child("maincontrol-chatInfo");
	self.maincontrol_chatInfo:SetText("");
	self:createMsgsWnd()
	self.maincontrol_chatInfoBack = self:Child("maincontrol-chatInfoBack");
	
	self.maincontrol_encourage_dian = self:Child("maincontrol-encourage-dian");
	self.maincontrol_encourage_dian_effect1 = self:Child("maincontrol-encourage-dian-effect1");
	
	function onClickGMOK()
		--[[
		local text = self:Child("maincontrol-gmedit"):GetText();
	

		if text ~= "" then
			local temp = string.find( text,"!!!")
			if( temp~= nil)then
				local file = string.gsub( text,"!!!","")
				return 		BUG_REPORT.replayBattle(file)	
			end
			sendGm(text);
			
		end
		--]]
		if(self.maincontrol_gmedit_dian)then
			self.maincontrol_gmedit_dian:SetVisible(false)
		end
		eventManager.dispatchEvent({name = global_event.CHATROOM_SHOW});
		
		--[[
		if dataManager.playerData:getLevel() >= 10 then
			eventManager.dispatchEvent({name = global_event.CHATROOM_SHOW});
		else
			eventManager.dispatchEvent({name = global_event.NOTICE_SHOW, 
				messageType = enum.MESSAGE_BOX_TYPE.COMMON, 
				textInfo = "10级开启聊天"});
					
		end
		--]]
		
	end
	
	function onClickPack()	
		 eventManager.dispatchEvent({name = global_event.PACK_SHOW});		
		--eventManager.dispatchEvent({name = global_event.ANNOUNCEMENT_SHOW });
		 
		--eventManager.dispatchEvent({name = global_event.NOTICE_GUIDETIP_SHOW,newUi = 1,tip = ""});		
	end
	
	self.maincontrol_mail = self:Child("maincontrol-youjian")
	self.maincontrol_mail:subscribeEvent("ButtonClick", "onClickMail")
	
	function onClickBuyDiamond()
		eventManager.dispatchEvent({name = global_event.PURCHASE_SHOW});
	end
	
	function onClickDiamondBuy(args)
		local window = LORD.toWindowEventArgs(args).window;
		local moneyType = window:GetUserData();
		self:onDiamondBuy(moneyType);
	end
	
	function onClickMail()	
			
		sendaskMaillList()
		eventManager.dispatchEvent({name = global_event.MAILBOX_SHOW});		
	end

	self.maincontrol_bingzhong:subscribeEvent("ButtonClick", "onClickMainTuJian");
	function onClickMainTuJian()
		eventManager.dispatchEvent({name = global_event.CROPSINFOR_SHOW});
	end
	
	function onClickQuest()
		reload("gm.lua")	
	 	
	end

	self.maincontrol_renwu = self:Child("maincontrol-renwu");
	self.maincontrol_renwu:subscribeEvent("ButtonClick", "onClickQuest");	
	
	
	function onClickFriend()	
		eventManager.dispatchEvent({name = global_event.SOCIALNETWORK_SHOW});
		self:onFriendUpdate()		
	 
		--eventManager.dispatchEvent({name = global_event.REDENVELOPE_SHOW});
		
		--eventManager.dispatchEvent({name = global_event.BUG_SHOW});
		 
	 
	end
	self.maincontrol_friend_tips = self:Child("maincontrol-friend-tips");
	self.maincontrol_friend_tips:SetVisible(false)
	self.maincontrol_friend = self:Child("maincontrol-friend");
	self.maincontrol_friend:subscribeEvent("ButtonClick", "onClickFriend");	
	
	function onClickMainUnit()
		--eventManager.dispatchEvent({name = global_event.ACTIVITY_SHOW});

		local level = dataManager.playerData:getAdventureNormalProcess()
		
		if(level < dataConfig.configs.ConfigConfig[0].shipProcessLimit)then
			eventManager.dispatchEvent({name = global_event.NOTICE_SHOW, 
						messageType = enum.MESSAGE_BOX_TYPE.COMMON, data = "", 
						--textInfo = dataConfig.configs.ConfigConfig[0].shipProcessLimit.."级开启"..enum.HOMELAND_BUILD_NAME[enum.HOMELAND_BUILD_TYPE.SHIP] });
						textInfo = "通关1-1开启军团"});
			return 		
		end

		
		eventManager.dispatchEvent({name = global_event.ROLE_EQUIP_SHOW, ship = 1});
	end
	
	self.maincontrol_huodong = self:Child("maincontrol-huodong");
	self.maincontrol_huodong:subscribeEvent("ButtonClick", "onClickMainUnit");	
	
	function onTouchDownMainViewclassPlayerName()
		eventManager.dispatchEvent({name = global_event.PLAYERINFO_SHOW});
	end
	--self.maincontrol_name:subscribeEvent("WindowTouchDown", "onTouchDownMainViewclassPlayerName");	
	self.maincontrol_touxiang_tu:subscribeEvent("WindowTouchUp", "onTouchDownMainViewclassPlayerName");	
	
	self:upDataView()	
	eventManager.dispatchEvent({name = global_event.GUIDE_ON_ENTER_MAIN_UI})
				
end

function mainViewclass:updateDailyTaskState()
	
	print("updateDailyTaskState");
	if self._show then
		local playerData = dataManager.playerData;
		self.maincontrol_qiandao_dian:SetVisible(playerData:isHaveCanGainedReward());
	end
end

-- 更新活动状态
function mainViewclass:updateActivityState()
	if self._show then
		--local playerData = dataManager.playerData;
		self.maincontrol_huodong_dian:SetVisible(global:HasNewNoticeWithEquip());
	end
end

-- 更新邮件状态
function mainViewclass:updateMailState()
	if self._show then
		self.maincontrol_youjian_dian:SetVisible(dataManager.mailData:isHaveUnreadMail());
	end
end

-- 更新图鉴状态
function mainViewclass:updateTuJianState()
	
	if self._show then
		self.maincontrol_bingzhong_dian:SetVisible(cardData.isHaveNewGained());
	end
	
end


function mainViewclass:updateFirstChargeState()
	local playerData = dataManager.playerData;
	self.maincontrol_firstcharge_dian:SetVisible(playerData:hasFinishedFirstCharge());
	if playerData:hasGainedFirstCharge() then
		self.maincontrol_firstcharge:SetVisible(false);
	else
		self.maincontrol_firstcharge:SetVisible(true);
	end

end

function mainViewclass:onHide(event)
	
	self.maincontrol_tili_delta = nil;
		
	if self.vigorRefreshTick and self.vigorRefreshTick > 0 then
		scheduler.unscheduleGlobal(self.vigorRefreshTick);
		self.vigorRefreshTick = -1;
	end
 
	
	if(self.msgTimeHandle ~= nil)then
		scheduler.unscheduleGlobal(self.msgTimeHandle)
		self.msgTimeHandle = nil
	end	
	self.maincontrol_chatInfo = nil;
	
	self:Close();	
end

function mainViewclass:refreshVigor()
	local isOverflow = dataManager.playerData:getVitality() >= dataManager.playerData:getVigorMax();
	if isOverflow then
		self.maincontrol_tili_num:SetText( "^FFC124"..dataManager.playerData:getVitality().."^FFFFFF/"..dataManager.playerData:getVigorMax() )	
	else
		self.maincontrol_tili_num:SetText( dataManager.playerData:getVitality().."/"..dataManager.playerData:getVigorMax() )	
	end
end

function mainViewclass:upDataView()
	if(self._show ~= true)then
			return 
	end
	self:onFriendUpdate()
	local maincontrol_touxiang = LORD.toStaticImage(self:Child("maincontrol-touxiang"));
	local maincontrol_vip_image1 = LORD.toStaticImage(self:Child("maincontrol-vip-image1"));
	local maincontrol_vip_image2 = LORD.toStaticImage(self:Child("maincontrol-vip-image2"));
	
	if dataManager.playerData:getVipLevel() > 0 then
		maincontrol_touxiang:SetImage("set:maincontrol.xml image:VIP-icon-container");
		maincontrol_vip_image1:SetVisible(true);
		maincontrol_vip_image2:SetVisible(true);
	else
		maincontrol_touxiang:SetImage("set:maincontrol.xml image:iconinfor");
		maincontrol_vip_image1:SetVisible(false);
		maincontrol_vip_image1:SetVisible(false);
	end
	
	self:onUpdateGuildState();
	self:onUpateFuliState();
	self:updateTuJianState();
	self:updateMailState();
	self:updateActivityState();
	self:updateDailyTaskState();
	self:updateFirstChargeState();
	
	self.maincontrol_jinbi_num:SetText( dataManager.playerData:getGold() )
	self.maincontrol_mucai_num:SetText( dataManager.playerData:getWood() )
	self.maincontrol_zuanshi_num:SetText( dataManager.playerData:getGem() )

	self:refreshVigor();
	
	--self.maincontrol_name:SetText(dataManager.playerData:getName() )	
	self.maincontrol_VIP_num:SetText(dataManager.playerData:getVipLevel() )	
	self.maincontrol_lv_1:SetText(dataManager.playerData:getLevel() )	
	
	local percent = dataManager.playerData:getExp() / dataManager.playerData:getLevelupExp();
	self.maincontrol_expbar:SetProperty("Progress", percent);
	
	self.maincontrol_touxiang_tu:SetImage(global.getHeadIcon( dataManager.playerData:getHeadIcon())) 		
	
	--self.maincontrol_qiandao:SetVisible(dataManager.playerData:getLevel() >= dataConfig.configs.ConfigConfig[0].dailyButtonLevelLimit);
	
	
	
end



function mainViewclass:onFriendUpdate(event)
	if(self.maincontrol_friend_tips)then
		self.maincontrol_friend_tips:SetVisible(dataManager.buddyData:calcFrinedHasTips() or  dataManager.buddyData:hasNewFriend())
	end
end
function mainViewclass:onUpdateKingData(event)
	self:upDataView()

end

function mainViewclass:onDiamondBuy(mType)
	--eventManager.dispatchEvent({name = global_event.NOTICE_SHOW, dialogType = "diamondBuy", moneyType = mType, });
	eventManager.dispatchEvent({name = global_event.BUYRESOURCE_SHOW, source = "userclick", resType = mType, copyType = -1, copyID = -1, });
end

function mainViewclass:onMainViewNewChat(event)
	
	if(self.maincontrol_gmedit_dian)then
		if(event.record:getChannel() ==  enum.CHANNEL.CHANNEL_FRIEND )then
			local layout1 = layoutManager.getUI("chatRoom")
			if(  layout1:isShow() )then
				self.maincontrol_gmedit_dian:SetVisible(false)
			else
				self.maincontrol_gmedit_dian:SetVisible(  dataManager.chatData:hasPriveChatNewMsg())
			end
		end
	end
	
	--[[
		local text = event.record:getContent();
		local nameColor = "^AF15AF";
		local textColer = "^FFFFFF";
		self.maincontrol_chatInfo:SetText(nameColor..event.record:getTalker().."："..textColer..text);
		]]--
		--[[
	local nameColor = ""--"^AF15AF";
	local textColer = ""--"^FFFFFF";
	local msgs = dataManager.chatData:getLastWorldRecord(MAX_MSG_NUM) 
	
	for i , v in ipairs(msgs) do
		if(v)then
			local text =  v:getContent()
			text = math.getStrWithByteSize( text,MAX_MSG_TEXTSIZE).."..."
			self.msgs[MAX_MSG_NUM - i + 1 ]:SetText(nameColor..v:getTalker().."："..textColer..text);
		end
	end
	]]--
	
	local nameColor =  "^AF15AF";
	local textColer =  "^FFFFFF";
	
	local text = event.record:getContent();
	
	local msgData = self:getMsgData();
	
	local tempdata = clone(msgData);
	
	local nums = #msgData	
	for i = nums , 2, - 1  do
		
		if(msgData[i].free == false )then
			msgData[i-1].ShowTime = tempdata[i].ShowTime
			msgData[i-1].free = tempdata[i].free
			msgData[i-1].alapha = tempdata[i].alapha 
			msgData[i-1].fade = tempdata[i].fade
			msgData[i-1].fadeAlapha = tempdata[i-1].alapha
			msgData[i-1].text = tempdata[i].text
		end
	end
	
	dump(msgData);
	print("MAX_MSG_NUM "..MAX_MSG_NUM);
	
	msgData[MAX_MSG_NUM].ShowTime = 0 --s	  正常显示时间
	msgData[MAX_MSG_NUM].free = false --s	
	msgData[MAX_MSG_NUM].alapha = 1 --s	
	msgData[MAX_MSG_NUM].fade = false
	msgData[MAX_MSG_NUM].fadeAlapha = 1
	
	local oldtext = event.record:getContent() 
    --[[
	local textnum =  math.getStrByte(oldtext)
	local colorByte = math.getStrByte("^FFFFFF")
	
		if textnum > MAX_MSG_TEXTSIZE then 
			local pos= 0
			local nNum = 0
			for st,sp in function() return string.find(oldtext, "^", pos, true) end do
				
				 if(sp >= MAX_MSG_TEXTSIZE + nNum * colorByte) then
					break
				 end
				 nNum = nNum + 1	
				 pos = sp + 1
			end
			if(nNum%2 ~= 0)then
				nNum = nNum + 1
			end	
			
			text = math.getStrWithByteSize(oldtext,MAX_MSG_TEXTSIZE + nNum * colorByte   ) 
			msgData[MAX_MSG_NUM].text = (nameColor..event.record:getTalker().."："..textColer..text.."^FFFFFF".."...");
		 
	    else 
			msgData[MAX_MSG_NUM].text = (nameColor..event.record:getTalker().."："..textColer..oldtext);
	    end
		]]----
		
		local textnum =   getStrByteSizeNoColor(oldtext)
		if textnum > MAX_MSG_TEXTSIZE then 
			oldtext = getStrWithByteSizeNoColor(oldtext,MAX_MSG_TEXTSIZE).."^FFFFFF".."..."
		end
		
		
		msgData[MAX_MSG_NUM].text = (nameColor..event.record:getTalker().."："..oldtext);
 
	self:setSaveConfig(msgData);
	
	if self._show then
		local action = LORD.GUIAction:new();
		action:addKeyFrame(LORD.Vector3(0, 10, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1), 1, 0);
		action:addKeyFrame(LORD.Vector3(0, -20, 0), LORD.Vector3(0, 0, 0), LORD.Vector3(1, 1, 1),1, 300);
		self.msgs[MAX_MSG_NUM]:playAction(action);
	end
	
end

 

function mainViewclass:onVigorDelta(event)
	if self._show then
		self.maincontrol_tili_delta:SetVisible(true);
		self.maincontrol_tili_delta:SetText("+"..event.delta);
		
		scheduler.performWithDelayGlobal(function() 
			if self.maincontrol_tili_delta then
				self.maincontrol_tili_delta:SetVisible(false);
			end
		end, 2)
	end
end

-- 更新福利状态
function mainViewclass:onUpateFuliState(event)
	
	if self._show then

		self.maincontrol_encourage_dian:SetVisible(dataManager.limitedActivity:hasNotifyPoint());
		self.maincontrol_encourage_dian_effect1:SetVisible(dataManager.limitedActivity:hasNotifyPoint());
		self.maincontrol_encourage:SetVisible(dataManager.limitedActivity:shouldShow())
	end
	
end

function mainViewclass:onUpdateGuildState()
	
	local maincontrol_gonghui_tips = self:Child("maincontrol-gonghui-tips");
	if maincontrol_gonghui_tips then
		maincontrol_gonghui_tips:SetVisible(dataManager.guildData:isHaveNotifyState());
	end
end

return mainViewclass