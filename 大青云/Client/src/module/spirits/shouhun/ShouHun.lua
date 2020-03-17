--[[
灵兽魂魄
2016年1月14日15:22:35
haohu
]]

_G.ShouHun = {}

ShouHun.tid = nil
ShouHun.level = 0
ShouHun.star = 0

function ShouHun:new( tid )
	local obj = setmetatable( {}, {__index = self} )
	obj.tid = tid
	obj.level = 0
	obj.star = 0
	return obj
end

function ShouHun:GetTid()
	return self.tid
end

function ShouHun:GetCfg(level, star)
	if not level then
		level = self.level
	end
	if not star then
		star = self.star
	end
	local cfgkey = level * 100 + star
	return t_lingshousoul[cfgkey]
end

function ShouHun:ShowTips()
	local tips = ""
	if self:IsActive() then
		local attr = self:GetAttr()
		local attrName = enAttrTypeName[ attr.type ]
		tips = string.format( StrConfig['shouhun22'], self:GetName(), self:GetLevel(),
			self:GetShowAttr(), attrName, self:GetAttrTimes() * 100 ) -- "%sLV.%s\n%s：%s\n灵兽%s提升%0.2f%%",
	else
		tips = StrConfig['shouhun21']
	end
	TipsManager:ShowBtnTips( tips, TipsConsts.Dir_RightDown )
end

function ShouHun:GetName()
	local config = ShouHunConsts.config[self.tid]
	return config and config.name
end

function ShouHun:GetLevel()
	return self.level
end

function ShouHun:SetLevel(level)
	if self.level ~= level then
		self.level = level
		return true
	end
	return false
end

function ShouHun:GetStar()
	return self.star
end

function ShouHun:SetStar(star)
	if self.star ~= star then
		self.star = star
		return true
	end
	return false
end

function ShouHun:GetBaseAttr()
	local config = ShouHunConsts.config[self.tid]
	local attrType = config.attrType
	local value = 0
	local currentLS = SpiritsModel:GetWuhunId()
	if currentLS then
		local lsCfg = t_wuhun[ currentLS ]
		value = lsCfg and lsCfg[config.cfgKey] or 0
	end
	return { type = attrType, val = value }
end

function ShouHun:GetAttrTimes(level, star)
	if not level then
		level = self.level
	end
	if level == 0 then
		return 0
	end
	local cfg = self:GetCfg(level, star)
	return cfg.attrtimes
end

function ShouHun:GetShowAttr()
	local attr = self:GetAttr()
	local attrName = ShouHunConsts.AttrName[ attr.type ]
	local format = "<font color='#c8b267'>%s：</font>  <font color='#ffffff'>%s</font>"
	return string.format( format, attrName, getAtrrShowVal(attr.type, toint(attr.val, 1)) )
end

function ShouHun:GetAttr(level, star)
	local attr = self:GetBaseAttr()
	attr.val = attr.val * self:GetAttrTimes(level, star)
	return attr
end

function ShouHun:GetFight()
	return EquipUtil:GetFight( { self:GetAttr() }, true )
end

function ShouHun:GetNeedItem()
	local tab
	if self.level == 0 then
		local itemStr = t_consts[201].param
		tab = split( itemStr, "," )
	else
		local cfg = self:GetCfg()
		tab = cfg.needs
	end
	return { id = tonumber(tab[1]), num = tonumber(tab[2]) }
end

function ShouHun:GetNeedMoney()
	return 0
end

function ShouHun:IsItemEnough()
	local vo = self:GetNeedItem()
	return BagModel:GetItemNumInBag(vo.id) >= vo.num
end

function ShouHun:LevelUp()
	return ShouHunController:ReqShouHunLevelUp(self.tid)
end

function ShouHun:IsActive()
	return self.level > 0
end

function ShouHun:IsFull()
	return self.level >= ShouHunConsts:GetMaxLevel()
end

function ShouHun:GetAttrIncrement( level, star )
	local fromAttr = self:GetAttr()
	local toAttr = self:GetAttr( level, star )
	toAttr.val = toAttr.val - fromAttr.val
	return toAttr
end