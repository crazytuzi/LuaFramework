---
--- Created by  Administrator
--- DateTime: 2019/6/29 15:35
---
WeddingAppointmentItem = WeddingAppointmentItem or class("WeddingAppointmentItem", BaseCloneItem)
local this = WeddingAppointmentItem

function WeddingAppointmentItem:ctor(obj, parent_node, parent_panel)
    WeddingAppointmentItem.super.Load(self)
    self.events = {}
    self.model = MarryModel:GetInstance()
end

function WeddingAppointmentItem:dctor()
    GlobalEvent:RemoveTabListener(self.events)
end

function WeddingAppointmentItem:LoadCallBack()
    self.nodes = {
        "time","des","select","bg"
    }
    self:GetChildren(self.nodes)
    self.time = GetText(self.time)
    self.des = GetText(self.des)
    self.bgImg = GetImage(self.bg)
    self:InitUI()
    self:AddEvent()
end

function WeddingAppointmentItem:InitUI()

end

function WeddingAppointmentItem:AddEvent()

    local function call_back()
        if self.state == 0 then --超时了
            Notify.ShowText("Reservation is unavailable for now")
            return
        elseif self.state == 1 then -- 被预约了

        else

        end
        self.model:Brocast(MarryEvent.WeddingAppointmentItemClick,self.index)
    end
    AddClickEvent(self.bg.gameObject,call_back)
end

function WeddingAppointmentItem:SetData(data,index)
    self.data =  data
    self.index = index
    self:UpdateInfo()
end

function WeddingAppointmentItem:UpdateInfo()
    local startTimeTab = TimeManager:GetTimeDate(self.data.start_time)
    local sTimestr = "";
    if startTimeTab.hour then
        sTimestr = sTimestr .. string.format("%02d", startTimeTab.hour) .. ":";
    end
    if startTimeTab.min then
        sTimestr = sTimestr .. string.format("%02d", startTimeTab.min) .. "";
    end

    local endTimeTab = TimeManager:GetTimeDate(self.data.end_time)
    local eTimestr = "";
    if endTimeTab.hour then
        eTimestr = eTimestr .. string.format("%02d", endTimeTab.hour) .. ":";
    end
    if endTimeTab.min then
        eTimestr = eTimestr .. string.format("%02d", endTimeTab.min) .. "";
    end
    self.time.text = sTimestr.."-"..eTimestr

    self.state = self.model:GetAppointmentState(self.data)
    self:SetState()
end

function WeddingAppointmentItem:SetState()
    if self.state == 0 then --超时了
        self.des.text = "Expired"
        lua_resMgr:SetImageTexture(self, self.bgImg, "marry_image", "marry_itemBg2", true, nil, false)
    elseif self.state == 1 then -- 被预约了
        self.des.text = "Reserved"
        lua_resMgr:SetImageTexture(self, self.bgImg, "marry_image", "marry_itemBg2", true, nil, false)
    else
        self.des.text = "Available"
        lua_resMgr:SetImageTexture(self, self.bgImg, "marry_image", "marry_itemBg", true, nil, false)
    end
end

function WeddingAppointmentItem:SetSelect(isShow)
    SetVisible(self.select,isShow)
end

function WeddingAppointmentItem:SetApping()
    self.state = 1
    self.des.text = "Reserved"
    lua_resMgr:SetImageTexture(self, self.bgImg, "marry_image", "marry_itemBg2", true, nil, false)
end