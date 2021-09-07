-- 作者:jia
-- 5/8/2017 11:27:23 AM
-- 功能:套娃panel

DollsRandomPanel = DollsRandomPanel or BaseClass(BasePanel)
function DollsRandomPanel:__init(parent)
    self.model = DollsRandomManager.Instance.model
    self.parent = parent
    self.resList = {
        { file = AssetConfig.dollsrandompanel, type = AssetType.Main },
        { file = AssetConfig.dollsrandombigbg, type = AssetType.Main },
        { file = string.format(AssetConfig.effect, 20363), type = AssetType.Main },
        { file = string.format(AssetConfig.effect, 20368), type = AssetType.Main },
        { file = AssetConfig.may_textures, type = AssetType.Dep },
        { file =  AssetConfig.textures_campaign, type = AssetType.Dep }
    }
    self.OnOpenEvent:Add( function() self:OnOpen() end)
    self.OnHideEvent:Add( function() self:OnHide() end)
    self.hasInit = false
    self.slotItems = { }
    -- 打开套娃消耗的物品id
    --self.ItemKeyId = ValentineManager.Instance.DollsItemId
    -- 套娃数据
    self.DollsListData = { }
    -- 套娃ItemList
    self.DollsItemList = { }
    -- 已打开的套娃
    self.OpenedNum = 0
    -- 是否第一次init数据
    self.isFirstInit = true
    -- 当前活动开始时间
    self.BeginTime = 0
    -- 当前活动结束时间
    self.EndTime = 0
    -- 上次抖动的index
    self.lastIndex = 0
    self.curLuckey = 0
    self.ImgLoadetrs = { }

    self.itemSlot = {}

    self.RudeData =
    {
        TI18N("1、每砸开<color='#ffff00'>1</color>个金蛋或者精灵兜兜可获得<color='#ffff00'>1</color>次道具奖励和<color='#ffff00'>5</color>个彩蛋积分")
        ,TI18N("2、每次砸开可获得幸运值，幸运值<color='#ffff00'>越高</color>刷新出精灵兜兜的几率<color='#ffff00'>越大</color>")
        ,TI18N("3、幸运值满时刷新必出精灵兜兜，活动期间每天<color='#ffff00'>19:00~23:00</color>可进行砸蛋")
    }
    self.updateFun = function() self:UpdateDolls() end
    self.callBackFun = function(data) self:OnOpenDollsBack(data) end
    self.OpenAllDolls = function() self:OpenAllFun() end
    self.RefreshDolls = function() self:RefreshFun() end
    self.RefershItemKey = function() self:RefershItemKeyNumFun() end

    self._RewardlistUpdate = function() self:OnRewardlistUpdate(0) self:SetDollTimes() end
    self:InitHandler()
end

function DollsRandomPanel:__delete()
    self:RemoveHandler()
    self.hasInit = false
    if self.timer_luckey ~= nil then
        LuaTimer.Delete(self.timer_luckey)
        self.timer_luckey = nil
    end
    if self.openPanel ~= nil then
        self.openPanel:DeleteMe()
        self.openPanel = nil
    end
    if self.timer4 ~= nil then
        LuaTimer.Delete(self.timer4)
        self.timer4 = nil
    end
    if self.timer5 ~= nil then
        LuaTimer.Delete(self.timer5)
        self.timer5 = nil
    end
    if self.DollsItemList ~= nil then
        for _, item in pairs(self.DollsItemList) do
            item:DeleteMe()
        end
    end
    self.DollsItemList = nil
    if self.slotItems ~= nil then
        for _, v in pairs(self.slotItems) do
            v:DeleteMe()
        end
        self.slotItems = nil
    end
    if self.ImgLoadetrs ~= nil then
        for _, loader in pairs(self.ImgLoadetrs) do
            loader:DeleteMe()
            loader = nil
        end
        self.ImgLoadetrs = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function DollsRandomPanel:OnHide()
    if self.timer4 ~= nil then
        LuaTimer.Delete(self.timer4)
        self.timer4 = nil
    end
    if self.timer5 ~= nil then
        LuaTimer.Delete(self.timer5)
        self.timer5 = nil
    end
end

function DollsRandomPanel:OnOpen()
    --DollsRandomManager.Instance.RequestDollsData()
    DollsRandomManager.Instance:send20459()
    DollsRandomManager.Instance.isOpening = false

    self.ItemKeyId = DataCampaign.data_list[self.campId].loss_items[1][1] or 70407

    for index = 1, 3 do
        local imgLoader = SingleIconLoader.New(self.transform:Find("Main/RightContain/ImgKeyIcon" .. index):GetComponent(Image).gameObject)
        imgLoader:SetSprite(SingleIconType.Item, DataItem.data_get[self.ItemKeyId].icon)-- ValentineManager.Instance.CreamItemId
        table.insert(self.ImgLoadetrs, imgLoader)
    end
    self:UpdateDolls()
    self:RefershItemKeyNumFun()

    self:InitCampaignTime()
    self:PlayRefresh()
    self:RandomShake()
    --LuaTimer.Add(500,function() self:OnArrowClick(0) end)
end

function DollsRandomPanel:InitHandler()
    EventMgr.Instance:AddListener(event_name.dolls_open_back, self.callBackFun)
    EventMgr.Instance:AddListener(event_name.dolls_data_update, self.updateFun)
    EventMgr.Instance:AddListener(event_name.backpack_item_change, self.RefershItemKey)
    DollsRandomManager.Instance.onRewardlistUpdate:AddListener(self._RewardlistUpdate)
end

function DollsRandomPanel:RemoveHandler()
    EventMgr.Instance:RemoveListener(event_name.dolls_open_back, self.callBackFun)
    EventMgr.Instance:RemoveListener(event_name.dolls_data_update, self.updateFun)
    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.RefershItemKey)
    DollsRandomManager.Instance.onRewardlistUpdate:RemoveListener(self._RewardlistUpdate)
end

function DollsRandomPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.dollsrandompanel))
    self.gameObject.name = "DollsRandomPanel"
    UIUtils.AddUIChild(self.parent, self.gameObject)

    self.transform = self.gameObject.transform
    self.main = self.transform:Find("Main")

    local bigbg = GameObject.Instantiate(self:GetPrefab(AssetConfig.dollsrandombigbg))
    self.transform:Find("Main/BigBg").anchoredPosition = Vector2(14.2, -88)
    bigbg.gameObject.transform.localScale = Vector3(1, 1, 1)
    UIUtils.AddBigbg(self.transform:Find("Main/BigBg"), bigbg)

    self.TopContain = self.transform:Find("Main/TopContain/Container")
    self.transform:Find("Main/LeftContain/LuckeyBtn"):GetComponent(Button).onClick:AddListener(
    function()
        local msg = string.format(TI18N("幸运值满%s后，下次刷新必出精灵兜兜哦{face_1,7}"), DollsRandomManager.Instance.MaxLuckey)
        NoticeManager.Instance:FloatTipsByString(msg)
    end )
    self.LuckeyBar = self.transform:Find("Main/LeftContain/LuckeyBar"):GetComponent(RectTransform)
    self.LuckeyBar.anchoredPosition = Vector2(-279, -299.4)
    local sizeDdata = self.LuckeyBar.sizeDelta
    self.LuckeyW = sizeDdata.x
    self.LuckeyTH = sizeDdata.y
    self.LuckeyH = sizeDdata.y

    self.TxtLuckey = self.transform:Find("Main/LeftContain/BtnLucketTips/TxtLuckey"):GetComponent(Text)

    self.BtnLuckey = self.transform:Find("Main/LeftContain/BtnLuckey"):GetComponent(Button)
    self.BtnLuckey.onClick:AddListener(
    function()
        TipsManager.Instance:ShowText( { gameObject = self.BtnLuckey.gameObject, itemData = self.RudeData, isChance = true})
        TipsManager.Instance.model:ShowChance({chanceId = 212, special = true, isMutil = true})
    end
    )
    self.ImgTime = self.transform:Find("Main/LeftContain/ImgTime")
    self.ImgOpen = self.transform:Find("Main/LeftContain/ImgOpen")
    self.ImgOpen.anchoredPosition = Vector2(-337, -404)

    self.TxtTime = self.transform:Find("Main/LeftContain/TxtTime"):GetComponent(Text)
    self.TxtTime.transform.anchoredPosition = Vector2(-235,-404)

    self.DollsContain = self.transform:Find("Main/RightContain/DollsContain")

    self.BtnRefresh = self.transform:Find("Main/RightContain/BtnRefresh"):GetComponent(Button)
    self.BtnRefresh.onClick:AddListener(self.RefreshDolls)
    self.TxtRefreshDesc = self.transform:Find("Main/RightContain/TxtRefreshDesc"):GetComponent(Text)
    self.ImgKeyIcon2 = self.transform:Find("Main/RightContain/ImgKeyIcon2")

    self.BtnOpenAll = self.transform:Find("Main/RightContain/BtnOpenAll"):GetComponent(Button)
    self.BtnOpenAll.onClick:AddListener(self.OpenAllDolls)
    self.TxtOpenAllDesc = self.transform:Find("Main/RightContain/TxtOpenAllDesc"):GetComponent(Text)

    self.icon1 = self.transform:Find("Main/RightContain/ImgKeyIcon1"):GetComponent(Image)
    self.icon2 = self.transform:Find("Main/RightContain/ImgKeyIcon2"):GetComponent(Image)
    self.icon3 = self.transform:Find("Main/RightContain/ImgKeyIcon3"):GetComponent(Image)

    self.dollTimes = self.transform:Find("Main/DollTimes"):GetComponent(Text)


    self.nextTime = self.transform:Find("Main/LeftContain/TabContainer/I18N"):GetComponent(Text)
    
    -- local tempSlot = {29739,23250,22438}
    self.tabLayout = LuaBoxLayout.New(self.transform:Find("Main/LeftContain/TabContainer").gameObject,{axis = BoxLayoutAxis.x, cspacing = -8, border = 5})


    for i = 1,2 do
        if self.itemSlot[i] == nil then
            self.itemSlot[i] = ItemSlot.New()
            NumberpadPanel.AddUIChild(self.transform:Find(string.format("Main/LeftContain/TabContainer/Item%s",i)), self.itemSlot[i].gameObject)
        end
        self.tabLayout:AddCell(self.transform:Find(string.format("Main/LeftContain/TabContainer/Item%s",i)).gameObject)
        self.transform:Find(string.format("Main/LeftContain/TabContainer/Item%s",i)).gameObject:SetActive(true)
    end

    self.leftArrowTrans = self.transform:Find("Main/LeftContain/TabContainer/LeftArrow")
    self.leftArrowTrans:GetComponent(Button).onClick:AddListener(function() self:OnArrowClick(-1) end)
    self.rightArrowTrans = self.transform:Find("Main/LeftContain/TabContainer/RightArrow")
    self.rightArrowTrans:GetComponent(Button).onClick:AddListener(function() self:OnArrowClick(1) end)

    self.leftArrowTrans.gameObject:SetActive(false)
    self.rightArrowTrans.gameObject:SetActive(true)

    local setting =
    {
        column = 4,
        cspacing = 30,
        rspacing = 50,
        cellSizeX = 65,
        cellSizeY = 65
    }
    self.Layout = LuaGridLayout.New(self.DollsContain, setting)

    for index = 1, 8 do
        local item = DollsRandomDollsItem.New(self.DollsContain, self)
        item:Show()
        self.DollsItemList[index] = item
    end
    self.hasInit = true
    DollsRandomManager.Instance.isOpening = false
    self.curLuckey = DollsRandomManager.Instance.CurLuckey
    self:InitShowItems()
    self:UpdateDolls()
    self:RefershItemKeyNumFun()
    self.OnOpenEvent:Fire()
end
-- 更新幸运值显示
function DollsRandomPanel:UpdateLuckeyBar()
    if not self.hasInit then
        return
    end
    local curLuckey = DollsRandomManager.Instance.CurLuckey or 0
    local mheight = curLuckey / DollsRandomManager.Instance.MaxLuckey * self.LuckeyTH
    self.LuckeyBar.sizeDelta = Vector2(self.LuckeyW, mheight)
    self.TxtLuckey.text = string.format("（%s/%s）", curLuckey, DollsRandomManager.Instance.MaxLuckey)
    self.isFirstInit = false
    if not self.isFirstInit and self.curLuckey < curLuckey then
        if self.timer_luckey ~= nil then
            LuaTimer.Delete(self.timer_luckey)
            self.timee_luckey = nil
        end
        if self.lukeyEffect == nil then
            self.lukeyEffect = GameObject.Instantiate(self.assetWrapper:GetMainAsset(string.format(AssetConfig.effect, 20363)))
            self.lukeyEffect.transform:SetParent(self.LuckeyBar)
            self.lukeyEffect.transform.localRotation = Quaternion.identity
            Utils.ChangeLayersRecursively(self.lukeyEffect.transform, "UI")
            self.lukeyEffect.transform.localScale = Vector3(1, 1, 1)
        end
        self.lukeyEffect.transform.localPosition = Vector3(0, mheight, -400)
        self.lukeyEffect.gameObject:SetActive(true)
        self.timee_luckey = LuaTimer.Add(400,
        function()
            if self.lukeyEffect ~= nil then
                self.lukeyEffect.gameObject:SetActive(false)
            end
            self.timee_luckey = nil
        end )
    end
    if self.effect20368 == nil then
        self.effect20368 = GameObject.Instantiate(self.assetWrapper:GetMainAsset(string.format(AssetConfig.effect, 20368)))
        self.effect20368.transform:SetParent(self.LuckeyBar)
        self.effect20368.transform.localRotation = Quaternion.identity
        Utils.ChangeLayersRecursively(self.effect20368.transform, "UI")
        self.effect20368.transform.localScale = Vector3(1, 1, 1)
    end
    self.effect20368.transform.localPosition = Vector3(0, mheight, -400)
    self.curLuckey = curLuckey
end

-- 展示物品
function DollsRandomPanel:InitShowItems()
    if not self.hasInit then
        return
    end

    local baseTime = BaseUtils.BASE_TIME
    local timeData = DataCampaign.data_list[self.campId].cli_start_time[1]
    local startTime = tonumber(os.time{year = timeData[1], month = timeData[2], day = timeData[3], hour = timeData[4], min = timeData[5], sec = timeData[6]})
    local timestamp = baseTime - startTime
    local curDay = math.modf(timestamp / 3600 / 24) + 1

    local showItems = DataCampDoll.data_dolls_show_list
    local roleData = RoleManager.Instance.RoleData
    --BaseUtils.dump(showItems, "12121211")
    if next(showItems) ~= nil then
        for index = 1, 9 do
            local baseid = nil
            for k,v in pairs(showItems) do
                if v.day == curDay and v.pos == index and (v.classes == roleData.classes or v.classes == 0) and (v.sex == roleData.sex or v.sex == 2)and (v.lev_min < roleData.lev or v.lev_min == roleData.lev) and (v.lev_max > roleData.lev or v.lev_max == roleData.lev)  then
                    baseid = v.item_id
                    break
                end
            end
            --print(baseid.."baseid")
            if baseid ~= nil then
                local item = BackpackManager.Instance:GetItemBase(baseid)
                item.quantity = 0
                item.show_num = false
                local solt = ItemSlot.New()
                solt:ShowBg(false)
                solt:SetDefaultTalisman()
                solt.gameObject:SetActive(true)
                solt.qualityBg.gameObject:SetActive(false)
                --时装选择礼包特殊处理
                if item.type == BackpackEumn.ItemType.suitselectgift then
                    solt.noTips = true
                    solt:SetSelectSelfCallback(function() TipsManager.Instance.model:OpenSelectSuitPanel({baseid = baseid, isshow = true}) end)
                end
                local extra = { inbag = false, noqualitybg = true, nobutton = true }
                solt:SetAll(item, extra)
                solt:SetGrey(false)

                if BaseUtils.ContainValueTable( { 4, 5, 6 }, index) then
                    solt.bgImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.slot_res, "Level4")
                else
                    solt.bgImg.sprite = PreloadManager.Instance:GetSprite(AssetConfig.slot_res, "Level2")
                end
                table.insert(self.slotItems, solt)
                UIUtils.AddUIChild(self.TopContain.gameObject, solt.gameObject)
            end
        end
    end
end
-- 更新套娃
function DollsRandomPanel:UpdateDolls()
    if not self.hasInit then
        return
    end
    self.DollsListData = DollsRandomManager.Instance.DollsList
    self.OpenedNum = 0
    if next(self.DollsListData) ~= nil then
        for index, data in pairs(self.DollsListData) do
            local item = self.DollsItemList[index]
            if item ~= nil and data ~= nil then
                item:SetData(data)
                if DollsRandomManager.Instance.isRefresh then
                    item:PlayRefresh()
                end
            end
            if data.open == 1 then
                self.OpenedNum = self.OpenedNum + 1
            end
        end
    end
    local isCanFree = DollsRandomManager.Instance.FreeTimes > 0
    isCanFree = self.OpenedNum > 5 or isCanFree
    if isCanFree then
        self.TxtRefreshDesc.text = string.format(TI18N("本次刷新<color='#2fc823'>免费</color>"))
    else
        self.TxtRefreshDesc.text = string.format(TI18N("本次刷新消耗：1"))
    end
    self.ImgKeyIcon2.gameObject:SetActive(not isCanFree)
    self:UpdateLuckeyBar()
    self:RefershItemKeyNumFun()
    self:RandomShake()
    DollsRandomManager.Instance.isRefresh = false
end

function DollsRandomPanel:OnOpenDollsBack(data)

    -- self:ShowRewardPanel(data.reward)
    local type = data.type
    local items = data.reward
    if type == 1 then
        local item = self.DollsItemList[data.pos]
        if not BaseUtils.isnull(item) then
            item:PlayOpenEffect(
            function()
                if items ~= nil then
                    self.model:OpenRewardPanel(items)
                end
            end )
        end
    else
        if items ~= nil then
            self:ShowOpenPanel(items)
        end
    end
end

-- 显示奖励弹窗
function DollsRandomPanel:ShowOpenPanel(items)
    if self.openPanel ~= nil then
        self.openPanel:DeleteMe()
    end
    local callback = function()
        self.model:OpenRewardPanel(items)
    end
    self.openPanel = DollsRandomOpenPanel.New(self, callback)
    self.openPanel:Show()
end
-- 初始化活动时间
function DollsRandomPanel:InitCampaignTime()
    if not self.hasInit then
        return
    end
    if self.timer4 ~= nil then
        LuaTimer.Delete(self.timer4)
    end
    --    local sysid = ValentineManager.Instance.menuId.Bird
    --    local beginTimeData = DataCampaign.data_list[sysid].cli_start_time[1]
    --    local endTimeData = DataCampaign.data_list[sysid].cli_end_time[1]
    self.campaignTime = DataCampDoll.data_dolls_other_list[1].time[1]
    self.nowyear = os.date("%Y", BaseUtils.BASE_TIME)
    self.nowmonth = os.date("%m", BaseUtils.BASE_TIME)
    self.nowdate = os.date("%d", BaseUtils.BASE_TIME)

    self.BeginTime = tonumber(os.time { year = self.nowyear, month = self.nowmonth, day = self.nowdate, hour = self.campaignTime[1], min = self.campaignTime[2], sec = self.campaignTime[3] })
    self.EndTime = tonumber(os.time { year = self.nowyear, month = self.nowmonth, day = self.nowdate, hour = self.campaignTime[4], min = self.campaignTime[5], sec = self.campaignTime[6] })
    self.timer4 = LuaTimer.Add(0, 1000, function() self:ShowTime() end)
end
-- 显示倒计时
function DollsRandomPanel:ShowTime()
    local timeStr = ""
    local baseTime = BaseUtils.BASE_TIME
    self.nowyear = os.date("%Y", BaseUtils.BASE_TIME)
    self.nowmonth = os.date("%m", BaseUtils.BASE_TIME)
    self.nowdate = os.date("%d", BaseUtils.BASE_TIME)
    local endTime = 0
    if self.BeginTime < baseTime and baseTime < self.EndTime then
        endTime = self.EndTime
        self.ImgOpen.gameObject:SetActive(false)
        self.ImgTime.gameObject:SetActive(true)
    else
        if baseTime >= self.EndTime then
            endTime = tonumber(os.time { year = self.nowyear, month = self.nowmonth, day = self.nowdate + 1, hour = self.campaignTime[1], min = self.campaignTime[2], sec = self.campaignTime[3] })
        else
            endTime = self.BeginTime
        end
        self.ImgOpen.gameObject:SetActive(true)
        self.ImgTime.gameObject:SetActive(false)
    end
    local h = math.floor((endTime - baseTime) / 3600)
    local mm = math.floor(((endTime - baseTime) -(h * 3600)) / 60)
    local ss = math.floor((endTime - baseTime) -(h * 3600) -(mm * 60))
    timeStr = h .. "时" .. mm .. "分"
    if h <= 0 then
        timeStr = mm .. "分" .. ss .. "秒"
    end
    self.TxtTime.text = timeStr
end
-- 刷新套娃
function DollsRandomPanel:RefreshFun()
    local isAdv = false;
    for _, data in pairs(self.DollsListData) do
        if data.type == 2 and data.open ~= 1 then
            isAdv = true
            break
        end
    end
    if DollsRandomManager.Instance.FreeTimes > 0 or self.OpenedNum > 5 then
        if isAdv then
            local content = string.format(TI18N("<color='#ffff00'>精灵兜兜</color>还未被砸开，现在刷新亏大了，是否确定刷新"))
            self:ShowComfirmTips(content)
            return
        end
        DollsRandomManager.Instance:RefreshDolls()
        return
    end
    local num = BackpackManager.Instance:GetItemCount(self.ItemKeyId)
    local base_data = DataItem.data_get[self.ItemKeyId]
    if num <= 0 then
        local info = { itemData = base_data, gameObject = self.BtnRefresh.gameObject }
        local msg = string.format(TI18N("%s不足，无法刷新"), ColorHelper.color_item_name(base_data.quality, base_data.name))
        NoticeManager.Instance:FloatTipsByString(msg)
        TipsManager.Instance:ShowItem(info)
        return
    end
    local content = string.format(TI18N("是否消耗{assets_1,%s,1}刷新金蛋？"), self.ItemKeyId);
    if isAdv then
        content = string.format(TI18N("<color='#ffff00'>精灵兜兜</color>还未被砸开，并且需要消耗{assets_1,%s,1}，是否继续刷新金蛋？"), self.ItemKeyId);
    end
    self:ShowComfirmTips(content)
end

function DollsRandomPanel:ShowComfirmTips(conten)
    local data = NoticeConfirmData.New()
    data.type = ConfirmData.Style.Normal
    data.content = conten
    data.sureLabel = TI18N("确 定")
    data.cancelLabel = TI18N("取 消")
    data.sureCallback =
    function()
        DollsRandomManager.Instance:RefreshDolls()
    end
    NoticeManager.Instance:ConfirmTips(data)
end
-- 打开全部套娃
function DollsRandomPanel:OpenAllFun()
    local num = BackpackManager.Instance:GetItemCount(self.ItemKeyId)
    --print(self.ItemKeyId)
    --print("当前数量"..num)
    if num < 8 - self.OpenedNum then
        local base_data = DataItem.data_get[self.ItemKeyId]
        local info = { itemData = base_data, gameObject = self.BtnOpenAll.gameObject }
        local msg = string.format(TI18N("%s不足，无法全部解锁"), ColorHelper.color_item_name(base_data.quality, base_data.name))
        NoticeManager.Instance:FloatTipsByString(msg)
        TipsManager.Instance:ShowItem(info)
        return
    end
    --print("当dangdang")
    DollsRandomManager.Instance:OpenDolls(2, 0)
end

function DollsRandomPanel:RefershItemKeyNumFun()
    if not self.hasInit then
        return
    end
    --print("&&&&&&&&&&&&&&&&&&")
    --print(self.ItemKeyId)
    local num = BackpackManager.Instance:GetItemCount(self.ItemKeyId)  --ValentineManager.Instance.DollsItemId
    --print(num.."as((((((((((((((((dasdasdadsadassdasdasdasda))))))))))))))))s")
    if num < 8 - self.OpenedNum then
        self.TxtOpenAllDesc.text = string.format(TI18N("消耗：<color='#df3435'>%s</color>/%s"), num, 8 - self.OpenedNum)
    else
        --print(num.."asdasdasdadsadassdasdasdasdas")
        self.TxtOpenAllDesc.text = string.format(TI18N("消耗：%s/%s"), num, 8 - self.OpenedNum)
    end
end

function DollsRandomPanel:RandomShake()
    if self.timer5 ~= nil then
        LuaTimer.Delete(self.timer5)
        self.timer5 = nil
    end
    self.timer5 = LuaTimer.Add(4000,
    function()
        self.timer5 = nil
        self:ItemShake()
        self:RandomShake()
    end )
end

function DollsRandomPanel:ItemShake()
    local curIndex = self.lastIndex + 1
    if curIndex > 8 then
        curIndex = 1
    end
    self.lastIndex = curIndex
    local data = self.DollsListData[curIndex]
    if data ~= nil then
        if data.open == 0 then
            local item = self.DollsItemList[curIndex]
            item:StartShake()
        else
            self:ItemShake()
        end
    else
        self:ItemShake()
    end
end

function DollsRandomPanel:PlayRefresh()
    for _, item in pairs(self.DollsItemList) do
        item:PlayRefresh()
    end
end

function DollsRandomPanel:OnRewardlistUpdate(lev)
    local rewardList = self.model.rewardsList
    local lastrewardList = self.model.lastRewardList
    local HasDollTimes = self.model.AllTimes
    local level = lev
    local isMax = false   --没达到最大次数
    local reward_list = {}
    if level == 0 then
        --协议回调
        if next(rewardList) ~= nil then
            for i = 1, #rewardList do
                if rewardList[i].times > HasDollTimes then
                    level = i
                    reward_list = BaseUtils.copytab(rewardList[i].reward)
                    break
                end
            end
        else
            reward_list = BaseUtils.copytab(lastrewardList)
            level = 100
            isMax = true
        end
        self.model.curRewardLevel = level
        self.model.curRewardShowLevel = level
    else
        --通过左右按钮刷新
        reward_list = BaseUtils.copytab(rewardList[level].reward)
    end
    
    if isMax then
        self.nextTime.text = TI18N("已获得")
    else
        self.nextTime.text = string.format(TI18N("再抽%s次可获"),rewardList[level].times - HasDollTimes)
    end

    for i,v in ipairs(reward_list) do
        self.itemSlot[i]:SetAll(DataItem.data_get[v.item_id], {inbag = false, nobutton = true})
        self.itemSlot[i]:SetNum(v.num)
    end
    self:SetArrowStatus(level)
end


function DollsRandomPanel:OnArrowClick(index)
    local rewardList = self.model.rewardsList
    self.leftArrowTrans.gameObject:SetActive(true)
    self.rightArrowTrans.gameObject:SetActive(true)
    local showLev = self.model.curRewardShowLevel --显示等级
    showLev = showLev + index
    if showLev <= (#rewardList) and showLev >= 1 then
        self.model.curRewardShowLevel = showLev
    end
    self:OnRewardlistUpdate(self.model.curRewardShowLevel)
end


function DollsRandomPanel:SetArrowStatus(showLev)
    local rewardList = self.model.rewardsList
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

function DollsRandomPanel:SetDollTimes()
    self.dollTimes.text = string.format(TI18N("已抽奖: <color='#00ff00'>%s</color> 次"), self.model.AllTimes)
end