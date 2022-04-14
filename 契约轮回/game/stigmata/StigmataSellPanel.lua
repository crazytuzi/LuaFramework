---
---Author: wry
---Date: 2019/9/18 19:33:27
---
---
StigmataSellPanel = StigmataSellPanel or class("StigmataSellPanel",WindowPanel)
local this = StigmataSellPanel

local value_2_color = {
    [0] = 5,
    [1] = 4,
    [2] = 3
}

local color_2_value ={
    [5] = 0,
    [4] = 1,
    [3] = 2
}

local tData = {}

function StigmataSellPanel:ctor()
    self.abName = "bag"
    self.assetName = "StigmataSellPanel"
    self.layer = "UI"

    self.panel_type = 6
    self.use_background = true
    self.change_scene_close = true

    self.events = {}

    self.item_list = {}     --物品列表（prefab）
    self.itemDataList = {}  --物品数据列表
    self.exp = 0
    self.old_exp = 0
    self.model = BagModel:GetInstance()

    self.isToggle = true    --是否选中Toggle
    self.stigmataList = {}  --要分解的UID列表
end

function StigmataSellPanel:dctor()
    if self.scrollView then
        self.scrollView:OnDestroy()
        self.scrollView = nil
    end
    if self.events and #self.events ~= 0 then
        self.model:RemoveTabListener(self.events)
    end

    self.model = nil
    tData = nil
    self.item_list = nil
    self.itemDataList = nil
    self.exp = nil
    self.old_exp = nil
    self.model = nil
    self.isToggle = nil
    self.stigmataList = nil

end

function StigmataSellPanel:Open(data)
    StigmataSellPanel.super.Open(self)
    tData = data
end

function StigmataSellPanel:LoadCallBack()
    self.nodes = {
        "ScrollView/Viewport/Content","ScrollView/Viewport","ScrollView",
        "smeltbtn","star_toggle","color_drop","GetMoney/parent/expValue"
    }
    self:GetChildren(self.nodes)
    self:SetMask()
    self:AddEvent()

    self.color_drop = GetDropDown(self.color_drop)
    self.expValue = GetText(self.expValue)

    self:SetTileTextImage("bag_image", "bag_rapid_res")

    self:UpdateView()
end

function StigmataSellPanel:AddEvent()
    local function call_back(pitembase)
        self:SelectItem(pitembase)
    end
    self.events[#self.events+1] = self.model:AddListener(BagEvent.SmeltItemClick, call_back)

    --是否自动分解
    local function call_back(target, value)
        if value then
            tData.auto = 1
        else
            tData.auto = 0
        end

        StigmataController:GetInstance():RequestSetSoulDecompose(tData)

    end
    AddValueChange(self.star_toggle.gameObject, call_back)

    --选中颜色
    local function call_back(go, value)
        tData.color = value_2_color[value]
        StigmataController:GetInstance():RequestSetSoulDecompose(tData)
        self:SelectItems()
    end
    AddValueChange(self.color_drop.gameObject, call_back)

    --分解按钮
    local function SmeltBtnCall_back()

        if table.nums(self.stigmataList) == 0 then
            Notify.ShowText("Please select the stigmata you want to dismantle")
        else
            StigmataController:GetInstance():RequestSoulDecompose(self.stigmataList)
            self:Close()
        end

       
    end
    AddClickEvent(self.smeltbtn.gameObject,SmeltBtnCall_back)
end

function StigmataSellPanel:OpenCallBack()
    --EquipController:GetInstance():RequestSmeltInfo()
end

function StigmataSellPanel:UpdateView( )
    self.itemDataList = StigmataModel.GetInstance():GetSmeltStigmataList()
    --self:GetSmeltStigmataList()
    if tData.auto == 1 then
        self.star_toggle:GetComponent("Toggle").isOn = true
    else
        self.star_toggle:GetComponent("Toggle").isOn = false
    end
    --self.color_drop.value =tData.color
    self.color_drop.value = color_2_value[tData.color]

    if tData.color == 3 then
        --打开面板时 如果分解颜色设置为蓝色及以下 需要手动调用一下
        self:SelectItems()
    end

    self:UpdateBag()
end

function StigmataSellPanel:CloseCallBack(  )
    self.item_list = nil

    if self.StencilMask then
        destroy(self.StencilMask)
        self.StencilMask = nil
    end
end

function StigmataSellPanel:UpdateBag()
    if not self.scrollView then
        self:CreateItems(200)
    else
        for i=1, #self.item_list do
            self:UpdateCellCB(self.item_list[i])
        end
    end
    self:UpdateExp()
end

--单选用的
function StigmataSellPanel:SelectItem(pitembase)
    local cellid = pitembase.uid

    local soul_cfg = Config.db_soul[pitembase.id]

    local exp = String2Table(soul_cfg.gain)[1][2]  --本身分解

    --判断要分解的是否是圣痕
    if soul_cfg.slot ~= 0 then
        local soul_level_cfg = Config.db_soul_level[pitembase.id .. "@" .. pitembase.extra]
        if not soul_level_cfg then
            logError(pitembase.id .. "@" .. pitembase.extra .."不存在圣痕配置中")
            return
        end

        exp = exp + String2Table(soul_level_cfg.total_cost)[2]  --本身分解+升级消耗

    end

    local add_exp = 0
    if self.stigmataList[cellid] then
        self.stigmataList[cellid] = nil
        add_exp = 0 - exp
    else
        self.stigmataList[cellid] = true
        add_exp = exp
    end
    self.exp = self.exp + add_exp
    self:UpdateExp()
end

--进行多选时候用的
function StigmataSellPanel:SelectItem2(pitembase,isOn)
    local cellid = pitembase.uid

    local soul_cfg = Config.db_soul[pitembase.id]

    local exp = String2Table(soul_cfg.gain)[1][2]

    if soul_cfg.slot ~= 0 then
        local soul_level_cfg = Config.db_soul_level[pitembase.id .. "@" .. pitembase.extra]
        if not soul_cfg or not soul_level_cfg then
            logError(pitembase.id .. "@" .. pitembase.extra .."不存在圣痕配置中")
            return
        end
         --本身分解+升级消耗
         exp = String2Table(soul_cfg.gain)[1][2] + String2Table(soul_level_cfg.total_cost)[2]
    end
  

   

    local add_exp = 0
    if not isOn then
        self.stigmataList[cellid] = nil
        add_exp = 0
    else
        self.stigmataList[cellid] = true
        add_exp = exp
    end
    self.exp = self.exp + add_exp
    self:UpdateExp()
end

--选中多个
function StigmataSellPanel:SelectItems()
    self.exp = self.old_exp
    for i=1, #self.itemDataList do
        local pitembase = self.itemDataList[i]
        local id = pitembase.id
        local uid = pitembase.uid
        local soul = Config.db_soul[id]
        local item = Config.db_item[id]

        if not soul then
            logError(id.."不存在soul表中")
            return
        end

        if not item then
            logError(id.."不存在item表中")
            return
        end

        if soul.slot == 0 then
            self:SelectItem2(pitembase,true)  --品质筛选不对圣痕碎片生效
        elseif item.color <= tData.color then
            self:SelectItem2(pitembase,true)
        else
            self:SelectItem2(pitembase,false)
        end
        

    end
    self:UpdateItems()
end

function StigmataSellPanel:UpdateItems()
    for i=1, #self.item_list do
        if self.item_list[i] then
            local pitembase = self.item_list[i]:GetData()
            if pitembase then
                self.item_list[i]:Select(self.stigmataList[pitembase.uid])
            end
        end
    end
end

--更新exp
function StigmataSellPanel:UpdateExp()

    self.expValue.text = self.exp
end

function StigmataSellPanel:CreateItems(cellCount)
    local param = {}
    local cellSize = {width = 70,height = 70}
    param["scrollViewTra"] = self.ScrollView
    param["cellParent"] = self.Content
    param["cellSize"] = cellSize
    param["cellClass"] = BagSmeltItem
    param["begPos"] = Vector2(40,-53)
    param["spanX"] = 11.5
    param["spanY"] = 12.25
    param["createCellCB"] = handler(self,self.CreateCellCB)
    param["updateCellCB"] = handler(self,self.UpdateCellCB)
    param["cellCount"] = cellCount
    self.scrollView = ScrollViewUtil.CreateItems(param)
end

function StigmataSellPanel:CreateCellCB(itemCLS)
    self:UpdateCellCB(itemCLS, true)

    --默认选中
   --[[  local index = itemCLS.__item_index
    local item = self.itemDataList[index]
    if item then
        self:SelectItem2(item,true)
        itemCLS:Select(self.stigmataList[item.uid])
    end ]]
    
end

function StigmataSellPanel:UpdateCellCB(itemCLS)
    local index = itemCLS.__item_index
    local item = self.itemDataList[index]
    itemCLS:SetData(item, self:IsSelect(item), self.StencilId)
    if item then
        self.item_list[index] = itemCLS
    end
end

function StigmataSellPanel:IsSelect(pitembase)
    if not pitembase then
        return false
    end
    return self.stigmataList[pitembase.uid]
end

function StigmataSellPanel:SetMask()
    self.StencilId = GetFreeStencilId()
    self.StencilMask = AddRectMask3D(self.Viewport.gameObject)
    self.StencilMask.id = self.StencilId
end
