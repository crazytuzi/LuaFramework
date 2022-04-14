--- Created by Admin.
--- DateTime: 2019/11/6 20:30

QuickBuyPanel = QuickBuyPanel or class("QuickBuyPanel", BasePanel)


function QuickBuyPanel:ctor()
    self.abName = "quickBuy"
    self.assetName = "QuickBuyPanel"
    self.layer = "UI"
    self.use_background = true
    self.click_bg_close = true

    self.model = QuickBuyModel.GetInstance()

    self.curNum = 1 --当前购买数量
    self.price = 9 --单价
    self.is_select_bind = false  --是否选择绑定钻石
    self.quickConfig = nil --当前快捷购买配置
    self.itemIcon = nil  --物品icon
    self.jumpItems = {}  --跳转项
end

function QuickBuyPanel:dctor()
    self.data = nil
    if self.uiModel then
        self.uiModel:destroy()
        self.uiModel = nil
    end
    if self.itemIconSettor then
       self.itemIconSettor:destroy()
       self.itemIconSettor = nil
    end

    if self.jumpItems then
        for k,v in pairs(self.jumpItems) do
            v:destroy()
        end
        self.jumpItems = nil
    end

end

function QuickBuyPanel:LoadCallBack()
    self.nodes = {
        "left/name","left/pos","left/power",
        "mid/item/itemPos","mid/item/itemName","mid/item/itemPrice","mid/buyBtn",
        "mid/RechargeBtn","mid/price/priceNum","mid/money/Toggle","mid/money/Toggle1",
        "mid/buy/sub","mid/buy/add","mid/buy/cal","mid/buy/count",
        "right/ScrollView/Viewport/Content","right/rightItem","mid/price/icon1","mid/price/icon2",
        "close",
        "mid/item/itemIcon",
        "left/nameText/nText6","left/nameText/nText3","left/nameText/nText4","left/nameText/nText5","left/nameText/nText1","left/nameText/nText2",
        "left/valueText/vText5","left/valueText/vText4","left/valueText/vText3","left/valueText/vText6","left/valueText/vText2","left/valueText/vText1",
        "mid/item/icon3","mid/item/icon4",
    }
    self:GetChildren(self.nodes)
    self.leftNameTex = GetText(self.name)
    self.leftPowerTex = GetText(self.power)
    self.itemNameText = GetText(self.itemName)
    self.itemPriceTex = GetText(self.itemPrice)
    self.itemAllPriceTex = GetText(self.priceNum)
    self.countTex = GetText(self.count)

    self.tog1 = GetToggle(self.Toggle)
    self.tog2 = GetToggle(self.Toggle1)

    self.buyBtn = GetButton(self.buyBtn)
    self.rechargeBtn = GetButton(self.RechargeBtn)

    self.tog2.isOn = true

    for i=1,6 do
        self["nText"..i] = GetText(self["nText"..i])
        self["vText"..i] = GetText(self["vText"..i])
    end


    self:AddEvent()

    self:InitPanel()
end

function QuickBuyPanel:CloseCallBack()

end

function QuickBuyPanel:AddEvent()

    --关闭界面
    local function call_back()
        self:Close()
    end
    AddClickEvent(self.close.gameObject, call_back)
 

    --购买数量-1
    local function call_back()
       self:UpdateNum(self.curNum - 1)
    end
    AddClickEvent(self.sub.gameObject, call_back)

    --购买数量+1
    local function call_back()
        self:UpdateNum(self.curNum + 1)
    end
    AddClickEvent(self.add.gameObject, call_back)

    --打开数字键盘
    local function call_back()
        self.numKeyPad = lua_panelMgr:GetPanelOrCreate(NumKeyPad, self.count, handler(self, self.CheckInputCount), handler(self, self.CheckInputCount), handler(self, self.CheckInputCount), 2,-124.5,0)
        self.numKeyPad:Open()
    end
    AddClickEvent(self.cal.gameObject, call_back)
    AddClickEvent(self.count.gameObject, call_back)

    --充值按钮
    local function call_back()
        GlobalEvent:Brocast(VipEvent.OpenVipPanel, 2)
    end
    AddClickEvent(self.rechargeBtn.gameObject, call_back)

    --购买按钮
    local function call_back()
        local allPrice = self.price * self.curNum
        local bo

        local mallIds = self.quickConfig.mall_id
        mallIds = String2Table(mallIds)
        local mallId

        if not self.is_select_bind then
            bo = RoleInfoModel:GetInstance():CheckGold(allPrice, Constant.GoldType.Gold)
            mallId = mallIds[1][1]
        else
            local haveValue = RoleInfoModel.GetInstance():GetRoleValue(Constant.GoldType.BGold)
            
            bo = haveValue > allPrice

            if not bo then
                Notify.ShowText("Not enough bound diamonds")
            end

            mallId = mallIds[1][2]
        end

        if bo then
            GlobalEvent:Brocast(ShopEvent.BuyShopGoods, mallId, self.curNum)
        end
    end
    AddClickEvent(self.buyBtn.gameObject, call_back)

    --勾选钻石
    local function call_back(go, bool)
        if bool then
            self:UpdatePrice(false)
            self:UpdatePriceIcon(1)
        end
    end
    AddValueChange(self.Toggle.gameObject, call_back)

    --勾选绑定钻石
    local function call_back(go, bool)
        if bool then
            self:UpdatePrice(true)
            self:UpdatePriceIcon(2)
        end
    end
    AddValueChange(self.Toggle1.gameObject, call_back)

end

--data表里的数据：
-- id    玩家升级时选择的物品id
-- path  模型资源名
-- type  模型类型
-- name 名称
-- layer 阶级
-- star 星级
-- propTable 属性列表
function QuickBuyPanel:Open(data)
    self.data = data
    QuickBuyPanel.super.Open(self)
end

--初始化界面
function QuickBuyPanel:InitPanel()
    --获取快捷购买配置
    local config = Config.db_quick_buy
    for k,v in pairs(config) do
        if v.id == self.data.id then
            self.quickConfig = v
        end
    end
    if self.quickConfig then
        self:UpdatePrice(true)
        self:UpdatePriceIcon(2)
        self:UpdateNum(1)
        self:UpdateItemiconSettor()
        self:UpdateModelInfo()
        self:UpdateJumpItem()
    else
        logError("quick_buy 没有这个id = " .. self.data.id)
    end
end

--刷新物品单价数据
function QuickBuyPanel:UpdatePrice(isbind)
    self.is_select_bind = isbind
    if isbind then
        self.price = self.quickConfig.price
    else
        self.price = self.quickConfig.bprice
    end

    self.itemPriceTex.text = self.price
end

--刷新代币Icon
function QuickBuyPanel:UpdatePriceIcon(index)
    self.index = index
    SetVisible(self.icon1, index == 1)
    SetVisible(self.icon3, index == 1)
    SetVisible(self.icon2, index == 2)
    SetVisible(self.icon4, index == 2)
end

--刷新购买数量
function QuickBuyPanel:UpdateNum(targetNum)
    if targetNum < 1 or  targetNum > 999 then
        return
    end
    self.curNum = targetNum
    self.countTex.text = self.curNum
    self.itemAllPriceTex.text = self.curNum * self.price
end

--检查数字键盘输入的数量
function QuickBuyPanel:CheckInputCount()
    local count = tonumber(self.countTex.text)
    if count > 999 then
        count = 999
    end
    if count < 1 then
        count = 1
    end

    self:UpdateNum(count)
end

--刷新物品Icon
function QuickBuyPanel:UpdateItemiconSettor()
    
    self.itemIconSettor =  GoodsIconSettorTwo(self.itemIcon)

    local mallIds = self.quickConfig.mall_id
    mallIds = String2Table(mallIds)
    local mallConfig = Config.db_mall[mallIds[1][1]]
    local item = String2Table(mallConfig.item)
    local itemId = item[1]

	local param = {}
	param["item_id"] = itemId
    param["size"] = {x=80,y=80}
    param["bind"] = self.quickConfig.isbind
	param["can_click"] = true
	param["color_effect"] = 4
    param["effect_type"] = 2
	self.itemIconSettor:SetIcon(param)
end

--刷新模型与相关信息
function QuickBuyPanel:UpdateModelInfo(  )

    --模型
    local config = {};
    config.offset = { x = 4000, y = 0, z = 0 };
    config.far = 20
    

    if self.data.type == enum.ITEM_STYPE.ITEM_STYPE_MOUNT_MORPH then
        config.rotate = { x = 0, y = 135, z = 0 };
        config.scale = 50
    elseif  self.data.type == enum.ITEM_STYPE.ITEM_STYPE_OFFHAND_MORPH then
        config.scale = 60
        config.offset.y = 45
        config.rotate = { x = 0, y = 0, z = 0 };
    end

    self.uiModel = UIMountCamera(self.pos, nil, self.data.path, self.data.type,nil,false);
    self.uiModel:SetConfig(config)


    --名称
    local name = self.data.name.."."
    if self.data.layer then
        name = name .. self.data.layer .. "Stage"
    else
        name = name .. self.data.star .. "Star"
    end
    self.leftNameTex.text = name

    --战力
    local power = GetPowerByConfigList(self.data.propTable)
    self.leftPowerTex.text = power

    --属性
    local index = 1
    for k,v in pairs(self.data.propTable) do
        local nText = self["nText"..index]
        local vText = self["vText"..index]
        SetVisible(nText,true)
        SetVisible(vText,true)

        --属性名
        local name = self.model:GetAttrNameByIndex(v[1])
        nText.text = name..":"

        local value = v[2]
        local valueType = Config.db_attr_type[v[1]].type == 2
        if valueType then
            --处理百分比属性
            value = (value / 100) .. "%"
        end
        vText.text = value

        index = index + 1

    end
end

--刷新跳转
function QuickBuyPanel:UpdateJumpItem(  )
    local jumpTables = self.quickConfig.jump
    jumpTables = String2Table(jumpTables)

    local is_recom = self.quickConfig.is_recom
    is_recom = String2Table(is_recom)

    for k,v in pairs(jumpTables) do

        if type(v[2]) == "table" then
            --活动id
            local activityId = v[1]

            if OperateModel.GetInstance():GetAct(activityId) then
                --活动已开启 显示跳转项
                local jumpItem = RightItem(self.rightItem.gameObject,self.Content,"UI")
                table.insert( self.jumpItems, jumpItem )
        
                local data = {}
                data.jumpTable = v[2]
                data.IsRecom = is_recom[k] == 1
                jumpItem:SetData(data,self)
            end
        else
            local jumpItem = RightItem(self.rightItem.gameObject,self.Content,"UI")
            table.insert( self.jumpItems, jumpItem )
    
            local data = {}
            data.jumpTable = v
            data.IsRecom = is_recom[k] == 1
            jumpItem:SetData(data,self)
        end

       
    end
end

--选中跳转项
function QuickBuyPanel:SelectJumpItem(selectedItem)
    for k,v in pairs(self.jumpItems) do
        v:Select(v == selectedItem)
    end
end







