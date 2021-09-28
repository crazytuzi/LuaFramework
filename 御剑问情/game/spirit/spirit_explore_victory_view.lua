SpiritExploreVictoryView = SpiritExploreVictoryView or BaseClass(BaseView)

function SpiritExploreVictoryView:__init(instance)
	self.ui_config = {"uis/views/spiritview_prefab","SpiritExploreVictory"}
	self.view_layer = UiLayer.Pop
	self.play_audio = true
end

function SpiritExploreVictoryView:__delete()

end

function SpiritExploreVictoryView:SetData()
	if not self:IsOpen() then
		self:Open()
	end
end

function SpiritExploreVictoryView:LoadCallBack()
	self:ListenEvent("OnClick", BindTool.Bind(self.OnClick, self))
end

function SpiritExploreVictoryView:ReleaseCallBack()
end

function SpiritExploreVictoryView:OpenCallBack()
end

function SpiritExploreVictoryView:OnClick()
	self:Close()
	--SpiritCtrl.Instance:CloseHomeFightView()
end