require "Core.Module.Common.UIItem"

GuildInfoOLMemberItem = UIItem:New();

function GuildInfoOLMemberItem:_Init()
	self._bg = UIUtil.GetChildByName(self.transform, "UISprite", "bg");
	self._icoLeader = UIUtil.GetChildByName(self.transform, "UISprite", "icoLeader");
	self._txtName = UIUtil.GetChildByName(self.transform, "UILabel", "txtName");
	self._txtLv = UIUtil.GetChildByName(self.transform, "UILabel", "txtLv");
	self._txtType = UIUtil.GetChildByName(self.transform, "UILabel", "txtType");
	self._txtNum = UIUtil.GetChildByName(self.transform, "UILabel", "txtNum");
	
	self._icoVip = UIUtil.GetChildByName(self.gameObject, "UISprite", "icoVip");
	
	self._onClickBtn = function(go) self:_OnClickBtn(self) end
	UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn);
	
	self:UpdateItem(self.data);
end

function GuildInfoOLMemberItem:_Dispose()
	UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtn = nil;
end

function GuildInfoOLMemberItem:UpdateItem(data)
	self.data = data;
	
	if data then
		self._icoLeader.spriteName = "c" .. data.kind;
		self._txtName.text = data.name;
		self._txtLv.text = GetLvDes1(data.level);
		self._txtType.text = LanguageMgr.Get("guild/Identity/" .. data.identity);
		self._txtNum.text = data.dkpDay;
		self._bg.alpha = data.id == PlayerManager.playerId and 1 or 0.5;
		
		--self._icoVip.spriteName = VIPManager.GetVipIconByVip(data.vip);
        self._icoVip.spriteName = ""
	    local vc = ColorDataManager.Get_Vip(data.vip)
	    self._txtName.text = vc .. self._txtName.text
	else
		self._icoLeader.spriteName = "";
		self._txtName.text = "";
		self._txtLv.text = "";
		self._txtType.text = "";
		self._txtNum.text = "";
		self._icoVip.spriteName = "";
	end
end

function GuildInfoOLMemberItem:_OnClickBtn()
	if PlayerManager.playerId ~= self.data.id then
		ModuleManager.SendNotification(GuildNotes.OPEN_GUILD_MEMBER_PANEL, self.data);
	end
end 