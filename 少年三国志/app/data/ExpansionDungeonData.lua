require("app.cfg.expansion_dungeon_chapter_info")
require("app.cfg.expansion_dungeon_stage_info")
require("app.cfg.expansion_dungeon_shop_info")

local ExpansionDungeonData = class("ExpansionDungeonData")


require("app.cfg.expansion_dungeon_chapter_info")
require("app.cfg.expansion_dungeon_stage_info")

function ExpansionDungeonData:ctor()
	self:_init()
end

function ExpansionDungeonData:_init()
	self._tChatperList = {}

	-- 有没有开启新的章节
	self._isOpenNewChapter = false
	-- 有没有开启新的stage
	self._isOpenNewStage = false

	self._tAtkStage = nil
	self._tStoredMaxStage = nil  -- 另外存储一份最大stage的数据，方便战斗后进行比较


	-- 当前章节地图的y轴位置和缩放尺寸
	self._tMapLayerPosYAndScale = {
		_nChapterId = 0, -- 只针对这个章节有效
		_nPosY = 100, --默认值
		_nScale = 1,
	}

	self._nAtkChatperId = 0 -- 玩家选择的章节id,方便从GateScene退回到MainScene

	self._tStageAwardList = {} -- 达成一个目标后，回到GateScene

	-- 用来判断是否是第一次通关全部章节
	self._tPassTotalChapterState = {
		_bBeforeAtk = false,
		_bAfterAtk = false,
	}

	-- 上线后，如果商店中有物品，入口icon上显示一下红点，点进去后消失
	self._nLoginMark = true
end

function ExpansionDungeonData:storeChapterList(chapters)
	for key, val in pairs(chapters) do
		local chapter = val
		local tChapter = self:_packChatper(chapter)
		self._tChatperList[tChapter._nId] = tChapter  -- chapter的id作为索引
	end
end

function ExpansionDungeonData:getChapterList()
	return self._tChatperList
end

function ExpansionDungeonData:getChapterById(nChapterId)
	local tChapter = self._tChatperList[nChapterId]
	return tChapter
end

function ExpansionDungeonData:getStageById(nChapterId, nStageId)
	local tChapter = self:getChapterById(nChapterId)
	local tStage = nil
	if tChapter then
		tStage = tChapter._tStageList[nStageId]
	end
	return tStage
end

function ExpansionDungeonData:_packChatper(chapter)
	local tChapter = {}
	tChapter._nId = chapter.id
	tChapter._nStar = chapter.star
	tChapter._hasAwarded = chapter.has_awarded  -- 是否领取章节奖励
	tChapter._hasEntered = chapter.has_entered  -- 是否第一次进入
	tChapter._tStageList = {}					-- 关卡列表
	tChapter._tItemList = {}					-- 商品列表
	for key, val in pairs(chapter.stages) do
		local stage = val
		local tStage = self:_packStage(stage)
		tChapter._tStageList[tStage._nId] = tStage  -- stage的id作为索引 
	end
	for key, val in pairs(chapter.items) do
		local item = val
		local tItem = {}
		tItem._nId = item.id   					-- 商品id
		tItem._nCount = item.num 				-- 该商品已购买次数
		tChapter._tItemList[tItem._nId] = tItem -- 使用商品id做key
	end


	return tChapter
end

function ExpansionDungeonData:_packStage(stage)
	local tStage = {}
	tStage._nId = stage.id
	tStage._bTarget1 = stage.target1   -- 目标1是否完成，完成则算这个stage被完成了
	tStage._bTarget2 = stage.target2   -- 目标2
	tStage._bTarget3 = stage.target3   -- 目标3
	tStage._nMaxUId = stage.max_uid
	tStage._szMaxName = stage.max_name
	tStage._nMaxFV = stage.max_fv
	tStage._nMinUId = stage.min_uid
	tStage._szMinName = stage.min_name
	tStage._nMinFV = stage.min_fv

	return tStage
end

function ExpansionDungeonData:updateChapter(nChapterId, chapter)
	if type(nChapterId) ~= "number" or type(chapter) ~= "table" then
		return
	end
	local tChapter = self:_packStage(chapter)
	self._tChatperList[nChapterId] = tChapter
end

function ExpansionDungeonData:updateStage(nChapterId, stage)
	if type(nChapterId) ~= "number" or  type(stage) ~= "table" then
		return
	end
	local tStage = self:_packStage(stage)
	if not self._tChatperList[nChapterId] then
		-- 开启了一个新章节
		local tChapter = {}
		tChapter._nId = nChapterId
		tChapter._nStar = 0
		tChapter._hasAwarded = false  -- 是否领取章节奖励
		tChapter._hasEntered = false  -- 是否第一次进入
		tChapter._tStageList = {}
		tChapter._tItemList = {}
		self._tChatperList[nChapterId] = tChapter

		self:setOpenNewChapter(true)
	end

	local tChapter = self._tChatperList[nChapterId]
	if not tChapter._tStageList then
		tChapter._tStageList = {}
	end
	tChapter._tStageList[tStage._nId] = tStage

	-- local nStageCount = 0
	-- for key, val in pairs(self._tChatperList) do
	-- 	local tChapter = val
	-- 	for k, v in pairs(tChapter._tStageList) do
	-- 		nStageCount = nStageCount + 1
	-- 	end
	-- end
	-- __LogTag(TAG, "xx nStageCount = %d", nStageCount)
end

function ExpansionDungeonData:setOpenNewChapter(bOpen)
	self._isOpenNewChapter = bOpen
end

function ExpansionDungeonData:isOpenNewChapter()
	-- local temp = self._isOpenNewChapter
	-- self._isOpenNewChapter = false
	-- return temp
	return self._isOpenNewChapter
end

function ExpansionDungeonData:setOpenNewStage(bOpen)
	self._isOpenNewStage = bOpen
end

function ExpansionDungeonData:isOpenNewStage()
	local temp = self._isOpenNewStage
	self._isOpenNewStage = false
	return temp
end

function ExpansionDungeonData:getStageStarNum(tStage)
	local nStar = 0
	if tStage then
		nStar = tStage._bTarget1 and nStar + 1 or nStar
		nStar = tStage._bTarget2 and nStar + 1 or nStar
		nStar = tStage._bTarget3 and nStar + 1 or nStar
	end
	return nStar
end

function ExpansionDungeonData:hasEnterChpaterAlready(nChapterId)
	local tChapter = self:getChapterById(nChapterId)
	if tChapter then
		return tChapter._hasEntered 
	end
	return false
end

function ExpansionDungeonData:setAtkStage(tStage)
	self._tAtkStage = clone(tStage)
end

function ExpansionDungeonData:getAtkStage()
	-- local temp = self._tAtkStage
	-- self._tAtkStage = nil
	-- return temp
	return self._tAtkStage
end

function ExpansionDungeonData:clearAtkStage()
	self._tAtkStage = nil
end

function ExpansionDungeonData:getChapterStarNum(nChapterId)
	local nChapterStar = 0
	local tChapter = self._tChatperList[nChapterId]
	if tChapter then
		for key, val in pairs(tChapter._tStageList) do
			local tStage = val
			nChapterStar = nChapterStar + self:getStageStarNum(tStage)
		end
	end
	return nChapterStar
end

-- 每次攻打一个关卡前，要调用这个函数
function ExpansionDungeonData:updateStoredMaxStage()
	local nMaxChapter = table.nums(self._tChatperList)
	local tChapter = self:getChapterById(nMaxChapter)
	if tChapter then
		local tStageList = tChapter._tStageList
		local nMaxStageId = 0
		for key, val in pairs(tStageList) do
			local tStage = val
			nMaxStageId = math.max(nMaxStageId, tStage._nId)
		end
		self._tStoredMaxStage = clone(tStageList[nMaxStageId])
	end
end

function ExpansionDungeonData:getStoredMaxStage()
	return self._tStoredMaxStage
end

function ExpansionDungeonData:judgeOpenNewStage()
	if self._tStoredMaxStage then
		local tCurMaxStage = nil
		local nMaxChapter = table.nums(self._tChatperList)
		local tStageList = self:getChapterById(nMaxChapter)._tStageList
		local nMaxStageId = 0
		for key, val in pairs(tStageList) do
			local tStage = val
			nMaxStageId = math.max(nMaxStageId, tStage._nId)
		end
		tCurMaxStage = tStageList[nMaxStageId]

		if self._tStoredMaxStage._nId ~= tCurMaxStage._nId then
			self:setOpenNewStage(true)
		end
	end
end

-- 能否拿章节奖励
function ExpansionDungeonData:getChapterBoxState(nChapterId)
	if type(nChapterId) ~= "number" then
		return false, false
	end
	local claimed = false
	local could = false
	local tChapter = self:getChapterById(nChapterId)
	if tChapter and tChapter._hasAwarded then
		claimed = true
		could = false
		return claimed, could
	end

	if tChapter and not tChapter._hasAwarded then
		-- 看最后个stage是否过了
		local tStageList = tChapter._tStageList
		local tStageIdList = {}
		for i=1, expansion_dungeon_stage_info.getLength() do
			local tStageTmpl = expansion_dungeon_stage_info.indexOf(i)
			if tStageTmpl.chapter_id == nChapterId then
				table.insert(tStageIdList, #tStageIdList+1, tStageTmpl.id)
			end
		end

		local finishChapter = true
		for key, val in pairs(tStageIdList) do
			local nStageId = val
			local tStage = tStageList[nStageId]
			if not tStage or not tStage._bTarget1 then
				finishChapter = false
				break
			end
		end
		if finishChapter then
			could = true
		end
	end

	return claimed, could
end

function ExpansionDungeonData:isPassTotalChapter()
	local passTotal = false
	local nMaxChapterId = self:getMaxChapterId()
	if nMaxChapterId == expansion_dungeon_chapter_info.getLength() then
		local tChapter = G_Me.expansionDungeonData:getChapterById(nMaxChapterId)
		
		local nMaxStageId = 0
		for i=1, expansion_dungeon_stage_info.getLength() do
			local tStageTmpl = expansion_dungeon_stage_info.indexOf(i)
			if tStageTmpl.chapter_id == nMaxChapterId then
				nMaxStageId = math.max(nMaxStageId, tStageTmpl.id)
			end
		end

		local tStage = tChapter._tStageList[nMaxStageId]
		if tStage and tStage._bTarget1 then
			passTotal = true
		end
	end

	return passTotal
end

-- 
function ExpansionDungeonData:storeMapLayerPosYAndScale(nChapterId, nPosY, nScale)
	self._tMapLayerPosYAndScale._nChapterId = nChapterId or 0
	self._tMapLayerPosYAndScale._nPosY = nPosY or 100
	self._tMapLayerPosYAndScale._nScale = nScale or 1
end

function ExpansionDungeonData:getMapLayerPosYAndScale()
	return self._tMapLayerPosYAndScale._nChapterId, self._tMapLayerPosYAndScale._nPosY, self._tMapLayerPosYAndScale._nScale
end

function ExpansionDungeonData:updateWithClaimBoxSucc(nChapterId)
	if type(nChapterId) ~= "number" then
		return
	end
	local tChapter = self._tChatperList[nChapterId]
	if tChapter then
		tChapter._hasAwarded = true
	end
end

function ExpansionDungeonData:getMaxStageIdAndIndex()
	local nMaxStageId, nIndex = 0, 0
	for key, val in pairs(self._tChatperList) do
		local tChapter = val
		for k, v in pairs(tChapter._tStageList) do
			local tStage = v
			local tStageTmpl = expansion_dungeon_stage_info.get(tStage._nId)
			nMaxStageId = math.max(nMaxStageId, tStageTmpl.id)
		end
	end
	local tStageTmpl = expansion_dungeon_stage_info.get(nMaxStageId)
	nIndex = tStageTmpl.index
	return nMaxStageId, nIndex
end

function ExpansionDungeonData:getMaxChapterId()
	local nMaxChapterId = 0
	for key, val in pairs(self._tChatperList) do
		local tChapter = val
		nMaxChapterId = math.max(nMaxChapterId, tChapter._nId)
	end
	return nMaxChapterId
end

-- 有没有章节宝箱没有领取，如果可以领取的话
function ExpansionDungeonData:showChapterRedTips(nChapterId)
	local claimed, could = self:getChapterBoxState(nChapterId)
	local isShow = false
	if could and not claimed then
		isShow = true
	end
	return isShow
end

function ExpansionDungeonData:hasAnyUnclaimedBox()
	for key, val in pairs(self._tChatperList) do
		local tChapter = val
		if self:showChapterRedTips(tChapter._nId) then
			return true
		end
	end
	return false
end

function ExpansionDungeonData:setAtkChapterId(nId)
	self._nAtkChatperId = nId
end

function ExpansionDungeonData:getAtkChapterId()
	local temp = self._nAtkChatperId
	self._nAtkChatperId = 0
	return temp
end

function ExpansionDungeonData:setStageAwardList(tAwardList)
	self._tStageAwardList = tAwardList or {}
end

function ExpansionDungeonData:getStageAwardList()
	local temp = self._tStageAwardList
	self._tStageAwardList = {}
	return temp
end

-- 最后关是否拿到了3星
function ExpansionDungeonData:isLastStageGetThreeStar()
	local isGet = false
	local nOpenedChapterCount = table.nums(self._tChatperList)
	local nMaxChapterCount = expansion_dungeon_chapter_info.getLength()
	if nOpenedChapterCount < nMaxChapterCount then
		return isGet
	end
	if nOpenedChapterCount == nMaxChapterCount then
		local tChapter = self._tChatperList[nOpenedChapterCount]
		local tStageList = tChapter._tStageList
		local nMaxStageId = 0
		for i=1, expansion_dungeon_stage_info.getLength() do
			local tStageTmpl = expansion_dungeon_stage_info.indexOf(i)
			if tStageTmpl.chapter_id == tChapter._nId then
				local tStage = tStageList[tStageTmpl.id]
				if not tStage then
					return isGet
				end
				nMaxStageId = math.max(nMaxStageId, tStageTmpl.id)
			end
		end
		local tStage = tStageList[nMaxStageId]
		if tStage._bTarget1 and tStage._bTarget2 and tStage._bTarget3 then
			isGet = true
		end
	end

	return isGet
end

-- 所有stage一星过关，也算通关了章节
function ExpansionDungeonData:isPassChapter(nChapterId)
	local isPass = false
	if type(nChapterId) ~= "number" then
		return isPass
	end

	local tChapter = self._tChatperList[nChapterId]
	if not tChapter then
		return isPass
	end

	local nMaxStageId = 0
	for i=1, expansion_dungeon_stage_info.getLength() do
		local tStageTmpl = expansion_dungeon_stage_info.indexOf(i)
		if tStageTmpl and tStageTmpl.chapter_id == nChapterId then
			nMaxStageId = math.max(nMaxStageId, tStageTmpl.id)
		end
	end

	local tStage = tChapter._tStageList[nMaxStageId]
	if tStage and tStage._bTarget1 then
		isPass = true
	end

	return isPass
end

-- 章节商店要不要显示
function ExpansionDungeonData:isShowChapterShopEntry(nChapterId)
	local isOpen = self:isPassChapter(nChapterId)
	if not isOpen then
		return false
	else
		-- 判断商品是否售完了
		local isSoldOut = self:isGoodsSoldOut(nChapterId)
		return isOpen and not isSoldOut
	end
end

-- 该章节商店物品是否售完
function ExpansionDungeonData:isGoodsSoldOut(nChapterId)
	if type(nChapterId) ~= "number" then
		return false
	end

	-- 总的可购买次数与总的已购买次数相同，即为全部售完
	local nTotolBuyCount = 0
	for i=1, expansion_dungeon_shop_info.getLength() do
		local tItemTmpl = expansion_dungeon_shop_info.indexOf(i)
		if tItemTmpl and tItemTmpl.chapter_id == nChapterId then
			nTotolBuyCount = nTotolBuyCount + tItemTmpl.time
		end
	end
	local nTotalAlreadyBuyCount = 0
	local tChapter = self:getChapterById(nChapterId)
	if tChapter then
		for key, val in pairs(tChapter._tItemList) do
			local tItem = val
			nTotalAlreadyBuyCount = nTotalAlreadyBuyCount + tItem._nCount
		end
	end

	return nTotolBuyCount == nTotalAlreadyBuyCount
end

-- 是不是全部打开了商店的章节的商品都售完了
function ExpansionDungeonData:isTotalChapterGoodsSoldOut()
	local nChapterCount = expansion_dungeon_chapter_info.getLength()
	for i=1, nChapterCount do
		local tChapterTmpl = expansion_dungeon_chapter_info.indexOf(i)
		local isShowEntry = self:isShowChapterShopEntry(tChapterTmpl.id)
		if isShowEntry then
			return false
		end
	end

	return true
end

-- 某一个物品是否售完了
function ExpansionDungeonData:isItemSoldOut(nChapterId, nItemId)
	local isSoldOut = false
	local tChapter = self:getChapterById(nChapterId)
	if tChapter then
		local tItem = tChapter._tItemList[nItemId]
		if tItem then
			local tItemTmpl = expansion_dungeon_shop_info.get(tItem._nId)
			if tItem._nCount >= tItemTmpl.time then
				isSoldOut = true
			end
		end
	end

	return isSoldOut
end

-- 章节商品
function ExpansionDungeonData:updateChapterItem(nItemId, nItemCount)
	local tItemTmpl = expansion_dungeon_shop_info.get(nItemId)
	if not tItemTmpl then
		return
	end

	local nChapterId = tItemTmpl.chapter_id
	local tChapter = self:getChapterById(nChapterId)
	if tChapter then
		if not tChapter._tItemList then
			tChapter._tItemList = {}
		end
		local tItem = tChapter._tItemList[nItemId]
		if not tItem then
			tItem = {}
			tItem._nId = nItemId
			tItem._nCount = nItemCount
			tChapter._tItemList[tItem._nId] = tItem
		else
			tItem._nCount = nItemCount
		end
	end
end

function ExpansionDungeonData:getItemAlreadyBuyCount(nChapterId, nItemId)
	local nAlreadyBuyCount = 0
	local tChapter = self:getChapterById(nChapterId)
	if tChapter then
		local tItem = tChapter._tItemList[nItemId]
		if tItem then
			nAlreadyBuyCount = tItem._nCount
		end
	end

	return nAlreadyBuyCount
end

-- 商品剩余可购买次数
function ExpansionDungeonData:getLeftBuyCount(nChapterId, nItemId)
	local nAlreadyBuyCount = self:getItemAlreadyBuyCount(nChapterId, nItemId)
	local tItemTmpl = expansion_dungeon_shop_info.get(nItemId)
	local nLeftCount = 0
	if tItemTmpl then
		nLeftCount = tItemTmpl.time - nAlreadyBuyCount
	end
	return nLeftCount
end

function ExpansionDungeonData:isOpenFunction()
	local nOpenServerTime = G_Me.timePrivilegeData:getOpenServerTime()
--	__LogTag(TAG, "-- nOpenServerTime = %d", nOpenServerTime)

	if nOpenServerTime == 0 then
    	return false
    end

	-- 开服时间
	local nOpenTime = G_ServerTime:getTime() - nOpenServerTime
	local nTime = 7 * 24 * 60 * 60
	if nOpenTime >= nTime then
		return true
	end

	return false
end

function ExpansionDungeonData:setPassTotalChapterState(bBefore, bAfter)
	if bBefore ~= nil then
		self._tPassTotalChapterState._bBeforeAtk = bBefore
	end
	if bAfter ~= nil then
		self._tPassTotalChapterState._bAfterAtk = bAfter
	end
end

-- 是否第一次达成最后一个stage的第一个目标
function ExpansionDungeonData:isFirstPassTotalChapter()
	return self._tPassTotalChapterState._bBeforeAtk ~= self._tPassTotalChapterState._bAfterAtk
end

-- 有没有章节数据。
-- 正好开服7天后了，玩家没有退出游戏，不能拉到章节数据，但是现在入口icon是显示的
function ExpansionDungeonData:hasChapterData()
	local nChapterCount = 0
	for key, val in pairs(self._tChatperList) do
		nChapterCount = nChapterCount + 1
	end
	return nChapterCount ~= 0
end

function ExpansionDungeonData:clear()
	self._tChatperList = {}
end

function ExpansionDungeonData:getLoginMark()
	return self._nLoginMark
end

function ExpansionDungeonData:clearLoginMark()
	self._nLoginMark = false
end

return ExpansionDungeonData