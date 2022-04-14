CombineSlotItem = CombineSlotItem or class("CombineSlotItem", BaseItem)
local CombineSlotItem = CombineSlotItem

function CombineSlotItem:ctor(parent_node, layer)
    self.abName = "combine"
    self.assetName = "CombineSlotItem"
    self.layer = layer

    self.model = CombineModel.GetInstance()
    BaseItem.Load(self)
end

function CombineSlotItem:dctor()
    if self.itemicon ~= nil then
        self.itemicon:destroy()
        self.itemicon = nil
    end
    if self.red_dot then
        self.red_dot:destroy()
        self.red_dot = nil
    end
    if self.update_event_id then
        GlobalEvent:RemoveListener(self.update_event_id)
        self.update_event_id = nil
    end
    if self.udpate_rd_switch_event_id then
        GlobalEvent:RemoveListener(self.udpate_rd_switch_event_id)
        self.udpate_rd_switch_event_id = nil
    end
end

function CombineSlotItem:LoadCallBack()
    self.nodes = {
        "icon", "con/Text", "con/have",
        "Image",
        "red_con",
    }
    self:GetChildren(self.nodes)
    self:AddEvent()
    self.have = GetText(self.have)

    SetVisible(self.red_con, not self.model.is_hide_combine_rd)
    self.gameObject.name = "CombineSlotItem_" .. self.index
    self:ShowPanel()
end

function CombineSlotItem:AddEvent()
    local function call_back(target, x, y)
        self.model.curBagType = Config.db_item[String2Table(Config.db_equip_combine[self.data].gain)[1][1]].bag
        GlobalEvent:Brocast(CombineEvent.RightSlotItemClick, self.data)
    end
    AddClickEvent(self.Image.gameObject, call_back)

    local function callback(is_hide_rd)
        SetVisible(self.red_con, not is_hide_rd)
    end
    self.udpate_rd_switch_event_id = GlobalEvent:AddListener(CombineEvent.UpdateRDSwitch, callback)
    self.update_event_id = GlobalEvent:AddListener(CombineEvent.UpdateCombineArea, handler(self, self.UpdateRD))
end

function CombineSlotItem:SetData(data, index)
    self.data = data
    self.index = index or 0
    if self.is_loaded then
        self:ShowPanel()
    end
end

function CombineSlotItem:ShowPanel()
    local cb_cf = Config.db_equip_combine[self.data]
    if not cb_cf then
        logError("db_equip_combine中没有该配置，id是:", self.data)
        return
    end
    self.itemId = String2Table(cb_cf.gain)[1][1]

    --更新不固定材料数量
    local str = ""
    local unsettle_tbl = String2Table(cb_cf.other_cost)
    local is_show = false
    if not table.isempty(unsettle_tbl) then
        --有不固定材料需求
        local num = self.model:GetMaterialNum(cb_cf, 2, 101)
        if self.model.curBagType ~= 101 then
            num = self.model:GetMaterialNum(cb_cf, 2, self.model.curBagType)
        end
        str = "Available materials: " .. num
        is_show = true
    end
    SetVisible(self.have, is_show)
    self.have.text = str
    self.Text:GetComponent('Text').text = Config.db_item[self.itemId].name
    if self.itemicon then
        self.itemicon:destroy()
        self.itemicon = nil
    end
    self.itemicon = GoodsIconSettorTwo(self.icon)
    local param = {}
    param["model"] = self.model
    param["item_id"] = self.itemId
    param['bind'] = 0

    local item_cfg = Config.db_item[self.itemId]
    if item_cfg.type == enum.ITEM_TYPE.ITEM_TYPE_PET_EQUIP then
        --宠物装备特殊处理配置表
        param["cfg"] = Config.db_pet_equip[self.itemId.."@"..1]
    end

    self.itemicon:SetIcon(param)
    --self.itemicon:UpdateIconByItemId(self.itemId)
    self:UpdateRD()
end

function CombineSlotItem:UpdateRD()
    local is_show = self.model:GetStarRDList(self.model.select_sec_menu_id, self.data)
    self:SetRedDot(is_show)
end

function CombineSlotItem:GetHeight()
    return 100
end

function CombineSlotItem:SetRedDot(isShow)
    if not self.red_dot then
        self.red_dot = RedDot(self.red_con, nil, RedDot.RedDotType.Nor)
    end
    self.red_dot:SetPosition(0, 0)
    self.red_dot:SetRedDotParam(isShow)
end