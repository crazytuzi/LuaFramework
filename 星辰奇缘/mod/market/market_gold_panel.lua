MarketGoldPanel = MarketGoldPanel or BaseClass(BasePanel)

local GameObject = _G["GameObject"]

function MarketGoldPanel:__init(parent)
    self.parent = parent
    self.model = parent.model

    self.resList = {
        {file = AssetConfig.market_gold_panel, type = AssetType.Main}
        , {file = AssetConfig.market_textures, type = AssetType.Dep}
    }

    self.gameObject = nil
    self.btnObjList = {}    -- 左侧主按钮列表
    self.subbtnList = {}    -- 左侧次按钮列表的列表
    self.boolBarBtnOpenList = {}
    -- self.parent.subPanel[1] = self
    self.openCatalg2List = {}
    self.itemObjTemplate = nil
    self.cellObjList = {}

    self.model.lastPosition = 0

    self.isRefrshData = false
    self.doSavePosition = true

    self.frozen = nil
    self.gridPanel = BackpackGridPanel.New(nil, true)

    self.gridPanel.onInitCompletedCallback = function()
        self.gridPanel.tabbedPanel.MoveEndEvent:Remove(self.gridPanelMoveListener)
        self.gridPanel.tabbedPanel.MoveEndEvent:Add(self.gridPanelMoveListener)
    end

    self.redListener = function() self:CheckRed() end
    self.levelListener = function() self:CheckOpen() end
    self.worldLevListener = function() self:CheckOpen() end

    self.updateRedPoint = self.redListener

    self.openListener = function() self:OnOpen() end
    self.hideListener = function() self:OnHide() end
    self.onReloadGoldMarketListener = function() self:OnReloadMarketGold() end
    self.OnOpenEvent:Add(self.openListener)
    self.OnHideEvent:Add(self.hideListener)
    self.timerId = nil
end

function MarketGoldPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.market_gold_panel))
    self.gameObject.name = "GoldMarket"
    self.gameObject:SetActive(true)

    self.gameObject.transform:SetParent(self.parent.gameObject.transform:Find("Main"))

    self.gameObject.transform.localPosition = Vector3(0, 0, 0)
    self.gameObject.transform.localScale = Vector3(1, 1, 1)

    local role_info = RoleManager.Instance
    local role_assets = RoleManager.Instance.RoleData
    local model = self.model

    self.subIndex = {}
    local tabs = DataMarketGold.data_market_gold_tab
    for i=1,DataMarketGold.data_market_gold_tab_length do
        if self.subIndex[tabs[i].catalg_1] == nil then
            self.subIndex[tabs[i].catalg_1] = {}
        end

        if tabs[i].world_lev <= role_info.world_lev then
            table.insert(self.subIndex[tabs[i].catalg_1], tabs[i].catalg_2)
        end
    end

    local btnList = DataMarketGold.data_market_gold_tab
    local btnContainer = self.gameObject.transform:Find("Bar/mask/Container")
    local btnTemplate = btnContainer:Find("Button").gameObject
    btnTemplate:SetActive(false)
    local subbtnTemplate = btnContainer:Find("SubButton").gameObject
    subbtnTemplate:SetActive(false)

    local item = nil
    for _,v in pairs(btnList) do
        -- if v.world_lev <= role_info.world_lev then
            item = self.btnObjList[v.catalg_1]
            self.boolBarBtnOpenList[v.catalg_1] = false
            if item == nil then
                self.btnObjList[v.catalg_1] = GameObject.Instantiate(btnTemplate)
                item = self.btnObjList[v.catalg_1]
                item.transform:SetParent(btnContainer)
                item.transform.localScale = Vector3.one
                item.name = "Btn"..v.catalg_1
                self.subbtnList[v.catalg_1] = {}

                self.openCatalg2List[v.catalg_1] = v.catalg_2

                item.transform:Find("MainButton"):GetComponent(Button).onClick:AddListener(function ()
                    model.lastGoldMain = model.currentGoldMain
                    model.currentGoldMain = v.catalg_1
                    if model.lastGoldMain ~= model.currentGoldMain then
                        model.currentGoldSub = self.subIndex[model.currentGoldMain][1]
                        model.goldChosenBaseId = nil
                        model.selectPos = nil
                    end
                    model.targetBaseId = nil
                    self:UpdateMainButton()
                    self:UpdateSubButton()
                    self:ReloadBuyPanel()
                end)
                item.transform:Find("MainButton/Text"):GetComponent(Text).text = v.catalg_1_name
                item.transform:Find("MainButton/Image"):GetComponent(Image).sprite = self.assetWrapper:GetSprite(AssetConfig.market_textures, v.icon)
            end

            local subbtnList = self.subbtnList[v.catalg_1]
            subbtnList[v.catalg_2] = GameObject.Instantiate(subbtnTemplate)
            local subbtn = subbtnList[v.catalg_2]
            subbtn.transform:SetParent(item.transform)
            subbtn.transform.localScale = Vector3.one
            subbtn.name = "sub_"..v.catalg_1.."_"..v.catalg_2
            subbtn:GetComponent(Button).onClick:AddListener(function ()
                model.lastGoldSub = model.currentGoldSub
                model.currentGoldSub = v.catalg_2
                model.targetBaseId = nil
                model.goldChosenBaseId = nil
                model.selectPos = nil
                model.lastPosition = 0
                self:UpdateSubButton()
                self:ReloadBuyPanel()
            end)
            subbtn.transform:Find("Text"):GetComponent(Text).text = v.catalg_2_name

            item:SetActive(true)
        -- end
    end

    -- self:OnOpen()

    self.buyPanelContainer = self.gameObject.transform:Find("BuyPanel/mask/Scroll/Container")
    self.buyPanelContainerRect = self.buyPanelContainer:GetComponent(RectTransform)
    self.vScroll = self.gameObject.transform:Find("BuyPanel/mask/Scroll"):GetComponent(ScrollRect)
    self.itemObjTemplate = self.buyPanelContainer:Find("Item").gameObject
    self.itemObjTemplate:SetActive(false)

    self.setting_data = {
       item_list = self.cellObjList--放了 item类对象的列表
       ,data_list = {} --数据列表
       ,item_con = self.buyPanelContainer  --item列表的父容器
       ,single_item_height = self.itemObjTemplate:GetComponent(RectTransform).sizeDelta.y --一条item的高度
       ,item_con_last_y = self.buyPanelContainer:GetComponent(RectTransform).anchoredPosition.y --父容器改变时上一次的y坐标
       ,scroll_con_height = self.vScroll:GetComponent(RectTransform).sizeDelta.y --显示区域的高度
       ,item_con_height = 0 --item列表的父容器高度
       ,scroll_change_count = 0 --父容器滚动累计改变值
       ,data_head_index = 0  --数据头指针
       ,data_tail_index = 0 --数据尾指针
       ,item_head_index = 1 --item列表头指针
       ,item_tail_index = 0 --item列表尾指针
    }
    self.vScroll.onValueChanged:AddListener(function()
        if self.doSavePosition then
            self.model.lastPosition = self.buyPanelContainerRect.anchoredPosition.y
        end
        BaseUtils.on_value_change(self.setting_data)
    end)
    self.boxYLayout = LuaBoxLayout.New(self.buyPanelContainer, {axis = BoxLayoutAxis.Y,spacing = 10})
    local obj = nil
    for i=1,15 do
        obj = GameObject.Instantiate(self.itemObjTemplate)
        obj.name = tostring(i)
        self.boxYLayout:AddCell(obj)
        obj:SetActive(false)
        self.cellObjList[i] = MarketGoldItem.New(self.model, obj, self.assetWrapper)
    end

    self:UpdateMainButton()
    self:UpdateSubButton()
    self:ReloadBuyPanel()

    local sellPanel = self.gameObject.transform:Find("SellPanel")

    -- 加载背包格子
    self.gridPanel.parent = sellPanel:Find("bg/Container").gameObject

    self.buyButton = sellPanel:Find("BuyButton"):GetComponent(CustomButton)
    self.noticeBtn = sellPanel:Find("Notice"):GetComponent(Button)
    self.frozen = FrozenButton.New(self.buyButton.gameObject, {})
    self.buyButton.onClick:AddListener(function () self:OnBuy() end)
    self.buyButton.onHold:AddListener(function() self:OnNumberpad() end)
    self.buyButton.onDown:AddListener(function() self:OnDown() end)
    self.buyButton.onUp:AddListener(function() self:OnUp() end)
    self.assetGoldText = sellPanel:Find("Image/GoldVal"):GetComponent(Text)
    self.assetGoldText.color = Color(232/255, 250/255, 255/255, 1)
    self.assetGoldText.text = tostring(role_assets.gold_bind)
    self.addGoldButton = sellPanel:Find("Image/AddGoldBtn"):GetComponent(Button)
    self.addGoldButton.onClick:AddListener(function () WindowManager.Instance:OpenWindowById(WindowConfig.WinID.exchange_window, 1) end)
    self.noticeBtn.onClick:AddListener(function() self:OnNotice() end)
    local toggleGroup = self.gameObject.transform:Find("SellPanel/ToggleGroup")
    self.toggle = {nil, nil, nil}
    local page = math.ceil(BackpackManager.Instance.volumeOfItem/25)
    for i=1, page do
        local obj = nil
        if i <= toggleGroup.childCount then
            obj = toggleGroup:GetChild(i - 1)
            self.toggle[i] = obj:GetComponent(Toggle)
        else
            obj = GameObject.Instantiate(self.toggle[1].gameObject)
            obj.transform:SetParent(toggleGroup)
            obj.transform.localScale = Vector3.one
            self.toggle[i] = obj:GetComponent(Toggle)
            self.toggle[i].isOn = false
        end
    end

    local title = sellPanel:Find("title")
    self.btnPageTabList = {nil, nil, nil}
    for i=1,page do
        self.btnPageTabList[i] = title:Find("PageTab"..i)
        if self.btnPageTabList[i] ~= nil then
            self.btnPageTabList[i] = self.btnPageTabList[i]:GetComponent(Button)
            self.btnPageTabList[i].onClick:AddListener(function ()
                for j=1,3 do
                    self.btnPageTabList[j].gameObject:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton5")
                    -- self.btnPageTabList[j].transform.localScale = Vector3(1, 1, 1)
                end
                self.btnPageTabList[i].gameObject:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton7")
                -- self.btnPageTabList[i].transform.localScale = Vector3(1, 1, 1)

                self.gridPanel.tabbedPanel:TurnPage(i)
                self.gridPanelMoveListener()
            end)
        end
    end

    if self.gridPanelMoveListener == nil then
        self.gridPanelMoveListener = function ()
            for j=1,3 do
                self.toggle[j].isOn = false
            end
            if self.toggle[self.gridPanel.tabbedPanel.currentPage] ~= nil then
                self.toggle[self.gridPanel.tabbedPanel.currentPage].isOn = true
            end
            for j=1,3 do
                self.btnPageTabList[j].gameObject:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton5")
                -- self.btnPageTabList[j].transform.localScale = Vector3(1, 1, 1)
            end
            if self.btnPageTabList[self.gridPanel.tabbedPanel.currentPage] ~= nil then
                self.btnPageTabList[self.gridPanel.tabbedPanel.currentPage].gameObject:GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton7")
            end
        end
    end

    self.numberpadSetting = {               -- 弹出小键盘的设置
        gameObject = self.buyButton.gameObject,
        min_result = 1,
        max_by_asset = 20,
        max_result = 20,
        textObject = nil,
        show_num = false,
        returnKeep = true,
        funcReturn = function(num) model.goldBuyNum = num if self.frozen.enabled == true then self:OnBuy() end model.goldBuyNum = 1 end,
        callback = nil,
        show_num = true,
        returnText = TI18N("购买"),
    }

    self.OnOpenEvent:Fire()
    self.gridPanel:Show()
    self.noticeBtn.gameObject.transform:SetAsLastSibling()
end

function MarketGoldPanel:__delete()
    if self.timerId ~= nil then
        LuaTimer.Delete(self.timerId)
        self.timerId = nil
    end
    self.OnHideEvent:Fire()
    self.model.lastSelectObj = nil
    if self.frozen ~= nil then
        self.frozen:DeleteMe()
        self.frozen = nil
    end
    if self.boxYLayout ~= nil then
        self.boxYLayout:DeleteMe()
        self.boxYLayout = nil
    end
    if self.gridPanel ~= nil then
        self.gridPanel:DeleteMe()
        self.gridPanel = nil
    end
    if self.cellObjectList ~= nil then
        for k,v in pairs(self.cellObjectList) do
            v:DeleteMe()
        end
        self.cellObjList = nil
    end
    self.setting_data = nil
    GameObject.DestroyImmediate(self.gameObject)
    self.OnOpenEvent:Remove(self.openListener)
    self.OnHideEvent:Remove(self.hideListener)
    self.gameObject = nil
    self.parent = nil
    self.isUp = nil
    self:AssetClearAll()
end

function MarketGoldPanel:OnOpen()

    local noSub = true
    local model = self.model
    if model.currentGoldSub ~= nil then
        for k,v in pairs(self.subIndex[model.currentGoldMain]) do
            if v == model.currentGoldSub then
                noSub = false
                break
            end
        end
    end
    if noSub then
        model.currentGoldSub = self.subIndex[model.currentGoldMain][1]
    end

    self:CheckOpen()

    self:UpdateMainButton()
    self:UpdateSubButton()
    self:ReloadBuyPanel()

    self:RemoveListeners()
    -- MarketManager.Instance.onReloadGoldMarket:AddListener(self.onReloadGoldMarketListener)
    MarketManager.Instance.onUpdateRed:AddListener(self.redListener)
    EventMgr.Instance:AddListener(event_name.world_lev_change, self.worldLevListener)
    EventMgr.Instance:AddListener(event_name.role_level_change, self.levelListener)
    EventMgr.Instance:AddListener(event_name.market_gold_update, self.onReloadGoldMarketListener)
end

function MarketGoldPanel:OnHide()
    self:RemoveListeners()
    local roleData = RoleManager.Instance.RoleData
    if self.boolBarBtnOpenList ~= nil then
        for k,_ in pairs(self.boolBarBtnOpenList) do
            self.boolBarBtnOpenList[k] = false
        end
    end
    self.model.selectPos = nil
    self.model.goldChosenBaseId = nil
    self.model.lastGoldTime = nil
    if self.arrowEffect ~= nil and not BaseUtils.isnull(self.arrowEffect.gameObject) then
        self.arrowEffect.gameObject:SetActive(false)
    end

    for k1,list in pairs(MarketManager.Instance.redPointDic[1]) do
        if list ~= nil then
            for k2,_ in pairs(list) do
                list[k2] = false
                PlayerPrefs.SetInt(BaseUtils.Key(roleData.id, roleData.platform, roleData.zone_id, MarketManager.Instance.marketLocalSave, k1, k2), BaseUtils.BASE_TIME)
            end
        end
    end

    MarketManager.Instance.onUpdateRed:Fire()
end

-- 更新左边类型
function MarketGoldPanel:UpdateMainButton()
    local model = self.parent.model
    local catalg_1 = model.lastGoldMain
    local mainBtn = nil
    local arrow1 = nil
    local arrow2 = nil
    local subbtn = nil

    if catalg_2 == 0 then
        catalg_2 = self.openCatalg2List[catalg_1]
    end

    if catalg_1 ~= nil then
        mainBtn = self.btnObjList[catalg_1].transform:Find("MainButton").gameObject
        mainBtn.transform:Find("Arrow1").gameObject:SetActive(false)
        mainBtn.transform:Find("Arrow2").gameObject:SetActive(true)
        if catalg_1 ~= model.currentGoldMain then
            self.boolBarBtnOpenList[catalg_1] = false
        end
    else
        mainBtn = self.btnObjList[model.currentGoldMain].transform:Find("MainButton").gameObject
        mainBtn.transform:Find("Arrow1").gameObject:SetActive(true)
        mainBtn.transform:Find("Arrow2").gameObject:SetActive(false)
        self.boolBarBtnOpenList[model.currentGoldMain] = false
    end
    catalg_1 =  model.currentGoldMain
    self.boolBarBtnOpenList[catalg_1] = not self.boolBarBtnOpenList[catalg_1]
    mainBtn = self.btnObjList[catalg_1].transform:Find("MainButton").gameObject
    mainBtn.transform:Find("Arrow1").gameObject:SetActive(self.boolBarBtnOpenList[catalg_1])
    mainBtn.transform:Find("Arrow2").gameObject:SetActive(not self.boolBarBtnOpenList[catalg_1])

    for k,v in pairs(self.btnObjList) do
        local image = v.transform:Find("MainButton/Bg"):GetComponent(Image)
        image.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton8")
        v.transform:Find("MainButton/Text"):GetComponent(Text).color = ColorHelper.DefaultButton8
        local red = false
        if MarketManager.Instance.redPointDic[1][k] ~= nil then
            for _,v in pairs(MarketManager.Instance.redPointDic[1][k]) do
                red = red or (v == true)
            end
        end
        v.transform:Find("MainButton/NotifyPoint").gameObject:SetActive(red)
    end
    if self.boolBarBtnOpenList[catalg_1] == true then
        self.btnObjList[catalg_1].transform:Find("MainButton/Bg"):GetComponent(Image).sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "DefaultButton9")
        self.btnObjList[catalg_1].transform:Find("MainButton/Text"):GetComponent(Text).color = ColorHelper.DefaultButton9
    end
end

function MarketGoldPanel:UpdateSubButton()
    local model = self.parent.model
    local catalg_1 = model.currentGoldMain
    local catalg_2 = model.currentGoldSub
    if catalg_2 == 0 then
        catalg_2 = self.openCatalg2List[catalg_1]
    end
    local subbtnList = self.subbtnList[catalg_1]

    local count = 0
    for k,v in pairs(subbtnList) do
        if v ~= nil then
            count = count + 1
        end
    end
    for k,_ in pairs(self.btnObjList) do
        for _,v in pairs(self.subbtnList[k]) do
            -- v:SetActive(self.boolBarBtnOpenList[k])
            v:SetActive(false)
        end
    end

    local arrow1 = self.btnObjList[catalg_1].transform:Find("MainButton/Arrow1")

    if count > 1 then
        MarketManager.Instance.redPointDic[1][catalg_1] = MarketManager.Instance.redPointDic[1][catalg_1] or {}
        for k,v in pairs(subbtnList) do
            v:SetActive(self.boolBarBtnOpenList[catalg_1] and model.goldOpenTab[catalg_1][k])
            -- v:SetActive(true)
            if k == catalg_2 then
                v.transform:Find("Select").gameObject:SetActive(true)
                v.transform:Find("Text"):GetComponent(Text).color = ColorHelper.DefaultButton11
            else
                v.transform:Find("Select").gameObject:SetActive(false)
                v.transform:Find("Text"):GetComponent(Text).color = ColorHelper.DefaultButton10
            end
            v.transform:Find("NotifyPoint").gameObject:SetActive(MarketManager.Instance.redPointDic[1][catalg_1][k] == true)
        end
    else

    end
end

function MarketGoldPanel:ReloadBuyPanel()
    self:UpdateBuyPanel()

    local model = self.model
    local catalg_1 = model.currentGoldMain
    local catalg_2 = model.currentGoldSub
    if catalg_2 == 0 then
        catalg_2 = self.openCatalg2List[catalg_1]
        model.currentGoldSub = catalg_2
    end
    MarketManager.Instance:send12400(catalg_1, catalg_2)
end

-- 更新购买列表
function MarketGoldPanel:UpdateBuyPanel()
    local model = self.parent.model
    local catalg_1 = model.currentGoldMain
    local catalg_2 = model.currentGoldSub
    local roleData = RoleManager.Instance.RoleData

    MarketManager.Instance.onUpdateRed:Fire()
    MarketManager.Instance.redPointDic[1][catalg_1] = MarketManager.Instance.redPointDic[1][catalg_1] or {}

    LuaTimer.Add(500, function()
            MarketManager.Instance.redPointDic[1][catalg_1][catalg_2] = false
        end)

    PlayerPrefs.SetInt(BaseUtils.Key(roleData.id, roleData.platform, roleData.zone_id, MarketManager.Instance.marketLocalSave, catalg_1, catalg_2), BaseUtils.BASE_TIME)

    if catalg_2 == 0 then
        catalg_2 = self.openCatalg2List[catalg_1]
        model.currentGoldSub = catalg_2
    end

    local itemList = model.goldItemList
    itemList[catalg_1] = itemList[catalg_1] or {}
    -- if itemList[catalg_1][catalg_2] == nil then
    --     --return
    -- end

    itemList = itemList[catalg_1][catalg_2] or {}
    if model.targetBaseId ~= nil then
        model.selectPos = nil
        for i=1,#itemList do
            if itemList[i].base_id == model.targetBaseId then
                model.selectPos = i
                break
            end
        end

        if model.selectPos ~= nil then
            model.lastPosition = (model.selectPos - 1) * 42
            -- if self.buyPanelContainerRect.sizeDelta.y - model.lastPosition < 387 then
            --     model.lastPosition = self.buyPanelContainerRect.sizeDelta.y - 387
            -- end
            if self.buyPanelContainerRect.sizeDelta.y > 387 then
                if self.buyPanelContainerRect.sizeDelta.y - model.lastPosition < 387 then
                    model.lastPosition = self.buyPanelContainerRect.sizeDelta.y - 387
                end
            else
                model.lastPosition = 0
            end

            model.goldChosenBaseId = model.targetBaseId
        end
    end

    self.setting_data.data_list = itemList
    BaseUtils.refresh_circular_list(self.setting_data)

    self.doSavePosition = false
    self.vScroll.onValueChanged:Invoke({0, 1})
    self.buyPanelContainerRect.anchoredPosition = Vector2(0, model.lastPosition)
    self.doSavePosition = true
    self.vScroll.onValueChanged:Invoke({0, 1 - model.lastPosition / self.buyPanelContainerRect.sizeDelta.y})

    self.isRefrshData = false
end

function MarketGoldPanel:RoleAssetsListener()
    if self.gameObject ~= nil and self.assetGoldText ~= nil then
        self.assetGoldText.text = tostring(RoleManager.Instance.RoleData.gold_bind)
    end
end

function MarketGoldPanel:OnReloadMarketGold()
    local model = self.model
    model.goldChosenBaseId = nil
    model.selectPos = nil
    model.lastSelectObj = nil
    self:UpdateBuyPanel()
end

function MarketGoldPanel:RemoveListeners()
    MarketManager.Instance.onReloadGoldMarket:RemoveListener(self.onReloadGoldMarketListener)
    MarketManager.Instance.onUpdateRed:RemoveListener(self.redListener)
    EventMgr.Instance:RemoveListener(event_name.world_lev_change, self.worldLevListener)
    EventMgr.Instance:RemoveListener(event_name.role_level_change, self.levelListener)
    EventMgr.Instance:RemoveListener(event_name.market_gold_update, self.onReloadGoldMarketListener)
end

function MarketGoldPanel:CheckRed()
    for k,v in pairs(self.btnObjList) do
        local red = false
        if MarketManager.Instance.redPointDic[1][k] ~= nil then
            for _,v in pairs(MarketManager.Instance.redPointDic[1][k]) do
                red = red or (v == true)
            end
        end
        v.transform:Find("MainButton/NotifyPoint").gameObject:SetActive(red)
    end
end

function MarketGoldPanel:OnBuy()
    local model = self.model
    local chosenId = model.goldChosenBaseId
    local margin = 0
    local price = 0

    -- if model.lastGoldTime ~= nil then
    --     if BaseUtils.BASE_TIME - model.lastGoldTime < 3 then
    --         self:OnNumberpad()
    --         model.lastGoldTime = nil
    --         return
    --     end
    -- end
    -- model.lastGoldTime = BaseUtils.BASE_TIME

    model.lastPosition = self.buyPanelContainerRect.anchoredPosition.y
    if chosenId ~= nil and model.goldItemList[model.currentGoldMain] ~= nil and model.goldItemList[model.currentGoldMain][model.currentGoldSub] ~= nil then
        self.isRefrshData = true
        local itemlist = model.goldItemList[model.currentGoldMain][model.currentGoldSub]
        for i,v in ipairs(itemlist) do
            if v.base_id == chosenId then
                margin = v.margin
                price = v.cur_price
                break
            end
        end
        if margin >= 1100 and self.initConfirm ~= true and price < DataMarketGold.data_market_gold_item[chosenId].max_price then
            local confirmData = NoticeConfirmData.New()
            confirmData.type = ConfirmData.Style.Normal
            confirmData.content = TI18N("目前该物品涨幅超过10%,继续购买将以130%的价格支付,是否继续?")
            confirmData.sureSecond = -1
            confirmData.cancelSecond = -1
            confirmData.sureLabel = TI18N("确认")
            confirmData.cancelLabel = TI18N("取消")
            confirmData.sureCallback = function()
                self.initConfirm = true
                self.frozen:OnClick()
                MarketManager.Instance:send12401(chosenId, model.goldBuyNum)
            end
            NoticeManager.Instance:ConfirmTips(confirmData)
        else
            self.frozen:OnClick()
            MarketManager.Instance:send12401(chosenId, model.goldBuyNum)
        end
        -- model.targetBaseId = chosenId
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("请选择要购买的商品"))
    end
    -- print(model.targetBaseId)
end

function MarketGoldPanel:OnNumberpad()
    local model = self.model
    if model.goldChosenBaseId == nil then
        NoticeManager.Instance:FloatTipsByString(TI18N("请选择需要购买的物品"))
    else
        local maxValue = DataItem.data_get[model.goldChosenBaseId].overlap
        if maxValue > 20 then
            maxValue = 20
        end
        self.numberpadSetting.max_result = maxValue
        NumberpadManager.Instance:set_data(self.numberpadSetting)
    end
end

function MarketGoldPanel:OnNotice()
    local tipsText = {
        TI18N("<color='#ffff00'>长按[购买]</color>可批量购买"),
    }
    TipsManager.Instance:ShowText({gameObject = self.noticeBtn.gameObject, itemData = tipsText})
end

function MarketGoldPanel:OnDown()
    self.isUp = false
    LuaTimer.Add(150, function()
        if self.isUp ~= false then
            return
        end
        if self.arrowEffect == nil then
            self.arrowEffect = BibleRewardPanel.ShowEffect(20009, self.buyButton.gameObject.transform, Vector3(1, 1, 1), Vector3(0, 61, -400))
        else
            if not BaseUtils.is_null(self.arrowEffect.gameObject) then
                self.arrowEffect.gameObject:SetActive(false)
                self.arrowEffect.gameObject:SetActive(true)
            end
        end
    end)
end

function MarketGoldPanel:OnUp()
    self.isUp = true
    if self.arrowEffect ~= nil then
        self.arrowEffect:DeleteMe()
        self.arrowEffect = nil
    end
end

function MarketGoldPanel:CheckOpen()
    MarketManager.Instance:CheckOpen()
    local model = self.model
    for main,item in pairs(self.btnObjList) do
        local bool = false
        local sublist = self.subbtnList[main]
        for k,v in pairs(model.goldOpenTab[main]) do
            sublist[k].gameObject:SetActive(v)
            bool = bool or v
        end
        item.gameObject:SetActive(bool)
    end
end

