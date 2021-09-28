MainUIModel = BaseClass(LuaModel)

--单例
function MainUIModel:GetInstance()
	if MainUIModel.inst == nil then
		MainUIModel.inst = MainUIModel.New()
	end
	return MainUIModel.inst
end


function MainUIModel:__init()
	self:InitData()
	self:InitEvent()
	self:InitMainUIVoList()
	
end

function MainUIModel:InitData()
	self.mainUIVoList = {}
	self.isCloseToMonster = false --是否靠近boos怪物
	self.quickEquipList = {}
	self.unEquipedList = {}
	self.activitesUIState = MainUIConst.ActivitesUIState.None
	self.redTipsDataCache = {} --红点数据缓存
	self:ResetPopCheck()
	self.isClickPrivateChat = 1
end

function MainUIModel:InitEvent()
	self.handler0 = GlobalDispatcher:AddEventListener(EventName.MAINUI_RED_TIPS , function(data)
		if MainUIController:GetInstance():GetView() and MainUIController:GetInstance():GetView():GetPanel() == nil then
			self:UpdateRedTipsDataCache(data)
		end
	end)
	self.handler1 = GlobalDispatcher:AddEventListener(EventName.MAINUI_EXIST , function()
		self:CleanRedTipsDataCache()
		GlobalDispatcher:RemoveEventListener(self.handler0)
	end)
end

function MainUIModel:CleanEvent()
	GlobalDispatcher:RemoveEventListener(self.handler0)
	GlobalDispatcher:RemoveEventListener(self.handler1)
end

function MainUIModel:InitMainUIVoList()
	local pushNotice = GetCfgData("pushNotice")
	for key , v in pairs(pushNotice) do
		if type(v) ~= 'function' then
			local curMainUIVo = MainUIVo.New()
			local isFadeIn = v.appear == 1 or false
			curMainUIVo:SetData(nil , v.apper , v.id , nil , v.level , v.taskId , v.moduleId , isFadeIn)
			table.insert(self.mainUIVoList , curMainUIVo)
		end
	end
end

--刷新MainUIVoList
function MainUIModel:RefershMainUIVoList(isLevelUp)
	local isChange = false

	local curPlayerLev = -1
	local mainPlayerVo = SceneModel:GetInstance():GetMainPlayer()
	if mainPlayerVo then
		curPlayerLev = mainPlayerVo.level
		if isLevelUp then
			self:OnMainPlayerUpgrade(curPlayerLev)
		end
	end

	local taskId =  -1
	local taskDataObj = TaskModel:GetInstance():GetMainTask()
	if not TableIsEmpty(taskDataObj) then
		taskId = taskDataObj:GetTaskId()
	end

	for index = 1 , #self.mainUIVoList do
		local curMainUIVo = self.mainUIVoList[index]
		local curState = MainUIConst.MainUIItemState.Close
		-- if curMainUIVo.limitLev <= curPlayerLev or  curMainUIVo.limitLev == 0 then
		-- 	if  curMainUIVo.openTaskId <= taskId or curMainUIVo.openTaskId == 0 or taskId == -1 then --当前没有主线的外，说明主线任务做完了，功能开启的任务都是主线类型
		-- 		curState = MainUIConst.MainUIItemState.Open
		-- 		zy("======= curState " , curState , curMainUIVo)
		-- 	end
		-- end

		if curMainUIVo.limitLev == 0 then
			if curMainUIVo.taskId == 0 then
				curState = MainUIConst.MainUIItemState.Open
			else
				if taskId == -1 or curMainUIVo.openTaskId <= taskId then
					curState = MainUIConst.MainUIItemState.Open
				end
			end
		else
			if curMainUIVo.taskId == 0 then
				if curMainUIVo.limitLev <= curPlayerLev then
					curState = MainUIConst.MainUIItemState.Open
				end
			else
				if curMainUIVo.limitLev <= curPlayerLev  then
					if taskId == -1 or curMainUIVo.openTaskId <= taskId then
						curState = MainUIConst.MainUIItemState.Open
					end
				end
			end
		end

		local oldState = curMainUIVo:GetState()
		curMainUIVo:SetState(curState)
		if oldState == 2 and curMainUIVo:GetState() == 1 then
		end
		if oldState  ~= curMainUIVo:GetState() then
			if (self:IsFirstRechargeModule(curMainUIVo:GetModuleId()) and FirstRechargeModel:GetInstance():IsShowIcon()) or
				(self:IsSevenLoginModule(curMainUIVo:GetModuleId()) and SevenLoginModel:GetInstance():IsClose()) or 
				(self:IsOpenGiftModule(curMainUIVo:GetModuleId()) and not OpenGiftModel:GetInstance():IsOpenActivity()) or
				(self:IsEquipmentStoreModule(curMainUIVo:GetModuleId()) and EquipmentStoreTipsModel:GetInstance():IsClose()) then
			 	 --zy("首充模块开启条件为等级、任务，但关闭条件为是否已经领取首充奖励")
			else
				self:DispatchEvent(MainUIConst.UIStateChange , {oldState = oldState , newMainUIVo = curMainUIVo})
			end
		end

		--审核版本，关掉部分功能
		if SHENHE and self:IsNotShenHeModule(curMainUIVo:GetModuleId()) then
			self:DispatchEvent(MainUIConst.UIStateChange , {oldState = oldState , newMainUIVo = curMainUIVo})
		end


	end
end

function MainUIModel:IsFirstRechargeModule(moduleId)
	local rtnIs = false
	if moduleId == FunctionConst.FunEnum.firstRecharge then
		rtnIs = true
	end
	return rtnIs
end

function MainUIModel:IsOpenGiftModule(moduleId)
	local rtnIs = false
	if moduleId == FunctionConst.FunEnum.OpenGift then
		rtnIs = true
	end
	return rtnIs
end

function MainUIModel:IsSevenLoginModule(moduleId)
	local rtnIs = false
	if moduleId == FunctionConst.FunEnum.SevenLogin then
		rtnIs = true
	end
	return rtnIs
end

function MainUIModel:IsEquipmentStoreModule(moduleId)
	local rtnIs = false
	if moduleId == FunctionConst.FunEnum.EquipStore then
		rtnIs = true
	end
	return rtnIs
end

function MainUIModel:GetMainUIVoList()
	return self.mainUIVoList or {}
end

function MainUIModel:GetMainUIVoListById(id)
	--return self.mainUIVoList[id] or {}
	local rtnVo = {}
	if id then
		for index = 1 , #self.mainUIVoList do
			local curVo = self.mainUIVoList[index]
			if curVo and curVo:GetModuleId() == id then
				rtnVo = curVo
				break
			end
		end
	end
	return rtnVo
end

function MainUIModel:SetCloseToMonsterState(state)
	if state ~= nil then
		self.isCloseToMonster = state
	end
end

function MainUIModel:IsCloseToMonster()
	return self.isCloseToMonster
end

--审核版本，交易行、VIP、充值、侍魂殿、仇敌系统关闭(交易行，vip，充值，仇敌只关闭页签，不关闭入口)
function MainUIModel:IsNotShenHeModule(moduleId)
	local rtnIsNot = false
	if moduleId == FunctionConst.FunEnum.ladder or
		moduleId == FunctionConst.FunEnum.vip then
		rtnIsNot = true
	end
	return rtnIsNot
end

function MainUIModel:__delete()
	-- body
	self:CleanEvent()
	if self.mainUIItemVoList then
		for index = 1 , #self.mainUIItemVoList do
			if self.mainUIItemVoList[index] then
				self.mainUIItemVoList[index]:Destroy()
			end
		end
		self.mainUIItemVoList = nil
	end
	self:ClearQuickList()
	MainUIModel.inst = nil
	self.isCloseToMonster = false
end
-- 已创建出的快捷装备被卸下或销毁
function MainUIModel:FilterExistList(id, bid)
	for k, v in pairs(self.quickEquipList) do
		if ( (not bid) and v:GetEquipId() == id ) or ( bid and bid == v:GetGoodsData()[2] ) then
			self.quickEquipList[k]:Destroy()
			self.quickEquipList[k] = nil
			self:DispatchEvent(MainUIConst.E_QuickEquipChange, nil)
		end
	end
end
-- 检测是否符合快捷穿戴条件
function MainUIModel:CheckEquipPush(tab)
	if tab and tab[1] and tab[1] < 0 and tab[2] and tab[2].equipId then
		self:FilterExistList(tab[2].equipId, tab[2].bid)
	end
	if (not tab[1]) or (not tab[2]) or (tab[2].goodsType ~= 1) then
		return false
	end
	if (not tab[2].isNew) or (tab[2].state ~= 1) or (tab[2].num < 1) then
		return false
	end
	local vo = tab[2]
	local equipInfo = PkgModel:GetInstance():GetEquipInfoByInfoId(vo.equipId)
	local curEquip = nil
	if equipInfo then
		curEquip = PkgModel:GetInstance():GetOnEquipByEquipType(equipInfo.equipType)
	end
	return self:CheckEquipInfo(equipInfo, curEquip)
end

function MainUIModel:CheckEquipInfo(equipInfo, curEquip)
	if not equipInfo then return false end
	local player = SceneModel:GetInstance():GetMainPlayer()
	local cfg = equipInfo:GetCfgData()
	if cfg.automatic and cfg.automatic == 0 then
		print("equip.automatic == 0")
		return false
	end
	-- 非本职业则return false
	if cfg.needJob ~= 0 and cfg.needJob ~= player.career then print("equip career not match") return false end
	-- 等级不够则 return false
	if player.level < cfg.level then print("equip level not match") return false end
	local newScore = equipInfo.score or 0
	-- 当前无该部位装备
	if not curEquip then
		return true, equipInfo
	end
	if newScore > curEquip.score then
		return true, equipInfo
	else
		print("new equip score not enough")
		return false
	end
end

-- 更新quickEquipList
function MainUIModel:RefreshQuickEquip(data)
	if (not data) or (not next(data)) then return end
	for bid, v in pairs(data) do
		if v[2] and v[2].goodsType ~= 1 then
			self:CheckQuickGoods(v)
		else
			local bPush, equipInfo = self:CheckEquipPush(v)
			if bPush then
				local tType = equipInfo.equipType
				local oldEquip = self.quickEquipList[tType]
				-- 非刚卸下的装备
				if not self:IsInUnEquipedList(equipInfo.bid) then
					if oldEquip then
						if equipInfo.score > oldEquip:GetScore() then
							self.quickEquipList[tType]:Destroy()
							self.quickEquipList[tType] = QuickEquipVo.New(equipInfo)
						end
					else
						self.quickEquipList[tType] = QuickEquipVo.New(equipInfo)
					end
				else
					self.unEquipedList = {}
				end
			end
		end
	end
	self:DispatchEvent(MainUIConst.E_QuickEquipChange, nil)
end

function MainUIModel:IsInUnEquipedList(id)
	if (not id) or (not self.unEquipedList) then return true end
	for _, v in pairs(self.unEquipedList) do
		if v == id then
			return true
		end
	end
	return false
end

function MainUIModel:EraseQuickEquip(tType)
	if self.quickEquipList and self.quickEquipList[tType] then
		self.quickEquipList[tType]:Destroy()
		self.quickEquipList[tType] = nil
	end
	self:DispatchEvent(MainUIConst.E_QuickEquipChange, nil)
end

function MainUIModel:GetQuickList()
	return self.quickEquipList
end

function MainUIModel:ClearQuickList()
	if not self.quickEquipList then return end
	for _, v in pairs(self.quickEquipList) do
		if v then
			v:Destroy()
			v = nil
		end
	end
	self.quickEquipList = nil
end
-- 将卸下的装备记录,背包获得该装备时清空该表
function MainUIModel:HandleEquipToBag(id)
	table.insert(self.unEquipedList, id)
end
-- 装上的装备在列表里消掉
function MainUIModel:HandleBagToEquip(id)
	self:FilterExistList(id)
end

-- 角色升级后检测一波快捷穿戴
function MainUIModel:OnMainPlayerUpgrade(curPlayerLev)
	local pkgModel = PkgModel:GetInstance()
	local gridItems = pkgModel:GetOnGrids()
	local tmpList = {}
	-- 先选出背包中未装备&&可装备的装备中每个部位评分最高的放到tmpList
	for _, vo in ipairs(gridItems) do
		if vo and vo.goodsType == GoodsVo.GoodType.equipment then
			local info = pkgModel:GetEquipInfoByGoodsVo(vo)
			if info then
				local tType = info.equipType
				-- 优先判断tmpList里的装备
				local curEquip = tmpList[tType]
				if not curEquip then
					-- 判断玩家身上的
					curEquip = PkgModel:GetInstance():GetOnEquipByEquipType(tType)
				end
				local bPush, equipInfo = self:CheckEquipInfo(info, curEquip)
				if bPush then
					tmpList[tType] = info
				end
			end
		end
	end
	for k, v in pairs(tmpList) do
		if self.quickEquipList[k] then
			self.quickEquipList[k]:Destroy()
		end
		self.quickEquipList[k] = QuickEquipVo.New(v)
	end
	self:DispatchEvent(MainUIConst.E_QuickEquipChange, nil)
end

--设置MainCityUI中activites的显示状态
function MainUIModel:SetActivitesUIState(uiStateEnum)
	if uiStateEnum then
		self.activitesUIState = uiStateEnum
	end
end

function MainUIModel:GetActivitesUIState()
	return self.activitesUIState 
end

function MainUIModel:Reset()
	self.isCloseToMonster = false --是否靠近boos怪物
	self.activitesUIState = MainUIConst.ActivitesUIState.None
	self:HandleMainPlayerDie()
	self:ResetPopCheck()
	self:CleanMainUIVoList()
	self:InitMainUIVoList()
	-- zy("====== MainUIModel:Reset " , self.mainUIVoList)
end

function MainUIModel:CleanMainUIVoList()
	for index = 1 , #self.mainUIVoList do
		self.mainUIVoList[index]:Destroy()
	end
	self.mainUIVoList = {}
end

--新增快捷物品
function MainUIModel:CheckQuickGoods(v)
	if v[1] and v[2] then
		if v[2].cfg or ( (not v[2].cfg) and v[2].bid ) then
			-- local send = true
			-- if v[2].cfg and v[2].cfg.useType and v[2].cfg.useType == 9 and StyleModel:GetInstance():IsActive(v[2].bid) and v[1] > 0 then
			-- 	send = false
			-- end
			-- if send then
				self:DispatchEvent(MainUIConst.E_QuickGoodsChange, {num = v[1], vo = v[2]})
			-- end
		end
	end
end

function MainUIModel:HandleMainPlayerDie(data)
	self:ClearQuickList()
	self.quickEquipList = {}
	self.unEquipedList = {}
end

function MainUIModel:UpdateRedTipsDataCache(data)
	if not TableIsEmpty(data) then
		local rtnIsHas , rtnIndex = self:IsContainsRedTips(data)
		if not rtnIsHas then
			table.insert(self.redTipsDataCache , data)
		else
			if rtnIndex ~= 0 and self.redTipsDataCache[rtnIndex] then
				self.redTipsDataCache[rtnIndex] = data
			end
		end
	end
end

function MainUIModel:IsContainsRedTips(data)
	local rtnIsContains = false
	local rtnIndex = 0
	if not TableIsEmpty(data) then
		for i , v in pairs(self.redTipsDataCache) do
			if (not TableIsEmpty(v)) and (v.moduleId == data.moduleId) then
				rtnIsContains = true
				rtnIndex = i
				break
			end
		end
	end
	return rtnIsContains , rtnIndex
end

function MainUIModel:CleanRedTipsDataCache()
	self.redTipsDataCache = {}
end

function MainUIModel:GetRedTipsDataCache()
	return self.redTipsDataCache
end

function MainUIModel:SetPopCheckState(state)
	self.popCheckState = state
end

function MainUIModel:GetPopCheckState()
	return self.popCheckState
end

function MainUIModel:ResetPopCheck()
	self:InitPopCheckList()
	self:SetPopCheckState(MainUIConst.PopCheckState.None)
end

function MainUIModel:GetPopCheckList()
	return self.popCheckList
end

function MainUIModel:InitPopCheckList()
	self.popCheckList = {}
	for i = 1, MainUIConst.PopModule.Max - 1 do
		self.popCheckList[i] = {checked = false}
	end
end
--接收弹出数据,缓存满后按顺序弹出,顺序暂定义在MainUIConst.PopModule
--@param : data.isClose 只有关闭弹出界面时为true,标识进入下一阶段
--		   data.show 接收阶段为true,标识是否需要显示
--		   data.data 如果show为true,则包含该弹出的回调openCb和参数args
--@usage: 先在MainUIConst.PopModule加枚举定义顺序,将原先弹出函数写成回调,派发消息,
--		  然后在弹出界面的析构中派发show为false,isClose为true的消息
function MainUIModel:HandlePopStateChange(data)
	if self:PopShowOver() or (not data) or (not data.id) then return end
	self.popCheckList[data.id].checked = true
	self.popCheckList[data.id].data = data
	if not data.show then
		--如果界面关闭,则检测下一阶段
		if data.isClose and self:GetPopCheckState() ~= MainUIConst.PopCheckState.ShowOver then
			self:DispatchEvent(MainUIConst.E_ShowPopStateChange, {show = true, index = data.id + 1})
		end
	end
	if self:CheckFull() then
		self:SetPopCheckState(MainUIConst.PopCheckState.Showing)
		self:DispatchEvent(MainUIConst.E_ShowPopStateChange, {show = true, index = 1})
	end
end

function MainUIModel:PopCheckOver()
	return self:GetPopCheckState() ~= MainUIConst.PopCheckState.None
end

function MainUIModel:PopShowOver()
	return self:GetPopCheckState() == MainUIConst.PopCheckState.ShowOver
end

function MainUIModel:CheckFull()
	if self:PopCheckOver() then return false end
	for i = 1, MainUIConst.PopModule.Max - 1 do
		if not self.popCheckList[i].checked then
			return false
		end
	end
	return true
end

--首充活动图标开关、以及图标对应的红点、特效
function MainUIModel:CloseFirstRecharge()
	GlobalDispatcher:DispatchEvent(EventName.MAINUI_RED_TIPS , {moduleId = FunctionConst.FunEnum.firstRecharge , state = false})
	local curMainUIVo = self:GetMainUIVoListById(FunctionConst.FunEnum.firstRecharge)
	oldState = curMainUIVo:GetState()
	curMainUIVo:SetState(MainUIConst.MainUIItemState.Close)
	self:DispatchEvent(MainUIConst.UIStateChange , {oldState = oldState , newMainUIVo = curMainUIVo})
end

function MainUIModel:CloseOpenGift()
	GlobalDispatcher:DispatchEvent(EventName.MAINUI_RED_TIPS , {moduleId = FunctionConst.FunEnum.OpenGift , state = false})
	local curMainUIVo = self:GetMainUIVoListById(FunctionConst.FunEnum.OpenGift)
	oldState = curMainUIVo:GetState()
	curMainUIVo:SetState(MainUIConst.MainUIItemState.Close)
	self:DispatchEvent(MainUIConst.UIStateChange , {oldState = oldState , newMainUIVo = curMainUIVo})
end

function MainUIModel:CloseSevenLogin()
	local curMainUIVo = self:GetMainUIVoListById(FunctionConst.FunEnum.SevenLogin)
	oldState = curMainUIVo:GetState()
	curMainUIVo:SetState(MainUIConst.MainUIItemState.Close)
	self:DispatchEvent(MainUIConst.UIStateChange , {oldState = oldState , newMainUIVo = curMainUIVo})
end

--获取屏幕右上角Activites各个功能的模块ID，以及对应的出现位置
--位置1-12为Activites的位置
function MainUIModel:GetActivitesPushNotice()
	local rtnData = {}
	local pushNoticeCfg = GetCfgData("pushNotice")
	for k , v in pairs(pushNoticeCfg) do
		if type(v) ~= 'function' then
			if v and v.apper > 0 and v.apper < 13 then
				table.insert(rtnData , v)
			end
		end
	end
	table.sort(rtnData , function (a , b)
		return a.apper < b.apper
	end)

	-- zwx("========= 获取屏幕右上角Activites各个功能的模块ID，以及对应的出现位置 " , rtnData)
	return rtnData
end


--主界面功能入口是否需要特效
function MainUIModel:IsNeedEffect(moduleId)
	local rtnIsCan = false
	if moduleId then
		if moduleId == FunctionConst.FunEnum.carnival or 
			moduleId == FunctionConst.FunEnum.firstRecharge or
			moduleId == FunctionConst.FunEnum.EquipStore   then
			rtnIsCan = true
		end
	end
	return rtnIsCan
end