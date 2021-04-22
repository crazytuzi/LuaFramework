

local QUIDialog = import(".QUIDialog")
local QUIDialogMockBattleRank = class("QUIDialogMockBattleRank", QUIDialog)
local QListView = import("...views.QListView")
local QUIViewController = import("..QUIViewController")
local QUIWidgetMockBattleRankCell = import("..widgets.QUIWidgetMockBattleRankCell")

function QUIDialogMockBattleRank:ctor(options)
	local ccbFile = "ccb/Dialog_MockBattle_Rank.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
		-- {ccbCallbackName = "onTriggerNormal", callback = handler(self, self._onTriggerNormal)},
		-- {ccbCallbackName = "onTriggerTop", callback = handler(self, self._onTriggerTop)},
	}
	QUIDialogMockBattleRank.super.ctor(self,ccbFile,callBacks,options)
	self._data ={}

end 


function QUIDialogMockBattleRank:viewDidAppear()
    QUIDialogMockBattleRank.super.viewDidAppear(self)
	self:initRankData()
	self:initListView()
	self:setInfo()
    self:addBackEvent(false)
end

function QUIDialogMockBattleRank:viewWillDisappear()
    QUIDialogMockBattleRank.super.viewWillDisappear(self)
    self:removeBackEvent()
end

function QUIDialogMockBattleRank:setInfo()
	self._ccbOwner.frame_tf_title:setString("统  计")
end

function QUIDialogMockBattleRank:initRankData()
	self._data = {}
	self._data = remote.mockbattle:getMockBattleHeroData()
	-- local hero_data = remote.mockbattle:getMockBattleHeroData()

	-- for i,v in ipairs(table_name) do
	-- 	table.insert(self._data, v)
	-- end
	if #self._data >= 2 then
		table.sort(self._data, function (x, y)
				if x.winRate and y.winRate then
					return x.winRate > y.winRate
				else
					return x.attendanceRate > y.attendanceRate
				end
			end)
	end	

end

function QUIDialogMockBattleRank:initListView()
	self._ccbOwner.node_empty:setVisible(not next(self._data))
	if not self._listView then
		local cfg = {
			renderItemCallBack = handler(self, self._renderItemFunc),
	        curOriginOffset = 0,
	        isVertical = true,
	        enableShadow = true,
	      	ignoreCanDrag = true,
	      	spaceY = 6,
	      	contentOffsetX = 6,
	        totalNumber = #self._data,
		}
		self._listView = QListView.new(self._ccbOwner.sheet_content,cfg)
	else
		self._listView:reload({totalNumber = #self._data})
	end
end

function QUIDialogMockBattleRank:_renderItemFunc( list, index, info )
    -- body
    local isCacheNode = true
    local itemData = self._data[index]
    local item = list:getItemFromCache(self._selectTab)
    if not item then
    	item = QUIWidgetMockBattleRankCell.new()
    	isCacheNode = false
    end
    item:setInfo(itemData,index)
    --item:initGLLayer()
    info.item = item
    info.size = item:getContentSize()

    return isCacheNode
end


function QUIDialogMockBattleRank:_backClickHandler()
    self:playEffectOut()
end

function QUIDialogMockBattleRank:_onTriggerClose(event)
	if q.buttonEventShadow(event, self._ccbOwner.btn_close) == false then return end
	app.sound:playSound("common_cancel")
    self:playEffectOut()
end


return QUIDialogMockBattleRank