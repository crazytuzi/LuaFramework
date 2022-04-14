CombineSelectEquipItem = CombineSelectEquipItem or class("CombineSelectEquipItem", BaseItem)
local CombineSelectEquipItem = CombineSelectEquipItem

function CombineSelectEquipItem:ctor(parent_node, layer)
    self.abName = "combine"
    self.assetName = "CombineSlotItem"
    self.layer = layer

    self.item = nil  --p_item_base
    self.model = CombineModel.GetInstance()
    BaseItem.Load(self)
end

function CombineSelectEquipItem:dctor()
    if self.itemicon ~= nil then
        self.itemicon:destroy()
        --self
    end
end

function CombineSelectEquipItem:LoadCallBack()
    self.nodes = {
        "con/Text",
        "icon",
        "Image",
    }
    self:GetChildren(self.nodes)
    self:AddEvent()

    self:ShowPanel()
end

function CombineSelectEquipItem:AddEvent()
    local function call_back(target, x, y)
        GlobalEvent:Brocast(CombineEvent.SelectEquipItemClick, self.item)
    end
    AddClickEvent(self.Image.gameObject, call_back)
end

function CombineSelectEquipItem:SetData(data)
    self.item = data
    self.item.parent_trans_idx = self.model.cur_grid_index
    if self.is_loaded then
        self:ShowPanel()
    end
end

function CombineSelectEquipItem:ShowPanel()
    self.Text:GetComponent('Text').text = Config.db_item[self.item.id].name
    self.itemicon = GoodsIconSettorTwo(self.icon)
    local param = {}
    param["model"] = self.model
    param["item_id"] = self.item.id
    --param["num"] = data[2]
    --param["size"] = {x=70,y=70}
    param["p_item"] = self.item


    local item_cfg = Config.db_item[self.item.id]
    if item_cfg.type == enum.ITEM_TYPE.ITEM_TYPE_PET_EQUIP then
        --宠物装备配置表特殊处理
        param["cfg"] = Config.db_pet_equip[self.item.id.."@"..self.item.misc.stren_phase]
    end

    self.itemicon:SetIcon(param)
    --self.itemicon:UpdateIconByItemId(self.item.id)
end

function CombineSelectEquipItem:GetHeight()
    return 100
end