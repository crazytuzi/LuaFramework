--[[
******排行榜数据管理类*******

	-- by quanhuan
	-- 2015/9/5
]]

local RankManager = class("RankManager")

RankManager.GETRANKDATADONE = "RankManager.getRankDataDone"
RankManager.POST_MSG_BOSSFIGHT = "RankManager.postMsgForBossFight"
RankManager.GetFactionList = "RankManager.GetFactionList"

function RankManager:ctor(data)

	
	--绑定英雄榜消息回调
	TFDirector:addProto(s2c.RANKING_LIST_TOP_POWER, self, self.getRankDataInfo_hero)
	--绑定群豪榜消息回调
	TFDirector:addProto(s2c.RANKING_LIST_ARENA, self, self.getRankDataInfo_qunhao)
	--绑定无量榜消息回调
	TFDirector:addProto(s2c.RANKING_LIST_WU_LIANG, self, self.getRankDataInfo_wuliang)
	--绑定侠客榜消息回调
	TFDirector:addProto(s2c.RANKING_LIST_XIA_KE, self, self.getRankDataInfo_xiake)
	--绑定附魔榜消息回调
	TFDirector:addProto(s2c.RANKING_LIST_WORLD_BOSS, self, self.getRankDataInfo_fumo)

	--绑定公会排行榜战力榜消息回调
	TFDirector:addProto(s2c.RANK_LIST_GUILD_POWER, self, self.getRankDataInfo_FactionPower)
	--绑定公会排行榜等级榜消息回调
	TFDirector:addProto(s2c.RANK_LIST_GUILD_LEVEL, self, self.getRankDataInfo_FactionLevel)

	--绑定杀戮榜消息回调
	TFDirector:addProto(s2c.ADVENTURE_MASSACRE_RANKING, self, self.getRankDataInfo_ShaLu)

	--绑定侠客详细
	TFDirector:addProto(s2c.ROLE_DETAILS, self, self.getRoleDataDetails)

	self:restart()
end

function RankManager:restart()
	
	self.rankDataMap = {}
	self.refreshTime = {}
	for i=1,RankListType.Rank_List_Max do
		self.refreshTime[i] = 1
	end

end

function RankManager:RequestDataFromServer(type, start_index, length)

	if type <= RankListType.Rank_List_None and type >= RankListType.Rank_List_Max then
		return
	end
	self.currType = type

	--判断时间是否超过1分钟
	local currTime = GetGameTime()
	-- local timeDelay = currTime - self.refreshTime[type]
	--取消1分钟缓存
	local timeDelay = 99999

	if timeDelay >= 60 then
		local Msg = 
		{
			type,
			start_index,
			length,0,0,0
		}
		TFDirector:send(c2s.QUERY_RANKING_BASE_INFO,Msg)
		showLoading();
	else
		TFDirector:dispatchGlobalEventWith(RankManager.GETRANKDATADONE ,{self.rankDataMap[self.currType]})
		if self.currType == RankListType.Rank_List_FactionLevel then
			TFDirector:dispatchGlobalEventWith(RankManager.GetFactionList, {self.rankDataMap[self.currType]})
		end

		self.currType = nil
	end	
end

function RankManager:setDelayTimeZero(type)
	self.refreshTime[type] = 1
end

function RankManager:RequestDataFromServerByMore(type, start_index, length)

	if type <= RankListType.Rank_List_None and type >= RankListType.Rank_List_Max then
		return
	end
	self.currType = type

	if length > 50 then
		length = 50
	end

	length = math.floor(length/10)*10

	if #(self.rankDataMap[self.currType].rankInfo) < length then
		local Msg = 
		{
			type,
			start_index,
			length,0,0,0
		}	
		TFDirector:send(c2s.QUERY_RANKING_BASE_INFO,Msg)
		showLoading();	
	else
		TFDirector:dispatchGlobalEventWith(RankManager.GETRANKDATADONE ,{self.rankDataMap[self.currType]})
		if self.currType == RankListType.Rank_List_FactionLevel then
			TFDirector:dispatchGlobalEventWith(RankManager.GetFactionList, {self.rankDataMap[self.currType]})
		end
		self.currType = nil
	end	
end


function RankManager:getRankDataInfo_hero(event)

	local rank_type = RankListType.Rank_List_Hero

	self.refreshTime[rank_type] = GetGameTime()

	self.rankDataMap[rank_type] = nil

	self.rankDataMap[rank_type] = event.data

	TFDirector:dispatchGlobalEventWith(RankManager.GETRANKDATADONE ,{self.rankDataMap[rank_type]})

	hideLoading();
end


function RankManager:getRankDataInfo_qunhao(event)

	local rank_type = RankListType.Rank_List_Qunhao

	self.refreshTime[rank_type] = GetGameTime()

	self.rankDataMap[rank_type] = nil

	self.rankDataMap[rank_type] = event.data

	TFDirector:dispatchGlobalEventWith(RankManager.GETRANKDATADONE ,{self.rankDataMap[rank_type]})

	hideLoading();
end


function RankManager:getRankDataInfo_wuliang(event)

	local rank_type = RankListType.Rank_List_Wuliang

	self.refreshTime[rank_type] = GetGameTime()

	self.rankDataMap[rank_type] = nil

	self.rankDataMap[rank_type] = event.data

	TFDirector:dispatchGlobalEventWith(RankManager.GETRANKDATADONE ,{self.rankDataMap[rank_type]})

	hideLoading();
end



function RankManager:getRankDataInfo_xiake(event)

	local rank_type = RankListType.Rank_List_Xiake

	self.refreshTime[rank_type] = GetGameTime()

	self.rankDataMap[rank_type] = nil

	self.rankDataMap[rank_type] = event.data

	TFDirector:dispatchGlobalEventWith(RankManager.GETRANKDATADONE ,{self.rankDataMap[rank_type]})

	hideLoading();
end

function RankManager:getRankDataInfo_fumo(event)

	local rank_type = RankListType.Rank_List_fumo

	self.refreshTime[rank_type] = GetGameTime()

	self.rankDataMap[rank_type] = nil

	self.rankDataMap[rank_type] = event.data

	TFDirector:dispatchGlobalEventWith(RankManager.GETRANKDATADONE ,{self.rankDataMap[rank_type]})

	TFDirector:dispatchGlobalEventWith(RankManager.POST_MSG_BOSSFIGHT ,{self.rankDataMap[rank_type]})

	hideLoading();
end

function RankManager:getRankDataInfo_ShaLu(event)
	local rank_type = RankListType.Rank_List_ShaLu

	self.refreshTime[rank_type] = GetGameTime()

	self.rankDataMap[rank_type] = nil

	self.rankDataMap[rank_type] = event.data

	TFDirector:dispatchGlobalEventWith(RankManager.GETRANKDATADONE ,{self.rankDataMap[rank_type]})

	hideLoading();
end

function RankManager:requestRoleDataById( playerId, roleId, item )

	self.item = item
	local Msg = 
	{
		playerId,
		roleId
	}	
	TFDirector:send(c2s.GET_OTHER_ROLE_DETAILS,Msg)
end

function RankManager:getRoleDataDetails( event )
	OtherPlayerManager:openXiakeRoleInfo(event.data, event.data.id, self.item)
end

function RankManager:pariseSuccess( playerId )

	for i=1,RankListType.Rank_List_fumo do
		if self.rankDataMap[i] ~= nil then
			if playerId == MainPlayer:getPlayerId() then
				self.rankDataMap[i].praiseCount = self.rankDataMap[i].praiseCount + 1
			end
			local dataTable = self.rankDataMap[i].rankInfo or {}
			for j=1,#dataTable do
				if dataTable[j].playerId == playerId then
					dataTable[j].goodNum = dataTable[j].goodNum + 1
				end
			end
		end
	end
end

function RankManager:getDataMapByType( type )
	return self.rankDataMap[type]
end

function RankManager:getPlayerInfoByTypePlayerID( type,playerId )

	local data = self.rankDataMap[type] or {}
	local rankInfo = data.rankInfo or {}
	for k,v in pairs(rankInfo) do
		if v.playerId == playerId then
			return v
		end
	end
	return nil
end

function RankManager:isInTen( playerId )

	if self.rankDataMap[1] and self.rankDataMap[1].rankInfo then
	
		local dataTable = self.rankDataMap[1].rankInfo
		local size = #dataTable

		if size > 10 then
			size = 10
		end

		for i=1,size do
			if playerId == dataTable[i].playerId then
				return i
			end
		end
	end
	return 20
end


function RankManager:getRankDataInfo_FactionPower(event)

	local rank_type = RankListType.Rank_List_FactionPower

	self.refreshTime[rank_type] = GetGameTime()

	self.rankDataMap[rank_type] = nil

	self.rankDataMap[rank_type] = event.data

	TFDirector:dispatchGlobalEventWith(RankManager.GETRANKDATADONE ,{self.rankDataMap[rank_type]})


	hideLoading();
end

function RankManager:getRankDataInfo_FactionLevel(event)

	local rank_type = RankListType.Rank_List_FactionLevel

	self.refreshTime[rank_type] = GetGameTime()

	self.rankDataMap[rank_type] = nil

	self.rankDataMap[rank_type] = event.data

	TFDirector:dispatchGlobalEventWith(RankManager.GETRANKDATADONE ,{self.rankDataMap[rank_type]})

	TFDirector:dispatchGlobalEventWith(RankManager.GetFactionList, {self.rankDataMap[rank_type]})

	hideLoading();
end

function RankManager:applyFlagSet(guildIds, flag)

	print("guildIds = ",guildIds)
	print("flag = ",flag)

	if self.rankDataMap[RankListType.Rank_List_FactionLevel] and self.rankDataMap[RankListType.Rank_List_FactionLevel].rankInfo then
		for j=1,#guildIds do
			local id = guildIds[j]
			print("id = ",id)
			for i=1,#(self.rankDataMap[RankListType.Rank_List_FactionLevel].rankInfo) do
				
				if self.rankDataMap[RankListType.Rank_List_FactionLevel].rankInfo[i].guildId == id then
					self.rankDataMap[RankListType.Rank_List_FactionLevel].rankInfo[i].apply = flag				
				end
				
			end
		end
	end	
end

function RankManager:getApplyIdTable(num)
	local iDs = {}
	local needCount = 0
	if self.rankDataMap[RankListType.Rank_List_FactionLevel] and self.rankDataMap[RankListType.Rank_List_FactionLevel].rankInfo then
		for k,v in pairs(self.rankDataMap[RankListType.Rank_List_FactionLevel].rankInfo) do
			if v.apply == false then
				needCount = needCount + 1
				iDs[needCount] = v.guildId			
				if needCount >= num then
					return iDs
				end
			end
		end
	end
	return iDs
end

function RankManager:canTiaoZhan(playerId)
	return not self:isTiaoZhanContainId(playerId)
end

function RankManager:isTiaoZhanContainId(playerId)
	local rank_type = RankListType.Rank_List_ShaLu
	local tList = self.rankDataMap[rank_type].challengeId or {}
	if tList == nil then return false end
	for k,v in pairs(tList) do
		if v == playerId then
			return true
		end
	end
	return false
end

function RankManager:pushTiaoZhanId(playerId)
	if self:isTiaoZhanContainId(playerId) == true then
		return
	end
	local rank_type = RankListType.Rank_List_ShaLu
	self.rankDataMap[rank_type].challengeId = self.rankDataMap[rank_type].challengeId or {}
	local len = #(self.rankDataMap[rank_type].challengeId)
	self.rankDataMap[rank_type].challengeId[len+1] = playerId
end

function RankManager:getTitlePic( index )

	local picPath = "ui_new/leaderboard/n1.png"

	if index > 0 and index < 11 then
		picPath = "ui_new/leaderboard/n"..index..".png" 
	end
	
	return picPath
end

return RankManager:new()