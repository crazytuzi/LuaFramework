--[[
	新天神
	chenyujia
	2016-12-9
]]

_G.NewTianshen = {};

function NewTianshen:new()
	local obj = setmetatable({}, {__index = self});
	obj.id = id
	obj.tianshenID = 0	--天神ID
	obj.cardid = 0		--天神卡ID
	obj.lv = 0		--天神等级
	obj.exp = 0	--等级进度
	obj.star = 0	--天神星级
	obj.natural = 100 --资质
	obj.pos = -1     --出站位
	obj.map = 0		--获取地图
	obj.timeget = 0 --获取时间
	obj.passSkill = {} --被动技能列表
	return obj;
end

function NewTianshen:CreateTianshen(data)
	local tianshen = self:new()
	tianshen.id = data.id
	tianshen.tianshenID = data.tid
	tianshen.cardid = data.cardid
	tianshen.pos = data.pos
	tianshen.lv = data.step
	tianshen.star = data.star
	tianshen.exp = data.stepexp
	tianshen.natural = data.ability
	tianshen.map = data.mapget
	tianshen.timeget = data.timeget
	tianshen.attachedSkills = NewTianshenUtil:GetAttachedSkills(tianshen:GetSkill());
	local list = split(data.passskills, ",")
	for k, v in pairs(list) do
		if v and v ~= "" then
			table.insert(tianshen.passSkill, toint(v))
		end
	end
	return tianshen
end

function NewTianshen:CreateZeroTianshen(id)
	local tianshen = self:new()
	tianshen.tianshenID = id
	tianshen.natural = 200
	tianshen.GetAttachedSkills = NewTianshenUtil:GetAttachedSkills(tianshen:GetSkill())
	return tianshen
end

function NewTianshen:UpdataInfo(data)
	self.id = data.id
	self.tianshenID = data.tid
	self.cardid = data.cardid
	self.pos = data.pos
	self.lv = data.step
	self.exp = data.stepexp
	self.star = data.star
	self.natural = data.ability
	self.map = data.mapget
	self.timeget = data.timeget
	local list = split(data.passskills, ",")
	self.passSkill = {}
	for k, v in pairs(list) do
		if v and v ~= "" then
			table.insert(self.passSkill, toint(v))
		end
	end
end

function NewTianshen:GetTianshenID()
	return self.tianshenID
end

function NewTianshen:GetQuality()
	return NewTianshenUtil:GetQualityByZizhi(self.natural)
end

function NewTianshen:GetShowQuality()
	return NewTianshenUtil:GetShowQuality(self.natural)
end

function NewTianshen:GetPos()
	return self.pos
end

function NewTianshen:GetCardID()
	return self.cardid
end

function NewTianshen:GetType()
	return self:GetCfg().type
end

function NewTianshen:GetName()
	return self:GetCfg().name
end

function NewTianshen:GetScene()
	return self:GetCfg().ui_sen
end

function NewTianshen:GetCfg()
	return NewTianshenUtil:GetBaseConfig(self.tianshenID)
end

function NewTianshen:GetHtmlName()
	return string.format("<font color='%s'>%s</font>", TipsConsts:GetItemQualityColor(self:GetShowQuality()), self:GetName())
end

function NewTianshen:GetHtmlZizhi()
	return string.format("<font color='%s'>%s</font>", TipsConsts:GetItemQualityColor(self:GetShowQuality()), self:GetZizhi())
end

function NewTianshen:GetColor()
	return TipsConsts:GetItemQualityColor(self:GetShowQuality())
end

function NewTianshen:GetIcon()
	return ResUtil:GetNewTianshenIcon(self:GetCfg().name_icon)
end

function NewTianshen:GetNameIcon()
	local quality = self:GetQuality()
	return ResUtil:GetNewTianshenIcon(self:GetCfg().rank_name_icon .. "_" .. quality)
end

function NewTianshen:GetMainNameIcon()
	local quality = self:GetQuality()
	return ResUtil:GetNewTianshenIcon(self:GetCfg().name_icon1 .. "_" .. quality)
end
function NewTianshen:GetMainNameUIcon()
	local quality = self:GetQuality()
	return ResUtil:GetNewTianshenUIcon(self:GetCfg().rank_name_icon .. "_" .. quality)
end

function NewTianshen:GetLv()
	return self.lv
end

function NewTianshen:GetZizhi()
	return self.natural
end

function NewTianshen:GetFightValue()
	return PublicUtil:GetFigthValue(self:GetPro())
end

function NewTianshen:GetNextLvFight()
	return PublicUtil:GetFigthValue(self:GetNextLvPro())
end

function NewTianshen:GetNextStarFight()
	return PublicUtil:GetFigthValue(self:GetNextStarPro())
end

function NewTianshen:GetPro()
	local pro = {}
	local cfg = NewTianshenUtil:GetAttrConfig(self.tianshenID)
	local basepro = AttrParseUtil:Parse(cfg.baseattr)
	local lvpro = AttrParseUtil:Parse(cfg.attr_lv)
	local xishuCfg = NewTianshenUtil:GetAttrXishuCfg(self:GetQuality())
	local xishu = NewTianshenUtil:GetAttrXiShu(xishuCfg, self:GetZizhi())
	for k, v in pairs(basepro) do
		basepro[k].val = v.val*xishu
	end
	pro = PublicUtil:GetFightListPlus(pro, basepro)
	if self:GetLv() ~= 0 then
		for k, v in pairs(lvpro) do
			lvpro[k].val = v.val*xishu*self:GetLv()
		end
		pro = PublicUtil:GetFightListPlus(pro, lvpro)
	end

	if self:GetStar() ~= 0 then
		local starpro = AttrParseUtil:Parse(NewTianshenUtil:GetTianshenStarAttrCfg(self:GetStar())["baseattr" ..self:GetQuality()])
		pro = PublicUtil:GetFightListPlus(pro, starpro)
	end
	---被动技能属性
	for k, v in pairs(self.passSkill) do
		local str = t_passiveskill[v].add_attr
		if str and str ~= "" then
			pro = PublicUtil:GetFightListPlus(pro, AttrParseUtil:Parse(str))
		end
	end
	for k, v in pairs(pro) do
		pro[k].val = toint(v.val + 0.5)
	end
	return pro
end

function NewTianshen:GetNextLvPro()
	local pro = {}
	local cfg = NewTianshenUtil:GetAttrConfig(self.tianshenID)
	local basepro = AttrParseUtil:Parse(cfg.baseattr)
	local lvpro = AttrParseUtil:Parse(cfg.attr_lv)
	local xishuCfg = NewTianshenUtil:GetAttrXishuCfg(self:GetQuality())
	local xishu = NewTianshenUtil:GetAttrXiShu(xishuCfg, self:GetZizhi())
	for k, v in pairs(basepro) do
		basepro[k].val = v.val*xishu
	end
	pro = PublicUtil:GetFightListPlus(pro, basepro)
	for k, v in pairs(lvpro) do
		lvpro[k].val = v.val*xishu*(self:GetLv() + 1)
	end
	pro = PublicUtil:GetFightListPlus(pro, lvpro)
	if self:GetStar() ~= 0 then
		local starpro = AttrParseUtil:Parse(NewTianshenUtil:GetTianshenStarAttrCfg(self:GetStar())["baseattr" ..self:GetQuality()])
		pro = PublicUtil:GetFightListPlus(pro, starpro)
	end

	---被动技能属性
	for k, v in pairs(self.passSkill) do
		local str = t_passiveskill[v].add_attr
		if str and str ~= "" then
			pro = PublicUtil:GetFightListPlus(pro, AttrParseUtil:Parse(str))
		end
	end
	for k, v in pairs(pro) do
		pro[k].val = toint(v.val + 0.5)
	end
	return pro
end

function NewTianshen:GetNextStarPro()
	local pro = {}
	local cfg = NewTianshenUtil:GetAttrConfig(self.tianshenID)
	local basepro = AttrParseUtil:Parse(cfg.baseattr)
	local lvpro = AttrParseUtil:Parse(cfg.attr_lv)
	local xishuCfg = NewTianshenUtil:GetAttrXishuCfg(self:GetQuality())
	local xishu = NewTianshenUtil:GetAttrXiShu(xishuCfg, self:GetZizhi())
	for k, v in pairs(basepro) do
		basepro[k].val = v.val*xishu
	end
	pro = PublicUtil:GetFightListPlus(pro, basepro)
	if self:GetLv() ~= 0 then
		for k, v in pairs(lvpro) do
			lvpro[k].val = v.val*xishu*self:GetLv()
		end
		pro = PublicUtil:GetFightListPlus(pro, lvpro)
	end
	local starpro = AttrParseUtil:Parse(NewTianshenUtil:GetTianshenStarAttrCfg(self:GetStar() + 1)["baseattr" ..self:GetQuality()])
	pro = PublicUtil:GetFightListPlus(pro, starpro)
	for k, v in pairs(pro) do
		pro[k].val = toint(v.val + 0.5)
	end

	---被动技能属性
	for k, v in pairs(self.passSkill) do
		local str = t_passiveskill[v].add_attr
		if str and str ~= "" then
			pro = PublicUtil:GetFightListPlus(pro, AttrParseUtil:Parse(str))
		end
	end
	return pro
end

function NewTianshen:GetId()
	return self.id
end

function NewTianshen:GetStar()
	return self.star
end

function NewTianshen:GetLvProgress()
	return self.exp
end

function NewTianshen:GetSkill()
	local cfg = self:GetCfg()
	local list = {}
	local skillList = split(cfg['fight_skill' ..self:GetQuality()], ",")
	for k, v in pairs(skillList) do
		table.insert(list, toint(v))
	end
	return list
end

function NewTianshen:GetPassSkill()
	return self.passSkill
end

function NewTianshen:GetMaxLv()
	return NewTianshenUtil:GetAttrXishuCfg(self:GetQuality()).maxlv
end

function NewTianshen:IsMaxLv()
	return self.lv >= self:GetMaxLv()
end

function NewTianshen:IsMaxStar()
	return self.star >= self:GetMaxStar()
end

function NewTianshen:IsCanLvUp()
	return self.lv < MainPlayerModel.humanDetailInfo.eaLevel
end

function NewTianshen:GetMaxStar()
	return NewTianshenUtil:GetAttrXishuCfg(self:GetQuality()).maxstar
end

function NewTianshen:GetStarNeedQuality()
	local xishuCfg = NewTianshenUtil:GetAttrXishuCfg(self:GetQuality())
	local qualityList = {}
	local qualityTab = split(xishuCfg.eatstartype, ",")
	for k, v in pairs(qualityTab) do
		qualityList[toint(v)] = true
	end
	return qualityList
end

function NewTianshen:GetLvNeedCount()
	local curExp = 0
	local curLvCfg = NewTianshenUtil:GetLvUpCfg(self.lv)
	if curLvCfg then
		curExp = curLvCfg.exp
	end
	return NewTianshenUtil:GetLvUpCfg(self.lv + 1).exp - curExp
end

function NewTianshen:GetStarUpPer()
	return NewTianshenUtil:GetStarUpCfg(self.star)["exp" ..self:GetQuality()]
end

function NewTianshen:GetSuccess()
	return NewTianshenUtil:GetStarUpCfg(self.star + 1).display
end

function NewTianshen:Clone(source)
	if not source then
		return nil;
	end
	local result = {};
	for name,value in pairs(source) do
		local typeof = type(name);
		if typeof ~= 'table' and typeof ~= 'function' then
			result[name] = value;
		end
	end
	
end

function NewTianshen:Equal(source,target)
	if not source or not target then
		return true;
	end
	
	local changed = false;
	for name,value in pairs(source) do
		if value ~= target[name] then
			changed = true;
			break;
		end
	end
	
	return changed;
	
end