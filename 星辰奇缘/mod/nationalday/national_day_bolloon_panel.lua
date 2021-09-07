--作者:hosr
--16-9-22 下07时44分29秒
--功能:国庆活动气球收集  庆典贺华诞

NationDayBolloonPanel = NationDayBolloonPanel or BaseClass(BasePanel)
function NationDayBolloonPanel:__init(parent)
	self.parent = parent
	self.effectPath = string.format(AssetConfig.effect, "20053")
	self.effect = nil

	self.effectPath1 = string.format(AssetConfig.effect, "20049")
	self.effect1 = nil

	self.effect2 = nil

	self.resList = {
		{file = AssetConfig.nationaldayballoonpanel, type = AssetType.Main},
		--{file = AssetConfig.nationaldayballoonbg, type = AssetType.Main},
		{file = self.effectPath, type = AssetType.Main},
		{file = self.effectPath1, type = AssetType.Main},
		{file = AssetConfig.national_day_res, type = AssetType.Dep},
	}
	self.OnOpenEvent:Add(function() self:OnOpen() end)
	self.OnHideEvent:Add(function() self:OnHide() end)

	self.listener = function() self:SetData() end
	self.itemChangeListener = function() end

	self.hasInit = false

	self.itemList = {}
	self.currItem = nil
	self.currIndex = 1
	self.hasNeed = 0
end

function NationDayBolloonPanel:__delete()
	self:OnHide()

	self.getbtnImg.sprite = nil

	for i,v in ipairs(self.itemList) do
		v:DeleteMe()
	end
	self.itemList = nil

	if self.needSlot ~= nil then
		self.needSlot:DeleteMe()
		self.needSlot = nil
	end

	if self.RewardSlot ~= nil then
		self.RewardSlot:DeleteMe()
		self.RewardSlot = nil
	end
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

function NationDayBolloonPanel:OnHide()
	self:RemoveListener()
	self:EndLoop()

	-- if not BaseUtils.is_null(self.effect) then
	-- 	self.effect:SetActive(false)
	-- end

	if not BaseUtils.is_null(self.effect1) then
		self.effect1:SetActive(false)
	end

	-- if not BaseUtils.is_null(self.effect2) then
	-- 	self.effect2:SetActive(false)
	-- end
end

function NationDayBolloonPanel:OnOpen()
	self:SetData(true)
	self:AddListener()
end

function NationDayBolloonPanel:AddListener()
	EventMgr.Instance:AddListener(event_name.welfare_bags_info_update, self.listener)
	-- EventMgr.Instance:AddListener(event_name.backpack_item_change, self.itemChangeListener)
end

function NationDayBolloonPanel:RemoveListener()
	EventMgr.Instance:RemoveListener(event_name.welfare_bags_info_update, self.listener)
	-- EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.itemChangeListener)
end

function NationDayBolloonPanel:InitPanel()
	self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.nationaldayballoonpanel))
	self.gameObject.name = "NationDayBolloonPanel"

	self.transform = self.gameObject.transform
	self.transform:SetParent(self.parent.transform)
	self.transform.localScale = Vector3.one
	self.transform.localPosition = Vector3.zero

    --local obj = GameObject.Instantiate(self:GetPrefab(AssetConfig.nationaldayballoonbg))
    --UIUtils.AddBigbg(self.transform:Find("Bg"), obj)
    --obj.transform:SetAsFirstSibling()
	-- self.transform:Find("Bg"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.nationaldayballoonbg, "NationalDayBalloonBg")

	self.transform:Find("TimeText"):GetComponent(Text).text = TI18N("2016年9月30日-2016年10月7日")
	self.TimeText = self.transform:Find("RemindTimeBgImage/TimeText"):GetComponent(Text)
	self.ConDescText = self.transform:Find("ConDescText"):GetComponent(Text)
	self.ConDescText.text = TI18N("活动内容:<color='#C9F9FE'>活动期间每天<color='#FFFEA0'>收集相应颜色气球</color>可以获得奖励</color>")

	self.Container = self.transform:Find("Container")
	local len = self.Container.childCount
	for i = 1, len do
		local item = NationalDayBolloonItem.New(self.Container:GetChild(i - 1), self)
		table.insert(self.itemList, item)
	end

	self.Full = self.transform:Find("Full").gameObject
	self.NotFull = self.transform:Find("NotFull").gameObject

    self.RewardSlot = ItemSlot.New()
    UIUtils.AddUIChild(self.transform:Find("RewardSlot").gameObject, self.RewardSlot.gameObject)

    self.needSlot = ItemSlot.New()
    UIUtils.AddUIChild(self.transform:Find("NotFull/NeedSlot").gameObject, self.needSlot.gameObject)

    self.getbtnObj = self.transform:Find("Full/GetButton").gameObject
	self.transform:Find("Full/GetButton"):GetComponent(Button).onClick:AddListener(function() self:ClickGetReward() end)
	self.transform:Find("NotFull/FildButton"):GetComponent(Button).onClick:AddListener(function() self:ClickFill() end)
	self.red = self.transform:Find("NotFull/FildButton/Red").gameObject

	self.helpObj = self.transform:Find("NotFull/AskHelpButton").gameObject
	self.helpObj:GetComponent(Button).onClick:AddListener(function() self:ClickHelp() end)
	self.getbtnImg = self.transform:Find("Full/GetButton/Icon"):GetComponent(Image)

	self.imgLoader = SingleIconLoader.New(self.transform:Find("Full/GetButton/Icon").gameObject)
	self.imgLoader:SetSprite(SingleIconType.Item, 22505)

    self.effect = GameObject.Instantiate(self:GetPrefab(self.effectPath))
    local effectTransform = self.effect.transform
    effectTransform:SetParent(self.RewardSlot.transform)
    effectTransform.localScale = Vector3.one
    effectTransform.localPosition = Vector3(-32, -23, -500)
    Utils.ChangeLayersRecursively(effectTransform, "UI")
    self.effect:SetActive(true)

    self.effect2 = GameObject.Instantiate(self:GetPrefab(self.effectPath))
    local effectTransform = self.effect2.transform
    effectTransform:SetParent(self.getbtnObj.transform)
    effectTransform.localScale = Vector3(2.1, 0.7, 1)
    effectTransform.localPosition = Vector3(-65, -17, -500)
    Utils.ChangeLayersRecursively(effectTransform, "UI")
    self.effect2:SetActive(true)

    self.effect1 = GameObject.Instantiate(self:GetPrefab(self.effectPath1))
    self.effectTransform = self.effect1.transform
    self.effectTransform:SetParent(self.Container)
    self.effectTransform.localScale = Vector3.one
    self.effectTransform.localPosition = Vector3(0, 0, -500)
    Utils.ChangeLayersRecursively(self.effectTransform, "UI")
    self.effect1:SetActive(false)

	self:OnOpen()
end

function NationDayBolloonPanel:SetData(isInit)
	self:UpdateBagInfo(isInit)
	self:BeginLoop()

	local red = NationalDayManager.Instance.model:CheckBalloonRed()
	self.red:SetActive(red)

	if self.currItem ~= nil then
		self.currItem:Select(false)
	end
	self.currItem = self.itemList[self.currIndex]
	self:SelectOne(self.currItem)
end

function NationDayBolloonPanel:UpdateBagInfo(isInit)
	local list = {[1]={id=27000,num=1,status=0},[2]={id=27001,num=1,status=0},[3]={id=27003,num=1,status=0},[4]={id=27005,num=1,status=0}}--CampaignManager.Instance.campaign_bags.collected
	self.IsFinish = true
	local index = nil
	for i,v in ipairs(list) do
		local item = self.itemList[i]
		local tempFinish = item:IsFinish()
		item:SetData(v)
		if not isInit and tempFinish ~= item:IsFinish() then
			self.effectTransform.localPosition = item:GetPos()
			self.effect1:SetActive(false)
			self.effect1:SetActive(true)
		end

		if item:CanFill() and index == nil then
			index = i
		end
		self.IsFinish = self.IsFinish and item:IsFinish()
	end

	if index ~= nil then
		self.currIndex = index
	end

	self.Full:SetActive(self.IsFinish)
	self.NotFull:SetActive(not self.IsFinish)
	self.getbtnObj:SetActive(CampaignManager.Instance.campaign_bags.rewarded == 0)
end

function NationDayBolloonPanel:SelectOne(item)
	if self.currItem ~= nil then
		self.currItem:Select(false)
	end
	self.currItem = item
	self.currItem:Select(true)
	self:UpadteInfo()
end

function NationDayBolloonPanel:UpadteInfo()
	local baseId = self.currItem.base.id

	if self.needItemData == nil then
		self.needItemData = ItemData.New()
	end
	self.hasNeed = BackpackManager.Instance:GetItemCount(baseId)
	self.needItemData:SetBase(DataItem.data_get[baseId])
	self.needSlot:SetAll(self.needItemData)
	self.needSlot:SetNum(self.hasNeed, self.currItem.base.need)

	if self.rewardItemData == nil then
		self.rewardItemData = ItemData.New()
		local rewardBaseId = self.currItem.base.reward_full[1][1]
		local rewardNum = self.currItem.base.reward_full[1][2]
		self.rewardItemData:SetBase(DataItem.data_get[rewardBaseId])
		self.RewardSlot:SetAll(self.rewardItemData)
		self.RewardSlot:SetNum(rewardNum)
	end
end

function NationDayBolloonPanel:UpdateTime()
    local day,hour,min,second = BaseUtils.time_gap_to_timer(self.time)
    local timeStr = tostring(hour)
    if hour < 10 then
        timeStr = "0"..tostring(hour)
    end
    if min < 10 then
        timeStr = timeStr.. TI18N("小时0") .. tostring(min)
    else
        timeStr = timeStr.. TI18N("小时") .. tostring(min)
    end
    if second < 10 then
        timeStr = string.format(TI18N("%s分钟0%s秒"), timeStr, second)
    else
        timeStr = string.format(TI18N("%s分钟%s秒"), timeStr, second)
    end
	self.TimeText.text = timeStr
end

function NationDayBolloonPanel:BeginLoop()
    local ph = tonumber(os.date("%H", BaseUtils.BASE_TIME))
    local pm = tonumber(os.date("%M", BaseUtils.BASE_TIME))
    local ps = tonumber(os.date("%S", BaseUtils.BASE_TIME))
    self.time = 86400 - ph * 3600 - pm * 60 - ps
    if self.time <= 0 then
    	self.TimeText.text = TI18N("00时00分00秒")
    	self:EndLoop()
    	return
    end
    self:EndLoop()
	self:UpdateTime()
	self.timeId = LuaTimer.Add(0, 1000, function() self:Loop() end)
end

function NationDayBolloonPanel:Loop()
	self.time = self.time - 1
	self:UpdateTime()
end

function NationDayBolloonPanel:EndLoop()
	if self.timeId ~= nil then
		LuaTimer.Delete(self.timeId)
		self.timeId = nil
	end
end

function NationDayBolloonPanel:ClickHelp()
    local btns = {{label = TI18N("好友求助"), callback = function() self:ShareToFriend() end}
            , {label = TI18N("公会求助"), callback = function() self:ShareToGuild() end}}
    TipsManager.Instance:ShowButton({gameObject = self.helpObj, data = btns})
end

function NationDayBolloonPanel:ClickFill()
	if self.currItem == nil or self.currItem.data == nil then
		return
	end

	if self.hasNeed == 0 then
		self.needSlot:SureClick()
		return
	end

	CampaignManager.Instance:Send14010(self.currItem.data.id)
end

function NationDayBolloonPanel:ClickGetReward()
	CampaignManager.Instance:Send14014()
end

function NationDayBolloonPanel:ShareToFriend()
    local callBack = function(_, friendData)
    	CampaignManager.Instance:Send14012(friendData.id, friendData.platform, friendData.zone_id, self.currItem.data.id)
    	NoticeManager.Instance:FloatTipsByString(TI18N("求助发送成功"))
    end
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.friendselect, {callBack})
end

function NationDayBolloonPanel:ShareToGuild()
    if GuildManager.Instance.model:check_has_join_guild() then
		CampaignManager.Instance:Send14013(self.currItem.data.id)
		NoticeManager.Instance:FloatTipsByString(TI18N("求助发送成功"))
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("请创建或加入一个公会"))
    end
end
