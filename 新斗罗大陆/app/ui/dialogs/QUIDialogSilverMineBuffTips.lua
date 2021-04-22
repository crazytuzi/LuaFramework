--
-- Author: Kumo.Wang
-- Date: Tue July 12 18:30:36 2016
-- 魂兽森林tips
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogSilverMineBuffTips = class("QUIDialogSilverMineBuffTips", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QScrollView = import("...views.QScrollView") 
local QStaticDatabase = import("...controllers.QStaticDatabase")

function QUIDialogSilverMineBuffTips:ctor(options)
 	local ccbFile = "ccb/Dialog_SilverMine_BuffTips.ccbi"
    local callBacks = {}
    QUIDialogSilverMineBuffTips.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true --是否动画显示

    -- if options.type == LORD_TYPE.SELF then
    -- 	self:getChildView():setPosition(options.x + 55, options.y + 30)
    -- else
    -- 	self:getChildView():setPosition(options.x + 95, options.y + 30)
    -- end
    
    self._bgSize = self._ccbOwner.s9s_bg:getContentSize()
    self._bgPositionY = self._ccbOwner.s9s_bg:getPositionY()
    self._mineId = options.mineId

    self:_init()
end

function QUIDialogSilverMineBuffTips:_backClickHandler()
    self:_onTriggerClose()
end

-- 关闭对话框
function QUIDialogSilverMineBuffTips:_onTriggerClose()
    self:playEffectOut()
end

function QUIDialogSilverMineBuffTips:viewAnimationOutHandler()
    app:getNavigationManager():popViewController(app.topLayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogSilverMineBuffTips:viewWillDisappear()
	QUIDialogSilverMineBuffTips.super.viewWillDisappear(self)

	if self._goldPickaxeScheduler then
		scheduler.unscheduleGlobal(self._goldPickaxeScheduler)
		self._goldPickaxeScheduler = nil
	end
end

function QUIDialogSilverMineBuffTips:_init()
	self:_updateInfo()
end

function QUIDialogSilverMineBuffTips:_updateInfo()
	self._titleStr = ""
	local caveId = remote.silverMine:getCaveIdByMineId( self._mineId )
	self._myConsortiaId = nil
	self._level = nil
	self._ownerConsortiaId = nil
	local lordType = remote.silverMine:getLordTypeByMineId( self._mineId )
	self._offsetY = 0
	if lordType == LORD_TYPE.SELF then
		self._isMine = true
		self._titleStr = "我的"
	elseif lordType == LORD_TYPE.NORMAL or lordType == LORD_TYPE.SOCIETY then
		self._isMine = true
		self._titleStr = "当前"
		local otherPlayerSilverMine = remote.silverMine:getOtherPlayerSilverMine() or {}
		local otherPlayerOccupy = remote.silverMine:getOtherPlayerOccupy()
		self._level = otherPlayerSilverMine.miningLv or 1
		self._ownerConsortiaId = otherPlayerOccupy.consortiaId
	else
		self._isMine = false
		self._titleStr = "预计"
		self._myConsortiaId = remote.silverMine:getMyConsortiaId()
	end

-----------------------------------------------------------------------------------------------------------------------------

	local mineConfig = remote.silverMine:getMineConfigByMineId( self._mineId )
	local name = remote.silverMine:getMineCNNameByQuality(mineConfig.mine_quality)
	self._ccbOwner.tf_base_title:setString(name.."基础产量(10分钟) :")

	local moneyOutputBase, silverMineMoneyOutputBase = remote.silverMine:getBaseOutputByMineId( self._mineId )
	self._ccbOwner.tf_base_money_output:setString( moneyOutputBase )
	self._ccbOwner.tf_base_silvermineMoney_output:setString( silverMineMoneyOutputBase )

-----------------------------------------------------------------------------------------------------------------------------
	
	local isBuff, member = remote.silverMine:getSocietyBuffInfoByCaveId( caveId, self._myConsortiaId, self._mineId )
	local moneyOutputSocietyUp, silverMineMoneyOutputSocietyUp = remote.silverMine:getSocietyBuff( self._mineId, self._myConsortiaId, self._ownerConsortiaId )
	if isBuff and moneyOutputSocietyUp ~= 0 and silverMineMoneyOutputSocietyUp ~= 0 then
		self._ccbOwner.tf_societyBuff_title:setString(self._titleStr.."宗门加成("..member.."人) :")
		self._ccbOwner.tf_society_money_buff:setString( moneyOutputSocietyUp )
		self._ccbOwner.tf_society_silvermineMoney_buff:setString( silverMineMoneyOutputSocietyUp )
		self._ccbOwner.node_society:setVisible(true)
	else
		self._offsetY = self._offsetY + 34
		self._ccbOwner.tf_societyBuff_title:setString(self._titleStr.."没有宗门加成 :")
		self._ccbOwner.tf_society_money_buff:setString( 0 )
		self._ccbOwner.tf_society_silvermineMoney_buff:setString( 0 )
		self._ccbOwner.node_society:setVisible(false)
	end

-----------------------------------------------------------------------------------------------------------------------------

	local moneyOutputLevelup, silverMineMoneyOutputLevelup = remote.silverMine:getLevelBuff( self._level )
	self._ccbOwner.tf_levelBuff_title:setString(self._titleStr.."等级加成(LV. "..(self._level or remote.silverMine:getMiningLv())..") :")
	self._ccbOwner.tf_level_money_buff:setString( (moneyOutputLevelup * 100).."%" )
	self._ccbOwner.tf_level_silvermineMoney_buff:setString( (silverMineMoneyOutputLevelup * 100).."%" )
	self._ccbOwner.node_level:setPositionY(self._offsetY)

-----------------------------------------------------------------------------------------------------------------------------

    local occupy = remote.silverMine:getMineOccupyInfoByMineID(self._mineId)
    local assistCount = 0
    local moneyOutputAssistUp = 0
    local silverMineMoneyOutputAssitUp = 0
    if occupy ~= nil then
		self._ccbOwner.node_assist:setVisible(true)
	    assistCount = #(occupy.assistUserInfo or {})
	end
	if assistCount > 0 then
		moneyOutputAssistUp,silverMineMoneyOutputAssitUp = remote.silverMine:getAssistBuff(assistCount)
		self._ccbOwner.tf_assistBuff_title:setString(self._titleStr.."协助加成("..assistCount.."人) :")
		self._ccbOwner.tf_assist_money_buff:setString( (moneyOutputAssistUp * 100).."%" )
		self._ccbOwner.tf_assist_silvermineMoney_buff:setString( (silverMineMoneyOutputAssitUp * 100).."%" )
	else
		self._ccbOwner.node_assist:setVisible(false)
		self._offsetY = self._offsetY + 34
	end
	self._ccbOwner.node_assist:setPositionY(self._offsetY)	

-----------------------------------------------------------------------------------------------------------------------------

	local isOvertime = false
	local timeStr = "00:00:00"
	if not self._isMine then
		isOvertime, timeStr = remote.silverMine:updateGoldPickaxeTime(true)
	else
		isOvertime, timeStr = remote.silverMine:updateGoldPickaxeTime(nil, self._mineId)
	end
	if isOvertime then
		self._ccbOwner.node_goldPickaxe:setVisible(false)
		self._offsetY = self._offsetY + 34
	else
		local buff = QStaticDatabase.sharedDatabase():getConfigurationValue("huangjinkuanggao_buff")
		self._goldPickaxeBuff = (buff * 100).."%"
		if self._goldPickaxeScheduler then
			scheduler.unscheduleGlobal(self._goldPickaxeScheduler)
			self._goldPickaxeScheduler = nil
		end
		self:_updateGoldPickaxeTime()
		self._goldPickaxeScheduler = scheduler.scheduleGlobal(self:safeHandler(function() 
				self:_updateGoldPickaxeTime()
			end), 1)
		self._ccbOwner.node_goldPickaxe:setVisible(true)
	end

	self._ccbOwner.node_goldPickaxe:setPositionY(self._offsetY)	

-----------------------------------------------------------------------------------------------------------------------------

	self:_updateOutput()
end

function QUIDialogSilverMineBuffTips:_updateGoldPickaxeTime()
	local isOvertime = false
	local timeStr = "00:00:00"
	if not self._isMine then
		isOvertime, timeStr = remote.silverMine:updateGoldPickaxeTime(true)
	else
		isOvertime, timeStr = remote.silverMine:updateGoldPickaxeTime(nil, self._mineId)
	end
	if isOvertime then
		self._ccbOwner.tf_goldPickaxeBuff_title:setString(self._titleStr.."诱魂草加成(00:00:00) :")
		self._ccbOwner.tf_goldPickaxe_money_buff:setString("0%")
		self._ccbOwner.tf_goldPickaxe_silvermineMoney_buff:setString("0%")

		self:_updateOutput()

		if self._goldPickaxeScheduler then
			scheduler.unscheduleGlobal(self._goldPickaxeScheduler)
			self._goldPickaxeScheduler = nil
		end
	else
		self._ccbOwner.tf_goldPickaxeBuff_title:setString(self._titleStr.."诱魂草加成("..timeStr..") :")
		self._ccbOwner.tf_goldPickaxe_money_buff:setString( self._goldPickaxeBuff )
		self._ccbOwner.tf_goldPickaxe_silvermineMoney_buff:setString( self._goldPickaxeBuff )
	end
end

function QUIDialogSilverMineBuffTips:_updateOutput()
	local moneyOutput, silverMineMoneyOutput = remote.silverMine:getOutPutByMineId( self._mineId, self._myConsortiaId, self._level, self._ownerConsortiaId, not self._isMine )
	moneyOutput = math.floor(moneyOutput)
	silverMineMoneyOutput = math.floor(silverMineMoneyOutput)
	self._ccbOwner.tf_output_title:setString(self._titleStr.."每10分钟产量 :")
	self._ccbOwner.tf_money_output:setString( moneyOutput )
	self._ccbOwner.tf_silvermineMoney_output:setString( silverMineMoneyOutput )

-----------------------------------------------------------------------------------------------------------------------------
	
	self._ccbOwner.tf_all_output_title:setString(self._titleStr.."8小时产量 :")
	local numMoney, unitMoney = q.convertLargerNumber( moneyOutput * 48 )
	self._ccbOwner.tf_all_money_output:setString( numMoney..(unitMoney or "") )
	local numSilvermineMoney, unitSilvermineMoney = q.convertLargerNumber( silverMineMoneyOutput * 48 )
	self._ccbOwner.tf_all_silvermineMoney_output:setString( numSilvermineMoney..(unitSilvermineMoney or "") )

	self._ccbOwner.node_others:setPositionY(self._offsetY)
	self._ccbOwner.s9s_bg:setPreferredSize(CCSize(self._bgSize.width, self._bgSize.height - self._offsetY))
	self._ccbOwner.sp_title:setPositionX(self._ccbOwner.s9s_bg:getPositionX() + self._bgSize.width/2)
end

return QUIDialogSilverMineBuffTips