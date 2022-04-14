---
--- Created by  Administrator
--- DateTime: 2019/11/11 16:26
---
BabyRecordItem = BabyRecordItem or class("BabyRecordItem", BaseCloneItem)
local this = BabyRecordItem

function BabyRecordItem:ctor(obj, parent_node, parent_panel)
    BabyRecordItem.super.Load(self)
    self.events = {}
    self.model = BabyModel:GetInstance()
end

function BabyRecordItem:dctor()
    --self.model:RemoveTabListener(self.events)
end

function BabyRecordItem:LoadCallBack()
    self.nodes = {
        "des","zanBtn","time","bg"
    }
    self:GetChildren(self.nodes)
    self.des = GetText(self.des)
    self.time = GetText(self.time)
    self.zanBtnImg = GetImage(self.zanBtn)
    self:InitUI()
    self:AddEvent()
end

function BabyRecordItem:InitUI()

end

function BabyRecordItem:AddEvent()
    local function call_back()
        if self.state == 1 then
            return
        end
        BabyController:GetInstance():RequstBabyLike(self.data.role_id)
    end
    AddButtonEvent(self.zanBtn.gameObject,call_back)
    --self.events[#self.events + 1] = self.model:AddListener(BabyEvent.BabyLike,handler(self,self.BabyLike))
end

--function BabyRecordItem:BabyLike(data)
--
--end

function BabyRecordItem:SetData(data,index)
    self.data = data
    SetVisible(self.bg,index%2 == 0)
    self.des.text = string.format("<color=#%s>%s</color> just liked your baby","49a3ff",self.data.role_name)
    local time = os.date("%m-%d %H:%M:%S", self.data.time)
    self.time.text = time
    self:SetBtnState(self.data.state)
end

function BabyRecordItem:SetBtnState(state)
    self.state = state
    if self.state == 1 then --点赞了
        ShaderManager:GetInstance():SetImageGray(self.zanBtnImg)
    else
        ShaderManager:GetInstance():SetImageNormal(self.zanBtnImg)
    end
end