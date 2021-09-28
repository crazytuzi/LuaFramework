--[[
    文件名: BossRewardLayer.lua
    描述: boss积分奖励预览
    创建人: liaoyuangang
    创建时间: 2016-06-16
    修改人：chenqiang
--]]

local BossRewardLayer = class("BossRewardLayer", function()
	return display.newLayer()
end)

--[[
-- 参数 params 中的各个字段为
    {
    	battleInfo: boss 信息
    }
]]
local JiFenImage = Utility.getResTypeSubImage(ResourcetypeSub.eBossCoin)
function BossRewardLayer:ctor(params)
	params = params or {}
	--
	self.mBattleInfo = params.battleInfo
	-- 扫荡节点列表中每个条目的显示大小
    self.mListCellSize = cc.size(535, 122)
    -- 积分奖励列表数据
    self.mBoxList = {}

	-- 添加弹出框层
	local parentLayer = require("commonLayer.PopBgLayer").new({
        bgSize = cc.size(620, 930),
        title = TR("击杀恶徒积分奖励"),
        closeAction = function()
            LayerManager.removeLayer(self)
        end
	})
	self:addChild(parentLayer)

	-- 保存弹框控件信息
    self.mBgSprite = parentLayer.mBgSprite
    self.mBgSize = self.mBgSprite:getContentSize()

    self.mRewardList = LuckbossShopModel.items

	-- 初始化页面控件
	self:initUI()
	--
	self:requestBoxList()
end

-- 初始化页面控件
function BossRewardLayer:initUI()
    --文字背景
    local topLabelBgSprite = ui.newScale9Sprite("c_25.png", cc.size(590, 54))
    topLabelBgSprite:setPosition(self.mBgSize.width * 0.5, self.mBgSize.height - 95)
    self.mBgSprite:addChild(topLabelBgSprite)
    -- 积分奖励的提示信息
    local tempNode = ui.newLabel({
        text = TR("奖励全部领取后自动重置，并扣除%s积分", LuckbossShopModel.items[LuckbossShopModel.items_count].needValue),
        color = Enums.Color.eNormalWhite,
        outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
        size = 22,
    })
    tempNode:setAnchorPoint(cc.p(0, 0.5))
    tempNode:setPosition(80, self.mBgSize.height - 95)
    self.mBgSprite:addChild(tempNode)
    -- self.mScoreLabel = tempNode

    local curScore = ui.newLabel({
        text = TR("当前积分:{%s}  %s%s", JiFenImage, "#d17b00", Utility.numberWithUnit(self.mBattleInfo.JiFen)),
        color = Enums.Color.eNormalWhite,
        outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
        size = 22,
        })
    curScore:setPosition(320, self.mBgSize.height - 140)
    self.mBgSprite:addChild(curScore)
    self.mScoreLabel = curScore

    -- 限时兑换倒计时
    -- self.mTimeLabel = ui.newLabel({
    --     text = TR("限时兑换倒计时: --:--:--"),
    --     color = Enums.Color.eBlack,
    --     size = 22,
    -- })
    -- self.mTimeLabel:setAnchorPoint(cc.p(1, 0.5))
    -- self.mTimeLabel:setPosition(self.mBgSize.width - 20, self.mBgSize.height - 95)
    -- self.mBgSprite:addChild(self.mTimeLabel)

    -- 奖励背景
    local rewardBgSprite = ui.newScale9Sprite("c_17.png", cc.size(556, 670))
    rewardBgSprite:setAnchorPoint(cc.p(0.5, 1))
    rewardBgSprite:setPosition(self.mBgSize.width * 0.5, self.mBgSize.height - 170)
    self.mBgSprite:addChild(rewardBgSprite)

	-- 创建奖励列表控件
	self.mListView = ccui.ListView:create()
    self.mListView:setContentSize(cc.size(self.mListCellSize.width, 650))
    self.mListView:setItemsMargin(5)
    self.mListView:setDirection(ccui.ListViewDirection.vertical)
    self.mListView:setBounceEnabled(true)
    self.mListView:setAnchorPoint(cc.p(0.5, 1))
    self.mListView:setPosition(self.mBgSize.width * 0.5, self.mBgSize.height - 180)
    self.mBgSprite:addChild(self.mListView)

    local onekeyBtn = ui.newButton({
        text = TR("一键领取"),
        normalImage = "c_28.png",
        clickAction = function ()
            self:requestOneKey()
        end
        })
    onekeyBtn:setPosition(self.mBgSize.width * 0.5, 55)
    self.mBgSprite:addChild(onekeyBtn)

end

-- 刷新奖励信息列表
function BossRewardLayer:refreshListView()
    self.mListView:removeAllChildren()

    self.mHandleData = {}
    for i,v in ipairs(self.mExchangeInfo) do
        if v.Status ~= 0 then
            table.insert(self.mHandleData, v.ID)
        end
    end

    -- 排序
    table.sort(self.mHandleData, function(a, b)
        if a ~= b then
            return a < b
        end
    end)

    for i = 1, #self.mHandleData do
        local tempItem = self:refreshListViewItem(i)
        self.mListView:pushBackCustomItem(tempItem)
    end

end

-- 刷新奖励信息中的一个条目
function BossRewardLayer:refreshListViewItem(ifro)
    local index = self.mHandleData[ifro]

    local lvItem = ccui.Layout:create()
    lvItem:setContentSize(self.mListCellSize)

    local tempModel = LuckbossShopModel.items[index]
    local item = Utility.analysisStrResList(tempModel.outStr)[1]

    -- 条目的背景
    local cellBgSprite = ui.newScale9Sprite("c_18.png", self.mListCellSize)
    cellBgSprite:setPosition(self.mListCellSize.width / 2, self.mListCellSize.height / 2)
    lvItem:addChild(cellBgSprite)

    -- 奖励的卡牌
    local tempCard = CardNode.createCardNode({
    	resourceTypeSub = item.resourceTypeSub,
        modelId = item.modelId,
        num = item.num,
        cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum},
        allowClick = true,
    })
    tempCard:setPosition(80, self.mListCellSize.height / 2)
    lvItem:addChild(tempCard)

    -- 奖励名称
    local cardName = Utility.getGoodsName(item.resourceTypeSub, item.modelId)
    local cardColorLv = Utility.getColorLvByModelId(item.modelId, item.resourceTypeSub)
    local cardColor =  Utility.getColorValue(cardColorLv, 1)
    local tempName = ui.newLabel({
        text = cardName,
        color = cardColor,
        outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
        outlineSize = 2,
    })
    tempName:setAnchorPoint(cc.p(0, 0.5))
    tempName:setPosition(140, self.mListCellSize.height / 2 + 30)
    lvItem:addChild(tempName)

    -- 可兑换次数
    -- local countLabel = ui.newLabel({
    --     text = TR("今日兑换次数: %d", self.mBoxList[index].CurCount),
    --     color = Enums.Color.eBlack,
    -- })
    -- countLabel:setAnchorPoint(cc.p(0, 0.5))
    -- countLabel:setPosition(140, self.mListCellSize.height / 2)
    -- lvItem:addChild(countLabel)

    -- local tipLabel = ui.newLabel({
    --     text = TR("需达到:"),
    --     color = Enums.Color.eBlack,
    -- })
    -- tipLabel:setAnchorPoint(cc.p(0, 0.5))
    -- tipLabel:setPosition(140, self.mListCellSize.height / 2)
    -- lvItem:addChild(tipLabel)

    -- 积分
    local scoreLabel = ui.newLabel({
        text = TR("需达到:{%s}%d", JiFenImage,tempModel.needValue),
        color = Enums.Color.eBlack,
    })
    scoreLabel:setAnchorPoint(cc.p(0, 0.5))
    scoreLabel:setPosition(140, self.mListCellSize.height / 2 - 30)
    lvItem:addChild(scoreLabel)

    -- 按钮
    local tempBtn = ui.newButton({
        normalImage = "c_28.png",
        text = TR("领取"),
        clickAction = function()
        	if self.mBattleInfo.JiFen < tempModel.needValue then
        		ui.showFlashView(TR("积分不足"))
        		return
        	end
        	self:requestDrawBox(tempModel.ID)
        end
    })
    tempBtn:setPosition(self.mListCellSize.width - 100, self.mListCellSize.height / 2)
    lvItem:addChild(tempBtn)
    lvItem.getButton = tempBtn
    local getStatus = self.mExchangeInfo[tempModel.ID].Status
    if getStatus == 1 then
        tempBtn:setBright(true)
    elseif getStatus == 2 then
        tempBtn:setBright(false)
    end
    return lvItem
end

-- 判断是否有可领取的条目
function BossRewardLayer:haveRewardItem()
	-- for _, item in ipairs(self.mBoxList) do
	-- 	if item.NeedValue <= self.mBattleInfo.JiFen and item.IsDraw == false then
	-- 		return true
	-- 	end
	-- end
	-- return false
end

-- ====================== 服务器请求相关函数 ====================
-- 获取宝箱列表数据请求
function BossRewardLayer:requestBoxList()
	HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "BossBattle",
        methodName = "GetExchangeInfo",
        svrMethodData = {},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
            	return
            end
            --dump(response,"tttttt")
            self.mJiFen = response.Value.JiFen
            self.mExchangeInfo = response.Value.ExchangeInfo

            self:refreshListView()
        end,
    })
end

-- 领取积分对应奖励表数据请求
function BossRewardLayer:requestDrawBox(id)
	HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "BossBattle",
        methodName = "Exchange",
        svrMethodData = {id},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
            	return
            end
            --dump(response,"getreward")
            self.mBattleInfo.JiFen = response.Value.JiFen
            self.mExchangeInfo = response.Value.ExchangeInfo
            -- 更新积分
            self.mScoreLabel:setString(TR("当前积分:{%s}  %s%s", JiFenImage, Enums.Color.eNormalYellowH, Utility.numberWithUnit(self.mBattleInfo.JiFen)))
            -- 显示获得资源
            ui.ShowRewardGoods(response.Value.BaseGetGameResourceList, true)
            -- 刷新兑换列表
            self:refreshListView()
        end,
    })
end

--一键领取
function BossRewardLayer:requestOneKey()
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "BossBattle",
        methodName = "OneKeyExchange",
        svrMethodData = {},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            --dump(response)
            self.mExchangeInfo = response.Value.ExchangeInfo
            self.mBattleInfo.JiFen = response.Value.JiFen
            self.mScoreLabel:setString(TR("当前积分:{%s}  %s%s", JiFenImage, Enums.Color.eNormalYellowH, Utility.numberWithUnit(self.mBattleInfo.JiFen)))

            if not next(response.Value.BaseGetGameResourceList[1]) then
                ui.showFlashView(TR("无物品可领取"))
            else
                ui.ShowRewardGoods(response.Value.BaseGetGameResourceList, true)
                self:refreshListView()
            end
        end,
    })
end

return BossRewardLayer
