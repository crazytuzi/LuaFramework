require("game/helper/helper_evaluate_view")
require("game/helper/helper_content_view")
HelperView = HelperView or BaseClass(BaseView)

function HelperView:__init()
	self.ui_config = {"uis/views/helperview","HelperView"}
	self.full_screen = false
	self.play_audio = true
	self:SetMaskBg()
end

function HelperView:__delete()

end

function HelperView:LoadCallBack()
	self.helper_evaluate_view = HelperEvaluateView.New(self:FindObj("helper_evaluate_view"))
	self.helper_content_view = HelperContentView.New(self:FindObj("helper_content_view"))
	self:ListenEvent("close_view", BindTool.Bind(self.OnCloseBtnClick, self))
	self.toggle_list = {}
	for i=1,6 do
		self:ListenEvent("toggle_" .. i, BindTool.Bind2(self.OnToggleClick, self, i))
		self.toggle_list[i] = self:FindObj("toggle_"..i)
	end
	self.toggle_list[2].toggle.isOn = true

	self.money_bar = MoneyBar.New()
	self.money_bar:SetInstanceParent(self:FindObj("MoneyBar"))
end

function HelperView:ReleaseCallBack()
	if self.helper_evaluate_view then
		self.helper_evaluate_view:DeleteMe()
		self.helper_evaluate_view = nil
	end
	if self.helper_content_view then	
		self.helper_content_view:DeleteMe()
		self.helper_content_view = nil
	end	
	if self.money_bar then
		self.money_bar:DeleteMe()
		self.money_bar = nil
	end
	for i = 1,6 do
		if self.toggle_list[i] then
			self.toggle_list[i] = nil
		end
	end
	
	self.full_screen = nil
	self.play_audio = nil
end

function HelperView:OnCloseBtnClick()
	self:Close()
end

function HelperView:OnToggleClick(i,is_click)
	if is_click then
		if i > 1 then
			HelperContentView.Instance:SetCurrentHelperType(i)
		end
	end
end

function HelperView:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "kaifu_to_helper" then
			self.toggle_list[2].toggle.isOn = true
		elseif k == "jungong" then
			self.toggle_list[3].toggle.isOn = true
		end
	end
end