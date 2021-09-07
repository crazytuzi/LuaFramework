--爬塔活动

ChildBirthHundredPanel = ChildBirthHundredPanel or BaseClass(BasePanel)

function ChildBirthHundredPanel:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "ChildBirthHundredPanel"

    self.resList = {
        {file = AssetConfig.child_hundred_panel, type = AssetType.Main},
        {file = AssetConfig.child_hundred_bg, type = AssetType.Main},
        {file = AssetConfig.childbirth_textures, type = AssetType.Dep},
        {file = AssetConfig.talisman_textures,type = AssetType.Dep}
    }
    self.timeFormatString1 = TI18N("%s小时%s分%s秒")
    self.timeFormatString2 = TI18N("%s分%s秒")
    self.timeFormatString3 = TI18N("%s秒")
    self.timeFormatString4 = TI18N("活动已结束")
    self.floorString = TI18N("当前所在<color='#ffff00'>第%s层</color>/n")

    self.levelList = {}
    self.itemList = {}
    self.recordList = {}
    self.effectList = {}
    self.iconloader = {}

    self.itemSlot = {}
    self.itemSloteffect = {}

    self.type = 1
    self.campId = nil

    self.timeListener = function() self:OnTimeListener() end
    self.gotoFloorListener = function(list) self:GotoFloors(list) end
    self.backpackListener = function() self:SetExhcangeNum() end
    self.updatetimes = function() self:Reload(0) end

    self.campaignData_cli = DataCampaign.data_list[CampaignManager.Instance.model:GetIdsByType(CampaignEumn.ShowType.FlowerHundred)[1]]
    self.exchangeBaseId = self.campaignData_cli.loss_items[1][1]

    self.targetMomont = os.time{year = self.campaignData_cli.cli_end_time[1][1], month = self.campaignData_cli.cli_end_time[1][2], day = self.campaignData_cli.cli_end_time[1][3], hour = self.campaignData_cli.cli_end_time[1][4], min = self.campaignData_cli.cli_end_time[1][5], sec = self.campaignData_cli.cli_end_time[1][6]}

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)

    self.voiceTextList =
    {
        [1] = "<color='#7FFF00'>当前所在</color><color='#ffff00'>第1层\n平步青云</color>",
        [2] = "<color='#7FFF00'>当前所在</color><color='#ffff00'>第2层\n扶摇直上</color>",
        [3] = "<color='#7FFF00'>当前所在</color><color='#ffff00'>第3层\n步步登高</color>",
        [4] = "<color='#7FFF00'>当前所在</color><color='#ffff00'>第4层\n吉运亨通</color>",
        [5] = "<color='#7FFF00'>当前所在</color><color='#ffff00'>第5层\n鸿喜云集</color>",
        [6] = "<color='#7FFF00'>当前所在</color><color='#ffff00'>第6层\n福与天齐</color>",
    }
end

function ChildBirthHundredPanel:__delete()
    self.OnHideEvent:Fire()
    for k,v in pairs(self.iconloader) do
        v:DeleteMe()
    end
    self.iconloader = {}
    if self.levelList ~= nil then
        for _,v in pairs(self.levelList) do
            if v ~= nil and v.itemList ~= nil then
                for _,item in pairs(v.itemList) do
                    if item ~= nil then
                        item.iconImage.sprite = nil
                    end
                end
            end
        end
        self.levelList = nil
        self.itemList = nil
    end

    if self.itemSloteffect[i] ~= nil then
        for i,v in pairs(self.itemSloteffect) do
            v:DeleteMe()
            v = nil
        end
    end

    if self.itemSlot ~= nil then
        for i,v in pairs(self.itemSlot) do
            v:DeleteMe()
            v = nil
        end
    end

    if self.tabLayout ~=  nil then
      self.tabLayout:DeleteMe()
      self.tabLayout = nil
    end

    if self.headSlot ~= nil then
        self.headSlot:DeleteMe()
        self.headSlot = nil
    end
    if self.recordList ~= nil then
        for _,v in pairs(self.recordList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.recordList = nil
    end
    if self.msgBox ~= nil then
        self.msgBox:DeleteMe()
        self.msgBox = nil
    end
    if self.frozon1 ~= nil then
        self.frozon1:DeleteMe()
        self.frozon1 = nil
    end
    if self.frozon2 ~= nil then
        self.frozon2:DeleteMe()
        self.frozon2 = nil
    end
    if self.selectEffect ~= nil then
        self.selectEffect:DeleteMe()
        self.selectEffect = nil
    end
    if self.chooseEffect ~= nil then
        self.chooseEffect:DeleteMe()
        self.chooseEffect = nil
    end
    if self.chooseEffect1 ~= nil then
        self.chooseEffect1:DeleteMe()
        self.chooseEffect1 = nil
    end
    if self.model.giftPanel ~= nil then
        self.model.giftPanel:DeleteMe()
        self.model.giftPanel = nil
    end
    if self.effectList ~= nil then
        for _,v in pairs(self.effectList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.effectList = nil
    end

    if self.imgLoaderOne ~= nil then
        self.imgLoaderOne:DeleteMe()
        self.imgLoaderOne = nil
    end

    self:AssetClearAll()
end

function ChildBirthHundredPanel:OnOpen()
    self:RemoveListeners()
    if self.timer2Id == nil then
        self.timer2Id = LuaTimer.Add(0, 300, function() self:OnTimeListener() end)
    end
    -- OpenBetaManager.Instance.onTickTime:AddListener(self.timeListener)
    ChildBirthManager.Instance.onHundredEvent:AddListener(self.gotoFloorListener)
    ChildBirthManager.Instance.onUpdateTower:AddListener(self.updatetimes)
    EventMgr.Instance:AddListener(event_name.backpack_item_change, self.backpackListener)

    local d = tonumber(os.date("%d", BaseUtils.BASE_TIME))
    local m = tonumber(os.date("%m", BaseUtils.BASE_TIME))
    local y = tonumber(os.date("%Y", BaseUtils.BASE_TIME))
    self.dailyStart = os.time{year = y, month = m, day = d, hour = 19, min = 0, sec = 0}
    self.dailyEnd = os.time{year = y, month = m, day = d, hour = 23, min = 0, sec = 0}

    --ChildBirthManager.Instance:send17824()
    self.frozon1:Release()
    self.frozon2:Release()
    self:OnTimeListener()
    self.headSlot:SetAll(RoleManager.Instance.RoleData, {isSmall = true})
    self:SetExhcangeNum()
    self:Reload(0)
    if self.selectEffect ~= nil then
        self.selectEffect:SetActive(false)
    end
    if self.chooseEffect ~= nil then
        self.chooseEffect:SetActive(false)
    end
    if self.chooseEffect1 ~= nil then
        self.chooseEffect1:SetActive(false)
    end

    local baseData = DataCampaign.data_list[self.campId]
    self.dateText.text = string.format(TI18N("%s年%s月%s日-%s年%s月%s日"), baseData.cli_start_time[1][1], baseData.cli_start_time[1][2], baseData.cli_start_time[1][3], baseData.cli_end_time[1][1], baseData.cli_end_time[1][2], baseData.cli_end_time[1][3])
    self:SetSelectPos(self.currentFloor)
end

function ChildBirthHundredPanel:OnHide()
    self:RemoveListeners()

    if self.timer2Id ~= nil then
        LuaTimer.Delete(self.timer2Id)
        self.timer2Id = nil
    end

    for _,v in pairs(self.itemList) do
        if v ~= nil then v.select:SetActive(false) end
    end
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
    if self.tweenId ~= nil then
        Tween.Instance:Cancel(self.tweenId)
        self.tweenId = nil
    end
    if self.waitNextId ~= nil then
        LuaTimer.Delete(self.waitNextId)
        self.waitNextId = nil
    end
end

function ChildBirthHundredPanel:RemoveListeners()
    -- OpenBetaManager.Instance.onTickTime:RemoveListener(self.timeListener)
    ChildBirthManager.Instance.onHundredEvent:RemoveListener(self.gotoFloorListener)
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.backpackListener)
    ChildBirthManager.Instance.onUpdateTower:RemoveListener(self.updatetimes)
end

function ChildBirthHundredPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.child_hundred_panel))
    local t = self.gameObject.transform
    self.transform = t
    UIUtils.AddUIChild(self.parent.mainContainer.gameObject, self.gameObject)
    --self.transform.anchoredPosition = Vector2(0,0)

    self.gameObject.name = self.name

    UIUtils.AddBigbg(t:Find("Bg"), GameObject.Instantiate(self:GetPrefab(AssetConfig.child_hundred_bg)))

    self.rewardCountText = t:Find("Count/ConText/Text"):GetComponent(Text)

    local levelContainer = t:Find("LevelContainer")
    --levelContainer.transform.anchoredPosition = Vector2(-84,61)
    for i=1,6 do
        local tab = {}
        tab.transform = levelContainer:Find("Level" .. i)
        tab.y = tab.transform.anchoredPosition.y
        tab.itemList = {}
        for j=1,7 - i do
            local tab1 = {}
            tab1.transform = tab.transform:GetChild(j - 1)
            tab1.gameObject = tab1.transform.gameObject
            tab1.iconImage = tab1.transform:Find("Icon"):GetComponent(Image)
            tab1.iconImage.gameObject:SetActive(true)
            tab1.floor = i
            tab1.numberText = tab1.transform:Find("Num"):GetComponent(Text)
            tab1.numberBg = tab1.transform:Find("NumberBg")
            tab1.select = tab1.transform:Find("SelectCircle").gameObject
            tab1.transform:GetComponent(Button).onClick:AddListener(function()
                if tab1.base_id ~= nil then
                    TipsManager.Instance:ShowItem({gameObject = tab1.transform.gameObject, itemData = DataItem.data_get[tab1.base_id], extra = {nobutton = true, inbag = false}})
                end
            end)
            tab1.select:SetActive(false)
            tab.itemList[j] = tab1
        end
        self.levelList[i] = tab
    end

    local list = {}
    for i,v in ipairs(DataCampWishFlower.data_list) do
        list[v.floor] = list[v.floor] or {}
        if (RoleManager.Instance.RoleData.lev >= v.min_lev and RoleManager.Instance.RoleData.lev <= v.max_lev) or v.max_lev == 0 then
            table.insert(list[v.floor], v.id)
        end
    end


    for i,v in ipairs(list) do
        table.sort(v, function(a,b)
        if   DataCampWishFlower.data_list[a].next_floor ~= DataCampWishFlower.data_list[b].next_floor then
            return (DataCampWishFlower.data_list[a].next_floor + 1) % 3 < (DataCampWishFlower.data_list[b].next_floor + 1) % 3
        else
            return a < b
        end

        end)

        for j,id in ipairs(list[i]) do
            local tab = self.levelList[i].itemList[j]
            tab.id = id
            tab.index = j
            tab.base_id = DataCampWishFlower.data_list[id].item[1][1]
            local id1 = tab.iconImage.gameObject:GetInstanceID()
            if self.iconloader[id1] == nil then
                self.iconloader[id1] = SingleIconLoader.New(tab.iconImage.gameObject)
            end
            self.iconloader[id1]:SetSprite(SingleIconType.Item, DataItem.data_get[tab.base_id].icon)
            tab.numberText.text = DataCampWishFlower.data_list[id].item[1][2]
            self.itemList[id] = tab
            if DataCampWishFlower.data_list[id].is_rare == 1 then
                table.insert(self.effectList, BibleRewardPanel.ShowEffect(20266, tab.transform, Vector3(1, 1, 1), Vector3(0, 0, -400)))
            end
        end
    end

    self.select = levelContainer:Find("Select")
    self.headSlot = HeadSlot.New()
    NumberpadPanel.AddUIChild(self.select:Find("Head"), self.headSlot.gameObject)

    self.bestMark = levelContainer:Find("BestMark")
    self.floorText = levelContainer:Find("Info"):GetComponent(Text)


    self.timeBg = t:Find("Info/Time/Bg")
    self.timeImg = t:Find("Info/Time/Image"):GetComponent(Image)
    self.timeText = t:Find("Info/Time/Text"):GetComponent(Text)
    t:Find("Notice").gameObject:SetActive(false)
    self.noticeBtn = t:Find("NoticeBtn"):GetComponent(Button)
    self.noticeBtn.transform.anchorMax = Vector2(0.5,0.5)
    self.noticeBtn.transform.anchorMin = Vector2(0.5,0.5)
    --self.noticeBtn.transform.anchoredPosition = Vector2(340,288)

    self.msgBox = ChildBirthHundredMsg.New(t:Find("Info/Record/Scroll/Container"), t:Find("Info/Record/Scroll/Cloner").gameObject)

    --额外奖励列表
    self.nextTime = t:Find("Info/TabContainer/I18N"):GetComponent(Text)

    local tabContainer = t:Find("Info/TabContainer")
    self.leftArrowTrans = tabContainer:Find("LeftArrow")
    self.leftArrowTrans:GetComponent(Button).onClick:AddListener(function() self:OnArrowClick(-1) end)
    self.rightArrowTrans = tabContainer:Find("RightArrow")
    self.rightArrowTrans:GetComponent(Button).onClick:AddListener(function() self:OnArrowClick(1) end)

    self.leftArrowTrans.gameObject:SetActive(false)
    self.rightArrowTrans.gameObject:SetActive(true)

    -- local tempSlot = {29739,23250,22438}
    self.tabLayout = LuaBoxLayout.New(t:Find("Info/TabContainer").gameObject,{axis = BoxLayoutAxis.x, cspacing = 7, border = 5})
    -- for i,v in ipairs (self.model.rewardList) do
    --     if self.itemSlot[i] == nil then
    --         self.itemSlot[i] = ItemSlot.New()
    --         NumberpadPanel.AddUIChild(t:Find(string.format("Info/TabContainer/Item%s",i)), self.itemSlot[i].gameObject)
    --     end
    --     self.itemSlot[i]:SetAll(DataItem.data_get[v.base_Id], {inbag = false, nobutton = true})
    --     self.itemSlot[i]:SetNum(v.num)
    --     self.tabLayout:AddCell(t:Find(string.format("Info/TabContainer/Item%s",i)).gameObject)
    --     t:Find(string.format("Info/TabContainer/Item%s",i)).gameObject:SetActive(true)
    -- end

    for i = 1, 2 do
        if self.itemSlot[i] == nil then
            self.itemSlot[i] = ItemSlot.New()
            NumberpadPanel.AddUIChild(t:Find(string.format("Info/TabContainer/Item%s",i)), self.itemSlot[i].gameObject)
        end
        --self.itemSlot[i]:SetAll(DataItem.data_get[v.base_Id], {inbag = false, nobutton = true})
        --self.itemSlot[i]:SetNum(v.num)
        self.tabLayout:AddCell(t:Find(string.format("Info/TabContainer/Item%s",i)).gameObject)
        t:Find(string.format("Info/TabContainer/Item%s",i)).gameObject:SetActive(true)
    end 

    --抽奖消耗品
    if self.imgLoaderOne == nil then
        self.imgLoaderOne = SingleIconLoader.New(t:Find("Info/Own/Tobbg/Icon").gameObject)
    end

    --抽奖按钮
    self.button1 = t:Find("Info/Own/Button1"):GetComponent(Button)
    self.button2 = t:Find("Info/Own/Button2"):GetComponent(Button)

    self.dateText = t:Find("Date"):GetComponent(Text)

    self.frozon1 = FrozenButton.New(self.button1.gameObject, {timeout = 20})
    self.frozon2 = FrozenButton.New(self.button2.gameObject, {timeout = 20})

    self.button1.onClick:AddListener(function() self:OnClick1() end)
    self.button2.onClick:AddListener(function() self:OnClick2() end)
    self.noticeBtn.onClick:AddListener(function() TipsManager.Instance:ShowText({gameObject = self.noticeBtn.gameObject, itemData = {self.campaignData_cli.cond_desc}, isChance = true}) TipsManager.Instance.model:ShowChance({chanceId = 213, special = true, isMutil = true})
     end)
end

function ChildBirthHundredPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function ChildBirthHundredPanel:Reload(lev)
    self.currentFloor = self.model.currentFloor or 1 --当前在第几层
    local rewardCount = self.model.rewardCount or 9999--已抽奖次数
    local next_times = 9999  --再抽多少次得到奖励
    local rewardList = self.model.rewardList or {}

    local level = lev
    local reward_list = {}   --当前显示的奖励
    self.rewardCountText.text = string.format(TI18N("%s次"), rewardCount)
    if level == 0 then
        --协议回调
        if next(rewardList) ~= nil then
            reward_list = rewardList[1].reward
            next_times = rewardList[1].next_times
            if next_times == 0 then
                self.nextTime.text = TI18N("已获得")
                level = 100
            else
                self.nextTime.text = string.format(TI18N("再抽%s次可获"),next_times)
                level = 1
            end
        end
        self.model.curRewardLevel = level
        self.model.curRewardShowLevel = level
    else
        --通过左右按钮刷新
        next_times = rewardList[level].next_times
        self.nextTime.text = string.format(TI18N("再抽%s次可获"),next_times)
        reward_list = BaseUtils.copytab(rewardList[level].reward)
    end
    
    --设置道具
    --BaseUtils.dump(reward_list,"reward_list")
    for i,v in ipairs (reward_list) do
        if self.itemSlot[i] ~= nil then
            self.itemSlot[i]:SetAll(DataItem.data_get[v.base_id], {inbag = false, nobutton = true})
            self.itemSlot[i]:SetNum(v.num)
            if v.effect == 1 then
                if self.itemSloteffect[i] == nil then
                    self.itemSloteffect[i] = BibleRewardPanel.ShowEffect(20223,self.itemSlot[i].transform,Vector3(0,0,0),Vector3(0,0,-400))
                else
                    self.itemSloteffect[i]:SetActive(true)
                end
            end
        end
    end
    self:SetArrowStatus(level)
end

--copy
function ChildBirthHundredPanel:OnArrowClick(index)
    local rewardList = self.model.rewardList
    self.leftArrowTrans.gameObject:SetActive(true)
    self.rightArrowTrans.gameObject:SetActive(true)
    local showLev = self.model.curRewardShowLevel --显示等级
    showLev = showLev + index
    if showLev <= (#rewardList) and showLev >= 1 then
        self.model.curRewardShowLevel = showLev
    end
    self:Reload(self.model.curRewardShowLevel)
end


function ChildBirthHundredPanel:SetArrowStatus(showLev)
    local rewardList = self.model.rewardList
    self.leftArrowTrans.gameObject:SetActive(true)
    self.rightArrowTrans.gameObject:SetActive(true)
    if showLev == self.model.curRewardLevel then
        self.leftArrowTrans.gameObject:SetActive(false)
    end
    if showLev == (#rewardList) then
        self.rightArrowTrans.gameObject:SetActive(false)
    end
    if showLev == 100 then
        self.leftArrowTrans.gameObject:SetActive(false)
        self.rightArrowTrans.gameObject:SetActive(false)
    end
end
--end

function ChildBirthHundredPanel:OnTimeListener()
    local d = nil
    local h = nil
    local m = nil
    local s = nil

    local time = 0
    if BaseUtils.BASE_TIME < self.dailyStart then
        self.timeImg.sprite = self.assetWrapper:GetSprite(AssetConfig.childbirth_textures, "I18NFromStart")
        time = self.dailyStart
    else
        self.timeImg.sprite = self.assetWrapper:GetSprite(AssetConfig.childbirth_textures, "I18NLeftTime")
        time = self.dailyEnd
    end
    if BaseUtils.BASE_TIME < time then
        d,h,m,s = BaseUtils.time_gap_to_timer(time - BaseUtils.BASE_TIME)
        if d ~= 0 then
            self.timeText.text = string.format(self.timeFormatString1, tostring(d * 24 + h), tostring(m), tostring(s))
        elseif h ~= 0 then
            self.timeText.text = string.format(self.timeFormatString1, tostring(h), tostring(m), tostring(s))
        elseif m ~= 0 then
            self.timeText.text = string.format(self.timeFormatString2, tostring(m), tostring(s))
        else
            self.timeText.text = string.format(self.timeFormatString3, tostring(s))
        end
    else
        self.timeText.text = self.timeFormatString4
    end

    -- local w = math.ceil(self.timeText.preferredWidth + 20)
    -- self.timeBg.sizeDelta = Vector2(w, 35)
end

function ChildBirthHundredPanel:GotoFloors(list)
    if #list > 0 then
        self.frozon1:OnClick()
        self.frozon2:OnClick()
        self.resultList = list
        if #list > 0 then
            self:GotoFloor(1)
        end
    else
        self.frozon1:Release()
        self.frozon2:Release()
    end
end

-- 往下一层
function ChildBirthHundredPanel:GotoFloor(index)

    local id = self.resultList[index].id
    self.currentFloor = DataCampWishFlower.data_list[id].floor

    if self.currentFloor == 6 then
        self.bestMark.gameObject:SetActive(false)
    else
        self.bestMark.gameObject:SetActive(true)
        self.bestMark.anchoredPosition = Vector2(32 * (6 - self.currentFloor) + 8, self.levelList[self.currentFloor + 1].y)
    end

    if self.timerId == nil then
        if self.currentFloor == 6 then
            self.lastId = 1     -- 没卵用的，只是为了不为nil
            self.targetId = id
            self:GoNextStep(index)
        else
            self.lastId = self.levelList[self.currentFloor].itemList[1].id
            self.timerId = LuaTimer.Add(0, 50, function()
                self:GoNextStep(index)
            end)
            LuaTimer.Add(1500 / self.type, function()
                self.targetId = id
            end)
        end
    end
end

-- 走下一步
function ChildBirthHundredPanel:GoNextStep(index)
    if self.lastId ~= nil then
        self.itemList[self.lastId].select:SetActive(false)
        if self.selectEffect ~= nil then
            self.selectEffect:SetActive(false)
        end

        local floor = self.currentFloor or 1
        self.lastId = self.levelList[floor].itemList[self.itemList[self.lastId].index % (7 - floor) + 1].id
    else
        self.lastId = 1
    end

    if self.lastId ~= self.targetId then
        self.itemList[self.lastId].select:SetActive(true)
        if self.selectEffect == nil then
            self.selectEffect = BibleRewardPanel.ShowEffect(20259, self.itemList[self.lastId].transform, Vector3(1, 1, 1), Vector3(0, 0, -4-0))
        else
            self.selectEffect:SetActive(false)
            if not BaseUtils.isnull(self.selectEffect.gameObject) then
                self.selectEffect.gameObject.transform:SetParent(self.itemList[self.lastId].transform)
                self.selectEffect.gameObject.transform.localScale = Vector3(1, 1, 1)
                self.selectEffect.gameObject.transform.localPosition = Vector3(0, 0, -400)
            end
            self.selectEffect:SetActive(true)
        end
    else
        local id = self.targetId

        if self.timerId ~= nil then
            LuaTimer.Delete(self.timerId)
            self.timerId = nil
        end

        if self.tweenId ~= nil then
            Tween.Instance:Cancel(self.tweenId)
        end
        self.tweenId = Tween.Instance:ValueChange(self.select.anchoredPosition.y, self.levelList[self.resultList[index].floor].y, 0.6 / self.type, function() self.tweenId = nil
            -- self.currentFloor = self.resultList[index].floor
            -- self:SetSelectPos(self.resultList[index].floor)
        end, LeanTweenType.easeOutQuad, function(value) self.select.anchoredPosition = Vector2(self.select.anchoredPosition.x, value - 2) end).id


        self.lastId = nil
        self.targetId = nil

        self:ShowFocus(id)

        -- 如果还有下一个的话，继续走
        if self.resultList[index + 1] ~= nil then
            if self.waitNextId ~= nil then
                LuaTimer.Delete(self.waitNextId)
            end
            self:MoveSelect(DataCampWishFlower.data_list[self.resultList[index].id].floor)
            self.waitNextId = LuaTimer.Add(500, function() self:GoNextStep2(index + 1) end)
        else
            self.frozon1:Release()
            self.frozon2:Release()

            local datalist = {}
            for i,v in ipairs(self.resultList) do
                local item = DataCampWishFlower.data_list[v.id].item[1]
                table.insert(datalist, {item[1], item[2], DataCampWishFlower.data_list[v.id].next_floor})
            end
            if self.type == 2 then
                LuaTimer.Add(300, function()
                    CollectPanel.PlayEffectTest(20152)
                    self:OnShowFinalGift(datalist, TI18N("恭喜您抽中以下物品："))
                end)
            else
                NoticeManager.Instance:FloatTipsByString(string.format(TI18N("你获得了{item_2,%s,0,%s}"), tostring(datalist[1][1]), tostring(datalist[1][2])))
            end
        end
    end
end

function ChildBirthHundredPanel:MoveSelect(floor, callback)
    if self.tweenId ~= nil then
        Tween.Instance:Cancel(self.tweenId)
    end
    self.tweenId = Tween.Instance:ValueChange(self.select.anchoredPosition.y, self.levelList[floor].y, 0.6 / self.type, function() self.tweenId = nil
        if callback ~= nil then callback() end
    end, LeanTweenType.easeOutQuad, function(value) self.select.anchoredPosition = Vector2(self.select.anchoredPosition.x, value - 2) end).id
end

function ChildBirthHundredPanel:ShowChooseEffect1(id)
    if self.chooseEffect1 == nil then
        self.chooseEffect1 = BibleRewardPanel.ShowEffect(20261, self.itemList[id].transform, Vector3(1, 1, 1), Vector3(0, 0, -400))
    else
        self.chooseEffect1:SetActive(false)
        if not BaseUtils.isnull(self.chooseEffect1.gameObject) then
            self.chooseEffect1.transform:SetParent(self.itemList[id].transform)
            self.chooseEffect1.transform.localScale = Vector3(1, 1, 1)
            self.chooseEffect1.transform.localPosition = Vector3(0, 0, -400)
        end
        self.chooseEffect1:SetActive(true)
    end
end

function ChildBirthHundredPanel:ShowChooseEffect(id)
    if self.chooseEffect == nil then
        self.chooseEffect = BibleRewardPanel.ShowEffect(20258, self.itemList[id].transform, Vector3(1, 1, 1), Vector3(0, 0, -400))
    else
        self.chooseEffect:SetActive(false)
        if not BaseUtils.isnull(self.chooseEffect.gameObject) then
            self.chooseEffect.transform:SetParent(self.itemList[id].transform)
            self.chooseEffect.transform.localScale = Vector3(1, 1, 1)
            self.chooseEffect.transform.localPosition = Vector3(0, 0, -400)
        end
        self.chooseEffect:SetActive(true)
    end
end

function ChildBirthHundredPanel:GoNextStep2(index)
    if (self.currentFloor or 1) < DataCampWishFlower.data_list[self.resultList[index].id].floor then
        self:ShowChooseEffect(self.resultList[index].id)
    else
        self:ShowChooseEffect1(self.resultList[index].id)
    end

    if self.resultList[index + 1] ~= nil then
        if self.waitNextId ~= nil then
            LuaTimer.Delete(self.waitNextId)
        end
        self.currentFloor = DataCampWishFlower.data_list[self.resultList[index].id].floor

        self:MoveSelect(self.currentFloor)
        self.floorText.text = string.format(self.voiceTextList[self.currentFloor], tostring(self.currentFloor))
        self.waitNextId = LuaTimer.Add(500, function() self:GoNextStep2(index + 1) end)
    else
        self.frozon1:Release()
        self.frozon2:Release()
        self:MoveSelect(self.model.currentFloor or 1, function() self:SetSelectPos(self.model.currentFloor or 1) end)
        -- self:SetSelectPos(self.model.currentFloor or 1)

        local datalist = {}
        for i,v in ipairs(self.resultList) do
            local item = DataCampWishFlower.data_list[v.id].item[1]
            table.insert(datalist, {item[1], item[2], DataCampWishFlower.data_list[v.id].next_floor})
        end
        LuaTimer.Add(300, function()
            CollectPanel.PlayEffectTest(20152)
            self:OnShowFinalGift(datalist, TI18N("恭喜您抽中以下物品："))
        end)
    end
end

function ChildBirthHundredPanel:ShowFocus(id)
    self.itemList[id].select:SetActive(false)
    if self.selectEffect ~= nil then
        self.selectEffect:SetActive(false)
    end
    -- Tween.Instance:Scale(self.itemList[id].gameObject, Vector3(1.2,1.2,1.2), 0.5, function()
    --     Tween.Instance:Scale(self.itemList[id].gameObject, Vector3(1,1,1), 0.5, function() end, LeanTweenType.easeOutElastic)
    -- end, LeanTweenType.easeOutElastic)

    if self.chooseEffect == nil then
        self.chooseEffect = BibleRewardPanel.ShowEffect(20258, self.itemList[id].transform, Vector3(1, 1, 1), Vector3(0, 0, -400))
    else
        self.chooseEffect:SetActive(false)
        if not BaseUtils.isnull(self.chooseEffect.gameObject) then
            self.chooseEffect.transform:SetParent(self.itemList[id].transform)
            self.chooseEffect.transform.localScale = Vector3(1, 1, 1)
            self.chooseEffect.transform.localPosition = Vector3(0, 0, -400)
        end
        self.chooseEffect:SetActive(true)
    end
end

function ChildBirthHundredPanel:SetSelectPos(floor)
    if floor == 6 then
        self.bestMark.gameObject:SetActive(false)
    else
        self.bestMark.gameObject:SetActive(true)
        self.bestMark.anchoredPosition = Vector2(32 * (6 - (floor)) + 8, self.levelList[(floor) + 1].y)
    end
    self.select.anchoredPosition = Vector2(self.select.anchoredPosition.x, self.levelList[floor].y - 2)
    self.floorText.text = string.format(self.voiceTextList[floor], tostring(floor))
end


function ChildBirthHundredPanel:SetExhcangeNum()
    self.imgLoaderOne:SetSprite(SingleIconType.Item, DataItem.data_get[self.exchangeBaseId].icon)
    local num = BackpackManager.Instance:GetItemCount(self.exchangeBaseId)
    --     self.itemSlot:SetNum(num, 1)
    local textCount = self.gameObject.transform:Find("Info/Own/Tobbg/RightText"):GetComponent(Text)
    if num < 1 then
        textCount.text = string.format("<color='#ff0000'>%s</color><color='#ffff00'>/</color>%s", tostring(num), 1)
    else
        textCount.text = string.format("<color='#00ff00'>%s</color><color='#ffff00'>/</color>%s", tostring(num), 1)
    end
end

function ChildBirthHundredPanel:OnShowFinalGift(itemlist, title)
    if self.model.giftPanel == nil then
        self.model.giftPanel = GiftPreview.New(self.parent.gameObject)
    end
    self.model.giftPanel.showClose = true
    self.model.giftPanel.hideCallback = function()
        for _,v in pairs(self.effectList) do
            if v ~= nil then v:SetActive(true) end
        end
    end
    for _,v in pairs(self.effectList) do
        if v ~= nil then v:SetActive(false) end
    end
    self.model.giftPanel:Show({text = title, autoMain = true, column = 4, reward = itemlist})
end

-- 又是测试代码
function ChildBirthHundredPanel:OnClick1()
    self.type = 1
    if BackpackManager.Instance:GetItemCount(self.exchangeBaseId) > 0 then
        self.frozon1:OnClick()
        self.frozon2:OnClick()
    else
        TipsManager.Instance:ShowItem({gameObject = self.button1.gameObject, itemData = DataItem.data_get[self.exchangeBaseId]})
    end
    ChildBirthManager.Instance:send17825(1)
end

function ChildBirthHundredPanel:OnClick2()
    self.type = 2
    if BackpackManager.Instance:GetItemCount(self.exchangeBaseId) > 9 then
        self.frozon1:OnClick()
        self.frozon2:OnClick()
    else
        TipsManager.Instance:ShowItem({gameObject = self.button2.gameObject, itemData = DataItem.data_get[self.exchangeBaseId]})
    end
    ChildBirthManager.Instance:send17825(10)
end

