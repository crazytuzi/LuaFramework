--
-- Author: Daniel
-- Date: 2015-01-21 17:16:43
--
BiwuController = {}
BiwuConst = {
	BIWU     = 1,
	ENEMY    = 2,
	TIAOZHAN = 3,
}
TabIndex = {
	BIWU     = 1,
	CHOUREN  = 2,
	TIANBANG = 4
}

BiwuController.sendFightData = function (type,roleid,tabIndex)
	
end


BiwuController.sendFightData = function (type,roleid,tabIndex)
	--发送请求，请求检查排名是否已经发生改变，返回后如果成功
    RequestHelper.biwuSystem.checkFight({
    	type = type,
		roleId = roleid,
        callback = function(data)
            print("check data")
            dump(data)
            local change = data["1"]
            if change == 1 then
                if game.player:getNaili() < 2 then
					local layer = require("game.Arena.ArenaBuyMsgBox").new({updateListen = handler(self, BiwuController.updateNaiLiLbl)})
			        display.getRunningScene():addChild(layer,1000000)
					return
				end
				RequestHelper.biwuSystem.getFightData({
					type = type,
					roleId = roleid,
	                callback = function(data)
	                    dump(data)
	                    if data["0"] ~= "" then
	                        dump(data["0"]) 
	                    else 
	                        GameStateManager:ChangeState(GAME_STATE.STATE_BIWU_BATTLE,{ data = data , tabindex = tabIndex})
	                    end
	                end 
                })
   			elseif change == 2 then 
                --名次发生了改变，弹出提示框 要求玩家选择是否战斗
                local changeMsgBox = require("game.Arena.ArenaChangeMsgBox").new({
                    battleFunc = function() self:sendBattleReq() end,
                    resetFunc = function() self.resetFunc() end
                    })
                display.getRunningScene():addChild(changeMsgBox, MAX_ZORDER)

            elseif change == 3 then 
                local isBagFull = true 
                local bagObj = data["2"] 
				-- 判断背包空间是否足，如否则提示扩展空间 
                local function extendBag(data)
                    -- 更新第一个背包，先判断当前拥有数量是否小于上限，若是则接着提示下一个背包类型需要扩展，否则更新cost和size 
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
                            end}), MAX_ZORDER)
                    else
                        isBagFull = false 
                    end
                end
				if isBagFull then 
                    game.runningScene:addChild(require("utility.LackBagSpaceLayer").new({
                        bagObj = bagObj, 
                        callback = function(data)
                            extendBag(data)
                        end}), 100000)
                end
            end
        end
        })
end

BiwuController.updateNaiLiLbl = function ()
	PostNotice(NoticeKey.CommonUpdate_Label_Naili)
    PostNotice(NoticeKey.BIWu_update_naili)
    PostNotice(NoticeKey.CommonUpdate_Label_Gold)
    PostNotice(NoticeKey.CommonUpdate_Label_Silver)
end


