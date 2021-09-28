SpiritHarvertLoseView = SpiritHarvertLoseView or BaseClass(BaseView)

function SpiritHarvertLoseView:__init(instance)
	self.ui_config = {"uis/views/spiritview_prefab","SpiritHarvertLose"}
	self.view_layer = UiLayer.Pop
	self.play_audio = true
end

function SpiritHarvertLoseView:__delete()

end

function SpiritHarvertLoseView:SetData()
	if not self:IsOpen() then
		self:Open()
	end
end

function SpiritHarvertLoseView:LoadCallBack()
	self:ListenEvent("OnClick", BindTool.Bind(self.OnClick, self))
end

function SpiritHarvertLoseView:ReleaseCallBack()
end

function SpiritHarvertLoseView:OpenCallBack()
end

function SpiritHarvertLoseView:OnClick()
	SpiritData.Instance:ResetFightResult()
	self:Close()
end