-- -----------------------------
-- 坐骑技能tips
-- hosr
-- -----------------------------
RideSkillTips = RideSkillTips or BaseClass(BaseTips)

function RideSkillTips:__init(model)
    self.model = model
    self.resList = {
        {file = AssetConfig.tips_ride_skill, type = AssetType.Main},
        {file = AssetConfig.rideattricon, type = AssetType.Dep},
    }
    self.mgr = TipsManager.Instance
    self.width = 315
    self.height = 20
    self.DefaultSize = Vector2(315, 0)

    self.updateCall = function() self:UnRealUpdate() end
    self.OnHideEvent:Add(function() self:RemoveTime() end)

    self.attrItemList = {}
end

function RideSkillTips:__delete()
	for i,v in ipairs(self.attrItemList) do
		v.icon.sprite = nil
	end
	self.attrItemList = nil

	if self.slot ~= nil then
		self.slot:DeleteMe()
		self.slot = nil
	end

    self.mgr = nil
    self.height = 20
    self:RemoveTime()
end

function RideSkillTips:RemoveTime()
    self.mgr.updateCall = nil
end

function RideSkillTips:UnRealUpdate()
    if Input.touchCount > 0 and Input.GetTouch(0).phase == TouchPhase.Began then
        local v2 = Input.GetTouch(0).position
        if self.model:Checkvalidregion(v2.x, v2.y) == false then
            self.model:Closetips()
        end
    end

    if Input.GetMouseButtonDown(0) then
        local v2 = Input.mousePosition
        if self.model:Checkvalidregion(v2.x, v2.y) == false then
            self.model:Closetips()
        end
    end
end

function RideSkillTips:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.tips_ride_skill))
    self.gameObject.name = "RideSkillTips"
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.model.tipsCanvas.transform)
    self.transform.localScale = Vector3.one
    self.transform.localPosition = Vector3.zero

    self.gameObject:GetComponent(Button).onClick:AddListener(function() self.model:Closetips() end)
    self.rect = self.gameObject:GetComponent(RectTransform)

    self.name = self.transform:Find("Name"):GetComponent(Text)
    self.desc = self.transform:Find("Desc"):GetComponent(Text)
    self.lev = self.transform:Find("SkillIcon/Lev/Text"):GetComponent(Text)

    self.slot = SkillSlot.New()
    self.slot.transform:SetParent(self.transform:Find("SkillIcon"))
    self.slot.transform.localScale = Vector3.one
    self.slot.transform.localPosition = Vector3.zero
    self.slot.transform:SetAsFirstSibling()
    self.slot:SetNotips()

    local len = self.transform:Find("AttrContainer").childCount
    for i = 1, len do
    	local item = self.transform:Find("AttrContainer"):GetChild(i - 1)
    	item.gameObject:SetActive(false)
    	local txt = item:GetComponent(Text)
    	local icon = item:Find("Icon"):GetComponent(Image)
    	table.insert(self.attrItemList, {obj = item.gameObject, txt = txt, icon = icon, rect = item:GetComponent(RectTransform)})
    end
end

-- info = DataSkill.data_mount_skill
function RideSkillTips:UpdateInfo(info)
	self.data = info

	self.name.text = RideEumn.ColorName(self.data.lev, self.data.name)
	self.desc.text = string.format(TI18N("作用对象:<color='#ffff00'>%s</color>"), RideEumn.SkillEffectTypeName[self.data.effect_type])
	self.lev.text = RideEumn.SkillLevShow[self.data.lev]

	self.slot:SetAll(Skilltype.rideskill, info)
	self.slot.gameObject:SetActive(true)
	self.slot:ShowLevel(false)
	self.slot:ShowName(false)

	self.height = 130 + self:UpdateAttr() + 10
	self.mgr.updateCall = self.updateCall

	self.rect.sizeDelta = Vector2(self.width, self.height)
end

function RideSkillTips:UpdateAttr()
	local h = 0
	local skill = self.data
	if skill.desc1_type ~= 0 then
		self.attrItemList[1].txt.text = skill.desc1
		self.attrItemList[1].icon.sprite = self.assetWrapper:GetSprite(AssetConfig.rideattricon, string.format("RideAttrIcon%s", skill.desc1_type))
		self.attrItemList[1].obj:SetActive(true)
		self.attrItemList[1].rect.sizeDelta = Vector2(235, self.attrItemList[1].txt.preferredHeight)
		self.attrItemList[1].rect.anchoredPosition = Vector2(0, -h)
		h = h + self.attrItemList[1].txt.preferredHeight + 15
	else
		self.attrItemList[1].obj:SetActive(false)
	end

	if skill.desc2_type ~= 0 then
		self.attrItemList[2].txt.text = skill.desc2
		self.attrItemList[2].icon.sprite = self.assetWrapper:GetSprite(AssetConfig.rideattricon, string.format("RideAttrIcon%s", skill.desc2_type))
		self.attrItemList[2].obj:SetActive(true)
		self.attrItemList[2].rect.sizeDelta = Vector2(235, self.attrItemList[2].txt.preferredHeight)
		self.attrItemList[2].rect.anchoredPosition = Vector2(0, -h)
		h = h + self.attrItemList[2].txt.preferredHeight + 15
	else
		self.attrItemList[2].obj:SetActive(false)
	end

	if skill.desc3_type ~= 0 then
		self.attrItemList[3].txt.text = skill.desc3
		self.attrItemList[3].icon.sprite = self.assetWrapper:GetSprite(AssetConfig.rideattricon, string.format("RideAttrIcon%s", skill.desc3_type))
		self.attrItemList[3].obj:SetActive(true)
		self.attrItemList[3].rect.sizeDelta = Vector2(235, self.attrItemList[3].txt.preferredHeight)
		self.attrItemList[3].rect.anchoredPosition = Vector2(0, -h)
		h = h + self.attrItemList[3].txt.preferredHeight + 15
	else
		self.attrItemList[3].obj:SetActive(false)
	end

	if skill.desc4_type ~= 0 then
		self.attrItemList[4].txt.text = skill.desc4
		self.attrItemList[4].icon.sprite = self.assetWrapper:GetSprite(AssetConfig.rideattricon, string.format("RideAttrIcon%s", skill.desc4_type))
		self.attrItemList[4].obj:SetActive(true)
		self.attrItemList[4].rect.sizeDelta = Vector2(235, self.attrItemList[4].txt.preferredHeight)
		self.attrItemList[4].rect.anchoredPosition = Vector2(0, -h)
		h = h + self.attrItemList[4].txt.preferredHeight + 15
	else
		self.attrItemList[4].obj:SetActive(false)
	end

	return h
end