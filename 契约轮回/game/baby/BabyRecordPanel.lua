---
--- Created by  Administrator
--- DateTime: 2019/11/11 16:25
---
BabyRecordPanel = BabyRecordPanel or class("BabyRecordPanel", WindowPanel)
local this = BabyRecordPanel

function BabyRecordPanel:ctor(obj, parent_node, parent_panel)
    self.abName = "baby"
    self.assetName = "BabyRecordPanel"
    self.image_ab = "baby_image";
    self.layer = "UI"
    self.events = {}
    self.use_background = true
    self.click_bg_close = true
    self.panel_type = 5
    self.items = {}
    self.model = BabyModel:GetInstance()
end

function BabyRecordPanel:dctor()
    self.model:RemoveTabListener(self.events)
    if self.items then
        for i, v in pairs(self.items) do
            v:destroy()
        end
        self.items = {}
    end
end



function BabyRecordPanel:LoadCallBack()
    self.nodes = {
        "ScrollView/Viewport/Content","BabyRecordItem","NoObj",
    }
    self:GetChildren(self.nodes)

    self:InitUI()
    self:AddEvent()
    self:SetTileTextImage("baby_image", "baby_titile_tex4")
    BabyController:GetInstance():RequstBabyLikeRecords()
end

function BabyRecordPanel:InitUI()

end

function BabyRecordPanel:AddEvent()
    self.events[#self.events + 1] = self.model:AddListener(BabyEvent.BabyLikeRecord,handler(self,self.BabyLikeRecord))
    self.events[#self.events + 1] = self.model:AddListener(BabyEvent.BabyLike,handler(self,self.BabyLike))
end

function BabyRecordPanel:BabyLike(data)
   -- local id = data.id

    Notify.ShowText("You returned the like")
    self:UpdateInfo(self.model.recordsInfo)
end

function BabyRecordPanel:BabyLikeRecord(data)
   -- dump(self.model.recordsInfo)
    SetVisible(self.NoObj,table.isempty(self.model.recordsInfo) )
    if not table.isempty(self.model.recordsInfo) then
        self:UpdateInfo(self.model.recordsInfo)
    end
end

function BabyRecordPanel:UpdateInfo(tab)
    table.sort(tab, function(a,b)
        return a.state < b.state
    end)
    for i = 1, #tab do
        local item = self.items[i]
        if not item then
            item = BabyRecordItem(self.BabyRecordItem.gameObject,self.Content,"UI")
            self.items[i] = item
        end
        item:SetData(tab[i],i)
    end
end