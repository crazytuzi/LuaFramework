--[[
	文件名: DlgGuessBoxLayer
	描述: 我的竞猜日志对话框
	创建人: peiyaoqiang
	创建时间: 2017.11.2
-- ]]

local DlgGuessBoxLayer = class("DlgGuessBoxLayer",function()
	return display.newLayer()
end)

function DlgGuessBoxLayer:ctor(params)
	-- 添加弹出框层
    local bgLayer = require("commonLayer.PopBgLayer").new({
        title = TR("竞猜宝箱奖励"),
        bgSize = cc.size(570, 680),
        closeImg = "c_29.png",
        closeAction = function()
            LayerManager.removeLayer(self)
        end
    })
    self:addChild(bgLayer)

    -- 保存弹窗控件信息
    self.mBgSprite = bgLayer.mBgSprite
    self.mBgSize = bgLayer.mBgSprite:getContentSize()

    -- 初始化
    self:initUI()
    self:requestGetInfo()
end

function DlgGuessBoxLayer:initUI()
	-- 已竞猜次数
	local sprite, label = ui.createSpriteAndLabel({
        imgName = "c_25.png",
        scale9Size = cc.size(520, 54),
        labelStr = "",
        fontColor = Enums.Color.eWhite,
        outlineColor = cc.c3b(0x46, 0x22, 0x0d),
        outlineSize = 2,
    })
    sprite:setAnchorPoint(cc.p(0.5, 0.5))
    sprite:setPosition(self.mBgSize.width * 0.5, self.mBgSize.height - 95)
    self.mBgSprite:addChild(sprite)
    self.countLabel = label

	-- 列表背景
	local grayBgSize = cc.size(self.mBgSize.width - 70, self.mBgSize.height - 160)
	local grayBgSprite = ui.newScale9Sprite("c_17.png", grayBgSize)
    grayBgSprite:setAnchorPoint(0.5, 0)
    grayBgSprite:setPosition(self.mBgSize.width/2, 30)
    self.mBgSprite:addChild(grayBgSprite)
    self.cellSize = cc.size(grayBgSize.width - 20, 170)

    -- 奖励列表
    local listView = ccui.ListView:create()
    listView:setDirection(ccui.ScrollViewDir.vertical)
    listView:setBounceEnabled(true)
    listView:setGravity(ccui.ListViewGravity.centerVertical)
    listView:setContentSize(cc.size(grayBgSize.width - 20, grayBgSize.height - 20))
    listView:setAnchorPoint(cc.p(0.5, 0))
    listView:setPosition(cc.p(grayBgSize.width / 2, 10))
    grayBgSprite:addChild(listView)
    self.mListView = listView
end

function DlgGuessBoxLayer:createCellView(model)
	local custom_item = ccui.Layout:create()
    custom_item:setContentSize(self.cellSize)

    -- 背景图
    local cellBgSprite = ui.newScale9Sprite("c_18.png", cc.size(self.cellSize.width, self.cellSize.height - 6))
    cellBgSprite:setAnchorPoint(cc.p(0.5, 0))
    cellBgSprite:setPosition(self.cellSize.width * 0.5, 4)
    custom_item:addChild(cellBgSprite)

    -- 次数提示
    local descLabel = ui.newLabel({
        text = TR("今日竞猜正确%s %s %s场，可获得以下奖励:", "#249029", model.betWinNum, "#46220D"),
        color = cc.c3b(0x46, 0x22, 0x0d),
        anchorPoint = cc.p(0, 0.5),
        x = 20,
        y = self.cellSize.height - 25,
    })
    custom_item:addChild(descLabel)

    -- 显示奖品
    local tempCard = ui.createCardList({
        maxViewWidth = 320,     --显示的最大宽度
        viewHeight = 120,       --显示的高度，默认为120
        cardShowAttrs = {},
        cardDataList = Utility.analysisStrResList(model.reward),
        allowClick = true,
        isSwallow = false,
    })
    tempCard:setScale(0.9)
    tempCard:setPosition(cc.p(20, 15))
    custom_item:addChild(tempCard)

    -- 领奖状态
    if (self:isAlreadyGetreward(model.betWinNum) == true) then
    	-- 已领取
    	local sprite = ui.newSprite("jc_21.png")
    	sprite:setPosition(self.cellSize.width - 80, 70)
    	custom_item:addChild(sprite)
    else
    	local btnGet = ui.newButton({
            normalImage = "c_33.png",
            text = TR("领取"),
            position = cc.p(self.cellSize.width - 80, 70),
            clickAction = function()
            	self:requestGetReward(model.betWinNum)
            end
        })
        btnGet:setEnabled(false)
        custom_item:addChild(btnGet)

        -- 可领取
        if (self:isCanGetreward(model.betWinNum) == true) then
        	local tempSprite, _ = ui.createStrImgMark("c_62.png", TR("可领取"), Enums.Color.eWhite, 18, nil, cc.c3b(0x46, 0x22, 0x0d))
		    tempSprite:setRotation(90)
		    tempSprite:setPosition(self.cellSize.width - 40, self.cellSize.height - 40)
		    custom_item:addChild(tempSprite, 1)
        	btnGet:setEnabled(true)
        end
    end

    return custom_item
end

----------------------------------------------------------------------------------------------------

-- 刷新界面
function DlgGuessBoxLayer:refreshUI()
	-- 刷新次数
    self.countLabel:setString(TR("今日已竞猜正确%s %s %s场", "#00FF00", self.mBetWinNum or 0, Enums.Color.eWhiteH))

    -- 刷新列表
    if (self.dataList == nil) then
    	self.dataList = {}
	    for _,v in pairs(PvpinterTopBetModel.items) do
	    	table.insert(self.dataList, v)
	    end
	    table.sort(self.dataList, function (a, b)
	    		return a.betWinNum < b.betWinNum
	    	end)
    end
    self.mListView:removeAllItems()
    for _,v in ipairs(self.dataList) do
    	self.mListView:pushBackCustomItem(self:createCellView(v))
    end
end

-- 处理接口返回值
function DlgGuessBoxLayer:dealResponse(responseData)
	if (responseData == nil) then
		return
	end

	-- 保存相关数据
	self.mBetWinNum = responseData.BetWinNum
	self.mBetRewardList = string.splitBySep(responseData.BetRewardStr or "", ",")
end

-- 判断是否达成条件
function DlgGuessBoxLayer:isCanGetreward(idx)
	local tmpNum = self.mBetWinNum or 0
	return (tmpNum >= idx)
end

-- 判断是否已领奖
function DlgGuessBoxLayer:isAlreadyGetreward(idx)
	for _,v in ipairs(self.mBetRewardList or {}) do
		if (tonumber(v) == idx) then
			return true
		end
	end
	return false
end

----------------------------------------------------------------------------------------------------

-- 接口：获取信息
function DlgGuessBoxLayer:requestGetInfo()
	HttpClient:request({
        moduleName = "PVPinterTop",
        methodName = "GetBetRecordInfo",
        svrMethodData = {},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            self:dealResponse(response.Value.PvpinterTopBetRecordInfo)
            self:refreshUI()
        end
    })
end

-- 接口：领奖
function DlgGuessBoxLayer:requestGetReward(rewardIdx)
	HttpClient:request({
        moduleName = "PVPinterTop",
        methodName = "GetBetReward",
        svrMethodData = {rewardIdx},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            self:dealResponse(response.Value.PvpinterTopBetRecordInfo)
            self:refreshUI()

            -- 飘窗弹出奖励
            ui.ShowRewardGoods(response.Value.BaseGetGameResourceList)
        end
    })
end



return DlgGuessBoxLayer
