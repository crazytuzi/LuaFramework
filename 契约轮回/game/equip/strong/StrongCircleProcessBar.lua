--
-- @Author: chk
-- @Date:   2018-10-24 15:55:50
--
StrongCircleProcessBar = StrongCircleProcessBar or class("CircleProcessBar",BaseItem)
local StrongCircleProcessBar = StrongCircleProcessBar

function StrongCircleProcessBar:ctor(parent_node,layer)
	self.abName = "equip"
	self.assetName = "CircleProcessBar"
	self.layer = layer

    self.speed = 0
	self.crntProcess = 0
    StrongCircleProcessBar.super.Load(self)
end

function StrongCircleProcessBar:dctor()
    GlobalSchedule:Stop(self.schel_id)
end

function StrongCircleProcessBar:LoadCallBack()
	self.nodes = {
		"process",
        "innerCircle",
        "indicator",
	}
	self:GetChildren(self.nodes)
    self:GetRectTransform()
	self:AddEvent()

    if self.need_load_end then
        self:UpdateProcess(self.bless,self.max_bless)
    end
end

function StrongCircleProcessBar:AddEvent()
end

function StrongCircleProcessBar:GetRectTransform()
    self.processImg = self.process:GetComponent('Image')
end

function StrongCircleProcessBar:SetData(data)

end

function StrongCircleProcessBar:UpdateProcess(bless, max_bless)
    self.bless = bless
    self.max_bless = max_bless
    local process = bless/max_bless
    local interval = (process - self.crntProcess)/10

    if self.is_loaded then

        if self.schel_id ~= nil then
            GlobalSchedule:Stop(self.schel_id)
            self.schel_id = nil
        end

        local function call_back()
            self.crntProcess = self.crntProcess + interval
            self.processImg.fillAmount = self.crntProcess
        end
        self.schel_id = GlobalSchedule:Start(call_back, Time.deltaTime, 10)

    else
        self.need_load_end = true
    end
end