--[[
******游戏数据帮派后山管理类*******

	-- by yao
	-- 2015/12/25
]]


local HoushanManager = class("HoushanManager")

HoushanManager.EVENT_UPDATE_HOUSHAN = "HoushanManager.EVENT_UPDATE_HOUSHAN"
HoushanManager.EVENT_UPDATE_HOUSHANREWARDEFFECT = "HoushanManager.EVENT_UPDATE_HOUSHANREWARDEFFECT"
HoushanManager.EVENT_UPDATE_HOUSHANDETAIL = "HoushanManager.EVENT_UPDATE_HOUSHANDETAIL"


function HoushanManager:ctor( Data )
	self:init(Data)
	self.houshanList = require("lua.table.t_s_guild_zone_checkpoint")
	self.guildzonedpsaward = require("lua.table.t_s_guild_zone_dps_award")
	self.guildzone = require("lua.table.t_s_guild_zone")
	TFDirector:addProto(s2c.LOCKED_ZONE_SUCESS, self,self.lockedZoneSucess)
	TFDirector:addProto(s2c.UNLOCK_ZONE_SUCESS, self,self.unLockedZoneSucess)
	self.chapter = nil
	self.bossIndex = nil
	self.isClock = false
end

function HoushanManager:init( Data )
	
end

--进入boss章节界面
function HoushanManager:showHoushanLayer(chapter)
	-- body
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.faction.HoushanLayer");
    layer:loadData(chapter);
    AlertManager:show();
end

--进入boss信息界面
function HoushanManager:showDetailLayer(chapter,bossIndex)
	-- body
	local layer =  AlertManager:addLayerToQueueAndCacheByFile("lua.logic.faction.HoushanBossDetail",AlertManager.BLOCK);
    layer:setData(chapter,bossIndex);
    AlertManager:show();
end

--获取全部章节信息
function HoushanManager:getHoushanInfoList()
	-- body
	local houshanInfolist = {}
	for v in self.houshanList:iterator() do
		table.insert(houshanInfolist,v)
	end
	return houshanInfolist
end

--获得章节数量
function HoushanManager:getHoushanChapterNum()
	-- body
	local chapter = {}
	for v in self.houshanList:iterator() do
		if next(chapter) ~= 0 then
			local ishave = false
			for m,n in pairs(chapter) do
				if n == v.zone_id then
					ishave = true
					break
				end
			end
			if ishave == false then
				table.insert(chapter,v.zone_id)
			end	
		else
			table.insert(chapter,v.zone_id)
		end
	end
	return #chapter
end

--根据章节Id获取boss列表
function HoushanManager:getHoushanListByZoneId(zoneId)
	-- body
	local oneChapterbossList = {}
	for v in self.houshanList:iterator() do
		if v.zone_id == zoneId then
			table.insert(oneChapterbossList,v)
		end
	end
	return oneChapterbossList
end

--获取伤害奖励数据
function HoushanManager:getGuildZoneDpsAward()
	-- body
	local zonedpsaward = {}
	for v in self.guildzonedpsaward:iterator() do
		table.insert(zonedpsaward,v)
	end
	return zonedpsaward
end

--根据章节获取伤害还奖励数据
function HoushanManager:getGuildZoneDpsAwardByZoneId(zoneId)
	-- body
	local zonedpsawardInfo = {}
	local zonedpsaward = {}
	for n in self.guildzonedpsaward:iterator() do
		table.insert(zonedpsaward,n)
	end
	for k,v in pairs(zonedpsaward) do
		if v.zone_id == zoneId then
			table.insert(zonedpsawardInfo,v)
		end
	end
	return zonedpsawardInfo 
end

--获取章节数据
function HoushanManager:getGuildZone()
	-- body
	local guildzoneinfo = {}
	for v in self.guildzone:iterator() do
		table.insert(guildzoneinfo,v)
	end
	return guildzoneinfo
end

--获取挑战掉落奖励
function HoushanManager:getDropItemListByBossInfo(Info)
    return DropGroupData:GetDropItemListByIdsStr(Info.drops)
end

function HoushanManager:restart()
	-- body
	--self.houshanList = {}
end

--根据章节获取服务器返回章节数据
function HoushanManager:getGuildZoneInfoByZoneId(zoneId)
	-- body
	local guildZoneInfo = FactionManager:getZoneBaseInfo()
	local oneGuildZoneInfo = guildZoneInfo[zoneId]
	return oneGuildZoneInfo
end

--根据章节获取服务器返回人物数据
function HoushanManager:getZonePersonalInfoByZoneId(zoneId)
	-- body
	local oneZonePersonalInfo = nil
	local zonePersonalInfo = FactionManager:getZonePersonalInfo()
	if zonePersonalInfo ~= nil then
		for k,v in pairs(zonePersonalInfo) do
			if v.zoneId == zoneId then
				oneZonePersonalInfo = v
			end		
		end
	end
	return oneZonePersonalInfo
end

--设置关卡章节和第几个boss
function HoushanManager:setHoushanUnlockBossInfo(chapter,bossIndex)
	-- body
	self.chapter = chapter
	self.bossIndex = bossIndex
end

--获得挑战的关卡和bossId
function HoushanManager:getHoushanChapterAndBossId()
	-- body
	local houshanInfo = self:getHoushanListByZoneId(self.chapter)
	local checkpoint_id = houshanInfo[self.bossIndex].checkpoint_id
	local info = {chapter = self.chapter,checkpointid = checkpoint_id }

	print('getHoushanChapterAndBossIdinfo = ',info)
	return info
end


--设置副本解锁信息
function HoushanManager:setZoneIsClock(clock)
	-- body
	self.isClock = clock
end

--获取副本解锁信息
function HoushanManager:getZoneIsClock()
	-- body
	return self.isClock
end

-- --挑战结束回到后山boss界面
-- function HoushanManager:setBackToHoushanBossLayer()
-- 	-- body
-- end

--挑战到十分钟回到后山boss章节界面
function HoushanManager:setTenMinuteBackBossLayer(layer)
	-- body
	local time = 10
	-- local str = TFLanguageManager:getString(ErrorCodeData.Zone_time_out_ten_minute)
 --    str = string.format(str,time)
 
 	local str = stringUtils.format(localizable.Zone_time_out_ten_minute,time)

	CommonManager:showOperateSureLayer(
        function()                
        end,
        function()
            AlertManager:closeAllToLayer(layer)
        end,
        {
        title = localizable.common_tips, --"提示" ,
        msg = str,
        uiconfig = "lua.uiconfig_mango_new.common.OperateSure1"
        }
    )
end

--在boss详情界面两分钟回到后山boss章节界面
function HoushanManager:setTwoMinuteBackBossLayer(layer)
	-- body
	local time = 2
	-- local str = TFLanguageManager:getString(ErrorCodeData.Zone_time_out_two_minute)
 --    str = string.format(str,time)

 	local str = stringUtils.format(localizable.Zone_time_out_ten_minute,time)

	CommonManager:showOperateSureLayer(
        function()                
        end,
        function()
            AlertManager:closeAllToLayer(layer)
        end,
        {
        title = localizable.common_tips, --"提示" ,
        msg = str,
        uiconfig = "lua.uiconfig_mango_new.common.OperateSure1"
        }
    )
end

--在结算界面十秒回到后山boss界面
function HoushanManager:setTenSecondBackBossLayer()
	-- body

	local time = 20
	-- local str = TFLanguageManager:getString(ErrorCodeData.Zone_time_out_ten_second)
 --    str = string.format(str,time)

 	local str = stringUtils.format(localizable.Zone_time_out_ten_minute,time)
 	
	CommonManager:showOperateSureLayer(
        function()                
        end,
        function()
            AlertManager:close()
        end,
        {
        title = localizable.common_tips, --"提示" ,
        msg = str,
        uiconfig = "lua.uiconfig_mango_new.common.OperateSure1"
        }
    )
end

--挑战副本请求
function HoushanManager:requestTiaozhan(zone_id, checkpoint_id,fightTpye)
	if fightTpye == nil then
		fightTpye = 0
	end
	local Msg = {
		zone_id,
		checkpoint_id,
		fightTpye,
	}
	TFDirector:send(c2s.CHALLENGE_GUILD_CHECKPOINT,Msg)
	showLoading()
end

--锁定副本请求
function HoushanManager:lockedZone(zone_id)
	local Msg = {
		zone_id,
	}
	TFDirector:send(c2s.LOCKED_ZONE,Msg)
	showLoading()
end

--解锁副本请求
function HoushanManager:unlockZone(zone_id)
	local Msg = {
		zone_id,
	}
	TFDirector:send(c2s.UNLOCK_ZONE,Msg)
	showLoading()
end

--锁定副本返回消息
function HoushanManager:lockedZoneSucess(event)
	-- body
	
	hideLoading()
	self:showDetailLayer(self.chapter,self.bossIndex)
	--self.chapter = nil
	--self.bossIndex = nil
	self.isClock = true
end

--解锁定副本返回消息
function HoushanManager:unLockedZoneSucess()
	-- body
	hideLoading()
	self.isClock = false
end

return HoushanManager:new()
