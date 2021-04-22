
local QUIWidget = import("...widgets.QUIWidget")
local QUIWidgetUnionDragonTrainPersonalRank = class("QUIWidgetUnionDragonTrainPersonalRank", QUIWidget)
local QUIWidgetAvatar = import("...widgets.QUIWidgetAvatar")

function QUIWidgetUnionDragonTrainPersonalRank:ctor(options)
	local ccbFile = "ccb/Widget_society_dragontrain_paihang4.ccbi"
	local callBack = {
		{ccbCallbackName = "onTriggerClickHead", callback = handler(self, self._onTriggerClickHead)}
	}
	QUIWidgetUnionDragonTrainPersonalRank.super.ctor(self, ccbFile, callBack, options)

end

function QUIWidgetUnionDragonTrainPersonalRank:getContentSize()
	return self._ccbOwner.normal_banner:getContentSize()
end

function QUIWidgetUnionDragonTrainPersonalRank:setInfo(data, isShow)
	self._ccbOwner.first:setVisible(data.rank == 1)
	self._ccbOwner.second:setVisible(data.rank == 2)
	self._ccbOwner.third:setVisible(data.rank == 3)
	self._ccbOwner.other:setVisible(data.rank > 3)
	self._ccbOwner.other:setString(data.rank)
	self._ccbOwner.tf_level:setString("LV."..data.level)
	self._ccbOwner.tf_name:setString(data.name)

	if isShow then
		self._ccbOwner.node_self:setVisible(data.consortiaId == remote.user.userConsortia.consortiaId)
		self._ccbOwner.node_enemy:setVisible(data.consortiaId ~= remote.user.userConsortia.consortiaId)
	else
		self._ccbOwner.node_self:setVisible(false)
		self._ccbOwner.node_enemy:setVisible(false)
	end

	local num,unit = q.convertLargerNumber(data.todayHurt)
	local str = num..unit
	if data.fightCount and data.fightCount ~= 0 and isShow then
		str = str.." (共"..data.fightCount.."次)"
	end
	self._ccbOwner.tf_value1:setString(str)

	print("data.force",data.force)
	
	if data.force and data.force == 0 then
		self._ccbOwner.tf_force_value:setString("受魂力波动影响未知")
	elseif data.force and data.force > 0 then
		local num, str = q.convertLargerNumber(math.floor(data.force))
		print("num,str",num,str)
		self._ccbOwner.tf_force_value:setString(num..(str or ""))
	else
		self._ccbOwner.tf_force_value:setString(data.force or "受魂力波动影响未知")
	end

	self._ccbOwner.tf_vip:setString("VIP"..(data.vip or "0"))

	-- local envName = data.game_area_name 
	-- if envName == "" or envName == nil then
	-- 	envName = "熔岩之地（1服）"
	-- end
	--self._ccbOwner.tf_env_name:setString(envName or "")

	if self._avatar == nil then
		self._avatar = QUIWidgetAvatar.new()
		self._ccbOwner.node_icon:addChild(self._avatar)
	end
	self._avatar:setInfo(data.avatar)
	self._avatar:setSilvesArenaPeak(data.championCount)

	local nodes = {}
	table.insert(nodes, self._ccbOwner.tf_level)
	table.insert(nodes, self._ccbOwner.tf_name)
	table.insert(nodes, self._ccbOwner.tf_vip)

	if data.consortiaId == remote.user.userConsortia.consortiaId then
		table.insert(nodes, self._ccbOwner.node_self)
	else
		table.insert(nodes, self._ccbOwner.node_enemy)
	end
	q.autoLayerNode(nodes, "x", 5)
end

function QUIWidgetUnionDragonTrainPersonalRank:_onTriggerClickHead()
	-- app.sound:playSound("common_small")

	-- app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogPlayerInfo",
 --        options = {fighter = fighter, specialTitle1 = "今日伤害：", specialValue1 = fighter.victory, forceTitle = ""}}, {isPopCurrentDialog = false})
end

return QUIWidgetUnionDragonTrainPersonalRank