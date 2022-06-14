local guildCreate = class( "guildCreate", layout );

global_event.GUILDCREATE_SHOW = "GUILDCREATE_SHOW";
global_event.GUILDCREATE_HIDE = "GUILDCREATE_HIDE";
global_event.GUILDCREATE_UPDATE = "GUILDCREATE_UPDATE";

function guildCreate:ctor( id )
	guildCreate.super.ctor( self, id );
	self:addEvent({ name = global_event.GUILDCREATE_SHOW, eventHandler = self.onShow});
	self:addEvent({ name = global_event.GUILDCREATE_HIDE, eventHandler = self.onHide});
	self:addEvent({ name = global_event.GUILDCREATE_UPDATE, eventHandler = self.update});
	
end

function guildCreate:onShow(event)
	if self._show then
		return;
	end

	self:Show();
	
	function onGuildCreateClose()
		self:onHide();
	end
	
	function onGuildCreateCreateGuild()
		
		eventManager.dispatchEvent({name = global_event.GUILDAPPLY_SHOW, });

	end
	
	local guildCreate_close = self:Child("guildCreate-close");
	guildCreate_close:subscribeEvent("ButtonClick", "onGuildCreateClose");
	
	local guildCreate_apply = self:Child("guildCreate-apply");
	guildCreate_apply:subscribeEvent("ButtonClick", "onGuildCreateCreateGuild");
	
	-- 先初始化item，后面只是刷新
	local xpos = LORD.UDim(0, 0);
	local ypos = LORD.UDim(0, 0);
	
	local guildCreate_list_sp = self:Child("guildCreate-list-sp");
	
	for i=1, guildData.PLAYER_COUNT_PER_PAGE do
		
		local guildItem = LORD.GUIWindowManager:Instance():CreateWindowFromTemplate("guildCreate"..i, "guildItem.dlg");

		local givemaster = self:Child("guildCreate"..i.."_guildItem-givemaster");
		givemaster:subscribeEvent("ButtonClick", "onGuildCreateClickGiveMaster");
		
		local yesbtn = self:Child("guildCreate"..i.."_guildItem-yes");
		local nobtn = self:Child("guildCreate"..i.."_guildItem-no");

		yesbtn:subscribeEvent("ButtonClick", "onGuildCreateClickAgreeApply");
		nobtn:subscribeEvent("ButtonClick", "onGuildCreateClickRefuseApply");
		
		local applyBtn = self:Child("guildCreate"..i.."_guildItem-apply");
		applyBtn:subscribeEvent("ButtonClick", "onGuildCreateClickApplyGuild");
										
		guildItem:SetXPosition(xpos);
		guildItem:SetYPosition(ypos);
		
		guildCreate_list_sp:AddChildWindow(guildItem);
		
		ypos = ypos + guildItem:GetHeight();
	end
		
	-- 这里只是设置到text上，还没向服务器发送
	function onGuildCreateChangeGuildNotice()
		
		local guildCreate_changenotice = self:Child("guildCreate-changenotice");
		local guildNotice = guildCreate_changenotice:GetText();
		
		if guildNotice ~= "" then
			guildCreate_changenotice:SetText("");
			
			local changenotice_text = self:Child("guildCreate-changenotice-text");
			changenotice_text:SetVisible(false);
			
			local changenotice_yon = self:Child("guildCreate-changenotice-yon");
			changenotice_yon:SetVisible(true);
			
			local guildCreate_mywordtext = self:Child("guildCreate-mywordtext");
			guildCreate_mywordtext:SetText(guildNotice);
			
		end
		
	end
	
	local guildCreate_changenotice = self:Child("guildCreate-changenotice");
	guildCreate_changenotice:subscribeEvent("EditTextInput", "onGuildCreateChangeGuildNotice");
	-- 改公告
	
	function onGuildCreateChangeNotice()
		
		local guildCreate_mywordtext = self:Child("guildCreate-mywordtext");
		local guildNotice = guildCreate_mywordtext:GetText();
		
		dataManager.guildData:onHandleChangeGuildNotice(guildNotice);

		local changenotice_text = self:Child("guildCreate-changenotice-text");
		changenotice_text:SetVisible(true);
		
		local changenotice_yon = self:Child("guildCreate-changenotice-yon");
		changenotice_yon:SetVisible(false);
					
	end
	
	function onGuildCreateCancelChangeNotice()
		
		local text = dataManager.guildData:getNotice();
		
		local guildCreate_mywordtext = self:Child("guildCreate-mywordtext");
		guildCreate_mywordtext:SetText(text);

		local changenotice_text = self:Child("guildCreate-changenotice-text");
		changenotice_text:SetVisible(true);
			
		local changenotice_yon = self:Child("guildCreate-changenotice-yon");
		changenotice_yon:SetVisible(false);
						
	end
	
	local changenotice_yes = self:Child("guildCreate-changenotice-yes");
	local changenotice_no = self:Child("guildCreate-changenotice-no");
	changenotice_yes:subscribeEvent("ButtonClick", "onGuildCreateChangeNotice");
	changenotice_no:subscribeEvent("ButtonClick", "onGuildCreateCancelChangeNotice");
	
	-- 翻页处理
	function onGuildCreatePagePre()
		self:onClickPagePre();
	end
	
	function onGuildCreatePageNext()
		self:onClickPageNext();
	end
	
	local guildCreate_last = self:Child("guildCreate-last");
	local guildCreate_next = self:Child("guildCreate-next");
	
	guildCreate_last:subscribeEvent("ButtonClick", "onGuildCreatePagePre");
	guildCreate_next:subscribeEvent("ButtonClick", "onGuildCreatePageNext");
	
	
	-- 签到奖励
	function onGuildCreateSignIn()
		
		dataManager.guildData:onHandleSignIn();
		
	end
	
	local guildCreate_moneybag = self:Child("guildCreate-moneybag");
	guildCreate_moneybag:subscribeEvent("ButtonClick", "onGuildCreateSignIn");
	
	-- 退出公会
	function onGuildCreateQuitGuild()
		
		dataManager.guildData:onHandleQuitGuild();
		
	end
	
	local guildCreate_quitguild = self:Child("guildCreate-quitguild");
	guildCreate_quitguild:subscribeEvent("ButtonClick", "onGuildCreateQuitGuild");
	
	
	-- 申请列表
	function onGuildCreateApplyList()
		self.isInApplyPage = true;
		
		sendGuildOp(enum.GUILD_OPCODE_TYPE.GUILD_OPCODE_TYPE_APPLYS, 0);
		
		self:update();
	end
	
	
	-- 公会战入口
	function onGuildCreateGuildWar()
		
		dataManager.guildData:onEnterGuildWar();
		
	end
	
	local guildCreate_guilddoor = self:Child("guildCreate-guilddoor");
	guildCreate_guilddoor:subscribeEvent("WindowTouchUp", "onGuildCreateGuildWar");
	
	local guildCreate_applylist = self:Child("guildCreate-applylist");
	guildCreate_applylist:subscribeEvent("ButtonClick", "onGuildCreateApplyList");

	function onGuildCreateQuitApplyList()
		self.isInApplyPage = false;
		self:update();
	end
	
	local guildCreate_quitapplylist = self:Child("guildCreate-quitapplylist");
	guildCreate_quitapplylist:subscribeEvent("ButtonClick", "onGuildCreateQuitApplyList");
		
	-- pageIndex
	self.guildPlayerPage = 1; -- 公会成员的当前页
	self.applyPlayerPage = 1; -- 申请列表的页
	self.guildPage = 1; -- 公会信息的页
	
	-- 一个标志，当切换到申请页的时候设置成true
	self.isInApplyPage = false;
	
	self:update();
	
end

function guildCreate:onHide(event)
	
	self:Close();
	
end

function guildCreate:update()
	
	if not self._show then
		return;
	end
	
	function onGuildCreateRule()
		
		eventManager.dispatchEvent({name = global_event.RULE_SHOW, battleType = enum.BATTLE_TYPE.BATTLE_TYPE_GUILDWAR })
		
	end
	
	-- update common
	-- 一些通用的信息，统一设置
	
	local guildwar_timeon = self:Child("guildCreate-guildwar-timeon");
	local guildwar_time = self:Child("guildCreate-guildwar-time");
	local guildCreate_rule = self:Child("guildCreate-rule");
	
	guildCreate_rule:SetVisible(not dataManager.guildWarData:isActive());
	guildCreate_rule:subscribeEvent("ButtonClick", "onGuildCreateRule");
	
	guildwar_time:SetText(dataConfig.configs.ConfigConfig[0].guildWarBegin.."~"..dataConfig.configs.ConfigConfig[0].guildWarFinish.."开启");
	
	if dataManager.guildWarData:isActive() then
		
		if dataManager.guildWarData:isOpen() then
			
			guildwar_timeon:SetText("公会战进行中");
			
		else
			
			guildwar_timeon:SetText("公会战休战中");
			
		end
		
	else
	
		guildwar_timeon:SetText("开服第4天开启公会战");
		
	end
	
	local text = dataManager.guildData:getNotice();
		
	local guildCreate_mywordtext = self:Child("guildCreate-mywordtext");
	guildCreate_mywordtext:SetText(text);
			
	local guildCreate_myguildname = self:Child("guildCreate-myguildname");
	guildCreate_myguildname:SetText(dataManager.guildData:getName());
	
	local guildCreate_moneynum = self:Child("guildCreate-moneynum");
	guildCreate_moneynum:SetText(dataManager.guildData:getDailyRewardGold());
	
	local guildCreate_moneytip = self:Child("guildCreate-moneytip");
	guildCreate_moneytip:SetVisible(not dataManager.guildData:isAlreadySignIn());
	local guildCreate_moneysended = self:Child("guildCreate-moneysended");
	guildCreate_moneysended:SetVisible(dataManager.guildData:isAlreadySignIn());
	local guildCreate_moneybag = self:Child("guildCreate-moneybag");
	guildCreate_moneybag:SetEnabled(not dataManager.guildData:isAlreadySignIn());
	
	local guildCreate_changenotice = self:Child("guildCreate-changenotice");
	guildCreate_changenotice:SetVisible(dataManager.guildData:isCanChangeNotice());
	
	local guildCreate_quitguild = self:Child("guildCreate-quitguild");
	if dataManager.guildData:isMyselfPrecident() then
		guildCreate_quitguild:SetText("解散公会");
	else
		guildCreate_quitguild:SetText("退出公会");
	end
	
	local guildCreate_applylist = self:Child("guildCreate-applylist");
	local guildCreate_quitapplylist = self:Child("guildCreate-quitapplylist");
	guildCreate_applylist:SetVisible((dataManager.guildData:isMyselfPrecident() or dataManager.guildData:isMyselfElders()) and not self.isInApplyPage);
	guildCreate_quitapplylist:SetVisible((dataManager.guildData:isMyselfPrecident() or dataManager.guildData:isMyselfElders()) and self.isInApplyPage);
	
	local guildCreate_applyNotice = self:Child("guildCreate-applyNotice");
	guildCreate_applyNotice:SetVisible(dataManager.guildData:isHaveApplyedPlayer());
	
	if dataManager.guildData:isHaveGuildMyself() then
		
		if self.isInApplyPage then
			self:updateGuildApplyInfo();
		else
			self:updateGuildInfo();
		end
		
	else
		
		self:updateChooseGuildInfo();
		
	end
		
end

function guildCreate:updateGuildApplyInfo()
	
	if not self._show then
		return;
	end
	
	function onGuildCreateClickRefuseApply(args)
		
		local window = LORD.toWindowEventArgs(args).window;
		local targetID = window:GetUserData();
		
		dataManager.guildData:onHandleRefuseApply(targetID);
		
		self:update();
		
	end
	
	function onGuildCreateClickAgreeApply(args)
		
		local window = LORD.toWindowEventArgs(args).window;
		local targetID = window:GetUserData();
		
		dataManager.guildData:onHandleAgreeApply(targetID);
		
		self:update();
	end

	function onClickGuildCreateApplyItem(args)
	
		local window = LORD.toWindowEventArgs(args).window;
		local targetID = window:GetUserData();
		
		local rect = window:GetUnclippedOuterRect();
		
		dataManager.guildData:onHandleClickApplyPlayerMenu(targetID, rect);
		
	end
		
	local guildCreate_textguild = self:Child("guildCreate-textguild");
	local guildCreate_guildctrl = self:Child("guildCreate-guildctrl");
	local guildCreate_totalnum = self:Child("guildCreate-totalnum");
	local guildCreate_list = self:Child("guildCreate-list");
	local guildCreate_npc = self:Child("guildCreate-npc");
	local guildCreate_texttest = self:Child("guildCreate-texttest");
	local guildCreate_textapply = self:Child("guildCreate-textapply");
	local guildCreate_title_text = self:Child("guildCreate-title-text");
	
	local guildCreate_playername = self:Child("guildCreate-playername");
	
	
	guildCreate_npc:SetVisible(false);
	guildCreate_textguild:SetVisible(false);
	guildCreate_texttest:SetVisible(false);
	guildCreate_textapply:SetVisible(true);
	
	guildCreate_guildctrl:SetVisible(true);
	guildCreate_totalnum:SetVisible(true);
	guildCreate_list:SetXPosition(LORD.UDim(0, 11));
		
	local title_text = self:Child("guildCreate-title-text");
	title_text:SetText("申请列表");

	local guildCreate_spnum = self:Child("guildCreate-spnum");
	guildCreate_spnum:SetText(self.applyPlayerPage.."/"..dataManager.guildData:getTotalApplyPage());

	local applyListData = dataManager.guildData:getApplyDataByPage(self.applyPlayerPage);
	for i=1, guildData.APPLY_COUNT_PER_PAGE do
		local playerData = applyListData[i];
		
		local guildItem = self:Child("guildCreate"..i.."_guildItem");
		local playerName = self:Child("guildCreate"..i.."_guildItem-playername");
		local playerLevel = self:Child("guildCreate"..i.."_guildItem-playerlv");
		local playerTitle = self:Child("guildCreate"..i.."_guildItem-playertitle");
		
		local totalnum = self:Child("guildCreate"..i.."_guildItem-totalnum");
		local playertime = self:Child("guildCreate"..i.."_guildItem-playertime");
		local yesbtn = self:Child("guildCreate"..i.."_guildItem-yes");
		local nobtn = self:Child("guildCreate"..i.."_guildItem-no");
		
		local applyBtn = self:Child("guildCreate"..i.."_guildItem-apply");
		local sendedImage = self:Child("guildCreate"..i.."_guildItem-sended");
		local givemaster = self:Child("guildCreate"..i.."_guildItem-givemaster");
		
		guildItem:SetVisible(playerData~=nil);
		
		if playerData then
			
			if playerData:getVip() > 0 then
				playerName:SetText("VIP"..playerData:getVip().." "..playerData:getName());
			else
				playerName:SetText(playerData:getName());
			end
			
			playerLevel:SetText("Lv"..playerData:getLevel());
			
			
			local guildItem_textitem = self:Child("guildCreate"..i.."_guildItem-textitem");
			-- 成员操作
			guildItem_textitem:removeEvent("WindowTouchUp");
			if playerData:getID() ~= dataManager.playerData:getPlayerId() then
				-- 自己不弹出菜单
				
				guildItem_textitem:SetUserData(playerData:getID());
				guildItem_textitem:subscribeEvent("WindowTouchUp", "onClickGuildCreateApplyItem");
				
			end
			
			-- show hide detail--------
			playerName:SetVisible(true);
			playerLevel:SetVisible(true);
			playerTitle:SetVisible(false);
			playertime:SetVisible(false);
			
			totalnum:SetVisible(false);
			yesbtn:SetVisible(true);
			nobtn:SetVisible(true);
			applyBtn:SetVisible(false);
			sendedImage:SetVisible(false);
			givemaster:SetVisible(false);
			-------------------------------
			
			yesbtn:SetUserData(playerData:getID());
			nobtn:SetUserData(playerData:getID());
			
		end
		
	end
			
end

function guildCreate:updateGuildInfo()

	if not self._show then
		return;
	end
	
	function onGuildCreateClickGiveMaster(args)
		
		local window = LORD.toWindowEventArgs(args).window;
		dataManager.guildData:onHandleClickGiveMaster();
	end
	
	function onClickGuildCreateMemberItem(args)
	
		local window = LORD.toWindowEventArgs(args).window;
		local targetID = window:GetUserData();
		
		local rect = window:GetUnclippedOuterRect();
		
		dataManager.guildData:onHandleClickMemberMenu(targetID, rect);
		
	end
	
	local guildCreate_textguild = self:Child("guildCreate-textguild");
	local guildCreate_guildctrl = self:Child("guildCreate-guildctrl");
	local guildCreate_totalnum = self:Child("guildCreate-totalnum");
	local guildCreate_list = self:Child("guildCreate-list");
	local guildCreate_npc = self:Child("guildCreate-npc");
	local guildCreate_texttest = self:Child("guildCreate-texttest");
	local guildCreate_textapply = self:Child("guildCreate-textapply");
	local guildCreate_title_text = self:Child("guildCreate-title-text");
	
	guildCreate_npc:SetVisible(false);
	guildCreate_textguild:SetVisible(true);
	guildCreate_texttest:SetVisible(false);
	guildCreate_textapply:SetVisible(false);
	
	guildCreate_guildctrl:SetVisible(true);
	guildCreate_totalnum:SetVisible(true);
	guildCreate_list:SetXPosition(LORD.UDim(0, 11));
	
	
	local guildCreate_spnum = self:Child("guildCreate-spnum");
	guildCreate_spnum:SetText(self.guildPlayerPage.."/"..dataManager.guildData:getPlayerlistTotalPage());
	
	-- player count
	guildCreate_totalnum:SetText(dataManager.guildData:getPlayerCount().."/"..dataManager.guildData:getMaxPlayerCount());
	
	local title_text = self:Child("guildCreate-title-text");
	title_text:SetText("会员列表");
	
	-- 更新公会成员信息
	local playerListData = dataManager.guildData:getPlayerListByPage(self.guildPlayerPage);
	for i=1, guildData.PLAYER_COUNT_PER_PAGE do
	
		local playerData = playerListData[i];
		
		local guildItem = self:Child("guildCreate"..i.."_guildItem");
		local playerName = self:Child("guildCreate"..i.."_guildItem-playername");
		local playerLevel = self:Child("guildCreate"..i.."_guildItem-playerlv");
		local playerTitle = self:Child("guildCreate"..i.."_guildItem-playertitle");
		
		local totalnum = self:Child("guildCreate"..i.."_guildItem-totalnum");
		local playertime = self:Child("guildCreate"..i.."_guildItem-playertime");
		local yesbtn = self:Child("guildCreate"..i.."_guildItem-yes");
		local nobtn = self:Child("guildCreate"..i.."_guildItem-no");
		
		local applyBtn = self:Child("guildCreate"..i.."_guildItem-apply");
		local sendedImage = self:Child("guildCreate"..i.."_guildItem-sended");
		local givemaster = self:Child("guildCreate"..i.."_guildItem-givemaster");

		local guildItem_textitem = self:Child("guildCreate"..i.."_guildItem-textitem");
		
		guildItem:SetVisible(playerData~=nil);
		
		if playerData then
			
			if playerData:getVip() > 0 then
				playerName:SetText("VIP"..playerData:getVip().." "..playerData:getName());
			else
				playerName:SetText(playerData:getName());
			end
			
			playerLevel:SetText("Lv"..playerData:getLevel());
			playerTitle:SetText(playerData:getTitle());
			playertime:SetText(playerData:getOnlineState());
			
			
			-- 成员操作
			guildItem_textitem:removeEvent("WindowTouchUp");
			if playerData:getID() ~= dataManager.playerData:getPlayerId() then
				-- 自己不弹出菜单
				
				guildItem_textitem:SetUserData(playerData:getID());
				guildItem_textitem:subscribeEvent("WindowTouchUp", "onClickGuildCreateMemberItem");
				
			end
			
			-- show hide detail--------
			playerName:SetVisible(true);
			playerLevel:SetVisible(true);
			playerTitle:SetVisible(true);
			playertime:SetVisible(true);
			
			totalnum:SetVisible(false);
			yesbtn:SetVisible(false);
			nobtn:SetVisible(false);
			applyBtn:SetVisible(false);
			sendedImage:SetVisible(false);
						
			-- 该按钮只在userdate为会长的item才会出现，并且是会长超过3天没上线且当前操作人是长老的时候该按钮出现。点击则成为会长
			givemaster:SetVisible(playerData:isPresident() and playerData:leaveTooLong() and dataManager.guildData:isMyselfElders());
			-------------------------------
		end
		
	end
	
end

function guildCreate:updateChooseGuildInfo()

	if not self._show then
		return;
	end

	function onGuildCreateClickApplyGuild(args)
		
		local window = LORD.toWindowEventArgs(args).window;
		local guildID = window:GetUserData();
		
		dataManager.guildListData:onHandleApplyGuild(guildID);
		
	end
		
	local guildCreate_textguild = self:Child("guildCreate-textguild");
	local guildCreate_guildctrl = self:Child("guildCreate-guildctrl");
	local guildCreate_totalnum = self:Child("guildCreate-totalnum");
	local guildCreate_list = self:Child("guildCreate-list");
	local guildCreate_npc = self:Child("guildCreate-npc");
	local guildCreate_texttest = self:Child("guildCreate-texttest");
	local guildCreate_textapply = self:Child("guildCreate-textapply");
	
	guildCreate_npc:SetVisible(true);
	guildCreate_textguild:SetVisible(false);
	guildCreate_texttest:SetVisible(true);
	guildCreate_textapply:SetVisible(false);
	
	guildCreate_guildctrl:SetVisible(false);
	guildCreate_totalnum:SetVisible(false);
	guildCreate_list:SetXPosition(LORD.UDim(0, 578));

	local title_text = self:Child("guildCreate-title-text");
	title_text:SetText("公会列表");

	local guildCreate_spnum = self:Child("guildCreate-spnum");

	guildCreate_spnum:SetText(self.guildPage.."/"..dataManager.guildListData:getTotalPageNum());
	
	
	local guildListInfo = dataManager.guildListData:getPageData(self.guildPage);
	for i=1, guildListData.GUILD_COUNT_PER_PAGE do
		
		local guildData = guildListInfo[i];
		
		local guildItem = self:Child("guildCreate"..i.."_guildItem");
		local playerName = self:Child("guildCreate"..i.."_guildItem-playername");
		local playerLevel = self:Child("guildCreate"..i.."_guildItem-playerlv");
		local playerTitle = self:Child("guildCreate"..i.."_guildItem-playertitle");
		
		local totalnum = self:Child("guildCreate"..i.."_guildItem-totalnum");
		local playertime = self:Child("guildCreate"..i.."_guildItem-playertime");
		local yesbtn = self:Child("guildCreate"..i.."_guildItem-yes");
		local nobtn = self:Child("guildCreate"..i.."_guildItem-no");
		
		local applyBtn = self:Child("guildCreate"..i.."_guildItem-apply");
		local sendedImage = self:Child("guildCreate"..i.."_guildItem-sended");
		local givemaster = self:Child("guildCreate"..i.."_guildItem-givemaster");
		
		guildItem:SetVisible(guildData~=nil);
		
		if guildData then
			
			playerName:SetText(guildData.name);
			playerLevel:SetText(guildData.creater);
			totalnum:SetText(guildData.count.."/"..dataManager.guildData:getMaxPlayerCount());
			
			-- show hide detail--------
			playerName:SetVisible(true);
			playerLevel:SetVisible(true);
			playerTitle:SetVisible(false);
			playertime:SetVisible(false);
			
			totalnum:SetVisible(true);
			yesbtn:SetVisible(false);
			nobtn:SetVisible(false);
			applyBtn:SetVisible(not dataManager.guildListData:isGuildApplyed(guildData.id));
			applyBtn:SetUserData(guildData.id);
						
			-- 是否已申请
			sendedImage:SetVisible(dataManager.guildListData:isGuildApplyed(guildData.id));
			givemaster:SetVisible(false);
			-------------------------------			
		end
		
	end
	
end


function guildCreate:onClickPagePre()
	
	if not self._show then
		return;
	end

	if dataManager.guildData:isHaveGuildMyself() then
		
		if self.isInApplyPage then
			
			if self.applyPlayerPage ~= 1 then
				self.applyPlayerPage = self.applyPlayerPage - 1;
			end
		
		else
			
			if self.guildPlayerPage ~= 1 then
				self.guildPlayerPage = self.guildPlayerPage - 1;
			end
		
		end
		
	else
		
		if self.guildPage ~= 1 then
			self.guildPage = self.guildPage - 1;
		end
		
	end
	
	self:update();
	
end

function guildCreate:onClickPageNext()

	if not self._show then
		return;
	end
	
	if dataManager.guildData:isHaveGuildMyself() then
		
		if self.isInApplyPage then
			
			local maxPage = dataManager.guildData:getTotalApplyPage();	
			if self.applyPlayerPage ~= maxPage then
				self.applyPlayerPage = self.applyPlayerPage + 1;
			end
		
		else
			
			local maxPage = dataManager.guildData:getPlayerlistTotalPage();	
			print("self.guildPlayerPage "..self.guildPlayerPage);
			print("maxPage "..maxPage);
			
			if self.guildPlayerPage ~= maxPage then
				self.guildPlayerPage = self.guildPlayerPage + 1;
			end
		
		end
		
	else
		
		local maxPage = dataManager.guildListData:getTotalPageNum();
		if self.guildPage ~= maxPage then
			self.guildPage = self.guildPage + 1;
		end
		
	end
		
	self:update();
end

return guildCreate;
 