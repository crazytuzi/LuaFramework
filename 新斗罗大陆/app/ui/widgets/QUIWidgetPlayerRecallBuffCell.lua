local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetPlayerRecallBuffCell = class("QUIWidgetPlayerRecallBuffCell", QUIWidget)

local QUIWidgetQlistviewItem = import(".QUIWidgetQlistviewItem")
local QUIWidgetItemsBox = import("...widgets.QUIWidgetItemsBox")
local QUIViewController = import("...ui.QUIViewController")
local QListView = import("...views.QListView")

function QUIWidgetPlayerRecallBuffCell:ctor(options)
	local ccbFile = "ccb/Widget_playerRecall_buff.ccbi"
	local callBacks = {
		-- {ccbCallbackName = "onTriggerOK", callback = handler(self, self._onTriggerOK)},
		-- {ccbCallbackName = "onTriggerGo", callback = handler(self, self._onTriggerGo)},
    }
	QUIWidgetPlayerRecallBuffCell.super.ctor(self, ccbFile, callBack, options)
end

function QUIWidgetPlayerRecallBuffCell:getContentSize()
	return self._ccbOwner.node_size:getContentSize()
end

function QUIWidgetPlayerRecallBuffCell:setInfo(info)
	if not info or next(info) == nil then return end

	local index = 1
	while true do
		local node = self._ccbOwner["node_"..index]
		if node then
			if index == info.type then
				self._type = info.type
				node:setVisible(true)
			else
				node:setVisible(false)
			end
			index = index + 1
		else
			break
		end
	end
	if not self._type then return end

	local str = ""
	if info.desc then
		str = info.desc
	else
		if info.type == 1 then
			str = "收益增加"
		elseif info.type == 2 then
			str = "伤害增加"
		elseif info.type == 3 then
			str = "伤害增加"
		elseif info.type == 4 then
			str = "收益增加"
		end
		str = str..info.buff_num.."%"
	end
	self._ccbOwner.tf_buff:setString(str)
end

function QUIWidgetPlayerRecallBuffCell:onTriggerOK()
	if not self._type then return end
    -- app.sound:playSound("common_small")
    if self._type == 1 then
    	self:_onTriggerBlackRock()
    elseif self._type == 2 then
    	self:_onTriggerUnionFuBen()
    elseif self._type == 3 then
    	self:_onTriggerUnionDragonWar()
    elseif self._type == 4 then
    	self:_onTriggerUnionBuilding()
    end
end

--传灵塔
function QUIWidgetPlayerRecallBuffCell:_onTriggerBlackRock()
	-- app.sound:playSound("common_small")
	remote.blackrock:openDialog()
end

--巨龙之战
function QUIWidgetPlayerRecallBuffCell:_onTriggerUnionDragonWar()
    -- app.sound:playSound("common_small")
    if next(remote.union.consortia) == nil then
		app.tip:floatTip("尚未加入宗门")
		return
	end
	remote.unionDragonWar:openDragonWarDialog()
end

--宗门副本
function QUIWidgetPlayerRecallBuffCell:_onTriggerUnionFuBen()
    -- app.sound:playSound("common_small")
    if not ENABLE_UNION_DUNGEON then
		app.tip:floatTip("暂未开启，敬请期待")
		return
	end
	if next(remote.union.consortia) == nil then
		app.tip:floatTip("尚未加入宗门")
		return
	end

	local needLevel = remote.union:getSocietyNeedLevel()
	if remote.union.consortia and remote.union.consortia.level and remote.union.consortia.level >= needLevel then
		remote.union:unionGetBossListRequest(function ( response )
			app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSocietyMap", 
				options = {}}, {isPopCurrentDialog = true})
		end, function ( response )
			app.tip:floatTip("无法获取实时BOSS信息，请检查下当前网络是否稳定。")
		end)
	else
		app.tip:floatTip("宗门"..needLevel.."级开启宗门副本")
	end
end

--宗门捐献
function QUIWidgetPlayerRecallBuffCell:_onTriggerUnionBuilding()
    -- app.sound:playSound("common_small")
    if next(remote.union.consortia) == nil then
		app.tip:floatTip("尚未加入宗门")
		return
	end
	app:getNavigationManager():pushViewController(app.mainUILayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogUnionBuilding", 
        options = {}}, {isPopCurrentDialog = true})
end

return QUIWidgetPlayerRecallBuffCell