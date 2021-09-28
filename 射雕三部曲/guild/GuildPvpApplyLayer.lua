--[[
    文件名: GuildPvpApplyLayer
    描述: 帮派战报名
    创建人: yanghongsheng
    创建时间: 2018.01.03
-- ]]

local GuildPvpApplyLayer = class("GuildPvpApplyLayer",function()
    return display.newLayer()
end)

--[[
-- 参数 params 中的各项为：
    {
    }
]]
function GuildPvpApplyLayer:ctor(params)
    -- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    -- 初始化页面控件
    self:initUI()

    -- 创建底部导航和顶部玩家信息部分
    local tempLayer = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        topInfos = {ResourcetypeSub.eVIT, ResourcetypeSub.eGold, ResourcetypeSub.eDiamond}
    })
    self:addChild(tempLayer)

    -- 关闭按钮
    self.mCloseBtn = ui.newButton({
        normalImage = "c_29.png",
        clickAction = function()
            LayerManager.removeLayer(self)
        end
    })
    self.mCloseBtn:setPosition(cc.p(604, 1040))
    self.mParentLayer:addChild(self.mCloseBtn)
end

-- 初始化页面控件
function GuildPvpApplyLayer:initUI()
    -- 创建页面背景
    local bgSprite = ui.newSprite("bpz_03.jpg")
    bgSprite:setPosition(320, 568)
    self.mParentLayer:addChild(bgSprite)

    -- 添加题目
    local titleSprite = ui.newSprite("bpz_01.png")
    titleSprite:setPosition(340, 1020)
    self.mParentLayer:addChild(titleSprite)

    -- 报名截止时间
    local timeNode, timeLabel = ui.createSpriteAndLabel({
            imgName = "c_25.png",
            scale9Size = cc.size(400, 50),
            labelStr = TR("报名截止时间: #f8ea3a00:00:00"),
            outlineColor = Enums.Color.eOutlineColor,
        })
    timeNode:setPosition(320, 922)
    self.mParentLayer:addChild(timeNode)
    self.timeLabel = timeLabel

    -- 被去单提示
    local hintLabel = ui.newLabel({
            text = TR("很遗憾，您的帮派在本次帮派战中没有匹配到对手，请报名参与下次帮派战！"),
            color = Enums.Color.eLightYellow,
            outlineColor = cc.c3b(0x46, 0x22, 0x0d),
            dimensions = cc.size(400, 0)
        })
    hintLabel:setPosition(340, 860)
    self.mParentLayer:addChild(hintLabel)
    self.hintLabel = hintLabel

    -- -- 上届冠军
    -- local hintSize = cc.size(640, 200)
    -- local hintBg = ui.newScale9Sprite("qxzb_3.png", hintSize)
    -- hintBg:setPosition(320, 225)
    -- self.mParentLayer:addChild(hintBg)

    -- local titleLabel = ui.newLabel({
    --         text = TR("上届冠军"),
    --         color = cc.c3b(0xFF, 0xE7, 0x48),
    --         outlineColor = Enums.Color.eOutlineColor,
    --     })
    -- titleLabel:setPosition(hintSize.width*0.5, hintSize.height-50)
    -- hintBg:addChild(titleLabel)

    -- local guildName = ui.newLabel({
    --         text = "",
    --         color = cc.c3b(0x46, 0x22, 0x0d),
    --     })
    -- guildName:setAnchorPoint(cc.p(0, 0))
    -- guildName:setPosition(50, hintSize.height*0.5-30)
    -- hintBg:addChild(guildName)
    -- self.guildName = guildName

    -- local presidentName = ui.newLabel({
    --         text = "",
    --         color = cc.c3b(0x46, 0x22, 0x0d),
    --     })
    -- presidentName:setAnchorPoint(cc.p(0, 0))
    -- presidentName:setPosition(hintSize.width*0.5, hintSize.height*0.5-30)
    -- hintBg:addChild(presidentName)
    -- self.presidentName = presidentName

    -- 按钮
    self:createBtnList()

    self:refreshUI()
end

function GuildPvpApplyLayer:createBtnList()
    local btnList = {
        -- 报名
        {
            normalImage = "bpz_02.png",
            effect = "effect_ui_baoming",
            position = cc.p(320, 715),
            clickAction = function ()
                if GuildObj:getGuildBattleInfo().EnrollEndTime - Player:getCurrentTime() <= 0 then
                    ui.showFlashView({text = TR("今日报名时间已截止")})
                    return
                end
                self:requestSignUp()
            end,
        },
        -- 往期战报
        {
            normalImage = "tb_198.png",
            position = cc.p(60, 950),
            clickAction = function ()
                LayerManager.addLayer({
                        name = "guild.GuildPvpReportLayer",
                        cleanUp = false,
                    })
            end,
        },
        -- 排行榜
        {
            normalImage = "tb_16.png",
            position = cc.p(60, 850),
            clickAction = function ()
                LayerManager.addLayer({
                        name = "guild.GuildPvpRankLayer",
                        cleanUp = false,
                    })
            end,
        },
        -- 规则
        {
            normalImage = "c_72.png",
            position = cc.p(60, 1040),
            clickAction = function ()
                MsgBoxLayer.addRuleHintLayer(TR("规则"),
                {
                    TR("一、准备日"),
                    TR("1.每两周为一个赛季，共7轮帮派战"),
                    TR("2.一个准备日和决战日即为一轮帮派战"),
                    TR("3.帮派战报名时间为：每日的0点到23:30"),
                    TR("4.准备日23:30到次日8:00为读取玩家阵容信息时间，请不要在该时间段内进行人物、装备下阵等降战力的操作"),
                    TR("5.报名成功的帮派可在准备日进行招募佣兵和布阵等操作以应对即将到来的对手"),
                    TR("6.如果在准备日报名帮派战，则次日即可开战；如果在决战日报名帮派战，则提前进入下一轮准备日阶段，需要等到下一轮决战日才能开战"),
                    TR("7.帮主和副帮主可以给帮派成员招募佣兵和布阵，其他帮派成员只能给自己招募佣兵和布阵"),
                    " ",
                    TR("二、决战日"),
                    TR("1.决战日的时候可选择对方帮派任意成员进行挑战或切磋，但同一个玩家只能对其进行一次挑战或切磋"),
                    TR("2.击败对方任意3个角色可得1颗星，击败对方主角可再得1颗星，全灭对方的话可得3颗星，只要获得至少1可星即为战斗胜利"),
                    TR("3.只能挑战尚未被3星的敌帮成员，已经被3星的敌帮成员只能和其进行切磋"),
                    TR("4.每次帮派战每个玩家都有2次挑战和5次切磋机会"),
                    TR("5.每次挑战和切磋都能获得帮派战积分和帮派武技，数量多少和本次挑战的敌帮成员序号以及获得的星级评价有关"),
                    " ",
                    TR("三、结算"),
                    TR("1.帮派战胜负根据本次帮派战的总星数比分判定，获得总星数多的帮派胜利"),
                    TR("2.胜利的帮派每人可额外获得积分和帮派武技（本轮帮派战没有获得积分的成员不会额外获得任何奖励）"),
                    TR("3.帮派战中获得的帮派武技会在帮派战结束后通过领奖中心发放，发奖期间退出或加入其它帮派将不会收到帮派武技奖励"),
                    TR("4.个人排行按照本赛季个人在帮派战获得的积分排名，帮派排行则是帮派所有人获得的积分累计排行，排行奖励会在赛季结束时发放"),
                })
            end,
        },
    }

    for _, btnInfo in pairs(btnList) do
        local tempBtn = ui.newButton(btnInfo)
        self.mParentLayer:addChild(tempBtn)

        if btnInfo.effect then
            ui.newEffect({
                    parent = tempBtn,
                    position = cc.p(tempBtn:getContentSize().width*0.5, tempBtn:getContentSize().height*0.5),
                    effectName = btnInfo.effect,
                    loop = true,
                })
        end
    end
end

function GuildPvpApplyLayer:refreshUI()
    -- 停止倒计时
    if self.mSchelTime then
        self:stopAction(self.mSchelTime)
        self.mSchelTime = nil
    end
    local seasonInfo = GuildObj:getGuildBattleInfo()
    -- 创建定时器刷新时间
    self.mSchelTime = Utility.schedule(self, function ()
        local timeLeft = seasonInfo.EnrollEndTime - Player:getCurrentTime()
        if timeLeft > 0 then
            local day, hours, minutes, seconds = MqTime.toHour(timeLeft)
            local timeText = ""
            if day and day > 0 then
                timeText = timeText .. TR("#f8ea3a%d#F7F5F0天", day)
            end
            if hours and hours > 0 then
                timeText = timeText .. TR("#f8ea3a%d#F7F5F0小时", hours)
            end
            if minutes and minutes > 0 then
                timeText = timeText .. TR("#f8ea3a%d#F7F5F0分", minutes)
            end
            if seconds and seconds > 0 then
                timeText = timeText .. TR("#f8ea3a%d#F7F5F0秒", seconds)
            end

            self.timeLabel:setString(TR("报名截止时间:  %s", timeText))
        else
            self.timeLabel:setString(TR("报名截止时间:  %s00:00:00", "#f8ea3a"))

            -- 停止倒计时
            if self.mSchelTime then
                self:stopAction(self.mSchelTime)
                self.mSchelTime = nil
            end
        end
    end, 1.0)
    -- 提示
    if seasonInfo.IsFightDay then
        if seasonInfo.IsMatchSuccess == 0 then
            self.hintLabel:setString(TR("您的帮派没有报名上轮帮派战，请报名参与下一轮！"))
        elseif seasonInfo.IsMatchSuccess == 2 then
            self.hintLabel:setString(TR("很遗憾，您的帮派在本次帮派战中没有匹配到对手，请报名参与下次帮派战！"))
        end
        self.hintLabel:setVisible(true)
    else
        self.hintLabel:setVisible(false)
    end
    -- 帮派名
    -- self.guildName:setString(string.format("{bpz_04.png}  %s", TR("虚位以待")))
    -- -- 帮派名
    -- self.presidentName:setString(string.format("{bpz_05.png}  %s", TR("虚位以待")))
end

--================================服务器相关=============================
-- 报名
function GuildPvpApplyLayer:requestSignUp()
    local playerPosId = GuildObj:getPlayerGuildInfo().PostId
    -- 是否是帮主,副帮主
    if playerPosId ~= 34001001 and playerPosId ~= 34001002 then
        ui.showFlashView({text = TR("快去提醒帮主报名吧")})
        return
    end
    HttpClient:request({
        moduleName = "Guild",
        methodName = "Enroll",
        svrMethodData = {},
        callbackNode = self,
        callback = function (response)
            if not response or response.Status ~= 0 then
                return
            end
            ui.showFlashView({text = TR("成功报名参加帮派战")})
            -- 删除报名界面
            LayerManager.deleteStackItem("guild.GuildPvpApplyLayer")
            -- 跳转
            LayerManager.addLayer({
                    name = "guild.GuildPvpReadyLayer",
                })
        end
    })
end

return GuildPvpApplyLayer