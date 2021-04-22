local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogDailySignInCurrencyPrompt = class("QUIDialogDailySignInCurrencyPrompt", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")

function QUIDialogDailySignInCurrencyPrompt:ctor(options)
  local ccbFile = "ccb/Widget_DialySignIn_FushiPrompt.ccbi"
  local callBacks = {}
  QUIDialogDailySignInCurrencyPrompt.super.ctor(self, ccbFile, callBacks, options)
  self.isAnimation = true
  
  local typeInfo = remote.items:getWalletByType(options.type)
  self.word = typeInfo.description or ""

  self._ccbOwner.label_content:setString(self.word or "")
  print(self.word or "")
  if options.index ~= nil then
    if options.isStack == true then
      self._ccbOwner.sign_num:setString("累计"..options.index.."次签到可领取此奖励")
    else
      self._ccbOwner.sign_num:setString("本月第"..options.index.."次签到可领取此奖励")
    end
  end
  
end

function QUIDialogDailySignInCurrencyPrompt:viewDidAppear()
    QUIDialogDailySignInCurrencyPrompt.super.viewDidAppear(self)
    self._backTouchLayer = CCLayerColor:create(ccc4(0, 0, 0, 0), display.width, display.height)
    self._backTouchLayer:setPosition(-display.width/2, -display.height/2)
    self._backTouchLayer:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
    self._backTouchLayer:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, QUIDialogDailySignInCurrencyPrompt._onTouchEnable))
    self._backTouchLayer:setTouchEnabled(true)
    self:getView():addChild(self._backTouchLayer,-1)
end

function QUIDialogDailySignInCurrencyPrompt:viewAnimationOutHandler()
    self:removeSelfFromParent()
end

function QUIDialogDailySignInCurrencyPrompt:_onTouchEnable(event)
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

function QUIDialogDailySignInCurrencyPrompt:_onTriggerClose()
    self:playEffectOut()
end

function QUIDialogDailySignInCurrencyPrompt:removeSelfFromParent()
    app:getNavigationManager():popViewController(app.middleLayer, QNavigationController.POP_TOP_CONTROLLER)
end

return QUIDialogDailySignInCurrencyPrompt