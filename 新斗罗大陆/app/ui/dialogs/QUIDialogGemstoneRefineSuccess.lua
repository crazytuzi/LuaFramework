local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogGemstoneRefineSuccess = class("QUIDialogGemstoneRefineSuccess", QUIDialog)
local QUIWidgetEquipmentAvatar = import("..widgets.QUIWidgetEquipmentAvatar")

function QUIDialogGemstoneRefineSuccess:ctor(options)
	local ccbFile = "ccb/Dialog_Baoshi_Refine_Success.ccbi"
	QUIDialogGemstoneRefineSuccess.super.ctor(self, ccbFile, callBacks, options)
	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
	self.isAnimation = true

    if options ~= nil then 
        self._itemConfig = options.itemConfig

        self._oldGemstoneInfo = options.oldGemstoneInfo
        self._newGemstoneInfo = options.newGemstoneInfo

		self._oldAttributes = options.oldAttributes
		self._newAttributes = options.newAttributes
		self._callback = options.callback
	end
    app.sound:playSound("common_level_up")
    self:setRefineInfo()
end

-- 设置item下的道具名称
function QUIDialogGemstoneRefineSuccess:_setItemTitle(tfNode, gemstoneInfo)
    local level,color = remote.herosUtil:getBreakThrough(gemstoneInfo.craftLevel) 
    local name = self._itemConfig.name
    local advancedLevel = gemstoneInfo.godLevel
    local mixLevel = gemstoneInfo.mix_level or 0
    name = remote.gemstone:getGemstoneNameByData(name,advancedLevel,mixLevel)

    if level > 0 then
    	name = name .. "＋".. level
	end
	
	local fontColor = BREAKTHROUGH_COLOR_LIGHT[color]
    tfNode:setColor(fontColor)
    tfNode:setString(name)
end

-- 设置显示item的信息
function QUIDialogGemstoneRefineSuccess:setItemInfo(itemNode, tfNode, gemstoneInfo)
    local gemStoneWidget = QUIWidgetEquipmentAvatar.new()
    itemNode:addChild(gemStoneWidget)
    
	local craftLevel = gemstoneInfo.craftLevel or 0
	local godLevel = gemstoneInfo.godLevel or 0
	local mixLevel = gemstoneInfo.mix_level or 0
	local refineLevel = gemstoneInfo.refine_level or 0

	gemStoneWidget:setGemstonInfo(self._itemConfig, craftLevel, 1.0, godLevel, mixLevel, refineLevel)
	gemStoneWidget:hideAllColor()
    
    self:_setItemTitle(tfNode, gemstoneInfo)
end

-- 设置精炼信息
function QUIDialogGemstoneRefineSuccess:setRefineInfo()
    self:setItemInfo(self._ccbOwner.old_head, self._ccbOwner.tf_old_name, self._oldGemstoneInfo)
    self:setItemInfo(self._ccbOwner.new_head, self._ccbOwner.tf_new_name, self._newGemstoneInfo)

    self._index = 1
    self:setTFValue(self._newAttributes.percentName, self._oldAttributes.percentSrc or 0, self._newAttributes.percentSrc or 0, true)
    self:setTFValue(self._newAttributes.valueName, math.floor(self._oldAttributes.valueSrc or 0), math.floor(self._newAttributes.valueSrc or 0), false)
end

function QUIDialogGemstoneRefineSuccess:setTFValue(name, oldValue, newValue, isPercent)
	if self._index > 2 then return end
    if self._ccbOwner["name"..self._index] ~= nil then
        self._ccbOwner["name"..self._index]:setString(name.."：")
        if isPercent == true then
            self._ccbOwner["old_prop"..self._index]:setString(string.format("  %.2f%%",oldValue*100))
            self._ccbOwner["new_prop"..self._index]:setString(string.format("  %.2f%%",(newValue)*100))
        else
            self._ccbOwner["old_prop"..self._index]:setString("  "..oldValue)
            self._ccbOwner["new_prop"..self._index]:setString("  "..newValue)
        end
        self._ccbOwner["arrow"..self._index]:setVisible(true)
    end
    self._index = self._index + 1
end

function QUIDialogGemstoneRefineSuccess:_backClickHandler()
	self:_onTriggerClose()
end

function QUIDialogGemstoneRefineSuccess:_onTriggerClose()
	self:playEffectOut()
end

function QUIDialogGemstoneRefineSuccess:viewAnimationOutHandler()
	local callback = self._callback
    remote.herosUtil:dispatchEvent({name = remote.herosUtil.EVENT_REFESH_BATTLE_FORCE})
    
	self:popSelf()
	if callback then
		callback()
	end
end

return QUIDialogGemstoneRefineSuccess