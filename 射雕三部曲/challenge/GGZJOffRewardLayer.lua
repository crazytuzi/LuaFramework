--[[
	文件名：GGZJOffRewardLayer.lua
	描述：血刃悬赏官阶奖励页面 (GGZJ--->过关斩将)
	创建人：liucunxin
	创建时间：2016.12.17
--]]

local GGZJOffRewardLayer = class("GGZJOffRewardLayer", function(params)
    return display.newLayer()
end)

-- 构造函数
--[[
	params:
		-- 以下均为必传参数
		parent 									-- 页面父对象
		playerInfo 				-- 所需数据（暂定）
        offLv                       -- 大官阶
        subOffLv                    -- 小官阶

--]]
function GGZJOffRewardLayer:ctor(params)
	self.mPlayerInfo = params.playerInfo
    self.mSubOffLv = params.subOffLv
    self.mOffLv = params.offLv
    self.mSupplyList = {}
    self.mRewardId = 0
    self.mCallFunc = params.callfunc
    -- 配置宝箱能够领取ID
    self:configRewardID()
	self:initUI()
end

-- 配置奖励宝箱奖励ID
function GGZJOffRewardLayer:configRewardID()
    -- 宝箱配置奖励数
    local tempList = {}
    for i,v in ipairs(XrxsXrlvModel.items) do
        if v.reward ~= "" then
            table.insert(tempList, i, i)
        else
            table.insert(tempList, i, 0)
        end
    end
    -- 筛选可领取宝箱
    for i, v in pairs(self.mPlayerInfo.LvRewardIds) do
        tempList[v] = 0
    end
    -- table.sort(tempList, function(a, b)
    --     return a < b
    -- end)
    self.mSupplyList = clone(tempList)

    local function getReward(index)
        if self.mSupplyList[index] == 0 then
            getReward(index + 1)
        else
            self.mRewardId = index
        end
    end

    getReward(1)
end

-- 初始化界面
function GGZJOffRewardLayer:initUI()
    -- 创建该页面的父节点
    -- 添加弹出框层
    local bgSpriteWidth = 583
    local bgSpriteHeight = 790
    local parentLayer = require("commonLayer.PopBgLayer").new({
        bgSize = cc.size(bgSpriteWidth, bgSpriteHeight),
        title = TR("捕快官阶"),
        closeAction = function()
            LayerManager.removeLayer(self)
        end
    })
    self:addChild(parentLayer)
    -- self.mParentLayer = ui.newStdLayer()
    -- self:addChild(self.mParentLayer)

    self:createRewardLayer(parentLayer)
end

-- 官阶奖励页面
function GGZJOffRewardLayer:createRewardLayer(parent)
    -- 页面背景
    local bgSprite = parent.mBgSprite
    local bgSize = bgSprite:getContentSize()

    -- 子父背景
    local subBgSprite = ui.newScale9Sprite("c_17.png", cc.size(525, 700))
    subBgSprite:setAnchorPoint(cc.p(0.5, 0))
    subBgSprite:setPosition(cc.p(bgSize.width * 0.5 ,25))
    bgSprite:addChild(subBgSprite)

    -- 预览奖励背景
    local subPreview = ui.newScale9Sprite("c_18.png",cc.size(510, 210))
    -- subPreview:setContentSize(cc.size(530, 210))
    subPreview:setAnchorPoint(cc.p(0.5, 0.5))
    subPreview:setPosition(cc.p(subBgSprite:getContentSize().width * 0.5, subBgSprite:getContentSize().height - 110))
    subBgSprite:addChild(subPreview)

    -- 经验条
    local tempMaxInfo = XrxsXrlvModel.items[self.mSubOffLv] and XrxsXrlvModel.items[self.mSubOffLv + 1] or XrxsXrlvModel.items[#XrxsXrlvModel.items]
    self.mProgressBar = require("common.ProgressBar").new({
        bgImage = "tjl_10.png",
        barImage = "tjl_09.png",
        currValue = self.mPlayerInfo.LvStar,
        contentSize = cc.size(270, 23),
        maxValue= tempMaxInfo.needStars,
        needLabel = true,
        color = Enums.Color.eWhite,
    })
    self.mProgressBar:setAnchorPoint(cc.p(0, 0))
    self.mProgressBar:setPosition(cc.p(subBgSprite:getContentSize().width * 0.22, subBgSprite:getContentSize().height * 0.25 - 20))
    subPreview:addChild(self.mProgressBar)

    local offlvBg = ui.newSprite("tjl_24.png")
    offlvBg:setPosition(cc.p(-55, 20))
    self.mProgressBar:addChild(offlvBg)

    -- 官阶（当前）
    local offLvLabel = ui.newLabel({
        text = TR("%s", XrxsXrlvModel.items[self.mSubOffLv].name),
        color = Enums.Color.eNormalWhite,
        outlineColor = Enums.Color.eBlack,
        dimensions = cc.size(90, 0),
        align = cc.TEXT_ALIGNMENT_CENTER,
        size = 22
    })
    offLvLabel:setAnchorPoint(cc.p(0, 0.5))
    offLvLabel:setPosition(cc.p(-100, 20))
    self.mProgressBar:addChild(offLvLabel)

    local offlvBgNext = ui.newSprite("tjl_24.png")
    offlvBgNext:setPosition(cc.p(self.mProgressBar:getContentSize().width + 60, 20))
    self.mProgressBar:addChild(offlvBgNext)
    -- 官阶（下一阶）
    local offLv = XrxsXrlvModel.items[self.mSubOffLv + 1] and self.mSubOffLv + 1 or self.mSubOffLv
    local offLvNextLabel = ui.newLabel({
        text = TR("%s", XrxsXrlvModel.items[offLv].name),
        color = Enums.Color.eNormalWhite,
        outlineColor = Enums.Color.eBlack,
        dimensions = cc.size(90, 0),
        align = cc.TEXT_ALIGNMENT_CENTER,
        size = 22
    })
    offLvNextLabel:setAnchorPoint(cc.p(0, 0.5))
    offLvNextLabel:setPosition(cc.p(self.mProgressBar:getContentSize().width + 10, 20))
    self.mProgressBar:addChild(offLvNextLabel)

    -- 提示label
    local notifyLabel = ui.newLabel({
        text = TR("官阶福利: 悬赏获得铜钱奖励 #158420+%s%%", XrxsXrlvModel.items[offLv].goldR / 100),
        color = Enums.Color.eBlack,
        size = 22
    })
    notifyLabel:setAnchorPoint(cc.p(0, 0.5))
    notifyLabel:setPosition(cc.p(12, subPreview:getContentSize().height * 0.69 - 10))
    subPreview:addChild(notifyLabel)

    -- 领取按钮
    self.mDrawBtn = ui.newButton({
        normalImage = "c_28.png",
        text = TR("领取"),
        anchorPoint = cc.p(1, 0),
        clickAction = function ()
            -- 请求服务器领取奖励
            if self.mPlayerInfo.LvStar > 0 then
                if self.mRewardId <= self.mSubOffLv then
                    self:requestLvReward()
                else
                    ui.showFlashView({
                        text = TR("暂无官阶奖励可领取")
                    })
                end
            else
                ui.showFlashView({
                    text = TR("当前暂无奖励，快去挑战悬赏令升级官阶吧！！！")
                })
            end
        end
    })
    self.mDrawBtn:setPosition(cc.p(subPreview:getContentSize().width - 20, subPreview:getContentSize().height * 0.2 - 10))
    self.mDrawBtn:setEnabled(self.mRewardId <= self.mSubOffLv)
    subPreview:addChild(self.mDrawBtn)

    -- 奖励列表
    local List = {}
    if XrxsXrlvModel.items[self.mRewardId] then
        List = Utility.analysisStrResList(XrxsXrlvModel.items[self.mRewardId].reward)
        for i, v in ipairs(List) do
            v.cardShowAttrs = {
                CardShowAttr.eBorder,
                CardShowAttr.eNum
            }
        end
    else
        List = Utility.analysisStrResList("")
    end

    self.mRewardList = ui.createCardList({
            space = -10,
            maxViewWidth = subPreview:getContentSize().width - self.mDrawBtn:getContentSize().width - 55,
            viewHeight = 90,
            cardDataList = List,
            allowTouch = true
        })
    self.mRewardList:setAnchorPoint(cc.p(0, 0))
    self.mRewardList:setPosition(cc.p(30, 15))
    subPreview:addChild(self.mRewardList)

    -- 官阶不足
    self.mOffLvEnoughLabel = ui.newLabel({
        text = TR("#FF0000官阶不足"),
        size = 20
    })
    self.mOffLvEnoughLabel:setAnchorPoint(cc.p(0.5, 0))
    self.mOffLvEnoughLabel:setPosition(cc.p(self.mDrawBtn:getContentSize().width * 0.5, self.mDrawBtn:getContentSize().height))
    -- self.mOffLvEnoughLabel:setVisible((self.mPlayerInfo.LvMaxRewardId >= self.mSubOffLv) and (self.mPlayerInfo.LvStar > 0))
    self.mDrawBtn:addChild(self.mOffLvEnoughLabel)

    -- 已满级
    self.mMaxLv = ui.newLabel({
        text = TR("已满级"),
        size = 32,
    })
    subPreview:addChild(self.mMaxLv)
    self.mMaxLv:setPosition(cc.p(subPreview:getContentSize().width * 0.465, subPreview:getContentSize().height * 0.4 - 10))
    self.mMaxLv:setVisible(false)

    -- 官阶预览标签背景
    -- local preBgSprite = ui.newSprite("c_82.png")
    -- preBgSprite:setPosition(cc.p(subBgSprite:getContentSize().width * 0.5, subBgSprite:getContentSize().height * 0.65))
    -- subBgSprite:addChild(preBgSprite)

    self.mPreLabel = ui.newLabel({
        text = TR("晋升奖励"),
        dimensions = cc.size(10, 0),
        color = cc.c3b(0xff, 0x66, 0xf3),
        size = 20
        })
    self.mPreLabel:setPosition(cc.p(subBgSprite:getContentSize().width * 0.05, subBgSprite:getContentSize().height * 0.8 - 10))
    subBgSprite:addChild(self.mPreLabel)

    -- 官阶预览标签
    local preLabel = ui.newLabel({
        text = TR("官阶预览"),
        color = Enums.Color.eWhite,
        outlineColor = cc.c3b(0x47, 0x50, 0x54),
        outlineSize = 2,
        size = 26,
        align = TEXT_ALIGN_CENTER
    })
    preLabel:setAnchorPoint(cc.p(0.5, 0))
    preLabel:setPosition(cc.p(
        subPreview:getContentSize().width * 0.5,
        subBgSprite:getContentSize().height - subPreview:getContentSize().height - 52)
    )
    subBgSprite:addChild(preLabel, 2)

    -- 父对象, 坐标, 称号名, 加成信息
    local function createItem(parent, pos, designationName, rewardInfo, offlv)
        -- local bgSprite = ui.newSprite("xrxs_24.png")
        -- bgSprite:setAnchorPoint(cc.p(0, 0.5))
        -- bgSprite:setPosition(pos)
        -- parent:addChild(bgSprite)

        local tempSprite = ui.newSprite(XrxsXrlvModel.items[offlv].lvPic)
        tempSprite:setAnchorPoint(cc.p(0, 0.5))
        tempSprite:setPosition(pos.x - 10, pos.y)
        parent:addChild(tempSprite)
        local tempSize = tempSprite:getContentSize()

        local designLabel = ui.newLabel({
            text = TR("获得称号: #FF8745%s", XrxsXrlvModel.items[offlv].name),
            color = Enums.Color.eBlack,
            size = 24,
            align = TEXT_ALIGN_CENTER,
        })
        designLabel:setAnchorPoint(cc.p(0, 0.5))
        designLabel:setPosition(cc.p(10 + tempSize.width, tempSize.height * 0.7))
        tempSprite:addChild(designLabel)

        local rewardIntroLabel = ui.newLabel({
            text = TR("官阶福利: 悬赏获得奖励 +%s%%", XrxsXrlvModel.items[offlv].goldR / 100),
            color = Enums.Color.eBlack,
            size = 20,
            align = TEXT_ALIGN_CENTER,
        })
        rewardIntroLabel:setAnchorPoint(cc.p(0, 0.5))
        rewardIntroLabel:setPosition(cc.p(10 + tempSize.width, tempSize.height * 0.3))
        tempSprite:addChild(rewardIntroLabel)
    end

    -- 预览信息背景
    local preBgSprite = ui.newScale9Sprite("c_37.png", cc.size(510, 470))
    preBgSprite:setPosition(cc.p(subBgSprite:getContentSize().width * 0.5, subBgSprite:getContentSize().height * 0.5 - 110))
    subBgSprite:addChild(preBgSprite)

    -- 创建条目子背景
    local listViewSize = {
        width = 520,
        height = 104
    }

    -- listview
    local rewardList = ccui.ListView:create()
    rewardList:setDirection(ccui.ScrollViewDir.vertical)
    rewardList:setBounceEnabled(true)
    rewardList:setContentSize(cc.size(preBgSprite:getContentSize().width * 1.05 + 60, preBgSprite:getContentSize().height))
    rewardList:setTouchEnabled(false)
    rewardList:setGravity(ccui.ListViewGravity.centerVertical)
    rewardList:setItemsMargin(5)
    rewardList:setAnchorPoint(cc.p(0.5, 0))
    rewardList:setPosition(cc.p(subBgSprite:getContentSize().width * 0.6 + 30, -30))
    rewardList:setChildrenActionType(ui.LISTVIEW_ACTION_NONE)
    preBgSprite:addChild(rewardList)

    -- 当前只有四条信息
    for i = 4, 1, -1 do
        local customCell = ccui.Layout:create()
        customCell:setContentSize(cc.size(listViewSize.width, listViewSize.height))
        rewardList:pushBackCustomItem(customCell)
        createItem(customCell, cc.p(30, listViewSize.height * 0.5), nil, nil, #XrxsXrlvModel.items + 1 - i * 5 + 4)
    end

    for  i = 1, 3 do --根据条目信息修改个数
        local tempPos = cc.p(subBgSprite:getContentSize().width, subBgSprite:getContentSize().height)
        local lineSprite = ui.newSprite("tjl_15.png")
        lineSprite:setPosition(cc.p(tempPos.x * 0.5, tempPos.y * 0.5 - 10 - (i-1)*110))
        preBgSprite:addChild(lineSprite)
    end

    self:refreshUI()
end

-- 刷新界面
function GGZJOffRewardLayer:refreshUI()
    if XrxsXrlvModel.items[self.mRewardId] then
        self.mProgressBar:setMaxValue(XrxsXrlvModel.items[self.mRewardId].needStars)
        self.mProgressBar:setCurrValue(self.mPlayerInfo.LvStar, 0, nil)
        local List = Utility.analysisStrResList(XrxsXrlvModel.items[self.mRewardId].reward)
        for i, v in ipairs(List) do
            v.cardShowAttrs = {
                CardShowAttr.eBorder,
                CardShowAttr.eNum
            }
        end

        self.mRewardList.refreshList(List)

        -- 设置领取按钮状态
        print(self.mSubOffLv, "lv")
        local isEnable = (self.mRewardId <= self.mSubOffLv) and (self.mPlayerInfo.LvStar > 0)
        self.mDrawBtn:setEnabled(isEnable)
        -- 按钮提示标签
        self.mOffLvEnoughLabel:setVisible(not isEnable)
    else
        self.mOffLvEnoughLabel:setVisible(false)
        self.mRewardList:setVisible(false)
        self.mDrawBtn:setVisible(false)
        self.mPreLabel:setVisible(false)
        self.mMaxLv:setVisible(true)
    end
end

--===================网络相关==================
-- 请求服务器领取奖励
function GGZJOffRewardLayer:requestLvReward()
    HttpClient:request({
        moduleName = "XrxsInfo",
        methodName = "LvReward",
        svrMethodData = {self.mRewardId},
        callback = function(response)
            if response.Value == nil then
                self:refreshUI()
                return
            else
                self.mPlayerInfo.LvRewardIds = response.Value.Info.LvRewardIds
                self:configRewardID()
                -- self.mPlayerInfo.LvMaxRewardId = response.Value.Info.SupplyMaxRewardId
                self:refreshUI()
                ui.ShowRewardGoods(response.Value.BaseGetGameResourceList)
            end
        end
    })
end

return GGZJOffRewardLayer
