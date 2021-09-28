WarGiftItem = BaseClass(LuaUI)
function WarGiftItem:__init(data)
	local ui = UIPackage.CreateObject("Duhufu","WarGiftItem")
	self.ui = ui
	self.costIcon = ui:GetChild("costIcon")
	self.cost1 = ui:GetChild("cost1")
	self.cost2 = ui:GetChild("cost2")


	ui.onClick:Add(function ()
		self.fun(ui, self.data)
	end)
	self.icon = PkgCell.New(ui)
	self.icon:SetDataByCfg( GoodsVo.GoodType.item, data.itemId, 1, 0)
	self.icon:SetXY(20,20)
	self:Update(data)
end
function WarGiftItem:Update( data )
	self.data = data
	local cfg = GoodsVo.GetItemCfg(data.itemId)
	self.ui.title = StringFormat("[color={0}]{1}[/color]",GoodsVo.RareColor[cfg.rare], cfg.name)
	self.costIcon.url = GoodsVo.GetIconUrl(GoodsVo.GoodType.gold, 0)
	self.cost1.text = cfg.buyPrice
	self.cost2.text = data.curPrice
end

function WarGiftItem:SetClickCallback(fun)
	self.fun = fun
end

function WarGiftItem:__delete()
	self.icon:Destroy()
	self.icon=nil
end