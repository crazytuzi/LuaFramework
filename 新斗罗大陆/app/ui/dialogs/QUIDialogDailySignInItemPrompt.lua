local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogDailySignInItemPrompt = class("QUIDialogDailySignInItemPrompt", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

function QUIDialogDailySignInItemPrompt:ctor(options)
  local ccbFile = "ccb/Widget_DailySignIn_ItemPrompt2.ccbi"
  local callBacks = {}
  QUIDialogDailySignInItemPrompt.super.ctor(self, ccbFile, callBacks, options)
  self.isAnimation = true
  
  self:getView():setPosition(ccp(display.width/2 + 35, display.height/2 ))
  if options.index ~= nil then
    if options.isStack == true then
      self._ccbOwner.sign_num:setString("累计"..options.index.."次签到可领取此奖励")
    else
      self._ccbOwner.sign_num:setString("本月第"..options.index.."次签到可领取此奖励")
    end
  end
  self.itemConfig = options.itemInfo
  self.item_id = options.id
  self.oldDecSize = self._ccbOwner.kuang_bg:getContentSize()
  self.oldMoneySize = self._ccbOwner.itme_money:getContentSize()
  self:getView():setPositionX(display.cx)
  
  self:resetAll()
  self:setInfo()
  self:setItemIcon()
end

function QUIDialogDailySignInItemPrompt:viewDidAppear()
    QUIDialogDailySignInItemPrompt.super.viewDidAppear(self)
    self._backTouchLayer = CCLayerColor:create(ccc4(0, 0, 0, 0), display.width, display.height)
    self._backTouchLayer:setPosition(-display.width/2, -display.height/2)
    self._backTouchLayer:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
    self._backTouchLayer:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, QUIDialogDailySignInItemPrompt._onTouchEnable))
    self._backTouchLayer:setTouchEnabled(true)
    self:getView():addChild(self._backTouchLayer,-1)
end

function QUIDialogDailySignInItemPrompt:viewAnimationOutHandler()
    self:removeSelfFromParent()
end

function QUIDialogDailySignInItemPrompt:resetAll()
  self._ccbOwner.itme_name:setString("")
  self._ccbOwner.itme_money:setString("")
  self._ccbOwner.itme_level:setString("")
  self._ccbOwner.have_num:setString("")
  for i = 1 , 3 ,1 do
    self._ccbOwner["property"..i]:setString("")
    self._ccbOwner["number"..i]:setString("")
  end
end

function QUIDialogDailySignInItemPrompt:setInfo()
  self._ccbOwner.itme_name:setString(self.itemConfig.name or "")
  self._ccbOwner.itme_money:setString(self.itemConfig.selling_price or 0)
  self._ccbOwner.itme_level:setString(self.itemConfig.level or 0)
  self._ccbOwner.have_num:setString(remote.items:getItemsNumByID(self.itemConfig.id) or 0)
  self._ccbOwner.property1:setString(q.autoWrap(self.itemConfig.description or "", 21, 40/3, self.oldDecSize.width - 10) or "")
    
  local moneyIconPosition = ccp(self._ccbOwner.money_icon:getPosition())
  local moneySize = self._ccbOwner.itme_money:getContentSize()
  local positionChange = self.oldMoneySize.width - moneySize.width
  self._ccbOwner.money_icon:setPosition(moneyIconPosition.x + positionChange, moneyIconPosition.y)
end

function QUIDialogDailySignInItemPrompt:setItemIcon()
  local itmeBox = QUIWidgetItemsBox.new()
  self._ccbOwner.item_icon:addChild(itmeBox)
  itmeBox:setGoodsInfo(self.item_id, ITEM_TYPE.ITEM, 0)
end

function QUIDialogDailySignInItemPrompt:_onTouchEnable(event)
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

function QUIDialogDailySignInItemPrompt:_onTriggerClose()
    self:playEffectOut()
end

function QUIDialogDailySignInItemPrompt:removeSelfFromParent()
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

return QUIDialogDailySignInItemPrompt