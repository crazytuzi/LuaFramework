-- @author hze
-- @date #19/08/19#
-- 战令购买窗口
WarOrderBuyWindow = WarOrderBuyWindow or BaseClass(BaseWindow)

function WarOrderBuyWindow:__init(model)
    self.model = model
    self.name = "WarOrderBuyWindow"

    self.mgr = CampaignProtoManager.Instance

    self.windowId = WindowConfig.WinID.warorderbuywindow

    self.resList = {
        {file = AssetConfig.war_order_buy_window, type = AssetType.Main}
        ,{file = AssetConfig.war_order_buy_bg, type = AssetType.Main}
        ,{file = AssetConfig.leftgirl, type = AssetType.Main}
        ,{file = AssetConfig.warordertextures, type = AssetType.Dep}
    }

    self.itemList = {}

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function WarOrderBuyWindow:__delete()
    self.OnHideEvent:Fire()
    if self.layout then 
        self.layout:DeleteMe()
    end

    if self.boxIconLoader then 
        self.boxIconLoader:DeleteMe()
    end

end

function WarOrderBuyWindow:OnHide()
    self:RemoveListeners()

end

function WarOrderBuyWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function WarOrderBuyWindow:AddListeners()
end

function WarOrderBuyWindow:RemoveListeners()
end

function WarOrderBuyWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.war_order_buy_window))
    self.gameObject.name = "WarOrderBuyWindow"
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)

    self.transform = self.gameObject.transform

    local main = self.transform:Find("Main")

    UIUtils.AddBigbg(main:Find("Bg"), GameObject.Instantiate(self:GetPrefab(AssetConfig.war_order_buy_bg)))
    UIUtils.AddBigbg(main:Find("BigBg"), GameObject.Instantiate(self:GetPrefab(AssetConfig.leftgirl)))

    self.closeBtn = main:Find("CloseButton"):GetComponent(Button)
    self.closeBtn.onClick:AddListener(function() self:OnCloseClick() end )
    

    local boxBtn1 = main:Find("Box1"):GetComponent(Button)
    boxBtn1.onClick:AddListener(function() self:OnBoxClick(1) end )

    self.boxIconLoader = SingleIconLoader.New(boxBtn1.transform:Find("Icon").gameObject)
    self.boxIconLoader:SetSprite(SingleIconType.Item, 21711)

    boxBtn1.transform:Find("Icon").anchoredPosition = Vector2(1.2, 5)

    local boxBtn2 = main:Find("Box2"):GetComponent(Button)
    boxBtn2.onClick:AddListener(function() self:OnBoxClick(2) end )

    boxBtn2.transform:Find("Icon").sizeDelta = Vector2(63, 58)
    boxBtn2.transform:Find("Icon").anchoredPosition = Vector2(1.2, 2.2)
    
    self.scroll = main:Find("ScrollRect"):GetComponent(ScrollRect)
    self.scroll.onValueChanged:AddListener(function()
        self:DealExtraEffect()
        end)


    self.itemContainer = main:Find("ScrollRect/Container")
    self.layout = LuaGridLayout.New(self.itemContainer, {column = 4, bordertop = 5, borderleft = 15, cspacing = 11, rspacing = 8, cellSizeX = 64, cellSizeY = 64})

    self.btnImg = main:Find("BuyButton"):GetComponent(Image)
    self.btnTxtImg = main:Find("BuyButton/Image"):GetComponent(Image)

    self.buyBtn = main:Find("BuyButton"):GetComponent(Button)
    self.buyBtn.onClick:AddListener(function() self:OnBuyClick() end)
end

function WarOrderBuyWindow:OnOpen()
    self:RemoveListeners()
    self:AddListeners()

    self:ReloadData()

    self:DealExtraEffect()
end


function WarOrderBuyWindow:OnCloseClick()
    WindowManager.Instance:CloseWindow(self)
end

function WarOrderBuyWindow:OnBoxClick(type)
    -- if type == 1 then 
    --     print("第一个宝箱")
    -- else
    --     print("第二个宝箱")
    -- end
end

function WarOrderBuyWindow:OnBuyClick()
    print("直购点击")
    local val = 980
    if SdkManager.Instance:RunSdk() then
        SdkManager.Instance:ShowChargeView(ShopManager.Instance.model:GetSpecialChargeData(val), BaseUtils.DiamondToRmb(val), val / 10 * 10, "9")
    end
end


function WarOrderBuyWindow:ReloadData()
    local data = DataCampWarOrder.data_reward
    local specailList = {}
    local markspeList = {}

    for lev, _ in pairs(data) do
        local reward = WarOrderConfigHelper.GetReward(lev)
        for i, v in ipairs(reward) do
            if v.type == 2 then
                if not markspeList[v.item_id] then
                    markspeList[v.item_id] = true
                    table.insert(specailList, v)
                end
            end
        end
    end

    table.sort( specailList, function(a, b) return a.sort < b.sort end)

    self.layout:ReSet()
    for i, v in ipairs(specailList) do
        local item = self.itemList[i]
        if not item then 
            item = ItemSlot.New()
            local itemdata = ItemData.New()
            itemdata:SetBase(DataItem.data_get[v.item_id])
            item:SetAll(itemdata, {inbag = false, nobutton = true})
            item.effectFlag = v.effect == 1
            item:ShowEffect(v.effect == 1, 20223)
            -- item:ShowEffect(true, 20223)
            UIUtils.AddUIChild(self.itemContainer, item.gameObject)
        end
        self.itemList[i] = item
        self.layout:AddCell(item.gameObject)
    end
end


--处理特效
function WarOrderBuyWindow:DealExtraEffect()
    local scrollRect = self.scroll
    local container = scrollRect.content

    local item_list = self.itemList
    local delta1 = 0
    local delta2 = 0

    local a_side = -container.anchoredPosition.y
    local b_side = a_side - scrollRect.transform.sizeDelta.y

    local a_xy, s_xy = 0, 0
    for k, v in pairs(item_list) do
        a_xy = v.gameObject.transform.anchoredPosition.y + delta1
        s_xy = v.gameObject.transform.sizeDelta.y + delta1 + delta2

        if v.effect ~= nil then
            v.effect:SetActive((a_xy < a_side and a_xy - s_xy > b_side) and v.effectFlag)
        end
    end
end
