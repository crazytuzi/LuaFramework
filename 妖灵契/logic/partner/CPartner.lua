local CPartner = class("CPartner")

function CPartner.ctor(self, dPartner)
	self.m_ID = dPartner.parid
	self.m_PartnerType = dPartner.partner_type
	self.m_Data = self:CreateDefaultData(dPartner)
end

function CPartner.CreateDefaultData(self, dPartner)
	local d = {
		partner_type = 0,
		parid = 0,
		star = 0,
		name = "",
		model_info = {},
		grade = 0,
		exp = 0,
		hp = 0,
		attack = 0,
		defense = 0,
		critical_ratio = 0,
		res_critical_ratio = 0,
		cure_critical_ratio = 0,
		abnormal_attr_ratio = 0,
		res_abnormal_ratio = 0,
		speed = 0,
		
		power = 0,
		lock = 0,
		awake = 0,
		skill = {},
		patahp = 0,
		status = 0,
		power_rank = 0,
		amount = 1,
		souls = {},
		soul_type = 0,
	}
	return table.update(d, dPartner)
end

function CPartner.GetValue(self, key)
	if key == "maxhp" then
		key = "max_hp"
	end
	local v = self.m_Data[key]
	if not v then
		local t = data.partnerdata.DATA[self.m_Data.partner_type]
		if t then
			v = t[key]
		end
	end
	return v
end

function CPartner.UpdateProp(self, dPartner)
	if dPartner["model_info"] then
		self.m_Icon = nil
	end
	table.update(self.m_Data, dPartner)
end

function CPartner.GetMaxStar(self)
	return 5
end

function CPartner.GetShape(self)
	local shape = self:GetValue("model_info").shape or self:GetValue("shape")
	return shape
end

function CPartner.GetIcon(self)
	if self.m_Icon then
		return self.m_Icon
	end
	self.m_Icon = self:GetValue("icon")
	local skinList = g_PartnerCtrl:GetPartnerSkin(self:GetValue("partner_type"))
	local shape = self:GetShape()
	for _, v in ipairs(skinList) do
		if v.shape == shape then
			self.m_Icon = v.icon
			break
		end
	end
	return self.m_Icon
end

function CPartner.GetEquipInfo(self, planid)
	if not planid then
		planid = self:GetValue("equip_plan_id")
	end
	local equipplan = self:GetValue("equip_plan")
	local curplan = nil
	for i, v in pairs(equipplan) do
		if v["plan_id"] == planid then
			curplan = v["itemid_list"]
		end
	end
	if not curplan then
		return {}
	end

	local equipinfo = {}
	for k, itemid in pairs(curplan) do
		local oItem = g_ItemCtrl:GetItem(itemid)
		local pos = oItem:GetValue("pos")
		if pos then
			equipinfo[pos] = itemid
		end
	end
	return equipinfo
end

function CPartner.GetCurEquipInfo(self)
	local curplan = self:GetValue("equip_list")
	if not curplan then
		return {}
	end
	local equipinfo = {}
	for k, itemid in pairs(curplan) do
		local oItem = g_ItemCtrl:GetItem(itemid)
		if oItem then
			local pos = oItem:GetValue("pos")
			if pos then
				equipinfo[pos] = itemid
			end
		end
	end
	return equipinfo
end

function CPartner.GetOriAttr(self)
	local grade = self:GetValue("grade")
	for _, attrdata in pairs(data.partnerdata.ATTR) do
		if attrdata["partner_type"] == self:GetValue("partner_type") and attrdata["star"] == self:GetValue("star") 
			and self:GetValue("grade") >= attrdata["grade_range"]["min"]
			and self:GetValue("grade") <= attrdata["grade_range"]["max"] then
			local result = {}
			for key, value in pairs(attrdata) do
				if type(value) == "string" then
					result[key] = math.floor(string.eval(value, {lv = grade}))
				end
			end
			return result
		end
	end
	return nil
end

function CPartner.GetCurExp(self, grade, sumexp)
	if not grade then
		grade = self:GetValue("grade")
	end
	if not sumexp or sumexp == 0 then
		sumexp = self:GetValue("exp")
	end
	local expdata = data.partnerdata.UPGRADE
	if self:IsStarType() then
		expdata = data.partnerdata.STARUPGRADE
	end
	local getexp = 0
	for i = 1, grade - 1 do
		getexp = getexp + expdata[i]["partner_exp"]
	end
	return sumexp - getexp
end

function CPartner.GetNeedExp(self, iGrade)
	if not iGrade then
		iGrade = self:GetValue("grade")
	end
	if self:IsStarType() then
		return data.partnerdata.STARUPGRADE[iGrade]["partner_exp"]
	else
		return data.partnerdata.UPGRADE[iGrade]["partner_exp"]
	end
end

function CPartner.GetMaxGrade(self)
	grade = g_AttrCtrl.grade + 5
	return grade
end

function CPartner.GetStarLimitGrade(self)
	return 60
end

function CPartner.GetMaxEatExp(self)
	local grade = self:GetValue("grade")
	local maxgrade = self:GetMaxGrade()
	if maxgrade == grade then
		return 0
	end
	local expdata = data.partnerdata.UPGRADE
	if self:IsStarType() then
		expdata = data.partnerdata.STARUPGRADE
	end
	local maxexp = self:GetNeedExp() - self:GetCurExp()
	
	for i = grade + 1, maxgrade-1 do
		maxexp = maxexp + expdata[i]["partner_exp"]
	end
	return maxexp
end

function CPartner.GetAttrLevel(self, attrkey)
	local dData = data.partnerawakedata.Level
	local dict = dData[self:GetValue("partner_type")] or {}
	return dict[attrkey]
end

function CPartner.GetAwakeAttrLevel(self, attrkey)
	local dData = data.partnerawakedata.AwakeLevel
	local dict = dData[self:GetValue("partner_type")] or {}
	return dict[attrkey]
end

function CPartner.GetParSoulList(self)
	local soulList = self:GetValue("souls") or {}
	local dict = {}
	for _, v in ipairs(soulList) do
		dict[v.pos] = v.itemid
	end
	return dict
end

function CPartner.GetRestSoulPos(self)
	local dSoulData = self:GetParSoulList()
	local dLockData = data.partnerequipdata.ParSoulUnlock
	local iGrade = g_AttrCtrl.grade
	for i = 1, 6 do
		if iGrade >= dLockData[i]["unlock_grade"] then
			if not dSoulData[i] then
				return i
			end
		end
	end
	return 0
end

function CPartner.IsNormalType(self)
	local itype, _ = math.modf( self:GetValue("effect_type")/100 )
	return itype == 1
end

function CPartner.IsExpType(self)
	local itype, _ = math.modf( self:GetValue("effect_type")/100 )
	return itype == 2
end

function CPartner.IsStarType(self)
	local itype, _ = math.modf( self:GetValue("effect_type")/100 )
	return itype == 3
end

function CPartner.IsSkillType(self)
	local itype, _ = math.modf( self:GetValue("effect_type")/100 )
	return itype == 4
end

function CPartner.IsRedBun(self)
	return self:GetValue("partner_type") == 1754
end

function CPartner.IsAwake(self)
	return self:GetValue("awake") == 1
end

function CPartner.GetUpSkillAmount(self)
	local skilllist = self:GetValue("skill")
	local needamount = 0
	local dSkillData = data.skilldata.PARTNER
	for k, skillobj in pairs(skilllist) do
		local iMax = 5
		local dSkill =  dSkillData[skillobj["sk"]]
		if dSkill then
			iMax = #dSkill
		end
		needamount = needamount + math.max(iMax - skillobj["level"], 0)
	end
	return needamount
end

--status 1好友上锁 2好友展示 3公平竞技  4跟随 5参加据点战 6游历 7寄存游历
function CPartner.IsLock(self)
	local iStatus = self:GetValue("status")
	return MathBit.andOp(iStatus, 1) == 1
end

function CPartner.IsFollow(self)
	local iStatus = self:GetValue("status")
	return MathBit.andOp(iStatus, 8) == 8
end

function CPartner.IsEqualarena(self)
	local iStatus = self:GetValue("status")
	return MathBit.andOp(iStatus, 4) == 4
end

function CPartner.IsFriendShow(self)
	local iStatus = self:GetValue("status")
	return MathBit.andOp(iStatus, 2) == 2
end

function CPartner.IsTerraWar(self)
	local iStatus = self:GetValue("status")
	return MathBit.andOp(iStatus, 16) == 16
end

function CPartner.IsTravel(self)
	local iStatus = self:GetValue("status")
	return MathBit.andOp(iStatus, 32) == 32
end

function CPartner.IsInTravel(self)
	local iStatus = self:GetValue("status")
	return MathBit.andOp(iStatus, 64) == 64
end

function CPartner.IsEqualarenaPartner(self)
	local oData = data.equalarenadata.Partner[self.m_PartnerType]
	if oData then
		return true
	else
		return false
	end
end

function CPartner.GetStatusTxt(self)
	local txt
	if self:IsTravel() then
		txt = "游历中"
	elseif self:IsInTravel() then
		txt = "寄存中"
	end
	return txt
end

function CPartner.GetSkillLevel(self, skid)
	for _, skillobj in ipairs(self:GetValue("skill")) do
		if skid == skillobj["sk"] then
			return skillobj["level"]
		end
	end
	return 0
end

function CPartner.HasRank(self)
	return data.partnerdata.DATA[self.m_Data.partner_type].rank == 0
end

function CPartner.GetRankStr(self)
	local iPowerRank = self:GetValue("power_rank")
	if iPowerRank > 0 then
		return string.format("战力排名：%s", iPowerRank)
	else
		return "未上榜"
	end
end

function CPartner.IsHasUpStarRedPoint(self)
	if self.m_UpStarRedPoint == self:GetValue("star") then
		return false
	else
		if self:CanUpStar() then
			return true
		else
			return false
		end
	end
end

function CPartner.SetUpStarRedPoint(self)
	if self:CanUpStar() then
		self.m_UpStarRedPoint = self:GetValue("star")
		g_PartnerCtrl:OnEvent(define.Partner.Event.UpdateRedPoint, self.m_ID)
	end
end

--能否升星
function CPartner.CanUpStar(self)
	local b = false
	local star = self:GetValue("star")
	if star < 5 then
		local upData = data.partnerdata.UPSTAR[star]
		local chipCost = upData.cost_amount 
		local cost = upData.cost_coin 
		local level = upData.limit_level
		local myCnt = g_ItemCtrl:GetTargetItemCountBySid(20000 + self:GetValue("partner_type"))
		if g_AttrCtrl.coin >= cost and myCnt >= chipCost and self:GetValue("grade") >= level then
			b = true
		end 
	end
	return b
end

--能否觉醒
function CPartner.CanAwake(self)
	local b = false
	if not self:IsAwake() then
		local partnerData = data.partnerdata.DATA[self:GetValue("partner_type")]
		if partnerData and partnerData.awake_coin_cost and partnerData.awake_cost and next(partnerData.awake_cost) then
			if partnerData.awake_coin_cost > g_AttrCtrl.coin then
				return false
			end
			for i, v in ipairs(partnerData.awake_cost) do
				local myCnt = g_ItemCtrl:GetTargetItemCountBySid(v.sid)
				if myCnt < v.amount then
					return false
				end
			end
			b = true
		end
	end
	return b
end

--能否升级技能
function CPartner.CanSkillUp(self)
	local b = false
	if not self:IsMaxSkillLevel() then
		local partnerData = data.partnerdata.DATA[self:GetValue("partner_type")]		
		if partnerData and partnerData.skill_cost then
			local myCnt = g_ItemCtrl:GetTargetItemCountBySid(partnerData.skill_cost.sid)			
			if myCnt >= partnerData.skill_cost.amount then
				return true
			end
		end
	end 
	return b
end

function CPartner.CanParEquipUpStone(self)
	local dParEquipInfo = self:GetCurEquipInfo()
	for i = 1, 4 do
		local oItem = g_ItemCtrl:GetItem(dParEquipInfo[i])
		if oItem and oItem:IsParEquipCanUpStone() then
			return true
		end
	end
end

function CPartner.CanParEquipUpGrade(self)
	local dParEquipInfo = self:GetCurEquipInfo()
	for i = 1, 4 do
		local oItem = g_ItemCtrl:GetItem(dParEquipInfo[i])
		if oItem and oItem:IsHasParEquipUpGradeRedPoint() then
			return true
		end
	end
end

function CPartner.CanParEquipUpStar(self)
	local dParEquipInfo = self:GetCurEquipInfo()
	for i = 1, 4 do
		local oItem = g_ItemCtrl:GetItem(dParEquipInfo[i])
		if oItem and oItem:IsHasParEquipUpStarRedPoint() then
			return true
		end
	end
end

function CPartner.CanWearParSoul(self)
	if self.m_ParSoulRedFlag then
		return false
	end
	local iAmount = self:GetRestSoulPos()
	local dSoulList = self:GetValue("souls") or {}
	local dAttrDict = {}
	for _, v in ipairs(dSoulList) do
		local oItem = g_ItemCtrl:GetItem(v.itemid)
		if oItem then
			dAttrDict[oItem:GetValue("attr_type")] = true
		end
	end
	if iAmount > 0 and self:GetValue("soul_type") > 0 then
		local itemList = g_ItemCtrl:GetParSoulListBySoulType(self:GetValue("soul_type"))
		for _, oItem in ipairs(itemList) do
			if oItem:GetValue("parid") == 0 and not dAttrDict[oItem:GetValue("attr_type")] then
				return true
			end
		end
	end
	return false
end

function CPartner.CanWearParEquip(self)
	local info = self:GetCurEquipInfo()
	local dPos2UnLockLevel = data.partnerequipdata.ParEquipUnlock
	local iGrade = g_AttrCtrl.grade
	for i = 1, 4 do
		if iGrade >= dPos2UnLockLevel[i]["unlock_grade"]and not info[i] then
			return true
		end
	end
	return false
end

--技能是否满级
function CPartner.IsMaxSkillLevel(self)
	local cur = 0
	local max = 0
	local t = self:GetValue("skill")
	for i = 1, #t do
		local level = t[i].level
		local sk = t[i].sk
		local skM = data.powerguidedata.PARTNER_SKILL_MAX_LEVEL[sk] or level
		cur = level + cur
		max = skM + max
	end
	return cur == max
end

--获取已经穿戴的御灵列表
function CPartner.GetEquipedSoulTable(self )
	local t = {}
	local dSoulList = self:GetParSoulList()
	for i = 1, 6 do
		local iItemID = dSoulList[i]
		if iItemID then
			local d = {pos=i, id=iItemID}
			table.insert(t, d)
		end
	end
	return t
end

return CPartner