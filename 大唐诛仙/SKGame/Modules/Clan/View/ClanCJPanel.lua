ClanCJPanel = BaseClass(LuaUI)
function ClanCJPanel:__init( root )
	self.ui = UIPackage.CreateObject("Duhufu","CJPanel")
	self.label0 = self.ui:GetChild("label0")
	self.label1 = self.ui:GetChild("label1")
	self.label2 = self.ui:GetChild("label2")
	self.label4 = self.ui:GetChild("label4")
	self.txtInputName = self.ui:GetChild("txtInputName")
	self.txtInputNotice = self.ui:GetChild("txtInputNotice")
	self.labelCost1 = self.ui:GetChild("labelCost1")
	self.iconCost1 = self.ui:GetChild("iconCost1")
	self.txtCost1 = self.ui:GetChild("txtCost1")
	self.labelCost2 = self.ui:GetChild("labelCost2")
	self.iconCost2 = self.ui:GetChild("iconCost2")
	self.txtCost2 = self.ui:GetChild("txtCost2")
	self.txtInfo = self.ui:GetChild("txtInfo")
	self.btnCreate = self.ui:GetChild("btnCreate")

	self.parent = root
	self.model = ClanModel:GetInstance()
	self.isUnPay=""

	self:Layout()
	self:InitEvent()
end

function ClanCJPanel:InitEvent()
	self.btnCreate.onClick:Add(function ()
		if self.isUnPay ~= "" then
			UIMgr.Win_FloatTip(StringFormat("您的{0}不足！",self.isUnPay))
			return
		end
		local v = self.txtInputName.text
		if  string.trim(v) == "" or string.utf8len(v)>12 or #v<4 then
			UIMgr.Win_FloatTip("都护府名字长度不对，应该是2-6个汉字或4-12个字符")
			return
		end
		if isExistSensitive(v) then
			UIMgr.Win_FloatTip("贵府名字不合法！")
			return
		end
		v = self.txtInputNotice.text
		if string.trim(v) == "" then
			UIMgr.Win_FloatTip("您还没有给贵府写公告！")
			return
		end
		if isExistSensitive(v) then
			UIMgr.Win_FloatTip("贵府公告存在不合法词语！")
			return
		end
		ClanCtrl:GetInstance():C_CreateGuild(self.txtInputName.text, self.txtInputNotice.text)
	end)
end

function ClanCJPanel:Layout()
	self:AddTo(self.parent)
	self:SetXY(169, 135)
	self.txtInfo.text = ClanConst.cjPaneXX
	self.txtInputName.text = ""
	self.txtInputNotice.text = ""
	self.iconCost1.url = GoodsVo.GetIconUrl(GoodsVo.GoodType.gold, 0)
	self.iconCost2.url = GoodsVo.GetIconUrl(GoodsVo.GoodType.diamond, 0)
	
end

function ClanCJPanel:Update()
	local roleVo = SceneModel:GetInstance():GetMainPlayer()
	local needGold = GetCfgData("constant"):Get(60).value
	local needDiamond = GetCfgData("constant"):Get(61).value
	self.isUnPay=""
	if roleVo.gold < needGold then
		self.isUnPay = "金币"
		self.txtCost1.color = newColorByString("ff0000")
	else
		self.txtCost1.color = newColorByString("2E3341")
	end
	if roleVo.diamond < needDiamond then
		self.isUnPay = "元宝"
		self.txtCost2.color = newColorByString("ff0000")
	else
		self.txtCost2.color = newColorByString("2E3341")
	end
	self.txtCost1.text = needGold
	self.txtCost2.text = needDiamond
end

function ClanCJPanel:SetVisible(v,first)
	LuaUI.SetVisible(self, v)
	if v and not first then
		ClanCtrl:GetInstance():C_GetGuild()
	end
end

function ClanCJPanel:__delete()
end