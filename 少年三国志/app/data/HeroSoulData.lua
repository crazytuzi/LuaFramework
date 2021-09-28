require("app.cfg.ksoul_info")
require("app.cfg.ksoul_group_info")
require("app.cfg.ksoul_dungeon_info")
require("app.cfg.ksoul_summon_info")
require("app.cfg.ksoul_group_target_info")
require("app.cfg.ksoul_group_chapter_info")

local VipConst = require("app.const.VipConst")
local HeroSoulConst = require("app.const.HeroSoulConst")

---------------------------------------------
local SoulRankData = class("SoulRankData")

function SoulRankData:ctor(data)
	self.id 		= data.id
	self.sid 		= data.sid
	self.name 		= rawget(data, "name") or ""
	self.sname		= rawget(data, "sname") or ""
	self.main_role	= rawget(data, "main_role") or 1
	self.dress_id	= rawget(data, "dress_id") or 0
	self.chartPoint = rawget(data, "sp1") or 0	-- 阵图值
	self.chartNum 	= rawget(data, "sp2") or 0 	-- 已激活阵图数
end
-------------------------------------------

local HeroSoulData = class("HeroSoulData")

function HeroSoulData:ctor()
	self._souls	= {} 					-- 所拥有的将灵表 key: soul ID, value: number
	
	-- 阵图
	self._chartPoints = 0				-- 阵图值
	self._totalChartsByChap		= {}	-- 每章所有的阵图ID
	self._totalChartsBySoul		= {}	-- 每个将灵所关联的所有阵图ID
	self._activatedCharts 		= {}	-- 所有已激活的阵图
	self._activatedChartsMap	= {} 	-- 以阵图ID为key的激活表
	self._activatedChartsByChap = {}	-- 每章已激活的阵图
	self._chartAttrs			= {}	-- 阵图带来的属性加成表

	-- 成就
	self._activatedAchievements = {}	-- 已激活的阵图成就
	self._achievementAttrs		= {}	-- 成就带来的属性加成表

	-- 排行
	self._localRank				= 0		-- 我的本服排名
	self._crossRank 			= 0		-- 我的全服排名
	self._localRankList 		= {}	-- 本服排行榜
	self._crossRankList 		= {}	-- 全服排行榜

	-- 副本
	self._nDgnRefreshCount = 0			-- 副本已经刷新次数
	self._nDgnChallengeCount = 0 		-- 副本已经挑战次数

	-- 商店
	self._nShopRefreshCount = 0			-- 今天商店刷新过的次数
	self._nNextTimestamp = 0			-- 下次刷新的时间戳

	-- 点将
	self._nFreeExtractCount = 0			-- 免费点将次数
	self._nQiyuValue = 0				-- 奇遇值
	self._nCircleExtractCount = 0		-- 轮回内已经点将的次数（0~4取值）
	self._tExchangeList = {}			-- 今日奇遇兑换将灵的信息

	self._bClickedShop = false			-- 有没有点过商店

	self._nMovePercent = 50				-- mainlayer滚动到的百分比

	self._bOnActivating = false			-- 是否正在激活一个阵图，要等动画结束后，才能继续激活下一个

	self._tDate = nil 					-- 记录下基础协议是哪时候拉的

	-- initialize some data
	self:_classifyAllCharts()
end

--[[
message S2C_GetKsoul {
  repeated Ksoul ksouls = 1;//将灵
  repeated uint32 ksoul_groups = 2;//已激活的阵图
  repeated uint32 ksoul_targets = 3;//阵图成就
  optional uint32 free_summon = 4;//免费点将次数
  //optional uint32 summon_score = 5;//点将点数
  optional uint32 summon_count = 6;//轮回内已经点将的次数
  repeated Ksoul summon_exchange = 7;//今日奇遇兑换的信息
  optional uint32 dungeon_challenge_cnt = 8;
  optional uint32 dungeon_refresh_cnt = 9;
}

]]

function HeroSoulData:setSoulInfo(data)
	self:_reset()

	if rawget(data, "ksouls") then
		for i, v in ipairs(data.ksouls) do
			self._souls[v.id] = v.num
		end
	end

	if rawget(data, "ksoul_groups") then
		self._activatedCharts = clone(data.ksoul_groups)

		-- map
		for i, v in ipairs(self._activatedCharts) do
			self._activatedChartsMap[v] = true
		end

		-- attributes by chart
		self:_updateChartAttrs()
	end

	if rawget(data, "ksoul_targets") then
		self._activatedAchievements = clone(data.ksoul_targets)
		self:_updateAchievementAttrs()
	end

	-- 免费点将次数
	if rawget(data, "free_summon") then
		self._nFreeExtractCount = data.free_summon
	end

	-- 轮回内已经点将的次数（0~4取值）
	if rawget(data, "summon_count") then
		self._nCircleExtractCount = data.summon_count
	end

	-- 名将试炼挑战次数
	if rawget(data, "dungeon_challenge_cnt") then
		self._nDgnChallengeCount = data.dungeon_challenge_cnt
	end

	-- 名将试炼刷新次数
	if rawget(data, "dungeon_refresh_cnt") then
		self._nDgnRefreshCount = data.dungeon_refresh_cnt
	end

	-- calculate total chart points
	self:_calcChartPoints()

	-- classify charts by chapter
	self:_classifyChartsByChapter()

	self._tDate = G_ServerTime:getDate()
end

function HeroSoulData:setShopInfo(nRefreshCount, nNextTimestamp)
	self._nShopRefreshCount = nRefreshCount
	self._nNextTimestamp = nNextTimestamp
end

-- 激活阵图
function HeroSoulData:setActivateChart(chartId)
	self._activatedCharts[#self._activatedCharts + 1] = chartId
	self._activatedChartsMap[chartId] = true

	-- 增加阵图值
	local chartInfo = ksoul_group_info.get(chartId)
	self._chartPoints = self._chartPoints + chartInfo.target_value

	-- 添加到章节的已激活列表
	local chapterId = chartInfo.chapter_id
	if not self._activatedChartsByChap[chapterId] then
		self._activatedChartsByChap[chapterId] = {}
	end

	local arr = self._activatedChartsByChap[chapterId]
	arr[#arr + 1] = chartId

	-- 添加属性加成
	self:_addChartAttr(chartId)
end

-- 激活成就
function HeroSoulData:setActivateAchievement(achieveId)
	local len = #self._activatedAchievements
	self._activatedAchievements[len + 1] = achieveId
	self:_addAchievementAttr(achieveId)
end

-- 刷新将灵数量
function HeroSoulData:updateSoulNum(data)
	if rawget(data, "insert_ksouls") then
		for i, v in ipairs(data.insert_ksouls) do
			self._souls[v.id] = v.num
		end
	end

	if rawget(data, "update_ksouls") then
		for i, v in ipairs(data.update_ksouls) do
			self._souls[v.id] = v.num
		end
	end

	if rawget(data, "delete_ksouls") then
		for i, v in ipairs(data.delete_ksouls) do
			self._souls[v] = nil
		end
	end
end

-- 刷新排行榜
function HeroSoulData:updateChartRanks(data)
	local ranks = {}

	-- rank list
	if rawget(data, "rank") then
		for i, v in ipairs(data.rank) do
			ranks[#ranks + 1] = SoulRankData.new(v)
		end
	end

	-- set data
	local myRank = rawget(data, "self_rank") or 0
	if data.r_type == HeroSoulConst.RANK_LOCAL then
		self._localRank = myRank
		self._localRankList = ranks
	else
		self._crossRank = myRank
		self._crossRankList = ranks
	end
end

function HeroSoulData:getSoulList() return self._souls end
function HeroSoulData:getSoulNum(soulId) return self._souls[soulId] or 0 end
function HeroSoulData:getChartPoints() return self._chartPoints end
function HeroSoulData:getActivatedChartsNum() return #self._activatedCharts end
function HeroSoulData:getAllChartsByChap(chapterId) return self._totalChartsByChap[chapterId] end
function HeroSoulData:getAllChartsBySoul(soulId) return self._totalChartsBySoul[soulId] end
function HeroSoulData:getAchivementAttrs() return self._achievementAttrs end
function HeroSoulData:getChartAttrs() return self._chartAttrs end
function HeroSoulData:setOnActivating(bOn) self._bOnActivating = bOn end
function HeroSoulData:getOnActivating() return self._bOnActivating end

function HeroSoulData:setFreeExtractCount(nCount)
	self._nFreeExtractCount = nCount
end
function HeroSoulData:getFreeExtractCount()
	return self._nFreeExtractCount
end

-- 轮回内已经点将的次数（0~4取值）
function HeroSoulData:setCircleExtractCount(nCount)
	self._nCircleExtractCount = nCount
end
function HeroSoulData:getCircleExtractCount()
	return self._nCircleExtractCount
end

function HeroSoulData:setClickedShop()
	self._bClickedShop = true
end

-- 显示商店的红点
function HeroSoulData:showSoulShopRedTips()
	return G_ServerTime:getLeftSeconds(self._nNextTimestamp) < 0 or not self._bClickedShop
end

function HeroSoulData:setMovePercent(nPercent)
	self._nMovePercent = nPercent or 0
end

function HeroSoulData:getMovePercent()
	return self._nMovePercent
end

-- 获取某一章节总的阵图数量
function HeroSoulData:getTotalChartsNumByChap(chapterId)
	if self._totalChartsByChap[chapterId] then
		return #self._totalChartsByChap[chapterId]
	end

	return 0
end

-- 获取某一章节已激活的阵图数量
function HeroSoulData:getActivatedChartsNumByChap(chapterId)
	if self._activatedChartsByChap[chapterId] then
		return #self._activatedChartsByChap[chapterId]
	end

	return 0
end

-- 根据阵图Id获取其在章节中的序号
function HeroSoulData:getChartIndexById(chartId)
	for k, v in pairs(self._totalChartsByChap) do
		for i = 1, #v do
			if v[i] == chartId then
				return i
			end
		end
	end

	return 0
end

-- 获取我的阵图排名
function HeroSoulData:getChartRank(rankType)
	return rankType == HeroSoulConst.RANK_LOCAL and self._localRank or self._crossRank
end

-- 获取阵图排行榜中的玩家数量
function HeroSoulData:getChartRankNum(rankType)
	local srcList = rankType == HeroSoulConst.RANK_LOCAL and self._localRankList or self._crossRankList
	return #srcList
end

-- 获取阵图排行榜中的玩家
function HeroSoulData:getChartRankUser(rankType, rank)
	local srcList = rankType == HeroSoulConst.RANK_LOCAL and self._localRankList or self._crossRankList
	return srcList[rank]
end

-- 获取上一个激活的成就ID
function HeroSoulData:getLastActivatedAchievement()
	local maxID = 0
	for i, v in ipairs(self._activatedAchievements) do
		if v > maxID then
			maxID = v
		end
	end

	return maxID
end

function HeroSoulData:setDungeonInfo(nRefreshCount, nChallengeCount)
	self._nDgnRefreshCount = nRefreshCount
	self._nDgnChallengeCount = nChallengeCount
end

function HeroSoulData:getDgnRefreshCount()
	return self._nDgnRefreshCount
end

function HeroSoulData:getDgnChallengeCount()
	return self._nDgnChallengeCount
end

function HeroSoulData:getLeftDgnChallengeCount()
	return math.max(G_Me.vipData:getData(VipConst.HERO_SOUL_TRIAL).value - self._nDgnChallengeCount, 0)
end

function HeroSoulData:getShopRefreshCount()
	return self._nShopRefreshCount
end

function HeroSoulData:getNextTimestamp()
	return self._nNextTimestamp
end

-- whether a chart is activated
function HeroSoulData:isChartActivated(chartId)
	return self._activatedChartsMap[chartId] or false
end

-- can a chart be activated
function HeroSoulData:canActivateChart(chartId)
	-- 如果已经激活了，不能再激活
	if self:isChartActivated(chartId) then
		return false
	end
	
	-- 前置阵图是否已激活
	local chartInfo = ksoul_group_info.get(chartId)
	local isPreChartOK = true
	if chartInfo.pre_id > 0 then
		isPreChartOK = self:isChartActivated(chartInfo.pre_id)
	end

	-- 所需将灵是否都已拥有
	if isPreChartOK then
		for i = 1, HeroSoulConst.MAX_SOUL_PER_CHART do
			local soulId = chartInfo["ksoul_id" .. i]
			if soulId > 0 then
				if self:getSoulNum(soulId) == 0 then
					return false
				end
			end
		end

		return true
	end

	return false
end

-- get the number of lacking heros of a chart
function HeroSoulData:getChartLackHeroNum(chartId)
	local chartInfo = ksoul_group_info.get(chartId)
	local lackNum   = 0
	for i = 1, HeroSoulConst.MAX_SOUL_PER_CHART do
		local soulId = chartInfo["ksoul_id" .. i]
		if soulId > 0 and self:getSoulNum(soulId) == 0 then
			lackNum = lackNum + 1
		end
	end

	return lackNum
end

-- whether an achievement is activated
function HeroSoulData:isAchievementActivated(achieveId)
	for i, v in ipairs(self._activatedAchievements) do
		if v == achieveId then
			return true
		end
	end

	return false
end

function HeroSoulData:isPrevAchievementActivated(achieveId)
	return self:isAchievementActivated(achieveId - 1)
end

function HeroSoulData:isNextAchievementActivated(achieveId)
	return self:isAchievementActivated(achieveId + 1)
end

-- can an achievement be activated
function HeroSoulData:canActivateAchievement(achieveId)
	-- 已经激活过了，不能再激活
	if self:isAchievementActivated(achieveId) then
		return false
	end

	local achieveInfo = ksoul_group_target_info.get(achieveId)

	-- 判断阵图值和前置成就是否满足
	if achieveInfo then
		if self._chartPoints < achieveInfo.target_value then
			return false
		else
			if achieveInfo.pre_id == 0 then
				return true
			else				
				return self:isAchievementActivated(achieveInfo.pre_id)
			end
		end
	end

	return false
end

-- classify all charts by each chapter and each hero-soul
function HeroSoulData:_classifyAllCharts()
	local chartsNum = ksoul_group_info.getLength()
	for i = 1, chartsNum do
		local chartInfo = ksoul_group_info.indexOf(i)

		-- classify by each chapter
		local chapterId = chartInfo.chapter_id

		if not self._totalChartsByChap[chapterId] then
			self._totalChartsByChap[chapterId] = {}
		end
		table.insert(self._totalChartsByChap[chapterId], chartInfo.id)

		-- classify by each hero-soul
		for j = 1, HeroSoulConst.MAX_SOUL_PER_CHART do
			local soulId = chartInfo["ksoul_id" .. j]
			if soulId > 0 then
				if not self._totalChartsBySoul[soulId] then
					self._totalChartsBySoul[soulId] = {}
				end
				table.insert(self._totalChartsBySoul[soulId], chartInfo.id)
			end
		end
	end
end

-- calculate total chart points
function HeroSoulData:_calcChartPoints()
	self._chartPoints = 0
	for i, v in ipairs(self._activatedCharts) do
		local chartInfo = ksoul_group_info.get(v)
		self._chartPoints = self._chartPoints + chartInfo.target_value
	end
end

-- classify the activated charts by chapter
function HeroSoulData:_classifyChartsByChapter()
	for i, v in ipairs(self._activatedCharts) do
		local chartInfo = ksoul_group_info.get(v)
		local chapterId = chartInfo.chapter_id

		if not self._activatedChartsByChap[chapterId] then
			self._activatedChartsByChap[chapterId] = {}
		end

		local arr = self._activatedChartsByChap[chapterId]
		arr[#arr + 1] = v
	end
end

-- update the additionnal attributes caused by charts
function HeroSoulData:_updateChartAttrs()
	self._chartAttrs = {}

	for i, v in ipairs(self._activatedCharts) do
		self:_addChartAttr(v)
	end
end

function HeroSoulData:_addChartAttr(chartId)
	local chartInfo = ksoul_group_info.get(chartId)

	for i = 1, HeroSoulConst.MAX_ATTR_PER_CHART do
		local attrType  = chartInfo["attribute_type" .. i]
		local attrValue = chartInfo["attribute_value" .. i]

		if attrType > 0 and attrValue > 0 then
			local oldValue = self._chartAttrs[attrType] or 0
			self._chartAttrs[attrType] = oldValue + attrValue
		end
	end
end

-- update the additional attributes caused by achievements
function HeroSoulData:_updateAchievementAttrs()
	self._achievementAttrs = {}

	for i, v in ipairs(self._activatedAchievements) do
		self:_addAchievementAttr(v)
	end
end

function HeroSoulData:_addAchievementAttr(achieveId)
	local achieveInfo = ksoul_group_target_info.get(achieveId)
	local attrType = achieveInfo.attribute_type1
	local attrValue = achieveInfo.attribute_value1

	local oldValue = self._achievementAttrs[attrType] or 0
	self._achievementAttrs[attrType] = oldValue + attrValue
end

-- 某个将灵相关的阵图是否都已经激活了
function HeroSoulData:isActivatedAllCharts(soulId)
	local charts = self:getAllChartsBySoul(soulId)
	for i, v in ipairs(charts) do
		if not G_Me.heroSoulData:isChartActivated(v) then
			return false
		end
	end
	
	return true
end

-- 某个章节是否已开启
function HeroSoulData:isChapterUnlocked(chapterId)
	local chapterInfo = ksoul_group_chapter_info.get(chapterId)

	-- first check the level request
	if G_Me.userData.level < chapterInfo.level then
		return false
	else
		local preChapter = chapterInfo.pre_chapter
		if preChapter > 0 then
			-- check the activated charts count of the pre-chapter
			local curActivatedNum = G_Me.heroSoulData:getActivatedChartsNumByChap(preChapter)
			return curActivatedNum >= chapterInfo.group_num
		else
			return true
		end
	end
end

-- 当前soulId对应的打开的阵图列表，如果有材料即可激活
function HeroSoulData:getOpenedChartList(soulId)
	local tChartIdList = {}
	local charts = self:getAllChartsBySoul(soulId)
	for i, v in ipairs(charts) do
		if not self:isChartActivated(v) then
			local chartInfo = ksoul_group_info.get(v)
			local isChapterUnlocked = self:isChapterUnlocked(chartInfo.chapter_id)
			
			if isChapterUnlocked and (chartInfo.pre_id == 0 or self:isChartActivated(chartInfo.pre_id)) then
				table.insert(tChartIdList, #tChartIdList + 1, v)
			end
		end
	end
	return tChartIdList
end

-- 所有打开的章节的阵图中，这个将灵是否需要
function HeroSoulData:isSoulNeeded(soulId)
	return #self:getOpenedChartList(soulId) > self:getSoulNum(soulId)
end

-- 所有打开的章节的阵图中，这个将灵是否急需，即买了它，可以马上激活一条阵图
function HeroSoulData:isSoulBadlyNeeded(soulId)
	local isBadlyNeeded = false
	local tChartIdList = self:getOpenedChartList(soulId)

	-- 急需的阵图列表
	local tBadlyNeededChartIdList = {}
	for i=1, #tChartIdList do
		local tChartTmpl = ksoul_group_info.get(tChartIdList[i])
		assert(tChartTmpl)
		local isPartnersExist = true
		for j=1, HeroSoulConst.MAX_SOUL_PER_CHART do
			local nSoulId = tChartTmpl["ksoul_id" .. j]
			if nSoulId > 0 and nSoulId ~= soulId then
				if self:getSoulNum(nSoulId) == 0 then
					isPartnersExist = false
					break
				end
			end
		end
		if isPartnersExist then
			table.insert(tBadlyNeededChartIdList, #tBadlyNeededChartIdList + 1, tChartTmpl)
		end
	end

	if self:getSoulNum(soulId) < #tBadlyNeededChartIdList then
		isBadlyNeeded = true
	end

	return isBadlyNeeded
end

------------- 红点相关 -------------------------

-- 是否有灵阵图可激活
function HeroSoulData:hasChartToActivate()
	local numChapters = ksoul_group_chapter_info.getLength()
	for i = 1, numChapters do
		local chapterId = ksoul_group_chapter_info.indexOf(i).id
		if self:hasChartToActivateByChap(chapterId) then
			return true
		end
	end

	return false
end

-- 某一章节是否有灵阵图可激活
function HeroSoulData:hasChartToActivateByChap(chapterId)
	if not self:isChapterUnlocked(chapterId) then
		return false
	end

	local charts = self._totalChartsByChap[chapterId]
	for i, v in ipairs(charts) do
		if self:canActivateChart(v) then
			return true
		end
	end

	return false
end

-- 是否有成就可激活
function HeroSoulData:hasAchievementToActivate()
	-- 最后一个激活的成就ID
	local lastAchievement = self:getLastActivatedAchievement()

	-- 若还未激活所有成就，检查下一个成就是否可激活
	if lastAchievement < ksoul_group_target_info.getLength() then
		return self:canActivateAchievement(lastAchievement + 1)
	end

	-- 所有成就都激活了，返回false
	return false
end

function HeroSoulData:_reset()
	self._activatedCharts 		= {}	-- 所有已激活的阵图
	self._activatedChartsMap	= {} 	-- 以阵图ID为key的激活表
	self._activatedChartsByChap = {}	-- 每章已激活的阵图
	self._chartAttrs			= {}	-- 阵图带来的属性加成表

	-- 成就
	self._activatedAchievements = {}	-- 已激活的阵图成就
	self._achievementAttrs		= {}	-- 成就带来的属性加成表
end

-- 是否隔天了，需要重新拉取基础协议
function HeroSoulData:isAnotherDay()
	if self._tDate ~= G_ServerTime:getDate() then
		self._tDate = G_ServerTime:getDate()
		return true
	end
	return false
end

-----------------------------------------------

return HeroSoulData