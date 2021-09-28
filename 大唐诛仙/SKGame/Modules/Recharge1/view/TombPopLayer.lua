TombPopLayer = BaseClass(LuaUI)
function TombPopLayer:__init(...)
	self.URL = "ui://g35bobp2osjzr";
	self:__property(...)
	self:Config()
	self:InitEvent()
end
function TombPopLayer:SetProperty(...)
	
end
function TombPopLayer:Config()
	
end
function TombPopLayer:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("Welfare","TombPopLayer");

	self.txtTitle = self.ui:GetChild("txtTitle")
	self.btnQuxiao = self.ui:GetChild("btnQuxiao")
	self.btnQueding = self.ui:GetChild("btnQueding")
	self.txtTansuoCost = self.ui:GetChild("txtTansuoCost")
	self.txtTansuo = self.ui:GetChild("txtTansuo")
	self.comTansuo = self.ui:GetChild("comTansuo")
	self.comChange = self.ui:GetChild("comChange")
	self.txtChange2 = self.ui:GetChild("txtChange2")
end
function TombPopLayer.Create(ui, ...)
	return TombPopLayer.New(ui, "#", {...})
end
function TombPopLayer:__delete()
end

function TombPopLayer:InitEvent()
	self.btnQuxiao.onClick:Add(function()
		self:Destroy()
	end)
	self.btnQueding.onClick:Add(function()
		if self.tType == 1 then
			RechargeController:GetInstance():C_Tomb(self.tombIndex)
		else
			RechargeController:GetInstance():C_ChangeTomb()
		end
		self:Destroy()
	end)
end

function TombPopLayer:SetData(data)
	self.tType = data.tType
	self.tombIndex = data.idx or 1
	self:RefreshUI()
end

function TombPopLayer:RefreshUI()
	local model = RechargeModel:GetInstance()
	if self.tType == 1 then	-- 探索
		self.comTansuo.visible = true
		self.comChange.visible = false
		local ownItems = model:GetOwnItems()
		local str1 = ""
		for i = 1, #ownItems do
			local data = GetCfgData("item"):Get(ownItems[i].id) or {}
			--local icon = data.icon
			local icon = data.id
			local tmp = StringFormat("[img=28,28]Icon/Goods/{0}[/img]", icon)
			str1 = str1 .. StringFormat([[{0}[color=#43515B]X{1}[/color] ]], tmp, ownItems[i].num)
		end
		local str = [[ [color=#43515B]持有摸金令:[/color] ]]
		local str = str .. str1
		setRichTextContent(self.txtTansuoCost, str)

		local costData = model:GetCostItem()
		local tmp = StringFormat("[img=28,28]Icon/Goods/{0}[/img]", costData[1])
		local newStr = StringFormat( [[使用{0}[color=#ff0000]{1}[/color]个探索该墓室？ ]], tmp, costData[2])
		setRichTextContent(self.txtTansuo, newStr)
	else -- 更换
		self.comTansuo.visible = false
		self.comChange.visible = true
		local cost = model:GetChangeCost()
		local str = "免费刷新奖励？"
		if cost > 0 then
			str = StringFormat([[ [color=#43515B]花费[/color][color=#ff0000]{0}[/color][color=#43515B]元宝刷新奖励?[/color] ]], 10)
		end
		self.txtChange2.text = str
	end
end