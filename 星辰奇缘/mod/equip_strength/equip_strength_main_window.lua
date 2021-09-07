EquipStrengthMainWindow  =  EquipStrengthMainWindow or BaseClass(BaseWindow)

function EquipStrengthMainWindow:__init(model)
    self.name  =  "EquipStrengthMainWindow"
    self.windowId = WindowConfig.WinID.eqmadvance
    self.model  =  model
    -- 缓存
    self.cacheMode = CacheMode.Visible

    self.resList  =  {
        {file  =  AssetConfig.equip_strength_main_win, type  =  AssetType.Main}
        , {file = AssetConfig.guidetaskicon, type = AssetType.Dep}
    }

    self.subFirst = nil
    self.subSecond = nil
    self.mainObj = nil

    self.tabLevelOpenList = {
        38,
        40,
        40,
        45,
        80,
    }

    self.cur_index = 0
    self.OnOpenEvent:Add(function() self:OnShow() end)
    self.OnHideEvent:Add(function() self:OnHide() end)
    self.OnInitCompletedEvent:Add(function() self:OnInitCompleted() end)

    self.on_role_change = function(data)
        for i,v in ipairs(self.tabLevelOpenList) do
            self["tab_btn" .. i].gameObject:SetActive(RoleManager.Instance.RoleData.lev >= v)
        end
    end

    self.guideEffect = nil

    return self
end

function EquipStrengthMainWindow:OnInitCompleted()
    self:CheckGuidePoint()
end
function EquipStrengthMainWindow:OnShow()
    if self.openArgs ~= nil and #self.openArgs > 0 then
        self:tabChange(self.openArgs[1])
    else
        self:tabChange(self.curSelectedBtn)
    end

    self.on_tab_point_update()
    self:CheckGuidePoint()
end

function EquipStrengthMainWindow:OnHide()
    if self.subSecond ~= nil then
        self.subSecond:OnResetHeroStone()
        self.subSecond:Hiden()
    end
    if self.subFirst ~= nil then
        self.subFirst:Hiden()
    end
end

function EquipStrengthMainWindow:__delete()
    EventMgr.Instance:RemoveListener(event_name.quest_update,self.checkGuidePoint)
    EventMgr.Instance:RemoveListener(event_name.equip_item_change, self.on_tab_point_update)
    EventMgr.Instance:RemoveListener(event_name.equip_build_resetval_update, self.on_tab_point_update)
    EventMgr.Instance:RemoveListener(event_name.role_level_change, self.on_role_change)

    EventMgr.Instance:RemoveListener(event_name.backpack_item_change, self.on_tab_point_update)

    self.tab_btn_icon1.sprite = nil
    self.tab_btn_icon2.sprite = nil
    self.tab_btn_icon3.sprite = nil
    self.tab_btn_icon4.sprite = nil

    if self.buyConfirm ~= nil then
        self.buyConfirm:DeleteMe()
        self.buyConfirm = nil
    end
    if self.guideEffect ~= nil then
        self.guideEffect:DeleteMe()
        self.guideEffect = nil
    end

    if self.imgLoader ~= nil then
        self.imgLoader:DeleteMe()
        self.imgLoader = nil
    end

    if self.subFirst ~= nil then
        self.subFirst:DeleteMe()
        self.subFirst = nil
    end
    if self.subSecond ~= nil then
        self.subSecond:DeleteMe()
        self.subSecond = nil
    end

    if self.guideScript ~= nil then
        self.guideScript:DeleteMe()
        self.guideScript = nil
    end

    self.curSelectedBtn = 0
    self.is_open = false

    GameObject.DestroyImmediate(self.gameObject)
    self.gameObject = nil
    self:AssetClearAll()
end

function EquipStrengthMainWindow:InitPanel()
    if self.gameObject ~=  nil then
        --加载回调两次，这里暂时处理
        return
    end
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.equip_strength_main_win))
    self.gameObject:SetActive(false)
    self.gameObject.name = "EquipStrengthMainWindow"
    self.transform = self.gameObject.transform
    UIUtils.AddUIChild(ctx.CanvasContainer.transform.gameObject, self.gameObject)

    self.MainCon = self.transform:FindChild("MainCon")
    self.mainObj = self.MainCon.gameObject
    local CloseBtn = self.MainCon:FindChild("CloseButton"):GetComponent(Button)
    CloseBtn.onClick:AddListener(function() self.model:CloseEquipStrengthMainUI() end)

    local tabGroup = self.MainCon:FindChild("TabButtonGroup").gameObject
    self.tab_btn1 = tabGroup.transform:GetChild(0):GetComponent(Button)
    self.tab_btn1.onClick:AddListener(function() self:tabChange(1) end)
    self.tab_btn2 = tabGroup.transform:GetChild(1):GetComponent(Button)
    self.tab_btn2.onClick:AddListener(function() self:tabChange(2) end)
    self.tab_btn3 = tabGroup.transform:GetChild(2):GetComponent(Button)
    self.tab_btn3.onClick:AddListener(function() self:tabChange(3) end)
    self.tab_btn4 = tabGroup.transform:GetChild(3):GetComponent(Button)
    self.tab_btn4.onClick:AddListener(function() self:tabChange(4) end)
    self.tab_btn5 = tabGroup.transform:GetChild(4):GetComponent(Button)
    self.tab_btn5.onClick:AddListener(function() self:tabChange(5) end)

    self.notify_point1 = self.tab_btn1.transform:FindChild("NotifyPoint").gameObject
    self.notify_point2 = self.tab_btn2.transform:FindChild("NotifyPoint").gameObject
    self.notify_point3 = self.tab_btn3.transform:FindChild("NotifyPoint").gameObject
    self.notify_point4 = self.tab_btn4.transform:FindChild("NotifyPoint").gameObject
    self.notify_point5 = self.tab_btn5.transform:FindChild("NotifyPoint").gameObject


    self.tab_btn_icon1 = self.tab_btn1.transform:FindChild("ImgIcon"):GetComponent(Image)
    self.tab_btn_icon2 = self.tab_btn2.transform:FindChild("ImgIcon"):GetComponent(Image)
    self.tab_btn_icon3 = self.tab_btn3.transform:FindChild("ImgIcon"):GetComponent(Image)
    self.tab_btn_icon4 = self.tab_btn4.transform:FindChild("ImgIcon"):GetComponent(Image)
    self.tab_btn_icon5 = self.tab_btn5.transform:FindChild("ImgIcon"):GetComponent(Image)

    self.tab_btn_icon1.sprite = self.assetWrapper:GetSprite(AssetConfig.guidetaskicon, tostring(40006))
    self.tab_btn_icon2.sprite = self.assetWrapper:GetSprite(AssetConfig.guidetaskicon, tostring(41021))
    self.tab_btn_icon3.sprite = self.assetWrapper:GetSprite(AssetConfig.guidetaskicon, tostring(40007))
    self.tab_btn_icon4.sprite = self.assetWrapper:GetSprite(AssetConfig.guidetaskicon, tostring(40008))

    if self.imgLoader == nil then
        self.imgLoader = SingleIconLoader.New(self.tab_btn_icon5.gameObject)
    end
    self.imgLoader:SetSprite(SingleIconType.Item, 20653)

    self.tab_btn_icon1.gameObject:SetActive(true)
    self.tab_btn_icon2.gameObject:SetActive(true)
    self.tab_btn_icon3.gameObject:SetActive(true)
    self.tab_btn_icon4.gameObject:SetActive(true)
    self.tab_btn_icon5.gameObject:SetActive(true)

    self.notify_point1:SetActive(false)
    self.notify_point2:SetActive(false)
    self.notify_point3:SetActive(false)
    self.notify_point4:SetActive(false)
    self.notify_point5:SetActive(false)

    self.is_open = true

    self.on_tab_point_update = function()
        self.notify_point3:SetActive(false)
        local state = self.model:check_has_equip_can_stone()
        self.notify_point3:SetActive(state)

        self.notify_point1:SetActive(false)
        state = self.model:check_has_equip_can_lev_up()
        self.notify_point1:SetActive(state)

        self.notify_point2:SetActive(false)
        state = self.model:check_rebuild_val_enough()
        self.notify_point2:SetActive(state)


        self.notify_point5:SetActive(false)
        state = self.model:check_has_equip_can_craft()
        self.notify_point5:SetActive(state)
    end

    self.checkGuidePoint = function() self:CheckGuidePoint() end
    EventMgr.Instance:AddListener(event_name.quest_update,self.checkGuidePoint)
    EventMgr.Instance:AddListener(event_name.equip_item_change, self.on_tab_point_update)
    EventMgr.Instance:AddListener(event_name.equip_build_resetval_update, self.on_tab_point_update)

    EventMgr.Instance:AddListener(event_name.backpack_item_change, self.on_tab_point_update)

    EventMgr.Instance:AddListener(event_name.role_level_change, self.on_role_change)
    self.on_role_change()

    if self.openArgs ~= nil and #self.openArgs > 0 then
        self:tabChange(self.openArgs[1])
    else
        self:tabChange(1)
    end

    self.on_tab_point_update()
end

function EquipStrengthMainWindow:switch_tab_btn(btn)
    self.tab_btn1.transform:FindChild("Select").gameObject:SetActive(false)
    self.tab_btn2.transform:FindChild("Select").gameObject:SetActive(false)
    self.tab_btn3.transform:FindChild("Select").gameObject:SetActive(false)
    self.tab_btn4.transform:FindChild("Select").gameObject:SetActive(false)
    self.tab_btn5.transform:FindChild("Select").gameObject:SetActive(false)
    self.tab_btn1.transform:FindChild("Normal").gameObject:SetActive(true)
    self.tab_btn2.transform:FindChild("Normal").gameObject:SetActive(true)
    self.tab_btn3.transform:FindChild("Normal").gameObject:SetActive(true)
    self.tab_btn4.transform:FindChild("Normal").gameObject:SetActive(true)
    self.tab_btn5.transform:FindChild("Normal").gameObject:SetActive(true)
    btn.transform:FindChild("Select").gameObject:SetActive(true)
    btn.transform:FindChild("Normal").gameObject:SetActive(false)
end

 -- 切换tab逻辑
function EquipStrengthMainWindow:tabChange(index)
    if self.is_open == false then
        return
    end
    self.curSelectedBtn = index
    if index == 1 then
        --锻造
        self:switch_tab_btn(self.tab_btn1)
        self:ShowFirst(true, 1)
        self:ShowSecond(false)
    elseif index == 2 then
        --重铸
        self:switch_tab_btn(self.tab_btn2)
        self:ShowFirst(true, 2)
        self:ShowSecond(false)
    elseif index == 3 then
        --宝石
        self:switch_tab_btn(self.tab_btn3)
        self:ShowFirst(false)
        self:ShowSecond(true)
    elseif index == 4 then
        --强化
        self:switch_tab_btn(self.tab_btn4)
        self:ShowFirst(true, 3)
        self:ShowSecond(false)
    elseif index == 5 then
        --点化
        self:switch_tab_btn(self.tab_btn5)
        self:ShowFirst(true, 4)
        self:ShowSecond(false)
    end

    if index ~= 3 then
        LuaTimer.Add(100, function() self:CheckGuide() end)
    else
        if self.guideScript ~= nil then
            self.guideScript:DeleteMe()
            self.guideScript = nil
        end
    end
    self:CheckGuidePoint()
end

function EquipStrengthMainWindow:ShowFirst(IsShow, index)
    if IsShow then
        self.cur_index = index
        if self.subFirst == nil then
            self.subFirst = EquipStrengthFirstTab.New(self)
            self.subFirst:Show()
        else
            self.subFirst:Show()
            self.subFirst:ShowCon(index)
        end
    else
        if self.subFirst ~= nil then
            self.subFirst:Hiden()
        end
    end
end

function EquipStrengthMainWindow:ShowSecond(IsShow)
    if IsShow then
        if self.subSecond == nil then
            self.subSecond = EquipStrengthSecondTab.New(self)
        else
            self.subSecond:update_left_list()
        end
        self.subSecond:Show()
    else
        if self.subSecond ~= nil then
            self.subSecond:Hiden()
        end
    end
end

--打开宝石快捷购买
-- array = {
--         [base_id] = {need = 0}
--     }
-- }
function EquipStrengthMainWindow:ShowStoneQuickBuy(array)
    -- if self.stone_quick_buy == nil then
    --     self.stone_quick_buy = EquipStrengthQuickBuyTab.New(self)
    -- else
    --     self.stone_quick_buy:update_content()
    -- end
    -- self.stone_quick_buy:Show()
    local base_ids = {}
    for base_id,v in pairs(array) do
        if base_id < 90000 and v ~= nil and v.need > 0 then
            table.insert(base_ids, {base_id = base_id})
        end
    end
    MarketManager.Instance:send12416({base_ids = base_ids}, function(priceByBaseid)
        if self.gameObject == nil then
            return
        end
        local baseidToPrice = {}
        for _,v in pairs(priceByBaseid) do
            baseidToPrice[v.base_id] = {}
            for key,value in pairs(v) do
                baseidToPrice[v.base_id][key] = value
            end
        end
        if self.buyConfirm == nil then
            self.buyConfirm = BuyConfirm.New()
        end
        self.buyConfirm:Show({baseidToPrice = baseidToPrice, baseidToNeed = array, clickCallback = self.onClick, content = self.content})
    end)
end

--关闭宝石快捷购买
function EquipStrengthMainWindow:CloseStoneQuickBuy()
    if self.stone_quick_buy ~= nil then
        self.stone_quick_buy:DeleteMe()
        self.stone_quick_buy = nil
    end
end


--打开英雄宝石快捷购买
function EquipStrengthMainWindow:ShowHeroStoneQuickBuy()
    if self.hero_stone_quick_buy == nil then
        self.hero_stone_quick_buy = EquipStrengthQuickBuyHeroTab.New(self)
    else
        self.hero_stone_quick_buy:update_content()
    end
    self.hero_stone_quick_buy:Show()
end

--关闭英雄宝石快捷购买
function EquipStrengthMainWindow:CloseHeroStoneQuickBuy()
    if self.hero_stone_quick_buy ~= nil then
        self.hero_stone_quick_buy:DeleteMe()
        self.hero_stone_quick_buy = nil
    end
end

function EquipStrengthMainWindow:CheckGuide()
    local questData = QuestManager.Instance.questTab[41261]
    if questData ~= nil and questData.finish == QuestEumn.TaskStatus.Doing and MainUIManager.Instance.priority == 2 then
        -- 只引导武器
        local weapon = BackpackManager.Instance.equipDic[1]
        if weapon.lev < 30 then
            -- 装备未到30级不播引导
            return
        end

        local hasStone = false
        for i,v in ipairs(weapon.attr) do
            if v.type == GlobalEumn.ItemAttrType.gem then
                hasStone = true
            end
        end

        if hasStone then
            -- 已经有镶嵌过宝石不播引导
            return
        end

        if self.guideScript ~= nil then
            self.guideScript:DeleteMe()
            self.guideScript = nil
        end

        self.guideScript = GuideEquipStoneTab.New(self)
        self.guideScript:Show()
    end
end

function EquipStrengthMainWindow:CheckGuidePoint()

    if MainUIManager.Instance.priority == 1 and self.curSelectedBtn ~= 4 then
        TipsManager.Instance:ShowGuide({gameObject = self.tab_btn4.gameObject, data = TI18N("点击进入强化界面"), forward = TipsEumn.Forward.Left})

        if self.guideEffect ~= nil then
            -- self.guideEffect.transform:SetParent(self.tab_btn4.transform)
            -- self.guideEffect.transform.localScale = Vector3(1,1,1)
            -- self.guideEffect.transform.localPosition = Vector3(23.5,0,-400)
            -- self.guideEffect.transform.localRotation = Quaternion.identity
            self.guideEffect:DeleteMe()
            self.guideEffect = nil
        end

        if self.guideEffect == nil then
            self.guideEffect = BaseUtils.ShowEffect(20104,self.tab_btn4.transform,Vector3(1,1,1), Vector3(23.5,0,-400))
        end

        self.guideEffect:SetActive(true)

    elseif MainUIManager.Instance.priority == 3 and self.curSelectedBtn ~= 1 then
        TipsManager.Instance:ShowGuide({gameObject = self.tab_btn1.gameObject, data = TI18N("点击进入锻造界面"), forward = TipsEumn.Forward.Left})

        if self.guideEffect ~= nil then
            -- self.guideEffect.transform:SetParent(self.tab_btn1.transform)
            -- self.guideEffect.transform.localScale = Vector3(1,1,1)
            -- self.guideEffect.transform.localPosition = Vector3(23.5,0,-400)
            -- self.guideEffect.transform.localRotation = Quaternion.identity
            self.guideEffect:DeleteMe()
            self.guideEffect = nil
        end
        if self.guideEffect == nil then
            self.guideEffect = BaseUtils.ShowEffect(20104,self.tab_btn1.transform,Vector3(1,1,1), Vector3(23.5,0,-400))
        end

        self.guideEffect:SetActive(true)
    elseif MainUIManager.Instance.priority == -1 and self.curSelectedBtn ~= 5 then
        TipsManager.Instance:ShowGuide({gameObject = self.tab_btn5.gameObject, data = TI18N("点击进入精炼界面"), forward = TipsEumn.Forward.Left})

        if self.guideEffect ~= nil then
            -- self.guideEffect.transform:SetParent(self.tab_btn5.transform)
            -- self.guideEffect.transform.localScale = Vector3(1,1,1)
            -- self.guideEffect.transform.localPosition = Vector3(23.5,0,-400)
            -- self.guideEffect.transform.localRotation = Quaternion.identity
            self.guideEffect:DeleteMe()
            self.guideEffect = nil
        end
        if self.guideEffect == nil then
            self.guideEffect = BaseUtils.ShowEffect(20104,self.tab_btn5.transform,Vector3(1,1,1), Vector3(23.5,0,-400))
        end

        self.guideEffect:SetActive(true)
    else
        if self.guideEffect ~= nil then
            self.guideEffect:SetActive(false)
        end
    end

end
