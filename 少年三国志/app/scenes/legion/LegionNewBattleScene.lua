--LegionBattleScene.lua

require "app.cfg.corps_dungeon_info"
require "app.cfg.corps_dungeon_tips_info"


local LegionNewBattleScene = class("LegionNewBattleScene", UFCCSBaseScene)


function LegionNewBattleScene:ctor( msg, ... )
	self.super.ctor(self, msg, ...)
        local BattleLayer = require("app.scenes.battle.BattleLayer")
	self._battleField = BattleLayer.create(
        {battleType = BattleLayer.LEGION_BATTLE, msg=msg.data.info, battleBg= msg.bg,skip = BattleLayer.SkipConst.SKIP_YES}, handler(self, self._onBattleEvent))
        self._finishFunc = msg.func
        self:addChild(self._battleField)
        
        self._damage = msg.data.harm
        self._corpPoint = msg.data.corp_point
        self._finalAward = msg.data.final_award
        self._dismissFlag = -1
        self._enemyHp = self._battleField:getKnightTotalHP(2)
        -- 保存一下battleresult
        self._data = msg.data
        
        self._curDamage = 0
        self._buff = require("app.scenes.legion.LegionNewBattleBuffLayer").create()
        self:addChild(self._buff)
        local winSize = CCDirector:sharedDirector():getWinSize()
        self._buff:setPosition(ccp(0, winSize.height/2+50))  
        self._buff:initData(msg.data.dungeon)
end

function LegionNewBattleScene:onSceneLoad( ... )
	-- body
end

function LegionNewBattleScene:onSceneEnter( ... )
	uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_DISMISS_CORP, function ( ... )
        self._dismissFlag = 1
    end, self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_NOTIFY_CORP_DISMISS, function ( dismiss )
        self._dismissFlag = dismiss
    end, self)
    G_SoundManager:playBackgroundMusic(require("app.const.SoundConst").BackGroundMusic.FIGHT)
end

function LegionNewBattleScene:play()
    self._battleField:play()
end

function LegionNewBattleScene:_onBattleEvent( event ,param1,param2,param3)
	local BattleLayer = require "app.scenes.battle.BattleLayer"

        if event == BattleLayer.BATTLE_OPENING_FINISH then
            
                        -- 伤害加成显示
                        -- 关卡id
                        local gateId = self._data.dungeon.id

                        local info = corps_dungeon_info.get(gateId)
                        assert(info, "Could not find the corps_dungeon_info with id: "..gateId)
                        
                        -- countryId
                        local countryId = info['country']
                        local tipInfo = corps_dungeon_tips_info.get(countryId)
                        assert(tipInfo, "Could not find the corps_dungeon_tips_info with id: "..countryId)
                        
                        local knights = self._battleField:getHeroKnight()

                        -- 入口集
                        local entrySet = require("app.scenes.battle.entry.Entry").new()

                        local LegionBattleDamageAdditionEntry = require "app.scenes.legion.LegionBattleDamageAdditionEntry"
                        for k, knight in pairs(knights) do
                            local cardConfig = knight:getCardConfig()
                            -- 是否属于压制一方的国家阵营
                            if cardConfig.group == tipInfo.group then
                                local additionEntry = LegionBattleDamageAdditionEntry.create(knight, self._battleField)
                                entrySet:addEntryToNewQueue(additionEntry, additionEntry.updateEntry)
                            end
                        end

                        -- 添加至当前队列的顶层，表示马上需要播放
                        self._battleField:insertEntryToQueueAtTop(entrySet, entrySet.updateEntry)
        elseif  event == BattleLayer.BATTLE_DAMAGE_UPDATE then
                        if param1 == 2 then
                            self._curDamage = self._curDamage - param3
                            self._buff:updateDamage(self._curDamage)
                        end
            
        elseif event == BattleLayer.BATTLE_FINISH then
                         self._buff:updateDamage(self._enemyHp - self._battleField:getKnightCurrentHP(2))
                	local fightEnd = require("app.scenes.common.fightend.FightEnd")
                	local attackSize = (self._finalAward and #self._finalAward > 0) and (self._finalAward[1].size or 0) or 0
                         local finalAward = (self._finalAward and #self._finalAward > 0) and self._finalAward[1] or nil
                	fightEnd.show(fightEnd.TYPE_JUNTUAN, true, 
                	{
                		damage = self._damage,
                		gongxian = self._corpPoint,
                		last_attack_award = attackSize > 0 and attackSize or nil, --self._finalAward,
                                      last_attack_award_extra = finalAward,
                	},
                	function ( ... )
                		if self._dismissFlag >= 0 then 
                			G_HandlersManager.legionHandler:disposeCorpDismiss(self._dismissFlag)
                		else
                			uf_sceneManager:popScene()
                		end
                	end)		
        end
end

return LegionNewBattleScene

