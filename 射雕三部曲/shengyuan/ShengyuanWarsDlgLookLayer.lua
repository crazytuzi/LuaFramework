--[[
    文件名：ShengyuanWarsDlgLookLayer.lua
    描述：飞行器查看页面
    创建人：peiyaoqiang
    创建时间：2016.10.13
--]]
local ShengyuanWarsDlgLookLayer = class("ShengyuanWarsDlgLookLayer", function(params)
    return cc.Layer:create()
end)

-- 初始化函数
--[[
    params: 参数列表
    {
    }
--]]
function ShengyuanWarsDlgLookLayer:ctor(params)
    -- 屏蔽点击事件
    ui.registerSwallowTouch({node = self})

    -- 读取飞行器的属性
    self.ModelId = params.AeroInfo.ModelId
    self.Guid = params.AeroInfo.Guid
    self.Name = params.AeroInfo.Name
    self.BaseInfo = GoddomainMountModel.items[self.ModelId]

    self.mHeroModelId = {}   -- 存放hero的modelId
    self.mHeroHp = {}      -- 存放Hero的Hp
    self.mTotalHeroHp = {} -- 满血的Hero的Hp
    self.tableDataList = {}   -- 战报信息List

    -- 创建原始界面
    self:initLayer()
end

-- 初始化界面
--[[
    无参数
--]]
function ShengyuanWarsDlgLookLayer:initLayer()
    local popSprite = require("commonLayer.PopBgLayer").new({
        title = TR("详 情"),
        bgSize = cc.size(640, 694),
        closeAction = function()
            LayerManager.removeLayer(self)
        end
    })
    self:addChild(popSprite)

    local bgSprite = popSprite.mBgSprite
    self.bgSize = bgSprite:getContentSize()
    self.bgSprite = bgSprite

    -- 显示飞行器
    local planeBg = ui.newSprite("fb_32.png")
    planeBg:setAnchorPoint(0, 1)
    planeBg:setPosition(10, self.bgSize.height - 100)
    planeBg:setScale(0.8)
    bgSprite:addChild(planeBg)
    local planeBgSize = planeBg:getContentSize()
    local item = {
        MountModelId = self.ModelId,
        PlayerId = self.Guid,
        showWave = false,
    }
    local planeSprite = ShengyuanWarsUiHelper:createBoat(item)
    planeSprite:setPosition(planeBgSize.width/2, planeBgSize.height/2 + 100)
    planeBg:addChild(planeSprite)

    -- 获取玩家buff信息
    local buffBg = ui.newSprite("jzthd_18.png")
    buffBg:setPosition(self.bgSize.width/2, self.bgSize.height/2-60)
    -- buffBg:setScaleY(1.1)
    bgSprite:addChild(buffBg)
    local buffSize = buffBg:getContentSize()

    local playerInfo = ShengyuanWarsHelper:getPlayerData(self.Guid)
    if playerInfo.Buff then
        local buffInfo = playerInfo.Buff
        local buffList = {}  -- 神符详情
        -- 五毒散
        if buffInfo["1"] and buffInfo["1"] == -1 then 
            local item = {
                buffSprite = ShengyuanwarsBuffModel.items[1].insidePic..".png",
                intro = ShengyuanwarsBuffModel.items[1].intro,
                name = ShengyuanwarsBuffModel.items[1].name,
                remainTime = nil
            }
            table.insert(buffList, item)
        end     
        -- 双倍神符
        if buffInfo["3"] and buffInfo["3"] > 0 then 
            local item = {
                buffSprite = ShengyuanwarsBuffModel.items[3].insidePic..".png",
                intro = ShengyuanwarsBuffModel.items[3].intro,
                name = ShengyuanwarsBuffModel.items[3].name,
                remainTime = buffInfo["3"]
            }
            table.insert(buffList, item)
        end
        -- 嗜血神符
        if buffInfo["4"] and buffInfo["4"] > 0 then 
            local item = {
                buffSprite = ShengyuanwarsBuffModel.items[4].insidePic..".png",
                intro = ShengyuanwarsBuffModel.items[4].intro,
                name = ShengyuanwarsBuffModel.items[4].name,
                remainTime = buffInfo["4"]
            }
            table.insert(buffList, item)
        end

        local remainLabel = {} -- 倒计时标签

        if #buffList > 0  then
            for i=1, #buffList do
                -- 神符资源图片
                local shenfuEffect = ui.newSprite(buffList[i].buffSprite)
                shenfuEffect:setScale(0.8)
                shenfuEffect:setPosition(cc.p(130, buffSize.height*0.75 - (i-1)*(buffSize.height*0.25)))
                buffBg:addChild(shenfuEffect)
                -- 神符说明
                local detailLabel = ui.newLabel({
                    text = TR("%s", buffList[i].intro),
                    color = cc.c3b(0x46, 0x22, 0x0d), 
                    size = 20,
                    anchorPoint = cc.p(0, 0.5),
                })
                detailLabel:setPosition(160, buffSize.height*0.75 - (i-1)*(buffSize.height*0.25))
                buffBg:addChild(detailLabel)

                -- 神符剩余时间
                if buffList[i].remainTime then 
                    remainLabel[i] = ui.newLabel({
                        text = TR("剩余时间：%s秒", buffList[i].remainTime),
                        color = cc.c3b(0x46, 0x22, 0x0d), 
                        size = 20,
                        anchorPoint = cc.p(0, 0.5),
                    })
                    remainLabel[i]:setPosition(400, buffSize.height*0.75 - (i-1)*(buffSize.height*0.25))
                    buffBg:addChild(remainLabel[i])

                    Utility.schedule(remainLabel[i], function()
                        remainLabel[i]:setString(TR("剩余时间 :%s秒",buffList[i].remainTime))
                        buffList[i].remainTime = buffList[i].remainTime - 1
                        if buffList[i].remainTime < 1 then
                            remainLabel[i]:setString(TR("剩余时间 :%s秒",0))
                        end
                    end, 1.0)
                end     
            end
        else 
            local detailLabel = ui.newLabel({
                text = TR("暂没获取增益效果"),
                color = cc.c3b(0x46, 0x22, 0x0d), 
                size = 22,
                anchorPoint = cc.p(0, 0.5),
            })
            detailLabel:setPosition(160, buffSize.height*0.5)
            buffBg:addChild(detailLabel)     
        end
    else 
        local detailLabel = ui.newLabel({
            text = TR("暂没获取增益效果"),
            color = cc.c3b(0x46, 0x22, 0x0d), 
            size = 22,
            anchorPoint = cc.p(0, 0.5),
        })
        detailLabel:setPosition(160, buffSize.height*0.5)
        buffBg:addChild(detailLabel)    
    end

    -- 获取人物信息
    ShengyuanWarsHelper:playerViewInfo(self.Guid, function (reponse)
        -- 判断页面是否已经被关闭
        if tolua.isnull(self) then
            return
        end
        local data = reponse.Data
        -- 所有信息
        self.mPlayerInfo = cjson.decode(data.BaseFormation)
        -- 每个hero的血量信息
        self.mHpAndRp = data.HpAndRp or {}
        
        -- 战报
        self.tableDataList = data.FightBrief or {}
        
        -- 卡槽和hero的对应关系
        self.mHeroAndSlot = cjson.decode(data.SlotFormationInfo)
        -- 战斗力
        self.mFap = data.Fap

        -- 刷新Layer
        self:refreshLayer()
    end)

    ------------------------------------------------------------
    -- 比赛结束后关闭自身
    Notification:registerAutoObserver(ShengyuanWarsUiHelper:getOneEmptyNode(self), 
        function (node, info)
            LayerManager.removeLayer(self)
        end, {ShengyuanWarsHelper.Events.eShengyuanWarsFightResult})
end

-- 刷新界面
function ShengyuanWarsDlgLookLayer:refreshLayer()
    -- 显示玩家名
    local nameLabel = ui.newLabel({
        text = self.mPlayerInfo.PlayerInfo.Name, 
        color = cc.c3b(0xff, 0x66, 0xf3), 
        outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
        outlineSize = 2,
        size = 24, 
        x = 140, 
        y = self.bgSize.height - 305, 
    })
    self.bgSprite:addChild(nameLabel)
    local fapLabel = ui.newLabel({
        text = TR("战力: #d17b00%s",Utility.numberFapWithUnit(self.mFap)), 
        color = cc.c3b(0x46, 0x22, 0x0d), 
        size = 20, 
        -- outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
        -- outlineSize = 1,
        x = 140, 
        y = self.bgSize.height - 335, 
    })
    self.bgSprite:addChild(fapLabel)

    -- 获取hero的ModelId
    local slotInfos = self.mPlayerInfo.SlotInfos
    if slotInfos then
        for i,v in ipairs(slotInfos) do
            if v.Hero then
                if v.Hero.HeroId and v.Hero.HeroId ~= EMPTY_ENTITY_ID then
                    -- v.Hero.slotId = v.SlotId
                    table.insert(self.mHeroModelId, v.Hero)
                end
            end
        end
    end

    -- 获取hero的血量
    if self.mHpAndRp then
        for a, b in ipairs(self.mHeroModelId) do
            for i, v in ipairs(self.mHpAndRp) do
                if (b.SlotId == self.mHeroAndSlot[1] and v.PosId == 1) or (b.SlotId == self.mHeroAndSlot[2] and v.PosId == 2) or (b.SlotId == self.mHeroAndSlot[3] and v.PosId == 3) or
                    (b.SlotId == self.mHeroAndSlot[4] and v.PosId == 4) or (b.SlotId == self.mHeroAndSlot[5] and v.PosId == 5) or (b.SlotId == self.mHeroAndSlot[6] and v.PosId == 6) then
                    table.insert(self.mHeroHp, v.HP)
                    table.insert(self.mTotalHeroHp, v.TotalHp)
                end
            end
        end
    end
    
    -- 显示6个人物头像
    local heroCount = #self.mHeroModelId
    if heroCount > 0 then
        local headerPosList = {cc.p(305, 490), cc.p(420, 490), cc.p(535, 490)}
        if heroCount > 3 then
            headerPosList = {cc.p(305, 540), cc.p(420, 540), cc.p(535, 540), cc.p(305, 420), cc.p(420, 420), cc.p(535, 420)}
        end
        for i = 1, heroCount do
            -- 无查看具体主将信息
            local heroItem = self.mHeroModelId[i]
            local headerPos = headerPosList[i]
            local headerNode = CardNode.createCardNode({
                resourceTypeSub = ResourcetypeSub.eHero,
                modelId = heroItem.HeroModelId,
                IllusionModelId = heroItem.IllusionModelId,
                cardShowAttrs = {CardShowAttr.eBorder},
                onClickCallback = function ()
                end
            })
            -- headerNode:setScale(0.95)
            headerNode:setAnchorPoint(0.5, 0.5)
            headerNode:setPosition(headerPos)
            self.bgSprite:addChild(headerNode)

            -- 显示血量进度条
            local progressBar = require("common.ProgressBar"):create({
                bgImage = "zd_01.png",
                barImage = "zd_02.png",
                currValue = self.mHeroHp[i] or 1,
                maxValue = self.mTotalHeroHp[i] or 1,
                needLabel = false,
            })
            progressBar:setAnchorPoint(cc.p(0.5, 0.5))
            progressBar:setPosition(cc.p(headerPos.x, headerPos.y - 35))
            progressBar:setScale(0.83)
            self.bgSprite:addChild(progressBar)
        end
    end

    -- 显示战报
    self:createDlgFightInfo()
end

-- 查看战报
function ShengyuanWarsDlgLookLayer:createDlgFightInfo()
    -- 背景框
    local cellSprite = ui.newScale9Sprite("c_17.png",cc.size(self.bgSize.width - 60, 200))
    cellSprite:setAnchorPoint(cc.p(0.5, 0))
    cellSprite:setPosition(self.bgSize.width * 0.5, 25)
    self.bgSprite:addChild(cellSprite)

    -- 背景框
    local listSprite = ui.newScale9Sprite("c_54.png", cc.size(self.bgSize.width - 70, 190))
    listSprite:setAnchorPoint(cc.p(0.5, 0))
    listSprite:setPosition(self.bgSize.width * 0.5, 28)
    self.bgSprite:addChild(listSprite)

    --单项名
    local itemNameLabel = ui.newLabel({
        text = TR("战报"),
        outlineColor = cc.c3b(0x83, 0x49, 0x38),
        outlineSize = 2,
        size = 26,
        x = (self.bgSize.width - 70)/2,
        y = 185,
    })
    itemNameLabel:setAnchorPoint(cc.p(0.5, 1))
    listSprite:addChild(itemNameLabel) 

    -- 添加技能头像
    if #self.tableDataList == 0 then
        local notLabel = ui.newLabel({
            text = TR("暂无战报信息"),
            font = _FONT_PANGWA,
            size = 28,
            color = cc.c3b(0x46, 0x22, 0x0d), 
            x = (self.bgSize.width - 70)/2,
            y = 85,
            align = ui.TEXT_ALIGN_CENTER
        })
        listSprite:addChild(notLabel)
        return
    end

    local listViewSize = cc.size(self.bgSize.width - 70, 140)
    local listView = ccui.ListView:create()
    listView:setContentSize(listViewSize)
    listView:setPosition(listViewSize.width * 0.5, 5)
    listView:setAnchorPoint(cc.p(0.5, 0))
    listView:setDirection(ccui.ListViewDirection.vertical)
    listSprite:addChild(listView)

    for i, v in ipairs(self.tableDataList) do
        local cellSize = cc.size(self.bgSize.width - 70, 60)
        local cellSprite = ccui.Layout:create()
        cellSprite:setContentSize(cellSize)
        listView:pushBackCustomItem(cellSprite)

        local currItem = clone(v)
        -- 显示战报文字
        local strAttackName = currItem.AttackName
        local strTargetName = TR("您")
        local isPlayerWin = (not currItem.IsWin)
        if (currItem.AttackName == Player.playerName) then
            isPlayerWin = currItem.IsWin
            strAttackName = TR("您")
            strTargetName = currItem.TargetName
        end
        local winOrFailure = (isPlayerWin == true) and TR("您胜利了") or TR("您失败了")

        -- 当攻击方和目标方都不是玩家自己的时候
        if currItem.AttackName ~= Player.playerName and currItem.TargetName ~= Player.playerName then
            strAttackName = currItem.AttackName
            strTargetName = currItem.TargetName
            winOrFailure = currItem.IsWin and TR("%s胜利了",strAttackName) or TR("%s胜利了",strTargetName)
        end

        local reportLabel = ui.newLabel({
            text = TR("%s对%s发起了挑战，%s", strAttackName, strTargetName, winOrFailure),
            color = cc.c3b(0x46, 0x22, 0x0d), 
            size = 20,
            x = 20,
            y = cellSize.height-8,
            font = _FONT_PANGWA,
            align = cc.TEXT_ALIGNMENT_LEFT,
            valign = cc.TEXT_ALIGNMENT_CENTER,
            dimensions = cc.size(cellSize.width - 140, 0),
        })
        reportLabel:setAnchorPoint(cc.p(0, 1))
        cellSprite:addChild(reportLabel)

        -- 显示查看按钮
        local btnReport = ui.newButton({
            normalImage = "c_28.png",
            text = TR("重  播"),
            fontSize = 24,
            position = cc.p(cellSize.width - 58, cellSize.height/2),
            clickAction = function ()
                ShengyuanWarsHelper:viewFightReport(self.Guid, (i-1) ,function (reponse)
                    -- 获取战斗信息
                    local info = reponse.Data
                    info.IsWin = info.Result.IsWin
                    local control = Utility.getBattleControl(ModuleSub.eShengyuanWars)
                    LayerManager.addLayer({
                        name = "ComBattle.BattleLayer",
                        data = {
                            data = info,
                            skip = control.skip,
                            trustee = control.trustee,
                            skill = control.skill,
                            map = Utility.getBattleBgFile(ModuleSub.eChallengeWrestle),-- 用挖矿的地图
                            callback = function(battleResult)
                                PvpResult.showPvpResultLayer(
                                    ModuleSub.eShengyuanWars,
                                    info,
                                    {
                                        PlayerName = info.AttackName,
                                        FAP = info.AttackFap,
                                    },
                                    {
                                        PlayerName = info.TargetName,
                                        FAP = info.TargetFap,
                                    }
                                )

                                if control.trustee and control.trustee.changeTrusteeState then
                                    control.trustee.changeTrusteeState(battleResult.trustee)
                                end
                            end
                        }
                    })
                end)
            end,
        })
        btnReport:setScale(0.75)
        cellSprite:addChild(btnReport)
    end        
end

return ShengyuanWarsDlgLookLayer