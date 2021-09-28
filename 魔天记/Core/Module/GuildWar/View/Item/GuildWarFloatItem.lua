require "Core.Module.Common.UIItem"

local GuildWarFloatItem = UIItem:New();

function GuildWarFloatItem:_Init()
    self._icon = UIUtil.GetChildByName(self.transform, "UISprite", "icon");
    self._txtName = UIUtil.GetChildByName(self.transform, "UILabel", "name");
    self._txtStatus = UIUtil.GetChildByName(self.transform, "UILabel", "status");

    self._btnGo = UIUtil.GetChildByName(self.transform, "UIButton", "btnGo");
    self._btnGo.gameObject:SetActive(false);

    self._onClick = function(go) self:_OnClick(self) end
	UIUtil.GetComponent(self._btnGo, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClick);

    --self._timer = Timer.New(function(val) self:_OnUpdate(val) end, 1, - 1);
	--self._timer:Start();

	self:SetContent(self.data);
end

function GuildWarFloatItem:_Dispose()
    self._icon = nil;
    self._txtName = nil; 
    self._txtStatus = nil;

    UIUtil.GetComponent(self._btnGo, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClick = nil;
	--[[
    if(self._timer) then
		self._timer:Stop();
		self._timer = nil;
	end
	]]
end

function GuildWarFloatItem:SetContent()
	if self.data then
		local monsterInfo = ConfigManager.GetMonById(self.data.mid);
		self._txtName.text = monsterInfo.name
		self._icon.spriteName = monsterInfo.icon_id
	end
end

function GuildWarFloatItem:UpdateItem(data)
    if (data) then
    	self:SetContent();
		self:UpdateStatus(data)
		self.data = data;
	else
		self._txtName.text = "";
		self._txtStatus.text = "";
		self._icon.spriteName = "";
    end
end

function GuildWarFloatItem:UpdateStatus(data)
	if data.info == nil or data.info.hp <= 0 then
		ColorDataManager.SetGray(self._icon)
		--self._txtStatus.text = LanguageMgr.Get("GuildWar/Float/st/0");
		self._txtStatus.text = "";
		self._btnGo.gameObject:SetActive(false);
	else
		ColorDataManager.UnSetGray(self._icon);
		local per = math.floor(data.info.hp / data.info.hp_max * 1000) / 10;
		self._txtStatus.text = LanguageMgr.Get("GuildWar/Float/st/1", {per = per});
		self._btnGo.gameObject:SetActive(true);
	end
end

function GuildWarFloatItem:_OnClick()
	if self.data then
		local cfg = ConfigManager.GetConfig(ConfigManager.CONFIGNAME_GUILDWAR_POS)[self.data.posId];
		local moveToPos = Convert.PointFromServer(cfg.x, 0, cfg.z);
		HeroController:GetInstance():MoveTo(moveToPos, GameSceneManager.map.info.id);
	end
end

return GuildWarFloatItem;
