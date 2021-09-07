-- @author hze
-- @date #2019/01/14#
-- 惊喜折扣商店

SurpriseDisCountShopPanel = SurpriseDisCountShopPanel or BaseClass(BasePanel)

function SurpriseDisCountShopPanel:__init(model, parent)
    self.model = model
    self.parent = parent
    self.name = "SurpriseDisCountShopPanel"

    self.resList = {
        {file = AssetConfig.surprise_discount_shop_panel, type = AssetType.Main}
        ,{file = AssetConfig.card_exchange_bg4, type = AssetType.Main}
        ,{file = AssetConfig.cardexchangetexture, type = AssetType.Dep}
    }

    self.OperateType = { ADD = 1, MINUS = 2, NUMPAD = 3}
    self.shopCellList = {}

    self.updateCellListListener = function(data) self:UpdateCellList(data) end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function SurpriseDisCountShopPanel:__delete()
    self.OnHideEvent:Fire()
    if self.luaGrid ~= nil then 
        self.luaGrid:DeleteMe()
    end
    if self.shopCellList ~= nil then 
        for k,v in ipairs(self.shopCellList) do
            if v.loader ~= nil then 
                v.loader:DeleteMe()
            end
            BaseUtils.ReleaseImage(v.costIcon)
        end
    end

    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function SurpriseDisCountShopPanel:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.surprise_discount_shop_panel))
    self.gameObject.name = self.name
    local t = self.gameObject.transform
    UIUtils.AddUIChild(self.parent, self.gameObject)
    self.transform = t

    local main = self.transform:Find("Main")

    local bg =  GameObject.Instantiate(self:GetPrefab(AssetConfig.card_exchange_bg4))
    UIUtils.AddBigbg(self.transform:Find("Main/Bg1"),bg)
    bg.transform.anchoredPosition = Vector2(-6,46)

    self.timeTxt = main:Find("TimeTxt"):GetComponent(Text)

    self.shopItemContainer = main:Find("ScrollRect/Container")
    self.shopItemCloner = main:Find("ScrollRect/ItemCloner").gameObject
    self.shopItemCloner:SetActive(false)

    -- self.tipsBtn = main:Find("Notice"):GetComponent(Button)
    -- self.tipsBtn.onClick:AddListener(function()
    --         TipsManager.Instance:ShowText({gameObject = self.tipsBtn.gameObject, itemData = self.tips})
    --     end)

    self.costTxt = main:Find("CostText"):GetComponent(Text)
    main:Find("MidleText"):GetComponent(Text).text = TI18N("在折扣店每消费1000钻石即可获得一张刮刮卡")

    self.luaGrid = LuaGridLayout.New(self.shopItemContainer, {column = 2, cspacing = 10, rspacing = 8, cellSizeX = 271, cellSizeY = 139, bordertop = 3, borderleft = 3})
end

function SurpriseDisCountShopPanel:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function SurpriseDisCountShopPanel:OnOpen()
    self:RemoveListeners()
    CardExchangeManager.Instance.OnUpdateCellListEvent:AddListener(self.updateCellListListener)
    local campData = DataCampaign.data_list[self.campId]
    local s_m = campData.cli_start_time[1][2]
    local s_d = campData.cli_start_time[1][3]
    local e_m = campData.cli_end_time[1][2]
    local e_d = campData.cli_end_time[1][3]
    self.timeTxt.text = string.format("%s:%s%s%s%s-%s%s%s%s",TI18N("开业时间"),s_m,TI18N("月"),s_d,TI18N("日"),e_m,TI18N("月"),e_d,TI18N("日"))

    CardExchangeManager.Instance:Send20465()
    PlayerPrefs.SetInt(BaseUtils.Key(RoleManager.Instance.RoleData.id, RoleManager.Instance.RoleData.platform, RoleManager.Instance.RoleData.zone_id, CardExchangeManager.Instance.SurpriseShopTag),BaseUtils.BASE_TIME)
end

function SurpriseDisCountShopPanel:OnHide()
    self:RemoveListeners()
end

function SurpriseDisCountShopPanel:RemoveListeners()
    CardExchangeManager.Instance.OnUpdateCellListEvent:RemoveListener(self.updateCellListListener)
end

function SurpriseDisCountShopPanel:UpdateCellList(data)
    -- local tempData = {
    --                     {id = 1, item_id = 22205, bind = 1, num = 1, price_item_id = 90002, price_num = 1200, left_num = 10, total_num = 10, show_effect = 1},
    --                     {id = 2, item_id = 20038, bind = 1, num = 1, price_item_id = 90003, price_num = 1100, left_num = 0, total_num = 0, show_effect = 0},
    --                     {id = 3, item_id = 20003, bind = 1, num = 1, price_item_id = 90003, price_num = 1300, left_num = 2, total_num = 5, show_effect = 0},
    --                     {id = 4, item_id = 20025, bind = 1, num = 1, price_item_id = 90002, price_num = 1550, left_num = 0, total_num = 0, show_effect = 1},
    --                     {id = 5, item_id = 20067, bind = 1, num = 1, price_item_id = 90003, price_num = 120, left_num = 20, total_num = 20, show_effect = 1},
    --                     {id = 6, item_id = 20081, bind = 1, num = 1, price_item_id = 90002, price_num = 9995, left_num = 0, total_num = 0, show_effect = 0},
    --                     {id = 7, item_id = 20032, bind = 1, num = 1, price_item_id = 90002, price_num = 100, left_num = 1, total_num = 5, show_effect = 0},
    --                     {id = 8, item_id = 20036, bind = 1, num = 1, price_item_id = 90002, price_num = 2050, left_num = 10, total_num = 30, show_effect = 1},
    --                     {id = 9, item_id = 20044, bind = 1, num = 1, price_item_id = 90002, price_num = 200, left_num = 5, total_num = 5, show_effect = 1},
    --                 }
    self.luaGrid:ReSet()
    for i,v in ipairs (data.shop_list) do
        local tab = self.shopCellList[i]
        if not tab then
            tab = {}
            tab.gameObject = GameObject.Instantiate(self.shopItemCloner)
            tab.transform = tab.gameObject.transform
            local t = tab.transform
            tab.nameTxt = t:Find("NamBg/Name"):GetComponent(Text)
            tab.limitTxt = t:Find("LimitTxt"):GetComponent(Text)
            tab.priceTxt = t:Find("PriceBg/Price"):GetComponent(Text)
            tab.costIcon = t:Find("PriceBg/Currency"):GetComponent(Image)

            tab.buyCountTrans = t:Find("BuyCount")
            tab.addbtn = tab.buyCountTrans:Find("AddBtn"):GetComponent(Button)
            tab.minusbtn = tab.buyCountTrans:Find("MinusBtn"):GetComponent(Button)
            tab.count = tab.buyCountTrans:Find("CountBg/Count"):GetComponent(Text)
            tab.countbtn = tab.count.transform:GetComponent(Button)

            tab.cell = t:Find("ItemSlot")
            tab.icon = tab.cell:Find("Icon"):GetComponent(Image)
            tab.effectImgObj = tab.cell:Find("EffectImg").gameObject
            tab.loader = SingleIconLoader.New(tab.icon.gameObject)
            tab.numTxt = tab.cell:Find("NumText"):GetComponent(Text)
            tab.buybtn = t:Find("BuyBtn"):GetComponent(Button)
            tab.soldoutObj = t:Find("SoldoutImg").gameObject

            --点击事件监听
            tab.addbtn.onClick:AddListener(function() self:CountChange(self.OperateType.ADD,tab) end)
            tab.minusbtn.onClick:AddListener(function() self:CountChange(self.OperateType.MINUS,tab) end)

            tab.icon.transform:GetComponent(Button).onClick:RemoveAllListeners()
            tab.icon.transform:GetComponent(Button).onClick:AddListener(function()
                    TipsManager.Instance:ShowItem({gameObject = tab.icon.transform.gameObject, itemData = DataItem.data_get[v.item_id], extra = { nobutton = true, inbag = false}
                        })
                end)

            tab.countbtn.onClick:RemoveAllListeners()
            tab.countbtn.onClick:AddListener(function() self:OnNumberpad(tab) end)

            tab.buybtn.onClick:RemoveAllListeners()
            tab.buybtn.onClick:AddListener(function() 
                if tab.data.num > 0 then
                        local dat = NoticeConfirmData.New()
                        dat.type = ConfirmData.Style.Normal
                        dat.content = string.format(TI18N("是否确认花费{assets_1,%s,%s}购买<color='#00ff00'>%s*%s</color>?"), v.price_item_id, v.price_num*tab.data.num, DataItem.data_get[v.item_id].name,tab.data.num)
                        dat.sureLabel = TI18N("购买")
                        dat.sureCallback = function() CardExchangeManager.Instance:Send20466(tab.data.id, tab.data.num) end
                        NoticeManager.Instance:ConfirmTips(dat)
                else
                    NoticeManager.Instance:FloatTipsByString(TI18N("请选择购买数量{face_1,3}"))
                end
            end) 
        end
        
        local itemData = DataItem.data_get[v.item_id]
        print(v.item_id)
        tab.nameTxt.text = itemData.name
        tab.priceTxt.text = v.price_num
        tab.costIcon.sprite = PreloadManager.Instance:GetSprite(AssetConfig.base_textures, "Assets"..v.price_item_id)
        
        tab.loader:SetSprite(SingleIconType.Item, itemData.icon)
        tab.effectImgObj:SetActive(1 == v.show_effect)

        if v.total_num ~= 0 then
            tab.buybtn.transform.gameObject:SetActive(v.left_num ~= 0)
            tab.soldoutObj:SetActive(v.left_num == 0)
            tab.limitTxt.text = string.format(TI18N("限购：%s/%s个"), v.left_num, v.total_num)
        else
            tab.limitTxt.gameObject:SetActive(false)
        end

        if v.num > 1 then 
            tab.numTxt.text = v.num
            tab.numTxt.transform.gameObject:SetActive(false)
        end

        tab.count.text = 0  --重置选择数量

        --构建数据
        tab.data = {id = v.id, num = 0, total_num = v.total_num, left_num = v.left_num}
        self.luaGrid:AddCell(tab.gameObject)
        self.shopCellList[i] = tab
    end
    -- --下方可获描述更新
    self.costTxt.text = string.format(TI18N("还需消耗<color='#fff000'>%s钻石</color>可获得一张刮刮卡"), data.need_cost)
end

function SurpriseDisCountShopPanel:CountChange(operateType,cell)

    if operateType == 1 then
        --增加购买数量
        if cell.data.total_num == 0 then
            cell.data.num = cell.data.num + 1
        else
            if cell.data.num < cell.data.left_num then
                cell.data.num = cell.data.num + 1
            else
                NoticeManager.Instance:FloatTipsByString(TI18N("已超过限购个数"))
            end
        end
    elseif operateType == 2 then
        if cell.data.num > 0 then
            cell.data.num = cell.data.num - 1
        end
    elseif operateType == 3 then 
        cell.data.num = NumberpadManager.Instance:GetResult()
    end

    --限购商品
    if cell.data.total_num ~= 0 then
        cell.limitTxt.text = string.format(TI18N("限购：%s/%s个"), cell.data.left_num - cell.data.num, cell.data.total_num)
    end
    --当前选择个数显示
    cell.count.text = cell.data.num
end

function SurpriseDisCountShopPanel:OnNumberpad(tab)
    local model = ShopManager.Instance.model

    local max_result = 9999
    if tab.data.total_num ~= 0 then
        max_result = tab.data.left_num
    end
    self.numberpadSetting = {               -- 弹出小键盘的设置
        gameObject = tab.buyCountTrans:Find("CountBg").gameObject,
        min_result = 1,
        max_by_asset = max_result,
        max_result = max_result,
        textObject = tab.count,
        show_num = false,
        callback = function() self:CountChange(self.OperateType.NUMPAD,tab) end
    }
    NumberpadManager.Instance:set_data(self.numberpadSetting)
end
