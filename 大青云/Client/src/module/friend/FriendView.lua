--[[
好友界面
lizhuangzhuang
2014年10月17日15:56:52
]]

_G.UIFriend = BaseUI:new("UIFriend");

--页签
UIFriend.tabPanel = {};
UIFriend.currTalPanel = "";
--好友面板分类
UIFriend.panelFMap = {
	{type=FriendConsts.RType_Recent,label=StrConfig['friend301']},
	{type=FriendConsts.RType_Friend,label=StrConfig['friend302']},
	{type=FriendConsts.RType_Enemy,label=StrConfig['friend303']},
	{type=FriendConsts.RType_Black,label=StrConfig['friend304']},
};
--好友面板打开索引
UIFriend.panelFOpneIndex = -1;
--好友刷新定时器
UIFriend.timerKey = nil;


function UIFriend:Create()
	self:AddSWF("friendPanel.swf",true,"center");
end

function UIFriend:OnLoaded(objSwf,name)
	objSwf.btnClose.click = function() self:OnBtnCloseClick(); end
	objSwf.loaderHead.loaded = function() 
									objSwf.loaderHead.content._width = 64;
									objSwf.loaderHead.content._height = 64;
								end
	objSwf.btnRecommend.click = function() self:OnBtnRecommendClick(); end
	objSwf.btnAddFriend.click = function() self:OnBtnAddFriendClick(); end
	objSwf.btnIntimacy.click = function() self:OnBtnIntimacyClick(); end
	--
	objSwf.ipSearch.restrict = "^[]<>{}#&";
	objSwf.ipSearch.textChange = function() self:OnIpSearchChange(); end
	objSwf.searchList.itemClick = function(e) self:OnSearchListItemClick(e); end
	objSwf.searchNone.visible = false;
	objSwf.searchList.visible = false;
	--
	self.tabPanel["friend"] = {btn=objSwf.btnFriend,panel=objSwf.panelFriend};
	self.tabPanel["guild"] = {btn=objSwf.btnGuild,panel=objSwf.panelGuild};
	for name,cfg in pairs(self.tabPanel) do
		cfg.btn.click = function() self:OnTabButtonClick(name); end
	end
	--
	objSwf.panelFriend.buttonClick = function(e) self:OnFriendPanelClick(e); end
	for i,cfg in ipairs(self.panelFMap) do
		objSwf.panelFriend:addButton();
	end
	objSwf.panelFriend.list.itemClick = function(e) self:OnFriendListItemClick(e); end
	objSwf.panelFriend.list.itemDoubleClick = function(e) self:OnFriendListItemDoubleClick(e); end
	objSwf.panelFriend.list.killOver = function(e) self:OnFriendListKillOver(e); end
	objSwf.panelFriend.list.killOut = function(e) TipsManager:Hide(); end
	objSwf.panelFriend.list.intimacyOver = function(e) self:OnFriendListIntimacyOver(e); end
	objSwf.panelFriend.list.intimacyOut = function(e) TipsManager:Hide(); end
	
	objSwf.panelGuild.list.itemClick = function (e) self:OnUnionFriendListClickHandler(e); end 
	objSwf.panelGuild.list.itemDoubleClick = function (e) self:OnUnionFriendListDoubleClickHandler(e); end 
end

function UIFriend:OnDelete()
	for k,_ in pairs(self.tabPanel) do
		self.tabPanel[k] = nil;
	end
end

function UIFriend:IsTween()
	return true;
end

function UIFriend:GetPanelType()
	return 0;
end

function UIFriend:ESCHide()
	return true;
end

function UIFriend:IsShowLoading()
	return true;
end

function UIFriend:IsShowSound()
	return true;
end

function UIFriend:GetHeight()
	return 688;
end

function UIFriend:GetWidth()
	return 464;
end

function UIFriend:OnShow()
	self:ShowMeInfo();
	self:OnTabButtonClick("friend");
	self:StartRefreshTimer();
end

function UIFriend:StartRefreshTimer()
	self:StopRefreshTimer()
	local func = function() self:ReqRefresh() end
	self.timerKey = TimerManager:RegisterTimer( func, FriendConsts.UpdateTime, 0);
	self:ReqRefresh()
end

function UIFriend:ReqRefresh()
	FriendController:ReqRelationChangeList();
end

function UIFriend:StopRefreshTimer()
	if self.timerKey then
		TimerManager:UnRegisterTimer( self.timerKey );
		self.timerKey = nil
	end
end

function UIFriend:OnHide()
	self:StopRefreshTimer()
end

function UIFriend:HandleNotification(name,body)
	if not self.bShowState then return; end
	local objSwf = self.objSwf;
	if not objSwf then return; end
	objSwf.btnIntimacy.visible = false;
	if name == NotifyConsts.PlayerAttrChange then
		if body.type==enAttrType.eaLevel then
			self:ShowMeInfo();
		end
	elseif name == NotifyConsts.StageClick then
		local ipSearchTarget = string.gsub(objSwf.ipSearch._target,"/",".");
		local searchListTarget = string.gsub(objSwf.searchList._target,"/",".");
		if string.find(body.target,ipSearchTarget) or string.find(body.target,searchListTarget) then
			return;
		end
		self:OnIpSearchFocusOut();
	elseif name == NotifyConsts.StageFocusOut then
		self:OnIpSearchFocusOut();
	elseif name == NotifyConsts.FriendChange then
		self:ShowFriendOnlineNum();
		self:ShowFriendList(self.panelFOpneIndex,true);
	elseif name == NotifyConsts.FriendOnlineChange then
		self:ShowFriendOnlineNum();
		self:ShowFriendList(self.panelFOpneIndex,true);
	elseif name == NotifyConsts.ChatPrivateNotice then
		self:ShowFriendList(self.panelFOpneIndex,true);
	elseif name == NotifyConsts.UpdateGuildMemberList then
		self:ShowUnionFriendList()
	elseif name == NotifyConsts.MyUnionInfoUpdate then
		self:ClearUnionFriendList();
	end
end

function UIFriend:ListNotificationInterests()
	return {NotifyConsts.PlayerAttrChange,NotifyConsts.ChatPrivateNotice,
			NotifyConsts.StageClick,NotifyConsts.StageFocusOut,
			NotifyConsts.FriendChange,NotifyConsts.FriendOnlineChange,
			NotifyConsts.UpdateGuildMemberList,
			NotifyConsts.MyUnionInfoUpdate};
end


--显示我的信息
function UIFriend:ShowMeInfo()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local playerInfo = MainPlayerModel.humanDetailInfo;
	objSwf.tfName.text = playerInfo.eaName;
	objSwf.tfLvl.text = string.format(StrConfig['friend101'],playerInfo.eaLevel);
	if UnionModel:GetMyUnionId() ~= nil then
		objSwf.tfGuild.text = UnionModel.MyUnionInfo.guildName;
	else
		objSwf.tfGuild.text = "";
	end
	objSwf.loaderHead.source = ResUtil:GetHeadIcon(MainPlayerModel:GetIconId());
end

------------------------------页签--------------------------
--页签点击
function UIFriend:OnTabButtonClick(name)
	if not self.tabPanel[name] then
		return;
	end
	if name == self.currTalPanel then return; end
	self.tabPanel[name].btn.selected = true;
	self:ShowTabPanel(name);
end

--显示页签
function UIFriend:ShowTabPanel(name)
	if not self.tabPanel[name] then return; end
	self.currTalPanel = name;
	for n,cfg in pairs(self.tabPanel) do
		if n == name then
			cfg.panel._visible = true;
		else
			cfg.panel._visible = false;
		end
	end
	if name == "friend" then
		self:ShowFriendOnlineNum();
		self:ShowFriendList(1);
	elseif name == "guild" then
		if not UnionModel.MyUnionInfo.guildId or UnionModel.MyUnionInfo.guildId == "0_0" then
			return ;
		end
		UnionController:ReqMyGuildMems();
	end
end
------------------------------搜索相关----------------------
function UIFriend:OnIpSearchChange()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local searchKey = objSwf.ipSearch.text;
	if searchKey == "" then
		objSwf.searchNone.visible = false;
		objSwf.searchList.visible = false;
		return;
	end
	local list = {};
	if self.currTalPanel == "friend" then
		list = FriendModel:Search(searchKey);
	else
		list = UIFriend:Search(searchKey);
	end
	if #list <= 0 then
		objSwf.searchNone.visible = true;
		objSwf.searchList.visible = false;
		return;
	end
	objSwf.searchNone.visible = false;
	objSwf.searchList.visible = true;
	objSwf.searchList.height = #list * 21+5;
	objSwf.searchList.dataProvider:cleanUp();
	for i,friendVO in ipairs(list) do
		local listVO = {};
		listVO.roleId = friendVO:GetRoleId();
		listVO.name = friendVO:GetRoleName();
		listVO.lvl = string.format(StrConfig['friend101'],friendVO:GetLevel());
		objSwf.searchList.dataProvider:push(UIData.encode(listVO));
	end
	objSwf.searchList:invalidateData();
end

--输入文本失去焦点
function UIFriend:OnIpSearchFocusOut()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if objSwf.ipSearch.focused then
		objSwf.ipSearch.focused = false;
	end
	objSwf.searchNone.visible = false;
	objSwf.searchList.visible = false;
end

--点击搜索结果
function UIFriend:OnSearchListItemClick(e)
	local roleId = e.item.roleId;
	local friendVO = FriendModel:GetFriendVO(roleId);
	if friendVO then
		ChatController:OpenPrivateChat(friendVO:GetRoleId(),friendVO:GetRoleName(),
						friendVO:GetIconId(),friendVO:GetLevel(),friendVO:GetVIPLevel());
	end
	self:OnIpSearchFocusOut();
end
--------------------------工会成员列表相关--------------------------
UIFriend.unionFriendList = {};
function UIFriend:ShowUnionFriendList()
	local objSwf = self.objSwf;
	if not objSwf then return end
	local _list = UnionModel.UnionMemberList
	objSwf.panelGuild.list.dataProvider:cleanUp();
	local cfg = _list;
	for i , v in ipairs(cfg) do
		local obj = FriendUnionVO:New(v);
		self.unionFriendList[i] = obj;
		objSwf.panelGuild.list.dataProvider:push(UIData.encode(obj));
	end
	objSwf.panelGuild.list:invalidateData();
end

--工会好友单击事件
function UIFriend:OnUnionFriendListClickHandler(e)
	local unionFriendVO = self:GetUnionCfg(e.item.roleId);
	if not unionFriendVO then return; end
	UIFriendOper:Open(unionFriendVO,nil);
end

--工会好友双击事件
function UIFriend:OnUnionFriendListDoubleClickHandler(e)
	local unionFriendVO = e.item;
	if unionFriendVO.roleId == MainPlayerController:GetRoleID() then 
		return;
	end
	if unionFriendVO then
		ChatController:OpenPrivateChat(unionFriendVO.roleId,unionFriendVO.roleName,
						unionFriendVO.icon,unionFriendVO.lvl,unionFriendVO.vipLvl);
	end
end

--当解散了工会 将工会好友列表清空
function UIFriend:ClearUnionFriendList()
	local objSwf = self.objSwf ;
	if not objSwf then return end
	objSwf.panelGuild.list.dataProvider:cleanUp();
	objSwf.panelGuild.list:invalidateData();
end

--得到某个工会人物的cfg
function UIFriend:GetUnionCfg(roleId)
	for i , v in pairs(self.unionFriendList) do
		if v:GetRoleId() == roleId then
			return v;
		end
	end
end

--搜索
function UIFriend:Search(key)
	local list = {};
	for k,friendVO in pairs(self.unionFriendList) do
		local startIndex = string.find(friendVO:GetRoleName(),key);
		if startIndex then
			table.push(list,friendVO);
		end
	end
	return list;
end
-------------------------------好友列表相关-----------------
--显示列表在线人数
function UIFriend:ShowFriendOnlineNum()
	local objSwf = self.objSwf;
	if not objSwf then return; end
	for i,cfg in ipairs(self.panelFMap) do
		local button = objSwf.panelFriend:getButtonAt(i-1);
		if button then
			local list = FriendModel:GetListByRType(cfg.type);
			local onlineNum = 0;
			for i,friendVO in ipairs(list) do
				if friendVO:GetOnlineState() == 1 then
					onlineNum = onlineNum + 1;
				end
			end
			if cfg.label then
				button.label = string.format(cfg.label,onlineNum,#list);
			end
		end
	end
end
--显示列表
--@param buttonIndex 分类索引,从0开始
--@param keepPos 是否保留滚动条位置
function UIFriend:ShowFriendList(buttonIndex,keepPos)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	local cfg = self.panelFMap[buttonIndex+1];
	if not cfg then return; end
	local list = FriendModel:GetListByRType(cfg.type);
	objSwf.panelFriend:Open(buttonIndex,#list);
	self.panelFOpneIndex = buttonIndex;
	--
	FriendUtil:Sort(list,cfg.type)
	--
	objSwf.panelFriend.list.dataProvider:cleanUp();
	for i,friendVO in ipairs(list) do
		local uilistVO = {};
		uilistVO.roleId = friendVO:GetRoleId();
		uilistVO.name = friendVO:GetRoleName();
		uilistVO.lvl = string.format(StrConfig["friend101"],friendVO:GetLevel());
		uilistVO.vipLvl = friendVO:GetVIPLevel();
		uilistVO.online = friendVO:GetOnlineState()==1;
		uilistVO.onlineStr = FriendConsts:GetOnlineStr(friendVO:GetOnlineState());
		uilistVO.showKill = friendVO:GetBeKillNum()>0;
		uilistVO.iconUrl = ResUtil:GetHeadIcon(friendVO:GetIconId(),friendVO:GetOnlineState()~=1);
		uilistVO.guild = "";
		uilistVO.newMsg = ChatModel:GetHasPrivateNotice(friendVO:GetRoleId());
		objSwf.panelFriend.list.dataProvider:push(UIData.encode(uilistVO));
	end
	objSwf.panelFriend.list:invalidateData();
	if not keepPos then
		objSwf.panelFriend.list:scrollToIndex(0);
	end
end

function UIFriend:OnFriendPanelClick(e)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	if self.panelFOpneIndex == e.index then
		objSwf.panelFriend:Close(e.index);
		self.panelFOpneIndex = -1;
		objSwf.panelFriend.list.dataProvider:cleanUp();
		objSwf.panelFriend.list:invalidateData();
	else
		self:ShowFriendList(e.index);
	end
end

--点击好友列表
function UIFriend:OnFriendListItemClick(e)
	local roleId = e.item.roleId;
	local friendVO = FriendModel:GetFriendVO(roleId);
	if not friendVO then return; end
	local cfg = self.panelFMap[self.panelFOpneIndex+1];
	if not cfg then return; end
	UIFriendOper:Open(friendVO,cfg.type);
end

--双击好友列表
function UIFriend:OnFriendListItemDoubleClick(e)
	local roleId = e.item.roleId;
	local friendVO = FriendModel:GetFriendVO(roleId);
	if friendVO then
		ChatController:OpenPrivateChat(friendVO:GetRoleId(),friendVO:GetRoleName(),
						friendVO:GetIconId(),friendVO:GetLevel(),friendVO:GetVIPLevel());
	end
end

--击杀over
function UIFriend:OnFriendListKillOver(e)
	local roleId = e.item.roleId;
	local friendVO = FriendModel:GetFriendVO(roleId);
	if not friendVO then return; end
	if friendVO:GetBeKillNum() <= 0 then return; end
	TipsManager:ShowBtnTips(string.format(StrConfig['friend206'],friendVO:GetBeKillNum()));
end

--亲密度over
function UIFriend:OnFriendListIntimacyOver(e)
	local roleId = e.item.roleId;
	local friendVO = FriendModel:GetFriendVO(roleId);
	if not friendVO then return; end
	local intimacyCfg = FriendUtil:GetIntimacyCfg(friendVO:GetIntimacy());
	if not intimacyCfg then return; end
	local str = string.format(StrConfig['friend205'],intimacyCfg.name,friendVO:GetIntimacy());
	TipsManager:ShowBtnTips(str);
end

-----------------------------------------------------------------
--点击推荐好友
function UIFriend:OnBtnRecommendClick()
	if UIFriendRecommend:IsShow() then
		UIFriendRecommend:Hide();
	else
		FriendController:ReqRecommendFriend();
		UIFriendRecommend:Show();
	end
end

--点击添加好友
function UIFriend:OnBtnAddFriendClick()
	if UIFriendAdd:IsShow() then
		UIFriendAdd:Hide();
	else
		UIFriendAdd:Show();
	end
end

--点击亲密度
function UIFriend:OnBtnIntimacyClick()
	if UIFriendIntimacy:IsShow() then
		UIFriendIntimacy:Hide();
	else
		UIFriendIntimacy:Show();
	end
end

function UIFriend:OnBtnCloseClick()
	self:Hide();
end