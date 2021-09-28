--[[
	文件名：GGZJLayer.lua
	描述：江湖悬赏主页面 (GGZJ--->过关斩将)
	创建人：suntao
    修改人：lenjiazi
	创建时间：2016.12.12
--]]

local GGZJLayer = class("GGZJLayer", function()
    return display.newLayer()
end)

require("Config.XrxsXrlvModel")
require("Config.XrxsNodeModel")
require("Config.XrxsEnemyrefreshRelation")

-- 通缉令显示张数
local ARRESTMAXNUM = 3

-- 构造函数
--[[
    params:
    {
        data            服务器中 GGZJ 模块 GetGGZJInfo 方法返回的数据
        checkData       默认为false，不检查data与服务器的异同
        needAction      是否需要播放入场动画
        ---- 恢复数据
        arrestSelectID  通缉令选择实例，默认为中间（1）
    }
--]]
function GGZJLayer:ctor(params)
    -- 参数
    self.mCheckData = params.checkData
    self.mNeedAction = params.needAction ~= false

    -- self.mArrestInsList = params.arrestInsList
    if self.mCheckData == nil then
        self.mCheckData = false
    end

    -- 控件变量
    self.mProgressBar = nil
    self.mLevelLabel = nil
    self.mDefeatLabel = nil
    self.mNameLabel = nil
    self.mFapLabel = nil
    self.mServerLabel = nil

    -- 筛选配置表通缉令最大品质
    local tempMaxStarList = {}
    for i, v in pairs(XrxsNodeModel.items) do
        table.insert(tempMaxStarList, v)
    end
    table.sort(tempMaxStarList, function(a, b)return a.stars > b.stars end)
    self.mMaxArrestQuality = tempMaxStarList[1].stars

    -- 通缉令实例列表
    self.mArrestInsList = {}

    -- 通缉令ID
    self.mArrestID = 0

    -- 默认滑动控件上限距离
    self.mScrollLimDis = 480

    -- 数据变量
    self.mData = params.data and params.data or {}

    -- 创建该页面的父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    -- 创建背景
    local sprite = ui.newSprite("tjl_14.png")
    sprite:setPosition(320, 568)
    self.mParentLayer:addChild(sprite)

    -- 播放动画的时候添加一个临时屏蔽层
    self.tempShieldLayer = cc.LayerColor:create(cc.c4b(0, 0, 0, 0))
    self:addChild(self.tempShieldLayer)
    ui.registerSwallowTouch{node = self.tempShieldLayer}

    --箭头
    local arrowLeft = ui.newSprite("tjl_11.png")
    arrowLeft:setPosition(105, 628)
    arrowLeft:setRotation(180)
    self.mParentLayer:addChild(arrowLeft)
    local arrowRight = ui.newSprite("tjl_11.png")
    arrowRight:setPosition(510, 628)
    self.mParentLayer:addChild(arrowRight)

    -- 从服务器获取数据并显示
    self:requestGetGGZJInfo()

    -- 创建顶部资源栏和底部导航栏
    local topResource = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        currentLayerType = Enums.MainNav.eChallenge,
        topInfos = {
            ResourcetypeSub.eSTA,
            ResourcetypeSub.eDiamond,
            {
                resourceTypeSub = ResourcetypeSub.eFunctionProps,
                modelId = 16050091,
            }
        }
    })
    self:addChild(topResource)

    -- 注册继续新手引导事件
    Notification:registerAutoObserver(arrowLeft, handler(self, self.executeGuide), 
        {EventsName.eGameLayerPrefix .. "challenge.GGZJLayer"})
end
--创建椭圆控件
function GGZJLayer:createEllipseView()
    self._ellipseLayer = require("common.EllipseLayer3D").new({
        longAxias = 500,
        shortAxias = 50,
        fixAngle = 90,
        totalItemNum = 3,
        itemContentCallback = function(parent, index)
            self:createOneArrest(parent, index)
        end,
        alignCallback = function (index)
            self:refreshByEllipse(index)
        end
    })
    self._ellipseLayer:setPosition(cc.p(335, 600))
    self.mParentLayer:addChild(self._ellipseLayer)
end

--创建单个通缉令
function GGZJLayer:createOneArrest(parent, index)
    self:createArrest(parent, self.mArrestInfo[index], self.mNodeInfo[index])
end
--滑动刷新
function GGZJLayer:refreshByEllipse(index)
    self.mArrsetSelectID = index
    self:setRefreshBtn(self.mNodeInfo[index].IsWin or self.mNodeInfo[index].FailureCount >= 3)
end

-- 初始化界面
function GGZJLayer:createLayer()
    -- 创建UI
    self:initUI()

    -- 创建通缉令父节点
    self.mParentArrest = cc.Node:create()
    self.mParentLayer:addChild(self.mParentArrest)
    self.mParentArrest:setScale(0.8)
    self.mParentArrest:setPosition(cc.p(320, 568))
end

-- 创建UI
function GGZJLayer:initUI()
    -- 创建退出按钮
    local button = ui.newButton({
        normalImage = "c_29.png",
        position = cc.p(590, 1035),
        clickAction = function()
            LayerManager.removeLayer(self)
        end
    })
    self.mParentLayer:addChild(button)
    self.mCloseBtn = button

    -- 提示 按钮
    local button = ui.newButton({
            normalImage = "c_72.png",
            position = cc.p(50, 1035),
            clickAction = function()
                self:createTipsLayer()
            end
        })
    self.mParentLayer:addChild(button)

    -- 创建下方操作面板
    self:createOperationPanelViews()

    -- 判断已讨伐数
    local tempNum = 0
    for i, v in pairs(self.mNodeInfo) do
        if v.IsWin then
            tempNum = tempNum + 1
        end
    end
    -- 已讨伐标签
    local killScheduleLabel = ui.newLabel({
        text = TR("#FFFFFF已讨伐 : %s / %s", tempNum, #self.mNodeInfo),
        outlineColor = Enums.Color.eBlack,
        size = 24,
    })
    killScheduleLabel:setPosition(cc.p(self.mParentLayer:getContentSize().width * 0.5,
    self.mParentLayer:getContentSize().height * 0.8 - 20))
    self.mParentLayer:addChild(killScheduleLabel)

    -- 佣兵按钮
    local campBtn = ui.newButton({
        normalImage = "tb_168.png",
        clickAction = function ()
            LayerManager.addLayer({
                name = "challenge.GGZJFormationLayer",
                cleanUp = false,
                needRestore = true
            })
        end
        })
    campBtn:setPosition(425, 305)
    self.campBtn = campBtn
    self.mParentLayer:addChild(campBtn)

    -- 加成
    local attrLabel = ConfigFunc:getMonthAddAttrStr(true)
    if attrLabel then
        attrLabel:setPosition(cc.p(self.mParentLayer:getContentSize().width * 0.7,
    self.mParentLayer:getContentSize().height * 0.8 - 20))
        self.mParentLayer:addChild(attrLabel)
    end
end

-- 设置卡牌位置接口
-- 1 2   -- 三号位在最上面
--  3
function GGZJLayer:setArrestIndex(index)
    self.mArrestIndex = {
        [1] = 1,
        [2] = 2,
        [3] = 3
    }

    for i = ARRESTMAXNUM, 1, -1 do
        self.mArrestIndex[i] = index
        index = index - 1 <= 0 and ARRESTMAXNUM or index - 1
    end

    -- 通缉令信息
    self.mArrestInfo = {
        [self.mArrestIndex[1]] = {
            originPos = {
                x = -545,
                y = 40
            },
            targetPos = {
                x = -545,
                y = 40
            },
            rotation = 0,
            originScale = 1,
            scale = 0.9,
            zOrder = 10,
            index = 1
        },
        [self.mArrestIndex[2]] = {
            originPos = {
                x = 540,
                y = 30
            },
            targetPos = {
                x = 540,
                y = 30
            },
            rotation = 0,
            originScale = 1,
            scale = 0.9,
            zOrder = 20,
            index = 2
        },
        [self.mArrestIndex[3]] = {
            originPos = {
                x = 0,
                y = 60
            },
            targetPos = {
                x = 0,
                y = 60
            },
            rotation = 0,
            originScale = 1,
            scale = 0.9,
            zOrder = 30,
            index = 3
        }
    }
end

-- 创建通缉令实例大纲
--[[
    params:
        parent              -- 通缉令父节点
        arrestInfo          -- 子父节信息
    self.mArrestInsList     -- 通缉令实例表，只在初始化的时候向该表添加数据
    self.mArrestInsList = {
        [1] = {
            index = ,                   -- 位置序号
            arrestBgSprite = ,          -- 通缉令背景
            headSprite = ,              -- 头像
            parentNode = ,              -- 父节点
            ID,                         -- 实例id
            starNode,                   -- 星星结点
            arrestTitleName,            -- 标签名
        },
        [2] ......
    }
--]]
function GGZJLayer:createArrest(parent, arrestInfo, nodeInfo)
    -- 容错处理
    if not self.mArrestInsList then
        self.mArrestInsList = {}
        if self.mArrestID == table.maxn(self.mArrestInsList) then
            self.mArrestID = self.mArrestID + 1
            self.mArrestInsList[self.mArrestID] = {}
            -- 初始化实例初始坐标
            self.mArrestInsList[self.mArrestID].index = self.mArrestID
        else
            print("创建通缉令实例出错")
        end
    else
        if self.mArrestID == table.maxn(self.mArrestInsList) then
            self.mArrestID = self.mArrestID + 1
            self.mArrestInsList[self.mArrestID] = {}
            self.mArrestInsList[self.mArrestID].index = self.mArrestID
        else
            print("创建通缉令实例出错")
        end
    end

    -- 临时识别Id
    local tempId = self.mArrestID

    -- 存放通缉令父节点
    local arrestParent = cc.Node:create()
    -- arrestParent:setPosition(cc.p(arrestInfo.originPos.x, arrestInfo.originPos.y))
    arrestParent:setRotation(arrestInfo.rotation)
    arrestParent:setScale(arrestInfo.scale)
    parent:addChild(arrestParent, arrestInfo.zOrder)
    self.mArrestInsList[self.mArrestID].parentNode = arrestParent
    arrestParent:setVisible(false)

    -- 初始化实例ID
    self.mArrestInsList[self.mArrestID].ID = self.mArrestID
    arrestParent:setVisible(not self.mNeedAction)
    local tagImage
    if XrxsNodeModel.items[(nodeInfo.NodeId - 1) * 5 + 1].ID <= 5 then
        tagImage = "tjl_07.png"
    elseif XrxsNodeModel.items[(nodeInfo.NodeId - 1) * 5 + 1].ID > 5 and XrxsNodeModel.items[(nodeInfo.NodeId - 1) * 5 + 1].ID <= 10 then
        tagImage = "tjl_06.png"
    else
        tagImage = "tjl_05.png"
    end
    -- 通缉令背景
    local bgSpriteButton = ui.newButton({
        normalImage = "tjl_26.png",
        clickAction = function (pSender)
            -- 根据对应id选出位置表中的调用位置
            local tempIndex = nil
            for i, v in pairs(self.mArrestIndex) do
                if v == pSender.ID then
                    tempIndex = i
                    break
                end
            end
            -- 计算出位置信息表中原本真实的位置
            -- local realIndex = self.mArrestInfo[self.mArrestInsList[self.mArrestIndex[tempIndex]].index].index
            -- print(realIndex, self.mArrsetSelectID, tempIndex, "xxxxxxxxx")
            -- if self.mCanTouch and realIndex == self.mArrsetSelectID then
                local _, _, eventID = Guide.manager:getGuideInfo()
                MqAudio.playEffect("xuanshang_open.mp3")
                LayerManager.addLayer({
                    name = "challenge.GGZJArrestDetailLayer",
                    data = {
                        selectId = pSender.ID,
                        playerInfo = self.mPlayerInfo,
                        nodeInfo = self.mNodeInfo[pSender.ID],
                        arrestInsList = self.mArrestInsList,
                        arrestIndex = self.mArrestIndex,
                        arrestInfo = self.mArrestInfo,
                        maxArrestQuality = self.mMaxArrestQuality,
                        tagImage = tagImage,
                    },
                    cleanUp = false,
                    needRestore = not eventID, -- 新手引导时不需要restore
                })
            -- else
            --     -- self:clickMoveAction(realIndex)
            -- end
        end
    })

    bgSpriteButton:setPosition(cc.p(-20, 0))
    bgSpriteButton:setPressedActionEnabled(false)
    bgSpriteButton:setScale(0.78)
    arrestParent:addChild(bgSpriteButton)
    bgSpriteButton.ID = self.mArrestID
    self.mArrestInsList[self.mArrestID].arrestBgSprite = bgSpriteButton
    local tempBgSpriteSize = bgSpriteButton:getContentSize()

    -- xx悬赏令标签
    local arrestTitleLabel = ui.newSprite(tagImage)
    arrestTitleLabel:setAnchorPoint(cc.p(0.5, 0.5))
    arrestTitleLabel:setPosition(cc.p(100, 205))
    bgSpriteButton:getExtendNode2():addChild(arrestTitleLabel)
    self.mArrestInsList[self.mArrestID].arrestTitleName = arrestTitleLabel
    self.mArrestInsList[self.mArrestID].nodeId = nodeInfo.NodeId

    -- 星级标签
    local starNode = ui.newStarLevel(self.mNodeInfo[self.mArrestID].Stars, "c_75.png", nil, self.mMaxArrestQuality, "c_75.png")
    starNode:setPosition(cc.p(-100, -85))
    bgSpriteButton:getExtendNode2():addChild(starNode)
    self.mArrestInsList[self.mArrestID].starNode = starNode

    -- 头像节点
    local headPicNode = cc.Node:create()
    headPicNode:setContentSize(173, 293)
    headPicNode:setPosition(tempBgSpriteSize.width * 0.5, tempBgSpriteSize.height * 0.8)
    -- headPicNode:setScale(tempScale)
    bgSpriteButton:addChild(headPicNode)
    self.mArrestInsList[self.mArrestID].headPic = headPicNode

    -- 头像背景图片
    local heroHeadBgPic = ui.newScale9Sprite("c_83.png",cc.size(240, 425))
    heroHeadBgPic:setPosition(cc.p(260, 290))
    bgSpriteButton:addChild(heroHeadBgPic)
    heroHeadBgPic:setTag(9999)

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
    clipNode:setPosition(cc.p(tempBgSpriteSize.width * 0.01 - 60, tempBgSpriteSize.height * 0.25))
    heroHeadBgPic:addChild(clipNode)

    -- figure缩放大小
    local tempScale = 0.5
    local stardardOffset = 350

    local heroModelID = self.mNodeInfo[self.mArrestID].TargetHeadImageId
    local headPic = ui.newSprite(Utility.getHeroStaticPic(heroModelID))
    headPic:setPosition(0, 0)
    clipNode:addChild(headPic)

    -- 头像底部黑框
    local underBorderSprite = ui.newSprite("tjl_28.png")
    underBorderSprite:setPosition(109, 380)
    bgSpriteButton:addChild(underBorderSprite, 10)
    -- 印章
    local sealSprite = ui.newSprite("tjl_29.png")
    sealSprite:setPosition(200, 290)
    bgSpriteButton:addChild(sealSprite, 10)

    -- 通缉令描述
    local tempId = (nodeInfo.NodeId - 1)*5 + nodeInfo.Stars
    local introLabel = ui.newLabel({
        text = string.format("%s",  XrxsNodeModel.items[tempId].intro),
        size = 25,
        color = cc.c3b(0x3b, 0x1d, 0x06),
        -- outlineColor = cc.c3b(0x3b, 0x1d, 0x06),
        dimensions = cc.size(180, 0)
        })
    introLabel:setAnchorPoint(0, 1)
    introLabel:setPosition(235, 495)
    bgSpriteButton:addChild(introLabel)


    function headPicNode.refreshFigureNode()
        if heroHeadBgPic then
            -- bgSpriteButton:removeChildByTag(9999)
            local tempNodeId = self.mNodeInfo[self.mArrsetSelectID].NodeId
            local tempId =(tempNodeId - 1)*5 + self.mNodeInfo[self.mArrsetSelectID].Stars
            introLabel:setString(string.format("%s",  XrxsNodeModel.items[tempId].intro))
        end
        -- 头像背景图片
        local heroModelID = self.mNodeInfo[self.mArrsetSelectID].TargetHeadImageId
        headPic:setTexture(Utility.getHeroStaticPic(heroModelID))
        
    end

    -- 掉落物品预览
    local List = Utility.analysisStrResList(nodeInfo.Reward)
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
    cardList:setPosition(cc.p(0, -180))
    bgSpriteButton:getExtendNode2():addChild(cardList)
    self.mArrestInsList[self.mArrestID].cardList = cardList

    -- 创建文字按钮
    local browseDetailLabel = ui.newLabel({
        text = TR("点击查看详情"),
        align = TEXT_ALIGN_CENTER,
        color = cc.c3b(0x90, 0x6b, 0x33),
        size = 40
        })
    browseDetailLabel:setPosition(cc.p(0, -260))
    bgSpriteButton:getExtendNode2():addChild(browseDetailLabel)
    self.mArrestInsList[self.mArrestID].infoLabel = browseDetailLabel

    -- 失败图标
    local failSprite = ui.newSprite("tjl_27.png")
    failSprite:setAnchorPoint(cc.p(0.5, 0.5))
    failSprite:setPosition(cc.p(tempBgSpriteSize.width * 0.85, tempBgSpriteSize.height * 0.2))
    -- failSprite:setScale(1.5)
    failSprite:setVisible(self.mNodeInfo[self.mArrestID].FailureCount >= 3)
    bgSpriteButton:addChild(failSprite)
    self.mArrestInsList[self.mArrestID].failSprite = failSprite

    -- 通过图标
    local successSprite = ui.newSprite("tjl_17.png")
    successSprite:setAnchorPoint(cc.p(0.5, 0.5))
    successSprite:setPosition(cc.p(tempBgSpriteSize.width * 0.8, tempBgSpriteSize.height * 0.2))
    successSprite:setVisible(self.mNodeInfo[self.mArrestID].IsWin)
    -- successSprite:setScale(1.5)
    bgSpriteButton:addChild(successSprite)
    self.mArrestInsList[self.mArrestID].successSprite = successSprite
end

-- 下方操作面板
function GGZJLayer:createOperationPanelViews()
    --下半部分颜色背景
    local bottomBgSprite = ui.newScale9Sprite("tjl_22.png", cc.size(640, 160))
    bottomBgSprite:setPosition(320, 170)
    self.mParentLayer:addChild(bottomBgSprite)

    -- 通缉令五星刷新提示
    function refreshMention(type)
        local buttonInfo = {
            [1] = {
                normalImage = "c_28.png",
                text = TR("确定"),
                clickAction = function(layerObj, btnObj)
                    LayerManager.removeLayer(layerObj)
                    self:requestRefreshArr(type)
                end
            },
            [2] = {
                normalImage = "c_28.png",
                text = TR("取消"),
                clickAction = function(layerObj, btnObj)
                    LayerManager.removeLayer(layerObj)
                end
            },
        }

        -- 引导时不提示对话框
        local _, _, eventID = Guide.manager:getGuideInfo()
        if self.mNodeInfo[self.mArrsetSelectID].Stars >= self.mMaxArrestQuality and eventID ~= 11503 then
            MsgBoxLayer.addDIYLayer({
                msgText = TR("当前悬赏令为%d星级，此星级为最高星级，确认刷新吗？", self.mMaxArrestQuality),
                btnInfos = buttonInfo
            })
        else
           self:requestRefreshArr(type)
        end
    end

    -- 创建刷新按钮
    self.mRefreshBtn = ui.newButton({
        normalImage = "c_83.png",
        text = TR("刷新"),
        size = cc.size(145, 65),
        fontSize = 30,
        outlineColor = cc.c3b(0x5b, 0x34, 0x21),
        clickAction = function ()
            -- 是否已经通过该节点
            if not self.mNodeInfo[self.mArrsetSelectID].IsWin and self.mNodeInfo[self.mArrsetSelectID].FailureCount < 3 then
                -- 检测刷新令是否够用
                if GoodsObj:getCountByModelId(16050091) > 0 then
                    refreshMention(2)
                else
                    if Utility.getOwnedGoodsCount(ResourcetypeSub.eDiamond) >= self.mNeedDiaInfo[1].num then
                        refreshMention(3)
                    else
                        MsgBoxLayer.addGetDiamondHintLayer()
                        -- 无法刷新，引导失败
                        local _, _, eventID = Guide.manager:getGuideInfo()
                        if eventID == 11503 then
                            Guide.helper:guideError(eventID, -1)
                        end
                    end
                end
            else
                local str = self.mNodeInfo[self.mArrsetSelectID].IsWin and TR("已通过") or TR("该节点挑战失败，请更换挑战节点")
                if self.mSuccess then
                    str = TR("已通关")
                end
                ui.showFlashView({text = str})
            end
        end
    })
    self.mRefreshBtn:setAnchorPoint(cc.p(0.5, 0.5))
    self.mRefreshBtn:setPosition(cc.p(200, 285))
    self.mParentLayer:addChild(self.mRefreshBtn, 3)
    self:crerateRefreshInfo(self.mRefreshBtn)

    local tempSprite = ui.newSprite("tjl_13.png")
    tempSprite:setPosition(200, 340)
    self.mParentLayer:addChild(tempSprite, 2)

    -- 操作按钮的父节点
    if not self.optParentNode then
        self.optParentNode = cc.Node:create()
    end
    self.optParentNode:setPosition(cc.p(320, 180))
    self.mParentLayer:addChild(self.optParentNode)

    -- 官阶图标
    local offRankSprite = ui.newSprite(XrxsXrlvModel.items[self.mSubOffLv].lvPic)
    offRankSprite:setAnchorPoint(cc.p(0.5, 0.5))
    offRankSprite:setPosition(cc.p(-240, 0))
    self.optParentNode:addChild(offRankSprite)
    local tempOffRankSize = offRankSprite:getContentSize()

    -- 官阶星数
    -- local tempNum = self.mPlayerInfo.LvStar > 0 and (self.mPlayerInfo.LvStar % 5 == 0 and 5 or self.mPlayerInfo.LvStar % 5) or 0
    -- local offRankStar = ui.newStarLevel(self.mOffStarLv)
    -- offRankStar:setPosition(cc.p(tempOffRankSize.width * 0.5, tempOffRankSize.height * 0.25))
    -- offRankSprite:addChild(offRankStar)


    -- 官阶名字
    local offName = XrxsXrlvModel.items[self.mSubOffLv] and XrxsXrlvModel.items[self.mSubOffLv].name or TR("暂无官阶")
    local offNameLabel = ui.newLabel({
        text = TR("%s", offName),
        align = TEXT_ALIGN_CENTER,
        outlineColor = cc.c4b(0, 0, 0, 150),
        outlineSize = 2
    })
    offNameLabel:setAnchorPoint(cc.p(0.5, 0.5))
    offNameLabel:setPosition(cc.p(tempOffRankSize.width * 0.5, tempOffRankSize.height * 0.06))
    offRankSprite:addChild(offNameLabel)


    -- 悬赏铜钱奖励标签
    local rewardNum = XrxsXrlvModel.items[self.mSubOffLv] and XrxsXrlvModel.items[self.mSubOffLv].goldR / 100 or 0
    local rewardLabel = ui.newLabel({
        text = TR("悬赏获得铜钱奖励+%s%%", rewardNum),
        color = Enums.Color.eNormalWhite,
        outlineColor = Enums.Color.eBlack,
        aling = TEXT_ALIGN_CENTER
    })
    rewardLabel:setAnchorPoint(cc.p(0, 0.5))
    rewardLabel:setPosition(cc.p(tempOffRankSize.width + 35, tempOffRankSize.height * 0.55 + 10))
    offRankSprite:addChild(rewardLabel)

    -- 经验条
    local tempMaxLv = XrxsXrlvModel.items[self.mSubOffLv] and XrxsXrlvModel.items[self.mSubOffLv + 1] or XrxsXrlvModel.items[#XrxsXrlvModel.items]
    local progressBar = require("common.ProgressBar").new({
        bgImage = "tjl_10.png",
        barImage = "tjl_09.png",
        currValue = self.mPlayerInfo.LvStar,
        size = 18,
        outlineColor = Enums.Color.eBlack,
        outlineSize = 1,
        maxValue = tempMaxLv.needStars,
        needLabel = true,
        color = Enums.Color.eWhite,
    })
    progressBar:setAnchorPoint(cc.p(0, 0))
    progressBar:setPosition(cc.p(tempOffRankSize.width + 35, tempOffRankSize.height * 0.18))
    offRankSprite:addChild(progressBar)

    local starTag = ui.newSprite("c_75.png")
    starTag:setPosition(progressBar:getContentSize().width * 0.5 - 55, progressBar:getContentSize().height * 0.5)
    starTag:setScale(0.7)
    progressBar:addChild(starTag)

    -- 官阶奖励按钮

    -- self.mRewarBox = ui.newEffect({
    --     effectName = "effect_hualibaoxiang",
    --     parent = self.optParentNode,
    --     position = cc.p(165, 0),
    --     scale = 0.2,
    -- })


    self.mRewardBtn = ui.newButton({
        text = TR("官阶奖励"),
        normalImage = "r_05.png",
        fontSize = 22,
        -- size = cc.size(90, 90),
        position = cc.p(165, 0),
        clickAction = function ()
            -- self:createRewardLayer(self.mParentLayer)
            LayerManager:addLayer({
                LayerManager.addLayer({
                    name = "challenge.GGZJOffRewardLayer",
                    data = {
                        parent = self.mParentLayer,
                        playerInfo = self.mPlayerInfo,
                        subOffLv = self.mSubOffLv,
                        offLv = self.mOffLv,
                    },
                    cleanUp = false
                })
            })
        end
    })
    self.optParentNode:addChild(self.mRewardBtn)
    self.mRewardBtn.mTitleLabel:setPositionY(self.mRewardBtn.mTitleLabel:getPositionY() - 50)

    -- 悬赏奖励按钮
    -- self.mCompensation = ui.newEffect({
    --     effectName = "effect_jipingbaoxiang",
    --     parent = self.optParentNode,
    --     position = cc.p(265, -10),
    --     scale = 0.2,
    -- })
    self.mCompensationBtn = ui.newButton({
        text = TR("悬赏奖励"),
        fontSize = 22,
        normalImage = "r_06.png",
        -- size = cc.size(90, 90),
        position = cc.p(265, 0),
        clickAction = function ()
            ui.newEffect({
                effectName = "effect_ui_xiangzitexiao",
                parent = self.optParentNode,
                position = cc.p(165, 0),
                -- endListener    动作结束回调
                completeListener = function()
                    self.mCompensation:removeFromParent(true)
                end
            })
            LayerManager:addLayer({
                LayerManager.addLayer({
                    name = "challenge.GGZJCompensationLayer",
                    data = {
                        parent = self.mParentLayer,
                        playerInfo = self.mPlayerInfo,
                    },
                    cleanUp = false
                })
            })
        end
    })
    self.optParentNode:addChild(self.mCompensationBtn)
    self.mCompensationBtn.mTitleLabel:setPositionY(self.mCompensationBtn.mTitleLabel:getPositionY() - 50)



    -- 注册小红点
    local redDotModuleList = {
        {
            subKey = "XrxsXrlv",
            btn = self.mRewardBtn,
            effect = self.mRewarBox,
        },
        {
            subKey = "XrxsSupply",
            btn = self.mCompensationBtn,
            effect = self.mCompensation,
        },
    }

    for i, v in pairs(redDotModuleList) do
        -- v.effect:setAnimation(0, "daiji", true)
        local function dealRedDotVisible(redDotSprite)
            local redDotData = RedDotInfoObj:isValid(ModuleSub.eXrxs, v.subKey)
            redDotSprite:setVisible(redDotData)
        end
        ui.createAutoBubble({refreshFunc = dealRedDotVisible, eventName = RedDotInfoObj:getEvents(ModuleSub.eXrxs, v.subKey), parent = v.btn})
    end
end


-- 创建刷新按钮旁边信息
function GGZJLayer:crerateRefreshInfo(parent)
    parent:removeAllChildren()
    local isUseDia = GoodsObj:getCountByModelId(16050091) > 0

    self.mNeedDiaInfo = self.mPlayerInfo.DiamondRefreshCount + 1 >= #XrxsEnemyrefreshRelation.items and
    Utility.analysisStrResList(XrxsEnemyrefreshRelation.items[#XrxsEnemyrefreshRelation.items].use) or
    Utility.analysisStrResList(XrxsEnemyrefreshRelation.items[self.mPlayerInfo.DiamondRefreshCount + 1].use)

    local diamond, label= ui.createDaibiView({
        resourceTypeSub = ResourcetypeSub.eDiamond,
        number = self.mNeedDiaInfo[1].num,
        fontColor = Enums.Color.eNormalWhite,
        outlineColor = cc.c3b(0x25, 0x16, 0x05)
        })
    diamond:setAnchorPoint(cc.p(0.5, 0.5))
    diamond:setPosition(cc.p(parent:getContentSize().width  * 0.5,
        parent:getContentSize().height + 50))
    diamond:setVisible(not isUseDia)
    parent:addChild(diamond)
    self.mDiamond = diamond
    self.mDiamondLabel = label
    --红色斜杠
    local redLine = ui.newSprite("cdjh_14.png")
    redLine:setRotation(-10)
    redLine:setPosition(35, 15)
    self.mDiamond:addChild(redLine)
    redLine:setVisible(false)
    self.mRedLine = redLine

    local refreshLabel = ui.newLabel({
        text = TR("{%s} %s",Utility.getDaibiImage(ResourcetypeSub.eFunctionProps, 16050091), 1),
        color = cc.c3b(0xff, 0xff, 0xff),
        outlineColor = cc.c4b(0x6b, 0x48, 0x2b),
        outlineSize = 2,
        align = TEXT_ALIGN_CENTER
    })
    refreshLabel:setAnchorPoint(cc.p(0.5, 0.5))
    refreshLabel:setPosition(cc.p(parent:getContentSize().width * 0.5, parent:getContentSize().height + 45))
    refreshLabel:setVisible(GoodsObj:getCountByModelId(16050091) > 0)
    parent:addChild(refreshLabel)

    -- 注册刷新令数量改变事件
    local function autoChangeRefreshLabel(tempLabel)
        -- refreshLabel:setString(TR("拥有江湖令:%s", GoodsObj:getCountByModelId(16050091)))
    end
    Notification:registerAutoObserver(refreshLabel, autoChangeRefreshLabel, EventsName.ePropRedDotPrefix..16050091)
end

--- ==================== 弹出窗口 =======================
-- 创建规则提示层
function GGZJLayer:createTipsLayer()
    -- 规则
    local rules = {
        [1] = TR("1.悬赏分为甲乙丙三个等级，被通缉的等级越高敌人实力越强，相同的通缉等级情况下也会有星数差异，可以通过元宝刷新星数，同等级情况下星数越高奖励越丰厚。"),
        [2] = TR("2.每日拥有一次免费刷新悬赏奖励的次数"),
        [3] = TR("3.进行悬赏时允许有3次失败，失败后无法继续挑战，每日零点自动刷新"),
        [4] = TR("4.完成一次江湖悬赏可获得大量铜币和珍稀道具奖励，同时累积星数"),
        [5] = TR("5.累积星数可以使自身获得朝廷官阶，官阶晋升时可获得奖励，同时官阶等级对应相应的奖励，官阶等级越高，可领取的官阶补给越丰厚"),
    }
    MsgBoxLayer.addRuleHintLayer(TR("规则提示"), rules)
end

--- ==================== 特效相关 =========================
-- 通缉令出现动画
-- 此处index不需要外部传值
function GGZJLayer:playEnemyAppear(index)
    if self.mNeedAction and not self.mSuccess then
        self.mCanTouch = false
        self.mRewardBtn:setTouchEnabled(false)
        self.mCompensationBtn:setTouchEnabled(false)
        index = index or self.mArrestIndex[1]
        -- 判断表中实体是否为空，不为空则继续让下一个节点播放动画
        local callfunc = cc.CallFunc:create(function ()
            if index ~= self.mArrestIndex[ARRESTMAXNUM] then
                index = index + 1 > ARRESTMAXNUM and 1 or index + 1
                self:playEnemyAppear(index)
                MqAudio.playEffect("sound_xrxs_drop.mp3")
            end
        end)

        -- 父页面动画
        local pCallfunc = cc.CallFunc:create(function ()
            self:runAction(
                cc.Sequence:create(
                    cc.EaseExponentialOut:create(cc.ScaleTo:create(0.2, 0.98)),
                    cc.CallFunc:create(function()
                        MqAudio.playEffect("sound_xrxs_drop.mp3")
                    end),
                    cc.ScaleTo:create(0.1, 1),
                    cc.CallFunc:create(function()
                        -- 添加触摸监听
                        self:setTouch()
                        self.mCanTouch = true
                        self.mRewardBtn:setTouchEnabled(true)
                        self.mCompensationBtn:setTouchEnabled(true)
                        -- 刷新通缉令状态
                        self:reqreshArrestState()
                        -- 取消屏蔽通缉令点击
                        for index, item in pairs(self.mArrestInsList) do
                            item.arrestBgSprite:setTouchEnabled(true)
                        end
                        -- 移除临时屏蔽层
                        self:removeChild(self.tempShieldLayer)
                    end),
                    nil
                )
            )
        end)

        self.mArrestInsList[index].parentNode:setVisible(true)
        -- 禁用悬赏令点击
        -- self.mArrestInsList[index].arrestBgSprite:setTouchEnabled(false)


        if index ~= self.mArrestIndex[ARRESTMAXNUM] then
            self.mArrestInsList[index].parentNode:setScale(self.mArrestInfo[index].originScale * 1.5)
            self.mArrestInsList[index].parentNode:runAction(
                cc.Sequence:create(
                    cc.EaseSineIn:create(cc.ScaleTo:create(0.25, self.mArrestInfo[index].scale)),
                    callfunc,
                    nil
                )
            )
        else
            self.mArrestInsList[index].parentNode:setScale(self.mArrestInfo[index].originScale * 1.8)
            self.mArrestInsList[index].parentNode:runAction(
                cc.Sequence:create(
                    cc.EaseExponentialOut:create(cc.ScaleBy:create(0.2, self.mArrestInfo[index].originScale * 1.3)),
                    cc.EaseSineIn:create(cc.ScaleTo:create(0.05,
                    self.mArrestInfo[index].scale)),
                    callfunc,
                    pCallfunc,
                    nil
                )
            )
        end
    else
        for i, v in ipairs(self.mArrestInsList) do
            v.parentNode:setVisible(true)
            -- v.arrestBgSprite:setTouchEnabled(not self.mNodeInfo[self.mArrestInsList[i].ID].IsWin)
            -- v.parentNode:setPosition(cc.p(self.mArrestInfo[i].targetPos.x, self.mArrestInfo[i].targetPos.y))
        end
        -- 刷新卡牌状态
        self:reqreshArrestState()
        -- 禁用悬赏令点击
        -- for _, v in pairs(self.mArrestInsList) do
        --     if self.mNodeInfo[v.ID].IsWin then
        --         v.arrestBgSprite:setTouchEnabled(false)
        --         -- 禁用cardlist的点击
        --         --todo
        --     end
        -- end
        -- 添加触摸监听,通关之后便不添加触摸事件
        -- if not self.mSuccess then
        -- 移除临时屏蔽层
        self:removeChild(self.tempShieldLayer)
        self:setTouch()
        -- end
    end
end

-- 刷新通缉令状态
function GGZJLayer:reqreshArrestState()
    for _, v in pairs(self.mArrestInsList) do
        v.failSprite:setVisible(self.mNodeInfo[v.ID].FailureCount >= 3)
        v.successSprite:setVisible(self.mNodeInfo[v.ID].IsWin)
    end
end

-- 设置触摸事件
function GGZJLayer:setTouch()
    self.mCanTouch = true
    local startPosX, prevPosX = 0, 0
    local isMove = false
    local moveRight = true
    -- local diffX = 0
    local prev = {x = 0, y = 0}
    local start = {x = 0, y = 0}

    -- 触摸开始函数
    local function touchBegin(touch, event)
        prev.x = touch:getLocation().x
        prev.y = touch:getLocation().y

        start.x = touch:getLocation().x
        start.y = touch:getLocation().y

        return true
    end

    -- 触摸中函数
    local function touchMoved(touch, event)
        local diffX = touch:getLocation().x - prev.x
        prev.x = touch:getLocation().x
        prev.y = touch:getLocation().y
        if diffX > 0 then
            self._ellipseLayer:setRadiansOffset(-1)
        end
        if diffX < 0 then
            self._ellipseLayer:setRadiansOffset(1)
        end
    end

    -- 触摸结束函数
    local function touchEnd(touch, event)
        local diffX = touch:getLocation().x - start.x
        if diffX > 100 then 
            self._ellipseLayer:moveToPreviousItem() 
            return 
        end
        if diffX < -100 then self._ellipseLayer:moveToNextItem() 
            return 
        end
        self._ellipseLayer:alignTheLayer(true)
    end

    local function onTouchCancel(touch, event)
        local diffX = touch:getLocation().x - start.x
        if diffX > 100 then 
            self._ellipseLayer:moveToPreviousItem() 
            return 
        end
        if diffX < -100 then self._ellipseLayer:moveToNextItem() 
            return 
        end
        self._ellipseLayer:alignTheLayer(true)
    end

    -- 创建触摸层
    local touchNode = cc.Layer:create()
    self.mParentLayer:addChild(touchNode)
    ui.registerSwallowTouch({
        node = touchNode,
        allowTouch = false,
        beganEvent = touchBegin,
        movedEvent = touchMoved,
        endedEvent = touchEnd,
        cancellEvent = onTouchCancel,
    })
end

--- ==================== 数据相关 =======================
-- 数据恢复
function GGZJLayer:getRestoreData()
    local retData = {
        -- playAnimation = self.mIsAuto and false or true,
        -- data = self.mData,
        -- checkData = self.mCheckData,
        -- isAuto = self.mIsAuto,
        -- arrestSelectID = self.mArrsetSelectID,
        needAction = false,
    }
    return retData
end

--- ==================== 服务器数据请求相关 =======================
-- 返回信息数据结构
--[[
{
   Info:玩家血刃悬赏信息
        {
            ShareType：雇佣类型(0:未雇佣1:拥有公会雇佣兵2:雇佣神将)
            ShareId：雇佣兵Id
            HeroModelId：神将模型Id
            HeroLv：神将等级
            Formation1：阵型1号
            Formation2：阵型2号
            Formation3：阵型3号
            Formation4：阵型4号
            Formation5：阵型5号
            Formation6：阵型6号
            Formation7：雇佣兵7号
            DiamondRefreshCount：钻石刷新次数
            LvStar：官阶星数
            LvMaxRewardId：血刃等级领取的宝箱最大宝箱id
            SupplyStar：补给可用星数
            SupplyRefreshCount：补给刷新次数
            SupplyMaxRewardId：补给领取的最大奖励id
            ClearanceRewardsDate：最近领取通过奖励时间
            Crdate：最近更新时间
        }
        NodeInfo:节点数据
        [
            {
                NodeId：节点Id
                Stars：星数
                FailureCount：失败次数
                IsWin：是否胜利
                Reward：节点奖励
                TargetName：对手信息
                TargetFap：对手战力
                TargetServerName：对手服务器名称
                TargetHeadImageId：对手头像
            },
            ......
        ]
}
--]]

-- 获取总信息
function GGZJLayer:requestGetGGZJInfo()
	HttpClient:request({
    	moduleName = "XrxsInfo",
    	methodName = "GetInfo",
    	--svrMethodData = {},
    	callback = function(response)
    	    if response.Status ~= 0 then
                LayerManager.removeLayer(self)
                return
            end

            if self.mData ~= nil and self.mCheckData then
                self.mCheckData = false
            end

            -- 玩家信息
            self.mPlayerInfo = response.Value.Info

            -- 节点信息
            self.mNodeInfo = response.Value.NodeInfo

            -- 官阶小等级
            for i, v in ipairs(XrxsXrlvModel.items) do
                -- 星数容错处理
                self.mPlayerInfo.LvStar = self.mPlayerInfo.LvStar > XrxsXrlvModel.items[#XrxsXrlvModel.items].needStars
                    and XrxsXrlvModel.items[#XrxsXrlvModel.items].needStars or self.mPlayerInfo.LvStar

                -- 若星数超过上限则直接取最后一个
                if self.mPlayerInfo.LvStar >= XrxsXrlvModel.items[#XrxsXrlvModel.items].needStars then
                    self.mSubOffLv = #XrxsXrlvModel.items
                    break
                end

                if self.mPlayerInfo.LvStar < v.needStars then
                    self.mSubOffLv = self.mPlayerInfo.LvStar <= 0 and 1 or i - 1
                    break
                end
            end

            --dump(self.mSubOffLv, "subLv")

            -- 五个小等级等于一个大等级
            -- 官阶星数
            self.mOffStarLv = math.ceil(self.mSubOffLv % 5 == 0 and 5 or self.mSubOffLv % 5)
            -- 官阶大等级
            self.mOffLv = math.ceil(self.mSubOffLv / 5)
            -- 创建层
            self:createLayer()

            -- 数据修正
            -- for i = 1, #self.mNodeInfo do
            --     table.sort(self.mData.Target[i].SlotFormationInfo, function (a, b)
            --         return a.Formation < b.Formation
            --     end)
            -- end

            -- 选择通缉令ID，默认为1(正中的玩家id)
            local tempIndex = 1
            for index, item in ipairs(self.mNodeInfo) do
                if not item.IsWin and not (item.FailureCount >= 3) then
                    tempIndex = index
                    break
                end
            end
            self.mArrsetSelectID = tempIndex
            self:setArrestIndex(self.mArrsetSelectID)
            self:createEllipseView()
            self._ellipseLayer:moveToIndexItem(self.mArrsetSelectID)

            -- 创建通缉令
            -- for i = 1, 3 do
            --     self:createArrest(self.mParentArrest, self.mArrestInfo[i], self.mNodeInfo[i])
            -- end
            


            -- 刷新刷新按钮状态
            self:setRefreshBtn(self.mNodeInfo[self.mArrsetSelectID].IsWin)

            if self.mData.NodeId == 0 then
                self.mCheckBtn:setVisible(false)
                self.mCheckBtn:setCheckState(false)
                self.mParentLayer:stopAction(self.mTimeAction)
                self.mFightBtn_:setTitleText(TR("讨伐"))
            end

	        -- 判断是否通关
            self.mSuccess = false

            for i, v in ipairs(self.mNodeInfo) do
                if not v.IsWin then
                    break
                else
                    if i == #self.mNodeInfo then
                        self.mSuccess = true
                    end
                end
            end
            -- self:setTouch()
            -- if not self.mSuccess then
            self:playEnemyAppear()
            -- else
            --     self:playEnemyAppear()
            --     self:playClearEffect()
            -- end

            -- 执行新手引导
            self:executeGuide()
    	end
	})
end

-- 请求刷新通缉令
-- type             道具类型  2:道具  3:钻石
function GGZJLayer:requestRefreshArr(type)
    HttpClient:request({
        moduleName = "XrxsInfo",
        methodName = "RefreshNode",
        guideInfo = Guide.helper:tryGetGuideSaveInfo(11503),
        svrMethodData = {self.mArrestInsList[self.mArrsetSelectID].nodeId, type},
        callback = function(response)
            if response.Value == nil then
                ui.showFlashView({text = TR("请求数据为空")})
                return
            end
            --[[--------新手引导--------]]--
            local _, _, eventID = Guide.manager:getGuideInfo()
            if eventID == 11503 then
                Guide.manager:nextStep(eventID)
                self:executeGuide()
            end

            -- 设置刷新按钮状态图片
            self.mRefreshBtn:loadTextureNormal(GoodsObj:getCountByModelId(16050091) > 0 and "c_83.png" or "c_83.png")

            self.mNodeInfo[self.mArrsetSelectID] = clone(response.Value.NodeInfo)
            self.mPlayerInfo = response.Value.Info

            -- if type == 3 then
            ui.showFlashView(TR("刷新成功"))

            -- else
            --     ui.showFlashView(TR("刷新挑战节点%s", self.mArrsetSelectID))
            -- end
            -- 刷新通缉令大纲信息
            -- self.mArrestInsList[response.Value.NodeInfo.NodeId].arrestTitleName
            --     :setString(TR(XrxsNodeModel.items[(response.Value.NodeInfo.NodeId - 1) * 5 + 1].name.."%s", "悬赏令"))

            self.mArrestInsList[response.Value.NodeInfo.NodeId].starNode.
                setStarLevel(response.Value.NodeInfo.Stars, self.mMaxArrestQuality)

            -- 刷新cartnode信息
            local rewardList = Utility.analysisStrResList(response.Value.NodeInfo.Reward)
            for i, v in ipairs(rewardList) do
                v.cardShowAttrs = {
                    CardShowAttr.eBorder,
                    CardShowAttr.eNum
                }
            end
            self.mArrestInsList[response.Value.NodeInfo.NodeId].cardList.
                refreshList(rewardList)

            -- 刷新通缉令头像
            self.mArrestInsList[response.Value.NodeInfo.NodeId].headPic.refreshFigureNode()

            self:crerateRefreshInfo(self.mRefreshBtn)
        end
    })
end

-- 设置刷新按钮状态
function GGZJLayer:setRefreshBtn(isHide)
    -- self.mRefreshBtn:setVisible(not isHide)
    local tempStr
    if self.mNodeInfo[self.mArrsetSelectID].IsWin then
        tempStr = TR("#ABDF84已完成")
    else
        tempStr = TR("刷新")
    end
    if self.mNodeInfo[self.mArrsetSelectID].FailureCount >= 3 then
        tempStr = TR("#FF4A46失败")
    end

    -- self.mNodeWinLabel:setVisible(isHide)
    if isHide then
        -- self.mNodeWinLabel:setString(tempStr)
        self.mDiamond.daibiSprite:setTexture("tjl_12.png")
        self.mDiamondLabel:setString(string.format("#878787%s", self.mNeedDiaInfo[1].num))
        self.mRefreshBtn:setEnabled(false)
        self.mRefreshBtn.mTitleLabel:setString(tempStr)
        self.mRedLine:setVisible(true)
    else
        local daibiImage = Utility.getDaibiImage(ResourcetypeSub.eDiamond)
        self.mDiamond.daibiSprite:setTexture(daibiImage)
        self.mDiamondLabel:setString(string.format("#FFFFFF%s", self.mNeedDiaInfo[1].num))
        self.mRefreshBtn:setEnabled(true)
        self.mRefreshBtn.mTitleLabel:setString(tempStr)
        self.mRedLine:setVisible(false)
    end
end


-- ========================== 新手引导 ===========================

-- 执行新手引导
function GGZJLayer:executeGuide()
    local _, _, eventID = Guide.manager:getGuideInfo()
    if eventID == 11504 or eventID == 4002 or eventID == 4009 then
        self._ellipseLayer:setLocalZOrder(1)
    end
    Guide.helper:executeGuide({
        -- 箭头指向刷新按钮（首次刷新5星）
        [11503] = {clickNode = self.mRefreshBtn},
        -- 箭头指向悬赏令
        [11504] = {clickNode = self.mArrestInsList[self.mArrsetSelectID].arrestBgSprite},
        -- 指向佣兵招募
        [4002] = {clickNode = self.campBtn},
        -- 箭头再次指向悬赏令
        [4009] = {clickNode = self.mArrestInsList[self.mArrsetSelectID].arrestBgSprite},
    })
end

return GGZJLayer
