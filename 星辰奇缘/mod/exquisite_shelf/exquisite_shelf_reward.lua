-- @author 黄耀聪
-- @date 2017年8月21日, 星期一

ExquisiteShelfReward = ExquisiteShelfReward or BaseClass(BaseWindow)

function ExquisiteShelfReward:__init(model)
    self.model = model
    self.name = "ExquisiteShelfReward"
    self.windowId = WindowConfig.WinID.exquisite_shelf_reward
    self.cacheMode = CacheMode.Visible
    if BaseUtils.IsIPhonePlayer() then --ios特殊处理
        self.cacheMode = CacheMode.Destroy
    end
    self.holdTime = 180

    self.resList = {
        {file = AssetConfig.exquisite_shelf_reward, type = AssetType.Main},
        {file = AssetConfig.exquisite_shelf_textures, type = AssetType.Dep},
    }

    self.conList = {}
    self.normalList = {}
    self.rareList = {}
    self.timerIds = {}
    self.effectList = {[2] = {}, [3] = {}}

    self.isNormalOpened = false
    self.isRareOpened = false

    self.updateListener = function(data) self:Update(data) end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function ExquisiteShelfReward:__delete()
    self.OnHideEvent:Fire()
    if self.normalList ~= nil then
        for _,v in pairs(self.normalList) do
            if v.slot ~= nil then
                v.slot:DeleteMe()
            end
        end
        self.normalList = nil
    end
    if self.rareList ~= nil then
        for i,v in pairs(self.rareList) do
            if v.slot ~= nil then
                v.slot:DeleteMe()
            end
        end
        self.rareList = nil
    end
    if self.effectList ~= nil then
        for _,effects in pairs(self.effectList) do
            for _,effect in pairs(effects) do
                if effect ~= nil then
                    effect:DeleteMe()
                end
            end
        end
        self.effectList = nil
    end
    if self.titleExt2 ~= nil then
        self.titleExt2:DeleteMe()
        self.titleExt2 = nil
    end
    self:AssetClearAll()
end

function ExquisiteShelfReward:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.exquisite_shelf_reward))
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    local t = self.gameObject.transform
    self.gameObject.name = self.name
    self.transform = t
    local canvas = self.gameObject:GetComponent(Canvas)
    canvas.overrideSorting = true
    canvas.sortingOrder = 20
    canvas.overrideSorting = false

    local main = t:Find("Main")
    self.main = main
    self.title1 = main:Find("TitleBg1").gameObject
    self.titleText1 = main:Find("TitleBg1/Text1"):GetComponent(Text)
    self.title2 = main:Find("TitleBg2").gameObject
    self.titleExt2 = MsgItemExt.New(main:Find("TitleBg2/Text2"):GetComponent(Text), 500, 18, 20.85)
    self.closeBtn = main:Find("Close"):GetComponent(Button)
    self.closeText = main:Find("Close/Text"):GetComponent(Text)
    self.free = main:Find("Free")
    for i=1,3 do
        local tab = {}
        tab.transform = self.free:GetChild(i - 1)
        tab.gameObject = tab.transform.gameObject
        tab.open = tab.transform:Find("Open").gameObject
        tab.close = tab.transform:Find("Close").gameObject
        tab.slot = ItemSlot.New()
        tab.slot.transform:SetParent(tab.transform)
        tab.slot.transform.localScale = Vector3.one
        tab.slot.transform.localPosition = Vector3.zero
        tab.get = tab.transform:Find("Get").gameObject
        tab.get.transform:SetAsLastSibling()
        local j = i
        tab.gameObject:GetComponent(Button).onClick:AddListener(function() self:OpenBox(j, 2) end)
        self.normalList[i] = tab
        tab.slot.gameObject:SetActive(false)
    end
    self.unfree = main:Find("UnFree")
    for i=1,3 do
        local tab = {}
        tab.transform = self.unfree:GetChild(i - 1)
        tab.gameObject = tab.transform.gameObject
        tab.open = tab.transform:Find("Open").gameObject
        tab.close = tab.transform:Find("Close").gameObject
        tab.slot = ItemSlot.New()
        tab.slot.transform:SetParent(tab.transform)
        tab.slot.transform.localScale = Vector3.one
        tab.slot.transform.localPosition = Vector3.zero
        tab.get = tab.transform:Find("Get").gameObject
        tab.get.transform:SetAsLastSibling()
        local j = i
        tab.gameObject:GetComponent(Button).onClick:AddListener(function() self:OpenBox(j, 3) end)
        self.rareList[i] = tab
        tab.slot.gameObject:SetActive(false)
    end

    self.title1.gameObject:SetActive(false)
    self.title2.gameObject:SetActive(false)

    self.closeText.text = TI18N("关 闭")
    self.closeBtn.onClick:AddListener(function() self:OnClose() end)
end

function ExquisiteShelfReward:OnInitCompleted()
    self.OnOpenEvent:Fire()

    self.transform:Find("Panel"):GetComponent(Button).onClick:RemoveAllListeners()
    -- self.transform:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:OnRealClose() end)
end

function ExquisiteShelfReward:OnOpen()
    self:RemoveListeners()
    ExquisiteShelfManager.Instance.onRewardEvent:AddListener(self.updateListener)


    -- self.openArgs = {data = {
    --     type = 3,
    --     wave = 2,
    --     normal_gain_list = {
    --         {item_id = 20000, num = 10000},
    --         {item_id = 20000, num = 10000, is_get = 1},
    --         {item_id = 20000, num = 10000},
    --     },
    --     gold_gain_list = {
    --         {item_id = 20000, num = 10000},
    --         {item_id = 20000, num = 10000},
    --         {item_id = 20000, num = 10000},
    --     },
    -- }}

    self.data = (self.openArgs or {}).data or self.data or {normal_gain_list = {}, gold_gain_list = {}}
    self.type = self.data.type or self.type or 2
    self.isNormalOpened = false
    self.isRareOpened = false
    self:Init()
end

function ExquisiteShelfReward:OnHide()
    self:RemoveListeners()
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
    for k,v in pairs(self.timerIds) do
        if v ~= nil then
            LuaTimer.Delete(v)
            self.timerIds[k] = nil
        end
    end
    if self.tweenId ~= nil then
        Tween.Instance:Cancel(self.tweenId)
        self.tweenId = nil
    end
end

function ExquisiteShelfReward:RemoveListeners()
    ExquisiteShelfManager.Instance.onRewardEvent:RemoveListener(self.updateListener)
end

function ExquisiteShelfReward:Init()
    self.title1:SetActive(true)
    self.free.gameObject:SetActive(true)

    if self.data.wave < ExquisiteShelfManager.Instance.firstWave then
        self.title2:SetActive(false)
        self.unfree.gameObject:SetActive(false)
        self.main.sizeDelta = Vector2(0,200)
    else
        self.title2:SetActive(true)
        self.unfree.gameObject:SetActive(true)
        self.titleExt2:SetData(string.format(TI18N("开启玲珑珍宝需要花费<color='#00ff00'>%s</color>{assets_2,%s}，是否开启？"), DataExquisiteShelf.data_cost[self.data.wave].cost[1][2], DataExquisiteShelf.data_cost[self.data.wave].cost[1][1]))
        local size = self.titleExt2.contentTrans.sizeDelta
        self.titleExt2.contentTrans.anchoredPosition = Vector2(-size.x/2, size.y/2)
        self.title2.transform.sizeDelta = Vector2(size.x + 100, size.y + 20)

        self.main.sizeDelta = Vector2(0,350)
    end

    self.closeBtn.gameObject:SetActive(false)
    self:Reload(self.data, true)
end

function ExquisiteShelfReward:Reload(data, isFirst)
    -- 容错处理
    data.normal_gain_list = data.normal_gain_list or {}
    data.gold_gain_list = data.gold_gain_list or {}

    local normalGot = false
    for _,v in ipairs(data.normal_gain_list) do
        normalGot = normalGot or (v.is_get == 1)
    end

    for i,box in ipairs(self.normalList) do
        local dat = data.normal_gain_list[i]
        box.transform.localScale = Vector3.one
        if dat == nil or not normalGot or (dat.is_get == 0 and ExquisiteShelfManager.Instance:GetCurrentLevel(self.data.wave) ~= 1) then
            box.open:SetActive(false)
            box.close:SetActive(true)
            box.slot.gameObject:SetActive(false)
            box.get.gameObject:SetActive(false)

            if self.effectList[2][i] ~= nil then
                self.effectList[2][i]:SetActive(false)
            end
        else
            box.open:SetActive(true)
            box.close:SetActive(false)
            box.itemData = box.itemData or ItemData.New()
            box.itemData:SetBase(DataItem.data_get[dat.item_id])
            box.slot:SetAll(box.itemData, {inbag = false, nobutton = true})
            box.slot:SetNum(dat.num)
            box.slot.gameObject:SetActive(true)
            box.get.gameObject:SetActive(dat.is_get == 1)

            if dat.is_get == 1 and not isFirst then
                if self.effectList[2][i] == nil then
                    self.effectList[2][i] = BaseUtils.ShowEffect(20146, box.transform, Vector3(1, 1, 1), Vector3(0, 0, -400))
                else
                    self.effectList[2][i]:SetActive(true)
                end
            end
        end
        box.data = dat
    end

    if self.data.wave > ExquisiteShelfManager.Instance.firstWave then
        self.titleText1.text = string.format(TI18N("通过%s星难度可开启<color='#00ff00'>%s</color>/%s宝箱"), 3, ExquisiteShelfManager.Instance:GetBoxNum(), 3)
        self.titleExt2:SetData(string.format(TI18N("开启玲珑珍宝需要花费<color='#00ff00'>%s</color>{assets_2,%s}，是否开启？"), DataExquisiteShelf.data_cost[self.data.wave].cost[1][2], DataExquisiteShelf.data_cost[self.data.wave].cost[1][1]))
        local size = self.titleExt2.contentTrans.sizeDelta
        self.titleExt2.contentTrans.anchoredPosition = Vector2(-size.x/2, size.y/2)
        self.title2.transform.sizeDelta = Vector2(size.x + 100, size.y + 20)
    else
        self.titleText1.text = TI18N("请选择一个宝箱开启！")
    end

    local rareGot = false
    for _,v in ipairs(data.gold_gain_list) do
        rareGot = rareGot or (v.is_get == 1)
    end

    for i,box in ipairs(self.rareList) do
        local dat = data.gold_gain_list[i]
        box.transform.localScale = Vector3.one
        if dat == nil or dat.item_id == 0 or not rareGot then
            box.open:SetActive(false)
            box.close:SetActive(true)
            box.slot.gameObject:SetActive(false)
            box.get.gameObject:SetActive(false)
        else
            box.open:SetActive(true)
            box.close:SetActive(false)
            box.itemData = box.itemData or ItemData.New()
            box.itemData:SetBase(DataItem.data_get[dat.item_id])
            box.slot:SetAll(box.itemData, {inbag = false, nobutton = true})
            box.slot:SetNum(dat.num)
            box.slot.gameObject:SetActive(true)
            box.get.gameObject:SetActive(dat.is_get == 1)

            if dat.is_get == 1 and not isFirst then
                if self.effectList[3][i] == nil then
                    self.effectList[3][i] = BaseUtils.ShowEffect(20146, box.transform, Vector3(1, 1, 1), Vector3(0, 0, 0))
                else
                    self.effectList[3][i]:SetActive(true)
                end
            end
        end
        box.data = dat
    end

    if self.type == ExquisiteShelfEumn.RewardType.Normal then
        if normalGot then
            self:CheckForClose()
        end
    elseif self.type == ExquisiteShelfEumn.RewardType.Gold then
        self.closeBtn.gameObject:SetActive(normalGot or rareGot)
    end

    -- ==============================================
    -- ================== 以下弃用 ==================
    -- ==============================================

    -- if type == 2 then
    --     list = self.normalList
    --     self.data.show_list = data.show_list
    --     self.data.gain_list = data.gain_list
    -- elseif type == 3 then
    --     list = self.rareList
    -- else
    --     list = self.normalList
    -- end

    -- if order > 0 then
    --     local box = list[order]
    --     box.open:SetActive(true)
    --     box.close:SetActive(false)
    --     box.itemData = box.itemData or ItemData.New()
    --     box.itemData:SetBase(DataItem.data_get[data.gain_list[1].item_id1])
    --     box.slot:SetAll(box.itemData, {inbag = false, nobutton = true})
    --     box.slot.gameObject:SetActive(true)
    --     box.slot:SetNum(data.gain_list[1].num1)
    --     box.get.gameObject:SetActive(true)

    --     if self.effectList[type] == nil then
    --         self.effectList[type] = BaseUtils.ShowEffect(20146, box.transform, Vector3(1, 1, 1), Vector3(0, 0, 0))
    --     else
    --         self.effectList[type]:SetActive(false)
    --         self.effectList[type]:SetActive(true)
    --     end
    -- end

    -- if self.timerIds[type] ~= nil then
    --     LuaTimer.Delete(self.timerIds[type])
    --     self.timerIds[type] = nil
    -- end

    -- local datalist = {}
    -- if data.show_list ~= nil and next(data.show_list) ~= nil then
    --     if type == 2 then
    --         self.isNormalOpened = true
    --     elseif type == 3 then
    --         self.isRareOpened = true
    --     end
    --     local index = 1
    --     for i=1,#data.show_list+1 do
    --         if i == data.order and #data.gain_list > 0 then
    --             table.insert(datalist, {base_id = data.gain_list[1].item_id1, num = data.gain_list[1].num1})
    --         else
    --             print(index)
    --             table.insert(datalist, {base_id = data.show_list[index].item_id2, num = data.show_list[index].num2})
    --             index = index + 1
    --         end
    --     end

    --     if type == 2 then
    --         self.hasGetNormal = true
    --     else
    --         self.hasGetRare = true
    --     end
    -- end

    -- if list ~= nil then
    --     local dat = nil
    --     for i,box in ipairs(list) do
    --         dat = datalist[i]
    --         box.close:SetActive(dat == nil)
    --         box.open:SetActive(dat ~= nil)
    --         box.slot.gameObject:SetActive(dat ~= nil)
    --         box.get:SetActive(false)
    --         if dat ~= nil then
    --             box.itemData = box.itemData or ItemData.New()
    --             box.itemData:SetBase(DataItem.data_get[dat.base_id])
    --             box.slot:SetAll(box.itemData, {inbag = false, nobutton = true})
    --             box.slot:SetNum(dat.num)

    --             box.get:SetActive(i == order)
    --         end
    --         box.data = dat
    --     end
    -- else
    --     for i,box in ipairs(list) do
    --         box.data = nil
    --     end
    -- end

    -- -- if order ~= 0 then
    -- --     self.closeBtn.gameObject:SetActive(true)
    -- --     self:ShowCloseCountdown()
    -- -- end

    -- if order ~= 0 then
    --     if self.type == 3 then
    --         self.closeBtn.gameObject:SetActive(true)
    --     else
    --         self.closeBtn.gameObject:SetActive(false)
    --         self:CheckForClose()
    --     end
    -- else
    --     self.closeBtn.gameObject:SetActive(false)
    -- end

    -- if self.openArgs == nil or next(self.openArgs) == nil then
    --     self.closeBtn.gameObject:SetActive(true)
    -- end
end

function ExquisiteShelfReward:OpenBox(order, type)
    --print(string.format("%s_%s", order, type))
    if type == 2 then
        if self.normalList[order].data ~= nil and self.normalList[order].data.is_get == 1 then
            return
        end
        self.isNormalOpened = true
        self:Duang(self.normalList[order].gameObject, function() ExquisiteShelfManager.Instance:send20310(order, type) end)
        return
    elseif type == 3 then
        local rareGot = false
        for _,v in ipairs(self.data.gold_gain_list) do
            if v.is_get == 1 then
                return
            end
        end
        if DataExquisiteShelf.data_cost[self.data.wave] ~= nil then
            local confirmData = NoticeConfirmData.New()
            confirmData.content = string.format(TI18N("开启玲珑珍宝需要花费<color='#00ff00'>%s</color>{assets_2,%s}，是否开启？"), DataExquisiteShelf.data_cost[self.data.wave].cost[1][2], DataExquisiteShelf.data_cost[self.data.wave].cost[1][1])
            confirmData.sureCallback = function() self.isRareOpened = true ExquisiteShelfManager.Instance:send20310(order, type) end
            self:Duang(self.rareList[order].gameObject, function() NoticeManager.Instance:ConfirmTips(confirmData) end)
        else
            self.isRareOpened = true
            self:Duang(self.rareList[order].gameObject, function() ExquisiteShelfManager.Instance:send20310(order, type) end)
        end
    end
end

function ExquisiteShelfReward:Update(data)
    self.data = data
    self:Reload(data, false)
end

function ExquisiteShelfReward:OnClose()
    WindowManager.Instance:CloseWindow(self)
    if RoleManager.Instance.RoleData.event == RoleEumn.Event.ExquisiteShelf then
        if ExquisiteShelfManager.Instance:GetCurrentLevel() == 1 then
            ExquisiteShelfManager.Instance:ShowTeamUp()
        else
            if self.data.wave <= ExquisiteShelfManager.Instance.firstWave and (not self.isNormalOpened) and (not self.isRareOpened) then
                LuaTimer.Add(200, function() ExquisiteShelfManager.Instance:send20309() end)
            end
        end
    end
end

function ExquisiteShelfReward:OnRealClose()
    WindowManager.Instance:CloseWindow(self)
    if RoleManager.Instance.RoleData.event == RoleEumn.Event.ExquisiteShelf and ExquisiteShelfManager.Instance:GetCurrentLevel() == 1 then
        ExquisiteShelfManager.Instance:ShowTeamUp()
    end
end

function ExquisiteShelfReward:ShowCloseCountdown()
    if self.hasGetNormal ~= true or self.hasGetRare ~= true then
        return
    end
    if self.timerId == nil then
        self.counter1 = 3
        self.timerId = LuaTimer.Add(0, 1000, function()
            self.closeText.text = string.format(TI18N("关闭（%s）"), self.counter1)
            self.counter1 = (self.counter1 or 1) - 1
            if self.counter1 == 0 then
                LuaTimer.Delete(self.timerId)
                self.timerId = nil
                self:OnRealClose()
            end
        end)
    end
end

function ExquisiteShelfReward:Duang(target, callback)
    if self.tweenId == nil then
        self.tweenId = Tween.Instance:Scale(target.transform, Vector3.one * 0.7, 0.2, function()
            if callback ~= nil then callback() end
            self.tweenId = Tween.Instance:Scale(target.transform, Vector3.one, 0.2, function() self.tweenId = nil end, LeanTweenType.easeOutElastic).id
        end, LeanTweenType.linear).id
    end
end

function ExquisiteShelfReward:CheckForClose()
    if self.timerId == nil then
        self.counter1 = 3
        self.timerId = LuaTimer.Add(0, 1000, function()
            self.counter1 = (self.counter1 or 1) - 1
            if self.counter1 == 0 then
                LuaTimer.Delete(self.timerId)
                self.timerId = nil
                self:OnRealClose()
            end
        end)
    end
end
