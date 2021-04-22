--
-- zxs
-- 精英赛8强
--

local QUIWidget = import("..QUIWidget")
local QUIWidgetSanctuaryBetRecord = class("QUIWidgetSanctuaryBetRecord", QUIWidget)
local QUIWidgetSanctuaryPageGroup = import("..sanctuary.QUIWidgetSanctuaryPageGroup")
local QUIWidgetAvatar = import("..QUIWidgetAvatar")
local QUIViewController = import("....ui.QUIViewController")

function QUIWidgetSanctuaryBetRecord:ctor(options)
	local ccbFile = "ccb/Widget_Sanctuary_record.ccbi"
	local callBacks = {
        {ccbCallbackName = "onTriggerShow", callback = handler(self, self._onTriggerShow)},
	}
	QUIWidgetSanctuaryBetRecord.super.ctor(self,ccbFile,callBacks,options)
end

function QUIWidgetSanctuaryBetRecord:onEnter()
	QUIWidgetSanctuaryBetRecord.super.onEnter(self)
end

function QUIWidgetSanctuaryBetRecord:onExit()
	QUIWidgetSanctuaryBetRecord.super.onExit(self)
end

function QUIWidgetSanctuaryBetRecord:resetData()
	for i = 0, 2 do
		self._ccbOwner["sp_flag_"..i]:setVisible(false)
	end
	self._ccbOwner.node_head_1:removeAllChildren()
	self._ccbOwner.node_head_2:removeAllChildren()
	self._ccbOwner.tf_name_1:setString("")
	self._ccbOwner.tf_name_2:setString("")
	self._ccbOwner.tf_score:setString("")
	self._ccbOwner.tf_reward:setString(0)
	self._ccbOwner.tf_bet_num:setString(0)
	self._ccbOwner.node_reward:setVisible(false)
	self._ccbOwner.btn_detail:setVisible(false)
end

--刷新数据
function QUIWidgetSanctuaryBetRecord:setInfo(info)
	self:resetData()
	self._info = info

	self._ccbOwner.tf_name_1:setString(info.fighter1.name)
	self._ccbOwner.tf_name_2:setString(info.fighter2.name)
	local avatar = QUIWidgetAvatar.new(info.fighter1.avatar)
	avatar:setSilvesArenaPeak(info.fighter1.championCount)
    self._ccbOwner.node_head_1:addChild(avatar)
	local avatar = QUIWidgetAvatar.new(info.fighter2.avatar)
	avatar:setSilvesArenaPeak(info.fighter2.championCount)
    avatar:setScaleX(-1)
    self._ccbOwner.node_head_2:addChild(avatar)

    local score = remote.sanctuary.SCORE_MAP[info.myScoreId]
	self._ccbOwner.tf_score:setString(score[1].." : "..score[2])

	self._failId = nil
    if info.localInfo.winNum ~= 0 or info.localInfo.loseNum ~= 0 then
		self._ccbOwner.btn_detail:setVisible(true)
    	if info.localInfo.winNum > info.localInfo.loseNum then
    		self._failId = info.fighter1.userId
    	else
    		self._failId = info.fighter2.userId
    	end
    end
	self._ccbOwner.tf_bet_num:setString(info.localInfo.myBetNum)
	self._ccbOwner["sp_flag_"..info.localInfo.awardNum]:setVisible(true)

	if info.localInfo.awardNum == 1 then
		self._ccbOwner.node_reward:setVisible(true)
		self._ccbOwner.tf_reward:setString(info.localInfo.canGetNum)
		self._ccbOwner.tf_reward_name:setString("收益：")
	elseif info.localInfo.awardNum == 0 then
		self._ccbOwner.node_reward:setVisible(true)
		self._ccbOwner.tf_reward:setString(info.localInfo.canGetNum)
		self._ccbOwner.tf_reward_name:setString("预计：")
	end
end

function QUIWidgetSanctuaryBetRecord:getContentSize()
	local size = self._ccbOwner.background:getContentSize()
	return CCSize(size.width, size.height+5)
end

function QUIWidgetSanctuaryBetRecord:_onTriggerDetail()
	local betInfo = self._info
	remote.sanctuary:sanctuaryWarGetReportRequest(self._info.currRound, self._failId, false, true, self._info.isThirdRound, function (data)
			local reports = data.sanctuaryWarGetReportResponse.reports or {}
			if reports[1] then
				app:getNavigationManager():pushViewController(app.middleLayer, {uiType = QUIViewController.TYPE_DIALOG, uiClass = "QUIDialogSanctuaryRecordDetail", 
					options = {report = reports[1], betInfo = betInfo}}, {isPopCurrentDialog = false})
			end
		end)
end

return QUIWidgetSanctuaryBetRecord