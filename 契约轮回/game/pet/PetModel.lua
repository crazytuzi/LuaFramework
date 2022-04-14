---
--- Created by  R2D2
--- DateTime: 2019/4/2 19:30
---
PetModel = PetModel or class("PetModel", BaseModel)
local PetModel = PetModel

PetModel.PetBag = 105
PetModel.DecomposeItemId = 0
PetModel.DecomposeQualityDivide = 5 ---分解品质分割点
PetModel.AutoDecomposeBeginNum = 0  ---需要自动分解时的数量
PetModel.DecomposeSettingKey = "Pet_AutoDecompose_Key"

PetModel.TipType = {
	PetBag = 1,
	PetEgg = 2,
	PetMarket = 3, --市场上架
	DownMarket = 4, --市场下架
	buyMarket = 5, --市场购买
	DesBuyMarket = 6, --指定交易购买
}

function PetModel:ctor()
	self:Init()
	PetModel.Instance = self
	
	self:Reset()
	self.ColorTab = {
		ColorUtil.ColorType.White,
		ColorUtil.ColorType.White,
		ColorUtil.ColorType.White,
		ColorUtil.ColorType.Green,
		ColorUtil.ColorType.Orange,
		ColorUtil.ColorType.Red,
		ColorUtil.ColorType.Pink,
		ColorUtil.ColorType.Pink,
	}
end

--- 初始化或重置
function PetModel:Reset()
	self.TipPets = {}
	self.bagPetSortList = {}
	self.bagPetQualitySortList = {}
	self.battlePetSortList = {}
	self.pet_views = {}
end

function PetModel:GetInstance()
	if PetModel.Instance == nil then
		PetModel()
	end
	return PetModel.Instance
end

function PetModel:Init()
	self:ReadSettings()
	
	PetModel.DecomposeItemId = enum.ITEM.ITEM_PET_CREAM
	
	self.TipPets = {}
	
	---按大小排序的所有阶数,显示阶数，品质
	self.orderList = {}
	self.orderShowList = {}
	self.qualityList = {}
	---训练宠物最大的ID
	self.trainMaxList = {}
	---没有对应阶数上阵宠物时的列表
	self.defaultShowList = {}
	---融合按类型分组
	self.composeGroup = {}
	
	local orderTab = {}
	local orderShowTab = {}
	local qualityTab = {}
	for _, v in pairs(Config.db_pet) do
		if v.order ~= 9999 then
			if (not orderTab[v.order]) then
				orderTab[v.order] = true
				orderShowTab[v.order_show] = true
			end
			if (not qualityTab[v.quality]) then
				qualityTab[v.quality] = true
			end
		end
	end
	
	for k, _ in pairs(orderTab) do
		table.insert(self.orderList, k)
	end
	
	for k, _ in pairs(orderShowTab) do
		table.insert(self.orderShowList, k)
	end
	
	for k, _ in pairs(qualityTab) do
		table.insert(self.qualityList, k)
	end
	
	table.sort(self.orderList)
	table.sort(self.orderShowList)
	table.sort(self.qualityList)
	
	for _, v in ipairs(self.orderList) do
		self.defaultShowList[v] = self:GetBestQualityById(v)
	end
	
	orderTab = {}
	for _, v in pairs(Config.db_pet_strong) do
		
		if (orderTab[v.order]) then
			orderTab[v.order] = math.max(orderTab[v.order], v.cross)
		else
			orderTab[v.order] = v.cross
		end
	end
	
	self.trainMaxList = orderTab
	
	for _, v in pairs(Config.db_pet_compose) do
		
		if (not self.composeGroup[v.type_id]) then
			self.composeGroup[v.type_id] = {}
		end
		local t = {}
		t.id = v.id
		t.type_id = v.type_id
		t.level = v.level
		t.target = String2Table(v.target)
		t.cost = String2Table(v.cost)
		t.proba = v.proba
		table.insert(self.composeGroup[v.type_id], t)
	end
	
	for _, v in ipairs(self.composeGroup) do
		table.sort(v, function(p1, p2)
			return  p1.id < p2.id
		end)		
	end
end

function PetModel:SaveSettings(bool)
	self.IsAutoDecompose = toBool(bool)
	local v = self.IsAutoDecompose and 1 or 0
	CacheManager:SetInt(PetModel.DecomposeSettingKey, v)
end

function PetModel:ReadSettings()
	local v = CacheManager:GetInt(PetModel.DecomposeSettingKey, 1)
	self.IsAutoDecompose = v > 0
end

function PetModel:GetOrderIndex(order)
	for i, v in ipairs(self.orderList) do
		if (v == order) then
			return i
		end
	end
	
	return 0
end

function PetModel:SetEggRecords(data)
	local tempNum
	local tempCfg
	local tempTab = {}

	---为了不影响已经发出的包，只能保持协议不变
	---如果能转成数字就当ID处理，否则直接当作宠物名字显示
	---且每次只会带一个宠物,不然代码逻辑就无法正确运行
	for _, v in ipairs(data.records) do
		for k, vv in pairs(v.pets) do
			tempNum = tonumber(vv)
			if (tempNum) then
				tempCfg = Config.db_pet[tempNum]
				if (tempCfg and tempCfg.quality >= PetModel.DecomposeQualityDivide) then
					v.pets[k] = tempNum
					v.Config = tempCfg
					table.insert(tempTab, v)
				end
			else
				table.insert(tempTab, v)
			end
		end
	end

	self.eggRecords = tempTab
	GlobalEvent:Brocast(PetEvent.Pet_EggRecordsEvent)
end

function PetModel:GetEggRecords()
	return self.eggRecords
end

---保存背包中的宠物列表
function PetModel:SetBagPetList(tab)
	
	local bagPetList = tab.items
	self.BagCellCount = tab.opened
	PetModel.AutoDecomposeBeginNum = self.BagCellCount - 5
	
	---按阶排序后列表
	
	self.bagPetSortList = self.bagPetSortList or {}
	self.bagPetQualitySortList = self.bagPetQualitySortList or {}
	
	for _, v in ipairs(bagPetList) do
		self:AddBagPet(v, false)
	end
end

---获取可交易的宠物
function PetModel:GetMarketPet()
	local marketPet = {}
	
	for _, v in pairs(self.bagPetSortList) do
		for _, w in ipairs(v) do
			table.insert(marketPet, w)
		end
	end
	
	return marketPet
end

---所有的宠物，包括背包与出战中的
function PetModel:GetAllPet()
	local pets = self:GetMarketPet()

	for _, v in pairs(self.battlePetSortList) do
			table.insert(pets, v)
	end

	return pets
end

---添加宠物到背包
function PetModel:AddBagPet(pet, isNotice, isTip)
	local p = Config.db_pet[pet.id]
	
	if (not self.bagPetSortList[p.order]) then
		self.bagPetSortList[p.order] = {}
	end
	
	if (not self.bagPetQualitySortList[p.quality]) then
		self.bagPetQualitySortList[p.quality] = {}
	end
	
	table.insert(self.bagPetSortList[p.order], pet)
	table.insert(self.bagPetQualitySortList[p.quality], pet)
	
	---从服务器下发的不要通知，后面安装或卸下时通知界面刷新
	if (isNotice) then
		self:Brocast(PetEvent.Pet_Model_AddBagPetEvent)
		if (self.IsAutoDecompose) then
			self:CheckAutoDecompose()
		end
	end
	if p.order == 9999 then
		isTip = false
	end
	if (isTip) then
		self:RecommendPet(pet)
	end
end

---（检查）推荐宠物
function PetModel:RecommendPet(pet)
	
	local count = 0
	for _, v in pairs(self.battlePetSortList) do
		if (v) then
			count = count + 1
		end
	end
	
	for _, v in pairs(self.bagPetSortList) do
		if (v) then
			count = count + #v
		end
	end
	
	---如果全局只有一个，则当作是任务产生的首个宠物，交由向导处理
	if (count == 1) then
		return
	end
	
	local cfg = Config.db_pet[pet.id]
	---达不到出战条件，忽略之
	if (not self:CheckFightCondition(cfg, false)) then
		return
	end
	
	---如果相应阶未出战，或是出战的评分比新得的低，进行推荐
	local battlePet = self.battlePetSortList[cfg.order]
	if battlePet then
		if (battlePet.score < pet.score) then
			GlobalEvent:Brocast(PetEvent.Pet_RecommendEvent, pet)
			if not self.pet_views[pet.uid] then
				local view = UsePetView()
				view:SetData(pet)
				self.pet_views[pet.uid] = view
			end
		end
	else
		GlobalEvent:Brocast(PetEvent.Pet_RecommendEvent, pet)
		if not self.pet_views[pet.uid] then
			local view = UsePetView()
			view:SetData(pet)
			self.pet_views[pet.uid] = view
		end
	end
end

function PetModel:CheckAutoDecompose()
	local count = 0
	
	for k, v in pairs(self.bagPetSortList) do
		count = count + #v
	end
	
	if (count > PetModel.AutoDecomposeBeginNum) then
		for _, v in ipairs(self.qualityList) do
			if (v >= self.DecomposeQualityDivide) then
				break
			end
			
			if (self.bagPetQualitySortList[v] and #self.bagPetQualitySortList[v] > 0) then
				local index = math.random(1, #self.bagPetQualitySortList[v])
				PetController:GetInstance():RequestDecomposePet({ self.bagPetQualitySortList[v][index].uid })
				break
			end
		end
	end
end

---Controller中监听关闭PetShow窗口事件
---关闭时检查有没有要继续弹的
function PetModel:TipClose()
	self.TipOpened = false
	self:CheckTip(true)
end

---检查是否要弹出Tip
---isWait:如果是首次则立即弹出，连续的则要等待一点时间
function PetModel:CheckTip(isWait)
	if (not self.TipOpened) then
		local p = self:GetTipPetData()
		if (p) then
			self.TipOpened = true
			
			local function call_back()
				local view = PetAcquirePanel()
				view:SetData(p)
			end
			
			if (isWait) then
				GlobalSchedule:StartOnce(call_back, 0.2)
			else
				call_back()
			end
		end
	end
end

---从缓存取出用于TIP的
function PetModel:GetTipPetData()
	if #self.TipPets > 0 then
		local p = self.TipPets[#self.TipPets]
		table.remove(self.TipPets)
		return p
	end
	
	return nil
end

function PetModel:RepalceBagPet(petData)
	local index = 0
	local uid = petData.uid
	
	for _, v in pairs(self.bagPetSortList) do
		for i, p in ipairs(v) do
			if (p.uid == uid) then
				index = i
				break ;
			end
		end
		
		if index > 0 then
			v[index] = petData
			break
		end
	end
	
	for _, v in pairs(self.bagPetQualitySortList) do
		for i, p in ipairs(v) do
			if (p.uid == uid) then
				index = i
				break ;
			end
		end
		
		if index > 0 then
			v[index] = petData
			break
		end
	end
end

---删除背包宠物
function PetModel:RemoveBagPet(uid)
	local index = 0
	for _, v in pairs(self.bagPetSortList) do
		for i, p in ipairs(v) do
			if (p.uid == uid) then
				index = i
				break ;
			end
		end
		
		if index > 0 then
			table.remove(v, index)
			break
		end
	end
	
	index = 0
	for _, v in pairs(self.bagPetQualitySortList) do
		for i, p in ipairs(v) do
			if (p.uid == uid) then
				index = i
				break ;
			end
		end
		
		if index > 0 then
			table.remove(v, index)
			break
		end
	end
	if self.pet_views[uid] then
		self.pet_views[uid]:destroy()
	end
	self:Brocast(PetEvent.Pet_Model_DeleteBagPetEvent, uid)
end

---保存出/助战的宠物列表
function PetModel:SetBattlePetList(tab)
	
	self.fight_order = tab.fight_order
	
	local battlePetList = tab.pets
	self.battlePetSortList = self.battlePetSortList or {}
	
	for _, v in ipairs(battlePetList) do
		local p = Config.db_pet[v.id]
		self.battlePetSortList[p.order] = v
	end
	
	local newPetUid = nil
	if (#battlePetList == 1) then
		newPetUid = battlePetList[1].uid
	end
	
	self:Brocast(PetEvent.Pet_Model_BattlePetDataEvent, newPetUid)
end

---临时方案，保持设置出战/助战的值，用于返回时飘字
function PetModel:SaveRequestPetSetValue(value)
	self.requestPetSetValue = value
end

---当前操作的宠物阶数
function PetModel:SetFightOrder(order)
	--self.fight_order = order
	
	local p = self:GetShowPetByOrder(order)
	if (p) then
		local v = self.requestPetSetValue
		self.requestPetSetValue = nil
		self:Brocast(PetEvent.Pet_Model_ChangeBattlePetEvent, p, v, order)
	end
end

---训练
function PetModel:OnTrainPet(order)
	
	local p = self:GetShowPetByOrder(order)
	if (p) then
		self:Brocast(PetEvent.Pet_Model_TrainBattlePetEvent, p)
	end
end

---超越
function PetModel:OnCrossPet(order)
	
	local p = self:GetShowPetByOrder(order)
	if (p) then
		self:Brocast(PetEvent.Pet_Model_CrossBattlePetEvent, p)
	end
end

---突破
function PetModel:OnEvolutionPet(order)
	local p = self:GetShowPetByOrder(order)
	if (p) then
		self:Brocast(PetEvent.Pet_Model_EvolutionBattlePetEvent, p)
	end
end

---突破退还
function PetModel:OnBackEvolutionPet(order)
	local p = self:GetShowPetByOrder(order)
	if (p) then
		self:Brocast(PetEvent.Pet_Model_BackEvolutionBattlePetEvent, p)
	end
end

---融合
function PetModel:OnComposePet(id, success)
	self:Brocast(PetEvent.Pet_Model_ComposePetEvent, id, success)
end

---分解宠物
function PetModel:OnDecomposePet()
	self:Brocast(PetEvent.Pet_Model_DecomposePetEvent)
end

---根据过滤条件，获取相应背包中的宠物列表
function PetModel:GetAllList(filter)
	local allList = {}
	local tempTab
	for _, v in pairs(self.bagPetSortList) do
		for _, p in ipairs(v) do
			local config = Config.db_pet[p.id]
			if (type(filter) == "function") then
				if (filter(config)) then
					tempTab = { ["Data"] = p, ["Config"] = config, ["IsInBag"] = true, ["IsFighting"] = false }
					table.insert(allList, tempTab)
				end
			else
				tempTab = { ["Data"] = p, ["Config"] = config, ["IsInBag"] = true, ["IsFighting"] = false }
				table.insert(allList, tempTab)
			end
		end
	end
	
	return allList
end

-----获取要展示的列表
function PetModel:GetShowList()
	local showList = {}
	local active_list = {}
	for _, v in ipairs(self.orderList) do
		local pet = self:GetShowPetByOrder(v)
		if pet.IsActive then
			table.insert(active_list, pet)
		else
			table.insert(showList, pet)
		end
	end

	local function sort_fun(a, b)
		local sort1 = Config.db_pet[a.Data.id].sort
		local sort2 = Config.db_pet[b.Data.id].sort
		return sort1 < sort2
	end
	table.sort(active_list, sort_fun)
	table.insertto(active_list, showList, 0)
	--table.sort(showList, function (p1, p2)
	--	local v1 = p1.IsActive and 1 or 0
	--	v1 = v1 + (p1.IsFighting and 1 or 0)
	--
	--	local v2 = p2.IsActive and 1 or 0
	--	v2 = v2 + (p2.IsFighting and 1 or 0)
	--
	--	return v1 > v2 or p1.Config.order < p2.Config.order
	--end)

	return active_list
end

---获取对应阶的出战/助战，无则返回nil
function PetModel:GetOnBattlePetByOrder(order)
	if (self.battlePetSortList and self.battlePetSortList[order]) then
		return self.battlePetSortList[order]
	end
	return nil
end

---获取出战的宠物
function PetModel:GetFightingPet()
	for _, v in pairs(self.battlePetSortList) do
		local cfg = Config.db_pet[v.id]
		if (cfg and cfg.order == self.fight_order) then
			return v
		end
	end
	
	return nil
end

---获取指定UID的Pet
function PetModel:GetPetByUid(uid)
	
	local pet = self:GetBattlePetByUid(uid)
	
	if pet == nil then
		pet = self:GetBagPetByUid(uid)
	end
	
	return pet
end

---获取需要展示的（如无上阵的，则选取默认序列的）
function PetModel:GetShowPetByOrder(order)
	
	---先检测有没有已上阵的
	local p = self:GetBattlePetByOrder(order)
	local bagPet = self:GetBestBagPet(order)
	
	--local function CheckOverdue(petData)
	--    if (petData and petData.Data) then
	--        if petData.Data.etime == 0 then
	--            return false
	--        end
	--
	--        local serverTime = TimeManager.Instance:GetServerTime()
	--        return petData.Data.etime <= serverTime
	--    end
	--    return false
	--end
	
	if (p) then
		local hasBetter = bagPet and bagPet.score > p.Data.score or false
		p["HasBetter"] = hasBetter
		--p["BagCount"] = bagCount
		p["CheckOverdue"] = self.CheckOverdue -- handler(self, self. CheckOverdue)
		return p
	end
	
	local bagConfig = nil
	
	if (bagPet) then
		bagConfig = Config.db_pet[bagPet.id]
	end
	
	if (bagPet) then
		return { ["Config"] = bagConfig, ["IsActive"] = false,
			["HasInBag"] = true, ["BagPet"] = bagPet, ["CheckOverdue"] = self.CheckOverdue } --handler(self, self. CheckOverdue) }
	else
		return { ["Config"] = self.defaultShowList[order], ["IsActive"] = false,
			["HasInBag"] = false, ["CheckOverdue"] = self.CheckOverdue } --= handler(self, self. CheckOverdue) }
	end
end

function PetModel.CheckOverdue(petData)
	if (petData and petData.Data) then
		if petData.Data.etime == 0 then
			return false
		end
		
		local serverTime = TimeManager.Instance:GetServerTime()
		return petData.Data.etime <= serverTime
	end
	return false
end

---获取上阵中的宠物
function PetModel:GetBattlePetByOrder(order)
	if (self.battlePetSortList and self.battlePetSortList[order]) then
		local data = self.battlePetSortList[order]
		local config = Config.db_pet[data.id]
		local isFighting = order == self.fight_order
		return { ["Data"] = data, ["Config"] = config, ["IsActive"] = true,
			["IsFighting"] = isFighting, ["CheckOverdue"] = handler(self, self. CheckOverdue)  }
	else
		return nil
	end
end

---获取指定UID的上阵中的宠物
function PetModel:GetBattlePetByUid(uid)
	if (self.battlePetSortList) then
		
		for _, v in pairs(self.battlePetSortList) do
			if v.uid == uid then
				local data = v
				local config = Config.db_pet[data.id]
				local isFighting = config.order == self.fight_order
				return { ["Data"] = data, ["Config"] = config, ["IsActive"] = true,
					["IsFighting"] = isFighting, ["CheckOverdue"] = handler(self, self. CheckOverdue) }
			end
		end
		
		return nil
	else
		return nil
	end
end

---获取融合列表
function PetModel:GetComposeGroupByType(typeId)
	return self.composeGroup[typeId]
end

---出战条件文字描述
function PetModel:GetConditionString(petCfg)
	
	local condition = {}
	if petCfg.wake > 0 then
		table.insert(condition, string.format("%d Awakening", petCfg.wake))
	end
	
	if petCfg.level > 1 then
		table.insert(condition, string.format("LV.%d", petCfg.level))
	end
	
	if (#condition > 0) then
		return table.concat(condition, "")
	else
		return nil
	end
end

function PetModel:GetOnBattleSkill()
	local tab = {
		{ 700001 },
		{ 700002 },
		{ 700003, 700004 },
	}
	return tab
end

---宠物描述 加品质描述及数量，方便统一颜色及弹出TIP
function PetModel:GeneratePetDescribe(petCfg, num)
	local desc
	local itemcfg = Config.db_item[petCfg.id]
	if num == nil or num <= 0 then
		desc = ConfigLanguage.Pet["Quality_Name_" .. itemcfg.color] .. petCfg.name
	else
		desc = ConfigLanguage.Pet["Quality_Name_" .. itemcfg.color] .. petCfg.name .. "*" .. num
	end
	
	return ColorUtil.GetHtmlStr(self.ColorTab[itemcfg.color], desc)
end

---背包中，同阶最高品的可用的
function PetModel:GetBestBagPet(order)    
	local list = self.bagPetSortList[order]
	if list == nil or #list == 0 then
		return nil
	end
	
	local list2 = {}
	local serverTime = TimeManager.Instance:GetServerTime()
	for _, v in ipairs(list) do	
		if v.etime == 0 or  v.etime > serverTime  then
			table.insert(list2, v)
		end
	end
	
	table.sort(list2, function(a, b)
			return a.score > b.score
		end)
	
	for _, v in ipairs(list2) do
		local cfg = Config.db_pet[v.id]
		if self:CheckFightCondition(cfg, false) then
			return v
		end
	end
	
	return nil --list[1]
end

---获取指定UID的背包中的宠物
function PetModel:GetBagPetByUid(uid)
	for _, v in pairs(self.bagPetSortList) do
		for _, w in ipairs(v) do
			if (w.uid == uid) then
				local config = Config.db_pet[w.id]
				return { ["Data"] = w, ["Config"] = config, ["IsInBag"] = true, ["IsFighting"] = false }
			end
		end
	end
	return nil
end

---配置中, 同阶最高品的
function PetModel:GetBestQualityById(order)
	
	local configList = {}
	
	for _, v in pairs(Config.db_pet) do
		if (v.order == order) then
			table.insert(configList, v)
		end
	end
	
	table.sort(configList, function(a, b)
			return a.quality > b.quality
		end)
	
	return configList[1]
end

---配置中，训练宠物最大ID
function PetModel:GetMaxTrainByOrder(order)
	if self.trainMaxList and self.trainMaxList[order] then
		return self.trainMaxList[order]
	else
		return order
	end
end

---获取并合并培养值
function PetModel:GetTrainValues(order, cross, stones)
	stones = stones or {}
	
	local key = string.format("%s@%s", order, cross)
	local cfg = Config.db_pet_strong[key]
	
	local base = String2Table(cfg.base)
	local max = String2Table(cfg.max)
	local values = {}
	
	for i, v in ipairs(base) do
		local v2 = stones[v[1]] or v[2]
		values[v[1]] = { v2, max[i][2] }
		--table.insert(values, { v[1], v2, max[i][2] })
	end
	
	return values, cfg.percent
end

---检查上阵条件
---isNotice:是否要飘字提示
function PetModel:CheckFightCondition(petConfig, isNotice)
	local lv = RoleInfoModel.GetInstance():GetRoleValue("level")
	if (petConfig.level > lv) then
		if isNotice then
			Notify.ShowText(string.format(ConfigLanguage.Pet.LevelConditionTip, petConfig.level))
		end
		return false
	end
	
	local wake = RoleInfoModel.GetInstance():GetRoleValue("wake")
	if (petConfig.wake > wake) then
		if isNotice then
			Notify.ShowText(string.format(ConfigLanguage.Pet.WakeConditionTip, petConfig.wake))
		end
		return false
	end
	
	return true
end

---查找多个属性表中的有效值（>0）
function PetModel:GetValidValueAttrs(...)
	local attrs = { ... }
	local tab = {}
	
	for _, t in ipairs(attrs) do
		for k, v in pairs(t) do
			if (type(v) == "number" and v > 0) then
				local index = GetAttrMapIndexByKey(k)
				tab[index] = v
			end
		end
	end
	
	return tab
end

---查找属性中的有效值（>0）
function PetModel:GetValidValueAttr(attrs)
	local tab = {}
	
	for k, v in pairs(attrs) do
		if (type(v) == "number" and v > 0) then
			local index = GetAttrMapIndexByKey(k)
			tab[index] = v
		end
	end
	
	return tab
end

PetModel.BlankSpaceConfig = {
	[2] = string.rep(" ", 10),
	[3] = string.rep(" ", 3),
	[4] = string.rep(" ", 1),
}

function PetModel:SplitChsWord(inputstr)
	local tab = {}
	local lenInByte = #inputstr
	local width = 0
	local i = 1
	while (i <= lenInByte) do
		local curByte = string.byte(inputstr, i)
		local byteCount = 1
		if curByte > 0 and curByte <= 127 then
			byteCount = 1 --1字节字符
		elseif curByte >= 192 and curByte < 223 then
			byteCount = 2 --双字节字符
		elseif curByte >= 224 and curByte < 239 then
			byteCount = 3 --汉字
		elseif curByte >= 240 and curByte <= 247 then
			byteCount = 4 --4字节字符
		end
		local char = string.sub(inputstr, i, i + byteCount - 1)
		--print(char)
		table.insert(tab, char)
		
		i = i + byteCount -- 重置下一字节的索引
		width = width + 1 -- 字符的个数（长度）
	end
	return width, tab
end

function PetModel:InsertBlankInChsWord(word)
	local count, tab = self:SplitChsWord(word)
	if (self.BlankSpaceConfig[count]) then
		return table.concat(tab, self.BlankSpaceConfig[count])
	else
		return word
	end
end

----------红点相关----------

function PetModel:IsOpen(id)
	local sideConfig = SidebarConfig.PetPanel
	
	local config = nil
	for _, v in ipairs(sideConfig) do
		if (v.id == id) then
			config = v
		end
	end
	
	if config == nil then
		return true
	end
	
	return IsOpenModular(config.open_lv, config.open_task)
end

---背包中是否有可以上阵的
function PetModel:HasBagPet(order)
	if (self.bagPetSortList == nil) then
		return false
	end
	
	local list = self.bagPetSortList[order]
	
	if list == nil or #list == 0 then
		return false
	end
	
	for _, v in ipairs(list) do
		local cfg = Config.db_pet[v.id]
		if (self:CheckFightCondition(cfg, false) and (not self.CheckOverdue({["Data"]=v}))) then
			return true
		end
	end
	
	return false
end

---背包中是否有更高评分的
function PetModel:HasBetter(order, score)
	local isHasBagPet = self:HasBagPet(order)
	if (isHasBagPet) then
		local basePet = self:GetBestBagPet(order)
		return basePet.score > score
	end
	return false
end

---是否可训练/突破
---返回3个值，分别对应=> 最终结果（逻辑或）,能不能培养,能不能超越
function PetModel:HasTrainOrCross(petData)
	---未开放
	if (not self:IsOpen(2)) then
		return false
	end

	---已经过期
	if petData:CheckOverdue() then
		return false
	end

	local _, trainConfig, isFull, isMax = self:GetPetTrainValue(petData)
	if (isFull) then
		if (isMax) then
			---满了后
			return false, false, false
		else
			local tab = String2Table(trainConfig.cross_cost)
			local isHad = self:CheckGoods(tab)
			return (false or isHad), false, isHad
		end
	else
		local tab = String2Table(trainConfig.strength_cost)
		local isHad = self:CheckGoods(tab)
		return (false or isHad), isHad, false
	end
end

--是否可超越
function PetModel:HasEvolution(petData)
	if (not self:IsOpen(3)) then
		return false
	end
	
	local epCount = petData.Config.evolution
	---不可用
	if epCount <= 0 then
		return false
	end
	
	---已满
	local extra = petData.Data.extra or 0
	if (extra >= epCount) then
		return false
	end
	
	---检查物品是否满足
	local nextKey = petData.Config.order .. "@" .. (extra + 1)
	local nextCfg = Config.db_pet_evolution[nextKey]
	if not nextCfg then
		return false
	end
	local tab = String2Table(nextCfg.cost)
	return self:CheckGoods(tab)
end

--是否有足够的宠物融合
function PetModel:HasEnoughPets(pet_id, need_count, need_level)
	local level = RoleInfoModel:GetInstance():GetRoleValue("level")
	if level < need_level then
		return false
	end
	local petcfg = Config.db_pet[pet_id]
	local needorder =petcfg.order
	local orderPets = self:GetAllList(function(cfg)
        return cfg.order == needorder
    end)
    local battlePet = self:GetBattlePetByOrder(needorder)
    if (battlePet) then
        table.insert(orderPets, battlePet)
    end

    local pets = {}
    for _, v in pairs(orderPets) do
    	if v.Config.id == pet_id then
    		table.insert(pets, v)
    	end
    end

    return #pets >= need_count
end

--是否可以融合
function PetModel:HasCompose()
	if not OpenTipModel.GetInstance():IsOpenSystem(860, 8) then
		return false
	end
	for type_id, composes in pairs(self.composeGroup) do
		for i=1, #composes do
			local costTab = composes[i].cost
			local pet_id = costTab[1][1]
			local need_count = costTab[1][2]
			if self:HasEnoughPets(pet_id, need_count, composes[i].level) then
				return true, type_id
			end
		end
	end
	return false
end

--是否有炼化
function PetModel:HasRefining()
	local count = 0
	for _, v in ipairs(self.qualityList) do
		if v < self.DecomposeQualityDivide then
			local pets = self.bagPetQualitySortList[v] or {}
			count = count + #pets
		end
	end

	return count >= 3
end

function PetModel:CheckGoods(goods)
	
	for _, v in ipairs(goods) do
		local num = BagModel:GetInstance():GetItemNumByItemID(v[1])
		if (num < v[2]) then
			return false
		end
	end
	
	return true
end

function PetModel:GetPetTrainValue(petData)
	
	local isMax = self:GetMaxTrainByOrder(petData.Config.order)
	isMax = petData.IsActive and isMax <= petData.Data.pet.cross or false
	
	local tKey = petData.Config.order .. "@" .. (petData.IsActive and petData.Data.pet.cross or 0)
	local tConfig = Config.db_pet_strong[tKey]
	
	local base = String2Table(tConfig.base)
	local max = String2Table(tConfig.max)
	local stones = petData.IsActive and petData.Data.pet.strong or {}
	
	local values = {}
	local isFull = true
	for i, v in ipairs(base) do
		local v2 = stones[v[1]] or v[2]
		
		if (v2 < max[i][2]) then
			isFull = false
		end
		table.insert(values, { v[1], v2, max[i][2] })
	end
	
	return values, tConfig, isFull, isMax
end

---变强用点刷新
function PetModel:RefreshStrongRedPoint()

	local has_Bag, has_Train, has_Evolution = false, false, false
	local showPetList = self:GetShowList()

	for _, v in ipairs(showPetList) do
		if (v.IsActive) then

			if self:HasTrainOrCross(v) and (not has_Train) then
				has_Train = true
			end

			if self:HasEvolution(v) and (not has_Evolution) then
				has_Evolution = true
			end
		else
			if self:HasBagPet(v.Config.order) and (not has_Bag) then
				has_Bag =  true
			end
		end
	end
	local has_compose = self:HasCompose()
	local has_refining = self:HasRefining()

	GlobalEvent:Brocast(MainEvent.ChangeSystemShowInStronger, 22, has_Bag)
	GlobalEvent:Brocast(MainEvent.ChangeSystemShowInStronger, 23, has_Train)
	GlobalEvent:Brocast(MainEvent.ChangeSystemShowInStronger, 24, has_Evolution)
	GlobalEvent:Brocast(MainEvent.ChangeSystemShowInStronger, 58, has_compose)
	GlobalEvent:Brocast(MainEvent.ChangeSystemShowInStronger, 59, has_refining)
end

function PetModel:RefreshMainRedPoint()

	if self.bagPetSortList == nil then
		return
	end
	self:RefreshStrongRedPoint()

	local isShow = self:AnyRedPoint()
	GlobalEvent:Brocast(MainEvent.ChangeRedDot, "pet", isShow)
end

function PetModel:AnyRedPoint()
	local showPetList = self:GetShowList()
	
	for _, v in ipairs(showPetList) do
		if (v.IsActive) then
			
			if (self:HasBetter(v.Config.order, v.Data.score)) then
				return true
			end
			
			if (self:HasTrainOrCross(v)) then
				return true
			end
			
			if (self:HasEvolution(v)) then
				return true
			end
		else
			
			if (self:HasBagPet(v.Config.order)) then
				return true
			end
		end
	end

	if self:HasCompose() then
		return true
	end

	if self:HasRefining() then
		return true
	end
	
	return false
end