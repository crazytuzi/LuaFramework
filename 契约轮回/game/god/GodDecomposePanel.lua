---
--- Created by  Administrator
--- DateTime: 2019/11/29 14:28
---
GodDecomposePanel = GodDecomposePanel or class("GodDecomposePanel", WindowPanel)
local this = GodDecomposePanel

function GodDecomposePanel:ctor(parent_node, WindowPanel)

    self.abName = "god"
    self.assetName = "GodDecomposePanel"
    self.layer = "UI"
    self.events = {}
    self.mEvents = {}
    self.use_background = true
    self.click_bg_close = true
    self.panel_type = 3
    self.model = GodModel:GetInstance()
    self.defColor = enum.COLOR.COLOR_BLUE
end

function GodDecomposePanel:Open()
    self.model.isOpenDecompose = true
    WindowPanel.Open(self)
end

function GodDecomposePanel:dctor()
    GlobalEvent:RemoveTabListener(self.events)
    self.model:RemoveTabListener(self.mEvents)
    self.model.isOpenDecompose = false
    if self.PageScrollView ~= nil then
        self.PageScrollView:OnDestroy()
        self.PageScrollView = nil
    end
    if self.StencilMask then
        destroy(self.StencilMask)
        self.StencilMask = nil
    end
end

function GodDecomposePanel:LoadCallBack()
    self.nodes = {
        "moneyParent/moneyTex","moneyParent/moneyIcon","decomposeBtn","qulityDropdown",
        "itemScrollView/Viewport","itemScrollView/Viewport/itemContent","itemScrollView"
    }
    self:GetChildren(self.nodes)
    self.moneyTex = GetText(self.moneyTex)
    self.moneyIcon = GetImage(self.moneyIcon)
    self.qulityDropdown = GetDropDown(self.qulityDropdown)
    self:InitUI()
    self:AddEvent()
    self:AddQulityDropDown()
    self:SetMask()
    self:SetTileTextImage("god_image", "god_equip_tex1");
    BagController:GetInstance():RequestBagInfo(BagModel.God)
end

function GodDecomposePanel:AddQulityDropDown()
    self.qulityDropdown.options:Clear();
    local od = UnityEngine.UI.Dropdown.OptionData();
    od.text = enumName.COLOR[enum.COLOR.COLOR_GREEN].."Below Lv.X";              --1
    self.qulityDropdown.options:Add(od);

    od = UnityEngine.UI.Dropdown.OptionData();
    od.text = enumName.COLOR[enum.COLOR.COLOR_BLUE].."and below";              --2
    self.qulityDropdown.options:Add(od);

    od = UnityEngine.UI.Dropdown.OptionData();
    od.text = enumName.COLOR[enum.COLOR.COLOR_PURPLE].."and below";              --3
    self.qulityDropdown.options:Add(od);

    od = UnityEngine.UI.Dropdown.OptionData();
    od.text = enumName.COLOR[enum.COLOR.COLOR_ORANGE].."and below";              --3
    self.qulityDropdown.options:Add(od);

    od = UnityEngine.UI.Dropdown.OptionData();
    od.text = enumName.COLOR[enum.COLOR.COLOR_RED].."and below";              --3
    self.qulityDropdown.options:Add(od);

    od = UnityEngine.UI.Dropdown.OptionData();
    od.text = enumName.COLOR[enum.COLOR.COLOR_PINK].."and below";              --3
    self.qulityDropdown.options:Add(od);
end

function GodDecomposePanel:SetMask()
    self.StencilId = GetFreeStencilId()
    self.StencilMask = AddRectMask3D(self.Viewport.gameObject)
    self.StencilMask.id = self.StencilId
end

function GodDecomposePanel:InitUI()
    local iconName = Config.db_item[enum.ITEM.ITEM_GOD_MONEY].icon
    GoodIconUtil:CreateIcon(self, self.moneyIcon, iconName, true)
end

function GodDecomposePanel:SelectItems(color)
    --dump( self.model:GetEquipsByColor(color))
    -- self.color = color
    local euqips = BagModel:GetInstance().godItems
    for i, v in pairs(euqips) do
        local uid = v.uid
        local cfg = Config.db_item[v.id]
        if cfg and cfg.color <= color then
            self.model:SetEquipSelect(uid,true)
        else
            self.model:SetEquipSelect(uid,false)
        end
    end
end

function GodDecomposePanel:AddEvent()
    local function call_back(go,value)
        -- logError(value + 2)
        -- self:SelectItems(value + 2)
        self.defColor = value + 2
        self:SelectItems(self.defColor)
        self:UpdataMoney()
        if self.PageScrollView ~= nil then
            self.PageScrollView:ForceUpdate()
        end
    end
    AddValueChange(self.qulityDropdown.gameObject, call_back);

    local function call_back()
        dump(self.model.selectEquip)
        if table.isempty(self.model.selectEquip) then
            Notify.ShowText("Please select a hallow to dismantle")
            return
        end
        GodController:GetInstance():RequstGodEquipDecomposeInfo(self.model.selectEquip)
    end
    AddClickEvent(self.decomposeBtn.gameObject,call_back)

    self.events[#self.events + 1] = GlobalEvent:AddListener(GodEvent.GodBagInfo,handler(self,self.GodBagInfo))
    self.mEvents[#self.mEvents + 1] = self.model:AddListener(GodEvent.GodEquipDecomposeInfo,handler(self,self.GodEquipDecomposeInfo))
end

function GodDecomposePanel:GodBagInfo()
    self:SelectItems(self.defColor -1 )
    self:CreateItems()
    if self.PageScrollView ~= nil then
        self.PageScrollView:ForceUpdate()
    end
    self:UpdataMoney()
    --self.moneyTex.text =
end

function GodDecomposePanel:GodEquipDecomposeInfo()
    self:UpdataMoney()
end


function GodDecomposePanel:UpdataMoney()
    local money = 0
    for i, v in pairs(self.model.selectEquip) do
        local id = self.model:GetEquipId(v)
        if id ~= 0 then
            local cfg = Config.db_god_equip[id]
            if cfg then
                local gain = String2Table(cfg.gain)
                local num = gain[1][2]
                money = money + num
            end
        end
    end
    if money <= 0 then
        self.moneyTex.text = RoleInfoModel:GetInstance():GetRoleValue(Constant.GoldType.GodScore)
    else
        local str = string.format("%s<color=#3ab60e>+%s</color>",RoleInfoModel:GetInstance():GetRoleValue(Constant.GoldType.GodScore),money)
        self.moneyTex.text = str
    end

end

function GodDecomposePanel:CreateItems()
    local param = {}
    local cellSize = {width = 78,height = 78}
    param["scrollViewTra"] = self.itemScrollView
    param["cellParent"] = self.itemContent
    param["cellSize"] = cellSize
    param["cellClass"] = BabyBagDecomposeSettor
    param["begPos"] = Vector2(0,0)
    param["spanX"] = 5
    param["spanY"] = 10
    param["createCellCB"] = handler(self,self.CreateCellCB)
    param["updateCellCB"] = handler(self,self.UpdateCellCB)
    param["cellCount"] = BagModel.GetInstance().godOpenCells
    self.PageScrollView = ScrollViewUtil.CreateItems(param)
end

function GodDecomposePanel:CreateCellCB(itemCLS)
    self:UpdateCellCB(itemCLS)
end

function GodDecomposePanel:UpdateCellCB(itemCLS)
    itemCLS.bag = BagModel.god
    if BagModel:GetInstance().godItems ~=nil then
        local itemBase = BagModel:GetInstance().godItems[itemCLS.__item_index]
        if itemBase ~= nil and itemBase ~= 0 then
            local configItem = Config.db_item[itemBase.id]
            if configItem ~= nil then --配置表存该物品
                --type,uid,id,num,bag,bind,outTime
                local param = {}
                param["type"] = configItem.type
                param["uid"] = itemBase.uid
                param["id"] = configItem.id
                param["num"] = itemBase.num
                param["bag"] = itemBase.bag
                param["bind"] = itemBase.bind
                param["multy_select"] = true
                param["itemSize"] = {x=78, y=78}
                param["get_item_cb"] = handler(self,self.GetItemDataByIndex)
                param["selectItemCB"] = handler(self,self.SelectItemCB)
                param["get_item_select_cb"] = handler(self,self.GetItemSelect)
                param["model"] = self.model
                param["itemIndex"] = itemCLS.__item_index
                param["stencil_id"] = self.StencilId
                itemCLS:DeleteItem()
                itemCLS:UpdateItem(param)
            end

        else
            local param = {}
            param["bag"] = BagModel.god
            param["get_item_cb"] = handler(self,self.GetItemDataByIndex)
            param["model"] = self.model
            param["selectItemCB"] = handler(self,self.SelectItemCB)
            param["get_item_select_cb"] = handler(self,self.GetItemSelect)
            itemCLS:InitItem(param)
        end
    else
        local param = {}
        param["bag"] = BagModel.god
        param["get_item_cb"] = handler(self,self.GetItemDataByIndex)
        param["model"] = self.model
        param["selectItemCB"] = handler(self,self.SelectItemCB)
        param["get_item_select_cb"] = handler(self,self.GetItemSelect)
        itemCLS:InitItem(param)
    end
end

function GodDecomposePanel:SelectItemCB(uid,is_select)
    self.model:SetEquipSelect(uid,is_select)
    self:UpdataMoney()
end

function GodDecomposePanel:GetItemSelect(uid)
    return self.model:GetEquipOneSelect(uid)
end

--function BabyDecomposePanel:GetItemSelect()
--
--end


function GodDecomposePanel:GetItemDataByIndex(index)
    return BagModel.Instance:GetGodItemDataByIndex(index)
end