    --[[
    文件名：GGZJArrestDetailLayer.lua
    描述：血刃悬赏通缉令详情页面 (GGZJ--->过关斩将)
    创建人：liucunxin
    创建时间：2016.12.17
--]]


local GGZJArrestDetailLayer = class("GGZJArrestDetailLayer", function(params)
    return display.newLayer(cc.c4b(0, 0, 0, 200))
end)

require("Config.XrxsConfig")
----- 以下信息均从GGZJLayer拷贝

-- 通缉令显示张数
local ArrestMaxNum = 3
------------

-- 构造函数
--[[
    params:
        -- 必传参数:父页面选择的通缉令id
        selectId                                                                                        -- 选择的卡牌的id,调用时只需要传入此参数即可(1, 2, 3)
        -- 默认传入参数:父页面中 setArrestIndex() 中定义, 以下参数用来获取缩小动画所对应的卡牌坐标
        arrestIndex                                                                                     -- 通缉令位置表
        arrestInfo                                                                                      -- 通缉令属性信息
        arrestInsList                                                                                   -- 实例列表
        ----------------------
        -- arrestInfo表结构如下:
        -- arrestInfo{
               arrestInsList{
                    arrestIndex[arrestIndex]{
                        index                                                                           -- 此为该页面中通过表数据解析出来的正确坐标
                    }
                    ...
               }
               ...
        }
        -- 可传参数
        playerInfo              -- 玩家信息
        nodeInfo                -- 节点信息
        maxArrestQuality        -- 最大背景星数
--]]
function GGZJArrestDetailLayer:ctor(params)
    -- dump(params)
    params = params or {}
    self.mIsWin = params.isWin and params.isWin or false
    self.mArrestIndex = params.arrestIndex
    self.mArrestInfo = params.arrestInfo
    self.mArrestInsList = params.arrestInsList
    self.mPlayerInfo = params.playerInfo
    self.mNodeInfo = params.nodeInfo
    -- self.mSubOffLv = params.subOffLv
    self.mSelectId = params.selectId
    self.mMaxArrestQuality = params.maxArrestQuality
    self.mTagImage = params.tagImage
    self.mNeedAction = false

    if not params.playerInfo or not params.nodeInfo then
        self:requestInfo(self.mSelectId)
    else
        self:initUI(self.mSelectId)
    end

    -- 新手引导
    self:executeGuide()
end

-- 初始化界面
function GGZJArrestDetailLayer:initUI(selectId)
    -- 创建该页面的父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)
    -- 创建触摸层
    self.mTouchLayer = cc.LayerColor:create(cc.c4b(0, 0, 0, 0))
    self:addChild(self.mTouchLayer)

    self:createArrestDetail(selectId)
end

-- 创建通缉令详细信息界面
function GGZJArrestDetailLayer:createArrestDetail(selectID)
    ui.registerSwallowTouch({node = self})
    -- 创建通缉令信息
    local arrestParent = self:createArrestDesign(selectID)
    -- 创建操作按钮
    self:createOptBattleBtn(self.mDetailLayer)

    local function touchBegin(touch ,event)
        return not ui.touchInNode(touch, arrestParent)
    end

    local function touchEnded(touch, event)
       if not ui.touchInNode(touch, arrestParent) then
        -- 计算当前选择卡牌位置序列
        local index = nil
        for i, v in pairs(self.mArrestIndex) do
            if v == selectID then
                index = i
            end
        end
        self.mParentLayer:runAction(
            cc.Sequence:create(
                cc.Spawn:create(
                    cc.ScaleTo:create(0.1, 0.01),
                    cc.MoveTo:create(0.1, cc.p(
                            self.mArrestInfo[self.mArrestInsList[self.mArrestIndex[index]].index].targetPos.x + self:getContentSize().width * 0.5,
                            self.mArrestInfo[self.mArrestInsList[self.mArrestIndex[index]].index].targetPos.y + self:getContentSize().height * 0.5
                        )
                    )
                ),
                cc.CallFunc:create(function ()
                    LayerManager.removeLayer(self)
                end),
                nil
                )
            )
       end
    end

    -- 注册通缉令点击事件
    ui.registerSwallowTouch({
        node = self.mTouchLayer,
        allowTouch = false,
        beganEvent = touchBegin,
        endedEvent = touchEnded
    })
end

-- 创建通缉令详细信息
--parent            父节点
--selectID          当前选择对象
function GGZJArrestDetailLayer:createArrestDesign(selectID)
    local tempId = (self.mNodeInfo.NodeId - 1)*5 + self.mNodeInfo.Stars

    -- 存放通缉令父节点
    local arrestParent = cc.Node:create()
    arrestParent:setPosition(cc.p(320, 618))
    self.mParentLayer:addChild(arrestParent)

    -- 通缉令背景
    local bgSprite = ui.newSprite("tjl_26.png")
    bgSprite:setPosition(cc.p(0, 0))
    arrestParent:addChild(bgSprite)
    local tempSize = bgSprite:getContentSize()

    -- 关闭按钮
    local arrestCloseBtn = ui.newButton({
        normalImage = "tjl_08.png",
        clickAction = function ()
            LayerManager.removeLayer(self)
        end
    })
    arrestCloseBtn:setAnchorPoint(cc.p(1, 1))
    arrestCloseBtn:setPosition(cc.p(tempSize.width * 0.98, tempSize.height * 0.98))
    bgSprite:addChild(arrestCloseBtn)

    -- xx悬赏令标签
    local arrestTitleLabel = ui.newSprite(self.mTagImage)
    arrestTitleLabel:setAnchorPoint(cc.p(0.5, 0.5))
    arrestTitleLabel:setPosition(cc.p(100, 205))
    arrestParent:addChild(arrestTitleLabel)
    -- dump(self.mNodeInfo,"nodeInfo")

    -- 星级标签
    local starNode = ui.newStarLevel(self.mNodeInfo.Stars, "c_75.png", nil, self.mMaxArrestQuality, "c_75.png")
    starNode:setPosition(cc.p(-100, -85))
    arrestParent:addChild(starNode)

    -- 头像背景图片
    local heroHeadBgPic = ui.newScale9Sprite("c_83.png", cc.size(240, 425))
    heroHeadBgPic:setPosition(cc.p(260, 290))
    bgSprite:addChild(heroHeadBgPic)

    -- 模板
    local stencilNode = cc.LayerColor:create(cc.c4b(255, 0, 0, 128))
    stencilNode:setContentSize(cc.size(170, 300))
    stencilNode:setIgnoreAnchorPointForPosition(false)
    stencilNode:setAnchorPoint(cc.p(0.5, 0))
    stencilNode:setPosition(cc.p(30, 40))

    -- 创建剪裁
    local clipNode = cc.ClippingNode:create()
    clipNode:setAlphaThreshold(1.0)
    clipNode:setStencil(stencilNode)
    clipNode:setPosition(cc.p(tempSize.width * 0.01 - 60, tempSize.height * 0.25))
    heroHeadBgPic:addChild(clipNode)

    -- figure缩放大小
    local tempScale = 0.5
    local stardardOffset = 490

    local heroModelID = self.mNodeInfo.TargetHeadImageId
    local headPic = ui.newSprite(Utility.getHeroStaticPic(heroModelID))
    headPic:setPosition(0, 0)
    clipNode:addChild(headPic)

     -- 头像底部黑框
    local underBorderSprite = ui.newSprite("tjl_28.png")
    underBorderSprite:setPosition(109, 380)
    bgSprite:addChild(underBorderSprite, 10)
    -- 印章
    local sealSprite = ui.newSprite("tjl_29.png")
    sealSprite:setPosition(200, 290)
    bgSprite:addChild(sealSprite, 10)

    -- 通缉令描述
    local introLabel = ui.newLabel({
        text = string.format("%s",  XrxsNodeModel.items[tempId].intro),
        size = 25,
        color = cc.c3b(0x3b, 0x1d, 0x06),
        -- outlineColor = cc.c3b(0x3b, 0x1d, 0x06),
        dimensions = cc.size(180, 0)
        })
    introLabel:setAnchorPoint(0, 1)
    introLabel:setPosition(235, 495)
    bgSprite:addChild(introLabel)


    -- 标签信息列表：对手姓名，对手战力，对手服务器，失败次数
    local labelList = {
        [1] = {
            text = TR("#3b1d06敌方: %s", self.mNodeInfo.TargetName),
            anchorPoint = cc.p(0, 0.5),
            x = -190,
            y = -123,
        },
        [2] = {
            text = TR("#3b1d06战力: %s", Utility.numberFapWithUnit(self.mNodeInfo.TargetFap)),
            anchorPoint = cc.p(0, 0.5),
            x = 30,
            y = -123,
        },
        [3] = {
            text = TR("#3b1d06服务器: %s", self.mNodeInfo.TargetServerName),
            anchorPoint = cc.p(0, 0.5),
            x = -190,
            y = -168,
        },
        [4] = {
            text = TR("#3b1d06失败次数:%s/3", self.mNodeInfo.FailureCount),
            anchorPoint = cc.p(0, 0.5),
            x = 30,
            y = -168,
        },
    }

    -- 创建信息标签
    for index, item in pairs(labelList) do
        local tempLabel = ui.newLabel(item)
        arrestParent:addChild(tempLabel)
    end

    -- 创建掉落物品预览
    local List = Utility.analysisStrResList(self.mNodeInfo.Reward)
    for i, v in ipairs(List) do
        v.cardShowAttrs = {
            CardShowAttr.eBorder,
            CardShowAttr.eNum
        }
    end

    local cardList = ui.createCardList({
        maxViewWidth = 450,
        space = 5,
        cardDataList = List,
        allowClick = true,
        })
    cardList:setAnchorPoint(0.5, 0.5)
    cardList:setPosition(cc.p(200, 65))
    cardList:setScale(0.8)
    bgSprite:addChild(cardList)

    -- 失败图标
    local failSprite = ui.newSprite("tjl_27.png")
    failSprite:setAnchorPoint(cc.p(0.5, 0.5))
    failSprite:setPosition(cc.p(tempSize.width * 0.3, - tempSize.height * 0.3 - 20))
    failSprite:setVisible(self.mNodeInfo.FailureCount >= 3)
    failSprite:setScale(1.8)
    arrestParent:addChild(failSprite)

    -- 通过图标
    local successSprite = ui.newSprite("tjl_17.png")
    successSprite:setAnchorPoint(cc.p(0.5, 0.5))
    successSprite:setPosition(cc.p(tempSize.width * 0.3, - tempSize.height * 0.3 - 20))
    successSprite:setVisible(self.mNodeInfo.IsWin)
    successSprite:setScale(3)
    arrestParent:addChild(successSprite)

    local action = cc.Spawn:create({
        cc.ScaleTo:create(0.2, 1),
        cc.MoveTo:create(0.25, cc.p(tempSize.width * 0.3, -tempSize.height * 0.3))
        })

    if self.mNeedAction then
        MqAudio.playEffect("gaizhang.mp3")
        if self.mNodeInfo.FailureCount >= 3 then
            failSprite:runAction(action)
        end
        if self.mNodeInfo.IsWin then
            successSprite:runAction(action:clone())
        end
    else
        successSprite:setPosition(cc.p(tempSize.width * 0.3, - tempSize.height * 0.3))
        successSprite:setScale(1)
        failSprite:setPosition(cc.p(tempSize.width * 0.3, - tempSize.height * 0.3))

        failSprite:setScale(1)
    end

    return bgSprite
end

-- 创建下方操作面板
function GGZJArrestDetailLayer:createOptBattleBtn()
    if not self.mNodeInfo.IsWin and self.mNodeInfo.FailureCount < 3 then
        -- 己方阵容 按钮
        local button = ui.newButton({
            text = TR("我的阵容"),
            normalImage = "c_28.png",
            position = cc.p(180, 215),
            clickAction = function()
                -- 进入布阵页面
                LayerManager.addLayer({
                    name = "challenge.GGZJFormationLayer",
                    cleanUp = false,
                    needRestore = true
                })
            end
        })
        self.mParentLayer:addChild(button)
        self.mMyFormationBtn_ = button

        -- 开始战斗 按钮
        local button = ui.newButton({
            text = TR("讨伐"),
            clickAudio = "sound_dianjikaizhan.mp3",
            normalImage = "c_28.png",
            position = cc.p(440, 215),
            clickAction = function()
                if self.mIsWin then
                    ui.showFlashView(TR("已通过"))
                    return
                end

                if self.mNodeInfo.FailureCount >= XrxsConfig.items[1].perNodeDareNumMax then
                    ui.showFlashView(TR("失败次数已达上限"))
                    return
                end

                self:requestGetFightBeforeInfo()
            end
        })
        self.mParentLayer:addChild(button)
        self.mFightBtn_ = button

        local staPic = Utility.getResTypeSubImage(ResourcetypeSub.eSTA)
        local enduranceLabel = ui.newLabel({
            text = TR("讨伐消耗:{%s}2", staPic),
        })
        enduranceLabel:setPosition(cc.p(button:getContentSize().width * 0.5, button:getContentSize().height + 15))
        button:addChild(enduranceLabel)
    else
        -- 提示标签
        local tempStr
        local tempColor
        if self.mNodeInfo.IsWin then
            tempStr = TR("已完成此悬赏令")
            tempColor = Enums.Color.eGreen
        end

        if self.mNodeInfo.FailureCount >= 3 then
            tempStr = TR("该悬赏令挑战失败，请更换其他悬赏令挑战")
            tempColor = Enums.Color.eRed
        end
        local completeLabel = ui.newLabel({
            text = tempStr,
            color = tempColor,
            size = 26,
        })
        completeLabel:setPosition(cc.p(320, 220))
        self.mParentLayer:addChild(completeLabel)
    end
end

--
function GGZJArrestDetailLayer:requestInfo(selectId)
    HttpClient:request({
        moduleName = "XrxsInfo",
        methodName = "GetInfo",
        callback = function(response)
            if response.Value == nil then
                LayerManager:removeLayer(self)
                return
            end
            print("requestGetInfo")
            self.mNodeInfo = response.Value.NodeInfo[selectId]
            self.mPlayerInfo = response.Value.Info
            if self.mIsWin ~= self.mNodeInfo.IsWin then
                self.mNeedAction = true
            end
            self.mIsWin = self.mNodeInfo.IsWin


            -- 判断是否通关
            local tempSuccess = false

            for i, v in ipairs(response.Value.NodeInfo) do
                if not v.IsWin then
                    break
                else
                    if i == #response.Value.NodeInfo then
                        tempSuccess = true
                    end
                end
            end
            -- if tempSuccess then
            --     print("mission clear")
            --     LayerManager:removeLayer(self)
            --     return
            -- end

            self:initUI(selectId)
        end
    })
end

-- 获取战斗准备信息
function GGZJArrestDetailLayer:requestGetFightBeforeInfo()
    -- 检查耐力
    if not Utility.isResourceEnough(ResourcetypeSub.eSTA, 2, true) then
        return
    end

    -- 调用战斗页面玩家名字、战力数据
    local enemyData = self.mNodeInfo
    local _, _, eventID = Guide.manager:getGuideInfo()
    local saveInfo
    if eventID == 11505 or eventID == 4010 then
        saveInfo = Guide.helper:tryGetGuideSaveInfo(eventID)
    end

    HttpClient:request({
        moduleName = "XrxsInfo",
        methodName = "GetFightInfo",
        guideInfo = saveInfo,
        svrMethodData = {self.mNodeInfo.NodeId},
        callback = function(response)
            if response.Status ~= 0 then return end
            -- 引导想关, 保存最后一步
            if eventID == 11505 or eventID == 4010 then
                Guide.manager:removeGuideLayer()
                Guide.manager:nextStep(eventID)
            end

            -- 战斗信息
            local value = response.Value
            -- 战斗页面控制信息
            local controlParams = Utility.getBattleControl(ModuleSub.eXrxs)
            local battleLayer = LayerManager.addLayer({
                name = "ComBattle.BattleLayer",
                data = {
                    data = value.FightInfo,
                    skip = controlParams.skip,
                    trustee = controlParams.trustee,
                    skill = controlParams.skill,
                    map = Utility.getBattleBgFile(ModuleSub.eXrxs),
                    callback = function(retData)
                        -- 本地战斗完成
                        CheckPve.ChallengeGGZJ(
                            {PlayerName = PlayerAttrObj:getPlayerAttrByName("PlayerName"),
                                FAP = PlayerAttrObj:getPlayerAttrByName("FAP")},
                            {PlayerName = enemyData.TargetName, FAP = enemyData.TargetFap},
                            {
                                nodeId = enemyData.NodeId,
                                result = retData.result,
                                data = retData.data,
                            }
                        )

                        if controlParams.trustee and controlParams.trustee.changeTrusteeState then
                            controlParams.trustee.changeTrusteeState(retData.trustee)
                        end
                    end
                },
            })
        end
    })
end

-- 数据恢复
function GGZJArrestDetailLayer:getRestoreData()
    local retData = {
        isWin = self.mIsWin,
        selectId = self.mSelectId,
        arrestIndex = self.mArrestIndex,
        arrestInfo = self.mArrestInfo,
        arrestInsList = self.mArrestInsList,
        tagImage = self.mTagImage,
        isRestore = true
        -- playerInfo = self.mPlayerInfo,
        -- nodeInfo = clone(self.mNodeInfo)
    }
    return retData
end

-- ========================== 新手引导 ===========================

-- 执行新手引导
function GGZJArrestDetailLayer:executeGuide()
    Guide.helper:executeGuide({
        -- 指向讨伐
        [11505] = {clickNode = self.mFightBtn_},
        -- 再次指向讨伐
        [4010] = {clickNode = self.mFightBtn_},
    })
end

return GGZJArrestDetailLayer
