
-- 坐骑升级界面
-- hosr
-- -----------------------------------
RideUpgradePanel = RideUpgradePanel or BaseClass(BasePanel)

function RideUpgradePanel:__init(parent)
	self.parent = parent
	self.model = RideManager.Instance.model
	self.effectSucc = nil
	self.effectFail = nil
	self.effectHold = nil
	self.effectBreak = nil
	self.succPath = "prefabs/effect/20167.unity3d"
	self.failPath = "prefabs/effect/20168.unity3d"
	self.holdPath = "prefabs/effect/20170.unity3d"
	self.breakPath = "prefabs/effect/20174.unity3d"
	self.resList = {
		{file = AssetConfig.ridewindow_upgrade, type = AssetType.Main},
		{file = AssetConfig.ride_texture, type = AssetType.Dep},
		{file = AssetConfig.ridebg, type = AssetType.Dep},
		{file = AssetConfig.attr_icon, type = AssetType.Dep},
		{file = self.succPath, type = AssetType.Main},
		{file = self.failPath, type = AssetType.Main},
		{file = self.holdPath, type = AssetType.Main},
		{file = self.breakPath, type = AssetType.Main},
	}

    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
    self.holdTimeId = nil
    self.effectStayId = nil
    self.listener = function(code) self:UpdateState(code) end
    self.itemObjList = {}
    self.attrUpObjList = {}
    self.attrIconList = {}
    self.attrNameList = {}
    self.attrValList = {}
    self.attrUpValList = {}
    self.breakItemList = {}
    self.breakIconList = {}
    self.breakNameList = {}
    self.breakDataList = {}

    self.enough = false
    self.hasDone = false
    self.canUp = true
    self.init = false

    self.tickFlag = false --是否保底升级
end

function RideUpgradePanel:__delete()
	if self.slot ~= nil then
	    self.slot:DeleteMe()
	    self.slot = nil
	end

    if self.breakIconList ~= nil then
    	for i,v in ipairs(self.breakIconList) do
    		v:DeleteMe()
    	end
    end
    self.breakIconList = nil

	if self.attrIconList ~= nil then
		for i,v in ipairs(self.attrIconList) do
			v.sprite = nil
		end
	end
	self.attrIconList = nil

	if self.holdTimeId ~= nil then
		LuaTimer.Delete(self.holdTimeId)
		self.holdTimeId = nil
	end

	if self.effectStayId ~= nil then
		LuaTimer.Delete(self.effectStayId)
		self.effectStayId = nil
	end
end

function RideUpgradePanel:OnHide()
    RideManager.Instance.OnUpgradeUpdate:Remove(self.listener)
    RideManager.Instance.OnBreakUpdate:Remove(self.listener)
	if self.effectSucc ~= nil then
		self.effectSucc:SetActive(false)
	end

	if self.effectFail ~= nil then
		self.effectFail:SetActive(false)
	end

	if self.effectHold ~= nil then
		self.effectHold:SetActive(false)
	end

	if self.effectBreak ~= nil then
		self.effectBreak:SetActive(false)
	end

	if self.timerId ~= nil then
			LuaTimer.Delete(self.timerId)
			self.timerId = nil
	end
end

function RideUpgradePanel:OnShow()
	self.canUp = true
    RideManager.Instance.OnUpgradeUpdate:Add(self.listener)
    RideManager.Instance.OnBreakUpdate:Add(self.listener)
	self:updateInfo()
end

function RideUpgradePanel:InitPanel()
    self.gameObject  =  GameObject.Instantiate(self:GetPrefab(AssetConfig.ridewindow_upgrade))
    self.gameObject.name = "RideUpgradePanel"
    self.transform = self.gameObject.transform
    self.transform:SetParent(self.parent.mainTransform)
    self.transform.localScale = Vector3.one
    self.gameObject:GetComponent(RectTransform).anchoredPosition = Vector2(116, -7)

    self.transform:Find("Bg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.ridebg, "RideBg")
    self.preview = self.transform:Find("Preview").gameObject

    self.point = self.transform:Find("PointText"):GetComponent(Text)
    self.info = self.transform:Find("Info")
    self.levTxt = self.info:Find("Lev"):GetComponent(Text)
    self.upObj = self.transform:Find("Info/Up").gameObject
    self.breakObj = self.transform:Find("Info/Break").gameObject

    local con = self.breakObj.transform:Find("Container")
    for i = 1, 4 do
    	local child = con:GetChild(i - 1)
    	table.insert(self.breakItemList, child.gameObject)
    	table.insert(self.breakIconList, SingleIconLoader.New(child.gameObject))
    	table.insert(self.breakNameList, child:Find("Name"):GetComponent(Text))
    	local index = i
    	child:GetComponent(Button).onClick:AddListener(function() self:ClickSkill(index) end)
    end

    self.itemClone = self.info:Find("Up/Mask/Panel/Item").gameObject
    self.itemClone:SetActive(false)
    self.itemObjList = {}
    -- self.itemObjList = {
    -- 	self.info:Find("Up/Item1").gameObject,
    -- 	self.info:Find("Up/Item2").gameObject,
    -- 	self.info:Find("Up/Item3").gameObject,
    -- 	self.info:Find("Up/Item4").gameObject,
    -- }

    -- local attr1Icon = self.info:Find("Up/Item1/Icon"):GetComponent(Image)
    -- local attr2Icon = self.info:Find("Up/Item2/Icon"):GetComponent(Image)
    -- local attr3Icon = self.info:Find("Up/Item3/Icon"):GetComponent(Image)
    -- local attr4Icon = self.info:Find("Up/Item4/Icon"):GetComponent(Image)
    -- self.attrIconList = {attr1Icon, attr2Icon, attr3Icon, attr4Icon}

    -- local attr1Name = self.info:Find("Up/Item1/Name"):GetComponent(Text)
    -- local attr2Name = self.info:Find("Up/Item2/Name"):GetComponent(Text)
    -- local attr3Name = self.info:Find("Up/Item3/Name"):GetComponent(Text)
    -- local attr4Name = self.info:Find("Up/Item4/Name"):GetComponent(Text)
    -- self.attrNameList = {attr1Name, attr2Name, attr3Name, attr4Name}

    -- local attr1Val = self.info:Find("Up/Item1/Val"):GetComponent(Text)
    -- local attr2Val = self.info:Find("Up/Item2/Val"):GetComponent(Text)
    -- local attr3Val = self.info:Find("Up/Item3/Val"):GetComponent(Text)
    -- local attr4Val = self.info:Find("Up/Item4/Val"):GetComponent(Text)
    -- self.attrValList = {attr1Val, attr2Val, attr3Val, attr4Val}

    -- local attr1UpObj = self.info:Find("Up/Item1/UpVal").gameObject
    -- local attr2UpObj = self.info:Find("Up/Item2/UpVal").gameObject
    -- local attr3UpObj = self.info:Find("Up/Item3/UpVal").gameObject
    -- local attr4UpObj = self.info:Find("Up/Item4/UpVal").gameObject
    -- self.attrUpObjList = {attr1UpObj, attr2UpObj, attr3UpObj, attr4UpObj}

    -- local attr1UpVal = self.info:Find("Up/Item1/UpVal/Val"):GetComponent(Text)
    -- local attr2UpVal = self.info:Find("Up/Item2/UpVal/Val"):GetComponent(Text)
    -- local attr3UpVal = self.info:Find("Up/Item3/UpVal/Val"):GetComponent(Text)
    -- local attr4UpVal = self.info:Find("Up/Item4/UpVal/Val"):GetComponent(Text)
    -- self.attrUpValList = {attr1UpVal, attr2UpVal, attr3UpVal, attr4UpVal}

    self.bottom = self.transform:Find("Bottom")
    self.rateTxt = self.bottom:Find("RateTxt"):GetComponent(Text)
    self.name = self.bottom:Find("Name"):GetComponent(Text)
    self.breakBtn = self.bottom:Find("BreakButton"):GetComponent(Button)
    self.breakBtn.onClick:AddListener(function() self:OnBreak() end)
    self.breakDesc = self.bottom:Find("BreakDesc"):GetComponent(Text)

    self.helpUp = self.bottom:Find("HelpUp")
    self.tickBtn = self.helpUp:Find("Bg"):GetComponent(Button)
    self.tickImg = self.helpUp:Find("Tick").gameObject
    self.tickBtn.onClick:AddListener(function() self:OnTickHelpUp() end)


    self.slot = ItemSlot.New()
    UIUtils.AddUIChild(self.bottom:Find("Slot").gameObject, self.slot.gameObject)

    self.max = self.transform:Find("Max").gameObject
    self.maxTxt = MsgItemExt.New(self.transform:Find("Max/MaxTxt"):GetComponent(Text), 380, 22, 22)
    self.maxTxt:SetData(TI18N("当前已达坐骑最大等级{face_1,18}"))

    self.upBtn = self.bottom:Find("UpButton"):GetComponent(CustomButton)
    self.upBtn.onUp:AddListener(function() self:OnUp() end)
    self.upBtn.onDown:AddListener(function() self:OnDown() end)
    self.upBtn.onClick:AddListener(function() self:OnClick() end)
    -- self.upBtn.onHold:AddListener(function() self:OnHold() end)

    self.effectSucc = GameObject.Instantiate(self:GetPrefab(self.succPath))
    self.effectSucc.transform:SetParent(self.transform)
    self.effectSucc.transform.localScale = Vector3.one
    self.effectSucc.transform.localPosition = Vector3(-96, 29, -500)
    Utils.ChangeLayersRecursively(self.effectSucc.transform, "UI")
    self.effectSucc:SetActive(false)

    self.effectFail = GameObject.Instantiate(self:GetPrefab(self.failPath))
    self.effectFail.transform:SetParent(self.transform)
    self.effectFail.transform.localScale = Vector3.one
    self.effectFail.transform.localPosition = Vector3(-96, 29, -500)
    Utils.ChangeLayersRecursively(self.effectFail.transform, "UI")
    self.effectFail:SetActive(false)

    self.effectHold = GameObject.Instantiate(self:GetPrefab(self.holdPath))
    self.effectHold.transform:SetParent(self.transform)
    self.effectHold.transform.localScale = Vector3.one
    self.effectHold.transform.localPosition = Vector3(-96, 29, -500)
    Utils.ChangeLayersRecursively(self.effectHold.transform, "UI")
    self.effectHold:SetActive(false)

    self.effectBreak = GameObject.Instantiate(self:GetPrefab(self.breakPath))
    self.effectBreak.transform:SetParent(self.transform)
    self.effectBreak.transform.localScale = Vector3.one
    self.effectBreak.transform.localPosition = Vector3(-96, 29, -500)
    Utils.ChangeLayersRecursively(self.effectBreak.transform, "UI")
    self.effectBreak:SetActive(false)

    self.init = true
    self:OnShow()
end

function RideUpgradePanel:update()
	self.tickFlag = false --更换坐骑时重置
	self:updateInfo()
end

function RideUpgradePanel:updateInfo()
	self.rideData = self.model.cur_ridedata
	local key = string.format("%s_%s", self.rideData.lev, self.rideData.index)
	self.levData = DataMount.data_ride_lev[key]

	self.point.text = self.rideData.score * 5
	self.levTxt.text = string.format(TI18N("等级:%s"), self.rideData.lev)
	key = string.format("%s_%s_%s", self.rideData.lev, RoleManager.Instance.RoleData.classes, self.rideData.index)
	local nextKey = string.format("%s_%s_%s", self.rideData.lev + 1, RoleManager.Instance.RoleData.classes, self.rideData.index)
	local attrData = DataMount.data_ride_attr[key]
	local nextData = DataMount.data_ride_attr[nextKey]

	self:UpdateAttr(attrData.attr, nextData)

	self.tickImg:SetActive(self.tickFlag)

	local loss = {}
	if self.levData.is_up_lev == 1 and tonumber(self.rideData.upgrade_lev) ~= tonumber(self.rideData.lev) then
		-- 突破
		self.breakObj:SetActive(true)
		self.breakDesc.gameObject:SetActive(true)
		self.upObj:SetActive(false)
		self.rateTxt.gameObject:SetActive(false)
		self.upBtn.gameObject:SetActive(false)
		self.breakBtn.gameObject:SetActive(true)

		self.max:SetActive(false)
		self.bottom.gameObject:SetActive(true)
		self.helpUp.gameObject:SetActive(false)

		loss = self.levData.upgrade_cost
		self:UpdateSkill()
	else
		local key = string.format("%s_%s", self.rideData.lev + 1, self.rideData.index)
		if DataMount.data_ride_lev[key] == nil then
			self.max:SetActive(true)
			self.bottom.gameObject:SetActive(false)
		else
			self.max:SetActive(false)
			self.bottom.gameObject:SetActive(true)
		end

		self.breakBtn.gameObject:SetActive(false)
		self.upBtn.gameObject:SetActive(true)
		self.upObj:SetActive(true)
		self.rateTxt.gameObject:SetActive(true)
		self.breakObj:SetActive(false)
		self.breakDesc.gameObject:SetActive(false)

		loss = self.levData.lev_cost

		if self.tickFlag then
			loss = self.levData.sure_success_cost
		end
		self.helpUp.gameObject:SetActive(self.levData.is_can_sure_success_levup == 1)
	end

	self:UpdateLoss(loss)
	self:UpdateRate()
	self:UpdateModel()
end

function RideUpgradePanel:UpdateAttr(attr, nextData)
	if self.model.cur_ridedata.index == 3 then
        self.info:Find("Up/Image/Text"):GetComponent(Text).text = TI18N("下级加成<color='#ffff00'>宠物</color>")
    else
        self.info:Find("Up/Image/Text"):GetComponent(Text).text = TI18N("下级属性")
    end


	if nextData ~= nil then
		table.sort(nextData.attr, function(a,b) return a.attr_name < b.attr_name end)
	end
	table.sort(attr, function(a,b) return a.attr_name < b.attr_name end)
	local count = 0
	for i,v in ipairs(attr) do
		count = i
		-- self.attrIconList[i].sprite = self.assetWrapper:GetSprite(AssetConfig.attr_icon, "AttrIcon"..v.attr_name)
		-- self.attrNameList[i].text = KvData.attr_name[v.attr_name]
		-- self.attrValList[i].text = v.val1
		-- self.attrUpObjList[i]:SetActive(false)
		-- self.itemObjList[i]:SetActive(true)

		-- if nextData == nil then
		-- 	self.attrUpObjList[i]:SetActive(false)
		-- else
		-- 	if nextData.attr[i].val1 - v.val1 <= 0 then
		-- 		self.attrUpObjList[i]:SetActive(false)
		-- 	else
		-- 		self.attrUpObjList[i]:SetActive(true)
		-- 		self.attrUpValList[i].text = nextData.attr[i].val1 - v.val1
		-- 	end
		-- end
		local item = self.itemObjList[i]
		if item == nil then
            local itemObj = GameObject.Instantiate(self.itemClone)
            itemObj:SetActive(true)
            itemObj.transform:SetParent(self.info:Find("Up/Mask/Panel"))
            itemObj:GetComponent(RectTransform).localScale = Vector3(1, 1, 1)
            item = {}
            item.gameObject = itemObj
            item.attrIcon = itemObj.transform:Find("Icon"):GetComponent(Image)
			item.attrName = itemObj.transform:Find("Name"):GetComponent(Text)
			item.attrVal = itemObj.transform:Find("Val"):GetComponent(Text)
			item.attrUpObj = itemObj.transform:Find("UpVal").gameObject
			item.attrUpVal = itemObj.transform:Find("UpVal/Val"):GetComponent(Text)
            self.itemObjList[i] = item
        end

        item.attrIcon.sprite = self.assetWrapper:GetSprite(AssetConfig.attr_icon, "AttrIcon"..v.attr_name)
		item.attrName.text = KvData.attr_name[v.attr_name]
		item.attrVal.text = v.val1
		item.attrUpObj:SetActive(false)
		item.gameObject:SetActive(true)

		if nextData == nil then
			item.attrUpObj:SetActive(false)
		else
			if nextData.attr[i].val1 - v.val1 <= 0 then
				item.attrUpObj:SetActive(false)
			else
				item.attrUpObj:SetActive(true)
				item.attrUpVal.text = nextData.attr[i].val1 - v.val1
			end
		end
	end

	for i = count + 1, #self.itemObjList do
		self.itemObjList[i].gameObject:SetActive(false)
	end
end

function RideUpgradePanel:UpdateRate()
	local addRate = self.rideData.fail_times * (self.levData.fail_add / 10)
	if self.tickFlag then
		self.rateTxt.text = string.format("%s%%", 100)
	elseif addRate == 0 then
		self.rateTxt.text = string.format("%s%%", self.levData.ratio / 10)
	else
		self.rateTxt.text = string.format("%s%% <color='#00ff00'>+%s%%</color>", self.levData.ratio / 10, addRate)
	end
end

function RideUpgradePanel:UpdateLoss(list)
	if #list == 0 then
		return
	end

	local baseId = list[1][1]
	local num = list[1][2]
	local has = BackpackManager.Instance:GetItemCount(baseId)

    local itemData = ItemData.New()
    itemData:SetBase(BaseUtils.copytab(DataItem.data_get[baseId]))
    self.slot:SetAll(itemData)
    self.slot:SetNum(has, num)
    self.name.text = ColorHelper.color_item_name(itemData.quality, itemData.name)
    self.enough = (has >= num)
end

function RideUpgradePanel:UpdateSkill()
	local classes = RoleManager.Instance.RoleData.classes
	local list = {}
	for k,v in pairs(DataMount.data_ride_skill) do
		if (tonumber(v.classes) == tonumber(classes) or tonumber(v.classes) == 0) and tonumber(self.rideData.index) == tonumber(v.index) and tonumber(v.skill_index) == tonumber(self.levData.skill_cnt) then
			local dat = BaseUtils.copytab(v)
			dat.skill_lev = 1
			table.insert(list, dat)
		end
	end

	local count = 0
	self.breakDataList = {}
	for i,v in ipairs(list) do
		local skillData = DataSkill.data_mount_skill[string.format("%s_%s", v.id, v.skill_lev)]
		if skillData ~= nil then
			count = count + 1
			self.breakItemList[count]:SetActive(true)
			-- self.breakIconList[count].sprite = self.assetWrapper:GetSprite(AssetConfig.skillIcon_ride, tostring(skillData.icon))
			self.breakIconList[count]:SetSprite(SingleIconType.SkillIcon, tostring(skillData.icon))
			self.breakNameList[count].text = skillData.name
			table.insert(self.breakDataList, skillData)
		end
	end

	for i = count + 1, #self.breakItemList do
		self.breakItemList[i]:SetActive(false)
	end
end

function RideUpgradePanel:UpdateModel()
    -- local ride_look = self.rideData.base.base_id
    -- local ride_jewelry1 = 0
    -- local ride_jewelry2 = 0
    -- if self.rideData.transformation_id == 0 then
    --     for _,value in ipairs(self.rideData.decorate_list) do
    --         if value.decorate_index == 1 and value.is_hide == 0 then
    --             ride_jewelry1 = value.decorate_base_id
    --         elseif value.decorate_index == 2 and value.is_hide == 0 then
    --             ride_jewelry2 = value.decorate_base_id
    --         end
    --     end
    -- else
    --     ride_look = self.rideData.transformation_id
    -- end

    -- local data = {type = PreViewType.Ride, classes = 1, sex = 1, looks = {}, scale = 1, effects = {}}
    -- table.insert(data.looks, { looks_type = SceneConstData.looktype_ride, looks_val = ride_look })
    -- table.insert(data.looks, { looks_type = SceneConstData.looktype_ride_jewelry1, looks_val = ride_jewelry1 })
    -- table.insert(data.looks, { looks_type = SceneConstData.looktype_ride_jewelry2, looks_val = ride_jewelry2 })
    local data = self.model:MakeRideLook(self.rideData)
    self.parent:load_preview(self.preview.transform, data)
end

function RideUpgradePanel:OnDown()
	-- if not self.canUp then
	-- 	return
	-- end
	local canUpgrade, message = self.model:CheckRideCanUpgrade_Level()
	if not canUpgrade then
		NoticeManager.Instance:FloatTipsByString(string.format(TI18N("角色等级达到<color='#00ff00'>%s</color>，才能继续升级坐骑哦"), message))
		return
	end

	self.hasDone = false
	if not self.enough then
		self.hasDone = true
		NoticeManager.Instance:FloatTipsByString(TI18N("道具不足"))
		self.slot:SureClick()
		return
	end

	self:StayTimeOut()

	if self.effectHold ~= nil then
		self.effectHold:SetActive(false)
		self.effectHold:SetActive(true)
	end
    LuaTimer.Add(100,function()
        SoundManager.Instance:Play(232)
    end)
	self:BeginTime()
end

function RideUpgradePanel:OnUp()
	if self.effectHold ~= nil then
		self.effectHold:SetActive(false)
	end
    SoundManager.Instance:StopId(232)
	self:StopTime()
end

function RideUpgradePanel:OnClick()
	local canUpgrade, message = self.model:CheckRideCanUpgrade_Level()
	if not canUpgrade then
		return
	end
	if not self.hasDone then
		NoticeManager.Instance:FloatTipsByString(TI18N("请<color='#ffff00'>长按</color>进行坐骑提升{face_1,22}"))
	end
end

function RideUpgradePanel:OnHold()
end

function RideUpgradePanel:OnBreak()
	if self.effectStayId ~= nil then
		LuaTimer.Delete(self.effectStayId)
		self.effectStayId = nil
	end
	if not self.enough then
		NoticeManager.Instance:FloatTipsByString(TI18N("道具不足"))
		self.slot:SureClick()
		return
	end
	RideManager.Instance:Send17011(self.rideData.index)
end

function RideUpgradePanel:BeginTime()
	self:StopTime()
	self.holdTimeId = LuaTimer.Add(1800, function() self:Beng() end)
end

function RideUpgradePanel:StopTime()
	if self.holdTimeId ~= nil then
		LuaTimer.Delete(self.holdTimeId)
		self.holdTimeId = nil
	end
end

function RideUpgradePanel:Beng()
	self.hasDone = true
	-- 特效结束，发送升级协议
	self:StopTime()
	RideManager.Instance:Send17006(self.rideData.index,self.tickFlag)
end

function RideUpgradePanel:UpdateState(data)
	self:StopTime()
	if self.effectHold ~= nil then
		self.effectHold:SetActive(false)
	end
	if data.code == 1 then
		self:PlaySucc()
	elseif data.code == 0 then
		self:PlayFail()
	elseif data.code == 2 then
		self:PlayBreak(data.list)
	end
	self:updateInfo()
end

function RideUpgradePanel:PlaySucc()
    self.canUp = false
	self.effectSucc:SetActive(false)
	self.effectSucc:SetActive(true)
    SoundManager.Instance:Play(233)
	self.effectStayId = LuaTimer.Add(1500, function() self:StayTimeOut() end)
end

function RideUpgradePanel:PlayFail()
    self.canUp = false
	self.effectFail:SetActive(false)
	self.effectFail:SetActive(true)
    SoundManager.Instance:Play(234)
	self.effectStayId = LuaTimer.Add(1500, function() self:StayTimeOut() end)
end

function RideUpgradePanel:PlayBreak(list)
    self.canUp = false
	self.effectBreak:SetActive(false)
	self.effectBreak:SetActive(true)
    SoundManager.Instance:Play(232)
	self.effectStayId = LuaTimer.Add(500, function() self:StayTimeOut(list) end)
end

function RideUpgradePanel:StayTimeOut(list)
    self.canUp = true
	if self.effectStayId ~= nil then
		LuaTimer.Delete(self.effectStayId)
		self.effectStayId = nil
	end

	if self.effectSucc ~= nil then
		self.effectSucc:SetActive(false)
	end

	if self.effectFail ~= nil then
		self.effectFail:SetActive(false)
	end

	if self.effectBreak ~= nil then
		self.effectBreak:SetActive(false)
	end

	if list ~= nil and #list > 0 then
		self:OpenGetSkill(list[1])
	end
end

function RideUpgradePanel:ClickSkill(index)
	TipsManager.Instance:ShowRideSkill({gameObject = self.breakItemList[index], data = self.breakDataList[index]})
end

-- 打开获得新技能界面
function RideUpgradePanel:OpenGetSkill(args)
    if self.rideGetSkill == nil then
        self.rideGetSkill = RideGetSkillPanel.New(self)
    end
    self.rideGetSkill:Show(args)
end

function RideUpgradePanel:CloseGetSkill()
    if self.rideGetSkill ~= nil then
        self.rideGetSkill:DeleteMe()
        self.rideGetSkill = nil
    end
end

function RideUpgradePanel:OnTickHelpUp()
		self.tickFlag = not self.tickFlag
		if self.tickFlag then
			TipsManager.Instance:ShowText({gameObject = self.helpUp.gameObject, itemData = {TI18N("消耗多个精灵缰绳，可<color='#00ff00'>100%</color>升级成功")}, tipsOffsetX = 0, tipsOffsetY = 80})
			-- NoticeManager.Instance:FloatTipsByString(TI18N("消耗多个精灵缰绳，可100%升级成功"))
			if self.timerId ~= nil then
				LuaTimer.Delete(self.timerId)
				self.timerId = nil
			end
			self.timerId = LuaTimer.Add(2000,function() TipsManager.Instance:Clear() end)
		end
		self:updateInfo()
end
