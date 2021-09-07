FuBenWingStoryView = FuBenWingStoryView or BaseClass(BaseView)

function FuBenWingStoryView:__init()
	self.ui_config = {"uis/views/fubenview", "WingStoryFbView"}

	self.open_door_callback = nil
end

function FuBenWingStoryView:__delete()
	self.open_door_callback = nil
end

function FuBenWingStoryView:LoadCallBack()
	self.show_open_door = self:FindVariable("ShowOpenDoor")
	self:ListenEvent("OpenDoor", BindTool.Bind(self.OnClickOpenDoor, self))
end

function FuBenWingStoryView:ShowOpenDoorView(open_door_callback)
	self.open_door_callback = open_door_callback
	self.show_open_door:SetValue(true)
end

function FuBenWingStoryView:OnClickOpenDoor()
	self.show_open_door:SetValue(false)
	if nil ~= self.open_door_callback then
		self.open_door_callback()
	end
end
