local CItem = class("CItem")

CItem.ItemState = 
{
	Invaild = 1,
	Limit = 2,
	Bind = 3 ,
	Normal = 4,
}

function CItem.ctor(self, dItem)
	self.m_ID = dItem.id
	self.m_SData = self:CreateDefalutData(dItem)
	local sid = dItem.sid
	self.m_CDataGetter = function() return DataTools.GetItemData(sid) end
end

function CItem.CreateDefalutData(self, dItem)
	local d = {
		sid = 0,
		create_time = 0,
		itemlevel = 0,
		amount = 0,
		end_time = 0,
		key = 0,
		apply_info = nil,
		desc = "",
		equip_info =nil,
		partner_equip_info = nil,
		treasure_info = nil,
		power = 0,
		lock = 0,
	}

	return table.update(d, dItem)
end

function CItem.NewBySid(iSid)
	local d = {sid = iSid}
	return CItem.New(d)
end

function CItem.GetValue(self, k)
	if k == "sub_type" then
		return self:GetItemSubType()

	elseif k == "icon" then
		return self:GetItemIcon()
	elseif k == "stone_sid" then
		return self:GetItemStoneSid()
	end

	local value = self.m_SData[k]
	if value == nil then
		value = self.m_CDataGetter()[k]
	end
	if value == nil then
		if self:IsPartnerEquip() and k ~= "red_dot" and self.m_SData["partner_equip"] then
			value = self.m_SData["partner_equip"][k]
		end
		
		if self:IsPartnerSoul() and k ~= "red_dot" and self.m_SData["partner_soul"] then
			value = self.m_SData["partner_soul"][k]
		end

		--如果获取道具的等级，则默认为1级
		if value == nil and k == "level" then
			value = 1
		end

		if value == nil and k == "exp" then
			value = 0
		end

		if value == nil and k == "state" then
			value = self:GetItemState()
		end

		if value == nil and k == "group_amount" then
			value = self:GetGroupAmount()
		end

		if value == nil and k == "can_equip_level" then
			value = self:GetCanEequipLevel()
		end

		if value == nil and k == "greate_self_score" then
			value = self:GetGreateSelfEquipScore()
		end		

		if value == nil and k == "base_score" then
			value = self:GetEquipBaseScore()
		end

		if value == nil and k == "state_group_amount" then
			value = self:GetStateGroupAmount()
		end
	end
	return value
end

function CItem.SetValue(self, k, v)
	if k == "amount" then
		self.m_SData.amount = v
	elseif k == "create_time" then
		self.m_SData.create_time = v
	else
		self.m_SData[k] = v
	end
end

function CItem.IsEquip(self)
	return define.Item.ItemType.Equip == self:GetValue("type")
end

function CItem.IsConsume(self)
	return define.Item.ItemType.Consume == self:GetValue("type")
end

function CItem.IsPartnerEquip(self)
	if define.Item.ItemType.PartnerEquip == self.m_CDataGetter()["type"] and
		self.m_SData["sid"] > 6000000 then
		return true
	else
		return false
	end
end

function CItem.IsTravel(self)
	return define.Item.ItemType.Travel == self:GetValue("type")
end

function CItem.IsPartnerChip(self)
	return define.Item.ItemType.PartnerChip == self:GetValue("type")
end

function CItem.IsPartnerSkin(self)
	return define.Item.ItemType.PartnerSkin == self:GetValue("type")
end

function CItem.IsExpPartnerEquip(self)
	if self:IsPartnerEquip() and self:GetValue("equip_type") == 60 then
		return true
	else
		return false
	end
end

function CItem.IsPartnerStone(self)
	return define.Item.ItemType.PartnerStone == self.m_CDataGetter()["type"]
end

function CItem.IsPartnerSoul(self)
	return define.Item.ItemType.PartnerSoul == self.m_CDataGetter()["type"]
end

function CItem.IsBagItemPos(self)

 	return true

-- 	if self.m_SData then
-- 		return self.m_SData.pos > define.Item.Constant.BagItemHand
-- 	end
end

--是否是身上的装备
function CItem.IsEquiped(self)
	local b = false
	
	if self:IsEquip() and self.m_SData.equip_info ~= nil and self.m_SData.equip_info.pos <= define.Equip.Pos.Shoes  then
		b = true
	end
	return b
end

function CItem.IsEquipSoul(self)
	return false
	-- return data.itemdata.EQUIPSOUL[self.m_CDataGetter.id] ~= nil and self.m_CDataGetter.id < 12300 
end


function CItem.HasAttachSoul(self)
	return self.m_SData.equip_info.fuhun_attr and #self.m_SData.equip_info.fuhun_attr > 0
end

function CItem.GetEquipAttrBase(self)
	local list = {} 

	if  self:IsEquiped() or self:GetValue("sub_type") == define.Item.ItemSubType.EquipStone  then
		list = self.m_SData.apply_info	or {}
	end
	return list
end

function CItem.GetEquipAttrFuWen(self, plan)
	local list = {}
	if  self:IsEquiped() then
		plan = plan or self.m_SData.equip_info.fuwen_plan
		if not plan then
			plan = 1
		end
		list = {}
		if self.m_SData.equip_info.fuwen[plan] then
			list = self.m_SData.equip_info.fuwen[plan].fuwen_attr
		end
	end
	return list
end

--缓存的符文属性
function CItem.GetEquipAttrFuWenBackup(self, plan)
	local list = {}
	if  self:IsEquiped() then
		plan = plan or self.m_SData.equip_info.fuwen_plan
		if not plan then
			plan = 1
		end		
		if self.m_SData.equip_info.fuwen and self.m_SData.equip_info.fuwen[plan] then
			list = self.m_SData.equip_info.fuwen[plan].back_fuwen or {}
		end		
	end
	return list
end

--获取符文品质
function CItem.GetEquipFuWenQuality(self, plan)
	local quality = 1
	if  self:IsEquiped() then
		plan = plan or self.m_SData.equip_info.fuwen_plan
		if not plan then
			plan = 1
		end
		if self.m_SData.equip_info.fuwen[plan] then
			local t = self.m_SData.equip_info.fuwen[plan].fuwen_attr or {}
			if #t > 0 then
				for i = 1, #t do
					if t[i].quality > quality then
						quality = t[i].quality
					end
				end
			end
		end
	end
	return quality
end

--获取符文重置品质
function CItem.GetEquipFuWenQualityBackup(self, plan)
	local quality = 1
	if  self:IsEquiped() then
		plan = plan or self.m_SData.equip_info.fuwen_plan
		if not plan then
			plan = 1
		end
		if self.m_SData.equip_info.fuwen[plan] then
			local t = self.m_SData.equip_info.fuwen[plan].back_quality or {}
			if #t > 0 then
				for i = 1, #t do
					if t[i].quality > quality then
						quality = t[i].quality
					end
				end
			end			
		end
	end
	return quality
end

function CItem.GetEquipAttrStrength(self)
	local list = {}
	if self:IsEquiped() then
		list = self.m_SData.equip_info.strength_attr or {}
	end
	return list
end

function CItem.GetEquipAttrGem(self)
	local list = {}
	if  self:IsEquiped() then
		list = self.m_SData.equip_info.gem_attr or {}
	end
	return list
end

--根据宝石的位置(1~6)，获取返回的宝石信息
--没有镶嵌或者没开启宝石槽，则返回nil
function CItem.GetEquipPerGemDataByPos(self, pos)
	local t = nil
	local gem = self:GetEquipAttrGem()
	for k , v in pairs(gem) do
		if v.pos == pos then
			local iExp = 0
			for _k, _v in pairs(v.apply_info) do
				if _v.key == "exp" then
					iExp = _v.value
					break
				end			
			end
			t = {pos = v.pos, sid = v.sid, exp = iExp, apply_info = v.apply_info}
			break
		end
	end

	return t
end

function CItem.IsBingdingItem(self)
	local key = self:GetValue("key") or 0
	return MathBit.andOp(key, 1) ~= 0
end

function CItem.IsLimitItem(self)
	local key = self:GetValue("key") or 0
	return MathBit.andOp(key, 2) ~= 0
end

function CItem.GetLimitTime(self)
	if not self:IsLimitItem() then
		return ""
	end
	local invaildTime = self:GetValue("time") or 0

	local time = invaildTime - g_TimeCtrl:GetTimeS()
	if time	< 0 then
		str = "已失效"
	else
		local d = math.floor(time / (3600 * 24))
		time = time % (3600 * 24)
		local h = math.floor(time / 3600)
		time = time % 3600
		local m = math.floor(time / 60)
		str = (d ~= 0) and str..tostring(d).."天" or str
		str = (h ~= 0) and str..tostring(h).."时" or str
		str = str..tostring(m).."分"
	end
	return str
end

function CItem.IsInvaildItem(self)
	return (self:GetLimitTime() == "已失效")
end

function CItem.isCanSellItem(self)
	local price = self:GetValue("sale_price") or 0
	return price ~= 0
end

function CItem.GetItemSubType(self)
	local iType = -1

	local sid = self:GetValue("sid")
	local t = define.Item.ItemSubTypeRange

	for k,v in pairs(t) do
		if sid >= v[1] and sid <= v[2] then
			iType = k
			break
		end
	end
	return iType
end

function CItem.GetStrengthLevel(self)
	local level = 0
	if self:IsEquiped() then
		local t = self:GetEquipAttrStrength() or {}
		for _,v in pairs(t) do
			if v.key == "level" then
				level = tonumber(v.value or 0) 
				break
			end
		end
	end
	return level 
end

function CItem.GetPartnerEquipAttr(self)
	local attrdict = {}
	local equipinfo = self:GetValue("partner_equip_info")
	for i, name in pairs({"main_apply", "sub_apply"}) do
		for _, applyinfo in pairs(equipinfo[name]) do
			local key = applyinfo["key"]
			if not attrdict[key] then
				attrdict[key] = 0
			end
			attrdict[key]= attrdict[key] + applyinfo["value"]
		end
	end
	return attrdict
end

function CItem.GetParEquipAttr(self)
	local sAttr = self:GetValue("attr")
	local func = loadstring("return "..sAttr) 
	local dAttrData = func()
	local dStoneInfo = self:GetValue("stone_info")
	for _, dStone in ipairs(dStoneInfo) do
		for _, dApply in ipairs(dStone.apply_info) do
			dAttrData[dApply.key] = dAttrData[dApply.key] or 0
			dAttrData[dApply.key] = dAttrData[dApply.key] + dApply.value
		end
	end
	return dAttrData
end

function CItem.GetParEquipBaseAttr(self)
	local sAttr = self:GetValue("attr")
	local func = loadstring("return "..sAttr) 
	local dAttrData = func()
	return dAttrData
end

function CItem.GetParSoulAttr(self)
	local sAttr = self:GetValue("attr")
	local iLevel = self:GetValue("level")
	sAttr = string.replace(sAttr, "level", tostring(iLevel))
	local func = loadstring("return "..sAttr) 
	local dBaseAttr = func() or {}

	local sAttr = self:GetValue("attr_ratio")
	sAttr = string.replace(sAttr, "level", tostring(iLevel))
	local func = loadstring("return "..sAttr) 
	local dRatioAttr = func() or {}
	table.update(dBaseAttr, dRatioAttr)
	return dBaseAttr
end

function CItem.UpdatePartnerEquip(self, partnerequip)
	self.m_SData["partner_equip"] = partnerequip
end

function CItem.UpdatePartnerSoul(self, info)
	self.m_SData["partner_soul"] = info
end

function CItem.UpdateLock(self, iLock)
	self.m_SData["lock"] = iLock 
end

--获取装备适用
function CItem.GetEquipFitInfo(self)
	local str = ""
	if self:GetValue("type") == define.Item.ItemType.EquipStone or 
		self:GetValue("type") == define.Item.ItemType.Equip then
		local pos = self:GetValue("pos")
		if pos == define.Equip.Pos.Weapon then
			local weaponType = self:GetValue("weapon_type")
			local branch = 1
			for k, v in ipairs(data.itemdata.SCHOOL_WEAPON) do
				if v.weapon == weaponType then
					branch = k
					break
				end
			end
			str = data.roletypedata.BRANCH_TYPE[branch].name

		elseif pos == define.Equip.Pos.Necklace or pos == define.Equip.Pos.Ring then
			str = "全部"
		else
			if self:GetValue("sex") == 2 then
				str = "女"
			else
				str = "男"
			end
		end
	end
	return str
end

--获取装备总评分
function CItem.GetEquipScore(self)
	local str = ""
	if self:GetValue("type") == define.Item.ItemType.EquipStone or 
		self:GetValue("type") == define.Item.ItemType.Equip then
		str = tostring(self:GetValue("power")) 
	end
	return str
end

--获取装备基本评分
function CItem.GetEquipBaseScore(self)
	local score = 0
	if self:GetValue("type") == define.Item.ItemType.EquipStone or 
		self:GetValue("type") == define.Item.ItemType.Equip then
		local t = self:GetValue("apply_info")
		if t and next(t) then
			for _, v in pairs(t) do
				if v.key == "equip_power" then
					score = tonumber(v.value)
					break
				end
			end
		end
	end
	return score
end

function CItem.GetItemState(self)
	local s = CItem.ItemState.Normal
	if self:GetLimitTime() == "已失效" then
		s = CItem.ItemState.Invaild
	elseif self:GetLimitTime() ~= "" then 
		s = CItem.ItemState.Limit
	elseif self:IsBingdingItem() then
		s = CItem.ItemState.Bind
	end
	return s
end

--同一sid物品的组合数量
function CItem.SetGroupAmount(self, amount)
	self.group_amount = amount
end

function CItem.GetGroupAmount( self )
	local t = 0
	if self.group_amount ~= nil then
		t = self.group_amount 
	end
	return t
end

--同一sid物品 同一状态(失效，限时，绑定，正常)的组合数量
function CItem.SetStateGroupAmount(self, amount)
	self.state_group_amount = amount
end

function CItem.GetStateGroupAmount( self )
	local t = 0
	if self.state_group_amount ~= nil then
		t = self.state_group_amount 
	end
	return t
end

--获取装备的某种基本属性(比如攻击力,不算符文和宝石)
function CItem.GetEquipBaseAttrByKey(self, key)
	local attr = 0
	if self:IsEquiped() or self:GetValue("sub_type") == define.Item.ItemSubType.EquipStone  then
		local t = self:GetEquipAttrBase() or {}
		for k, v in pairs(t) do
			if key == v.key then
				attr = v.value
				break
			end
		end
	end
	return attr
end

--获取装备的宝石属性
function CItem.GetEquipGemAttr(self)
	local attr = {}
	if self:IsEquiped() then
		local t = self:GetEquipAttrGem() or {}
		if next(t) ~= nil then
			for i = 1, 6 do 
				local d = t[i]
				if d ~= nil and d.apply_info ~= nil then
					for k, v in pairs(d.apply_info) do
						if v.key ~= "exp" then
							attr[v.key] = attr[v.key] or 0
							attr[v.key] = attr[v.key] + v.value
						end
					end
				end	
			end
		end
	end
	return attr
end

--该装备是否适合该职业
function CItem.IsFit(self, isFitSchool)
	local b = false
	local sub_type = self:GetValue("sub_type")
	if sub_type == define.Item.ItemSubType.EquipStone then
		local pos = self:GetValue("pos")	
		if pos == define.Equip.Pos.Weapon then
			local weaponType = self:GetValue("weapon_type")
			if isFitSchool then
				local myWeaponTypeTable = g_AttrCtrl:GetMyFitSchoolWeaponType()
				for i,v in ipairs(myWeaponTypeTable) do
					if v == weaponType then
						b = true
						break
					end
				end	
			else
				local myWeaponType = g_AttrCtrl:GetMyFitWeaponType()
				b = (weaponType == myWeaponType)
			end

		elseif pos == define.Equip.Pos.Necklace or pos == define.Equip.Pos.Ring then
			b = true
		else
			local sex = self:GetValue("sex")
			b = (sex == g_AttrCtrl.sex)
		end
	end
	return b
end

--装备是否已经加锁
function CItem.IsEuqipLock(self)
	return self:GetValue("lock") == 1
end


--uimode == 1  背包
--获取装备特效
function CItem.GetEquipSEString(self, uiMode)
	local str = "无"
	local sid 
	local pos = define.Equip.Pos.Weapon
	local equipLevel = 0
	local isEquipStone = false
	uiMode = uiMode or 1
	local ColorTrigger = nil
	local ColorUnTrigger = nil
	local ColorOther = nil
	--颜色类型
	if uiMode == 1 then
		ColorOther = "[FFFFFF]"
		ColorTrigger = "[54e414]"
		ColorUnTrigger = "[8c8783]"
	else
		ColorOther = "[FFFFFF]"
		ColorTrigger = "[54e414]"
		ColorUnTrigger = "[8c8783]"
	end

	if self:GetValue("type") == define.Item.ItemType.EquipStone then
		sid = self:GetValue("sid")
		pos = self:GetValue("pos")
		isEquipStone = true
	elseif self:GetValue("type") == define.Item.ItemType.Equip then
		sid = self.m_SData.equip_info.stone_sid or 0
		pos = self:GetValue("pos")
	end

	--武器的装备特效就是套装技能
	if pos == define.Equip.Pos.Weapon then
		if sid then
			local d = data.itemdata.EQUIP_SE[sid]
			if d then
				str = string.format("%s%s", ColorTrigger,d.desc) 			
			end
		end
	else
		--当前世装备灵石的套装，都是未装备的装备
		local set_type = nil
		local skill_level = nil
		local equipPosList = nil
		if isEquipStone then
			set_type = self:GetValue("set_type")
			skill_level = self:GetValue("skill_level")		
			equipLevel = self:GetValue("level")		
			equipPosList = {[1] = {pos = pos, level = equipLevel}}	
		else
			--身上的装备特效，要考虑套装触发等级
			sid = self.m_SData.equip_info.stone_sid or 0			
			set_type, skill_level, equipLevel = g_ItemCtrl:GetEuipSetTypeAndLevelBySid(sid)
			equipPosList = {[1] = {pos = pos, level = equipLevel}}	
			if set_type and skill_level then
				local d = data.itemdata.EQUIP_SET[set_type]
				if d then
					--根据部位，获取身上其他部位的装备，是否和该装备是同一套装
					for i, v in ipairs(d.pos_list) do
						if v ~= pos then
							local equipItem = g_ItemCtrl:GetEquipedByPos(v)
							if equipItem and equipItem.m_SData.equip_info.stone_sid then
								local t, slv, lv = g_ItemCtrl:GetEuipSetTypeAndLevelBySid(equipItem.m_SData.equip_info.stone_sid)
								if t == set_type then
									table.insert(equipPosList, {pos = v, level = lv})
								end								
							end						
						end
					end
				end
			end	
		end
		if set_type and set_type ~= 0 then
			--根据套装部位和身上装备的部位，获取套装触发字符串
			local function GetExitString(listSetPos, listEquipPos)
				local str = ""
				local isAll = true
				local minLevel = 100
				if not listSetPos and not next(listSetPos) or not listEquipPos or not next(listEquipPos) then
					return str, false, 0
				end
				local temp = {}
				for i, v in ipairs(listSetPos) do
					local t = {}
					t.keyName = define.Equip.PosName[v]
					t.isExit = false
					for _i, _v in ipairs(listEquipPos) do
						if minLevel > _v.level then
							minLevel = _v.level
						end						
						if v == _v.pos then
							t.isExit = true
						end
					end
					table.insert(temp, t)
				end
				if next(temp) then
					str = ColorOther .. "("
					for i, v in ipairs(temp) do
						if v.isExit then
							str = str.. ColorTrigger .. v.keyName
							if i + 1 <= #temp then
								str = str.. ColorOther.. "/"	
							else
								str = str.. ColorOther..")"
							end
						else
							isAll = false
							str = str.. ColorUnTrigger .. v.keyName
							if i + 1 <= #temp then
								str = str.. ColorOther .. "/"	
							else
								str = str.. ColorOther ..")"
							end
						end
					end						
				end
				return str, isAll, minLevel
			end
			--套装描述拼凑
			local d = data.itemdata.EQUIP_SET[set_type]
			if d then
				local str2 , isAll, minLevel = GetExitString(d.pos_list, equipPosList, uiMode)
				local setName = ""
				if data.itemdata.EQUIP_SET_NAME and data.itemdata.EQUIP_SET_NAME[minLevel] then
					setName = data.itemdata.EQUIP_SET_NAME[minLevel].name
				end
				local str1 = string.format("%s%s", setName, d.name)
				if isAll then
					str = ColorOther .. str1 .. str2 .."\n".. ColorTrigger .. g_SkillCtrl:GetEquipSkillSetDes(set_type, skill_level)
				else
					str = ColorOther .. str1 .. str2 .."\n" .. ColorUnTrigger .. g_SkillCtrl:GetEquipSkillSetDes(set_type, skill_level)
				end				
			end
		end 
	end
	return str
end

function CItem.GetEquipFuWenLevel(self, plan)
	local level = 0
	if  self:IsEquiped() then
		plan = plan or self.m_SData.equip_info.fuwen_plan
		if not plan then
			plan = 1
		end
		if self.m_SData.equip_info.fuwen[plan] then
			level = self.m_SData.equip_info.fuwen[plan].level or 0
		end
	end
	return level
end

function CItem.GetCanEequipLevel(self)
	local level = 0
	if self:GetValue("type") == define.Item.ItemType.EquipStone then
		level = self:GetValue("level")
		if level > g_AttrCtrl.grade then
			level = 0
		end

	elseif self:GetValue("type") == define.Item.ItemType.Equip then
		level = self:GetValue("equip_level")
		if level > g_AttrCtrl.grade then
			level = 0
		end
	end	
	return level
end

function CItem.GetGreateSelfEquipScore(self)
	local score = 0
	local pos
	if self:GetValue("type") == define.Item.ItemType.EquipStone or 
		self:GetValue("type") == define.Item.ItemType.Equip then
		pos = self:GetValue("pos")
	end	
	if pos then
		local equip = g_ItemCtrl:GetEquipedByPos(pos)
		if equip then
			local base_score = equip:GetEquipBaseScore()
			local target_score = self:GetEquipBaseScore()
			if target_score > base_score then
				score = 1000
			end
		end
	end

	return score
end

function CItem.GetItemIcon(self)
	if self:GetValue("type") == define.Item.ItemType.Equip then
		local ssid = self:GetEquipStoneSid()
		local d = data.itemdata.EQUIPSTONE[ssid]
		if d then
			return d.icon
		end
	else
		return self.m_CDataGetter()["icon"]
	end
end

function CItem.GetEquipStoneSid(self)
	local stoneSid = 0
	if self:GetValue("type") == define.Item.ItemType.Equip then
		if self.m_SData and self.m_SData.equip_info and self.m_SData.equip_info.stone_sid then
			stoneSid = self.m_SData.equip_info.stone_sid or 0
		end
	else
		stoneSid = self:GetValue("sid")
	end
	return stoneSid
end

--该伙伴符文是否能够升级
function CItem.IsPartnerEquipCanUpGrade(self)
	local b = false
	local dUpgradeData = self:GetValue("upgrade_item")
	if dUpgradeData then
		local iShape = dUpgradeData["sid"]
		local iNeedAmount = dUpgradeData["amount"] or 0
		local iAmount = g_ItemCtrl:GetBagItemAmountBySid(iShape) or 0
		local iCost = self:GetValue("upgrade_coin") or 0
		local bShow = (self:GetValue("level") or 0) < 10
		if bShow and g_AttrCtrl.coin >= iCost and iAmount >= iNeedAmount then
			b = true
		end
	end
	return b
end

function CItem.IsHasParEquipUpGradeRedPoint(self)
	if self.m_ParEquipUpGradeRedFlag then
		return false
	end
	return self:IsPartnerEquipCanUpGrade()
end

--该伙伴符文是否能够升星
function CItem.IsPartnerEquipCanUpStar(self)
	local b = false
	local dUpgradeData = self:GetValue("upstar_item")
	if dUpgradeData then
		local iShape = dUpgradeData["sid"]
		local iNeedAmount = dUpgradeData["amount"] or 0
		local iAmount = g_ItemCtrl:GetBagItemAmountBySid(iShape)
		local iCost = self:GetValue("upstar_coin") or 0
		local iStar = self:GetValue("star") or 0
		local bShow = (self:GetValue("level") or 0) >= 10
		if iStar ~= 6 and bShow and g_AttrCtrl.coin >= iCost and iAmount >= iNeedAmount then
			b = true
		end
	end
	return b
end

function CItem.IsHasParEquipUpStarRedPoint(self)
	if self.m_ParEquipUpStarRedFlag then
		return false
	end
	return self:IsPartnerEquipCanUpStar()
end

function CItem.GetParEquipUpStoneResult(self)
	local dData = data.partnerequipdata.ParEquip2Stone
	local dParStone2Count = data.partnerequipdata.ParStone2Count
	local iStar = self:GetValue("star")
	local iLevel = self:GetValue("level")
	local dUnLockList = dData[iStar]["unlock_stone"]
	local dStoneInfo = self:GetValue("stone_info") or {}
	local dLv2StoneList = {}
	for _, dStone in ipairs(dStoneInfo) do
		dLv2StoneList[dStone.pos] = dStone
	end
	local resultList = {}
	local iPos = self:GetValue("pos")
	for i = 1, 7 do
		if table.index(dUnLockList, i) then
			local dStoneList = dLv2StoneList[i]
			local bFlag = false
			if dStoneList then
				local iAmount = #dStoneList.sids
				local iNeedAmount = dParStone2Count[i]["inlay_count"]
				if iAmount < iNeedAmount then
					bFlag = true
				end
			else
				bFlag = true
			end
			local iShape = 300000 + iPos * 10000 + i
			if bFlag and g_ItemCtrl:GetBagItemAmountBySid(iShape) > 0 then
				table.insert(resultList, i)
			end
		else
			break
		end
	end
	if #resultList == 0 then
		return nil
	else
		return resultList
	end
end

function CItem.IsParEquipCanUpStone(self, bIgnorRedPoint)
	if self.m_ParEquipUpStoneRedFlag then
		return false
	end
	return self:GetParEquipUpStoneResult()
end

--获取伙伴装备 主属性数值
function CItem.GetPartnerEquipedMainAttrValue(self)
	local value = 0
	if self:IsPartnerEquip() then
		local t = self:GetPartnerEquipedMainAttrList()
		if t and #t > 0 then
			value = t[1][2]
		end
	end
	return value
end

--获取伙伴装备 属性列表
function CItem.GetPartnerEquipedMainAttrList(self)
	local t = {}
	if self:IsPartnerEquip() then
		local attr_info = self:GetValue("attr")
		if attr_info then
			local info = loadstring("return "..attr_info)()
			if info and table.count(info) > 0 then
				for key, value in pairs(info) do
					local attrname = data.partnerequipdata.EQUIPATTR[key]["name"]
					local attrvalue = ""
					if string.endswith(key, "_ratio") or key == "critical_damage" then
						attrvalue = self:GetPrintPecent(value)
					else
						attrvalue = value
					end
					table.insert(t, {attrname, attrvalue})
				end
			end
		end
	end
	return t
end

function CItem.GetItemStoneSid(self)
	local sid = 0
	if self.m_SData and self.m_SData.equip_info and self.m_SData.equip_info.stone_sid then
		sid = self.m_SData.equip_info.stone_sid
	else
		sid = self:GetValue("sid")
	end
	return sid
end

return CItem