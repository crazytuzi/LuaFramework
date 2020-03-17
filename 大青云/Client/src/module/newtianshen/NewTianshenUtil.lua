--[[
	新天神
]]

_G.NewTianshenUtil = {};

--获取天神基础配置
function NewTianshenUtil:GetBaseConfig(id)
	return t_newtianshen[id]
end

--获取天神属性配置
function NewTianshenUtil:GetAttrConfig(id)
	return t_newtianshenshuxing[id]
end

--获取天神属性系数配置
function NewTianshenUtil:GetAttrXishuCfg(id)
	return t_newtianshenxishu[id]
end

--获取天神升级配置表
function NewTianshenUtil:GetLvUpCfg(lv)
	return t_newtianshenlv[lv]
end

--获取天神升星配置
function NewTianshenUtil:GetStarUpCfg(star)
	return t_newtianshenstar[star]
end

--获取天神卡经验配置
function NewTianshenUtil:GetTianshenCardCfg(cardID)
	return t_newtianshencard[cardID]
end

--根据资质获取品质
function NewTianshenUtil:GetQualityByZizhi(nValue)
	for k, v in pairs(t_newtianshenxishu) do
		if v.limit[1] <= nValue and nValue <= v.limit[2] then
			return k
		end
	end
end

--根据资质获取显示品质
function NewTianshenUtil:GetShowQuality(nValue)
	local quality = self:GetQualityByZizhi(nValue)
	if quality == 3 then
		quality = 5
	end
	return quality
end

--获取应该选中的天神
function NewTianshenUtil:GetShowTianshenIndex()
	local list = NewTianshenModel:GetFightList()
	local index
	for i = 0, 5 do
		local tianshen = list[i]
		if tianshen then
			if not index then
				index = i
			end
			if self:IsCanStarUpBySize(i) or self:IsCanLvupBySize(i) then
				return i
			end
		end
	end
	return index
end

--- 获取星级属性配置
function NewTianshenUtil:GetTianshenStarAttrCfg(star)
	return t_newtianshenstarattr[star]
end

--- 属性系数公式
function NewTianshenUtil:GetAttrXiShu(cfg, zizhi)
	return ((zizhi-cfg.num3) * cfg.num4/100000 + cfg.num5)
end

function NewTianshenUtil:SetTianshenSlot(UI, tianshen)
	if tianshen then
		UI.icon._visible = true
		if UI.icon.source ~= tianshen:GetIcon() then
			UI.icon.source = tianshen:GetIcon()
		end
		UI.txt_star.text = "+" ..tianshen:GetStar()
		if UI.pfx then
			UI.pfx:gotoAndStop(tianshen:GetQuality() + 1)
		end
		if UI.pfx1 then
			UI.pfx1:gotoAndStop(tianshen:GetQuality() + 1)
		end
	else
		if UI.pfx then
			UI.pfx:gotoAndStop(6)
		end
		if UI.pfx1 then
			UI.pfx1:gotoAndStop(6)
		end
		UI.icon._visible = false
		UI.txt_star.text = ""
	end
end

function NewTianshenUtil:GetTianshenFightOpenLv(size)
	local cfg = t_consts[NewTianshenConsts.constID]
	local list = split(cfg.param, "#")
	for k, v in pairs(list) do
		local info = split(v, ",")
		if toint(info[1]) == size then
			return toint(info[2])
		end
	end
end

--获取列表VO
function NewTianshenUtil:GetSkillListVO(skillId)
	local vo = {};

	vo.skillId = skillId;
	local cfg = t_passiveskill[skillId];
	if not cfg then
	   cfg = t_skill[skillId];
	end
	if cfg then
		vo.name = cfg.name;
		vo.lvl = cfg.level;
		vo.iconUrl = ResUtil:GetSkillIconUrl(cfg.icon);
	end
	return vo;
end


---是否有天神可以获取升级传承
function NewTianshenUtil:IsHaveTianshenCanAcceptLv(tianshen)
	local list = NewTianshenModel:GetFightList()
	for k, v in pairs(list) do
		if v:GetLv() > tianshen:GetLv() then
			return true
		end
	end
	return false
end

--- 天神是否能被传承
function NewTianshenUtil:IsCanResp(tianshen)
	if tianshen:GetLv() > 0 or tianshen:GetStar() > 0 then
		return true
	end
	return false
end

--- 是否可以传承星级
function NewTianshenUtil:IsCanRespStar(tianshen)
	if tianshen:GetStar() > 0 then
		return true
	end
	return false
end

-- 是否可以被传承等级
function NewTianshenUtil:IsCanRespLv(tianshen)
	if tianshen:GetLv() > 0 then
		return true
	end
	return false
end

---是否有天神可以获取升星传承
function NewTianshenUtil:IsHaveTianshenCanAcceptStar(tianshen)
	local list = NewTianshenModel:GetFightList()
	for k, v in pairs(list) do
		if v:GetQuality() == tianshen:GetQuality() and v:GetStar() < v:GetStar() then
			return true
		end
	end
	return false
end

--获取天神卡属性
function NewTianshenUtil:GetTianshenCardPro(cardID, zizhi)
	local pro = {}
	local cardCfg = self:GetTianshenCardCfg(cardID)
	local baseCfg = self:GetBaseConfig(cardCfg.tianshenid)
	local cfg = NewTianshenUtil:GetAttrConfig(cardCfg.tianshenid)
	local basepro = AttrParseUtil:Parse(cfg.baseattr)
	local lvpro = AttrParseUtil:Parse(cfg.attr_lv)

	local xishuCfg = NewTianshenUtil:GetAttrXishuCfg(self:GetQualityByZizhi(zizhi))
	local xishu = NewTianshenUtil:GetAttrXiShu(xishuCfg, zizhi)
	for k, v in pairs(basepro) do
		basepro[k].val = v.val*xishu
	end
	pro = PublicUtil:GetFightListPlus(pro, basepro)
	local lv = cardCfg.param[2] or 0
	if lv ~= 0 then
		for k, v in pairs(lvpro) do
			lvpro[k].val = v.val*xishu*lv
		end
		pro = PublicUtil:GetFightListPlus(pro, lvpro)
	end

	local star = cardCfg.param[1] or 0
	if star ~= 0 then
		local starpro = AttrParseUtil:Parse(NewTianshenUtil:GetTianshenStarAttrCfg(star)["baseattr" ..self:GetQualityByZizhi(zizhi)])
		pro = PublicUtil:GetFightListPlus(pro, starpro)
	end
	for k, v in pairs(pro) do
		pro[k].val = toint(v.val + 0.5)
	end
	return pro
end

--获取天神卡星级等级
function NewTianshenUtil:GetTianshenCardStarLv(cardID)
	local cardCfg = self:GetTianshenCardCfg(cardID)
	return cardCfg.param[1], cardCfg.param[2]
end

--根据天神卡获取天神名字
function NewTianshenUtil:GetTianshenName(cardID)
	return self:GetBaseConfig(self:GetTianshenCardCfg(cardID).tianshenid).name
end

--获取附体技能列表
function NewTianshenUtil:GetAttachedSkills(skills)
	local result = {};	
	for i,id in ipairs(skills) do
		local skill = SkillVO:new(toint(id));
		skill.selected = true;
		skill.pos = i;
		table.push(result,skill);
	end
	
	return result;
end


---是否有超过30个白色或者蓝色天神卡
function NewTianshenUtil:IsHaveCardCanCompose()
	local bag = BagModel:GetBag(BagConsts.BagType_Tianshen);
	local cards = bag:GetItemListByShowType(BagConsts.ShowType_All)
	local count = 0
	local count1 = 0
	for k, v in pairs(cards) do
		local quality = NewTianshenUtil:GetQualityByZizhi(v:GetParam())
		if quality == 0 then
			count = count + 1
		elseif quality == 1 then
			count1 = count1 + 1
		end
		if count1 >= 30 or count >= 30 then
			return true
		end
	end
	return false
end

---是否有超过10个白色或者蓝色天神卡
function NewTianshenUtil:IsHaveTenCardCanCompose(type)
	local bag = BagModel:GetBag(BagConsts.BagType_Tianshen);
	local cards = bag:GetItemListByShowType(BagConsts.ShowType_All)
	local count = 0
	for k, v in pairs(cards) do
		local quality = NewTianshenUtil:GetQualityByZizhi(v:GetParam())
		if type == 1 and quality == 0 then
			count = count + 1
		elseif type == 2 and quality == 1 then
			count = count + 1
		end
		if count >= 10 then
			return true
		end
	end
	return false
end

---是否有天神可上阵
function NewTianshenUtil:IsHaveTianshenCanFight()
	for i = 0, 5 do
		if not NewTianshenModel:GetTianshenByFightSize(i) and NewTianshenUtil:GetTianshenFightOpenLv(i) <= MainPlayerModel.humanDetailInfo.eaLevel then
			for k,v in pairs(NewTianshenModel:GetTianshenList()) do
				if v:GetPos() == -1 and not NewTianshenModel:HaveFightByTianshenID(v:GetTianshenID()) then
					return true
				end
			end
		end
	end
	return false
end

---是否有天神可以升星
function NewTianshenUtil:IsHaveTianshenCanStarUp()
	for i = 0, 5 do
		if self:IsCanStarUpBySize(i) then
			return true
		end
	end
	return false
end

--出战位是否可以升星
function NewTianshenUtil:IsCanStarUpBySize(i)
	local tianshen = NewTianshenModel:GetTianshenByFightSize(i)
	if tianshen then
		if not tianshen:IsMaxStar() then
			local needQuality = tianshen:GetStarNeedQuality()
			local bag = BagModel:GetBag(BagConsts.BagType_Tianshen);
			local cards = bag:GetItemListByShowType(BagConsts.ShowType_All)
			local count = 0
			for k, v in pairs(cards) do
				local quality
				if self:IsExpCard(v:GetTid()) then
					quality = t_item[v:GetTid()].quality
					if quality == 5 then
						quality = 3
					end
				else
					quality = NewTianshenUtil:GetQualityByZizhi(v:GetParam())
				end
				if needQuality[quality] then
					count = count + 1
					if count >= 10 then
						return true
					end
				end
			end
		end
	end
	return false
end

---是否有天神可以升级
function NewTianshenUtil:IsHaveTianshenCanLvUp()
	for i = 0, 5 do
		if self:IsCanLvupBySize(i) then
			return true
		end
	end
	return false
end

---出战位是否可以升级
function NewTianshenUtil:IsCanLvupBySize(i)
	local tianshen = NewTianshenModel:GetTianshenByFightSize(i)
	if tianshen then
		if not tianshen:IsMaxLv() and tianshen:IsCanLvUp() then
			if BagModel:GetItemNumInBag(t_consts[348].val1) > 0 then
				return true
			end
		end
	end
end
function NewTianshenUtil:CheckTianShenCanOperation()

	if not FuncManager:GetFuncIsOpen(FuncConsts.NewTianshen) then 
		return false
	end
	if self:IsHaveTianshenCanFight() or self:IsHaveTianshenCanStarUp() or self:IsHaveTianshenCanLvUp() then 
		return true
	end
    return false
end

--- 获取当前天神总属性
function NewTianshenUtil:GetAllPro()
	local list = NewTianshenModel:GetFightList()
	local pro = {}
	for k, v in pairs(list) do
		pro = PublicUtil:GetFightListPlus(pro, v:GetPro())
	end
	return pro
end

--- 判断天神卡是不是经验卡
function NewTianshenUtil:IsExpCard(id)
	if self:GetTianshenCardCfg(id).tianshenid == 0 then
		return true
	end
end

-- 天神卡获取技能
function NewTianshenUtil:GetSKill(cardID, quality)
	local cfg = self:GetTianshenCardCfg(cardID)
	local tianshenCfg = self:GetBaseConfig(cfg.tianshenid)

	local list = {}
	local skillList = split(tianshenCfg['fight_skill' ..quality], ",")
	for k, v in pairs(skillList) do
		table.insert(list, toint(v))
	end
	return list
end

-- 天神卡获取资质(这里)
function NewTianshenUtil:GetTianshenCardZizhi(cardID)
	local cfg = self:GetTianshenCardCfg(cardID)
	local zizhi
	local zizhi1
	for i = 1, 5 do
		if cfg['ability' ..i] and cfg['ability' ..i] ~= "" then
			zizhi = toint(split(cfg['ability' ..i], ",")[2])
			if not zizhi1 then
				zizhi1 = toint(split(cfg['ability' ..i], ",")[1])
			end
		else
			break
		end
	end
	return zizhi, zizhi1
end

-- 天神卡是否比上阵的天神资质更高
function NewTianshenUtil:IsBetterCard(id)
	local bagVO = BagModel:GetBag(BagConsts.BagType_Tianshen);
	if not bagVO then return false end
	local item = bagVO:GetItemById(id)
	if not id then return false end
	local tianshenID = self:GetTianshenCardCfg(item:GetTid()).tianshenid
	if tianshenID == 0 then return false end
	local fightList = NewTianshenModel:GetFightList()
	for k, v in pairs(fightList) do
		if v:GetTianshenID() == tianshenID then
			return item:GetParam() > v:GetZizhi()
		end
	end
	for i = 0, 5 do
		if fightList[i] then
			if item:GetParam() > fightList[i]:GetZizhi() then
				return true
			end
		else
			if MainPlayerModel.humanDetailInfo.eaLevel >= NewTianshenUtil:GetTianshenFightOpenLv(i) then
				return true
			end
		end
	end
	return false
end

---是否有天神可以升星
function NewTianshenUtil:IsHaveTianshenCanStarUpThree()
	for i = 0, 5 do
		if self:IsCanStarUpThreeBySize(i) then
			return true
		end
	end
	return false
end

--出战位是否可以升星
function NewTianshenUtil:IsCanStarUpThreeBySize(i)
	local tianshen = NewTianshenModel:GetTianshenByFightSize(i)
	if tianshen then
		if not tianshen:IsMaxStar() then
			local needQuality = tianshen:GetStarNeedQuality()
			local bag = BagModel:GetBag(BagConsts.BagType_Tianshen);
			local cards = bag:GetItemListByShowType(BagConsts.ShowType_All)
			local count = 0
			for k, v in pairs(cards) do
				local quality
				if self:IsExpCard(v:GetTid()) then
					quality = t_item[v:GetTid()].quality
					if quality == 5 then
						quality = 3
					end
				else
					quality = NewTianshenUtil:GetQualityByZizhi(v:GetParam())
				end
				if needQuality[quality] then
					count = count + 1
					if count >= 30 then
						return true
					end
				end
			end
		end
	end
end

---是否有天神可以升级
function NewTianshenUtil:IsHaveTianshenCanLvUpTwo()
	for i = 0, 5 do
		if self:IsCanLvupTwoBySize(i) then
			return true
		end
	end
	return false
end

---出战位是否可以升级
function NewTianshenUtil:IsCanLvupTwoBySize(i)
	local tianshen = NewTianshenModel:GetTianshenByFightSize(i)
	if tianshen then
		if not tianshen:IsMaxLv() and tianshen:IsCanLvUp() then
			if BagModel:GetItemNumInBag(t_consts[348].val1) > 20 then
				return true
			end
		end
	end
end
function NewTianshenUtil:CheckTianShenCanOperation()

	if not FuncManager:GetFuncIsOpen(FuncConsts.NewTianshen) then 
		return false
	end
	if self:IsHaveTianshenCanFight() or self:IsHaveTianshenCanStarUp() or self:IsHaveTianshenCanLvUp() then 
		return true
	end
    return false
end

--- 天神是否可以接受传承等级和星级
function NewTianshenUtil:IsCanAcceptLvAndStar(tianshen, acceptTianshen)
	local bLv, bStar = false, false
	if tianshen:GetLv() > acceptTianshen:GetLv() then
		bLv = true
	end
	if tianshen:GetQuality() == acceptTianshen:GetQuality() and tianshen:GetStar() > acceptTianshen:GetStar() then
		bStar = true
	end
	return bLv, bStar
end