---
--- Created by  Administrator
--- DateTime: 2020/2/18 17:54
---
MainTopRightSub = MainTopRightSub or class("MainTopRightSub", BaseItem)
local this = MainTopRightSub

function MainTopRightSub:ctor(parent_node, layer)
    self.abName = "main"
    self.assetName = "MainTopRightSub"
    self.layer = layer
    self.events = {}
    self.model = MainModel:GetInstance()
    self.icon_list = {}
    self.model:Brocast(MainEvent.CloseMainRightSub)
    MainTopRightSub.super.Load(self)
end

function MainTopRightSub:dctor()
    self.model:RemoveTabListener(self.events)
    if not table.isempty(self.icon_list) then
        for i, v in pairs(self.icon_list) do
            v:destroy()
        end
        self.icon_list = {}
    end
end

function MainTopRightSub:LoadCallBack()
    self.nodes = {
        "MainTopRightItem","IconParent","bg"
    }
    self:GetChildren(self.nodes)

    self:InitUI()
    self:AddEvent()
    if self.is_need_setData then
        self:SetData(self.config,self.line_index)
    end
end

function MainTopRightSub:InitUI()

end

function MainTopRightSub:AddEvent()
    local function call_back()
        self:InitIcon()
    end
    self.events[#self.events + 1] = self.model:AddListener(MainEvent.RemoveRightIcon, call_back)

    local function call_back()
        self:destroy()
    end
    self.events[#self.events + 1] = self.model:AddListener(MainEvent.CloseMainRightSub, call_back)

end

function MainTopRightSub:SetData(cfg,line_index)
    self.config = cfg
    self.line_index = line_index
    if not self.config then
        return
    end
    if not self.is_loaded then
        self.is_need_setData = true
        return
    end
    self:InitIcon()

end

function MainTopRightSub:InitIcon()
    local key = self.config.key_str
    local list = {}
    for i, v in pairs(self.model.right_top_icon_sub_list[key]) do
        list[#list + 1] = v
    end
    table.sort(list, function(a,b)
        return a.cf.index < b.cf.index
    end)
    for i = 1, #list do
        local item =  self.icon_list[i]
        if  not item then
            item = MainTopRightItem(self.MainTopRightItem.gameObject,self.IconParent,"UI")
            self.icon_list[i] = item
        else
            item:SetVisible(true)
        end
        item:SetData(list[i])
    end
    for i = #list + 1,#self.icon_list do
        local buyItem = self.icon_list[i]
        buyItem:SetVisible(false)
    end
    self:SetPos(#list)
end

function MainTopRightSub:SetPos(nums)
    --3 230  2 170  110
    local width = 60
    SetSizeDeltaX(self.bg,110 + (nums - 1) * width)
    if self.line_index <= 0 then
        SetLocalPositionX(self.transform,self.transform.position.x-50)
    end
    --logError(self.line_index)
end

