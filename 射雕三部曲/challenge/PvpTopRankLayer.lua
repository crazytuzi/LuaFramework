--[[
    文件名：PvpTopRankLayer.lua
    描述： 武林盟主排名主界面
    创建人：yanghongsheng
    创建时间：2017.11.2
-- ]]
local PvpTopRankLayer = class("PvpTopRankLayer", function(params)
	return display.newLayer()
end)

-- 自定义枚举（用于进行页面分页）
local TabPageTags = {
    eTagRank = 1,   -- 排名页面
    eTagReward = 2, -- 奖励页面
}

function PvpTopRankLayer:ctor(params)
	-- 屏蔽下层事件
	ui.registerSwallowTouch({node = self})
	-- 当前页
	self.mSubPageType = params.subPageType or TabPageTags.eTagRank

	self.mSubPageData = params.subPageData or {}

	-- 设置父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    self.mTabContentLayer = cc.Node:create()
    self:addChild(self.mTabContentLayer)
    -- 创建底部导航和顶部玩家信息部分
    local tempLayer = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        needFAP = false,
        topInfos = {ResourcetypeSub.eVIT, ResourcetypeSub.eSTA, ResourcetypeSub.eDiamond, ResourcetypeSub.eGold}
    })
    self:addChild(tempLayer)
    -- 初始化界面
    self:initUI()
end

function PvpTopRankLayer:getRestoreData()
	local retData = {
        subPageType = self.mSubPageType,
        subPageData = {
            [self.mSubPageType] = self.mCurrPageNode.getRestoreData and self.mCurrPageNode:getRestoreData()
        },
    }

    return retData
end

function PvpTopRankLayer:initUI()
	-- 背景
	local bgSprite = ui.newSprite("wlmz_31.jpg")
	bgSprite:setPosition(320, 568)
	self.mParentLayer:addChild(bgSprite)

	--下方背景
    -- local bottomSprite = ui.newScale9Sprite("wlmz_31.jpg", cc.size(640, 990))
    -- bottomSprite:setAnchorPoint(0.5, 0)
    -- bottomSprite:setPosition(320, 0)
    -- self.mParentLayer:addChild(bottomSprite)

	-- tableView信息
	local tableViewInfo = {
		btnInfos = {
            {
                text = TR("排名"),
                tag  = TabPageTags.eTagRank
            },
            {
                text = TR("奖励"),
                tag  = TabPageTags.eTagReward
            },
       	 },
       	viewSize = cc.size(640, 80),
       	-- space = 20,
       	allowChangeCallback = function(btnTag)
            return true
        end,
        onSelectChange = function(selectBtnTag)
            if self.mSubPageType == selectBtnTag then
                return
            else
	            self.mSubPageType = selectBtnTag

	            if not tolua.isnull(self.mCurrPageNode) then
	                self.mSubPageData[self.mSubPageType] = self.mCurrPageNode.getRestoreData and self.mCurrPageNode:getRestoreData()
	            end

	            self:selecteCellButton()
	        end
        end,
	}

	self.mTableView = ui.newTabLayer(tableViewInfo)
	self.mTableView:setAnchorPoint(cc.p(0, 0.5))
	self.mTableView:setPosition(cc.p(0, 1024))
    self.mParentLayer:addChild(self.mTableView)

    self:selecteCellButton()

    -- 规则
	local ruleBtn = ui.newButton({
			normalImage = "c_72.png",
	        clickAction = function()
	            local rule = {
	                [1] = TR("1.一个赛季分为初赛、争霸赛2个阶段，一周为一个赛季"),
                    [2] = TR("2.每周周一0点至周日凌晨5点为初赛阶段，周日18:30点开始决赛，同时各位大侠可以给中意的强者下注"),
                    [3] = TR("3.初赛分为初入江湖，小有名气，名动一方，天下闻名，一代宗师，登峰造极，6个段位，登峰造极前128名进入武林神话段位，参加争霸赛"),
                    [4] = TR("4.初赛规则与武林争霸规则一致"),
                    [5] = TR("5.在争霸赛开始时，进入争霸赛的玩家会随机分成4个组进入战斗"),
                    [6] = TR("6.争霸赛分为16强赛、8强赛、4强赛、半决赛、决赛5个比赛阶段"),
                    [7] = TR("7.每场比赛的规则会根据比赛阶段进行变化（16强赛一局定胜负，8强赛三局两胜，4强赛三局两胜，半决赛三局两胜，决赛五局三胜)"),
                    [8] = TR("8.每个比赛阶段前都会开启【竞猜】\n每场比赛的阶段竞猜时间：\n    16强赛：每周日18:30-19：00\n    8强赛：每周日19:00-19:30\n    4强赛：每周日19:30-20:00\n    半决赛：每周日20:00-20:30\n    决赛：每周日20:30-21:00"),
                    [9] = TR("9.每个比赛阶段只能为1名玩家进行【下注】"),
                    [10] = TR("10.竞猜成功将获得酬金与本金返还，竞猜失败则无法获得酬金并且不返还本金"),
                    [11] = TR("11.本轮争霸赛结束后按照排行榜发放奖励，并可在次日对武林盟主进行膜拜，并开启下一轮比赛"),
                    [12] = TR("12.每位玩家可对【武林盟主】进行膜拜，每日只能进行1次膜拜"),
                    [13] = TR("13.每周将清空争霸赛的积分和信息，每两周将清空初赛的积分和信息"),
                    [14] = TR("14.每周参与竞猜，竞猜正确可以领取竞猜宝箱。"),
	            }

	            MsgBoxLayer.addRuleHintLayer(TR("规则"), rule)
	        end
		})
	ruleBtn:setPosition(520, 1040)
	self.mParentLayer:addChild(ruleBtn)
	-- 返回
	local closeBtn = ui.newButton({
			normalImage = "c_29.png",
			clickAction = function ()
				LayerManager.removeLayer(self)
			end,
		})
	closeBtn:setPosition(Enums.StardardRootPos.eCloseBtn)
	self.mParentLayer:addChild(closeBtn)
end

function PvpTopRankLayer:selecteCellButton()
	if self.mCurrPageNode and  not tolua.isnull(self.mCurrPageNode) then
		self.mCurrPageNode:removeFromParent()
		self.mCurrPageNode = nil
	end

	local subPageData = self.mSubPageData[self.mSubPageType] or {}
	if self.mSubPageType == TabPageTags.eTagRank then
		self.mCurrPageNode = require("challenge.PvpTopRankSubLayer"):create(subPageData)
        self.mTabContentLayer:addChild(self.mCurrPageNode)
	elseif self.mSubPageType == TabPageTags.eTagReward then
		self.mCurrPageNode = require("challenge.PvpTopRewardSubLayer"):create(subPageData)
        self.mTabContentLayer:addChild(self.mCurrPageNode)
	end
end


return PvpTopRankLayer