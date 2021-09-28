
--[[
    文件名：BattleLayer
	描述：战斗基础场景，处理传入参数。
	创建人：luoyibo
	创建时间：2016.08.12
-- ]]

require("ComBattle.BattleInit")

--[[
    params:
        data                战斗数据（普通战斗和剧情战斗都是通过这里传入）
                            普通战斗既服务器饭后的FightInfo结构
                            剧情战斗既require("ComBattle.Script.xxxx")
        storyData           战斗前人物气泡对话数据(脚本配置)
        map                 地图数据
        challengeStr        (BDD)神装塔结点通关条件(BddNodeModel中starTypeStr字段)
        callback            战斗回调函数,返回值为一个结构callback(data)
                            data = {
                                            -- 是否进行了跳过
                                    isskip   = isSkip,
                                            -- 跳过时，默认战斗结果为true
                                    result   = isSkip and true or self.data:get_battle_finishValue(),
                                            -- 战斗过程
                                    data     = bd.func.serialize(record),
                                            -- 挑战结果(有通关条件时有效)
                                    optional = self.data:getChallengeValue(),
                                            -- 伤害(XXBZ时有效)
                                    damage   = damage,
                                            -- 奖励(XXBZ时有效)
                                    reward   = reward,
                                            -- 我方剩余主将数量
                                    leftHero = self.data:getAliveHero(),
                                            -- 最终托管状态
                                    trustee  = self.data:get_ctrl_trustee_state(),
                                            -- 伤害记录
                                    damageRecord = self.data.battle_.damageRecord,
                                            {
                                                [stageIdx] = {
                                                    [pos] = {
                                                        hp, -- 治疗量
                                                        dp, -- 伤害量
                                                    }
                                                }
                                            }
                            }
        ----------------以上必需，以下可选---------------------
        startPet { 开场宠物控制
            fspView         是否显示先手值比拼(默认true)
        }
        trustee {
            viewable        是否显示托管按钮，与托管状态无关(bool)
            state           当前托管状态bd.trusteeState(见BattleDefine.lua)
                            bd = {
                                -- 托管状态定义
                                trusteeState = {
                                    eNormal            = 1, -- 正常
                                    eSpeedUp           = 2, -- 加速
                                    eSpeedUpAndTrustee = 3, -- 加速托管
                                },
                            }

            executable      用于控制托管功能是否执行的函数,在点击托管按钮时判断。
                            executable = function()
                                return true 返回true表示执行托管按钮功能
                            end
        }
        skip {
            viewable        是否显示跳过按钮(bool)
            clickable       控制跳过按钮是否可用点击的功能函数，不可点时在界面上表现为按钮置灰
                            clickable = function(roundIdx, stageIdx) roundIdx回合数，stageIdx关卡数
                                return true 返回true表示跳过按钮可点
                            end
            executable      用于控制跳过功能能否执行的条件函数,在点击跳过按钮时判断。
                            condition = function(roundIdx, stageIdx) roundIdx回合数，stageIdx关卡数
                                return true 返回true表示执行跳过功能
                            end
        }
        skill {
            viewable        技能条是否显示(bool),也表示是否可以手动放技能
        }
        skillFeature {
            enable          是否显示技能切屏
        }
        camera {
            enable          是否启用相机
        }
        rebornNum {
            enemyEnable     敌方重生显示
            friendlyEnable  友方重生显示
        }
        ----------------以下特殊功能需求---------------------
        debug               测试模式，普通战斗不管
    return:
        NULL
]]

local BattleLayer = class("BattleLayer", function(params)
    local layer = cc.Layer:create()

    -- 启用node事件
    layer:enableNodeEvents()

    -- 屏蔽下层点击
    bd.func.registerSwallowTouch({node = layer})

    return layer
end)


function BattleLayer:ctor(params)
    bd.layer = self
    math.randomseed(os.time())

    bd.log.debug(params, "params for [BattleLayer]")

    bd.assert(params and params.data, TR("战斗数据不存在"))
    params.data = clone(params.data)

    if bd.project == "project_huanzhu" then
        params.startPet = {
             fspView = false,
         }
     end

    -- 用于摆放子节点
    self.parentLayer = cc.Layer:create()
    self:addChild(self.parentLayer)
    self.heroPlant = self.parentLayer

    local data_file
    local process_file
    if params.data.guider then
        -- 脚本战斗
        data_file    = require("ComBattle.Data.BattleData_guide")
        process_file = require("ComBattle.Process.BattleProcess_guide")
    else
        -- 正常战斗
        data_file    = require("ComBattle.Data.BattleData")
        process_file = require("ComBattle.Process.BattleProcess")
    end

    --
    self.spdy = require("ComBattle.Data.BattleSpdy").new()

    -- 数据中心
    self.data = data_file.new({
        data  = params,
        spdy  = self.spdy,
        layer = self,
    })
    -- 战斗流程控制
    self.process = process_file.new({
        battleLayer = self,
        battleData  = self.data,
        spdy        = self.spdy,
    })

    -- 校验
    if debug_server_verify then
        require("ComLogic.jsonlua")
        self.verify_str_ = _json._encode(params.data)
    end

    self.loadingLayer_ = require("ComBattle.UICtrl.BDLoadingLayer").new({
        battleData = self.data,
        spdy       = self.spdy,
        async      = true,
        callback   = function(layer)
            layer:setContentSize(cc.size(0, 0))
            layer:setVisible(false)
            self:start(params)
        end,
    })
    self.parentLayer:addChild(self.loadingLayer_)
end


function BattleLayer:start(params)
    -- 战斗地图/场景
    require("ComBattle.UICtrl.BDMap").new({
        mapFile     = params.map,
        battleLayer = self,
        time        = nil,
        guider      = params.data.guider,
    })

    -- 界面控件（回合数、托管、跳过、、、）
    local uiCtrlLayer = require("ComBattle.UICtrl.BDCtrlLayer").new({
        battleData    = self.data,
        battleProcess = self.process,
    })
    self:addChild(uiCtrlLayer, bd.ui_config.zOrderCtrl)
    self.ctrlLayer_ = uiCtrlLayer


    -- 用于管理消息监听
    self.battleWatcher = require("ComBattle.UICtrl.BDCtrlWatcher").new({
        battleData    = self.data,
        battleProcess = self.process,
    })

    self.data:on("ctrl_skip_state", function(skip)
        if skip then
            return self.process:skip()
        end
    end)

    -- 监听战斗开始
    self.process
        :on(bd.event.eBattleBegin, handler(self, self.onBattleBegin))

    -- 监听回合开始
        :on(bd.event.eStageBegin, handler(self, self.onStageBegin))

    -- 监听回合结束
        :on(bd.event.eStageEnd, handler(self, self.onStageEnd))

    -- 监听战斗结束
        :on(bd.event.eBattleEnd, handler(self, self.onBattleEnd))

    -- Go Go Go
        :battleBegin()
end


function BattleLayer:onExit()
    bd.layer = nil

end


-- @战斗开始
function BattleLayer:onBattleBegin()
    -- 开始监听消息
    self.battleWatcher:on()
end


-- @关卡开始
function BattleLayer:onStageBegin()

end

-- @关卡结束
function BattleLayer:onStageEnd()
    -- 清除主将
    self:cleanHeroNode()
end


-- @战斗结束
function BattleLayer:onBattleEnd(isSkip)
    self.data:set_battle_speed(bd.CONST.speed.normal)

    local damage, reward = self.data:getCoinReward()
    local record = self.data:get_battle_records()
    record.verify_str = self.verify_str_
    local data = {
                -- 是否进行了跳过
        isskip   = isSkip,
                -- 跳过时，默认战斗结果为true
        result   = isSkip and true or self.data:get_battle_finishValue(),
                -- 战斗过程
        data     = bd.func.serialize(record),
                -- 挑战结果(有通关条件时有效)
        optional = self.data:getChallengeValue(),
                -- 伤害(XXBZ时有效)
        damage   = damage,
                -- 奖励(XXBZ时有效)
        reward   = reward,
                -- 我方剩余主将数量
        leftHero = self.data:getAliveHero(),
                -- 最终托管状态
        trustee  = self.data:get_ctrl_trustee_state(),
                -- 伤害记录
        damageRecord = self.data.battle_.damageRecord,
    }

    local function finish_()
        -- 清理资源
        self:clean()

        local params = self.data:get_battle_params()
        local cb = params.callback
        if cb then
            -- 回调
            bd.log.debug(data, "battle end")
            params.callback = nil -- 确保只回调一次
            cb(data)
        else
            bd.log.warnning(TR("战斗结束:没有callback?"))
        end
    end

    if isSkip then
        data.skipCallback = function(...)
            -- self.process:setResult(...)
        end
    elseif self.data:get_battle_finishValue() == true and bd.patch and bd.patch.onBattleEnd then
        return  bd.patch.onBattleEnd(finish_)
    end

    finish_()
end


-- @清除上一关卡的主将
function BattleLayer:cleanHeroNode()
    -- 清除前一关卡主将
    local heroList = self.data:getHeroNodeList()
    for _, v in pairs(heroList) do
        v:unscheduleUpdate()
        v:removeFromParent()
    end
    self.data.stage_.nodeList = {}
end


-- @清除资源
function BattleLayer:clean()
    -- 释放LogicCore，开启多线程时，需要调用release释放资源
    local core = self.data:get_battle_LogicCore()
    local _ = core and core:release()
    self.data:set_battle_LogicCore(nil)

    bd.func.performWithDelay(self.parentLayer, function()
        if loadingLayer_ then
            -- loadingLayer_:onExit()时:释放骨骼资源
            self.loadingLayer_:removeFromParent()
        end
    end, 0)
end

-- @伪镜头效果
function BattleLayer:cameraTo(pos, scale, delay, cb)
    local time = 0.1

    local layer = self.parentLayer
    layer:setIgnoreAnchorPointForPosition(false)
    layer:setAnchorPoint(cc.p(pos.x / bd.ui_config.width, pos.y / bd.ui_config.height))
    layer:setPosition(pos)

    if delay <= 0 then
        layer:setScale(scale)
        return cb and cb()
    end

    layer:stopActionByTag(bd.CONST.actionTag.eCamera)
    if layer.lastCameraCB ~= nil then
        layer.lastCameraCB()
    end
    layer.lastCameraCB = cb

    local action = cc.Sequence:create({
        cc.EaseOut:create(cc.ScaleTo:create(delay, scale), 1),
        cc.CallFunc:create(function()
            layer.lastCameraCB = nil
            return cb and cb()
        end)
    })
    action:setTag(bd.CONST.actionTag.eCamera)
    layer:runAction(action)
end

return BattleLayer
