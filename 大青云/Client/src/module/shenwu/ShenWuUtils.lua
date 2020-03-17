--[[
神武 utils
haohu
2015年12月25日16:36:03
]]

_G.ShenWuUtils = {}

function ShenWuUtils:GetStarCfg(level, star)
	if not level or not star then return end
	-- if level == ShenWuConsts:GetMaxLevel() then
	-- 	star = 0
	-- end
	local id = 10 * level + star
	return t_shenwustar[id]
end

function ShenWuUtils:GetUIScene()
	local cfg = t_shenwu[1] -- 场景每个等级一样
	local tab = split(cfg.sence, "#")
	local prof = MainPlayerModel.humanDetailInfo.eaProf
	return tab[prof]
end

function ShenWuUtils:GetUIShowScene()
	local cfg = t_shenwu[1] -- 场景每个等级一样
	local tab = split(cfg.sence_show, "#")
	local prof = MainPlayerModel.humanDetailInfo.eaProf
	return tab[prof]
end

function ShenWuUtils:GetUIPfxInfo(level)
	local cfg = t_shenwu[level]
	if not cfg then return end
	local prof = MainPlayerModel.humanDetailInfo.eaProf
	local bone = tostring( cfg["ui_bone" .. prof] )
	if not bone or bone == "" then return end
	local pfx = tostring( cfg["ui_pfx" .. prof] )
	if not pfx or pfx == "" then return end
	return bone, pfx .. ".pfx"
end

function ShenWuUtils:GetModelInfo(equipId)
	local equipCfg = t_equip[equipId]
	if not equipCfg then return end
	local equipLevel = equipCfg.level
	local prof = MainPlayerModel.humanDetailInfo.eaProf
	local cfgKey = 1000 + equipLevel
	local cfg = t_shenwumodel[cfgKey]
	if not cfg then return end
	local tabSkn = split( cfg.skn, "#" )
	local tabSkl = split( cfg.skl, "#" )
	local tabSan = split( cfg.san, "#" )
	return tabSkn[prof], tabSkl[prof], tabSan[prof]
end

function ShenWuUtils:IsCurrentMaterialEnough()
	local material = self:GetCurrentMaterial()
	local vo = material and material[1]
	return vo and BagModel:GetItemNumInBag(vo.id) >= vo.num or false
end

function ShenWuUtils:GetCurrentMaterial()
	local material
	local level = ShenWuModel:GetLevel()
	if ShenWuModel:IsStarUp() then
		material = self:GetStarUpMaterial(level)
	elseif ShenWuModel:IsLevelUp() then
		material = self:GetLevelUpMaterial(level)
	end
	return material
end

function ShenWuUtils:GetStarUpMaterial(level)
	if level >= ShenWuConsts:GetMaxLevel() then return end
	local cfg = t_shenwu[level]
	if not cfg then return end
	local vo = {}
	vo.id = cfg.item[1]
	vo.num = cfg.item[2]
	return {vo}
end

function ShenWuUtils:GetLevelUpMaterial(level)
	if level >= ShenWuConsts:GetMaxLevel() then return end
	local nextLevel = level + 1
	local cfg = t_shenwu[nextLevel]
	if not cfg then return end
	local material = {}
	local tab = split(cfg.needs, "#")
	for _, str in ipairs(tab) do
		local tab1 = split(str, ",")
		local vo = {}
		vo.id = tonumber(tab1[1])
		vo.num = tonumber(tab1[2])
		table.push(material, vo)
	end
	return material
end

function ShenWuUtils:GetAttrMap(level, star)
	local cfg = self:GetStarCfg(level, star)
	if not cfg then return end
	return AttrParseUtil:ParseAttrToMap( cfg.property )
end

function ShenWuUtils:GetAttrIncrementMap( level, star )
	local levelA = ShenWuModel:GetLevel()
	if levelA < 0 then
		Error("wrong shenwu level, must >= 0")
		return
	end
	local starA = ShenWuModel:GetStar()
	local attrMapA = ShenWuUtils:GetAttrMap(levelA, starA)
	local attrMapB = ShenWuUtils:GetAttrMap(level, star)
	for attrType, attr in pairs(attrMapB) do
		attrMapA[attrType] = attr - attrMapA[attrType]
	end
	return attrMapA
end

function ShenWuUtils:GetSkill(level)
	local skills = {}
	local cfg = t_shenwu[level]
	if cfg then
		local str = cfg.skill
		local tab = split(str, "#")
		for _, skillIdStr in ipairs(tab) do
			table.push( skills, tonumber(skillIdStr) )
		end
	end
	return skills
end

--获取列表VO
function ShenWuUtils:GetSkillVO(skillId)
	local vo = {}
	local cfg = t_passiveskill[skillId];
	if cfg then
		vo.skillId = skillId
		vo.name = cfg.name
		vo.lvl = cfg.level
		vo.showLvlUp = false
		vo.iconUrl = ResUtil:GetSkillIconUrl(cfg.icon)
	end
	return vo
end

function ShenWuUtils:GetCurrentRate()
	local rate = 0
	if ShenWuModel:IsStarUp() then
		rate = ShenWuModel:GetStarRate()
	elseif ShenWuModel:IsLevelUp() then
		local level = ShenWuModel:GetLevel()
		local cfg = t_shenwu[level]
		local oRate = cfg and cfg.rate_real or 0
		local stoneNum = ShenWuModel:GetUseStoneNum()
		local stoneRate = ShenWuConsts:GetStoneRate() * stoneNum
		rate = oRate + stoneRate
	end
	return rate
end

function ShenWuUtils:GetDataToShenWuUIVO(vo)
	local wuqi = ShenWuConsts:GetDefaultWuQi()
	local isBig = false
	vo.hasItem = true
	vo.iconUrl = BagUtil:GetItemIcon(wuqi,isBig);
	vo.qualityUrl = ResUtil:GetSlotQuality(t_equip[wuqi].quality, isBig and 54 or nil);
	vo.quality = t_equip[wuqi].quality;
	vo.strenLvl = 0
	vo.super = 0;
	if vo.quality == BagConsts.Quality_Green2 then
		vo.super = 2;
	elseif vo.quality == BagConsts.Quality_Green3 then
		vo.super = 3;
	end
	vo.showBind = BagConsts.Bind_Bind
	vo.groupBsUrl = ResUtil:GetShenWuSlotIcon(ShenWuModel:GetLevel(), ShenWuModel:GetStar())
end

function ShenWuUtils:IsWeaponEquiped()
	local bagVO = BagModel:GetBag(BagConsts.BagType_Role)
	return bagVO:GetItemByPos(BagConsts.Equip_WuQi) ~= nil
end

function ShenWuUtils:GetCurrentWuQiId()
	local bagVO = BagModel:GetBag(BagConsts.BagType_Role)
	local item = bagVO:GetItemByPos(BagConsts.Equip_WuQi)
	return item and item:GetTid() or ShenWuConsts:GetDefaultWuQi()
end

function ShenWuUtils:GetFight(isEquiped, pos, level, star)
	if not isEquiped then return 0 end
	if pos ~= BagConsts.Equip_WuQi then return 0 end
	return 0 -- 武器tips装备评分用，与策划确认暂时与神武无关 2015年12月29日17:20:10	
end

function ShenWuUtils:ShowShenWuTips(level, star)
	local itemTipsVO
	if ShenWuUtils:IsWeaponEquiped() then
		itemTipsVO = ItemTipsUtil:GetBagItemTipsVO(BagConsts.BagType_Role, BagConsts.Equip_WuQi)
	else
		local tid = ShenWuConsts:GetDefaultWuQi()
		itemTipsVO = ItemTipsUtil:GetItemTipsVO(tid, 1)
	end
	if not itemTipsVO then return; end
	if itemTipsVO.id <= 0 then return end;
	itemTipsVO.isInBag = false
	itemTipsVO.shenWuLevel = level
	itemTipsVO.shenWuStar = star
	TipsManager:ShowTips(itemTipsVO.tipsType,itemTipsVO,itemTipsVO.tipsShowType, TipsConsts.Dir_RightDown);
end

function ShenWuUtils:GetOStarRate(level)
	local cfg = t_shenwu[level]
	return cfg and cfg.starrate_real or 0
end

function ShenWuUtils:IsFreeShenWuSkill(skillId)
	local cfg = t_passiveskill[skillId]
	if not cfg then return end
	local freeGroupDic = ShenWuConsts:GetFreeSkillGroupDic()
	return freeGroupDic[ cfg.group_id ] == true 
end

function ShenWuUtils:GetSkillListVO(skillId, lvl)
	local vo = {}
	vo.skillId = skillId
	local cfg = t_passiveskill[skillId]
	if cfg then
		vo.name = cfg.name
		vo.lvl = lvl
		if lvl == 0 then
			vo.lvlStr = StrConfig['skill101']
		else
			local maxLvl = SkillUtil:GetSkillMaxLvl(skillId)
			vo.lvlStr = string.format( StrConfig['skill102'], lvl, maxLvl )
			local skillVO = SkillModel:GetSkill(skillId)
			if skillVO and lvl < maxLvl then
				vo.showLvlUp = self:GetSkillCanLvlUp(skillId);
			else
				vo.showLvlUp = false;
			end
		end
		local url = ResUtil:GetSkillIconUrl(cfg.icon);
		vo.iconUrl = lvl > 0 and url or ImgUtil:GetGrayImgUrl(url)
	end
	return vo;
end

--获取技能是否可升级
function ShenWuUtils:GetSkillCanLvlUp(skillId)
	local conditionlist = SkillUtil:GetLvlUpConditionForSkill(skillId, false) -- param learn:是否是学习技能
	for i, vo in ipairs(conditionlist) do
		if not vo.state then
			return false;
		end
	end
	return true;
end