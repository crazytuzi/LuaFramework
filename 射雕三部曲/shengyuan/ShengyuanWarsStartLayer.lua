--[[
    文件名: ShengyuanWarsStartLayer.lua
    描述: 决战桃花岛初始进入页面
    创建人: chenzhong
    创建时间: 2017.9.2
--]]

local ShengyuanWarsStartLayer = class("ShengyuanWarsStartLayer", function(params)
    return display.newLayer()
end)

require("shengyuan.ShengyuanWarsStatusHelper")
require("shengyuan.ShengyuanWarsHelper")
require("shengyuan.ShengyuanWarsUiHelper")

--[[
    params:
    {
        autoShowTeamLayer                   -- 是否自动弹出队伍页面，默认不显示
    }
--]]
function ShengyuanWarsStartLayer:ctor(params)
    ui.registerSwallowTouch({node = self})

    -- 创建页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    -- 导航栏
    local tempLayer = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        currentLayerType = Enums.MainNav.eChallenge,
        topInfos = {ResourcetypeSub.eVIT, ResourcetypeSub.eGodDomainGlory, ResourcetypeSub.eDiamond}
    })
    self:addChild(tempLayer)

    -- 初始化UI
    self:initUI()

    -- 获取赛季信息
    self:requestGetInfo()
end

-- 初始化UI
function ShengyuanWarsStartLayer:initUI()
    -- 背景图
    self.mBgSprite = ShengyuanWarsUiHelper:createWaveWaterSprite("jzthd_26.jpg")
    self.mBgSprite:setPosition(320, 568)
    self.mParentLayer:addChild(self.mBgSprite)
    self.mBgSize = self.mBgSprite:getContentSize()

    -- 创建码头
    local wharfSprite = ui.newSprite("jzthd_27.png")
    wharfSprite:setAnchorPoint(0, 0)
    wharfSprite:setPosition(0, 391)
    self.mBgSprite:addChild(wharfSprite)

    -- 飞机sliderview父节点
    self.mSliderNode = cc.Node:create()
    self.mSliderNode:setContentSize(640, 636)
    self.mSliderNode:setPosition(0, 400)
    self.mBgSprite:addChild(self.mSliderNode)

    -- 下边加一张背景图
    local downBg = ui.newSprite("c_19.png")
    downBg:setAnchorPoint(0.5, 1)
    downBg:setPosition(320, 415)
    self.mBgSprite:addChild(downBg)
    for i=1,2 do
        local yaoqingBg = ui.newSprite("jzthd_01.png")
        yaoqingBg:setPosition(320, i == 1 and 320 or 190)
        self.mBgSprite:addChild(yaoqingBg)
    end     

    -- 标题、倒计时等标签
    self:addSomeLabels()

    -- 排行榜、商店、规则、关闭按钮
    self:addFuncBtns()

    -- 宝箱奖励父节点
    self.mChestNode = cc.Node:create()
    self.mBgSprite:addChild(self.mChestNode)

    -- 匹配按钮
    self.mMatchBtnList = self:createMatchBtn()

    -- 匹配中动画精灵
    self.mMatchSprite = ui.newSprite("jzthd_02.png")
    self.mMatchSprite:setScale(0.9)
    self.mMatchSprite:setPosition(320, 480)
    self.mBgSprite:addChild(self.mMatchSprite)
    self.mMatchSprite:setVisible(false)

    -- 更换船只的按钮
    self.changeShipBtn = ui.newButton({
        normalImage = "c_28.png",
        text = TR("船只培养"),
        clickAction = function()
            LayerManager.addLayer({
                name = "shengyuan.ShengyuanPlaneLevelUpLayer",
                data = {
                    ownPlaneList = self.mMountInfo,
                    callback = function()
                        self:refreshSliderNode()
                    end,
                },
                cleanUp = false
            })
        end
    })
    self.changeShipBtn:setPosition(320, 480)
    self.mBgSprite:addChild(self.changeShipBtn)

    -- 更换时装的按钮
    local fashionBtn = ui.newButton({
        normalImage = "sz_3.png",
        clickAction = function()
        	if not ModuleInfoObj:moduleIsOpen(ModuleSub.eQbanShizhuang, true) then
        		return
        	end
        	local shengyuanState = ShengyuanWarsStatusHelper:getGodDomainTeamState()
        	if shengyuanState == 2 then
        		ui.showFlashView(TR("匹配中不能更换时装"))
        		return
        	end
            LayerManager.addLayer({
                name = "fashion.QFashionSelectLayer",
                data = {
                    combatType = 1,
                    callback = function()
                        self:refreshSliderNode()
                    end,
                },
                cleanUp = false
            })
        end
    })
    fashionBtn:setPosition(500, 650)
    self.mBgSprite:addChild(fashionBtn)

    -- 注册匹配成功的通知事件
    Notification:registerAutoObserver(self.mBgSprite, function ()
        print("inter mapLayer......")
        LayerManager.addLayer({name = "shengyuan.ShengyuanWarsMapLayer", zOrder=Enums.ZOrderType.eDefault + 4})
    end, {ShengyuanWarsHelper.Events.eShengyuanWarsEnterBattle})
end

-- -- 刷新主页飞船
function ShengyuanWarsStartLayer:refreshSliderNode()
    self.mSliderNode:removeAllChildren()

    -- 创建飞船传参数
    local item = {
        MountModelId = ShengyuanWarsHelper:getMountModelId(),
        showWave = true,
    }
    local planeSprite = ShengyuanWarsUiHelper:createBoat(item)
    planeSprite:setPosition(440, 380)
    self.mSliderNode:addChild(planeSprite)
    -- 船的小幅领衔
    planeSprite:runAction(cc.RepeatForever:create(cc.Sequence:create({
        cc.MoveBy:create(1.5, cc.p(0, 8)), cc.MoveBy:create(1.5, cc.p(0, -8))
        })))
end

-- 添加标题、倒计时等标签
function ShengyuanWarsStartLayer:addSomeLabels()
    -- 顶部标签
    self.mTopLabel = ui.createLabelWithBg({
        bgFilename = "zdfb_10.png",
        labelStr = TR("决战桃花岛"),
        fontSize = 26,
        color = cc.c3b(0x46, 0x22, 0x0d),
        alignType = ui.TEXT_ALIGN_CENTER
    })
    self.mTopLabel:setPosition(320, 1010)
    self.mBgSprite:addChild(self.mTopLabel)

    -- 倒计时标签
    self.mCountDownLabel = ui.createLabelWithBg({
        bgFilename = "c_25.png",
        bgSize = cc.size(340, 45),
        labelStr = TR("本赛季倒计时:%s", MqTime.formatAsDay(0)),
        color = cc.c3b(0x20, 0xff, 0x09),
        outlineColor = cc.c3b(0x21, 0x46, 0x21),
        alignType = ui.TEXT_ALIGN_CENTER
    })
    self.mCountDownLabel:setPosition(320, 965)
    self.mBgSprite:addChild(self.mCountDownLabel)

    -- 挂机惩罚倒计时标签
    self.mHangOutLabel = ui.createLabelWithBg({
        bgFilename = "c_25.png",
        bgSize = cc.size(340, 45),
        labelStr = TR("挂机惩罚倒计时"),
        color = cc.c3b(0xff, 0x00, 0x00),
        outlineColor = cc.c3b(0x21, 0x46, 0x21),
        alignType = ui.TEXT_ALIGN_CENTER
    })
    self.mHangOutLabel:setPosition(320, 925)
    self.mBgSprite:addChild(self.mHangOutLabel)
    self.mHangOutLabel:setVisible(false)
end

-- 添加排行榜、商店、规则、关闭按钮
function ShengyuanWarsStartLayer:addFuncBtns()
    -- 规则按钮
    local ruleBtn = ui.newButton({
        normalImage = "c_72.png",
        clickAction = function()
            local rulesData = {
                [1] = TR("1、决战桃花岛为10V10战场，玩家至多5人组队进入战场"),
                [2] = TR("2、战场中心的桃花岛为主战场，旁边有4个神符点"),
                [3] = TR("3、占领桃花岛可以获得积分，每十秒获得一次积分。占领人数越多，获得积分越多"),
                [4] = TR("4、周围有的4个神符点每一段时间就可以刷新4种不同的神符（血量恢复，攻防属性翻倍，击杀积分翻倍，直接获得积分）"),
                [5] = TR("5、自己的一方的码头每一段时间就会刷新3个五毒散（下场战斗结束时随机消灭敌人一个角色）"),
                [6] = TR("6、首先达到2000分的队伍获得胜利"),
                [7] = TR("7、帮派组队会增加帮派积分"),
                [8] = TR("8、每周为一个赛季，赛季结束时，根据帮派积分排名发放奖励"),
            }
            MsgBoxLayer.addRuleHintLayer(TR("规则提示"), rulesData, cc.size(598, 474))
        end
    })
    ruleBtn:setPosition(60, 1000)
    self.mBgSprite:addChild(ruleBtn)

    -- 关闭按钮
    local closeBtn = ui.newButton({
        normalImage = "c_29.png",
        clickAction = function()
            LayerManager.removeLayer(self)
        end
    })
    closeBtn:setPosition(640 - 60, 1000)
    self.mBgSprite:addChild(closeBtn)

    -- 排行榜、商店按钮
    local btnInfos = {
        [1] = {
            image = "tb_16.png",
            clickAction = function()
                local layer = LayerManager.addLayer({
                    name = "shengyuan.ShengyuanWarsRankLayer",
                    cleanUp = false,
                })
            end
        },
        [2] = {
            image = "tb_178.png",
            clickAction = function()
                local layer = LayerManager.addLayer({
                    name = "shengyuan.ShengyuanWarsShopLayer",
                    cleanUp = false,
                })
            end
        },
    }

    for idx, item in pairs(btnInfos) do
        local tempBtn = ui.newButton({
            normalImage = item.image,
            position = cc.p(60, 900 - (idx - 1) * 110),
            clickAction = item.clickAction
        })
        self.mBgSprite:addChild(tempBtn)
    end
end

-- 刷新宝箱奖励父节点
function ShengyuanWarsStartLayer:refreshChestNode()
    self.mChestNode:removeAllChildren()

    -- 个人奖励宝箱
    local personalChestBtn = ui.newButton({
        normalImage = "tb_75.png",
        position = cc.p(125, 320),
        clickAction = function(btnObj)
            LayerManager.addLayer({
                name = "shengyuan.ShengyuanWarsChestRewardLayer",
                data = {
                    winNum = self.mGodDomainMainInfo.SingleWinNum,
                    todayNum = self.mGodDomainMainInfo.SingleChallengeNum,
                    chestType = Enums.ShengyuanWarsChestType.ePersonal,
                    drawStr = self.mGodDomainMainInfo.SingleRewardState,
                    callback = function(rewardState)
                        self.mGodDomainMainInfo.SingleRewardState = rewardState

                        -- 刷新宝箱状态
                        self:refreshChestNode()
                    end
                },
                cleanUp = false
            })
        end
    })
    self.mChestNode:addChild(personalChestBtn)

    local pCanDrawList = string.splitBySep(self.mGodDomainMainInfo.SingleRewardState, ",")
    local isCanDraw = pCanDrawList and next(pCanDrawList) and true or false
    -- 如果有奖励信息，就闪动宝箱
    if isCanDraw then
        ui.setWaveAnimation(personalChestBtn)
    end
    -- 所需胜利场数，所需参与场数
    local personalNeedNum = nil
    local personNeedPart = nil
    -- 获取配置表数据(保证有序表，按升序排列)
    local rewardRelation = {}
    for k, v in pairs(ShengyuanwarsWinboxPersonRelation.items) do
        table.insert(rewardRelation, v)
    end
    table.sort(rewardRelation, function(a, b)
        return a.winNum < b.winNum
    end)
    -- 给所需胜利场数赋值
    for i, v in ipairs(rewardRelation) do
        if isCanDraw then
            if self.mGodDomainMainInfo.SingleWinNum <= v.winNum then
                personalNeedNum = v.winNum
                break
            end
        else
            if self.mGodDomainMainInfo.SingleWinNum < v.winNum then
                personalNeedNum = v.winNum
                break
            end
        end
    end
    personalNeedNum = personalNeedNum or rewardRelation[#rewardRelation].winNum
    
    -- 所需参与场数赋值
    for i, v in ipairs(rewardRelation) do
        if isCanDraw then
            if self.mGodDomainMainInfo.SingleChallengeNum <= v.partNum then
                personNeedPart = v.partNum
                break
            end
        else
            if self.mGodDomainMainInfo.SingleChallengeNum < v.partNum then
                personNeedPart = v.partNum
                break
            end
        end
    end
    personNeedPart = personNeedPart or rewardRelation[#rewardRelation].partNum

    -- 胜利场数
    local personalWinLabel = ui.newLabel({
        text = TR("领取条件:胜利%s/%s场\n        或参与%s/%s场", self.mGodDomainMainInfo.SingleWinNum, personalNeedNum,
            self.mGodDomainMainInfo.SingleChallengeNum, personNeedPart),
        color = cc.c3b(0x46, 0x22, 0x0d),
        size = 24,
        anchorPoint = cc.p(0, 0.5),
        x = 190,
        y = 320
    })
    self.mChestNode:addChild(personalWinLabel)

    -- 帮派奖励宝箱
    local familyChestBtn = ui.newButton({
        normalImage = "tb_75.png",
        position = cc.p(125, 190),
        clickAction = function(btnObj)
            LayerManager.addLayer({
                name = "shengyuan.ShengyuanWarsChestRewardLayer",
                data = {
                    winNum = self.mGodDomainMainInfo.TeamWinNum,
                    todayNum = self.mGodDomainMainInfo.TeamChallengeNum,
                    chestType = Enums.ShengyuanWarsChestType.eGuild,
                    drawStr = self.mGodDomainMainInfo.TeamRewardState,
                    callback = function(rewardState)
                        self.mGodDomainMainInfo.TeamRewardState = rewardState

                        -- 刷新宝箱状态
                        self:refreshChestNode()
                    end
                },
                cleanUp = false
            })
        end
    })
    familyChestBtn:setScale(0.9)
    self.mChestNode:addChild(familyChestBtn)

    local fCanDrawList = string.splitBySep(self.mGodDomainMainInfo.TeamRewardState, ",")
    local isCanDraw = fCanDrawList and next(fCanDrawList) and true or false
    -- 如果有奖励信息，就闪动宝箱
    if isCanDraw then
        ui.setWaveAnimation(familyChestBtn)
    end
    -- 所需胜利场数，所需参与场数
    local teamNeedNum = nil
    local teamNeedPart = nil
    -- 获取配置表数据(保证有序表，按升序排列)
    local rewardRelation = {}
    for k, v in pairs(ShengyuanwarsWinboxGuildRelation.items) do
        table.insert(rewardRelation, v)
    end
    table.sort(rewardRelation, function(a, b)
        return a.winNum < b.winNum
    end)
    -- 给所需胜利场数赋值
    for i, v in ipairs(rewardRelation) do
        if isCanDraw then
            if self.mGodDomainMainInfo.TeamWinNum <= v.winNum then
                teamNeedNum = v.winNum
                break
            end
        else
            if self.mGodDomainMainInfo.TeamWinNum < v.winNum then
                teamNeedNum = v.winNum
                break
            end
        end
    end
    teamNeedNum = teamNeedNum or rewardRelation[#rewardRelation].winNum
    -- 所需参与场数赋值
    for i, v in ipairs(rewardRelation) do
        if isCanDraw then
            if self.mGodDomainMainInfo.TeamChallengeNum <= v.partNum then
                teamNeedPart = v.partNum
                break
            end
        else
            if self.mGodDomainMainInfo.TeamChallengeNum < v.partNum then
                teamNeedPart = v.partNum
                break
            end
        end
    end
    teamNeedPart = teamNeedPart or rewardRelation[#rewardRelation].partNum

    -- 胜利场数
    local teamWinLabel = ui.newLabel({
        text = TR("领取条件:胜利%s/%s场\n        或参与%s/%s场", self.mGodDomainMainInfo.TeamWinNum, teamNeedNum,
            self.mGodDomainMainInfo.TeamChallengeNum, teamNeedPart),
        color = cc.c3b(0x46, 0x22, 0x0d),
        size = 24,
        anchorPoint = cc.p(0, 0.5),
        x = 190,
        y = 190
    })
    self.mChestNode:addChild(teamWinLabel)
end

-- 匹配按钮
function ShengyuanWarsStartLayer:createMatchBtn()
    local tempBtnList = {}
    local tempBtnInfo = {
        [1] = {
            image = "jzthd_03.png",
            text = "",
            color = Enums.Color.eGreen_D,
            outlineColor = Enums.Color.eBlack,
            clickAction = function ()
                local curGameModelId = self.mGodDomainMainInfo.GameModuleId
                if self.mGodDomainMainInfo.State == 2 and curGameModelId > 0 and curGameModelId ~= ModuleSub.eShengyuanWars then 
                    ui.showFlashView(TR("%s正在匹配中，不能匹配桃花岛！", ModuleSubModel.items[curGameModelId].name))
                    return
                end 
                if not self.mGodDomainMainInfo or not next(self.mGodDomainMainInfo) then
                    ui.showFlashView(TR("数据为空!!!"))
                    return
                end

                -- 赛季已结束
                if self.mGodDomainMainInfo and self.mGodDomainMainInfo.SeasonState and self.mGodDomainMainInfo.SeasonState == 0 then
                    ui.showFlashView(TR("还未到开启时间哟!"))
                    return
                end

                local shengyuanState = ShengyuanWarsStatusHelper:getGodDomainTeamState()
                local shengyuanLeaderId = ShengyuanWarsStatusHelper:getGodDomainLeaderId()
                if shengyuanState == 0 and self.mGodDomainMainInfo.GameModuleId == ModuleSub.eShengyuanWars then      -- 初始状态
                    -- 开始匹配
                    self:matchConfirm()
                elseif shengyuanState == 1 and self.mGodDomainMainInfo.GameModuleId == ModuleSub.eShengyuanWars then  -- 队伍中
                    -- 是否为队长
                    if shengyuanLeaderId == PlayerAttrObj:getPlayerAttrByName("PlayerId") then
                        -- 开始匹配
                        self:matchConfirm()
                    else
                        ui.showFlashView(TR("请耐心等待队长开始匹配!!!"))
                    end
                elseif shengyuanState == 2 and self.mGodDomainMainInfo.GameModuleId == ModuleSub.eShengyuanWars then  -- 匹配中
                    -- 家族匹配中且不是队长
                    if shengyuanLeaderId ~= EMPTY_ENTITY_ID and shengyuanLeaderId ~= PlayerAttrObj:getPlayerAttrByName("PlayerId") then
                        ui.showFlashView(TR("只有队长才能取消匹配!!!"))
                    -- 单人匹配或家族匹配是队长
                    else
                        local cancelRet = ShengyuanWarsHelper:cancelMatch(function(retValue)
                            if retValue.Code == 0 then
                                ui.showFlashView(TR("取消匹配!"))
                                self:requestGetInfo()
                            end
                        end)
                        if not cancelRet then
                            ShengyuanWarsUiHelper:exitGame(true)
                        end
                    end
                elseif shengyuanState == 3 and self.mGodDomainMainInfo.GameModuleId == ModuleSub.eShengyuanWars then  -- 游戏中
                    -- 进入游戏
                    LayerManager.addLayer({
                        name = "shengyuan.ShengyuanWarsMapLayer"
                    })
                end
            end
        },
        [2] = {
            --[[
                存在被踢出队伍的情况
                1.若在主页面被踢出队伍直接飘窗提示被踢出队伍，重新请求服务器主页面信息刷新页面
                2.若在队伍页面被踢出队伍则关闭队伍页面，并飘窗提示被踢出队伍，同时刷新页面（回调数据刷新或者回调请求服务器刷新数据后刷新页面）
            --]]-- todo
            image = "jzthd_04.png",
            text = "",
            color = Enums.Color.eGreen_D,
            outlineColor = Enums.Color.eBlack,
            clickAction = function ()
                local guildInfo = GuildObj:getGuildInfo()
                if not Utility.isEntityId(guildInfo.Id) then
                    ui.showFlashView(TR("请先加入帮派"))
                    return
                end

                local curGameModelId = self.mGodDomainMainInfo.GameModuleId
                if self.mGodDomainMainInfo.State == 2 and curGameModelId > 0 and curGameModelId ~= ModuleSub.eShengyuanWars then 
                    ui.showFlashView(TR("%s正在匹配中，不能匹配桃花岛！", ModuleSubModel.items[curGameModelId].name))
                    return
                end 

                -- 赛季已结束
                if self.mGodDomainMainInfo and self.mGodDomainMainInfo.SeasonState and self.mGodDomainMainInfo.SeasonState == 0 then
                    ui.showFlashView(TR("还未到开启时间哟!"))
                    return
                end

                local shengyuanState = ShengyuanWarsStatusHelper:getGodDomainTeamState()
                local shengyuanLeaderId = ShengyuanWarsStatusHelper:getGodDomainLeaderId()
                -- dump(shengyuanState,"shengyuanState")
                -- dump(shengyuanLeaderId,"shengyuanLeaderId")
                if shengyuanState == 0 then          -- 初始状态
                    self:createTeam()
                elseif shengyuanState == 1 then      -- 队伍中
                    self:showTeamLayer()
                elseif shengyuanState == 2 then  -- 匹配中
                    if shengyuanLeaderId == EMPTY_ENTITY_ID then
                        ui.showFlashView(TR("单人匹配中，请取消匹配后重试！"))
                    else
                        self:showTeamLayer()
                    end
                elseif shengyuanState == 3 then  -- 游戏中
                    -- 单人
                    if shengyuanLeaderId and shengyuanLeaderId == EMPTY_ENTITY_ID then
                        ui.showFlashView(TR("已经进入战斗！"))
                    else
                        self:showTeamLayer()
                    end
                end
            end
        }
    }

    for index, item in pairs(tempBtnInfo) do
        local tempBtn
        tempBtn = ui.newButton({
            normalImage = item.image,
            text = item.text,
            textColor = item.color,
            outlineColor = item.outlineColor,
            clickAction = item.clickAction,
        })
        tempBtn:setPosition(510, index == 1 and 320 or 190)
        self.mBgSprite:addChild(tempBtn)
        tempBtnList[index] = tempBtn

        -- 刷新按钮描述
        local tempFunc
        if index == 1 then
            tempFunc = function()
                -- 默认可以点击
                local touchEnable = true

                -- 赛季已结束
                if self.mGodDomainMainInfo and self.mGodDomainMainInfo.SeasonState == 0 then
                    print("11111")
                    touchEnable = false
                end

                -- 赛季已结束
                if self.mGodDomainMainInfo and self.mGodDomainMainInfo.EndTime then
                    if self.mGodDomainMainInfo.EndTime - Player:getCurrentTime() <= 0 then
                        print("22222")
                        touchEnable = false
                    end
                end

                -- 挂机惩罚中
                if self.mGodDomainMainInfo and self.mGodDomainMainInfo.HangUpResetTime then
                    if self.mGodDomainMainInfo.HangUpResetTime - Player:getCurrentTime() > 0 then
                        print("33333")
                        touchEnable = false
                    end
                end

                local shengyuanState = ShengyuanWarsStatusHelper:getGodDomainTeamState()
                print(shengyuanState,"shengyuanStateSinge")
                if shengyuanState == 0 and self.mGodDomainMainInfo.GameModuleId == ModuleSub.eShengyuanWars then      -- 初始状态
                    tempBtn:loadTextureNormal("jzthd_03.png")
                    tempBtn:loadTexturePressed("jzthd_03.png")

                    self.mMatchSprite:setVisible(false)
                elseif shengyuanState == 1 and self.mGodDomainMainInfo.GameModuleId == ModuleSub.eShengyuanWars then  -- 队伍中
                    tempBtn:loadTextureNormal("jzthd_03.png")
                    tempBtn:loadTexturePressed("jzthd_03.png")

                    self.mMatchSprite:setVisible(false)
                elseif shengyuanState == 2 and self.mGodDomainMainInfo.GameModuleId == ModuleSub.eShengyuanWars then  -- 匹配中
                    tempBtn:loadTextureNormal("jzthd_28.png")
                    tempBtn:loadTexturePressed("jzthd_28.png")
                    
                    self.mMatchSprite:setVisible(true)
                    -- 更换船只按钮置灰
                    self.changeShipBtn:setVisible(false)
                elseif shengyuanState == 3 and self.mGodDomainMainInfo.GameModuleId == ModuleSub.eShengyuanWars then  -- 游戏中
                    tempBtn:loadTextureNormal("jzthd_03.png")
                    tempBtn:loadTexturePressed("jzthd_03.png")

                    self.mMatchSprite:setVisible(false)
                end

                tempBtn:setEnabled(touchEnable)
            end
        elseif index == 2 then
            tempFunc = function()
                -- 默认可以点击
                local touchEnable = true

                -- 赛季已结束
                if self.mGodDomainMainInfo and self.mGodDomainMainInfo.SeasonState == 0 then
                    touchEnable = false
                end

                -- 赛季已结束
                if self.mGodDomainMainInfo and self.mGodDomainMainInfo.EndTime then
                    if self.mGodDomainMainInfo.EndTime - Player:getCurrentTime() <= 0 then
                        touchEnable = false
                    end
                end

                -- 挂机惩罚中
                if self.mGodDomainMainInfo and self.mGodDomainMainInfo.HangUpResetTime then
                    if self.mGodDomainMainInfo.HangUpResetTime - Player:getCurrentTime() > 0 then
                        touchEnable = false
                    end
                end

                if ShengyuanWarsStatusHelper:getGodDomainLeaderId() ~= EMPTY_ENTITY_ID then
                    tempBtn:loadTextureNormal("jzthd_04.png")
                    tempBtn:loadTexturePressed("jzthd_04.png")
                else
                    tempBtn:loadTextureNormal("jzthd_04.png")
                    tempBtn:loadTexturePressed("jzthd_04.png")
                end

                tempBtn:setEnabled(touchEnable)
            end
        end

        tempBtn.refresh = tempFunc
    end

    -- 刷新节点序号，不传则全部刷新
    function tempBtnList.refreshMatchBtn(index)
        if not index then
            tempBtnList[1].refresh()
            tempBtnList[2].refresh()
            return
        end

        index = index <= 1 and 1 or index
        index = index >= 2 and 2 or index
        tempBtnList[index].refresh()
    end

    return tempBtnList
end

-- 显示组队页面
function ShengyuanWarsStartLayer:showTeamLayer(index)
    HttpClient:request({
        moduleName = "ShengyuanTeam",
        methodName = "GetMyTeamInfo",
        svrMethodData = {},
        callbackNode = self,
        callback = function(response)
            -- 容错处理
            if response.Status ~= 0 then
                return
            end

            -- 设置队伍信息
            ShengyuanWarsHelper:setTeamInfo(response.Value.TeamInfo.TeamMember)
            self.mMatchBtnList.refreshMatchBtn() -- 刷新按钮

            if index and index == 2 then 
                -- 不需要添加组队页面
                return
            end     
            LayerManager.addLayer({
                name = "shengyuan.ShengyuanWarsTeamLayer",
                data = {
                    refreshCallback = function()
                        self:requestGetInfo(2)
                    end,
                },
                cleanUp = false,
            })
        end
    })
end

-- 进入组队页面
function ShengyuanWarsStartLayer:createTeam()
    LayerManager.addLayer({
        name    = "shengyuan.ShengyuanWarsTeamLayer",
        data = {
            refreshCallback = function()
                self:requestGetInfo(2)
            end,
        },
        cleanUp = false,
    })
end

-- 刷新倒计时标签，开始倒计时
function ShengyuanWarsStartLayer:refreshCountDown()
    -- 赛季倒计时
    if self.mGodDomainMainInfo.EndTime - Player:getCurrentTime() > 0 and self.mGodDomainMainInfo.SeasonState == 1 then
        -- 刷新倒计时
        if self.mCountDownSche then
            self.mCountDownLabel:stopAllActions()
            self.mCountDownSche = nil
        end
        self.mCountDownSche = Utility.schedule(self.mCountDownLabel, function()
                self:updateCountDown()
            end, 1)
    else
        self.mCountDownLabel:setString(TR("每日18点到23点开放"))
    end

    -- 惩罚倒计时
    if self.mGodDomainMainInfo.HangUpResetTime and self.mGodDomainMainInfo.HangUpResetTime - Player:getCurrentTime() > 0 then
        self.mHangOutLabel:setVisible(true)
        -- 挂机倒计时
        if self.mHangOutCountDownSche then
            self.mHangOutLabel:stopAllActions()
            self.mHangOutCountDownSche = nil
        end
        self.mHangOutCountDownSche = Utility.schedule(self.mHangOutLabel, function()
                self:updateHangOutCountDown()
            end, 1)
    else
        self.mHangOutLabel:setVisible(false)
    end
end

-- 更新倒计时
function ShengyuanWarsStartLayer:updateCountDown()
    local lastTime = self.mGodDomainMainInfo.EndTime - Player:getCurrentTime()
    if lastTime <= 0 or self.mGodDomainMainInfo.SeasonState == 0 then
        local str = TR("每日18点到23点开放")
        self.mCountDownLabel:setString(str)
        self.mCountDownLabel:stopAllActions()
        self.mCountDownSche = nil
    else
        self.mCountDownLabel:setString(TR("本赛季倒计时:%s", MqTime.formatAsDay(lastTime)))
    end
end

-- 更新挂机倒计时
function ShengyuanWarsStartLayer:updateHangOutCountDown()
    local lastTime = self.mGodDomainMainInfo.HangUpResetTime - Player:getCurrentTime()
    if lastTime > 0 then
        self.mHangOutLabel:setString(TR("挂机惩罚倒计时:%s", MqTime.formatAsDay(lastTime)))
    else
        self.mHangOutLabel:stopAllActions()
        self.mHangOutCountDownSche = nil
        self.mHangOutLabel:setVisible(false)

        self:requestGetInfo()
    end
end

-- 根据状态刷新页面
function ShengyuanWarsStartLayer:dealWithState(notPop)
    -- 判断当前状态
    --dump(ShengyuanWarsStatusHelper:getGodDomainTeamState(),"stateDealWithState")
    if self.mGodDomainMainInfo.GameModuleId == ModuleSub.eShengyuanWars and (ShengyuanWarsStatusHelper:getGodDomainTeamState() == 3 or ShengyuanWarsStatusHelper:getGodDomainTeamState() == 2) then
        -- 已经连接了匹配战斗
        ShengyuanWarsHelper:setUrl(self.mGodDomainMainInfo.IP)
        ShengyuanWarsHelper:connect(function(retValue)
            if retValue == nil or retValue.Code == 0 then
                if ShengyuanWarsStatusHelper:getGodDomainTeamState() == 3 then
                    -- 手动通知进入战场页面
                    Notification:postNotification(ShengyuanWarsHelper.Events.eShengyuanWarsEnterBattle)
                end
            end
        end)
    elseif self.mGodDomainMainInfo and self.mGodDomainMainInfo.HangUpResetTime - Player:getCurrentTime() > 0  then
        return
    elseif ShengyuanWarsStatusHelper:getGodDomainLeaderId() ~= EMPTY_ENTITY_ID then
    end
end

-- 队伍匹配确认弹窗
function ShengyuanWarsStartLayer:matchConfirm()
    --dump(ShengyuanWarsHelper:getTeamInfo(),"ShengyuanWarsHelper:getTeamInfo()")
    if table.nums(ShengyuanWarsHelper:getTeamInfo()) == 0 then
        --五分之一的几率弹窗放挂机弹窗
        local randNum = math.random(1, 5)
        if randNum == 5 then 
            LayerManager.addLayer({
                name = "shengyuan.ShengyuanHangupPopLayer",
                data = {callBack = function ( ... )
                    self:requestSingleMatch()
                end},
                cleanUp=false
            })
        else 
            self:requestSingleMatch()
        end 
        return
    end
end

--=============================网络请求相关============================--
-- 请求服务器，获取赛季数据
function ShengyuanWarsStartLayer:requestGetInfo(index)
    self.changeShipBtn:setVisible(true)
    HttpClient:request({
        moduleName = "Shengyuan",
        methodName = "GetShengyuanData",
        callbackNode = self,
        callback = function(data)
            --dump(data,"data")
            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end

            self.mGodDomainMainInfo = data.Value

            -- 刷新倒计时
            self:refreshCountDown()

            -- 更新缓存
            ShengyuanWarsHelper:setMountModelId(data.Value.PlaneModelId)
            ShengyuanWarsHelper:setMountLv(data.Value.MountLv)
            -- ShengyuanWarsHelper:setMaxMountModelId(data.Value.ColourMaxMount)

            -- 飞剑技能信息
            -- ShengyuanWarsHelper:setCurrMountSkillInfo(data.Value.SlotInfo)

            -- 获取玩家飞机信息
            self:requestGetGodDomainMountData()

            -- 保存队伍状态
            print("data.Value.State===",data.Value.State)
            ShengyuanWarsStatusHelper:setGodDomainTeamState(data.Value.State)
            if not next(data.Value.LeaderId or {}) then
                ShengyuanWarsStatusHelper:setGodDomainLeaderId(EMPTY_ENTITY_ID)
            else
                ShengyuanWarsStatusHelper:setGodDomainLeaderId(data.Value.LeaderId[1].LeaderId)
                -- 获取组队信息
                self:showTeamLayer(index)
            end

            -- 刷新宝箱父节点
            self:refreshChestNode()

            -- -- 刷新匹配按钮状态
            self.mMatchBtnList.refreshMatchBtn(index)

            -- -- 根据状态刷新界面
            self:dealWithState()
        end
    })
end

-- 请求服务器，获取玩家飞机信息
function ShengyuanWarsStartLayer:requestGetGodDomainMountData()
    HttpClient:request({
        moduleName = "GodDomain",
        methodName = "GetGodDomainMountData",
        svrMethodData = {},
        callbackNode = self,
        callback = function(data)
            -- 容错处理
            if not data.Value or data.Status ~= 0 then
                return
            end

            -- 玩家飞机信息
            self.mMountInfo = data.Value.MountInfo

            -- 刷新飞机sliderview
            self:refreshSliderNode()
        end
    })
end

-- 请求服务器，单人匹配
function ShengyuanWarsStartLayer:requestSingleMatch(callback)
    if self.mGodDomainMainInfo and self.mGodDomainMainInfo.EndTime then
        if self.mGodDomainMainInfo.EndTime - Player:getCurrentTime() <= 0 then
            ui.showFlashView(TR("赛季结算中，请稍后重试！"))
            return
        end
    end

    if self.mGodDomainMainInfo and self.mGodDomainMainInfo.HangUpResetTime then
        if self.mGodDomainMainInfo.HangUpResetTime - Player:getCurrentTime() > 0 then
            ui.showFlashView(TR("挂机惩罚中，请稍后重试！"))
            return
        end
    end

    if self.mGodDomainMainInfo and self.mGodDomainMainInfo.GameModuleId ~= ModuleSub.eShengyuanWars and self.mGodDomainMainInfo.State == 2 then
        ui.showFlashView(TR("%s正在匹配中，请取消后重试！", ModuleSubModel.items[self.mGodDomainMainInfo.GameModuleId].name))
        return
    end

    -- 断开绝情谷连接
    require("killervalley.KillerValleyHelper")
    KillerValleyHelper:leave()

    HttpClient:request({
        moduleName = "ShengyuanTeam",
        methodName = "StartMatch",
        callbackNode = self,
        callback = function (response)
            -- 容错处理
            if response.Status ~= 0 then
                return
            end
            self.mGodDomainMainInfo.IP = response.Value.SocketServerIP

            -- 更新匹配状态
            ShengyuanWarsStatusHelper:setGodDomainTeamState(2)

            -- 刷新飞机信息父节点
            -- self:refreshSliderNode()

            -- 刷新匹配按钮状态
            self.mMatchBtnList.refreshMatchBtn()

            -- 根据状态刷新界面
            self:dealWithState()

            if callback then
                callback()
            end
        end
    })
end

return ShengyuanWarsStartLayer