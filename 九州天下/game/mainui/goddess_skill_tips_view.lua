GoddessSkillTipsView = GoddessSkillTipsView or BaseClass(BaseView)

function GoddessSkillTipsView:__init()
	self.ui_config = {"uis/views/main", "GoddessSkillTips"}
	self.view_layer = UiLayer.Pop
end

function GoddessSkillTipsView:__delete()

end

function GoddessSkillTipsView:ReleaseCallBack( ... )

end

function GoddessSkillTipsView:LoadCallBack()
		self:ListenEvent("CloseWindow", BindTool.Bind(self.CloseWindow, self))
end

function GoddessSkillTipsView:CloseWindow()
	self:Close()
end

function GoddessSkillTipsView:CloseCallBack()
	if self.call_back then
		self.call_back()
	end
end

function GoddessSkillTipsView:SetCloseCallBack(call_back)
	self.call_back = call_back
end