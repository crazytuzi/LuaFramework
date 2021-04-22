-- @Author: liaoxianbo
-- @Date:   2020-04-12 17:36:17
-- @Last Modified by:   DELL
-- @Last Modified time: 2020-04-14 18:13:45
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSoulTowerMonsterInfo = class("QUIDialogSoulTowerMonsterInfo", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QUIWidgetSoulTowerFloorMonsterView = import("..widgets.QUIWidgetSoulTowerFloorMonsterView")
local QListView = import("...views.QListView")

function QUIDialogSoulTowerMonsterInfo:ctor(options)
	local ccbFile = "ccb/Dialog_SoulTower_Monster.ccbi"
    local callBacks = {
		{ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
    }
    QUIDialogSoulTowerMonsterInfo.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()

    self._soulTowerFloorInfo = options.floorInfo

    self._ccbOwner.frame_tf_title:setString("魂兽情报")

    local waves = self._soulTowerFloorInfo.wave 

    self._monsterWave = {}
    if waves then
    	local tabWave = string.split(waves,",")
    	for index, wave in pairs(tabWave) do
    		-- self._monsterWave[index] = wave
            local tbl = string.split(wave,"^")
    		table.insert(self._monsterWave,{index = index, wave = tbl[1],level = tbl[2]})
    	end
    end
    self:initListView()
end

function QUIDialogSoulTowerMonsterInfo:viewDidAppear()
	QUIDialogSoulTowerMonsterInfo.super.viewDidAppear(self)

	self:addBackEvent(true)
end

function QUIDialogSoulTowerMonsterInfo:viewWillDisappear()
  	QUIDialogSoulTowerMonsterInfo.super.viewWillDisappear(self)

	self:removeBackEvent()
end

function QUIDialogSoulTowerMonsterInfo:initListView()
    if not self._contentListView then
	    local cfg = {
	        renderItemCallBack = handler(self,self.renderFunHandler),
	        ignoreCanDrag = true,
	        totalNumber = #self._monsterWave,
	        enableShadow = false,
	    }  
	    self._contentListView = QListView.new(self._ccbOwner.sheet_layout, cfg)
	else
		self._contentListView:reload({totalNumber = #self._monsterWave})
	end
end

function QUIDialogSoulTowerMonsterInfo:renderFunHandler(list, index, info)
    local isCacheNode = true
    local waveInfo = self._monsterWave[index]
    local item = list:getItemFromCache()

    if not item then
    	item = QUIWidgetSoulTowerFloorMonsterView.new()
        isCacheNode = false
    end
    info.item = item
	item:setMonsterHead(waveInfo,self)
    -- item:registerItemBoxPrompt(index, list)
    list:registerTouchHandler(index,"onTouchListView")
    
    info.size = item:getContentSize()
	return isCacheNode
end

function QUIDialogSoulTowerMonsterInfo:getContentListView()
    return self._contentListView
end

function QUIDialogSoulTowerMonsterInfo:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogSoulTowerMonsterInfo:_onTriggerClose()
  	app.sound:playSound("common_close")
	self:playEffectOut()
end

function QUIDialogSoulTowerMonsterInfo:viewAnimationOutHandler()
	local callback = self._callBack

	self:popSelf()

	if callback then
		callback()
	end
end

return QUIDialogSoulTowerMonsterInfo
