--
-- @Author: lwj
-- @Date:  2018-11-12 16:31:46
--
ShopPanel = ShopPanel or class("ShopPanel", WindowPanel)
local ShopPanel = ShopPanel

function ShopPanel:ctor()
    self.abName = "shop"
    self.assetName = "ShopPanel"
    self.layer = "UI"
    self.title = "title"
    --选中物品时，content移动相关
    self.ignoreNum = 4
    self.line_num = 4
    self.first_item_height = 181.5
    self.isMovingContent = false
    self.content_anchored_x = 0
    self.is_hide_other_panel = true

    self.panel_type = 7

    self.model = ShopModel.GetInstance()
    if self.model.isCloseOther then
        self.is_hide_other_panel = true
    end
    --self.show_sidebar = true        --是否显示侧边栏
    self.is_loading_model = false
    self.curPanel = 1
    self.is_first_open = true
    self:Reset()
end

function ShopPanel:Reset()
    self.slotItemList = {}                      --商品列表
    self.willLoadList = {}
    self.checkTiems = 0
    self.lastX = 0
    self.line_height = 94.7
end

function ShopPanel:dctor()
end

function ShopPanel:Open(label_id, top_toggle_id, shop_id, is_goods_id)
    self.default_toggle_index = top_toggle_id
    if is_goods_id then
        self.model.default_shop_id = self.model:GetMallIdByItemId(shop_id)
    else
        self.model.default_shop_id = shop_id
    end
    if label_id then
        self.default_table_index = label_id
    end
    WindowPanel.Open(self)
end

function ShopPanel:LoadCallBack()
    self.nodes = {
        "RightContainer/Count_Group/num",
        "RightContainer/Count_Group/plus_btn",
        "RightContainer/Count_Group/minus_btn",
        "RightContainer/Count_Group/keypad_btn",
        "TopScrollView/Viewport/TopContent",
        "LeftContent/Viewport/SlotContent",
        "LeftContent/Viewport/SlotContent/ShopItem",
        "LeftContent", "RELAX",
        "RightContainer",
        "tips","RightContainer/TextCount_3","RightContainer/TextCount_1","RightContainer/TextCount_2",
        "RightContainer/have_diamond/haveIcon",
        "RightContainer/sum_Price/sumIcon",
        -- "RightContainer/desTitlePos/des",
        "RightContainer/desTitlePos/Scroll View/Viewport/Content/des",
        "RightContainer/desTitlePos/icon",
        "RightContainer/desTitlePos/RTex/remain",
        "RightContainer/desTitlePos/RTex",
        "RightContainer/desTitlePos/level",
        "RightContainer/desTitlePos",
        "RightContainer/desTitlePos/itemName",
        "RightContainer/sum_Price/sumprice",        "RightContainer/sum_Price",
        "RightContainer/have_diamond/HDiamond",        "RightContainer/have_diamond",
        "RightContainer/Count_Group",
        "RightContainer/buy_btn",
        "RightContainer/Count_Group/numBg",
        "RightContainer/Count_Group/minus_btn/minus_Grey",
        "RightContainer/roleTitlePos/roleTitleName",
        "RightContainer/roleTitlePos",
        "RightContainer/roleTitlePos/role_con",
        "RightContainer/have_diamond/getDiamond_btn",
    }
    self:GetChildren(self.nodes)
    self.input = self.num:GetComponent('Text')
    self.nameT = self.itemName:GetComponent('Text')
    self.roleTitleNameT = self.roleTitleName:GetComponent('Text')
    self.levelT = self.level:GetComponent('Text')
    self.desT = self.des:GetComponent('Text')
    self.remainT = self.remain:GetComponent('Text')
    self.sumPriceT = self.sumprice:GetComponent('Text')
    self.sumIconI = self.sumIcon:GetComponent('Image')
    self.haveIconI = self.haveIcon:GetComponent('Image')
    self.HDiamondT = self.HDiamond:GetComponent('Text')
    self.left_cont_rect = GetRectTransform(self.SlotContent)
    self.rest_tip_title = GetText(self.RTex)

    self.scroll = GetScrollRect(self.LeftContent)
    self.content_rect = GetRectTransform(self.SlotContent)
    self.content_anchored_x = self.content_rect.anchoredPosition.x

    self.shop_item_obj = self.ShopItem.gameObject
    --self:SwitchCallBack(1)
    self:AddEvent()

end

function ShopPanel:BindRoleBalanceUpdate()
    local function call_back(typ)
        --if self.model.curMallType ~= "1,1" and typ == self.moneyType then
        if self.model.curMallType ~= "1,1" then
            self:UpdateHaveDiamText()
            self:CalculateSumPrice()
        end
    end
    self.boss_event_id = RoleInfoModel:GetInstance():GetMainRoleData():BindData(Constant.GoldType.BossScore, call_back, Constant.GoldType.BossScore)
    self.gold_event_id = RoleInfoModel:GetInstance():GetMainRoleData():BindData(Constant.GoldType.Gold, call_back, Constant.GoldType.Gold)
    self.diamond_event_id = RoleInfoModel:GetInstance():GetMainRoleData():BindData(Constant.GoldType.BGold, call_back, Constant.GoldType.BGold)
    self.honor_event_id = RoleInfoModel:GetInstance():GetMainRoleData():BindData(Constant.GoldType.Honor, call_back, Constant.GoldType.Honor)
end

function ShopPanel:AddEvent()
    self.scroll.onValueChanged:AddListener(handler(self, self.ResetMoveMentType))
    local function callback()
        if self.curPanel == 4 then
            lua_panelMgr:GetPanelOrCreate(AthleticsPanel):Open()
        elseif self.curPanel == 5 then
            lua_panelMgr:GetPanelOrCreate(DungeonPanel):Open()
        else
            GlobalEvent:Brocast(VipEvent.OpenVipPanel, 2)
        end
    end
    AddButtonEvent(self.getDiamond_btn.gameObject, callback)

    --数量加减点击事件
    local function call_back()
        local curNum = tonumber(self.input.text)
        curNum = curNum + 1
        self.input.text = curNum
        local isOk = self:CheckInputCount()
        if isOk == false then
            Notify.ShowText(ConfigLanguage.Shop.MaximumAmount)
        end
        self:CalculateSumPrice()
        if curNum > 1 and isOk then
            SetVisible(self.minus_Grey, false)
        end
    end
    AddButtonEvent(self.plus_btn.gameObject, call_back)

    local function call_back()
        local curNum = tonumber(self.input.text)
        if curNum > 1 then
            curNum = curNum - 1
            self.input.text = curNum
            self:CalculateSumPrice()
        end
        if curNum < 2 then
            SetVisible(self.minus_Grey, true)
        end
    end
    AddButtonEvent(self.minus_btn.gameObject, call_back)

    --购买
    local function call_back()
        if not self.isCanBuy then
            Notify.ShowText("<color=#E63232>Vip level not enough</color>")
            return
        end
        local paymentTypeId = String2Table((Config.db_mall[self.model.curId]).price)[1]
        local typeName = ShopModel:GetInstance():GetTypeNameById(paymentTypeId)
        local roleBalance = RoleInfoModel:GetInstance():GetRoleValue(typeName)
        if roleBalance then
            --if roleBalance == 0 then
            --
            --    return
            --end
            local allprice = tonumber(String2Table((Config.db_mall[self.model.curId]).price)[2]) * tonumber(self.input.text)
            if paymentTypeId == 90010004 and roleBalance < allprice then
                local name = ShopModel:GetInstance():GetTypeNameById(90010003)
                roleBalance = RoleInfoModel:GetInstance():GetRoleValue(name)
            end

            if roleBalance >= allprice then
                --足够购买
                local limit = Config.db_mall[self.model.curId].limit_num
                if self.model.curLimit then
                    if limit - self.model.curLimit == 0 then
                        Notify.ShowText(ConfigLanguage.Shop.RestAmountIsNotEnough)
                        return
                    end
                end
                local curLimitNum = self:GetgmatchStr(Config.db_mall[self.model.curId].limit_num)
                if curLimitNum ~= '0' then
                    self.model.isRecivingSingle = true
                end
                GlobalEvent:Brocast(ShopEvent.BuyShopGoods, tonumber(self.model.curId), tonumber(self.input.text))

                self.input.text = "1"
                SetVisible(self.minus_Grey, true)
                self:UpdateHaveDiamText()
                self:CalculateSumPrice()
            else
                local typeName = String2Table((Config.db_mall[self.model.curId]).price)[1]
                local name = Config.db_item[typeName].name
                local tips = string.format(ConfigLanguage.Shop.BalanceNotEnough, name)
                if typeName ~= 90010003 and typeName ~= 90010004 then
                    tips = string.format(ConfigLanguage.Shop.OtherNotEnough, name)
                    local str = string.format("<color=#%s>%s</color>", ColorUtil.GetColor(ColorUtil.ColorType.Red), tips)
                    Notify.ShowText(str)
                else
                    local function callback()
                        GlobalEvent:Brocast(VipEvent.OpenVipPanel, 2)
                    end
                    Dialog.ShowTwo("Tip", tips, "Confirm", callback, nil, "Cancel", nil, nil, nil, false, false);
                end
            end
        end
    end
    AddButtonEvent(self.buy_btn.gameObject, call_back)

    --数字键盘点击
    local function call_back()
        self.numKeyPad = lua_panelMgr:GetPanelOrCreate(NumKeyPad, self.num, handler(self, self.ClickCheckInput), handler(self, self.ClickCheckInput), handler(self, self.ClickCheckInput), 2)
        self.numKeyPad:Open()
    end
    AddButtonEvent(self.keypad_btn.gameObject, call_back)
    AddButtonEvent(self.numBg.gameObject, call_back)

    self.global_event = {}
    self.global_event[#self.global_event + 1] = GlobalEvent:AddListener(ShopEvent.GoodItemClick, handler(self, self.ShopItemClick))
    self.global_event[#self.global_event + 1] = GlobalEvent:AddListener(ShopEvent.HandelShopBoughtList, handler(self, self.HandleGoodsLoad))
    self.global_event[#self.global_event + 1] = GlobalEvent:AddListener(ShopEvent.HandleSingleBought, handler(self, self.UpdateShopItemLimit))
    self.global_event[#self.global_event + 1] = GlobalEvent:AddListener(ShopEvent.UpdatePanelReaminText, handler(self, self.UpdateReaminText))

    local function callback()
        self:SetIndexRedDotParam(1, false)
    end
    self.global_event[#self.global_event + 1] = GlobalEvent:AddListener(ShopEvent.CancleShopRedDot, callback)

    self.model_event = {}
    self.model_event[#self.model_event + 1] = self.model:AddListener(ShopEvent.ShowShopPanelContains, handler(self, self.ShowShopContainers))
    self.model_event[#self.model_event + 1] = self.model:AddListener(ShopEvent.UpdateLeftContenetPos, handler(self, self.LocateToSelItemPos))
    self.model_event[#self.model_event + 1] = self.model:AddListener(ShopEvent.MoveContentWhenSelect, handler(self, self.CheckIsNeedMoveContent))

    --local call_back = function(target, x, y)
    --    if self.lastX == 0 then
    --        self.lastX = x;
    --        return ;
    --    end
    --    local x1 = x - self.lastX;
    --    self.role_model.transform:Rotate(0, -x1, 0);
    --    self.lastX = x;
    --end
    --AddDragEvent(self.dragImg.gameObject, call_back);
    --
    --local call_back = function(target, x, y)
    --    self.lastX = 0;
    --end
    --AddDragEndEvent(self.dragImg.gameObject, call_back);
end

function ShopPanel:OpenCallBack()
    self:BindRoleBalanceUpdate()
    self:SetTitleImgPos(-307, 274.9)
end

function ShopPanel:CheckIsNeedMoveContent(index)
    if index > self.ignoreNum then
        self:StartMoveContent(index - self.ignoreNum)
    end
end

function ShopPanel:StartMoveContent(index)
    local line = math.ceil(index / self.line_num)
    local move_dis = line * self.first_item_height
    self.isMovingContent = true
    self.scroll.movementType = UnityEngine.UI.ScrollRect.MovementType.Unrestricted
    cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.content_rect)
    local time = 0.2
    local moveAction = cc.MoveTo(time, self.content_anchored_x, move_dis, 0)
    local function end_call_back()
        self.isMovingContent = false
    end
    local call_action = cc.CallFunc(end_call_back)
    local sys_action = cc.Sequence(moveAction, cc.DelayTime(0.2), call_action)
    cc.ActionManager:GetInstance():addAction(sys_action, self.content_rect)
end

function ShopPanel:ResetMoveMentType()
    if not self.isMovingContent then
        self.scroll.movementType = UnityEngine.UI.ScrollRect.MovementType.Elastic
    end
end

function ShopPanel:Close()
    if self.model.curMallType == "1,1" then
        local content_Data = { pos = { -10, 5 }, size = { 454, 150 } }
        local toggle_Data = { -54, -69 }

        if self.model.is_check or (not self.model:IsHavaFlashSaleItem()) then
            self:OrginalClose()
        else
            local function ok_fun(is_check)
                self.model.is_check = is_check
                self:OrginalClose()
            end
            Dialog.ShowTwo("Tip", "Warrior, are you sure to leave? \nThis discount is very rare to see <color=#ec1c1c>or you will wait for a long time</color>", "Confirm", ok_fun, nil, "Cancel", nil, nil, "Don't notice anymore until next time I log in", false, false, "Shop_Panel", content_Data, toggle_Data);
        end
    else
        self:OrginalClose()
    end
end

function ShopPanel:OrginalClose()
    lua_panelMgr:ToClosePanel(self)
    if not self.is_exist_always then
        self.isShow = false
        self:CloseCallBack()
        self:destroy()
    else
        self.isShow = false
        SetVisible(self.gameObject, false)
    end
    GlobalEvent:Brocast(EventName.OpenNextSysTipPanel)
end

function ShopPanel:UpdateReaminText(num)
    self.remainT.text = tostring(num)
end

function ShopPanel:UpdateShopItemLimit()
    local list = self.model.goodsSingelBought
    if list then
        for i, v in pairs(list) do
            for ii, vv in pairs(self.slotItemList) do
                if vv.data.mallData.id == i then
                    vv:UpdateLimitText(v)
                end
            end
        end
    end
end

function ShopPanel:UpdateHaveDiamText()
    local typeName = ShopModel:GetInstance():GetTypeNameById(self.model:GetCurPanymentType())
    local roleBalance = RoleInfoModel:GetInstance():GetRoleValue(typeName)
    if not roleBalance then
        roleBalance = 0
    end
    if self.HDiamondT then
        self.HDiamondT.text = tostring(roleBalance)
    end
    local curPaymentType = self.model:GetCurPanymentType()
    local icon = Config.db_item[curPaymentType].icon
    if self.sumIconI then
        if self.model.curMallType == "2,2" then
            GoodIconUtil:CreateIcon(self, self.sumIconI, "90010004", true)
        else
            if self.sumIconI.sprite.name ~= tostring(icon) .. "(Clone)" then
                GoodIconUtil:CreateIcon(self, self.sumIconI, icon, true)
            end
        end
    end
    if self.haveIconI then
        if self.model.curMallType == "2,2" then
            GoodIconUtil:CreateIcon(self, self.haveIconI, "90010004", true)
        else
            if self.haveIconI.sprite.name ~= tostring(icon) .. "(Clone)" then
                GoodIconUtil:CreateIcon(self, self.haveIconI, icon, true)
            end
        end
    end
end

function ShopPanel:SwitchCallBack(index, toggle_id)
    --  self:SetTileTextImage("shop_image", "Shop_Title_" .. tostring(index), false)
    if self.is_first_open then
        self.is_first_open = false
        return
    end
    self:CleanSlotList()
    self.model.curMallType = index .. "," .. toggle_id
    if self.child_node then
        self.child_node:SetVisible(false)
    end
    SetVisible(self.RELAX, not (index == 3))
    if index == 1 and toggle_id == 2 then
        SetVisible(self.tips, true)
    else
        SetVisible(self.tips, false)
    end
    if index == 1 and toggle_id == 1 then
        if not self.flashSalePanel then
            self.flashSalePanel = FlashSalePanel(self.child_transform, "UI")
        end
        self:PopUpChild(self.flashSalePanel)
        SetVisible(self.LeftContent, false)
        SetVisible(self.RightContainer, false)
        return
    end
    GlobalEvent:Brocast(ShopEvent.GetShopItemList)
    self.default_table_index = nil
    if index == 3 then
        if toggle_id == 1 then
            self.curPanel = 4
        end
        if toggle_id == 2 then
            self.curPanel = 5
        end
    else
        self.curPanel = 1
    end
end

function ShopPanel:GetToggleDataByID(switch_index)
    local sidebar_data = self:GetSidebarDataByID(switch_index)
    if not sidebar_data or not sidebar_data.toggle_data then
        return
    end
    if sidebar_data.id == 1 then
        local num = self.model:GetFlashSaleListNums()
        if num < 1 and sidebar_data.toggle_data[1].text == "Snap up" then
            --没有限购
            self.model.flash_sale_side_data = sidebar_data.toggle_data[1]
            sidebar_data.toggle_data[1] = sidebar_data.toggle_data[2]
            sidebar_data.toggle_data[2] = nil
        else
            if not sidebar_data.toggle_data[2] and num > 0 then
                sidebar_data.toggle_data[2] = sidebar_data.toggle_data[1]
                sidebar_data.toggle_data[1] = self.model.flash_sale_side_data
            end
        end
    end
    local toggle_data = sidebar_data.toggle_data
    local data = {}
    local len = #toggle_data
    for i = 1, len do
        local info = toggle_data[i]
        if IsOpenModular(info.show_lv, info.show_task) then
            data[#data + 1] = info
        end
    end
    return data
end

function ShopPanel:HandleGoodsLoad()
    local mallStr = ""
    local vStr = ""
    local mall_type = self.model.curMallType
    if mall_type ~= nil then
        mallStr = self:GetgmatchStr(mall_type)
    end
    local con_interator = table.pairsByKey(Config.db_mall)
    --取得要加载的物品的列表
    local min_order = nil
    local my_lv = RoleInfoModel.GetInstance():GetMainRoleLevel()
    local first_list = {}
    for i, v in con_interator do
        vStr = self:GetgmatchStr(v.mall_type)
        if vStr == mallStr and v.limit_level <= my_lv then
            first_list[v.order] = v
            if not min_order then
                min_order = v.order
            elseif v.order < min_order then
                min_order = v.order
            end
            --table.insert(self.willLoadList, v)
        end
    end
    local inte = table.pairsByKey(first_list)
    for i, v in inte do
        if my_lv >= v.limit_level then
            self.willLoadList[#self.willLoadList + 1] = v
        end
    end
    self.model.min_order = min_order
    --取得物品数据
    local dataList = {}
    local itemData = {}
    local len = #self.willLoadList
    self.model.shop_goods_num = len
    for i = 1, len do
        itemData = {}
        itemData.mallData = self.willLoadList[i]
        itemData.boughtRecord = self.model:GetGoodsBoRecordById(itemData.mallData.id)
        itemData.index = i
        dataList[i] = itemData
    end
    --加载
    self.slotItemList = self.slotItemList or {}
    local len = #dataList
    for i = 1, len do
        local item = self.slotItemList[i]
        if not item then
            item = ShopItem(self.shop_item_obj, self.SlotContent)
            self.slotItemList[i] = item
            --local x = 0
            --local y = -(i-1) * 150
            --item:SetPosition(x, y)
            --item:SetCallBack(callback)
        else
            item:SetVisible(true)
        end
        item:SetData(dataList[i])
    end
    for i = len + 1, #self.slotItemList do
        local item = self.slotItemList[i]
        item:SetVisible(false)
    end

    self:CloseFlashPanel()
    self.willLoadList = {}
end

function ShopPanel:GetgmatchStr(str)
    local vStr = ""
    for word in string.gmatch(str, "%d+") do
        vStr = vStr .. word
    end
    return vStr
end

function ShopPanel:ShopItemClick(data, isCanBuy)
    self.isCanBuy = isCanBuy
    local mall_cf = Config.db_mall[data.id]
    local itemId = String2Table(mall_cf.item)[1]

    if self.model.curMallType == '2,3' then
        SetVisible(self.desTitlePos, false)
        SetVisible(self.roleTitlePos, true)
        self.roleTitleNameT.text = Config.db_item[itemId].name
        local model_tbl = String2Table(mall_cf.model)
        self:LoadRoleModel(model_tbl)

        --self.role_model:SetDragViewPosition(-2, -3)
        --self.role_model:SetDragViewSize(310, 500)
    else
        SetVisible(self.desTitlePos, true)
        SetVisible(self.roleTitlePos, false)

        local id = itemId
        local gender = RoleInfoModel.GetInstance():GetSex()
        if type(itemId) == "table" then
            id = itemId[gender]
        end
        local colorNum = Config.db_item[id].color
        local str = string.format("<color=#%s>%s</color>", ColorUtil.GetColor(colorNum), Config.db_item[id].name)
        self.nameT.text = str
        self.levelT.text = Config.db_item[id].level
        self.desT.text = Config.db_item[id].desc
        if self.itemIcon then
            self.itemIcon:destroy()
        end

        local param = {}
        local operate_param = {}
        param["item_id"] = id
        param["model"] = self.model
        param["can_click"] = true
        param["operate_param"] = operate_param
        param["size"] = { x = 80, y = 80 }
        self.itemIcon = GoodsIconSettorTwo(self.icon)
        self.itemIcon:SetIcon(param)
    end
    local mall_cf = Config.db_mall[data.id]
    local limit = mall_cf.limit_num
    local leftNum = nil
    if limit ~= 0 then
        leftNum = limit - self.model.curLimit
    end
    if limit == 0 then
        SetVisible(self.RTex, false)
    else
        if mall_cf.refresh == 1 then
            self.rest_tip_title.text = ConfigLanguage.Shop.CurDayRest
        elseif mall_cf.refresh == 2 then
            self.rest_tip_title.text = ConfigLanguage.Shop.CurWeekRest
        end
        SetVisible(self.RTex, true)
        self.remainT.text = data.remain
    end
    if leftNum == 0 then
        self.input.text = "0"
    elseif tonumber(self.input.text) ~= 1 then
        self.input.text = 1
    end
    SetVisible(self.minus_Grey, true)
    self:CalculateSumPrice()
    self:UpdateHaveDiamText()
    self.default_toggle_index = nil
end

function ShopPanel:LoadRoleModel(model_tbl)
    if self.is_loading_model then
        return
    end
    self.is_loading_model = true
    local role = RoleInfoModel.GetInstance():GetMainRoleData()
    local data = {}
    local gender = RoleInfoModel.GetInstance():GetSex()
    data = clone(role)
    local config = {}
    if model_tbl ~= nil and (not table.isempty(model_tbl)) and model_tbl ~= "" then
        for i = 1, #model_tbl do
            local key = model_tbl[i]
            local tbl = string.split(key, '@')
            local model_id
            local model_cf = Config.db_fashion[key]
            if tbl[2] == '1' then
                model_id = gender == 1 and model_cf.man_model or model_cf.girl_model
                data.figure['fashion_clothes'] = {}
                data.figure["fashion_clothes"].model = model_id
                data.figure["fashion_clothes"].show = true
            elseif tbl[2] == '2' then
                model_id = gender == 1 and model_cf.man_model or model_cf.girl_model
                data.figure.fashion_head = {}
                data.figure.fashion_head.model = model_id
                data.figure.fashion_head.show = true
            elseif tbl[2] == '3' then
                model_id = gender == 1 and model_cf.man_model or model_cf.girl_model
                data.figure.weapon = {}
                data.figure.weapon.model = model_id
                data.figure.weapon.show = true
            end
        end
    end
    config.is_show_wing = false
    local function callback()
        self.is_loading_model = false
    end
    if not self.role_model then
        self.role_model = UIRoleCamera(self.role_con, nil, data, 1, nil, nil, config)
    else
        self.role_model:ReLoadModel(data)
    end
    self.role_model:AddLoadCallBack(callback)
    if not self.is_setted_layer then
        LayerManager.GetInstance():AddOrderIndexByCls(self, self.TextCount_1, nil, true, nil , 1, 50)
        LayerManager.GetInstance():AddOrderIndexByCls(self, self.TextCount_2, nil, true, nil , 1, 51)
        LayerManager.GetInstance():AddOrderIndexByCls(self, self.TextCount_3, nil, true, nil , 1, 52)
        LayerManager.GetInstance():AddOrderIndexByCls(self, self.sum_Price, nil, true, nil , 1, 53)
        LayerManager.GetInstance():AddOrderIndexByCls(self, self.have_diamond, nil, true, nil , 1, 54)
        LayerManager.GetInstance():AddOrderIndexByCls(self, self.Count_Group, nil, true, nil , 1, 55)
        LayerManager.GetInstance():AddOrderIndexByCls(self, self.buy_btn, nil, true, nil , 1, 56)
        self.is_setted_layer=true
    end
end

function ShopPanel:ClickCheckInput()
    if not self:CheckInputCount() then
        Notify.ShowText(ConfigLanguage.Shop.MaximumAmount)
    end
    self:CalculateSumPrice()
end

function ShopPanel:CalculateSumPrice()
    local count = tonumber(self.input.text)
    local sum = count * tonumber(self.model:GetCurSinglePrice())
    self.sumPriceT.text = sum
    local paymentTypeId = String2Table((Config.db_mall[self.model.curId]).price)[1]
    local typeName = ShopModel:GetInstance():GetTypeNameById(paymentTypeId)
    self.moneyType = typeName
    local roleBalance = RoleInfoModel:GetInstance():GetRoleValue(typeName)
    if roleBalance then
        if sum > roleBalance then
            SetColor(self.sumPriceT, 255, 0, 0, 255)
        else
            SetColor(self.sumPriceT, 173, 110, 71, 255)
        end
    end
end

function ShopPanel:CheckInputCount()
    local temp = tonumber(self.input.text)
    local conTbl = Config.db_mall[self.model.curId]
    local limit = conTbl.limit_num
    local bought = self.model.curLimit

    if tonumber(limit) == 0 then
        local once_limit_num = 300
        local priceTbl = String2Table(conTbl.price)
        local needMoney = priceTbl[2] * temp
        local typeName = ShopModel:GetInstance():GetTypeNameById(priceTbl[1])
        local curMoney = RoleInfoModel:GetInstance():GetRoleValue(typeName)
        if curMoney < needMoney or temp > once_limit_num then
            local rest = curMoney % priceTbl[2]
            local finalText = (curMoney - rest) / priceTbl[2]
            if finalText >= once_limit_num then
                self.input.text = once_limit_num
            else
                self.input.text = finalText
            end
            if self.input.text == "0" then
                self.input.text = 1
            end
            return false
        end
    else
        --有限购
        if temp > tonumber(limit) - tonumber(bought) then
            self.input.text = tonumber(limit) - tonumber(bought)
            if self.input.text == "0" then
                self.input.text = 1
            end
            return false
        end
    end
    self.input.text = temp
    return true
end

function ShopPanel:CloseCallBack()
    self.model.isCloseOther = false
    self:CleanSlotList()
    self:CloseFlashPanel()
    if self.numKeyPad then
        self.numKeyPad = nil
    end
    if self.gold_event_id then
        RoleInfoModel:GetInstance():GetMainRoleData():RemoveListener(self.gold_event_id)
        self.gold_event_id = nil
    end
    if self.diamond_event_id then
        RoleInfoModel:GetInstance():GetMainRoleData():RemoveListener(self.diamond_event_id)
        self.diamond_event_id = nil
    end
    if self.honor_event_id then
        RoleInfoModel:GetInstance():GetMainRoleData():RemoveListener(self.honor_event_id)
        self.honor_event_id = nil
    end

    if self.boss_event_id then
        RoleInfoModel:GetInstance():GetMainRoleData():RemoveListener(self.boss_event_id)
        self.boss_event_id = nil
    end

    self:DestroyRoleModel()
    if self.itemIcon then
        self.itemIcon:destroy()
    end

    if self.model_event then
        for i, v in pairs(self.model_event) do
            self.model:RemoveListener(v)
        end
        self.model_event = {}
    end

    if self.global_event then
        for i, v in pairs(self.global_event) do
            GlobalEvent:RemoveListener(v)
        end
        self.global_event = {}
    end

end

function ShopPanel:DestroyRoleModel()
    if self.role_model ~= nil then
        self.role_model:destroy()
        self.role_model = nil
    end
end

function ShopPanel:CleanSlotList()
    if self.slotItemList and table.nums(self.slotItemList) > 0 then
        for i, v in pairs(self.slotItemList) do
            if v then
                v:destroy()
            end
        end
        self.slotItemList = {}
    end
end

function ShopPanel:CloseFlashPanel()
    if self.flashSalePanel then
        self.flashSalePanel:destroy()
        self.flashSalePanel = nil
    end
end

--定位到指定物品的位置
function ShopPanel:LocateToSelItemPos(shop_id)
    if not shop_id then
        return
    end
    local index = nil
    local tbl = self.slotItemList
    for i = 1, #tbl do
        if tbl[i].data.mallData.id == shop_id then
            index = i
            return
        end
    end
    if not index then
        return
    end
    if index <= 10 then
        return
    else
        local page = math.floor(index / 10)
        local line = math.ceil((index % 10) / 2)
        local dis = (page * 473.5) + (line * self.line_height)
        SetAnchoredPosition(self.left_cont_rect, 0, dis)
    end
end

function ShopPanel:ShowShopContainers()
    SetVisible(self.LeftContent, true)
    SetVisible(self.RightContainer, true)
end