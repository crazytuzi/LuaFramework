--[[
灵诀
haohu
2016年1月22日11:33:33
]]

_G.LingJue = {}

LingJue.tid = nil
LingJue.level = 0
LingJue.pro = 0

function LingJue:new(tid)
	local obj = setmetatable( {}, {__index = self} )
	obj.tid = tid
	obj.level = 0
	obj.pro = 0
	return obj
end

function LingJue:GetTid()
	return self.tid
end

function LingJue:GetCfg()
	local cfg = t_lingjueachieve[self.tid]
	if not cfg then
		Error("wrong id:" .. tostring(self.tid))
	end
	return cfg
end

function LingJue:GetLevelCfg()
	local levelCfgKey = self.tid * 100 + self.level
	local cfg = t_lingjue[levelCfgKey]
	if not cfg then
		Error(self.tid, self.level)
	end
	return cfg
end

function LingJue:GetLevel()
	return self.level
end

function LingJue:GetPro()
	return self.pro
end

function LingJue:SetPro(pro, level)
	if self.pro ~= pro or self.level ~= level then
		self.pro = pro
		self.level = level
		return true
	end
	return false
end

function LingJue:GetGroup()
	local cfg = self:GetCfg()
	return cfg and cfg.group
end

function LingJue:GetAttrTotal()
	local attrList1 = self:GetAttrActive()
	local attrList2 = self:GetAttrAppendAll()
	return LingJueUtils:AttrAdd( attrList1, attrList2 )
end

function LingJue:GetAttrActive()
	local cfg = self:GetCfg()
	if not cfg then return end
	return AttrParseUtil:Parse(cfg.attr)
end

function LingJue:GetAttrAppendAll()
	local attrList = self:GetAttrAppend()
	for _, vo in pairs(attrList) do
		vo.val = vo.val * self.pro
	end
	return attrList
end

function LingJue:GetAttrAppend()
	if not self:IsActive() then
		return {}
	end
	local levelCfg = self:GetLevelCfg()
	return AttrParseUtil:Parse( levelCfg.lingjue_attr )
end

function LingJue:GetFight()
	local attrlist = self:GetAttrTotal()
	return EquipUtil:GetFight( attrlist, true )
end

function LingJue:GetMaxPro()
	if not self:IsActive() then
		return 1
	end
	local levelCfg = self:GetLevelCfg()
	return levelCfg.progress
end

function LingJue:GetMaxLevel()
	local level = 0
	for _, cfg in pairs(t_lingjue) do
		if self.tid == cfg.lingjue_id then
			level = math.max(level, cfg.lingjue_lv)
		end
	end
	return level
end

function LingJue:GetActiveConsume()
	local cfg = self:GetCfg()
	return { id = cfg.item[1], num = cfg.item[2] }
end

function LingJue:GetConsume()
	if not self:IsActive() then
		return self:GetActiveConsume()
	end
	local cfg = self:GetLevelCfg()
	return { id = cfg.lingjue_consume[1], num = cfg.lingjue_consume[2] }
end

function LingJue:IsItemEnough()
	local item = self:GetConsume()
	return BagModel:GetItemNumInBag(item.id) >= item.num
end

function LingJue:IsActive()
	return self.level > 0
end

function LingJue:IsFull()
	return self.level == self:GetMaxLevel()
end

function LingJue:ShowBtnTips()
	if not self:IsActive() then
		return
	end
	local str = StrConfig['lingjue20']
	for _, vo in ipairs(self:GetAttrAppend()) do
		str = str .. string.format( "<br/><font color='#D5B772'>%s:</font><font color='#00FF00'>+%s</font>", enAttrTypeName[ vo.type ], vo.val )
	end
	TipsManager:ShowBtnTips( str, TipsConsts.Dir_RightDown )
end

function LingJue:ShowConsumeTips()
	local item = self:GetConsume()
	if item then
		TipsManager:ShowItemTips(item.id)
	end
end

function LingJue:ShowTips()
	if not self:IsActive() then
		return TipsManager:ShowBtnTips( StrConfig['lingjue1'], TipsConsts.Dir_RightDown )
	end
	local str = StrConfig['lingjue2']
	for _, vo in ipairs(self:GetAttrTotal()) do
		str = str .. string.format( "<br/><font color='#D5B772'>%s:</font><font color='#00FF00'>+%s</font>", enAttrTypeName[ vo.type ], vo.val )
	end
	TipsManager:ShowBtnTips( str, TipsConsts.Dir_RightDown )
end

function LingJue:GetBookUrl()
	return ResUtil:GetLingJueBookUrl(self.tid)
end

function LingJue:GetUIData()
	local vo = {}
	vo.tid = self.tid
	vo.bookUrl = self:GetBookUrl()
	vo.textLevel = string.format( "<font color='#F4E036'>Lv:%s</font>", self.level )
	local item = self:GetConsume()
	local itemName = t_item[item.id] and t_item[item.id].name
	local playerHasNum = BagModel:GetItemNumInBag(item.id)
	local color = playerHasNum < item.num and "#FF0000" or "#00FF00"
	vo.textConsume = string.format( "<font color='#00FF00'><u>%s</u><font color='%s'>(%s/%s)</font></font>", itemName, color, playerHasNum, item.num )
	local times = math.floor( playerHasNum / item.num )
	local color2 = times > 0 and "#00FF00" or "#FF0000"
	if self:IsActive() then
		vo.textPro = string.format( StrConfig['lingjue3'], self.pro, self:GetMaxPro() )
		vo.btnLabel = string.format( StrConfig['lingjue4'], color2, times )
	else
		vo.textPro = StrConfig['lingjue18']
		vo.btnLabel = StrConfig['lingjue19']
	end
	return UIData.encode(vo)
end