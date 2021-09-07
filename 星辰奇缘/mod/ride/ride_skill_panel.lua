-- -----------------------------------
-- 坐骑升级
-- hosr
-- -----------------------------------
RideSkillPanel = RideSkillPanel or BaseClass(BasePanel)

function RideSkillPanel:__init(parent)
	self.parent = parent
	self.model = RideManager.Instance.model
    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
    self.effectSucc = nil
    self.succPath = "prefabs/effect/20049.unity3d"
	self.resList = {
		{file = AssetConfig.rideskill, type = AssetType.Main},
		{file = AssetConfig.ride_texture, type = AssetType.Dep},
		{file = AssetConfig.rideattricon, type = AssetType.Dep},
		{file = self.succPath, type = AssetType.Main},
	}

	self.skillItemList = {}
	self.attrItemList = {}
	self.posList = {
		Vector3(-190, 170, 0),
		Vector3(-190, 70, 0),
		Vector3(-190, -30, 0),
		Vector3(-190, -130, 0),
	}

	self.listener = function() self:ProtoUpdate() end
	self.itemChangeListener = function() self:UpdateInfo() end

	self.currSelectItem = nil
end

function RideSkillPanel:__delete()
	if self.slot ~= nil then
	    self.slot:DeleteMe()
	    self.slot = nil
	end

	for i,v in ipairs(self.skillItemList) do
		v:DeleteMe()
	end

	for i,v in ipairs(self.attrItemList) do
		v.icon.sprite = nil
	end
	if self.skillIcon ~= nil then
		self.skillIcon:DeleteMe()
		self.skillIcon = nil
	end
    if self.slotNameExt ~= nil then
        self.slotNameExt:DeleteMe()
        self.slotNameExt = nil
    end
    if self.upgradeButton ~= nil then
        self.upgradeButton:DeleteMe()
        self.upgradeButton = nil
    end

	self.attrItemList = nil
	self.skillItemList = nil
end

function RideSkillPanel:OnShow()
	self:update()
	RideManager.Instance.OnSkillUpdate:Add(self.listener)
	EventMgr.Instance:AddListener(event_name.backpack_item_change, self.itemChangeListener)
end

function RideSkillPanel:OnHide()
	if self.effectSucc ~= nil then
		self.effectSucc:SetActive(false)
	end
	RideManager.Instance.OnSkillUpdate:Remove(self.listener)
	EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.itemChangeListener)
end

function RideSkillPanel:InitPanel()
    self.gameObject  =  GameObject.Instantiate(self:GetPrefab(AssetConfig.rideskill))
    self.gameObject.name = "RideSkillPanel"
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.parent.mainTransform)
    self.transform.localScale = Vector3.one
    self.gameObject:GetComponent(RectTransform).anchoredPosition = Vector2(116, -7)

    self.leftContainer = self.transform:Find("Left/Container")
    self.leftContainerRect = self.leftContainer:GetComponent(RectTransform)

    local len = self.leftContainer.childCount
    for i = 1, len do
    	local index = i
   		local item = RideSkillItem.New(self.leftContainer:GetChild(i - 1).gameObject, self, false, true, index)
   		table.insert(self.skillItemList, item)
    end

    self.arrow = self.transform:Find("Arrow").gameObject

    local right = self.transform:Find("Right")
    self.normal = right:Find("Normal").gameObject
    self.max = right:Find("Max").gameObject

    self.skillIcon = SingleIconLoader.New(right:Find("SkillIcon").gameObject)
    self.lev = right:Find("SkillIcon/Lev/Text"):GetComponent(Text)
    self.skillName = right:Find("SkillName"):GetComponent(Text)
    self.skillDesc = right:Find("SkillDesc"):GetComponent(Text)
    self.slotNameExt = MsgItemExt.New(right:Find("Normal/SlotName"):GetComponent(Text), 100, 15, 17.37)
    self.needTxt = right:Find("Normal/NeedTxt"):GetComponent(Text)
    self.skillPoint = right:Find("SkillPoint"):GetComponent(Text)

    self.slot = ItemSlot.New()
    UIUtils.AddUIChild(right:Find("Normal/Slot").gameObject, self.slot.gameObject)

    len = right:Find("AttrContainer").childCount
    for i = 1, len do
    	local item = right:Find("AttrContainer"):GetChild(i - 1)
    	item.gameObject:SetActive(false)
    	local txt = item:GetComponent(Text)
    	local icon = item:Find("Icon"):GetComponent(Image)
    	table.insert(self.attrItemList, {obj = item.gameObject, txt = txt, icon = icon, rect = item:GetComponent(RectTransform)})
    end

    self.nextPreBtn = right:Find("PreBtn"):GetComponent(Button)
    self.nextPreBtn.onClick:AddListener(function() self:ShowNextLev() end)
    right:Find("AllPreBtn"):GetComponent(Button).onClick:AddListener(function() self.model:OpenRideSkillPreview() end)
    right:Find("WashBtn"):GetComponent(Button).onClick:AddListener(function() self:ClickWash() end)
    self.upgradeButton = BuyButton.New(right:Find("Normal/UpgradeContainer"), TI18N("升级技能"))
	self.upgradeButton.key = "RideSkillUpgrade"
	self.upgradeButton.protoId = 17005
    self.upgradeButton:Show()
    right:Find("Normal/UpBtn"):GetComponent(Button).onClick:AddListener(function() self.upgradeButton:OnClick() end)
    self.red = right:Find("Normal/UpBtn/Red").gameObject
    self.red:SetActive(false)

    self.effectSucc = GameObject.Instantiate(self:GetPrefab(self.succPath))
    self.effectSucc.transform:SetParent(self.transform)
    self.effectSucc.transform.localScale = Vector3.one
    self.effectSucc.transform.localPosition = Vector3.zero
    Utils.ChangeLayersRecursively(self.effectSucc.transform, "UI")
    self.effectSucc:SetActive(false)

    self.init = true
    self:OnShow()
end

-- 协议更新,处理特效
function RideSkillPanel:ProtoUpdate()
	if self.currSelectItem ~= nil and self.currSelectItem.data ~= nil then
		self.effectSucc.transform.localPosition = self.posList[self.currSelectItem.data.skill_index]
		self.effectSucc:SetActive(false)
		self.effectSucc:SetActive(true)
	end

	self:update()
end

function RideSkillPanel:update()
	if self.currSelectItem ~= nil then
		self.currSelectItem:Select(false)
	end
	if self.rideData ~= nil and self.rideData.index ~= self.model.cur_ridedata.index then
		self.currSelectItem = nil
	end
	self.rideData = self.model.cur_ridedata
	if self.rideData == nil then
		Log.Error(TI18N("取不到坐骑数据"))
		return
	end
	self:UpdateSkill()
	self:SelectOne(self.currSelectItem)
end

function RideSkillPanel:UpdateSkill()
	local list = self.rideData.skill_list
	table.sort(list, function(a,b) return a.skill_index < b.skill_index end)

	-- for i = 1, 4 do
	-- 	local v = list[i]
	-- 	self.skillItemList[i]:SetData(v)
	-- end

	-- for i = 5, #self.skillItemList do
	-- 	self.skillItemList[i].gameObject:SetActive(false)
	-- end

	local skill_num = 5
	self.arrow:SetActive(true)

	for i = 1, #list do
		local v = list[i]
		self.skillItemList[i]:SetData(v)
	end

	if #list < skill_num then
		for i = #list+1, skill_num do
			self.skillItemList[i]:SetData(nil)
		end
	end

	if skill_num < #self.skillItemList then
		for i = skill_num+1, #self.skillItemList do
			self.skillItemList[i].gameObject:SetActive(false)
		end
	end

	self.leftContainerRect.sizeDelta = Vector2(100, skill_num * 100)
	-- self.leftContainerRect.sizeDelta = Vector2(100, 400)
end

function RideSkillPanel:SelectOne(data)
	if self.currSelectItem ~= nil then
		self.currSelectItem:Select(false)
	end
	if data == nil then
		self.currSelectItem = self.skillItemList[1]
	else
		self.currSelectItem = data
	end
	self.currSelectItem:Select(true)

	self.levData = DataMount.data_ride_skill_upgrade[self.currSelectItem.data.skill_lev]

	self:UpdateInfo()
	self:UpdateAttr()
end

function RideSkillPanel:UpdateInfo()
	if self.currSelectItem == nil then
		return
	end
	-- self.skillIcon.sprite = self.assetWrapper:GetSprite(AssetConfig.skillIcon_ride, tostring(self.currSelectItem.skillData.icon))
	if self.skillIcon == nil then return end
	self.skillIcon:SetSprite(SingleIconType.SkillIcon, tostring(self.currSelectItem.skillData.icon))
	self.skillName.text = RideEumn.ColorName(self.currSelectItem.data.skill_lev, self.currSelectItem.skillData.name)
	self.lev.text = RideEumn.SkillLevShow[self.currSelectItem.data.skill_lev]
	self.skillPoint.text = string.format(TI18N("技能点:%s/%s"), self.rideData.skill_point, self.rideData.lev)
	self.skillDesc.text = string.format(TI18N("作用对象:<color='#ffff00'>%s</color>"), RideEumn.SkillEffectTypeName[self.currSelectItem.skillData.effect_type])
	self.needTxt.text = string.format(TI18N("消耗技能点:<color='#ffffff'>%s</color>"), 0)

	if self.levData == nil then
		self.max:SetActive(true)
		self.normal:SetActive(false)
    	self.nextPreBtn.gameObject:SetActive(false)
		return
	end

	self.max:SetActive(false)
	self.normal:SetActive(true)

	local list = self.levData.cost
	local baseId = list[1][1]
	local num = list[1][2]
	local has = BackpackManager.Instance:GetItemCount(baseId)

	local itemData = ItemData.New()
  	itemData:SetBase(BaseUtils.copytab(DataItem.data_get[baseId]))
    self.slot:SetAll(itemData)
    self.slot:SetNum(has, num)
    self.slotNameExt:SetData(ColorHelper.color_item_name(itemData.quality, itemData.name))
    self.slotNameExt.contentTrans.anchoredPosition = Vector2(-66.54993 - self.slotNameExt.contentTrans.sizeDelta.x / 2, -31 + self.slotNameExt.contentTrans.sizeDelta.y / 2)
    self.enough = (has >= num)
    self.nextPreBtn.gameObject:SetActive(true)

    self.red:SetActive(false)
	if self.rideData.skill_point < self.levData.point then
		self.needTxt.text = string.format(TI18N("消耗技能点:<color='#ff0000'>%s</color>"), self.levData.point)
	else
		self.needTxt.text = string.format(TI18N("消耗技能点:<color='#ffffff'>%s</color>"), self.levData.point)
		if self.enough then
			self.red:SetActive(true)
		end
	end

    self.upgradeButton:Layout({[baseId] = {need = num}}, function() self:ClickUp() end, function(tab) self:AfterPriceBack(tab) end, {antofreeze = true})
end

function RideSkillPanel:AfterPriceBack(priceTab)
    for _,v in pairs(priceTab) do
        if v.allprice > 0 then
            self.slotNameExt:SetData(string.format("%s{assets_2, %s}", v.allprice, v.assets))
        else
            self.slotNameExt:SetData(string.format("<color='#ff0000'>%s</color>{assets_2, %s}", -v.allprice, v.assets))
        end
        self.slotNameExt.contentTrans.anchoredPosition = Vector2(-66.54993 - self.slotNameExt.contentTrans.sizeDelta.x / 2, -31 + self.slotNameExt.contentTrans.sizeDelta.y / 2)
        break
    end
end

function RideSkillPanel:UpdateAttr()
	local h = 0
	local skill = self.currSelectItem.skillData
	if skill.desc1_type ~= 0 then
		self.attrItemList[1].txt.text = skill.desc1
		self.attrItemList[1].icon.sprite = self.assetWrapper:GetSprite(AssetConfig.rideattricon, string.format("RideAttrIcon%s", skill.desc1_type))
		self.attrItemList[1].obj:SetActive(true)
		self.attrItemList[1].rect.sizeDelta = Vector2(255, self.attrItemList[1].txt.preferredHeight)
		self.attrItemList[1].rect.anchoredPosition = Vector2(0, -h)
		h = h + self.attrItemList[1].txt.preferredHeight + 15
	else
		self.attrItemList[1].obj:SetActive(false)
	end

	if skill.desc2_type ~= 0 then
		self.attrItemList[2].txt.text = skill.desc2
		self.attrItemList[2].icon.sprite = self.assetWrapper:GetSprite(AssetConfig.rideattricon, string.format("RideAttrIcon%s", skill.desc2_type))
		self.attrItemList[2].obj:SetActive(true)
		self.attrItemList[2].rect.sizeDelta = Vector2(255, self.attrItemList[2].txt.preferredHeight)
		self.attrItemList[2].rect.anchoredPosition = Vector2(0, -h)
		h = h + self.attrItemList[2].txt.preferredHeight + 15
	else
		self.attrItemList[2].obj:SetActive(false)
	end

	if skill.desc3_type ~= 0 then
		self.attrItemList[3].txt.text = skill.desc3
		self.attrItemList[3].icon.sprite = self.assetWrapper:GetSprite(AssetConfig.rideattricon, string.format("RideAttrIcon%s", skill.desc3_type))
		self.attrItemList[3].obj:SetActive(true)
		self.attrItemList[3].rect.sizeDelta = Vector2(255, self.attrItemList[3].txt.preferredHeight)
		self.attrItemList[3].rect.anchoredPosition = Vector2(0, -h)
		h = h + self.attrItemList[3].txt.preferredHeight + 15
	else
		self.attrItemList[3].obj:SetActive(false)
	end

	if skill.desc4_type ~= 0 then
		self.attrItemList[4].txt.text = skill.desc4
		self.attrItemList[4].icon.sprite = self.assetWrapper:GetSprite(AssetConfig.rideattricon, string.format("RideAttrIcon%s", skill.desc4_type))
		self.attrItemList[4].obj:SetActive(true)
		self.attrItemList[4].rect.sizeDelta = Vector2(255, self.attrItemList[4].txt.preferredHeight)
		self.attrItemList[4].rect.anchoredPosition = Vector2(0, -h)
		h = h + self.attrItemList[4].txt.preferredHeight + 15
	else
		self.attrItemList[4].obj:SetActive(false)
	end
end

function RideSkillPanel:ShowNextLev()
    local key = string.format("%s_%s", tostring(self.currSelectItem.data.skill_id), tostring(self.currSelectItem.data.skill_lev+1))
    local skillData = DataSkill.data_mount_skill[key]
    TipsManager.Instance:ShowRideSkill({gameObject = self.nextPreBtn.gameObject, data = skillData})
end

function RideSkillPanel:ClickUp()
	if self.rideData.skill_point < self.levData.point then
		NoticeManager.Instance:FloatTipsByString(TI18N("技能点不足，<color='#ffff00'>坐骑升级</color>可获得更多技能点"))
		return
	end

	-- if not self.enough then
	-- 	NoticeManager.Instance:FloatTipsByString(TI18N("道具不足"))
	-- 	self.slot:SureClick()
	-- 	return
	-- end

	if self.rideData.lev < self.levData.mount_lev then
		NoticeManager.Instance:FloatTipsByString(string.format(TI18N("坐骑等级不足<color='#00ff00'>%s级</color>"), self.levData.mount_lev))
		return
	end

	RideManager.Instance:Send17005(self.rideData.index, self.currSelectItem.data.skill_index)
end

function RideSkillPanel:ClickWash()
	self.parent.cacheMode = CacheMode.Visible
	WindowManager.Instance:OpenWindowById(WindowConfig.WinID.rideskillwash, self.currSelectItem.data)
end