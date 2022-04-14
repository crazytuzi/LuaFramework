---
--- Created by  Administrator
--- DateTime: 2019/5/7 14:48
---
ArenaBigDownItem = ArenaBigDownItem or class("ArenaBigDownItem", BaseCloneItem)
local this = ArenaBigDownItem

function ArenaBigDownItem:ctor(obj, parent_node, parent_panel)
    ArenaBigDownItem.super.Load(self)
    self.events = {}
    self.model = ArenaModel:GetInstance()
end

function ArenaBigDownItem:dctor()
    GlobalEvent:RemoveTabListener(self.events)

end

function ArenaBigDownItem:LoadCallBack()
    self.nodes = {
        "power", "rank", "click", "select", "headBG/mask/head", "name", "powerUp",
    }
    self:GetChildren(self.nodes)
    self.name = GetText(self.name)
    self.power = GetText(self.power)
    self.head = GetImage(self.head)
    self.rank = GetText(self.rank)
    self:InitUI()
    self:AddEvent()
end

function ArenaBigDownItem:InitUI()

end

function ArenaBigDownItem:AddEvent()
    local function call_back()
        self.model:Brocast(ArenaEvent.ArenaBigItemClick, self.index)
    end
    AddClickEvent(self.click.gameObject, call_back)
end

function ArenaBigDownItem:SetData(data, index)
    self.index = index
    self.data = data
    self:SetPos()
    self:SetInfo()

end
function ArenaBigDownItem:SetPos()
    if self.data.rank < 7 then
        local x = (self.data.rank - 4) * 280
        local y = 0
        if self.data.rank == 5 then
            y = -5
        end
        SetLocalPosition(self.transform, x, y, 0)
        -- self.data.rank -
    else
        local x = -170 + (self.data.rank - 7) * 325
        local y = -75
        if self.data.rank == 9 then
            x = -170 + (self.data.rank - 7) * 290
        elseif self.data.rank == 10 then
            x = -170 + (self.data.rank - 7) * 310
        end
        SetLocalPosition(self.transform, x, y, 0)
    end
end

function ArenaBigDownItem:SetInfo()
    self.name.text = self.data.name
    --self.power.text = "战力："..self.data.power
    self.rank.text = "No." .. self.data.rank .. "No. X"
    local power = GetShowNumber(self.data.power)
    self.power.text = "CP:" .. power
    --if self.data.sti_times > 0  then
    --    local power =  self.model:GetPower(self.data.sti_times,self.data.power)
    --    self.power.text =  "战力："..power
    --else
    --    local power = GetShowNumber(self.data.power)
    --    self.power.text =  "战力："..power
    --end
    SetVisible(self.powerUp, self.data.sti_times > 0)
    if self.data.gender == 1 then
        --男
        lua_resMgr:SetImageTexture(self, self.head, "main_image", "img_role_head_1", true, nil, false)
    else
        lua_resMgr:SetImageTexture(self, self.head, "main_image", "img_role_head_2", true, nil, false)
    end
end

function ArenaBigDownItem:SetShow(isShow)
    SetVisible(self.select, isShow)
end
