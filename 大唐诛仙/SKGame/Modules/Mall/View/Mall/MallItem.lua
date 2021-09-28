MallItem = BaseClass(LuaUI)

MallItem.CurSelectItem = nil
function MallItem:__init(...)
	self.URL = "ui://z5rl8hw3kt6kw";
	self:__property(...)
	self:Config()
end

function MallItem:SetProperty(...)
	
end

function MallItem:Config()
	
end

function MallItem:RegistUI(ui)
	self.ui = ui or self.ui or UIPackage.CreateObject("Mall","MallItem");

	self.content = self.ui:GetChild("content")
	self.leftMark = self.ui:GetChild("leftMark")
	self.rightMark = self.ui:GetChild("rightMark")

	self.select = self.content:GetChild("select")
	self.propName = self.content:GetChild("propName")
	self.cost2 = self.content:GetChild("cost2")
	self.costIcon = self.content:GetChild("costIcon")
	self.cost1 = self.content:GetChild("cost1")
	self.line = self.content:GetChild("line")

	self.icon = PkgCell.New(self.ui)
	self.icon:SetXY(self.leftMark.x + 7, self.leftMark.y + 7)	
	self.icon:OpenTips(true)
	self.ui:AddChild(self.leftMark)

	self.data = nil

	self:AddEvent()
	self:UnSelect()
end

function MallItem.Create(ui, ...)
	return MallItem.New(ui, "#", {...})
end

function MallItem:AddEvent()
	self.content.onClick:Add(self.OnClickHandler, self)
end

function MallItem:RemoveEvent()
	self.content.onClick:Remove(self.OnClickHandler, self)
end

function MallItem:OnClickHandler()
	if MallItem.CurSelectItem then
		MallItem.CurSelectItem:UnSelect()
	end
	self:Select()
end

function MallItem:Select()
	self.select.visible = true
	MallItem.CurSelectItem = self

	local showBuy = function()
		MallModel:GetInstance():DispatchEvent(MallConst.MallItemSelect, self.data)
	end

	if self.data.bugagain == 1 then
		if PkgModel:GetInstance():GetTotalByBid(self.data.itemId) > 0 then
			UIMgr.Win_Alter("提示", StringFormat("{0}已购买，无法重复购买", self.goodVo.name), "确定", function() end)
		else
			showBuy()
		end
	else
		showBuy()
	end
end

function MallItem:UnSelect()
	self.select.visible = false
end

function MallItem:Refresh(data)
	self.data = data

	self:Update()
end

function MallItem:Update()
	self.goodVo = GoodsVo.GetCfg(self.data.itemType, self.data.itemId)
	self.propName.text = StringFormat("[color={0}]{1}[/color]",GoodsVo.RareColor[self.goodVo.rare],self.goodVo.name)

	if self.data.discount == 0 then
		self.line.visible = false
		self.cost2.visible = false
		self.cost1.text = self.data.price
	else
		self.line.visible = true
		self.cost2.visible = true
		self.cost1.text = self.data.price
		self.line.width = self.cost1.textWidth + 15
		self.cost2.text = math.ceil(self.data.price*self.data.discount/100) 
	end
	self.icon:SetDataByCfg(self.data.itemType, self.data.itemId, 1, 0)
	self.costIcon.url = GoodsVo.GetIconUrl(self.data.moneyType)
	if #self.data.tagId > 0 then
		local markType = self.data.tagId[1]
		local iconUrl = "Icon/Mall/"..self.data.tagId[2]
		if markType == 1 then
			self.leftMark.url = iconUrl
		else
			self.rightMark.url = iconUrl
		end
	end

	self:SetWingOrStyleActive()
end

--已激活的翅膀或时装，其图标右上方显示“已激活”标签，如图2个位置（如果该位置有其他图标，则覆盖掉）
function MallItem:SetWingOrStyleActive()
	if self.data == nil then return end
	local isActive , activeType = MallModel:GetInstance():IsWingOrStyleActive(self.data.itemId)
	if isActive then
		local activeIconURL = "Icon/Vip/jihuo"
		self.leftMark.url = activeIconURL
	end
end


function MallItem:Reset()
	self:UnSelect()
	self.leftMark.url = ""
	self.rightMark.url = ""
end

function MallItem:__delete()
	self:RemoveEvent()

	self.icon:Destroy()
	self.icon = nil
end