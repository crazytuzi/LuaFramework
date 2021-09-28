require "Core.Module.Common.UIItem"

CareerItem = UIItem:New();

function CareerItem:_Init()
	
	self._trSelectedUI = UIUtil.GetChildByName(self.gameObject, "SelectedUI");
	self._trCreateUI = UIUtil.GetChildByName(self.gameObject, "CreateUI");
	
	self._txtHeroName = UIUtil.GetChildByName(self._trSelectedUI, "UILabel", "HeroName");
	self._txtHeroKind = UIUtil.GetChildByName(self._trSelectedUI, "UILabel", "HeroKind");
	self._txtHeroLevel = UIUtil.GetChildByName(self._trSelectedUI, "UILabel", "HeroLevel");
	
	self.bg = UIUtil.GetChildByName(self._trSelectedUI, "Transform", "bgTog/bg");
	self.bg2 = UIUtil.GetChildByName(self._trSelectedUI, "Transform", "bgTog/bg2");
	self._imgLevelBg = UIUtil.GetChildByName(self._trSelectedUI, "UISprite", "lvBg")
	self._imgHeroIcon = UIUtil.GetChildByName(self._trSelectedUI, "UISprite", "heroIcon");
	
	self._btnAddHero = UIUtil.GetChildByName(self._trCreateUI, "UIButton", "BtnAddHero");
	
	self._onClickBtn = function(go) self:_OnClickBtn(self) end
	UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onClickBtn);
	
	self._onCreateClickBtn = function(go) self:_OnCreateClickBtn(self) end
	UIUtil.GetComponent(self._btnAddHero, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onCreateClickBtn);
	
	self:SetSelect(false);
	self.selected = false;
end

function CareerItem:SetSelect(v)
	self.bg.gameObject:SetActive(v == false);
	self.bg2.gameObject:SetActive(v == true);
	self.selected = v;
	self:UpdateDisplay();
end

function CareerItem:_OnClickBtn()
	ModuleManager.SendNotification(SelectRoleNotes.CAREERITEM_CHANGE, self.data);
end

function CareerItem:_OnCreateClickBtn()
	ModuleManager.SendNotification(SelectRoleNotes.CLOSE_SELECTROLE_PANEL);
	ModuleManager.SendNotification(SelectRoleNotes.OPEN_CREATEROLEPANEL);
end

-- 设置成创建角色 按钮
function CareerItem:SetForCreateRolePanel()
	self._trSelectedUI.gameObject:SetActive(false);
	self._trCreateUI.gameObject:SetActive(true);
end

function CareerItem:SetData(info)
	self.data = info;
	
	self._imgHeroIcon.spriteName = info.kind;
	
	self._txtHeroName.text = info.name;
	self._txtHeroKind.text = ConfigManager.GetCareerByKind(info.kind).career;
	self._txtHeroLevel.text = GetLv(info.level);
	self._imgLevelBg.spriteName = info.level <= 400 and "levelBg1" or "levelBg2"
	self._imgLevelBg:MakePixelPerfect()
end

function CareerItem:UpdateDisplay()
	self._txtHeroName.gameObject:SetActive(self.selected);
	self._txtHeroKind.gameObject:SetActive(self.selected);
end

function CareerItem:_Dispose()
	UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onClickBtn = nil;
	
	UIUtil.GetComponent(self._btnAddHero, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onCreateClickBtn = nil;
	
	self._btnAddHero = nil
end 