-- @author ###
-- @date 2018年4月13日,星期五

MainuiChallangeView = MainuiChallangeView or BaseClass(BasePanel)

function MainuiChallangeView:__init(Manager)
    self.name = "MainuiChallangeView"

    self.ReallyManager = Manager

    self.agendaMgr = AgendaManager.Instance
    self.resList = {
        {file = AssetConfig.mainuichallange, type = AssetType.Main}
        ,{file = AssetConfig.dailyicon, type = AssetType.Dep}
        ,{file = AssetConfig.agenda_textures, type = AssetType.Dep}
    }

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)

    self.challangeList = nil

    self.tipsSlotList = {}

    self.itemList = {}

    self.setting = {
        column = 3
        ,borderleft = 8
        ,bordertop = 8
        ,cspacing = 5
        ,rspacing = 5
        ,cellSizeX = 146
        ,cellSizeY = 178
    }
end

function MainuiChallangeView:__delete()
    self.OnHideEvent:Fire()


    if self.GridLayout ~= nil then
        self.GridLayout:DeleteMe()
        self.GridLayout = nil
    end

    if self.tipsSlotList ~= nil then
        for _,slot in pairs(self.tipsSlotList) do
            slot:DeleteMe()
        end
        self.tipsSlotList = nil
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function MainuiChallangeView:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.mainuichallange))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(TipsManager.Instance.model.tipsCanvas, self.gameObject)
    self.transform = t
    self.panelBtn = self.transform:Find("Panel"):GetComponent(Button):GetComponent(Button)
    self.panelBtn.onClick:AddListener(function() self.ReallyManager:CloseChallengePanel() end)
    self.transform:Find("CloseButton"):GetComponent(Button).onClick:AddListener(function () self.ReallyManager:CloseChallengePanel() end)
    self.tipspanel = self.transform:Find("TipsPanel")

    self.tipspanel:Find("CloseButton"):GetComponent(Button).onClick:AddListener(function() self.tipspanel.gameObject:SetActive(false) end)
    self.tipspanel:GetComponent(Button).onClick:AddListener(function() self.tipspanel.gameObject:SetActive(false) end )

    self.NormalAct = self.transform:Find("MainCon/ActivityItem").gameObject
    self.parentContainer = self.transform:Find("MainCon/ActivityCon2/MaskScroll/Layout")

    self.GridLayout = LuaGridLayout.New(self.parentContainer, self.setting)
end

function MainuiChallangeView:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function MainuiChallangeView:OnOpen()
    self:RemoveListeners()
    self.challangeList = AgendaManager.Instance.challange_list

    self:LoadActivity()

end

function MainuiChallangeView:OnHide()
    self:RemoveListeners()
end

function MainuiChallangeView:RemoveListeners()
end

--加载活动item
function MainuiChallangeView:LoadActivity()
    self.GridLayout:ReSet()

    for i,data in pairs(self.challangeList) do
        if self.itemList[i] == nil then
            local item = {}
            item.gameObject = GameObject.Instantiate(self.NormalAct)
            item.transform = item.gameObject.transform
            item.name = item.transform:Find("Title/Name"):GetComponent(Text)
            item.label = item.transform:Find("Label")
            item.timestxt = item.transform:Find("TimesImg/Times"):GetComponent(Text)
            item.Acttxt = item.transform:Find("ActTimesImg/ActTimes"):GetComponent(Text)
            item.finish = item.transform:Find("Finish")
            item.icon = item.transform:Find("HeadBg/Image"):GetComponent(Image)
            --item.gain_icon = item.transform:Find("Title/gain"):GetComponent(Image)
            --item.iconloader = SingleIconLoader.New(item.icon.gameObject)
            --item.gainiconloader = SingleIconLoader.New(item.gain_icon.gameObject)

            item.button = item.transform:GetComponent(Button)
            item.button.onClick:RemoveAllListeners()
            item.button.onClick:AddListener(function() self:ShowTips(1, data) end)
            self.itemList[i] = item

        end
        self.GridLayout:AddCell(self.itemList[i].gameObject)
        local TempItem = self.itemList[i]
        if data.engaged == nil then
            data.engaged = data.max_try
        end
        --item.name = tostring(data.id)
        TempItem.label.gameObject:SetActive(false)
        TempItem.name.text = data.name
        --TempItem.name.transform.sizeDelta = Vector2(TempItem.name.preferredWidth, 30)

        local rate = 1
        if self.agendaMgr.recommend_list[data.id] ~= nil then
            rate = 2
            TempItem.label.gameObject:SetActive(true)
        end

        -- local gain_icon = DataItem.data_get[data.gain_id]
        -- if gain_icon then
        --     TempItem.gainiconloader:SetSprite(SingleIconType.Item, gain_icon.icon)
        --     TempItem.gain_icon.gameObject:SetActive(true)
        -- else
        --     Log.Error("<color='#ff0000'>gain_id错误：活动ID</color>"..tostring(data.id))
        -- end
        TempItem.icon.sprite = self.assetWrapper:GetSprite(AssetConfig.dailyicon, tostring(data.icon))
        TempItem.icon.gameObject:SetActive(true)

        TempItem.Acttxt.text = string.format(TI18N("活跃<color='#167FD5'>%s/%s</color>"), tostring(math.min((data.engaged) * data.activity,data.max_activity) * rate),tostring(data.max_activity * rate))
        TempItem.gameObject:SetActive(true)

        if data.max_try == 0 then
            TempItem.timestxt.text = TI18N("无限次")
            TempItem.finish.gameObject:SetActive(false)
            TempItem.icon.color = Color(1 ,1 ,1 , 1)
        elseif data.engaged < data.max_try then
            TempItem.timestxt.text = string.format(TI18N("次数<color='#167FD5'>%s/%s</color>"), tostring(data.engaged), tostring(data.max_try))
            TempItem.finish.gameObject:SetActive(false)
            TempItem.icon.color = Color(1 ,1 ,1 , 1)
        else
            TempItem.timestxt.text = string.format(TI18N("次数<color='#FA2525'>%s/%s</color>"), tostring(data.max_try), tostring(data.max_try))
            TempItem.finish.gameObject:SetActive(true)
            TempItem.icon.color = Color(0.4 ,0.4 ,0.4 , 1)
        end
    end
end

-- 类型1：活动  点击每个列表元素触发
function MainuiChallangeView:ShowTips(_type, data, aId)
    local acttrans = self.tipspanel:Find("Act")
    local duntrans = self.tipspanel:Find("Dun")
    acttrans.gameObject:SetActive(false)
    duntrans.gameObject:SetActive(false)
    if self.agendaExt == nil then
        self.agendaExt = MsgItemExt.New(acttrans:Find("Decstxt"):GetComponent(Text), 492, 18, 21)
    end
    if _type == 1 then
        acttrans:Find("HeadBg/Image"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.dailyicon, tostring(data.icon))
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
        acttrans:Find("Leveltxt"):GetComponent(Text).text = string.format(TI18N("%s级以上"), tostring(data.open_leve))
        acttrans:Find("Extxt"):GetComponent(Text).text = data.quest_desc
        self.agendaExt:SetData(string.format(TI18N("任务描述：%s"), data.desc))
        --acttrans:Find("Decstxt"):GetComponent(Text).text = string.format("任务描述：%s", data.desc)
        acttrans:Find("Activitytxt"):GetComponent(Text).text = string.format(TI18N("活跃度奖励：%s"), data.max_activity)
        --十二星座，请求星座分布
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

--tip面板里面的button监听
function MainuiChallangeView:TipsButtonFunc(data)
    if RoleManager.Instance.RoleData.event == RoleEumn.Event.Dungeon and DungeonManager.Instance.activeType == 5 then
        DungeonManager.Instance:ExitDungeon()
        return
    end
    self.tipspanel.gameObject:SetActive(false)
    if self.agendaMgr.model:SpecialDaily(data.id) then
        return
    end

    if data.panel_id ~= 0 then
        self.ReallyManager:CloseChallengePanel()
        if #data.panelargs > 0 then
            WindowManager.Instance:OpenWindowById(data.panel_id, data.panelargs)
        else
            WindowManager.Instance:OpenWindowById(data.panel_id)
        end
    elseif data.npc_id ~= "0" then
        local uid = tostring(data.npc_id)
        self.ReallyManager:CloseChallengePanel()
        SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
        SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)
        SceneManager.Instance.sceneElementsModel:Self_PathToTarget(uid)
    end
end
--设置12 星座 位置信息
function MainuiChallangeView:SetConstellationArea(data)
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

function MainuiChallangeView:CreatSlot(baseid, parent, index)
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

