SpiritExploreLoseView = SpiritExploreLoseView or BaseClass(BaseView)

function SpiritExploreLoseView:__init(instance)
	self.ui_config = {"uis/views/spiritview_prefab","SpiritExploreLose"}
	self.view_layer = UiLayer.Pop
	self.play_audio = true
end

function SpiritExploreLoseView:__delete()

end

function SpiritExploreLoseView:SetData()
	if not self:IsOpen() then
		self:Open()
	end
end

function SpiritExploreLoseView:LoadCallBack()
	self:ListenEvent("OnClick", BindTool.Bind(self.OnClick, self))
end

function SpiritExploreLoseView:ReleaseCallBack()
end

function SpiritExploreLoseView:OpenCallBack()
end

function SpiritExploreLoseView:OnClick()
	self:Close()
	--SpiritCtrl.Instance:CloseHomeFightView()
end