-- 
-- zxs
-- 头像属性数据类
--

local QBaseModel = import("...models.QBaseModel")
local QHeadProp = class("QHeadProp", QBaseModel)
local QActorProp = import("...models.QActorProp")
local QNotificationCenter = import("...controllers.QNotificationCenter")
local QStaticDatabase = import("...controllers.QStaticDatabase")

QHeadProp.AVATAR_DEFAULT_TYPE = 1			-- 基本头像
QHeadProp.AVATAR_HERO_TYPE = 2				-- 英雄头像
QHeadProp.AVATAR_OTHER_TYPE = 3				-- 其他头像
QHeadProp.AVATAR_ACTIVITY_TYPE = 4			-- 活动头像
QHeadProp.AVATAR_HEORSKIN_TYPE = 6			-- 皮肤头像

QHeadProp.FRAME_NORMAL_TYPE = 1				-- 普通头像框
QHeadProp.FRAME_VIP_TYPE = 2				-- vip头像框
QHeadProp.FRAME_ARENA_TYPE = 3				-- 斗魂场头像框
QHeadProp.FRAME_GLORY_TYPE = 4				-- 魂师大师头像框
QHeadProp.FRAME_FIGHT_TYPE = 5				-- 地狱杀戮头像框
QHeadProp.FRAME_ACTIVITY_TYPE = 6			-- 活动头像框
QHeadProp.FRAME_STORM_TYPE = 7				-- 索托斗魂场头像框
QHeadProp.FRAME_SANCTUARY_TYPE = 8			-- 全大陆精英赛头像框
QHeadProp.FRAME_SOTO_TEAM_TYPE = 9			-- 云顶之战头像框
QHeadProp.FRAME_COLLEGETRAIN_TYPE = 10		-- 史莱克学院头像框
QHeadProp.FRAME_SILVESARENA_PEAK_TYPE = 11  -- 西尔维斯巅峰赛头像框

-- 称号
QHeadProp.TITLE_TRIAL_TYPE = 1				-- 魂力称号
QHeadProp.TITLE_ACTIVITY_TYPE = 2			-- 活动称号
QHeadProp.TITLE_LUCKYBAG_P_TYPE = 3			-- 福袋称号-钻石
QHeadProp.TITLE_LUCKYBAG_A_TYPE = 4			-- 福袋称号-活动

QHeadProp.NONE_TYPE = 0						-- 未识别
QHeadProp.AVATAR_TYPE = 1					-- 头像
QHeadProp.FRAME_TYPE = 2					-- 头像框
QHeadProp.TITLE_TYPE = 6					-- 称号

QHeadProp.AVATAR_CHANGE = "AVATAR_CHANGE"			-- 头像替换更新
QHeadProp.HEAD_UNLOCK_UPDATE = "HEAD_UNLOCK_UPDATE"	-- 头像解锁更新

QHeadProp.ITEM_HEAD_NORMAL = 0					--正常
QHeadProp.ITEM_HEAD_ACTIVATED = 1				--是否激活
QHeadProp.ITEM_HEAD_HAS = 2						--是否拥有

QHeadProp.ITEM_SUBTYPE = 35

local SEPARATOR = 10000


function QHeadProp:ctor(options)
    cc.GameObject.extend(self)
    self:addComponent("components.behavior.EventProtocol"):exportMethods()

	self:resetData()
end

function QHeadProp:didappear()
	QHeadProp.super.didappear(self)
end

function QHeadProp:disappear()
	QHeadProp.super.disappear(self)
end

function QHeadProp:loginEnd(success)
	if success then
		success()
	end
end

function QHeadProp:resetData()
	self._headList = {}
	self._avatarProp = {}
	self._frameProp = {}
	self._titleProp = {}
end

-- 获取已解锁头像列表（未过期）
function QHeadProp:getHeadList()
	local headList = {}
	local nowTime = q.serverTime() * 1000
    for i, v in pairs(self._headList) do
        local remainingTime = v.expiredAt - nowTime
        if remainingTime > 0 then
            table.insert(headList, v)
        end
    end
	return headList
end

--是否解锁
function QHeadProp:getIsLocked(titleId)
	if not self._headList then
		return true
	end
	for i, v in pairs(self._headList) do 
		if titleId == v.titleId then
			return false, v.expiredAt
		end
	end
	return true
end

--获取对应属性
function QHeadProp:getAvatarProp()
	return self._avatarProp
end

function QHeadProp:getFrameProp()
	return self._frameProp
end

function QHeadProp:getTitleProp()
	return self._titleProp
end

local function sortFunc(a, b)
	if not a or not b then
		return true
	end
	if a.sort or b.sort then
		if not a.sort then
			return false
		end 
		if not b.sort then
			return true
		end 
		return a.sort < b.sort
	else	
		return a.id < b.id
	end
end

local function sortFunc1(sortTable)
	table.sort( sortTable, sortFunc )
	
	local temp = {}
	for i, v in pairs(sortTable) do
		if not v.lock then
			temp[#temp+1] = v
		end
	end
	for i, v in pairs(sortTable) do
		if v.lock then
			temp[#temp+1] = v
		end
	end
	return temp
end

function QHeadProp:sortFunc2(sortTable)
	local temp = {}
	for i, v in pairs(sortTable) do
		if not v.isPercent then
			temp[#temp+1] = v
		end
	end
	for i, v in pairs(sortTable) do
		if v.isPercent then
			temp[#temp+1] = v
		end
	end
	return temp
end

local function insertFunc(table, newTable)
	for _, v in pairs(newTable) do
		table[#table+1] = v
	end
end

-- 头像信息
function QHeadProp:getAvatarInfo()
	-- default avatars
	local defaultAvaters = {}
	for k, v in pairs(db:getAvatars(QHeadProp.AVATAR_DEFAULT_TYPE)) do
		v.lock = self:getIsLocked(v.id)
		defaultAvaters[#defaultAvaters+1] = v
	end
	defaultAvaters = sortFunc1(defaultAvaters)

	-- break through avatars
	local heroAvatars = {}
	for k, v in pairs(db:getAvatars(QHeadProp.AVATAR_HERO_TYPE)) do
		v.lock = self:getIsLocked(v.id)
		heroAvatars[#heroAvatars+1] = v
	end
	heroAvatars = sortFunc1(heroAvatars)

	-- other avatars
	local otherAvatars = {}
	for k, v in pairs(db:getAvatars(QHeadProp.AVATAR_OTHER_TYPE)) do
		v.lock = self:getIsLocked(v.id)
		otherAvatars[#otherAvatars+1] = v
	end
	otherAvatars = sortFunc1(otherAvatars)

	-- activity avatars
	local activityAvatars = {}
	for k, v in pairs(db:getAvatars(QHeadProp.AVATAR_ACTIVITY_TYPE)) do
		v.lock = self:getIsLocked(v.id)
		activityAvatars[#activityAvatars+1] = v
	end
	activityAvatars = sortFunc1(activityAvatars)

	-- activity avatars
	local skinAvatars = {}
	for k, v in pairs(db:getAvatars(QHeadProp.AVATAR_HEORSKIN_TYPE)) do
		v.lock = self:getIsLocked(v.id)
		skinAvatars[#skinAvatars+1] = v
	end
	skinAvatars = sortFunc1(skinAvatars)

	local avatarList = {}
	insertFunc(avatarList, defaultAvaters)
	insertFunc(avatarList, heroAvatars)
	insertFunc(avatarList, otherAvatars)
	insertFunc(avatarList, activityAvatars)
	insertFunc(avatarList, skinAvatars)

	local newList = {}
	for k, v in pairs(avatarList) do
		if not db:checkHeroShields(v.id, SHIELDS_TYPE.HEAD_DEFAULT) then
			newList[#newList+1] = v
		end
	end
	return newList
end

--头像框信息
function QHeadProp:getFrameInfo()
	local normalFrames = {}
	for k, v in pairs(db:getFrames(QHeadProp.FRAME_NORMAL_TYPE)) do
		v.lock = false
		normalFrames[#normalFrames+1] = v
	end
	-- check vip conditions
	local vipFrames = {}
	for k, v in pairs(db:getFrames(QHeadProp.FRAME_VIP_TYPE)) do
		v.lock = self:getIsLocked(v.id)
		vipFrames[#vipFrames+1] = v
	end
	vipFrames = sortFunc1(vipFrames)

	-- check arena conditions
	local arenaFrames = {}
	for k, v in pairs( db:getFrames(QHeadProp.FRAME_ARENA_TYPE)) do
		v.lock = self:getIsLocked(v.id)
		arenaFrames[#arenaFrames+1] = v
	end
	arenaFrames = sortFunc1(arenaFrames)

	-- check tower conditions
	local gloryFrames = {}
	for k, v in pairs(db:getFrames(QHeadProp.FRAME_GLORY_TYPE)) do
		v.lock = self:getIsLocked(v.id)
		gloryFrames[#gloryFrames+1] = v
	end
	gloryFrames = sortFunc1(gloryFrames)

	-- check tower conditions
	local fightFrames = {}
	for k, v in pairs(db:getFrames(QHeadProp.FRAME_FIGHT_TYPE)) do
		v.lock = self:getIsLocked(v.id)
		fightFrames[#fightFrames+1] = v
	end
	fightFrames = sortFunc1(fightFrames)

	-- check tower conditions
	local stormFrames = {}
	for k, v in pairs(db:getFrames(QHeadProp.FRAME_STORM_TYPE)) do
		v.lock = self:getIsLocked(v.id)
		stormFrames[#stormFrames+1] = v
	end
	stormFrames = sortFunc1(stormFrames)

	-- check tower conditions
	local sanctuaryFrames = {}
	for k, v in pairs(db:getFrames(QHeadProp.FRAME_SANCTUARY_TYPE )) do
		v.lock = self:getIsLocked(v.id)
		sanctuaryFrames[#sanctuaryFrames+1] = v
	end
	sanctuaryFrames = sortFunc1(sanctuaryFrames)

	-- check tower conditions
	local sotoTeamFrames = {}
	for k, v in pairs(db:getFrames(QHeadProp.FRAME_SOTO_TEAM_TYPE )) do
		v.lock = self:getIsLocked(v.id)
		sotoTeamFrames[#sotoTeamFrames+1] = v
	end
	sotoTeamFrames = sortFunc1(sotoTeamFrames)

	local collegeTrainFrames = {}
	for k,v in pairs(db:getFrames(QHeadProp.FRAME_COLLEGETRAIN_TYPE)) do
		v.lock = self:getIsLocked(v.id)
		collegeTrainFrames[#collegeTrainFrames + 1] = v
	end
	collegeTrainFrames = sortFunc1(collegeTrainFrames)
	-- check   conditions
	local activityFrames = {}
	for k, v in pairs(db:getFrames(QHeadProp.FRAME_ACTIVITY_TYPE)) do
		v.lock = self:getIsLocked(v.id)
		activityFrames[#activityFrames+1] = v
	end
	activityFrames = sortFunc1(activityFrames)

	-- silves
	local silvesArenaPeakFrames = {}
	for k, v in pairs(db:getFrames(QHeadProp.FRAME_SILVESARENA_PEAK_TYPE)) do
		v.lock = self:getIsLocked(v.id)
		silvesArenaPeakFrames[#silvesArenaPeakFrames+1] = v
	end
	silvesArenaPeakFrames = sortFunc1(silvesArenaPeakFrames)

	local frames = {}
	--insertFunc(frames, normalFrames)
	insertFunc(frames, vipFrames)
	insertFunc(frames, arenaFrames)
	insertFunc(frames, gloryFrames)
	insertFunc(frames, fightFrames)
	insertFunc(frames, stormFrames)
	insertFunc(frames, sanctuaryFrames)
	insertFunc(frames, sotoTeamFrames)
	insertFunc(frames, collegeTrainFrames)
	insertFunc(frames, silvesArenaPeakFrames)

	-- 活动和平台有关
	for _, value in pairs(activityFrames) do
		if device.platform == "mac" or device.platform == "windows" then
			frames[#frames+1] = value
		elseif not value.platform or value.platform == device.platform then
			frames[#frames+1] = value
		end
	end

	return frames
end 

--称号信息
function QHeadProp:getTitleInfo()
	local trialTitles = {}
	local nexMin, curMax = 1000000000, 0
	local curTrial, nextTrial
	for i, v in pairs(db:getHeroTitle(QHeadProp.TITLE_TRIAL_TYPE)) do
		local idTble = string.split(v.condition, ",")
		local min = tonumber(idTble[1])
		v.lock = remote.user.soulTrial < min

		-- 最大已解锁
		if not v.lock and curMax < min then
			curMax = min
			curTrial = v
		end

		-- 最小未解锁
		if v.lock and min < nexMin then
			nexMin = min
			nextTrial = v
		end
	end
	table.insert(trialTitles, curTrial)
	table.insert(trialTitles, nextTrial)

	local luckyBagTitles = {}
	local curActivity, nextActivity = self:getRedPacketTitleLockInfo(QHeadProp.TITLE_LUCKYBAG_P_TYPE)
	local curAiamond, nextAiamond = self:getRedPacketTitleLockInfo(QHeadProp.TITLE_LUCKYBAG_A_TYPE)
	table.insert(luckyBagTitles, curActivity)
	table.insert(luckyBagTitles, nextActivity)
	table.insert(luckyBagTitles, curAiamond)
	table.insert(luckyBagTitles, nextAiamond)

	local activityTitles = {}
	for k, v in pairs(db:getHeroTitle(QHeadProp.TITLE_ACTIVITY_TYPE)) do
		v.lock = self:getIsLocked(v.id)
		activityTitles[#activityTitles+1] = v
	end
	activityTitles = sortFunc1(activityTitles)

	local titles = {}
	insertFunc(titles, trialTitles)
	insertFunc(titles, luckyBagTitles)
	insertFunc(titles, activityTitles)

	return titles
end

-- 获取最大解锁和最小未解锁
function QHeadProp:getRedPacketTitleLockInfo(titleType)
	local nexMin, curMax = 1000000000, 0
	local curActivity, nextActivity
	for k, v in pairs(db:getHeroTitle(titleType)) do
		v.lock = self:getIsLocked(v.id)
		local num = tonumber(v.id)

		-- 最大已解锁
		if not v.lock and curMax < num then
			curMax = num
			curActivity = v
		end

		-- 最小未解锁
		if v.lock and num < nexMin then
			nexMin = num
			nextActivity = v
		end
	end

	return curActivity, nextActivity
end

function QHeadProp:getTitleInfoBySoulTrial(soulTrial)
	for i, v in pairs(db:getHeroTitle(QHeadProp.TITLE_TRIAL_TYPE)) do
		local idTble = string.split(v.condition, ",")
		local min = tonumber(idTble[1])
		local max = tonumber(idTble[2])
		if min <= soulTrial and soulTrial <= max then
			return v
		end
	end
	return nil
end

--称号是否解锁信息-单独使用
function QHeadProp:getIsTitleLocked(titleId)
	if titleId == 0 then
		return false
	end
	
	local titleInfo = db:getHeadInfoById(titleId)
	local locked = true
	if titleInfo and titleInfo.function_type == remote.headProp.TITLE_TRIAL_TYPE then
    	local idTble = string.split(titleInfo.condition, ",")
		local min = tonumber(idTble[1])
	    locked = remote.user.soulTrial < min
    else
    	locked = self:getIsLocked(titleId)
    end

	return locked
end

--属性叠加
local function countPropInfo(propInfo, allProp)
	for key, value in pairs(QActorProp._field) do
		if propInfo[key] then
			allProp[key] = allProp[key] or {}
			allProp[key].nativeName = value.name
			allProp[key].num = allProp[key].num or 0
			allProp[key].num = allProp[key].num + propInfo[key]
			allProp[key].isPercent = value.isPercent

			if key == "pvp_physical_damage_percent_attack" then
				allProp[key].nativeName = "全队pvp物理加伤"
			elseif key == "pvp_magic_damage_percent_attack" then
				allProp[key].nativeName = "全队pvp法术加伤"
			elseif key == "pvp_physical_damage_percent_beattack_reduce" then
				allProp[key].nativeName = "全队pvp物理减伤"
			elseif key == "pvp_magic_damage_percent_beattack_reduce" then
				allProp[key].nativeName = "全队pvp法术减伤"
			else
				allProp[key].nativeName = value.name
			end

			if value.isPercent then
				allProp[key].value = (allProp[key].num * 100).."%"
			else
				allProp[key].value = allProp[key].num
			end
		end
	end
end

--属性叠加
local function countProps(propInfo, allProp)
	for key, value in pairs(QActorProp._field) do
		if propInfo[key] then
			allProp[key] = allProp[key] or 0
			allProp[key] = allProp[key] + propInfo[key]
		end
	end
end

-- 获取红包属性
function QHeadProp:getRedpacketTitleProp(titleId)
	local titleInfo = db:getHeadInfoById(titleId)
	local allProp = {}
	for k, v in pairs(db:getHeroTitle(titleInfo.function_type)) do
		if v.id <= titleId then
			countProps(v, allProp)
		end
	end
	return allProp
end

-- 根据头像信息获得加成属性数据 
function QHeadProp:getHeadProp(userTitles, propType)
	local allProp = {}
	if not userTitles or type(userTitles) ~= "table" then
		return allProp
	end
	local nowTime = q.serverTime() * 1000
	for i, v in pairs(userTitles) do
		local remainingTime = v.expiredAt - nowTime
		if remainingTime > 0 then
			local propInfo = db:getHeadInfoById(v.titleId)
			if propInfo and propInfo.type == propType then
				if propInfo.attribute_add ~= 1 then
					local titleId = remote.user.title or 0
					local avatarId, frameId = db:getAvatarFrameId(remote.user.avatar)
					frameId = frameId or 0
					if v.titleId == titleId or v.titleId == frameId then
						countPropInfo(propInfo, allProp)
					end
				else
					countPropInfo(propInfo, allProp)
				end
			end
		end
	end

	return allProp
end

function QHeadProp:countHeadProp()
	local avatarProp = self:getHeadProp(self._headList, QHeadProp.AVATAR_TYPE)
	local frameProp = self:getHeadProp(self._headList, QHeadProp.FRAME_TYPE)
	local titleProp = self:getHeadProp(self._headList, QHeadProp.TITLE_TYPE)

	-- 魂力试炼称号
	local chapter = remote.soulTrial:getChapterById(remote.user.soulTrial) or {}
	local chapterConfig = remote.soulTrial:getBossConfigByChapter( chapter )
	countPropInfo(chapterConfig, titleProp)
	
	self._avatarProp = self:sortFunc2(avatarProp)
	self._frameProp = self:sortFunc2(frameProp)
	self._titleProp = self:sortFunc2(titleProp)
end

function QHeadProp:updateHeadList(data)
	if not data.userTitles then
		self:countHeadProp()
		return
	end

	self:resetData()
	self._headList = data.userTitles
	self:countHeadProp()
	self:updateAvatarInfos()

	self:dispatchEvent({name = QHeadProp.HEAD_UNLOCK_UPDATE})
end

function QHeadProp:getDefaultAvatar(avatarId)
	return db:getAvatars()[avatarId] or db:getDefaultAvatar()
end

function QHeadProp:getDefaultFrame(frameId)
	return db:getFrames()[frameId] or db:getDefaultFrame()
end

function QHeadProp:getAvatarFrameId(avatar)
	if avatar and type(avatar) == "number" then
		local avatarId = math.fmod(avatar, SEPARATOR)
		local frameId = avatar - avatarId
		return avatarId, frameId
	end
	return
end

function QHeadProp:getAvatar(newAvatarId, newFrameId)
	local avatarId, frameId = self:getAvatarFrameId(remote.user.avatar)
	if newAvatarId and newFrameId then
		return newAvatarId + newFrameId
	elseif newAvatarId then
		return newAvatarId + frameId
	elseif newFrameId then
		return avatarId + newFrameId
	end
	return avatarId + frameId
end

-- 英雄信息发生变化时，检查头像信息是否发生变化
function QHeadProp:updateAvatarInfos()
	local newAvatar = remote.user.avatar
	local newTitle = remote.user.title
	local avatarId, frameId = self:getAvatarFrameId(newAvatar)
	local isAvatarLock = self:getIsLocked(avatarId)
	local isFrameLock = self:getIsLocked(frameId)
	local isTitleLock = self:getIsTitleLocked(newTitle)

	if isAvatarLock then
		avatarId = db:getDefaultAvatar().id 
		newAvatar = self:getAvatar(avatarId, frameId)
	end
	if isFrameLock then
		frameId = db:getDefaultFrame().id 
		newAvatar = self:getAvatar(avatarId, frameId)
	end
	if isTitleLock then
		newTitle = 0
	end
	if isAvatarLock or isFrameLock or isTitleLock then
		self:changeAvatarRequest(newAvatar, newTitle)
	end

	-- check show hero 
	if remote.user.defaultActorId == nil or remote.user.defaultActorId == 0 then
		local defaultHero = remote.herosUtil:getMaxForceHero().id or 1001
		local defaultSkinId = remote.herosUtil:getMaxForceHero().skinId
	 	self:changeShowHeroRequest(defaultHero,defaultSkinId)
	end
end

function QHeadProp:getFarmeAndTitleInfo(_type)
	local framesAndTitleList = {}
	local frames = self:getFrameInfo()
	local titles = self:getTitleInfo()
	if _type == nil then
		for _,v in pairs(frames) do
			table.insert(framesAndTitleList,v)
		end
		for _,v in pairs(titles) do
			table.insert(framesAndTitleList,v)
		end
	elseif _type == QHeadProp.TITLE_TYPE then
		for _,v in pairs(titles) do
			table.insert(framesAndTitleList,v)
		end
	elseif _type == QHeadProp.FRAME_TYPE then
		for _,v in pairs(frames) do
			table.insert(framesAndTitleList,v)
		end
	end
	return framesAndTitleList
end

function QHeadProp:checkItemHeadByItem( itemId )
	local itemInfo = QStaticDatabase:sharedDatabase():getItemByID(itemId)
	if itemInfo and itemInfo.type and itemInfo.type == ITEM_CONFIG_TYPE.CONSUM_PACKAGE then
		local contents = string.split(itemInfo.content, ";")

		for _,v in pairs(contents) do
			local subContent = string.split(v, "^")
			if subContent[1] and tonumber(subContent[1]) then
				local subItemInfo = QStaticDatabase:sharedDatabase():getItemByID(subContent[1])

				if subItemInfo and subItemInfo.type and subItemInfo.type ~= QHeadProp.ITEM_SUBTYPE then
					return QHeadProp.ITEM_HEAD_NORMAL
				end

				local framesAndTitleList = self:getFarmeAndTitleInfo()

				if next(framesAndTitleList) == nil then
					return QHeadProp.ITEM_HEAD_NORMAL
				end

				if subItemInfo and subItemInfo.type and subItemInfo.type == QHeadProp.ITEM_SUBTYPE then
					for i,v in pairs(framesAndTitleList) do
						if v.condition == tonumber(subContent[1]) and not v.lock then
							return  QHeadProp.ITEM_HEAD_ACTIVATED
						end
					end
				end
				local items = remote.items:getItemsByCategory( ITEM_CONFIG_CATEGORY.CONSUM)
				if next(items) == nil then
					return QHeadProp.ITEM_HEAD_NORMAL
				end

				for k,v in pairs(items) do
					if v.type == itemInfo.id then
						for a,b in pairs(framesAndTitleList) do
							if b.condition == tonumber(subContent[1]) and tonumber(subContent[1]) ~= nil then
								return QHeadProp.ITEM_HEAD_HAS
							end
						end
					end
				end			
			end
		end
	end

	return QHeadProp.ITEM_HEAD_NORMAL
end


function QHeadProp:checkItemTitleOrFrameByItem( itemId )

	local itemInfo = QStaticDatabase:sharedDatabase():getItemByID(itemId)
	if itemInfo and itemInfo.type and itemInfo.type == ITEM_CONFIG_TYPE.CONSUM_PACKAGE then
		local contents = string.split(itemInfo.content, ";")

		for _,v in pairs(contents) do
			local subContent = string.split(v, "^")
			if subContent[1] and tonumber(subContent[1]) then
				local subItemInfo = QStaticDatabase:sharedDatabase():getItemByID(subContent[1])

				if subItemInfo and subItemInfo.type and subItemInfo.type ~= QHeadProp.ITEM_SUBTYPE then
					return QHeadProp.ITEM_HEAD_NORMAL,QHeadProp.NONE_TYPE
				end
				local type_table= {QHeadProp.TITLE_TYPE,QHeadProp.FRAME_TYPE}

				for _i,_type in pairs(type_table) do
					local framesAndTitleList = self:getFarmeAndTitleInfo(_type)

					if next(framesAndTitleList) == nil then
						return QHeadProp.ITEM_HEAD_NORMAL,QHeadProp.NONE_TYPE
					end

					if subItemInfo and subItemInfo.type and subItemInfo.type == QHeadProp.ITEM_SUBTYPE then
						for i,v in pairs(framesAndTitleList) do
							if v.condition == tonumber(subContent[1]) and not v.lock then
								return  QHeadProp.ITEM_HEAD_ACTIVATED,_type
							end
						end
					end
					local items = remote.items:getItemsByCategory( ITEM_CONFIG_CATEGORY.CONSUM)
					if next(items) == nil then
						return QHeadProp.ITEM_HEAD_NORMAL,QHeadProp.NONE_TYPE
					end

					for k,v in pairs(items) do
						if v.type == itemInfo.id then
							for a,b in pairs(framesAndTitleList) do
								if b.condition == tonumber(subContent[1]) and tonumber(subContent[1]) ~= nil then
									return QHeadProp.ITEM_HEAD_HAS,_type
								end
							end
						end
					end	
				end						
			end
		end
	end

	return QHeadProp.ITEM_HEAD_NORMAL,QHeadProp.NONE_TYPE
end


----------------------requset handler -----------------------------

--请求头像信息数据
function QHeadProp:requestHeadList(success)
    local request = { api = "USER_TITLE_LIST" }
    local callback = function (data)
    	self:updateHeadList(data)
    	if success then
    		success()
    	end
	end
    app:getClient():requestPackageHandler("USER_TITLE_LIST", request, callback, fail)
end

function QHeadProp:changeAvatarRequest(newAvatar, newTitle, success)
	if newAvatar == nil then return end

	if newAvatar == -1 then
		newAvatar = self:getDefaultAvatar().id
	end

	if newTitle == nil then 
		newTitle = remote.user.title
	end

	local callback = function (data)
		remote.user:update({avatar = newAvatar})
		remote.user:update({title = newTitle})
		--重新计算属性
		remote.headProp:countHeadProp()
		
		self:dispatchEvent({name = QHeadProp.AVATAR_CHANGE, avatar = newAvatar, title = newTitle})
		if success then
			success()
		end
	end
    app:getClient():changeAvatar(newAvatar, newTitle, callback)
end

function QHeadProp:changeShowHeroRequest(actorId,skinId,isTransform,success)
	local defaultActorId = actorId or 1001
	local defaultSkinId = skinId or 1001
	local callback = function (data)
		remote.user:update({defaultSkinId = defaultSkinId})
		remote.user:update({defaultActorId = defaultActorId})
		--重新计算属性
		remote.headProp:countHeadProp()
		
		QNotificationCenter.sharedNotificationCenter():dispatchEvent({name = QNotificationCenter.SHOW_HERO_CHANGE_SUCCESS, actorId = defaultActorId,skinId = defaultSkinId,isTransform = isTransform})
 		if success then
 			success()
 		end
	end
	app:getClient():changeDefaultActorRequest(defaultActorId,defaultSkinId, callback)
end

return QHeadProp
