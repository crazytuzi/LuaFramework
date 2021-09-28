FurnaceItemI = BaseClass(LuaUI)
function FurnaceItemI:__init( ... )
	self.URL = "ui://wt6b3levu156n";
	self:__property(...)
	self:Config()
end
function FurnaceItemI:SetProperty( ... )
end
function FurnaceItemI:Config()
	
end
function FurnaceItemI:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("Furnace","FurnaceItemI");

	self.txtPrice = self.ui:GetChild("txtPrice")
	self.payIcon = self.ui:GetChild("payIcon")
	self.btnApply = self.ui:GetChild("btnApply")
	self.bg = self.ui:GetChild("bg")

	self.btnApply.onClick:Add(function ()
		if self.data and self.data.sellConfirm==1 then
			UIMgr.Win_Confirm("提示", StringFormat("您确定要花 {1}元宝 购买 {0} 吗？", self.data.name, GetCfgData("market"):Get(self.ui.data).price), "确定", "取消", function (  )
				MallController:GetInstance():ReqBuy(self.ui.data, 1, true)
			end, nil)
		end
	end)
end
function FurnaceItemI:SetData( v )
	self.data = v
	self.cell = PkgCell.New( self.ui, nil, nil )
	self.cell:SetXY(self.bg.x, self.bg.y)
	self.cell:SetDataByCfg( GoodsVo.GoodType.item, self.data.id, 0, 0 )
	self.cell:OpenTips( true)
end

function FurnaceItemI.Create( ui, ...)
	return FurnaceItemI.New(ui, "#", {...})
end
function FurnaceItemI:__delete()
	if self.btnApply then
		self.btnApply.onClick:Clear()
	end
	self.btnApply = nil
	if self.cell then
		self.cell:Destroy()
	end
	self.cell = nil
end