

local FightEnd = class ("FightEnd", UFCCSModelLayer)
local Colors = require("app.setting.Colors")
--[[

FightEnd.RESULT_WANSHENG    = "1"    完胜
FightEnd.RESULT_SHENG_LI    = "2"    胜利
FightEnd.RESULT_XIAN_SHENG  = "3"    险胜
FightEnd.RESULT_XI_BAI      = "4"    失败
FightEnd.RESULT_SHI_BAI     = "5"    惜败
FightEnd.RESULT_CAN_BAI     = "6"    惨败
]]
FightEnd.RESULT_WANSHENG    = "1"
FightEnd.RESULT_SHENG_LI    = "2"
FightEnd.RESULT_XIAN_SHENG  = "3"
FightEnd.RESULT_XI_BAI      = "4"
FightEnd.RESULT_SHI_BAI     = "5"
FightEnd.RESULT_CAN_BAI     = "6"

-- 主线副本：（胜利，失败只有经验和银两） 
--     星级  star
--     获得经验 exp
--     获得银两 money
--     掉落道具展示（三种箱子） awards    (金色品质: quality>=5, 银色品质 quality >=3,  铜色宝箱 quality>=1)
-- 剧情副本（胜利，失败只有经验和银两） 
--     星级  star
--     获得经验  exp
--     获得银两  money
--     掉落道具展示（三种箱子）awards    (金色品质: quality>=5, 银色品质 quality >=3,  铜色宝箱 quality>=1)

-- 闯关:（胜利，失败啥也没有）
--     获得道具   awards
--     获得闯关积分   tower_score
--     获得银两  tower_money
--     过关胜利条件  win_desc
--     表里的值 compare_value_1 威名 用来比对的参数
--     表里的值 compare_value_2 银两 用来比对的参数
-- 夺宝：（胜利，失败只有经验和银两）
--     获得经验 exp
--     获得银两 money
--     翻牌  picks
--     是否抢夺成功  rob_result,成功则为碎片ID,否则则为0
-- 竞技场（胜利，失败只有经验和银两,声望）
--     获得经验 exp
--     获得银两 money
--     老的排名 old_rank
--     新的排名 new_rank
--     获得声望 prestige
--     翻牌 picks

-- 叛军(无论胜利失败)
--     本次造成伤害 damage
--     获得功勋  gongxun 
--     获得战功  zhangong 
-- VIP(无论胜利失败)
--  战斗描述 win_desc 
--  award:
--  基础奖励  base_reward
--  额外奖励  extra_reward

-- CITY 挂机
--      awards
--
-- 军团副本
--  本次造成伤害 damage
--  军团贡献  gongxian
--  最后一击  last_attack 
--
-- 跨服演武积分战
--      获得积分 crosswar_score
--      演武勋章 crosswar_medal
--
-- 百战沙场
--      战宠积分 pet_point
--      战胜对象 beat_user

--


FightEnd.TYPE_DUNGEON = 1 -- 主线副本|剧情副本
FightEnd.TYPE_TOWER = 2   --闯关
FightEnd.TYPE_ROB = 3   --夺宝
FightEnd.TYPE_ARENA = 4   --竞技场
FightEnd.TYPE_MOSHEN = 5   --叛军
FightEnd.TYPE_FRIEND = 6   --好友
FightEnd.TYPE_VIP = 7   --VIP副本
FightEnd.TYPE_LEVELUP = 8   --专们升级
FightEnd.TYPE_CITY = 9   -- 挂机
FightEnd.TYPE_JUNTUAN = 10
FightEnd.TYPE_JUNTUANZHAN = 11  --军团战
FightEnd.TYPE_CROSSWAR = 12 --跨服演武
FightEnd.TYPE_TIME_DUNGEON = 13 --限时挑战副本
FightEnd.TYPE_HARD_RIOT = 14 --精英暴动
FightEnd.TYPE_REBEL_BOSS = 15 --世界Boss
FightEnd.TYPE_ROB_RICE = 16 -- 争粮战
FightEnd.TYPE_WUSH_BOSS = 17 -- 三国无双精英boss
FightEnd.TYPE_DUNGEON_DAILY = 18 -- 新版日常副本
FightEnd.TYPE_CRUSADE = 19 -- 百战沙场
FightEnd.TYPE_CROSSPVP = 20 -- 跨服夺帅
FightEnd.TYPE_EX_DUNGEON = 21 -- 过关斩将
FightEnd.TYPE_DAILY_PVP = 22 -- 组队pvp
FightEnd.TYPE_HERO_SOUL = 23 -- 将灵

--[[

]]
function FightEnd.show(type, isWin, data, endCallback,status)
    local node = FightEnd.new()
    -- uf_notifyLayer:getModelNode():addChild(node)
    uf_sceneManager:getCurScene():addChild(node)   
    node:init(type, isWin, status,data, endCallback)
    node:play()

    G_SoundManager:stopBackgroundMusic()
end

function FightEnd:ctor(...)
    self.super.ctor(self, ...)
    self._type = nil
    self._isWin = nil
    self._data = nil
    self._parts = {}
    self._waiting = false
    self._endCallback = nil
end

function FightEnd:init(type, isWin, status,data, endCallback)
    self._type = type
    self._isWin = isWin
    --战斗结果状态,惨胜,完胜
    self._status = status
    self._data = data
    self._endCallback = endCallback

    self._parts = {}


    --黑色底图
    local bgBlack = CCLayerColor:create(ccc4(0, 0, 0, 220), display.width,display.height)
    self:addChild(bgBlack)


    --正文部分
    self._content = display.newNode()
    self._content:setPosition(ccp(display.cx, display.cy))
    self:addChild(self._content)


    --所有动画分成以下几个部分进行组合
    -- begin  (细分 starWin|win|lose)  展示胜利/失败字样
    -- show (细分 money|exp|tower_score)  展示 数值奖励列表 (银两, 积分, 经验等)
    -- pickCard  展示翻牌
    -- dropItems   展示宝箱掉落
    -- wait  等待下一步

    if self._type == FightEnd.TYPE_DUNGEON  then
        
        if not self._isWin then
            self:_addPart( {part="begin",   result= self._status or FightEnd.RESULT_SHI_BAI})
            self:_addPart( {part="show",    result="lost", list = {"money", "exp"}  } )
            self:_addPart( {part="lose_guide",   } )

            self:_addPart( {part="wait",   } )
        else
            self:_addPart( {part ="begin",  result= self._status or FightEnd.RESULT_SHENG_LI})
            self:_addPart( {part ="show",   result="win", list = {"money", "exp"} })
            self:_addPart( {part="wait",   } )

           
            if self._data.awards and #self._data.awards > 0 then
                self:_addPart( {part ="dropItems"})
                self:_addPart( {part="wait",   } )

            end

            self:_checkLevelUp(data.exp)


        end
    elseif self._type == FightEnd.TYPE_TOWER then
        if not self._isWin then
            self:_addPart( {part="begin",   result="lost"})
            self:_addPart( {part="lose_guide",   } )

            self:_addPart( {part="wait",   } )
        else
            self:_addPart( {part ="begin",  result= "win"})
            self:_addPart( {part ="show",   result="win", list = {"tower_score", "tower_money",} })
            self:_addPart( {part="wait",   } )

            -- if self._data.awards and #self._data.awards > 0 then
            --     self:_addPart( {part ="dropItems"})
            --     self:_addPart( {part="wait",   } )

            -- end



        end
    elseif self._type == FightEnd.TYPE_ROB then
        if not self._isWin then
            self:_addPart( {part="begin",   result=self._status or FightEnd.RESULT_SHI_BAI})
            self:_addPart( {part ="show",   result="lost", list = {"money", "exp"} })
            self:_addPart( {part="lose_guide",   } )

            self:_addPart( {part="wait",   } )

            self:_checkLevelUp(data.exp)

        else
            self:_addPart( {part ="begin",  result= self._status or FightEnd.RESULT_SHENG_LI})
            self:_addPart( {part ="show",   result="", list = {"money", "exp", "rob_result"} })
            self:_addPart( {part="wait",   } )

            self:_addPart( {part ="pickCard" })


            self:_addPart( {part="wait",   } )

            self:_checkLevelUp(data.exp)

        end
    elseif self._type == FightEnd.TYPE_ARENA then
        if not self._isWin then
            self:_addPart( {part="begin",   result=self._status  or FightEnd.RESULT_SHI_BAI})
            self:_addPart( {part ="show",   result="lose", list = {"money", "prestige", "exp"} })
            self:_addPart( {part="lose_guide",   } )

            self:_addPart( {part="wait",   } )

            self:_checkLevelUp(data.exp)
        else
            self:_addPart( {part ="begin",  result= self._status or FightEnd.RESULT_SHENG_LI})
            self:_addPart( {part ="show",   result="win", list = {"money", "prestige", "exp"} })
            
            self:_addPart( {part="wait",   } )



            self:_addPart( {part ="pickCard" })

            self:_addPart( {part="wait",   } )

            self:_checkLevelUp(data.exp)


        end
        
    elseif self._type == FightEnd.TYPE_MOSHEN then
        self:_addPart( {part ="begin",  result= "moshen_result"})

        self:_addPart( {part ="show",   result="moshen_result", list = {"damage", "gongxun","zhangong"} })
        self:_addPart( {part="wait",   } )
    elseif self._type == FightEnd.TYPE_FRIEND then
        if not self._isWin then
            self:_addPart( {part="begin",   result=self._status or FightEnd.RESULT_SHI_BAI})
         
            self:_addPart( {part="lose_guide",   } )

            self:_addPart( {part="wait",   } )


        else
            self:_addPart( {part ="begin",  result= self._status or FightEnd.RESULT_SHENG_LI})
            self:_addPart( {part="wait",   } )


        end

    elseif self._type == FightEnd.TYPE_VIP then
        self:_addPart( {part ="begin",  result= "vip_result"})
        self:_addPart( {part ="show",   result="vip_result", list = {"award"} })
        self:_addPart( {part="wait",   } )
    elseif self._type == FightEnd.TYPE_CITY then
        --只有胜利失败
        if not self._isWin then
            self:_addPart( {part="begin",   result= self._status or FightEnd.RESULT_SHI_BAI})
         
            self:_addPart( {part="lose_guide",   } )

            self:_addPart( {part="wait",   } )


        else
            self:_addPart( {part ="begin",  result= self._status or FightEnd.RESULT_SHENG_LI})
            self:_addPart( {part ="dropItems"})
            self:_addPart( {part="wait",   } )


        end
    elseif self._type == FightEnd.TYPE_TIME_DUNGEON then
        --只有胜利失败
        if not self._isWin then
            self:_addPart( {part="begin",   result= self._status or FightEnd.RESULT_SHI_BAI})
         
            self:_addPart( {part="lose_guide",   } )

            self:_addPart( {part="wait",   } )


        else
            self:_addPart( {part ="begin",  result= self._status or FightEnd.RESULT_SHENG_LI})
            self:_addPart( {part ="dropItems"})
            self:_addPart( {part="wait",   } )


        end
    elseif self._type == FightEnd.TYPE_JUNTUAN then
        self:_addPart( {part ="begin",  result= "juntuan_result"})

        self:_addPart( {part ="show",   result="juntuan_result", list = {"damage", "gongxian","last_attack_award"} })
        self:_addPart( {part="wait",   } )
    elseif self._type == FightEnd.TYPE_JUNTUANZHAN then
        if not self._isWin then
        self:_addPart( {part="begin",   result=self._status or FightEnd.RESULT_SHI_BAI})
        self:_addPart( {part ="show",   result="juntuan_zhan_result", list = {"gongxian"} })
        self:_addPart( {part="lose_guide",   } )

        self:_addPart( {part="wait",   } )
        else
            self:_addPart( {part ="begin",  result= self._status or FightEnd.RESULT_SHENG_LI})

            self:_addPart( {part ="show",   result="juntuan_zhan_result", list = {"gongxian","rob_exp"} })
            self:_addPart( {part="wait",   } )
        end
    elseif self._type == FightEnd.TYPE_CROSSWAR then
        if not self._isWin then
            self:_addPart( {part ="begin", result =self._status or FightEnd.RESULT_SHI_BAI})
            self:_addPart( {part ="show", result ="lose", list = {"crosswar_score", "crosswar_medal"} })
            self:_addPart( {part ="lose_guide"} )
            self:_addPart( {part ="wait"} )
        else
            self:_addPart( {part ="begin", result = self._status or FightEnd.RESULT_SHENG_LI})
            self:_addPart( {part ="show", result ="win", list = {"crosswar_score", "crosswar_medal"} })
            self:_addPart( {part ="wait"} )
        end
    elseif self._type == FightEnd.TYPE_HARD_RIOT then
        if not self._isWin then
            self:_addPart( {part="begin",   result="lost"})
            self:_addPart( {part="lose_guide",   } )
            self:_addPart( {part="show",    result="lost", list = {"money", "exp"}  } )
            self:_addPart( {part="wait",   } )
        else
            self:_addPart( {part ="begin",  result= "win"})
            self:_addPart( {part ="show",   result="win", list = {"money", "exp",} })
            self:_addPart( {part="wait",   } )

            if self._data.awards and #self._data.awards > 0 then
                self:_addPart( {part ="dropItems"})
                self:_addPart( {part="wait",   } )
            end
            self:_checkLevelUp(data.exp)
        end
    elseif self._type == FightEnd.TYPE_REBEL_BOSS then
        self:_addPart( {part ="begin",  result= "rebelboss_result"})
        self:_addPart( {part ="show",   result= "rebelboss_result", list = {"damage", "rongyu","zhangongboss", "rebelboss_result"} })
        self:_addPart( {part="wait",   } )
    elseif self._type == FightEnd.TYPE_ROB_RICE then
        if not self._isWin then
            self:_addPart( {part="begin",   result=self._status  or FightEnd.RESULT_SHI_BAI})
            self:_addPart( {part ="show",   result="lose", list = {"rice_prestige", "foster_pill", "rice"} })
            self:_addPart( {part="lose_guide",   } )

            self:_addPart( {part="wait",   } )
        else
            self:_addPart( {part ="begin",  result= self._status or FightEnd.RESULT_SHENG_LI})
            self:_addPart( {part ="show",   result="win", list = {"rice_prestige", "foster_pill", "rice"} })
            
            self:_addPart( {part="wait",   } )
        end
    elseif self._type == FightEnd.TYPE_CRUSADE then
        if not self._isWin then
            self:_addPart( {part ="begin", result =self._status or FightEnd.RESULT_SHI_BAI})
            self:_addPart( {part ="lose_guide"} )
            self:_addPart( {part ="wait"} )
        else
            self:_addPart( {part ="begin", result = "win"})
            self:_addPart( {part ="show", result ="win", list = {"crusade_pet_point", "crusade_award_size"}})
            self:_addPart( {part ="wait"} )
        end
    elseif self._type == FightEnd.TYPE_WUSH_BOSS then
        if not self._isWin then
            self:_addPart( {part="begin",   result=self._status  or FightEnd.RESULT_SHI_BAI})
            self:_addPart( {part="lose_guide",   } )

            self:_addPart( {part="wait",   } )
        else
            self:_addPart( {part ="begin",  result= self._status or FightEnd.RESULT_SHENG_LI})
            self:_addPart( {part ="show",   result="win", list = {"wush_boss_baowujinglianshi", "wush_boss_yinliang", "wush_boss_jipinjinglianshi", "wush_boss_hongsezhuangbeijinghua", "wush_boss_shizhuangjinghua"} })
            
            self:_addPart( {part="wait",   } )
        end
    elseif self._type == FightEnd.TYPE_DUNGEON_DAILY then
        if not self._isWin then
            self:_addPart( {part="begin",   result=self._status  or FightEnd.RESULT_SHI_BAI})
            self:_addPart( {part="lose_guide",   } )

            self:_addPart( {part="wait",   } )
        else
            self:_addPart( {part ="begin",  result= self._status or FightEnd.RESULT_SHENG_LI})
            self:_addPart( {part ="show",   result="win", list = {
                "dungeon_daily_tuposhi",
                "dungeon_daily_jinlongbaobao",
                "dungeon_daily_yinliang",
                "dungeon_daily_jipinjinglianshi", 
                "dungeon_daily_huangjinjingyanbaowu", 
                "dungeon_daily_baowujinglianshi"
                } })
            
            self:_addPart( {part="wait",   } )
        end
    elseif self._type == FightEnd.TYPE_CROSSPVP then
        if not self._isWin then
            self:_addPart( {part="begin",   result=self._status  or FightEnd.RESULT_SHI_BAI})
            self:_addPart( {part="lose_guide",   } )

            self:_addPart( {part="wait",   } )
        else
            self:_addPart( {part ="begin",  result= self._status or FightEnd.RESULT_SHENG_LI})
            self:_addPart( {part ="show",   result="win", list = {"engaged_score", } })
            self:_addPart( {part="wait",   } )
        end
    elseif self._type == FightEnd.TYPE_EX_DUNGEON then
        if not self._isWin then
            self:_addPart( {part="begin",   result= self._status or FightEnd.RESULT_SHI_BAI})
            self:_addPart( {part="lose_guide",   } )
            self:_addPart( {part="wait",   } )
        else
            self:_addPart( {part ="begin",  result= self._status or FightEnd.RESULT_SHENG_LI})
            self:_addPart( {part="ex_dungeon",   } )
            self:_addPart( {part="wait",   } )

            self:_checkLevelUp(data._nExp + data._nExpAdd)
        end
    elseif self._type == FightEnd.TYPE_DAILY_PVP then
        if not self._isWin then
            self:_addPart( {part="begin",   result= self._status or FightEnd.RESULT_SHI_BAI})
            self:_addPart( {part ="show",   result="daily_pvp_lose", list = {"daily_pvp_score", "daily_pvp_honor", "left_time"} })
            self:_addPart( {part="wait",   } )
        else
            self:_addPart( {part ="begin",  result= self._status or FightEnd.RESULT_SHENG_LI})
            self:_addPart( {part ="show",   result="daily_pvp_win", list = {"daily_pvp_score", "daily_pvp_honor", "left_time"} })
            self:_addPart( {part="wait",   } )
        end
    elseif self._type == FightEnd.TYPE_HERO_SOUL then
        if not self._isWin then
            self:_addPart( {part="begin",   result= self._status or FightEnd.RESULT_SHI_BAI})
            self:_addPart( {part="lose_guide",   } )
            self:_addPart( {part="wait",   } )
        else
            self:_addPart( {part ="begin",  result= self._status or FightEnd.RESULT_SHENG_LI})
            self:_addPart( {part ="show",   result="", list = {"hero_soul_point", } })
            self:_addPart( {part="hero_soul",   } )
            self:_addPart( {part="wait",   } )
        end
    end



    self:registerTouchEvent(false,true,0)



end




function FightEnd:_addPart(  info )
    table.insert(self._parts, info)
end

function FightEnd:_playNextPart(  )
    local info = table.remove(self._parts, 1)

    if info == nil then
        self:_end()           
    else
        if info.part == "begin" then
            if info.result == "lost" or info.result == FightEnd.RESULT_XI_BAI or info.result == FightEnd.RESULT_SHI_BAI or info.result == FightEnd.RESULT_CAN_BAI then
                local part =require("app.scenes.common.fightend.parts.BeginLose").new( self._data, info.result, handler(self, self._playNextPart))
                self._content:addChild(part)
                part:play()
                G_SoundManager:playSound(require("app.const.SoundConst").GameSound.BATTLE_LOSE)

            elseif info.result == "win" or info.result == "vip_result" or info.result == "arean_win" or  info.result == "rebelboss_result" or  info.result == "moshen_result" or info.result == FightEnd.RESULT_WANSHENG or info.result == FightEnd.RESULT_SHENG_LI or info.result == FightEnd.RESULT_XIAN_SHENG or info.result == "juntuan_result" then
            
                local part =require("app.scenes.common.fightend.parts.BeginStarWin").new(self._data, info.result, handler(self, self._playNextPart))
                self._content:addChild(part)
                part:play()
                G_SoundManager:playSound(require("app.const.SoundConst").GameSound.BATTLE_WIN)
            
            end
        elseif info.part == "show" then
            local part =require("app.scenes.common.fightend.parts.ShowValueList").new(info.result,info.list, self._data, handler(self, self._playNextPart))
            if info.result == "moshen_result" then 
                part:setPositionY(-100) 
            end
            self._content:addChild(part)
            part:play()
        elseif info.part == "levelup" then
            --local part =require("app.scenes.common.fightend.parts.LevelUpPart").new(info.old_level, info.new_level, handler(self, self._playNextPart))
            --self._content:addChild(part)
            --part:play()
            local levelup = require("app.scenes.common.fightend.parts.LevelupLayer").create(info.old_level, info.new_level, function ( ... )
                self:_playNextPart()
            end)
            self._content:addChild(levelup)

            
        elseif info.part == "lose_guide" then

            local part =require("app.scenes.common.fightend.parts.LoseGuide").new( handler(self, self._playNextPart))
            self._content:addChild(part)
            part:play()

        elseif info.part == "wait" then
            self._waiting = true
         
            
            local part =require("app.scenes.common.fightend.parts.WaitContinue").new()
            self._content:addChild(part)
            part:play()
        elseif info.part == "dropItems" then
            local part =require("app.scenes.common.fightend.parts.DropItems").new(self._data.awards, handler(self, self._playNextPart))
            --挂机里面需要往下移动一点
            if self._type == FightEnd.TYPE_CITY or self._type == FightEnd.TYPE_TIME_DUNGEON then
                part:setPositionY(-200)
            end
            self._content:addChild(part)
            part:play()
        elseif info.part == "pickCard" then
            local part =require("app.scenes.common.fightend.parts.PickCard").new(self._data.picks, handler(self, self._playNextPart))
            self._content:addChild(part)
            part:play()     
        elseif info.part == "ex_dungeon" then
            local part =require("app.scenes.common.fightend.parts.ExDungeonLayer").new(self._data, handler(self, self._playNextPart))
            self._content:addChild(part)
            part:play()    
        elseif info.part == "hero_soul" then
            local part =require("app.scenes.common.fightend.parts.AwardIconLayer").new(self._data, handler(self, self._playNextPart))
            self._content:addChild(part)
            part:play()    
        end
        
    end
end

function FightEnd:onLayerUnload( ...  )
    --这里用来卸载资源, 本类似乎没什么需要卸载的
end

function FightEnd:_end(   )
    self:removeFromParentAndCleanup(true)

    if self._endCallback ~= nil then
        self._endCallback()
    else
        dump(self)
    end

    uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_FINISH_PLAY_FIGHTEND)
end

function FightEnd:play(  )
    self:_playNextPart()
end

--返回 是否升级, 新等级, 老等级
function FightEnd:_getLevelUpData( exp )
    local totalExp = FightEnd.getTotalExpLevelRange(1, G_Me.userData.level -1) + G_Me.userData.exp
    local oldTotalExp = totalExp - exp
    local leftExp, level = FightEnd.getLevelExpFromTotalExp(oldTotalExp)
    local hasLevelup = level <G_Me.userData.level 
    return  hasLevelup, G_Me.userData.level, level
end

--返回 是否升级, 新等级, 老等级
function FightEnd:_checkLevelUp( exp )
    local hasLevelup,new_level, level = self:_getLevelUpData(exp)
    if hasLevelup then

        self:_addPart( {part ="levelup", old_level = level, new_level = new_level})
        self:_addPart( {part="wait",   } )

    end
end


function FightEnd:onTouchEnd( xpos, ypos )
    if self._waiting  then
        print("cancel waiting")
        self._content:removeAllChildrenWithCleanup(true)
        self._waiting = false
        self:_playNextPart()
    end


    --self:removeFromParentAndCleanup(true)
    return true
end

require("app.cfg.role_info")

--计算某个等级区间所需要的经验
function FightEnd.getTotalExpLevelRange(startLevel, endLevel)
    local total = 0
    for i=startLevel,endLevel do
        total = total  + role_info.get(i).experience
    end

    return total
end

--根据某个总经验, 计算他的等级和剩余经验
function FightEnd.getLevelExpFromTotalExp(totalExp)
    local len = role_info:getLength()
    local level = 1
    for i=1,len do
        local info = role_info.indexOf(i)
        if info.experience <= totalExp then
            totalExp = totalExp - info.experience
            level = i 
        else
            level = i 
            break
        end
    end

    return totalExp, level
end

return FightEnd