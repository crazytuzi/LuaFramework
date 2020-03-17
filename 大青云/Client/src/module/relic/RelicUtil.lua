_G.RelicUtil = {}

function RelicUtil:GetRelicFight(item)
	if not item then return 0 end
	local relicID = item:GetParam()
	if not relicID then
		relicID = BagUtil:GetRelicId(item:GetTid())
		if not relicID then self:Hide() return end
	end
	local cfg = t_newequip[relicID]
	return PublicUtil:GetFigthValue(AttrParseUtil:Parse(cfg.att))
end

function RelicUtil:GetRelicEquipByRelic(item)
	local relicID = item:GetParam()
	if not relicID then
		relicID = BagUtil:GetRelicId(item:GetTid())
		if not relicID then self:Hide() return end
	end
	local cfg = t_newequip[relicID]
	local bagVO = BagModel:GetBag(BagConsts.BagType_RELIC)
	local item = bagVO:GetItemByPos(cfg.part - 201)
	return item
end

function RelicUtil:GetRelicAddFightByEquip(item)
	return self:GetRelicFight(item) - self:GetRelicFight(self:GetRelicEquipByRelic(item))
end