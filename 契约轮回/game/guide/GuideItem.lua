GuideItem = GuideItem or class("GuideItem",BaseItem)
local GuideItem = GuideItem

function GuideItem:ctor(parent_node,layer)
	self.abName = "guide"
	self.assetName = "GuideItem"
	self.layer = layer

	self.model = GuideModel:GetInstance()
	GuideItem.super.Load(self)
end

function GuideItem:dctor()
	self:StopTime()
	if self.event_id then
		GlobalEvent:RemoveListener(self.event_id)
		self.event_id = nil
	end
end

function GuideItem:LoadCallBack()
	self.nodes = {
		"guideimg",
	}
	self:GetChildren(self.nodes)
	self.guideimg = GetImage(self.guideimg)
	self.guideRect = GetRectTransform(self.guideimg)
	self:AddEvent()
	self:UpdateView()
	self:Loop()
end

function GuideItem:AddEvent()
	local function call_back(target)
		if self.parent_node == target.transform and not self.clicked then
			self.clicked = true
			self.model.step_index = self.model.step_index + 1
			GuideController:GetInstance():NextStep(self.data.delay)
		else
			GuideController:GetInstance():NextStep(self.data.delay)
		end
	end
	self.event_id = GlobalEvent:AddListener(GuideEvent.OnClick, call_back)
end

--data:guide_step

function GuideItem:SetData(data)
	self.data = data
	if self.is_loaded then
		self:UpdateView()
	end
end

function GuideItem:UpdateView()
	local off_set = String2Table(self.data.off_set)
	self.transform.anchoredPosition = Vector2(off_set[1], off_set[2])
end

function GuideItem:Loop()
	local pos = {-20,-17,-14,-11,-14,-17}
	self:StopTime()
	local time = 0
	local function step()
		time = time + 1
		if time > 6 then
			time = 1
		end
		SetAnchoredPosition(self.guideRect ,pos[time],0)
	end
	self.time_id = GlobalSchedule:Start(step,0.1)
	step()
end
function GuideItem:StopTime()
	if self.time_id then
		GlobalSchedule:Stop(self.time_id)
	end
end
