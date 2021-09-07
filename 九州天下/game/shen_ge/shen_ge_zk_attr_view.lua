ShenGeZKAttrTipView = ShenGeZKAttrTipView or BaseClass(BaseView)

function ShenGeZKAttrTipView:__init()
	self.ui_config = {"uis/views/shengeview", "ShenGeZKAttrTip"}
	self.play_audio = true
	self.view_layer = UiLayer.Pop
	self:SetMaskBg(true)
end

function ShenGeZKAttrTipView:LoadCallBack()
	self.info_str = {}
	self.info_obj = {}
	self.attr_value = {}
	for i = 1, 12 do
		self.info_str[i] = self:FindVariable("info_str" .. i)
		self.info_obj[i] = self:FindObj("Info" .. i)
		self.attr_value[i] = self:FindVariable("attr_" .. i)

	end
	self.fight_power = self:FindVariable("fight_power")
	self:ListenEvent("close_click",BindTool.Bind(self.OnCloseClick, self))
end

function ShenGeZKAttrTipView:ReleaseCallBack()
	self.info_str = {}
	self.info_obj = {}
	self.attr_value = {}
	self.fight_power = nil
end

function ShenGeZKAttrTipView:ShowIndexCallBack()
	self:Flush()
end

function ShenGeZKAttrTipView:OnFlush()
	local cfg, cap = ShenGeData.Instance:GetShenGeZKAttrCfg()
	if self.fight_power ~= nil then
		self.fight_power:SetValue(cap or 0)
	end

	if cfg ~= nil then
		for i = 1, 12 do
			if cfg[i] ~= nil then
				self.info_obj[i]:SetActive(true)
				self.info_str[i]:SetValue(cfg[i].str)
				self.attr_value[i]:SetValue(cfg[i].val)
			else
				self.info_str[i]:SetValue(nil)
				self.info_obj[i]:SetActive(false)
				self.attr_value[i]:SetValue(nil)
			end
		end
	end
end

function ShenGeZKAttrTipView:OnCloseClick()
	self:Close()
end