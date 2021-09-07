-- -----------------------------
-- 坐骑技能tips
-- hosr
-- -----------------------------
ChildTelnetTips = ChildTelnetTips or BaseClass(BaseTips)

function ChildTelnetTips:__init(model)
    self.model = model
    self.resList = {
        {file = AssetConfig.tips_ride_skill, type = AssetType.Main},
        {file = AssetConfig.attr_icon, type = AssetType.Dep},
        {file = AssetConfig.childtelenticon, type = AssetType.Dep},
        {file = AssetConfig.ride_texture, type = AssetType.Dep},
    }
    self.mgr = TipsManager.Instance
    self.width = 315
    self.height = 20
    self.DefaultSize = Vector2(315, 0)

    self.updateCall = function() self:UnRealUpdate() end
    self.OnHideEvent:Add(function() self:RemoveTime() end)

    self.attrItemList = {}
end

function ChildTelnetTips:__delete()
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

function ChildTelnetTips:RemoveTime()
    self.mgr.updateCall = nil
end

function ChildTelnetTips:UnRealUpdate()
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

function ChildTelnetTips:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.tips_ride_skill))
    self.gameObject.name = "ChildTelnetTips"
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.model.tipsCanvas.transform)
    self.transform.localScale = Vector3.one
    self.transform.localPosition = Vector3.zero

    self.gameObject:GetComponent(Button).onClick:AddListener(function() self.model:Closetips() end)
    self.rect = self.gameObject:GetComponent(RectTransform)

    self.name = self.transform:Find("Name"):GetComponent(Text)
    self.desc = self.transform:Find("Desc"):GetComponent(Text)
    self.lev = self.transform:Find("SkillIcon/Lev/Text"):GetComponent(Text)
    self.transform:Find("SkillIcon/Lev").gameObject:SetActive(false)

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
function ChildTelnetTips:UpdateInfo(info)
	self.data = info
	self.skillData = DataSkill.data_child_telent[string.format("%s_%s", self.data.id, self.data.lev)]

	self.name.text = self.skillData.name
	self.desc.text = string.format(TI18N("等级:<color='#ffff00'> %s</color>"), self.skillData.lev)
	self.lev.text = RideEumn.SkillLevShow[self.skillData.lev]

	self.slot:SetAll(Skilltype.childtelent, self.skillData)
	self.slot.gameObject:SetActive(true)
	self.slot:ShowLevel(false)
	self.slot:ShowName(false)

	self.height = 130 + self:UpdateAttr() + 10
	self.mgr.updateCall = self.updateCall

	self.rect.sizeDelta = Vector2(self.width, self.height)
end

function ChildTelnetTips:UpdateAttr()
	local h = 0
	local skill = self.skillData
	self.attrItemList[1].txt.text = skill.desc
	self.attrItemList[1].icon.sprite = self.assetWrapper:GetSprite(AssetConfig.attr_icon, "AttrIcon4")
	self.attrItemList[1].icon.transform.localPosition = Vector2(-8, 3)
	self.attrItemList[1].icon:SetNativeSize()
	self.attrItemList[1].obj:SetActive(true)
	self.attrItemList[1].rect.sizeDelta = Vector2(235, self.attrItemList[1].txt.preferredHeight)
	self.attrItemList[1].rect.anchoredPosition = Vector2(0, -h)
	h = h + self.attrItemList[1].txt.preferredHeight + 15

	self.attrItemList[2].obj:SetActive(false)
	self.attrItemList[3].obj:SetActive(false)
	self.attrItemList[4].obj:SetActive(false)

	return h
end