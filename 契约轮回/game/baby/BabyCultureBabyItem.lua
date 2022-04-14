---
--- Created by  Administrator
--- DateTime: 2019/8/29 11:32
---
BabyCultureBabyItem = BabyCultureBabyItem or class("BabyCultureBabyItem", BaseCloneItem)
local this = BabyCultureBabyItem

function BabyCultureBabyItem:ctor(obj, parent_node, parent_panel)
    self.events = {}
    self.model = BabyModel:GetInstance()
    BabyCultureBabyItem.super.Load(self)


end

function BabyCultureBabyItem:dctor()
    self.model:RemoveTabListener(self.events)
    if self.red then
        self.red:destroy()
        self.red = nil
    end
end

function BabyCultureBabyItem:LoadCallBack()
    self.nodes = {
        "head","select","level","name","bg","kuang"
    }
    self:GetChildren(self.nodes)
    self.name = GetText(self.name)
    self.level = GetText(self.level)
    self.head = GetImage(self.head)
    self.kuang = GetImage(self.kuang)


    self.red = RedDot(self.transform, nil, RedDot.RedDotType.Nor)
    self.red:SetPosition(80, 40)

    self:InitUI()
    self:AddEvent()


end

function BabyCultureBabyItem:InitUI()

end

function BabyCultureBabyItem:AddEvent()
    local function call_back()
        self.model:Brocast(BabyEvent.BabyCultureItemClick,self.data)
    end
    AddClickEvent(self.bg.gameObject,call_back)

    self.events[#self.events + 1] = self.model:AddListener(BabyEvent.UpdateRedPoint,handler(self,self.UpdateRedPoint))
end

function BabyCultureBabyItem:UpdateRedPoint()
    local isRed = false
    for i, red in pairs(self.model.babyCulRedPoints[self.data.gender]) do
        if red == true then
            isRed = true
            break
        end
    end
    self.red:SetRedDotParam(isRed)
    
end


function BabyCultureBabyItem:SetData(data)
    self.data = data
    self.name.text = self.data.name
    local info = self.model:GetBabyInfo(self.data.gender)
    lua_resMgr:SetImageTexture(self, self.head, "baby_image", "baby_Head"..self.data.gender, false, nil, false)
    lua_resMgr:SetImageTexture(self,  self.kuang, "baby_image", "baby_Kuang"..self.data.gender, true, nil, false)
    if not self.model:IsBirth(self.data.gender) then
        self:UpdateLevel(0)
    else
        self:UpdateLevel(info.level)
    end

end

function BabyCultureBabyItem:SetShow(isShow)
    SetVisible(self.select,isShow)
end

function BabyCultureBabyItem:UpdateLevel(level)
    self.level.text = "Level"..level
end