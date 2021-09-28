 --[[
 --
 -- @authors shan 
 -- @date    2014-06-03 17:40:45
 -- @version 
 --
 --]]

require("game.GameConst")



local MAX_ZORDER = 11113 

local ArenaResult = class("ArenaResult", function (data)
	return require("utility.ShadeLayer").new()
end) 


-- 创建战斗胜利后，玩家需要选择的宝箱
function ArenaResult:createTreasure(lostDebris, data)
    -- 掉落物品[默认第一个为获得]
    local rtnAry = data["3"]
    dump(rtnAry) 

    display.addSpriteFramesWithFile("ui/ui_duobao.plist", "ui/ui_duobao.png")

    local function createOpenEffect(baoxiang)
        -- -- 宝箱打开特效
        -- local qishouEffect = ResMgr.createArma({
        --     resType = ResMgr.UI_EFFECT,
        --     armaName = "baoxiangdakaiguangxiao_qishou",
        --     finishFunc = function()
        --     -- 宝箱循环特效
        --         local xunhuanEffect = ResMgr.createArma({
        --             resType = ResMgr.UI_EFFECT,
        --             armaName = "baoxiangdakaiguangxiao_xunhuan",
        --             isRetain = true
        --         })
        --         xunhuanEffect:setPosition(baoxiang:getContentSize().width/2, baoxiang:getContentSize().height/2)
        --         baoxiang:addChild(xunhuanEffect, -10)
        --     end,
        --     isRetain = false
        -- })

        -- qishouEffect:setPosition(baoxiang:getContentSize().width/2, baoxiang:getContentSize().height/2)
        -- baoxiang:addChild(qishouEffect, -10)
        
        -- 宝箱循环特效
        local xunhuanEffect = ResMgr.createArma({
            resType = ResMgr.UI_EFFECT,
            armaName = "baoxiangdakaiguangxiao_xunhuan",
            isRetain = true
        })
        xunhuanEffect:setPosition(baoxiang:getContentSize().width/2, baoxiang:getContentSize().height/2)
        baoxiang:addChild(xunhuanEffect, -10)
    end

    local function onClickCard(index)
        local time = 0.2

        -- 属性图标
        local function checkShuxingIcon(index)
            local tag = index 
            local v = rtnAry[tag]
            local canhunIcon = self._rootnode["canhun_" .. tag]
            local suipianIcon = self._rootnode["suipian_" .. tag] 

            if v.t == 3 then
                -- 装备碎片
                suipianIcon:setVisible(true) 
            elseif v.t == 5 then
                -- 残魂(武将碎片)
                canhunIcon:setVisible(true) 
            end

            self._rootnode["icon_" .. tostring(tag)]:setVisible(true) 
            self._rootnode["reward_name_".. tostring(tag)]:setVisible(true)
        end

        local function openTreasure(index) 
            local function resetFrame(node)
                node:setDisplayFrame(display.newSprite("#db_card_front_image.png"):getDisplayFrame()) 
                node:runAction(transition.sequence({
                    CCScaleTo:create(time, 1.0, 1.0) 
                    }))
                checkShuxingIcon(index) 
            end 

            local baoxing = self._rootnode["baoxiang_" .. index] 
            baoxing:stopAllActions() 
            baoxing:runAction(transition.sequence({
                        CCScaleTo:create(time, 0.01, 1.0), 
                        CCCallFuncN:create(resetFrame)
                    })) 
        end 

        -- 其他两个宝箱全部打开
        local function openAllBaoxiang()
            for i, v in ipairs(rtnAry) do 
                if i ~= index then 
                    -- createOpenEffect(self._rootnode["baoxiang_" .. tostring(i)]) 
                    openTreasure(i)
                end
            end

            if lostDebris then
                self._rootnode["snatchBtn"]:setEnabled(true)
                self._rootnode["zhenrongBtn"]:setEnabled(true)
                -- self._rootnode["zhanbaoBtn"]:setEnabled(true)
            end

            self._rootnode["replayBtn"]:setEnabled(true)
            self._rootnode["confirmBtn"]:setEnabled(true)
        end 

        -- 默认第一个为选中的奖励
        local item = rtnAry[index]
        rtnAry[index] = rtnAry[1]
        rtnAry[1] = item

        local data_item_item = require("data.data_item_item")
        local data_card_card = require("data.data_card_card")
        for i, v in ipairs(rtnAry) do 
            local id = v.id 
            local rewardIcon = self._rootnode["icon_" .. i]
            local resType =  ResMgr.getResType(v.t) 
            ResMgr.refreshIcon({
                id = id, 
                resType = resType, 
                itemBg = rewardIcon, 
                iconNum = v.n, 
                isShowIconNum = false, 
                numLblSize = 22, 
                numLblColor = ccc3(0, 255, 0), 
                numLblOutColor = ccc3(0, 0, 0) 
            })
            rewardIcon:setTag(i) 
            rewardIcon:setVisible(false)

            self._rootnode["canhun_" .. i]:setVisible(false)
            self._rootnode["suipian_" .. i]:setVisible(false) 

            -- 名称
            local nameKey = "reward_name_" .. tostring(i) 
            local nameColor = ccc3(255, 255, 255)
            local name 
            if resType == ResMgr.ITEM or resType == ResMgr.EQUIP then 
                
                nameColor = ResMgr.getItemNameColor(id)
                name = data_item_item[id].name
            elseif resType == ResMgr.HERO then 
                
                nameColor = ResMgr.getHeroNameColor(id)
                name = data_card_card[id].name 
            end

            local nameLbl = ui.newTTFLabelWithShadow({
                text = name,
                size = 20,
                color = nameColor,
                shadowColor = ccc3(0,0,0),
                font = FONTS_NAME.font_fzcy,
                align = ui.TEXT_ALIGN_LEFT
                })
            
            nameLbl:setPosition(-nameLbl:getContentSize().width/2, nameLbl:getContentSize().height/2) 
            self._rootnode[nameKey]:addChild(nameLbl) 
            self._rootnode[nameKey]:setVisible(false) 
        end 

        local baoxing = self._rootnode["baoxiang_" .. index] 
        baoxing:stopAllActions() 
        baoxing:runAction(transition.sequence({
                    CCScaleTo:create(time, 0.01, 1.0), 
                    CCCallFuncN:create(function(node)
                        node:setDisplayFrame(display.newSprite("#db_card_front_image.png"):getDisplayFrame()) 
                        checkShuxingIcon(index) 
                        node:runAction(transition.sequence({
                            CCScaleTo:create(time, 1.0, 1.0),
                            CCCallFuncN:create(function(node)
                                createOpenEffect(node)
                                end), 
                            CCDelayTime:create(time), 
                            CCCallFunc:create(openAllBaoxiang)
                            }))
                    end)
                })) 
    end 

    local function scaleFunc(node)
        node:runAction(CCRepeatForever:create(transition.sequence({
            CCScaleTo:create(0.15, 0.8),
            CCScaleTo:create(0.15, 1.0),
            CCDelayTime:create(0.5)
        })))
    end

    for i, v in ipairs(rtnAry) do
        local baoxiang = self._rootnode["baoxiang_" .. i]

        baoxiang:runAction(transition.sequence({
            CCDelayTime:create((i - 1) * 0.3),
            CCCallFuncN:create(scaleFunc)
        }))

        baoxiang:setTouchEnabled(true)
        baoxiang:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
            if (event.name == "began") then
                onClickCard(i) 
                for j, vbao in ipairs(rtnAry) do
                    self._rootnode["baoxiang_" .. j]:setTouchEnabled(false)
                end
                return true
            end
        end)
    end
end


-- 战斗胜利
function ArenaResult:initWin( data )

    local proxy = CCBProxy:create()
    local node = CCBuilderReaderLoad("arena/arena_win.ccbi", proxy, self._rootnode)
    node:setPosition(display.width/2, display.height/2)
    self:addChild(node) 

    -- 特效     
    local effWin = ResMgr.createArma({
        resType = ResMgr.UI_EFFECT, 
        armaName = "zhandoushengli", 
        isRetain = true 
    }) 
    effWin:setPosition(self._rootnode["tag_title_anim"]:getContentSize().width/2, self._rootnode["tag_title_anim"]:getContentSize().height) 
    self._rootnode["tag_title_anim"]:addChild(effWin) 
    local effTextWin = ResMgr.createArma({
        resType = ResMgr.UI_EFFECT, 
        armaName = "zhandoushengli_zi", 
        isRetain = true 
    }) 
    effTextWin:setPosition(self._rootnode["tag_title_anim"]:getContentSize().width/2, self._rootnode["tag_title_anim"]:getContentSize().height) 
    self._rootnode["tag_title_anim"]:addChild(effTextWin) 

    self._rootnode["replayBtn"]:setEnabled(false)
    self._rootnode["confirmBtn"]:setEnabled(false)

    self:createTreasure(false, data) 
end


-- 失败
function ArenaResult:initLost(data)
    local proxy = CCBProxy:create()
    local node = CCBuilderReaderLoad("arena/arena_lost.ccbi", proxy, self._rootnode)
    node:setPosition(display.width/2, display.height/2)
    self:addChild(node)

    local zhenrongBtn = self._rootnode["zhenrongBtn"]
    -- if self._isNPC then
        zhenrongBtn:setVisible(false)
    -- end 

    -- 武将强化
    self._rootnode["wujiangBtn"]:addHandleOfControlEvent(
        function(eventName,sender)
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
            GameStateManager:ChangeState(GAME_STATE.STATE_XIAKE)
        end,
        CCControlEventTouchUpInside)

    -- 装备强化 
    self._rootnode["zhuangbeiBtn"]:addHandleOfControlEvent(
        function(eventName,sender)
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
            GameStateManager:ChangeState(GAME_STATE.STATE_EQUIPMENT)
        end,
        CCControlEventTouchUpInside)

    -- 阵容
    self._rootnode["goZhenrongBtn"]:addHandleOfControlEvent(
        function(eventName,sender)
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
            GameStateManager:ChangeState(GAME_STATE.STATE_ZHENRONG)
        end, CCControlEventTouchUpInside)

    -- 侠客送礼
    self._rootnode["heroRewardBtn"]:addHandleOfControlEvent(
        function(eventName,sender)
            GameStateManager:ChangeState(GAME_STATE.STATE_JIANGHULU)
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
        end, CCControlEventTouchUpInside)

    -- 真气
    self._rootnode["zhenqiBtn"]:addHandleOfControlEvent(
        function(eventName,sender)
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
            GameStateManager:ChangeState(GAME_STATE.STATE_JINGYUAN) 
        end, CCControlEventTouchUpInside)
end 


function ArenaResult:ctor(param) 
    local data = param.data
    self._rootnode = {}

    -- local shengwangNum = data["9"] or 0 
    
    -- 抢夺结果
    local result = data["1"][1] 
    -- 奖励货币类型
    local coinAry = data["4"]
    -- 信息 
    local objData = data["5"]

    if (result == 1) then
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_shengli))
        self:initWin(data) 
    elseif (result == 2) then    
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_shibai))
        self:initLost(data)
    else
        --不是赢 就是输
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_shibai))
        self:initLost(data)
    end

    -- dump(objData) 

    self._rootnode["battle_value_left"]:setString(tostring(objData.attack1))
    self._rootnode["battle_value_right"]:setString(tostring(objData.attack2))
    -- self._rootnode["nailiLbl"]:setString("-" .. objData.resisVal)
    self._rootnode["nailiLbl"]:setString("-2")

    self._rootnode["player_name_left"]:setString(objData.name1)
    self._rootnode["player_name_right"]:setString(objData.name2)

    for _, v in ipairs(coinAry) do
        if v.id == 2 then
            self._rootnode["yinbiLbl"]:setString("+" .. tostring(v.n))
        elseif v.id == 5 then 
            self._rootnode["shengwangLbl"]:setString("+" .. tostring(v.n)) 
        elseif v.id == 6 then
            self._rootnode["expLbl"]:setString("+" .. tostring(v.n))
        end
    end

    self._rootnode["confirmBtn"]:addHandleOfControlEvent(
        function(eventName,sender)
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
            GameStateManager:ChangeState(GAME_STATE.STATE_ARENA)
        end,
        CCControlEventTouchUpInside)

    local replayBtn = self._rootnode["replayBtn"] 
    replayBtn:addHandleOfControlEvent(
        function(eventName,sender)
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
            replayBtn:setEnabled(false) 
            local function closeFunc(node)
                node:removeFromParentAndCleanup(true) 
                replayBtn:setEnabled(true) 
            end
            self:addChild(require("game.Duobao.DuobaoBattleReplayLayer").new(data, closeFunc), MAX_ZORDER) 
        end,
        CCControlEventTouchUpInside) 

end


function ArenaResult:onExit( ... )
    CCTextureCache:sharedTextureCache():removeUnusedTextures()

    ResMgr.ReleaseUIArmature("baoxiangdakaiguangxiao_xunhuan")
    ResMgr.ReleaseUIArmature("zhandoushengli")
    ResMgr.ReleaseUIArmature("zhandoushengli_zi")

    display.removeSpriteFramesWithFile("ui/ui_duobao.plist", "ui/ui_duobao.png")
end

return ArenaResult
