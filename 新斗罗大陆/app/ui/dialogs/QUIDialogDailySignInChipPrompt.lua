local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogDailySignInChipPrompt = class("QUIDialogDailySignInChipPrompt", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")
local QStaticDatabase = import("...controllers.QStaticDatabase")

function QUIDialogDailySignInChipPrompt:ctor(options)
  local ccbFile = "ccb/Widget_DailySignIn_ItemPrompt1.ccbi"
  local callBacks = {}
  QUIDialogDailySignInChipPrompt.super.ctor(self, ccbFile, callBacks, options)
  self.isAnimation = true

  self:getView():setPosition(ccp(display.width/2 + 35, display.height/2))
    if options.isStack == true then
      self._ccbOwner.sign_num:setString("累计"..options.index.."次签到可领取此奖励")
    else
      self._ccbOwner.sign_num:setString("本月第"..options.index.."次签到可领取此奖励")
    end
  self.itemConfig = options.itemInfo
  self.item_id = options.id
  self.oldMoneySize = self._ccbOwner.itme_money:getContentSize()
  self.oldChipNumSize = self._ccbOwner.have_num_red:getContentSize()
  self.oldMaxNumSize = self._ccbOwner.max_num:getContentSize()

  self:resetAll()
  self:setItemInfo()
  self:setItemIcon(self.itemConfig.icon)
end

function QUIDialogDailySignInChipPrompt:viewDidAppear()
  QUIDialogDailySignInChipPrompt.super.viewDidAppear(self)
  self._backTouchLayer = CCLayerColor:create(ccc4(0, 0, 0, 0), display.width, display.height)
  self._backTouchLayer:setPosition(-display.width/2, -display.height/2)
  self._backTouchLayer:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
  self._backTouchLayer:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, QUIDialogDailySignInChipPrompt._onTouchEnable))
  self._backTouchLayer:setTouchEnabled(true)
  self:getView():addChild(self._backTouchLayer,-1)
end

function QUIDialogDailySignInChipPrompt:viewAnimationOutHandler()
  self:removeSelfFromParent()
end

function QUIDialogDailySignInChipPrompt:resetAll()
  self._ccbOwner.itme_name:setString("")
  self._ccbOwner.itme_money:setString("")
  self._ccbOwner.itme_level:setString("")
  self._ccbOwner.have_num_green:setString("")
  self._ccbOwner.have_num_red:setString("")
  self._ccbOwner.property1:setString("")
end

function QUIDialogDailySignInChipPrompt:setItemInfo()
  self._ccbOwner.property1:setString(self.itemConfig.description or "")
  self._ccbOwner.itme_name:setString(self.itemConfig.name)
  self._ccbOwner.itme_money:setString(self.itemConfig.selling_price)
  self._ccbOwner.itme_level:setString(self.itemConfig.level)

  local grade = QStaticDatabase:sharedDatabase():getGradeNeedMaxSoulNumByHeroSoulId(self.itemConfig.id)
  local soul_count = nil 
  if grade == nil then
    soul_count = 0
    self._ccbOwner.max_num:setString("")
  else
    soul_count = grade
    self._ccbOwner.max_num:setString("/"..soul_count)
  end
  if remote.items:getItemsNumByID(self.itemConfig.id) < soul_count then
      self._ccbOwner.have_num_red:setString(remote.items:getItemsNumByID(self.itemConfig.id))
      self._ccbOwner.have_num_green:setString("")
    else
      self._ccbOwner.have_num_green:setString(remote.items:getItemsNumByID(self.itemConfig.id))
      self._ccbOwner.have_num_red:setString("")
  end

  local moneyIconPosition = ccp(self._ccbOwner.money_icon:getPosition())
  local moneySize = self._ccbOwner.itme_money:getContentSize()
  local positionChange = self.oldMoneySize.width - moneySize.width
  self._ccbOwner.money_icon:setPosition(moneyIconPosition.x + positionChange, moneyIconPosition.y)

  self:setHaveNum()
end

function QUIDialogDailySignInChipPrompt:setHaveNum()
  local chipNumPosition = ccp(self._ccbOwner.have_num_red:getPosition())
  local leftNumPosition = ccp(self._ccbOwner.left_shell:getPosition())
  local maxNumSize = self._ccbOwner.max_num:getContentSize()
  local chipNumSize1 = self._ccbOwner.have_num_green:getContentSize()
  local chipNumSize2 = self._ccbOwner.have_num_red:getContentSize()
  local chipNumChange = self.oldChipNumSize.width - chipNumSize1.width - chipNumSize2.width
  local maxNumChange = self.oldMaxNumSize.width - maxNumSize.width
  
  self._ccbOwner.have_num_red:setPosition(chipNumPosition.x + maxNumChange, chipNumPosition.y)
  self._ccbOwner.have_num_green:setPosition(chipNumPosition.x + maxNumChange, chipNumPosition.y)
  self._ccbOwner.left_shell:setPosition(leftNumPosition.x + chipNumChange + maxNumChange, leftNumPosition.y)
  
end

function QUIDialogDailySignInChipPrompt:setItemIcon(respath)
  local itmeBox = QUIWidgetItemsBox.new()
  self._ccbOwner.item_icon:addChild(itmeBox)
  itmeBox:setGoodsInfo(self.item_id, ITEM_TYPE.ITEM, 0)
end

function QUIDialogDailySignInChipPrompt:_onTouchEnable(event)
  if event.name == "began" then
    return true
  elseif event.name == "moved" then

  elseif event.name == "ended" then
    scheduler.performWithDelayGlobal(function()
      self:_onTriggerClose()
    end,0)
  elseif event.name == "cancelled" then

  end
end

function QUIDialogDailySignInChipPrompt:_onTriggerClose()
  self:playEffectOut()
end

function QUIDialogDailySignInChipPrompt:removeSelfFromParent()
  app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

return QUIDialogDailySignInChipPrompt
