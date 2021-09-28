TaskInlayEquipment =BaseClass(TaskBehavior)
function TaskInlayEquipment:Behavior()
	self:SetTaskTargetType(TaskConst.TaskTargetType.InlayEquipment)
end