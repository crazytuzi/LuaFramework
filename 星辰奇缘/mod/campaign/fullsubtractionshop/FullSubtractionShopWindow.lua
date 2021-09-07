-- @author hze
-- @date 2018/06/01
-- 满减商城

FullSubtractionShopWindow = FullSubtractionShopWindow or BaseClass(BaseWindow)

function FullSubtractionShopWindow:__init(model)
    self.model = model
    self.name = "FullSubtractionShopWindow"

    self.windowId = WindowConfig.WinID.fullsubtractionshop

    self.resList = {
        {file = AssetConfig.fullsubtractionshopwindow, type = AssetType.Main}
        ,{file = AssetConfig.fullshopdescti18n, type = AssetType.Main}
        ,{file = AssetConfig.fullshopdesc, type = AssetType.Main}
        ,{file = AssetConfig.christmastitletop, type = AssetType.Main}
        ,{file = AssetConfig.leftgirl, type = AssetType.Main}
        ,{file = AssetConfig.beginautum,type = AssetType.Dep}
        ,{file = AssetConfig.shop_textures,type = AssetType.Dep}
    }

    self.shopCellList = {}
    self.cell_buy_data = {b_l = {}}

    self.tips = {}

    self.showEffectFlag = true

    self.OperateType = { Add = 1, Minus = 2}

    self.updateCellListListener = function() self:UpdateCellList() end

    self.OnOpenEvent:AddListener(function() self:OnOpen() end)
    self.OnHideEvent:AddListener(function() self:OnHide() end)
end

function FullSubtractionShopWindow:__delete()
    self.OnHideEvent:Fire()

    if self.shopCellList ~= nil then
        for k,v in ipairs(self.shopCellList) do
            if v ~= nil then
                if v.loader ~= nil then v.loader:DeleteMe() v.loader = nil end
                if v.icon ~= nil then BaseUtils.ReleaseImage(v.icon) end
            end
        end
        self.shopCellList = nil
    end




    if self.gameObject ~= nil then
        GameObject.DestroyImmediate(self.gameObject)
        self.gameObject = nil
    end
    self:AssetClearAll()
end

function FullSubtractionShopWindow:InitPanel()
    self.gameObject = GameObject.Instantiate(self:GetPrefab(AssetConfig.fullsubtractionshopwindow))
    UIUtils.AddUIChild(ctx.CanvasContainer, self.gameObject)
    self.gameObject.name = self.name
    self.transform = self.gameObject.transform

    local main = self.transform:Find("Main")
    main:Find("CloseButton"):GetComponent(Button).onClick:AddListener(function() WindowManager.Instance:CloseWindow(self) end)

    UIUtils.AddBigbg(main:Find("Bg/BigTopBg"), GameObject.Instantiate(self:GetPrefab(AssetConfig.christmastitletop)))
    UIUtils.AddBigbg(main:Find("Bg/TimeBg"), GameObject.Instantiate(self:GetPrefab(AssetConfig.fullshopdesc)))
    local cehua =  GameObject.Instantiate(self:GetPrefab(AssetConfig.fullshopdescti18n))
    UIUtils.AddBigbg(main:Find("Bg/TimeBg"),cehua)
    cehua.transform.anchoredPosition = Vector2(2,-10)
    UIUtils.AddBigbg(main:Find("Girld"), GameObject.Instantiate(self:GetPrefab(AssetConfig.leftgirl)))


    self.timeTxt = main:Find("Bg/TimeTxt"):GetComponent(Text)
    self.timeTxt.transform.anchoredPosition = Vector2(172,150)
    self.timeTxt.fontSize = 13

    self.shopItemContainer = main:Find("ScrollRect/Container")
    self.shopItemCloner = main:Find("ScrollRect/ItemCloner").gameObject
    self.shopItemCloner:SetActive(false)

    self.shopCarTrans = main:Find("ShopCar")
    self.targetEffectPos = self.shopCarTrans.position
    self.shopCarTrans:GetComponent(Button).onClick:AddListener(function() NoticeManager.Instance:FloatTipsByString(TI18N("快来添加商品填满我吧，优惠多多不容错过哟{face_1,3}")) end)

    self.tweenImg = main:Find("TweenImg")
    self.tweenImg.gameObject:SetActive(false)

    self.qipao = main:Find("QiPaoBg")

    self.tipsBtn = main:Find("Notice"):GetComponent(Button)
    self.tipsBtn.onClick:AddListener(function()
            TipsManager.Instance:ShowText({gameObject = self.tipsBtn.gameObject, itemData = self.tips})
        end)

    self.accountBtn = main:Find("AccountButton"):GetComponent(Button)
    self.accountBtn.onClick:AddListener(function()
        local dat = self.cell_buy_data
        if next(dat.b_l) then
                local data = NoticeConfirmData.New()
                data.type = ConfirmData.Style.Normal
                data.content = string.format(TI18N("是否确认花费{assets_1,90002,%s}购买心仪的商品?"), dat.c_p)
                if dat.t_p < self.model.cellInfolist.rebate_info[3].purchase_val then
                    data.content = string.format(TI18N("%s\n\n<color='#ffff00'>(再购买%s钻，则可再减免%s钻)</color>"), data.content, dat.n_p, dat.n_d_p)
                end
                data.sureLabel = TI18N("确认结算")
                data.cancelLabel = TI18N("再买点")
                data.blueSure = true
                data.greenCancel = true
                data.showClose = 1
                data.cancelCallback = function() end
                data.sureCallback = function()
                        if BackpackManager.Instance:GetCurrentGirdNum() == 0 then
                            NoticeManager.Instance:FloatTipsByString(TI18N("背包已满，请整理后再尝试"))
                        else
                            local proto_data = {}
                            for k,v in ipairs(dat.b_l) do
                                table.insert(proto_data, {item_id = v.data.item_id, buy_num = v.data.num})
                            end
                            BaseUtils.dump(proto_data,"proto_data")
                            MagicEggManager.Instance:Send20457(proto_data)
                        end
                    end
                NoticeManager.Instance:ConfirmTips(data)
        else
            NoticeManager.Instance:FloatTipsByString(TI18N("快去选择心仪的商品再进行结算吧{face_1,3}"))
        end
     end)

    self.DescExt = MsgItemExt.New(main:Find("TitleBg/MidleText"):GetComponent(Text), 239)
    self.discountExt = MsgItemExt.New(self.qipao:Find("MidleText"):GetComponent(Text), 110)
    self.costTxt = MsgItemExt.New(self.accountBtn.transform:Find("CostText"):GetComponent(Text), 140)
end

function FullSubtractionShopWindow:OnInitCompleted()
    self.OnOpenEvent:Fire()
end

function FullSubtractionShopWindow:OnOpen()
    self:RemoveListeners()
    MagicEggManager.Instance.OnUpdateCellListEvent:AddListener(self.updateCellListListener)

    -- BaseUtils.dump(self.openArgs)
    if next(self.openArgs) ~= nil then
        self.campId = self.openArgs.campId or 1093
    end
    if self.campId == nil then print("活动ID为空") return end
    local campData = DataCampaign.data_list[self.campId]
    self.tips = {campData.cond_desc}

    local s_m = campData.cli_start_time[1][2]
    local s_d = campData.cli_start_time[1][3]

    local e_m = campData.cli_end_time[1][2]
    local e_d = campData.cli_end_time[1][3]

    self.timeTxt.text = string.format("%s:%s%s%s%s-%s%s%s%s",TI18N("开业时间"),s_m,TI18N("月"),s_d,TI18N("日"),e_m,TI18N("月"),e_d,TI18N("日"))

    MagicEggManager.Instance:Send20456()

    PlayerPrefs.SetInt(BaseUtils.Key(RoleManager.Instance.RoleData.id, RoleManager.Instance.RoleData.platform, RoleManager.Instance.RoleData.zone_id, MagicEggManager.Instance.FullSubShopTag),BaseUtils.BASE_TIME)
end

function FullSubtractionShopWindow:OnHide()
    self:RemoveListeners()

    if self.DescExt ~= nil then
        self.DescExt:DeleteMe()
        self.DescExt = nil
    end

    if self.discountExt ~= nil then
        self.discountExt:DeleteMe()
        self.discountExt = nil
    end

    if self.costTxt ~= nil then
        self.costTxt:DeleteMe()
        self.costTxt = nil
    end

    if self.luaGrid ~= nil then
        self.luaGrid:DeleteMe()
        self.luaGrid = nil
    end

    if self.tweenId1 ~= nil then
        Tween.Instance:Cancel(self.tweenId1)
        self.tweenId1 = nil
    end

    if self.tweenId2 ~= nil then
        Tween.Instance:Cancel(self.tweenId2)
        self.tweenId2 = nil
    end

    if self.tweenId3 ~= nil then
        Tween.Instance:Cancel(self.tweenId2)
        self.tweenId3 = nil
    end

    if self.tweenImg:GetComponent(Image) ~= nil then
        BaseUtils.ReleaseImage(self.tweenImg:GetComponent(Image))
    end

end

function FullSubtractionShopWindow:RemoveListeners()
    MagicEggManager.Instance.OnUpdateCellListEvent:RemoveListener(self.updateCellListListener)
end

function FullSubtractionShopWindow:UpdateCellList()
    -- local tempData = {
    --                     {item_id = 22205, buy_limit = 5, buyed_num = 0, price = 1200, item_name = "精灵珍魂"},
    --                     {item_id = 20038, buy_limit = 5, buyed_num = 2, price = 1300, item_name = "神兽之魂"},
    --                     {item_id = 20003, buy_limit = 5, buyed_num = 5, price = 1400, item_name = "悬赏产玫瑰"},
    --                     {item_id = 20025, buy_limit = 5, buyed_num = 1, price = 1500, item_name = "冒险笔记"},
    --                     {item_id = 20067, buy_limit = 0, buyed_num = 0, price = 1700, item_name = "宠物·雪狐"},
    --                     {item_id = 20081, buy_limit = 0, buyed_num = 0, price = 1150, item_name = "醒神卡"},
    --                     {item_id = 20032, buy_limit = 0, buyed_num = 0, price = 1950, item_name = "999朵玫瑰"},
    --                     {item_id = 20036, buy_limit = 0, buyed_num = 0, price = 1320, item_name = "三品灵犀"},
    --                     {item_id = 20044, buy_limit = 0, buyed_num = 0, price = 5220, item_name = "结缘申请戒指"},
    --                     {item_id = 21406, buy_limit = 0, buyed_num = 0, price = 4410, item_name = "凤凰复活散"}
    --                 }
    local tempData = self.model.cellInfolist.item_info

    -- BaseUtils.dump(tempData,"tempData")

    self:ResetCell()

    self.luaGrid = LuaGridLayout.New(self.shopItemContainer, {column = 2, cspacing = 10, rspacing = 10, cellSizeX = 265, cellSizeY = 121, bordertop = 6, borderleft = 7})

    for i,v in ipairs (tempData) do
        local tab = self.shopCellList[i]
        if not tab then
            tab = {}
            tab.gameObject = GameObject.Instantiate(self.shopItemCloner)
            tab.transform = tab.gameObject.transform
            local t = tab.transform
            tab.btn = t:GetComponent(Button)
            tab.selectObj = t:Find("Select").gameObject
            tab.nameTxt = t:Find("NamBg/Name"):GetComponent(Text)
            tab.priceTxt = t:Find("PriceBg/Price"):GetComponent(Text)

            tab.selectAddBtn = t:Find("SelectAddBtn"):GetComponent(Button)

            tab.buyCountTrans = t:Find("BuyCount")

            tab.addbtn = tab.buyCountTrans:Find("AddBtn"):GetComponent(Button)
            tab.minusbtn = tab.buyCountTrans:Find("MinusBtn"):GetComponent(Button)
            tab.count = tab.buyCountTrans:Find("CountBg/Count"):GetComponent(Text)
            tab.countbtn = tab.count.transform:GetComponent(Button)

            tab.restraintObj = t:Find("Restraint").gameObject

            tab.cell = t:Find("ItemSlot")
            tab.icon = tab.cell:Find("Icon"):GetComponent(Image)
            tab.soldoutObj = tab.cell:Find("SoldoutImg").gameObject
            tab.selectedImgObj = tab.cell:Find("SelectedImg").gameObject
            tab.effectImgObj = tab.cell:Find("EffectImg").gameObject

            tab.loader = SingleIconLoader.New(tab.icon.gameObject)

            --点击事件监听
            tab.selectAddBtn.onClick:AddListener(function() self:ShopCellSelceted(tab) end)

            tab.addbtn.onClick:AddListener(function() self:CountChange(self.OperateType.Add,tab) end)
            tab.minusbtn.onClick:AddListener(function() self:CountChange(self.OperateType.Minus,tab) end)

            tab.icon.transform:GetComponent(Button).onClick:AddListener(function()
                    TipsManager.Instance:ShowItem({gameObject = tab.icon.transform.gameObject, itemData = DataItem.data_get[v.item_id], extra = { nobutton = true, inbag = false}
                        })
                end)

            tab.countbtn.onClick:AddListener(function()
                    self:OnNumberpad(tab)
                end)

            -- tab.btn.onClick:AddListener(function() self:ShopCellSelceted(tab) end)
        end

        tab.nameTxt.text = v.item_name
        tab.priceTxt.text = v.price

        -- tab.icons
        tab.loader:SetSprite(SingleIconType.Item, DataItem.data_get[v.item_id].icon)

        tab.effectImgObj:SetActive(1 == v.is_effect)

        --限购商品是否已经售罄
        if v.buy_limit ~= 0 then
            tab.soldoutObj:SetActive(v.buyed_num == v.buy_limit)
            tab.restraintObj.transform:GetComponent(Text).text = string.format(TI18N("今日可购%s/%s个"), v.buy_limit - v.buyed_num, v.buy_limit)
        end

        --构建数据
        tab.data = {item_id = v.item_id, num = 0, max_num = v.buy_limit, buyed_num = v.buyed_num, price = v.price}

        self.shopCellList[i] = tab
        self.luaGrid:AddCell(tab.gameObject)
    end

end

function FullSubtractionShopWindow:ResetCell(cell)
    for k,v in ipairs(self.shopCellList) do
        v.selectObj:SetActive(false)
        v.buyCountTrans.gameObject:SetActive(false)
        v.selectAddBtn.transform.gameObject:SetActive(true)  --‘加减’号&数量文本
        v.restraintObj:SetActive(false)
        v.selectedImgObj:SetActive(false)

        v.transform:Find("PriceBg").anchoredPosition = Vector2(34.5, -14.4)
        v.transform:Find("PriceBg").sizeDelta = Vector2(99.4, 24.7)
    end

    --描述初始化
    self.DescExt:SetData(string.format("<color='#248813'>%s</color><color='#fff000'>%s</color>{assets_2,90002}<color='#248813'>%s</color><color='#fff000'>%s</color>{assets_2,90002}", TI18N("原价"), 0, TI18N("减免"), 0))
    self.discountExt:SetData(string.format("%s<color='#fff000'>%s</color>%s%s<color='#fff000'>%s</color>{face_1,3}", TI18N("再买"), self.model.cellInfolist.rebate_info[1].purchase_val, TI18N("钻"), TI18N("再减"), self.model.cellInfolist.rebate_info[1].rebate_val))
    self.costTxt:SetData(string.format("{assets_2,90002}<color='#906014'>%s</color>", TI18N("结 算")))
    self.accountBtn.transform.sizeDelta = Vector2(110, 45)
end

function FullSubtractionShopWindow:ShopCellSelceted(cell)
    cell.selectObj:SetActive(true)  --青色选中状态
    cell.buyCountTrans.gameObject:SetActive(true)           --加减号数量文本
    cell.selectAddBtn.transform.gameObject:SetActive(false)  --选中‘加’号
    if cell.data.max_num ~= 0 then
        cell.restraintObj:SetActive(true)   --限购描述
    end
    cell.selectedImgObj:SetActive(true)  --勾选图标

    cell.transform:Find("PriceBg").anchoredPosition = Vector2(52, -2.1)
    cell.transform:Find("PriceBg").sizeDelta = Vector2(134.4, 24.7)

    --选中调用一次增加数量
    self:CountChange(self.OperateType.Add,cell)
end

function FullSubtractionShopWindow:CountChange(operateType,cell)

    if operateType == 1 then
        local showEffectFlag = true  -- 是否播放特效标志
        --增加购买数量
        if cell.data.max_num == 0 then
            cell.data.num = cell.data.num + 1
        else
            if cell.data.num < cell.data.max_num - cell.data.buyed_num then
                cell.data.num = cell.data.num + 1
            else
                showEffectFlag = false
                NoticeManager.Instance:FloatTipsByString(TI18N("已超过限购个数"))
            end
        end

        --播放飞过去的特效 &购物车抖动
        if showEffectFlag then
            self:ShowEffect(cell)
        end


    elseif operateType == 2 then
        if cell.data.num > 0 then
            cell.data.num = cell.data.num - 1
        end
    elseif operateType == 3 then 
        cell.data.num = NumberpadManager.Instance:GetResult()
    end

    --限购商品
    if cell.data.max_num ~= 0 then
        cell.restraintObj.transform:GetComponent(Text).text = string.format(TI18N("今日可购%s/%s个"), cell.data.max_num - cell.data.buyed_num - cell.data.num, cell.data.max_num)
    end

    --当前选择个数显示
    cell.count.text = cell.data.num

    -- 当前购买数量为1
    if cell.data.num == 0 then
        cell.selectObj:SetActive(false)
        cell.buyCountTrans.gameObject:SetActive(false)
        cell.selectAddBtn.transform.gameObject:SetActive(true)  --‘加减’号&数量文本
        cell.restraintObj:SetActive(false)
        cell.selectedImgObj:SetActive(false)

        cell.transform:Find("PriceBg").anchoredPosition = Vector2(34.5, -14.4)
        cell.transform:Find("PriceBg").sizeDelta = Vector2(99.4, 24.7)
    end


    local buy_list = {}
    for k,v in ipairs(self.shopCellList) do
        if v.data.num > 0 then
            table.insert(buy_list,v)
        end
    end

    local total_price = 0                --总价
    local discount_price = 0             --减免
    local need_price = 0                 --离下一档位
    local need_discount_price = 0        --离下一档位可减免

    for k,v in ipairs(buy_list) do
        local single_price = v.data.price * v.data.num
        total_price = single_price + total_price
    end

    --显示气泡
    self.qipao.gameObject:SetActive(true)

    local rebate_data = self.model.cellInfolist.rebate_info
    -- BaseUtils.dump(rebate_data,"rebate_data")

    --根据减免方案计算
    if total_price >= rebate_data[1].purchase_val and total_price < rebate_data[2].purchase_val then
        discount_price = rebate_data[1].rebate_val
        need_price = rebate_data[2].purchase_val - total_price
        need_discount_price = rebate_data[2].rebate_val - rebate_data[1].rebate_val

    elseif total_price >= rebate_data[2].purchase_val and total_price < rebate_data[3].purchase_val then
        discount_price = rebate_data[2].rebate_val
        need_price = rebate_data[3].purchase_val - total_price
        need_discount_price = rebate_data[3].rebate_val - rebate_data[2].rebate_val

    elseif total_price >= rebate_data[3].purchase_val then
        discount_price = rebate_data[3].rebate_val

        --不显示气泡
        self.qipao.gameObject:SetActive(false)
    else
        need_price = rebate_data[1].purchase_val - total_price
        need_discount_price = rebate_data[1].rebate_val
    end

    local cost_price = total_price - discount_price


    self.cell_buy_data = {b_l = buy_list, t_p = total_price , d_p = discount_price, n_p = need_price, n_d_p = need_discount_price, c_p = cost_price}

    -- BaseUtils.dump(self.cell_buy_data,"cell_buy_data")

    --下方减免描述同步更新
    self.DescExt:SetData(string.format("<color='#248813'>%s</color><color='#fff000'>%s</color>{assets_2,90002}<color='#248813'>%s</color><color='#fff000'>%s</color>{assets_2,90002}", TI18N("原价"), total_price, TI18N("减免"), discount_price))

    --气泡描述更新
    self.discountExt:SetData(string.format("%s<color='#fff000'>%s</color>%s%s<color='#fff000'>%s</color>{face_1,3}", TI18N("再买"), need_price, TI18N("钻"), TI18N("再减"), need_discount_price))

    --结算按钮描述更新
    if cost_price == 0 then
        self.costTxt:SetData(string.format("{assets_2,90002}<color='#906014'>%s</color>", TI18N("结 算")))
        self.accountBtn.transform.sizeDelta = Vector2(110, 45)
    else
        self.costTxt:SetData(string.format("<color='#906014'>%s</color>{assets_2,90002}<color='#906014'>%s</color>", cost_price, TI18N("结算")))
            self.accountBtn.transform.sizeDelta = Vector2(144, 45)
    end
end


function FullSubtractionShopWindow:ShowEffect(cell)
    --cd 冷却限制
    if not self.showEffectFlag then return end
    self.showEffectFlag = false

    local pos = cell.icon.transform.position
    local hk_pos = self.targetEffectPos

    self.tweenImg.gameObject:SetActive(true)

    local a = nil
    local h = nil
    local k = nil

    if pos.x < hk_pos.x then
        h = hk_pos.x
        k = hk_pos.y
        a = (pos.y - k)/((pos.x - h)*(pos.x - h))
    else
        h = pos.x
        k = pos.y
        a = (hk_pos.y - k)/((hk_pos.x - h)*(hk_pos.x - h))
    end


    self.tweenImg.position = pos
    self.tweenImg:GetComponent(Image).sprite = cell.icon.sprite

    --未完成取消并删除动画
    if self.tweenId1 ~= nil then
        Tween.Instance:Cancel(self.tweenId1)
        self.tweenId1 = nil
    end

    if self.tweenId2 ~= nil then
        Tween.Instance:Cancel(self.tweenId2)
        self.tweenId2 = nil
    end

    if self.tweenId3 ~= nil then
        Tween.Instance:Cancel(self.tweenId2)
        self.tweenId3 = nil
    end


    --购物车抖动
    local callback = function()
        self.tweenId2 = Tween.Instance:ValueChange(-360, 360, 0.2
            , function()
                Tween.Instance:Cancel(self.tweenId2)
                self.tweenId2 = nil
                self.showEffectFlag = true
            end
            , LeanTweenType.easeInSine
            ,function(value)
                self.shopCarTrans.localRotation = Quaternion.Euler(0, 0, math.sin(value/180*math.pi)*20)
                self.shopCarTrans.localPosition = Vector3(-191 - math.sin(value/180*math.pi)* 2, -202 + math.sin(value/180*math.pi)* 2 , 0)
            end).id
    end

    local callback2 = function()
        self.tweenId1 = Tween.Instance:ValueChange(pos.x, hk_pos.x, 0.4
            , function()
                Tween.Instance:Cancel(self.tweenId1)
                self.tweenId1 = nil
                self.tweenImg.gameObject:SetActive(false)
                -- 其它回调
                callback()
            end
            , LeanTweenType.easeInSine
            ,function(value)
                self.tweenImg.position = Vector3(value, a*(value - h)*(value - h) + k , 0)
                local scaleVal = math.abs((hk_pos.x - value) / (hk_pos.x - pos.x))
                scaleVal = 0.5*scaleVal + 0.5
                self.tweenImg.localScale = Vector3(scaleVal, scaleVal, scaleVal)
            end).id
    end

    self.tweenId3 = Tween.Instance:Scale(self.tweenImg.gameObject, Vector3(1.3,1.3,1.3), 0.5
            , function()
                Tween.Instance:Cancel(self.tweenId3)
                self.tweenId3 = nil
                -- 其它回调
                callback2()
            end
            , LeanTweenType.easeOutElastic).id


    -- local callback = function()
    --     if cell.effect ~= nil then
    --         cell.effect:DeleteMe()
    --         cell.effect = nil
    --     end

    --     local fun = function(effectView)
    --         local effectObject = effectView.gameObject
    --         effectObject.transform:SetParent(cell.transform)
    --         effectObject.name = "Effect"
    --         effectObject.transform.localScale = Vector3(1,1,1)
    --         effectObject.transform.localPosition = Vector3(58,-56,-400)
    --         effectObject.transform.localRotation = rotation or Quaternion.identity

    --         Utils.ChangeLayersRecursively(effectObject.transform, "UI")


    --         --特效作Tween动画
    --         cell.tweenId = Tween.Instance:Move(effectObject, self.targetEffectPos, 0.6
    --         , function()
    --             if cell.tweenId ~= nil then
    --                 Tween.Instance:Cancel(cell.tweenId)
    --                 cell.tweenId = nil
    --             end
    --         end, LeanTweenType.linear).id

    --     end
    --     cell.effect = BaseEffectView.New({effectId = 20471, time = nil, callback = fun})

    -- end

end


function FullSubtractionShopWindow:OnNumberpad(tab)
    local model = ShopManager.Instance.model

    
    local max_result = 9999
    if tab.data.max_num ~= 0 then
        max_result = tab.data.max_num - tab.data.buyed_num
    end
    self.numberpadSetting = {               -- 弹出小键盘的设置
        gameObject = tab.buyCountTrans:Find("CountBg").gameObject,
        min_result = 1,
        max_by_asset = max_result,
        max_result = max_result,
        textObject = tab.count,
        show_num = false,
        callback = function() self:CountChange(3,tab) end
    }
    NumberpadManager.Instance:set_data(self.numberpadSetting)
end