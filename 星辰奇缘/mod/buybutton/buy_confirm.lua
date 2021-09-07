-- @auther 黄耀聪
-- 新版快捷购买

BuyConfirm = BuyConfirm or BaseClass(BasePanel)

function BuyConfirm:__init()
    self.name = "BuyConfirm"

    self.resList = {
        {file = AssetConfig.buy_confirm, type = AssetType.Main}
        , {file = AssetConfig.dropicon, type = AssetType.Dep}
        , {file = AssetConfig.buy_textures, type = AssetType.Dep}
    }

    self.itemList = {}
    self.gainList = {}
    self.numList = {}
    self.visitedList = {}

    self.priceListener = function() self:ReloadCount() end
    self.assetsListener = function() self:UpdateAssets() end
    self.doItFunc = function() self:DoIt() end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function BuyConfirm:__delete()
    self.OnHideEvent:Fire()
    if self.confirmData ~= nil then
        self.confirmData:DeleteMe()
        self.confirmData = nil
    end
    if self.tabbedPanel ~= nil then
        self.tabbedPanel:DeleteMe()
        self.tabbedPanel = nil
    end
    if self.assetLoader ~= nil then
        self.assetLoader:DeleteMe()
        self.assetLoader = nil
    end
    if self.gainLayout ~= nil then
        self.gainLayout:DeleteMe()
        self.gainLayout = nil
    end
    if self.headerLayout ~= nil then
        self.headerLayout:DeleteMe()
        self.headerLayout = nil
    end
    if self.itemList ~= nil then
        for _,v in pairs(self.itemList) do
            v.slot:DeleteMe()
            v.descExt:DeleteMe()
        end
        self.itemList = nil
    end
    if self.gainList ~= nil then
        for _,v in pairs(self.gainList) do
            v.iconLoader:DeleteMe()
        end
        self.gainList = nil
    end
    if self.starGoldLoader ~= nil then
        self.starGoldLoader:DeleteMe()
        self.starGoldLoader = nil
    end
    if self.descExt ~= nil then
        self.descExt:DeleteMe()
        self.descExt = nil
    end
    self:AssetClearAll()
end

function BuyConfirm:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.buy_confirm))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    self.transform = t
    UIUtils.AddUIChild(TipsManager.Instance.model.tipsCanvas, self.gameObject)

    local main = t:Find("Main")
    self.closeBtn = main:Find("Close"):GetComponent(Button)
    self.header = main:Find("Header")
    self.headContainer = self.header:Find("Container")
    self.headerCloner = self.header:Find("Item").gameObject
    self.headerWidth = self.headerCloner.transform.sizeDelta.x

    self.body = main:Find("Body")
    local gainWay = main:Find("Body/GainWay")
    self.gainLayout = LuaBoxLayout.New(gainWay:Find("Scroll/Container"), {axis = BoxLayoutAxis.Y, cspacing = 0, border = 10})
    self.gainCloner = gainWay:Find("Scroll/Cloner").gameObject

    local valuation = main:Find("Body/Valuation")
    self.itemNameText = valuation:Find("Title/Text"):GetComponent(Text)
    self.numberText = valuation:Find("Number/Text"):GetComponent(Text)
    self.numberBg = valuation:Find("Number")
    self.numberButton = self.numberBg:GetComponent(Button) or self.numberBg.gameObject:AddComponent(Button)
    self.numberButton.onClick:AddListener(function() self:OnNumberpad() end)
    self.minusBtn = valuation:Find("Minus"):GetComponent(Button)
    self.addBtn = valuation:Find("Add"):GetComponent(Button)
    self.valueText = valuation:Find("Value/Text"):GetComponent(Text)
    self.assetLoader = SingleIconLoader.New(valuation:Find("Value/Assets").gameObject)
    self.button = valuation:Find("Button"):GetComponent(Button)
    self.buttonText = valuation:Find("Button/Text"):GetComponent(Text)
    self.leftBtn = main:Find("Body/Left"):GetComponent(Button)
    self.rightBtn = main:Find("Body/Right"):GetComponent(Button)
    self.leftNormal = main:Find("Body/Left/Normal").gameObject
    self.leftSelect = main:Find("Body/Left/Select").gameObject
    self.rightNormal = main:Find("Body/Right/Normal").gameObject
    self.rightSelect = main:Find("Body/Right/Select").gameObject
    self.toggle = main:Find("Toggle"):GetComponent(Button)
    self.toggleTick = main:Find("Toggle/Tick").gameObject

    self.top = t:Find("Top")
    self.starGoldLoader = SingleIconLoader.New(self.top:Find("StarGold").gameObject)
    self.assetTab = {
        [KvData.assets.coin] = {text = self.top:Find("Text1"):GetComponent(Text), obj = self.top:Find("Coin").gameObject},
        [KvData.assets.gold_bind] = {text = self.top:Find("Text2"):GetComponent(Text), obj = self.top:Find("GoldBind").gameObject},
        [KvData.assets.gold] = {text = self.top:Find("Text3"):GetComponent(Text), obj = self.top:Find("Gold").gameObject},
        [KvData.assets.star_gold] = {text = self.top:Find("Text4"):GetComponent(Text), obj = self.top:Find("StarGold").gameObject},
    }

    self.main = main

    self.closeBtn.onClick:AddListener(function() self:OnClose() end)
    t:Find("Panel"):GetComponent(Button).onClick:AddListener(function() self:OnClose() end)
    self.addBtn.onClick:AddListener(function() self:OnAdd() end)
    self.minusBtn.onClick:AddListener(function() self:OnMinus() end)
    self.button.onClick:AddListener(function() self:OnClick() end)
    self.header:GetComponent(ScrollRect).onValueChanged:AddListener(function() self:ValueChange() end)
    self.leftBtn.onClick:AddListener(function() self:OnLeft() end)
    self.rightBtn.onClick:AddListener(function() self:OnRight() end)
    self.toggle.onClick:AddListener(function() self:OnToggle() end)
    self.starGoldLoader:SetSprite(SingleIconType.Item, 90026)

    self.leftBtn.gameObject:SetActive(false)
    self.rightBtn.gameObject:SetActive(false)


    self.updatePrice = function() self:OnUpdatePrice() end
    self.max_result = 100
     self.numberpadSetting = {               -- 弹出小键盘的设置
        gameObject = self.numberButton.gameObject,
        min_result = 1,
        max_by_asset = self.max_result,
        max_result = self.max_result,
        textObject = self.numberText,
        show_num = false,
        funcReturn = function() NoticeManager.Instance:FloatTipsByString(TI18N("请确认购买")) end,
        callback = self.updatePrice
    }
end

function BuyConfirm:OnUpdatePrice()
    self.numList[self.index] = NumberpadManager.Instance:GetResult()
    self:ReloadCount()
end

-- 点出数字小键盘
function BuyConfirm:OnNumberpad()
    local max_result = 200
    self.numberpadSetting.max_result = max_result
    self.numberpadSetting.max_by_asset = max_result
    NumberpadManager.Instance:set_data(self.numberpadSetting)
end

function BuyConfirm:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function BuyConfirm:OnOpen()
    self:RemoveListeners()
    EventMgr.Instance:AddListener(event_name.role_asset_change, self.priceListener)
    EventMgr.Instance:AddListener(event_name.role_asset_change, self.assetsListener)

    if self.openArgs == nil then
        Log.Error(string.format("快捷购买确认框参数不能为空！！！！\n", debug.traceback()))
        return
    end

    self.baseidToPrice = self.openArgs.baseidToPrice
    self.baseidToNeed = self.openArgs.baseidToNeed
    self.clickCallback = self.openArgs.clickCallback
    self.content = self.openArgs.content
    self.toggleKey = self.openArgs.key
    self.protoId = self.openArgs.protoId

    self.buttonText.text = TI18N("购 买")


    self.index = 1
    self.baseIdList = {}
    for base_id,v in pairs(self.baseidToNeed) do
        if v ~= nil
            and base_id < 90000
            and (self.baseidToPrice[base_id] ~= nil
                and (self.baseidToPrice[base_id].assets ~= KvData.assets.gold or self.baseidToPrice[base_id].assets ~= KvData.assets.star_gold or self.baseidToPrice[base_id].assets ~= KvData.assets.star_gold_or_gold)
                )
            and (BuyManager.Instance.autoBuyList[self.toggleKey] == nil or BuyManager.Instance.autoBuyList[self.toggleKey][base_id] ~= true)
            then
            table.insert(self.baseIdList, base_id)
        end
    end

    self:ReloadHeader()
    self.visitedList = {}
    self.numList = {}
    -- self.tabbedPanel:TurnPage(self.index)

    self:Update()
    self:UpdateAssets()

    self.transform:SetAsLastSibling()
end

function BuyConfirm:OnHide()
    -- self.tabbedPanel:TurnPage(1)
    self:RemoveListeners()
end

function BuyConfirm:Update()
    local base_id = self.baseIdList[self.index]
    local cfgData = DataItem.data_get[base_id]
    local needData = self.baseidToNeed[base_id]
    local priceData = self.baseidToPrice[base_id]


    self.headContainer.anchoredPosition = Vector2(-(self.index - 1) * self.headerWidth, 0)
    if BuyManager.Instance.autoBuyList[self.toggleKey] ~= nil then
        self.toggleTick:SetActive(BuyManager.Instance.autoBuyList[self.toggleKey][base_id]== true)
    end

    if priceData == nil then
        Log.Error(string.format("%s 有一个base=%s的物品没有请求到价格，具体功能是这个————%s，全部物品价格列表是 %s\n%s", tostring(self.index), base_id, self.toggleKey, BaseUtils.serialize(self.baseidToPrice, "", false, 5), debug.traceback()))
        return
    end

    for assets,id in pairs(KvData.assets) do
        if priceData.assets == id then
            self.assets = assets
            break
        end
    end

    self.singlePrice = priceData.price
    self.numList[self.index] = self.numList[self.index] or needData.need
    self.itemNameText.text = cfgData.name
    self.assetLoader:SetSprite(SingleIconType.Item, priceData.assets)

    self.header.sizeDelta = Vector2(self.headerWidth, self.itemList[self.index].height)

    self:ReloadGainway(base_id)
    self:ReloadCount()

    self.visitedList[base_id] = true

    self.body.transform.anchoredPosition = Vector2(0, self.header.anchoredPosition.y - self.header.sizeDelta.y - 5)

    if self.toggleKey == nil then
        self.main.sizeDelta = Vector2(518, self.body.sizeDelta.y - self.body.anchoredPosition.y + 15)
        self.toggle.gameObject:SetActive(false)
    else
        self.main.sizeDelta = Vector2(518, self.body.sizeDelta.y - self.body.anchoredPosition.y + 45)
        self.toggle.gameObject:SetActive(true)
    end

    --坐骑技能洗练特殊处理
    if self.toggleKey == "RideSkillWash" then
        self.toggle.gameObject:SetActive(false)
    end

end

function BuyConfirm:RemoveListeners()
    EventMgr.Instance:RemoveListener(event_name.role_asset_change, self.priceListener)
    EventMgr.Instance:RemoveListener(event_name.role_asset_change, self.assetsListener)
end

-- 刷新获取方式
function BuyConfirm:ReloadGainway(base_id)
    local cfgData = DataItem.data_get[base_id]
    local dropList = {}
    local showList = {}
    local dropstr = nil

    self.gainLayout:ReSet()
    for _,data in ipairs(cfgData.tips_type) do
        if data.tips == TipsEumn.ButtonType.Drop then
            dropstr = data.val
            break
        end
    end

    local index = 0
    if dropstr ~= nil then
        for code,argstr,label,desc,icon in string.gmatch(dropstr, "{(%d-);(.-);(.-);(.-);(%d-)}") do
            index = index + 1
            local tab = self.gainList[index]
            if tab == nil then
                tab = {}
                tab.gameObject = GameObject.Instantiate(self.gainCloner)
                tab.transform = tab.gameObject.transform
                tab.iconLoader = SingleIconLoader.New(tab.transform:Find("Image").gameObject)
                tab.text = tab.transform:Find("Text"):GetComponent(Text)
                tab.gameObject:GetComponent(Button).onClick:AddListener(function() if tab.clickCallback ~= nil then tab.clickCallback() end end)
                self.gainList[index] = tab
            end

            code = tonumber(code)
            tab.iconLoader:SetOtherSprite(self.assetWrapper:GetSprite(AssetConfig.dropicon, tostring(icon)))
            tab.text.text = label

            local args = StringHelper.Split(argstr, "|")
            if #args == 0 then
                table.insert(args,tonumber(argstr))
            end
            local func = nil
            if code == TipsEumn.DropCode.OpenWindow then
                func = function()
                    self:OnClose()
                    local windowId = tonumber(args[1])
                    table.remove(args, 1)
                    local fuck = {}
                    for i,v in ipairs(args) do
                        table.insert(fuck, tonumber(v))
                    end
                    table.insert(fuck, base_id)
                    if windowId == WindowConfig.WinID.guildauctionwindow then
                        if GuildManager.Instance.model:has_guild() then
                            WindowManager.Instance:OpenWindowById(windowId, fuck)
                        end
                    else
                        WindowManager.Instance:OpenWindowById(windowId, fuck)
                    end
                end
            elseif code == TipsEumn.DropCode.FindNpc then
                func = function()
                    self:OnClose()
                    EventMgr.Instance:Fire(event_name.drop_findnpc)
                    local key = BaseUtils.get_unique_npcid(args[2], args[1])
                    SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)
                    SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
                    SceneManager.Instance.sceneElementsModel:Self_PathToTarget(key)
                end
            elseif code == TipsEumn.DropCode.FloatTips then
                func = function()
                    NoticeManager.Instance:FloatTipsByString(argstr)
                end
            end
            tab.clickCallback = func

            self.gainLayout:AddCell(tab.gameObject)
        end
    end
    for i=index + 1,#self.gainList do
        self.gainList[i].gameObject:SetActive(false)
    end

    self.gainCloner:SetActive(false)
end

function BuyConfirm:ReloadCount()
    local totalAssets = RoleManager.Instance.RoleData[self.assets]
    local totalPrice = self.singlePrice * self.numList[self.index]

    self.numberText.text = self.numList[self.index] or 0

    if totalPrice > totalAssets then
        self.valueText.text = string.format("<color='#ff0000'>%s</color>", totalPrice)
    else
        self.valueText.text = totalPrice
    end
end

function BuyConfirm:OnClose()
    self:Hiden()
end

function BuyConfirm:OnAdd()
    if self.index ~= nil and self.numList[self.index] ~= nil then
        self.numList[self.index] = self.numList[self.index] + 1
        self:ReloadCount()
    end
end

function BuyConfirm:OnMinus()
    if self.numList[self.index] > 1 then
        self.numList[self.index] = self.numList[self.index] - 1
    else
        NoticeManager.Instance:FloatTipsByString(TI18N("最少选择一个"))
    end
    self:ReloadCount()
end

-- “智能购买所有并使用”版本
function BuyConfirm:OnClickSmart()
    if not self:IsAllVisited() then
        -- self.index = self.index + 1
        -- self:Update()
        -- self.tabbedPanel:TurnPage(self.index + 1)
    else
        self.confirmData = self.confirmData or NoticeConfirmData.New()
        local tab = {}
        local assetList, extraList = self:CalculateSmart()
        for base_id,num in pairs(assetList) do
            if num > 0 then
                table.insert(tab, string.format("{assets_2, %s}<color='#00ff00'>%s</color>", base_id, num))
            end
        end
        self.confirmData.content = string.format(TI18N("是否消耗%s购买所需物品？"), table.concat(tab))
        self.confirmData.sureLabel = TI18N("购 买")
        self.confirmData.sureCallback = self.doItFunc
        NoticeManager.Instance:ConfirmTips(self.confirmData)
    end
end


-- “只购买单种物品不使用”版本 （钻石购买并入了金币购买）
function BuyConfirm:DoIt()
    if self.numList[self.index] > 0 then
        local type = MarketManager.Instance.model:CheckGoldOrSliverItem(self.baseIdList[self.index])
        if type == 2 then 
            MarketManager.Instance:send12422({{base_id = self.baseIdList[self.index], num = self.numList[self.index]}}, self.protoId)
        else
            MarketManager.Instance:send12421({{base_id = self.baseIdList[self.index], num = self.numList[self.index]}}, self.protoId)
        end
    end

    self:DoNext()
end

function BuyConfirm:OnClick()
    local base_id = self.baseIdList[self.index]
    local priceData = self.baseidToPrice[base_id]
    local num = self.numList[self.index]
    local gold = 0
    local extra = 0

    local world_lev = RoleManager.Instance.world_lev

    if priceData == nil then
        return
    end

    if priceData.assets == KvData.assets.coin then
        local sliver_to_gold = DataMarketSilver.data_market_silver_ratio[world_lev].rate
        if priceData.price * num > RoleManager.Instance.RoleData.coin then
            gold = math.ceil((priceData.price * num) / sliver_to_gold)
            -- extra = RoleManager.Instance.RoleData.coin - RoleManager.Instance.RoleData.coin % priceData.price
        end
    elseif priceData.assets == KvData.assets.gold_bind then
        local goldbind_to_gold = DataMarketGold.data_market_gold_ratio[world_lev].rate
        if priceData.price * num > RoleManager.Instance.RoleData.gold_bind then
            gold = math.ceil((priceData.price * num) / goldbind_to_gold)
            -- extra = RoleManager.Instance.RoleData.gold_bind - RoleManager.Instance.RoleData.gold_bind % priceData.price
        end
    end

    if gold == 0 then
        self.doItFunc()
    else
        self.confirmData = self.confirmData or NoticeConfirmData.New()
        if extra == 0 then
            self.confirmData.content = string.format(TI18N("{assets_2,%s}不足，是否消耗{assets_2,90002}<color='#00ff00'>%s</color>购买<color='#ffff00'>%s</color>？"), priceData.assets, gold, DataItem.data_get[base_id].name)
        else
            self.confirmData.content = string.format(TI18N("{assets_2,%s}不足，是否消耗{assets_2,90002}<color='#00ff00'>%s</color>{assets_2,%s}<color='#00ff00'>%s</color>购买<color='#ffff00'>%s</color>？"), priceData.assets, gold, priceData.assets, extra, DataItem.data_get[base_id].name)
        end
        self.confirmData.sureLabel = TI18N("购 买")
        self.confirmData.sureCallback = self.doItFunc
        NoticeManager.Instance:ConfirmTips(self.confirmData)
    end
end

-- 智能版本，自动购买并且使用 (钻石购买并入了金币购买)
function BuyConfirm:DoItSmart()
    local tab = {}
    local fit = true
    for index,base_id in ipairs(self.baseIdList) do
        fit = fit and (self.numList[index] - self.baseidToNeed[base_id].need >= 0)
    end
    if not fit then
        for index,base_id in ipairs(self.baseIdList) do
            if self.numList[index] > 0 then
                tab[base_id] = self.numList[index]
            end
        end
    else
        for index,base_id in ipairs(self.baseIdList) do
            tab[base_id] = self.numList[index] - self.baseidToNeed[base_id].need
        end
    end

    local gold_base_ids = {}
    local sliver_base_ids = {}
    for base_id,num in pairs(tab) do
        if num > 0 then
            local type = MarketManager.Instance.model:CheckGoldOrSliverItem(base_id)
            if type == 2 then 
                table.insert(sliver_base_ids, {base_id = base_id, num = num})
            else
                table.insert(gold_base_ids, {base_id = base_id, num = num})
            end
            
        end
    end

    if fit then
        if self.clickCallback ~= nil then
            self.clickCallback()
        end
    end

    if #gold_base_ids > 0 then
        MarketManager.Instance:send12421(gold_base_ids, self.protoId)
    end

    if #sliver_base_ids > 0 then
        MarketManager.Instance:send12422(sliver_base_ids, self.protoId)
    end


    self:OnClose()
end

function BuyConfirm:DoNext()
    if self.index < #self.baseIdList then
        self.index = self.index + 1
        self:Update()
    else
        self:OnClose()
    end
end

function BuyConfirm:ReloadHeader()
    local width = 0
    local height = 0
    for i,baseId in ipairs(self.baseIdList) do
        local tab = self.itemList[i]
        if tab == nil then
            tab = {}
            tab.gameObject = GameObject.Instantiate(self.headerCloner)
            tab.transform = tab.gameObject.transform
            tab.slot = ItemSlot.New()
            NumberpadPanel.AddUIChild(tab.transform:Find("Slot"), tab.slot.gameObject)
            tab.nameText = tab.transform:Find("Name"):GetComponent(Text)
            tab.descExt = MsgItemExt.New(tab.transform:Find("Desc"):GetComponent(Text), 381, 14, 16.22)
            self.itemList[i] = tab

            tab.transform:SetParent(self.headContainer)
            tab.transform.localScale = Vector3.one
            tab.transform.anchoredPosition = Vector2(width, 0)
        end
        tab.itemData = tab.itemData or ItemData.New()
        tab.itemData:SetBase(DataItem.data_get[baseId])
        tab.slot:SetAll(tab.itemData, {inbag = false, nobutton = true})
        tab.nameText.text = tab.itemData.name
        tab.descExt:SetData(tab.itemData.desc)
        tab.gameObject:SetActive(true)
        width = width + tab.transform.sizeDelta.x
        if tab.descExt.contentTrans.sizeDelta.y - tab.descExt.contentTrans.anchoredPosition.y > 64 then
            tab.height = tab.descExt.contentTrans.sizeDelta.y - tab.descExt.contentTrans.anchoredPosition.y
        else
            tab.height = 64
        end
    end
    for i=#self.baseIdList + 1,#self.itemList do
        self.itemList[i].gameObject:SetActive(false)
    end
    self.headerCloner:SetActive(false)
    self.headContainer.sizeDelta = Vector2(width, 0)
    self.header.sizeDelta = Vector2(self.headerWidth, 0)
    -- self.tabbedPanel:SetPageCount(1)
end

-- 顶部滚动
function BuyConfirm:ValueChange()
    local index = math.ceil(-self.headContainer.anchoredPosition.x / self.headerWidth + 0.5)
    if index < 1 then
        index = 1
    elseif index > #self.baseIdList then
        index = #self.baseIdList
    end
    if index ~= self.index then
        self.index = index
        self:Update()
    end
end

function BuyConfirm:OnLeft()
    if self.index > 1 then
        -- self.tabbedPanel:TurnPage(self.index - 1)
    end
    self:ReloadLeftRight()
end

function BuyConfirm:OnRight()
    if self.index < #self.baseIdList then
        -- self.tabbedPanel:TurnPage(self.index + 1)
    end
    self:ReloadLeftRight()
end

function BuyConfirm:ReloadLeftRight()
    self.leftBtn.gameObject:SetActive(#self.baseIdList > 1)
    self.rightBtn.gameObject:SetActive(#self.baseIdList > 1)
    if self.index > 1 then
        self.leftSelect:SetActive(true)
        self.leftNormal:SetActive(false)
    else
        self.leftSelect:SetActive(false)
        self.leftNormal:SetActive(true)
    end
    if self.index < #self.baseIdList then
        self.rightSelect:SetActive(true)
        self.rightNormal:SetActive(false)
    else
        self.rightSelect:SetActive(false)
        self.rightNormal:SetActive(true)
    end
end

function BuyConfirm:IsAllVisited()
    local all = true
    for _,base_id in pairs(self.baseIdList) do
        all = all and self.visitedList[base_id]
    end
    return all
end

-- 计算应该消耗的货币类型及数量
function BuyConfirm:CalculateSmart()
    local assetList = {}
    local extraList = {}
    local baseIdList = {}
    for base_id,v in pairs(self.baseidToNeed) do
        if v ~= nil then
            if base_id < 90000 then
                baseIdList[base_id] = (baseIdList[base_id] or 0) + v.need
            else
                assetList[base_id] = (assetList[base_id] or 0) + v.need
            end
        end
    end

    local world_lev = RoleManager.Instance.world_lev
    local glodbind_to_gold = DataMarketGold.data_market_gold_ratio[world_lev].rate
    local sliver_to_gold = DataMarketSilver.data_market_silver_ratio[world_lev].rate

    local ownList = {
        [KvData.assets.coin] = RoleManager.Instance.RoleData.coin,
        [KvData.assets.gold] = RoleManager.Instance.RoleData.gold,
        [KvData.assets.star_gold] = RoleManager.Instance.RoleData.star_gold,
        [KvData.assets.gold_bind] = RoleManager.Instance.RoleData.gold_bind
    }
    for base_id,num in pairs(assetList) do
        ownList[base_id] = ownList[base_id] - num
    end

    local gold = 0
    local star_gold = 0

    for i,base_id in ipairs(self.baseIdList) do
        local priceData = self.baseidToPrice[base_id]
        local needData = self.baseidToNeed[base_id]
        if priceData.assets == KvData.assets.coin then
            if priceData.price * self.numList[i] < ownList[KvData.assets.coin] then
                ownList[KvData.assets.coin] = ownList[KvData.assets.coin] - priceData.price * self.numList[i]
                assetList[KvData.assets.coin] = (assetList[KvData.assets.coin] or 0) + priceData.price * self.numList[i]
            else
                assetList[KvData.assets.coin] = (assetList[KvData.assets.coin] or 0) + math.floor(ownList[KvData.assets.coin] / priceData.price) * priceData.price
                star_gold = star_gold + math.ceil((self.numList[i] - math.floor(ownList[KvData.assets.coin] / priceData.price)) * priceData.price / sliver_to_gold)
                ownList[KvData.assets.coin] = ownList[KvData.assets.coin] % priceData.price
            end
        elseif priceData.assets == KvData.assets.gold_bind then
            if priceData.price * self.numList[i] < ownList[KvData.assets.gold_bind] then
                ownList[KvData.assets.gold_bind] = ownList[KvData.assets.gold_bind] - priceData.price * self.numList[i]
                assetList[KvData.assets.gold_bind] = (assetList[KvData.assets.gold_bind] or 0) + priceData.price * self.numList[i]
            else
                assetList[KvData.assets.gold_bind] = (assetList[KvData.assets.gold_bind] or 0) + math.floor(ownList[KvData.assets.gold_bind] / priceData.price) * priceData.price
                star_gold = star_gold + math.ceil((self.numList[i] - math.floor(ownList[KvData.assets.gold_bind] / priceData.price)) * priceData.price / glodbind_to_gold)
                ownList[KvData.assets.gold_bind] = ownList[KvData.assets.gold_bind] % priceData.price
            end
        elseif priceData.assets == KvData.assets.gold then
            gold = gold + priceData.price * self.numList[i]
        elseif priceData.assets == KvData.assets.star_gold then
            star_gold = star_gold + priceData.price * self.numList[i]
        elseif priceData.assets == KvData.assets.star_gold_or_gold then
            star_gold = star_gold + priceData.price * self.numList[i]
        end

        if self.numList[i] < needData.need then
            extraList[base_id] = self.numList[i]
        else
            extraList[base_id] = self.numList[i] - needData.need
        end
    end

    if star_gold > ownList[KvData.assets.star_gold] then
        assetList[KvData.assets.star_gold] = (assetList[KvData.assets.star_gold] or 0) + ownList[KvData.assets.star_gold]
        gold = gold + (star_gold - ownList[KvData.assets.star_gold])
        ownList[KvData.assets.star_gold] = 0
    else
        assetList[KvData.assets.star_gold] = (assetList[KvData.assets.star_gold] or 0) + star_gold
        ownList[KvData.assets.star_gold] = ownList[KvData.assets.star_gold] - star_gold
    end
    assetList[KvData.assets.gold] = (assetList[KvData.assets.gold] or 0) + gold

    return assetList, extraList
end

function BuyConfirm:UpdateAssets()
    local tab = {"coin", "gold", "gold_bind", "star_gold"}
    for _,key in pairs(tab) do
        self.assetTab[KvData.assets[key]].text.text = RoleManager.Instance.RoleData[key]
        self.assetTab[KvData.assets[key]].obj:SetActive(true)
    end
end

function BuyConfirm:OnToggle()
    if BuyManager.Instance.autoBuyList[self.toggleKey] == nil then
        return
    end
    local base_id = self.baseIdList[self.index]
    BuyManager.Instance.autoBuyList[self.toggleKey][base_id] = not (BuyManager.Instance.autoBuyList[self.toggleKey][base_id] == true)
    self.toggleTick:SetActive(BuyManager.Instance.autoBuyList[self.toggleKey][base_id] == true)
end
