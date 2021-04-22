--
-- Author: Kumo.Wang
-- Date: Tue July 12 18:30:36 2016
-- 魂兽森林tips
--
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogPlunderBuffTips = class("QUIDialogPlunderBuffTips", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")

function QUIDialogPlunderBuffTips:ctor(options)
 	local ccbFile = "ccb/Dialog_plunder_buffTips.ccbi"
    local callBacks = {}
    QUIDialogPlunderBuffTips.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true --是否动画显示
    
    self._bgSize = self._ccbOwner.s9s_bg:getContentSize()
    self._mineId = options.mineId

    self:_init()
end

function QUIDialogPlunderBuffTips:_backClickHandler()
    self:_onTriggerClose()
end

-- 关闭对话框
function QUIDialogPlunderBuffTips:_onTriggerClose()
    self:playEffectOut()
end

function QUIDialogPlunderBuffTips:viewAnimationOutHandler()
    app:getNavigationManager():popViewController(app.topLayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogPlunderBuffTips:viewWillDisappear()
	QUIDialogPlunderBuffTips.super.viewWillDisappear(self)

	if self._goldPickaxeScheduler then
		scheduler.unscheduleGlobal(self._goldPickaxeScheduler)
		self._goldPickaxeScheduler = nil
	end
end

function QUIDialogPlunderBuffTips:_init()
	self:_updateInfo()
end

function QUIDialogPlunderBuffTips:_updateInfo()
	self._titleStr = ""
	local caveId = remote.plunder:getCaveIdByMineId( self._mineId )
	self._myConsortiaId = nil
	self._ownerConsortiaId = nil
	local lordType = remote.plunder:getLordTypeByMineId( self._mineId )
	self._offsetY = 0
	if lordType == LORD_TYPE.SELF then
		self._titleStr = "我的"
	elseif lordType == LORD_TYPE.NORMAL or lordType == LORD_TYPE.SOCIETY then
		self._titleStr = "当前"
		local mineInfo = remote.plunder:getMineInfoByMineId( self._mineId )
		self._ownerConsortiaId = mineInfo.consortiaId
	else
		self._titleStr = "预计"
		self._myConsortiaId = remote.plunder:getMyConsortiaId()
	end

-----------------------------------------------------------------------------------------------------------------------------

	local mineConfig = remote.plunder:getMineConfigByMineId( self._mineId )
	local name = remote.plunder:getMineCNNameByQuality(mineConfig.mine_quality)
	self._ccbOwner.tf_base_title:setString(name.."产量（10分钟）：")

	local scoreOutputBase = remote.plunder:getBaseOutputByMineId( self._mineId )
	self._ccbOwner.tf_base_score_output:setString( scoreOutputBase )

-----------------------------------------------------------------------------------------------------------------------------
	
	local isBuff, member = remote.plunder:getSocietyBuffInfoByCaveId( caveId, self._myConsortiaId, self._mineId )
	local scoreOutputSocietyUp = remote.plunder:getSocietyBuff( self._mineId, self._myConsortiaId, self._ownerConsortiaId )
	if isBuff and scoreOutputSocietyUp ~= 0 then
		self._ccbOwner.tf_societyBuff_title:setString(self._titleStr.."宗门加成（ "..member.." 人 ）：")
		self._ccbOwner.tf_society_score_buff:setString( scoreOutputSocietyUp )
		self._ccbOwner.node_society:setVisible(true)
	else
		self._offsetY = self._offsetY + 34
		self._ccbOwner.tf_societyBuff_title:setString(self._titleStr.."没有宗门加成：")
		self._ccbOwner.tf_society_score_buff:setString( 0 )
		self._ccbOwner.node_society:setVisible(false)
	end

-----------------------------------------------------------------------------------------------------------------------------

	self:_updateOutput()
end

function QUIDialogPlunderBuffTips:_updateOutput()
	local scoreOutput = remote.plunder:getOutPutByMineId( self._mineId, self._myConsortiaId, self._ownerConsortiaId )
	scoreOutput = math.floor(scoreOutput)
	self._ccbOwner.tf_output_title:setString(self._titleStr.."每10分钟产量：")
	self._ccbOwner.tf_score_output:setString( scoreOutput )

-----------------------------------------------------------------------------------------------------------------------------
	
	self._ccbOwner.tf_all_output_title:setString(self._titleStr.."10小时总产量：")
	local numScore, unitScore = q.convertLargerNumber( scoreOutput * 60 )
	self._ccbOwner.tf_all_score_output:setString( numScore..(unitScore or "") )

	self._ccbOwner.node_others:setPositionY(90 + self._offsetY)
	self._ccbOwner.s9s_bg:setPreferredSize(CCSize(self._bgSize.width, self._bgSize.height - self._offsetY))
end

return QUIDialogPlunderBuffTips