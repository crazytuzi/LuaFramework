---
--- Created by  Administrator
--- DateTime: 2019/11/27 16:29
---
CompeteEnrollItem = CompeteEnrollItem or class("CompeteEnrollItem", BaseCloneItem)
local this = CompeteEnrollItem

function CompeteEnrollItem:ctor(obj, parent_node, parent_panel)
    CompeteEnrollItem.super.Load(self)
    self.events = {}
    self.model = CompeteModel:GetInstance()
end

function CompeteEnrollItem:dctor()
    GlobalEvent:RemoveTabListener(self.events)
end

function CompeteEnrollItem:LoadCallBack()
    self.nodes = {
        "des","cuo","dui","buyBtn"
    }
    self:GetChildren(self.nodes)
    self.des = GetText(self.des)
    self:InitUI()
    self:AddEvent()
end

function CompeteEnrollItem:InitUI()

end

function CompeteEnrollItem:AddEvent()
    
    local function call_back() --
        OpenLink(180,1,2,1,2127)
    end
    AddClickEvent(self.buyBtn.gameObject,call_back)
end
function CompeteEnrollItem:SetData(data)
    self.data = data
    local des = ""
    SetVisible(self.buyBtn,false)
    if type(self.data[1]) == "number" then --入场券
        SetVisible(self.buyBtn,true)
        local color = "eb0000" --红
        local num =  BagModel:GetInstance():GetItemNumByItemID(self.data[1])
        if num >= self.data[2] then
            color = "6CFE00"
            self:SetState(true)
        else
            self:SetState(false)
        end
        des = string.format("Diamond Ring Ticket (<color=#%s>%s/%s</color>)",color,num,self.data[2])

    else
        local role = RoleInfoModel:GetInstance():GetMainRoleData()
        if self.data[1] == "wake" then --觉醒
            local wake = role.wake
            local color = "eb0000" --红
            if wake >= self.data[2] then
                color = "6CFE00"
                self:SetState(true)
            else
                self:SetState(false)
            end
            des = string.format("When you finished %s times awakening(<color=#%s>%s/%s</color>)",self.data[2],color,wake,self.data[2])
        elseif self.data[1] == "level" then --等級
            local level = role.level
            local color = "eb0000" --红
            if level >= self.data[2] then
                color = "6CFE00"
                self:SetState(true)
            else
                self:SetState(false)
            end
            des = string.format("When you reaches Lv.%s (<color=#%s>%s/%s</color>)",self.data[2],color,level,self.data[2])
        elseif self.data[1] == "rank" then --排名
            local  rank = self.model.powerRank
            local color = "eb0000" --红
            if rank <= self.data[2] and rank~= 0 then
                color = "6CFE00"
                self:SetState(true)
            else
                self:SetState(false)
            end
            if rank == 0 then
                rank = "Didn't make list"
            end
            des = string.format("Top %s of Server CP Rankings (<color=#%s>%s/%s</color>)",self.data[2],color,rank,self.data[2])
        end
    end
    self.des.text =  des
    --dump(data)
end

function CompeteEnrollItem:SetState(boo)
    if boo then
        SetVisible(self.dui,true)
        SetVisible(self.cuo,false)
    else
        SetVisible(self.dui,false)
        SetVisible(self.cuo,true)
    end
end

function CompeteEnrollItem:UpdateNums()
    local des = ""
    local color = "eb0000" --红
    local num =  BagModel:GetInstance():GetItemNumByItemID(self.data[1])
    if num >= self.data[2] then
        color = "6CFE00"
        self:SetState(true)
    else
        self:SetState(false)
    end
    des = string.format("Diamond Ring Ticket (<color=#%s>%s/%s</color>)",color,num,self.data[2])
    self.des.text =  des
end