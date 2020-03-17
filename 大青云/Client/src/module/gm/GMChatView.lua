--[[
聊天监控
lizhuangzhuang
2015年10月9日15:53:46
]]

_G.UIGMChat = BaseUI:new("UIGMChat");

UIGMChat.RefreshTime = 500;--聊天刷新时间(ms)
UIGMChat.lastRefreshTime = 0;--聊天上次刷新时间
UIGMChat.refreshState = 0;--刷新状态:0正常,1等待刷新

--当前开启的频道
UIGMChat.channels = {};

function UIGMChat:Create()
	self:AddSWF("gmChatPanel.swf",true,nil);
end

function UIGMChat:OnLoaded(objSwf)
	objSwf.btnClear.click = function() self:OnBtnClearClick(); end
	objSwf.btnUseTitle.click = function() self:OnBtnUseTitleClick(); end
	objSwf.chatText.linkClick = function(e) self:OnLinkClick(e); end
	for i=1,8 do
		if GMConsts.ChatChannel[i] then
			objSwf["cbChannel"..i].visible = true;
			objSwf["cbChannel"..i].label = ChatConsts:GetChannelName(GMConsts.ChatChannel[i]);
			objSwf["cbChannel"..i].click = function() self:OnChannelClick(i,GMConsts.ChatChannel[i]); end
		else
			objSwf["cbChannel"..i].visible = false;
		end
	end
end

function UIGMChat:OnShow()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	for i=1,8 do
		if GMConsts.ChatChannel[i] then
			objSwf["cbChannel"..i].selected = true;
			self.channels[GMConsts.ChatChannel[i]] = true;
		end
	end
	--
	self:ShowChat();
	self:SetGMTitleState();
end

function UIGMChat:ShowChat()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local text = "";
	local len = #GMModule.chatList;
	for i=len,1,-1 do
		local chatVO = GMModule.chatList[i];
		if self.channels[chatVO.channel] then
			text = text .. chatVO.text .. "<br/>";
		end
	end
	objSwf.chatText.htmlText = text;
end

function UIGMChat:OnChannelClick(index,channel)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local button = objSwf["cbChannel"..index];
	if not button then return; end
	self.channels[channel] = button.selected;
	self:ShowChat();
end

function UIGMChat:OnBtnClearClick()
	GMModule:ClearChat();
	self:ShowChat();
end

function UIGMChat:SetGMTitleState()
	if not self:IsShow() then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if GMModule:IsGMTitle() then
		objSwf.btnUseTitle.label = StrConfig["gm020"];
	else
		objSwf.btnUseTitle.label = StrConfig["gm021"];
	end
end

function UIGMChat:OnBtnUseTitleClick()
	GMController:UseGMTitle(not GMModule:IsGMTitle());
end

function UIGMChat:Update()
	if not self:IsShow() then return; end
	if self.refreshState == 1 then
		if GetCurTime()-self.lastRefreshTime > UIGMChat.RefreshTime then
			self:ShowChat();
			self.lastRefreshTime = GetCurTime();
			self.refreshState = 0;
		end
	end
end

function UIGMChat:OnLinkClick(e)
	local linkStr = e.url;
	local params = split(linkStr,",");
	if #params<=0 then return; end
	local type = toint(params[1]);
	local parseClass = ChatConsts.ChatParamMap[type];
	if not parseClass then return; end
	local parser = parseClass:new();
	parser:DoLink(linkStr);
end

function UIGMChat:HandleNotification(name,body)
	if name == NotifyConsts.GMChatRefresh then
		if not self.channels[body.channel] then return; end
		if GetCurTime()-self.lastRefreshTime > UIGMChat.RefreshTime then
			self:ShowChat();
			self.lastRefreshTime = GetCurTime();
			self.refreshState = 0;
		else
			self.refreshState = 1;
		end
	end
end

function UIGMChat:ListNotificationInterests()
	return {NotifyConsts.GMChatRefresh};
end