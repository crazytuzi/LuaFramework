--[[
 --
 -- add by vicky
 -- 2014.08.19
 --
 --]]

local data_item_item = require("data.data_item_item")
local data_card_card = require("data.data_card_card")

local MAX_ZORDER = 11113
local RequestInfo = require("network.RequestInfo")
local DuobaoResult = class("DuobaoResult", function (data)
    return require("utility.ShadeLayer").new()
end)


-- 胜利并得到碎片
function DuobaoResult:initWinDebris(data)
    local proxy = CCBProxy:create()
    local node = CCBuilderReaderLoad("duobao/duobao_win_debris.ccbi", proxy, self._rootnode)
    node:setPosition(display.width/2, display.height/2)
    self:addChild(node)

    -- 名称
    local nameColor = ResMgr.getItemNameColor(self._getItemId) 
    local nameLbl = ui.newTTFLabelWithShadow({ 
        text = self._debrisName, 
        size = 30, 
        color = nameColor, 
        shadowColor = ccc3(0,0,0), 
        font = FONTS_NAME.font_haibao, 
        align = ui.TEXT_ALIGN_CENTER 
        })
    
    nameLbl:setPosition(nameLbl:getContentSize().width/2, 0)
    self._rootnode["debrisNameLbl"]:addChild(nameLbl)

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

function DuobaoResult:setBtnEnabled(b, isSnatchAgain)
    if isSnatchAgain == false then 
        if self._rootnode["snatchBtn"] ~= nil then 
            self._rootnode["snatchBtn"]:setEnabled(b) 
        end 
    end  

    if self._rootnode["replayBtn"] then
        self._rootnode["replayBtn"]:setEnabled(b)
    end

    if self._rootnode["confirmBtn"] then
        self._rootnode["confirmBtn"]:setEnabled(b)
    end
end

function DuobaoResult:setBtnDisabled(isSnatchAgain)
    self:setBtnEnabled(false, isSnatchAgain)
    self:performWithDelay(function()
        self:setBtnEnabled(true, isSnatchAgain)
    end, 2)
end


-- 胜利但没有得到碎片
function DuobaoResult:initWin(data)
    local proxy = CCBProxy:create()
    local node = CCBuilderReaderLoad("duobao/duobao_win.ccbi", proxy, self._rootnode)
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

    local zhenrongBtn = self._rootnode["zhenrongBtn"]
    local zhanbaoBtn = self._rootnode["zhanbaoBtn"]
    if self._isNPC then
        zhenrongBtn:setVisible(false)
        zhanbaoBtn:setPosition(display.width/2 - zhenrongBtn:getContentSize().width/2, zhanbaoBtn:getPositionY())
    end

    zhenrongBtn:setEnabled(false)
    zhanbaoBtn:setEnabled(false) 

    self._rootnode["snatchBtn"]:setEnabled(false)
    self._rootnode["replayBtn"]:setEnabled(false)
    self._rootnode["confirmBtn"]:setEnabled(false)

    local snatchAgainBtn = self._rootnode["snatchBtn"] 
    snatchAgainBtn:addHandleOfControlEvent(function()
        snatchAgainBtn:setEnabled(false) 
        self:setBtnDisabled(true)
        -- 判断耐力是否足够
        if game.player.m_energy < 2 then 
            local layer = require("game.Duobao.DuobaoBuyMsgBox").new({}) 
            game.runningScene:addChild(layer, self:getZOrder() + 1)  
            snatchAgainBtn:setEnabled(true)  
        else
            self._snatchAgain(self._snatchIndex) 
        end

        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))

    end, CCControlEventTouchUpInside)
--
--    self._rootnode["zhenrongBtn"]:addHandleOfControlEvent(function()
--        self._rootnode["zhenrongBtn"]:setEnabled(false)
--        snatchAgainBtn:setEnabled(false)
--
--        push_scene(require("game.form.EnemyFormScene").new(1, self._enemyAcc))
--
--        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
--        self:performWithDelay(function()
--            self._rootnode["zhenrongBtn"]:setEnabled(true)
--            snatchAgainBtn:setEnabled(true)
--        end, 1)
--
--    end, CCControlEventTouchUpInside)

   

    self:createTreasure(true, data)

     
end


-- 创建战斗胜利后，玩家需要选择的宝箱
function DuobaoResult:createTreasure(lostDebris, data)
    -- 掉落物品[默认第一个为获得]
    local rtnAry = data["3"]
    dump(rtnAry) 

    display.addSpriteFramesWithFile("ui/ui_duobao.plist", "ui/ui_duobao.png")

    local function createOpenEffect(baoxiang) 
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
        -- 默认第一个为选中的奖励
        local item = rtnAry[index]
        rtnAry[index] = rtnAry[1]
        rtnAry[1] = item 

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
            -- 若升级则直接跳转界面 弹出开启新系统提示 
            if self._isLevelup == true then 
                self:confirmFunc() 
            end 

            for i, v in ipairs(rtnAry) do 
                if i ~= index then 
                    -- createOpenEffect(self._rootnode["baoxiang_" .. tostring(i)]) 
                    openTreasure(i)
                end
            end

            if self._getDebris == false then 
                self._rootnode["snatchBtn"]:setEnabled(true)
            end 

            if lostDebris == true then
                self._rootnode["zhenrongBtn"]:setEnabled(true)
                -- self._rootnode["zhanbaoBtn"]:setEnabled(true)
            end

            self._rootnode["replayBtn"]:setEnabled(true)
            self._rootnode["confirmBtn"]:setEnabled(true) 

            -- icon 道具详情 
            for i, v in ipairs(rtnAry) do 
                self._rootnode["icon_" .. i]:setTouchEnabled(true) 
            end 

        end   

        for i, v in ipairs(rtnAry) do 
            local id = v.id 
            if i == index and id == self._debrisId then 
                self._getDebris = true 
            end 

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

            -- icon 道具详情 
            rewardIcon:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
                if (event.name == "began") then 
                    rewardIcon:setTouchEnabled(false) 
                    local itemInfo = require("game.Huodong.ItemInformation").new({
                        id = id,
                        type = v.t,
                        endFunc = function()
                            rewardIcon:setTouchEnabled(true) 
                        end
                        })  
                    self:addChild(itemInfo, MAX_ZORDER)
                    return true 
                end 
            end) 

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
                GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_fanpai)) 
                PostNotice(NoticeKey.REMOVE_TUTOLAYER)
                onClickCard(i) 
                for j, vbao in ipairs(rtnAry) do
                    self._rootnode["baoxiang_" .. j]:setTouchEnabled(false)
                end
                return true
            end
        end)
    end
   
    -- local tutoBtn = self._rootnode["baoxiang_2"]
    -- TutoMgr.addBtn("duobao_shengli_baoxiang",tutoBtn)
    -- TutoMgr.addBtn("duobao_shengli_confirm",self._rootnode["confirmBtn"])

end


-- 战斗失败
function DuobaoResult:initLost(data)
    local proxy = CCBProxy:create()
    local node = CCBuilderReaderLoad("duobao/duobao_lost.ccbi", proxy, self._rootnode)
    node:setPosition(display.width/2, display.height/2)
    self:addChild(node)

    local zhenrongBtn = self._rootnode["zhenrongBtn"]
    if self._isNPC then
        zhenrongBtn:setVisible(false)
    end

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
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding)) 
            GameStateManager:ChangeState(GAME_STATE.STATE_JIANGHULU)
        end, CCControlEventTouchUpInside)

    -- 真气
    self._rootnode["zhenqiBtn"]:addHandleOfControlEvent(
        function(eventName,sender)
            GameStateManager:ChangeState(GAME_STATE.STATE_JINGYUAN)
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
        end, CCControlEventTouchUpInside)


end


function DuobaoResult:onEnter()
  -- ResMgr.delayFunc(0.5,function() 
  --    TutoMgr.active()
  --           end)
    
end


function DuobaoResult:onExit()
    -- TutoMgr.removeBtn("duobao_shengli_baoxiang")
    -- TutoMgr.removeBtn("duobao_shengli_confirm")    
    display.removeSpriteFramesWithFile("ui/ui_duobao.plist", "ui/ui_duobao.png")
    CCTextureCache:sharedTextureCache():removeUnusedTextures()

    ResMgr.ReleaseUIArmature("zhandoushengli")
    ResMgr.ReleaseUIArmature("zhandoushengli_zi")
    ResMgr.ReleaseUIArmature("baoxiangdakaiguangxiao_xunhuan")
    
end


function DuobaoResult:confirmFunc() 
    if self._getDebris == true then
        CCDirector:sharedDirector():popToRootScene()
    else
        pop_scene()
    end
end


function DuobaoResult:ctor(param) 
    self._isLevelup = false   
    self._rootnode = {}
    local data = param.data
    local name = param.name
    self._isNPC = param.isNPC
    self._enemyAcc = param.enemyAcc
    self._debrisName = param.title
    self._snatchIndex = param.snatchIndex 
    self._snatchAgain = param.snatchAgain
    self._debrisId = param.debrisId 

    -- ResMgr.createBefTutoMask(self)

    dump(data)

    self:setNodeEventEnabled(true)
    -- 抢夺结果
    local result = data["1"][1]
    -- 是否获得碎片
    self._getItemId = data["5"]
    -- 奖励货币类型
    local coinAry = data["4"]
    -- 消耗的耐力值
    local resisVal = data["6"]
    -- 敌方战斗力
    local attack = data["7"]
    -- 当前等级
    local beforeLevel = game.player.getLevel()  -- 之前等级
    local curlevel = data["9"] or beforeLevel 
    local curExp = data["10"] or 0 

    game.player:updateMainMenu({
        lv = curlevel,
        exp = curExp
    })

    self._getDebris = false
    if (result == 2) then
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_shibai))
        self:initLost(data)
    elseif (result == 1) then
        GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_shengli))
        if (self._getItemId == 0) then
            self:initWin(data)
        else
            self._getDebris = true 
            self:initWinDebris(data) 
        end 
    end

    -- 判断是否升级 
    local curLv = game.player:getLevel() 
    if beforeLevel < curLv then 
        self._isLevelup = true 
        local curNail = game.player:getNaili()
        local shengjiLayer = require("game.Shengji.ShengjiLayer").new({
            level = beforeLevel, 
            uplevel = curLv, 
            naili = curNail, 
            curExp = curExp 
            })
        self:addChild(shengjiLayer, MAX_ZORDER)
    end

    self._rootnode["battle_value_left"]:setString(tostring(game.player:getBattlePoint()))
    self._rootnode["battle_value_right"]:setString(tostring(attack))
    self._rootnode["nailiLbl"]:setString("-" .. resisVal)

    self._rootnode["player_name_left"]:setString(game.player.getPlayerName())
    self._rootnode["player_name_right"]:setString(name)

    for _, v in ipairs(coinAry) do
        if v.id == 2 then
            self._rootnode["yinbiLbl"]:setString("+" .. tostring(v.n))
        elseif v.id == 6 then
            self._rootnode["expLbl"]:setString("+" .. tostring(v.n))
        end
    end

    self._rootnode["confirmBtn"]:addHandleOfControlEvent(
        function(eventName,sender)
            self:setBtnDisabled(false)
            self:confirmFunc() 
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
            PostNotice(NoticeKey.REMOVE_TUTOLAYER)
        end,
        CCControlEventTouchUpInside)

    local replayBtn = self._rootnode["replayBtn"] 
    replayBtn:addHandleOfControlEvent(
        function(eventName,sender)

            self:setBtnDisabled(false)
            local function closeFunc(node)
                node:removeFromParentAndCleanup(true) 
                replayBtn:setEnabled(true) 
            end 
            self:addChild(require("game.Duobao.DuobaoBattleReplayLayer").new(data, closeFunc), MAX_ZORDER)
            GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
        end,
        CCControlEventTouchUpInside)


    if self._rootnode["zhenrongBtn"] ~= nil then 
        self._rootnode["zhenrongBtn"]:setVisible(false)
    end

    if self._rootnode["zhanbaoBtn"] ~= nil then 
        self._rootnode["zhanbaoBtn"]:setVisible(false)
    end


end


return DuobaoResult