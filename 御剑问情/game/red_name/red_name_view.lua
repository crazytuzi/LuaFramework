RedNameView = RedNameView or BaseClass(BaseView)

function RedNameView:__init()
	self.ui_config = {"uis/views/redname_prefab", "RedNameView"}

	self.view_layer = UiLayer.Pop
	self.play_audio = true

end

function RedNameView:__delete()

end

function RedNameView:LoadCallBack()
	self:ListenEvent("Close", BindTool.Bind(self.CloseWindow, self))	
	self:ListenEvent("ToBuy", BindTool.Bind(self.ToBuy, self))
end

function RedNameView:ReleaseCallBack()
	-- 清理变量和对象
	self.notice = nil
end

function RedNameView:CloseWindow()
	self:Close()
	RedNameCtrl.Instance:AskNoMoreOpenMessageBox()
end

function RedNameView:ToBuy()
	self:Close()
	ViewManager.Instance:Open(ViewName.Shop,TabIndex.shop_baoshi)
end

function RedNameView:OpenCallBack()
	self.notice = self:FindVariable("Notice")
	local reduce_percent_hp, reduce_percent_gongji = RedNameCtrl.Instance:GetReducePercentHpAndGongji()
	local str = string.format(Language.Common.RedNameContent, reduce_percent_hp, reduce_percent_gongji, PlayerData.Instance:GetAttr("evil"))
	self.notice:SetValue(str)
end

function RedNameView:OnFlush()
end

