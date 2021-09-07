-- ------------------------------
-- 坐骑获得新技能
-- hosr
-- ------------------------------
RideGetSkillPanel = RideGetSkillPanel or BaseClass(BasePanel)

function RideGetSkillPanel:__init(parent)
	self.parent = parent
    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
	self.resList = {
		{file = AssetConfig.ridegetskill, type = AssetType.Main},
		{file = AssetConfig.ride_texture, type = AssetType.Dep},
		{file = AssetConfig.rideattricon, type = AssetType.Dep},
	}
	self.attrItemList = {}
end

function RideGetSkillPanel:__delete()
	for i,v in ipairs(self.attrItemList) do
		v.icon.sprite = nil
	end

	if self.desc ~= nil then
		self.desc:DeleteMe()
		self.desc = nil
	end

	self.icon.sprite = nil
	self.flyIcon.sprite = nil
end

function RideGetSkillPanel:OnShow()
	self.currentSkill = self.openArgs
	self.currentSkillData = DataSkill.data_mount_skill[string.format("%s_%s", self.currentSkill.skill_id, self.currentSkill.skill_lev)]
	self:Update()
end

function RideGetSkillPanel:OnHide()
end

function RideGetSkillPanel:Close()
	self.parent:CloseGetSkill()
end

function RideGetSkillPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.ridegetskill))
    self.gameObject.name = "RideGetSkillPanel"
    UIUtils.AddUIChild(self.parent.parent.gameObject, self.gameObject)
    self.transform = self.gameObject.transform

    self.panel = self.transform:Find("Panel"):GetComponent(Image)
    self.flyIcon = self.transform:Find("FlyIcon"):GetComponent(Image)

    self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:Fly() end)

    self.main = self.transform:Find("Main")
    self.main:Find("CloseButton"):GetComponent(Button).onClick:AddListener(function() self:Fly() end)

  	self.desc = MsgItemExt.New(self.main:Find("Desc1"):GetComponent(Text), 330, 18, 22)
  	self.desc:SetData(TI18N("恭喜！坐骑突破获得新技能{face_1,56}"))
  	self.skillIcon = self.main:Find("SkillIcon").gameObject
  	self.icon = self.main:Find("SkillIcon"):GetComponent(Image)
  	self.name = self.main:Find("SkillIcon/Name"):GetComponent(Text)
  	self.lev = self.main:Find("SkillIcon/Lev/Text"):GetComponent(Text)

  	self.flyIconLoader = SingleIconLoader.New(self.flyIcon.gameObject)
  	self.iconLoader = SingleIconLoader.New(self.icon.gameObject)

   	local len = self.main:Find("AttrContainer").childCount
    for i = 1, len do
    	local item = self.main:Find("AttrContainer"):GetChild(i - 1)
    	item.gameObject:SetActive(false)
    	local txt = item:GetComponent(Text)
    	local icon = item:Find("Icon"):GetComponent(Image)
    	table.insert(self.attrItemList, {obj = item.gameObject, txt = txt, icon = icon, rect = item:GetComponent(RectTransform)})
    end

    self:OnShow()
end

function RideGetSkillPanel:Update()
	-- self.flyIcon.sprite = self.assetWrapper:GetSprite(AssetConfig.skillIcon_ride, tostring(self.currentSkillData.icon))
	-- self.icon.sprite = self.assetWrapper:GetSprite(AssetConfig.skillIcon_ride, tostring(self.currentSkillData.icon))
	self.flyIconLoader:SetSprite(SingleIconType.SkillIcon, tostring(self.currentSkillData.icon))
	self.iconLoader:SetSprite(SingleIconType.SkillIcon, tostring(self.currentSkillData.icon))
	self.lev.text = RideEumn.SkillLevShow[self.currentSkill.skill_lev]
	self.name.text = RideEumn.ColorName(self.currentSkill.skill_lev, self.currentSkillData.name)

	self:UpdateAttr()
end

function RideGetSkillPanel:UpdateAttr()
	local h = 0
	local skill = self.currentSkillData
	if skill.desc1_type ~= 0 then
		self.attrItemList[1].txt.text = skill.desc1
		self.attrItemList[1].icon.sprite = self.assetWrapper:GetSprite(AssetConfig.rideattricon, string.format("RideAttrIcon%s", skill.desc1_type))
		self.attrItemList[1].obj:SetActive(true)
		self.attrItemList[1].rect.sizeDelta = Vector2(230, self.attrItemList[1].txt.preferredHeight)
		self.attrItemList[1].rect.anchoredPosition = Vector2(0, -h)
		h = h + self.attrItemList[1].txt.preferredHeight + 15
	else
		self.attrItemList[1].obj:SetActive(false)
	end

	if skill.desc2_type ~= 0 then
		self.attrItemList[2].txt.text = skill.desc2
		self.attrItemList[2].icon.sprite = self.assetWrapper:GetSprite(AssetConfig.rideattricon, string.format("RideAttrIcon%s", skill.desc2_type))
		self.attrItemList[2].obj:SetActive(true)
		self.attrItemList[2].rect.sizeDelta = Vector2(230, self.attrItemList[2].txt.preferredHeight)
		self.attrItemList[2].rect.anchoredPosition = Vector2(0, -h)
		h = h + self.attrItemList[2].txt.preferredHeight + 15
	else
		self.attrItemList[2].obj:SetActive(false)
	end

	if skill.desc3_type ~= 0 then
		self.attrItemList[3].txt.text = skill.desc3
		self.attrItemList[3].icon.sprite = self.assetWrapper:GetSprite(AssetConfig.rideattricon, string.format("RideAttrIcon%s", skill.desc3_type))
		self.attrItemList[3].obj:SetActive(true)
		self.attrItemList[3].rect.sizeDelta = Vector2(230, self.attrItemList[3].txt.preferredHeight)
		self.attrItemList[3].rect.anchoredPosition = Vector2(0, -h)
		h = h + self.attrItemList[3].txt.preferredHeight + 15
	else
		self.attrItemList[3].obj:SetActive(false)
	end

	if skill.desc4_type ~= 0 then
		self.attrItemList[4].txt.text = skill.desc4
		self.attrItemList[4].icon.sprite = self.assetWrapper:GetSprite(AssetConfig.rideattricon, string.format("RideAttrIcon%s", skill.desc4_type))
		self.attrItemList[4].obj:SetActive(true)
		self.attrItemList[4].rect.sizeDelta = Vector2(230, self.attrItemList[4].txt.preferredHeight)
		self.attrItemList[4].rect.anchoredPosition = Vector2(0, -h)
		h = h + self.attrItemList[4].txt.preferredHeight + 15
	else
		self.attrItemList[4].obj:SetActive(false)
	end
end

function RideGetSkillPanel:Fly()
	if self.tweeing then
		return
	end

	self.main.gameObject:SetActive(false)
	self.panel.color = Color(0,0,0,0)
	self.flyIcon.gameObject:SetActive(true)

	self.tweeing = true
	Tween.Instance:MoveLocal(self.flyIcon.gameObject, Vector3(355, 41, 0), 0.8, function() self:FlyEnd() end, LeanTweenType.linear)
	Tween.Instance:Scale(self.flyIcon.gameObject, Vector3.one * 0.6, 0.8, nil, LeanTweenType.linear)
end

function RideGetSkillPanel:FlyEnd()
	self.tweeing = false
	self:Close()
end