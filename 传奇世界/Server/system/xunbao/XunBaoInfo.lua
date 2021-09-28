--XunBaoInfo.lua
--/*-----------------------------------------------------------------
 --* Module:  XunBaoInfo.lua
 --* Author:  HE Ningxu
 --* Modified: 2014年6月16日
 --* Purpose: Implementation of the class XunBaoInfo 
 -------------------------------------------------------------------*/

require ("base.class")
require ("system.xunbao.XunBaoConstants")
XunBaoInfo = class()

local prop = Property(XunBaoInfo)
prop:accessor("UID")
prop:accessor("SID")
prop:accessor("updateDB", false)		--是否需要更新数据库	20151020

function XunBaoInfo:__init(UID, SID)
	self._count = 0
	self._item = {}
	self._luck = 0
	self._time = 0 						--点亮的字保存的时间
	self._step = 0 						--点亮字的个数
	self._buyCount = 0 					--使用元宝刷新 次数
	self._reward = 0                   	--集字奖励的  物品ID
	self._rewardNum = 1 				--集字奖励的  物品数量
	self._free = 0 						--下一次免费元宝抽奖的时间
	self._xunbaocount = {0,0,0,0,0}		--20151019	单次寻宝符，单次免费元宝寻宝，单次元宝寻宝，元宝十连抽，寻宝符十连抽
	self._xunbaoAllcount = 0 				--20151019
	self._probability = {aPro=4,bPro=60}   	--A B 奖池的基本概率  十万分制
	self._xunbaoABNum = {aNum=1,bNum=1}		--A奖池未中次数		B奖池未中次数
	self._date = dateToday()
	prop(self, "UID", UID)
	prop(self, "SID", SID)

	self:refresh()    					--刷新集字奖励的物品
	--self:refresh()
end

function XunBaoInfo:refreshFree()
	local tmp = os.time()
	if self._free <= tmp then
		self._free = tmp + XUNBAO_FREE_TIME
		return true
	else
		return false
	end
end

function XunBaoInfo:getDropID(level, LIST)
	for index = 1, #LIST do
		if level <= LIST[index].lv then
			return LIST[index].id
		end
	end
end

function XunBaoInfo:refresh()
	local player = g_entityMgr:getPlayer(self:getUID())
	if player then
		local level = player:getLevel()
		local id = self:getDropID(level, XUNBAO_REFRESH_ID)
		local item = dropString(player:getSchool(), player:getSex(), id)

		if item and item[1] then
			self._reward = item[1].itemID
			self._rewardNum = item[1].count
		end
	end
end

function XunBaoInfo:addLuck(num)
	if self._step == 4 then return end
	if num == 1 then
		self._luck = self._luck + XUNBAO_LUCK_ADD
	end

	if num == 10 then
		local ret = math.random(XUNBAO_LUCK_MAX)
		if ret <= XUNBAO_LUCK_PROP[self._step] then
			self._step = self._step + 1
			self._luck = 0
			if self._step == 1 then
				self._time = os.time() + 24 * 60 * 60
			end
		end
	end
end

function XunBaoInfo:PushItem(itemID, slot, num)
	self._count = self._count + 1
	self._item[self._count] = {itemID, slot, num}
end

function XunBaoInfo:ZhaoHuan() --首次寻宝
	local player = g_entityMgr:getPlayer(self:getUID())
	if not player then return end
    local itemMgr = player:getItemMgr()
	if not itemMgr then return end
	
	--检察包裹空间
	local freeSlots = itemMgr:getEmptySize(BAG_INDEX_BAG)
    if (freeSlots < XUNBAO_NEED_SLOT+1) then
        g_XunBaoMgr:sendErrMsg2Client(self:getUID(), XUNBAO_ERR_NOSLOT, 0, {}) 
        return
    end
	
	--扣除寻宝材料
    local num = itemMgr:getItemCount(XUNBAO_MATERIAL_ID)
    if not isMatEnough(player, XUNBAO_MATERIAL_ID, XUNBAO_MATERIAL_NUM) then
	--if (num < XUNBAO_MATERIAL_NUM) then
        g_XunBaoMgr:sendErrMsg2Client(self:getUID(), XUNBAO_ERR_MATEIRIAL, 0, {})
        return
    end

    local ItemTmp = itemMgr:findItemByItemID(XUNBAO_MATERIAL_ID)  
	local ItemName = ""
	local BindTmp = 0
	if ItemTmp then
		ItemName = ItemTmp:getName()
		BindTmp = ItemTmp:isBinded() and 1 or 0
	end
	--itemMgr:destoryItem(XUNBAO_MATERIAL_ID, XUNBAO_MATERIAL_NUM, errorCode)
	costMat(player, XUNBAO_MATERIAL_ID, XUNBAO_MATERIAL_NUM, 105, BindTmp)
	
	--20151020
	if self._xunbaocount[1] then
		self._xunbaocount[1] = self._xunbaocount[1] + 1
	else
		self._xunbaocount[1] = 1
	end
	self._xunbaoAllcount = self._xunbaoAllcount + 1

	--活跃度标记
	g_ActivenessMgr:Act(self:getUID(), 12)
	--成就标记
	--g_achieveSer:notify(player:getSerialID(), AchieveType.Activity, AchieveEventType.ShakeReward, 1)
	--g_achieveSer:notify(player:getSerialID(), AchieveType.Activity, AchieveEventType.SilverBox, 1)
	--任务标记
	g_taskMgr:NotifyListener(player, "onLottery")
	
	--Tlog[LotteryFlow]
	g_tlogMgr:TlogLotteryFlow(player,0,0)

	--每次寻宝掉落一个太阳神水
	itemMgr:addItemByDropList(BAG_INDEX_BAG, XUNBAO_EVERY_DROPID, 105, 0)
	
	--寻宝
    self._count = 0
    local retStr = itemMgr:addItemByDropList(BAG_INDEX_BAG, XUNBAO_DROPS_ID_1, 105, 0)
	local item = unserialize(retStr)
	self:PushItem(item[1].itemID, item[1].slot, item[1].count)	
	self:Send(XUNBAO_WHITE_SINGLE)

    self:setUpdateDB(true)
	self:cast2DB()
end

function XunBaoInfo:ZhaoHuan1() --普通寻宝
	local player = g_entityMgr:getPlayer(self:getUID())
	if not player then return end
    local itemMgr = player:getItemMgr()
	if not itemMgr then return end
	
	--检察包裹空间
	local freeSlots = itemMgr:getEmptySize(BAG_INDEX_BAG)
    if (freeSlots < XUNBAO_NEED_SLOT+1) then
        g_XunBaoMgr:sendErrMsg2Client(self:getUID(), XUNBAO_ERR_NOSLOT, 0, {}) 
        return
    end
	
	--扣除寻宝材料
    local num = itemMgr:getItemCount(XUNBAO_MATERIAL_ID)
    if not isMatEnough(player, XUNBAO_MATERIAL_ID, XUNBAO_MATERIAL_NUM) then
	--if (num < XUNBAO_MATERIAL_NUM) then
        g_XunBaoMgr:sendErrMsg2Client(self:getUID(), XUNBAO_ERR_MATEIRIAL, 0, {})
        return
    end

    local ItemTmp = itemMgr:findItemByItemID(XUNBAO_MATERIAL_ID)  
	local ItemName = ""
	local BindTmp = 0
	if ItemTmp then
		ItemName = ItemTmp:getName()
		BindTmp = ItemTmp:isBinded() and 1 or 0
	end

	--itemMgr:destoryItem(XUNBAO_MATERIAL_ID, XUNBAO_MATERIAL_NUM, errorCode)
	costMat(player, XUNBAO_MATERIAL_ID, XUNBAO_MATERIAL_NUM, 105, BindTmp)
	
	--20151020
	if self._xunbaocount[1] then
		self._xunbaocount[1] = self._xunbaocount[1] + 1
	else
		self._xunbaocount[1] = 1
	end
	self._xunbaoAllcount = self._xunbaoAllcount + 1
	
	--活跃度标记
	g_ActivenessMgr:Act(self:getUID(), 12)
	--成就标记
	--g_achieveSer:notify(player:getSerialID(), AchieveType.Activity, AchieveEventType.ShakeReward, 1)
	--g_achieveSer:notify(player:getSerialID(), AchieveType.Activity, AchieveEventType.SilverBox, 1)
	--任务标记
	g_taskMgr:NotifyListener(player, "onLottery")
	
	--Tlog[LotteryFlow]
	g_tlogMgr:TlogLotteryFlow(player,1,0)

	--每次寻宝掉落一个太阳神水
	itemMgr:addItemByDropList(BAG_INDEX_BAG, XUNBAO_EVERY_DROPID, 105, 0)
	
	--寻宝
	self._count = 0
    local retStr = itemMgr:addItemByDropList(BAG_INDEX_BAG, XUNBAO_DROPS_ID_1, 105, 0)
	local item = unserialize(retStr)
	self:PushItem(item[1].itemID, item[1].slot, item[1].count)	
	self:Send(XUNBAO_WHITE_SINGLE)	

	self:setUpdateDB(true)
	self:cast2DB()
end

function XunBaoInfo:ZhaoHuan2() --珍稀寻宝
	local player = g_entityMgr:getPlayer(self:getUID())
	if not player then return end
    local itemMgr = player:getItemMgr()
	if not itemMgr then return end

	local level = player:getLevel()   
	
	--检察包裹空间
	local freeSlots = itemMgr:getEmptySize(BAG_INDEX_BAG)
    if (freeSlots <XUNBAO_NEED_SLOT+1) then
        g_XunBaoMgr:sendErrMsg2Client(self:getUID(), XUNBAO_ERR_NOSLOT, 0, {}) 
        return
    end
	
	local bFreeXunBao = false				--20150720	免费寻宝时  掉落ID不同
	local FreeXunBaoNum = 0					--免费寻宝次数
	local needmoney = 0

	--扣除元宝
	if not self:refreshFree() then
		local num = player:getIngot()
		if not isIngotEnough(player, XUNBAO_MATERIAL_NUM_1) then
		--if (num < XUNBAO_MATERIAL_NUM_1) then
			g_XunBaoMgr:sendErrMsg2Client(self:getUID(), XUNBAO_ERR_NOINGOT, 0, {})
			return
		end
		--player:setIngot(num - XUNBAO_MATERIAL_NUM_1)
		costIngot(player, XUNBAO_MATERIAL_NUM_1, 29)
		needmoney = XUNBAO_MATERIAL_NUM_1

		--成就标记
		--g_achieveSer:costIngot(player:getSerialID(), XUNBAO_MATERIAL_NUM_1)
		
		--消费记录
		g_PayRecord:Record(self:getUID(), -XUNBAO_MATERIAL_NUM_1, CURRENCY_INGOT, 3)
	else
		bFreeXunBao = true			--
		--FreeXunBaoNum = g_litterfunMgr:GetFreeXunBao(player:getSerialID())
		FreeXunBaoNum = tonumber(self._xunbaocount[2] or 0)
	end

	--活跃度标记
	g_ActivenessMgr:Act(self:getUID(), 12)
	--任务标记
	g_taskMgr:NotifyListener(player, "onLottery")
	
	--Tlog[LotteryFlow]
	g_tlogMgr:TlogLotteryFlow(player,2,needmoney)

	--成就标记
	--g_achieveSer:notify(player:getSerialID(), AchieveType.Activity, AchieveEventType.GoldBox, 1)

	--每次寻宝掉落一个太阳神水
	itemMgr:addItemByDropList(BAG_INDEX_BAG, XUNBAO_EVERY_DROPID, 29, 0)	
	
	--寻宝
    self._count = 0
    local bFreeXunBaoSpe = false
    --local CurDropIDList = XUNBAO_DROPS_ID_2	--20150720	免费寻宝时  掉落ID不同

    if bFreeXunBao then
    	if 0==FreeXunBaoNum then
	    	if self._xunbaocount[2] then		--20151020
				self._xunbaocount[2] = self._xunbaocount[2] + 1
			else
				self._xunbaocount[2] = 1
			end
			self._xunbaoAllcount = self._xunbaoAllcount + 1

	    	--第一次免费赤金灵匣  必掉本职业20级绿色武器
	    	local School = player:getSchool()
	    	local ItemIDList = {3010102,3020102,3030102}
	    	local ItemID = ItemIDList[School]

	    	local Ret,errorCode,slotRet = itemMgr:addItem(BAG_INDEX_BAG,ItemID,1,true,0,0,0,0)
			if Ret then
				local retStr = toString(ItemID)..' '..toString(1)..' '..toString(1)..' '..toString(0)..' '..toString(slotRet)
				local item = dropTable(retStr)
				if not item then return end

				self:PushItem(item.list[1].itemID, item.list[1].slot, 1)				
			    self:Send(XUNBAO_GOLDEN_SINGLE)

			    self:setUpdateDB(true)
				self:cast2DB()
			end
			return    
		end					
    end

    local CurDropID = 0
    if bFreeXunBao then
    	--CurDropIDList = XUNBAO_FREE_DROPS_ID_2
    	CurDropID = self:getDropID(level, XUNBAO_FREE_DROPS_ID_2)
   
    	if self._xunbaocount[2] then		--20151020
			self._xunbaocount[2] = self._xunbaocount[2] + 1
		else
			self._xunbaocount[2] = 1
		end
		self._xunbaoAllcount = self._xunbaoAllcount + 1
	else
		CurDropID = self:getABCDropID(level)
	    if self._xunbaocount[3] then		--20151020
			self._xunbaocount[3] = self._xunbaocount[3] + 1
		else
			self._xunbaocount[3] = 1
		end
		self._xunbaoAllcount = self._xunbaoAllcount + 1
    end 

	local retStr = itemMgr:addItemByDropList(BAG_INDEX_BAG, CurDropID, 29, 0)
	local item = unserialize(retStr)
	if #item <= 0 then
		return
	end
	self:PushItem(item[1].itemID, item[1].slot, item[1].count)	
	--增加幸运值
	--self:addLuck(1)	
    self:Send(XUNBAO_GOLDEN_SINGLE)	

    self:setUpdateDB(true)
	self:cast2DB()
end

function XunBaoInfo:ZhaoHuan3() --极品寻宝
	local player = g_entityMgr:getPlayer(self:getUID())
	if not player then return end
    local itemMgr = player:getItemMgr()
	if not itemMgr then return end
	
	local level = player:getLevel()    
	
	--检察包裹空间
	local freeSlots = itemMgr:getEmptySize(BAG_INDEX_BAG)
    if (freeSlots < XUNBAO_NEED_SLOT*10+1) then
        g_XunBaoMgr:sendErrMsg2Client(self:getUID(), XUNBAO_ERR_NOSLOT, 0, {}) 
        return
    end

	--扣除元宝
    local num = player:getIngot()
    if not isIngotEnough(player, XUNBAO_MATERIAL_NUM_2) then
    --if (num < XUNBAO_MATERIAL_NUM_2) then
        g_XunBaoMgr:sendErrMsg2Client(self:getUID(), XUNBAO_ERR_NOINGOT, 0, {})
        return
    end
    --player:setIngot(num - XUNBAO_MATERIAL_NUM_2)
    costIngot(player, XUNBAO_MATERIAL_NUM_2, 29)

	--消费记录
	g_PayRecord:Record(self:getUID(), -XUNBAO_MATERIAL_NUM_2, CURRENCY_INGOT, 3)
	
	--成就标记
	--g_achieveSer:costIngot(player:getSerialID(), XUNBAO_MATERIAL_NUM_2)
	--g_achieveSer:notify(player:getSerialID(), AchieveType.Activity, AchieveEventType.GoldBox, 10)

	--任务标记
	g_taskMgr:NotifyListener(player, "onLottery")
	
	--Tlog[LotteryFlow]
	g_tlogMgr:TlogLotteryFlow(player,3,XUNBAO_MATERIAL_NUM_2)

	 if self._xunbaocount[4] then		--20151020
		self._xunbaocount[4] = self._xunbaocount[4] + 10
	else
		self._xunbaocount[4] = 10
	end
	self._xunbaoAllcount = self._xunbaoAllcount + 10
	
	--每次寻宝掉落一个太阳神水
	itemMgr:addItemByDropList(BAG_INDEX_BAG, XUNBAO_EVERY_DROPID, 29, 0)
	
	--寻宝
    self._count = 0
	self._item = {}
	for i = 1, 10 do
		local CurDropID = self:getABCDropID(level)
		--local retStr = itemMgr:addItemByDropList(BAG_INDEX_BAG, self:getDropID(level, XUNBAO_DROPS_ID_3), 0)
		local retStr = itemMgr:addItemByDropList(BAG_INDEX_BAG,CurDropID,29,0)
		local item = unserialize(retStr)
		if item[1] then
			self:PushItem(item[1].itemID, item[1].slot, item[1].count)
		end
		--活跃度标记
		g_ActivenessMgr:Act(self:getUID(), 12)
	end	
	--增加幸运值
	self:addLuck(10)	
    self:Send(XUNBAO_GOLDEN_TEN)

    self:setUpdateDB(true)
	self:cast2DB()
end

function XunBaoInfo:ZhaoHuan4() --寻宝符10连抽
	local player = g_entityMgr:getPlayer(self:getUID())
	if not player then return end
    local itemMgr = player:getItemMgr()
	if not itemMgr then return end
	local level = player:getLevel()    

    --检察包裹空间
	local freeSlots = itemMgr:getEmptySize(BAG_INDEX_BAG)
    if (freeSlots < XUNBAO_NEED_SLOT*10+1) then
        g_XunBaoMgr:sendErrMsg2Client(self:getUID(), XUNBAO_ERR_NOSLOT, 0, {}) 
        return
    end

    --扣除寻宝材料
    local num = itemMgr:getItemCount(XUNBAO_MATERIAL_ID)
    if not isMatEnough(player, XUNBAO_MATERIAL_ID, XUNBAO_MATERIAL_NUM_3) then
	--if (num < XUNBAO_MATERIAL_NUM_3) then
        g_XunBaoMgr:sendErrMsg2Client(self:getUID(), XUNBAO_ERR_MATEIRIAL, 0, {})
        return
    end
    
	local ItemTmp = itemMgr:findItemByItemID(XUNBAO_MATERIAL_ID)  
	local ItemName = ""
	local BindTmp = 0
	if ItemTmp then
		ItemName = ItemTmp:getName()
		BindTmp = ItemTmp:isBinded() and 1 or 0
	end	

	--itemMgr:destoryItem(XUNBAO_MATERIAL_ID, XUNBAO_MATERIAL_NUM_3, errorCode)
	costMat(player, XUNBAO_MATERIAL_ID, XUNBAO_MATERIAL_NUM_3, 105, BindTmp)

	if self._xunbaocount[5] then
		self._xunbaocount[5] = self._xunbaocount[5] + 10
	else
		self._xunbaocount[5] = 10
	end
	self._xunbaoAllcount = self._xunbaoAllcount + 10
	
	--成就标记
	--g_achieveSer:notify(player:getSerialID(), AchieveType.Activity, AchieveEventType.ShakeReward, 1)
	--g_achieveSer:notify(player:getSerialID(), AchieveType.Activity, AchieveEventType.SilverBox, 10)

	--任务标记
	g_taskMgr:NotifyListener(player, "onLottery")
	
	--Tlog[LotteryFlow]
	g_tlogMgr:TlogLotteryFlow(player,4,0)

	--每次寻宝掉落一个太阳神水
	itemMgr:addItemByDropList(BAG_INDEX_BAG, XUNBAO_EVERY_DROPID, 105, 0)
	
	--寻宝
    self._count = 0
	self._item = {}
	for i = 1, 10 do
		local retStr = itemMgr:addItemByDropList(BAG_INDEX_BAG, XUNBAO_DROPS_ID_1, 105, 0)
		local item = unserialize(retStr)
		if item[1] then
			self:PushItem(item[1].itemID, item[1].slot, item[1].count)
		end
		--活跃度标记
		g_ActivenessMgr:Act(self:getUID(), 12)
	end	
    self:Send(XUNBAO_WHITE_TEN)
    self:setUpdateDB(true)
	self:cast2DB()		
end

function XunBaoInfo:Send(style)
	local player = g_entityMgr:getPlayer(self:getUID())
	if not player then return end
    
	local buff = LuaEventManager:instance():getLuaRPCEvent(XUNBAO_SC_ZHAOHUAN)
	buff:pushInt(style)
    buff:pushInt(self._step)
	buff:pushInt(math.max((self._time - os.time()), 0))
	buff:pushInt(math.max((self._free - os.time()), 0))
	buff:pushInt(self._count)
	for i = 1, self._count do
        buff:pushInt(self._item[i][2])
        buff:pushInt(self._item[i][3])
    end
    g_engine:fireLuaEvent(self:getUID(), buff)
end

function XunBaoInfo:switchOut(peer, dbid, mapID)
	local luaBuf = g_buffMgr:getLuaEventEx(LOGIN_WW_SWITCH_WORLD)
	luaBuf:pushInt(dbid)
	luaBuf:pushShort(EVENT_XUNBAO_SETS)
	--具体数据跟在后面
	luaBuf:pushInt(self._luck)
	luaBuf:pushInt(self._reward)
	luaBuf:pushInt(self._rewardNum)	
	luaBuf:pushInt(self._free)
	luaBuf:pushInt(self._time)
	luaBuf:pushInt(self._step)
	luaBuf:pushInt(self._buyCount)
	luaBuf:pushInt(self._xunbaoAllcount)
	luaBuf:pushString(serialize(self._date))
	luaBuf:pushString(serialize(self._xunbaocount))
	luaBuf:pushString(serialize(self._xunbaoABNum))

	g_engine:fireSwitchBuffer(peer, mapID, luaBuf)
end

function XunBaoInfo:switchIn(luabuf)
	if luabuf:size() > 0 then
		self._luck = luabuf:popInt()
		self._reward = luabuf:popInt()
		self._rewardNum = luabuf:popInt()		
		self._free = luabuf:popInt()
		self._time = luabuf:popInt()
		self._step = luabuf:popInt()
		self._buyCount = luabuf:popInt()
		self._xunbaoAllcount = luabuf:popInt()
		self._date = unserialize(luabuf:popString())
		self._xunbaocount = unserialize(luabuf:popString())
		self._xunbaoABNum = unserialize(luabuf:popString())
	end
	self:initABNums(g_XunBaoMgr._aProBasic,g_XunBaoMgr._bProBasic)
end

function XunBaoInfo:loadDBdata(param)
	--{roleID = 905000040, count = "{0,0,0,0}", datas = "{b=0,f=0,s=0,r=4019,d={2015,10,19},l=0,t=0}"}
	--20151019
	if param.datas then	
		local data = unserialize(param.datas)	--param.datas
		self._luck = data.l
		self._date = data.d
		self._free = data.f
		self._time = data.t
		self._step = data.s
		self._xunbaocount = data.nums or {0,0,0,0,0}	
		self._xunbaoABNum = data.abNums or {aNum=1,bNum=1}
	end
	if param.count then
		self._xunbaoAllcount = param.count 	--unserialize(param.count)
	end
end

function XunBaoInfo:cast2DB()
	return
	--[[local player = g_entityMgr:getPlayer(self:getUID())
	if not player then
		return
	end

	local RoleSID = player:getSerialID()
	--local dbStr = {l = self._luck, r = self._reward, rn = self._rewardNum, b = self._buyCount, s = self._step, t = self._time, d = self._date, f = self._free, nums = self._xunbaocount}
	local dbStr = {l=self._luck,s=self._step,t=self._time,d=self._date,f=self._free,nums=self._xunbaocount,abNums=self._xunbaoABNum}
	--g_entityDao:updateRole(self:getSID(), serialize(dbStr), "xunbao")

	if self:getUpdateDB() then
		local params =
		{
			{
			rId  = player:getSerialID(),
			_datas = serialize(dbStr),
			_count = self._xunbaoAllcount,
			spName = "sp_UpdateXunbao",
			dataBase = 1,
			sort = "rId,_datas,_count",
			}
		}
		local operationID = apiEntry.exeSP(params, true)
		self:setUpdateDB(false)
	end]]
end

function XunBaoInfo:getXunbaoAllCount()
	if not self._xunbaoAllcount then
		self._xunbaoAllcount = 0
	end

	return self._xunbaoAllcount
end

function XunBaoInfo:initABNums(Apro,Bpro)
	if Apro>0 then		
		self._probability.aPro = Apro
	end

	if Bpro>0 then
		self._probability.bPro = Bpro
	end
end

function XunBaoInfo:getABCDropID(level)
	local aNum = self._xunbaoABNum.aNum
	local bNum = self._xunbaoABNum.bNum
	local curNum = math.random(XUNBAO_REWARD_BASIC)

	if curNum<=aNum*self._probability.aPro then
		self._xunbaoABNum.aNum = 1
		return self:getDropID(level,XUNBAO_A_DROP_ID)
	end
	self._xunbaoABNum.aNum = self._xunbaoABNum.aNum + 1

	curNum = math.random(XUNBAO_REWARD_BASIC)

	if curNum<=bNum*self._probability.bPro then
		self._xunbaoABNum.bNum = 1
		return self:getDropID(level,XUNBAO_B_DROP_ID)		
	end
	self._xunbaoABNum.bNum = self._xunbaoABNum.bNum + 1

	return self:getDropID(level,XUNBAO_C_DROP_ID)
end