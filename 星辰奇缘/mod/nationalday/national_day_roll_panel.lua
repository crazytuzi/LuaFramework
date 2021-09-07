--作者:hosr
--16-9-23 上11时44分57秒
--功能:国庆摇奖  彩虹七天乐

NationalDayRollPanel = NationalDayRollPanel or BaseClass(BasePanel)
function NationalDayRollPanel:__init(parent)
	self.parent = parent
	self.effectPath = string.format(AssetConfig.effect, "20187")
	self.effect = nil
	self.resList = {
		{file = AssetConfig.nationaldayrollpanel, type = AssetType.Main},
		{file = AssetConfig.i18nnationaldayrollbg1, type = AssetType.Main},
		{file = AssetConfig.nationaldayrollbg2, type = AssetType.Main},
		{file = AssetConfig.i18nacticebegin, type = AssetType.Dep},
		{file = AssetConfig.i18nacticeend, type = AssetType.Dep},
		{file = self.effectPath, type = AssetType.Main},
	}
	self.OnOpenEvent:Add(function() self:OnOpen() end)
	self.OnHideEvent:Add(function() self:OnHide() end)

	self.itemList = {}
	self.noticeList = {}

	self.maxNum = 0
	self.rolling = false
	self.rollId = nil
	self.rollCall = function() self:Loop() end
	self.currItem = nil
	self.count = 0
	self.loopCount = 0
	self.space = 0
	self.step = 1
	self.slowDown = false
	self.rollType = 1
	self.has = 0
	self.has10 = 0

	self.canRoll = true
	self.noticeIndex = 1
	self.hasNoticeStart = false

	self.imgLoader = nil
	self.poolListener = function(isInit) self:PoolUpdata(isInit) end
	self.resultCallBack = function() self:OnResultBack() end
	self.roll10 = function() self:RandomRoll(10) end

	self.tipsList = {
		TI18N("1.玩家通过其他国庆活动可获得<color='#ffff00'>彩虹豆</color>且使用它可进行抽奖"),
		TI18N("2.2016年9月30日-2016年10月7日<color='#ffff00'>每天19:00--22:00</color>为抽奖时间"),
	}

	self.price = DataShop.data_hidens[23718].price
	self.refreshCost = DataCampNational.data_roll_cost[2].cost[1][2]

	self.noticeItemData = ItemData.New()
	self.noticeItemData:SetBase(DataItem.data_get[23718])

	self.hasInit = false
end

function NationalDayRollPanel:__delete()
	self:OnHide()
	self.timeBg.sprite = nil
	self.needIcon.sprite = nil

	if self.rollId ~= nil then
		LuaTimer.Delete(self.rollId)
		self.rollId = nil
	end

	for i,v in ipairs(self.noticeList) do
		v:DeleteMe()
	end
	self.noticeList = nil

	for i,v in ipairs(self.itemList) do
		v:DeleteMe()
	end
	self.itemList = nil

	if self.imgLoader ~= nil then
        self.imgLoader:DeleteMe()
        self.imgLoader = nil
    end
	if self.gameObject ~= nil then
		GameObject.DestroyImmediate(self.gameObject)
		self.gameObject = nil
	end
	self:AssetClearAll()
end

function NationalDayRollPanel:RemoveListener()
	EventMgr.Instance:RemoveListener(event_name.nationalday_rewardpool_update, self.poolListener)
    EventMgr.Instance:RemoveListener(event_name.nationalday_rewardresult_update, self.resultCallBack)
    EventMgr.Instance:RemoveListener(event_name.nationalday_roll10, self.roll10)
end

function NationalDayRollPanel:AddListener()
    EventMgr.Instance:AddListener(event_name.nationalday_rewardresult_update, self.resultCallBack)
	EventMgr.Instance:AddListener(event_name.nationalday_rewardpool_update, self.poolListener)
    EventMgr.Instance:AddListener(event_name.nationalday_roll10, self.roll10)
end

function NationalDayRollPanel:OnHide()
	for i,v in ipairs(self.noticeList) do
		v:Reset()
	end
	self.hasNoticeStart = false

	self:RemoveListener()
	self:End()
	self:EndTime()
	self:EndFreeTime()

	if self.effectTimeId ~= nil then
		LuaTimer.Delete(self.effectTimeId)
		self.effectTimeId = nil
	end
end

function NationalDayRollPanel:OnOpen()
	-- if not BaseUtils.is_null(self.effect) then
	-- 	self.effect:SetActive(false)
	-- end

	self:SetData()
	self:ShowCountDow()
	self:AddListener()
	NationalDayManager.Instance:Send14073()
end

function NationalDayRollPanel:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.nationaldayrollpanel))
	self.gameObject.name = "NationalDayRollPanel"

	self.transform = self.gameObject.transform
	self.transform:SetParent(self.parent.RightCon)
	self.transform.localScale = Vector3.one
	self.transform.localPosition = Vector3.zero

	UIUtils.AddBigbg(self.transform:Find("Bg"), GameObject.Instantiate(self:GetPrefab(AssetConfig.i18nnationaldayrollbg1)))
	self.transform:Find("Roll/Bg"):GetComponent(Image).enabled = false
    UIUtils.AddBigbg(self.transform:Find("Roll/Bg"), GameObject.Instantiate(self:GetPrefab(AssetConfig.nationaldayrollbg2)))

	self.timeBg = self.transform:Find("Time/Image"):GetComponent(Image)

	local infoBtnObj = self.transform:Find("InfoBtn").gameObject
	infoBtnObj:GetComponent(Button).onClick:AddListener(function()
		TipsManager.Instance:ShowText({gameObject = infoBtnObj, itemData = self.tipsList})
	end)

	self.TimeText = self.transform:Find("TimeText"):GetComponent(Text)
	self.TimeText.text = TI18N("时间怎么取啊")

	self.transform:Find("ConDescText").gameObject:SetActive(false)
	-- self.ConDescText = self.transform:Find("ConDescText"):GetComponent(Text)
	-- self.ConDescText.text = TI18N("活动内容:<color='#C9F9FE'>玩家通过其他国庆活动可获得<color='#FFFEA0'>彩虹豆</color>使用它可兑换<color='#FFFEA0'>丰厚奖励</color></color>")

	self.Container = self.transform:Find("Roll/Container")
	local len = self.Container.childCount
	for i = 1, len do
		local item = NationalDayRollItem.New(self.Container:GetChild(i - 1), self)
		table.insert(self.itemList, item)
	end
	self.maxNum = #self.itemList

	self.RefreshButton1 = self.transform:Find("Roll/RefreshButton"):GetComponent(Button)
	self.RefreshButton1.onClick:AddListener(function() self:OnRefresh() end)
	self.free = self.transform:Find("Roll/RefreshButton/FreeImg").gameObject
	self.noFree = self.transform:Find("Roll/RefreshButton/NoFree").gameObject
	self.noFreeTxt = self.transform:Find("Roll/RefreshButton/NoFree/Val"):GetComponent(Text)

	self.RollButton = self.transform:Find("Roll/RollButton"):GetComponent(Button)
	self.RollButton.onClick:AddListener(function() self:RandomRoll(1) end)

	self.RollButton10 = self.transform:Find("Roll/RollButton10"):GetComponent(Button)
	self.RollButton10.onClick:AddListener(function() self:RandomRoll(10) end)

	self.transform:Find("Roll/Val"):GetComponent(Button).onClick:AddListener(function() self:ClickNeed() end)
	self.needObj = self.transform:Find("Roll/Val").gameObject

	self.needIcon = self.transform:Find("Roll/Val/Icon"):GetComponent(Image)
	self.Text = self.transform:Find("Roll/Val/Text"):GetComponent(Text)
	self.Text.text = ""

    self.effect = GameObject.Instantiate(self:GetPrefab(self.effectPath))
    self.effectTransform = self.effect.transform
    self.effectTransform:SetParent(self.Container)
    self.effectTransform.localScale = Vector3.one
    self.effectTransform.localPosition = Vector3.zero
    Utils.ChangeLayersRecursively(self.effect.transform, "UI")
    self.effect:SetActive(false)

    local notice = self.transform:Find("Reward/Mask")
    len = notice.childCount
    for i = 1, len do
    	local item = NationalDayNoticeItem.New(notice:GetChild(i - 1).gameObject, function() self:NoticeNext() end)
    	table.insert(self.noticeList, item)
    end

	self:OnOpen()
end

function NationalDayRollPanel:SetData()
	if self.needItemData == nil then
		self.needItemData = ItemData.New()
	end

	self.has = BackpackManager.Instance:GetItemCount(23718)
	self.has10 = BackpackManager.Instance:GetItemCount(23728)
	local iconId = 0
	if self.has10 > 0 then
		self.Text.text = string.format(TI18N("拥有:<color='#00ff00'>%s</color>"), self.has10)
		iconId = 23728
	else
		self.Text.text = string.format(TI18N("拥有:<color='#00ff00'>%s</color>"), self.has)
		iconId = 23718
	end
	 if self.imgLoader == nil then
        local go = self.transform:Find("Roll/Val/Icon").gameObject
        self.imgLoader = SingleIconLoader.New(go)
    end
    self.imgLoader:SetSprite(SingleIconType.Item, iconId)
    self.needItemData:SetBase(DataItem.data_get[iconId])
	self:BeginFreeTime()
end

function NationalDayRollPanel:ShowCountDow()
    local ph = tonumber(os.date("%H", BaseUtils.BASE_TIME))
    local pm = tonumber(os.date("%M", BaseUtils.BASE_TIME))
    local ps = tonumber(os.date("%S", BaseUtils.BASE_TIME))

    local time = ph * 3600 + pm * 60 + ps

    -- 19时 -- 68400
    -- 22时 -- 79200
    if time < 68400 then
    	-- 未开启
    	self.time = 68400 - time
    	self.timeBg.sprite = self.assetWrapper:GetSprite(AssetConfig.i18nacticebegin, "I18NActiceBegin")
    	self.canRoll = false
    elseif time > 79200 then
    	-- 已结束
    	self.time = 86400 - 79200 + 68400
    	self.timeBg.sprite = self.assetWrapper:GetSprite(AssetConfig.i18nacticebegin, "I18NActiceBegin")
    	self.canRoll = false
    else
    	-- 进行中
    	self.time = 79200 - time
    	self.timeBg.sprite = self.assetWrapper:GetSprite(AssetConfig.i18nacticeend, "I18NActiceEnd")
    	self.canRoll = true
    end

    self:SetTime()
    self:EndTime()
    self.timeId = LuaTimer.Add(0, 1000, function() self:TimeLoop() end)
end

function NationalDayRollPanel:SetTime()
    local day,hour,min,second = BaseUtils.time_gap_to_timer(self.time)
    local timeStr = tostring(hour)
    if hour < 10 then
        timeStr = "0"..tostring(hour)
    end
    if min < 10 then
        timeStr = timeStr.. TI18N("时0") .. tostring(min)
    else
        timeStr = timeStr.. TI18N("时") .. tostring(min)
    end
    if second < 10 then
        timeStr = string.format(TI18N("%s分0%s秒"), timeStr, second)
    else
        timeStr = string.format(TI18N("%s分%s秒"), timeStr, second)
    end
	self.TimeText.text = timeStr
end

function NationalDayRollPanel:TimeLoop()
	self.time = self.time - 1
	self:SetTime()
end

function NationalDayRollPanel:EndTime()
	if self.timeId ~= nil then
		LuaTimer.Delete(self.timeId)
		self.timeId = nil
	end
end

function NationalDayRollPanel:PoolUpdata(isInit)
	local list = NationalDayManager.Instance.rainbow_prize_list
	for i,v in ipairs(list) do
		local item = self.itemList[i]
		if item ~= nil then
			item:SetData(v)
		end
	end

	if self.currItem ~= nil then
		self.currItem:Select(false)
	end

	self:SetData()
	self:ShowNotice()
end

function NationalDayRollPanel:BuyNotice(_num, _isRefresh, _isNoFree)
	local num = _num
	local isRefresh = _isRefresh
	local isNoFree = _isNoFree
	local needNum = num - self.has

	local sureCall = function(bool)
    	if isRefresh then
    		if isNoFree then
    			NationalDayManager.Instance.hasNoticeRollRefreshFree = bool
    			self:OnRefresh(true)
    		else
    			NationalDayManager.Instance.hasNoticeRollRefresh = bool
				if not self:CheckMoneyEnough(needNum) then
					return
				end
    			self:OnRefresh(true)
    		end
    	else
	    	if tonumber(num) == 1 then
	    		NationalDayManager.Instance.hasNoticeRoll1 = bool
	    		self:RandomRoll(1, true)
	    	elseif tonumber(num) == 10 then
	    		NationalDayManager.Instance.hasNoticeRoll10 = bool
	    		self:RandomRoll(10, true)
	    	end
    	end
   	end

	local price = needNum * self.price
	if isRefresh then
		local noticeData = NoticeConfirmData.New()
	    noticeData.type = ConfirmData.Style.Normal
	    noticeData.sureLabel = TI18N("确定")
	    noticeData.cancelLabel = TI18N("取消")
	    noticeData.showToggle = true
	    noticeData.toggleLabel = TI18N("今日不再提示")
	    noticeData.sureCallback = sureCall
		if isNoFree then
			noticeData.content = string.format(TI18N("是否消耗<color='#ffff00'>%s</color>个<color='#ffff00'>彩虹豆</color>刷新奖池"), num)
		else
			noticeData.content = string.format(TI18N("当前<color='#ffff00'>彩虹豆</color>不足，是否消耗{assets_1,90002,%s}立即刷新"), price)
		end
		NoticeManager.Instance:ConfirmTips(noticeData)
	else
		NoticeManager.Instance:FloatTipsByString(TI18N("背包中<color='#ffff00'>彩虹豆</color>不足，可通过<color='#ffff00'>国庆活动</color>获得{face_1,1}"))
		local info = {gameObject = self.needObj, itemData = self.noticeItemData}
		TipsManager.Instance:ShowItem(info)
		-- if num == 1 then
			-- noticeData.content = string.format(TI18N("当前<color='#ffff00'>彩虹豆</color>不足，是否消耗{assets_1,90002,%s}抽取1次"), price)
		-- else
			-- noticeData.content = string.format(TI18N("当前<color='#ffff00'>彩虹豆</color>不足，是否消耗{assets_1,90002,%s}抽取10次"), price)
		-- end
	end
end

function NationalDayRollPanel:CheckMoneyEnough(num)
	local enoughMoney = RoleManager.Instance.RoleData.gold >= self.price * tonumber(num)
	if not enoughMoney then
		NoticeManager.Instance:FloatTipsByString(TI18N("你的{assets_2,90002}不足"))
		return false
	end
	return true
end

function NationalDayRollPanel:RandomRoll(type, noCheck)
	if not self.canRoll then
		NoticeManager.Instance:FloatTipsByString(TI18N("活动将在每天19:00-22:00开启"))
		return
	end

	if self.rolling then
		return
	end

	if noCheck then
		-- if not self:CheckMoneyEnough(type) then
		-- 	return
		-- end
	else
		if type == 10 and self.has10 == 0 and self.has < type then
			if NationalDayManager.Instance.hasNoticeRoll10 then
				-- if not self:CheckMoneyEnough(type) then
				-- 	return
				-- end
			else
				self:BuyNotice(type)
				return
			end
		elseif type == 1 and self.has < type then
			if NationalDayManager.Instance.hasNoticeRoll1 then
				-- if not self:CheckMoneyEnough(type) then
				-- 	return
				-- end
			else
				self:BuyNotice(type)
			end
			return
		end
	end

	if not BaseUtils.is_null(self.effect) then
		self.effect:SetActive(false)
	end

	self.rolling = true
	self.rollType = type
	self.space = 0

	if self.rollId ~= nil then
		LuaTimer.Delete(self.rollId)
		self.rollId = nil
	end
	self.rollId = LuaTimer.Add(0, 40, self.rollCall)
end

function NationalDayRollPanel:Loop()
	if self.loopCount == 32 then
		if self.rollType == 10 then
			-- 10连抽
			NationalDayManager.Instance:Send14077()
		else
			NationalDayManager.Instance:Send14074()
		end
	end

	self.loopCount = self.loopCount + 1

	if self.slowDown then
		if self.count == self.target then
			self:End()
			self:ChooseOne()
			return
		end

		if self.loopCount % 3 == 0 then
			self.count = self.count + 1
		end
	else
		self.count = self.count + 1
	end

	if self.count > self.maxNum then
		self.count = 1
	end
	local item = self.itemList[self.count]
	if self.currItem ~= nil then
		self.currItem:Select(false)
	end
	self.currItem = item
	self.currItem:Select(true)
end

function NationalDayRollPanel:End()
	if self.rollId ~= nil then
		LuaTimer.Delete(self.rollId)
		self.rollId = nil
	end
	self.rolling = false
	self.loopCount = 0
	self.space = 0
	self.step = 1
	self.slowDown = false
end

function NationalDayRollPanel:ChooseOne()
	self.count = NationalDayManager.Instance.rainbow_id
	local item = self.itemList[self.count]
	if self.currItem ~= nil then
		self.currItem:Select(false)
	end
	self.currItem = item
	self.currItem:Select(true)
	self.currItem:ShowTime()

	if self.rollType ~= 10 then
		self.effectTransform.localPosition = self.currItem.position
		self.effect:SetActive(true)
		if self.effectTimeId ~= nil then
			LuaTimer.Delete(self.effectTimeId)
			self.effectTimeId = nil
		end
		self.effectTimeId = LuaTimer.Add(2000, function()
			if not BaseUtils.is_null(self.effect) then
				self.effect:SetActive(false)
			end
		end)
	end

	-- 展示完摇奖过程，请求发奖励
	NationalDayManager.Instance:Send14075()
end

function NationalDayRollPanel:OnResultBack()
	-- 得到结果，开始停下来
	self.step = 0
	self.space = 1
	self.target = NationalDayManager.Instance.rainbow_id
	self.slowDown = true
end

function NationalDayRollPanel:OnRefresh(noCheck)
	if not self.canRoll then
		NoticeManager.Instance:FloatTipsByString(TI18N("活动将在每天19:00-22:00开启"))
		return
	end

	if self.rolling then
		return
	end

	local isfree = NationalDayManager.Instance.model:IsFreeRefresh()
	if not isfree and not noCheck then
		if self.has < self.refreshCost then
			if NationalDayManager.Instance.hasNoticeRollRefresh then
				if not self:CheckMoneyEnough(self.refreshCost) then
					return
				end
			else
				self:BuyNotice(self.refreshCost, true)
				return
			end
		elseif self.has >= self.refreshCost then
			if NationalDayManager.Instance.hasNoticeRollRefreshFree then
				if not self:CheckMoneyEnough(self.refreshCost) then
					return
				end
			else
				self:BuyNotice(self.refreshCost, true, true)
				return
			end
		end
	end

	if not BaseUtils.is_null(self.effect) then
		self.effect:SetActive(false)
	end

	NationalDayManager.Instance:Send14076()
end

function NationalDayRollPanel:ShowNotice()
	if #NationalDayManager.Instance.rainbow_notice_list == 0 then
		return
	end

	if self.hasNoticeStart then
		return
	end

	self.hasNoticeStart = true
	self:NoticeNext()
end

function NationalDayRollPanel:NoticeNext()
	local notice = self.noticeList[self.noticeIndex]
	self.noticeIndex = self.noticeIndex + 1
	if self.noticeIndex >= #self.noticeList then
		self.noticeIndex = 1
	end
	notice:Run()
end

function NationalDayRollPanel:ShowFreeTime()
	local _, hour, minute, second = BaseUtils.time_gap_to_timer(self.freeCount)
	if minute < 10 then
		minute = string.format("0%s", minute)
	end
	if second < 10 then
		second = string.format("0%s", second)
	end
	self.noFreeTxt.text = string.format("%s:%s", minute, second)
end

function NationalDayRollPanel:ShowFreeLoop()
	if self.freeCount <= 0 then
		self:BeginFreeTime()
		return
	end
	self.freeCount = self.freeCount - 1
	self:ShowFreeTime()
end

function NationalDayRollPanel:BeginFreeTime()
	self:EndFreeTime()
	local isfree = NationalDayManager.Instance.model:IsFreeRefresh()
	if isfree then
		self.free:SetActive(true)
		self.noFree:SetActive(false)
	else
		self.free:SetActive(false)
		self.noFree:SetActive(true)
		self.freeCount = NationalDayManager.Instance.model.freeSpace
		self:ShowFreeTime()
		self.freeTimeId = LuaTimer.Add(0, 1000, function() self:ShowFreeLoop() end)
	end
end

function NationalDayRollPanel:EndFreeTime()
	if self.freeTimeId ~= nil then
		LuaTimer.Delete(self.freeTimeId)
		self.freeTimeId = nil
	end
end

function NationalDayRollPanel:ClickNeed()
	local info = {gameObject = self.needObj, itemData = self.needItemData}
	TipsManager.Instance:ShowItem(info)
end

function NationalDayRollPanel:Notice1()
end

function NationalDayRollPanel:Notice10()
	local info = {gameObject = self.needObj, itemData = self.needItemData}
	TipsManager.Instance:ShowItem(info)
end