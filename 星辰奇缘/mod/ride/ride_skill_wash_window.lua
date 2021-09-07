-- ------------------------------------
-- 坐骑技能洗炼界面
-- hosr
-- ------------------------------------
RideSkillWashWindow = RideSkillWashWindow or BaseClass(BaseWindow)

function RideSkillWashWindow:__init()
	self.model = RideManager.Instance.model
	self.windowId = WindowConfig.WinID.rideskillwash
    self.cacheMode = CacheMode.Visible
    if BaseUtils.IsIPhonePlayer() then --ios特殊处理
        self.cacheMode = CacheMode.Destroy
    end
    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
    self.effectSucc = nil
    self.succPath = "prefabs/effect/20049.unity3d"
	self.resList = {
		{file = AssetConfig.ridewash, type = AssetType.Main},
		{file = AssetConfig.ride_texture, type = AssetType.Dep},
		{file = AssetConfig.rideattricon, type = AssetType.Dep},
		{file = self.succPath, type = AssetType.Main},
	}
	self.attrItemList = {}
	self.skillItemList = {}
	self.effectItemList = {}
	self.listener = function() self:PortoUpdate() end
	self.itemChangeListener = function() self:UpdateInfo() end
	self.enough = false

	self.tickFlag = false --是否指定洗练
	self.currentSelectedItemSkill_id = 0 --当前选中技能id

	self.freeOpen = true

end

function RideSkillWashWindow:__delete()
	self.OnHideEvent:Fire()

	if self.effectItemList ~= nil then
			for k,v in pairs(self.effectItemList) do
					if v ~= nil then
						v:DeleteMe()
						v = nil
					end
			end
	end

	if self.slot ~= nil then
	    self.slot:DeleteMe()
	    self.slot = nil
	end
	if self.icon ~= nil then
		self.icon:DeleteMe()
		self.icon = nil
	end
    if self.upButton ~= nil then
        self.upButton:DeleteMe()
        self.upButton = nil
    end
    if self.slotNumExt ~= nil then
        self.slotNumExt:DeleteMe()
        self.slotNumExt = nil
    end

	RideManager.Instance.OnSkillUpdate:Remove(self.listener)
	EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.itemChangeListener)
	for i,v in ipairs(self.attrItemList) do
		v.icon.sprite = nil
	end

	for i,v in ipairs(self.skillItemList) do
		v:DeleteMe()
	end

	self.attrItemList = nil
	self.skillItemList = nil
	self.effectItemList = nil
end

function RideSkillWashWindow:OnShow()
	if self.openArgs ~= nil then
		self.currSelectSkill = self.openArgs
	end

	self:Update()
	RideManager.Instance.OnSkillUpdate:Add(self.listener)
	EventMgr.Instance:AddListener(event_name.backpack_item_change, self.itemChangeListener)
end

function RideSkillWashWindow:OnHide()
	if self.effectSucc ~= nil then
		self.effectSucc:SetActive(false)
	end

	if self.timerId ~= nil then
		LuaTimer.Delete(self.timerId)
		self.timerId = nil
	end

	if self.timerId2 ~= nil then
		LuaTimer.Delete(self.timerId2)
		self.timerId2 = nil
	end

	RideManager.Instance.OnSkillUpdate:Remove(self.listener)
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.itemChangeListener)
end

function RideSkillWashWindow:Close()
	WindowManager.Instance:CloseWindowById(WindowConfig.WinID.rideskillwash)
end

function RideSkillWashWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.ridewash))
    self.gameObject.name = "RideSkillWashWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    local main = self.transform:Find("Main")
    main:Find("CloseButton"):GetComponent(Button).onClick:AddListener(function() self:Close() end)
    self.main = main.gameObject

    main:GetChild(4):Find("Text"):GetComponent(Text).text = TI18N("请选中<color='#ffff00'>任一</color>技能进行<color='#ffff00'>洗炼</color>")

    self.tips = self.transform:Find("Tips").gameObject
    self.tips:SetActive(false)
    self.tipsTitle = self.transform:Find("Tips/Main/Title"):GetComponent(Text)
    self.tipsDesc = self.transform:Find("Tips/Main/Desc"):GetComponent(Text)
    self.transform:Find("Tips/Main/Sure/Text"):GetComponent(Text).text = TI18N("确定")

    self.transform:Find("Tips/Main/Sure"):GetComponent(Button).onClick:AddListener(function() self:ClickSure() end)
    self.transform:Find("Tips/Main/Cancel"):GetComponent(Button).onClick:AddListener(function() self:ClickCancel() end)

    self.icon = SingleIconLoader.New(main:Find("Top/SkillIcon").gameObject)
    self.lev = main:Find("Top/SkillIcon/Lev/Text"):GetComponent(Text)
    self.name = main:Find("Top/SkillIcon/Name/Text"):GetComponent(Text)


    self.helpUp = main:Find("HelpUp")
    self.tickBtn = self.helpUp:Find("Bg"):GetComponent(Button)
    self.tickImg = self.helpUp:Find("Tick").gameObject
    self.tickBtn.onClick:AddListener(function()
	    	if self.freeOpen then
	    		self.freeOpen = false
	    		LuaTimer.Add(500,function() self.freeOpen = true end)
	    		self:OnTickHelpUp()
	    	end
    	end)

    local len = main:Find("Top/AttrContainer").childCount
    for i = 1, len do
    	local item = main:Find("Top/AttrContainer"):GetChild(i - 1)
    	item.gameObject:SetActive(false)
    	local txt = item:GetComponent(Text)
    	local icon = item:Find("Icon"):GetComponent(Image)
    	table.insert(self.attrItemList, {obj = item.gameObject, txt = txt, icon = icon, rect = item:GetComponent(RectTransform)})
    end

    len = main:Find("Container").childCount
    for i = 1, len do
   		local item = RideSkillItem.New(main:Find("Container"):GetChild(i - 1).gameObject, self, true, false)
   		table.insert(self.skillItemList, item)
    end

    self.slot = ItemSlot.New()
    UIUtils.AddUIChild(main:Find("Slot").gameObject, self.slot.gameObject)

    self.slotName = main:Find("Name"):GetComponent(Text)
    self.slotNumExt = MsgItemExt.New(main:Find("Num"):GetComponent(Text), 200, 18, 20.85)

    self.upBtn = main:Find("UpBtn"):GetComponent(Button)
    self.upButton = BuyButton.New(main:Find("UpContainer"), TI18N("洗练技能"), true)
	self.upButton.key = "RideSkillWash"
	self.upButton.protoId = 17013
    self.upButton:Show()
    self.upBtn.onClick:AddListener(function() self.upButton:OnClick() end)

    self.levBtn = main:Find("LevBtn").gameObject
    self.levBtn:SetActive(true)
    self.levBtn:GetComponent(Button).onClick:AddListener(function() self:OpenTips() end)

    self.effectSucc = GameObject.Instantiate(self:GetPrefab(self.succPath))
    self.effectSucc.transform:SetParent(self.transform)
    self.effectSucc.transform.localScale = Vector3.one
    self.effectSucc.transform.localPosition = Vector3(-209, 106, 0)
    Utils.ChangeLayersRecursively(self.effectSucc.transform, "UI")
    self.effectSucc:SetActive(false)

    self:OnShow()
end

function RideSkillWashWindow:PortoUpdate()
	if self.effectSucc ~= nil then
		self.effectSucc:SetActive(false)
		self.effectSucc:SetActive(true)
	end

	for k,v in ipairs(self.skillItemList) do
			if v ~= nil then
				v:Select(false)
			end
	end

	self:Update()
end

function RideSkillWashWindow:Update()
	self.rideData = self.model.cur_ridedata

	self:UpdateSkill()
	self:UpdateInfo()
	self:UpdateAttr()
end

function RideSkillWashWindow:UpdateSkill()
	for i,v in ipairs(self.rideData.skill_list) do
		if v.skill_index == self.currSelectSkill.skill_index then
			-- 取到当前操作的技能槽技能数据
			self.currentSkill = v
			self.currentSkillData = DataSkill.data_mount_skill[string.format("%s_%s", v.skill_id, v.skill_lev)]
		end
	end

	local classes = RoleManager.Instance.RoleData.classes
	local list = {}
	for k,v in pairs(DataMount.data_ride_skill) do
		if (tonumber(v.classes) == tonumber(classes) or tonumber(v.classes) == 0) and tonumber(self.rideData.index) == tonumber(v.index) and tonumber(v.skill_index) == tonumber(self.currSelectSkill.skill_index) then --and self.currSelectSkill.skill_id ~= v.id then
			table.insert(list, {skill_index = v.skill_index, skill_id = v.id, skill_lev = self.currSelectSkill.skill_lev})
		end
	end

	table.sort(list, function(a,b) return a.skill_id < b.skill_id end)

	for i,v in ipairs(list) do
		self.skillItemList[i]:SetData(v)
		-- self.skillItemList[i].transform:Find("UseIcon").gameObject:SetActive(v.skill_id == self.currentSkillData.id)
		self.skillItemList[i].callback = function(item) self:OnClickSkillItem(item) end
	end

	for i = #list + 1, #self.skillItemList do
		self.skillItemList[i].gameObject:SetActive(false)
	end


  --指定洗练
	if self.tickFlag then
		 --  --选中 第一个且不是正在使用中的技能slot
			-- for i,v in ipairs(list) do
			-- 		if v.skill_id ~= self.currentSkillData.id then
			-- 			self:OnClickSkillItem(self.skillItemList[i])
			-- 			break
			-- 		end
			-- end
	else
			--无指定洗练重置选中状态，当前技能id为0
			if self.lastItem ~= nil then
				self.lastItem:Select(false)
			end
			self.currentSelectedItemSkill_id = 0
	end
end

function RideSkillWashWindow:UpdateInfo()

	-- self.icon.sprite = self.assetWrapper:GetSprite(AssetConfig.skillIcon_ride, tostring(self.currentSkillData.icon))
	self.icon:SetSprite(SingleIconType.SkillIcon, tostring(self.currentSkillData.icon))
	self.lev.text = RideEumn.SkillLevShow[self.currentSkill.skill_lev]
	self.name.text = RideEumn.ColorName(self.currentSkill.skill_lev, self.currentSkillData.name)

	local list = DataMount.data_ride_skill_wash[string.format("%s_%s", self.rideData.index, self.currentSkill.skill_index)].cost

	--指定洗练
	if self.tickFlag then
			--得到指定洗练后的花费列表
			list = DataMount.data_ride_skill_wash[string.format("%s_%s", self.rideData.index, self.currentSkill.skill_index)].select_skill_cost
	end

	local baseId = list[1][1]
	local num = list[1][2]
	local has = BackpackManager.Instance:GetItemCount(baseId)

 	local itemData = ItemData.New()
  	itemData:SetBase(BaseUtils.copytab(DataItem.data_get[baseId]))
    self.slot:SetAll(itemData)
    self.slot:SetNum(has, num)
    self.slotName.text = ColorHelper.color_item_name(itemData.quality, itemData.name)
    -- self.enough = (has >= num)
    -- if self.enough then
    -- 	self.slotNum.text = string.format("%s/%s", has, num)
    -- else
    -- 	self.slotNum.text = string.format("<color='%s'>%s</color>/%s", ColorHelper.color[6], has, num)
    -- end

    self.upButton:Layout({[baseId] = {need = num}}, function() self:ClickWash() end, function(tab) self:AfterPriceBack(tab) end, {antofreeze = true})
end

function RideSkillWashWindow:AfterPriceBack(priceTab)
	BaseUtils.dump(priceTab)

    for _,v in pairs(priceTab) do
        if v.allprice > 0 then
            self.slotNumExt:SetData(string.format("%s{assets_2, %s}", v.allprice, v.assets))
        else
            self.slotNumExt:SetData(string.format("<color='#ff0000'>%s</color>{assets_2, %s}", -v.allprice, v.assets))
        end
        -- self.slotNumExt.contentTrans.anchoredPosition = Vector2(-53 - self.slotNumExt.contentTrans.sizeDelta.x / 2, -14 + self.slotNumExt.contentTrans.sizeDelta.y / 2)
        break
    end
end

function RideSkillWashWindow:UpdateAttr()
	local h = 0
	local skill = self.currentSkillData
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

function RideSkillWashWindow:ClickWash()
	-- if not self.enough then
	-- 	NoticeManager.Instance:FloatTipsByString(TI18N("道具不足"))
	-- 	self.slot:SureClick()
	-- 	return
	-- end

	if self.tickFlag and self.currentSelectedItemSkill_id == 0 then
		NoticeManager.Instance:FloatTipsByString(TI18N("请选择想要洗炼的技能"))
		return
	end


	RideManager.Instance:Send17013(self.rideData.index, self.currentSkill.skill_index, self.currentSelectedItemSkill_id)
end

function RideSkillWashWindow:OpenTips()
	if self.currentSkill.skill_lev == 1 then
		NoticeManager.Instance:FloatTipsByString(TI18N("I级技能不需降级"))
		return
	end
    self.tipsTitle.text = string.format(TI18N("是否降低%s等级？"), RideEumn.ColorName(self.currentSkill.skill_lev, self.currentSkillData.name))
    self.tipsDesc.text = string.format(TI18N("当前技能等级将降低至%s级，并<color='#ffff00'>返还相应技能点</color>，升级道具不返还。"), self.currentSkill.skill_lev-1)
	self.tips:SetActive(true)
end

function RideSkillWashWindow:ClickSure()
	RideManager.Instance:Send17018(self.rideData.index, self.currentSkill.skill_index)
	self:ClickCancel()
end

function RideSkillWashWindow:ClickCancel()
	self.tips:SetActive(false)
end

function RideSkillWashWindow:OnTickHelpUp()
		self.tickFlag = not self.tickFlag

		if self.tickFlag then
			TipsManager.Instance:ShowText({gameObject = self.helpUp.gameObject, itemData = {TI18N("消耗多个驭兽笔记，指定洗炼<color='#ffff00'>任一</color>技能")}, tipsOffsetX = 0, tipsOffsetY = 80})
			-- NoticeManager.Instance:FloatTipsByString(TI18N("消耗多个驭兽笔记，指定洗炼任一技能。"))
			if self.timerId2 ~= nil then
				LuaTimer.Delete(self.timerId2)
				self.timerId2 = nil
			end
			self.timerId2 = LuaTimer.Add(2000,function() TipsManager.Instance:Clear() end)
		end
		self.tickImg:SetActive(self.tickFlag)
		self:Update()


		if self.tickFlag then
			--播放扫光特效
			for k,v in ipairs(self.skillItemList) do
					if v.data ~= nil then
							if self.effectItemList[k] == nil then
								self.effectItemList[k] = BaseUtils.ShowEffect(20252,v.gameObject.transform,Vector3(1.78,1.78,1),Vector3(37,-37,-300))
							end
								self.effectItemList[k]:SetActive(false)
								self.effectItemList[k]:SetActive(true)
					end
					--打开指定洗练无tips
					v.noTips = true
			end
		else
			for k,v in ipairs(self.skillItemList) do
					if v.data ~= nil and self.effectItemList[k] ~= nil then
						self.effectItemList[k]:SetActive(false)
					end
					v.noTips = false
			end
		end
end

function RideSkillWashWindow:OnClickSkillItem(currentItem)
	--若没指定洗练，则不需要选中处理
	if not self.tickFlag then  return end

	if self.effectItemList ~= nil then
		for k,v in pairs(self.effectItemList) do
			if v ~= nil then
				v:SetActive(false)
			end
		end
	end


	if currentItem.noTips == true then
		if currentItem.data.skill_id == self.currentSkillData.id then
			NoticeManager.Instance:FloatTipsByString(TI18N("选中技能为当前技能，无需洗练"))
			return
		else
			NoticeManager.Instance:FloatTipsByString(string.format(TI18N("已选中<color='#00ff00'>%s</color>"),DataSkill.data_mount_skill[string.format("%s_%s", currentItem.data.skill_id, currentItem.data.skill_lev)].name))
		end
	end

	if self.lastItem ~= nil then
		self.lastItem:Select(false)
		--关闭上一次选中的itemtips
		self.lastItem.noTips = true
	end
	self.currentSelectedItemSkill_id = currentItem.data.skill_id

	--打开当前选中的item
	currentItem.noTips = false

	currentItem:Select(true)
	self.lastItem = currentItem

	if self.timerId ~= nil then
		LuaTimer.Delete(self.timerId)
		self.timerId = nil
	end
	self.timerId = LuaTimer.Add(2000,function() TipsManager.Instance:Clear() end)
end
