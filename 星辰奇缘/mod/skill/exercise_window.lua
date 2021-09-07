-- 历练面板
-- xhs  20180110

ExerciseWindow = ExerciseWindow or BaseClass(BaseWindow)

function ExerciseWindow:__init(model)
    self.Mgr = ClassesChallengeManager.Instance
    self.model = model
    self.name = "ExerciseWindow"
    self.windowId = WindowConfig.WinID.exercise_window
    self.cacheMode = CacheMode.Destroy

    self.resList = {
        {file = AssetConfig.exercise_window, type = AssetType.Main},
        {file = AssetConfig.exercise_textures, type = AssetType.Dep, holdTime = 5},
        {file = AssetConfig.dailyicon, type = AssetType.Dep},
    }

    self.itemList = {}

    self.extList = {}


    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function ExerciseWindow:__delete()
    self.OnHideEvent:Fire()

    for k,v in pairs(self.itemList) do
        GameObject.DestroyImmediate(v)
        self.itemList[k] = nil
    end
    self.itemList = {}

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    if self.timeMsgItem ~= nil then
        self.timeMsgItem:DeleteMe()
        self.timeMsgItem = nil
    end

    for k,v in pairs(self.extList) do
        v:DeleteMe()
    end
    self.extList = {}
    self:AssetClearAll()
end

function ExerciseWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.exercise_window))
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.gameObject.name = self.name
    local main = self.gameObject.transform:Find("Main")
    main:Find("CloseButton"):GetComponent(Button).onClick:AddListener(function() self:OnClose() end)
    local con = main:Find("Con")
    self.total = con:Find("Total/val"):GetComponent(Text)
    self.time = con:Find("Right/val"):GetComponent(Text)
    self.time1 = con:Find("Right/val1"):GetComponent(Text)
    self.container = con:Find("ItemBar/mask/Container")
    self.cloner = self.container:Find("cloner").gameObject
    self.timeMsgItem = MsgItemExt.New(self.time,197.5,17,25)
    self.timeMsgItem1 = MsgItemExt.New(self.time1,115,17,25)
    self.quickBuy = con:Find("Right/Button"):GetComponent(Button)
    self.quickBuy.onClick:AddListener(function() self:QuickBuy() end)

end

function ExerciseWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function ExerciseWindow:OnOpen()
    self:AddListeners()
    -- SkillManager.Instance:Send10834()
    self.day_list = {}
    for k,v in pairs(AgendaManager.Instance.day_list) do
        if v.id == 2019 then
            table.insert(self.day_list,2023)
        elseif v.id == 2023 then
            table.insert(self.day_list,2019)
        end
        table.insert(self.day_list,v.id)
    end

    self:SetItem()
    self:ShowTime()
end

function ExerciseWindow:OnHide()
    self:RemoveListeners()
end

function ExerciseWindow:ShowTime()
    local time = SkillManager.Instance.sq_double - BaseUtils.BASE_TIME
    local str = nil
    if time < 3600 and time > 0 then
        str = string.format(TI18N("剩余%s分钟"), tostring(math.ceil(time/60)))
    elseif time < 3600 * 10 and time > 0 then
        str = string.format(TI18N("剩余%s小时%s分钟"), tostring(math.floor(time/3600)),tostring(math.floor(time%3600/60)))
    elseif time < 3600 * 24 and time > 0 then
        str = string.format(TI18N("剩余%s小时"), tostring(math.floor(time/3600)))
    elseif time < 0 then
        str = "未开启加成"
    else
        str = string.format(TI18N("剩余%s天"), tostring(math.floor(time/3600/24)))
    end
     self.timeMsgItem:SetData(string.format("%s",str))
     self.timeMsgItem1:SetData(string.format("{assets_2,23838}历练加成:"))
end

function ExerciseWindow:AddListeners()
    self:RemoveListeners()
    -- EventMgr.Instance:Fire(event_name.agenda_update)
    -- SkillManager.Instance.OnUpdateDoublePoint:AddListener(self.updatedouble)
end

function ExerciseWindow:RemoveListeners()
    -- SkillManager.Instance.OnUpdateDoublePoint:RemoveListener(self.updatedouble)
end

function ExerciseWindow:OnClose()
    WindowManager.Instance:CloseWindow(self)
    -- WindowManager.Instance:OpenWindowById(WindowConfig.WinID.skill)
end

function ExerciseWindow:SetItem()
    local totalPoint = 0
    local actualPoint = 0
    for i=1,#DataSkillUnique.data_agenda_list do
        local agenda = DataSkillUnique.data_agenda_list[i]
        local item = self.itemList[agenda.agenda_id]
        if self:CheckOpen(agenda.agenda_id) then
            if item == nil then
                item = GameObject.Instantiate(self.cloner)
                item.transform:SetParent(self.container)
                item:GetComponent(RectTransform).localScale = Vector3(1, 1, 1)
                local data = DataAgenda.data_list[agenda.agenda_id]
                item.name = agenda.agenda_id
                item.transform:Find("Name"):GetComponent(Text).text = data.name
                item.transform:Find("Desc"):GetComponent(Text).text = agenda.desc
                item.transform:Find("Icon/Image"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.dailyicon,tostring(data.icon))

                local limit = DataSkillUnique.data_combat_exp[agenda.agenda_id.."_"..RoleManager.Instance.RoleData.lev]

                local ext
                table.insert(self.extList,ext)

                if agenda.agenda_id ~= 1000 then
                    if limit.limit == 99 then
                        item.transform:Find("Val1/Limit"):GetComponent(Text).text = 0
                    else
                        item.transform:Find("Val1/Limit"):GetComponent(Text).text = "0/"..limit.limit
                    end
                    ext = MsgItemExt.New(item.transform:Find("Val1/Text"):GetComponent(Text), 200, 17, 25)
                    ext:SetData("0{assets_2,90055}")
                else
                    item.transform:Find("Val1").gameObject:SetActive(false)
                    item.transform:Find("Val2").gameObject:SetActive(true)
                    ext = MsgItemExt.New(item.transform:Find("Val2/Text"):GetComponent(Text), 200, 17, 25)
                    ext:SetData(string.format("0/%s{assets_2,90055}",limit.sq_exp_total))
                end

                for k,v in pairs(SkillManager.Instance.count) do
                    if v.combat_type == agenda.combat_type then
                        totalPoint = totalPoint + v.real_gain
                        actualPoint = actualPoint + v.gain
                        if v.combat_type ~= 8 then
                            if limit.limit == 99 then
                                item.transform:Find("Val1/Limit"):GetComponent(Text).text = v.times
                            else
                                if v.times >= limit.limit then
                                    item.transform:Find("Val1/Limit"):GetComponent(Text).text = string.format("<color='#ff0000'>%s</color>/%s",v.times,limit.limit)
                                else
                                    item.transform:Find("Val1/Limit"):GetComponent(Text).text = v.times.."/"..limit.limit
                                end
                            end
                            ext:SetData(string.format("%s{assets_2,90055}",v.real_gain))
                        else
                            item.transform:Find("Val1").gameObject:SetActive(false)
                            item.transform:Find("Val2").gameObject:SetActive(true)
                            if v.real_gain >= limit.sq_exp_total then
                                ext:SetData(string.format("<color='#ff0000'>%s</color>/%s{assets_2,90055}",v.real_gain,limit.sq_exp_total))
                            else
                                ext:SetData(string.format("%s/%s{assets_2,90055}",v.real_gain,limit.sq_exp_total))
                            end
                        end
                    end
                end
                item.transform:Find("Button"):GetComponent(Button).onClick:AddListener(function()
                    if data.id ~= 1017 and data.id ~= 1027 and RoleManager.Instance.RoleData.event == RoleEumn.Event.Dungeon and DungeonManager.Instance.activeType == 5 then
                        DungeonManager.Instance:ExitDungeon()
                        self:OnClose()
                        return
                    end
                    if AgendaManager.Instance.model:SpecialDaily(data.id) then
                        self:OnClose()
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
                end)
            end
            item:SetActive(true)
        else
            if item ~= nil then
                item:SetActive(false)
            end
        end
    end
    local ext = MsgItemExt.New(self.total, 200, 17, 25)
    table.insert(self.extList,ext)
    ext:SetData(string.format("%s(额外%s){assets_2,90055}",totalPoint,totalPoint - actualPoint))
end

function ExerciseWindow:CheckOpen(id)
    for k,v in pairs(self.day_list) do
        if id == v then
            return true
        end
    end
    return false
end

function ExerciseWindow:QuickBuy()
    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.exercisequickbuywindow)

end


