-- 争粮战战况回顾

local ArenaRobReviewLayer = class("ArenaRobReviewLayer", UFCCSModelLayer)

local ReviewItem = require("app.scenes.arena.ArenaRobReviewItem")

function ArenaRobReviewLayer.create( ... )
	return ArenaRobReviewLayer.new("ui_layout/arena_RobReview.json", Colors.modelColor, ...)
end

function ArenaRobReviewLayer:ctor(json, color, ... )
	self.super.ctor(self)

    -- 复仇玩家的复仇ID
    self._crit = 0
    self._revengeId = -1
    self._revengeEnemyInfo = nil
end

function ArenaRobReviewLayer:onLayerEnter( ... )
	self:showAtCenter(true)
    self:closeAtReturn(true)

	require("app.common.effects.EffectSingleMoving").run(self, "smoving_bounce")

	self:registerBtnClickEvent("Button_Close", function ( ... )
		self:animationToClose()
	end)

    self:registerBtnClickEvent("Button_Buy_Revenge", function ( ... )
        if G_Me.arenaRobRiceData:getTokenRemainBuyTimes(1) > 0 then
        require("app.scenes.arena.ArenaRobBuyPanel").show(1)
        else
            local myVip = G_Me.userData.vip
            if myVip >= 12 then
                -- TODO:
                G_MovingTip:showMovingTip(G_lang:get("LANG_ROB_RICE_BUY_HIT_MAX"))
            else
                G_GlobalFunc.showVipNeedDialog(require("app.const.VipConst").ROBRICEREVENGE)            
            end
        end
    end)

	self:_initListView()
    self:_onCrit()

	self:getLabelByName("Label_Revenge_Times"):setText(G_Me.arenaRobRiceData:getRevengeToken())

	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_ARENA_USER_INFO, self._onGetUserInfo, self)
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_ROB_RICE_GET_REVENGE_ENEMY, self._revengeEnemy, self) 
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_ROB_RICE_BUY_RICE_TOKEN, self._onBuyToken, self)
end


function ArenaRobReviewLayer:_initListView( ... )
	local enemyList = G_Me.arenaRobRiceData:getEnemies()
	
	if #enemyList == 0 then
        self:showWidgetByName("Label_No_Attack_Tips", true)
		return
	end

    if self._listView ~= nil then
        self:showWidgetByName("Label_No_Attack_Tips", false)
        return
    end

	local panel = self:getPanelByName("Panel_Listview")
	self._listView = CCSListViewEx:createWithPanel(panel, LISTVIEW_DIR_VERTICAL)
	self._listView:setCreateCellHandler(function ( list, index )
		local item = ReviewItem.new()
		return item
	end)
	self._listView:setUpdateCellHandler(function ( list, index, cell )
        local enemyList = G_Me.arenaRobRiceData:getEnemies()
		cell:updateCell(enemyList[index + 1], 
			function ( ... ) 
				G_HandlersManager.arenaHandler:sendCheckUserInfo(enemyList[index + 1].user_id)
			end, 
			function ( ... )
				G_HandlersManager.arenaHandler:sendRevengeRiceEnemy(enemyList[index + 1].id)
                self._revengeId = enemyList[index + 1].id
                self._revengeEnemyInfo = {
                    baseId = enemyList[index + 1].base_id,
                    name = enemyList[index + 1].name,
                }
			end)
	end)

	self._listView:initChildWithDataLength(#enemyList)

end


function ArenaRobReviewLayer:_onGetUserInfo(data)
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
function ArenaRobReviewLayer:_revengeEnemy( data )
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
            
            local enemy = {                
            }

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
function ArenaRobReviewLayer:_challengeSuccess(data,result)
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
        
        self:_updateLocalEnemyState(self._revengeId)
        self._crit = data.rob_crit_rice
        uf_sceneManager:popScene()
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
            opponent = self._revengeEnemyInfo,        
        },
        challageCallback,result)
end

function ArenaRobReviewLayer:_onChallengeSuccessHandler()
    -- self:setTouchEnabled(false)
    if not self or (not self._me) or (G_SceneObserver:getSceneName() ~= "ArenaScene" and G_SceneObserver:getSceneName() ~= "RobRiceBattleScene") then
        __Log("已经不在这场景了")
        return
    end
    
    
end


--挑战失败
function ArenaRobReviewLayer:_challengeFailed(data,result)
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
        awards=data.rewards},
        function()  
            if not self or (G_SceneObserver:getSceneName() ~= "ArenaScene" and G_SceneObserver:getSceneName() ~= "RobRiceBattleScene") then
                __Log("已经不在这场景了")
                return
            end
            
            uf_sceneManager:popScene()
        end,result)

end
------------------------------------------END---------------------------------

-- 复仇成功需要修改本地该仇人的状态，将其改为已复仇成功
function ArenaRobReviewLayer:_updateLocalEnemyState( localEnemyId )
    __Log("==================ArenaRobEnemyInfoLayer:_updateLocalEnemyState============")
    G_Me.arenaRobRiceData:removeEnemyToRevenge(localEnemyId)
    self._listView:reloadWithLength(#G_Me.arenaRobRiceData:getEnemies())
end

function ArenaRobReviewLayer:_onBuyToken( data )
    if data.ret == 1 then
        -- 更新复仇令牌数值
        self:getLabelByName("Label_Revenge_Times"):setText(G_Me.arenaRobRiceData:getRevengeToken())
    end
end

function ArenaRobReviewLayer:_onCrit(  )
    if self._crit > 0 then
        require("app.scenes.arena.ArenaRobRiceCritPopupLayer").show(self._crit)
        self._crit = 0
    end
end

return ArenaRobReviewLayer