PlayerEquipSkepListItem =BaseClass(LuaUI)

function PlayerEquipSkepListItem:__init( itemVo, isChange )
	self.URL = "ui://0oudtuxpfqe0v"
	self:__property(itemVo, isChange)
	self:Config()
end

function PlayerEquipSkepListItem:SetProperty(itemVo, isChange)
	self.itemVo = itemVo
	self.isChange = isChange
end

function PlayerEquipSkepListItem:Config()
	self.clickMask.onClick:Add(function ()
		PlayerInfoModel:GetInstance():DispatchEvent(PlayerInfoConst.EventName_OpenEquipTips, self.itemVo)
	end,self)
	self.equipBtn.onClick:Add(self.PutOnOrOffEquipment,self)
end

function PlayerEquipSkepListItem:Init()
	self:Refresh()
end

function PlayerEquipSkepListItem:Refresh()
	local vo = self.itemVo
	if vo then
		local cfg = GoodsVo.GetEquipCfg(vo.bid)
		local equipType = vo.equipType
		self.equipName.color = newColorByString(GoodsVo.RareColor[cfg.rare]) --设置名字
		self.equipName.text = StringFormat("{0}",cfg.name)
		
		self.icon:GetChild("bg").url = "Icon/Common/grid_cell_"..cfg.rare -- 设置图标显示
		self.icon:GetChild("icon").url = StringFormat("Icon/Goods/{0}", cfg.icon)
		if vo.state == 2 then
			DelayCall(function()
				if not self.itemVo or self.isChange then return end
				PlayerInfoModel:GetInstance():DispatchEvent(PlayerInfoConst.EventName_OpenEquipTips, self.itemVo)
			end, 0.3)
			self.equipBtn.title = "卸下"
		else
			self.equipBtn.title = "装备"
		end
		--设置评分
		self.powerText.text = StringFormat("评分:{0}",vo.score or 0)
		--设置按钮的状态
		self:SetEquipBtnState()
		--判断战斗力对比
		local info = PkgModel:GetInstance():GetOnEquipByEquipType(equipType)
		if not info then 
			self.upORdown:GetChild("icon").url = PlayerInfoConst.UpORDown[1]
		else
			if info.score > vo.score then
				self.upORdown:GetChild("icon").url = PlayerInfoConst.UpORDown[2]
			end
			if info.score < vo.score then
				self.upORdown:GetChild("icon").url = PlayerInfoConst.UpORDown[1]
			end
			if info.score == vo.score then
				self.upORdown:GetChild("icon").url = PlayerInfoConst.UpORDown[0]
			end
		end
	end
end

--设置按钮的状态
function PlayerEquipSkepListItem:SetEquipBtnState()
	if self.itemVo then
		if self.itemVo.state == 2 then
			self.equipBtnCtrl.selectedIndex = 1  --显示卸载
			self.equipBtn.title = "卸下"
		else
			self.equipBtnCtrl.selectedIndex = 0  --显示穿上
			self.equipBtn.title = "装备"
		end
	end
end

--点击装备或者卸载装备
function PlayerEquipSkepListItem:PutOnOrOffEquipment()
	if self.itemVo then
		if self.itemVo.state == 2 then
			PkgCtrl:GetInstance():C_PutDownEquipment(self.itemVo.id)
		else
			PkgCtrl:GetInstance():C_PutOnEquipment(self.itemVo.id)
			GlobalDispatcher:DispatchEvent(EventName.FinishNewbieGuideStep)
		end
	end
end

function PlayerEquipSkepListItem:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("PlayerInfo","PlayerEquipSkepListItem");

	self.equipBtn = self.ui:GetChild("equipBtn")
	self.equipBtnCtrl = self.equipBtn:GetController("button")
	self.icon = self.ui:GetChild("icon")
	self.equipName = self.ui:GetChild("equipName")
	self.powerText = self.ui:GetChild("powerText")
	self.clickMask = self.ui:GetChild("clickMask")
	self.upORdown = self.ui:GetChild("upORdown")
end

function PlayerEquipSkepListItem:__delete()
	self.itemVo = nil
	self.clickMask.onClick:Clear()
	self.equipBtn.onClick:Clear()

end