--
-- Author: Kumo.Wang
-- 仙品养成成功展示界面
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMagicHerbSuccess = class("QUIDialogMagicHerbSuccess", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetMagicHerbBox = import("..widgets.QUIWidgetMagicHerbBox")
local QActorProp = import("...models.QActorProp")
local QRichText = import("...utils.QRichText")
local QUIWidgetTitelEffect = import("..widgets.QUIWidgetTitelEffect")

function QUIDialogMagicHerbSuccess:ctor(options)
	local ccbFile = "ccb/Dialog_MagicHerb_Success.ccbi"
	local callBack = {}
	QUIDialogMagicHerbSuccess.super.ctor(self, ccbFile, callBack, options)
	self.isAnimation = true

	cc.GameObject.extend(self)
	self:addComponent("components.behavior.EventProtocol"):exportMethods()
	app.sound:playSound("hero_breakthrough")

	local titleWidget = QUIWidgetTitelEffect.new()
	self._ccbOwner.node_title_effect:addChild(titleWidget)
	
    if options then
		self._sid = options.sid
		self._oldPropList = options.oldPropList
		self._nowPropList = options.nowPropList
		self._type = options.type
		self._callback = options.callback
	end

	self:_init()
end

function QUIDialogMagicHerbSuccess:viewDidAppear()
	QUIDialogMagicHerbSuccess.super.viewDidAppear(self)
end

function QUIDialogMagicHerbSuccess:viewWillDisappear()
	QUIDialogMagicHerbSuccess.super.viewWillDisappear(self)
end

function QUIDialogMagicHerbSuccess:_init()

	if self._type == 1 then
		self._ccbOwner.tf_title_old:setString("升星前")
		self._ccbOwner.tf_title_new:setString("升星后")
		self._ccbOwner.node_title_shengxing:setVisible(true)
		self._ccbOwner.node_title_zhuansheng:setVisible(false)
		local magicHerbItemInfo = remote.magicHerb:getMaigcHerbItemBySid(self._sid)
		local nowGrade = magicHerbItemInfo.grade
		local box1 = QUIWidgetMagicHerbBox.new()
		box1:setInfo(self._sid)
		box1:hideName()
		self._ccbOwner.node_icon1:addChild(box1)
		local box2 = QUIWidgetMagicHerbBox.new()
		box2:setInfo(self._sid)
		box2:hideName()
		self._ccbOwner.node_icon2:addChild(box2)
		box1:setStarNum(nowGrade - 1)
	else
		self._ccbOwner.tf_title_old:setString("转生前")
		self._ccbOwner.tf_title_new:setString("转生后")
		self._ccbOwner.node_title_shengxing:setVisible(false)
		self._ccbOwner.node_title_zhuansheng:setVisible(true)
		local box1 = QUIWidgetMagicHerbBox.new()
		box1:setInfo(self._sid)
		box1:hideName()
		self._ccbOwner.node_icon:addChild(box1)
		self._ccbOwner.sp_arrow:setVisible(false)
	end

	if self._nowPropList then
		local line = 10
		if #self._nowPropList > 2 then
			line = 4
		end
		if self._nowPropTf == nil then
	        self._nowPropTf = QRichText.new(nil, nil, {lineSpacing=line})
	        self._nowPropTf:setAnchorPoint(ccp(0, 0.5))
	        self._ccbOwner.node_prop_new:addChild(self._nowPropTf)
	    end

	    local nowPropTfConfig = {}
	   
		for _, value in ipairs(self._nowPropList) do
			local str = value.name.."："..(value.num or value.value)
			if value.isMax then
				str = str.."（满）"
			end
			local color = value.color and COLORS[value.color] or COLORS.p
			local strokeColor = getShadowColorByFontColor(color)
		 	table.insert(nowPropTfConfig, {oType = "font", content = str, size = 20, color = color, strokeColor = strokeColor})
        	table.insert(nowPropTfConfig, {oType = "wrap"})
		end

		self._nowPropTf:setString(nowPropTfConfig)
	end

	if self._oldPropList then
		local line = 10
		if #self._oldPropList > 2 then
			line = 4
		end

		if self._oldPropTf == nil then
	        self._oldPropTf = QRichText.new(nil, nil, {lineSpacing=line})
	        self._oldPropTf:setAnchorPoint(ccp(0, 0.5))
	        self._ccbOwner.node_prop_old:addChild(self._oldPropTf)
	    end

	    local oldPropTfConfig = {}
	   
		for _, value in ipairs(self._oldPropList) do
			local str = value.name.."："..(value.num or value.value)
			if value.isMax then
				str = str.."（满）"
			end
			local color = value.color and COLORS[value.color] or COLORS.p
			local strokeColor = getShadowColorByFontColor(color)
		 	table.insert(oldPropTfConfig, {oType = "font", content = str, size = 20, color = color, strokeColor = strokeColor})
        	table.insert(oldPropTfConfig, {oType = "wrap"})
		end

		self._oldPropTf:setString(oldPropTfConfig)
	end
end

function QUIDialogMagicHerbSuccess:_getPropList( prop, refineId )
	local tbl = {}
	if prop then
		for _, value in pairs(prop) do
			local key = value.attribute
			local num = value.refineValue
			if QActorProp._field[key] then
				local color, isMax = remote.magicHerb:getRefineValueColorAndMax(key, num, refineId)
				local name = QActorProp._field[key].uiName or QActorProp._field[key].name
				num = q.getFilteredNumberToString(num, QActorProp._field[key].isPercent, 2)		
				table.insert(tbl, {name = name, num = num, color = color, isMax = isMax})
			end
		end
	end

	return tbl
end

function QUIDialogMagicHerbSuccess:_backClickHandler()
    self:_onTriggerClose()
end

function QUIDialogMagicHerbSuccess:_onTriggerClose()
	app.sound:playSound("common_cancel")
	self:playEffectOut()
end

function QUIDialogMagicHerbSuccess:viewAnimationOutHandler()
	self:popSelf()

	if self._callback then
		self._callback()
	end
end

return QUIDialogMagicHerbSuccess