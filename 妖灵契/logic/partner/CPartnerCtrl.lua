local CPartnerCtrl = class("CPartnerCtrl", CCtrlBase)

define.Partner = {
	Event = {
		LoginInit = 1,
		PartnerAdd = 2,
		DelPartner = 3,
		FightChange = 4,
		AddBullet = 5,
		UpdatePartner = 6,
		UpdateChip = 7,
		UpdateAwakeItem = 8,
		UpdateChoukaConfig = 9,
		UpdateRedPoint = 10,
		AddSoulPlan = 11,
		DelSoulPlan = 12,
		UpdateSoulPlan = 13,
	},
	Rare = {
		N = 1,
		R = 2,
		SR = 3,
		SSR = 4,
	},
	PrintRare = {
		[1] = "[c8c8c8]N[-]",
		[2] = "[34c8f4]R[-]",
		[3] = "[e110fa]SR[-]",
		[4] = "[fab310]SSR[-]",
	},
	State = {
		InWar = 1,
		AlreadyWar =2,
		Died = 3,
	},
	CardColor = {
		[1] = "zi",
		[2] = "jin",
		[3] = "zi",
		[4] = "zi",
	},
	Pos = {
		Main = 1,
		SubOne = 2,
		SubTwo = 3,
		SubThree = 4,
	},
	AttrLevel = {
		[1] = "[fe8900]S[-]",
		[2] = "[c451ff]A[-]",
		[3] = "[518aff]B[-]",
		[4] = "[27e0bb]C[-]",
		[5] = "[8c8c8c]D[-]",
	},
	ParEquip = {
		MaxLevel = 10,
		MaxStar = 6,
	},
}

function CPartnerCtrl.ctor(self)
	CCtrlBase.ctor(self)
	self.m_Partners = {}
	self.m_FightInfo = {}
	self.m_ChipInfo = {}
	self.m_Partner2Chip = {}
	self.m_AwakeItems = {}
	self.m_PartnerGuideList = {}
	self.m_EquipGuideList = {}
	self.m_PartnerPhoto = {}
	self.m_ChoukaConfig = {}
	self.m_HireData = {}
	self.m_SoulPlanInfo = {}
	self:InitChipInfo()
end

--bIgnoreBaozi true：忽略包子
function CPartnerCtrl.GetPartnerList(self, bIgnoreBaozi)
	local list = table.values(self.m_Partners)
	if bIgnoreBaozi then
		list = self:GetIgnoreBaoziPartnerList(list)
	end
	return list
end

function CPartnerCtrl.GetIgnoreBaoziPartnerList(self, list)
	return list
end

function CPartnerCtrl.GetFightList(self)
	return self.m_FightInfo
end

function CPartnerCtrl.GetFightPartnerCnt(self)
	local i = 0 
	for k, v in pairs(self.m_FightInfo) do
		i = i + 1
	end
	return i
end

function CPartnerCtrl.CommonSortFunc(self, oPartner1, oPartner2)
	local pos1 = self:GetFightPos(oPartner1:GetValue("parid")) or 9999
	local pos2 = self:GetFightPos(oPartner2:GetValue("parid")) or 9999
	if pos1 ~= pos2 then
		return pos1 < pos2
	end
	local iRare1 = oPartner1:GetValue("rare")
	local iRare2 = oPartner2:GetValue("rare")
	if iRare1 and iRare2 and iRare1 ~= iRare2 then
		return oPartner1:GetValue("rare") < oPartner2:GetValue("rare")
	end
	return oPartner1:GetValue("parid") < oPartner2:GetValue("parid")
end

function CPartnerCtrl.IsFight(self, parid)
	for k, v in pairs(self.m_FightInfo) do
		if v.parid == parid then
			return true
		end
	end
	return false
end

function CPartnerCtrl.GetMainFightPartner(self)
	return self:GetPartnerByFightPos(define.Partner.Pos.Main)
end

function CPartnerCtrl.GetPartnerByFightPos(self, pos)
	local dInfo = self.m_FightInfo[pos]
	if dInfo then
		return self:GetPartner(dInfo.parid)
	end
end

function CPartnerCtrl.GetFightPos(self, parid)
	for k, v in pairs(self.m_FightInfo) do
		if v.parid == parid then
			return v.pos
		end
	end
end

function CPartnerCtrl.ResetCtrl(self)
	self.m_Partners = {}
	self.m_FightInfo = {}
	self.m_ChipInfo = {}
	self.m_Partner2Chip = {}
	self.m_AwakeItems = {}
	self.m_PartnerGuideList = {}
	self.m_EquipGuideList = {}
	self.m_PartnerPhoto = {}
	self.m_ChoukaConfig = {}
	self.m_SoulPlanInfo = {}
	self:InitChipInfo()
end

function CPartnerCtrl.LoginInit(self, lFightInfo, lChipInfo)
	for i, dFightInfo in pairs(lFightInfo) do
		self.m_FightInfo[dFightInfo.pos] = dFightInfo
	end
	
	self:OnEvent(define.Partner.Event.LoginInit)
	self:AddItemCtrl()
end

function CPartnerCtrl.LoginPartnerList(self, lPartners)
	for i, dPartner in pairs(lPartners) do
		self.m_Partners[dPartner.parid] = CPartner.New(dPartner)
	end
end

function CPartnerCtrl.InitChipInfo(self)
	self.m_ChipInfo = {}
	for i, dChipInfo in pairs(data.itemdata.PARTNER_CHIP) do
		self.m_ChipInfo[i] = 0
		self.m_Partner2Chip[dChipInfo.partner_type] = i
	end
end

function CPartnerCtrl.InitAwakeItems(self, lAwakeItems)
	self.m_AwakeItems = {}
	for k, v in pairs(lAwakeItems) do
		self.m_AwakeItems[v["sid"]] = v
	end
end

function CPartnerCtrl.InitPartnerGuide(self, owned_partner_list, owned_equip_list)
	self.m_PartnerGuideList = owned_partner_list
	self.m_EquipGuideList = owned_equip_list
end

function CPartnerCtrl.InitSoulPlan(self, dSoulList)
	for _, soulObj in ipairs(dSoulList) do
		self.m_SoulPlanInfo[soulObj.idx] = soulObj
	end
end

function CPartnerCtrl.AddPartner(self, dPartner)
	local oPartner = CPartner.New(dPartner)
	self.m_Partners[dPartner.parid] = oPartner
	self:UpdatePartnerGuide(oPartner:GetValue("partner_type"))
	self:OnEvent(define.Partner.Event.PartnerAdd, {dPartner.parid})
end

function CPartnerCtrl.AddPartnerList(self, lPartners)
	local updatelist = {}
	for i, dPartner in pairs(lPartners) do
		local oPartner = CPartner.New(dPartner)
		self.m_Partners[dPartner.parid] = oPartner
		self:UpdatePartnerGuide(oPartner:GetValue("partner_type"))
		table.insert(updatelist, dPartner.parid)
	end
	self:OnEvent(define.Partner.Event.PartnerAdd, updatelist)
end

function CPartnerCtrl.DelPartner(self, del_list)
	for k, parid in pairs(del_list) do
		self.m_Partners[parid] = nil
	end
	self:OnEvent(define.Partner.Event.DelPartner, del_list)
end

function CPartnerCtrl.UpdatePartner(self, parid, dPartner)
	local oPower = g_AttrCtrl:GetPartPower() + g_AttrCtrl.power
	if self.m_Partners[parid] then
		self.m_Partners[parid]:UpdateProp(dPartner)
		self:OnEvent(define.Partner.Event.UpdatePartner, parid)
	end
	local nPower = g_AttrCtrl:GetPartPower() + g_AttrCtrl.power
	g_ItemCtrl:ShowAttrChangeAttrTips({power=oPower}, {power=nPower})
end

function CPartnerCtrl.AddSoulPlan(self, dSoulObj)
	self.m_SoulPlanInfo[dSoulObj.idx] = dSoulObj
	self:OnEvent(define.Partner.Event.AddSoulPlan, dSoulObj.idx)
end

function CPartnerCtrl.DelSoulPlan(self, idx)
	self.m_SoulPlanInfo[idx] = nil
	self:OnEvent(define.Partner.Event.DelSoulPlan, idx)
end

function CPartnerCtrl.UpdateSoulPlan(self, dSoulObj)
	self.m_SoulPlanInfo[dSoulObj.idx] = dSoulObj
	self:OnEvent(define.Partner.Event.UpdateSoulPlan, dSoulObj.idx)
end

function CPartnerCtrl.GetSoulPlan(self, idx)
	return self.m_SoulPlanInfo[idx]
end

function CPartnerCtrl.GetSoulPlanList(self)
	local dList = {}
	for _, v in pairs(self.m_SoulPlanInfo) do
		table.insert(dList, v)
	end
	table.sort(dList, function (a, b)
		return a.idx < b.idx
	end)
	return dList
end

function CPartnerCtrl.GetPartner(self, parid)
	return self.m_Partners[parid]
end

function CPartnerCtrl.GetPartners(self)
	return self.m_Partners
end

function CPartnerCtrl.IsHavePartner(self, partner_type)
	for parid, oPartner in pairs(self.m_Partners) do
		if oPartner:GetValue("partner_type") == partner_type then
			return true
		end
	end
	return false
end

function CPartnerCtrl.SetFightInfo(self, dFightInfo)
	local oPower = g_AttrCtrl:GetPartPower() + g_AttrCtrl.power
	self.m_FightInfo[dFightInfo.pos] = dFightInfo
	if self.m_FightTimer then
		Utils.DelTimer(self.m_FightTimer)
	end
	local nPower = g_AttrCtrl:GetPartPower() + g_AttrCtrl.power
	local function delay() 
		g_ItemCtrl:ShowAttrChangeAttrTips({power=oPower}, {power=nPower})
		self:OnEvent(define.Partner.Event.FightChange, dFightInfo)
	end
	self.m_FightTimer = Utils.AddTimer(delay, 0, 0.2)
end

function CPartnerCtrl.GetSingleChipInfo(self, chiptype)
	local oItem = nil
	if not self.m_ChipInfo[chiptype] or self.m_ChipInfo[chiptype] == 0 then
		local itemList = g_ItemCtrl:GetItemIDListBySid(chiptype)
		if itemList[1] then
			self.m_ChipInfo[chiptype] = itemList[1]
		end
	else
		oItem = g_ItemCtrl:GetItem(self.m_ChipInfo[chiptype])
		if not oItem then
			local itemList = g_ItemCtrl:GetItemIDListBySid(chiptype)
			if itemList[1] then
				self.m_ChipInfo[chiptype] = itemList[1]
			end
		end
	end
	oItem = g_ItemCtrl:GetItem(self.m_ChipInfo[chiptype])
	if not oItem then
		oItem = CItem.NewBySid(chiptype)
		oItem:SetValue("amount", 0)
		oItem:SetValue("create_time", 0)
	end
	return oItem
end

function CPartnerCtrl.GetChipByPartner(self, iPartner)
	return self.m_Partner2Chip[iPartner]
end

function CPartnerCtrl.GetChipByRare(self, iRare)
	local list = {}
	for chiptype, _ in pairs(self.m_ChipInfo) do
		local oItem = self:GetSingleChipInfo(chiptype)
		if oItem:GetValue("show_type") == 0 then
			--continue
		elseif iRare == oItem:GetValue("rare") then
			table.insert(list, oItem)
		elseif iRare == 0 then
			table.insert(list, oItem)
		end
	end
	return list
end

--获取碎片左上角品质小图标
function CPartnerCtrl.GetChipMarkSpriteName(self, rare)
	local filename = define.Partner.CardColor[rare] or "hui"
	return string.format("pic_suipian_%sse", filename)
end

--获取碎片品质底框
function CPartnerCtrl.GetRareBorderSpriteName(self, rare)
	local filename = define.Partner.CardColor[rare] or "hui"
	return string.format("bg_haoyoukuang_%sse", filename)
end

--获取许愿可得到的伙伴碎片数
function CPartnerCtrl.GetWishCount(self, rare)
	if data.orgdata.Wish[rare] then
		return data.orgdata.Wish[rare].amount
	else
		return 0
	end
end

function CPartnerCtrl.GetAwakeItemAmount(self, sid)
end

function CPartnerCtrl.RefreshAwakeItem(self, dAwakeItems)

end

--bIgnoreBaozi true：忽略包子
function CPartnerCtrl.GetPartnerByRare(self, iRare, bIgnoreBaozi)
	local list = {}
	for i, oPartner in pairs(self.m_Partners) do
		if iRare == oPartner:GetValue("rare") then
			table.insert(list, oPartner)
		elseif iRare == 0 then
			table.insert(list, oPartner)
		end
	end
	if bIgnoreBaozi then
		list = self:GetIgnoreBaoziPartnerList(list)
	end
	return list
end

function CPartnerCtrl.GetPartnerByStar(self, iStar, bIgnoreBaozi)
	local list = {}
	for i, oPartner in pairs(self.m_Partners) do
		if iStar == oPartner:GetValue("star") then
			table.insert(list, oPartner)
		elseif iStar == 0 then
			table.insert(list, oPartner)
		end
	end
	if bIgnoreBaozi then
		list = self:GetIgnoreBaoziPartnerList(list)
	end
	return list
end

function CPartnerCtrl.GetPartnerByType(self, iParType)
	for i, oPartner in pairs(self.m_Partners) do
		if oPartner:GetValue("partner_type") == iParType then
			return oPartner
		end
	end
end

function CPartnerCtrl.GetChipList(self)
	-- body
end

function CPartnerCtrl.GetRareText(self, iRare)
	if iRare == 1 then
		return "精英"
	else
		return "传说"
	end
end

function CPartnerCtrl.GetPrintRareText(self, iRare)
	return define.Partner.PrintRare[iRare]
end

function CPartnerCtrl.AddBullet(self, send_id, content)
	local oMsg = {
		send_id = send_id,
		content = content,
	}
	self:OnEvent(define.Partner.Event.AddBullet, oMsg)
end

function CPartnerCtrl.C2GSPartnerFight(self, tPos, tParid)
	local level = 5
	if g_AttrCtrl.grade < level then
		g_NotifyCtrl:FloatMsg(string.format("达到%d级之后，开放此功能", level))
		return
	end

	local myPos = self:GetFightPos(tParid)
	--该伙伴，已经上阵
	if myPos ~= nil then
		--如果交换的位置和该伙伴的位置，则说明是下阵该伙伴
		if myPos == tPos then
			if tPos == define.Partner.Pos.Main then
				g_NotifyCtrl:FloatMsg("不能下阵主战伙伴")
			else
				netpartner.C2GSPartnerFight({ pos = tPos, parid = tParid })	
			end
			
		else
			local oPartnerInfo = self:GetPartnerByFightPos(tPos)
			--交换的位置，已经有伙伴，需要交换
			if oPartnerInfo ~= nil then				
				netpartner.C2GSPartnerSwitch({ { pos = myPos,  parid = oPartnerInfo:GetValue("parid") }, { pos = tPos, parid = tParid } })

			--交换的位置，未有伙伴，需要交换
			else
				if myPos == define.Partner.Pos.Main then
					g_NotifyCtrl:FloatMsg("不能下阵主战伙伴")
				else
					netpartner.C2GSPartnerSwitch({{ pos = myPos,  parid = 0}, { pos = tPos, parid = tParid } })
				end				

			end				
		end

	--该伙伴，未上阵
	else		
		local oPartnerInfo = self:GetPartnerByFightPos(tPos)
		--交换的位置，已经有伙伴，直接上阵
		if oPartnerInfo ~= nil then
			netpartner.C2GSPartnerFight({ pos = tPos, parid = tParid })

		--交换的位置，未有伙伴，直接上阵
		else
			netpartner.C2GSPartnerFight({ pos = tPos, parid = tParid })

		end
	end
end

function CPartnerCtrl.ChangeRareBorder(self, spr, rare)
	local filename = define.Partner.CardColor[rare] or "hui"
	spr:SetSpriteName("bg_haoyoukuang_"..filename.."se")
end

function CPartnerCtrl.IsGetPartner(self, parid)
	return table.index(self.m_PartnerGuideList, parid)
end

--获取获得过的伙伴符文
function CPartnerCtrl.GetGetPartnerEquip(self)
	return self.m_EquipGuideList
end

function CPartnerCtrl.UpdatePartnerGuide(self, parid)
	if not table.index(self.m_PartnerGuideList, parid) then
		table.insert(self.m_PartnerGuideList, parid)
	end
end

function CPartnerCtrl.UpdatePartnrEquipGuide(self, oItem)
	if oItem:IsPartnerEquip() then
		if not table.index(self.m_EquipGuideList, oItem:GetValue("sid")) then
			table.insert(self.m_EquipGuideList, oItem:GetValue("sid"))
		end
	end
end

--图鉴照片
function CPartnerCtrl.UpdatePartnerPhoto(self, list)
	table.sort(list, function(a, b)
		if a["shape"] < b["shape"] then
			return true
		end
		return false
	end)
	self.m_PartnerPhoto = list
end

function CPartnerCtrl.GetPartnerPhoto(self)
	return self.m_PartnerPhoto
end

--免费抽卡CD
function CPartnerCtrl.ResetChoukaConfig(self)
	if self.m_ChoukaConfig["timer"] then
		Utils.DelTimer(self.m_ChoukaConfig["timer"])
	end
	self.m_ChoukaConfig = {}
end

function CPartnerCtrl.SetChoukaConfig(self, freecd, cost, mulcost, baodi)
	self.m_ChoukaConfig["freecd"] = freecd
	self.m_ChoukaConfig["cost"] = cost
	self.m_ChoukaConfig["mulcost"] = mulcost
	self.m_ChoukaConfig["baodi"] = baodi or 0
	self:OnEvent(define.Partner.Event.UpdateChoukaConfig)
	local iTime = self:GetChoukaFreeCD() - g_TimeCtrl:GetTimeS()
	if self.m_ChoukaConfig["timer"] then
		Utils.DelTimer(self.m_ChoukaConfig["timer"])
	end
	self.m_ChoukaConfig["timer"] = nil
	if iTime > 0 then
		self.m_ChoukaConfig["timer"] = Utils.AddTimer(function ()
			self:OnEvent(define.Partner.Event.UpdateChoukaConfig)
		end, 0, iTime)
	end
end

function CPartnerCtrl.GetChoukaFreeCD(self)
	return self.m_ChoukaConfig["freecd"] or 0
end

function CPartnerCtrl.GetChoukaCost(self)
	return self.m_ChoukaConfig["cost"]
end

function CPartnerCtrl.GetChoukaMulCost(self)
	return self.m_ChoukaConfig["mulcost"]
end

function CPartnerCtrl.GetBaodiTimes(self)
	return self.m_ChoukaConfig["baodi"]
end

function CPartnerCtrl.IsChoukaFree(self)
	return (g_TimeCtrl:GetTimeS() - self:GetChoukaFreeCD()) > 0
end

--获取伙伴的皮肤列表
function CPartnerCtrl.GetPartnerSkin(self, partner_type)
	local list = {}
	for _, v in pairs(data.itemdata.PARTNER_SKIN) do
		if v.partner_type == partner_type then
			table.insert(list, v)
		end
	end
	table.sort(list, function(d1,d2) return d1.id < d2.id end)
	return list
end

--获取一个叫重华的伙伴(取战力最高的那个)
function CPartnerCtrl.GetPartnerByName(self, name)
	local list = self:GetPartnerList()
	local t = {}
	for parid, oPartner in pairs(list) do
		if oPartner:GetValue("name") == name then
			table.insert(t, oPartner)
		end
	end
	if #t > 1 then
		table.sort(t, function (a, b)
			return a:GetValue("power") > b:GetValue("power")
		end)
	end
	return t[1]
end

--获取可合成的伙伴碎片sid
function CPartnerCtrl.GetCanComposePanterChipSid(self)
	for sid, _ in pairs(data.itemdata.PARTNER_CHIP) do
		local chipinfo = g_PartnerCtrl:GetSingleChipInfo(sid)
		if chipinfo then
			local haveAmount = chipinfo:GetValue("amount")
			local needAmount = chipinfo:GetValue("compose_amount")
			if haveAmount >= needAmount then
				return sid
			end
		end
	end
end

--获取一个非5星的伙伴
function CPartnerCtrl.GetPartnerUnFiveStar(self)
	local p = nil
	if next(self.m_Partners) then
		for k, v in pairs(self.m_Partners) do
			if v:GetValue("star") < 5 then
				return v
			end
		end
	end
	return	p
end

function CPartnerCtrl.GetOuQiBuff(self, oid)
	local t = g_TimeCtrl:GetTimeS()
	if self.m_OQTime and t - self.m_OQTime < 1 then
		g_NotifyCtrl:FloatMsg("你的操作过于频繁")
		return
	else
		netpartner.C2GSGetOuQi(oid)
		self.m_OQTime = t
	end
end

function CPartnerCtrl.SetFollower(self, oPartner, bFollow)
	if not oPartner then
		return
	end
	local titleList = g_TitleCtrl:GetPartnerTitle(oPartner:GetValue("partner_type"))
	local titleObj = titleList[1]
	if titleObj then
		netpartner.C2GSSetFollowPartner(oPartner.m_ID, titleObj)
	else
		netpartner.C2GSSetFollowPartner(oPartner.m_ID)
	end
end

function CPartnerCtrl.IsTestMode(self)
	return true
end

--招募相关
function CPartnerCtrl.InitHireData(self, dHireList)
	self.m_HireData = {}
	for _, v in ipairs(dHireList) do
		self.m_HireData[v.parid] = v.times
	end
end

function CPartnerCtrl.UpdateHireData(self, iParID, iTimes)
	self.m_HireData[iParID] = iTimes
end

function CPartnerCtrl.GetHireData(self)
	return self.m_HireData
end

function CPartnerCtrl.GetHireTime(self, iParID)
	return self.m_HireData[iParID] or 0
end

--按战力前的伙伴获取伙伴列表
function CPartnerCtrl.GetPartnerListSortByPower(self)
	local list = self:GetPartnerList(true)
	local t = {}
	for k, v in pairs(list) do
		table.insert(t, v)
	end
	if #t > 1 then
		table.sort(t, function (a, b)
			return a:GetValue("power") > b:GetValue("power")
		end)
	end	
	return t
end

--按战力前的伙伴获取伙伴列表
function CPartnerCtrl.GetPartnerListSortByPower(self)
	local list = self:GetPartnerList(true)
	local t = {}
	for k, v in pairs(list) do
		table.insert(t, v)
	end
	if #t > 1 then	
		table.sort(t, function (a, b)
			return a:GetValue("power") > b:GetValue("power")
		end)
	end	
	return t
end

--获取战力前4的4个伙伴
--排序方式
--排序类型
function CPartnerCtrl.GetFightPartnerListBySort(self, sort, sortType)
	sort = sort or 2
	sortType = sortType or "power"
	local list = self:GetPartnerListSortByPower()
	local t = {}
	for i = 1, 4 do
		local dInfo = list[i]
		if dInfo then
			table.insert(t, dInfo)
		end
	end
	if #t > 1 then
		--升序
		if sort == 1 then
			table.sort(t, function (a, b)
				return a:GetValue(sortType) < b:GetValue(sortType)
			end)
		--降序
		elseif sort == 2 then
			table.sort(t, function (a, b)
				return a:GetValue(sortType) > b:GetValue(sortType)
			end)
		end
	end
	return t
end

--获取已经开启的御灵槽总数
function CPartnerCtrl.GetUnlockSoulSoltCnt(self, isOne)
	local cnt = 0
	local dLockData = data.partnerequipdata.ParSoulUnlock
	local iGrade = g_AttrCtrl.grade
	for i = 1, 6 do
		if iGrade >= dLockData[i]["unlock_grade"] then
			cnt = cnt + 1
		end
	end
	if isOne then
		return cnt
	end
	return cnt * 4
end

--获取一个指定伙伴 
function CPartnerCtrl.GetTargetPartnerByPartnerType(self, partner_type)
	local list = self:GetPartnerList()
	for parid, oPartner in pairs(list) do
		if oPartner:GetValue("partner_type") == partner_type then
			return oPartner
		end
	end
end

function CPartnerCtrl.AddItemCtrl(self)
	g_ItemCtrl:AddCtrlEvent("CPartnerCtrl", callback(self, "OnItemCtrlEvent"))
end

function CPartnerCtrl.OnItemCtrlEvent(self, oCtrl)
	local oNewItem = nil
	local bAddItem = true
	if oCtrl.m_EventID == define.Item.Event.AddItem then
		oNewItem = oCtrl.m_EventData
	elseif oCtrl.m_EventID == define.Item.Event.RefreshSpecificItem then
		oNewItem = oCtrl.m_EventData
		bAddItem = oNewItem.m_IsAddAmount
	elseif oCtrl.m_EventID == define.Item.Event.DelItem then
		oNewItem = true
		bAddItem = false
	end
	if oNewItem then
		if bAddItem then
			for i = 1, 4 do
				local oPartner = g_PartnerCtrl:GetPartnerByFightPos(i)
				if oPartner then
					local dEquipInfo = oPartner:GetCurEquipInfo()
					for _, itemid in pairs(dEquipInfo) do
						local oItem = g_ItemCtrl:GetItem(itemid)
						local dUpGradeItem = oItem:GetValue("upgrade_item")
						local dUpStarItem = oItem:GetValue("upstar_item")
						if dUpGradeItem["sid"] == oNewItem.m_ID then
							oItem.m_ParEquipUpGradeRedFlag = false
						
						elseif dUpStarItem["sid"] == oNewItem.m_ID then
							oItem.m_ParEquipUpStarRedFlag = false
						
						elseif oNewItem:IsPartnerStone() then
							local dLevelList = oItem:GetParEquipUpStoneResult()
							if dLevelList and table.index(dLevelList, oNewItem:GetValue("level")) then
								oItem.m_ParEquipUpStoneRedFlag = false
							end
						elseif oNewItem:IsPartnerSoul() then
							if oPartner:GetValue("soul_type") == oNewItem:GetValue("soul_type") then
								if oPartner:GetRestSoulPos() > 0 then
									oPartner.m_ParSoulRedFlag = false
								end
							end
						end
					end
				end
			end
		else
			local dFightList = {}
			for k, v in pairs(self.m_FightInfo) do
				table.insert(dFightList, v.parid)
			end
			self:OnEvent(define.Partner.Event.UpdateRedPoint, dFightList)
		end
	end
end


function CPartnerCtrl.IsHaveMaxStarPartner(self)
	local b = false
	local d = data.partnerdata.DATA
	local pool = {}
	for k, v in pairs(d) do
		if v.icon ~= 318 then
			table.insert(pool, v)
		end
	end
	local showCtn = 0
	for i, v in ipairs(pool) do
		local oPartner = g_PartnerCtrl:GetTargetPartnerByPartnerType(v.icon)
		if oPartner and oPartner:GetValue("star") >= CPartner.GetMaxStar() then
			b = true
			break
		end
	end
	return b
end

return CPartnerCtrl