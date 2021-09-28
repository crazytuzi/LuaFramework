require "Core.Module.Common.UIItem"
PVPPlayerItem = class("PVPPlayerItem", UIItem);

function PVPPlayerItem:New()
	self = {};
	setmetatable(self, {__index = PVPPlayerItem});
	return self
end


function PVPPlayerItem:_Init()
	self:_InitReference();
	self:_InitListener();
	self:UpdateItem(self.data)
end

function PVPPlayerItem:_InitReference()
	--    local txts = UIUtil.GetComponentsInChildren(self.gameObject, "UILabel");
	--    self._txtChange = UIUtil.GetChildInComponents(txts, "txtChange");
	--    self._txtOwnerDes = UIUtil.GetChildInComponents(txts, "txtOwnerDes");
	--    self._txtSkillName = UIUtil.GetChildInComponents(txts, "txtSkillName");
	--    self._txtSkillLevel = UIUtil.GetChildInComponents(txts, "txtSkillLevel");
	--    self._btnChange = UIUtil.GetChildByName(self.transform, "UIButton", "btnChange")
	--    self._imgIcon = UIUtil.GetChildByName(self.transform, "UISprite", "skillIcon")
	--    self._imgQuality = UIUtil.GetChildByName(self.transform, "UISprite", "skillQuality")
	self._imgIcon = UIUtil.GetChildByName(self.transform, "UISprite", "icon")
	self._imgRank = UIUtil.GetChildByName(self.transform, "UISprite", "rankBg")
	self._txtRank = UIUtil.GetChildByName(self.transform, "UILabel", "rank")
	self._txtFight = UIUtil.GetChildByName(self.transform, "UILabel", "fight")
	self._txtName = UIUtil.GetChildByName(self.transform, "UILabel", "name")
	self._txtLevel = UIUtil.GetChildByName(self.transform, "UILabel", "level")
	self._imgLevelBg = UIUtil.GetChildByName(self.transform,"UISprite","levelBg")
	self._goMyRank = UIUtil.GetChildByName(self.transform, "goMyRank").gameObject
	self._goSelfTag = UIUtil.GetChildByName(self.transform, "goSelfTag").gameObject
	self._boxCollider = UIUtil.GetComponent(self.gameObject, "BoxCollider")
	--    self._imgQuality = UIUtil.GetChildByName(self.transform, "UISprite", "quality")
end

function PVPPlayerItem:_InitListener()
	self._onBtnItemClick = function(go) self:_OnBtnItemClick(self) end
	UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RegisterDelegate("OnClick", self._onBtnItemClick);
end

function PVPPlayerItem:_OnBtnItemClick()
	if(self.data.playerId == HeroController.GetInstance().id) then return end
	PVPProxy.SetSelectData(self.data)
end

function PVPPlayerItem:UpdateItem(data)
	if(data == nil) then return end
	self.data = data
	self._txtRank.text = tostring(data.rank)
	self._imgRank.spriteName =(data.rank <= 3) and "speRank" or "normalRank"
	if(self.data.playerId == HeroController.GetInstance().id) then
		self._boxCollider.enabled = false
		self._goMyRank:SetActive(true)
		self._goSelfTag:SetActive(true)
	else
		self._boxCollider.enabled = true
		self._goMyRank:SetActive(false)
		self._goSelfTag:SetActive(false)
	end
	--    self._
	self._txtName.text = tostring(data.name)
	self._imgIcon.spriteName = ConfigManager.GetCareerByKind(data.kind).icon_id
	self._txtLevel.text = GetLv(data.level)
	self._imgLevelBg.spriteName = data.level <=400 and "levelBg1" or "levelBg2"
	self._txtFight.text = tostring(data.power)
end

function PVPPlayerItem:_Dispose()
	UIUtil.GetComponent(self.gameObject, "LuaUIEventListener"):RemoveDelegate("OnClick");
	self._onBtnItemClick = nil;
end

