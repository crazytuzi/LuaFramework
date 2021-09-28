--WingManager.lua
--/*-----------------------------------------------------------------
 --* Module:  WingManager.lua
 --* Author:  seezon
 --* Modified: 2014年6月9日
 --* Purpose: 光翼管理器
 -------------------------------------------------------------------*/
require ("system.wing.WingServlet")
require ("system.wing.RoleWingInfo")
require ("system.wing.WingConstant")
require ("system.wing.WingEventParse")
require ("system.wing.LuaWingDAO")
	
WingManager = class(nil, Singleton)
--全局对象定义
g_wingServlet = WingServlet.getInstance()
g_LuaWingDAO = LuaWingDAO.getInstance()

function WingManager:__init()
	self._roleWingInfos = {} --运行时ID
	self._roleWingInfoBySID = {} --数据库ID
	self._operIdMap = {} --数据库操作ID映射
	g_listHandler:addListener(self)
end

--玩家上线
function WingManager:onPlayerLoaded(player)
	local roleID = player:getID()
	local roleSID = player:getSerialID()
	memInfo = RoleWingInfo()
	memInfo:setRoleID(roleID)
	memInfo:setRoleSID(roleSID)
	self._roleWingInfos[roleID] = memInfo
	self._roleWingInfoBySID[roleSID] = memInfo	
    
    --加载数据库的数据
	self:loadWing(roleSID)
end

function WingManager:loadWing(roleSID)
	if roleSID ~= "" then
		g_entityDao:loadWing(roleSID)
	end
end

--数据库回调
function WingManager:onloadWingRole(roleSID, data)	
	local memInfo = self:getRoleWingInfoBySID(roleSID)

	if memInfo then
		memInfo:loadWingRole(data)
	end

	local player = g_entityMgr:getPlayerBySID(roleSID)
	if player then
		g_teamMgr:loadTeamInfo(player)
	end
end

function WingManager:firstActiveWing(player)
	local memInfo = self:getRoleWingInfo(player:getID())
	
	if not memInfo or not player then
		return false
	end
	
	if not memInfo:getCurWingID() then
		memInfo:cast2DB()--第一次要存下数据库的
		local school = player:getSchool()
		local wingID = 0
		if school == 1 then
			wingID = ZHAN_FIRST_WING_ID --战士初始光翼
		elseif school == 2 then
			wingID = FA_FIRST_WING_ID --法师初始光翼
		elseif school == 3 then
			wingID = DAO_FIRST_WING_ID	--道士初始光翼
		end

		memInfo:setCurWingID(wingID)
		player:setCurWingID(wingID)
		self:loadProp(player, wingID)
		memInfo:battleChange()
		

		local ret = {}
		ret.wingID = wingID
		fireProtoMessage(player:getID(), WING_SC_FIRST_ACTIVE, 'WingFirstActiveProtocol', ret)

		--如果有新的技能格，就激活它
		local wingProto = g_LuaWingDAO:getPrototype(wingID)
		if tonumber(wingProto.q_activeSkill) > 0 then
		    memInfo:activeSkill(tonumber(wingProto.q_activeSkill))
		end

		--成就监听
		local level = self:getWingLevel(player:getSerialID())
		
		g_achieveSer:achieveNotify(player:getSerialID(), AchieveNotifyType.UpWing, level)

		g_achieveSer:achieveNotify(player:getSerialID(), AchieveNotifyType.getWing, 1)
		g_ActivityMgr:sevenFestivalChange(player:getID(), ACTIVITY_ACT.WINGTASK, 1)
		g_ActivityMgr:sevenFestivalChange(player:getID(), ACTIVITY_ACT.WINGUP, 1)
		return true
	end
	return false
end

function WingManager:getWingActiveState(roleSID)
	local memInfo = self:getRoleWingInfoBySID(roleSID)
	
	if not memInfo then
		return false
	end

	if not memInfo:getCurWingID() then
		return false
	end

	if memInfo:getCurWingID() > 0 then
		return true
	end

	return false
end

--玩家下线
function WingManager:onPlayerOffLine(player)
	local roleSID = player:getSerialID()
	local roleID = player:getID()
	local memInfo = self:getRoleWingInfoBySID(roleSID)
	if memInfo then
		--保存光翼数据到数据库
		memInfo:cast2DB()
		self._roleWingInfos[roleID] = nil
		self._roleWingInfoBySID[roleSID] = nil
	end
end

--玩家学习或升级技能
function WingManager:learnSkill(roleID, pos)
	local memInfo = self:getRoleWingInfo(roleID)
	if memInfo then
		memInfo:learnSkill(pos)
	end
end

--光翼进阶
function WingManager:promoteWing(roleID, onceUp)
	local player = g_entityMgr:getPlayer(roleID)
	local roleSID = player:getSerialID()
	local roleID = player:getID()
	local memInfo = self:getRoleWingInfoBySID(roleSID)
	if not memInfo then
		return
	 end	
	
    local errId = 0 --默认是成功的
	
    if not memInfo:getCurWingID() then
        return
    end
    local wingProto = g_LuaWingDAO:getPrototype(memInfo:getCurWingID())
    local nextWingID = tonumber(wingProto.q_nextID)

	local needMaterialNum = tonumber(wingProto.q_needNum)
	local needMoney = tonumber(wingProto.q_needMoney) * needMaterialNum

    --没有下一阶就是当前最高阶了
    if (not nextWingID) or nextWingID == 0 then
        errId = WING_ERR_MAX_LEVEL
    else
        if player:getLevel() < tonumber(wingProto.q_needLevel) then
			errId = WING_ERR_NOT_ENOUGH_LEVEL
        else
            local itemMgr = player:getItemMgr()
			--判断材料够不够
			local materialID = tonumber(wingProto.q_materialID)
			if isMatEnough(player, materialID, needMaterialNum) then
				if wingProto.q_advID and wingProto.q_advNum then
					if not isMatEnough(player, tonumber(wingProto.q_advID), tonumber(wingProto.q_advNum)) then
						errId = WING_ERR_NOT_ENOUGH_MATERIAL
					end
				end
			else
                errId = WING_ERR_NOT_ENOUGH_MATERIAL
            end
			
			--判断钱够不够
			if not isMoneyEnough(player, needMoney) then
				errId = WING_ERR_NOT_ENOUGH_MONEY
			end
        end
    end

    if errId == 0 then
        local ret = self:dealPomote(roleSID, needMoney)

		local retTB = {}
		retTB.ret = ret
		retTB.promoteTime = memInfo:getPomoteTime()
		fireProtoMessage(roleID, WING_SC_PROMOTE_RET, 'WingPromoteRetProtocol', retTB)
	else
		local ret = {}
		fireProtoMessage(roleID, WING_SC_PROMOTE_CONDITION_FAIL, 'WingPromoteConditionFailProtocol', ret)
		
		if errId == WING_ERR_NOT_ENOUGH_LEVEL then
			g_wingServlet:sendErrMsg2Client(roleID, errId, 1, {wingProto.q_needLevel})
		else
			g_wingServlet:sendErrMsg2Client(roleID, errId, 0)
		end
    end
end

function WingManager:dealPomote(roleSID)
    local memInfo = self:getRoleWingInfoBySID(roleSID)
    local player = g_entityMgr:getPlayerBySID(roleSID)
	local roleID = player:getID()

    local wingProto = g_LuaWingDAO:getPrototype(memInfo:getCurWingID())

	local needMaterialNum = tonumber(wingProto.q_needNum)
	local needMoney = tonumber(wingProto.q_needMoney) * needMaterialNum

    --扣除材料，金钱元宝等
	local errId = 0
	local materialID = tonumber(wingProto.q_materialID)
	costMat(player, materialID, needMaterialNum, 34, 0)
	if wingProto.q_advID and wingProto.q_advNum then
		costMat(player, tonumber(wingProto.q_advID), tonumber(wingProto.q_advNum), 34, 0)
	end
	costMoney(player, needMoney, 34)
	
	--通知任务系统
	g_taskMgr:NotifyListener(player, "onWingPromote")

	g_achieveSer:achieveNotify(roleSID, AchieveNotifyType.promotWing, 1)

	--清理数据
	memInfo:setPomoteTime(0)
	local oldLevel = self:getWingLevel(roleSID)
	--先卸载属性，换新的光翼后再加载属性
	self:unloadProp(player, memInfo:getCurWingID())
	memInfo:setCurWingID(wingProto.q_nextID)
	memInfo:setSuccessTime(os.time())
	--如果戴着光翼，需要刷新
	if memInfo:getWingState() then
		player:setWingID(wingProto.q_nextID)
	end
	player:setCurWingID(wingProto.q_nextID)
	self:loadProp(player, wingProto.q_nextID)
	local oldBattle = player:getbattle()
	memInfo:battleChange()

	--成就监听
	local proto = LuaWingDAO.getInstance():getPrototype(wingProto.q_nextID)
	local level = self:getWingLevel(roleSID)
	
	--如果有新的技能格，就激活它
	local nextWingProto = g_LuaWingDAO:getPrototype(wingProto.q_nextID)
	if tonumber(nextWingProto.q_activeSkill) > 0 then
		memInfo:activeSkill(tonumber(nextWingProto.q_activeSkill))
	end

	memInfo:cast2DB()
	g_ActivityMgr:sevenFestivalChange(player:getID(), ACTIVITY_ACT.WINGUP, level)

	g_MainObjectMgr:notify(roleSID, MainObjectType.wing, level, proto.q_star)
	if oldLevel ~= level then
		g_RedBagMgr:WingLevelUp(player, level)
		g_achieveSer:achieveNotify(roleSID, AchieveNotifyType.UpWing, level)

		if onceUp then
			g_achieveSer:achieveNotify(roleSID, AchieveNotifyType.autoPromotWing, 1)
		end
	end
	g_engine:notifyPlayerAttribs(player:getSerialID())
	local newBattle = self:calWingBattle(player:getID(), memInfo:getCurWingID()) or 0

    return true
end

--掉线登陆
function WingManager:onActivePlayer(player)
	local memInfo = self:getRoleWingInfoBySID(player:getSerialID()) 
	if not memInfo then
	return
    end
    memInfo:notifyClientLoadData(true)
end

--加载光翼属性
function WingManager:loadProp(player, wingID)
    local wingProto = g_LuaWingDAO:getPrototype(wingID)
    if not wingProto then  
        return
    end    
    --加载装备本身的属性
	changPlayerProp(player, wingProto, true)
end

--卸载光翼属性
function WingManager:unloadProp(player, wingID)
    local wingProto = g_LuaWingDAO:getPrototype(wingID)
    if not wingProto then  
        return
    end    
    --卸载装备本身的属性
	changPlayerProp(player, wingProto, false)
end

--获取Wing关系
function WingManager:writrWingInfo(roleID, luaBuff)
    local memInfo = self:getRoleWingInfo(roleID)
    if memInfo then
		local data = memInfo:writrWingInfo()
		luaBuff:pushLString(data, #data)
	else
		luaBuff:pushString("")
	end
end

--获取玩家数据
function WingManager:getRoleWingInfo(roleID)
	return self._roleWingInfos[roleID]
end

--获取玩家数据通过数据库ID
function WingManager:getRoleWingInfoBySID(roleSID)
	return self._roleWingInfoBySID[roleSID]
end

function WingManager.getWingID(roleID)
	local wingInfo = WingManager.getInstance():getRoleWingInfo(roleID)
	if wingInfo then
		return wingInfo:getCurWingID()
	else
		return 0
	end
end

--计算光翼战斗力
function WingManager:calWingBattle(roleID, wingId)
	local player = g_entityMgr:getPlayer(roleID)

	if not player then
		return
	end
	local wingProto = g_LuaWingDAO:getPrototype(wingId)

	if not wingProto then
		return
	end

	local battvals= require "data.AttrBattleDB"
	local sch = player:getSchool()
	local con = battvals[sch]
	local total=0
	if con then
		local luck = player:getLuck()
		if sch == 1 then
			total = total + math.floor(((tonumber(wingProto.q_attack_min) or 0) + (tonumber(wingProto.q_attack_max) or 0))/2)*tonumber(con.q_attack)
		elseif sch == 2 then
			total = total + math.floor(((tonumber(wingProto.q_magic_attack_min) or 0) + (tonumber(wingProto.q_magic_attack_max) or 0))/2)*tonumber(con.q_magic_attack)
		elseif sch == 3 then
			total = total + math.floor(((tonumber(wingProto.q_sc_attack_min) or 0) + (tonumber(wingProto.q_sc_attack_max) or 0))/2)*tonumber(con.q_sc_attack)
		end
		
		total = total + math.ceil(((tonumber(wingProto.q_defence_min) or 0) + (tonumber(wingProto.q_defence_max) or 0))/2)*tonumber(con.q_defence)
		total = total + math.ceil(((tonumber(wingProto.q_magic_defence_min) or 0) + (tonumber(wingProto.q_magic_defence_max) or 0))/2)*tonumber(con.q_magic_defence)
		total = total + (tonumber(wingProto.q_max_hp) or 0)*tonumber(con.q_max_hp)
		total = total + (tonumber(wingProto.q_hit) or 0)*tonumber(con.q_hit)
		total = total + (tonumber(wingProto.q_dodge) or 0)*tonumber(con.q_dodge)
		total = total + (tonumber(wingProto.q_luck) or 0)*tonumber(con.q_luck)

	end
	return total
end

--GM CMD use
function WingManager:dealPomoteGM(roleSID, wingID)
	local player = g_entityMgr:getPlayerBySID(roleSID)
	local roleID = player:getID()
	local memInfo = self:getRoleWingInfoBySID(roleSID)
	
	if not memInfo then return end


	if not memInfo:getCurWingID() then
		local ret = {}
		ret.wingID = wingID
		fireProtoMessage(player:getID(), WING_SC_FIRST_ACTIVE, 'WingFirstActiveProtocol', ret)
	end

	--清理数据
	memInfo:setPomoteTime(0)

	--先卸载属性，换新的光翼后再加载属性
	self:unloadProp(player, memInfo:getCurWingID())
	
	memInfo:setCurWingID(wingID)
	player:setWingID(wingID)
	self:loadProp(player, wingID)
	memInfo:battleChange()
	
	memInfo:GMlearnSkill()
	local retTB = {}
	retTB.ret = true
	retTB.promoteTime = memInfo:getPomoteTime()
	fireProtoMessage(roleID, WING_SC_PROMOTE_RET, 'WingPromoteRetProtocol', retTB)

	memInfo:cast2DB()
end

--GM CMD use
function WingManager:learnSkillGM(roleSID, pos, level)
	local player = g_entityMgr:getPlayerBySID(roleSID)
	local roleID = player:getID()
	local memInfo = self:getRoleWingInfoBySID(roleSID)
	
	if not memInfo then return end
	local wingProto = g_LuaWingDAO:getPrototype(memInfo:getCurWingID())
	if not wingProto then
		return
	end
    
	memInfo:GMlearnSkill(pos, level)
end

--获取仙翼等级
function WingManager:getWingLevel(roleSID)
	local wingInfo = self:getRoleWingInfoBySID(roleSID)
	if not wingInfo or not wingInfo:getCurWingID() then
		return 0
	end
	local wingID = wingInfo:getCurWingID()
	return math.floor(math.mod(wingID, 100) / 10)
end

function WingManager:parseWingData()
	package.loaded["data.WingDB"]=nil
	local tmpData = require "data.WingDB"

	if tmpData then
		for i=1, #tmpData do
			local data = tmpData[i]
			if g_LuaWingDAO._staticWings[data.q_ID] then
				table.deepCopy1(data, g_LuaWingDAO._staticWings[data.q_ID])
			else
				g_LuaWingDAO._staticWings[data.q_ID] = data
			end
		end
	end
end

function WingManager.getInstance()
	return WingManager()
end

g_wingMgr = WingManager.getInstance()