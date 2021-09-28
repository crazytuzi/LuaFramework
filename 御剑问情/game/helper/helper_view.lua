require("game/helper/helper_evaluate_view")
require("game/helper/helper_content_view")
HelperView = HelperView or BaseClass(BaseView)

function HelperView:__init()
	self.ui_config = {"uis/views/helperview_prefab","HelperView"}
	self.full_screen = false
	self.play_audio = true
end

function HelperView:LoadCallBack()
	self.helper_evaluate_view = HelperEvaluateView.New(self:FindObj("helper_evaluate_view"))
	self.helper_content_view = HelperContentView.New(self:FindObj("helper_content_view"))
	self:ListenEvent("close_view", BindTool.Bind(self.OnCloseBtnClick, self))
	self.toggle_list = {}
	for i=1,5 do
		self:ListenEvent("toggle_" .. i, BindTool.Bind2(self.OnToggleClick, self, i))
		self.toggle_list[i] = self:FindObj("toggle_"..i)
	end
	self.toggle_list[1].toggle.isOn = true
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
		end
	end
end

function HelperView:ShowIndexCallBack(index)
	if index == TabIndex.helper_zhanli then
		self.toggle_list[1].toggle.isOn = true
	elseif index == TabIndex.helper_upgrade then
		self.toggle_list[2].toggle.isOn = true
	elseif index == TabIndex.helper_earn then
		self.toggle_list[3].toggle.isOn = true
	elseif index == TabIndex.helper_equip then
		self.toggle_list[4].toggle.isOn = true
	elseif index == TabIndex.helper_strength then
		self.toggle_list[5].toggle.isOn = true
	end
end