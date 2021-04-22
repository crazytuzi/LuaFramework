local QUIWidget = import("..widgets.QUIWidget")
local QUIWidgetItmePrompt = class("QUIWidgetItmePrompt", QUIWidget)

local QUIWidgetItemsBox = import("..widgets.QUIWidgetItemsBox")

function QUIWidgetItmePrompt:ctor(options)
    local ccbFile = "ccb/Widget_ItemPrompt.ccbi"
    local callBacks = {}
    QUIWidgetItmePrompt.super.ctor(self, ccbFile, callBacks, options)
    if options ~= nil then
        self.itemConfig = options.itemConfig
        self.iconSize = options.boxSize
        self.scaleX = options.scaleX
        self.scaleY = options.scaleY
    end

    self:getOldInfo()

    self._ccbOwner.itme_name:setString("")
    self._ccbOwner.itme_money:setString("")
    self._ccbOwner.itme_level:setString("")
    self._ccbOwner.have_num:setString("")
    --  self._ccbOwner.tf_goods_num:setVisible(false)
    
    for i = 1 , 4 ,1 do
        self._ccbOwner["property"..i]:setString("")
        self._ccbOwner["number"..i]:setString("")
    end

    self:setItemIcon(self.itemConfig.icon)
  
    self:setInfo()
    self.size = self._ccbOwner.item_bg:getContentSize()
end
--设置物品信息
function QUIWidgetItmePrompt:setInfo()
    if self.itemConfig.type == ITEM_CONFIG_TYPE.GEMSTONE then
        self._ccbOwner.curHaveNumFront:setVisible(false)
        self._ccbOwner.curHaveNumBack:setVisible(false)
        self._ccbOwner.have_num:setVisible(false)
    else
        self._ccbOwner.curHaveNumFront:setVisible(true)
        self._ccbOwner.curHaveNumBack:setVisible(true)
        self._ccbOwner.have_num:setVisible(true)
        self._ccbOwner.have_num:setString(remote.items:getItemsNumByID(self.itemConfig.id))
    end
    self._ccbOwner.itme_name:setString(self.itemConfig.name or "")
    self._ccbOwner.itme_money:setString(self.itemConfig.selling_price or 0)
    self._ccbOwner.itme_level:setString(self.itemConfig.level or 0)
    self._ccbOwner.content:setString(self.itemConfig.description or "")
    local newContentSize = self._ccbOwner.content:getContentSize()
    self._ccbOwner.item_bg:setContentSize(CCSize(self.oldPromptSize.width, self.oldPromptSize.height - self.oldContentSize.height + newContentSize.height))
end

function QUIWidgetItmePrompt:setPromptBg()
    local itmeNameSize = self._ccbOwner.itme_name:getContentSize().width
    local moneyNodePosition = self._ccbOwner.money_node:getPositionX()
    local levelNameSize = self._ccbOwner.need_level:getContentSize().width
    local levelSize = self._ccbOwner.itme_level:getContentSize().width
    self.frameChange = self.propertySize * (4 - #self.property)

    if itmeNameSize < levelNameSize+levelSize then
        self.itmeNameChange = self.oldItmeSize.width - (levelNameSize+levelSize)
    else
        self.itmeNameChange = self.oldItmeSize.width - itmeNameSize
    end
    self._ccbOwner.item_bg:setContentSize(CCSize(self.oldPromptSize.width - self.itmeNameChange, self.oldPromptSize.height - self.frameChange))
    -- self._ccbOwner.money_node:setPositionX(moneyNodePosition - self.itmeNameChange)
end

function QUIWidgetItmePrompt:setFrameBg()
    local moneyIconPosition = ccp(self._ccbOwner.money_icon:getPosition())
    local moneySize = self._ccbOwner.itme_money:getContentSize()
    local positionChange = self.oldMoneySize.width - moneySize.width
    self._ccbOwner.money_icon:setPosition(moneyIconPosition.x + positionChange, moneyIconPosition.y)
  
    self._ccbOwner.kuang_bg:setScaleX((self.oldFrameSize.width - self.itmeNameChange)/self.oldFrameSize.width)
    self._ccbOwner.kuang_bg:setScaleY((self.oldFrameSize.height - self.frameChange)/self.oldFrameSize.height)
    if #self.property == 0 then
        self._ccbOwner.kuang_bg:setVisible(false)
    end
end

function QUIWidgetItmePrompt:getOldInfo()
    self.propertySize = self._ccbOwner.property1:getContentSize().height
    self.oldPromptSize = self._ccbOwner.item_bg:getContentSize()
    self.oldFrameSize = self._ccbOwner.kuang_bg:getContentSize()
    self.oldItmeSize = self._ccbOwner.itme_name:getContentSize()
    self.oldMoneySize = self._ccbOwner.itme_money:getContentSize()
    self.oldContentSize = self._ccbOwner.content:getContentSize()
end

function QUIWidgetItmePrompt:setItemIcon(respath)
    local itmeBox = QUIWidgetItemsBox.new()
    self._ccbOwner.item_icon:addChild(itmeBox)
    itmeBox:setGoodsInfo(self.itemConfig.id, ITEM_TYPE.ITEM, 0)
end

function QUIWidgetItmePrompt:setProperty()
    local contentSize = self._ccbOwner.property1:getContentSize()
    if contentSize.width > 50 then
        local position = ccp(self._ccbOwner.number1:getPosition())
        self._ccbOwner.number1:setPosition(position.x + 40, position.y)
    end
    for i = 2, 4, 1 do 
        local contentSize = self._ccbOwner["property"..i]:getContentSize()
        if contentSize.width < 80 then
        local position = ccp(self._ccbOwner["number".. i]:getPosition())
        self._ccbOwner["number".. i]:setPosition(position.x - 40, position.y)
        end
    end
end

return QUIWidgetItmePrompt
