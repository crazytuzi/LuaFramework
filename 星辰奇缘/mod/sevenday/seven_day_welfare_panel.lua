-- @author 黄耀聪
-- @date 2016年7月13日

SevendayWelfare = SevendayWelfare or BaseClass(BasePanel)

function SevendayWelfare:__init(model, parent,isright)
    self.model = model
    self.parent = parent
    self.name = "SevendayWelfare"
    self.mgr = SevendayManager.Instance

    self.resList = {
        {file = AssetConfig.sevenday_welfare, type = AssetType.Main},
        {file = AssetConfig.sevenday_textures, type = AssetType.Dep},
        {file = AssetConfig.masquerade_textures, type = AssetType.Dep},
    }

    self.updateListener = function() self:Update() end
    self.updateTargetListener = function() self:Update() end
    self.itemlist = {}
    self.itemEffectList = {}
    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
    self.effectList = {}
end

function SevendayWelfare:__delete()
    for k,list in pairs(self.effectList) do
        for _,e in ipairs(list) do
            e:DeleteMe()
        end
    end
    self.effectList = nil

    if self.itemEffectList ~= nil then
        for _,v in pairs(self.itemEffectList) do
            if v ~= nil then
                v:DeleteMe()
            end
        end
        self.itemEffectList = nil
    end
    self.OnHideEvent:Fire()
    if self.itemlist ~= nil then
        for _,v in pairs(self.itemlist) do
            if v ~= nil then
                v.layout:DeleteMe()
                if v.slot ~= nil then
                    v.slot:DeleteMe()
                end
            end
        end
        self.itemlist = nil
    end
    if self.layout ~= nil then
        self.layout:DeleteMe()
        self.layout = nil
    end
    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function SevendayWelfare:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.sevenday_welfare))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t


    self.container = t:Find("ScrollLayer/Container")
    self.cloner = t:Find("ScrollLayer/Cloner").gameObject
    self.scrollTrans = t:Find("ScrollLayer")
    t:Find("ScrollLayer"):GetComponent(ScrollRect).onValueChanged:AddListener(function() self:OnValueChanged() end)
    self.layout = LuaBoxLayout.New(self.container, {axis = BoxLayoutAxis.Y, cspacing = 10, border = 5})
end

function SevendayWelfare:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function SevendayWelfare:OnOpen()
    local model = self.model
    self:RemoveListeners()
    self.mgr.onUpdateTarget:AddListener(self.updateTargetListener)
    self.mgr.onUpdateCharge:AddListener(self.updateListener)
    BibleManager.Instance.onUpdateSevenday:AddListener(self.updateListener)
    EventMgr.Instance:AddListener(event_name.seven_day_charge_upgrade, self.updateListener)
    SevendayManager.Instance:send14106()
    -- self.updateListener()
end

function SevendayWelfare:GetDataList(day)
    local model = self.model

    local dat = {
        {
            id = self.openArgs,
            title = TI18N("今日登录赠送"),
            datalist = DataCheckin.data_get_checkin_data[self.openArgs].reward_client,
            val = #BibleManager.Instance.servenDayData.seven_day,
            target = self.openArgs,
            callback = function(order) BibleManager.Instance:send14101(order) end,
            rewarded = not (BibleManager.Instance.servenDayData.seven_day[self.openArgs] == nil or BibleManager.Instance.servenDayData.seven_day[self.openArgs].rewarded == 0),
            disString = TI18N("明日可领"),
            type = 1,
        }
    }
    local days, day8 = self.model:GetCurrentDay()
    if day == 7 then
        --累计登陆8天，选中第七天的，则将第八天的福利领取显示在第七天
        table.insert(dat, {
            id = 8,
            title = TI18N("第8天登录赠送"),
            datalist = DataCheckin.data_get_checkin_data[8].reward_client,
            val = #BibleManager.Instance.servenDayData.seven_day,
            target = 8,
            callback = function(order) BibleManager.Instance:send14101(order) end,
            rewarded = not (BibleManager.Instance.servenDayData.seven_day[8] == nil or BibleManager.Instance.servenDayData.seven_day[8].rewarded == 0),
            disString = TI18N("明日可领"),
            type = 2,
        })
    end

    for k, v in pairs(DataGoal.data_goal) do
        if v.tabId == 15 and v.day == day then
            --特殊
            table.insert(dat, {
                id = v.id,
                type = 3
            })
        end
    end

    if self.mgr.lastDays == nil or self.mgr.lastDays < 15 then
        if model.dayToCharge[day] ~= nil then
            for i,v in ipairs(model.dayToCharge[day]) do
                -- ((not (self.model.chargeTab[v] == nil or self.model.chargeTab[v].rewarded == 0)) == false and self.model.todayChargeData.day_charge >= DataCheckin.data_daily_charge[v].charge) or
                if day == days then
                    --是当天的累计充值，则显示出来
                    table.insert(dat, {
                            id = v,
                            title = string.format(TI18N("今日累计充值%s{assets_2,90002}可领(%s/%s)"), tostring(DataCheckin.data_daily_charge[v].charge), self.model.todayChargeData.day_charge, DataCheckin.data_daily_charge[v].charge),
                            datalist = DataCheckin.data_daily_charge[v].reward_client,
                            val =  self.model.todayChargeData.day_charge, --PrivilegeManager.Instance.charge,
                            target = DataCheckin.data_daily_charge[v].charge,
                            callback = function(order) SevendayManager.Instance:send14105(order) end,
                            discallback = function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.shop, {3, 1}) end,
                            disString = TI18N("充值"),
                            rewarded = not (self.model.chargeTab[v] == nil or self.model.chargeTab[v].rewarded == 0),
                            type = 2,
                        })
                end
            end
        end
    end
    return dat
end

function SevendayWelfare:OnHide()
    self:RemoveListeners()
end

function SevendayWelfare:RemoveListeners()
    self.mgr.onUpdateTarget:RemoveListener(self.updateTargetListener)
    self.mgr.onUpdateCharge:RemoveListener(self.updateListener)
    BibleManager.Instance.onUpdateSevenday:RemoveListener(self.updateListener)
    EventMgr.Instance:RemoveListener(event_name.seven_day_charge_upgrade,self.updateListener)
end

function SevendayWelfare:UpdateCharge()

end

function SevendayWelfare:OnGoto(id)
    local data = DataGoal.data_goal[id]
    local str = data.action
    if str == "" or RoleManager.Instance.RoleData.lev < data.lev then
        return
    end
    local strList = StringHelper.Split(str, ":")
    local type = strList[1]
    strList = StringHelper.Split(strList[2], ",")
    if type == "1" then
        local args = {}
        for i=2,#strList do
            table.insert(args, tonumber(strList[i]))
        end
        WindowManager.Instance:OpenWindowById(tonumber(strList[1]), args)
    elseif type == "2" then
        QuestManager.Instance.model:FindNpc(strList[1].."_"..strList[2])
        self.model:CloseWindow()
    end
end

function SevendayWelfare:ShowEffect(id, transform, scale, position, time, index)
    local fun = function(effectView)
        local effectObject = effectView.gameObject
        effectObject.transform:SetParent(transform)
        effectObject.name = "Effect"
        effectObject.transform.localScale = scale
        effectObject.transform.localPosition = position
        effectObject.transform.localRotation = Quaternion.identity

        Utils.ChangeLayersRecursively(effectObject.transform, "UI")

        local y = self.layout.panelRect.anchoredPosition.y
        local height = self.scrollTrans.rect.height+20
        local item = effectObject.transform.parent.parent.parent
        -- effectObject:SetActive(not (-item.anchoredPosition.y < y or -item.anchoredPosition.y + item.sizeDelta.y > y + height))
        effectObject:SetActive(index <= 3)
    end
    return BaseEffectView.New({effectId = id, time = time, callback = fun})
end

function SevendayWelfare:OnValueChanged()
    -- local y = self.layout.panelRect.anchoredPosition.y
    -- local height = self.scrollTrans.rect.height+20
    -- for _,v in pairs(self.itemEffectList) do
    --     if v ~= nil and v.gameObject ~= nil and not BaseUtils.is_null(v.gameObject) then
    --         local item = v.gameObject.transform.parent.parent.parent
    --         v.gameObject:SetActive(not (-item.anchoredPosition.y < y or -item.anchoredPosition.y + item.sizeDelta.y > y + height))
    --     end
    -- end
    for i,v in ipairs(self.itemlist) do
        local selfy = math.abs(v.rect.anchoredPosition.y)
        local y = self.container.anchoredPosition.y

        local show = true
        if (selfy + 104) - (321 + y) > 15 or y - selfy > 50 then
            show = false
        end

        if show then
            if self.effectList[i] ~= nil then
                for k,e in ipairs(self.effectList[i]) do
                    if e.gameObject ~= nil then
                        e.gameObject:SetActive(true)
                    end
                end
            end
        else
            if self.effectList[i] ~= nil then
                for k,e in ipairs(self.effectList[i]) do
                    if e.gameObject ~= nil then
                        e.gameObject:SetActive(false)
                    end
                end
            end
        end
    end
end

function SevendayWelfare:SetWelfare(tab, data)
    local loginDay = self.openArgs
    local nowDay,t = self.model:GetCurrentDay()
    local model = self.model
    tab.targetCon.gameObject:SetActive(false)
    tab.welfareCon.gameObject:SetActive(false)
    if data.type == 3 then
        --目标的挪过来
        tab.targetCon.gameObject:SetActive(true)

        local basedata = DataGoal.data_goal[data.id]
        local day = basedata.day
        local protoData = self.model.targetTab[data.id]
        tab.data:SetBase(DataItem.data_get[basedata.rewards_commit[1][1]])
        tab.slot:SetAll(tab.data, {inbag = false, nobutton = true})
        tab.slot:SetNum(basedata.rewards_commit[1][2], 0)

        --检查一下是否显示特效
        local showEffect = false
        for i=1, #basedata.rewards_effect do
            if basedata.rewards_effect[i][1] == basedata.rewards_commit[1][1] then
                showEffect = true
                break
            end
        end
        if showEffect then
            if self.itemEffectList[1] == nil then
                -- string.format("%s_%s", data.id, basedata.rewards_commit[1][1])
                self.itemEffectList[1] = self:ShowEffect(20223,tab.slot.transform,Vector3(1, 1, 1), Vector3(0, 0, 0))
            end
            local effectObj = self.itemEffectList[1]
            if effectObj ~= nil and effectObj.gameObject ~= nil and not BaseUtils.is_null(effectObj.gameObject) then
                local y = self.layout.panelRect.anchoredPosition.y
                local height = self.scrollTrans.rect.height+20
                local item = effectObj.gameObject.transform.parent.parent.parent
                effectObj.gameObject:SetActive(not (-item.anchoredPosition.y < y or -item.anchoredPosition.y + item.sizeDelta.y > y + height))
            end
        end

        tab.descText.text = basedata.desc
        tab.titleText.text = basedata.name
        tab.progressText.text = ""
        if protoData ~= nil then
            -- tab.slider.gameObject:SetActive(protoData.rewarded ~= 1)
            tab.gotoText.text = TI18N("前往")
            if protoData.finish == 1 or protoData.rewarded == 1 then
                tab.titleText.text = string.format("%s <color='#00ff00'>(%s)</color>", basedata.name, "0/0")
                tab.slider.value = 1
                if #protoData.progress == 0 then
                    tab.titleText.text = string.format("%s <color='#00ff00'>(%s)</color>", basedata.name, "1/1")
                    tab.slider.value = 1
                else
                    local tempStr = string.format("%s/%s", ItemSlot.FormatNum(nil, protoData.progress[1].value), ItemSlot.FormatNum(nil, protoData.progress[1].target_val))
                    tab.titleText.text = string.format("%s <color='#00ff00'>(%s)</color>", basedata.name, tempStr)
                    tab.slider.value = 1
                end
            else
                if #protoData.progress == 0 then
                    if protoData.finish == 1 then
                        tab.titleText.text = string.format("%s <color='#00ff00'>(%s)</color>", basedata.name, "1/1")
                        tab.slider.value = 1
                    else
                        tab.titleText.text = string.format("%s <color='#00ff00'>(%s)</color>", basedata.name, "0/1")
                        tab.slider.value = 0
                    end
                else
                    local tempStr = string.format("%s/%s", ItemSlot.FormatNum(nil, protoData.progress[1].value), ItemSlot.FormatNum(nil, protoData.progress[1].target_val))
                    tab.titleText.text = string.format("%s <color='#00ff00'>(%s)</color>", basedata.name, tempStr)
                    tab.slider.value = protoData.progress[1].value / protoData.progress[1].target_val
                end
            end

            if loginDay > nowDay then
                tab.getText.text = string.format("<color='%s'>第%s天可领</color>", ColorHelper.ButtonLabelColor.Blue,loginDay)
                tab.getText.gameObject:SetActive(true)
                tab.getBtn.gameObject:SetActive(false)
                tab.receiveObj:SetActive(false)
                tab.gotoBtn.gameObject:SetActive(false)
            else
                tab.getText.gameObject:SetActive(false)
                tab.getBtn.gameObject:SetActive(protoData.finish == 1 and protoData.rewarded ~= 1)
                tab.gotoBtn.gameObject:SetActive(protoData.finish == 0 and protoData.rewarded ~= 1)
                tab.receiveObj:SetActive(true)
            end


        else
            tab.getBtn.gameObject:SetActive(false)
            tab.gotoText.text = string.format(TI18N("%s级开启"), tostring(basedata.lev))
            if #basedata.progress == 0 then
                tab.titleText.text = string.format("%s <color='#00ff00'>(%s)</color>", basedata.name, "0/1")
                tab.slider.value = 0
            else
                local tempStr = string.format("0/%s", ItemSlot.FormatNum(nil, basedata.progress[1].target_val))
                tab.titleText.text = string.format("%s <color='#00ff00'>(%s)</color>", basedata.name, tempStr)
                tab.slider.value = 0
            end
            tab.receiveObj:SetActive(false)
        end

        tab.getBtn.onClick:RemoveAllListeners()
        tab.getBtn.onClick:AddListener(function() self.mgr:send10236(day, data.id) end)

        tab.gotoBtn.onClick:RemoveAllListeners()
        tab.gotoBtn.onClick:AddListener(function() self:OnGoto(data.id) end)
    else
        tab.welfareCon.gameObject:SetActive(true)
        -- tab.wtitleText.text = data.title
        tab.wtitleTextMsg:SetData(data.title)
        -- tab.wslider.gameObject:SetActive(data.type == 2)
        local fenmu = 10
        if data.id == 8 and data.target == 8 then
            fenmu = 1
        end
        if data.val > data.target then
            tab.wslider.value = 1

            tab.wprogressText.text = string.format("%s/%s", tostring(data.target / fenmu), tostring(data.target / fenmu))
        else
            tab.wslider.value = data.val / data.target
            tab.wprogressText.text = string.format("%s/%s", tostring(data.val / fenmu), tostring(data.target / fenmu))
        end

        local classes = RoleManager.Instance.RoleData.classes
        local sex = RoleManager.Instance.RoleData.sex
        local datalist = {}
        for _,v in pairs(data.datalist or {}) do
            if #v > 3 then
                if (v[3] == nil or v[3] == 0 or v[3] == classes) and (v[4] == nil or v[4] == 2 or v[4] == sex) then
                    table.insert(datalist, v)
                end
            else
                table.insert(datalist, v)
            end
        end
        local newW = 71*#datalist
        local index = tab.index
        if newW > 282 then
            newW = 282
        end
        tab.scrollLayer:GetComponent(RectTransform).sizeDelta = Vector2(newW, 66)
        model:AddItems(tab.layout, tab.container, tab.cloner, tab.itemlist, datalist, function(cloner) return self:GetObject(cloner) end, function(tab, data) self:SetData(tab, data, index) end)

        tab.btn.gameObject:SetActive(data.rewarded ~= true)


        local loginDay = self.openArgs
        local nowDay,t = self.model:GetCurrentDay()

        if data.val < data.target then
            tab.btnImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton1")
            -- tab.btnText.text = data.disString

            if loginDay > nowDay   then
                if data.id == 8 then
                    tab.btnText.text = string.format("<color='%s'>第8天可领</color>", ColorHelper.ButtonLabelColor.Blue)
                else
                    tab.btnText.text = string.format("<color='%s'>第%s天可领</color>", ColorHelper.ButtonLabelColor.Blue,loginDay)
                end
            else
                tab.btnText.text = string.format("<color='%s'>%s</color>", ColorHelper.ButtonLabelColor.Blue, data.disString)
            end
            if data.discallback == nil then
                tab.btn.enabled = false
                tab.btnImage.enabled = false
                -- tab.btnText.color = ColorHelper.colorObject[1]
            else
                tab.btn.enabled = true
                tab.btnImage.enabled = true
                -- tab.btnText.color = Color(0.83, 1, 1)
                tab.btn.onClick:RemoveAllListeners()
                tab.btn.onClick:AddListener(function() data.discallback() end)
            end
            tab.wreceiveObj:SetActive(false)
        else
            tab.btn.enabled = true
            tab.btnImage.enabled = true
            -- tab.btnText.color = Color(0.83, 1, 1)
            tab.btnText.text = string.format("<color='%s'>%s</color>", ColorHelper.ButtonLabelColor.Orange, TI18N("领取"))
            tab.btnImage.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton3")
            tab.btn.onClick:RemoveAllListeners()
            tab.btn.onClick:AddListener(function() print(data.id) data.callback(data.id) end)
            -- if BibleManager.Instance.servenDayData ~= nil then
            --     tab.receiveObj:SetActive(BibleManager.Instance.servenDayData.seven_day[data.id].rewarded == 1)
            -- end
            if data.rewarded == true then
                tab.wslider.gameObject:SetActive(false)
                tab.wreceiveObj:SetActive(true)
            else
                tab.wreceiveObj:SetActive(false)
            end
        end
    end
end

function SevendayWelfare:GetWelfare(cloner, index)
    local tab = {}
    tab.itemlist = {}
    tab.index = index
    tab.obj = GameObject.Instantiate(cloner)
    tab.rect = tab.obj:GetComponent(RectTransform)
    --福利
    tab.welfareCon = tab.obj.transform:Find("WelfareCon")
    tab.scrollLayer = tab.welfareCon:Find("ScrollLayer")
    tab.container = tab.welfareCon:Find("ScrollLayer/Container")
    tab.cloner = tab.welfareCon:Find("ScrollLayer/Cloner").gameObject
    tab.btn = tab.welfareCon:Find("Button"):GetComponent(Button)
    tab.btnText = tab.welfareCon:Find("Button/I18N_Text"):GetComponent(Text)
    tab.btnImage = tab.welfareCon:Find("Button"):GetComponent(Image)
    tab.wreceiveObj = tab.welfareCon:Find("ReceivedText").gameObject
    tab.wreceiveObj.gameObject:SetActive(false)
    tab.wtitleText = tab.welfareCon:Find("I18N_Title"):GetComponent(Text)
    tab.wtitleTextMsg = MsgItemExt.New(tab.wtitleText, 330, 16, 23)
    tab.wslider = tab.welfareCon:Find("Slider"):GetComponent(Slider)
    tab.wprogressText = tab.welfareCon:Find("Slider/Progress"):GetComponent(Text)
    tab.layout = LuaBoxLayout.New(tab.container, {axis = BoxLayoutAxis.X, border = 5, cspacing = 5})


    --目标
    tab.targetCon = tab.obj.transform:Find("TargetCon")
    tab.titleText = tab.targetCon:Find("Title"):GetComponent(Text)
    tab.slot = ItemSlot.New()
    NumberpadPanel.AddUIChild(tab.targetCon:Find("Reward"), tab.slot.gameObject)
    tab.data = ItemData.New()
    tab.descText = tab.targetCon:Find("Desc"):GetComponent(Text)
    tab.slider = tab.targetCon:Find("Slider"):GetComponent(Slider)
    tab.progressText = tab.targetCon:Find("Slider/Progress"):GetComponent(Text)
    tab.getBtn = tab.targetCon:Find("Get"):GetComponent(Button)
    tab.gotoBtn = tab.targetCon:Find("Goto"):GetComponent(Button)
    tab.gotoText = tab.targetCon:Find("Goto/I18N_Text"):GetComponent(Text)
    tab.receiveObj = tab.targetCon:Find("ReceivedText").gameObject
    tab.getText = tab.targetCon:Find("Button/I18N_Text"):GetComponent(Text)
    tab.getText.gameObject:SetActive(false)
    tab.receiveObj.gameObject:SetActive(false)
    return tab
end

function SevendayWelfare:GetObject(cloner)
    local tab = {}
    tab.obj = GameObject.Instantiate(cloner)
    tab.trans = tab.obj.transform
    tab.slot = ItemSlot.New()
    NumberpadPanel.AddUIChild(tab.trans, tab.slot.gameObject)
    tab.data = ItemData.New()
    return tab
end

function SevendayWelfare:SetData(tab, data, index)
    tab.data:SetBase(DataItem.data_get[data[1]])
    tab.slot:SetAll(tab.data, {inbag = false, nobutton = true})
    tab.slot:SetNum(data[2])
    tab.obj:SetActive(true)

    local needEffect = false
    if #data > 3 then
        needEffect = (data[6] == 1)
    else
        needEffect = (data[3] == 1)
    end

    if self.effectList[index] == nil then
        self.effectList[index] = {}
    end

    if needEffect then
        if tab.effect == nil then
            tab.effect = self:ShowEffect(20223, tab.trans, Vector3.one, Vector3(29, 0, 0), nil, index)
            table.insert(self.effectList[index], tab.effect)
        else
            if index <= 3 then
                if tab.effect.gameObject ~= nil and not BaseUtils.is_null(tab.effect.gameObject) then
                    tab.effect.gameObject:SetActive(true)
                end
            end
        end
    else
        if tab.effect ~= nil then
            if tab.effect.gameObject ~= nil and not BaseUtils.is_null(tab.effect.gameObject) then
                tab.effect.gameObject:SetActive(false)
            end
        end
    end
end

function SevendayWelfare:Update()
    local model = self.model
    local datalist = self:GetDataList(self.openArgs)
    model:AddItems(self.layout, self.container, self.cloner, self.itemlist, datalist, function(cloner, index) return self:GetWelfare(cloner, index) end, function(tab, data) self:SetWelfare(tab, data) end)
end
