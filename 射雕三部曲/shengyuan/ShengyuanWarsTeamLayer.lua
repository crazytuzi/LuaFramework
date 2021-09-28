--[[
	文件名: ShengyuanWarsTeamLayer.lua
	描述: 决战桃花岛帮派组队界面
	创建人: chenzhong
	创建时间: 2017.9.2
--]]

local ShengyuanWarsTeamLayer = class("ShengyuanWarsTeamLayer", function(params)
    return display.newLayer(cc.c4b(0, 0, 0, 100))
end)

require("shengyuan.ShengyuanWarsStatusHelper")
require("shengyuan.ShengyuanWarsHelper")
require("shengyuan.ShengyuanWarsUiHelper")

-- 五个玩家的位置
heroPosList = {
    [1]= cc.p(240, 880),
    [2]= cc.p(415, 790),
    [3]= cc.p(140, 625),
    [4]= cc.p(320, 545),
    [5]= cc.p(500, 465),
}

--[[
    params:
    Table params:
    {
        teamInfo: 队伍信息
        refreshCallBack : 父页面刷新方法
    }
--]]
function ShengyuanWarsTeamLayer:ctor(params)
    self.mRefreshCllback = params.refreshCallback
    -- 屏蔽底层触摸
    ui.registerSwallowTouch({node = self})
    -- 创建页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)
    -- 导航栏
    local tempLayer = require("commonLayer.CommonLayer"):create({
        currentLayerType = Enums.MainNav.eChallenge,
        topInfos = {ResourcetypeSub.eVIT, ResourcetypeSub.eGodDomainGlory, ResourcetypeSub.eDiamond}
    })
    self:addChild(tempLayer)

    -- 队伍信息 请求网络
    self.mTeamInfo = params.teamInfo or {}
    -- 
    self.mRefreshCallBack = params.refreshCallBack

    -- 头像列表 用于维护头像刷新
    self.mHeaderList = {}

    -- 初始化界面
    self:setUI()

    -- 添加排行榜、商店、规则、关闭按钮
    self:addFuncBtns()

    -- 放玩家头像信息
    self.heroNode = cc.Node:create()
    self.mParentLayer:addChild(self.heroNode)

    -- 未组队、未匹配：请求服务器，创建队伍
    --dump(ShengyuanWarsStatusHelper:getGodDomainLeaderId(),"xxxxxxxx")
    if ShengyuanWarsStatusHelper:getGodDomainLeaderId() == EMPTY_ENTITY_ID then
        print("创建队伍")
        self:creatTeam()
    -- 已组队状态，获取队伍信息
    else
        print("获取队伍")
        self:getTeamInfo()
    end

    -- 队伍信息变化：踢出/退出/解散/准备/取消准备
    Notification:registerAutoObserver(self.bgSprite, function(node, data)
        print("成员变化")
        self:getTeamInfo(true)
    end,
    {EventsName.eShengyuanTeam})

    -- 开始匹配
    Notification:registerAutoObserver(self, function (node, data)
        ShengyuanWarsStatusHelper:setGodDomainTeamState(2)
        --dump(data,"接收到匹配通知")
        -- 回调主页开始匹配
        if self.mRefreshCllback then
            self.mRefreshCllback()
        end
        -- 处理刷新页面
        self.mSocketServerIP = data
        self:dealWithState()
        if self.mMatchSprite then 
            self.mMatchSprite:setVisible(true)
        end     
    end,
    {EventsName.eShengyuanMatch})

    -- 取消匹配
    Notification:registerAutoObserver(self, function (node, data)
        print("接受到取消匹配通知")
        ShengyuanWarsStatusHelper:setGodDomainTeamState(1)
        self:getTeamInfo()

        --取消连接
        local leaderId = ShengyuanWarsStatusHelper:getGodDomainLeaderId()
        -- 如果是队长就不需要
        if leaderId ~= EMPTY_ENTITY_ID and leaderId ~= PlayerAttrObj:getPlayerAttrByName("PlayerId") then 
            -- 匹配图标消失
            if self.mMatchSprite then 
                self.mMatchSprite:setVisible(false) 
            end    
            ui.showFlashView(TR("队长取消匹配!"))
        end     
    end,
    {ShengyuanWarsHelper.Events.eShengyuanWarsCancelTeam})

    -- 注册匹配成功的通知事件
    Notification:registerAutoObserver(self.bgSprite, function ()
        print("inter mapLayer......")
        LayerManager.addLayer({name = "shengyuan.ShengyuanWarsMapLayer", zOrder=Enums.ZOrderType.eDefault + 4})
    end, {ShengyuanWarsHelper.Events.eShengyuanWarsEnterBattle})
end

function ShengyuanWarsTeamLayer:setUI()
    -- 创建背景
    self.bgSprite = ShengyuanWarsUiHelper:createWaveWaterSprite("jzthd_26.jpg")
    self.bgSprite:setPosition(320, 568)
    self.mParentLayer:addChild(self.bgSprite)

    -- 创建码头
    local wharfSprite = ui.newSprite("jzthd_27.png")
    wharfSprite:setAnchorPoint(0, 0)
    wharfSprite:setPosition(0, 0)
    self.bgSprite:addChild(wharfSprite)

    -- 添加一张岛屿的图片
    local baoSprite = ui.newSprite("jzthd_15.png")
    baoSprite:setPosition(700, 880)
    self.bgSprite:addChild(baoSprite)

    -- 退出组队
    local exitButton = ui.newButton({
        normalImage = "tb_181.png",
        position = cc.p(550, 1040),
        clickAction = function()
            -- 正在匹配中
            if ShengyuanWarsStatusHelper:getGodDomainTeamState() == 2 then 
                ui.showFlashView(TR("匹配中,队长取消匹配才能退出队伍"))
                return
            else 
                if self.mTeamInfo.LeaderId == PlayerAttrObj:getPlayerAttrByName("PlayerId") then 
                    self:dismissTeam()
                else 
                    self:exitTeam()
                end   
            end       
            
            LayerManager.removeLayer(self)
        end
    })
    self.bgSprite:addChild(exitButton)

    -- 邀请玩家
    self.mAddBtn = ui.newButton({
        normalImage = "jzthd_08.png",
        position = cc.p(550, 100),
        clickAction = function()
            -- 邀请组队界面
            LayerManager.addLayer({
                name = "shengyuan.ShengyuanWarsChooseTeamMateLayer",
                cleanUp = false,
            })
        end
    })
    self.bgSprite:addChild(self.mAddBtn)

    -- 开始匹配
    local shengYuanState = ShengyuanWarsStatusHelper:getGodDomainTeamState()
    local shengyuanLeaderId = ShengyuanWarsStatusHelper:getGodDomainLeaderId()
    local btImage = "jzthd_29.png"
    if shengYuanState == 2 and shengyuanLeaderId == PlayerAttrObj:getPlayerAttrByName("PlayerId") then 
        btImage = "jzthd_28.png"
    end     
    self.piPeiBtn = ui.newButton({
        normalImage = btImage,
        position = cc.p(430, 200),
        clickAction = function(obj)
            if self.mTeamInfo.LeaderId ~= PlayerAttrObj:getPlayerAttrByName("PlayerId") then 
                ui.showFlashView(TR("只要队长才能开始匹配"))
                return
            end    

            -- 如果队伍中只有一个人 不能匹配
            local perNum = self:getPersonNum()
            if perNum <= 1 then 
                ui.showFlashView(TR("至少需要两人在队伍中才能开始匹配,邀请帮派好友加入游戏吧！"))
                return
            end     

            local shengYuanState = ShengyuanWarsStatusHelper:getGodDomainTeamState()
            if shengYuanState == 2 then -- 开始匹配的时候 需要取消匹配
                local cancelRet = ShengyuanWarsHelper:cancelMatch(function(retValue)
                    if retValue.Code == 0 then
                        -- 回调
                        if self.mRefreshCllback then
                            self.mRefreshCllback()
                        end

                        ShengyuanWarsStatusHelper:setGodDomainTeamState(1)

                        -- 匹配图标消失
                        self.mMatchSprite:setVisible(false) 
                        ui.showFlashView(TR("取消匹配!"))

                        obj:loadTextureNormal("jzthd_29.png")
                        obj:loadTexturePressed("jzthd_29.png")
                    end
                end)
                if not cancelRet then
                    ShengyuanWarsUiHelper:exitGame(true)
                end
            else 
                --五分之一的几率弹窗放挂机弹窗
                local randNum = math.random(1, 5)
                if randNum == 5 then 
                    LayerManager.addLayer({
                        name = "shengyuan.ShengyuanHangupPopLayer",
                        data = {callBack = function ()
                            -- 开始匹配
                            local perNum = self:getPersonNum()
                            if perNum <= 1 then 
                                ui.showFlashView(TR("至少需要两人在队伍中才能开始匹配,邀请帮派好友加入游戏吧！"))
                            else   
                                self:startMarch()
                            end 
                        end},
                        cleanUp=false
                    })
                else 
                    -- 开始匹配
                    self:startMarch()
                end 
            end  
        end
    })
    self.bgSprite:addChild(self.piPeiBtn)

    -- 匹配中动画精灵
    self.mMatchSprite = ui.newSprite("jzthd_02.png")
    self.mMatchSprite:setScale(0.9)
    self.mMatchSprite:setPosition(290, 320)
    self.bgSprite:addChild(self.mMatchSprite)
    self.mMatchSprite:setVisible(shengYuanState == 2)

    -- 聊天按钮添加小红点
    local function dealRedDotVisible(redDotSprite)
        redDotSprite:setVisible(false)
        if ChatMng:getUnreadCount(Enums.ChatChanne.eTeam) > 0 then
            local lastData = ChatMng:getLastRecData()
            self:showChat(lastData)
        end
    end
    local eventNames = {EventsName.eChatUnreadPrefix .. tostring(Enums.ChatChanne.eTeam), EventsName.eChatNewMsg}
    ui.createAutoBubble({parent = self.bgSprite, eventName = eventNames, refreshFunc = dealRedDotVisible})

    --积分加成
    local integraBg = ui.newSprite("jzthd_70.png")
    integraBg:setPosition(300, 1050)
    self.bgSprite:addChild(integraBg)
    -- integraBg:setScale(0.8)
    local inteSize = integraBg:getContentSize()
    self.mIntegraLabel = ui.newLabel({
        text = TR("%s人帮派队伍\n帮派积分加成%s%%", 1, 0),
        size = 22,
        -- color = Enums.Color.eWhite,
        align = cc.TEXT_ALIGNMENT_CENTER,
        outlineColor = Enums.Color.eBlack,
    })
    self.mIntegraLabel:setPosition(inteSize.width/2, inteSize.height/2+7)
    integraBg:addChild(self.mIntegraLabel)
end

-- 添加排行榜、商店、规则、关闭按钮
function ShengyuanWarsTeamLayer:addFuncBtns()
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
    ruleBtn:setPosition(60, 1050)
    self.bgSprite:addChild(ruleBtn)

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
            position = cc.p(60, 955 - (idx - 1) * 110),
            clickAction = item.clickAction
        })
        self.bgSprite:addChild(tempBtn)
    end
end

--展示发言泡泡给玩家看
function ShengyuanWarsTeamLayer:showChat(data)
    local data = data or {}
    local scalX = 1.3
    if not data or next(data) == nil then
        return
    end
    local tempStr = data.Message
    if string.utf8len(data.Message) > 6  then
        tempStr = string.utf8sub(tempStr, 1, 6).."..."
    end
    tempStr = ChatMng:faceStrUnpack(tempStr)

    local actionArray = {}
    local chatBoxes = {}
    table.insert(actionArray, cc.CallFunc:create(function()
        --dump(self.mTeamInfo.TeamMember, "队伍信息")
        for index, team in ipairs(self.mTeamInfo.TeamMember) do
            if not  data.FromPlayer.ExtendInfo then
               return
            end
            if data.FromPlayer.ExtendInfo.Name == team.Name then
                local chatBox = ui.newSprite("jzthd_07.png")
                self.mParentLayer:addChild(chatBox)
                -- chatBox:setScaleX(scalX)
                local chatboxSize = chatBox:getContentSize()
                local chattext = ui.newLabel({
                    text = tempStr,
                    size = 18,
                    color = Enums.Color.eWhite,
                    outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
                    dimensions = cc.size(chatboxSize.width - 30 , 0),
                })
                chattext:setImageElementScale(0.25)
                chattext:setPosition(cc.p(chatboxSize.width/2, chatboxSize.height/2+4))
                chatBox:setPosition(cc.p(heroPosList[index].x+20, heroPosList[index].y+100))
                chatBox:addChild(chattext)
                table.insert(chatBoxes, chatBox)
            end
        end
    end))
    table.insert(actionArray, cc.DelayTime:create(3.5))
    table.insert(actionArray, cc.CallFunc:create(function()
        for k, chatBox in ipairs(chatBoxes) do
            if chatBox and not tolua.isnull(chatBox) then
                chatBox:setVisible(false)
            end
        end
    end))
    self:runAction(cc.Sequence:create(actionArray))
end

-- 刷新队伍信息
function ShengyuanWarsTeamLayer:refreshTeamInfo()
    self.heroNode:removeAllChildren()
    -- 刷新积分加成标签
    self:refreshIntegral()

    local teamInfo = self.mTeamInfo.TeamMember
    for i=1, ShengyuanwarsConfig.items[1].personNumOfTeam do
        local info = teamInfo[i]
        if info then
	        info.ShizhuangModelId = info.ShizhuangModelId and info.ShizhuangModelId or info.LeaderModelId
	        info.ShizhuangModelId = info.ShizhuangModelId == 0 and info.LeaderModelId or info.ShizhuangModelId
            -- 添加玩家飞船
            local item = {
                MountModelId = info.PlaneModelId,
                showWave = true,
                LeaderModelId = info.ShizhuangModelId,
            }
            local planeSpirte = ShengyuanWarsUiHelper:createBoat(item)
            planeSpirte:setPosition(heroPosList[i])
            self.heroNode:addChild(planeSpirte)
            planeSpirte:setScale(0.7)
            -- 船的小幅领衔
            planeSpirte:runAction(cc.RepeatForever:create(cc.Sequence:create({
                cc.MoveBy:create(1.5, cc.p(0, 8)), cc.MoveBy:create(1.5, cc.p(0, -8))
                })))

            -- 玩家名字
            local playerName = ui.newLabel({
                text        = string.format("Lv.%s  %s",info.Lv, info.Name),
                size        = 22,
                outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
                outlineSize = 2,
            }):addTo(self.heroNode):setPosition(cc.p(heroPosList[i].x+20, heroPosList[i].y+60))
            -- 战力显示
            local fapLabel = ui.newLabel({
                text        = TR("战力:%s",Utility.numberFapWithUnit(info.FAP)),
                size        = 22,
                outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
                outlineSize = 2,
            }):addTo(self.heroNode):setPosition(cc.p(heroPosList[i].x+20, heroPosList[i].y+30))

            -- 如果我是队长 就显示踢出按钮
            if self.mTeamInfo.LeaderId == PlayerAttrObj:getPlayerAttrByName("PlayerId") then
                -- 踢人按钮
                local tempBtn = ui.newButton({
                    normalImage = "jzthd_05.png",
                    clickAction = function()
                        self:requestExitTeam(info.PlayerId)
                    end
                })
                tempBtn:setPosition(cc.p(heroPosList[i].x-60, heroPosList[i].y))
                self.heroNode:addChild(tempBtn, 2)
                -- 队长自己没有踢出按钮
                tempBtn:setVisible(self.mTeamInfo.LeaderId ~= info.PlayerId)
            end

            -- 准备按钮
            local readyBtn = ui.newButton({
                normalImage = "jzthd_06.png",
                clickAction = function()
                    --五分之一的几率弹窗放挂机弹窗
                    local randNum = math.random(1, 5)
                    if randNum == 5 then 
                        LayerManager.addLayer({
                            name = "shengyuan.ShengyuanHangupPopLayer",
                            data = {callBack = function ( ... )
                                self:requestReady()
                            end},
                            cleanUp=false
                        })
                    else 
                        self:requestReady()
                    end 
                end
            })
            readyBtn:setPosition(cc.p(heroPosList[i].x-60, heroPosList[i].y))
            self.heroNode:addChild(readyBtn)
            -- 会长自己没有准备按钮
            readyBtn:setVisible(self.mTeamInfo.LeaderId ~= info.PlayerId and info.PlayerId == PlayerAttrObj:getPlayerAttrByName("PlayerId"))

            -- 准备好之后不显示准备按钮
            if info.ReadyStatus == 1 then
                readyBtn:setVisible(false)
                -- 添加准备好标志
                local readySprite = ui.newSprite("jzthd_67.png")
                readySprite:setAnchorPoint(cc.p(0.5, 0.5))
                readySprite:setPosition(cc.p(heroPosList[i].x+40, heroPosList[i].y-50))
                readySprite:setScale(0.8)
                self.heroNode:addChild(readySprite, 2)
                readySprite:setVisible(info.PlayerId ~= self.mTeamInfo.LeaderId)
            end
        else
            -- 空头像
            local emptyHero = ui.newButton({
                normalImage = "c_22.png",
                anchorPoint = cc.p(0.5, 0.5),
                position = heroPosList[i],
                clickAction = function()
                    -- if self.mTeamInfo.LeaderId ~= PlayerAttrObj:getPlayerAttrByName("PlayerId") then
                    --     ui.showFlashView(TR("只要队长才能邀请好友"))
                    --     return
                    -- end    

                    -- 邀请组队界面
                    LayerManager.addLayer({
                        name = "shengyuan.ShengyuanWarsChooseTeamMateLayer",
                        cleanUp = false,
                    })
                end
            })
            self.heroNode:addChild(emptyHero)
        end
    end
end

-- 刷新积分加成标签
function ShengyuanWarsTeamLayer:refreshIntegral()
    local num = 0 --成员人数
    local teamInfo = self.mTeamInfo.TeamMember
    for k,v in pairs(teamInfo) do
        if v.PlayerId and v.PlayerId ~= EMPTY_ENTITY_ID then 
            num = num + 1
        end     
    end

    local config = ShengyuanwarsTeamConfig.items[1]
    local addNum = 0
    if num == 1 then 
        if self.mIntegraLabel then 
            self.mIntegraLabel:setString(TR("至少两人组队\n才能获得帮派积分"))
        end    
    elseif num == 2 then 
        addNum = config.twoPersonScoreCoefficient*100 
    elseif num == 3 then 
        addNum = config.threePersonScoreCoefficient*100
    elseif num == 4 then 
        addNum = config.fourPersonScoreCoefficient*100
    elseif num == 5 then 
        addNum = config.fivePersonScoreCoefficient*100
    else
        addNum = 0
    end   

    if self.mIntegraLabel and num ~= 1 then 
        self.mIntegraLabel:setString(TR("%s人帮派队伍\n帮派积分加成%s%%", num, addNum))
    end                       
end

--辅助函数（查看有几人）
function ShengyuanWarsTeamLayer:getPersonNum()
    if next(self.mTeamInfo.TeamMember) == nil then 
        return 0
    end 
    -- dump(self.mMemberList,"self.mMemberList")    
    local num = 0
    for i,v in pairs(self.mTeamInfo.TeamMember) do
        if v.PlayerId ~= EMPTY_ENTITY_ID then
            num = num + 1
        end
    end

    return num
end

-----------------网络相关------------------------
-- 创建队伍
function ShengyuanWarsTeamLayer:creatTeam()
    HttpClient:request({
        moduleName = "ShengyuanTeam",
        methodName = "CreateTeam",
        svrMethodData = {},
        callbackNode = self,
        callback =function (data)
            if not data or data.Status ~= 0 then
                return
            end
            
            --dump(data,"CreatTeam")
            self.mTeamInfo = data.Value.TeamInfo
            -- 修改缓存
            ShengyuanWarsStatusHelper:setGodDomainLeaderId(self.mTeamInfo.LeaderId)
            ShengyuanWarsStatusHelper:setGodDomainTeamState(1)

            if self.mRefreshCallBack then 
                self.mRefreshCallBack()
            end 

            self.piPeiBtn:setEnabled(self.mTeamInfo.LeaderId == PlayerAttrObj:getPlayerAttrByName("PlayerId"))    

            -- 刷新队伍信息
            self:refreshTeamInfo()
            ShengyuanWarsHelper:setTeamInfo(data.Value.TeamInfo.TeamMember)
        end
        })
end

-- 获取队伍信息
----isTrip:是否是从变更事件里面来获取的
function ShengyuanWarsTeamLayer:getTeamInfo(isTrip)
    HttpClient:request({
        moduleName = "ShengyuanTeam",
        methodName = "GetMyTeamInfo",
        callback =function (data)
            -- 判断返回数据
            if not data or data.Status ~= 0 then
                if data.Status == -10003 then
                    ui.showFlashView(TR("组队已结束"))
                    ShengyuanWarsStatusHelper:setGodDomainLeaderId(0)
                    ShengyuanWarsStatusHelper:setGodDomainLeaderId(EMPTY_ENTITY_ID)
                    ShengyuanWarsHelper:setTeamInfo({})
                    LayerManager.removeLayer(self)
                end
                return
            end
                
            --dump(data,"getMyTeamInfo")
            self.mTeamInfo = data.Value.TeamInfo

            -- -- 修改缓存
            ShengyuanWarsStatusHelper:setGodDomainLeaderId(self.mTeamInfo.LeaderId)

            -- 刷新队伍信息
            if (not tolua.isnull(self)) then
                self:refreshTeamInfo()
                self.piPeiBtn:setEnabled(self.mTeamInfo.LeaderId == PlayerAttrObj:getPlayerAttrByName("PlayerId"))
            end     
            ShengyuanWarsHelper:setTeamInfo(data.Value.TeamInfo.TeamMember)
        end,
        })
end

-- 踢出对应玩家
function ShengyuanWarsTeamLayer:requestExitTeam(playerId)
    HttpClient:request({
        moduleName = "ShengyuanTeam",
        methodName = "KickOutTeam",
        svrMethodData       = {playerId},
        callback =function (data)
            if not data or data.Status ~= 0 then
                return
            end
            self.mTeamInfo = data.Value.TeamInfo
            -- 刷新队伍信息
            self:refreshTeamInfo()
            ShengyuanWarsHelper:setTeamInfo(data.Value.TeamInfo.TeamMember)

            ui.showFlashView(TR("踢出成功"))
        end
        })
end

-- 退出组队
function ShengyuanWarsTeamLayer:exitTeam()
    HttpClient:request({
        moduleName = "ShengyuanTeam",
        methodName = "ExitTeam",
        callback =function (data)
            if not data or data.Status ~= 0 then
                return
            end
            ui.showFlashView(TR("退出组队"))
            ShengyuanWarsStatusHelper:setGodDomainTeamState(0)
            ShengyuanWarsStatusHelper:setGodDomainLeaderId(EMPTY_ENTITY_ID)
            ShengyuanWarsHelper:setTeamInfo({})

            LayerManager.removeLayer(self)
        end
    })
end

-- 解散组队
function ShengyuanWarsTeamLayer:dismissTeam()
    HttpClient:request({
        moduleName = "ShengyuanTeam",
        methodName = "DismissTeam",
        callback =function (data)
            if not data or data.Status ~= 0 then
                return
            end
            ui.showFlashView(TR("解散组队"))
            
            ShengyuanWarsStatusHelper:setGodDomainTeamState(0)
            ShengyuanWarsStatusHelper:setGodDomainLeaderId(EMPTY_ENTITY_ID)
            ShengyuanWarsHelper:setTeamInfo({})

            LayerManager.removeLayer(self)
        end
        })
end

-- 准备
function ShengyuanWarsTeamLayer:requestReady()
    HttpClient:request({
        moduleName = "ShengyuanTeam",
        methodName = "ChangeReadyState",
        svrMethodData       = {true},
        callback =function (data)
            if not data or data.Status ~= 0 then
                return
            end
            --dump(data,"data")
            self.mTeamInfo = data.Value.TeamInfo
            -- 刷新队伍信息
            self:refreshTeamInfo()
            ShengyuanWarsHelper:setTeamInfo(data.Value.TeamInfo.TeamMember)
        end
        })
end

-- 开始匹配
function ShengyuanWarsTeamLayer:startMarch()
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
            self.mSocketServerIP = response.Value.SocketServerIP

            -- 更新匹配状态
            ShengyuanWarsStatusHelper:setGodDomainTeamState(2)

            -- 根据状态刷新界面
            self:dealWithState()

            -- 出现正在匹配图标
            self.mMatchSprite:setVisible(true) 
            self.piPeiBtn:loadTextureNormal("jzthd_28.png")
            self.piPeiBtn:loadTexturePressed("jzthd_28.png")
        end
    })
end

-- 根据状态刷新页面
function ShengyuanWarsTeamLayer:dealWithState()
    -- 判断当前状态
    --dump(ShengyuanWarsStatusHelper:getGodDomainTeamState(),"stateDealWithState")
    if ShengyuanWarsStatusHelper:getGodDomainTeamState() == 3 or ShengyuanWarsStatusHelper:getGodDomainTeamState() == 2 then
        -- 已经连接了匹配战斗
        print(self.mSocketServerIP,"self.mSocketServerIP")
        ShengyuanWarsHelper:setUrl(self.mSocketServerIP)
        ShengyuanWarsHelper:connect(function(retValue)
            if retValue == nil or retValue.Code == 0 then
                if ShengyuanWarsStatusHelper:getGodDomainTeamState() == 3 then
                    -- 手动通知进入战场页面
                    Notification:postNotification(ShengyuanWarsHelper.Events.eShengyuanWarsEnterBattle)
                end
            end
        end)
    end
end

return ShengyuanWarsTeamLayer
