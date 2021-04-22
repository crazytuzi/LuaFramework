
local QUIDialog = import("..dialogs.QUIDialog")
local QUIDialogMockBattleRewardTips = class("QUIDialogMockBattleRewardTips", QUIDialog)

local QNavigationController = import("...controllers.QNavigationController")
local QStaticDatabase = import("...controllers.QStaticDatabase")

function QUIDialogMockBattleRewardTips:ctor(options)
 	local ccbFile = "ccb/Dialog_MockBattle_RewardTips.ccbi"
    local callBacks = {}
    QUIDialogMockBattleRewardTips.super.ctor(self, ccbFile, callBacks, options)
    self.isAnimation = true --是否动画显示

    self:_init()
end

function QUIDialogMockBattleRewardTips:_backClickHandler()
    self:_onTriggerClose()
end

-- 关闭对话框
function QUIDialogMockBattleRewardTips:_onTriggerClose()
    self:playEffectOut()
end

function QUIDialogMockBattleRewardTips:viewAnimationOutHandler()
    app:getNavigationManager():popViewController(app.topLayer, QNavigationController.POP_TOP_CONTROLLER)
end

function QUIDialogMockBattleRewardTips:_init()
	local top_win_num = remote.mockbattle:getMockBattleUserInfo().topWinCount or 0
	local cur_win_num = remote.mockbattle:getMockBattleRoundInfo().winCount or 0
	local seasonType = remote.mockbattle:getMockBattleSeasonType()
	local score_table = {}
	local first_table = {}
	local score_item_num = 0
	local first_item_num = 0
	for i=1,2 do
		local  win = cur_win_num + i
		local socre_num = db:getMockBattleScoreRewardById( win,seasonType) or 0
		score_item_num = score_item_num + socre_num
		table.insert(score_table,score_item_num)
		if win > top_win_num then
			local item_reward = db:getMockBattleFirstWinRewardById(win,seasonType) 
			if item_reward then
	    		local item_table = string.split(item_reward, "^")
				first_item_num = first_item_num +  tonumber(item_table[2])
			end
			table.insert(first_table,first_item_num)
		end
	end
	self._ccbOwner.tf_value_1:setString("X"..score_table[2])
	self._ccbOwner.tf_value_3:setString("X"..score_table[1])
	self._ccbOwner.tf_value_2:setVisible(false)
	self._ccbOwner.sp_iocn_2:setVisible(false)
	self._ccbOwner.sp_first_1:setVisible(false)
	self._ccbOwner.tf_value_4:setVisible(false)
	self._ccbOwner.sp_iocn_4:setVisible(false)
	self._ccbOwner.sp_first_2:setVisible(false)		

	if first_table[2] ~=nil and first_table[2] ~= 0 then
		self._ccbOwner.tf_value_2:setString("X"..first_table[2])
		self._ccbOwner.tf_value_2:setVisible(true)
		self._ccbOwner.sp_iocn_2:setVisible(true)
		self._ccbOwner.sp_first_1:setVisible(true)
	end

	if first_table[1] ~=nil and first_table[1] ~= 0 then
		self._ccbOwner.tf_value_4:setString("X"..first_table[1])
		self._ccbOwner.tf_value_4:setVisible(true)
		self._ccbOwner.sp_iocn_4:setVisible(true)
		self._ccbOwner.sp_first_2:setVisible(true)
	end
end

function QUIDialogMockBattleRewardTips:viewAnimationOutHandler()
	local callBack = self._callBack
	self:popSelf()
	if callBack ~= nil then
		callBack()
	end
end


return QUIDialogMockBattleRewardTips