BabyMenuSubItem = BabyMenuSubItem or class("BabyMenuSubItem",BaseTreeTwoMenu)
local BabyMenuSubItem = BabyMenuSubItem

function BabyMenuSubItem:ctor(parent_node,layer,first_menu_item)
    self.abName = "system"
    self.assetName = "BabyMenuSubItem"
    --self.layer = layer
    self.model = BabyModel:GetInstance()
    self.index = 1
    self.events = {}
    self.layer = layer
    self.first_menu_item = first_menu_item
    BabyMenuSubItem.super.Load(self)
end

function BabyMenuSubItem:dctor()
    if self.redPoint then
        self.redPoint:destroy()
        self.redPoint = nil
    end
    self.model:RemoveTabListener(self.events)
end

function BabyMenuSubItem:LoadCallBack()
    self.nodes = {
        "orderTex","flag","headFrame/head","redParent"
    }
    self:GetChildren(self.nodes)
    self.orderTex = GetText(self.orderTex)
    self.head = GetImage(self.head)
    BabyMenuSubItem.super.LoadCallBack(self)
    self.redPoint = RedDot(self.redParent, nil, RedDot.RedDotType.Nor)
    self.redPoint:SetPosition(0, 0)

end
--
function BabyMenuSubItem:AddEvent()
    self.events[#self.events + 1] = self.model:AddListener(BabyEvent.UpdateOrderInfo,handler(self,self.UpdateOrderInfo))
    BabyMenuSubItem.super.AddEvent(self)
end
--
function BabyMenuSubItem:SetData(first_menu_id,data, select_sub_id,menuSpan, index)
    BabyMenuSubItem.super.SetData(self,first_menu_id,data, select_sub_id,menuSpan)
    self.group = first_menu_id
    self.babyId = data[1]
    self:UpdateInfo()
end

function BabyMenuSubItem:UpdateInfo()
   local cfg,info = self.model:GetBabyInfoAndCfg(self.babyId)
    if  cfg  then
        if cfg.order == 0 and not info then
            self.orderTex.text = "Inactive"
        else
            self.orderTex.text = "T"..cfg.order
        end
    end
    if not info then
        ShaderManager:GetInstance():SetImageGray(self.head)
    else
        ShaderManager:GetInstance():SetImageNormal(self.head)
    end
    SetVisible(self.flag,self.model:GetShowBaby() == self.babyId )
    local icon = cfg.icon
    lua_resMgr:SetImageTexture(self,self.head,"iconasset/icon_baby",icon, false)
end

function BabyMenuSubItem:UpdateOrderInfo(id)
    if id == self.babyId  then
        self:UpdateInfo()
    end
    SetVisible(self.flag,self.model:GetShowBaby() == self.babyId )
end

function BabyMenuSubItem:SetRedPoint()
   -- self.redPoint:SetRedDotParam(isRed)
    local redPoints = BabyModel:GetInstance().babyOrderRedPoints
    local isRed = false
    for i, v in pairs(redPoints[self.babyId]) do
        if v == true then
            isRed = true
            break
        end
    end
    self.redPoint:SetRedDotParam(isRed)
end

