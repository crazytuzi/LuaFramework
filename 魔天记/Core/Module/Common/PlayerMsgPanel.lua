require "Core.Module.Common.Panel";
require "Core.Module.Common.CommonColor";

PlayerMsgPanel = Panel:New();
function PlayerMsgPanel:_Init()
	self:_InitReference();
	self:_InitListener();
end
function PlayerMsgPanel:IsFixDepth()
	return true;
end

function PlayerMsgPanel:GetUIOpenSoundName()
	return ""
end

function PlayerMsgPanel:_InitReference()
	self._trsInfo = UIUtil.GetChildByName(self._trsContent, "Transform", "trsInfo");
	self._bg = UIUtil.GetChildByName(self._trsInfo, "UISprite", "bg");
	self._txtName = UIUtil.GetChildByName(self._bg, "UILabel", "txtName");
	self._icoHead = UIUtil.GetChildByName(self._bg, "UISprite", "icoHead");
	self._txtLevel = UIUtil.GetChildByName(self._icoHead, "UILabel", "txtLevel");
	self._imgLevelBg = UIUtil.GetChildByName(self._txtLevel, "UISprite", "lvBg")
	self._btnGrids = UIUtil.GetChildByName(self._bg, "UIGrid", "btnGrids");
	self._trsGrid = self._btnGrids.transform
	self._btnDetail = UIUtil.GetChildByName(self._trsGrid, "UIButton", "btnDetail");
	self._btnChat = UIUtil.GetChildByName(self._trsGrid, "UIButton", "btnChat");
	self._btnFriend = UIUtil.GetChildByName(self._trsGrid, "UIButton", "btnFriend");
	self._btnParty = UIUtil.GetChildByName(self._trsGrid, "UIButton", "btnParty");
	self._btnAddGuild = UIUtil.GetChildByName(self._trsGrid, "UIButton", "btnAddGuild");
end
function PlayerMsgPanel:_InitListener()
	self._onClickClose = function(go) self:_OnClickClose() end
	UIUtil.GetComponent(self._trsInfo, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickClose);
	
	self._onClickBtnDetail = function(go) self:_OnClickBtnDetail(self) end
	UIUtil.GetComponent(self._btnDetail, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnDetail);
	self._onClickBtnChat = function(go) self:_OnClickBtnChat(self) end
	UIUtil.GetComponent(self._btnChat, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnChat);
	self._onClickBtnFriend = function(go) self:_OnClickBtnFriend(self) end
	UIUtil.GetComponent(self._btnFriend, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnFriend);
	self._onClickBtnParty = function(go) self:_OnClickBtnParty(self) end
	UIUtil.GetComponent(self._btnParty, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnParty);
	self._onClickBtnAddGuild = function(go) self:_OnClickBtnAddGuild(self) end
	UIUtil.GetComponent(self._btnAddGuild, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtnAddGuild);
end
function PlayerMsgPanel:_Dispose()
	self:_DisposeListener();
	self:_DisposeReference();
end
function PlayerMsgPanel:_DisposeReference()
	
end
function PlayerMsgPanel:_DisposeListener()
	UIUtil.GetComponent(self._trsInfo, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickClose = nil;
	
	UIUtil.GetComponent(self._btnDetail, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnDetail = nil;
	UIUtil.GetComponent(self._btnChat, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnChat = nil;
	UIUtil.GetComponent(self._btnFriend, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnFriend = nil;
	UIUtil.GetComponent(self._btnParty, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnParty = nil;
	UIUtil.GetComponent(self._btnAddGuild, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtnAddGuild = nil;
end

function PlayerMsgPanel:_OnClickClose()
	self._trsContent.gameObject:SetActive(false)
end
function PlayerMsgPanel:_OnClickBtnDetail()
	--log( "_OnClickBtnDetail:pid=" .. self.pid)
	ModuleManager.SendNotification(OtherInfoNotes.OPEN_INFO_PANEL, self.pid);
	self:_OnClickClose()
end
function PlayerMsgPanel:_OnClickBtnChat()
	--log( "_OnClickBtnChat:pid=" .. self.pid)
	FriendDataManager.TryOpenCharUI(self.pid)
	self:_OnClickClose()
end
function PlayerMsgPanel:_OnClickBtnFriend()
	--log( "_OnClickBtnFriend:pid=" .. self.pid)
	AddFriendsProxy.TryAddFriend(self.pid)
	self:_OnClickClose()
end
function PlayerMsgPanel:_OnClickBtnParty()
	--log( "_OnClickBtnParty:pid=" .. self.pid)
	FriendProxy.TryInviteToTeam(self.pid,self.data.name)
	self:_OnClickClose()
end
function PlayerMsgPanel:_OnClickBtnAddGuild()
	--log( "_OnClickBtnAddGuild:pid=" .. self.pid)
	--GuildProxy.ReqInvate(self.pid)
	GuildDataManager.InvitatePlayer(self.pid);
	self:_OnClickClose()
end

function PlayerMsgPanel:Show()
	self._trsContent.gameObject:SetActive(true)
end
function PlayerMsgPanel:InitData(data)
	--log(tostring(data.pid).. "," .. data.s_name .. "__" .. data.lv .. "," .. data.k)
	self.data = data  
	self.pid = data.pid
	ChatManager.GetPlayerInfo(self.pid, function(data2)
		self._icoHead.spriteName = data2.kind
		self._txtName.text = data2.name
		self._txtLevel.text = GetLv(data2.level)
		self._imgLevelBg.spriteName = data2.level <= 400 and "levelBg1" or "levelBg2"
		self._imgLevelBg:MakePixelPerfect()
	end)
	local hasGuild = GuildDataManager.InGuild()
	self._btnAddGuild.gameObject:SetActive(hasGuild)
	self._bg.height = hasGuild and 350 or 270
	self._btnGrids:Reposition()
end
