---
--- Created by  Administrator
--- DateTime: 2019/11/26 11:17
---
CompeteResultPanel = CompeteResultPanel or class("CompeteResultPanel", BasePanel)
local this = CompeteResultPanel

function CompeteResultPanel:ctor(parent_node, parent_panel)

    self.abName = "compete"
    self.assetName = "CompeteResultPanel"
    self.layer = "Top"
    self.use_background = true
    self.change_scene_close = true
    self.item_list = {}
    self.count = 5
    self.model = CompeteModel:GetInstance()
end

function CompeteResultPanel:dctor()
    --GlobalEvent:RemoveTabListener(self.events)
    if not table.isempty(self.item_list ) then
        for i, v in pairs(self.item_list ) do
            v:destroy()
        end
        self.item_list = {}
    end
    if self.schedules then
        GlobalSchedule:Stop(self.schedules);
    end
    destroySingle(self.eft)
end

function CompeteResultPanel:Open(data)
    self.data = data
    CompeteResultPanel.super.Open(self)
end

function CompeteResultPanel:LoadCallBack()
    self.nodes = {
        "okBtn","jifen/txt_jifenNum","title","time","jifen/jifenIcon","iconParent","effParent","bg"
    }
    self:GetChildren(self.nodes)
    --self:SetMask()
    self.txt_jifenNum = GetText(self.txt_jifenNum)
    SetVisible(self.title,false)
    self.time = GetText(self.time)
    self.jifenIcon = GetImage(self.jifenIcon)
    self.title = GetImage(self.title)
    self:InitUI()
    self:AddEvent()
    LayerManager:GetInstance():AddOrderIndexByCls(self,self.effParent.transform,nil,true,nil,nil,1)
    --LayerManager:GetInstance():AddOrderIndexByCls(self,self.bg.transform,nil,true,nil,nil,2)
    --LayerManager:GetInstance():AddOrderIndexByCls(self,self.title.transform,nil,true,nil,nil,2)

end

function CompeteResultPanel:InitUI()
    local iconName = Config.db_item[enum.ITEM.ITEM_ARENA_MONEY].icon
    GoodIconUtil:CreateIcon(self, self.jifenIcon, iconName, true)
    local titleName = "compete_result_2"
    if self.data.is_win then
        titleName = "compete_result_1"
        destroySingle(self.eft)
        self.eft = UIEffect(self.effParent, 10126, false, self.layer)
        self.eft:SetOrderIndex(421)
    end
    local function call_back(sp)
        self.title.sprite = sp
        SetVisible(self.title.transform,true)
        LayerManager:GetInstance():AddOrderIndexByCls(self,self.title.transform,nil,true,nil,nil,2)
    end
    lua_resMgr:SetImageTexture(self, self.title, "compete_image",titleName, true, call_back, false)



   -- local tab = self.data.reward
    local tab = {}
    for i,v in pairs(self.data.reward) do
        table.insert(tab,i)
    end
    table.sort(tab,function(a,b)
        local cfg1 = Config.db_item[a]
        local cfg2 = Config.db_item[b]
        return cfg1.color > cfg2.color
    end)
    local index = 1
    for i, v in pairs(tab) do
        local id = v
        local num = self.data.reward[v]
        if id ~= enum.ITEM.ITEM_ARENA_MONEY then
            local item = self.item_list[index]
            if not item then
                item = STGoodsItem(self.iconParent)
                self.item_list[index] = item
            end
            item:SetData(id,num,2,self.StencilId)
            index = index + 1
        else
            self.txt_jifenNum.text = num
        end
    end
    --self.schedule = Schedule()
    --self.schedule_id = self.schedule:Start(handler(self,self.AddGoodsItem), 0.08, index)
    if self.schedules then
        GlobalSchedule:Stop(self.schedules);
    end
    self.schedules = GlobalSchedule:Start(handler(self,self.AutoClose), 1, -1);

end

function CompeteResultPanel:AutoClose()
    self.count = self.count - 1
    self.time.text = self.count.."Closing in X sec"
    if self.count <= 0 then
        self.count = 5
        self:OkClick()
        if self.schedules then
            GlobalSchedule:Stop(self.schedules);
        end
    end
end

function CompeteResultPanel:AddEvent()
    local function call_back()
        self:OkClick()
    end
    AddClickEvent(self.okBtn.gameObject,call_back)
end

function CompeteResultPanel:OkClick()
    self:Close()
end

function CompeteResultPanel:AddGoodsItem()
    
end

--function CompeteResultPanel:SetMask()
--    self.StencilId = GetFreeStencilId()
--    self.StencilMask = AddRectMask3D(self.Viewport.gameObject)
--    self.StencilMask.id = self.StencilId
--end


