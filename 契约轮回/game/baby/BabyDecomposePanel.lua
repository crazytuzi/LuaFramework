---
--- Created by  Administrator
--- DateTime: 2019/11/13 17:04
---
BabyDecomposePanel = BabyDecomposePanel or class("BabyDecomposePanel", WindowPanel)
local this = BabyDecomposePanel

function BabyDecomposePanel:ctor(parent_node, parent_panel)
    self.abName = "baby"
    self.assetName = "BabyDecomposePanel"
    self.image_ab = "baby_image";
    self.layer = "UI"
    self.events = {}
    self.mEvents = {}
    self.use_background = true
    self.click_bg_close = true
    self.panel_type = 3
    self.model = BabyModel:GetInstance()
    self.defColor = enum.COLOR.COLOR_GREEN
end


function BabyDecomposePanel:Open()
    self.model.isOpenDecompose = true
    WindowPanel.Open(self)
end

function BabyDecomposePanel:dctor()
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

function BabyDecomposePanel:LoadCallBack()
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
    self:SetTileTextImage("baby_image", "baby_titile_tex5");
    BagController:GetInstance():RequestBagInfo(BagModel.baby)
end

function BabyDecomposePanel:AddQulityDropDown()
    self.qulityDropdown.options:Clear();
    local od = UnityEngine.UI.Dropdown.OptionData();
    od.text = enumName.COLOR[enum.COLOR.COLOR_GREEN].."Below Lv.X";              --1
    self.qulityDropdown.options:Add(od);

    od = UnityEngine.UI.Dropdown.OptionData();
    od.text = enumName.COLOR[enum.COLOR.COLOR_BLUE].."Below Lv.X";              --2
    self.qulityDropdown.options:Add(od);

    od = UnityEngine.UI.Dropdown.OptionData();
    od.text = enumName.COLOR[enum.COLOR.COLOR_PURPLE].."Below Lv.X";              --3
    self.qulityDropdown.options:Add(od);

    od = UnityEngine.UI.Dropdown.OptionData();
    od.text = enumName.COLOR[enum.COLOR.COLOR_ORANGE].."Below Lv.X";              --3
    self.qulityDropdown.options:Add(od);

    od = UnityEngine.UI.Dropdown.OptionData();
    od.text = enumName.COLOR[enum.COLOR.COLOR_RED].."Below Lv.X";              --3
    self.qulityDropdown.options:Add(od);

    od = UnityEngine.UI.Dropdown.OptionData();
    od.text = enumName.COLOR[enum.COLOR.COLOR_PINK].."Below Lv.X";              --3
    self.qulityDropdown.options:Add(od);
end

function BabyDecomposePanel:SetMask()
    self.StencilId = GetFreeStencilId()
    self.StencilMask = AddRectMask3D(self.Viewport.gameObject)
    self.StencilMask.id = self.StencilId
end

function BabyDecomposePanel:InitUI()
    local iconName = Config.db_item[enum.ITEM.ITEM_BABY].icon
    GoodIconUtil:CreateIcon(self, self.moneyIcon, iconName, true)
end

function BabyDecomposePanel:SelectItems(color)
    --dump( self.model:GetEquipsByColor(color))
   -- self.color = color
    local euqips = BagModel:GetInstance().babyItems
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

function BabyDecomposePanel:AddEvent()
    local function call_back(go,value)
       -- logError(value + 2)
       -- self:SelectItems(value + 2)
        self.defColor = value + 2
        if self.PageScrollView ~= nil then
            self.PageScrollView:ForceUpdate()
        end
        self:SelectItems(self.defColor)
        self:UpdataMoney()
    end
    AddValueChange(self.qulityDropdown.gameObject, call_back);

    local function call_back()
        dump(self.model.selectEquip)
        if table.isempty(self.model.selectEquip) then
            Notify.ShowText("Please select a toy to dismantle")
            return
        end
        BabyController:GetInstance():RequstBabyEquipDecompose(self.model.selectEquip)
    end
    AddClickEvent(self.decomposeBtn.gameObject,call_back)

    self.events[#self.events + 1] = GlobalEvent:AddListener(BabyEvent.BabyBagInfo,handler(self,self.BabyBagInfo))
    self.mEvents[#self.mEvents + 1] = self.model:AddListener(BabyEvent.BabyEquipDecompose,handler(self,self.BabyEquipDecompose))
end

function BabyDecomposePanel:BabyBagInfo()
    self:SelectItems(self.defColor)
    self:CreateItems()
    if self.PageScrollView ~= nil then
        self.PageScrollView:ForceUpdate()
    end
    self:UpdataMoney()
    --self.moneyTex.text =
end

function BabyDecomposePanel:BabyEquipDecompose()
    self:UpdataMoney()
end


function BabyDecomposePanel:UpdataMoney()
    local money = 0
    for i, v in pairs(self.model.selectEquip) do
        local id = self.model:GetEquipId(v)
        if id ~= 0 then
            local cfg = Config.db_baby_equip[id]
            if cfg then
                local gain = String2Table(cfg.gain)
                local num = gain[1][2]
                money = money + num
            end
        end
    end
    if money <= 0 then
        self.moneyTex.text = RoleInfoModel:GetInstance():GetRoleValue(Constant.GoldType.BabyScore)
    else
        local str = string.format("%s<color=#3ab60e>+%s</color>",RoleInfoModel:GetInstance():GetRoleValue(Constant.GoldType.BabyScore),money)
        self.moneyTex.text = str
    end

end

function BabyDecomposePanel:CreateItems()
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
    param["cellCount"] = BagModel.GetInstance().babyOpenCells
    self.PageScrollView = ScrollViewUtil.CreateItems(param)
end

function BabyDecomposePanel:CreateCellCB(itemCLS)
    self:UpdateCellCB(itemCLS)
end

function BabyDecomposePanel:UpdateCellCB(itemCLS)
    itemCLS.bag = BagModel.baby
    if BagModel:GetInstance().babyItems ~=nil then
        local itemBase = BagModel:GetInstance().babyItems[itemCLS.__item_index]
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
            param["bag"] = BagModel.baby
            param["get_item_cb"] = handler(self,self.GetItemDataByIndex)
            param["model"] = self.model
            param["selectItemCB"] = handler(self,self.SelectItemCB)
            param["get_item_select_cb"] = handler(self,self.GetItemSelect)
            itemCLS:InitItem(param)
        end
    else
        local param = {}
        param["bag"] = BagModel.baby
        param["get_item_cb"] = handler(self,self.GetItemDataByIndex)
        param["model"] = self.model
        param["selectItemCB"] = handler(self,self.SelectItemCB)
        param["get_item_select_cb"] = handler(self,self.GetItemSelect)
        itemCLS:InitItem(param)
    end
end

function BabyDecomposePanel:SelectItemCB(uid,is_select)
    --logError(uid,is_select)
    self.model:SetEquipSelect(uid,is_select)
    self:UpdataMoney()
end

function BabyDecomposePanel:GetItemSelect(uid)
    return self.model:GetEquipSelect(uid,self.defColor)
end

--function BabyDecomposePanel:GetItemSelect()
--
--end


function BabyDecomposePanel:GetItemDataByIndex(index)
    return BagModel.Instance:GetBabyItemDataByIndex(index)
end


