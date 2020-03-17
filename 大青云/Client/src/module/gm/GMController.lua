--[[
运营GM
lizhuangzhuang
2015-10-9 14:45:32
]]

_G.GMController = setmetatable({},{__index=IController})

GMController.name = "GMController";

function GMController:Create()
	MsgManager:RegisterCallBack(MsgType.WC_GMInfo,self,self.OnGMInfo);
	MsgManager:RegisterCallBack(MsgType.WC_GMList,self,self.OnGMList);
	MsgManager:RegisterCallBack(MsgType.WC_GMChat,self,self.OnGMChat);
	MsgManager:RegisterCallBack(MsgType.WC_GMSearch,self,self.OnGMSearch)
	MsgManager:RegisterCallBack(MsgType.WC_GMOperRet,self,self.OnGmOperRet);
	MsgManager:RegisterCallBack(MsgType.WC_GMUnOperRet,self,self.OnGmUnOperRet);
	MsgManager:RegisterCallBack(MsgType.WC_GMGuildRoleList,self,self.OnGMGuild);
	MsgManager:RegisterCallBack(MsgType.WC_GMGuildDismiss,self,self.OnDismissGuild);
	MsgManager:RegisterCallBack(MsgType.WC_GMGuildOper,self,self.OnGuildOper);
	MsgManager:RegisterCallBack(MsgType.WC_GMGuildNotice,self,self.OnChangeGuildAnn);
	
	CControlBase:RegControl(self, true);
end

function GMController:OnKeyDown(keyCode)
	if keyCode == _System.KeyI then
		if isDebug or GMModule:IsGM() then
			if UIGMMain:IsShow() then
				UIGMMain:Hide();
			else
				UIGMMain:Show();
			end
		end
	end
end

function GMController:OnGMInfo(msg)
	if not GMModule:IsGM() and msg.isGM==1 then
		self:UseGMChat(true);
		self:GetGMList(GMConsts.T_UnChat);
		self:GetGMList(GMConsts.T_UnLogin);
		self:GetGMList(GMConsts.T_UnMac);
	end
	GMModule:SetGMInfo(msg.isGM==1 and true or false,msg.isUseGMTitle==1 and true or false,msg.isChat==1 and true or false);
	UIGMChat:SetGMTitleState();
	UIMainMap:UptateRankListOpenState();
end

--请求使用GM称号
function GMController:UseGMTitle(isUse)
	local msg = ReqGMTitleMsg:new();
	msg.isUseGMTitle = isUse and 1 or 0;
	msg.isChat = GMModule:IsChat() and 1 or 0;
	MsgManager:Send(msg);
end

--请求接收聊天
function GMController:UseGMChat(isUse)
	local msg = ReqGMTitleMsg:new();
	msg.isUseGMTitle = GMModule:IsGMTitle() and 1 or 0;
	msg.isChat = isUse and 1 or 0;
	MsgManager:Send(msg);
end

--请求GM列表
function GMController:GetGMList(type)
	local msg = ReqGMListMsg:new();
	msg.type = type;
	MsgManager:Send(msg);
end

function GMController:OnGMList(msg)
	GMModule:SetList(msg.type,msg.list);
end

--接收聊天
function GMController:OnGMChat(msg)
	local chatVO = GMChatVO:new();
	chatVO:SetData(msg);
	GMModule:AddChat(chatVO);
end

--查找
function GMController:GMSearch(key)
	if key == "" then return; end
	local msg = ReqGMSearchMsg:new();
	msg.key = key;
	MsgManager:Send(msg);
end

function GMController:OnGMSearch(msg)
	UIGMSearch:SetList(msg.list);
end

--执行GM操作
function GMController:DoGMOper(oper,uid)
	if oper == GMConsts.Oper_UnChatUnlock then
		local msg = ReqGMUnOperMsg:new();
		msg.id = uid;
		msg.type = 1;
		MsgManager:Send(msg);
		return;
	end
	if oper == GMConsts.Oper_UnLoginUnlock then
		local msg = ReqGMUnOperMsg:new();
		msg.id = uid;
		msg.type = 2;
		MsgManager:Send(msg);
		return;
	end
	if oper == GMConsts.Oper_UnMacUnlock then
		local msg = ReqGMUnOperMsg:new();
		msg.id = uid;
		msg.type = 3;
		MsgManager:Send(msg);
		return;
	end
	local msg = ReqGMOperMsg:new();
	msg.id = uid;
	msg.time = 0;
	if oper == GMConsts.Oper_UnChat1Hour then
		msg.type = 1;
		msg.time = 60*60;
	elseif oper == GMConsts.Oper_UnChat1Day then
		msg.type = 1;
		msg.time = 60*60*24;
	elseif oper == GMConsts.Oper_UnChatForever then
		msg.type = 1;
		msg.time = 60*60*24*365*10;--10year
	elseif oper == GMConsts.Oper_UnLogin1Hour then
		msg.type = 2;
		msg.time = 60*60;
	elseif oper == GMConsts.Oper_UnLogin1Day then
		msg.type = 2;
		msg.time = 60*60*24;
	elseif oper == GMConsts.Oper_UnLoginForever then
		msg.type = 2;
		msg.time = 60*60*24*365*10;--10year
	elseif oper == GMConsts.Oper_UnMac then
		msg.type = 3;
	elseif oper == GMConsts.Oper_Offline then
		msg.type = 4;
	end
	MsgManager:Send(msg);
end

function GMController:OnGmOperRet(msg)
	if msg.result ~= 0 then
		FloatManager:AddNormal(StrConfig["gm018"]);
		return;
	end
	FloatManager:AddNormal(StrConfig["gm019"]);
	if msg.type == 1 then
		self:GetGMList(GMConsts.T_UnChat);
	elseif msg.type == 2 then
		self:GetGMList(GMConsts.T_UnLogin);
	elseif msg.type == 3 then
		self:GetGMList(GMConsts.T_UnMac);
	end
end

function GMController:OnGmUnOperRet(msg)
	if msg.result ~= 0 then
		FloatManager:AddNormal(StrConfig["gm018"]);
		return;
	end
	FloatManager:AddNormal(StrConfig["gm019"]);
	if msg.type == 1 then
		self:GetGMList(GMConsts.T_UnChat);
	elseif msg.type == 2 then
		self:GetGMList(GMConsts.T_UnLogin);
	elseif msg.type == 3 then
		self:GetGMList(GMConsts.T_UnMac);
	end
end

--请求帮派信息
function GMController:GetGMGuildInfo(guildUid)
	local msg = ReqGMGuildRoleListMsg:new();
	msg.guildUid = guildUid;
	MsgManager:Send(msg);
end

function GMController:OnGMGuild(msg)
	if not UIGMGuild:IsShow() then
		UIGMGuild:Show();
	end
	UIGMGuild:SetData(msg.guildName,msg.guildUid,msg.timeNow,msg.GuildMemList);
end

function GMController:DoGMGuildOper(oper,uid,guildUid)
	local msg = ReqGMGuildOperMsg:new();
	msg.guildUid = guildUid;
	msg.roleId = uid;
	if oper == GMConsts.GOper_Leader then
		msg.type = 1;
	elseif oper == GMConsts.GOper_SubLeader then
		msg.type = 2;
	elseif oper == GMConsts.GOper_Elder then
		msg.type = 3;
	elseif oper == GMConsts.GOper_Elite then
		msg.type = 4;
	elseif oper == GMConsts.GOper_Common then
		msg.type = 5;
	elseif oper == GMConsts.GOper_KickOut then
		msg.type = 6;
	end
	MsgManager:Send(msg);
end

function GMController:OnGuildOper(msg)
	if msg.result == 0 then
		FloatManager:AddNormal(StrConfig["gm019"]);
	else
		FloatManager:AddNormal(StrConfig["gm018"]);
	end
end

function GMController:DismissGuild(guildUid)
	local msg = ReqGMGuildDismissMsg:new();
	msg.guildUid = guildUid;
	MsgManager:Send(msg);
end

function GMController:OnDismissGuild(msg)
	if msg.result == 0 then
		FloatManager:AddNormal(StrConfig["gm019"]);
		if UIGMGuild:IsShow() then
			UIGMGuild:Hide();
		end
	else
		FloatManager:AddNormal(StrConfig["gm018"]);
	end
end

function GMController:ChangeGuildAnn(guildUid,text)
	local msg = ReqGMGuildNoticeMsg:new();
	msg.guildUid = guildUid;
	msg.notice = text;
	MsgManager:Send(msg);
end

function GMController:OnChangeGuildAnn(msg)
	if msg.result == 0 then
	
	else
		FloatManager:AddNormal(StrConfig["gm018"]);
	end
end