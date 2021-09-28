--
-- Author: Daniel
-- Date: 2015-01-21 10:57:05
--
local RESULT_ZORDER = 3000
local LEVELUP_ZORDER = 3001


local BiwuBattleScene = class("BiwuBattleScene",function ()

	return display.newScene("BiwuBattleScene")
end)


function BiwuBattleScene:result(data)
	self.battleData = data["2"][1]
	local atkData = self.battleData.d[#self.battleData.d]
	local win = atkData["win"] 

	self.rewardItem = data["3"]
	self.rewardCoin = data["4"]

	local resultLayer = require("game.Biwu.BiwuResult").new({ 
		data = data, 
		win = win,
		rewardItem = {},
		rewardCoin = 1, 
		tabindex = self._tabIndex,
		extraMsg = self._extraMsg,
		jumpFunc = function()
			GameStateManager:ChangeState(GAME_STATE.STATE_BIWU,{tabindex = self._tabIndex,value = self._extraMsg})
		end
		})
	--[[胜利：耐力-2，次数-1，荣誉+2。积分增加值=(攻击目标总积分-1000)*10%；小数点向上取整
	失败：耐力-2，次数-1；荣誉不变，积分不变--]]
	--game.player.m_energy = game.player.m_energy - 2
	--GameStateManager:ChangeState(GAME_STATE.STATE_BIWU,{tabindex = self._tabIndex})
	self:addChild(resultLayer,RESULT_ZORDER)	
	game.player.m_energy = game.player.m_energy - 2
	self:checkIsLevelup(data)
end

-- 判断是否升级
function BiwuBattleScene:checkIsLevelup(data)
	-- dump(data)
    -- 当前等级
    local beforeLevel = game.player.getLevel()  -- 之前等级
    local curlevel = data["7"] or beforeLevel 
    local curExp = data["8"] 

    -- 没有更新当前等级的最大exp

    game.player:updateMainMenu({
        lv = curlevel, 
        exp = curExp
        })

    -- 判断是否升级
    if beforeLevel < curlevel then
        local curNail = game.player:getNaili()
        self:addChild(require("game.Shengji.ShengjiLayer").new({level = beforeLevel, uplevel = curlevel, naili = curNail, curExp = curExp}), LEVELUP_ZORDER)
    end
end

function BiwuBattleScene:ctor(msg)
	self._tabIndex = msg.tabindex
	self._extraMsg = msg.data["10"]
	display.addSpriteFramesWithFile("ui/ui_battle.plist", "ui/ui_battle.png")
	--设置游戏		
	self.timeScale = 1 
	self.timeScale = ResMgr.battleTimeScale 

	self.resultFunc = function(data)
		self:result(data)
	end
	self.battleLayer = require("game.Battle.BattleLayer").new({
		fubenType = ARENA_FUBEN,
		reqFunc = self.reqFunc,
		battleData = msg.data,
		resultFunc = self.resultFunc
		})
	self:addChild(self.battleLayer)
end

return BiwuBattleScene