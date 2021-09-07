ForgeSpiritHandbook = ForgeSpiritHandbook or BaseClass(BaseView)

-- 这两个表必须一致
local BagTag = {Green = 1, Blue = 2, Purple = 3, Orange = 4, Red = 5}
local ColorId = {"green_soul", "blue_soul", "purple_soul", "orange_soul", "red_soul"}

local COLUMN = 4
local Row = 3
local ColorTypes = 5
local AttrName = {"攻击", "防御", "气血", "命中", "闪避", "暴击", "抗暴"}
local Attrkey = {"gongji", "fangyu", "maxhp", "mingzhong", "shanbi", "baoji", "jianren"}

function ForgeSpiritHandbook:__init()
    local handbook = SpiritData.Instance:GetAllSpiritSoulCfg()
    local exp_data = SpiritData.Instance:GetSpiritSoulExpCfg()
    self.soul_list = {red_soul = {}, orange_soul = {}, purple_soul = {}, blue_soul = {}, green_soul = {}}
    for k, v in pairs(handbook) do
        table.insert(self.soul_list[ColorId[v.hunshou_color]], v)
    end
    self.ui_config = {"uis/views/forgeview", "SoulHandBookView"}
    exp_data = ListToMap(exp_data, "hunshou_color", "hunshou_level")
    self.soul_data = {}
    for i = 1, ColorTypes do
        table.insert(self.soul_data, exp_data[i][1])
    end
end

function ForgeSpiritHandbook:__delete()
    self.soul_list = nil
    self.soul_data = nil
end

function ForgeSpiritHandbook:ReleaseCallBack()
    for k, v in pairs(self.cell_list) do
        v:DeleteMe()
    end
    self.cell_list = nil
    self.lastindex = nil
    self.soul_name = nil
    self.fight_power = nil
    self.attr = nil
    self.value = nil
    self.quality_text = nil
    self.introduction = nil
    self.modle_effect = nil

    self.model_root = nil
    self.list_view = nil
    self.default_button = nil
end

function ForgeSpiritHandbook:LoadCallBack()
    self.cell_list = {}
    self.lastindex = 5
    self.soul_name = self:FindVariable("SoulName")
    self.fight_power = self:FindVariable("FightPower")
    self.attr = self:FindVariable("Attr")
    self.value = self:FindVariable("Value")
    self.quality_text = self:FindVariable("QualityText")
    self.introduction = self:FindVariable("Introduction")


    self.model_root = self:FindObj("ModelRoot")
    self.list_view = self:FindObj("ListView")
    self.default_button = self:FindObj("DefaultButton")
    self.list_view.scroll_rect.enabled = false

    self:ListenEvent("Close", BindTool.Bind(self.CloseWindow, self))
    for i = 1, 5 do
        self:ListenEvent("Toggle" .. i, BindTool.Bind(self.ToggleColor, self, i))
    end
    local scroller_delegate = self.list_view.list_simple_delegate
    scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.GetCellNumber, self)
    scroller_delegate.CellRefreshDel = BindTool.Bind(self.CellRefreshDel, self)
end

function ForgeSpiritHandbook:OpenCallBack()
    if self.cell_list[1] then
        self:FlushSoul(BagTag.Red)
    end
    self.default_button.toggle.isOn = true
end

function ForgeSpiritHandbook:CloseCallBack()
end


function ForgeSpiritHandbook:ToggleColor(state)

    if self.lastindex ~= state then
        self:FlushSoul(state)
    end
    self.lastindex = state
end

function ForgeSpiritHandbook:FlushSoul(state) 
    self:SetView(self.soul_list[ColorId[state]])
    self:FlushIntroduce(self.soul_list[ColorId[state]][1])
    self.cell_list[1].items[1].gameobject.toggle.isOn = true
end

function ForgeSpiritHandbook:CloseWindow()
    self:Close()
end
function ForgeSpiritHandbook:GetCellNumber()
    return 4
end
function ForgeSpiritHandbook:CellRefreshDel(cell, data_index, cell_Index)

    local group_cell = nil
    data_index = data_index + 1
    if nil == group_cell then
        group_cell = ForgeSoulHandBookGroup.New(cell.gameObject)
        self.cell_list[data_index] = group_cell
    end
    if data_index == 4 then
        self:FlushSoul(BagTag.Red)
    end
end

function ForgeSpiritHandbook:FlushIntroduce(itemdata)
    if itemdata then
        ForgeSpiritHandbook.LoadEffect(self, itemdata, self.model_root)
        local str = "<color=%s>"..itemdata.name.."</color>"
        self.soul_name:SetValue(string.format(str, SOUL_NAME_COLOR[itemdata.hunshou_color]))
        self.attr:SetValue(AttrName[itemdata.hunshou_type + 1])
        self.value:SetValue(self.soul_data[itemdata.hunshou_color][Attrkey[itemdata.hunshou_type + 1]])

        local fight_table = {}
        local attr_key = Attrkey[itemdata.hunshou_type + 1]
        fight_table[attr_key] = self.soul_data[itemdata.hunshou_color][attr_key]
        local fight = CommonDataManager.GetCapability(fight_table)
        self.fight_power:SetValue(fight)
        self.introduction:SetValue(itemdata.description)
        local color_name = Common_Five_Rank_Color[itemdata.hunshou_color]
        self.quality_text:SetValue(Language.QualityAttr[color_name])
    end
end


function ForgeSpiritHandbook:SetView(soul_list)
    local m = 1
    for j = 1, Row do
        for i = 1, COLUMN do
            if soul_list[m] then
                self.cell_list[i].items[j]:SetData(soul_list[m])
                m = m + 1
            else
                local soul_item = self.cell_list[i].items[j]
                soul_item:SetLock()
                local item_gameobject = soul_item.gameobject
                if item_gameobject.toggle.enabled == true then
                    item_gameobject.toggle.enabled = false
                else
                    item_gameobject.toggle.enabled = true
                    item_gameobject.toggle.enabled = false
                end
            end
        end
    end
end
function ForgeSpiritHandbook.LoadEffect(example, itemdata, model_root)
    if example.modle_effect then
        GameObject.Destroy(example.modle_effect)
        example.modle_effect = nil
    elseif example.is_load and itemdata.hunshou_id < 0 then
        example.is_stop_load_effect = true
    end
    if itemdata.hunshou_effect and not example.effect and not example.is_load then
        example.is_load = true
        PrefabPool.Instance:Load(AssetID("effects2/prefab/ui/ui_jinglinminghun/" .. string.lower(itemdata.hunshou_effect) .. "_prefab", itemdata.hunshou_effect), function (prefab)
            if not prefab then return end

            if example.is_stop_load_effect then
                example.is_stop_load_effect = false
                return
            end
            local obj = GameObject.Instantiate(prefab)
            PrefabPool.Instance:Free(prefab)
            local transform = obj.transform
            transform:SetParent(model_root.transform, false)
            example.modle_effect = obj.gameObject
            example.is_load = false
        end)
    end
end
--------------------ForgeSoulHandBookGroup---------------------------
ForgeSoulHandBookGroup = ForgeSoulHandBookGroup or BaseClass(BaseRender)
function ForgeSoulHandBookGroup:__init()
    self.items = {
        ForgeSoulHandBookItem.New(self:FindObj("SoulHandbookItem1")), 
        ForgeSoulHandBookItem.New(self:FindObj("SoulHandbookItem2")), 
        ForgeSoulHandBookItem.New(self:FindObj("SoulHandbookItem3")), 
    }
end

function ForgeSoulHandBookGroup:__delete()
    for k, v in ipairs(self.items) do
        v:DeleteMe()
    end
    self.items = {}
end
-------------------ForgeSoulHandBookItem-----------------------
ForgeSoulHandBookItem = ForgeSoulHandBookItem or BaseClass(BaseRender)
function ForgeSoulHandBookItem:__init()
    self.max_Level = 100
    self.icon = self:FindObj("Icon")
    self.gameobject = self:FindObj("Self")
    self.name = self:FindVariable("name")
    self.lv = self:FindVariable("lv")
    self.lock = self:FindVariable("lock")
    self.icon_root = self.icon
    self.effect = nil
    self.is_load = false
    self.is_stop_load_effect = false
    self:ListenEvent("Click", BindTool.Bind(self.ClickItem, self))
    self.gameobject.toggle.group = ForgeCtrl.Instance.forge_spirit_handbook_view.list_view.toggle_group
end

function ForgeSoulHandBookItem:__delete()

end

function ForgeSoulHandBookItem:SetToggleHighLight(state)
    -- self.root_node.toggle.isOn = state
end
function ForgeSoulHandBookItem:ClickItem()
    if self.data then
        if self.gameobject.toggle.isOn ~= true then
            ForgeCtrl.Instance.forge_spirit_handbook_view:FlushIntroduce(self.data)
        end
    else
        TipsCtrl.Instance:ShowSystemMsg(Language.JingLing.NoOpen)
    end

end
function ForgeSoulHandBookItem:SetData(data)
    self.data = data
    if self.data then
        ForgeCtrl.Instance.forge_spirit_handbook_view.LoadEffect(self, data, self.icon_root)
        local str = "<color=%s>"..self.data.name.."</color>"
        self.name:SetValue(string.format(str, SOUL_NAME_COLOR[self.data.hunshou_color]))
    else

    end
end

function ForgeSoulHandBookItem:SetLock()
    self.lock:SetAsset(ResPath.GetIconLock("1000"))
end
