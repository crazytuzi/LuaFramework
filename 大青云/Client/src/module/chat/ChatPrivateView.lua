--[[
私聊面板
lizhuangzhuang
2014年9月25日20:34:07
]]
_G.classlist['UIChatPrivate'] = 'UIChatPrivate'
_G.UIChatPrivate = BaseUI:new("UIChatPrivate");
UIChatPrivate.objName = 'UIChatPrivate'
function UIChatPrivate:Create()
	self:AddSWF("chatPrivate.swf",true,"center");
end

function UIChatPrivate:OnLoaded(objSwf,name)
	objSwf.btnClose.click = function() self:OnBtnCloseClick(); end
	objSwf.btnMin.click = function() self:OnBtnMinClick(); end
	objSwf.btnFace.click = function() TipsManager:Hide();self:OnBtnFaceClick(); end
	objSwf.btnTeam.click = function() self:OnBtnTeamClick(); end
	objSwf.btnFriend.click = function() self:OnBtnFriendClick(); end
	objSwf.btnCopyName.click = function() self:OnBtnCopyNameClick(); end
	objSwf.btnBlacklist.click = function() self:OnBtnBlacklistClick(); end
	objSwf.btnCancel.click = function() self:OnBtnCancelClick(); end
	objSwf.btnSend.click = function() self:OnBtnSendClick(); end
	objSwf.input.restrict = ChatConsts.Restrict;
	objSwf.input.textChange = function() self:OnInputChange(); end
	objSwf.labelLastInput.text = string.format(StrConfig['chat305'],ChatConsts.MaxInputNum);
	objSwf.loaderHead.loaded = function() 
									objSwf.loaderHead.content._width = 64;
									objSwf.loaderHead.content._height = 64;
								end
	--
	objSwf.list.itemClick = function(e) self:OnItemClick(e); end
	objSwf.list.itemClose = function(e) self:OnItemClose(e); end
	--tips
	objSwf.btnFace.rollOver = function() TipsManager:ShowBtnTips(StrConfig["chat111"]); end
	objSwf.btnFace.rollOut = function() TipsManager:Hide(); end
	objSwf.btnTeam.rollOver = function() TipsManager:ShowBtnTips(StrConfig['chat301']); end
	objSwf.btnTeam.rollOut = function() TipsManager:Hide(); end
	objSwf.btnFriend.rollOver = function() TipsManager:ShowBtnTips(StrConfig['chat302']); end
	objSwf.btnFriend.rollOut = function() TipsManager:Hide(); end
	objSwf.btnCopyName.rollOver = function() TipsManager:ShowBtnTips(StrConfig['chat303']); end
	objSwf.btnCopyName.rollOut = function() TipsManager:Hide(); end
	objSwf.btnBlacklist.rollOver = function() TipsManager:ShowBtnTips(StrConfig['chat304']); end
	objSwf.btnBlacklist.rollOut = function() TipsManager:Hide(); end
end

function UIChatPrivate:OnShow(name)
	self:ShowRoleList();
end

--显示左侧列表
function UIChatPrivate:ShowRoleList()
	local objSwf = self:GetSWF("UIChatPrivate");
	if not objSwf then return; end
	local list = ChatModel.privateChatList;
	objSwf.list.dataProvider:cleanUp();
	for i,vo in ipairs(list) do
		local listVO = {};
		listVO.roleId = vo.roleId;
		listVO.roleName = vo.roleName;
		listVO.icon = vo.icon;
		listVO.iconUrl = ResUtil:GetHeadIcon(vo.icon);
		listVO.lvl = vo.lvl;
		listVO.vipLvl = vo.vipLvl;
		listVO.newMsg = ChatModel:GetHasPrivateNotice(vo.roleId);
		objSwf.list.dataProvider:push(UIData.encode(listVO));
	end
	objSwf.list:invalidateData();
	--选中当前玩家
	local currRole = ChatModel.currPrivateChat;
	for i,vo in pairs(list) do
		if vo.roleId == currRole then
			objSwf.list.selectedIndex = i-1;
			break;
		end
	end
	--
	self:ShowRightInfo();
end

--显示右侧信息
function UIChatPrivate:ShowRightInfo()
	local objSwf = self:GetSWF("UIChatPrivate");
	if not objSwf then return; end
	objSwf.input.text = "";
	objSwf.labelLastInput.text = string.format(StrConfig['chat305'],ChatConsts.MaxInputNum);
	local chatInfo = ChatModel:GetPrivateInfo(ChatModel.currPrivateChat);
	if chatInfo then
		objSwf.labelName.text = chatInfo.roleName;
		objSwf.labelLvl.text = string.format(StrConfig['chat300'],chatInfo.lvl);
		objSwf.loaderHead.source = chatInfo.iconUrl;
	end
	self:ShowChatText();
end

--显示聊天内容
function UIChatPrivate:ShowChatText()
	local objSwf = self:GetSWF("UIChatPrivate");
	if not objSwf then return; end 
	objSwf.chatText.htmlText = "";
	local channelVO = ChatModel:GetPrivateChannel(ChatModel.currPrivateChat);
	if not channelVO then return; end
	for i,chatVO in ipairs(channelVO.chatList) do
		objSwf.chatText:appendHtml(chatVO:GetText());
		if i<#channelVO.chatList then
			objSwf.chatText:appendHtml("<br/><br/>");
		end
	end
	objSwf.chatText.position = objSwf.chatText.maxscroll;
end

--点击Item
function UIChatPrivate:OnItemClick(e)
	local roleId = e.item.roleId;
	ChatController:OpenPrivateChat(roleId,e.item.roleName,e.item.icon,e.item.lvl,e.item.vipLvl)
end

--点击Item Close
function UIChatPrivate:OnItemClose(e)
	local roleId = e.item.roleId;
	ChatController:ClosePrivateChat(roleId);
end

--点击关闭
function UIChatPrivate:OnBtnCloseClick()
	ChatController:CloseAllPrivateChat();
end

--点击最小化
function UIChatPrivate:OnBtnMinClick()
	self:Hide();
	local chatInfo = ChatModel:GetPrivateInfo(ChatModel.currPrivateChat);
	if chatInfo then
		UIChatPrivateMin:Open(chatInfo.roleId,chatInfo.roleName,chatInfo.icon,chatInfo.lvl,chatInfo.vipLvl)
	end
	ChatModel:SetCurrPrivateChat(0);
end

--点击发送
function UIChatPrivate:OnBtnSendClick()
	local objSwf = self:GetSWF("UIChatPrivate");
	if not objSwf then return; end
	local text = objSwf.input.text;
	if text == "" then 
		FloatManager:AddCenter(StrConfig["chat113"]);
		return; 
	end
	ChatController:SendPrivateChat(text,ChatModel.currPrivateChat);
	objSwf.input.text = "";
	objSwf.labelLastInput.text = string.format(StrConfig['chat305'],ChatConsts.MaxInputNum);
end

function UIChatPrivate:OnInputChange()
	local objSwf = self:GetSWF("UIChatPrivate");
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
		else
			ChatController:SendPrivateChat(text,ChatModel.currPrivateChat);
		end
		objSwf.input.text = "";
		objSwf.labelLastInput.text = string.format(StrConfig['chat305'],ChatConsts.MaxInputNum);
	else
		objSwf.input.text = text;
		local lastNum = ChatConsts.MaxInputNum-len;
		if lastNum<0 then lastNum=0; end
		objSwf.labelLastInput.text = string.format(StrConfig['chat305'],lastNum);
	end
end

--点击取消,关闭当前
function UIChatPrivate:OnBtnCancelClick()
	ChatController:ClosePrivateChat(ChatModel.currPrivateChat);
end

--点击表情
function UIChatPrivate:OnBtnFaceClick()
	local objSwf = self:GetSWF("UIChatPrivate");
	if not objSwf then return; end
	UIChatFace:Open(function(text)
		objSwf.input:appendText(text);
		objSwf.input.focused = true;
		self:OnInputChange();
	end,objSwf.btnFace);
end

--点击组队
function UIChatPrivate:OnBtnTeamClick()
	local chatInfo = ChatModel:GetPrivateInfo(ChatModel.currPrivateChat);
	if chatInfo then
		TeamController:InvitePlayerJoin(chatInfo.roleId);
	end
end

--点击添加好友
function UIChatPrivate:OnBtnFriendClick()
	local chatInfo = ChatModel:GetPrivateInfo(ChatModel.currPrivateChat);
	if chatInfo then
		FriendController:AddFriend(chatInfo.roleId);
	end
end

--点击复制名字
function UIChatPrivate:OnBtnCopyNameClick()
	local objSwf = self:GetSWF("UIChatPrivate");
	if not objSwf then return; end
	local chatInfo = ChatModel:GetPrivateInfo(ChatModel.currPrivateChat);
	if chatInfo then
		_sys.clipboard = chatInfo.roleName;
	end
end

--点击黑名单
function UIChatPrivate:OnBtnBlacklistClick()
	local chatInfo = ChatModel:GetPrivateInfo(ChatModel.currPrivateChat);
	if chatInfo then
		FriendController:AddBlack(chatInfo.roleId,chatInfo.roleName);
	end
end

function UIChatPrivate:HandleNotification(name,body)
	if not self.bShowState then return;end
	local objSwf = self:GetSWF("UIChatPrivate");
	if not objSwf then return;end
	if name == NotifyConsts.ChatPrivateListRefresh then
		self:ShowRoleList();
	elseif name == NotifyConsts.ChatPrivateRefresh then
		if body.roleId == ChatModel.currPrivateChat then
			self:ShowChatText();
		end
	elseif name == NotifyConsts.ChatPrivateNotice then
		self:ShowRoleList();
	end
end

function UIChatPrivate:ListNotificationInterests()
	return {NotifyConsts.ChatPrivateListRefresh,NotifyConsts.ChatPrivateRefresh,NotifyConsts.ChatPrivateNotice};
end