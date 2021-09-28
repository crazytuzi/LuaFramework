PlayerEquipItem =BaseClass(LuaUI)

function PlayerEquipItem:__init( ... )
	self.URL = "ui://0oudtuxpn1gar"
	self:__property(...)
	self:Config()
end

function PlayerEquipItem:SetProperty( pos, hideSelect)
	self.pos = pos
	self.hideSelect = hideSelect
end

function PlayerEquipItem:Config()
	self.ui.onClick:Add(function (e)
		PlayerInfoModel:GetInstance():DispatchEvent(PlayerInfoConst.EventName_OpenEquipList, self.pos)
	end,self)
end

function PlayerEquipItem:GetShuiyin( pos )
	pos = pos or 0
	if pos == 1 then
		self["sy"..pos] = self["sy"..pos] or UIPackage.GetItemURL("PlayerInfo", "cap_s")	-- 头盔
	elseif pos == 2 then
		self["sy"..pos] = self["sy"..pos] or UIPackage.GetItemURL("PlayerInfo", "clothes_s")	-- 铠甲
	elseif pos == 3 then
		self["sy"..pos] = self["sy"..pos] or UIPackage.GetItemURL("PlayerInfo", "shoes_s")	-- 裤子
	elseif pos == 4 then
		self["sy"..pos] = self["sy"..pos] or UIPackage.GetItemURL("PlayerInfo", "necklace_s")	-- 项链
	elseif pos == 5 then
		self["sy"..pos] = self["sy"..pos] or UIPackage.GetItemURL("PlayerInfo", "wrist_s")	-- 护腕
	elseif pos == 6 then
		self["sy"..pos] = self["sy"..pos] or UIPackage.GetItemURL("PlayerInfo", "ring_s")		-- 戒指
	elseif pos == 7 then
		self["sy"..pos] = self["sy"..pos] or UIPackage.GetItemURL("PlayerInfo", "sword_s")	-- 主武
	elseif pos == 8 then
		self["sy"..pos] = self["sy"..pos] or UIPackage.GetItemURL("PlayerInfo", "shield_s")	-- 盾
	end
	return self["sy"..pos]
end

--刷新玩家装备
function PlayerEquipItem:Refresh(info)
	self.itemVo = info
	if info == nil then
		self.quality.url = "Icon/Common/grid_cell_0"  --空
		self:SetUIVisible(false)
		self.shuiYin.url = self:GetShuiyin( self.pos ) -- PlayerInfoConst.ShuiYin[self.pos]
		self.wakanLevel.text = ""
	else
		local cfg = GoodsVo.GetEquipCfg(info.bid)
		local equipType = info.equipType
		self:SetUIVisible(true)
		self.quality.url = "Icon/Common/grid_cell_"..cfg.rare --设置品质图标
		self.icon.url = StringFormat("Icon/Goods/{0}",cfg.icon) --装备icon
		self.levelLabel.text = StringFormat("{0}",cfg.level) --设置装备等级
		self.shuiYin.url = nil

		local level = WakanModel:GetInstance():GetPartWakanInfo(self.pos)[2]
		if level ~= 0 then
			self.wakanLevel.text = "+"..level
		else
			self.wakanLevel.text = ""
		end
	end

	
end

--注灵图标刷新
function PlayerEquipItem:RefreshForWakan(pos)
	self.pos = pos
	self.quality.url = "Icon/Common/grid_cell_0"  --空
	self:SetUIVisible(false)
	self.shuiYin.url = nil

end

function PlayerEquipItem:SetUIVisible(bool)
	if not self.icon then return end
	self.icon.visible = bool
	self.shuiYin.visible = not bool
	self:HideNumAndCompare()
end
function PlayerEquipItem:HideNumAndCompare()
	self.levelLabel.visible = false
	self.conpareFlag.visible =false
end

function PlayerEquipItem:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("PlayerInfo","PlayerEquipItem");
	self.button = self.ui:GetController("button")
	self.quality = self.ui:GetChild("quality")
	self.shuiYin = self.ui:GetChild("shuiYin")
	self.icon = self.ui:GetChild("icon")
	self.levelLabel = self.ui:GetChild("levelLabel")
	self.conpareFlag = self.ui:GetChild("conpareFlag")
	self.mask = self.ui:GetChild("mask")
	self.wakanLevel = self.ui:GetChild("wakanLevel")
	self.red = self.ui:GetChild("red")

	self.wakanLevel.text = ""
	if self.hideSelect then
		self.mask.visible = false
	end

	self.red.visible = false
end

function PlayerEquipItem.Create( ui, ...)
	return PlayerEquipItem.New(ui, "#", {...})
end

function PlayerEquipItem:SetRedTipsState(isShow)
	if isShow ~= nil then
		self.red.visible = isShow
	end
end

function PlayerEquipItem:__delete()
end