--[[

	-- 战斗逻辑描述
	-- 	1.创建战斗scene
		2.创建战斗场景以及敌我上方阵法布局
		3.同时向服务器发送请求，请求战斗过程及结果
		4.直到收到服务器消息，战斗开始
]]
local RESULT_ZORDER = 3000
local LEVELUP_ZORDER = 3001


local data_jiefujipin_jiefujipin = require("data.data_jiefujipin_jiefujipin")


local HuoDongBattleScene = class("HuoDongBattleScene",function (msg)
	--切换此界面时，需要同时传入一个account的id，通过这个id 获得战斗数据
	return display.newScene("HuoDongBattleScene")
end)

function HuoDongBattleScene:sendReq(curWave)
	 RequestHelper.HuoDongBattle({
            callback = function(data) 
            	print("huodong fuben data")
            	dump(data)
            	self.totalData = data            
				self.battleLayer:battleCallBack(data)
				
            end,
            aid = self.fubenid,
            npc = curWave
        })	
end

function HuoDongBattleScene:result(data)
	-- self.battleData = data["2"][1]

	-- local atkData = self.battleData.d[#self.battleData.d]
	-- local win = atkData["win"] 

    local battleData = data["2"][1] 
    local win = battleData.d["end"]["win"] 

	self.rewardItem = data["3"]
	self.rewardCoin = data["4"]


	
	local resultLayer = require("game.Battle.BattleResult").new({
		win = win,
		rewardItem = self.rewardItem,
		rewardCoin = self.rewardCoin, 
		jumpFunc = function()
			GameStateManager:ChangeState(GAME_STATE.STATE_TIAOZHAN,2)
		end 
		})

	self:addChild(resultLayer,RESULT_ZORDER)	

	-- 活动副本没有经验值
	-- self:checkIsLevelup(data)
end

function HuoDongBattleScene:jieFuResult(data)
	print("dummmmmmm")
	dump(data)
	self.totoNumValue = data["6"]
	self.moneyValue = data["4"][1].n
	-- self.curSilverNum:setString(self.moneyValue)
	-- self.curSilverNum:setPosition(self._numrootnode["get_silver"]:getContentSize().width + self.curSilverNum:getContentSize().width/2,self._numrootnode["get_silver"]:getContentSize().height/2)

	-- self:updataMoneyNum(self.totoNumValue)
	local resultLayer = require("game.Huodong.jieFuJiPinResult").new({
		totalDamage = self.totoNumValue,
		totalMoney = self.moneyValue,
		jumpFunc = function()
			GameStateManager:ChangeState(GAME_STATE.STATE_TIAOZHAN,2)
		end 
		})
	self:addChild(resultLayer,RESULT_ZORDER)	

end



function HuoDongBattleScene:initJiefuJiPin()

	self.totoNumValue = 0


	local proxy = CCBProxy:create()
    self._numrootnode = {}

    local node = CCBuilderReaderLoad("huodong/jiefujipin.ccbi", proxy, self._numrootnode)
    node:setPosition(display.width/2,display.height/2)
    self:addChild(node,RESULT_ZORDER-1)

    self.curDamageNum =ui.newTTFLabelWithShadow({
        text = "0",
        size = 21,
        color = ccc3(255,240,0),
        shadowColor = ccc3(0,0,0),
        font = FONTS_NAME.font_haibao,
        align = ui.TEXT_ALIGN_LEFT 
        })
    self.curDamageNum:setAnchorPoint(ccp(0,0.5))
	self.curDamageNum:setPosition(self._numrootnode["cur_damage"]:getContentSize().width + self.curDamageNum:getContentSize().width/2,self._numrootnode["cur_damage"]:getContentSize().height/2)

    self._numrootnode["cur_damage"]:addChild(self.curDamageNum)


     self.curSilverNum =ui.newTTFLabelWithShadow({
        text = "0",
        size = 21,
        color = ccc3(231,230,228),
        shadowColor = ccc3(0,0,0),
        font = FONTS_NAME.font_haibao,
        align = ui.TEXT_ALIGN_LEFT 
        })
    self.curSilverNum:setAnchorPoint(ccp(0,0.5))
	self.curSilverNum:setPosition(self._numrootnode["get_silver"]:getContentSize().width  + self.curSilverNum:getContentSize().width/2,self._numrootnode["get_silver"]:getContentSize().height/2)

    self._numrootnode["get_silver"]:addChild(self.curSilverNum)

    self.restRoundNum =ui.newTTFLabelWithShadow({
        text = "0/5",
        size = 21,
        color = ccc3(4,246,38),
        shadowColor = ccc3(0,0,0),
        font = FONTS_NAME.font_haibao,
        align = ui.TEXT_ALIGN_LEFT 
        })
    self.restRoundNum:setAnchorPoint(ccp(0,0.5))
    self.restRoundNum:setPosition(self._numrootnode["rest_round"]:getContentSize().width - 10 + self.restRoundNum:getContentSize().width/2,self._numrootnode["rest_round"]:getContentSize().height/2)
    
    self._numrootnode["rest_round"]:addChild(self.restRoundNum)  


end

function HuoDongBattleScene:updateTotalDamgeNum(num)
	if type(num) == "number" then
		self.totoNumValue = math.ceil(self.totoNumValue + num)

		self.curDamageNum:setString(self.totoNumValue)
		self.curDamageNum:setPosition(self._numrootnode["cur_damage"]:getContentSize().width + self.curDamageNum:getContentSize().width/2,self._numrootnode["cur_damage"]:getContentSize().height/2)
		self:updataMoneyNum(self.totoNumValue)
	else
		assert(false,"错误类型")
	end
end

function HuoDongBattleScene:updataMoneyNum(damageNum)
	local jiefuData = data_jiefujipin_jiefujipin

	local function setMoneyNum(moneyNume)
	end
	
	for i = self.activeId,#jiefuData do
		if jiefuData[i].damage > damageNum then
			if i >1 then				
				self.moneyValue = jiefuData[i - 1].sumsilver + (damageNum - jiefuData[i-1].damage)*jiefuData[i-1].per/1000
				break
			else
				self.moneyValue = damageNum *jiefuData[i].per/1000
				break
			end
		else
			self.activeId = i
		end
	end

	if self.activeId == #jiefuData and damageNum >= jiefuData[self.activeId].damage then
		print("jiefuDatajiefuDatajiefuDatajiefuData")
		-- dump(jiefuData)
		self.moneyValue = jiefuData[self.activeId].sumsilver + (damageNum - jiefuData[self.activeId].per/1000)
	end
	self.moneyValue = math.ceil(self.moneyValue)
	self.curSilverNum:setString(self.moneyValue)
	self.curSilverNum:setPosition(self._numrootnode["get_silver"]:getContentSize().width + self.curSilverNum:getContentSize().width/2,self._numrootnode["get_silver"]:getContentSize().height/2)
	-- self.moneyTTF:setString(self.moneyValue)
end

function HuoDongBattleScene:updateRound(num)
	self.restRoundNum:setString(num.."/5")
	self.restRoundNum:setPosition(self._numrootnode["rest_round"]:getContentSize().width - 10 + self.restRoundNum:getContentSize().width/2,self._numrootnode["rest_round"]:getContentSize().height/2)
   
end



function HuoDongBattleScene:ctor(msg)
	display.addSpriteFramesWithFile("ui/ui_battle.plist", "ui/ui_battle.png")
	game.runningScene = self
	self.activeId = 1
	self.fubenid = msg

	self.timeScale = 1	

	if self.fubenid == 1 then --劫富济贫
		self:initJiefuJiPin()
		self.jiefuCB = function(num)
			self:updateTotalDamgeNum(num)
		end

		self.roundCB = function(num)
			self:updateRound(num)
		end

	end

	self.timeScale = ResMgr.battleTimeScale

	self.reqFunc = function(curWave)
		self:sendReq(curWave)
	end

	self.resultFunc = function(data)
		if self.fubenid == 1 then --劫富济贫
			self:jieFuResult(data)
		else
			self:result(data)
		end
	end

	self.totalData = nil 
	-- self.maxWave = msg.maxWave

	self.battleLayer = require("game.Battle.BattleLayer").new({
		fubenType = HUODONG_FUBEN,
		fubenId = self.fubenid,
		reqFunc = self.reqFunc,
		resultFunc = self.resultFunc,
		damageCB = self.jiefuCB,
		roundCB = self.roundCB
		})
	self:addChild(self.battleLayer)
end



function HuoDongBattleScene:onExit( ... )
	self:removeAllChildren()
end




return HuoDongBattleScene