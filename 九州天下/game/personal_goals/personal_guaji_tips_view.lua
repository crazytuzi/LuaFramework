PersonGuaTips = PersonGuaTips or BaseClass(BaseView)

function PersonGuaTips:__init()
	self.ui_config = {"uis/views/serveractivity/goals", "PersonalGuajiTips"}
	self.view_layer = UiLayer.Pop
end

function PersonGuaTips:__delete()

end

function PersonGuaTips:ReleaseCallBack()

end

function PersonGuaTips:LoadCallBack()
		self:ListenEvent("CloseWindow", BindTool.Bind(self.CloseWindow, self))
end

function PersonGuaTips:CloseWindow()
	PersonalGoalsCtrl.Instance:SendFinishGoleReq()
	self:Close()
end