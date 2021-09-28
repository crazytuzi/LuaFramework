-- 争粮战中可复仇玩家信息弹唱

local ArenaRobEnemyInfoLayer = class("ArenaRobEnemyInfoLayer", UFCCSModelLayer)

local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"

function ArenaRobEnemyInfoLayer.show( enemyInfo, ... )
	local layer = ArenaRobEnemyInfoLayer.new("ui_layout/arena_RobEnemyInfo.json", Colors.modelColor, enemyInfo, ...)
	uf_sceneManager:getCurScene():addChild(layer)
	-- layer:adapterWithScreen()
end


function ArenaRobEnemyInfoLayer:ctor( json, color, enemyInfo, ... )
	self.super.ctor(self, json, color, ...)

	self._enemyInfo = enemyInfo

	self._nameLabel = self:getLabelByName("Label_Name")
	self._fightValueLabel = self:getLabelByName("Label_Fight_Value")
	self._levelLabel = self:getLabelByName("Label_Level")
    self._robRiceDesLabel = self:getLabelByName("Label_Rob_Rice_Des")

    self:_createStrokes()
end

function ArenaRobEnemyInfoLayer:_createStrokes( ... )
	self._nameLabel:createStroke(Colors.strokeBrown, 1)
	self._fightValueLabel:createStroke(Colors.strokeBrown, 1)
	self._levelLabel:createStroke(Colors.strokeBrown, 1)
    self:getLabelByName("Label_Level_Tag"):createStroke(Colors.strokeBrown, 1)
    self:getLabelByName("Label_Fight_Value_Tag"):createStroke(Colors.strokeBrown, 1)
    self._robRiceDesLabel:createStroke(Colors.strokeBrown, 1)
end

function ArenaRobEnemyInfoLayer:onLayerEnter( ... )
	self:showAtCenter(true)
	self:closeAtReturn(true)

	self._nameLabel:setText(self._enemyInfo.name)
	self._levelLabel:setText(G_lang:get("LANG_ROB_RICE_LEVEL", {num = self._enemyInfo.level}))
	self._fightValueLabel:setText(GlobalFunc.ConvertNumToCharacter(self._enemyInfo.fight_value))
    self._robRiceDesLabel:setText(G_lang:get("LANG_ROB_RICE_WIN_RICE", {num = math.floor(self._enemyInfo.init_rice * 0.15)}))

    local knightPanel = self:getPanelByName("Panel_Knight")

    local user = self._enemyInfo
    local knightPic = require("app.scenes.common.KnightPic")
    local knight = knight_info.get(user.base_id)
    if not knight then
        return
    end

    if self._knightImageView ~= nil then
        knightPanel:removeAllChildrenWithCleanup(true)
    end 


    local res_id = G_Me.dressData:getDressedResidWithClidAndCltm(user.base_id, user.dress_base, rawget(user,"clid"),rawget(user,"cltm"),rawget(user,"clop"))
    self._knightImageView = knightPic.createKnightButton(res_id, knightPanel, "" .. user.user_id .. user.id, nil, function()            
    end,true)

    knightPanel:setScale(0.8)

    self._nameLabel:setColor(Colors.qualityColors[knight.quality])

	self:registerBtnClickEvent("Button_Check_Line_Up", function ( ... )
		self:_checkLineUp()
	end)

	self:registerBtnClickEvent("Button_Revenge", function ( ... )
		self:_revenge()
	end)

	self:registerBtnClickEvent("Button_Close", function ( ... )
		self:animationToClose()
	end)

    self:attachImageTextForBtn("Button_Revenge","Image_24")

    if self._enemyInfo.revenge == 1 then
        self:getButtonByName("Button_Revenge"):setTouchEnabled(false)
    end

	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_ARENA_USER_INFO, self._onGetUserInfo, self) 
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_ROB_RICE_GET_REVENGE_ENEMY, self._revengeEnemy, self)

    EffectSingleMoving.run(self, "smoving_bounce")
end

-- 查看阵容
function ArenaRobEnemyInfoLayer:_checkLineUp( ... )
	G_HandlersManager.arenaHandler:sendCheckUserInfo(self._enemyInfo.user_id)
end



-- 复仇
function ArenaRobEnemyInfoLayer:_revenge( ... )
	G_HandlersManager.arenaHandler:sendRevengeRiceEnemy(self._enemyInfo.id)
end

function ArenaRobEnemyInfoLayer:_onGetUserInfo(data)
	if data.ret == 1 then
		if data.user == nil or data.user.knights == nil or #data.user.knights == 0 then
			G_MovingTip:showMovingTip(G_lang:get("LANG_SERVER_DATA_EXCEPTION"))
			return
		end
		local layer = require("app.scenes.arena.ArenaZhenrong").create(data.user)
		uf_notifyLayer:getModelNode():addChild(layer)
	end
end


-- 复仇协议回调
function ArenaRobEnemyInfoLayer:_revengeEnemy( data )
	if data.ret == 1 then 
        local callback = function(result)
            if not self or (G_SceneObserver:getSceneName() ~= "ArenaScene" and G_SceneObserver:getSceneName() ~= "RobRiceBattleScene") then
                __Log("已经不在这场景了")
                return
            end
            if not data then
                return
            end
            if data.battle_report.is_win == true then
                if self and self._challengeSuccess ~= nil then
                    self:_challengeSuccess(data,result)
                end
            else
                if self and self._challengeFailed ~= nil then
                    self:_challengeFailed(data,result)
                end
            end
        end
        G_Loading:showLoading(function ( ... )
            --创建战斗场景
            if data == nil then 
                return
            end
            if not self then
                return
            end
            
            local enemy = {}

            self.scene = require("app.scenes.arena.RobRiceBattleScene"):new(data.battle_report,enemy,callback)
            self.scene.__EFFECT_FINISH_CALLBACK__ = self.__EFFECT_FINISH_CALLBACK__
            uf_sceneManager:pushScene(self.scene)
        end, 
        function ( ... )
            if self.scene ~= nil then
                self.scene:play()
            end
            --开始播放战斗
        end)
    else
        self:setTouchEnabled(true)
    end  
end

--挑战成功
function ArenaRobEnemyInfoLayer:_challengeSuccess(data,result)
    -- self:setTouchEnabled(false)
    local challageCallback = function()
        --暂时跳过突破奖励
        if not self or (G_SceneObserver:getSceneName() ~= "ArenaScene" and G_SceneObserver:getSceneName() ~= "RobRiceBattleScene") then
            __Log("已经不在这场景了")
            return
        end
        if not data then
            return
        end
        
        G_Me.arenaRobRiceData:setCritRice(data.rob_crit_rice)
        uf_sceneManager:popScene()        
        self:_updateLocalEnemyState(self._enemyInfo.id)
        self:removeFromParent()
    end
    local __awardMoney = 0
    local __awardExp = 0
    local __shengwang = 0

    for i,v in ipairs(data.rewards) do 
        if v.type == G_Goods.TYPE_MONEY then
            __awardMoney = v.size
        elseif v.type == G_Goods.TYPE_EXP then
            __awardExp = v.size
        elseif v.type == G_Goods.TYPE_SHENGWANG then
            __shengwang = v.size
        end
    end

    local FightEnd = require("app.scenes.common.fightend.FightEnd")
    local picks = nil
    
    if rawget(data, "turnover_rewards")  then
        picks= data.turnover_rewards.rewards
    end

    __Log("显示FightEnd.show")
    FightEnd.show(FightEnd.TYPE_ROB_RICE,true,
        {
            robrice_win = data.rob_init_rice,    
            rice=data.rob_growth_rice,
            foster_pill=data.rewards[2].size,
            rice_prestige=__shengwang,
            awards=data.rewards,
            opponent = {
                baseId = self._enemyInfo.base_id,
                name = self._enemyInfo.name,
            },   
        },
        challageCallback,result)
end

function ArenaRobEnemyInfoLayer:_onChallengeSuccessHandler()
    -- self:setTouchEnabled(false)
    if not self or (not self._me) or (G_SceneObserver:getSceneName() ~= "ArenaScene" and G_SceneObserver:getSceneName() ~= "RobRiceBattleScene") then
        __Log("已经不在这场景了")
        return
    end
end


--挑战失败
function ArenaRobEnemyInfoLayer:_challengeFailed(data,result)
    self:setTouchEnabled(true)
    local __awardMoney = 0
    local __awardExp = 0
    local __shengwang = 0

    for i,v in ipairs(data.rewards) do 
        if v.type == G_Goods.TYPE_MONEY then
            __awardMoney = v.size
        elseif v.type == G_Goods.TYPE_EXP then
            __awardExp = v.size
        elseif v.type == G_Goods.TYPE_SHENGWANG then
            __shengwang = v.size
        end
    end

    local FightEnd = require("app.scenes.common.fightend.FightEnd")
    FightEnd.show(FightEnd.TYPE_ROB_RICE,false,
        {
        exp=__awardExp,
        money=__awardMoney,
        rice_prestige=__shengwang,
        awards=data.rewards
        },
        function()  
            if not self or (G_SceneObserver:getSceneName() ~= "ArenaScene" and G_SceneObserver:getSceneName() ~= "RobRiceBattleScene") then
                __Log("已经不在这场景了")
                return
            end
            
            uf_sceneManager:popScene()

            self:removeFromParent()
        end,
        result)

end
------------------------------------------END---------------------------------

-- 复仇成功需要修改本地该仇人的状态，将其改为已复仇成功
function ArenaRobEnemyInfoLayer:_updateLocalEnemyState( localEnemyId )
    G_Me.arenaRobRiceData:removeEnemyToRevenge(localEnemyId)
end

function ArenaRobEnemyInfoLayer:onLayerExit(  )
    uf_eventManager:removeListenerWithTarget(self)
end

return ArenaRobEnemyInfoLayer