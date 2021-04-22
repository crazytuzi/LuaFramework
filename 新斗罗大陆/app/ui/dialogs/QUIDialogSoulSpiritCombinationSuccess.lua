-- @Author: zhouxiaoshu
-- @Date:   2019-06-18 15:42:08
-- @Last Modified by:   xurui
-- @Last Modified time: 2020-01-21 17:08:48

local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSoulSpiritCombinationSuccess = class("QUIDialogSoulSpiritCombinationSuccess", QUIDialog)
local QStaticDatabase = import("...controllers.QStaticDatabase")
local QUIWidgetSoulSpiritHead = import("..widgets.QUIWidgetSoulSpiritHead")
local QActorProp = import("...models.QActorProp")
local QUIWidgetTitelEffect = import("..widgets.QUIWidgetTitelEffect")

function QUIDialogSoulSpiritCombinationSuccess:ctor(options)
	local ccbFile = "ccb/Dialog_SoulSpirit_hunlingjihuo_12.ccbi"
	local callBacks = {
	}
	QUIDialogSoulSpiritCombinationSuccess.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true --是否动画显示
	app.sound:playSound("task_complete")

	local titleWidget = QUIWidgetTitelEffect.new()
	self._ccbOwner.node_title_effect:addChild(titleWidget)

    self._callBack = options.callback
    local grade = options.grade
    local combination = remote.soulSpirit:getCombinationByIdAndGrade(options.combinationId, grade)
    local soulSpiritIds = self:getSoulSpiritIds(combination)

    local soulSpiritConfig1 = db:getCharacterByID(soulSpiritIds[1])
	self._ccbOwner.tf_name_1:setString(soulSpiritConfig1.name)
	
	local soulSpiritInfo = remote.soulSpirit:getMySoulSpiritHistoryInfoById(soulSpiritIds[1])
	local soulSpiritInfo1 = {
		id = soulSpiritInfo.id,
		level = soulSpiritInfo.level;
		grade = grade - 1,
	}
	local soulSpiritBox1 = QUIWidgetSoulSpiritHead.new()
    soulSpiritBox1:setInfo(soulSpiritInfo1)
	self._ccbOwner.node_hero_1:addChild(soulSpiritBox1)

	if #soulSpiritIds > 1 then
		local soulSpiritConfig2 = db:getCharacterByID(soulSpiritIds[2])
		self._ccbOwner.tf_name_2:setString(soulSpiritConfig2.name)

		local soulSpiritInfo = remote.soulSpirit:getMySoulSpiritHistoryInfoById(soulSpiritIds[2])
		local soulSpiritInfo2 = {
			id = soulSpiritInfo.id,
			level = soulSpiritInfo.level;
			grade = grade - 1,
		}
		local soulSpiritBox2 = QUIWidgetSoulSpiritHead.new()
	    soulSpiritBox2:setInfo(soulSpiritInfo2)
		self._ccbOwner.node_hero_2:addChild(soulSpiritBox2)
	else
		self._ccbOwner.sp_add:setVisible(false)
		self._ccbOwner.node1:setPositionX(0)
		self._ccbOwner.node2:setVisible(false)
	end



	local propList = self:calculateCombinationProp(combination)
	local index = 1
	while true do
		local tf = self._ccbOwner["tf_prop"..index]
		if tf then
			tf:setVisible(false)
			index = index + 1
		else
			break
		end
	end
	for i, v in ipairs(propList) do
		local tf = self._ccbOwner["tf_prop"..i]
		if tf then
			tf:setString(v.str)
			tf:setVisible(true)
		end
	end

	local nameStr = string.format("%s LV.%d", combination.name, combination.grade)
	self._ccbOwner.tf_name:setString(nameStr)

    if grade == 1 then
    	self._ccbOwner.sp_actice:setVisible(true)
    	self._ccbOwner.sp_upgrade:setVisible(false)
    	self._ccbOwner.tf_desc:setString("获得以上魂灵激活图鉴：")
    else
    	self._ccbOwner.sp_actice:setVisible(false)
    	self._ccbOwner.sp_upgrade:setVisible(true)
    	self._ccbOwner.tf_desc:setString("图鉴升级获得下级效果：")
    end

	self._playOver = false
	scheduler.performWithDelayGlobal(function ()
		self._playOver = true
	end, 2)
end

function QUIDialogSoulSpiritCombinationSuccess:getSoulSpiritIds(combination)
	local conditionTbl = string.split(combination.condition, ";")
	local soulSpiritIds = {}
	for _, spiritInfo in pairs(conditionTbl) do
        local spiritInfoTbl = string.split(spiritInfo, "^")
        table.insert(soulSpiritIds, tonumber(spiritInfoTbl[1]))
    end
    return soulSpiritIds
end

function QUIDialogSoulSpiritCombinationSuccess:calculateCombinationProp(combination)
	local propList = {}

	for key, value in pairs(combination) do
		if QActorProp._field[key] then
            local name = QActorProp._field[key].uiName or QActorProp._field[key].name
            local isPercent = QActorProp._field[key].isPercent
            local valueStr = q.getFilteredNumberToString(value, isPercent, 1)
            table.insert(propList, {num = value, str = name.." +"..valueStr})
		end
	end
	table.sort(propList, function(a, b)
			return a.num < b.num
		end)
	return propList
end


function QUIDialogSoulSpiritCombinationSuccess:_backClickHandler()
	if self._playOver == true then
		if self._callBack ~= nil then
			self._callBack()
		end
		self:playEffectOut()
	end
end

return QUIDialogSoulSpiritCombinationSuccess
