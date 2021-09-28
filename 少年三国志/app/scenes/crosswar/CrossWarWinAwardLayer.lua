-- CrossWarWinAwardLayer
-- This layer shows the award list for winning streak.

local CrossWarWinAwardLayer = class("CrossWarWinAwardLayer", UFCCSModelLayer)

local AwardItem = require("app.scenes.crosswar.CrossWarWinAwardItem")

function CrossWarWinAwardLayer.create(...)
	return CrossWarWinAwardLayer.new("ui_layout/crosswar_WinAwardLayer.json",
		Colors.modelColor, ...)
end

function CrossWarWinAwardLayer:ctor(...)
	self._listView 		= nil
	self._awardStatus	= nil	-- the list of all award status

	self.super.ctor(self, ...)
end

function CrossWarWinAwardLayer:onLayerLoad(...)
	-- initialize my winning streak info
	self:_initWinStreak()

	-- initialize award list view
	self:_initListView()

	-- initialize award status
	self:_initAwardStatus()

	-- sort award list and reload it
	self:_sortAwardsAndReload()

	-- create strokes
	self:enableLabelStroke("Label_Reset_Explanation", Colors.strokeBrown, 1)

	-- register button events
	self:registerBtnClickEvent("Button_Close", handler(self, self._onCloseClick))
	self:registerBtnClickEvent("Button_Close_TopRight", handler(self, self._onCloseClick))
end

function CrossWarWinAwardLayer:onLayerEnter(...)
	self:showAtCenter(true)
	self:closeAtReturn(true)

	-- register event listeners
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_CROSS_WAR_FINISH_WINS_AWARD, self._onRcvFinishAward, self)
end

-- initialize my winning streak info
function CrossWarWinAwardLayer:_initWinStreak()
	-- current win streak
	local curWinStreak = G_Me.crossWarData:getCurWinStreak()
	self:getLabelByName("Label_CurWinStreak_Num"):setText(tostring(curWinStreak))
end

-- initialize the award list view
function CrossWarWinAwardLayer:_initListView()
	if not self._listView then
		local panel = self:getPanelByName("Panel_List")
		self._listView = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)

		self._listView:setCreateCellHandler(function(list, index)
			return AwardItem.new()
		end)

		self._listView:setUpdateCellHandler(function(list, index, cell)
			cell:update(self._awardStatus[index + 1])
		end)
	end
end

-- initialize award status
function CrossWarWinAwardLayer:_initAwardStatus()
	local gotAwardIDs = G_Me.crossWarData:gotAwardIDs()
	self._awardStatus = {}
	for i = 1, contest_points_winning_info.getLength() do
		-- store the award ID, if it's got, and needed winning number
		local status = {}
		status.awardID = i
		status.alreadyGot = gotAwardIDs[i]
		status.needWinNum = contest_points_winning_info.get(i).winning_number

		-- add to the award list
		self._awardStatus[#self._awardStatus + 1] = status
	end
end

-- sort award list, and reload it
function CrossWarWinAwardLayer:_sortAwardsAndReload()
	local sortFunc = function(a, b)
		-- move the already-got award IDs to the list tail
		if a.alreadyGot ~= b.alreadyGot then
			return not a.alreadyGot
		end

		-- move the awards that reach condition to the list head
		local maxWinStreak = G_Me.crossWarData:getMaxWinStreak()
		local canGetA = (maxWinStreak >= a.needWinNum and not a.alreadyGot)
		local canGetB = (maxWinStreak >= b.needWinNum and not b.alreadyGot)

		if canGetA ~= canGetB then
			return canGetA
		end

		-- no special condition, just sort by ID
		return a.awardID < b.awardID
	end

	-- sort the award list
	table.sort(self._awardStatus, sortFunc)

	-- update list view
	self._listView:reloadWithLength(#self._awardStatus)
end

-- the click handler of the close button
function CrossWarWinAwardLayer:_onCloseClick()
	self:animationToClose()

	local soundConst = require("app.const.SoundConst")
	G_SoundManager:playSound(soundConst.GameSound.BUTTON_SHORT)
end

-- the handler of "EVENT_CROSS_WAR_FINISH_WINS_AWARD" event
function CrossWarWinAwardLayer:_onRcvFinishAward(id, awards)
	-- pop up a message panel
	local layer = require("app.scenes.common.SystemGoodsPopWindowsLayer").create(awards)
	uf_notifyLayer:getModelNode():addChild(layer)

	-- set the status of the finished id
	for _, v in ipairs(self._awardStatus) do
		if v.awardID == id then
			v.alreadyGot = true
			break
		end
	end

	-- sort award list and reload it
	self:_sortAwardsAndReload()
end

return CrossWarWinAwardLayer