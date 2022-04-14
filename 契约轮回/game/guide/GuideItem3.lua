GuideItem3 = GuideItem3 or class("GuideItem3",BaseItem)
local GuideItem3 = GuideItem3

function GuideItem3:ctor(parent_node,layer)
	self.abName = "guide"
	self.assetName = "GuideItem3"
	self.layer = layer

	self.model = GuideModel:GetInstance()
	GuideItem3.super.Load(self)
end

function GuideItem3:dctor()
	cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.finger)
	if self.schedule_id then
		GlobalSchedule:Stop(self.schedule_id)
		self.schedule_id = nil
	end
	if self.event_id then
		GlobalEvent:RemoveListener(self.event_id)
		self.event_id = nil
	end
end

function GuideItem3:LoadCallBack()
	self.nodes = {
		"finger","tip",
	}
	self:GetChildren(self.nodes)
	self.tip = GetText(self.tip)
	self:AddEvent()
	self:UpdateView()
end

function GuideItem3:AddEvent()
	local function call_back( )
		self.model.step_index = self.model.step_index + 1
		GuideController:GetInstance():NextStep(self.data.delay)
	end
	self.event_id = GlobalEvent:AddListener(SceneEvent.ChangeMount, call_back)
end

--data:guide_step
function GuideItem3:SetData(data, node)
	self.data = data
end

function GuideItem3:UpdateView()
	TaskModel:GetInstance():PauseTask()
	self.second = self.data.sec
	self.tip.text = string.format("(Auto mount in %d sec)", self.second)
	local function count()
		self.second = self.second - 1
		self.tip.text = string.format("(Auto mount in %d sec)", self.second)
		if self.second == 0 then
			GlobalSchedule:Stop(self.schedule_id)
			self:Ride()
			self.model.step_index = self.model.step_index + 1
			GuideController:GetInstance():NextStep(self.data.delay)
		end
	end
	self.schedule_id = GlobalSchedule:Start(count, 1.0)
	self:MoveFinger()
end

function GuideItem3:MoveFinger()
	local time = 1
	local y = 180
	local moveAction = cc.MoveTo(time,259,y,0)
	local moveAction2 = cc.MoveTo(0,259,0,0)
	local action = cc.Sequence(moveAction,moveAction2)
	local action2 = cc.RepeatForever(action)
	cc.ActionManager:GetInstance():addAction(action2, self.finger)
end

function GuideItem3:Ride()
	local main_role = SceneManager:GetInstance():GetMainRole()
    if not main_role:IsRiding() then
        local move_pos = main_role.move_pos
        local move_dir = main_role.move_dir
        if not main_role.move_state then
        	move_pos = nil
        end
        local call_back
        if move_pos ~= nil then
            call_back = function()
                main_role:SetMovePosition(move_pos,move_dir)
            end
        end
        main_role:PlayMount(call_back,main_role.is_runing,move_pos)

    else
        main_role:PlayDismount()
    end
end

