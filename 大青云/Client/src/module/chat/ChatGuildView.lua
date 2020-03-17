--[[
帮派聊天
lizhuangzhuang
2015年9月26日12:17:32
]]

_G.UIChatGuild = BaseUI:new("UIChatGuild");

UIChatGuild.lastSendTime = 0;--上次发送时间

function UIChatGuild:Create()
	self:AddSWF("chatGuild.swf",true,"center");
end

function UIChatGuild:OnLoaded(objSwf)
	objSwf.btnClose.click = function() self:OnBtnCloseClick(); end
	objSwf.btnFace.click = function() TipsManager:Hide(); self:OnBtnFaceClick(); end
	objSwf.btnCancel.click = function() self:OnBtnCancelClick(); end
	objSwf.btnSend.click = function() self:OnBtnSendClick(); end
	objSwf.input.restrict = ChatConsts.Restrict;
	objSwf.input.textChange = function() self:OnInputChange(); end
	objSwf.labelLastInput.text = string.format(StrConfig['chat305'],ChatConsts.MaxInputNum);
	objSwf.chatText.linkClick = function(e) self:OnLinkClick(e); end
	objSwf.unionlist.itemClick = function(e) self:OnUnionItemClick(e); end
	--
	objSwf.btnFace.rollOver = function() TipsManager:ShowBtnTips(StrConfig["chat111"]); end
	objSwf.btnFace.rollOut = function() TipsManager:Hide(); end
end

function UIChatGuild:OnShow()
	if not UnionUtils:CheckMyUnion() then
		self:Hide();
		return;
	end
	UnionController:ReqMyGuildMems();
	self:ShowGuildInfo();
	self:ShowChatText();
end

function UIChatGuild:ShowGuildInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.tfGuildAnn.text = ChatUtil.filter:filter(UnionModel.MyUnionInfo.guildNotice);
	local unionlist = UnionModel.UnionMemberList;
	
	objSwf.unionlist.dataProvider:cleanUp();
	for i,vo in ipairs(unionlist) do
		local uiVO = {};
		uiVO.roleId = vo.id;
		uiVO.name = vo.name;
		uiVO.posUrl = ResUtil:GetUnionPosIconImg(vo.pos);
		if vo.online == 1 then
			uiVO.online = true;
		else
			uiVO.online = false;
		end
		objSwf.unionlist.dataProvider:push(UIData.encode(uiVO));
	end
	objSwf.unionlist:invalidateData();
end

function UIChatGuild:OnUnionItemClick(e)
	local roleId = e.item.roleId;
	local unionVO = nil;
	for i,vo in ipairs(UnionModel.UnionMemberList) do
		if vo.id == roleId then
			unionVO = vo;
			break;
		end
	end
	if not unionVO then return; end
	UIUnionOper:Open(e.renderer,unionVO.pos,unionVO.id,unionVO.name,unionVO.level,unionVO.vipLevel,unionVO.iconID)
end

function UIChatGuild:ShowChatText()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.chatText.htmlText = "";
	local channelVO = ChatModel:GetChannel(ChatConsts.Channel_Guild);
	if not channelVO then return; end
	for i,chatVO in ipairs(channelVO.chatList) do
		if chatVO:GetType() == 0 then
			objSwf.chatText:appendHtml(chatVO:GetText());
			if i<#channelVO.chatList then
				objSwf.chatText:appendHtml("<br/><br/>");
			end
		end
	end
	objSwf.chatText.position = objSwf.chatText.maxscroll;
end

function UIChatGuild:OnBtnSendClick()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local text = objSwf.input.text;
	if text == "" then 
		FloatManager:AddCenter(StrConfig["chat113"]);
		return; 
	end
	if GetServerTime()-self.lastSendTime < ChatConsts.InputInterval then
		FloatManager:AddCenter(StrConfig["chat118"]);
		objSwf.input.text = "";
		objSwf.labelLastInput.text = string.format(StrConfig['chat305'],ChatConsts.MaxInputNum);
		return;
	end
	ChatController:SendChat(ChatConsts.Channel_Guild,text);
	objSwf.input.text = "";
	objSwf.labelLastInput.text = string.format(StrConfig['chat305'],ChatConsts.MaxInputNum);
	self.lastSendTime = GetServerTime();
end

function UIChatGuild:OnInputChange()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local text = objSwf.input.text;
	if text == "" then 
		objSwf.labelLastInput.text = string.format(StrConfig['chat305'],ChatConsts.MaxInputNum);
		return; 
	end
	local hasEnter = false;
	text,hasEnter = ChatUtil:FilterInput(text);
	local len = 0;
	text,len = ChatUtil:CheckInputLength(text);
	if hasEnter or text:tail("\r") then
		if text:tail("\r") then
			local textLen = text:len();
			text = string.sub(text,1,textLen-1);
		end
		if text == "" then
			FloatManager:AddCenter(StrConfig["chat113"]);
			objSwf.input.text = "";
			objSwf.labelLastInput.text = string.format(StrConfig['chat305'],ChatConsts.MaxInputNum);
			return;
		end
		if GetServerTime()-self.lastSendTime < ChatConsts.InputInterval then
			FloatManager:AddCenter(StrConfig["chat118"]);
			objSwf.input.text = "";
			objSwf.labelLastInput.text = string.format(StrConfig['chat305'],ChatConsts.MaxInputNum);
			return;
		end
		ChatController:SendChat(ChatConsts.Channel_Guild,text);
		objSwf.input.text = "";
		objSwf.labelLastInput.text = string.format(StrConfig['chat305'],ChatConsts.MaxInputNum);
		self.lastSendTime = GetServerTime();
	else
		objSwf.input.text = text;
		local lastNum = ChatConsts.MaxInputNum-len;
		if lastNum<0 then lastNum=0; end
		objSwf.labelLastInput.text = string.format(StrConfig['chat305'],lastNum);
	end
end

function UIChatGuild:OnLinkClick(e)
	local linkStr = e.url;
	local params = split(linkStr,",");
	if #params<=0 then return; end
	local type = toint(params[1]);
	local parseClass = ChatConsts.ChatParamMap[type];
	if not parseClass then return; end
	local parser = parseClass:new();
	parser:DoLink(linkStr);
end

function UIChatGuild:OnBtnCancelClick()
	self:Hide();
end

function UIChatGuild:OnBtnCloseClick()
	self:Hide();
end

function UIChatGuild:OnBtnFaceClick()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	UIChatFace:Open(function(text)
		objSwf.input:appendText(text);
		objSwf.input.focused = true;
		self:OnInputChange();
	end,objSwf.btnFace);
end

function UIChatGuild:HandleNotification(name,body)
	if name == NotifyConsts.ChatChannelRefresh then
		if body.channel == ChatConsts.Channel_Guild then
			self:ShowChatText();
		end
	elseif name == NotifyConsts.EditNoticeUpdate then
		if self.objSwf then
			self.objSwf.tfGuildAnn.text = body.guildNotice;
		end
	elseif name == NotifyConsts.MyUnionInfoUpdate then
		if not UnionUtils:CheckMyUnion() then
			self:Hide();
		end
	elseif name == NotifyConsts.UpdateGuildMemberList then
		self:ShowGuildInfo();
	end
end

function UIChatGuild:ListNotificationInterests()
	return {NotifyConsts.ChatChannelRefresh,
			NotifyConsts.EditNoticeUpdate,NotifyConsts.MyUnionInfoUpdate,NotifyConsts.UpdateGuildMemberList};
end