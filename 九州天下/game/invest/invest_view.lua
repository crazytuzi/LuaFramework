require("game/invest/invest_content_one_view")
require("game/invest/invest_content_two_view")
InvestView = InvestView or BaseClass(BaseView)

function InvestView:__init()
	InvestView.Instance = self
	self.ui_config = {"uis/views/investview","InvestView"}
	self.full_screen = false
	self.play_audio = true
end

function InvestView:__delete()

end

function InvestView:LoadCallBack()
	self:ListenEvent("close_click", BindTool.Bind(self.OnCloseClick, self))
	self.invest_content_one_view = InvestContentOneView.New(self:FindObj("invest_content_one_view"))
	self.invest_content_two_view = InvestContentTwoView.New(self:FindObj("invest_content_two_view"))
end

function InvestView:OpenCallBack()
	self:ShowContent()
	self.invest_content_two_view:OpenCallBack()
	InvestData.Instance:SetIsOpenStatus(true)
end

function InvestView:OnCloseClick()
	self:Close()
	GlobalEventSystem:Fire(MainUIEventType.CHANGE_MAINUI_BUTTON, MainUIData.RemindingName.show_invest_icon, InvestData.Instance:IsOpenInvestButton())
end

function InvestView:ShowContent()
	local buy_time = InvestData.Instance:GetInvestInfo().buy_time

	if buy_time == 0 or InvestData.Instance:GetSevenDayAwardFlag() then
		self.invest_content_one_view:SetActive(true)
		self.invest_content_two_view:SetActive(false)
	else
		self.invest_content_one_view:SetActive(false)
		self.invest_content_two_view:SetActive(true)
	end
end
