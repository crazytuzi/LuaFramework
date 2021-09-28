require "Core.Module.Common.UIItem"

local WildBossVipFloatItem = UIItem:New();

function WildBossVipFloatItem:_Init()
    self._icon = UIUtil.GetChildByName(self.transform, "UISprite", "icon");
    self._txtName = UIUtil.GetChildByName(self.transform, "UILabel", "name");
    self._txtTime = UIUtil.GetChildByName(self.transform, "UILabel", "time");
    self._txtLevel = UIUtil.GetChildByName(self.transform, "UILabel", "level");
    self._txtIsRec = UIUtil.GetChildByName(self.transform, "UILabel", "txtIsRec");
    self._icoDead = UIUtil.GetChildByName(self.transform, "UISprite", "icoDead");
    if self._txtTime then self._txtTime.gameObject:SetActive(false); end
    if self._txtIsRec then self._txtIsRec.gameObject:SetActive(false); end
    self._icoDead.alpha = 0;

    self._btnGo = UIUtil.GetChildByName(self.transform, "UIButton", "btnGo");
    self._btnGo.gameObject:SetActive(false);

    self._onClick = function(go) self:_OnClick(self) end
	UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClick);
	UIUtil.GetComponent(self._btnGo, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClick);

    self._timer = Timer.New(function(val) self:_OnUpdate(val) end, 1, - 1);
	self._timer:Start();

	self:UpdateItem(self.data);
end

function WildBossVipFloatItem:_Dispose()
    self._icon = nil;
    self._txtName = nil;
    self._txtTime = nil;
    self._txtLevel = nil;
    self._txtIsRec = nil;

    UIUtil.GetComponent(self._btnGo, "LuaUIEventListener"):RemoveDelegate("OnClick");
    UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClick = nil;

    if(self._timer) then
		self._timer:Stop();
		self._timer = nil;
	end
end

function WildBossVipFloatItem:UpdateItem(data)
    self.data = data;
    if (data) then
		local lv = PlayerManager.GetPlayerLevel();
		self._txtName.text = self.data.name
		self._txtLevel.text = GetLvDes(self.data.monsterInfo.level)
		self._icon.spriteName = self.data.monsterInfo.icon_id

        if self._txtIsRec then
			local showRec = lv >= self.data.rec_level_lower and lv <= self.data.rec_level_upper;
			self._txtIsRec.gameObject:SetActive(showRec);
		end

		ColorDataManager.SetGray(self._icon)
		self._icoDead.alpha = 1;
		self._timer:Pause(false)
		self:_OnUpdate();
    end
end

function WildBossVipFloatItem:_OnUpdate()
	if self.data and self.data.rt then
		local time = GetTime()
		if(time > self.data.rt) then
			self._txtTime.gameObject:SetActive(false);
			self._btnGo.gameObject:SetActive(true);
			self._timer:Pause(true)
	        ColorDataManager.UnSetGray(self._icon)
	        self._icoDead.alpha = 0;
		else
			if not self._txtTime.gameObject.activeSelf then
				self._txtTime.gameObject:SetActive(true);
				self._btnGo.gameObject:SetActive(false);
			end
			self._txtTime.text = LanguageMgr.Get("WildBossVipFloatItem/time", {time = GetTimeByStr1((self.data.rt - time))});
		end
	end
end

function WildBossVipFloatItem:_OnClick()
	if self.data then
		local moveToPos = Convert.PointFromServer(self.data.boss_guide_point[1], 0, self.data.boss_guide_point[2]);
		HeroController:GetInstance():MoveTo(moveToPos, GameSceneManager.map.info.id);
	end
end

return WildBossVipFloatItem;
