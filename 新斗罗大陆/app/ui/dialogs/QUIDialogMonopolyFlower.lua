--
-- Author: Kumo.Wang
-- 大富翁仙品种植主界面
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMonopolyFlower = class("QUIDialogMonopolyFlower", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QUIViewController = import("..QUIViewController")
local QQuickWay = import("...utils.QQuickWay")

function QUIDialogMonopolyFlower:ctor(options)
	local ccbFile = "ccb/Dialog_monopoly_plant.ccbi"
	local callBack = {
        {ccbCallbackName = "onTriggerOK", callback = handler(self, self._onTriggerOK)},
        {ccbCallbackName = "onTriggerClose", callback = handler(self, self._onTriggerClose)},
	}
	QUIDialogMonopolyFlower.super.ctor(self, ccbFile, callBack, options)

	self._ccbOwner.frame_tf_title:setString("仙品种植")

	q.setButtonEnableShadow(self._ccbOwner.btn_ok)
	self._flowerId = options.flowerId or 1

    self:resetAll()
end

function QUIDialogMonopolyFlower:viewDidAppear()
	QUIDialogMonopolyFlower.super.viewDidAppear(self)
end

function QUIDialogMonopolyFlower:viewWillDisappear()
	QUIDialogMonopolyFlower.super.viewWillDisappear(self)
end

function QUIDialogMonopolyFlower:resetAll()
	local curConfig, nextConfig = remote.monopoly:getFlowerCurAndNextConfigById(self._flowerId)
	self._ccbOwner.tf_flowerName:setString(curConfig.name)
	self._ccbOwner.tf_flowerDesc:setString(curConfig.description)

	local path = curConfig.picture
	local sp = self._ccbOwner.sp_plants
	if path and sp then
		local frame = QSpriteFrameByPath(path)
		sp:setDisplayFrame(frame)
	end

	local immortalInfos = remote.monopoly.monopolyInfo.immortalInfos or {}
	local exp = 0
	if immortalInfos[tonumber(self._flowerId)] then
		exp = immortalInfos[tonumber(self._flowerId)].exp or 0
		self._ccbOwner.tf_level:setString(immortalInfos[tonumber(self._flowerId)].level or 1)
		self._ccbOwner.tf_actionType:setString("培养需要：")
		self._ccbOwner.tf_btnOK:setString("培  养")
		self._actionType = 2
	else
		self._ccbOwner.tf_level:setString("未种植")
		self._ccbOwner.tf_actionType:setString("种植需要：")
		self._ccbOwner.tf_btnOK:setString("种  植")
		self._actionType = 1
	end

	local curLuckyDrawConfig = remote.monopoly:getLuckyDrawByKey(curConfig.good)
	self:setWalletIcon(self._ccbOwner.sp_curIcon, curLuckyDrawConfig)
	self._ccbOwner.tf_curOutput:setString(string.format("%0.1f",(curLuckyDrawConfig.num_1 * curConfig.num * 60)).."/小时")

	if nextConfig then
		self._ccbOwner.tf_exp:setString( exp.."/"..nextConfig.exp)
		self._ccbOwner.sp_nextIcon:setVisible(true)
		self._ccbOwner.tf_nextOutput:setVisible(true)
		local nextLuckyDrawConfig = remote.monopoly:getLuckyDrawByKey(nextConfig.good)
		self:setWalletIcon(self._ccbOwner.sp_nextIcon, nextLuckyDrawConfig)
		self._ccbOwner.tf_nextOutput:setString(string.format("%0.1f",(nextLuckyDrawConfig.num_1 * nextConfig.num * 60)).."/小时")
		self._ccbOwner.node_nextOutput:setVisible(true)
		self._ccbOwner.node_curOutput:setPositionY(-25)
		self._ccbOwner.btn_ok:setEnabled(true)
		makeNodeFromGrayToNormal(self._ccbOwner.node_btn)
	else
		self._ccbOwner.tf_exp:setString("已满级")
		self._ccbOwner.sp_nextIcon:setVisible(false)
		self._ccbOwner.tf_nextOutput:setVisible(false)
		self._ccbOwner.node_nextOutput:setVisible(false)
		self._ccbOwner.node_curOutput:setPositionY(-45)
		self._ccbOwner.btn_ok:setEnabled(false)
		makeNodeFromNormalToGray(self._ccbOwner.node_btn)
	end

	self._ccbOwner.tf_price:setString("x0")
	if curConfig.cost then
		local tbl = string.split(curConfig.cost, ",")
		self._costItemId = tbl[1]
		self._costItemCount = tbl[2]
		self:setItemIcon(self._ccbOwner.sp_price, tbl[1])
		self._ccbOwner.tf_price:setString("x"..tbl[2].."（"..remote.items:getItemsNumByID(self._costItemId).."）")
	end
end

function QUIDialogMonopolyFlower:setWalletIcon(sp, config)

	local setIcon = function( path)
		local frame = QSpriteFrameByPath(path)
		if frame then
			sp:setDisplayFrame(frame)
		end
	end

	local resourceConfig = remote.items:getWalletByType(config.type_1)
	if q.isEmpty(resourceConfig) == false then
		-- local path = resourceConfig.alphaIcon
		setIcon(resourceConfig.alphaIcon)
	else
		local itemInfo = db:getItemByID(config.id_1)
		if itemInfo then
			setIcon(itemInfo.icon_1)
		end
		
	end
end

function QUIDialogMonopolyFlower:setItemIcon(sp, itemId)
	local path = remote.items:getURLForId(itemId, "icon_1")
	local frame = QSpriteFrameByPath(path)
	if frame then
		sp:setDisplayFrame(frame)
	end
end

function QUIDialogMonopolyFlower:_onTriggerOK()
    app.sound:playSound("common_small")
    if remote.items:getItemsNumByID(self._costItemId) >= tonumber(self._costItemCount) then
		local oldImmortalInfo = clone(remote.monopoly.monopolyInfo.immortalInfos or {})
    	local actionType = self._actionType
    	local flowerId = self._flowerId

	    remote.monopoly:monopolyPlantRequest(self._flowerId, function(data)
	    		self:_onTriggerClose()

	    		local newImmortalInfo = remote.monopoly.monopolyInfo.immortalInfos or {}
		        app:getNavigationManager():pushViewController(app.middleLayer, {uiType=QUIViewController.TYPE_DIALOG, uiClass="QUIDialogMonopolyFlowerUpgrade",
		        	options = {actionType = actionType, newImmortalInfo = newImmortalInfo[tonumber(flowerId)], oldImmortalInfo = oldImmortalInfo[tonumber(flowerId)], flowerId = flowerId}})
	    	end)
	else
		-- 注意，这次需要再跳转到充值界面前，先把这个界面pop掉，不然当充值返回的时候，由于当前界面已经在列表里了，再次调用pushViewController会直接关闭
		-- QQuickWay:addQuickWay(QQuickWay.TOKEN_DROP_WAY, nil, nil, function()
		-- 		self:_onTriggerClose()
		-- 	end)
		QQuickWay:addQuickWay(QQuickWay.ITEM_DROP_WAY, self._costItemId)
	end
end

function QUIDialogMonopolyFlower:_onTriggerClose(e)
	if q.buttonEventShadow(e, self._ccbOwner.frame_btn_close) == false then return end
    if e then
        app.sound:playSound("common_small")
		remote.monopoly:monopolyPlantRequest(0)
    end
	self:popSelf()
end

return QUIDialogMonopolyFlower