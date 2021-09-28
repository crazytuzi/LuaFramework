--[[

	-- 战斗逻辑描述
	-- 	1.创建战斗scene
		2.创建战斗场景以及敌我上方阵法布局
		3.同时向服务器发送请求，请求战斗过程及结果
		4.直到收到服务器消息，战斗开始
]]
local RESULT_ZORDER = 3000
local LEVELUP_ZORDER = 3001





local JingYingBattleScene = class("JingYingBattleScene",function (msg)
	--切换此界面时，需要同时传入一个account的id，通过这个id 获得战斗数据
	return display.newScene("JingYingBattleScene")
end)

function JingYingBattleScene:sendReq(curWave)
		 RequestHelper.JingyingFuBenBattle({
	            callback = function(data) 
	            print("jingying fuben data")
	            dump(data)
	            	self.totalData = data            
					self.battleLayer:battleCallBack(data)
					
	            end,
	            id = self.fubenid,
	            npc = curWave
	        })
	
end

function JingYingBattleScene:result(data)
	print("jing ying jingying ")
	
	local battleData = data["2"][1] 
    local win = battleData.d["end"]["win"] 

	self.rewardItem = data["3"]
	self.rewardCoin = data["4"]
	
	local resultLayer = require("game.Battle.BattleResult").new({
		win = win,
		rewardItem = self.rewardItem,
		rewardCoin = self.rewardCoin, 
		jumpFunc = function()
			-- scene = require("game.Challenge.ChallengeScene").new(1)
            -- display.replaceScene(scene,"fade", 0.3, display.COLOR_WHITE)
            GameStateManager:ChangeState(GAME_STATE.STATE_TIAOZHAN)
		end
		}) 

	self:addChild(resultLayer,RESULT_ZORDER)	

	self:checkIsLevelup(data)
end

-- 判断是否升级 
function JingYingBattleScene:checkIsLevelup(data) 
	dump(data)
    -- 当前等级
    local beforeLevel = game.player.getLevel()  -- 之前等级
    local curlevel = data["6"] or beforeLevel
    local curExp = data["7"] or 0

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



function JingYingBattleScene:ctor(msg)
	display.addSpriteFramesWithFile("ui/ui_battle.plist", "ui/ui_battle.png")
	game.runningScene = self

	self.fubenid = msg
	print("msg"..msg)
	self.timeScale = 1	

	self.timeScale = ResMgr.battleTimeScale
	self.reqFunc = function(curWave)
		self:sendReq(curWave)
	end

	self.resultFunc = function(data)
		self:result(data)
	end

	self.totalData = nil 
	-- self.maxWave = msg.maxWave

	self.battleLayer = require("game.Battle.BattleLayer").new({
		fubenType = JINGYING_FUBEN,
		fubenId = self.fubenid,
		reqFunc = self.reqFunc,
		resultFunc = self.resultFunc
		})
	self:addChild(self.battleLayer)
end


function JingYingBattleScene:onExit( ... )
	self:removeAllChildren()
end




return JingYingBattleScene