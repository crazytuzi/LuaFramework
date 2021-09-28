TianshenhutiOnekeyComposeView = TianshenhutiOnekeyComposeView or BaseClass(BaseView)

function TianshenhutiOnekeyComposeView:__init()
    self.ui_config = {"uis/views/tianshenhutiview_prefab", "QuickComposeView"}
   	self.play_audio = true
end

function TianshenhutiOnekeyComposeView:__delete()

end

function TianshenhutiOnekeyComposeView:CloseCallBack()

end

function TianshenhutiOnekeyComposeView:ReleaseCallBack()
	self.grade = nil
end

function TianshenhutiOnekeyComposeView:LoadCallBack()
	self.grade = self:FindVariable("Grade")
	self.grade:SetValue(2)
	self:ListenEvent("CloseWindow",BindTool.Bind(self.Close, self))
	self:ListenEvent("OnClickEnter",BindTool.Bind(self.OnClickEnter, self))
	self:ListenEvent("OnClickAdd",BindTool.Bind(self.OnClickAdd, self))
	self:ListenEvent("OnClickReduce",BindTool.Bind(self.OnClickReduce, self))
end

function TianshenhutiOnekeyComposeView:OnClickEnter()
	local grade = self.grade:GetInteger()
	TianshenhutiCtrl.SendTianshenhutiQuickCombine(grade)
end

function TianshenhutiOnekeyComposeView:OnClickAdd()
	local grade = self.grade:GetInteger()
	if grade >= TianshenhutiData.Instance:GetMaxLevel() then
		SysMsgCtrl.Instance:ErrorRemind(Language.Tianshenhuti.GradeTips[1])
		return
	end
	self.grade:SetValue(grade + 1)
end

function TianshenhutiOnekeyComposeView:OnClickReduce()
	local grade = self.grade:GetInteger()
	if grade <= 2 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Tianshenhuti.GradeTips[2])
		return
	end
	self.grade:SetValue(grade - 1)
end

function TianshenhutiOnekeyComposeView:OpenCallBack()
	self:Flush()
end

function TianshenhutiOnekeyComposeView:OnFlush(param_list)

end