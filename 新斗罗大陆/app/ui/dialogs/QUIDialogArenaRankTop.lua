local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogArenaRankTop = class("QUIDialogArenaRankTop", QUIDialog)
local QNavigationController = import("...controllers.QNavigationController")

function QUIDialogArenaRankTop:ctor(options)
  local ccbFile = "ccb/Dialog_Arena_RankTop.ccbi"
  local callBacks = {
	    {ccbCallbackName = "onTriggerConfirm", callback = handler(self, QUIDialogArenaRankTop._onTriggerClose)}
  	}
	QUIDialogArenaRankTop.super.ctor(self, ccbFile, callBacks, options)

    if options ~= nil then
        self.myInfo = options.myInfo
        self.token = options.token
        self.callBack = options.callBack or options.callback
        self.isStorm = options.isStorm 
    end
    CalculateUIBgSize(self._ccbOwner.btn_bg_closereward, 1280)

  	self:resetAll()
  	self:setInfo()

    self.animationIsDone = false
  	self._animationManager = tolua.cast(self:getChildView():getUserObject(), "CCBAnimationManager")
  	self._animationManager:connectScriptHandler(function()
    	self.animationIsDone = true
    	end)
  	self._animationManager:runAnimationsForSequenceNamed("one")

    app.sound:playSound("arena_refresh")
end

function QUIDialogArenaRankTop:resetAll()
  	self._ccbOwner.last_rank:setString(0)
  	self._ccbOwner.top_rank:setString(0)
  	self._ccbOwner.add_rank:setString(0)
    if self.isStorm then
        self._ccbOwner.stormMonyIcon:setVisible(true)
        self._ccbOwner.diamondIcon:setVisible(false)
    else
        self._ccbOwner.stormMonyIcon:setVisible(false)
        self._ccbOwner.diamondIcon:setVisible(true)
    end
  	self._ccbOwner.rank_award:setString("x 0")
end

function QUIDialogArenaRankTop:setInfo()
  	local token = self.token
    local rank = self.myInfo.topRank or 10001

  	self._ccbOwner.last_rank:setString(self.myInfo.lastRank)
  	self._ccbOwner.top_rank:setString(rank)
  	self._ccbOwner.add_rank:setString(self.myInfo.lastRank - rank)
    self._ccbOwner.sp_left:setPositionX(self._ccbOwner.add_rank:getPositionX()+self._ccbOwner.add_rank:getContentSize().width)
  	self._ccbOwner.rank_award:setString("x "..token)
end

function QUIDialogArenaRankTop:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogArenaRankTop:_onTriggerClose()  
    if self.callBack ~= nil then
        self.callBack()
    end
	app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

return QUIDialogArenaRankTop
