TipsVipBuffView = TipsVipBuffView or BaseClass(BaseView)

function TipsVipBuffView:__init()
	self.ui_config = {"uis/views/tips/vipbufftips", "VipBuffTips"}
	self.play_audio = true
	self.view_layer = UiLayer.Pop
	self:SetMaskBg(true)
end

function TipsVipBuffView:LoadCallBack()
	self.info_str = {}
	self.info_obj = {}
	for i = 1, 11 do
		self.info_str[i] = self:FindVariable("info_str" .. i)
		self.info_obj[i] = self:FindObj("Info" .. i)
	end
	self.fight_power = self:FindVariable("fight_power")
	self.vip_num = self:FindVariable("vip_num")
	self:ListenEvent("close_click",BindTool.Bind(self.OnCloseClick, self))
end

function TipsVipBuffView:ReleaseCallBack()
	self.info_str = {}
	self.info_obj = {}
	self.fight_power = nil
	self.vip_num = nil
	self.vip_level = nil
end

function TipsVipBuffView:OnFlush()
	self.vip_num:SetValue(string.format(Language.Vip.TipsVipDes, self.vip_level))
	self.fight_power:SetValue(VipData.Instance:GetVipBuffFightPower(self.vip_level))
	local data = VipData.Instance:GetVipBuffData(self.vip_level)
	for i = 1, 11 do
		if data[i] then
			self.info_obj[i]:SetActive(true)
			self.info_str[i]:SetValue(data[i])
		else
			self.info_str[i]:SetValue(nil)
			self.info_obj[i]:SetActive(false)
		end
	end
end

function TipsVipBuffView:SetData(vip_level)
	self.vip_level = vip_level
	if self.vip_level == nil or self.vip_level == 0 then
		self.vip_level = 1
	end
	self:Flush()
end

function TipsVipBuffView:OnCloseClick()
	self:Close()
end