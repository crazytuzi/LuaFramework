--LegionData.lua

require("app.cfg.corps_info")
require("app.cfg.corps_dungeon_chapter_info")
require("app.cfg.corps_technology_info")


--[=[]
--[[ CorpMember struct 
message CorpMember {
  required uint32 id = 1;
  required string name = 2;
  required uint32 level = 3;
  required uint32 fight_value = 4;
  required uint32 total_contribute = 5;
  required uint32 worship_id = 6;//祭天ID 0为无
  required uint32 worship_exp  = 7;//祭天贡献值
  required uint32 online = 8;
  required uint32 main_role = 9;
  required uint32 join_corp_time = 10;
  required uint32 position = 11;
  required uint32 vip = 12;
  optional uint32 dress_id = 13;
  optional uint32 worship_point = 14;//后面加的
  optional uint32 worship_time = 15;
}
--]]
local CorpMemberMeta = class("CorpMemberMeta")

function CorpMemberMeta:ctor( data )
	self:updateData(data)
end

function CorpMemberMeta:updateData( data )
	self.id 		= data and data.id or 0
	self.name 		= data and data.name or ""
	self.level 		= data and data.level or 1
	self.fight_value = data and data.fight_value or 0
	self.total_contribute = data and data.total_contribute or 0
	self.worship_id = data and data.worship_id or 0
	self.worship_exp = data and data.worship_exp or 0
	self.online 	= data and data.online or 0
	self.main_role 	= data and data.main_role or 1
	self.join_corp_time = data and data.join_corp_time or 0
	self.position 	= data and data.position or 0
	self.vip 		= data and data.vip or 0
	self.dress_id 	= data and data.dress_id or 0
	self.worship_point = data and data.worship_point or 0
	self.worship_time	= data and data.worship_time or 0
end
function LegionData:updateCorpMembers( members )
	self._corpMembers = {}
	for key, value in pairs(members) do 
		table.insert(self._corpMembers, #self._corpMembers + 1, CorpMemberMeta.new(value))
	end
end

]=]
local LegionData = class("LegionData")

LegionData._CROSS_TIME = {
	BAOMING_END_HOUR = 15,
	BAOMING_END_MIN = 55,
	PIPEI_END_HOUR = 16,
	PIPEI_END_MIN = 30,
	FIGHT_END_HOUR = 17,
	FIGHT_END_MIN = 2,
}

LegionData.DUNGEON_START_TIME = 14*60*60
LegionData.DUNGEON_END_TIME = 2*60*60 + 60
LegionData.DUNFEON_AWARD_END_TIME = 0

LegionData.TECH_OPEN_LEVEL = 4

function LegionData:ctor( ... )
	self:onDestoryCorp()
end

function LegionData:onDestoryCorp( ... )
	self._hasCorp = false
	self._dataInit = false
	self._corpDetail = nil

	--self._startCorpIndex = 0
	--self._endCorpIndex = 0

	self._historyStart = 0
	self._historyMax = 0

	self._searchCorpResult = nil
	self._myselfLevelRankIndex = 0
	self._myselfDungeonRankIndex = 0
	self._corpList = {}
	self._corpListIndex = {}
	self._corpJoinList = {}
	self._corpMembers = {}
	self._corpApplyMembers = {}

	self._worshipData = {}
	self._maxHistoryIndex = 0
	self._minHistoryIndex = 0
	self._historyListData = {}

	self._chapterData = nil
	self._dungeonInfo = nil
	self._selfGlobalRank = 0
	self._globalRanks = nil
	self._legionRanks = nil
	self._selfLegionRank = 0
	self._globalMemberCount = 0
	-- 砸蛋信息
	self._myDungeonAwardIndex = 0
	self._hasAcquireAward = false
	self._dungeonAwardList = {}
	self._dungeonAwardIndex = {}

	-- 红点flag
	self._flagCanWorship = false
	self._hasAwardRight = false
	self._flagHaveWorshipAward = false
	self._hasAcquireFinishAward = false
	self._flagCanHitEggs = false
	self._flagHasApply = false

	--新的军团副本
	self._newCurrentChapter = 0
	self._newAttackTimes = 0
	self._newBuyGold = 0
	self._newFinishAwards = {}
	self._newChapterData = {}
	self._newDungeonData = {}
	self._newRankList = {}

	-- 群英战
	self._crossStatus = 0
	self._crossField = 0
	self._hasApply = false

	self._cropBattleTimes = {}

	self._crossCropList = {}
	self._encourageInfo = {}
	self._battleFieldInfo = {}
	self._crossEnemysInfo = {}
	self._crossBattleRankInfo = {}
	self._selfBattleRank = 0

	--军团科技
	self._corpTech = {}
	self._userTech = {}
end

-- 缓存军团列表数据
function LegionData:updateCorpList( startId, endId, corpList )
__Log("start:%d, end:%d", startId, endId)
	if startId == 0 or endId == 0 then 
		return 
	end

	-- __Log("[updateCorpList] curStart:%d, curEnd:%d, pStart:%d, pEnd:%d",
	-- 	self._startCorpIndex, self._endCorpIndex, startId, endId)

	-- local isPrefList = (startId <= self._startCorpIndex)
	-- local isNextList = (endId >= self._endCorpIndex)
	-- if not isPrefList and not isNextList then 
	-- 	return __LogError("wrong list for isPrefList:%d, isNextList:%d, start:%d, end:%d", 
	-- 		isPrefList and 1 or 0, isNextList and 1 or 0, startId, endId)
	-- end

	-- local startIndex = startId
	-- if (self._startCorpIndex == 0) or isPrefList then 
	-- 	self._startCorpIndex = startId 
	-- end

	-- if (self._endCorpIndex == 0) or isNextList then 
	-- 	self._endCorpIndex = endId
	-- end

	 

	local myCorpId = self._corpDetail and self._corpDetail.id or 0
	self._myselfLevelRankIndex = 0

	--local loopi = 0
	for key, value in pairs(corpList) do 
		if type(value.id) == "number" and (not self._corpListIndex[value.id]) then
			table.insert(self._corpList, #self._corpList + 1, value)
			self._corpListIndex[value.id] = 1

			if value.id == myCorpId then 
				self._myselfLevelRankIndex = #self._corpList
			end
		end
		-- self._corpList[loopi + startIndex] = value
		-- self._corpListIndex[value.id] = 1
		-- loopi = loopi + 1
	end
	--__Log("[updateCorpList] newly: curStart:%d, curEnd:%d", self._startCorpIndex, self._endCorpIndex)

	if type(self._corpJoinList) == "table" then 
		for key, value in pairs(self._corpJoinList) do 
			if type(value.id) == "number" and (not self._corpListIndex[value.id]) then 
				table.insert(self._corpList, #self._corpList + 1, value)
				self._corpListIndex[value.id] = 1
				-- self._corpList[self._endCorpIndex + 1] = value
				-- self._corpListIndex[value.id] = 1
				-- self._endCorpIndex = self._endCorpIndex + 1

				--__Log("[updateCorpList] add item to corp join list: index=%d, start:%d, end:%d",
				 --self._endCorpIndex, self._startCorpIndex, self._endCorpIndex)
			end
		end
	end

__Log("size of corpList:%d", #self._corpList)

	local sortFunc = function ( corp1, corp2 )
		if not corp1 or not corp2 then 
			return false
		end

		if corp1.level ~= corp2.level then 
			return corp1.level > corp2.level 
		end

		if corp1.exp ~= corp2.exp then 
			return corp1.exp > corp2.exp
		end

		return corp1.id < corp2.id
	end

	if self:hasCorp() then
		table.sort(self._corpList, sortFunc)

		for key, value in pairs(self._corpList) do 
			if value.id == myCorpId then 
				self._myselfLevelRankIndex = key or 0
			end
		end
	end
end

function LegionData:clearCorpList( ... )
	self._corpList = {}
	self._corpListIndex = {}
	self._corpJoinList = {}
	--self._startCorpIndex = 0
	--self._endCorpIndex = 0
end

-- 缓存申请加入的军团列表数据
function LegionData:updateJoinCorpList( corpList )
	self._corpJoinList = {}
	if type(corpList) == "table" then 
		for key, value in pairs(corpList) do 
			table.insert(self._corpJoinList, #self._corpJoinList + 1, value)
		end
	end

	if type(self._corpJoinList) == "table" then 
		for key, value in pairs(self._corpJoinList) do 
			if type(value.id) == "number" and (not self._corpListIndex[value.id]) then 
				table.insert(self._corpList, #self._corpList + 1, value)
				self._corpListIndex[value.id] = 1
				-- self._corpList[self._endCorpIndex + 1] = value
				-- self._corpListIndex[value.id] = 1
				-- self._endCorpIndex = self._endCorpIndex + 1

				--__Log("[updateCorpList] add item to corp join list: index=%d, start:%d, end:%d",
				 --self._endCorpIndex, self._startCorpIndex, self._endCorpIndex)
			end
		end
	end
end

function LegionData:updateSearchCorpInfo( corp )
	self._searchCorpResult = corp
end

-- 缓存当前军团的详情数据
function LegionData:updateCorpDetailInfo( hasCorp, detailInfo, quitCorpCd, joinCorpTime )
	-- if not self._dataInit then 
	-- 	local FunctionLevelConst = require("app.const.FunctionLevelConst")
	-- 	if G_moduleUnlock:isModuleUnlock(FunctionLevelConst.LEGION) and hasCorp then 
	-- 		G_HandlersManager.legionHandler:sendGetJoinCorpList()
 --    	end
		
	-- end
	self._hasCorp = hasCorp and true or false
	self._corpDetail = detailInfo or {}
	self._corpDetail.quit_corp_cd = quitCorpCd or 0
	self._corpDetail.join_corp_time = joinCorpTime or 0

	if type(self._corpDetail.announcement) ~= "string" or self._corpDetail.announcement == "" then 
		self._corpDetail.announcement = G_lang:get("LANG_LEGION_DEFAULT_ANNOUNCEMENT")
	end
	if type(self._corpDetail.notification) ~= "string" or self._corpDetail.notification == "" then 
		self._corpDetail.notification = G_lang:get("LANG_LEGION_DEFAULT_NOTIFICATION")
	end
	
	self._dataInit = true
end

-- 缓存当前军团的成员数据
function LegionData:updateCorpMembers( members )
	if type(members) ~= "table" then 
		self._corpMembers = {}
		return 
	end

	self._corpMembers = {}
	for key, value in pairs(members) do 
		table.insert(self._corpMembers, #self._corpMembers + 1, value)
	end

	local myUserId = G_Me.userData.id
	local _sortMember = function ( mem1, mem2 )
		if not mem1 then 
			return false
		end

		if not mem2 then 
			return true 
		end
		
		if mem1.position == 1 then 
			return true
		elseif mem2.position == 1 then 
			return false
		end

		if mem1.position == mem2.position then 
			if mem1.id ==  myUserId then 
				return true
			elseif mem2.id == myUserId then 
				return false
			elseif mem1.online == mem2.online then 
				return mem1.id < mem2.id 
			else
				if mem1.online == 0 then 
					return true 
				elseif mem2.online == 0 then 
					return false
				else
					if mem1.worship_exp ~= mem2.worship_exp  then 
						return mem1.worship_exp > mem2.worship_exp
					else
						return mem1.id < mem2.id 
					end
				end
			end
		end

		return mem1.position > mem2.position
	end

	table.sort(self._corpMembers, _sortMember)
end

function LegionData:onCorpStaffChange( userId, position )
	if type(userId) ~= "number" then 
		return 
	end

	position = position or 0

	for key, value in pairs(self._corpMembers) do 
		if value and value.id == userId then 
			value.position = position
		end
	end
end

-- 缓存当前军团的动态信息
function LegionData:updateCorpHistory( startId, endId, historyList )
	local enterCorpTime = self._corpDetail and self._corpDetail.join_corp_time
	if type(historyList) == "table" then 
		for key, value in pairs(historyList) do 
			if value.time >= enterCorpTime then
				self._historyListData[value.id] = value

				if value.id > self._maxHistoryIndex then 
					self._maxHistoryIndex = value.id
				end

				if ((self._minHistoryIndex ~= 0) and (value.id < self._minHistoryIndex)) or self._minHistoryIndex == 0 then 
					self._minHistoryIndex = value.id
				end
			end
		end
	end
end

-- 缓存当前军团进度，贡献等动态信息
function LegionData:updateCorpWorship( bufferData )
	if bufferData.ret ~= 1 then
		return 
	end

	self._worshipData = {}
	self._worshipData.worship_level = bufferData.worship_level
	self._worshipData.worship_point = bufferData.worship_point
	self._worshipData.worship_id = bufferData.worship_id
	self._worshipData.worship_exp = bufferData.worship_exp
	self._worshipData.worship_crit = bufferData.worship_crit
	self._worshipData.worship_award = bufferData.worship_award
	self._worshipData.worship_count = bufferData.worship_count

	self._flagCanWorship = (bufferData.worship_id == 0) and (self._worshipData.worship_level > 0) and (self._worshipData.worship_count > 0)
	self._flagHaveWorshipAward = false
	local corpsAwardInfo = corps_info.get(bufferData.worship_level)
	if corpsAwardInfo then 
		for loopi = 1, 4, 1 do 
			if corpsAwardInfo["worship_value_"..loopi] <= bufferData.worship_point and 
				not bufferData.worship_award[loopi] then 
				self._flagHaveWorshipAward = true
			end
		end
	end
end

-- 申请加入军团后，更新军团信息
function LegionData:updateForApplyCorp( id, corpInfo )
	if type(id) ~= "number" then 
		return 
	end

	if self._searchCorpResult then 
		self._searchCorpResult.has_join = true
	end
	for key, value in pairs(self._corpList) do 
		if value and value.id == id then 
			value.has_join = true
		end
	end
end

-- 申请取消加入军团后，更新军团信息
function LegionData:updateForCancelApplyCorp( id, corpInfo )
	if type(id) ~= "number" then 
		return 
	end

	if self._searchCorpResult then 
		self._searchCorpResult.has_join = false
	end
	for key, value in pairs(self._corpList) do 
		if value and value.id == id then 
			value.has_join = false
		end
	end
end

function LegionData:updateForApplyList( joins )
	self._corpApplyMembers = {}

	self._flagHasApply = false
	if type(joins) ~= "table" then 
		return 
	end

	for key, value in pairs(joins) do 
		table.insert(self._corpApplyMembers, #self._corpApplyMembers + 1, value)
	end

	self._flagHasApply = #self._corpApplyMembers > 0

end

function LegionData:refreshJoinCorpMember( userId, confirm )
	if type(userId) ~= "number" then 
		return 
	end

	confirm = confirm or false
	for key, value in pairs(self._corpApplyMembers) do 
		if value.id == userId then 
			table.remove(self._corpApplyMembers, key)
			self._flagHasApply = #self._corpApplyMembers > 0
			return
		end
	end
end

function LegionData:onDismissCorpMember( userId )
	if type(userId) ~= "number" then 
		return 
	end

	confirm = confirm or false
	for key, value in pairs(self._corpMembers) do 
		if value.id == userId then 
			table.remove(self._corpMembers, key)
			return
		end
	end
end

-- 军团副本数据
function LegionData:updateChapterInfo( chapter )
	if type(chapter) ~= "table" then 
		return 
	end

	if not self._chapterData then 
		self._chapterData = {}
	end
	self._chapterData.chapter_id = chapter.chapter_id
	self._chapterData.today_chid = chapter.today_chid
	self._chapterData.hp = chapter.hp
	self._chapterData.max_hp = chapter.max_hp
	self._chapterData.chapter_count = chapter.chapter_count
	self._chapterData.chapters = chapter.chapters
	self._chapterData.reset_cost = chapter.reset_cost

	if self._chapterData.today_chid < 1 then 
		self._chapterData.today_chid = 1 
	end
	self:_doUpdateAwardFlag()
end

function LegionData:updateCorpDungeonInfo( dungeonInfo )
	if type(dungeonInfo) ~= "table" then 
		return 
	end

	if not self._dungeonInfo then 
		self._dungeonInfo = {}
	end
	self._dungeonInfo.chapter_id = dungeonInfo.chapter_id
	self._dungeonInfo.dungeon = dungeonInfo.dungeon
end

function LegionData:onCorpDungeonExecute( corpDungeon )
	if type(corpDungeon) ~= "table" then 
		return  
	end

	if self._dungeonInfo and type(self._dungeonInfo.dungeon) == "table" then
		for key, value in pairs(self._dungeonInfo.dungeon) do
			if value.id == corpDungeon.id then 
				self._dungeonInfo.dungeon[key] = corpDungeon
				return 
			end
		end
	end
	
end

function LegionData:onChapterHpUpdate( newHp )
	if type(newHp) ~= "number" or not self._chapterData then
		return 
	end

	self._chapterData.hp = newHp
end

function LegionData:_doUpdateAwardFlag( ... )
	self._flagCanHitEggs = self:hasCorp() and ((self._chapterData and self._chapterData.hp < 1) and not self._hasAcquireAward) and true or false
end

function LegionData:updateAwardListInfo( award )
	if type(award) ~= "table" then 
		return
	end

	self._dungeonAwardList = {}
	self._dungeonAwardIndex = {}

	self._hasAcquireAward = award.has_award
	self._hasAcquireFinishAward = award.has_point or false
	self._hasAwardRight = award.has_auth or false
	--self._dungeonAwardList = award.list
	
	if type(award.list) == "table" then 
		for key, value in pairs(award.list) do 
			self._dungeonAwardList[value.index] = value

			self._dungeonAwardIndex[value.id] = (self._dungeonAwardIndex[value.id] or 0) + 1
		end
	end	

	self:_doUpdateAwardFlag()
end

-- 领取通关全军团奖励
function LegionData:onUpdateDungeonAwardCorpPoint( flag )
	self._hasAcquireFinishAward = flag or false
end

-- 砸蛋后更新自己的砸蛋信息
function LegionData:onAddDungeonAward( award, isMyAward )
	if isMyAward then
		self._hasAcquireAward = true
	end
	if type(award) == "table" and type(award.index) == "number" then
		self._dungeonAwardList[award.index] = award
		self._dungeonAwardIndex[award.id] = (self._dungeonAwardIndex[award.id] or 0) + 1
	end

	self:_doUpdateAwardFlag()
end

function LegionData:updateGloabelRank( rank )
	if type(rank) ~= "table" then 
		return
	end

	self._selfGlobalRank = rank.self_rank
	self._globalMemberCount = 0
	self._globalRanks = {}
	if type(rank.ranks) == "table" then 
		for key, value in pairs(rank.ranks) do 
			self._globalRanks[value.rank] = value
			self._globalMemberCount = self._globalMemberCount + 1
			--table.insert(self._globalRanks, #self._globalRanks + 1, value)
		end
	end
	--self._globalRanks = rank.ranks
end

function LegionData:updateLegionRank( rank )
	if type(rank) ~= "table" then 
		return
	end

	self._selfLegionRank = 0
	self._legionRanks = rank.ranks

	local _sortRanks = function ( mem1, mem2 )
		if not mem1 then 
			return true
		elseif not mem2 then 
			return false
		end

		if mem1.harm ~= mem2.harm then 
			return mem1.harm > mem2.harm 
		end

		return mem1.id < mem2.id
	end

	local myselfId = G_Me.userData.id
	if type(self._legionRanks) == "table" then 
		table.sort(self._legionRanks, _sortRanks)

		local loopi = 1
		for key, value in pairs(self._legionRanks) do 
			value.rank = loopi
			loopi = loopi + 1

			if value.id == myselfId then 
				self._selfLegionRank = value.rank
			end
		end
	end
end

function LegionData:udpateMyContribute( worshipId, worshipExp, corpPoint )
	local myId = G_Me.userData.id
	for key, value in pairs(self._corpMembers) do 
		if value.id == myId then 
			value.worship_point = worshipExp or 0
			value.worship_id = worshipId or 0
		end
	end
end

function LegionData:updateCorpChapterRank( ranks )
	if type(ranks) ~= "table" then 
		return 
	end

	local myCorpId = self._corpDetail and self._corpDetail.id or 0
	self._myselfDungeonRankIndex = 0

	self._corpChapterRanks = {}
	for key, value in pairs(ranks) do 
		table.insert(self._corpChapterRanks, #self._corpChapterRanks + 1, value)
		if value.id == myCorpId then 
			self._myselfDungeonRankIndex = value.rank
		end
	end
end

-- 群英战
function LegionData:_clearCorpCrossData( ... )
	__Log("LegionData:_clearCorpCrossData")
	self._crossField = 0
	self._hasApply = false

	self._crossCropList = {}
	self._encourageInfo = {}
	self._battleFieldInfo = {}
	self._crossEnemysInfo = {}
	self._crossBattleRankInfo = {}
	self._selfBattleRank = 0
end

function LegionData:updateCrossBattleStatus( apply, state, field)
	self._crossStatus = state or self._crossStatus
	self._crossField = field or self._crossField
	self._hasApply = apply and true or false
	__Log("after:_hasApply:%d, _crossStatus:%d, field:%d", self._hasApply and 1 or 0, self._crossStatus, self._crossField)
end

function LegionData:changeCrossStatus( state )
	--local oldStatus = self._crossStatus
	self._crossStatus = state or self._crossStatus
	if self._crossStatus == 1 then 
		self:_clearCorpCrossData()
	end
end

function LegionData:changeBattleField( field )
	self._crossField = field or self._crossField
end

function LegionData:updateCropCrossBattleTime( times )
	if type(times) ~= "table" or #times < 1 then 
		return 
	end

	for key, value in pairs(times) do 
		self._cropBattleTimes[value.state] = {start = value.start, close = value.close}

		--local start = os.date("*t", value.start)
		--local close = os.date("*t", value.close)
		local start = G_ServerTime:getDateObject(value.start)
		local close = G_ServerTime:getDateObject(value.close)

		--__Log("section:[%d], start=[%d:%d:%d], close=[%d:%d:%d]", value.state, 
		--	start.hour, start.min, start.sec, close.hour, close.min, close.sec)
	end
end

function LegionData:updateApplyCrossBattleList( corps )
	self._crossCropList = corps or {}
	-- dump(self._crossCropList)
end

function LegionData:flushApplyCrossBattleInfo( add, corp )
	if type(corp) ~= "table" then 
		return
	end
	if add then
		table.insert(self._crossCropList, #self._crossCropList + 1, corp)
	else
		for key, value in pairs(self._crossCropList) do 
			if value.id == corp.id then 
				--self._crossCropList[key] = nil
				table.remove(self._crossCropList, key)
				return 
			end
		end
	end
end

function LegionData:refreshCorpCrossEncourage( decodeBuffer )
	if type(decodeBuffer) == "table" then
		self._encourageInfo = decodeBuffer
	end
end

function LegionData:flushCorpEncourage( decodeBuffer )
	if type(decodeBuffer) == "table" and self._encourageInfo then 
		self._encourageInfo.total_hp_count = decodeBuffer.hp_encourage
		self._encourageInfo.total_atk_count = decodeBuffer.atk_encourage
	end
end

function LegionData:onEncrourageResult( decodeBuffer )
	if type(decodeBuffer) == "table" and self._encourageInfo then 
		self._encourageInfo.hp_count = decodeBuffer.hp_count
		self._encourageInfo.atk_count = decodeBuffer.atk_count
		self._encourageInfo.total_hp_count = decodeBuffer.total_hp_count
		self._encourageInfo.total_atk_count = decodeBuffer.total_atk_count
	end
end

function LegionData:updateCrossBattleFieldDetail(decodeBuffer)
	if type(decodeBuffer) == "table" then
		self._battleFieldInfo = decodeBuffer

		local myCorpId = self._corpDetail and self._corpDetail.id or 0
		local _sortFieldInfo = function ( corp1, corp2 )
			if corp1.corp_id == myCorpId then 
				return true
			elseif corp2.corp_id == myCorpId then 
				return false
			end

			return corp1.corp_id < corp2.corp_id
		end

		table.sort(self._battleFieldInfo.corp, _sortFieldInfo)
	end
end

function LegionData:flushCrossBattleCorpInfo( corps )
	local _flushCorpInfo = function ( corp )
		for key, value in pairs(self._battleFieldInfo.corp) do 
			if value.corp_id == corp.corp_id and value.sid == value.sid then 
				table.remove(self._battleFieldInfo.corp, key)
				table.insert(self._battleFieldInfo.corp, key, corp)
				return 
			end
		end
	end
	if type(corps) == "table" and self._battleFieldInfo and type(self._battleFieldInfo.corp) == "table" then
		for key, value in pairs(corps) do 
			_flushCorpInfo(value)
		end
	end 
end

function LegionData:updateCrossBattleEnemys(decodeBuffer)
	if type(decodeBuffer) == "table" and type(decodeBuffer.sid) == "number" and type(decodeBuffer.corp_id) == "number" then
		self._crossEnemysInfo[decodeBuffer.sid.."_"..decodeBuffer.corp_id] = decodeBuffer

		if rawget(decodeBuffer, "refresh_cd") then
			self:updateBattleRefreshCD(decodeBuffer.refresh_cd)
		end

	end
end

function LegionData:updateBattleChallengeCD(battle_cd)
	if self._battleFieldInfo then 
		self._battleFieldInfo.battle_cd = battle_cd or self._battleFieldInfo.battle_cd
	end
end

function LegionData:updateBattleCost( battle_cost )
	if self._battleFieldInfo then 
		self._battleFieldInfo.battle_cost = battle_cost or self._battleFieldInfo.battle_cost
	end
end

function LegionData:updateBattleUser(sid, corpId, user)
	if type(sid) ~= "number" or type(corpId) ~= "number" or 
		not self._crossEnemysInfo[sid.."_"..corpId] or type(user) ~= "table" then 
		return 
	end

	if type(self._crossEnemysInfo[sid.."_"..corpId].users) ~= "table" then
		return 
	end

	for key, value in pairs(self._crossEnemysInfo[sid.."_"..corpId].users) do 
		if value.id == user.id then
			table.remove(self._crossEnemysInfo[sid.."_"..corpId].users, key)
			table.insert(self._crossEnemysInfo[sid.."_"..corpId].users, key, user)
			return
		end
	end
end

function LegionData:updateBattleRefreshCD( refresh_cd )
	if self._battleFieldInfo then 
		self._battleFieldInfo.refresh_cd = refresh_cd or 0
	end
end

function LegionData:udpateFireOnCrossBattle( sid, corp_id )
	local corps = self._battleFieldInfo.corp or {}
	if type(corps) ~= "table" or type(corp_id) ~= "number" or type(sid) ~= "number" then 
		return 
	end

	for key, value in pairs(corps) do 
		value.fire_on = (value and (value.corp_id == corp_id) and (value.sid == sid))
	end
end

function LegionData:flushBattleMemberInfo( userId, killCount, robExp )
	if self._battleFieldInfo then
		self._battleFieldInfo.kill_count = killCount or 0
		self._battleFieldInfo.rob_exp = robExp or 0
	end
end

function LegionData:updateCrossBattleMemberRanks( ranks )
	if type(ranks) == "table" then
		self._crossBattleRankInfo = ranks

		local _sortFunc = function ( rank1, rank2 )
			if not rank1 then 
				return false 
			end

			if not rank2 then 
				return true
			end

			if rank1.rob_exp ~= rank2.rob_exp then 
				return rank1.rob_exp > rank2.rob_exp
			end

			if rank1.kill_count ~= rank2.kill_count then 
				return rank1.kill_count > rank2.kill_count 
			end

			return rank1.user_id < rank2.user_id
		end

		table.sort(self._crossBattleRankInfo, _sortFunc)

		self._selfBattleRank = 0
		for key, value in pairs(self._crossBattleRankInfo) do 
			if value.user_id == G_Me.userData.id then 
				self._selfBattleRank = key
				return
			end
		end
	end
end


-- UI访问接口
function LegionData:isCorpInit( ... )
	return self._dataInit
end

function LegionData:hasCorp( ... )
	return self._hasCorp
end

function LegionData:getShowCorpStart( ... )
	return #self._corpList > 0 and 1 or 0
end

function LegionData:getEndCorpIndex( ... )
	return #self._corpList
end

function LegionData:getCorpLength( ... )
	return #self._corpList
	--return #self._corpList
	-- if self._endCorpIndex <= self._startCorpIndex then 
	-- 	return 0
	-- else
	-- 	return self._endCorpIndex - self._startCorpIndex + 1
	-- end
end

function LegionData:getCorpByIndex( index )
	if type(index) ~= "number" or index < 1 or index > #self._corpList then 
		return nil
	end

	return self._corpList[index]
end

function LegionData:getCorpDetail( ... )
	return self._corpDetail
end

function LegionData:getCorpLevel( ... )
	if not self._corpDetail then 
		return 0
	end

	return self._corpDetail.level
end

function LegionData:getMyCorpLevelRankIndex( ... )
	return self._myselfLevelRankIndex
end

function LegionData:getMyCorpDungeonRankIndex( ... )
	return self._myselfDungeonRankIndex
end

function LegionData:getSearchResultCorp( ... )
	return self._searchCorpResult
end

--军团成员
function LegionData:getCorpMemberLength( ... )
	return #self._corpMembers
end

function LegionData:getMemberIndexById( id )
	if type(id) ~= "number" then 
		return 
	end

	local loopi = 0
	for key, value in pairs(self._corpMembers) do 
		loopi = loopi + 1
		if value.id == id then 
			return loopi 
		end
	end

	return loopi
end

function LegionData:getCorpMemberByIndex( index )
	index = index or 1
	if type(index) ~= "number" then 
		return nil
	end

	return self._corpMembers[index] or nil
end

--军团申请列表
function LegionData:getCorpApplyLength( ... )
	return #self._corpApplyMembers
end

function LegionData:getCorpApplyByIndex( index )
	index = index or 1
	if type(index) ~= "number" then 
		return nil
	end

	return self._corpApplyMembers[index] or nil
end

function LegionData:getWorshipData( ... )
	return self._worshipData
end

function LegionData:getHistoryByIndex( index )
	return self._historyListData[index]
end

function LegionData:getHistoryCount( ... )
	return self._maxHistoryIndex > 0 and (self._maxHistoryIndex - self._minHistoryIndex + 1) or 0
end

function LegionData:getMaxHistoryIndex( ... )
	return self._maxHistoryIndex
end

function LegionData:getMinHistoryIndex( ... )
	return self._minHistoryIndex
end

function LegionData:hasHistoryDataInit( ... )
	if not self._corpDetail then 
		return false
	end

	return self._corpDetail.history_index == self._maxHistoryIndex
end

function LegionData:hasCorpChapterInit( ... )
	return self._chapterData ~= nil
end

function LegionData:getCorpChapters( ... )
	return self._chapterData
end

function LegionData:getChapterCount( ... )
	if not self._chapterData then 
		return 0
	end

	return self._chapterData.chapter_count or 0
end

function LegionData:getCorpDungeonInfo() 
	return self._dungeonInfo
end

function LegionData:getCorpDungeonInfoByIndex( index )
	if type(self._dungeonInfo.dungeon) ~= "table" or type(index) ~= "number" then 
		return 
	end
	for key, value in pairs(self._dungeonInfo.dungeon) do 
		if key == index then 
			return value
		end
	end

	return
end

function LegionData:getCorpDungeonInfoById( dungeonId )
	if type(self._dungeonInfo.dungeon) ~= "table" or type(dungeonId) ~= "number" then 
		return 
	end
	for key, value in pairs(self._dungeonInfo.dungeon) do 
		if value.id == dungeonId then 
			return value
		end
	end

	return 
end

function LegionData:getGlobalRankCount( ... )
	return self._globalMemberCount
end

function LegionData:getGlobalRankByIndex( index )
	if type(index) ~= "number" or not self._globalRanks then 
		return nil
	end

	return self._globalRanks[index]
end

function LegionData:getSelfGlobalRank( ... )
	return self._selfGlobalRank
end

function LegionData:getLegionRankCount( ... )
	if not self._legionRanks then 
		return 0
	end

	return #self._legionRanks
end

function LegionData:getLegionRankByIndex( index )
	if type(index) ~= "number" or not self._legionRanks then 
		return nil
	end

	return self._legionRanks[index]
end

function LegionData:getCorpChapterRankByIndex( index )
	if type(index) == "number" then
		return self._corpChapterRanks and self._corpChapterRanks[index] or nil
	else
		return nil
	end
end

function LegionData:getCorpChapterRankCount( ... )
	return self._corpChapterRanks and #self._corpChapterRanks or 0
end

function LegionData:getSelfLegionRank( ... )
	return self._selfLegionRank
end

function LegionData:getAwardByIndex( awardIndex )
	if type(awardIndex) ~= "number" then 
		return nil 
	end

	return self._dungeonAwardList[awardIndex]
end

function LegionData:getAwardIndexByIndex( awardIndex )
	if type(awardIndex) ~= "number" then 
		return 0
	end
	return self._dungeonAwardIndex[awardIndex] or 0
end

function LegionData:getAcquireTotalAwardCount( ... )
	if type(slf._dungeonAwardIndex) ~= "table" then 
		return 0
	end

	local count = 0
	for key, value in pairs(self._dungeonAwardIndex) do 
		count = count + value
	end

	return count
end

function LegionData:haveAcquireAward( ... )
	if self._hasAwardRight then 
		return self._hasAcquireAward
	else
		return true
	end
end

function LegionData:hasAcquireFinishAward( ... )
	return (not self._hasAcquireFinishAward) and self:hasFinishDungeonChapter() and self._hasAwardRight
end

function LegionData:canAcquireFinishAward( ... )
	return not self._hasAcquireFinishAward
end

function LegionData:hasFinishDungeonChapter( ... )
	return self._chapterData and self._chapterData.max_hp > 0 and self._chapterData.hp < 1
end

function LegionData:getLeftDungeonTime( ... )
	local time = G_ServerTime:getTime()
	local t = G_ServerTime:getDateObject(time)
	--local t = os.date("*t", time or os.time())
	if type(t) ~= "table" then 
		return 0
	end

	return 24*3600 - (t.hour*3600 + t.min*60 + t.sec)
end

-- 红点接口
function LegionData:canWorship( ... )
	return self._flagCanWorship and self._worshipData ~= nil
end

function LegionData:haveWorshipCount( ... )
	return self._worshipData and self._worshipData.worship_count and self._worshipData.worship_count > 0 
end

function LegionData:getMaxMemberCount( ... )
	require("app.cfg.corps_info")
	local corpsInfo = corps_info.get(self._corpDetail and self._corpDetail.level or 0)
	return corpsInfo and corpsInfo.number or 0
end

function LegionData:haveWorshipAward( ... )
	return self._flagHaveWorshipAward
end

function LegionData:haveFinishChapter( ... )
	if not self._chapterData then 
		return false
	end

	return self._chapterData.hp < 1
end

function LegionData:canHitEgg( ... )
	return self._flagCanHitEggs and self._hasAwardRight
end

function LegionData:hasAwardRight( ... )
	return self._hasAwardRight
end

function LegionData:hasCorpApply( ... )
	return self._flagHasApply and (self._corpDetail and self._corpDetail.position > 0)
end

function LegionData:hasNewCorpInfo( ... )
--	__Log("canWorship:%d, haveWorshipAward:%d, canHitEgg:%d, hasCorpApply:%d, checkAwardTipsByType:%d", 
	--	self:canWorship() and 1 or 0, self:haveWorshipAward() and 1 or 0, self:canHitEgg() and 1 or 0, 
	--	self:hasCorpApply() and 1 or 0, G_Me.shopData:checkAwardTipsByType(6) and 1 or 0)
	-- return self:hasCorp() and (self:canWorship() or self:haveWorshipAward() or self:canHitEgg() or self:hasCorpApply() or 
	-- G_Me.shopData:checkAwardTipsByType(6) or self:hasAcquireFinishAward())
	local crossState = G_Me.legionData:getLegionSectionAndCountDown()
	local state = G_Me.legionData:isBattleTimeReady() and G_Me.legionData:hasCorpCrossValid() and crossState > 1 and crossState < 5
	local state2 = self:hasCorp() and (self:canWorship() or self:haveWorshipAward() or self:hasCorpApply() or 
			G_Me.shopData:checkAwardTipsByType(6) or G_Me.shopData:getJunTuanHasNewData() or
			self:getNewChapterMapNeedTip() or self:getNewChapterFightTip())
	return state or state2
end

-- 群英战

function LegionData:hasCorpCrossValid( ... )
	if not G_Me.legionData:hasCorp() then 
        return false
    end

    require("app.cfg.corps_value_info")
    local minLevel = corps_value_info.get(16).value
    local corpDetail = G_Me.legionData:getCorpDetail() or {}
    if not corpDetail or corpDetail.level < minLevel then 
        return false
    end

    return true
end

-- function LegionData:isInFightingTime ( ... )
-- 	local time = G_ServerTime:getTime()
-- 	local t = os.date("*t", time or os.time())
-- 	if type(t) ~= "table" then 
-- 		return false
-- 	end

-- 	return (t.hour > LegionData._CROSS_TIME.PIPEI_END_HOUR or 
-- 		(t.hour == LegionData._CROSS_TIME.PIPEI_END_HOUR and t.min >= LegionData._CROSS_TIME.PIPEI_END_MIN)) and 
-- 		(t.hour < LegionData._CROSS_TIME.FIGHT_END_HOUR or 
-- 			(t.hour == LegionData._CROSS_TIME.FIGHT_END_HOUR and t.min < LegionData._CROSS_TIME.FIGHT_END_MIN))
-- end

function LegionData:isBattleTimeReady( ... )
	return type(self._cropBattleTimes) == "table" and #self._cropBattleTimes > 1
end

function LegionData:getLegionSectionAndCountDown( ... )
	if type(self._cropBattleTimes) ~= "table" or #self._cropBattleTimes < 1 then 
		return 0, 0
	end

	local destSectionIndex = 0
	local countDownTime = 0
	local time = G_ServerTime:getTime()
	for key, value in pairs(self._cropBattleTimes) do 
		if value.start <= time then 
			destSectionIndex = key
			countDownTime = value.close - time
		end
	end

	return destSectionIndex, countDownTime
-- 	local time = G_ServerTime:getTime()
-- 	local t = os.date("*t", time or os.time())
-- 	if type(t) ~= "table" then 
-- 		return 0, 0
-- 	end

-- 	local CROSS_TIME = LegionData._CROSS_TIME

-- 	local sectionIndex = 0
-- 	local countDown = 0
-- 	if t.hour < CROSS_TIME.BAOMING_END_HOUR or 
-- 		( (t.hour == CROSS_TIME.BAOMING_END_HOUR) and 
-- 			(t.min < CROSS_TIME.BAOMING_END_MIN) ) then 
-- 		sectionIndex = 1
-- 		local minOffset = (t.hour == CROSS_TIME.BAOMING_END_HOUR) and 0 or (CROSS_TIME.BAOMING_END_HOUR - t.hour)
-- 		local hourOffset = (t.hour == CROSS_TIME.BAOMING_END_HOUR) and 0 or (CROSS_TIME.BAOMING_END_HOUR - t.hour - 1)
-- 		countDown = hourOffset*3600 + (CROSS_TIME.BAOMING_END_MIN + minOffset*60 - t.min - 1)*60 + 60 - t.sec
-- 	elseif t.hour > CROSS_TIME.FIGHT_END_HOUR or 
-- 		(t.hour == CROSS_TIME.FIGHT_END_HOUR and t.min >= CROSS_TIME.FIGHT_END_MIN) then
-- 		sectionIndex = 4
-- 		countDown = (24 - t.hour - 1)*3600 + (60 - t.min - 1)*60 + 60 - t.sec
-- 	elseif t.hour < CROSS_TIME.PIPEI_END_HOUR or 
-- 		(t.hour == CROSS_TIME.PIPEI_END_HOUR and t.min < CROSS_TIME.PIPEI_END_MIN ) then
-- 		sectionIndex = 2 
-- 		local hourOffset = (t.hour == CROSS_TIME.PIPEI_END_HOUR) and 0 or (CROSS_TIME.PIPEI_END_HOUR - t.hour - 1)
-- 		local minOffset = (t.hour == CROSS_TIME.PIPEI_END_HOUR) and 0 or (CROSS_TIME.PIPEI_END_HOUR - t.hour)
-- 		countDown = hourOffset*3600 + (CROSS_TIME.PIPEI_END_MIN + minOffset*60 - t.min - 1)*60 + 60 - t.sec
-- 	else
-- 		local hourOffset = (t.hour == CROSS_TIME.FIGHT_END_HOUR) and 0 or (CROSS_TIME.FIGHT_END_HOUR - t.hour - 1)
-- 		local minOffset = (t.hour == CROSS_TIME.FIGHT_END_HOUR) and 0 or (CROSS_TIME.FIGHT_END_HOUR - t.hour)
-- 		countDown = hourOffset*3600 + (CROSS_TIME.FIGHT_END_MIN + minOffset*60 - t.min - 1)*60 + 60 - t.sec
-- 		sectionIndex = 3
-- 	end

-- __Log("t=%d.%d.%d, countDown:%d, sectionIndex:%d", t.hour, t.min, t.sec, countDown, sectionIndex)
-- 	return sectionIndex, countDown
end

function LegionData:getBattleTimeByStatus( status )
	if not self:isBattleTimeReady() or type(status) ~= "number" then 
		return nil
	end

	return self._cropBattleTimes[status] or {}
end

function LegionData:hasApplyCrossBattle(  )
	return self._crossStatus > 2 
end

function LegionData:isOnWaiting( ... )
	return self._crossStatus == 1
end

function LegionData:isOnApply( ... )
	return self._crossStatus == 2
end

function LegionData:isOnMatch( ... )
	return self._crossStatus == 3
end

function LegionData:isOnBattle( ... )
	return self._crossStatus == 4
end

function LegionData:isBattleFinish( ... )
	return self._crossStatus == 5
end

function LegionData:getCrossStatus( ... )
	return self._crossStatus
end

function LegionData:hasApply( ... )
	return self._hasApply
end

function LegionData:getCrossField( ... )
	return self._crossField
end

function LegionData:isMatchFinish( ... )
	return (self._crossStatus == 3 and self._crossField > 0) or (self._crossStatus > 3)
end

function LegionData:getBattleFieldCount( ... )
	return (self._battleFieldInfo and type(self._battleFieldInfo.corp) == "table") and #self._battleFieldInfo.corp or 0
end

function LegionData:isBattleFieldInit( ... )
	return type(self._battleFieldInfo) == "table" and type(self._battleFieldInfo.ret) == "number"
end

function LegionData:getBattleFieldInfoByIndex( index )
	if type(index) ~= "number" then 
		return nil
	end

	if (self._battleFieldInfo and type(self._battleFieldInfo.corp) == "table") then 
		return (index >= 0 and index <= #self._battleFieldInfo.corp) and self._battleFieldInfo.corp[index] or nil 
	end

	return nil
end

function LegionData:getBattleFreeTimeCD( ... )
	local cd = (type(self._battleFieldInfo) == "table") and self._battleFieldInfo.battle_cd or 0
	local curTime = G_ServerTime:getTime()
	if cd <= curTime then 
		return 0
	end

	return cd - curTime
end

function LegionData:getBattleFreshTimeCD( ... )
	local cd = (type(self._battleFieldInfo) == "table") and self._battleFieldInfo.refresh_cd or 0
	local curTime = G_ServerTime:getTime()
	if cd <= curTime then 
		return 0
	end

	return cd - curTime
end

function LegionData:getWaitingCD( ... )
	if not self:isOnWaiting() then 
		return 0
	end

	local times = self:getBattleTimeByStatus(1)
	local curTime = G_ServerTime:getTime()
	if curTime >= times.close then 
		return 0
	end

	return times.close - curTime
end

function LegionData:getBattleFreshCost( ... )
	return (type(self._battleFieldInfo) == "table") and self._battleFieldInfo.battle_cost or 0
end

function LegionData:getBattleFieldInfo( ... )
	return self._battleFieldInfo
end

function LegionData:getEncourageInfo( ... )
	return self._encourageInfo
end

function LegionData:hasBattleEnemysBySid( sid, corpId )
	if type(sid) ~= "number" or type(corpId) ~= "number" or not self._crossEnemysInfo[sid.."_"..corpId] then 
		return false
	end

	local users = self._crossEnemysInfo[sid.."_"..corpId].users
	return type(users) == "table" and #users > 0 
end

function LegionData:getBattleEnemysBySid( sid, corpId )
	if type(sid) ~= "number" or type(corpId) ~= "number" or not self._crossEnemysInfo[sid.."_"..corpId] then 
		return nil
	end

	return self._crossEnemysInfo[sid.."_"..corpId].users
end

function LegionData:IsBattleCorpFinishBySid( sid, corpId )
	if type(sid) ~= "number" or type(corpId) ~= "number" or not self._crossEnemysInfo[sid.."_"..corpId] then 
		return 0
	end

	if not rawget(self._crossEnemysInfo[sid.."_"..corpId], "is_finish") then 
		return 0
	end

	return self._crossEnemysInfo[sid.."_"..corpId].is_finish
end

function LegionData:calcBattleResult( ... )
	local battleResult = {}
	local finalExp = 0

	if type(self._battleFieldInfo.corp) == "table" then
		for key, value in ipairs(self._battleFieldInfo.corp) do 
			if key ~= 1 then
				finalExp = finalExp + value.robbed_exp - value.rob_exp
				table.insert(battleResult, #battleResult + 1, {sname=value.sname, name=value.name, robbed_exp=value.robbed_exp,rob_exp=value.rob_exp})
			end
		end
	end

	return battleResult, finalExp
end

function LegionData:getBattleRankCount( ... )
	if type(self._crossBattleRankInfo) ~= "table" or #self._crossBattleRankInfo < 1 then
		return 0
	end
	
	return #self._crossBattleRankInfo
end

function LegionData:getBattleRankInfoByIndex( index )
	if type(index) ~= "number" or index < 1 then 
		return nil 
	end

	if type(self._crossBattleRankInfo) ~= "table" or #self._crossBattleRankInfo < 1 or #self._crossBattleRankInfo < index then
		return nil
	end

	return self._crossBattleRankInfo[index]
end

function LegionData:getSelfBattleRankIndex( ... )
	return self._selfBattleRank
end

function LegionData:getCrossApplyCount( ... )
	if type(self._crossCropList) ~= "table" or #self._crossCropList < 1 then
		return 0
	end

	return #self._crossCropList
end

function LegionData:getCorssApplyInfoByIndex( index )
	if type(index) ~= "number" or index < 1 then 
		return nil 
	end

	if type(self._crossCropList) ~= "table" or #self._crossCropList < 1 or #self._crossCropList < index then
		return nil
	end

	return self._crossCropList[index]
end

--新的军团副本

function LegionData:updateNewChapterInfo(data)
	if self:isNeedRequestNewData() then
		self._newChapterData = {}
		G_HandlersManager.legionHandler:sendGetNewDungeonAwardHint()
	end
	self._date = G_ServerTime:getDate()
	self._newAttackTimes  = data.chapter_count
	self._newBuyGold  = data.reset_cost
	self._rollBack = data.rollback_chapter
	if rawget(data,"finish_awards") then
		self._newFinishAwards = data.finish_awards
	else
		self._newFinishAwards = {}
	end
	if rawget(data,"chapters") then
		self:updateNewChapterBaseInfo(data.chapters)
	else
		self._newChapterData = {}
	end

	self._hisMaxFinishDungeon = 0
	for k , v in pairs(data.finish_ch) do 
		if v > self._hisMaxFinishDungeon then
			self._hisMaxFinishDungeon = v 
		end
	end
	-- self._updateNewDungeonData(data.chapters)
end

-- @desc 是否重新需要拉数据
function LegionData:isNeedRequestNewData()
    local dateTime = G_ServerTime:getDate()
    if dateTime ~= self._date  then
        return true
    else
        return false
    end
end

function LegionData:getRollBack()
	return self._rollBack
end

function LegionData:getNextChapter()
	local chapterId = self:getMaxFinishDungeon()
	if not chapterId then
		return 0
	end
	chapterId = self:getDungeonOpen(chapterId+1) and chapterId or chapterId - 1
	return chapterId
end

function LegionData:getTargetChapter()
	local chapterId = self:getNextChapter()
	return self._rollBack and chapterId or chapterId + 1
end

function LegionData:setRollBack(rollBack)
	self._rollBack = rollBack
end

function LegionData:getMaxFinishDungeon()
	return self._hisMaxFinishDungeon
end

function LegionData:getNewChapterInfo(id)
	for k , v in pairs(self._newChapterData) do 
		if v.id == id then
			return v 
		end
	end
	return nil
end

function LegionData:getNewChapterData()
	return self._newChapterData
end

function LegionData:getNewChapterHasGotAward(chapterId)
	for k , v in pairs(self._newFinishAwards) do 
		if v == chapterId then 
			return true
		end
	end
	return false
end

function LegionData:getNewChapterAwardData()
	local sortFunc = function (a,b)
		if a.gotAward and not b.gotAward then
			return false
		end
		if not a.gotAward and b.gotAward then
			return true
		end
		return a.id < b.id
	end
	local awardData = {}
	for index = 1 , corps_dungeon_chapter_info.getLength() do 
		local info = corps_dungeon_chapter_info.indexOf(index)
		if info and info.base_id > 0 then
			info.gotAward = self:getNewChapterHasGotAward(info.id)
			table.insert(awardData,#awardData+1,info)
		end
	end
	table.sort( awardData, sortFunc )
	return awardData
end

function LegionData:updateNewChapterBaseInfo(data)
	self._newCurrentChapter = 0
	for k , v in pairs(data) do 
		local info = self:getNewChapterInfo(v.id)
		if info then
			info.hp = v.hp
			info.max_hp = v.max_hp
			info.is_finish = (v.hp == 0)
		else
			table.insert(self._newChapterData,#self._newChapterData+1,v)
		end
		if self:getDungeonOpen(v.id) and v.id > self._newCurrentChapter then
			self._newCurrentChapter = v.id
		end
	end

	--居然还会回退
	--最多回退一个
	for k , v in pairs(self._newChapterData) do 
		if v then
			local findv = false
			for k2 , v2 in pairs(data) do 
				if v.id == v2.id then
					findv = true
				end
			end
			if not findv then
				table.remove(self._newChapterData,k)
			end
		end
	end
end

function LegionData:haveNewFinishChapter(chapterId)
	local info = self:getNewChapterInfo(chapterId)
	return info.is_finish
end

function LegionData:getNewDungeonInfo(id)
	for k , v in pairs(self._newDungeonData) do 
		if v.id == id then
			return v 
		end
	end
	return nil
end

function LegionData:getNewDungeonData(chapterId)
	local info = corps_dungeon_chapter_info.get(chapterId)
	if info then
		local data = {}
		for i = 1 , 4 do 
			local temp = self:getNewDungeonInfo(info["dungeon_"..i])
			if temp then
				table.insert(data,#data+1,temp)
			end
		end
		return data
	end
	return {}
end

function LegionData:updateNewCorpDungeonInfo(data)
	for k , v in pairs(data.dungeon) do 
		local info = self:getNewDungeonInfo(v.id)
		if info then
			info.hp = v.hp
			info.max_hp = v.max_hp
			info.kill_name = v.kill_name
			info.is_finish = (v.hp == 0)
			info.chapterId = data.chapter_id
		else
			v.chapterId = data.chapter_id
			v.is_finish = (v.hp == 0)
			table.insert(self._newDungeonData,#self._newDungeonData+1,v)
		end
	end
end

function LegionData:onNewCorpDungeonExecute(data)
	local dungeonData = data.dungeon
	local info = self:getNewDungeonInfo(dungeonData.id)
	if info then
		info.hp = dungeonData.hp
		info.max_hp = dungeonData.max_hp
		info.kill_name = dungeonData.kill_name
		info.is_finish = (dungeonData.hp == 0)
	end
end

function LegionData:updateNewDungeonAwardList(data)
	local info = self:getNewDungeonInfo(data.dungeon_id)
	if info then
		info.has_award = data.has_award
		info.has_auth = data.has_auth
		info.award_id = 0
		info.award_init = true
		if rawget(data,"list") then
			info.awardList = data.list
			for k , v in pairs(data.list) do 
				if v.name == G_Me.userData.name then
					info.award_id = v.id
				end
			end
		else
			info.awardList = {}
		end
	end
end

function LegionData:onAddNewDungeonAward(id,award)
	local info = self:getNewDungeonInfo(id)
	if info then
		if not rawget(info,"awardList") then
			info.awardList = {}
		end
		local awardInfo = self:getNewDungeonAwardByIndex(id,award.index)
		if not awardInfo then
			table.insert(info.awardList,#info.awardList,award)
		end
		if award.name == G_Me.userData.name then
			info.award_id = award.id
		end	
	end
end

function LegionData:getNewDungeonAwardHasGet(dungeonId)
	local info = self:getNewDungeonInfo(dungeonId)
	if rawget(info,"has_award") then
		return info.has_award
	else
		return false
	end
end

function LegionData:getNewDungeonMyAward(dungeonId)
	local info = self:getNewDungeonInfo(dungeonId)
	-- for k , v in pairs(info.awardList) do 
	-- 	if v.name == G_Me.userData.name then
	-- 		return v
	-- 	end
	-- end
	return info.award_id
end

function LegionData:getNewDungeonAwardCanGet(dungeonId)
	local info = self:getNewDungeonInfo(dungeonId)
	if rawget(info,"has_auth") then
		return info.has_auth
	else
		return true
	end
end

function LegionData:getNewDungeonAwardByIndex(dungeonId,index)
	local info = self:getNewDungeonInfo(dungeonId)
	if info and rawget(info,"awardList") then
		for k , v in pairs(info.awardList) do 
			if v.index == index then
				return v
			end
		end
	end
	return nil
end

function LegionData:haveNewFinishDungeon(dungeonId)
	local info = self:getNewDungeonInfo(dungeonId)
	if info then
		return info.is_finish
	else
		return false
	end
end

function LegionData:updateNewHasAward(id,has_award)
	local info = self:getNewDungeonInfo(id)
	if info then
		info.has_award = has_award
	end
end

function LegionData:updateNewLegionRank(data)

	self._newMyRank = 0
	self._newRankList = data.ranks or {}
	local _sortRanks = function ( mem1, mem2 )
		if not mem1 then 
			return true
		elseif not mem2 then 
			return false
		end

		if mem1.harm ~= mem2.harm then 
			return mem1.harm > mem2.harm 
		end

		return mem1.id < mem2.id
	end

	local myselfId = G_Me.userData.id
	table.sort(self._newRankList, _sortRanks)

	local loopi = 1
	for key, value in pairs(self._newRankList) do 
		value.rank = loopi
		loopi = loopi + 1

		if value.id == myselfId then 
			self._newMyRank = value.rank
		end
	end
end

function LegionData:getNewLegionRank()
	return self._newRankList
end

function LegionData:getNewMyLegionRank()
	return self._newMyRank
end

function LegionData:getNewLegionRankByIndex(index)
	return self._newRankList[index]
end

function LegionData:addNewBuyTimes(data)
	self._newAttackTimes = data.chapter_count
	self._newBuyGold = data.reset_cost
end

function LegionData:onNewChapterHpUpdate(hp)
	local info = self:getNewChapterInfo(self._newCurrentChapter)
	info.hp = info.hp - hp
end

function LegionData:updateNewChapterAward(data)
	table.insert(self._newFinishAwards,#self._newFinishAwards+1,data.id)
end

function LegionData:getNewCurrentChapter()
	return self._newCurrentChapter
end

function LegionData:getNewBuyTimes()
	return self._newAttackTimes
end

function LegionData:getNewNextGold()
	return self._newBuyGold 
end

function LegionData:getDugeonEndTime()
	local cur = G_ServerTime:getCurrentDayLeftSceonds()
	if cur > LegionData.DUNGEON_START_TIME or cur < LegionData.DUNGEON_END_TIME then
		return -1 
	else
		return cur - LegionData.DUNGEON_END_TIME
	end
	return -1
end

function LegionData:getAwardEndTime()
	local cur = G_ServerTime:getCurrentDayLeftSceonds()
	if cur > LegionData.DUNGEON_START_TIME or cur < LegionData.DUNFEON_AWARD_END_TIME then
		return -1 
	else
		return cur - LegionData.DUNFEON_AWARD_END_TIME
	end
	return -1
end

function LegionData:updateNewDungeonAwardHint(data)
	self._date = G_ServerTime:getDate()
	for k , v in pairs(data.hints) do 
		local info = self:getNewDungeonInfo(v.id)
		if info then
			info.is_finish = v.is_finish
			info.has_award = v.has_award
			info.has_auth = v.has_auth
			info.award_id = v.award_id 
		else
			table.insert(self._newDungeonData,#self._newDungeonData+1,v)
		end
	end
end

function LegionData:getNewAwardPreviewList(dungeonId)
	local awardType = corps_dungeon_info.get(dungeonId).award_type
	local award = {}
	for index = 1 , corps_dungeon_award_info.getLength() do 
		local info = corps_dungeon_award_info.indexOf(index)
		if info and info.type == awardType then
			info.gotCount = self:getNewAwardCount(dungeonId,info.id)
			table.insert(award,#award+1,info)
		end
	end
	return award
end

function LegionData:getNewAwardInited(dungeonId)
	return rawget(self:getNewDungeonInfo(dungeonId),"award_init")
end

function LegionData:getNewAwardCount(dungeonId,awardId)
	local count = 0
	local info = self:getNewDungeonInfo(dungeonId)
	if not rawget(info,"awardList") then
		return 0 
	end
	local award = info.awardList
	for k , v in pairs(award) do 
		if v.id == awardId then
			count = count +1 
		end
	end
	return count
end

function LegionData:getNewAwardPreviewListByChapter(chapterId)
	local info = corps_dungeon_chapter_info.get(chapterId)
	local data = {}
	for i = 1 , 4 do 
		local awardCell = {}
		awardCell.award = self:getNewAwardPreviewList(info["dungeon_"..i])
		awardCell.name = corps_dungeon_info.get(info["dungeon_"..i]).dungeon_name_1
		table.insert(data,#data+1,awardCell)
	end
	return data
end

function LegionData:getNewChapterFinishNeedTip()
	local data = self:getNewChapterData()
	for id = 1 , self._hisMaxFinishDungeon do 
		if id < self:getNewCurrentChapter() and not self:getNewChapterHasGotAward(id) then
			return true
		end
	end
	return false
end

function LegionData:getNewChapterFightTip()
	if self:getDugeonEndTime() < 0 then
		return false
	end
	return self:getNewBuyTimes() > 0 and self:getDungeonOpen(1)
end

function LegionData:getNewChapterMapNeedTip()
	local data = self:getNewChapterData()
	for k , v in pairs(data) do 
		local id = v.id
		if id < self:getNewCurrentChapter() and not self:getNewChapterHasGotAward(id) then
			return true
		end
		if self:getNewChapterAwardNeedTip(id) then
			return true
		end
	end
	return false
end

function LegionData:getNewChapterAwardNeedTip(chapterId)
	if self:getAwardEndTime() < 0 then
		return false
	end
	local dungeonsData = self:getNewDungeonData(chapterId)
	if dungeonsData then
		for k , v in pairs(dungeonsData) do
			if self:haveNewFinishDungeon(v.id) and not self:getNewDungeonAwardHasGet(v.id) then
				return true
			end
		end
	end
	return false
end

function LegionData:getNewBattleAward(damage,hpMax,min,max)
	return math.min(max,min+math.floor((damage/hpMax)/0.001))
end

function LegionData:getDungeonOpen(chapterId)
	chapterId = chapterId or 1
	local info = corps_dungeon_chapter_info.get(chapterId)
	return self._corpDetail and info and info.base_id > 0 and self._corpDetail.level >= info.open_level
end

function LegionData:updateTechInfo(data)
	self._corpTech = data.corp_techs
	self._userTech = data.user_techs
end

function LegionData:updateTechBroadcast(data)
	self._corpTech = data.corp_techs
end

function LegionData:getTechDevelopLevel(id)
	for k , v in pairs(self._corpTech) do 
		if v.tech_id == id then
			return v.tech_level
		end
	end
	return 0
end

function LegionData:getTechLearnLevel(id)
	for k , v in pairs(self._userTech) do 
		if v.tech_id == id then
			return v.tech_level
		end
	end
	return 0
end

function LegionData:getTechTxt(id,level,_type)
	if level == 0 then
		return G_lang:get("LANG_LEGION_TECH_HAS_CLOSED".._type)
	end
	local info = corps_technology_info.get(id,level)
	if not info then
		return G_lang:get("LANG_LEGION_TECH_FULL")
	end
	local MergeEquipment = require("app.data.MergeEquipment")
	local _,_,typeStr,valueStr = MergeEquipment.convertAttrTypeAndValue(info.attr_type,info.attr_size)
	return info.assistant_description..valueStr
end

function LegionData:onDevelopTech(data)
	local find = false
	for k , v in pairs(self._corpTech) do 
		if v.tech_id == data.tech_id then
			find = true
			v.tech_level = data.tech_level
		end
	end
	if not find then
		table.insert(self._corpTech,#self._corpTech+1,{tech_id=data.tech_id,tech_level=data.tech_level})
	end
	self._corpDetail.exp = data.exp
end

function LegionData:onLearnTech(data)
	local find = false
	for k , v in pairs(self._userTech) do 
		if v.tech_id == data.tech_id then
			find = true
			v.tech_level = data.tech_level
		end
	end
	if not find then
		table.insert(self._userTech,#self._userTech+1,{tech_id=data.tech_id,tech_level=data.tech_level})
	end
end

function LegionData:onUpLevel(data)
	self._corpDetail.exp = data.exp
	self._corpDetail.level = data.level
end

function LegionData:isTechOpen(id)
	if not corps_technology_info.get(id,1) then
		return false
	end
	return self._corpDetail.level >= corps_technology_info.get(id,1).require_corpslevel
end

--获取军团科技的加成
function LegionData:getTechAdd()
	local data = {}
	for k , v in pairs(self._userTech) do 
		local info = corps_technology_info.get(v.tech_id,v.tech_level)
		if data[info.attr_type] then
			data[info.attr_type] = data[info.attr_type] + info.attr_size
		else
			data[info.attr_type] = info.attr_size
		end
	end
	return data
end

function LegionData:resetTechData()
	self._corpTech = {}
	self._userTech = {}
end

--state 用于排序
function LegionData:getTechState(id,_type)
	local learnLevel = self:getTechLearnLevel(id)
	local developLevel = self:getTechDevelopLevel(id)
	local techLevel = {learnLevel,developLevel}
	if _type == 1 and developLevel == 0 then
		return 0
	end
	if _type == 2 and corps_technology_info.get(id,1).require_corpslevel > self:getCorpDetail().level then
		return 0 
	end
	return techLevel[_type] > 0 and 1 or 2
end

function LegionData:isTechFunctionOpen()
	return self:getCorpDetail().level >= LegionData.TECH_OPEN_LEVEL
end

return LegionData

