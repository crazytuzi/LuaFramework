local CrossPVPConst = require("app.const.CrossPVPConst")

local CrossPVPShowBulletScreenLayer = class("CrossPVPShowBulletScreenLayer", UFCCSNormalLayer)

local MAX_CONTENT_HEIGHT = 450
local ROW_HEIGHT = 55
local TOP_DIS = 10  --第一条弹幕离显示panel的顶部的距离
local MOVE_SPEED = 120
local TWO_LABEL_SPACE = 75
local FONT_SIZE = 30
local ROW_LABEL_COUNT = 4
local BULLET_SCREEN_COUNT_MAX = 2000

local FLAG = {
	EMPTY = 0,  --空闲
	USED = 1,   --使用中
}

function CrossPVPShowBulletScreenLayer.create(nField, ...)
	return CrossPVPShowBulletScreenLayer.new("ui_layout/crosspvp_ShowBulletScreenLayer.json", nil, nField, ...)
end

function CrossPVPShowBulletScreenLayer:ctor(json, param, nField, ...)
	self:adapterWithScreen()

	-- 处在的战场
	self._nField = nField or 1
	-- 最大显示行
	self._nMaxRow = math.floor(MAX_CONTENT_HEIGHT / ROW_HEIGHT)
	self._tBulletScreenList = {}
	-- 从服务器拿到弹幕信息时，锁定，解锁后再进行下一条弹幕的显示
	self._bLock = false
	-- 定时器驱动弹幕显示
	self._tTimer = nil
	self._tBulletScreenPanel = self:getPanelByName("Panel_Middle")

	self._storedLabelMap = {}
	self._showLabelMap = {}

	self._isCreatLables = false

	self.super.ctor(self, json, param, ...)
end

function CrossPVPShowBulletScreenLayer:onLayerLoad()
--	self:_addTimer()
	self:_initWidgets()

	local nId = 1
	G_HandlersManager.crossPVPHandler:sendGetBulletScreenInfo(nId)
end

function CrossPVPShowBulletScreenLayer:onLayerEnter()
	self:adapterLayer()

	local panelContent = self:getPanelByName("Panel_Middle")
	local tSize = panelContent:getSize()
	self._tBarrarySize = tSize

	if not self._isCreatLables then
		self._isCreatLables = true
		self:_createLabels()
	end

	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_PVP_GET_BULLET_SCREEN_INFO_SUCC, self._onGetBulletScreenInfoSucc, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_PVP_GET_BULLET_SCREEN_CONTENT_SUCC, self._onGetBulletScreenContentSucc, self)

	self:_addTimer()
end

function CrossPVPShowBulletScreenLayer:onLayerExit()
	
end

function CrossPVPShowBulletScreenLayer:onLayerUnload()
	self:_removeTimer()
end

function CrossPVPShowBulletScreenLayer:_createLabels()
	-- 每行分配3个空的label对象
	self._storedLabelMap = {}
	for i=1, self._nMaxRow do
		local storedLabelRow = {}
		for k=1, ROW_LABEL_COUNT do
			local label = self:_createEmptyLabel(i)
			table.insert(storedLabelRow, #storedLabelRow + 1, label)
		end
		self._storedLabelMap[i] = storedLabelRow
	end

	-- 存储显示的label
	self._showLabelMap = {}
	for i=1, self._nMaxRow do
		self._showLabelMap[i] = {}
	end
end

function CrossPVPShowBulletScreenLayer:_initWidgets()
	-- self:registerBtnClickEvent("Button_OpenSend", function()
	-- 	local CrossPVPSendBulletScreenLayer = require("app.scenes.crosspvp.CrossPVPSendBulletScreenLayer")
	-- 	__Log("-- show self._nField = %s", tostring(self._nField))
	-- 	CrossPVPSendBulletScreenLayer.create(self._nField)
	-- end)
end

function CrossPVPShowBulletScreenLayer:adapterLayer()
	self:adapterWidgetHeight("Panel_Middle", "Panel_Top", "Panel_Bottom", 50, 0)
end

function CrossPVPShowBulletScreenLayer:_addTimer()
	if not self._tTimer then
		self._tTimer = G_GlobalFunc.addTimer(0.5, function(dt)
			-- 第三种方案
			self:_addBulletScreenToScreen()
			self:_recycleUnusedLabel()
		end)
	end
end

function CrossPVPShowBulletScreenLayer:_removeTimer()
	if self._tTimer then
		G_GlobalFunc.removeTimer(self._tTimer)
		self._tTimer = nil
	end
end

function CrossPVPShowBulletScreenLayer:_showBarrary()
	
end

function CrossPVPShowBulletScreenLayer:_updateWithRowIndex(nRowIndex)
	
end

--[[
message BulletScreen {
  required uint32 id = 1;//id
  required string content = 2;//内容
  required uint32 bs_type = 3;//弹幕级别//1 2
  optional uint32 time = 4;//时间
  optional uint64 sid = 5;
  optional uint32 user_id = 6;
  optional uint32 sp1 = 7;//特殊字段 通用
}
]]
function CrossPVPShowBulletScreenLayer:_packOneBulletScreenInfo(tData)
	local tBullet = {}
	tBullet._nId = tData.id
	tBullet._szContent = tData.content
	tBullet._bHightLight = (tData.bs_type ~= CrossPVPConst.TEXT_TYPE.NORMAL) and true or false
	tBullet._nSendTime = rawget(tData, "time") and tData.time or 0
	tBullet._nSId = rawget(tData, "sid") and tData.sid or 0
	tBullet._nUId = rawget(tData, "user_id") and tData.user_id or 0
	tBullet._nBattlefield = rawget(tData, "sp1") and tData.sp1 or 1

	return tBullet
end

function CrossPVPShowBulletScreenLayer:_startMoveBarraryInfo(label)
	assert(label)
	label:stopAllActions()
	local actMoveBy = CCMoveBy:create(1, ccp(-MOVE_SPEED, 0))
	local actForever = CCRepeatForever:create(actMoveBy)
	label:runAction(actForever)
end

function CrossPVPShowBulletScreenLayer:_onGetBulletScreenInfoSucc(tData)
	-- body
end

function CrossPVPShowBulletScreenLayer:_onGetBulletScreenContentSucc(tData)
	if not self:isVisible() then
		return
	end

	self._bLock = true
	for i, v in ipairs(tData.bs) do
		local tBullet = self:_packOneBulletScreenInfo(v)
		if self._nField == tBullet._nBattlefield then
			if not self:_isMyBulletScreenContent(tBullet._nSId, tBullet._nUId) then
				if #self._tBulletScreenList < BULLET_SCREEN_COUNT_MAX then
					table.insert(self._tBulletScreenList, #self._tBulletScreenList + 1, tBullet)
				end
			else
				table.insert(self._tBulletScreenList, 1, tBullet)
			end
		end
	end
	self._bLock = false
end

function CrossPVPShowBulletScreenLayer:_isMyBulletScreenContent(nSId, nUId)
	if tostring(G_PlatformProxy:getLoginServer().id) == tostring(nSId) and tostring(G_Me.userData.id) == tostring(nUId) then
		return true
	else
		return false
	end
end

function CrossPVPShowBulletScreenLayer:_createEmptyLabel(nRowIndex)
	local nTag = FLAG.EMPTY

	local szText = ""
	local fontSize = FONT_SIZE
	local tColor = Colors.darkColors.DESCRIPTION
	local label = G_GlobalFunc.createGameLabel(szText, fontSize, tColor, Colors.strokeBrown)
	label:setAnchorPoint(ccp(0, 0.5))
	local labelSize = label:getSize()
	assert(ROW_HEIGHT > labelSize.height)
	local x =  display.width
	local y = self._tBarrarySize.height - (TOP_DIS + (ROW_HEIGHT - labelSize.height) / 2 + (nRowIndex - 1)*ROW_HEIGHT)
	label:setPositionXY(x, y)
	self._tBulletScreenPanel:addChild(label)
	-- 记录下row index
	label:setTag(nTag)

	return label
end

-- 方案三
function CrossPVPShowBulletScreenLayer:_findEmptyRow()
	local nRowIndex = 0
	for i=1, self._nMaxRow do
		local showLabelRow = self._showLabelMap[i]
		local len = table.nums(showLabelRow)
		if len == 0 then
			nRowIndex = i
			break
		elseif len < ROW_LABEL_COUNT then
			local label = showLabelRow[len]
			local labelWidth = label:getSize().width
			local x = label:getPositionX()
			if x <= display.width - labelWidth - TWO_LABEL_SPACE then
				nRowIndex = i
				break
			end 
		end
	end
	return nRowIndex
end

function CrossPVPShowBulletScreenLayer:_addBulletScreenToScreen()
	-- 先判断有没有空行了
	local nRowIndex = self:_findEmptyRow()
	if nRowIndex == 0 then
		return
	end
	-- 在收弹幕信息
	if self._bLock then
		return
	end
	-- 拿到第一条弹幕信息
	local tBullet = self._tBulletScreenList[1]
	if not tBullet then
		return
	end

	-- 播放一条弹幕信息
	self:_playBulletScreenContent(nRowIndex, tBullet)
	-- 删除弹幕信息
	table.remove(self._tBulletScreenList, 1)
end

function CrossPVPShowBulletScreenLayer:_playBulletScreenContent(nRowIndex, tBullet)
	local storedLabelRow = self._storedLabelMap[nRowIndex]
	local showLabelRow = self._showLabelMap[nRowIndex]

	local label = storedLabelRow[1]
	if not label then
		return
	end
	label:setPositionX(display.width)
	label:setText(tBullet._szContent)
	label:setColor(tBullet._bHightLight and Colors.qualityColors[7] or Colors.darkColors.DESCRIPTION)

	table.remove(storedLabelRow, 1)
	table.insert(showLabelRow, #showLabelRow + 1, label)

	self:_startMoveBarraryInfo(label)
end

function CrossPVPShowBulletScreenLayer:_recycleUnusedLabel()
	for i=1, self._nMaxRow do
		local showLabelRow = self._showLabelMap[i]
		local storedLabelRow = self._storedLabelMap[i]

		local len = table.nums(showLabelRow)
		for k=len, 1, -1 do
			local label = showLabelRow[k]
			assert(label)
			local x = label:getPositionX()
			local labelWidth = label:getSize().width
			if x <= display.width - labelWidth - TWO_LABEL_SPACE then
				table.remove(showLabelRow, k)
				table.insert(storedLabelRow, #storedLabelRow + 1, label)
		 	end
		end
	end
end

function CrossPVPShowBulletScreenLayer:clearBulletScreen()
	self._tBulletScreenList = {}
	self:setVisible(false)
end

-- 当战斗结束，
function CrossPVPShowBulletScreenLayer:closeBulletScreen()
	self:_removeTimer()
end


return CrossPVPShowBulletScreenLayer