---
--- Created by  Administrator
--- DateTime: 2020/6/24 9:28
---
ArtifactBagPanel = ArtifactBagPanel or class("ArtifactBagPanel", BasePanel)
local this = ArtifactBagPanel

function ArtifactBagPanel:ctor()
    self.abName = "artifact"
    self.assetName = "ArtifactBagPanel"
    self.layer = "UI"
   -- self.parentPanel = parent_panel
    self.events = {}
    self.gEvents = {}
    self.use_background = true
    self.btns = {}
    self.model = ArtifactModel:GetInstance()


    --ArtifactBagPanel.super.Load(self)
end

function ArtifactBagPanel:dctor()
    GlobalEvent:RemoveTabListener(self.gEvents)
    self.model:RemoveTabListener(self.events)
    if self.PageScrollView ~= nil then
        self.PageScrollView:OnDestroy()
        self.PageScrollView = nil
    end
    if self.StencilMask then
        destroy(self.StencilMask)
        self.StencilMask = nil
    end
    if not table.isempty(self.btns) then
        for i, v in pairs(self.btns) do
            v:destroy()
        end
        self.btns = {}
    end
end

function ArtifactBagPanel:Open(id)
    self.curArtId = id
    ArtifactPanel.super.Open(self)
end

function ArtifactBagPanel:LoadCallBack()
    self.nodes = {
        "itemScrollView","ArtifactBagBtnItem","btnParent","itemScrollView/Viewport/itemContent","closeBtn",
        "itemScrollView/Viewport",
    }
    self:GetChildren(self.nodes)

    self:InitUI()
    self:AddEvent()
    self:SetMask()
    BagController:GetInstance():RequestBagInfo(BagModel.artifact)
end


function ArtifactBagPanel:SetMask()
    self.StencilId = GetFreeStencilId()
    self.StencilMask = AddRectMask3D(self.Viewport.gameObject)
    self.StencilMask.id = self.StencilId
end
function ArtifactBagPanel:InitUI()

end

function ArtifactBagPanel:AddEvent()
    local function call_back()
        self:Close()
    end
    AddButtonEvent(self.closeBtn.gameObject,call_back)
    self.gEvents[#self.gEvents + 1] = GlobalEvent:AddListener(ArtifactEvent.ArtifactBagInfo,handler(self,self.ArtifactBagInfo))
    self.events[#self.events + 1] = self.model:AddListener(ArtifactEvent.ArtifactPutOnInfo, handler(self, self.ArtifactPutOnInfo))
    self.events[#self.events + 1] = self.model:AddListener(ArtifactEvent.bagBtnClick,handler(self,self.bagBtnClick))

end

function ArtifactBagPanel:bagBtnClick(index)
    for i, v in pairs(self.btns) do
        if index == v.index then
            v:SetSelect(true)
            self.bagItems = BagModel:GetInstance():GetCurrentArtsItems(index)
            BagModel:GetInstance():ArrangeGoods(self.bagItems)
            if self.PageScrollView then
                self.PageScrollView:OnDestroy()

            end
            local cellCount = Config.db_bag[BagModel.artifact].cap
            cellCount = cellCount or 20
            self:CreateItems(cellCount)
            --self:CreateItems()
        else
            v:SetSelect(false)
        end
    end
end

function ArtifactBagPanel:ArtifactBagInfo()
    self:InitBtns()
    self:bagBtnClick(1)

    if self.PageScrollView ~= nil then
        self.PageScrollView:ForceUpdate()
    end
end

function ArtifactBagPanel:ArtifactPutOnInfo()
    if self.PageScrollView ~= nil then
        self.PageScrollView:ForceUpdate()
    end
end

function ArtifactBagPanel:InitBtns()
    local tab  = { [1] = "All",[2] = "Divine gear",[3] = "Material"}
    for i = 1, #tab do
        local item = self.btns[i]
        if not item  then
            item = ArtifactBagBtnItem(self.ArtifactBagBtnItem.gameObject,self.btnParent,"UI")
            self.btns[i] = item
        end
        item:SetData(tab[i],i)
    end
end

function ArtifactBagPanel:CreateItems(cellCount)
    local param = {}
    local cellSize = {width = 78,height = 78}
    param["scrollViewTra"] = self.itemScrollView
    param["cellParent"] = self.itemContent
    param["cellSize"] = cellSize
    param["cellClass"] = ArtifactBagSettor
    param["begPos"] = Vector2(0,0)
    param["spanX"] = 5
    param["spanY"] = 10
    param["createCellCB"] = handler(self,self.CreateCellCB)
    param["updateCellCB"] = handler(self,self.UpdateCellCB)
    param["cellCount"] = cellCount
    self.PageScrollView = ScrollViewUtil.CreateItems(param)
end

function ArtifactBagPanel:CreateCellCB(itemCLS)
    self:UpdateCellCB(itemCLS)
end

function ArtifactBagPanel:UpdateCellCB(itemCLS)
    itemCLS.bag = BagModel.artifact
    if self.bagItems ~=nil then
        local itemBase = self.bagItems[itemCLS.__item_index]
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
                param["itemSize"] = {x=78, y=78}
                param["get_item_cb"] = handler(self,self.GetItemDataByIndex)

                param["model"] = self.model
                param["itemIndex"] = itemCLS.__item_index
                param["stencil_id"] = self.StencilId
                if self.curArtId and self.model:IsCanEquipByArtId(self.curArtId,itemBase.id,itemBase.score) then
                    param["effect_id"] = 20429
                end
                itemCLS:DeleteItem()
                itemCLS:UpdateItem(param)
            end
        else
            local param = {}
            param["bag"] = BagModel.artifact
            param["get_item_cb"] = handler(self,self.GetItemDataByIndex)
            param["model"] = self.model
            itemCLS:InitItem(param)
        end
    else
        local param = {}
        param["bag"] = BagModel.artifact
        param["get_item_cb"] = handler(self,self.GetItemDataByIndex)
        param["model"] = self.model
        itemCLS:InitItem(param)
    end
end

function ArtifactBagPanel:GetItemDataByIndex(index)
    return BagModel.Instance:GetArtifactItemDataByIndex(index)
end
