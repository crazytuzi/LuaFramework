--[[
    文件名：ExpediMapLayer.lua
    描述：组队副本地图界面
    创建人：lengjiazhi
    创建时间：2017.8.29
--]]

local ExpediMapLayer = class("ExpediMapLayer", function(params)
    return display.newLayer()
end)

function ExpediMapLayer:ctor(params)

    self.mFightInfo = params.fightInfo or nil
    self.mMemberList = params.memberList or {{}, {}, {}}
    self:sortWithControl()
    self.mNodeModelInfo = params.fightInfo and ExpeditionNodeModel.items[self.mFightInfo.NodeInfo.NodeModelId] or ExpeditionNodeModel.items[1111]
    self.mFightCount = params.fightCount or 1
	-- 初始化寻路
    self.starWorld = require("common.AStar").new({"challenge.ExpediMap"})
    self:getTargetNodeId()
    self:handleConfig()
	self:initUI()
end

--根据玩家自己选择的顺序排序
function ExpediMapLayer:sortWithControl()
    table.sort( self.mMemberList, function (a, b)
        if a.PosId ~= b.PosId then
            return a.PosId < b.PosId
        end
    end )
end

function ExpediMapLayer:initUI()
	 -- 创建标准容器
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    -- 创建可拖动背景
    local worldView = ccui.ScrollView:create()
    worldView:setContentSize(cc.size(640, 1136))
    worldView:setPosition(cc.p(0,0))
    worldView:setDirection(ccui.ScrollViewDir.both)
    worldView:setSwallowTouches(false)
    worldView:setTouchEnabled(false)
    self.mParentLayer:addChild(worldView)
    self.worldView = worldView

    -- 创建背景
    local spriteBg = ui.newSprite("zf_10.jpg")
    spriteBg:setAnchorPoint(0, 0)
    spriteBg:setPosition(0, 0)
    self.worldView:setInnerContainerSize(spriteBg:getContentSize())
    self.worldView:addChild(spriteBg, -2)
    self.mapBg = spriteBg

    -- 创建顶部资源栏和底部导航栏
    -- local topResource = require("commonLayer.CommonLayer"):create({
    --     needMainNav = true,
    --     currentLayerType = Enums.MainNav.eChallenge,
    --     topInfos = {
    --         ResourcetypeSub.eSTA,
    --         ResourcetypeSub.eDiamond,
    --         ResourcetypeSub.eGold
    --     }
    -- })
    -- self:addChild(topResource, 4)

    -- 创建退出按钮
    -- local button = ui.newButton({
    --     normalImage = "c_29.png",
    --     anchorPoint = cc.p(0.5, 0.5),
    --     position = cc.p(600,1020),
    --     clickAction = function()
    --         LayerManager.removeLayer(self)
    --     end
    -- })
    -- self.mParentLayer:addChild(button, 5)
    -- self.closeBtn = button
    
    if self.mFightInfo.ContinueFightInfo then
        local fightCountLabel = ui.newLabel({
            text = TR("连战中%s/%s", self.mFightInfo.ContinueFightInfo.BattleCount, self.mFightInfo.ContinueFightInfo.NeedBattleCount),
            size = 26,
            outlineColor = Enums.Color.eBlack,
            })
        fightCountLabel:setPosition(320, 1035)
        self.mParentLayer:addChild(fightCountLabel)
    end

    self:createNpc()
    self:createTeamMember()
    self:startMove()
end

-- 计算目标点ID
function ExpediMapLayer:getTargetNodeId()
    local targetNodeID = self.mNodeModelInfo.floorId + self.mFightCount - 1
    if targetNodeID > 6 then
        targetNodeID = targetNodeID%6 
    end
    if targetNodeID == 0 then
        targetNodeID = 6
    end
    self.mTargetNodeId = targetNodeID
end

--创建3个队员
function ExpediMapLayer:createTeamMember()
    self.mMemberNodeList = {}
    local startPos
    if self.mFightCount == 1 then
        startPos = cc.p(640, 1136) 
    else
        if self.mTargetNodeId == 0 then
            startPos = Utility.analysisPoints(self.mWalkPosList[5])
        elseif self.mTargetNodeId == 1 then
            startPos = Utility.analysisPoints(self.mWalkPosList[6])
        else
            startPos = Utility.analysisPoints(self.mWalkPosList[self.mTargetNodeId - 1])
        end
    end
    -- startPos = Utility.analysisPoints(self.mWalkPosList[2])
    for i,v in ipairs(self.mMemberList) do
        -- 创建玩家node
        local memberNode = cc.Node:create()
        memberNode:setAnchorPoint(cc.p(0.5, 0.5))
        memberNode:setContentSize(120, 180)
        memberNode:setPosition(startPos.x - (i-1)*40, startPos.y)
        self.mapBg:addChild(memberNode, 4-i)
        -- memberNode:setLocalZOrder(1)

        local nameLabel = ui.newLabel({
            text = v.Name,
            size = 22,
            color = Enums.Color.eNormalWhite,
            outlineColor = cc.c3b(0x14, 0x16, 0x12),
            })
        nameLabel:setPosition(memberNode:getContentSize().width / 2, memberNode:getContentSize().height * 1.2)
        memberNode:addChild(nameLabel, 2)

        -- HeroQimageRelation.items[playerModelId].positivePic
        local playerModelId = FormationObj:getSlotInfoBySlotId(1).ModelId
        local isMySelf = v.PlayerId == PlayerAttrObj:getPlayerAttrByName("PlayerId")
        local positivePic, backPic = nil, nil
        if isMySelf then
        	positivePic, backPic = QFashionObj:getQFashionByDressType()
        else
        	positivePic, backPic = QFashionObj:getQFashionLargePic(playerModelId)
        end
        
        --正面形象
        upSpine = ui.newEffect({
            parent = memberNode,
            anchorPoint = cc.p(0.5, 0.5),
            effectName = positivePic,
            position = cc.p(memberNode:getContentSize().width / 2, memberNode:getContentSize().height / 2 ),
            loop = true,
            endRelease = true,
            scale = 0.6
        })
        upSpine:setAnimation(0, "daiji", true)
        --背面形象
        downSpine = ui.newEffect({
            parent = memberNode,
            anchorPoint = cc.p(0.5, 0.5),
            effectName = backPic,
            position = cc.p(memberNode:getContentSize().width / 2, memberNode:getContentSize().height / 2),
            loop = true,
            endRelease = true,
            scale = 0.6
        })
        downSpine:setVisible(false)

        memberNode.upSpine = upSpine --正面
        memberNode.downSpine = downSpine --背面
        memberNode.changeTag = false --切换动作标识符

        table.insert(self.mMemberNodeList, memberNode)

        if i == 1 then
            -- 脚底特效
            ui.newEffect({
                parent = memberNode,
                effectName = "effect_ui_renwuguangquan_Qban",
                zorder = -1,
                animation = "guangquan",
                anchorPoint = cc.p(0.5, 0.5),
                position = cc.p(memberNode:getContentSize().width / 2, memberNode:getContentSize().height / 2),
                loop = true,
                endRelease = true,
            })
            -- 上面特效
            ui.newEffect({
                parent = memberNode,
                effectName = "effect_ui_renwuguangquan_Qban",
                animation = "guangdian",
                anchorPoint = cc.p(0.5, 0.5),
                position = cc.p(memberNode:getContentSize().width / 2, memberNode:getContentSize().height / 2),
                loop = true,
                endRelease = true,
            })
            -- 尽量保持人物在中间位置
            local calcPercentX, calcPercentY = (startPos.x - 320) / 6.4, (2272 - startPos.y - 568) / 11.36
            self.curViewPosition = cc.p(calcPercentX, calcPercentY)
            self.worldView:scrollToPercentBothDirection(self.curViewPosition, 0, true)
        end
    end
end

--处理配置表数据
function ExpediMapLayer:handleConfig()
    self.mNpcPosList = string.splitBySep(self.mNodeModelInfo.movePosition, "|")
    self.mSpeakWardList = string.splitBySep(self.mNodeModelInfo.mountSpeak, "|")
    self.mWalkPosList = string.splitBySep(self.mNodeModelInfo.mountCoor, "|")
    self.mRandNum = math.random(1, 6)
end

--创建地图上的npc
function ExpediMapLayer:createNpc()
    self.mSpeakNodeList = {}
    for i,v in ipairs(self.mNpcPosList) do
        --形象
        local pos = Utility.analysisPoints(v)
        local npcSprite = ui.newEffect({
            parent  = self.mapBg,
            effectName = self.mNodeModelInfo.mountSpineQ,
            position = pos,
            anchorPoint = cc.p(0.5, 0),
            scale = 0.75,
            loop = true,
            })

        --气泡框
        local speakNode = cc.Node:create()
        speakNode:setPosition(pos.x + 130, pos.y + 170)
        speakNode:setContentSize(cc.size(210, 85))
        self.mapBg:addChild(speakNode, 10)
        speakNode:setVisible(false)
        speakNode:setScale(0.1)

        local speakSprite = ui.newSprite("zf_07.png")
        speakSprite:setPosition(0, 0)
        speakNode:addChild(speakSprite)
         
        --文字
        local speakLabel = ui.newLabel({
            text = self.mSpeakWardList[self.mRandNum],
            size = 20,
            color = cc.c3b(0x59, 0x28, 0x17),
            dimensions = cc.size(185, 0)
            })
        speakLabel:setAnchorPoint(0, 0.5)
        speakLabel:setPosition(-90, 10)
        speakNode:addChild(speakLabel)

        if i >= 2 and i <= 4 then
            speakSprite:setPosition(-260, 0)
            speakLabel:setPosition(-350, 10)
            speakSprite:setRotationSkewY(180)
        end  

        table.insert(self.mSpeakNodeList, speakNode)
    end
end

--开始行走
function ExpediMapLayer:startMove()
    -- if self.mFightCount == 1 then
    --     self:firstTimeFight()
    -- else
        local startPos = cc.p(self.mMemberNodeList[1]:getPosition())
        local targetPos
        if self.mTargetNodeId == 0 then
            targetPos = Utility.analysisPoints(self.mWalkPosList[6])
        else
            targetPos = Utility.analysisPoints(self.mWalkPosList[self.mTargetNodeId])
        end
        -- local targetPos = Utility.analysisPoints(self.mWalkPosList[5])
        local path = self.starWorld:calcTrack(startPos, targetPos)
        self:runAction(cc.Sequence:create({
            cc.DelayTime:create(1),
            cc.CallFunc:create(function()
                self:actionFunc(path)
            end)
        }))
    -- end

    -- 根据移动的位置，处理zorder
    local startZ = #self.mMemberNodeList + 1
    for i,v in ipairs(self.mMemberNodeList) do
        v:setLocalZOrder((targetPos.y-startPos.y) > 0 and i or (startZ - i))
    end
end
-- 首次进入特殊处理
-- function ExpediMapLayer:firstTimeFight()
--     self:readyToFight()
-- end

--行走动画
function ExpediMapLayer:actionFunc(stepList)
    if #stepList <= 1 then
        return
    end

    -- 开始移动
    local delayTime = 0
    self:scheduleUpdate(function(dt)
        delayTime = delayTime + dt
        for i,v in ipairs(self.mMemberNodeList) do
            if delayTime > i*0.4 then
                --设置骨骼为行走
                if not v.changeTag then
                    v.upSpine:setToSetupPose()
                    v.upSpine:setAnimation(0, "zou", true)
                    v.downSpine:setToSetupPose()
                    v.downSpine:setAnimation(0, "zou", true)
                    v.changeTag = true
                end

                --角色位置
                local playerPos = cc.p(v:getPosition())
                local isArrived, nextPos, up, angle, isAlpha = self.starWorld:getCurrentStepInfo(playerPos, 150, dt, i)   
                v:setPosition(nextPos)
                if up then
                    v.downSpine:setVisible(true)
                    v.upSpine:setVisible(false)
                else
                    v.downSpine:setVisible(false)
                    v.upSpine:setVisible(true)
                end

                --角色转向
                v.upSpine:setRotationSkewY(angle)
                v.downSpine:setRotationSkewY(angle)

                --设置半透明
                if isAlpha then
                    v.upSpine:setOpacity(100)
                    v.downSpine:setOpacity(100)
                else
                    v.upSpine:setOpacity(255)
                    v.downSpine:setOpacity(255)
                end

                if i == 1 then
                     -- 更新地图随人物移动
                    self.curViewPosition.x = self.curViewPosition.x + (nextPos.x - playerPos.x)/6.40
                    self.curViewPosition.y = self.curViewPosition.y - (nextPos.y - playerPos.y)/11.36
                    --滚动层滚动
                    self.worldView:scrollToPercentBothDirection(self.curViewPosition, 0, true)

                    if isArrived then
                        self:playerArrived()
                        break
                    end
                end
            end
        end
    end)
end

--人物到达回调
function ExpediMapLayer:playerArrived()
    self:unscheduleUpdate()
    --设置骨骼为行走
    for i,v in ipairs(self.mMemberNodeList) do
        v.upSpine:setToSetupPose()
        v.upSpine:setAnimation(0, "daiji", true)
        v.downSpine:setToSetupPose()
        v.downSpine:setAnimation(0, "daiji", true)
        v.changeTag = false
    end
    self:readyToFight()
end
--开战前气泡动画
function ExpediMapLayer:readyToFight()
    local action = cc.Sequence:create({
        cc.CallFunc:create(function()
            self.mSpeakNodeList[self.mTargetNodeId]:setVisible(true)
        end),
        cc.ScaleTo:create(0.3, 1),
        cc.DelayTime:create(0.8),
        cc.CallFunc:create(function()
            self:fightViewAction()
        end)
        })
    self.mSpeakNodeList[self.mTargetNodeId]:runAction(action)
end
--开战图标动画
function ExpediMapLayer:fightViewAction()
    local fightSprite = ui.newSprite("zdfb_34.png")
    fightSprite:setPosition(320, 928)
    fightSprite:setScale(7.5)
    self.mParentLayer:addChild(fightSprite)

    local action = cc.Sequence:create({
        cc.Spawn:create({
            cc.EaseSineIn:create(cc.MoveTo:create(0.1, cc.p(320, 628))),
            cc.EaseSineIn:create(cc.ScaleTo:create(0.1, 1)),
            cc.CallFunc:create(function()
                MqAudio.playEffect("kaishizhandou.mp3")
            end)
            }),
        cc.DelayTime:create(1.5),
        cc.CallFunc:create(function()
            fightSprite:removeFromParent()
            fightSprite = nil
            self:fightLayer()
        end)
        })
    fightSprite:runAction(action)
end

function ExpediMapLayer:fightLayer()
    LayerManager.addLayer({
        name = "challenge.ExpediFightLayer",
        data = {fightInfo = self.mFightInfo, memberList = self.mMemberList},
        cleanUp = false,
        zOrder = Enums.ZOrderType.eWeakPop
        })
end

return ExpediMapLayer