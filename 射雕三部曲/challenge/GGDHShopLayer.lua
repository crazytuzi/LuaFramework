--[[
    文件名：GGDHShopLayer.lua
    描述： 兑换界面
    创建人：wusonglin
    创建时间：2016.6.18
-- ]]
local GGDHShopLayer = class("GGDHShopLayer", function(params)
	return display.newLayer()
end)

-- 自定义枚举（用于进行页面分页）
local TabPageTags = {
    eTagGddhCoin = 1,   -- 豪侠令兑换页面 eTagGddhCoin
    eTagRankReward = 2, -- 排名奖励页面
    eTagOwnReward = 3,  -- 个人奖励
    eTagGuideReward = 4 -- 帮派奖励
}
--[[
-- 参数 params 中的各个字段为
    {
        subPageType: 子页面的类型, 默认取值为TabPageTags.eTagGddhCoin
        subPageData = {  -- 根据 subPageType 传入的值传入对应页面的参数
            [TabPageTags.eTagGddhCoin] = {  -- 打开普通副本页面的参数

            },
            [TabPageTags.eTagRankReward] = { -- 打开排名奖励页面的参数
                -- Todo
            },
            [TabPageTags.eTagOwnReward] = { -- 打开个人奖励页面的参数
                -- Todo
            },
            [TabPageTags.eTagGuideReward] = {  -- 打开帮派奖励页面的参数
                -- Todo
            },
        }

        histortRank   -- 历史排名 必须的参数
        signupData    -- 传入赛季数据
    }
]]
function GGDHShopLayer:ctor(params)
	-- 屏蔽下层事件
	ui.registerSwallowTouch({node = self})

    self.mRank = params.histortRank

    params = params or {}

    self.mSubPageType = params.subPageType or TabPageTags.eTagGddhCoin
    -- 需要打开页面的参数
    self.mSubPageData = params.subPageData or {}
    -- 当前打开的页面对象
    self.mCurrPageNode = nil

    -- 赛季信息，主界面传入.若是通过模块id创建则请求服务器数据
    if params.signupData then
        self.mSignupData = params.signupData
        -- 初始化页面
        self:initUI()
    else
        self:requestSignupInfo()
    end
end

function GGDHShopLayer:initUI()
	-- 设置父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    self.mTabContentLayer = cc.Node:create()
    self:addChild(self.mTabContentLayer)

    -- 创建底部导航和顶部玩家信息部分
    local tempLayer = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        topInfos = {ResourcetypeSub.eGDDHCoin, ResourcetypeSub.eGold, ResourcetypeSub.eDiamond}
    })
    self:addChild(tempLayer)

    local bgSprite = ui.newSprite("c_34.jpg")
    bgSprite:setPosition(320, 568)
    self.mParentLayer:addChild(bgSprite)
    self.mBgSize = bgSprite:getContentSize()

    --下方背景
    local bottomSprite = ui.newScale9Sprite("c_19.png", cc.size(640, 990))
    bottomSprite:setAnchorPoint(0.5, 0)
    bottomSprite:setPosition(320, 10)
    self.mParentLayer:addChild(bottomSprite)


    --显示返回按钮
    self.mCloseBtn = ui.newButton({
        normalImage = "c_29.png",
        -- anchorPoint = cc.p(0.5, 0),
        position = Enums.StardardRootPos.eCloseBtn,
        -- scale = Adapter.AutoScaleX,
        clickAction = function()
            LayerManager.removeLayer(self)
        end,
    })
    self.mParentLayer:addChild(self.mCloseBtn, 10)

	-- tableView信息
	local tableViewInfo = {
		btnInfos = {
            {
                text = TR("豪侠兑换"),
                tag  = TabPageTags.eTagGddhCoin
            },
            {
                text = TR("排名奖励"),
                tag  = TabPageTags.eTagRankReward
            },
            -- {
            --     text = TR("个人奖励"),
            --     tag  = TabPageTags.eTagOwnReward
            -- },
            -- {
            --     text = TR("帮派奖励"),
            --     tag  = TabPageTags.eTagGuideReward
            -- },
       	 },
       	viewSize = cc.size(660, 80),
       	-- space = 20,
       	allowChangeCallback = function(btnTag)
            return true
        end,
        onSelectChange = function(selectBtnTag)
            if self.mSubPageType == selectBtnTag then
                return
            else

                if not tolua.isnull(self.mCurrPageNode) then
                    self.mSubPageData[self.mSubPageType] = self.mCurrPageNode.getRestoreData and self.mCurrPageNode:getRestoreData()
                end

                self.mSubPageType = selectBtnTag
                self:selecteCellButton()
            end
        end
	}

	self.mTableView = ui.newTabLayer(tableViewInfo)
	self.mTableView:setPosition(cc.p(330, 1024))
    self.mParentLayer:addChild(self.mTableView)

    -- 排名奖励注册小红点
    local function dealRedDotVisible(redDotSprite)
        local redDotData = RedDotInfoObj:isValid(ModuleSub.eGDDHShop)
        redDotSprite:setVisible(redDotData)
    end
    ui.createAutoBubble({refreshFunc = dealRedDotVisible, eventName = RedDotInfoObj:getEvents(ModuleSub.eGDDHShop),
        parent = self.mTableView:getTabBtnByTag(TabPageTags.eTagRankReward)})

    -- 默认选择界面
    self:selecteCellButton()
end

--按钮切换回调
--[[
params:
    selectBtnTag: 按钮tag
--]]
function GGDHShopLayer:selecteCellButton()
	-- 先删除原来的子页面
    if not tolua.isnull(self.mCurrPageNode) then
        self.mCurrPageNode:removeFromParent()
        self.mCurrPageNode = nil
    end
    --dump(self.mSubPageData)
    -- print("self.mSubPageType--->"..self.mSubPageType)
    -- 跳转页面
    local subPageData = self.mSubPageData[self.mSubPageType] or {rank = self.mRank}
	if self.mSubPageType == TabPageTags.eTagGddhCoin then
        self.mCurrPageNode = require("challenge.GGDHShopCoinLayer"):create(subPageData)
        self.mTabContentLayer:addChild(self.mCurrPageNode)
    elseif self.mSubPageType == TabPageTags.eTagRankReward then
        self.mCurrPageNode = require("challenge.GGDHShopRankLayer"):create(subPageData)
        self.mTabContentLayer:addChild(self.mCurrPageNode)
    elseif self.mSubPageType == TabPageTags.eTagOwnReward then
        self.mCurrPageNode = require("challenge.GGDHShopOwnRewardLayer"):create(
        {layerSize = cc.size(640, 900),signupData = self.mSignupData})
        self.mTabContentLayer:addChild(self.mCurrPageNode)
    elseif self.mSubPageType == TabPageTags.eTagGuideReward then
        self.mCurrPageNode = require("challenge.GGDHShopGuideRewardLayer"):create(
        {layerSize = cc.size(640, 900),signupData = self.mSignupData})
        self.mTabContentLayer:addChild(self.mCurrPageNode)
    end
end
-- 获取恢复数据
function GGDHShopLayer:getRestoreData()
    local retData = {
        subPageType = self.mSubPageType,
        subPageData = {
            [self.mSubPageType] = self.mCurrPageNode.getRestoreData and self.mCurrPageNode:getRestoreData()
        },
        -- rankList = self.mRankList,
        -- gddhCoinList = self.gddhCoinList
        signupData = self.mSignupData,
    }

    return retData
end

--====================网络相关======================
-- 此页面请求服务器数据均用于主页面中通过模块页面id调用时使用
function GGDHShopLayer:requestSignupInfo()
    HttpClient:request({
        moduleName = "Gddh",
        methodName = "SignupInfo",
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                MsgBoxLayer.addOKLayer(
                    TR("数据请求错误，点击确定退出当前页面"),
                    TR("提示"),
                    {{
                        text = TR("确定"),
                        textColor = Enums.Color.eWhite,
                        clickAction = function(layerObj, btnObj)
                            LayerManager.removeLayer(layerObj)
                            LayerManager.removeLayer(self)
                        end
                    }},
                    {}
                    )
                return
            end
        -- 保存数据，格斗大会赛季信息表
        self.mSignupData = clone(response.Value)
        self:requestHistoryRank()
    end
    })
end

function GGDHShopLayer:requestHistoryRank()
    HttpClient:request({
        moduleName = "Gddh",
        methodName = "GetWrestleRaceInfo",
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 or response.Value.HistortRank == nil then
                MsgBoxLayer.addOKLayer(
                    TR("数据请求错误，点击确定退出当前页面"),
                    TR("提示"),
                    {{
                        text = TR("确定"),
                        textColor = Enums.Color.eWhite,
                        clickAction = function(layerObj, btnObj)
                            LayerManager.removeLayer(layerObj)
                            LayerManager.removeLayer(self)
                        end
                    }},
                    {}
                    )
                return
            end
            self.mRank = response.Value.HistortRank
            -- 初始化页面
            self:initUI()
        end
        })
end

----------------- 新手引导 -------------------
function GGDHShopLayer:onEnterTransitionFinish()
    self:executeGuide()
end
-- 执行新手引导
function GGDHShopLayer:executeGuide()
    Guide.helper:executeGuide({
        -- 指向返回按钮
        [11710] = {clickNode = self.mCloseBtn},
    })
end

return GGDHShopLayer
