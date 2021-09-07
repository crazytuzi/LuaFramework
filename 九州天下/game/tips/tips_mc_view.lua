TipsMCView = TipsMCView or BaseClass(BaseView)

function TipsMCView:__init()
	self.ui_config = {"uis/views/tips/magiccardtips","CardAttr"}

	self.close_callback = nil
	self.play_audio = true
	self.view_layer = UiLayer.Pop
end

function TipsMCView:__delete()
	self.close_callback = nil
end

function TipsMCView:LoadCallBack()
	self.card_name = self:FindVariable("CardName")
	self.card_status = self:FindVariable("CardStatus")
	self.card_uselevel = self:FindVariable("use_level")
	self.card_icon = self:FindVariable("Icon1")
	self.card_explain = self:FindVariable("CardExplain")
	self.hp = self:FindVariable("ShengMing")
	self.atk = self:FindVariable("GongJi")
	self.def = self:FindVariable("FangYu")
	self.level = self:FindVariable("level")
	self.buttontext = self:FindVariable("buttontext")

	self.ActiveText = self:FindObj("ActiveText")
	self.AttrContent = self:FindObj("AttrContent")
	self.KeyButton = self:FindObj("KeyButton")
	self.RoleImage = self:FindObj("RoleImage")

	self:ListenEvent("OnClickCloseButton", BindTool.Bind(self.OnClickCloseButton,self))
	self:ListenEvent("OnClickKeyButton", BindTool.Bind(self.OnClickKeyButton,self))
end

function TipsMCView:OnClickCloseButton()
	self:Close()
	if self.close_callback ~= nil then
		self.close_callback()
	end
end

function TipsMCView:JumpUpGrade()
	MoLongView.Instance:OnUpMcUpLevelToggle()
	MagicCardUpView.Instance:GetCardData(self.data)
	MagicCardUpView.Instance:FlushUpLevel(true)
	MagicCardUpView.Instance:FlushData()
end

function TipsMCView:OnClickKeyButton()
	if nil == self.data then return end

	if self.data.is_active then
		self:JumpUpGrade()
	else
		MoLongCtrl.Instance:SendMagicCardOperaReq(MAGIC_CARD_REQ_TYPE.MAGIC_CARD_REQ_TYPE_USE_CARD,self.data.card_id)
		if self.close_callback ~= nil then
			self.close_callback(self.data)
		end
	end
	self:Close()
end

function TipsMCView:OnFlush()
	self:FlushData()
end

function TipsMCView:SetData(data,close_callback)
	self.data = data
	self.close_callback = close_callback
	local info_data = {}
	info_data = MagicCardData.Instance:GetInfoById(data.card_id)
	self.data.card_name = info_data.card_name
	self.data.color = info_data.color
	self.data.type = info_data.type
	self.data.is_active = MagicCardData.Instance:GetCardIsActive(data.card_id)

	if self.data.type == 0 then
		self.data.is_exp = false
		self.data.level = MagicCardData.Instance:GetCardInfoListByIndex(data.card_id).strength_level
		self.attr_list = {}
		self.attr_list = MagicCardData.Instance:GetCardInfoByIdAndLevel(self.data.card_id,self.data.level)

		local info_list = {}
		info_list.max_hp = self.attr_list.maxhp
		info_list.gong_ji = self.attr_list.gongji
		info_list.fang_yu = self.attr_list.fangyu
		info_list.ming_zhong = self.attr_list.mingzhong
		info_list.shan_bi = self.attr_list.shanbi

		self.data.fight = CommonDataManager.GetCapabilityCalculation(info_list)

		self.card_suit = {}
		self.card_suit = MagicCardData.Instance:GetCardTaoZByColor(self.data.color)
	else
		self.data.is_exp = true
		self.data.level = 1
	end
end

function TipsMCView:FlushData()
	self.card_name:SetValue(self.data.card_name)
	local str = "Card_"..self.data.item_id
	self.card_icon:SetAsset("uis/views/magiccardview", str)

	if self.data.type == 0 then
		if self.data.is_active then
			self.ActiveText:SetActive(false)
			self.KeyButton:SetActive(false)
		else
			self.ActiveText:SetActive(true)
			self.KeyButton:SetActive(true)
		end
		self.AttrContent:SetActive(true)
		if self.data.level < 10 then
			if self.data.is_active then
				self.card_status:SetValue(string.format("<color=#00ff00>(已激活)</color>"))
				self.buttontext:SetValue("升级")
				self.RoleImage.grayscale.GrayScale = 0
			else
				self.card_status:SetValue(string.format("<color=#ff0000>(" .. Language.Common.NoActivate .. ")</color>"))
				self.buttontext:SetValue("激活")
				self.RoleImage.grayscale.GrayScale = 255
			end
		else
			self.card_status:SetValue(string.format("<color=#00ff00>(已激活)</color>"))
		end

		self.card_uselevel:SetValue(string.format("评分：%s",self.data.fight))

		self.card_explain:SetValue(string.format("%s 套装之 %s",self.card_suit.taoka_name,self.data.card_name))
		self.hp:SetValue(self.attr_list.maxhp)
		self.atk:SetValue(self.attr_list.gongji)
		self.def:SetValue(self.attr_list.fangyu)
		self.level:SetValue(self.data.level)
	else
		self.ActiveText:SetActive(false)
		self.KeyButton:SetActive(false)
		self.buttontext:SetValue("使用")
		self.RoleImage.grayscale.GrayScale = 0
		self.AttrContent:SetActive(false)
		self.card_uselevel:SetValue("")
		self.card_explain:SetValue(string.format("%s,使用后增加魔卡经验",self.data.card_name))
		self.level:SetValue(1)
	end
end

