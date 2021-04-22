local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetChipPrompt = class("QUIWidgetChipPrompt", QUIWidget)

local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

function QUIWidgetChipPrompt:ctor(options)
  local ccbFile = "ccb/Widget_ChipPrompt.ccbi"
  local callBacks = {}
  QUIWidgetChipPrompt.super.ctor(self, ccbFile, callBacks, options)
  if options ~= nil then
    self.itemConfig = options.itemConfig
    self.iconSize = options.boxSize
    self.scaleX = options.scaleX
    self.scaleY = options.scaleY
  end

  self:getOldInfo()

  self._ccbOwner.chip_name:setString("")
  self._ccbOwner.chip_money:setString("")
  self._ccbOwner.chip_level:setString("")
  self._ccbOwner.chip_num_red:setString("")
  self._ccbOwner.chip_num_green:setString("")
  self._ccbOwner.chip_content:setString("")

  self:setItemIcon(self.itemConfig.icon)
  self:setInfo()
  self.size = self._ccbOwner.chip_bg:getContentSize()

end
--设置物品信息
function QUIWidgetChipPrompt:setInfo()
  local grade = QStaticDatabase:sharedDatabase():getGradeNeedMaxSoulNumByHeroSoulId(self.itemConfig.id)
  self._ccbOwner.chip_name:setString(self.itemConfig.name)
  self._ccbOwner.chip_money:setString(self.itemConfig.selling_price)
  self._ccbOwner.chip_level:setString(self.itemConfig.level)
  local soul_count = nil 
  if grade == nil then
    soul_count = 0
    self._ccbOwner.max_num:setString("")
  else
    soul_count = grade
    self._ccbOwner.max_num:setString("/"..soul_count)
  end
  
  if remote.items:getItemsNumByID(self.itemConfig.id) < soul_count then
    self._ccbOwner.chip_num_red:setString(remote.items:getItemsNumByID(self.itemConfig.id))
    self._ccbOwner.chip_num_green:setString("")
  else
    self._ccbOwner.chip_num_green:setString(remote.items:getItemsNumByID(self.itemConfig.id))
    self._ccbOwner.chip_num_red:setString("")
  end
  self._ccbOwner.chip_content:setString(self.itemConfig.description or "")

  local moneyIconPosition = ccp(self._ccbOwner.money_icon:getPosition())
  local moneySize = self._ccbOwner.chip_money:getContentSize()
  local positionChange = self.oldMoneySize.width - moneySize.width
  self._ccbOwner.money_icon:setPosition(moneyIconPosition.x + positionChange, moneyIconPosition.y)
  self:setHaveNum()
end

function QUIWidgetChipPrompt:setHaveNum()
  local chipNumPosition = ccp(self._ccbOwner.chip_num_red:getPosition())
  local leftNumPosition = ccp(self._ccbOwner.left_shell:getPosition())
  local maxNumSize = self._ccbOwner.max_num:getContentSize()
  local chipNumSize1 = self._ccbOwner.chip_num_green:getContentSize()
  local chipNumSize2 = self._ccbOwner.chip_num_red:getContentSize()
  local chipNumChange = self.oldChipNumSize.width - chipNumSize1.width - chipNumSize2.width
  local maxNumChange = self.oldMaxNumSize.width - maxNumSize.width
  
  self._ccbOwner.chip_num_red:setPosition(chipNumPosition.x + maxNumChange, chipNumPosition.y)
  self._ccbOwner.chip_num_green:setPosition(chipNumPosition.x + maxNumChange, chipNumPosition.y)
  self._ccbOwner.left_shell:setPosition(leftNumPosition.x + chipNumChange + maxNumChange, leftNumPosition.y)
  
end

function QUIWidgetChipPrompt:setPromptBg()
  self._ccbOwner.chip_bg:setScaleY((self.oldPromptSize.height - self.frameChange)/self.oldPromptSize.width)
end

function QUIWidgetChipPrompt:setFrameBg()
  local contentSize = self._ccbOwner.chip_content:getContentSize().height
  self.frameChange = self.oldContentSize.height - contentSize
  self._ccbOwner.kuang_bg:setScaleY((self.oldFrameSize.height - self.frameChange)/self.oldFrameSize.height)
end

function QUIWidgetChipPrompt:getOldInfo()
  self.oldPromptSize = self._ccbOwner.chip_bg:getContentSize()
  self.oldFrameSize = self._ccbOwner.kuang_bg:getContentSize()
  self.oldContentSize = self._ccbOwner.chip_content:getContentSize()
  self.oldMoneySize = self._ccbOwner.chip_money:getContentSize()
  self.oldChipNumSize = self._ccbOwner.chip_num_red:getContentSize()
  self.oldMaxNumSize = self._ccbOwner.max_num:getContentSize()
end

function QUIWidgetChipPrompt:setItemIcon(respath)
  local itmeBox = QUIWidgetItemsBox.new()
  self._ccbOwner.node_head:addChild(itmeBox)
  itmeBox:setGoodsInfo(self.itemConfig.id, ITEM_TYPE.ITEM, 0)
  
--  if respath~=nil and #respath > 0 then
--    if self.icon == nil then
--      self.icon = CCSprite:create()
--      self._ccbOwner.node_icon:addChild(self.icon)
--      self._ccbOwner.node_mask:setVisible(false)
--      self._ccbOwner.node_scrap:setVisible(true)
--      self._ccbOwner.node_soul:setVisible(true)
--      self._ccbOwner.tf_goods_num:setVisible(false)
--    end
--    self.icon:setVisible(true)
--    self.icon:setScale(1)
--    self.icon:setTexture(CCTextureCache:sharedTextureCache():addImage(respath))
--  end
--  local size = self.icon:getContentSize()
--
--    if size.width > self.iconSize.width then
--      self.icon:setScaleX(self.iconSize.width * self.scaleX/size.width)
--    end
--    if size.height > self.iconSize.height then
--      self.icon:setScaleY(self.iconSize.height * self.scaleY/size.height)
--    end
end

return QUIWidgetChipPrompt
