ClanHDContributeItem = BaseClass(LuaUI)
function ClanHDContributeItem:__init( v )
	self.ui = UIPackage.CreateObject("Duhufu","HDContributeItem")
	self.txtCost = self.ui:GetChild("txtCost")
	self.iconCost = self.ui:GetChild("iconCost")
	self.txtSW = self.ui:GetChild("txtSW")
	self.txtZJ = self.ui:GetChild("txtZJ")
	self.txtJSD = self.ui:GetChild("txtJSD")
	self.btn = self.ui:GetChild("btn")
	self.btn.onClick:Add(function ()
		if self.limited then return end
		if self.data then ClanCtrl:GetInstance():C_Donate(self.data.id) end
	end)
	self:SetData(v)
end

function ClanHDContributeItem:SetData(v)
	self.data = v
	self.ui.title = v.des
	self.ui.icon =  GoodsVo.GetIconUrl(v.moneyType, 0) -- "Icon/Activity/dhf_jx"..v.id
	self.iconCost.url = GoodsVo.GetIconUrl(v.moneyType, 0)
	self.txtCost.text = v.value
	self.txtSW.text = StringFormat("贡献：+{0}", v.contribution)
	self.txtJSD.text =StringFormat("府建设度：+{0}", v.buildNum)
	self.txtZJ.text = StringFormat("府资金：+{0}", v.money)
end

function ClanHDContributeItem:__delete()
	self.limited = false
end