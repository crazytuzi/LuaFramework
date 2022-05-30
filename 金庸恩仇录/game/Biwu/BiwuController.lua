BiwuController = {}
BiwuConst = {
BIWU = 1,
ENEMY = 2,
TIAOZHAN = 3
}
TabIndex = {
BIWU = 1,
CHOUREN = 2,
TIANBANG = 4
}

function BiwuController.sendFightData(type, roleid, tabIndex, oppName)
	RequestHelper.biwuSystem.checkFight({
	type = type,
	roleId = roleid,
	callback = function(data)
		dump("check data")
		dump(data)
		local change = data["1"]
		if change == 1 then
			if game.player:getNaili() < 2 then
				local layer = require("game.Arena.ArenaBuyMsgBox").new({
				updateListen = handler(self, BiwuController.updateNaiLiLbl)
				})
				display.getRunningScene():addChild(layer, 1000000)
				return
			end
			ResMgr.oppName = oppName
			RequestHelper.biwuSystem.getFightData({
			type = type,
			roleId = roleid,
			callback = function(data)
				dump(data)
				if data["0"] ~= "" then
					dump(data["0"])
				else
					GameStateManager:ChangeState(GAME_STATE.STATE_BIWU_BATTLE, {data = data, tabindex = tabIndex})
				end
			end
			})
		elseif change == 2 then
			local changeMsgBox = require("game.Arena.ArenaChangeMsgBox").new({
			battleFunc = function()
				self:sendBattleReq()
			end,
			resetFunc = function()
				self.resetFunc()
			end
			})
			display.getRunningScene():addChild(changeMsgBox, MAX_ZORDER)
		elseif change == 3 then
			do
				local isBagFull = true
				local bagObj = data["2"]
				local function extendBag(data)
					if bagObj[1].curCnt < data["1"] then
						table.remove(bagObj, 1)
					else
						bagObj[1].cost = data["4"]
						bagObj[1].size = data["5"]
					end
					if #bagObj > 0 then
						game.runningScene:addChild(require("utility.LackBagSpaceLayer").new({
						bagObj = bagObj,
						callback = function(data)
							extendBag(data)
						end
						}), MAX_ZORDER)
					else
						isBagFull = false
					end
				end
				if isBagFull then
					game.runningScene:addChild(require("utility.LackBagSpaceLayer").new({
					bagObj = bagObj,
					callback = function(data)
						extendBag(data)
					end
					}), 100000)
				end
			end
		end
	end
	})
end

function BiwuController.updateNaiLiLbl()
	PostNotice(NoticeKey.CommonUpdate_Label_Naili)
	PostNotice(NoticeKey.BIWu_update_naili)
	PostNotice(NoticeKey.CommonUpdate_Label_Gold)
	PostNotice(NoticeKey.CommonUpdate_Label_Silver)
end