HetiBuffView = HetiBuffView or BaseClass(BaseView)

function HetiBuffView:__init()
	self.ui_config = {"uis/views/tips/vipbufftips", "VipBuffTips"}
	self.play_audio = true
	self.view_layer = UiLayer.Pop
	self:SetMaskBg(true)
end

function HetiBuffView:LoadCallBack()
	self.info_str = {}
	self.info_obj = {}
	for i = 1, 11 do
		self.info_str[i] = self:FindVariable("info_str" .. i)
		self.info_obj[i] = self:FindObj("Info" .. i)
	end
	self.fight_power = self:FindVariable("fight_power")
	self.show_text_tips = self:FindVariable("ShowTextTips")
	self.text_tips = self:FindVariable("TextTips")
	self.text_tips:SetValue(Language.Beaut.HetiAttrTips)
	self.vip_num = self:FindVariable("vip_num")
	self:ListenEvent("close_click",BindTool.Bind(self.OnCloseClick, self))
end

function HetiBuffView:OpenCallBack()
	self:Flush()
end

function HetiBuffView:ReleaseCallBack()
	self.info_str = {}
	self.info_obj = {}
	self.fight_power = nil
	self.vip_num = nil
	self.vip_level = nil
	self.text_tips = nil
	self.show_text_tips = nil
end

function HetiBuffView:OnFlush()
	self.vip_num:SetValue(Language.Beaut.BtnTextHetiAttr)
	local data = BeautyData.Instance:GetHetisData()
	local is_show_tips = true
	for i = 1, 11 do
		if data[i] then
			is_show_tips = false
			self.info_obj[i]:SetActive(true)
			self.info_str[i]:SetValue(Language.Common.AttrNameNoUnderline[Language.Beaut.HetiAttrType[data[i].attr_type]]  .. "+<color='#029120FF'>" .. data[i].attr_value.."</color>")
		else
			self.info_str[i]:SetValue(nil)
			self.info_obj[i]:SetActive(false)
		end
	end
	self.show_text_tips:SetValue(is_show_tips)
	self.fight_power:SetValue(CommonDataManager.GetCapabilityCalculation(BeautyData.Instance:GetHetiCapability()))
end

function HetiBuffView:OnCloseClick()
	self:Close()
end