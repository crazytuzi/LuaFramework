TipsMCAttrView = TipsMCAttrView or BaseClass(BaseView)

local POP_TYPE =
	{
		COMMON = 1,
		SHOP = 2,
		NOT_UPGRADE = 3,
	}

function TipsMCAttrView:__init()
	self.ui_config = {"uis/views/tips/magiccardtips","CardAttrTip"}

	self.callback = nil
	self.play_audio = true
	self.view_layer = UiLayer.Pop
end

function TipsMCAttrView:__delete()
	self.callback = nil
end

function TipsMCAttrView:LoadCallBack()
	self.card_name = self:FindVariable("CardName")
	self.card_status = self:FindVariable("CardStatus")
	self.card_score = self:FindVariable("Score")
	self.card_icon = self:FindVariable("Icon1")
	self.card_explain = self:FindVariable("CardExplain")
	self.Name = self:FindVariable("Name")
	self.hp = self:FindVariable("ShengMing")
	self.atk = self:FindVariable("GongJi")
	self.def = self:FindVariable("FangYu")
	self.level = self:FindVariable("level")
	self.buttontext = self:FindVariable("buttontext")

	self.KeyButton = self:FindObj("KeyButton")
	self.RoleImage = self:FindObj("RoleImage")
	self.ActiveText = self:FindObj("ActiveText")
	self.AttrContent = self:FindObj("AttrContent")

	self:ListenEvent("OnClickCloseButton", BindTool.Bind(self.OnClickCloseButton,self))
	self:ListenEvent("OnClickKeyButton", BindTool.Bind(self.OnClickKeyButton,self))
end

function TipsMCAttrView:OnClickCloseButton()
	self:Close()
end

function TipsMCAttrView:SetCallBack(close_callback)
	self.callback = close_callback
end

function TipsMCAttrView:OnClickKeyButton()
	if nil == self.data then return end

	if self.data.is_active then
		self:JumpUpGrade()
	else
		MoLongCtrl.Instance:SendMagicCardOperaReq(MAGIC_CARD_REQ_TYPE.MAGIC_CARD_REQ_TYPE_USE_CARD,self.data.card_id)
	end
	self:Close()
end

function TipsMCAttrView:JumpUpGrade()
	MoLongView.Instance:OnUpMcUpLevelToggle()
	MagicCardUpView.Instance:GetCardData(self.data)
	MagicCardUpView.Instance:FlushUpLevel(true)
	MagicCardUpView.Instance:FlushData()
end

function TipsMCAttrView:OnFlush()
	self:FlushData()
end

function TipsMCAttrView:SetData(data,pop_type,is_nextlevel)
	self.data = data
	self.pop_type = pop_type or POP_TYPE.COMMON
	self.is_nextlevel = is_nextlevel or false
	self.data.is_active = MagicCardData.Instance:GetCardIsActive(data.card_id)
	if pop_type == POP_TYPE.SHOP then
		self.data.level = 1
	else
		if is_nextlevel then
			self.data.level = MagicCardData.Instance:GetCardInfoListByIndex(data.card_id).strength_level + 1
		else
			self.data.level = MagicCardData.Instance:GetCardInfoListByIndex(data.card_id).strength_level
		end
	end

	if self.data.type == 0 then
		self.attr_list = {}
		self.attr_list = MagicCardData.Instance:GetCardInfoByIdAndLevel(data.card_id,self.data.level)

		local info_list = {}
		info_list.max_hp = self.attr_list.maxhp
		info_list.gong_ji = self.attr_list.gongji
		info_list.fang_yu = self.attr_list.fangyu
		info_list.ming_zhong = self.attr_list.mingzhong
		info_list.shan_bi = self.attr_list.shanbi

		self.data.fight = CommonDataManager.GetCapabilityCalculation(info_list)

		self.card_suit = {}
		self.card_suit = MagicCardData.Instance:GetCardTaoZByColor(self.data.color)
	end
end

function TipsMCAttrView:FlushData()
	local color = MagicCardData.Instance:GetRgbByColor(self.data.color)
	self.card_name:SetValue(string.format("<color=%s>%s</color>",color,self.data.card_name))
	self.Name:SetValue(self.data.card_name)
	local str = "Card_"..self.data.item_id
	self.card_icon:SetAsset("uis/views/magiccardview", str)

	if POP_TYPE.SHOP == self.pop_type then
		self:FlushDataInShop()
	elseif POP_TYPE.COMMON == self.pop_type then
		self:FlushDataInAttr()
	else
		self:FlushDataInNotUpGrade()
	end
end

function TipsMCAttrView:FlushDataInShop()
	self.ActiveText:SetActive(false)
	self.KeyButton:SetActive(false)
	self.RoleImage.grayscale.GrayScale = 0
	if self.data.type == 0 then
		self.AttrContent:SetActive(true)
		self.card_score:SetValue(string.format("评分：<color=#ffff00>%s</color>",self.data.fight))
		self.card_explain:SetValue(string.format("%s 套装之 %s",self.card_suit.taoka_name,self.data.card_name))
		self.hp:SetValue(self.attr_list.maxhp)
		self.atk:SetValue(self.attr_list.gongji)
		self.def:SetValue(self.attr_list.fangyu)
		self.level:SetValue(1)
	elseif self.data.type == 1 then
		self.AttrContent:SetActive(false)
		self.card_score:SetValue("")
		self.card_explain:SetValue(string.format("%s,可用于兑换魔卡",self.data.card_name))
		self.level:SetValue(1)
	else
		self.AttrContent:SetActive(false)
		self.card_score:SetValue("")
		self.card_explain:SetValue(string.format("%s,使用后增加魔卡经验",self.data.card_name))
		self.level:SetValue(1)
	end
end

function TipsMCAttrView:FlushDataInAttr()
	self.ActiveText:SetActive(true)
	self.KeyButton:SetActive(true)
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
		self.KeyButton:SetActive(false)
		self.card_status:SetValue(string.format("<color=#00ff00>(已激活)</color>"))
	end

	self.card_score:SetValue(string.format("评分：<color=#ffff00>%s</color>",self.data.fight))

	self.card_explain:SetValue(string.format("%s 套装之 %s",self.card_suit.taoka_name,self.data.card_name))
	self.hp:SetValue(self.attr_list.maxhp)
	self.atk:SetValue(self.attr_list.gongji)
	self.def:SetValue(self.attr_list.fangyu)
	self.level:SetValue(self.data.level)
end

function TipsMCAttrView:FlushDataInNotUpGrade()
	self.ActiveText:SetActive(false)
	self.KeyButton:SetActive(false)
	self.AttrContent:SetActive(true)
	self.RoleImage.grayscale.GrayScale = 255
	self.card_status:SetValue(string.format("<color=#00ff00>(已激活)</color>"))
	self.card_score:SetValue(string.format("评分：<color=#ffff00>%s</color>",self.data.fight))
	self.card_explain:SetValue(string.format("%s 套装之 %s",self.card_suit.taoka_name,self.data.card_name))
	self.hp:SetValue(self.attr_list.maxhp)
	self.atk:SetValue(self.attr_list.gongji)
	self.def:SetValue(self.attr_list.fangyu)
	self.level:SetValue(self.data.level)
end



