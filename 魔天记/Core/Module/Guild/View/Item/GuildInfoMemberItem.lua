require "Core.Module.Common.UIItem"

GuildInfoMemberItem = UIItem:New();

function GuildInfoMemberItem:_Init()
	
	self._icoLeader = UIUtil.GetChildByName(self.transform, "UISprite", "icoLeader");
	self._txtName = UIUtil.GetChildByName(self.transform, "UILabel", "txtName");
	self._txtLv = UIUtil.GetChildByName(self.transform, "UILabel", "txtLv");
	self._txtType = UIUtil.GetChildByName(self.transform, "UILabel", "txtType");
	self._txtDayNum = UIUtil.GetChildByName(self.transform, "UILabel", "txtDayNum");
	self._txtAllNum = UIUtil.GetChildByName(self.transform, "UILabel", "txtAllNum");
	self._txtStatus = UIUtil.GetChildByName(self.transform, "UILabel", "txtStatus");
	
	self._icoVip = UIUtil.GetChildByName(self.gameObject, "UISprite", "icoVip");
	
	self._onClickBtn = function(go) self:_OnClickBtn(self) end
	UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn);
	
	self:UpdateItem(self.data);
end

function GuildInfoMemberItem:_Dispose()
	UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtn = nil;
end

function GuildInfoMemberItem:UpdateItem(data)
	self.data = data;
	
	if data then
		self._icoLeader.spriteName = "c" .. data.kind;
		self._txtName.text = data.name;
		self._txtLv.text = GetLvDes1(data.level);
		self._txtType.text = LanguageMgr.Get("guild/Identity/" .. data.identity);
		self._txtDayNum.text = data.dkpDay;
		self._txtAllNum.text = data.dkpAll;
		if data:IsOnline() == true then
			self._txtStatus.text = LanguageMgr.Get("time/OL/1")
		else
			self._txtStatus.text = GuildInfoMemberItem.FormatTime(data.offlineTime)
		end
		
		--self._icoVip.spriteName = VIPManager.GetVipIconByVip(data.vip);
        self._icoVip.spriteName = ""
	    local vc = ColorDataManager.Get_Vip(data.vip)
	    self._txtName.text = vc .. self._txtName.text
	else
		self._icoLeader.spriteName = "";
		self._txtName.text = "";
		self._txtLv.text = "";
		self._txtType.text = "";
		self._txtDayNum.text = "";
		self._txtAllNum.text = "";
		self._txtStatus.text = "";
		self._icoVip.spriteName = "";
	end
end

function GuildInfoMemberItem:_OnClickBtn()
	if PlayerManager.playerId ~= self.data.id then
		ModuleManager.SendNotification(GuildNotes.OPEN_GUILD_MEMBER_PANEL, self.data);
	end
end

function GuildInfoMemberItem.FormatTime(time)
	if(time > 15 * 24 * 60 * 60) then
		-- >15天
		return LanguageMgr.Get("time/step/4");
	elseif(time > 24 * 60 * 60) then
		-- >1天
		return LanguageMgr.Get("time/step/3", {t = math.floor(time /(24 * 60 * 60))});
	elseif(time > 60 * 60) then
		-- >1小时
		return LanguageMgr.Get("time/step/2", {t = math.floor(time /(60 * 60))});
	else
		local tmp = math.max(math.floor(time / 60), 1);
		return LanguageMgr.Get("time/step/1", {t = tmp});
	end
end


