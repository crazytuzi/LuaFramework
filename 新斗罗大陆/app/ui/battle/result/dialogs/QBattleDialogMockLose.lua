

local QBattleDialog = import("...QBattleDialog")
local QBattleDialogMockLose = class(".QBattleDialogMockLose", QBattleDialog)
local QBattleDialogAgainstRecord = import(".....ui.battle.QBattleDialogAgainstRecord")

function QBattleDialogMockLose:ctor(options, owner)
	local ccbFile = "ccb/Battle_Dialog_MockDefeat.ccbi"
	local callBacks = {
		{ccbCallbackName = "onTriggerGetData", callback = handler(self, self.onTriggerGetData)},
	}
	self:setNodeEventEnabled(true)
    -- QPrintTable(callBacks)
	QBattleDialogMockLose.super.ctor(self, ccbFile, owner, callBacks)
	app.battle:resume()
    q.setButtonEnableShadow(self._ccbOwner.btn_data)
	audio.stopBackgroundMusic()
	self:setInfo()
end

function QBattleDialogMockLose:onEnter()
end

function QBattleDialogMockLose:onExit()
end


function QBattleDialogMockLose:setInfo()
	self.lose_num = remote.mockbattle:getMockBattleRoundInfo().loseCount or 0
	for i=1,3 do
		local lose = i <= self.lose_num
		self._ccbOwner["sp_lose_n"..i]:setVisible(not lose)
		self._ccbOwner["sp_lose_y"..i]:setVisible(lose)
	end

end

function QBattleDialogMockLose:_onClose()
	self._ccbOwner:onChoose()

end

function QBattleDialogMockLose:_backClickHandler()
    self:_onClose()
end

function QBattleDialogMockLose:onTriggerGetData()
	print("QBattleDialogMockLose:onTriggerGetData(event)")
    app.sound:playSound("common_small")
    QBattleDialogAgainstRecord.new({},{}) 
end
return QBattleDialogMockLose