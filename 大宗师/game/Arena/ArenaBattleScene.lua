

local RESULT_ZORDER = 3000
local LEVELUP_ZORDER = 3001


local ArenaBattleScene = class("ArenaBattleScene",function ()

	return display.newScene("ArenaBattleScene")
end)

function ArenaBattleScene:sendReq(curWave)
print("curWave"..curWave)
	RequestHelper.sendNormalBattle({
		id = self.levelID,
		type = self.gradeID,
		callback = function(data)
			self.battleLayer:battleCallBack(data)
		end
		})
end


function ArenaBattleScene:result(data)


	self.battleData = data["2"][1]

	local atkData = self.battleData.d[#self.battleData.d]
	local win = atkData["win"] 

	self.rewardItem = data["3"]
	self.rewardCoin = data["4"]
	
	local resultLayer = require("game.Arena.ArenaResult").new({ 
		data = data 
		})

	self:addChild(resultLayer,RESULT_ZORDER)	

	self:checkIsLevelup(data)
end


-- 判断是否升级
function ArenaBattleScene:checkIsLevelup(data)
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




function ArenaBattleScene:ctor(msg)
	display.addSpriteFramesWithFile("ui/ui_battle.plist", "ui/ui_battle.png")

	--设置游戏		
	self.timeScale = 1 
	self.timeScale = ResMgr.battleTimeScale 


	
	-- self.reqFunc = function(msg)
	-- 	self.battleLayer:battleCallBack(msg)
			
	-- end

	self.resultFunc = function(data)
		self:result(data)
	end

	-- self:resetFontFlag()
--发送请求， 要求获得信息
	-- self:sendReq()
	-- print("self.levelId"..self.levelID)
	self.battleLayer = require("game.Battle.BattleLayer").new({
		fubenType = ARENA_FUBEN,
		reqFunc = self.reqFunc,
		battleData = msg,
		resultFunc = self.resultFunc
		})
	self:addChild(self.battleLayer)

	



end






function ArenaBattleScene:onExit( ... )
	self:removeAllChildren()
end

return ArenaBattleScene