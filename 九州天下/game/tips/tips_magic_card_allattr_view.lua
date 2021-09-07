TipsMCAllAttrView = TipsMCAllAttrView or BaseClass(BaseView)

function TipsMCAllAttrView:__init()
	self.ui_config = {"uis/views/tips/magiccardtips","AllAttrTip"}

	self.full_screen = false
	self.data = {}
	self.play_audio = true
	self.view_layer = UiLayer.Pop
end

function TipsMCAllAttrView:LoadCallBack()
	self.fight = self:FindVariable("fight")
	self.all_def = self:FindVariable("all_def")
	self.all_hp = self:FindVariable("all_hp")
	self.all_atk = self:FindVariable("all_atk")
	self.jihuo = self:FindVariable("jihuo")

	self.suit_list = {{},{},{},{}}
	for i=1,4 do
		self.suit_list[i].suit_explain = self:FindVariable("suit0"..i.."_explain")
		self.suit_list[i].suit_hp = self:FindVariable("suit0"..i.."_hp")
		self.suit_list[i].suit_atk = self:FindVariable("suit0"..i.."_atk")
		self.suit_list[i].suit_def = self:FindVariable("suit0"..i.."_def")
		self.suit_list[i].suit_fight = self:FindVariable("suit0"..i.."_fight")
	end

	self:ListenEvent("OnClickCloseButton", BindTool.Bind(self.OnClickCloseButton,self))
end

function TipsMCAllAttrView:OnClickCloseButton()
	self:Close()
end

function TipsMCAllAttrView:OnFlush()
	self:FlushData()
end

function TipsMCAllAttrView:FlushData()
	local all_info = {}
	all_info = MagicCardData.Instance:GetAllInfo()

	self.data.fight = CommonDataManager.GetCapabilityCalculation(all_info)
	self.fight:SetValue(self.data.fight)
	self.all_def:SetValue(all_info.fang_yu)
	self.all_hp:SetValue(all_info.max_hp)
	self.all_atk:SetValue(all_info.gong_ji)

	local suit_data = {}
	local info_list = {}
	for i=1,4 do
		suit_data = MagicCardData.Instance:GetCardTaoZByColor(i - 1)
		self.suit_list[i].suit_hp:SetValue(suit_data.maxhp)
		self.suit_list[i].suit_atk:SetValue(suit_data.gongji)
		self.suit_list[i].suit_def:SetValue(suit_data.fangyu)

		info_list.max_hp = suit_data.maxhp
		info_list.gong_ji = suit_data.gongji
		info_list.fang_yu = suit_data.fangyu
		info_list.ming_zhong = suit_data.mingzhong
		info_list.shan_bi = suit_data.shanbi
		local fight = CommonDataManager.GetCapabilityCalculation(info_list)
		self.suit_list[i].suit_fight:SetValue(fight)
		local color = MagicCardData.Instance:GetRgbByColor(suit_data.color)
		if MagicCardData.Instance:GetCardSuitIsActive(i - 1) then
			self.suit_list[i].suit_explain:SetValue(string.format("<color=%s>%s</color> <color=#00ff00>(" .. Language.Common.YiActivate .. ")</color>",color,suit_data.taoka_name))
		else
			-- suit_data = MagicCardData.Instance:GetCardTaoZByColor(i - 1)
			self.suit_list[i].suit_explain:SetValue(string.format("<color=%s>%s</color> <color=#ff0000>(" .. Language.Common.NoActivate .. ")</color>",color,suit_data.taoka_name))
			-- self.suit_list[i].suit_hp:SetValue(0)
			-- self.suit_list[i].suit_atk:SetValue(0)
			-- self.suit_list[i].suit_def:SetValue(0)
			-- self.suit_list[i].suit_fight:SetValue(0)
		end
	end
end
