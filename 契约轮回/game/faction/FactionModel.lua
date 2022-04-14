--
-- @Author: chk
-- @Date:   2018-12-05 10:40:40
--
FactionModel = FactionModel or class("FactionModel",BaseBagModel)
local this = FactionModel

FactionModel.donateId = "donateEquip"

FactionModel.GUILD_DUNGE_ID = 30381;
FactionModel.GUILD_ACTIVITY_ID = 10221;


function FactionModel:ctor()
	FactionModel.Instance = self


	self:Reset()
end

function FactionModel:Reset()
	self.faction_id = 0
	self.skillLst = {}
	self.members = {}
	self.Cadremember = {}    --干部成员,包括帮主之类的
	self.crntAppointType = enum.GUILD_POST.GUILD_POST_VICE  --当前任命的职位
	self.canAppointMems  = {}  --可以被任命的会员
	self.canViceMems = {}
	self.girlMems = {}
	self.selfFactionInfo = nil
	self.factionLst = {}
	self.careerFromIndex = {}
	self.applyList = {}
	self.logs = {}
	self.welfare = {}
	self.modifyNotice = ""
	self.selfCareer = 1
	self.factionSetInfo = nil   --帮派入会设置信息
	self.isMgrStatus = false    --是否管理状态
	self.wareItemsId = {}
	self.canDonateEquips = {}   --可捐献的装备
	self.donateEquipIds = {}    --要捐献的装备uid
	self.appointCareer = enum.GUILD_POST.GUILD_POST_VICE
	self.isDonateEquip = false
	self.isEchEquip = false

	self.isMemberPanel = false --是否打开了成员面板
	self.wareId = "factionWare"
	self.spanIdx = 0
	self.wareInfo = {}
	self.wareItems = {}
	self.selectQuality = 0
	self.isMapSelf = false  --是否只显示自己的装备
	self.selectStep = 0
	self.roleData = RoleInfoModel.Instance:GetMainRoleData()


	self.isHaveApp = false  --是否有人申请职位
	self.redPoints = {}
	self.skillCfgList = {}
	self.appliants = {}
	self.welfares = {}
	self.guildLv = 0
	self.isOpenWarePanel = false
	self.btnCount = 30
	self.isBtn = true

	if self.btnSchedule then
		GlobalSchedule:Stop(self.btnSchedule)
		self.btnSchedule = nil
	end
end

function FactionModel.GetInstance()
	if FactionModel.Instance == nil then
		FactionModel()
	end
	return FactionModel.Instance
end

function FactionModel:AddFstItem()
	table.insert(self.wareInfo.items,1,"exch_item")
	--table.insert(self.wareItems,1,"exch_item")
end

function FactionModel:AddMember(member)
	table.insert(self.members,member)


end

function FactionModel:ChangeAppointCareerToNumber(career)
	if self.appointCareer == career then
		return 1
	else
		return 0
	end
end


function FactionModel:ChangeBoolToNumber(b)
	if b then
		return 1
	else
		return 0
	end
end

--删除可捐献物品
function FactionModel:DelDonateEquipByUid(uid)
	for i, v in pairs(self.donateEquipIds) do
		if uid == v then
			local donateEquip = self:GetDonateEquipByUid(uid)
			table.removebyvalue(self.canDonateEquips,donateEquip)
			table.removebyvalue(self.donateEquipIds,v)
			break
		end
	end
end



--删除仓库物品
function FactionModel:DelWareItemByUid(uid)
	for i, v in pairs(self.wareItemsId) do
		if uid == v then
			local wareItem = self:GetWareItemByUid(uid)
			table.removebyvalue(self.wareItems,wareItem)
			table.removebyvalue(self.wareItemsId,v)
			break
		end
	end
end

function FactionModel:GetFactionNameById(guild_id)
	local name = ""
	for i, v in pairs(self.factionLst) do
		if v.id == guild_id then
			name = v.name
		end
	end
	return name
end

function FactionModel:GetWareItemByUid(uid)
	local wareItem = nil
	for i, v in pairs(self.wareItems) do
		if type(v) == "table" and v.uid == uid then
			wareItem = v
			break
		end
	end

	return wareItem
end


function FactionModel:GetDonateEquipByUid(uid)
	local donateItem = nil
	for i, v in pairs(self.canDonateEquips) do
		if v.uid == uid then
			donateItem = v
			break
		end
	end

	return donateItem
end

--设置(仓库物品)是否选中
function FactionModel:SetWareItemSelect(uid,select)
	local hasUid = false
	for i, v in pairs(self.wareItemsId) do
		if v == uid then
			hasUid = true
			break
		end
	end

	if select then
		if not hasUid then
			table.insert(self.wareItemsId,uid)
		end
	else
		if hasUid then
			table.removebyvalue(self.wareItemsId,uid)
		end
	end

end

function FactionModel:GetWareItemSelect(uid)
	local isSelect = false
	for i, v in pairs(self.wareItemsId) do
		if v == uid then
			isSelect = true
			break
		end
	end
	return isSelect
end

--设置(捐献装备)是否选中
function FactionModel:SetDonateEquipSelect(uid,select)
	local hasUid = false
	for i, v in pairs(self.donateEquipIds) do
		if v == uid then
			hasUid = true
			break
		end
	end

	if select then
		if not hasUid then
			table.insert(self.donateEquipIds,uid)
		end
	else
		if hasUid then
			table.removebyvalue(self.donateEquipIds,uid)
		end
	end
end


function FactionModel:DelMemberByUid(role_id)
	for i, v in pairs(self.members) do
		if v.base.id == role_id then
			table.removebyvalue(self.members,v)
		end
	end
end


--设置可任命的帮众会员
function FactionModel:SetCanAppointmentMembers()
	self.canAppointMems = {}
	for i, v in pairs(self.members) do
		if v.post < enum.GUILD_POST.GUILD_POST_CHIEF then
			table.insert(self.canAppointMems,v)
		end
	end

	self.girlMems = {}
	for i, v in pairs(self.members) do
		if v.base.career == 2 and v.post ~= enum.GUILD_POST.GUILD_POST_CHIEF then
			table.insert(self.girlMems,v)
		end
	end
	self.canViceMems = {}
	for i, v in pairs(self.members) do
		if  v.post == enum.GUILD_POST.GUILD_POST_VICE then
			table.insert(self.canViceMems,v)
		end
	end

	local function call_back(m1,m2)
		local online1 = self:ChangeBoolToNumber(m1.online)
		local online2 = self:ChangeBoolToNumber(m2.online)
		local appointC1 = self:ChangeAppointCareerToNumber(m1.post)
		local appointC2 = self:ChangeAppointCareerToNumber(m2.post)

		if online1== 1 and online1 == online2 then --判断在线
			if appointC1 == appointC2 then
				if m1.base.career == m2.base.caree then  --职业相同，同，战力
					return m1.base.power > m2.base.power
				else
					return m1.post > m2.post             --高职位在前
				end
			else
				return appointC1 > appointC2
			end

		elseif online1 == 0  and  online1 == online2 then  --不在线
			return m1.logout > m2.logout
		else
			return online1 > online2
		end
	end

	table.sort(self.canAppointMems,call_back)
end

function FactionModel:GetLogItemByIndex(index)
	return self.wareInfo.logs[tonumber(index)]
end


function FactionModel:GetGoodsCanExchange(id)
	local ce = false
	for i, v in pairs(Config.db_guild_exch) do
		if v.item_id == id then
			ce = true
			break
		end
	end

	return ce
end

function FactionModel:GetExcBuyCfg(itemId)
	for i, v in pairs(Config.db_guild_exch) do
		if v.item_id == itemId then
			return v
		end
	end
end

--是否可以换购
function FactionModel:GetCanExcBuy(itemId,num)
	local can = false
	for i, v in pairs(Config.db_guild_exch) do
		if v.item_id == itemId then
			if self.wareInfo.score >= v.score * num then
				can = true
				break
			end
		end
	end

	return can
end

function FactionModel:GetEquipCanExchange(uid)
	local id = self:GetExchEquipId(uid)
	local equipCfg = Config.db_equip[id]
	if self.wareInfo.score >= equipCfg.donate_score then
		return true
	else
		return false
	end
end


function FactionModel:GetExchEquipId(uid)
	local id = nil
	for i, v in pairs(self.wareInfo.items) do
		if type(v) == "table" and v.uid == uid then
			local equipCfg = Config.db_equip[v.id]
			id = equipCfg.id
			break
		end
	end

	return id
end

function FactionModel:GetCanDonateEquip()
	local equips = BagModel.Instance:GetEquipsByMoreQuality(enum.COLOR.COLOR_PURPLE)
	self.canDonateEquips = {}
	for i, v in pairs(equips) do
		local equipCfg = Config.db_equip[v.id]
		if equipCfg.slot ~= enum.ITEM_STYPE.ITEM_STYPE_FAIRY and equipCfg.slot ~= enum.ITEM_STYPE.ITEM_STYPE_LOCK
		and equipCfg.order >= 4 and v.bind == false then
			table.insert(self.canDonateEquips,v)
		end
	end
end


function FactionModel:GetCareerByType(members,type)
	local careers = {}
	for i, v in pairs(members) do
		if v.post == type then
			table.insert(careers,v)
		end
	end

	return careers
end

function FactionModel:GetCareers(members)
	local careers = {}
	for i, v in pairs(members) do
		if v.post > enum.GUILD_POST.GUILD_POST_MEMB then
			table.insert(careers,v)
		end
	end

	return careers
end

function FactionModel:IsHaveBaby()
	local boo = false
	for i, v in pairs(self.members) do
		if v.post == enum.GUILD_POST.GUILD_POST_BABY then
			boo = true
			break
		end
	end
	return boo
end

--获取帮主
function FactionModel:GetPresident()
	return self.Cadremember[1]
end

function FactionModel:GetMemberByUdi(role_id)
	local member = nil
	for i, v in pairs(self.members) do
		if v.base.id == role_id then
			member = v
			break
		end
	end

	return member
end

function FactionModel:GetSelf()
		return self:GetMemberByUdi(self.roleData.id)
end


function FactionModel:GetWareLogTime(time)
	local date = TimeManager.Instance:GetTimeDate(time)
	return "[" .. date.month .. "-" .. date.day .. " " .. date.hour .. ":" .. date.min .. ":" .. date.sec .. "]"
end

function FactionModel:GetItemDataByIndex(index)
	return self.wareItems[index]
end

function FactionModel:GetMember()
	return self.members
end

function FactionModel:GetConfig(item_id)
	return Config.db_equip[item_id]
end

function FactionModel:GetPermCfg(perm)
	local permCfg = nil
	for i, v in pairs(Config.db_guild_perm) do
		if v.perm == perm then
			permCfg = v
		end
	end

	return permCfg
end

--一键申请用到
function FactionModel:GetAllCanApplyFactionids()
	local factionIds = {}
	local count = 1
	for i, v in pairs(self.factionLst or {}) do
        local guildCfg = Config.db_guild[v.level]
		local level = v.reqs.level or 0
		local power = v.reqs.power or 0
		if self.roleData.level >= level and self.roleData.power >= power and count <=5 and guildCfg.memb > v.num then
			table.insert(factionIds,v.id)
			count = count + 1
		end
	end

	return factionIds
end
--获取自己是否帮主
function FactionModel:GetIsPresidentSelf()
	return self.selfCareer == enum.GUILD_POST.GUILD_POST_CHIEF
end

--设置干部成员,包括帮主
function FactionModel:SetCadremember()
	if self.selfFactionInfo == nil then
		return
	end
	self.Cadremember = {}
	for i, v in pairs(self.selfFactionInfo.members) do
		if v.post > 1 then
			table.insert(self.Cadremember,v)
		end
	end

	local function call_back(c1,c2)
		if c1 ~= nil and c2 ~= nil then
			return c1.post > c2.post
		end
	end
	table.sort(self.Cadremember,call_back)

	self:SetCareerFromIndex()
end

--获取自己在帮会中的职位
function FactionModel:SetSelfCadre()
	self.selfCareer = 1
	local rold_id = RoleInfoModel.GetInstance():GetMainRoleId()
	for i, v in pairs(self.Cadremember) do
		if v.base.id == rold_id then
			self.selfCareer = v.post
			break
		end
	end

	return self.selfCareer
end

function FactionModel:GetOtherCader(uid)
	
end

function FactionModel:SetMembers(members)
	self.members = members
	local function call_back(m1,m2)
		local online1 = self:ChangeBoolToNumber(m1.online)
		local online2 = self:ChangeBoolToNumber(m2.online)

		if online1== 1 and online1 == online2 then --判断在线
			if m1.base.career == m2.base.caree then  --职业相同，同，战力
				return m1.base.power > m2.base.power
			else
				return m1.post > m2.post             --高职位在前
			end
		elseif online1 == 0  and  online1 == online2 then  --判断是否在线
			return m1.logout > m2.logout
		else
			return online1 > online2
		end
	end
	table.sort(self.members,call_back)
end

function FactionModel:SetFactionList(factionLst)
	self.factionLst = factionLst

	if table.nums(self.factionLst) >= 2 then
		local function call_back(f1,f2)
			if f1 ~= nil and f2 ~= nil then
				return f1.rank < f2.rank
			end
		end
		table.sort(self.factionLst,call_back)
	end

end

function FactionModel:SetCareerFromIndex()
	self.factionCfg = Config.db_guild[self.selfFactionInfo.level]
	self.careerFromIndex[enum.GUILD_POST.GUILD_POST_CHIEF] = 1  --帮主item项就是1
	self.careerFromIndex[enum.GUILD_POST.GUILD_POST_VICE] = self.careerFromIndex[enum.GUILD_POST.GUILD_POST_CHIEF] + self.factionCfg.vice  --副帮主item项从2开始

	self.careerFromIndex[enum.GUILD_POST.GUILD_POST_BABY] = self.careerFromIndex[enum.GUILD_POST.GUILD_POST_VICE] + self.factionCfg.baby
	--self.careerFromIndex[enum.GUILD_POST.GUILD_POST_ELDER] = self.careerFromIndex[enum.GUILD_POST.GUILD_POST_BABY] + self.factionCfg.elder
	self.careerFromIndex[enum.GUILD_POST.GUILD_POST_ELDER] = self.careerFromIndex[enum.GUILD_POST.GUILD_POST_BABY] + self.factionCfg.elder --长老
	--self.careerFromIndex[enum.GUILD_POST.GUILD_POST_BABY] = self.careerFromIndex[enum.GUILD_POST.GUILD_POST_ELDER] + self.factionCfg.baby
end

function FactionModel:SearchByName(name)

end

--设置为某个职位
function FactionModel:SetMemberCareer(rold_id,guild_pos)
	for i, v in pairs(self.members) do
		if v.base.id == rold_id then
			v.post = guild_pos
		end
	end

	self:SetCadremember()
end

function FactionModel:SetKitOut(role_id)
	for i, v in pairs(self.members) do
		if v.base.id == role_id then
			table.removebykey(self.members,i)
		end
	end
end

--设置领取福利的次数
function FactionModel:SetReceiveWelfareCount(welfare,count)
	self.selfFactionInfo.welfare[welfare] = count
end

function FactionModel:Setwelfares(welfare,count)
	self.welfares[welfare] = count
end


function FactionModel:SetWareItems(qulity,step,isMapSelf)
	self.wareItems = {}
	self.wareItems[1] = "exch_item"
	if qulity == 0 and step == 0  then
		for i, v in pairs(self.wareInfo.items) do
			if type(v) == "table" then
				if not isMapSelf then
					table.insert(self.wareItems,v)
				elseif type(v) == "table" and EquipModel.Instance:GetEquipIsMapCareer(v.id) then
					table.insert(self.wareItems,v)
				end
			end
		end
	else
		for i, v in pairs(self.wareInfo.items or {}) do
			if type(v) == "table" then
				local itemCfg = Config.db_item[v.id]
				local equipCfg = Config.db_equip[v.id]
				if qulity == 0 then
					if equipCfg.order == step then
						if not isMapSelf then
							table.insert(self.wareItems,v)
						elseif type(v) == "table" and EquipModel.Instance:GetEquipIsMapCareer(v.id) then
							table.insert(self.wareItems,v)
						end
					end
				else if step == 0 then
					if itemCfg.color == qulity then
						if not isMapSelf then
							table.insert(self.wareItems,v)
						elseif type(v) == "table" and EquipModel.Instance:GetEquipIsMapCareer(v.id) then
							table.insert(self.wareItems,v)
						end
					end
				else if itemCfg.color == qulity and equipCfg.order == step then
						if not isMapSelf then
							table.insert(self.wareItems,v)
						elseif type(v) == "table" and EquipModel.Instance:GetEquipIsMapCareer(v.id) then
							table.insert(self.wareItems,v)
						end
					end
				end
				end
			end

		end
	end
end

--添加捐献装备
function FactionModel:AddDonateEquip(item)
	local hasNil = false
	local nilIndex = 0
	for ii, vv in pairs(self.wareInfo.items) do
		if vv== nil then
			hasNil = 0
			nilIndex = ii
			break
		end
	end

	if hasNil then
		self.wareInfo.items[nilIndex] = item
		--self:Brocast(FactionEvent.AddWareItem,nilIndex)
	else
		table.insert(self.wareInfo.items,item)
		--self:Brocast(FactionEvent.AddWareItem,#self.wareInfo.items)
	end


	local hasNil2 = false
	local nilIndex2 = 0
	for ii, vv in pairs(self.wareItems) do
		if vv== 0 then
			hasNil2 = true
			nilIndex2 = ii
			break
		end
	end


	local itemCfg = Config.db_item[item.id]
	local equipCfg = Config.db_equip[item.id]
	local addIndex = 0
	if self.selectStep == 0 and self.selectQuality == 0  then
		if not self.isMapSelf or EquipModel.Instance:GetEquipIsMapCareer(item.id) then --匹配自己
			if hasNil2 then
				self.wareItems[nilIndex2] = item
				addIndex = nilIndex2
			else
				table.insert(self.wareItems,item)
				addIndex = self:GetWareItemsLen() + 1
			end
		end
	else
		--for i, v in pairs(self.wareInfo.items or {}) do
			if self.selectQuality == 0 then
				if equipCfg.order == self.selectStep and
						(not self.isMapSelf or EquipModel.Instance:GetEquipIsMapCareer(item.id))  then
					if hasNil2 then
						self.wareItems[nilIndex2] = item
						addIndex = nilIndex2
					else
						table.insert(self.wareItems,item)
						addIndex = self:GetWareItemsLen() + 1
					end
				end
			else if self.selectStep == 0 then
				if itemCfg.color == self.selectQuality and
						(not self.isMapSelf or EquipModel.Instance:GetEquipIsMapCareer(item.id)) then
					if hasNil2 then
						self.wareItems[nilIndex2] = item
						addIndex = nilIndex2
					else
						table.insert(self.wareItems,item)
						addIndex = self:GetWareItemsLen() + 1
					end
				end
			else if itemCfg.color == self.selectQuality and equipCfg.order == self.selectStep and
						(not self.isMapSelf or EquipModel.Instance:GetEquipIsMapCareer(item.id)) then
					if hasNil2 then
						self.wareItems[nilIndex2] = item
						addIndex = nilIndex2
					else
						table.insert(self.wareItems,item)
						addIndex = self:GetWareItemsLen() + 1--#self.wareItems
					end
				end
			end
			end

		--end
	end

	GlobalEvent:Brocast(BagEvent.AddItems, FactionModel.Instance.wareId, addIndex)
end

function FactionModel:GetWareItemsLen()
	local index =0
	for k, v in pairs(self.wareItems) do
		if type(v) == "table" then
			index = index + 1
		end
	end
	return index
end

function FactionModel:GetItemsLen()
	local index =0
	for k, v in pairs(self.wareInfo.items) do
		if type(v) == "table" then
			index = index + 1
		end
	end
	return index
end

--删除仓库的物品
function FactionModel:DelWareEquip(uid)
	for i, v in pairs(self.wareInfo.items) do
		if type(v) == "table" and v.uid == uid then
			self.wareInfo.items[i] = 0
			--GlobalEvent:Brocast(FactionEvent.DestroyEquipSucess,uid)
			break
		end
	end

	for i, v in pairs(self.wareItems) do
		if type(v) == "table" and v.uid == uid then
			self.wareItems[i] = 0
			GlobalEvent:Brocast(GoodsEvent.DelItems, FactionModel.Instance.wareId, uid)
			break
		end
	end
end

--添加捐献日志
function FactionModel:AddDonateLog(log)
	self.wareInfo.logs = self.wareInfo.logs or {}
	table.insert(self.wareInfo.logs,log)
	return #self.wareInfo.logs
end


function FactionModel:SortItems(items)
	if items ~= nil then
		table.removebyvalue(items,0,true)
		table.removebyvalue(items,nil,true)

		items = items or {}

		if #items >= 2 then
			local function call_back(item1,item2)
				if item1 ~= nil and item2 ~= nil and Config.db_item[item1.id] ~= nil and Config.db_item[item2.id] ~= nil then
					local sortKey1 = Config.db_item[item1.id].type .. "@" .. Config.db_item[item1.id].stype
					local sortKey2 = Config.db_item[item2.id].type .. "@" .. Config.db_item[item2.id].stype
					local sortItem1 = Config.db_item_type[sortKey1]
					local sortItem2 = Config.db_item_type[sortKey2]

					if Config.db_item[item1.id].type == Config.db_item[item2.id].type and Config.db_item[item1.id].stype ==
							Config.db_item[item2.id].stype then
						if Config.db_item[item1.id].type == enum.ITEM_TYPE.ITEM_TYPE_EQUIP then
							if item1.score == item2.score then
								local bind1 = 0
								local bind2 = 0
								if item1.bind then
									bind1 = 1
								end

								if item2.bind then
									bind2 = 1
								end
								return bind1 < bind2
							else
								return item1.score > item2.score
							end
						else
							if Config.db_item[item1.id].color == Config.db_item[item2.id].color then
								if item1.id == item2.id then
									local bind1 = 0
									local bind2 = 0
									if item1.bind then
										bind1 = 1
									end

									if item2.bind then
										bind2 = 1
									end
									return bind1 < bind2
								else
									return item1.id > item2.id
								end
							else
								return Config.db_item[item1.id].color > Config.db_item[item2.id].color
							end
						end
					elseif sortItem1 ~= nil and sortItem2 ~= nil then
						return sortItem1.order < sortItem2.order
					else
						return Config.db_item[item1.id].type < Config.db_item[item2.id].type
					end
				end
			end
			table.sort(items,call_back)
		end
	end
end


-- 是否同一个帮会
function FactionModel:IsSameGuild(gname)
	local main_role = RoleInfoModel:GetInstance():GetMainRoleData()
	return main_role and main_role.gname == gname and string.trim(gname) ~= ""
end

function FactionModel:CheckClickPage()
	local main_role = RoleInfoModel:GetInstance():GetMainRoleData()
	if main_role.guild == "0" then --已经加入公会
		return "Please join a guild first"
	end
end

function FactionModel:AddApplyList(role)
	--self.applyList.appliants
	print2(role)
	self.appliants = self.appliants or {}
	for i, v in pairs(self.appliants) do
		if role.base.id == v.base.id then
			return
		end
	end
	--for i = 1, #self.appliants do
	--	if role.base.id == self.appliants[i].base.id then
	--		return
	--	end
	--end
	table.insert(self.appliants,role)
end

function FactionModel:DeatchApplyList(role_id)
	
	self.appliants = self.appliants or {}
	for i, v in pairs(self.appliants ) do
		if role_id == v.base.id then
			table.removebykey(self.appliants,i)
			break
		end
	end
	--for i = 1, #self.appliants  do
	--	if role_id == self.appliants[i].base.id then
	--		table.removebykey(self.appliants,i)
	--		break
	--	end
	--end
	--dump(self.applyList.appliants)
end

function FactionModel:GetItemByUid(uid)
	local bag_id = BagModel:GetInstance():GetBagIdByUid(uid)
	if bag_id == 0 then
		for _, v in pairs(self.wareInfo.items) do
			if type(v) == "table" and v.uid == uid  then
				--if v.uid == uid then
					return v
				--end
			end
		
		end
	else
		return FactionModel.super:GetItemByUid(uid)
	end
	return nil
end

-------------------------------技能相关-------------------------
--获取技能的状态
--0  需求等级大于自身等级
--1  已激活
--2  未激活
function FactionModel:GetSkillStatus(id)
	local level = self.skillLst[id]
	if level == nil then
		level = 1
	end
	local key = id .. "@" .. level
	local skillLvCfg = Config.db_skill_level[key]
	local roleData = RoleInfoModel.GetInstance():GetMainRoleData()
	local reqTbl = String2Table(skillLvCfg.reqs)

	--需求等级大于自身等级
	if reqTbl[2] > roleData.level then
		return 0
	else
		--已经激活
		if self.skillLst[id] ~= nil then
			return 1

		else
			return 2
		end
	end

end

function FactionModel:StartBtnCountDown()
	self.btnSchedule = GlobalSchedule:Start(handler(self,self.BtnCutDown),1,30)
end

function FactionModel:BtnCutDown()
	self.btnCount = self.btnCount - 1
	if self.btnCount <= 0 then
		self.btnCount = 30
		self.isBtn = true
		if self.btnSchedule then
			GlobalSchedule:Stop(self.btnSchedule)
			self.btnSchedule = nil
		end
	end
	self:Brocast(FactionEvent.BtnCountDown)
end