require("game/temp_mount/temp_mount_view")
require("game/temp_mount/temp_wing_view")
require("game/temp_mount/temp_mount_data")

TempMountCtrl = TempMountCtrl or BaseClass(BaseController)

function TempMountCtrl:__init()
	if TempMountCtrl.Instance then
		print_error("[TempMountCtrl]:Attempt to create singleton twice!")
	end
	TempMountCtrl.Instance = self

	self.data = TempMountData.New()
	self.view = TempMountView.New(ViewName.TempMount)
	self.temp_wing_view = TempWingView.New(ViewName.TempWing)
end

function TempMountCtrl:__delete()
	self.view:DeleteMe()
	self.view = nil

	self.data:DeleteMe()
	self.data = nil

	self.temp_wing_view:DeleteMe()
	self.temp_wing_view = nil

	TempMountCtrl.Instance = nil
end

function TempMountCtrl:OpenView()
	self.view:Open()
end

function TempMountCtrl:CloseView()
	self.view:Close()
end

function TempMountCtrl:GetView()
	return self.view
end

function TempMountCtrl:FlushView(...)
	self.view:Flush(...)
end

function TempMountCtrl:FlushWingView(...)
	self.temp_wing_view:Flush(...)
end