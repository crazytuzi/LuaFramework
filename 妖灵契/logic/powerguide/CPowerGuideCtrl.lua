CPowerGuideCtrl = class("CPowerGuideCtrl", CCtrlBase)

function CPowerGuideCtrl.ctor(self)
	CCtrlBase.ctor(self)
	self:ResetAll()
end

--所有属性都有默认值
function CPowerGuideCtrl.ResetAll(self)
	self.m_Debug = false
	self.m_TabOpenCache = nil
	self.m_IsShowMainMenuRedDot = false
end

function CPowerGuideCtrl.GetPowerGuidTypeList(self, tab)
	local t = {}
	local d = data.powerguidedata.MENU
	if next(d) then
		for k, v in pairs(d) do
			if v.sort ~= 0 and tab == v.tab_index then
				table.insert(t, v)
			end			
		end
		table.sort(t, function(a, b)
			return a.sort < b.sort
		end)
	end
	return t
end	

function CPowerGuideCtrl.GetProgressValue(self, key, valueStr)
	local cur = 1
	local max = 1

	--printc(" >>>>>>>>>>>>>>>>> GetProgressValue  ", key)
	if key == "equip_all_strength_level" then
		max = tonumber(string.eval(valueStr, {lv=g_AttrCtrl.grade}))
		local level = 0
		for i = define.Equip.Pos.Weapon, define.Equip.Pos.Shoes do
			local oItem = g_ItemCtrl:GetEquipedByPos(i)
			if oItem then
				level = level + oItem:GetStrengthLevel()
			end
		end		
		cur = level

	elseif key == "equip_all_gem_level" then
		max = tonumber(valueStr)		
		local level = 0
		for i = define.Equip.Pos.Weapon, define.Equip.Pos.Shoes do
			local oItem = g_ItemCtrl:GetEquipedByPos(i)
			if oItem then
				local gems = oItem:GetEquipAttrGem()
				if gems and next(gems) then
					for k, v in pairs(gems) do
						local d = data.itemdata.GEM[v.sid]
						if d then
							level = level + d.level
						end
					end
				end				
			end
		end		
		cur = level

	elseif key == "fight_partner_all_level" then
		max = (g_AttrCtrl.grade + 5) * 4
		local list = g_PartnerCtrl:GetFightPartnerListBySort()
		local level = 0		
		for i = 1, 4 do
			local partner = list[i]
			if partner then
				level = partner:GetValue("grade") + level
			end
		end
		cur = level

	elseif key == "fight_partner_equip_all_level" then
		max = 96
		local list = g_PartnerCtrl:GetFightPartnerListBySort(1)
		local star = 0		
		for k, partner in pairs(list) do
			local oPartner = partner
			if oPartner then
				local equipList = oPartner:GetCurEquipInfo()
				if equipList and next(equipList) then
					for k, v in pairs(equipList) do
						local oItem = g_ItemCtrl:GetItem(v)
						if oItem then						
							star = star + oItem:GetValue("star")
						end
					end
				end
			end									
		end
		cur = star	

	elseif key == "fight_partner_all_awake" then
		max = 4
		cur = 0
		local list = g_PartnerCtrl:GetFightPartnerListBySort()
		local cnt = 0		
		for i = 1, 4 do
			local partner = list[i]
			if partner and partner:IsAwake() then
				cnt = cnt + 1
			end
		end
		cur = cnt

	elseif key == "equip_all_forge_fuwen" then
		max = 6
		local cnt = 0
		for i = define.Equip.Pos.Weapon, define.Equip.Pos.Shoes do
			local oItem = g_ItemCtrl:GetEquipedByPos(i)
			if oItem then
				local level = oItem:GetValue("equip_level")
				local quality = oItem:GetEquipFuWenQuality()
				local _, maxQuality = g_ItemCtrl:GetFuwenCanResetQuality(i, level)		
				if quality == maxQuality then
					cnt = cnt + 1
				end
			end
		end		
		cur = cnt

	elseif key == "equip_all_skill_point" then
		max = 400
		local total = 0
		local t = 
		{
			[1] = {point = 2, min = 1, max = 20},
			[2] = {point = 3, min = 21, max = 40},
			[3] = {point = 5, min = 41, max = 60},
			[4] = {point = 8, min = 61, max = 80},
			[5] = {point = 12, min = 81, max = 100},
		}
		local level = g_AttrCtrl.grade 
		local step = 1
		for i, v in ipairs(t) do
			if level >= v.min and level <= v.max then
				step = i 
				break
			end
		end
		if step > 1 then
			for i = 1, step - 1 do
				total = total + t[i].point * (t[i].max - t[i].min)
			end
			total = total + t[step].point * (level - t[step].min )
		else
			total = t[1].point * level
		end
		cur = math.min(400, total - g_AttrCtrl.skill_point)

	elseif key == "fight_partner_all_upgrade" then
		max = 20
		cur = 0
		local list = g_PartnerCtrl:GetFightPartnerListBySort()
		local star = 0		
		for i = 1, 4 do
			local partner = list[i]
			if partner then
				star = partner:GetValue("star") + star
			end
		end
		cur = star

	elseif key == "equip_all_suit" then
		max = 6
		cur = 0
		for i = define.Equip.Pos.Weapon, define.Equip.Pos.Shoes do
			local oItem = g_ItemCtrl:GetEquipedByPos(i)
			if oItem then
				if oItem:GetEquipSEString() ~= "无" then
					cur = cur + 1
				end
			end
		end		
	elseif key == "fight_partner_all_skill" then
		max = 1
		cur = 1
		local skMax = 0
		local skCur = 0
		local list = g_PartnerCtrl:GetFightPartnerListBySort()
		for i = 1, 4 do
			local partner = list[i]
			if partner then
				local t = partner:GetValue("skill")
				for i = 1, #t do
					local level = t[i].level
					local sk = t[i].sk
					local skM = data.powerguidedata.PARTNER_SKILL_MAX_LEVEL[sk] or level
					skCur = level + skCur
					skMax = skM + skMax
				end
			end
		end
		if skMax ~= 0 and skCur ~= 0 then
			max = skMax
			cur = skCur
		end

	elseif key == "fight_partner_all_yuling" then
		max = g_PartnerCtrl:GetUnlockSoulSoltCnt()
		cur = 0
		local list = g_PartnerCtrl:GetFightPartnerListBySort()
		for i = 1, 4 do
			local partner = list[i]
			if partner then
				local t = partner:GetEquipedSoulTable()
				cur = cur + #t
			end
		end

	elseif key == "fight_partner_all_stone" then
		max = 0
		cur = 0
		local list = g_PartnerCtrl:GetFightPartnerListBySort(1)	
		for k, partner in pairs(list) do
			local oPartner = partner
			if oPartner then
				local equipList = oPartner:GetCurEquipInfo()
				if equipList and next(equipList) then
					for _k, v in pairs(equipList) do
						local oItem = g_ItemCtrl:GetItem(v)
						if oItem then				
							local dData = data.partnerequipdata.ParEquip2Stone
							local iStar = oItem:GetValue("star")
							local dUnLockList = dData[iStar]["unlock_stone"]		
							local dStoneList = oItem:GetValue("stone_info") or {}
							local dLv2Stone = {}
							for _, dStone in ipairs(dStoneList) do
								dLv2Stone[dStone.pos] = dStone
							end							
							for i = 1, 7 do
								if table.index(dUnLockList, i) then
									if self:IsStoneInlayMax(i, table.index(dUnLockList, i), dLv2Stone[i], oItem:GetValue("pos")) then							
										cur = cur + 1
									end
									max = max + 1
								end
							end
						end
					end
				end
			end									
		end
		if max == 0 then
			cur = 0 
			max = 1
		end

	elseif key == "fight_partner_equip_dress" then
		max = 16
		cur = 0
		local list = g_PartnerCtrl:GetFightPartnerListBySort(1)	
		for k, partner in pairs(list) do
			local oPartner = partner
			if oPartner then
				local equipList = oPartner:GetCurEquipInfo()				
				if equipList and next(equipList) then
					cur = cur + table.count(equipList)
				end
			end									
		end

	end
	return cur / max, cur, max
end

function CPowerGuideCtrl.GetDefaultSelectId(self, tabIndex, isGuide)
	local id = 10001
	tabIndex = tabIndex or 1
	local menu = g_PowerGuideCtrl:GetPowerGuidTypeList(tabIndex)
	if menu and #menu > 0 then
		if isGuide and menu[1].main_type_list and menu[1].main_type_list[3] then
			id = menu[1].main_type_list[3]
			
		elseif menu[1].main_type_list and menu[1].main_type_list[1] then			
			id = menu[1].main_type_list[1]
		end	
	end
	return id
end

function CPowerGuideCtrl.GetSubMenuContentLis(sel, mainId)
	local temp1 = {}
	local temp2 = {}
	local d = data.powerguidedata.SUB
	for k, v in pairs(d) do
		if v.owner_menu == mainId and v.sort ~= 0 then
			if g_AttrCtrl.grade >= v.unlock_level then
				table.insert(temp1, v)
			else
				table.insert(temp2, v)
			end			
		end
	end

	if #temp1 > 1 then
		table.sort(temp1, function(a, b)			
			return a.sort < b.sort					
		end)
	end
	if #temp2 > 1 then
		table.sort(temp2, function(a, b)			
			return a.unlock_level < b.unlock_level						
		end)
	end	
	table.extend(temp1, temp2)
	return temp1
end

function CPowerGuideCtrl.SpecialGoto(self, special)
	local b = false
	if special == "partner_level_up" then
		local list = g_PartnerCtrl:GetFightPartnerListBySort(1)
		local oPartner = list[1]
		if oPartner then
			for i = 2, 4 do
				local oPar = list[i]
				if oPar then
					local oGrade = oPartner:GetValue("grade")
					local tGrade = oPar:GetValue("grade")
					if ( oGrade > tGrade) or (oGrade == tGrade and oPartner:GetValue("power") > oPar:GetValue("power") )then
						oPartner = oPar				
					end
				end
			end
		end		
		if oPartner then
			CPartnerImproveView:ShowView(function(oView)
				oView:OnChangePartner(oPartner:GetValue("parid"))
				oView:ShowUpGradePage()
			end)
			b = true
		else
			g_NotifyCtrl:FloatMsg("当前没有伙伴")
		end

	elseif special == "partner_star_up" then
		local oPartner 
		local list = g_PartnerCtrl:GetFightPartnerListBySort(1)
		for i = 1, 4 do
			local partner = list[i]
			if partner and partner:CanUpStar() then
				oPartner = partner 
				break
			end
		end 
		if not oPartner then
			oPartner = list[1]
		end
		if oPartner then
			CPartnerImproveView:ShowView(function(oView)
				oView:OnChangePartner(oPartner:GetValue("parid"))
				oView:ShowUpStarPage()
			end)
			b = true
		else
			g_NotifyCtrl:FloatMsg("当前没有伙伴")
		end

	elseif special == "partner_skill_up" then
		local oPartner 
		local list = g_PartnerCtrl:GetFightPartnerListBySort(2)
		for i = 1, 4 do
			local partner = list[i]
			if partner and partner:CanSkillUp() then
				oPartner = partner 
				break
			end
		end 
		if not oPartner then
			oPartner = list[1]
		end
		if oPartner then
			CPartnerImproveView:ShowView(function(oView)
				oView:OnChangePartner(oPartner:GetValue("parid"))
				oView:ShowUpSkillPage()
			end)
			b = true
		else
			g_NotifyCtrl:FloatMsg("当前没有伙伴")
		end

	elseif special == "partner_euqip_up" then
		local list = g_PartnerCtrl:GetFightPartnerListBySort(1)
		local oPartner
		local tItem 
		local type
		for i = 1, 4 do
			local oPar = list[i]
			if oPar then
				local info = oPar:GetCurEquipInfo()
				for i = 1, 4 do
					local itemId = info[i]
					if itemId then
						local oItem = g_ItemCtrl:GetItem(itemId)
						if oItem then
							if oItem:IsPartnerEquipCanUpGrade() then
								oPartner = oPar
								type = 1
								tItem =  oItem
								break
							elseif oItem:IsPartnerEquipCanUpStar() then
								oPartner = oPar
								type = 2
								tItem = oItem
								break
							end
						end
					end
				end
			end
		end
		if not oPartner then
			oPartner = list[1]
		end
		if oPartner then
			CPartnerMainView:ShowView(function(oView)
				oView:OnChangePartner(oPartner:GetValue("parid"))
				oView:ShowEquipPage()
				if tItem then
					if oView.m_PartnerEquipPage then
						if type == 2 then							
							oView.m_PartnerEquipPage:ShowUpStarPart(tItem)		
						else
							oView.m_PartnerEquipPage:ShowUpGradePart(tItem)		
						end						
					end			
				end				
			end)
			b = true
		else
			g_NotifyCtrl:FloatMsg("当前没有伙伴")
		end

		b = true

	elseif special == "partner_awake" then
		local oPartner 
		local list = g_PartnerCtrl:GetFightPartnerListBySort(1)
		for i = 1, 4 do
			local partner = list[i]
			if partner and partner:CanAwake() then
				oPartner = partner 
				break
			end
		end 
		if not oPartner then
			oPartner = list[1]
		end
		if oPartner then
			CPartnerImproveView:ShowView(function(oView)
				oView:OnChangePartner(oPartner:GetValue("parid"))
				oView:ShowAwakePage()
			end)
			b = true
		else
			g_NotifyCtrl:FloatMsg("当前没有伙伴")
		end

	elseif special == "partner_yuling" then
		local oPartner 
		local list = g_PartnerCtrl:GetFightPartnerListBySort(1)
		local maxCnt = g_PartnerCtrl:GetUnlockSoulSoltCnt(true)
		for i = 1, 4 do
			local partner = list[i]
			if partner then
				local t = partner:GetEquipedSoulTable()
				if #t < maxCnt then
					local SoulType = {}
					local soul_type = partner:GetValue("soul_type")				
					for k = 1, 6 do
						if t[k] then
							local oItem = g_ItemCtrl:GetItem(t[k].id)
							if oItem then
								SoulType[oItem:GetValue("attr_type")] = true
							end					
						end
					end
					local soulList = g_ItemCtrl:GetParSoulListBySoulType(soul_type)
					for i, v in ipairs(soulList) do
						if v:GetValue("parid") == 0 and SoulType[v:GetValue("attr_type")] == nil then
							oPartner = partner
							break
						end	
					end
					if oPartner then
						break
					end
				end
			end		
		end 
		if not oPartner then
			oPartner = list[1]
		end
		if oPartner then
			CPartnerMainView:ShowView(function(oView)
				oView:OnChangePartner(oPartner:GetValue("parid"))
				oView:ShowSoulPage()
			end)
			b = true
		else
			g_NotifyCtrl:FloatMsg("当前没有伙伴")
		end

	elseif special == "partner_stone" then
		local _, oPartner, oItem = self:IsRedPartAllStone()
		local list = g_PartnerCtrl:GetFightPartnerListBySort(1)
		if not oPartner then
			oPartner = list[1]
		end
		if oPartner then
			CPartnerMainView:ShowView(function(oView)
				oView:OnChangePartner(oPartner:GetValue("parid"))
				oView:ShowEquipPage()
				if oItem then
					if oView.m_PartnerEquipPage then
						oView.m_PartnerEquipPage:ShowUpStonePart(oItem:GetValue("pos"))		
					end							
				end				
			end)
			b = true
		else
			g_NotifyCtrl:FloatMsg("当前没有伙伴")
		end

	elseif special == "partner_euqip_dress" then
		local _, oPartner, pos = self:IsRedPartAllEquipDress()
		local list = g_PartnerCtrl:GetFightPartnerListBySort(1)
		if not oPartner then
			oPartner = list[1]
		end
		if oPartner then
			CPartnerMainView:ShowView(function(oView)
				oView:OnChangePartner(oPartner:GetValue("parid"))
				oView:ShowEquipPage()
			end)
			b = true
		else
			g_NotifyCtrl:FloatMsg("当前没有伙伴")
		end
	end
	return b
end

function CPowerGuideCtrl.ResetCtrl(self)
	self:ResetAll()
end

function CPowerGuideCtrl.GetPowerProgress(self)
	local cur = g_AttrCtrl:GetTotalPower()
	local max = 0
	--本地获取战力成就上限
	local t = {}
	local d = data.achievedata.ACHIEVE 
	if d and next(d) then
		for k, v in pairs(d) do
			if string.find(v.desc, "战力达到") then
				table.insert(t, v)
			end
		end
	end
	if #t > 1 then
		table.sort(t, function (a, b)
			return a.id < b.id
		end)		
	end	
	for i = 1, #t do
		if cur < t[i].condition then
			max = t[i].condition
			break
		end
	end
	if max == 0 then
		max = t[#t].condition
	end

	return cur, max
end

function CPowerGuideCtrl.GetFightGuideList(self, mainId)
	local t
	local d = data.powerguidedata.MAIN[mainId]
	if d and next(d.fight_list) then
		t = d.fight_list
	end
	return t
end

function CPowerGuideCtrl.IsPowerHeroRedDot(self)
	local b = false 
	local temp = data.powerguidedata.SUB
	local t = {}
	for k, v in pairs(temp) do
		if v.owner_menu == 1001 then
			table.insert(t, v)
		end
	end
	if next(t) then
		for i,v in ipairs(t) do
			local percent = self:GetProgressValue(v.key, v.progress)
			if percent ~= 1 then
				if v.red_func ~= "" and self[v.red_func] then
					local isRed = self[v.red_func]()
					if isRed == true then
						b = true
						break
					end
				end
			end
		end
	end
	return b
end

function CPowerGuideCtrl.IsRedStrengthLevel(self)
	local b = false
	b = g_ItemCtrl:ShowForgeRedDotByStrength()
	return b
end

function CPowerGuideCtrl.IsRedGemLevel(self)
	local b = false
	b = g_ItemCtrl:ShowForgeRedDotByGem()
	return b
end

function CPowerGuideCtrl.IsRedForgeFuwen(self)
	local b = false
	b = g_ItemCtrl:ShowForgeRedDotByFuwen()
	return b
end

function CPowerGuideCtrl.IsRedSkillPoint(self)
	local b = false
	b = g_SkillCtrl:IsCanLevelUp()
	return b
end

function CPowerGuideCtrl.IsRedEquipSuit(self)
	local b = false
	b = g_ItemCtrl:ShowForgeRedDotByComposite()
	return b
end

function CPowerGuideCtrl.IsRedPartEquipLevel(self)
	local b = false
	local list = g_PartnerCtrl:GetFightPartnerListBySort()
	for i = 1, 4 do
		local oPartner = list[i]
		if oPartner then
			local info = oPartner:GetCurEquipInfo()
			for i = 1, 4 do
				local itemId = info[i]
				if itemId then
					local oItem = g_ItemCtrl:GetItem(itemId)
					if oItem then
						if oItem:IsPartnerEquipCanUpGrade() or oItem:IsPartnerEquipCanUpStar() then
							return true
						end
					end
				end
			end
		end
	end
	return b
end



function CPowerGuideCtrl.IsRedPartAllLevel(self)
	local b = false
	local cnt = g_ItemCtrl:GetTargetItemCountBySid(14001)
	local list = g_PartnerCtrl:GetFightPartnerListBySort()
	for i = 1, 4 do
		local oPartner = list[i]
		if oPartner then
			local curexp = oPartner:GetCurExp()
	  		local needexp = oPartner:GetNeedExp()
	  		if cnt > ((needexp-curexp) / 2000) then
	  			b = true
	  			break
	  		end
		end
	end
	return b
end

function CPowerGuideCtrl.IsRedPartAllAwake(self)
	local b = false
	local list = g_PartnerCtrl:GetFightPartnerListBySort()
	for i = 1, 4 do
		local partner = list[i]
		if partner and partner:CanAwake() then
			b = true
			break
		end
	end 
	return b
end

function CPowerGuideCtrl.IsRedPartAllUpgrade(self)
	local b = false
	local list = g_PartnerCtrl:GetFightPartnerListBySort()
	for i = 1, 4 do
		local partner = list[i]
		if partner and partner:CanUpStar() then
			b = true
			break
		end
	end 
	return b
end


function CPowerGuideCtrl.IsRedPartAllSkill(self)
	local b = false
	local list = g_PartnerCtrl:GetFightPartnerListBySort()
	for i = 1, 4 do
		local partner = list[i]
		if partner and partner:CanSkillUp() then
			b = true
			break
		end
	end 
	return b
end

function CPowerGuideCtrl.IsRedPartAllEquipDress(self)
	local b = false
	local partner = nil
	local iPos = nil
	local list = g_PartnerCtrl:GetFightPartnerListBySort(1)
	local bagEquipList = g_ItemCtrl:GetPartnerUnEquipedEquip()	
	if bagEquipList and #bagEquipList > 1 then
		table.sort(bagEquipList, function (a, b)
			return a:GetValue("pos") > b:GetValue("pos")
		end)
	end
	for i = 1, 4 do
		local oPartner = list[i]
		if oPartner then
			local tPos
			local tItem 
			local equipList = oPartner:GetCurEquipInfo()	
			for i, v in ipairs(bagEquipList) do
				local pos = v:GetValue("pos")
				if tPos ~= pos then
					tPos = pos
					if equipList[pos] then
						tItem = g_ItemCtrl:GetItem(equipList[pos])
					else						
						return true, oPartner, pos
					end									
				end				
				if tItem:GetPartnerEquipedMainAttrValue() < v:GetPartnerEquipedMainAttrValue() then
					return true, oPartner, pos
				end		
			end
		end	
	end 
	return b
end

function CPowerGuideCtrl.IsRedPartAllStone(self)
	local b = false
	local list = g_PartnerCtrl:GetFightPartnerListBySort(1)	
	for k, partner in pairs(list) do
		local oPartner = partner
		if oPartner then
			local equipList = oPartner:GetCurEquipInfo()
			if equipList and next(equipList) then
				for _k, v in pairs(equipList) do
					local oItem = g_ItemCtrl:GetItem(v)
					if oItem then				
						local dData = data.partnerequipdata.ParEquip2Stone
						local iStar = oItem:GetValue("star")
						local dUnLockList = dData[iStar]["unlock_stone"]		
						local dStoneList = oItem:GetValue("stone_info") or {}
						local dLv2Stone = {}
						for _, dStone in ipairs(dStoneList) do
							dLv2Stone[dStone.pos] = dStone
						end
						for i = 1, 7 do
							if self:IsStoneCanUp(i, table.index(dUnLockList, i), dLv2Stone[i], oItem:GetValue("pos")) then							
								return true, oPartner, oItem
							end
						end
					end
				end
			end
		end									
	end
	return b
end

function CPowerGuideCtrl.IsStoneCanUp(self, iLevel, bUnLock, dStone, iPos)
	local b = false
	local iShape = 300000 + iPos * 10000 + iLevel
	local dStoneData = data.itemdata.PAR_STONE[iShape]
	local dParStone2Count = data.partnerequipdata.ParStone2Count
	if not dStoneData then
		return false
	end
	if bUnLock then
		local iAmount = 0
		if dStone and next(dStone) then
			iAmount = #dStone.sids
		end	
		local iNeedAmount = dParStone2Count[iLevel]["inlay_count"]
		local iCnt = g_ItemCtrl:GetTargetItemCountBySid(iShape)
		if iAmount < iNeedAmount and iCnt > 0 then
			b = true
		end
	end
	return b
end

function CPowerGuideCtrl.IsStoneInlayMax(self, iLevel, bUnLock, dStone, iPos)
	local b = false
	local iShape = 300000 + iPos * 10000 + iLevel
	local dStoneData = data.itemdata.PAR_STONE[iShape]
	local dParStone2Count = data.partnerequipdata.ParStone2Count
	if not dStoneData then
		return false
	end
	if bUnLock then
		local iAmount = 0
		if dStone and next(dStone) then
			iAmount = #dStone.sids
		end	
		local iNeedAmount = dParStone2Count[iLevel]["inlay_count"]
		if iAmount >= iNeedAmount then
			b = true
		end
	end
	return b
end

function CPowerGuideCtrl.IsRedPartAllYuLing(self)
	local b = false
	local list = g_PartnerCtrl:GetFightPartnerListBySort()
	local maxCnt = g_PartnerCtrl:GetUnlockSoulSoltCnt(true)
	for i = 1, 4 do
		local partner = list[i]
		if partner then
			local t = partner:GetEquipedSoulTable()
			if #t < maxCnt then
				local SoulType = {}
				local soul_type = partner:GetValue("soul_type")				
				for k = 1, 6 do
					if t[k] then
						local oItem = g_ItemCtrl:GetItem(t[k].id)
						if oItem then
							SoulType[oItem:GetValue("attr_type")] = true
						end					
					end
				end
				local soulList = g_ItemCtrl:GetParSoulListBySoulType(soul_type)				
				for i, v in ipairs(soulList) do					
					if v:GetValue("parid") == 0 and SoulType[v:GetValue("attr_type")] == nil then
						return true
					end	
				end
			end
		end		
	end 
	return b
end

function CPowerGuideCtrl.IsPowerPartnerRedDot(self)
	local b = false 
	local temp = data.powerguidedata.SUB
	local t = {}
	for k, v in pairs(temp) do
		if v.owner_menu == 1002 then
			table.insert(t, v)
		end
	end
	if next(t) then
		for i,v in ipairs(t) do
			local percent = self:GetProgressValue(v.key, v.progress)
			if percent ~= 1 then
				if v.red_func ~= "" and self[v.red_func] then
					local isRed = self[v.red_func](self)
					if isRed == true then
						b = true
						break
					end
				end
			end
		end
	end
	return b
end

return CPowerGuideCtrl