local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMagicHerbRefinePreview = class("QUIDialogMagicHerbRefinePreview", QUIDialog)
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QActorProp = import("...models.QActorProp")
local QScrollContain = import("...ui.QScrollContain")

function QUIDialogMagicHerbRefinePreview:ctor(options)
	local ccbFile = "ccb/Dialog_magicHerb_propView.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerClose", 				callback = handler(self, self._onTriggerClose)},
	}
	QUIDialogMagicHerbRefinePreview.super.ctor(self,ccbFile,callBacks,options)
	self.isAnimation = true
	if options then
		self._refineId = options.refineId
	end
	self._ccbOwner.tf_title:setString("转生属性")
	self._ccbOwner.tf_desc:setVisible(true)
	local refineConfig = remote.magicHerb:getRefineConfigByRefineId(self._refineId)

	local propList = {}
	local index = 1
    while true do
        if refineConfig["attribute_id_"..index] then
        	local key = refineConfig["attribute_id_"..index]
        	local color = refineConfig["color_"..index]
        	if QActorProp._field[key] then
				local name = QActorProp._field[key].uiName or QActorProp._field[key].name
				local tbl = string.split(refineConfig["value_"..index], ";")
				local isPercent = QActorProp._field[key].isPercent
				tbl[1] = q.getFilteredNumberToString(tonumber(tbl[1]), isPercent, 2)		
				tbl[2] = q.getFilteredNumberToString(tonumber(tbl[2]), isPercent, 2)		
				table.insert(propList, {name = name, minNum = tbl[1], maxNum = tbl[2], color = color, isPercent = isPercent})
			end
        end
        index = index + 1
        if index > table.nums(refineConfig) then
            break
        end
    end
    table.sort(propList, function(a, b)
    	if a.color ~= b.color then
    		return a.color > b.color
    	end
    	if a.isPercent ~= b.isPercent then
    		return a.isPercent == true
    	end
    end)

	local offsetY = -50
	local offsetX = 0
	local titleColor = COLORS.b
	local nameColor = COLORS.a
	local valueColor = COLORS.c

	index = 0
	offsetX = 20
	for _, v in ipairs(propList) do
		if index > 0 and index%2 == 0 then
			offsetX = 20
			offsetY = offsetY - 35
		end
		local tf1 = CCLabelTTF:create(v.name.."：", global.font_default, 20)
		tf1:setAnchorPoint(0,1)
		tf1:setColor(nameColor)
		tf1:setPosition(ccp(offsetX, offsetY))
		self._ccbOwner.node_prop:addChild(tf1)
		offsetX = offsetX + 100

		local tf2 = CCLabelTTF:create(v.minNum.."~"..v.maxNum, global.font_default, 20)
		tf2:setAnchorPoint(0,1)
		local color = COLORS[v.color] or valueColor
		-- local strokeColor = getShadowColorByFontColor(color)
		tf2:setColor(color)
		-- tf2:setShadowColor(strokeColor)
		tf2:setPosition(ccp(offsetX, offsetY))
		self._ccbOwner.node_prop:addChild(tf2)
		offsetX = offsetX + 200
		index = index + 1			
	end
	offsetY = offsetY - 54

	self._ccbOwner.tf_desc:setPositionY(offsetY)
	offsetY = offsetY - 15

    self._scroll = QScrollContain.new({sheet = self._ccbOwner.sheet, sheet_layout = self._ccbOwner.sheet_layout, direction = QScrollContain.directionY})
    self._scroll:setIsCheckAtMove(true)
    self._ccbOwner.node_prop:retain()
    self._ccbOwner.node_prop:setPosition(ccp(0,0))
    self._ccbOwner.node_prop:removeFromParent()
    self._scroll:addChild(self._ccbOwner.node_prop)
    self._ccbOwner.node_prop:release()
    self._scroll:setContentSize(0, math.abs(offsetY))
end

function QUIDialogMagicHerbRefinePreview:viewWillDisappear()
    QUIDialogMagicHerbRefinePreview.super.viewWillDisappear(self)
  
    if self._scroll ~= nil then
    	self._scroll:disappear()
    	self._scroll = nil
    end
end

function QUIDialogMagicHerbRefinePreview:_onTriggerClose()
	app.sound:playSound("common_cancel")
	self:playEffectOut()
end

function QUIDialogMagicHerbRefinePreview:_backClickHandler()
	app.sound:playSound("common_cancel")
	self:playEffectOut()
end

return QUIDialogMagicHerbRefinePreview