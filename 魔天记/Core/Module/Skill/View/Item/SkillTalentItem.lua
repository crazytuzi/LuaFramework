SkillTalentItem = class("SkillTalentItem");

function SkillTalentItem:Init(tr)
	self._transform = tr;
	self:_Init();
end

function SkillTalentItem:_Init()
	self._trsContent = UIUtil.GetChildByName(self._transform, "Transform", "content");
	self._icoLock = UIUtil.GetChildByName(self._transform, "UISprite", "icoLock");
	self._txtLock = UIUtil.GetChildByName(self._icoLock, "UILabel", "txtLock");
	self._icon = UIUtil.GetChildByName(self._transform, "UISprite", "icon");
	
	self._txtName = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtName");
	self._txtNum = UIUtil.GetChildByName(self._trsContent, "UILabel", "txtNum");
	self._btn1 = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn1");
	self._btn2 = UIUtil.GetChildByName(self._trsContent, "UIButton", "btn2");
	
	self._onReduce = function(go) self:_OnReduce() end
	UIUtil.GetComponent(self._btn1, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onReduce);
	
	self._onAdd = function(go) self:_OnAdd() end
	UIUtil.GetComponent(self._btn2, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onAdd);
	
	self._onClick = function(go) self:_OnClick() end
	UIUtil.GetComponent(self._transform, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClick);
end

function SkillTalentItem:Dispose()
	UIUtil.GetComponent(self._btn1, "LuaUIEventListener"):RemoveDelegate("OnClick");
	UIUtil.GetComponent(self._btn2, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onAdd = nil;
	self._onReduce = nil;
	
	UIUtil.GetComponent(self._transform, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClick = nil;
end

function SkillTalentItem:SetIndex(idx)
	self._idx = idx;
end

function SkillTalentItem:SetData(data, lv)
	self._data = data;
	self._lv = lv;
	self:UpdateDisplay();
end

function SkillTalentItem:SetActStaus(bool)
	if bool then
		ColorDataManager.UnSetGray(self._icon);
	else
		ColorDataManager.SetGray(self._icon);
	end
end

function SkillTalentItem:UpdateDisplay()
	local myinfo = PlayerManager.GetPlayerInfo();
	local careerCfg = ConfigManager.GetCareerByKind(myinfo.kind);
	local needLv = careerCfg.talentLv[self._idx];
	
	local tId = self._data;
	if myinfo.level >= needLv then
		self._icoLock.gameObject:SetActive(false);
		--self._icon.gameObject:SetActive(true);
		self._isLock = false;
		if tId > 0 then
			self._trsContent.gameObject:SetActive(true);
			local cfg = SkillManager.GetTalentCfg(tId);
			self._txtName.text = cfg.name;
			self._txtNum.text = self._lv;
			self._icon.spriteName = cfg.icon;
		else
			self._txtName.text = "";
			self._txtNum.text = 0;
			self._icon.spriteName = "";
			self._trsContent.gameObject:SetActive(false);
		end
	else
		self._txtLock.text = LanguageMgr.Get("skill/talent/unlock", {lv = GetLvDes1(needLv)});
		self._trsContent.gameObject:SetActive(false);
		--self._icon.gameObject:SetActive(false);
		self._icon.spriteName = "";
		self._icoLock.gameObject:SetActive(true);
		self._isLock = true;
		self._txtName.text = "";
		self._txtNum.text = "";
		--self._icon.spriteName = "";
	end
end

function SkillTalentItem:_OnAdd()
	if self._isLock then
		return;
	end
	MessageManager.Dispatch(SkillNotes, SkillNotes.EVENT_TALENT_POINT_CHG, {idx = self._idx, num = 1});
end

function SkillTalentItem:_OnReduce()
	if self._isLock then
		return;
	end
	MessageManager.Dispatch(SkillNotes, SkillNotes.EVENT_TALENT_POINT_CHG, {idx = self._idx, num = - 1});
end

function SkillTalentItem:_OnClick()
	MessageManager.Dispatch(SkillNotes, SkillNotes.EVENT_TALENT_CLICK, self._idx);
end 