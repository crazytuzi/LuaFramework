EquipmentInfoTipsTop =BaseClass(LuaUI)

-- Automatic code generation, don't change this function (Constructor) use .New(...)
function EquipmentInfoTipsTop:__init( ... )
	self.URL = "ui://ixdopynlhb6f9";
	self:__property(...)
	self:Config()
end

-- Set self property
function EquipmentInfoTipsTop:SetProperty()
	
end

-- Logic Starting
function EquipmentInfoTipsTop:Config()
	
end
--
function EquipmentInfoTipsTop:Init(itemVo)
	if itemVo == nil then return end
	local cfg = GoodsVo.GetEquipCfg(itemVo.bid)
	if not cfg then return end
	--设置名字
	self.ItemNameText.color = newColorByString(GoodsVo.RareColor[cfg.rare])
	self.ItemNameText.text = StringFormat("{0}",cfg.name)
	--设置等级
	if SceneModel:GetInstance():GetMainPlayer().level < cfg.level then
		self.ItemLevelText.text = StringFormat("[color=#FF0000]等级:{0}[/color]", cfg.level)
	else
		self.ItemLevelText.text = StringFormat("[color=#bad4dc]等级:{0}[/color]", cfg.level)
	end
	--设置背景的品质颜色
	self.bg.url = "Icon/Common/tipbg_r"..cfg.rare
	--设置item
	self.icon:GetChild("bg").url = "Icon/Common/grid_cell_"..cfg.rare
	self.icon:GetChild("icon").url = StringFormat("Icon/Goods/{0}",cfg.icon)
	--设置装备类型
	self.ItemType.text = StringFormat("{0}",GoodsVo.EquipTypeName[itemVo.equipType])
	--职业
	self.careerText.text = "职业:"..PropertyConst.JobName[cfg.needJob]
	--设置评分
	self.powerText.text = "i"..itemVo.score
	self.addText.text =  ""
	--设置对比信息
	--如果是在身上。
	if itemVo.state == 1 then 
		local onEquip = PkgModel:GetInstance():GetOnEquipByEquipType(itemVo.equipType)
		if onEquip and itemVo.cfg then 
			if onEquip.cfg.needJob == itemVo.cfg.needJob then
				if onEquip.score > itemVo.score then 
					self.compareMask.url = PlayerInfoConst.UpORDown[2]  --下降 

					self.addText.text = StringFormat("[color=#FF0000](-{0})[/color]", onEquip.score-itemVo.score)
				end
				if onEquip.score < itemVo.score then 
					self.compareMask.url = PlayerInfoConst.UpORDown[1]  --上升 
					self.addText.text = StringFormat("[color=#3DC476](+{0})[/color]", itemVo.score-onEquip.score)
				end
				if onEquip.score == itemVo.score then 
					self.compareMask.url = PlayerInfoConst.UpORDown[0]  --空
				end
			else
				self.addText.text =  ""
			end
		else
			self.compareMask.url = PlayerInfoConst.UpORDown[0]  --空
		end
	end
end
-- Register UI classes to lua
function EquipmentInfoTipsTop:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("Tips","EquipmentInfoTipsTop");

	self.bg = self.ui:GetChild("bg")
	self.icon = self.ui:GetChild("icon")
	self.ItemNameText = self.ui:GetChild("itemNameText")
	self.ItemLevelText = self.ui:GetChild("itemLevelText")
	self.careerText = self.ui:GetChild("careerText")
	self.powerText = self.ui:GetChild("powerText")
	self.ItemType = self.ui:GetChild("itemType")
	self.compareMask = self.ui:GetChild("compareMask")
	self.addText = self.ui:GetChild("addText")
end

-- Combining existing UI generates a class
function EquipmentInfoTipsTop.Create( ui, ...)
	return EquipmentInfoTipsTop.New(ui, "#", {...})
end

-- Dispose use EquipmentInfoTipsTop obj:Destroy()
function EquipmentInfoTipsTop:__delete()
	self.bg = nil
	self.icon = nil
	self.ItemNameText = nil
	self.ItemLevelText = nil
	self.powerText = nil
	self.ItemType = nil
	self.CompareMask = nil
end