--
-- Author: Kumo.Wang
-- Date: Thu Feb 25 13:15:15 2016
-- 考古学院数据管理


local QBaseModel = import("...models.QBaseModel")
local QArchaeology = class("QArchaeology", QBaseModel)
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QActorProp = import("...models.QActorProp")

function QArchaeology:ctor()
	QArchaeology.super.ctor(self)
	self._archaeologyInfo = {}
end

function QArchaeology:init()
	self._remoteProexy = cc.EventProxy.new(remote.user)
    self._remoteProexy:addEventListener(remote.user.EVENT_USER_PROP_CHANGE, function ()
        self:_checkArchaeologyUnlock()
    end)
end

function QArchaeology:disappear()
	if self._remoteProexy ~= nil then 
		self._remoteProexy:removeAllEventListeners()
		self._remoteProexy = nil
	end
end

function QArchaeology:loginEnd()
	if self:_checkArchaeologyUnlock() then
		app:getClient():archaeologyInfoRequest(function(response)
	    	remote.archaeology:responseHandler(response)
	    end)
	end

	self:_initArchaeologyInfo()
end

function QArchaeology:_initArchaeologyInfo()
	local config = QStaticDatabase.sharedDatabase():getArcharologyConfig()

	for _, value in pairs(config) do
		if not self._archaeologyInfo[value.map_id] then
			-- 该map_id不存在，新建
			self._archaeologyInfo[value.map_id] = {}
		end
		table.insert(self._archaeologyInfo[value.map_id], value)
	end

	for _, info in pairs(self._archaeologyInfo) do
		table.sort(info, function(a,b) return a.id < b.id end)
	end
	
	-- print("[Kumo] archaeology info :")
	-- printTable(self._archaeologyInfo)
end

--[[
    检查考古学院是否解锁
]]
function QArchaeology:_checkArchaeologyUnlock(isForce)
    return app.unlock:getUnlockArchaeology()
end

-----------------外部调用-----------------

--[[
	获取球体高亮部分的图片
	返回：坐标，路径
]]
function QArchaeology:getGaoliangURL()
	return {x = 0, y = 20}, QResPath("archaeology_gaoliang")
end

--[[
	获取背景流星雨的效果
	返回：路径
]]
function QArchaeology:getStarRainURL()
	return "ccb/effects/star_rain1.ccbi"
end

--[[
	获取相应颜色球体的路径
	@int 对应不用的颜色
	@boolean true on; false off
	返回：坐标，路径
]]
function QArchaeology:getBallURL( int, boolean )
	local paths = QResPath("archaeology_ball")

	local url = ""

	if int == 1 then
		if boolean then
			url = paths[1]
		else
			url = paths[2]
		end
	elseif int == 2 then
		if boolean then
			url = paths[3]
		else
			url = paths[4]
		end
	elseif int == 3 then
		if boolean then
			url = paths[5]
		else
			url = paths[6]
		end
	elseif int == 4 then
		if boolean then
			url = paths[7]
		else
			url = paths[8]
		end
	elseif int == 5 then
		if boolean then
			url = paths[9]
		else
			url = paths[10]
		end
	elseif int == 6 then
		if boolean then
			url = paths[11]
		else
			url = paths[12]
		end
	end

	return nil, url
end

--[[
	获取当前可激活关卡效果
	返回：坐标，路径
]]
function QArchaeology:getNeedEnableURL()
	return {x = -5, y = 3}, "ccb/effects/meirirenwu_g.ccbi"
end

--[[
	获取关卡小旗帜展开
	返回：坐标，路径
]]
function QArchaeology:getFlagURL()
	return {x = 0, y = -28}, "ccb/effects/archaeology/archaeology_qizi.ccbi"
end

--[[
	获取关卡激活效果
	返回：坐标，路径
]]
function QArchaeology:getEnableURL()
	return {x = 0, y = 37}, "ccb/effects/add_buff_guang.ccbi"
end

--[[
	获取展示激活关卡属性效果
	返回：坐标，路径
]]
function QArchaeology:getShowBuffURL( int )
	if int == 2 then
		return {x = 2, y = 130}, "ccb/effects/add_buff_zi2.ccbi"
	end
	return {x = 2, y = 130}, "ccb/effects/add_buff_zi.ccbi"
end

--[[
	获取碎片飘动效果
	返回：坐标，路径
]]
function QArchaeology:getPiaoURL()
	return nil, "ccb/effects/archaeology/archaeology_piao.ccbi"
end

-----------------------------------------

function QArchaeology:responseHandler( response )
	-- printTableWithColor(PRINT_FRONT_COLOR_DARK_GREEN, nil, response)
	if response.apiArchaeologyInfoResponse then
		local id = response.apiArchaeologyInfoResponse.archaeologyInfo.last_enable_fragment_id
		local money = response.apiArchaeologyInfoResponse.archaeologyMoney
		local mark = response.apiArchaeologyInfoResponse.archaeologyInfo.lucky_draw_mark

		self:setLastEnableFragmentID( id )
		self:setArchaeologyMoney( money )
		self:setLuckyDrawMark( mark )

		remote.user:update( response.apiArchaeologyInfoResponse )
	end

	if response.apiArchaeologyEnableResponse then
		local id = response.apiArchaeologyEnableResponse.archaeologyInfo.last_enable_fragment_id
		local money = response.apiArchaeologyEnableResponse.archaeologyMoney
		local mark = response.apiArchaeologyEnableResponse.archaeologyInfo.lucky_draw_mark

		self:setLastEnableFragmentID( id )
		self:setArchaeologyMoney( money )
		self:setLuckyDrawMark( mark )

		remote.user:update( response.apiArchaeologyEnableResponse )

		app.taskEvent:updateTaskEventProgress(app.taskEvent.ARCHAEOLOGY_ACTIVE_EVENT, 1, false, false, {compareNum = id})
	end

	if response.archaeologyGetLuckyDrawResponse then
		local id = response.archaeologyGetLuckyDrawResponse.archaeologyInfo.last_enable_fragment_id
		local money = response.wallet.archaeologyMoney
		local mark = response.archaeologyGetLuckyDrawResponse.archaeologyInfo.lucky_draw_mark
		local luckyDraw = response.archaeologyGetLuckyDrawResponse.luckyDraw

		self:setLastEnableFragmentID( id )
		self:setArchaeologyMoney( money )
		self:setLuckyDrawMark( mark )
		-- self:setRewardLuckyDraw( luckyDraw )

        remote.user:update( {wallet = response.wallet, luckyDraw = luckyDraw} )
        remote.user:update( response.archaeologyGetLuckyDrawResponse )

        if luckyDraw.items ~= nil then
			remote.items:setItems(luckyDraw.items)
		end
	end
end

--[[
	最后一个已经被激活的考古关卡id
]]
function QArchaeology:setLastEnableFragmentID( int )
	print("[Kumo] setLastEnableFragmentID : ", int)
	self._lastEnableFragmentID = int
end

function QArchaeology:getLastEnableFragmentID()
	return self._lastEnableFragmentID or 0
end

--[[
	玩家考古币总量
]]
function QArchaeology:setArchaeologyMoney( int )
	print("[Kumo] setArchaeologyMoney : ", int)
	self._archaeologyMoney = int
end

function QArchaeology:getArchaeologyMoney()
	return self._archaeologyMoney or 0
end

--[[
	@str 1001;1002;1003;...  id;id;
]]
function QArchaeology:setLuckyDrawMark( str )
	print("[Kumo] setLuckyDrawMark : ", str)
	self._luckyDrawMark = str
end

function QArchaeology:getLuckyDrawMark()
	return self._luckyDrawMark
end

--[[
	获取第一个关卡的id
]]
function QArchaeology:getFirstFragmentID()
	return self._archaeologyInfo[1][1].id
end

function QArchaeology:getLastMapID()
	return #self._archaeologyInfo
end

function QArchaeology:setCurrentMapID( int )
	print("[Kumo] setCurrentMapID : ", int)
	self._currentMapID = int
end

function QArchaeology:getCurrentMapID()
	return self._currentMapID
end

function QArchaeology:isAllEnable()
	local lastMapInfo = self._archaeologyInfo[self:getLastMapID()]
	local lastFragmentInfo = lastMapInfo[#lastMapInfo]
	return self._lastEnableFragmentID == lastFragmentInfo.id
end

function QArchaeology:getEnableCost()
	local lastID = self:getLastEnableFragmentID()
	local info = {}
	if not lastID or lastID == 0 then
		lastID = self:getFirstFragmentID()
		info = self:getFragmentInfoByID(lastID)
	else
		info = self:getFragmentInfoByID(lastID + 1)
	end
	if info then
		return info.cost
	end

	return nil
end

--[[
	根据地图ID，获取地图中关卡的信息
	@int mapID 1,2,3,...,
]]
function QArchaeology:getMapInfoByID( int )
	local mapID = int
	if mapID and mapID > 0 and mapID <= #self._archaeologyInfo then
		return self._archaeologyInfo[mapID]
	end
	return nil
end

--[[
	根据地图id和关卡id，获取关卡的信息

	@int1 fragmentID
	@int2 mapID
]]
function QArchaeology:getFragmentInfoByID( int1, int2 )
	local mapID = int2
	local fragmentID = int1
	local mapInfo = self:getMapInfoByID(mapID)
	if mapInfo then
		for _, info in pairs(mapInfo) do
			if info.id == fragmentID then
				return info
			end
		end	
	else
		for _, mapInfo in pairs(self._archaeologyInfo) do
			for _, info in pairs(mapInfo) do
				if info.id == fragmentID then
					return info
				end
			end	
		end
	end
	return nil
end

--[[
	根据地图id和关卡id，获取当前地图中最后一个被激活的关卡的index，如果全部已经激活或一个都没被激活，返回nil

	@int1 fragmentID
	@int2 mapID
]]
function QArchaeology:getLastEnableIndexByID( int1, int2 )
	local mapID = int2
	local fragmentID = int1
	local mapInfo = self:getMapInfoByID(mapID)

	if mapInfo then
		local index = (mapID-1)*5
		if mapInfo[1].id > fragmentID then
			return 0, index
		elseif mapInfo[#mapInfo].id < fragmentID then
			return #mapInfo, index
		end

		for i = 1, #mapInfo, 1 do
			if mapInfo[i].id == fragmentID then
				return i, (mapID-1)*5+i
			end
		end
	else
		local index = 0
		for _, mapInfo in pairs(self._archaeologyInfo) do
			for i = 1, #mapInfo, 1 do
				index = index + 1
				if mapInfo[i].id == fragmentID then
					return i, index
				end
			end
		end
	end
	return nil
end

--[[
	根据地图id和关卡id，获取关卡的属性名和属性数值

	@int1 fragmentID
	@int2 mapID
]]
function QArchaeology:getFragmentBuffNameAndValueByID( int1, int2 )
	local tbl = {}
	local info = self:getFragmentInfoByID( int1, int2 )
	for key, value in pairs(info) do
		if QActorProp._field[key] then
			local name = QActorProp._field[key].archaeologyName or QActorProp._field[key].name
			tbl[name] = value
		end
	end
	return tbl
end

--[[
	根据关卡id，判断是否已经领取过关卡奖励。注！只判断是否领取，不判断是否有奖励可领取
	@int fragmentID
]]
function QArchaeology:isMarked( int )
	local mark = self:getLuckyDrawMark()
	if not mark then return end

	local str = tostring(int)
	-- local str = tostring(int)
	return string.find(mark, str)
end

--[[
	获取第一个已经激活的关卡，该关卡拥有碎片奖励可领取但还未领取，返回关卡ID
]]
function QArchaeology:getFirstRewardID()
	local mark = self:getLuckyDrawMark()
	local firstID = self:getFirstFragmentID()
	local lastID = self:getLastEnableFragmentID()
	if not mark or mark == "" then
		for id = firstID, lastID, 1 do
			local info = self:getFragmentInfoByID(id)
			if info.reward_index then
				return id
			end
		end
	else
		for id = firstID, lastID, 1 do
			local info = self:getFragmentInfoByID(id)
			if info.reward_index then
				if not self:isMarked(id) then
					return id
				end
			end
		end
	end

	return nil
end

--[[
	获取下一个可激活的关卡所在的地图ID。
]]
function QArchaeology:getLastNeedEnableMapID()
	local lastID = self:getLastEnableFragmentID()
	if lastID == 0 then
		return 1
	end
	local fragmentInfo = self:getFragmentInfoByID(lastID)
	local mapID = fragmentInfo.map_id
	local mapInfo = self:getMapInfoByID(mapID)
	local index = self:getLastEnableIndexByID(lastID)

	if index == #mapInfo then
		mapID = mapID + 1
		if mapID > #self._archaeologyInfo then
			mapID = #self._archaeologyInfo
		end
	end

	return mapID
end

function QArchaeology:getLastChapterAndColor()
	local isAllEnable = self:isAllEnable()

	local chapter, color
	if isAllEnable then
		local lastMapID = self:getLastMapID()
		chapter = lastMapID
		if lastMapID < 2 then
			color = QIDEA_QUALITY_COLOR.WHITE
		elseif lastMapID < 7 then
			color = QIDEA_QUALITY_COLOR.GREEN
		elseif lastMapID < 10 then
			color = QIDEA_QUALITY_COLOR.PURPLE
		else
			color = QIDEA_QUALITY_COLOR.ORANGE
		end
	else
		local lastNeedEnableMapID = self:getLastNeedEnableMapID()
		local cur = 0
		if lastNeedEnableMapID == 0 then
			cur = 0
		else
			cur = lastNeedEnableMapID - 1
		end
		chapter = cur
		if cur < 2 then
			color = QIDEA_QUALITY_COLOR.WHITE
		elseif cur < 7 then
			color = QIDEA_QUALITY_COLOR.GREEN
		elseif cur < 10 then
			color = QIDEA_QUALITY_COLOR.PURPLE
		else
			color = QIDEA_QUALITY_COLOR.ORANGE
		end
	end

	return chapter, color
end

return QArchaeology