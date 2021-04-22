
local QBattleDialog = import(".QBattleDialog")
local QBattleDialogConsortiaWar = class("QBattleDialogConsortiaWar", QBattleDialog)
local QUserData = import("...utils.QUserData")
function QBattleDialogConsortiaWar:ctor(owner, options)
	local ccbFile = "Dialog_Unionwar_up.ccbi"
	if owner == nil then
		owner = {}
	end
	QBattleDialogConsortiaWar.super.ctor(self, ccbFile, owner)
	local value = app.scene:getDungeonConfig().consortiaWarHallIdNum or 0
	for i = 1,4,1 do
		if bit.band(value, bit.lshift(1, i - 1)) == 0 then
			owner["tf_"..i]:setString("暂无加成")
			owner["node"..i]:setVisible(false)
		end
	end
	scheduler.performWithDelayGlobal(function()
        if self.close and not self._closed then
            self:close()
        end
    end, 5)
end

function QBattleDialogConsortiaWar:_backClickHandler()
	self:close()
end

function QBattleDialogConsortiaWar:close()
	self._closed = true
	QBattleDialogConsortiaWar.super.close(self)
end

return QBattleDialogConsortiaWar