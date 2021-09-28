DevelopTip = DevelopTip or BaseClass(BaseView)

function DevelopTip:__init()
	self.ui_config = {"uis/views/tips/devoloptip_prefab", "DevelopTip"}
	self.view_layer = UiLayer.MaxLayer
end

function DevelopTip:LoadCallBack()
	self.speed = self:FindVariable("Speed")
	self.run_quest = GlobalTimerQuest:AddRunQuest(function ()
			self:FlushSpeed()
		end, 0)
end

function DevelopTip:ReleaseCallBack()
	if self.run_quest then
		GlobalTimerQuest:CancelQuest(self.run_quest)
		self.run_quest = nil
	end

	self.speed = nil
end

function DevelopTip:FlushSpeed()
	if Scene.Instance then
		local vo = Scene.Instance:GetMainRole().vo
		self.speed:SetValue(vo.move_speed)
	end
end