AgendaWindow = AgendaWindow or BaseClass(BaseWindow)

local GameObject = UnityEngine.GameObject

function AgendaWindow:__init(model)
    self.model = model
    self.windowId = WindowConfig.WinID.agendamain
    self.name = "AgendaWindow"
    self.cacheMode = CacheMode.Visible
    self.winLinkType = WinLinkType.Link
    self.currpage = nil
    self.agendaMgr = self.model.agendaMgr
    self.resList = {
        {file = AssetConfig.agenda, type = AssetType.Main}
        ,{file = "prefabs/effect/20110.unity3d", type = AssetType.Main}
        ,{file = "prefabs/effect/20053.unity3d", type = AssetType.Main}
        ,{file = AssetConfig.agenda_textures, type = AssetType.Dep}
        -- ,{file = AssetConfig.dungeonbossname, type = AssetType.Dep}
        ,{file = AssetConfig.dungeonname, type = AssetType.Dep}
        ,{file = AssetConfig.dailyicon, type = AssetType.Dep}
    }
    -- 2016--8--20--0--0--0 至 2016--8--22--22--0--0
    self.isbetaDay = 1471622400 < BaseUtils.BASE_TIME and BaseUtils.BASE_TIME < 1471874400
    self.currfilter = 1
    self.iconloader = {}
    self.slotlist = {}
    self.tipsSlotList = {}
    self.weekRewardButtonEffect = nil

    self._IsShowWeekRewardButtonEffect = function()
        self:IsShowWeekRewardButtonEffect()
    end
end

function AgendaWindow:__delete()
    if self.clanderPanel ~= nil then
        self.clanderPanel:DeleteMe()
        self.clanderPanel = nil
    end

    if self.iconloader ~= nil then
        for k,v in pairs(self.iconloader) do
            v:DeleteMe()
        end
        self.iconloader = nil
    end
    if self.slotlist ~= nil then
        for k,v in pairs(self.slotlist) do
            v:DeleteMe()
        end
        self.slotlist = nil
    end
    if self.tipsSlotList ~= nil then
        for _,slot in pairs(self.tipsSlotList) do
            slot:DeleteMe()
        end
        self.tipsSlotList = nil
    end
    self:ClearDepAsset()
end

function AgendaWindow:InitPanel()
    self.agendaMgr:LoadDailyList()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.agenda))
    self.gameObject.name = self.name
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.transform = self.gameObject.transform

    self.infoBtn = self.transform:Find("MainCon/InfoButton"):GetComponent(Button)
    self.pointTxt = self.transform:Find("MainCon/PonitDesc/pointtext"):GetComponent(Text)
    self.getpointBtn = self.transform:Find("MainCon/GetPointButton"):GetComponent(Button)
    -- self.getpointBtn.gameObject:SetActive(false)
    self.freezpointBtn = self.transform:Find("MainCon/FreezButton"):GetComponent(Button)
    self.RefreshDesc = self.transform:Find("MainCon/RefreshDesc/Text"):GetComponent(Text)
    self.RefreshDesc.text = TI18N("每日凌晨<color=#00ff00>5</color>点刷新")
    self.getpointBtn.onClick:AddListener(function() self.agendaMgr:Require12002() end)
    -- self.getpointBtn.gameObject.transform:Find("Text"):GetComponent(Text).text = "领 双"
    self.freezpointBtn.onClick:AddListener(function() self.agendaMgr:Require12003() end)
    self.infoBtn.onClick:AddListener(function()
        TipsManager.Instance:ShowText({gameObject = self.infoBtn.gameObject, itemData = {
            TI18N("1、野外挂机和悬赏任务可使用双倍点数"),
            TI18N("2、挂机场景每场战斗消耗1点双倍"),
            TI18N("3、野外挂机有50%几率不消耗双倍点数"),
            TI18N("4、野外打怪需要领取双倍才有可能遇到<color='#ffff00'>宠物宝宝</color>"),
            string.format(TI18N("5、每周可领取<color='#00ff00'>%s</color>点双倍点"), tostring(AgendaManager.Instance.DefaultDoubleNum)),
            TI18N("6、双倍点数最多可以存储<color='#00ff00'>420</color>点"),
            TI18N("7、冻结双倍点数需要消耗1点双倍点"),
            string.format(TI18N("8、当前剩余<color='#00ff00'>%s</color>点未领取"), tostring(self.agendaMgr.max_double_point)),
            TI18N("9、额外双倍点数可从<color='#ffff00'>师徒任务、功勋宝箱、兄弟币商店</color>获取"),
            }})
        end)

    self.transform:Find("MainCon/PonitDesc"):GetComponent(Button).onClick:AddListener(function()
        local itemData = ItemData.New()
        local basedata = DataItem.data_get[29015]
        itemData:SetBase(basedata)
        TipsManager.Instance:ShowItem({gameObject = nil, itemData = itemData})
    end)

    self.countGroup = {
        [1] = self.transform:Find("MainCon/ActivityCon1"),
        [2] = self.transform:Find("MainCon/DungeonCon1"),
        [3] = self.transform:Find("MainCon/ActivityCon2"),
        [4] = self.transform:Find("MainCon/ActivityCon3"),
    }
    self.parentcon = {
        [1] = self.countGroup[1]:Find("MaskScroll/Layout"),
        [2] = self.countGroup[2]:Find("MaskScroll/Layout"),
        [3] = self.countGroup[3]:Find("MaskScroll/Layout"),
        [4] = self.countGroup[4]:Find("MaskScroll/Layout"),
    }
    local setting1 = {
        column = 2
        ,cspacing = 3
        ,rspacing = 2
        ,cellSizeX = 295
        ,cellSizeY = 81
        ,bordertop = 5
        ,borderleft = 2
    }
    -- local setting = {
    --     axis = BoxLayoutAxis.X
    --     ,spacing = 0
    -- }
    self.Layout1 = LuaGridLayout.New(self.parentcon[1], setting1)
    --self.Layout2 = LuaGridLayout.New(self.parentcon[3], setting1)
    -- self.Layout3 = LuaGridLayout.New(self.parentcon[4], setting1)
    self.Layout4 = LuaGridLayout.New(self.parentcon[2], setting1)
    self.originAct = self.transform:Find("MainCon/ActivityItem")
    self.originDun = self.transform:Find("MainCon/DungeonItem")
    self.originDun1 = self.transform:Find("MainCon/DungeonItem1")
    self.lifeActTxt = self.transform:Find("MainCon/SkillLife_act/num")
    self.lifeActnumBtn = self.transform:Find("MainCon/SkillLife_act")
    self.lifeActnumBtn.anchoredPosition = Vector2(-301,-141)
    self.lifeTipsBtn = self.transform:Find("MainCon/SkillLife_act/Button"):GetComponent(Button)
    self.lifeTipsBtn.onClick:AddListener(function()
        TipsManager.Instance:ShowText({gameObject = self.lifeTipsBtn.gameObject, itemData = {
            TI18N("1.通过完成日常活动获取<color='#ffff00'>活跃度</color>，领取活跃度奖励"),
            TI18N("2.活跃度达到一定值可以领取活跃礼包，获得<color='#00ff00'>活力值</color>"),
            TI18N("3.活力值是<color='#ffff00'>生活技能</color>制作物品的必需品"),
            TI18N("4.活力值的上限随<color='#ffff00'>玩家等级</color>提升而增加"),
            TI18N("5.活力值超过上限时，次日超出部分会被<color='#00ff00'>清除</color>"),
            TI18N("6.<color='#ffff00'>月度礼包</color>可增加<color='#00ff00'>200点</color>活力值上限"),
            }})
        end)
    self.lifeActBtn = self.transform:Find("MainCon/SkillLifeButton")
    self.lifeActBtn.gameObject:SetActive(false)
    self.tipspanel = self.transform:Find("TipsPanel")
    self.transform:Find("CloseButton"):GetComponent(Button).onClick:AddListener(function () self:OnClose() end)
    self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function () self:OnClose() end)
    self.tipspanel:Find("CloseButton"):GetComponent(Button).onClick:AddListener(function() self.tipspanel.gameObject:SetActive(false) end )
    self.tipspanel:GetComponent(Button).onClick:AddListener(function() self.tipspanel.gameObject:SetActive(false) end )
    self.lifeActnumBtn:GetComponent(Button).onClick:AddListener(function() self:OnClose() SkillManager.Instance.model:OpenUseEnergy() end)
    self.lifeActBtn:GetComponent(Button).onClick:AddListener(function() self:OnClose() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.skill, {3}) end)
    self.transform:Find("MainCon/HotButton"):GetComponent(Button).onClick:AddListener(function() self:OnClose() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.sing_desc_window) end)
    -- self.transform:Find("MainCon/HotButton").gameObject:SetActive(false)
    self.transform:Find("MainCon/HotButton").anchoredPosition = Vector2(-311,-47)

    self.firstRedPoint = self.transform:Find("MainCon/HotButton/RedPoint").gameObject

    self.transform:Find("MainCon/WeekRewardButton"):GetComponent(Button).onClick:AddListener(function() self.model:OpenWeekRewardPanel() end)
    self.weekReardRedPoint = self.transform:Find("MainCon/WeekRewardButton/RedPoint").gameObject
    self.transform:Find("MainCon/WeekRewardButton").anchoredPosition = Vector2(-311,-91)

    self:InitTabButton()
    if self.reward_data ~= nil then
        self:SetReward(self.reward_data)
    end
    self.OnOpenEvent:AddListener(function() self:OnShow() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
    -- self:ClearMainAsset()
    self:SetDoublePoint()
    local hasLimitOpen = (self.agendaMgr.currTimeLimitID ~= 0 and self.agendaMgr.currTimeLimitID ~= 2013 and self.agendaMgr.currTimeLimitID ~= 2072 and DataAgenda.data_list[self.agendaMgr.currTimeLimitID].open_leve <= RoleManager.Instance.RoleData.lev)
    self.transform:Find("MainCon/TabButtonGroup"):GetChild(2):Find("redpoint").gameObject:SetActive(hasLimitOpen)

    self.clanderBtn = self.transform:Find("MainCon/CalendarButton"):GetComponent(Button)
    self.clanderPanel = AgendaClanderPanel.New(self.transform, self)
    self.clanderBtn.onClick:AddListener(function() self.clanderPanel:Show() end)

    self:SetDailyRedpoint()
    -- if hasLimitOpen then
    --     self.tabgroup:ChangeTab(3)
    -- end
    local ph = tonumber(os.date("%H", self.agendaMgr.refreshTime))
    local pm = tonumber(os.date("%d", self.agendaMgr.refreshTime))
    local nh = tonumber(os.date("%H", BaseUtils.BASE_TIME))
    local nm = tonumber(os.date("%d", BaseUtils.BASE_TIME))
    if pm~=nm or (ph<5 and nh>5) then
        AgendaManager.Instance:Require12000()
        TrialManager.Instance:RequestInitData()
        self.openTime = BaseUtils.BASE_TIME
    end
    self:IsRedPoint()
    self:IsShowWeekRewardButtonEffect()
end

function AgendaWindow:OnInitCompleted()
    self:OnShow()
end

--设置活动红点
function AgendaWindow:SetDailyRedpoint()
    -- local state = AlchemyManager.Instance.model:CheckRedPointState()--炼化
    -- state = state or GloryManager.Instance:RedPointMainUI()
    -- self.transform:Find("MainCon/TabButtonGroup"):GetChild(0):Find("redpoint").gameObject:SetActive(state)
    -- if self.model.currLimitList ~= nil and next(self.model.currLimitList) ~= nil then
    --     self.transform:Find("MainCon/TabButtonGroup"):GetChild(2):Find("redpoint").gameObject:SetActive(true)
    -- end
end


function AgendaWindow:OnShow()
    self:IsRedPoint()
    self:IsShowWeekRewardButtonEffect()
    self.agendaMgr:LoadDailyList()
    self.isbetaDay = 1471622400 < BaseUtils.BASE_TIME and BaseUtils.BASE_TIME < 1471874400
    -- print(self.agendaMgr.currTimeLimitID)
    local hastarget = false
    if self.model.currTab ~= nil then
        if type(self.model.currTab) == "table" then
            print("切换")
            self.model.currTab = self.model.currTab[1]
        end
        self.tabgroup:ChangeTab(self.model.currTab)
        hastarget = true
    else
        self:OnTabChange(self.tabgroup.currentIndex)
    end
    local hasLimitOpen = (self.agendaMgr.currTimeLimitID ~= 0 and self.agendaMgr.currTimeLimitID ~= 2013 and self.agendaMgr.currTimeLimitID ~= 2072 and DataAgenda.data_list[self.agendaMgr.currTimeLimitID].open_leve <= RoleManager.Instance.RoleData.lev)
    self.transform:Find("MainCon/TabButtonGroup"):GetChild(2):Find("redpoint").gameObject:SetActive(hasLimitOpen)
    self:SetDoublePoint()
    local ph = tonumber(os.date("%H", self.agendaMgr.refreshTime))
    local pm = tonumber(os.date("%d", self.agendaMgr.refreshTime))
    local nh = tonumber(os.date("%H", BaseUtils.BASE_TIME))
    local nm = tonumber(os.date("%d", BaseUtils.BASE_TIME))
    if pm~=nm or (ph<5 and nh>5) then
        AgendaManager.Instance:Require12000()
        TrialManager.Instance:RequestInitData()
        self.openTime = BaseUtils.BASE_TIME
    end
    -- if MainUIManager.Instance.MainUIIconView ~= nil then
    --     MainUIManager.Instance.MainUIIconView:set_icon_Redpoint_by_id(14, false)
    -- end

    self:SetDailyRedpoint()
    -- if hasLimitOpen and not hastarget then
    --     self.tabgroup:ChangeTab(3)
    -- end

    print(SingManager.Instance.activeState)
    self.transform:Find("MainCon/HotButton").gameObject:SetActive(SingManager.Instance.activeState ~= 1)

    AgendaManager.Instance.OnUpdateAgendaWeekData:Add(self._IsShowWeekRewardButtonEffect)
end

function AgendaWindow:OnHide()
    print("AgendaWindow:OnHide()")
    if self.clanderPanel ~= nil then
        self.clanderPanel:Hiden()
    end
    AgendaManager.Instance.OnUpdateAgendaWeekData:Remove(self._IsShowWeekRewardButtonEffect)
end

function AgendaWindow:OnClose()
    self.model:CloseWin()
end

function AgendaWindow:InitTabButton()
    local go = self.transform:Find("MainCon/TabButtonGroup").gameObject
    --local subgo = self.transform:Find("MainCon/ActivityCon1/SubTabButtonGroup").gameObject
    self.tabgroup = TabGroup.New(go, function (tab) self:OnTabChange(tab) end)
    --self.subtabgroup = TabGroup.New(subgo, function (tab) self:OnSubTabChange(tab) end)
    self:OnSubTabChange(1)
    if self.model.currTab ~= nil then
        if type(self.model.currTab) == "table" then
            self.model.currTab = self.model.currTab[1] or 1
        end
        self.tabgroup:ChangeTab(self.model.currTab)
    end
    -- if #self.agendaMgr.day_limited_list > 0
    --self.transform:Find("MainCon/TabButtonGroup"):GetChild(1).gameObject:SetActive(false)
    self.transform:Find("MainCon/TabButtonGroup"):GetChild(1).gameObject:SetActive(self.model.agendaMgr.challange_list ~= nil and #self.model.agendaMgr.challange_list > 0)
    self.transform:Find("MainCon/TabButtonGroup"):GetChild(3).gameObject:SetActive(self.model.agendaMgr.commingsoon_list ~= nil and #self.model.agendaMgr.commingsoon_list > 0)
end

function AgendaWindow:DisabledAll()

end

function AgendaWindow:RefreshCurrPage()
    -- self.tabgroup:ChangeTab(self.model.currTab)
    if  self.TabGroup ~= nil then
        self:OnTabChange(self.tabgroup.currentIndex)
    end
end

function AgendaWindow:OnTabChange(tab)
    if tab == 1 then
        self:OpenDaily(self.currfilter)
    elseif tab == 2 then
        self:OpenChallange()
    elseif tab == 3 then
        self:OpenTimeLimit()
    elseif tab == 4 then
        self:OpenComming()
    end
    for i,v in ipairs(self.countGroup) do
        if i ~= tab then
            v.gameObject:SetActive(false)
        else
            v.gameObject:SetActive(true)
        end
    end
end

--上方 我要金币 我要银币 我要经验 列表
function AgendaWindow:OnSubTabChange(tab)
    self.currfilter = tab
    self:OpenDaily(tab)
end

function AgendaWindow:OpenDaily(filter)
    local data_list = self.agendaMgr.day_list
    --BaseUtils.dump(data_list,"121212")
    self.Layout1:ReSet()
    for i,v in ipairs(data_list) do
        if self:Filter(filter, v.id) then
            xpcall(function() self:CreatDaily(v) end,
                function()  Log.Error(debug.traceback()) end )
        end
    end
end

function AgendaWindow:OpenDungeon1()
    local data_list = self.agendaMgr.dungeon_list
    for i,v in ipairs(data_list) do
        xpcall(function() self:CreatDungeon1(v) end,
            function()  Log.Error(debug.traceback()) end )
    end
end

function AgendaWindow:OpenChallange()
    local data_list = self.agendaMgr.challange_list
    for i,v in ipairs(data_list) do
        xpcall(function() self:CreatChallange(v) end,
            function()  Log.Error(debug.traceback()) end )
    end
end



function AgendaWindow:OpenTimeLimit()
    local data_list = self.agendaMgr.day_limited_list
    --self.Layout2:ReSet()
    self:SwitchLayout(self.parentcon[3].gameObject, true)
    for i,v in ipairs(data_list) do
        xpcall(function() self:CreatTimeLimit(v) end,
            function()  Log.Error(debug.traceback()) end )
    end
    local oldGo = {}
    for i = 0, self.parentcon[3].childCount -1 do
        local old = true
        local go = self.parentcon[3]:GetChild(i).gameObject
        for i,v in ipairs(data_list) do
            if tostring(v.id) == go.name then
                old = false
            end
        end
        if old then
            table.insert(oldGo, go)
        end
    end
    for i,v in ipairs(oldGo) do
        GameObject.Destroy(v)
    end
    LuaTimer.Add(150, function () self:SwitchLayout(self.parentcon[3].gameObject, false) end)
end


function AgendaWindow:OpenComming()
    local data_list = self.model.agendaMgr.commingsoon_list
    -- self.Layout4:ReSet()
    self:SwitchLayout(self.parentcon[4].gameObject, true)
    for i,v in ipairs(data_list) do
        self:CreatComming(v)
    end
    LuaTimer.Add(150, function () self:SwitchLayout(self.parentcon[4].gameObject, false) end)
end



function AgendaWindow:CreatDaily(data)
    if data.notshow == 1 then
        return
    end
    if RoleManager.Instance.world_lev < DataAgenda.data_list[data.id].world_lev then
        return
    end

    -- if data.time ~= TI18N("全天") then
    --     return self:CreatTimeLimit(data)
    -- end
    if data.is_guild == 1 and (GuildManager.Instance.model.my_guild_data == nil or GuildManager.Instance.model.my_guild_data.GuildId == 0) then
        return
    end
    if data.id == 1020 and TeacherManager.Instance.model:IsHasTeahcerStudentRelationShip() == false then
        return
    end
    --游侠历练 暂时隐藏
    if data.id == 1023 then  --data.id == 1017 魔法试炼
        return
    end

    local parentcon = self.parentcon[1]
    local item =  parentcon:Find(tostring(data.id)) or GameObject.Instantiate(self.originAct)
    --UIUtils.AddUIChild(parentcon.gameObject, item.gameObject)
    self.Layout1:AddCell(item.gameObject)
    local itemtrans = item.transform
    --self:SwitchLayout(itemtrans:Find("Title").gameObject, true)
    local timestxt = itemtrans:Find("Times"):GetComponent(Text)
    local Acttxt = itemtrans:Find("ActTimes"):GetComponent(Text)
    local icon = itemtrans:Find("HeadBg/Image"):GetComponent(Image)
    if data.engaged == nil then
        data.engaged = data.max_try
    end
    item.name = tostring(data.id)
    itemtrans:Find("Label").gameObject:SetActive(false)
    itemtrans:Find("Title/Name"):GetComponent(Text).text = data.name
    itemtrans:Find("Title/Name").sizeDelta = Vector2(itemtrans:Find("Title/Name"):GetComponent(Text).preferredWidth, 30)
    itemtrans:Find("Title/gain").anchoredPosition = Vector2(itemtrans:Find("Title/Name").sizeDelta.x+4, -15)

    -----------推荐日程
    local rate = 1
    if self.agendaMgr.recommend_list[data.id] ~= nil then
        rate = 2
        itemtrans:Find("Label").gameObject:SetActive(true)
    end
    if data.gain_id ~= 0 then
        local gain_icon = DataItem.data_get[data.gain_id]
        if gain_icon then
            self:SetSprite("", gain_icon.icon, itemtrans:Find("Title/gain"):GetComponent(Image))
            itemtrans:Find("Title/gain").gameObject:SetActive(true)
        else
            Log.Error("<color='#ff0000'>gain_id错误：活动ID</color>"..tostring(data.id))
        end
    end

    self:SetSprite(AssetConfig.dailyicon, data.icon, icon)
    Acttxt.text = string.format(TI18N("活跃<color='#167FD5'>%s/%s</color>"), tostring(math.min((data.engaged) * data.activity,data.max_activity) * rate),tostring(data.max_activity * rate))
    item.gameObject:SetActive(true)
    if data.max_try == 0 then
        timestxt.text = TI18N("无限次")
        itemtrans:Find("Finish").gameObject:SetActive(false)
        itemtrans:Find("Button").gameObject:SetActive(true)
        icon.color = Color(1 ,1 ,1 , 1)
    elseif data.engaged < data.max_try then
        timestxt.text = string.format(TI18N("次数<color='#167FD5'>%s/%s</color>"), tostring(data.engaged), tostring(data.max_try))
        itemtrans:Find("Finish").gameObject:SetActive(false)
        itemtrans:Find("Button").gameObject:SetActive(true)
        icon.color = Color(1 ,1 ,1 , 1)
    else
        timestxt.text = string.format(TI18N("次数<color='#FA2525'>%s/%s</color>"), tostring(data.max_try), tostring(data.max_try))
        -- if data.hide_button == 0 then
        itemtrans:Find("Finish").gameObject:SetActive(true)
        icon.color = Color(0.4 ,0.4 ,0.4 , 1)
        itemtrans:Find("Button").gameObject:SetActive(false)
        -- end
    end
    local function onclick(  )
        if data.id ~= 1017 and data.id ~= 1027 and RoleManager.Instance.RoleData.event == RoleEumn.Event.Dungeon and DungeonManager.Instance.activeType == 5 then
            DungeonManager.Instance:ExitDungeon()
            return
        end
        if self.model:SpecialDaily(data.id) then
            return
        end
        if data.panel_id~=0 then
            self:OnClose()
            if #data.panelargs >0 then
                WindowManager.Instance:OpenWindowById(data.panel_id, data.panelargs)
            else
                WindowManager.Instance:OpenWindowById(data.panel_id)
            end
        elseif data.npc_id~="0" then
            local uid = tostring(data.npc_id)
            self:OnClose()
            SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
            SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)
            SceneManager.Instance.sceneElementsModel:Self_PathToTarget(uid)
        end
    end
    itemtrans:Find("Button"):GetComponent(Button).onClick:RemoveAllListeners()
    itemtrans:Find("Button"):GetComponent(Button).onClick:AddListener(onclick)
    itemtrans:GetComponent(Button).onClick:RemoveAllListeners()
    itemtrans:GetComponent(Button).onClick:AddListener(function  () self:ShowTips(1, data)    end)

    for i,v in ipairs(self.agendaMgr.day_list) do

        if v.id == data.id then
            self.agendaMgr.day_list[i].item = item
        end
    end

    self:DoSpecial(item, data)
    -- LuaTimer.Add(50, function () self:SwitchLayout(itemtrans:Find("Title").gameObject, false) end)
end
--副本
function AgendaWindow:CreatDungeon1(data)
    local parentcon = self.parentcon[2]
    local baseDunData = DataDungeon.data_get[data.panel_id]
    local item =  parentcon:Find(tostring(data.id)) or GameObject.Instantiate(self.originDun1)
    self.Layout4:AddCell(item.gameObject)
    local itemtrans = item.transform
    -- self:SwitchLayout(itemtrans:Find("Title").gameObject, true)
    local timestxt = itemtrans:Find("Times"):GetComponent(Text)
    local Acttxt = itemtrans:Find("ActTimes"):GetComponent(Text)
    local icon = itemtrans:Find("HeadBg/Image"):GetComponent(Image)
    if data.engaged == nil then
        data.engaged = data.max_try
    end
    item.name = tostring(data.id)
    itemtrans:Find("Label").gameObject:SetActive(false)
    itemtrans:Find("Title/Name"):GetComponent(Text).text = data.name
    self:SetSprite(AssetConfig.dailyicon, data.icon, icon)

    itemtrans:Find("Limit/Text"):GetComponent(Text).text = string.format(TI18N("%s级开启"), tostring(data.open_leve))

    item.gameObject:SetActive(true)
    itemtrans:Find("Button").gameObject:SetActive(data.open_leve <= RoleManager.Instance.RoleData.lev)
    if data.max_try == 0 then
        timestxt.text = TI18N("无限次")
    elseif data.engaged < data.max_try then
        if baseDunData.type == 3 then
            timestxt.text = string.format(TI18N("本周奖励 <color='#167FD5'>%s/%s</color>"), tostring(data.engaged), tostring(data.max_try))
        else
            timestxt.text = string.format(TI18N("今日奖励 <color='#167FD5'>%s/%s</color>"), tostring(data.engaged), tostring(data.max_try))
        end
    elseif data.engaged == data.max_try then
        if baseDunData.type == 3 then
            timestxt.text = string.format(TI18N("本周奖励 <color='#FA2525'>%s/%s</color>"), tostring(data.engaged), tostring(data.max_try))
        else
            timestxt.text = string.format(TI18N("今日奖励 <color='#FA2525'>%s/%s</color>"), tostring(data.max_try), tostring(data.max_try))
        end
        itemtrans:Find("Finish").gameObject:SetActive(true)
        icon.color = Color(0.4 ,0.4 ,0.4 , 1)
        itemtrans:Find("Button").gameObject:SetActive(false)
    end
    itemtrans:Find("Label").gameObject:SetActive(baseDunData.type == 3)
    local function onclick(  )
        if RoleManager.Instance.RoleData.event == RoleEumn.Event.Dungeon and DungeonManager.Instance.activeType == 5 then
            DungeonManager.Instance:ExitDungeon()
            return
        end
        if data.id == 2048 then
            UnlimitedChallengeManager.Instance:Require17201()
            self:OnClose()
            return
        end
        self:OnClose()
        SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
        SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(2)
        SceneManager.Instance.sceneElementsModel:Self_PathToTarget(string.format("%s_1", tostring(baseDunData.npc_id)))
    end
    itemtrans:Find("Button"):GetComponent(Button).onClick:RemoveAllListeners()
    itemtrans:Find("Button"):GetComponent(Button).onClick:AddListener(onclick)
    itemtrans:GetComponent(Button).onClick:RemoveAllListeners()
    itemtrans:GetComponent(Button).onClick:AddListener(function  () self:ShowTips(2, baseDunData, data.id)    end)
    itemtrans:Find("Limit").gameObject:SetActive(data.open_leve > RoleManager.Instance.RoleData.lev)
    for i,v in ipairs(self.agendaMgr.dungeon_list) do
        if v.id == data.id then
            self.agendaMgr.dungeon_list[i].item = item
        end
    end
    -- LuaTimer.Add(50, function () self:SwitchLayout(itemtrans:Find("Title").gameObject, false) end)
end

--创建挑战item
function AgendaWindow:CreatChallange(data)

    local parentcon = self.parentcon[2]
    local item = parentcon:Find(tostring(data.id)) or GameObject.Instantiate(self.originAct)

    UIUtils.AddUIChild(parentcon.gameObject, item.gameObject)
    -- local parentcon = self.parentcon[1]
    -- local item =  parentcon:Find(tostring(data.id)) or GameObject.Instantiate(self.originAct)
    --self.Layout1:AddCell(item.gameObject)

    local itemtrans = item.transform
    self:SwitchLayout(itemtrans:Find("Title").gameObject, true)
    local icon = itemtrans:Find("HeadBg/Image"):GetComponent(Image)
    local Acttxt = itemtrans:Find("ActTimes"):GetComponent(Text)
    if data.engaged == nil then
        data.engaged = data.max_try          --最大次数
    end
    itemtrans:Find("Label").gameObject:SetActive(false)
    itemtrans:Find("end").gameObject:SetActive(false)
    local rate = 1
    if self.agendaMgr.recommend_list[data.id] ~= nil then
        rate = 2
        itemtrans:Find("Label").gameObject:SetActive(true)
    end
    -- data.activity 单次活跃度奖励   data.max_activity 该活动每天活跃度上限
    -- 如果是推荐活动，可获双倍活跃值
    Acttxt.text = string.format(TI18N("活跃<color='#167FD5'>%s/%s</color>"), tostring(math.min((data.engaged)*data.activity,data.max_activity * rate)),tostring(data.max_activity * rate))
    item.name = tostring(data.id)
    itemtrans:Find("Title/Name"):GetComponent(Text).text = data.name
    itemtrans:Find("Title/Name").sizeDelta = Vector2(itemtrans:Find("Title/Name"):GetComponent(Text).preferredWidth, 30)
    itemtrans:Find("Title/gain").anchoredPosition = Vector2(itemtrans:Find("Title/Name").sizeDelta.x+4, -15)
    if data.gain_id ~= 0 then
        local gain_icon = DataItem.data_get[data.gain_id]
        if gain_icon then
            self:SetSprite("", gain_icon.icon, itemtrans:Find("Title/gain"):GetComponent(Image))
            itemtrans:Find("Title/gain").gameObject:SetActive(true)
        else
            Log.Error("<color='#ff0000'>gain_id错误：活动ID</color>"..tostring(data.id))
        end
    end

    self:SetSprite(AssetConfig.dailyicon, data.icon, icon)
    item.gameObject:SetActive(true)
    local currtime = BaseUtils.BASE_TIME
    local h = tonumber(os.date("%H", currtime))
    local m = tonumber(os.date("%M", currtime))
    local currtimenum = h*3600+m*60
    local sH = math.floor(data.starttime/3600)
    local sM = math.floor(data.starttime%3600/60)
    local ssM = sM
    if ssM<10 then ssM = string.format("0%s", tostring(ssM)) end
    local eH = math.floor(data.endtime/3600)
    local eM = math.floor(data.endtime%3600/60)
    itemtrans:Find("TimeLimit/Text"):GetComponent(Text).text = string.format(TI18N("<color='#aaff00'>%s:%s</color>开启"), tostring(sH), tostring(ssM))
    --在限时时间段内且当前限时列表有该id 则显示参与
    -- 2013 十二星座
    if AgendaManager.Instance.currLimitList[data.id] and data.id ~= 2013 then
        itemtrans:Find("redpoint").gameObject:SetActive(true)
        itemtrans:Find("Button").gameObject:SetActive(true)
        itemtrans:Find("TimeLimit").gameObject:SetActive(false)
    end

    local timestxt = itemtrans:Find("Times"):GetComponent(Text)
    if data.max_try == 0 then
        timestxt.text = TI18N("无限次")
        icon.color = Color(1, 1, 1, 1)
        itemtrans:Find("Finish").gameObject:SetActive(false)
        itemtrans:Find("Button").gameObject:SetActive(true)
        itemtrans:Find("TimeLimit").gameObject:SetActive(false)
    elseif data.engaged < data.max_try then
        timestxt.text = string.format(TI18N("次数<color='#167FD5'>%s/%s</color>"), tostring(data.engaged), tostring(data.max_try))
        icon.color = Color(1, 1, 1, 1)
        itemtrans:Find("Finish").gameObject:SetActive(false)
        itemtrans:Find("Button").gameObject:SetActive(true)
        itemtrans:Find("TimeLimit").gameObject:SetActive(false)
    elseif data.engaged == data.max_try then
        timestxt.text = string.format(TI18N("次数<color='#FA2525'>%s/%s</color>"), tostring(data.max_try), tostring(data.max_try))
            icon.color = Color(0.4 ,0.4 ,0.4 , 1)
            itemtrans:Find("Finish").gameObject:SetActive(true)
            itemtrans:Find("Button").gameObject:SetActive(false)
            itemtrans:Find("TimeLimit").gameObject:SetActive(false)
            if self.agendaMgr.currTimeLimitID == data.id then

            end
        itemtrans:Find("redpoint").gameObject:SetActive(false)
    else
        timestxt.text = string.format(TI18N("次数<color='#FA2525'>%s/%s</color>"), tostring(data.max_try), tostring(data.max_try))
        if data.hide_button == 0 then
            icon.color = Color(0.4 ,0.4 ,0.4 , 1)
            itemtrans:Find("Finish").gameObject:SetActive(true)
            itemtrans:Find("Button").gameObject:SetActive(false)
            if self.agendaMgr.currTimeLimitID == data.id then

            end
        end
        itemtrans:Find("redpoint").gameObject:SetActive(false)
    end

    local function onclick(  )
        --先跑特殊处理
        if self.model:SpecialDaily(data.id) then
            return
        end
        --再跑统一打开窗口
        if data.panel_id~=0 then
            -- self:OnClose()
            if data.panel_id == WindowConfig.WinID.guild_fight_window then
                self:OnClose()
            elseif data.panel_id == WindowConfig.WinID.summer_activity_window then
                self:OnClose()
            elseif data.panel_id == WindowConfig.WinID.godswar_main then
                self:OnClose()
            elseif data.panel_id == WindowConfig.WinID.double_eleven_window then
                self:OnClose()
            elseif data.panel_id == WindowConfig.WinID.spring_festival then
                self:OnClose()
            elseif data.panel_id == WindowConfig.WinID.guild_siege_castle_window then
                self:OnClose()
            elseif data.panel_id == WindowConfig.WinID.ingot_crash_show then
                self:OnClose()
            elseif data.panel_id == WindowConfig.WinID.summercarnival_main_window then
                self:OnClose()
            end

            if #data.panelargs >0 then
                WindowManager.Instance:OpenWindowById(data.panel_id, data.panelargs)
            else
                WindowManager.Instance:OpenWindowById(data.panel_id)
            end
        elseif data.npc_id~="0" then
            local uid = tostring(data.npc_id)
            self:OnClose()
            SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
            SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)
            SceneManager.Instance.sceneElementsModel:Self_PathToTarget(uid)
        end
    end

    itemtrans:Find("Button"):GetComponent(Button).onClick:RemoveAllListeners()
    itemtrans:Find("Button"):GetComponent(Button).onClick:AddListener(onclick)
    item:GetComponent(Button).onClick:RemoveAllListeners()
    item:GetComponent(Button).onClick:AddListener(function  () self:ShowTips(1, data)    end)

    for i,v in ipairs(self.agendaMgr.challange_list) do
        if v.id == data.id then
            self.agendaMgr.challange_list[i].item = item
        end
    end

    self:DoSpecial(item,data)
    -- LuaTimer.Add(50, function () self:SwitchLayout(itemtrans:Find("Title").gameObject, false) end)
end

-- 创建限时item
function AgendaWindow:CreatTimeLimit(data)
    if data.notshow == 1 then
        return
    end
    if RoleManager.Instance.world_lev < DataAgenda.data_list[data.id].world_lev then
        return
    end
    --如果是公会任务但我没公会
    if data.is_guild == 1 and (GuildManager.Instance.model.my_guild_data == nil or GuildManager.Instance.model.my_guild_data.GuildId == 0) then
        return
    end
    --如果是武道会 不能连上中央服
    if data.id == 2028  and RoleManager.Instance.connect_type ~= 1 then
        return
    end
    -- 十二星座和 试炼资格/龙王试炼 星辰试炼 不放限时模块了
    if data.id == 2013 or data.id == 2057 or data.id == 2058 or data.id == 2059 or data.id == 2060 or data.id == 2072 or data.id == 2073 or data.id == 2074 or data.id == 2075 or data.id == 2076 or data.id == 2082 then
        return
    end

    local parentcon = self.parentcon[3]
    local item = parentcon:Find(tostring(data.id)) or GameObject.Instantiate(self.originAct)

    UIUtils.AddUIChild(parentcon.gameObject, item.gameObject)
    -- local parentcon = self.parentcon[1]
    -- local item =  parentcon:Find(tostring(data.id)) or GameObject.Instantiate(self.originAct)
    --self.Layout1:AddCell(item.gameObject)

    if data.id == 2014 or data.id == 2068 then
        local isHasCeremery = GodsWarWorShipManager.Instance.isHasGorWarShip
        if isHasCeremery == 1 then
            if data.id == 2014 then
                data.starttime = 79200  --(22:00)
            elseif data.id == 2068 then
                data.endtime = 79200
            end
        end
    end

    local itemtrans = item.transform
    self:SwitchLayout(itemtrans:Find("Title").gameObject, true)
    local icon = itemtrans:Find("HeadBg/Image"):GetComponent(Image)
    local Acttxt = itemtrans:Find("ActTimes"):GetComponent(Text)
    if data.engaged == nil then
        data.engaged = data.max_try          --最大次数
    end
    itemtrans:Find("Label").gameObject:SetActive(false)
    itemtrans:Find("end").gameObject:SetActive(false)
    local rate = 1
    if self.agendaMgr.recommend_list[data.id] ~= nil then
        rate = 2
        itemtrans:Find("Label").gameObject:SetActive(true)
    end
    -- data.activity 单次活跃度奖励   data.max_activity 该活动每天活跃度上限
    -- 如果是推荐活动，可获双倍活跃值
    Acttxt.text = string.format(TI18N("活跃<color='#167FD5'>%s/%s</color>"), tostring(math.min((data.engaged)*data.activity,data.max_activity * rate)),tostring(data.max_activity * rate))
    item.name = tostring(data.id)
    itemtrans:Find("Title/Name"):GetComponent(Text).text = data.name
    itemtrans:Find("Title/Name").sizeDelta = Vector2(itemtrans:Find("Title/Name"):GetComponent(Text).preferredWidth, 30)
    itemtrans:Find("Title/gain").anchoredPosition = Vector2(itemtrans:Find("Title/Name").sizeDelta.x+4, -15)
    if data.gain_id ~= 0 then
        local gain_icon = DataItem.data_get[data.gain_id]
        if gain_icon then
            self:SetSprite("", gain_icon.icon, itemtrans:Find("Title/gain"):GetComponent(Image))
            itemtrans:Find("Title/gain").gameObject:SetActive(true)
        else
            Log.Error("<color='#ff0000'>gain_id错误：活动ID</color>"..tostring(data.id))
        end
    end

    self:SetSprite(AssetConfig.dailyicon, data.icon, icon)
    item.gameObject:SetActive(true)
    local currtime = BaseUtils.BASE_TIME
    local h = tonumber(os.date("%H", currtime))
    local m = tonumber(os.date("%M", currtime))
    local currtimenum = h*3600+m*60
    local sH = math.floor(data.starttime/3600)
    local sM = math.floor(data.starttime%3600/60)
    local ssM = sM
    if ssM<10 then ssM = string.format("0%s", tostring(ssM)) end
    local eH = math.floor(data.endtime/3600)
    local eM = math.floor(data.endtime%3600/60)
    itemtrans:Find("TimeLimit/Text"):GetComponent(Text).text = string.format(TI18N("<color='#aaff00'>%s:%s</color>开启"), tostring(sH), tostring(ssM))
    --在限时时间段内且当前限时列表有该id 则显示参与
    if data.id ~= 1025 and data.id ~= 2044 then   --诸神
        if (currtimenum>=data.starttime and currtimenum <= data.endtime and data.id ~= 2013) or self.agendaMgr.currLimitList[data.id] == true then
            itemtrans:Find("Button").gameObject:SetActive(true)
            itemtrans:Find("TimeLimit").gameObject:SetActive(false)
            itemtrans:SetAsFirstSibling()
            itemtrans:Find("redpoint").gameObject:SetActive(true)
        else
            itemtrans:Find("Button").gameObject:SetActive(false)
            itemtrans:Find("TimeLimit").gameObject:SetActive(true)
            itemtrans:Find("redpoint").gameObject:SetActive(false)
        end
    end

    -- 2013 十二星座
    if AgendaManager.Instance.currTimeLimitID == data.id and data.id ~= 2013 then
        itemtrans:Find("redpoint").gameObject:SetActive(true)
        itemtrans:Find("Button").gameObject:SetActive(true)
        itemtrans:Find("TimeLimit").gameObject:SetActive(false)
    else
        -- itemtrans:Find("redpoint").gameObject:SetActive(false)
    end

    if data.id == 1030 then -- 公会副本，先检查时间，在时间内才显示红点
        if (currtimenum>=data.starttime and currtimenum <= data.endtime) then
            itemtrans:Find("Button").gameObject:SetActive(true)
            itemtrans:Find("TimeLimit").gameObject:SetActive(false)
            itemtrans:SetAsFirstSibling()
            if self.agendaMgr.currLimitList[data.id] == true then
                itemtrans:Find("redpoint").gameObject:SetActive(true)
            else
                itemtrans:Find("redpoint").gameObject:SetActive(false)
            end
        else
            itemtrans:Find("Button").gameObject:SetActive(false)
            itemtrans:Find("TimeLimit").gameObject:SetActive(true)
            itemtrans:Find("redpoint").gameObject:SetActive(false)
        end
    end
    --当前次数 data.engaged
    local timestxt = itemtrans:Find("Times"):GetComponent(Text)
    if data.max_try == 0 then
        timestxt.text = TI18N("无限次")
    elseif data.engaged < data.max_try then
        timestxt.text = string.format(TI18N("次数<color='#167FD5'>%s/%s</color>"), tostring(data.engaged), tostring(data.max_try))
    elseif data.engaged == data.max_try then
        --已完成该任务
        timestxt.text = string.format(TI18N("次数<color='#FA2525'>%s/%s</color>"), tostring(data.max_try), tostring(data.max_try))
        -- if data.hide_button == 0 then
            icon.color = Color(0.4 ,0.4 ,0.4 , 1)
            itemtrans:Find("Finish").gameObject:SetActive(true)
            itemtrans:Find("Button").gameObject:SetActive(false)
            itemtrans:Find("TimeLimit").gameObject:SetActive(false)
            if self.agendaMgr.currTimeLimitID == data.id then

            end
        -- end
        itemtrans:Find("redpoint").gameObject:SetActive(false)
    else
        timestxt.text = string.format(TI18N("次数<color='#FA2525'>%s/%s</color>"), tostring(data.max_try), tostring(data.max_try))
        if data.hide_button == 0 then
            icon.color = Color(0.4 ,0.4 ,0.4 , 1)
            itemtrans:Find("Finish").gameObject:SetActive(true)
            itemtrans:Find("Button").gameObject:SetActive(false)
            if self.agendaMgr.currTimeLimitID == data.id then

            end
        end
        itemtrans:Find("redpoint").gameObject:SetActive(false)
    end
    -- 99 更多活动~ 若当前小时大于结束小时 则显示结束 (诸神不算真正的限时，不走统一处理)
    if data.id ~= 99 and data.id ~= 1025 and data.id ~= 2044 and (data.endtime/3600) < h+m/60 then
        icon.color = Color(0.4 ,0.4 ,0.4 , 1)
        itemtrans:Find("end").gameObject:SetActive(true)
        itemtrans:Find("Button").gameObject:SetActive(false)
        itemtrans:Find("TimeLimit").gameObject:SetActive(false)
        itemtrans:Find("redpoint").gameObject:SetActive(false)
    end

    local function onclick(  )
        if RoleManager.Instance.RoleData.event == RoleEumn.Event.Dungeon and DungeonManager.Instance.activeType == 5 then
            DungeonManager.Instance:ExitDungeon()
            return
        end
        --先跑特殊处理
        if self.model:SpecialDaily(data.id) then
            return
        end
        --再跑统一打开窗口
        if data.panel_id~=0 then
            -- self:OnClose()
            if data.panel_id == WindowConfig.WinID.guild_fight_window then
                self:OnClose()
            elseif data.panel_id == WindowConfig.WinID.summer_activity_window then
                self:OnClose()
            elseif data.panel_id == WindowConfig.WinID.godswar_main then
                self:OnClose()
            elseif data.panel_id == WindowConfig.WinID.double_eleven_window then
                self:OnClose()
            elseif data.panel_id == WindowConfig.WinID.spring_festival then
                self:OnClose()
            elseif data.panel_id == WindowConfig.WinID.guild_siege_castle_window then
                self:OnClose()
            elseif data.panel_id == WindowConfig.WinID.ingot_crash_show then
                self:OnClose()
            elseif data.panel_id == WindowConfig.WinID.summercarnival_main_window then
                self:OnClose()
            end

            if #data.panelargs >0 then
                WindowManager.Instance:OpenWindowById(data.panel_id, data.panelargs)
            else
                WindowManager.Instance:OpenWindowById(data.panel_id)
            end
        elseif data.npc_id~="0" then
            local uid = tostring(data.npc_id)
            self:OnClose()
            SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
            SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)
            SceneManager.Instance.sceneElementsModel:Self_PathToTarget(uid)
        end
    end

    itemtrans:Find("Button"):GetComponent(Button).onClick:RemoveAllListeners()
    itemtrans:Find("Button"):GetComponent(Button).onClick:AddListener(onclick)
    item:GetComponent(Button).onClick:RemoveAllListeners()
    item:GetComponent(Button).onClick:AddListener(function  () self:ShowTips(1, data)    end)

    for i,v in ipairs(self.agendaMgr.day_limited_list) do
        if v.id == data.id then
            self.agendaMgr.day_limited_list[i].item = item
        end
    end

    self:DoSpecial(item,data)
    -- LuaTimer.Add(50, function () self:SwitchLayout(itemtrans:Find("Title").gameObject, false) end)
end


-- 创建comming的item
function AgendaWindow:CreatComming(data)
    --BaseUtils.dump(data,"CreatComming:")
    if data.id == 2037 or (DataAgenda.data_list[data.id] ~= nil and DataAgenda.data_list[data.id].notshow2 == 1) then
        return
    end
    local parentcon = self.parentcon[4]
    local item = parentcon:Find(tostring(data.id)) or GameObject.Instantiate(self.originAct)
    UIUtils.AddUIChild(parentcon.gameObject, item.gameObject)
    local itemtrans = item.transform
    self:SwitchLayout(itemtrans:Find("Title").gameObject, true)
    local icon = itemtrans:Find("HeadBg/Image"):GetComponent(Image)
    local Acttxt = itemtrans:Find("ActTimes"):GetComponent(Text)
    local timestxt = itemtrans:Find("Times"):GetComponent(Text)
    if data.engaged == nil then
        data.engaged = data.max_try
    end
    Acttxt.text = string.format(TI18N("活跃<color='#167FD5'>%s/%s</color>"), "0",tostring(data.max_activity))
    item.name = tostring(data.id)
    self:SetSprite(AssetConfig.dailyicon, data.icon, icon)
    itemtrans:Find("Label").gameObject:SetActive(false)
    itemtrans:Find("Button").gameObject:SetActive(false)
    itemtrans:Find("Limit").gameObject:SetActive(true)
    itemtrans:Find("Title/Name"):GetComponent(Text).text = data.name
    itemtrans:Find("Title/Name").sizeDelta = Vector2(itemtrans:Find("Title/Name"):GetComponent(Text).preferredWidth, 30)
    itemtrans:Find("Title/gain").anchoredPosition = Vector2(itemtrans:Find("Title/Name").sizeDelta.x+4, -15)
    if data.gain_id ~= 0 then
        local gain_icon = DataItem.data_get[data.gain_id]
        if gain_icon then
            self:SetSprite("", gain_icon.icon, itemtrans:Find("Title/gain"):GetComponent(Image))
            itemtrans:Find("Title/gain").gameObject:SetActive(true)
        else
            Log.Error("<color='#ff0000'>gain_id错误：活动ID</color>"..tostring(data.id))
        end
    end

    itemtrans:Find("Limit/Text"):GetComponent(Text).text = string.format(TI18N("%s级开启"), tostring(data.open_leve))
    if data.max_try == 0 then
        timestxt.text = TI18N("无限次")
    else
        timestxt.text = string.format(TI18N("次数<color='#167FD5'>%s/%s</color>"), tostring(0), tostring(data.max_try))
    end
    item.gameObject:SetActive(true)
    item:GetComponent(Button).onClick:RemoveAllListeners()
    item:GetComponent(Button).onClick:AddListener(function  () self:ShowTips(1, data)    end)

    for i,v in ipairs(self.agendaMgr.commingsoon_list) do
        if v.id == data.id then
            self.agendaMgr.commingsoon_list[i].item = item
        end
    end
    --十二星座 特殊处理
    if data.id == 2013 then
        itemtrans:Find("ActTimes").gameObject:SetActive(false)
        itemtrans:Find("TimeLimit").gameObject:SetActive(false)
        itemtrans:Find("Button").gameObject:SetActive(false)
        local starlev = itemtrans:Find("StarLev")
        starlev.gameObject:SetActive(true)
        starlev:Find("LevText"):GetComponent(Text).text = string.format(TI18N("可挑战<color='#00ff00'>%s</color>星"), tostring(ConstellationManager.Instance:GetCurrentLev()))
    end

    -- LuaTimer.Add(50, function () self:SwitchLayout(itemtrans:Find("Title").gameObject, false) end)
end

function AgendaWindow:SetSprite(res, iconid, img, SetNativeSize) --res 是资源路径
    local sprite = nil
    if "" == res then
        local id = img.gameObject:GetInstanceID()
        if self.iconloader[id] == nil then
            self.iconloader[id] = SingleIconLoader.New(img.gameObject)
        end
        self.iconloader[id]:SetSprite(SingleIconType.Item, iconid, SetNativeSize)
        return
    else
        sprite = self.assetWrapper:GetSprite(res, tostring(iconid))
    end
    img.sprite = sprite
    if SetNativeSize then
        img:SetNativeSize()
    end
    img.gameObject:SetActive(true)
end

function AgendaWindow:SwitchLayout(gameObject, flag)
    if BaseUtils.isnull(gameObject) then
        return
    end
    local ContentSizeFitterList = gameObject.transform:GetComponentsInChildren(ContentSizeFitter, true)
    local VerticalLayoutGroupList = gameObject.transform:GetComponentsInChildren(VerticalLayoutGroup, true)
    local HorizontalLayoutGroupList = gameObject.transform:GetComponentsInChildren(HorizontalLayoutGroup, true)
    local GridLayoutGroupList = gameObject.transform:GetComponentsInChildren(GridLayoutGroup, true)
    if ContentSizeFitterList ~= nil then
        for k,v in pairs(ContentSizeFitterList) do
            v.enabled = flag
        end
    end
    if VerticalLayoutGroupList ~= nil then
        for k,v in pairs(VerticalLayoutGroupList) do
            v.enabled = flag
        end
    end
    if HorizontalLayoutGroupList ~= nil then
        for k,v in pairs(HorizontalLayoutGroupList) do
            v.enabled = flag
        end
    end
    if GridLayoutGroupList ~= nil then
        for k,v in pairs(GridLayoutGroupList) do
            v.enabled = flag
        end
    end
end

function AgendaWindow:SetDoublePoint()
    if self.pointTxt == nil then
        return
    end
    self.pointTxt.text = tostring(self.agendaMgr.double_point)
    self.pointTxt.text = string.format("%s/%s", tostring(self.agendaMgr.double_point), tostring(self.agendaMgr.max_double_point))
end

function AgendaWindow:SetRewardData(data)
    self.reward_data = data
    if self.transform ~= nil then
        self:SetReward(self.reward_data)
    end
end

function AgendaWindow:SetReward(data)
    self.transform:Find("MainCon/ActivityBar/Bar/Image/Text"):GetComponent(Text).text = tostring(data.activity)
    local activitybar = self.transform:Find("MainCon/ActivityBar/Bar")
    if data.activity<20 then
        activitybar.sizeDelta = Vector2(math.max(1, 146 * (data.activity/20)), activitybar.sizeDelta.y)

    elseif data.activity >= 20 and data.activity < 40 then
        activitybar.sizeDelta = Vector2(146 + 165 * ((data.activity - 20)/20), activitybar.sizeDelta.y)

    elseif data.activity >= 40 and data.activity < 75 then
        activitybar.sizeDelta = Vector2(311 + 155*((data.activity - 40)/35), activitybar.sizeDelta.y)

    elseif data.activity >= 75 and data.activity < 120 then
        activitybar.sizeDelta = Vector2(466 + 140*((data.activity - 75)/45), activitybar.sizeDelta.y)

    elseif data.activity >= 120 then
        activitybar.sizeDelta = Vector2(math.min(656, (605 + 50*((data.activity - 120)/20))), activitybar.sizeDelta.y)
    end
    if DataAgenda.data_reward~= nil then
        for i,v in pairs(DataAgenda.data_reward) do
            local itembg = self.transform:Find(string.format("MainCon/%sGain",tostring(i))).gameObject
            -- if itemicon == nil then
            local slot = self.slotlist[i]
            if slot == nil then
                slot = ItemSlot.New()
                self.slotlist[i] = slot
            end
            local baseid = v.item_id
            if i == 75 and self.isbetaDay then
                baseid = 22549
            end
            local info = ItemData.New()
            local base = DataItem.data_get[baseid]
            info:SetBase(base)
            local extra = {inbag = false, nobutton = true}
            slot:SetAll(info, extra)
            UIUtils.AddUIChild(itembg,slot.gameObject)
            local itemicon = slot.gameObject
            -- end

            local get = false
            for _k,_v in pairs(data.rewarded) do
                if v.item_id == _v.item_id or (i == 75 and self.isbetaDay and 22549 == _v.item_id) then
                    get = true
                end
            end
            local getitem = self.transform:Find(string.format("MainCon/%s",tostring(i))).gameObject
            getitem:GetComponent(Button).onClick:RemoveAllListeners()
            getitem:GetComponent(Button).onClick:AddListener(function ()    self.agendaMgr:Require12005(v.item_id) end )
            local Img = itemicon.transform:Find("ItemImg"):GetComponent(Image)
            if get then
                -- itemicon.transform:Find("ItemImg"):GetComponent(Image).color = Color(0.4, 0.4, 0.4, 1)
                slot:SetColor(Color(0.4, 0.4, 0.4, 1))
                -- BaseUtils.SetGrey(Img, true)
                getitem:SetActive(false)
            else
                slot:SetColor(Color(1, 1, 1, 1))
                -- itemicon.transform:Find("ItemImg"):GetComponent(Image).color = Color(1, 1, 1, 1)
                -- BaseUtils.SetGrey(Img, false)
                if data.activity>= i then

                    -- itembg.transform:Find("EffectLayer").gameObject:SetActive(true)
                    if BaseUtils.isnull(getitem.transform:Find("20110")) then
                        local effectGo = GameObject.Instantiate(self:GetPrefab("prefabs/effect/20110.unity3d"))
                        effectGo.gameObject.name = "20110"
                        Utils.ChangeLayersRecursively(effectGo.transform, "UI")
                        effectGo.transform:SetParent(getitem.transform)
                        effectGo.transform.localPosition = Vector3(0, 0, -400)
                        effectGo.transform.localRotation = Quaternion.identity
                        effectGo.transform.localScale = Vector3.one
                        local glp = getitem.transform.localPosition
                        getitem.transform.localPosition = Vector3(glp.x, glp.y, -150)
                    end
                    getitem:SetActive(true)
                else

                    -- itembg.transform:Find("EffectLayer").gameObject:SetActive(false)
                    getitem:SetActive(false)
                    -- event_manager:GetUIEvent(itemicon).OnClick:RemoveAllListeners()
                    -- event_manager:GetUIEvent(itemicon).OnClick:AddListener(function ()  print(v.item_id)  self.agendaMgr:Require12005(v.item_id) end )
                end
            end
        end
    end
    self:SetLifeAct()
    -- ui_basefunctioiconarea.show_effect(14, false)
end

function AgendaWindow:SetLifeAct()
    local max_energy = DataAgenda.data_energy_max[RoleManager.Instance.RoleData.lev].max_energy
    if PrivilegeManager.Instance.monthlyExcessDays > 0 then
        max_energy = max_energy + 200
    end
    self.lifeActTxt:GetComponent(Text).text = string.format("%s/%s", RoleManager.Instance.RoleData.energy, max_energy)
end



-- 类型1：活动，类型2：副本  点击每个列表元素触发
function AgendaWindow:ShowTips(_type, data, aId)
        local acttrans = self.tipspanel:Find("Act")
        local duntrans = self.tipspanel:Find("Dun")
        acttrans.gameObject:SetActive(false)
        duntrans.gameObject:SetActive(false)
    if self.agendaExt == nil then
        self.agendaExt = MsgItemExt.New(acttrans:Find("Decstxt"):GetComponent(Text), 492, 18, 21)
    end
    if _type == 1 then
        self:SetSprite(AssetConfig.dailyicon, data.icon, acttrans:Find("HeadBg/Image"):GetComponent(Image))
        acttrans:Find("nametxt"):GetComponent(Text).text = data.name
        if data.max_try == 0 then
            acttrans:Find("Timestxt"):GetComponent(Text).text = TI18N("无限次")
        elseif data.engaged == data.max_try then
            acttrans:Find("Timestxt"):GetComponent(Text).text = string.format(TI18N("次数<color='#FA2525'>%s/%s</color>"), tostring(data.max_try), tostring(data.max_try))
        elseif data.engaged <data.max_try then
            acttrans:Find("Timestxt"):GetComponent(Text).text = string.format(TI18N("次数<color='#00ff00'>%s/%s</color>"), tostring(data.engaged), tostring(data.max_try))
        else
            acttrans:Find("Timestxt"):GetComponent(Text).text = string.format(TI18N("次数<color='#FA2525'>%s/%s</color>"), tostring(data.max_try), tostring(data.max_try))
        end
        acttrans:Find("Timetxt"):GetComponent(Text).text = data.time
        if data.id == 2014 or data.id == 2068 then
            local isHasCeremery = GodsWarWorShipManager.Instance.isHasGorWarShip
            if isHasCeremery == 1 then
                if data.id == 2014 then
                    acttrans:Find("Timetxt"):GetComponent(Text).text = TI18N("周日22:00-23:00")
                elseif data.id == 2068 then
                    acttrans:Find("Timetxt"):GetComponent(Text).text = TI18N("周日21:00-22:00")
                end
            end
        end
        acttrans:Find("Leveltxt"):GetComponent(Text).text = string.format(TI18N("%s级以上"), tostring(data.open_leve))
        acttrans:Find("Extxt"):GetComponent(Text).text = data.quest_desc
        self.agendaExt:SetData(string.format(TI18N("任务描述：%s"), data.desc))
        --acttrans:Find("Decstxt"):GetComponent(Text).text = string.format("任务描述：%s", data.desc)
        acttrans:Find("Activitytxt"):GetComponent(Text).text = string.format(TI18N("活跃度奖励：%s"), data.max_activity)
        if data.id == 2013 then
            acttrans:Find("Activitytxt"):GetComponent(Text).text = ""
            ConstellationManager.Instance:Send15202()
        end
        for i=1,3 do
            acttrans:Find(string.format("Reward%s",tostring(i))).gameObject:SetActive(false)
        end
        for i,v in ipairs(data.reward) do
            if i > 3 then break end
            local baseid = v.key
            local _slotbg = acttrans:Find(string.format("Reward%s",tostring(i))).gameObject
            self:CreatSlot(baseid,_slotbg, i)
            acttrans:Find(string.format("Reward%s",tostring(i))).gameObject:SetActive(true)
        end

        acttrans:Find("Button"):GetComponent(Button).onClick:RemoveAllListeners()
        acttrans:Find("Button"):GetComponent(Button).onClick:AddListener(function() self:TipsButtonFunc(data) end )
        -- if data.hide_button == 0 then
            acttrans:Find("Button").gameObject:SetActive(data.hide_button == 1 and data.open_leve <= RoleManager.Instance.RoleData.lev)
        -- elseif data.id > 2000 then
        --     acttrans:Find("Button").gameObject:SetActive(false)
        -- end
        acttrans.gameObject:SetActive(true)
    elseif _type == 2 then
        duntrans:Find("IconImage").gameObject:SetActive(data.id ~= 10071)
        duntrans:Find("BossBar").gameObject:SetActive(data.id ~= 10071)
        duntrans:Find("boss1").gameObject:SetActive(data.id ~= 10071)
        duntrans:Find("boss2").gameObject:SetActive(data.id ~= 10071)
        duntrans:Find("boss3").gameObject:SetActive(data.id ~= 10071)
        duntrans:Find("boss4").gameObject:SetActive(data.id ~= 10071)
        duntrans:Find("BossLogButton").gameObject:SetActive(data.id ~= 10071)
        duntrans:Find("bgText/Killtxt").gameObject:SetActive(data.id ~= 10071)
        if data.id ~= 10071 then
            self.agendaMgr:GetDungeonStatus(data.id)
        end
        duntrans:Find("BossLogButton"):GetComponent(Button).onClick:RemoveAllListeners()
        duntrans:Find("BossLogButton"):GetComponent(Button).onClick:AddListener(function ()
            TipsManager.Instance:ShowText({gameObject = duntrans:Find("BossLogButton").gameObject, itemData = {
            TI18N("每位BOSS身上可以获得一份随机奖励。"),
            }})
        end)
        duntrans:Find("Timetxt"):GetComponent(Text).text = DataAgenda.data_list[aId].time
        duntrans:Find("Leveltxt"):GetComponent(Text).text = string.format(TI18N("%s级以上"), tostring(data.cond_enter[1].val[1]))
        duntrans:Find("Decstxt"):GetComponent(Text).text = string.format(TI18N("任务描述：%s"), data.back_desc)
        duntrans:Find("Activitytxt"):GetComponent(Text).text = string.format(TI18N("活跃度奖励：%s"), data.max_activity == nil and 0 or data.max_activity)
        self:SetSprite("textures/dungeon/dungeonname.unity3d", data.name_res, duntrans:Find("NameImg"):GetComponent(Image), nil, true)
        for i=1,4 do
            duntrans:Find(string.format("ItemCon/Slot_%s",tostring(i))).gameObject:SetActive(false)
        end
        for i,v in ipairs(data.base_gain) do
            local baseid = v.item_id
            local _slotbg = duntrans:Find(string.format("ItemCon/Slot_%s",tostring(i))).gameObject
            self:CreatSlot(baseid,_slotbg, i)
            duntrans:Find(string.format("ItemCon/Slot_%s",tostring(i))).gameObject:SetActive(true)
        end
        duntrans.gameObject:SetActive(true)
    end
    self.tipspanel.gameObject:SetActive(true)
end

function AgendaWindow:CreatSlot(baseid, parent, index)
    local slot = self.tipsSlotList[index]
    if slot == nil then
        slot = ItemSlot.New()
        self.tipsSlotList[index] = slot
    end
    -- table.insert(self.slotlist, slot)
    local info = ItemData.New()
    local base = DataItem.data_get[baseid]
    if base == nil then
        Log.Error("[日程]道具id配错():[baseid:" .. tostring(baseid) .. "]")
    end
    info:SetBase(base)
    local extra = {inbag = false, nobutton = true}
    slot:SetAll(info, extra)
    UIUtils.AddUIChild(parent.gameObject,slot.gameObject)
end
--tip面板里面的button监听
function AgendaWindow:TipsButtonFunc(data)
    if RoleManager.Instance.RoleData.event == RoleEumn.Event.Dungeon and DungeonManager.Instance.activeType == 5 then
        DungeonManager.Instance:ExitDungeon()
        return
    end
    self.tipspanel.gameObject:SetActive(false)
    if self.model:SpecialDaily(data.id) then
        return
    end
    -- if (data.id == 2036 or data.id == 2037) and (GuildManager.Instance.my_guild_data == nil or GuildManager.Instance.my_guild_data.GuildId == 0) then
    --     NoticeManager.Instance:FloatTipsByString(TI18N("请先加入一个公会"))
    --     return
    -- end
    if data.panel_id~=0 then
        self:OnClose()
        if #data.panelargs >0 then
            WindowManager.Instance:OpenWindowById(data.panel_id, data.panelargs)
        else
            WindowManager.Instance:OpenWindowById(data.panel_id)
        end
    elseif data.npc_id~="0" then
        local uid = tostring(data.npc_id)
        self:OnClose()
        SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
        SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)
        SceneManager.Instance.sceneElementsModel:Self_PathToTarget(uid)
    end
end

function AgendaWindow:SetDungeonTips(data)

    local id = data.id
    local list = data.unit_reward
    local base_list = DataDungeon.data_get[id].unit_list
    for i, v in ipairs(base_list) do
        -- if list[i] ~= nil and v.unit_num >= list[i].num then
            self.tipspanel:Find(string.format("Dun/boss%s/Killed", tostring(i))).gameObject:SetActive(list[i] ~= nil and v.unit_num >= list[i].num)
        -- else
            -- self.tipspanel:Find(string.format("Dun/boss%s/Killed", tostring(i))).gameObject:SetActive(false)
        -- end
    end
end


function AgendaWindow:GetStartBtnByID(ID)
    for i,v in ipairs(self.parentcon) do
        if v:Find(string.format("%s/Button", tostring(ID))) ~= nil then
            return v:Find(string.format("%s/Button", tostring(ID))).gameObject
        end
    end
end

function AgendaWindow:SetConstellationArea(data)
    local maplist = {}
    for k,v in pairs(data.constellation_unit) do
        maplist[v.map_id] = 1
    end
    local str = ""
    for k,v in pairs(maplist) do
        if str == "" then
            str = str..DataMap.data_list[k].name
        else
            str = string.format("%s、%s", str, DataMap.data_list[k].name)
        end
    end
    if str == "" then
        str = TI18N("无")
    end
    self.tipspanel:Find("Act/Activitytxt"):GetComponent(Text).text = string.format(TI18N("当前星座降临区域：<color='#ffff00'>%s</color>"), str)
end

function AgendaWindow:DoSpecial(item, data)
    local itemtrans = item.transform
    local icon = itemtrans:Find("HeadBg/Image"):GetComponent(Image)
    local timestxt = itemtrans:Find("Times"):GetComponent(Text)
    if data.id == 2013 then
        itemtrans:Find("ActTimes").gameObject:SetActive(false)
        itemtrans:Find("TimeLimit").gameObject:SetActive(false)
        itemtrans:Find("Button").gameObject:SetActive(false)
        local starlev = itemtrans:Find("StarLev")
        starlev.gameObject:SetActive(true)
        starlev:Find("LevText"):GetComponent(Text).text = string.format(TI18N("可挑战<color='#00ff00'>%s</color>星"), tostring(ConstellationManager.Instance:GetCurrentLev()))
        itemtrans:Find("SpecialText").gameObject:SetActive(data.engaged ~= data.max_try and not itemtrans:Find("Finish").gameObject.activeSelf)
    elseif data.id == 2009 then
        itemtrans:Find("redpoint").gameObject:SetActive(self.agendaMgr.currLimitList[2009]== true)
    elseif data.id == 99 then
        itemtrans:Find("HeadBg").gameObject:SetActive(false)
        itemtrans:Find("Times").gameObject:SetActive(false)
        itemtrans:Find("ActTimes").gameObject:SetActive(false)
        itemtrans:Find("TimeLimit").gameObject:SetActive(false)
        itemtrans:Find("Title").gameObject:SetActive(false)
        itemtrans:Find("Button").gameObject:SetActive(false)
        itemtrans:Find("SpecialText").gameObject:SetActive(false)
        itemtrans:Find("More").gameObject:SetActive(true)
        item:GetComponent(Button).onClick:RemoveAllListeners()
        item:GetComponent(Button).onClick:AddListener(function  () self.clanderPanel:Show()   end)
    elseif data.id == 2044 then
        -- 诸神之战
        itemtrans:Find("redpoint").gameObject:SetActive(GodsWarManager.Instance:AgendaRed())
    elseif data.id == 1025 then
        itemtrans:Find("redpoint").gameObject:SetActive(GodsWarManager.Instance:AgendaRed())
        itemtrans:Find("HeadBg"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Item5")
        itemtrans:Find("Label"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Tipslabel4")
        itemtrans:Find("Label/Text"):GetComponent(Text).text = TI18N("盛事")
        itemtrans:Find("Label/Text"):GetComponent(Text).color = Color.white
        itemtrans:Find("Label").gameObject:SetActive(true)
        itemtrans:Find("Button").gameObject:SetActive(true)
        itemtrans:Find("TimeLimit").gameObject:SetActive(false)
    elseif data.id == 1004 then
        local maxtry = data.max_try
        if RoleManager.Instance.RoleData.lev < 50 then
            maxtry = 4
        end
        if data.engaged < maxtry then
            timestxt.text = string.format(TI18N("次数<color='#167FD5'>%s/%s</color>"), tostring(data.engaged), tostring(maxtry))
            itemtrans:Find("Finish").gameObject:SetActive(false)
            itemtrans:Find("Button").gameObject:SetActive(true)
            icon.color = Color(1 ,1 ,1 , 1)
        else
            timestxt.text = string.format(TI18N("次数<color='#FA2525'>%s/%s</color>"), tostring(maxtry), tostring(maxtry))
            -- if data.hide_button == 0 then
            itemtrans:Find("Finish").gameObject:SetActive(true)
            icon.color = Color(0.4 ,0.4 ,0.4 , 1)
            itemtrans:Find("Button").gameObject:SetActive(false)
            -- end
        end
    elseif data.id == 1022 then
        local maxtry = data.max_try
        if RoleManager.Instance.RoleData.lev < 50 then
            maxtry = 3
        end
        if data.engaged < maxtry then
            timestxt.text = string.format(TI18N("次数<color='#167FD5'>%s/%s</color>"), tostring(data.engaged), tostring(maxtry))
            itemtrans:Find("Finish").gameObject:SetActive(false)
            itemtrans:Find("Button").gameObject:SetActive(true)
            icon.color = Color(1 ,1 ,1 , 1)
        else
            timestxt.text = string.format(TI18N("次数<color='#FA2525'>%s/%s</color>"), tostring(maxtry), tostring(maxtry))
            -- if data.hide_button == 0 then
            itemtrans:Find("Finish").gameObject:SetActive(true)
            icon.color = Color(0.4 ,0.4 ,0.4 , 1)
            itemtrans:Find("Button").gameObject:SetActive(false)
            -- end
        end
    elseif data.id == 2057 then -- 龙王
        itemtrans:Find("ActTimes").gameObject:SetActive(false)
        itemtrans:Find("Times"):GetComponent(Text).text = StarChallengeManager.Instance:GetAgendaDescString(1)
        -- local showButton, specialTextString = StarChallengeManager.Instance:GetAgendaShowButton(1)
        -- itemtrans:Find("Button").gameObject:SetActive(showButton)
        -- itemtrans:Find("TimeLimit").gameObject:SetActive(not showButton)
        -- itemtrans:Find("TimeLimit/Text"):GetComponent(Text).text = specialTextString
        itemtrans:Find("Button").gameObject:SetActive(true)
        itemtrans:Find("TimeLimit").gameObject:SetActive(false)
    elseif data.id == 2058 then -- 龙王
        itemtrans:Find("ActTimes").gameObject:SetActive(false)
        itemtrans:Find("Times"):GetComponent(Text).text = StarChallengeManager.Instance:GetAgendaDescString(2)
        -- local showButton, specialTextString = StarChallengeManager.Instance:GetAgendaShowButton(2)
        -- itemtrans:Find("Button").gameObject:SetActive(showButton)
        -- itemtrans:Find("TimeLimit").gameObject:SetActive(not showButton)
        -- itemtrans:Find("TimeLimit/Text"):GetComponent(Text).text = specialTextString
        itemtrans:Find("Button").gameObject:SetActive(true)
        itemtrans:Find("TimeLimit").gameObject:SetActive(false)

    elseif data.id == 2075 then -- 天启
        itemtrans:Find("ActTimes").gameObject:SetActive(false)
        itemtrans:Find("Times"):GetComponent(Text).text = ApocalypseLordManager.Instance:GetAgendaDescString(1)
        itemtrans:Find("Button").gameObject:SetActive(true)
        itemtrans:Find("TimeLimit").gameObject:SetActive(false)
    elseif data.id == 2073 then -- 天启
        itemtrans:Find("ActTimes").gameObject:SetActive(false)
        itemtrans:Find("Times"):GetComponent(Text).text = ApocalypseLordManager.Instance:GetAgendaDescString(2)
        itemtrans:Find("Button").gameObject:SetActive(true)
        itemtrans:Find("TimeLimit").gameObject:SetActive(false)
    end

    if data.id == 2029 or data.id == 2030 or data.id == 2031 then
        itemtrans:Find("redpoint").gameObject:SetActive(false)
    end

    if data.id == 2044 then
        itemtrans:Find("HeadBg"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Item5")
        itemtrans:Find("Label"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Tipslabel4")
        itemtrans:Find("Label/Text"):GetComponent(Text).text = TI18N("盛事")
        itemtrans:Find("Label/Text"):GetComponent(Text).color = Color.white
        itemtrans:Find("Button").gameObject:SetActive(false)
        itemtrans:Find("TimeLimit").gameObject:SetActive(true)
        itemtrans:Find("TimeLimit/Text"):GetComponent(Text).text = TI18N("敬请期待")
        itemtrans:Find("Label").gameObject:SetActive(true)
    end

    if data.id == 1006 then
        -- if (TrialManager.Instance.model.mode == 1 and TrialManager.Instance.model.reset == 0 and TrialManager.Instance.model.times == 0 ) or (TrialManager.Instance.model.times == 0 and TrialManager.Instance.model.reset == 0) then
        local trialModel = TrialManager.Instance.model
        if (trialModel.reset == 0 and trialModel.times == 0) or (trialModel.reset == 0 and (trialModel.order == 0 or DataTrial.data_trial_data[trialModel.order] == nil)) then
            itemtrans:Find("Finish").gameObject:SetActive(true)
            icon.color = Color(0.4 ,0.4 ,0.4 , 1)
            itemtrans:Find("Button").gameObject:SetActive(false)
        else
            itemtrans:Find("Finish").gameObject:SetActive(false)
            icon.color = Color(1 ,1 ,1 , 1)
            itemtrans:Find("Button").gameObject:SetActive(true)
        end
    end
    ------------------------------------检查下是否需要显示红点
    if data.id == 1017 then
        --炼化
        local state = AlchemyManager.Instance.model:CheckRedPointState()
        itemtrans:Find("redpoint").gameObject:SetActive(state)
    elseif data.id == 1024 then
        itemtrans:Find("redpoint").gameObject:SetActive(GloryManager.Instance:RedPointMainUI())
    end
end
--筛选活动，全部活动则不筛选
function AgendaWindow:Filter(filter_type, id)
    if filter_type == nil or DataAgenda.data_filter[filter_type] == nil then
        return true
    else
        for k,v in pairs(DataAgenda.data_filter[filter_type].args) do
            if id == v then
                return true
            end
        end
        return false
    end
end


function AgendaWindow:IsRedPoint()
   local roledata = RoleManager.Instance.RoleData
    local key = BaseUtils.Key(roledata.id, roledata.platform, roledata.zone_id,99999)
    local str = PlayerPrefs.GetString(key)

    local t = false
    if str == "init" then
        t = false
    else
        t = true
    end



    local baseTime = BaseUtils.BASE_TIME
    local y = tonumber(os.date("%Y", baseTime))
    local m = tonumber(os.date("%m", baseTime))
    local d = tonumber(os.date("%d", baseTime))

    local beginTime = nil
    local endTime = nil

    if m == 6 and t == true then
        if d >= 16 and d <= 18 then
            print("进入了1")
            self.firstRedPoint.gameObject:SetActive(true)
        else
            local str = PlayerPrefs.GetString(key)
            if str ~= nil then
                PlayerPrefs.DeleteKey(key)
            end
            self.firstRedPoint.gameObject:SetActive(false)
        end
    else
        local str = PlayerPrefs.GetString(key)
        if str ~= nil then
            PlayerPrefs.DeleteKey(key)
        end
        self.firstRedPoint.gameObject:SetActive(false)
    end

end

function AgendaWindow:IsShowWeekRewardButtonEffect()
    local show = false
    if self.model.week_rewards_info ~= nil then
        for k,v in pairs(self.model.week_rewards_info) do
            if v.flag == 0 and self.model.week_activity >= v.activity_need then
                show = true
            end
        end
    end
    if show then
        if self.weekRewardButtonEffect == nil then
            local effectGo = GameObject.Instantiate(self:GetPrefab("prefabs/effect/20053.unity3d"))
            effectGo.gameObject.name = "20110"
            Utils.ChangeLayersRecursively(effectGo.transform, "UI")
            effectGo.transform:SetParent(self.transform:Find("MainCon/WeekRewardButton"))
            effectGo.transform.localPosition = Vector3(-55, -12, -400)
            effectGo.transform.localRotation = Quaternion.identity
            effectGo.transform.localScale = Vector3(1.8, 0.6, 1)
            self.weekRewardButtonEffect = effectGo
        else
            self.weekRewardButtonEffect:SetActive(true)
        end
    else
        if self.weekRewardButtonEffect ~= nil then
            self.weekRewardButtonEffect:SetActive(false)
        end
    end
end