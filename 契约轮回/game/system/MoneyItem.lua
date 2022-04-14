-- 
-- @Author: LaoY
-- @Date:   2018-08-23 21:15:38
-- 
MoneyItem = MoneyItem or class("MoneyItem", BaseWidget)
local MoneyItem = MoneyItem

function MoneyItem:ctor(parent_node, builtin_layer, key)
    self.abName = "system"
    self.assetName = "MoneyItem"
    -- 场景对象才需要修改
    -- self.builtin_layer = builtin_layer

    if (type(key) == "table") then
        self.key = key[1]
        self.btnVisible = key[2]
    else
        self.key = key
    end

    MoneyItem.super.Load(self)
end

function MoneyItem:dctor()
    if self.event_id then
        RoleInfoModel:GetInstance():RemoveListener(self.event_id)
        self.event_id = nil
    end
    if self.money_event_id then
        self.role_data:RemoveListener(self.money_event_id)
        self.money_event_id = nil
    end
    if self.global_event_list then
        GlobalEvent:RemoveTabListener(self.global_event_list)
        self.global_event_list = {}
    end
end

function MoneyItem:LoadCallBack()
    self.nodes = {
        "text", "img_icon", "btn_add",
    }
    self:GetChildren(self.nodes)
    self.img_icon_component = self.img_icon:GetComponent('Image')
    self.text_component = self.text:GetComponent('Text')
    self:AddEvent()

    -- 如果配置的是特殊道具，特殊处理。比如配置的是元宝道具id 要换成身上的字段
    if self.key == nil then

    end
    if self.key and type(self.key) == "string" then
        --local assetName = "img_gold_2"
        --if self.key == Constant.GoldType.Gold then
        --    assetName = "img_money_gold"
        --elseif self.key == Constant.GoldType.BGold then
        --    assetName = "img_money_b_gold"
        --elseif self.key == Constant.GoldType.Coin then
        --    assetName = "img_money_coin"
        --else
        --    assetName = nil
        local itemId = Constant.GoldTypeMap[self.key]
        if (itemId) then
            self:SetIconByItemId(itemId)
        end
        --end
        --if (assetName) then
        --    lua_resMgr:SetImageTexture(self, self.img_icon_component, "system_image", assetName)
        --end
        self:AddMoneyEventListener()
        self:SetValue()
    elseif self.key and type(self.key) == "number" then
        self:SetIconByItemId(self.key)
        self:BindGoods()
        self:SetValue()
    end

    if (self.btnVisible ~= nil and type(self.btnVisible) == "boolean") then
        SetVisible(self.btn_add, self.btnVisible)
    end
end

function MoneyItem:SetIconByItemId(itemId)

    local config = Config.db_item[itemId]
    if config then
        local abName = GoodIconUtil.GetInstance():GetABNameById(config.icon)
        abName = "iconasset/" .. abName
        lua_resMgr:SetImageTexture(self, self.img_icon_component, abName, tostring(config.icon), true)
    end

end

function MoneyItem:AddMoneyEventListener()
    self.role_data = RoleInfoModel:GetInstance():GetMainRoleData()
    if not self.role_data then
        local function call_back()
            self.role_data = RoleInfoModel:GetInstance():GetMainRoleData()
            if self.key then
                self:BindRoleUpdate()
                if not self.is_setvalue then
                    self:SetValue()
                end
            end
            RoleInfoModel:GetInstance():RemoveListener(self.event_id)
            self.event_id = nil
        end
        self.event_id = RoleInfoModel:GetInstance():AddListener(RoleInfoEvent.ReceiveRoleInfo, call_back)
    else
        self:BindRoleUpdate()
    end
end

function MoneyItem:BindRoleUpdate()
    if self.role_data and not self.money_event_id then
        local function call_back()
            self:SetValue()
        end
        self.money_event_id = self.role_data:BindData(self.key, call_back)
    end
end

function MoneyItem:BindGoods()
    local function call_back(id)
        if self.key == id then
            self:SetValue()
        end
    end
    self.global_event_list = self.global_event_list or {}
    self.global_event_list[#self.global_event_list + 1] = GlobalEvent:AddListener(BagEvent.UpdateGoods, call_back)
end

function MoneyItem:AddEvent()
    local function call_back(target, x, y)
        GoodsModel:GetInstance():GoodsJumpConfig(self.key)
    end
    AddButtonEvent(self.btn_add.gameObject, call_back)
end

function MoneyItem:SetValue()
    if not self.is_loaded then
        return
    end

    if self.key and type(self.key) == "string" then
        if self.role_data then
            self.is_setvalue = true
        end
        local value = self.role_data and self.role_data[self.key] or 0
        if value then
            self.text_component.text = GetShowNumber(value)
        end
    elseif self.key and type(self.key) == "number" then
        local value = BagModel:GetInstance():GetItemNumByItemID(self.key)
        self.text_component.text = GetShowNumber(value)
    end
end

function MoneyItem:SetData(key)
    self.key = key
    self:SetValue()
end