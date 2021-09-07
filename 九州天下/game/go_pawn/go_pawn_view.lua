require("game/go_pawn/go_pawn_content_view")
GoPawnView = GoPawnView or BaseClass(BaseView)

function GoPawnView:__init()
	self.ui_config = {"uis/views/gopawnview","GoPawnView"}
	self.full_screen = false
	self.play_audio = true
end

function GoPawnView:LoadCallBack()
	self.go_pawn_content_view = GoPawnContentView.New(self:FindObj("go_pawn_content_view"))
	self:ListenEvent("close_view", BindTool.Bind(self.OnCloseBtnClick, self))
end

function GoPawnView:__delete()
	if self.go_pawn_content_view ~= nil then
		self.go_pawn_content_view:DeleteMe()
		self.go_pawn_content_view = nil
	end
end

function GoPawnView:OpenCallBack()
	local active_value = ZhiBaoData.Instance:GetActiveDegreeValue()
	if active_value > 200 then
		active_value = 200
	end
	local slider = active_value / 200
	self.go_pawn_content_view:SetActiveSlider(active_value, slider)
	self.go_pawn_content_view:SetRedPoint(GoPawnData.Instance:CheckRedPoint())
end

function GoPawnView:CloseCallBack()
	self.go_pawn_content_view:CloseCallBack()

end

function GoPawnView:ReleaseCallBack()
	UnityEngine.PlayerPrefs.DeleteKey("use_quan")
	UnityEngine.PlayerPrefs.DeleteKey("use_gold")
end

function GoPawnView:OnCloseBtnClick()
	self:Close()
end
