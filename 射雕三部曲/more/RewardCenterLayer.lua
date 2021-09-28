--[[
	文件名：RewardCenterLayer.lua
	描述：领奖中心
	创建人：yanxingrui
	创建时间： 2016.6.1
--]]

local RewardCenterLayer = class("RewardCenterLayer", function(params)
    return display.newLayer()
end)


function RewardCenterLayer:ctor(params)
	-- 奖励信息
	self.mDataSrc = {}

	-- 模块名
	self.modelIdName = nil
    if params.isGuild ~= nil then
        self.modelIdName = "GuildReward"
    else
        self.modelIdName = "Reward"
    end

	-- 屏蔽下层事件
	ui.registerSwallowTouch({node = self})

	-- 初始化页面
	self:initUI()

	-- 获得奖励信息
	self:requestRewardInfo()
end

-- 初始化页面
function RewardCenterLayer:initUI()
    -- 添加弹出框层
    local bgLayer = require("commonLayer.PopBgLayer").new({
        title = TR("领奖中心"),
        bgSize = cc.size(630, 932),
        closeImg = "c_29.png",
        closeAction = function()
            LayerManager.removeLayer(self)
        end
    })
    self:addChild(bgLayer)
    self.mBgSprite = bgLayer.mBgSprite
    
	-- 一键领取按钮
    local mQuickGetBtn = ui.newButton({
        normalImage = "c_33.png",
        text = TR("一键领取"),
        clickAction = function()
            if table.maxn(self.mDataSrc) > 0 then
                local tempIdList = {}
                for index, item in pairs(self.mDataSrc) do
                    table.insert(tempIdList, item.Id)
                end
                self:requestGetReward(tempIdList)
            end
        end,
    })
    mQuickGetBtn:setPosition(320, 65)
    self.mBgSprite:addChild(mQuickGetBtn)

    -- if next(self.mDataSrc) then
    --     mQuickGetBtn:setEnabled(false)
    -- end
end

-- 创建列表控件
function RewardCenterLayer:createListView()
    --灰色背景
    local greyBgSprite = ui.newScale9Sprite("c_17.png", cc.size(570, 750))
    greyBgSprite:setAnchorPoint(0.5, 1)
    greyBgSprite:setPosition(315, 860)
    self.mBgSprite:addChild(greyBgSprite)

    -- 创建listView
    self.mListView = ccui.ListView:create()
    self.mListView:setDirection(ccui.ScrollViewDir.vertical)
    self.mListView:setBounceEnabled(true) -- 设置弹力
    self.mListView:setContentSize(cc.size(570, 730))
    self.mListView:setChildrenActionType(ui.LISTVIEW_ACTION_NONE)
    self.mListView:setItemsMargin(5) -- 改变两个cell之间的边界
    self.mListView:setPosition(285, 740)
    self.mListView:setAnchorPoint(cc.p(0.5, 1))
    greyBgSprite:addChild(self.mListView)

    -- 向listView添加数据
    for i = 1, #self.mDataSrc do
        self.mListView:pushBackCustomItem(self:createListCell(i))
    end

end

--创建cell列表
--[[
    params:
        index: cell条目数

    return:
        layout: 返回layout
--]]
function RewardCenterLayer:createListCell(index)
	local info = self.mDataSrc[index]

	-- 顶部描述label
	local introLabel = ui.newLabel({
		text = string.format("%s%s:%s%s", "#ff66f3", info.Title, 
			"#592817", info.Content),
		size = 20,
        dimensions = cc.size(535, 0),
	})

	-- 顶部描述label的高度
    local topHeight = introLabel:getContentSize().height

    -- -- 奖励列表高度
    -- local moreHeight = 0
    -- local colNum = 3
    -- if #info.ResourceList > colNum then
    -- 	moreHeight = math.floor((#info.ResourceList - 1) / colNum) * 100
    -- end

    -- 创建layout
    local cellSize = cc.size(560, 130 + topHeight) -- + moreHeight)
    local layout = ccui.Layout:create()
    layout:setContentSize(cellSize)

    --添加背景
    -- 创建cell
    local cellSprite = ui.newScale9Sprite("c_18.png", cellSize)
    cellSprite:setAnchorPoint(cc.p(0.5, 0.5))
    cellSprite:setPosition(285, cellSize.height/2)
    layout:addChild(cellSprite)

    -- 设置顶部描述label的位置
    introLabel:setAnchorPoint(cc.p(0, 1))
    introLabel:setPosition(25, cellSize.height-5)
    layout:addChild(introLabel, 5)

    -- 设置领取按钮
    local getBtn = ui.newButton({
        normalImage = "c_28.png",
        text = TR("领取"),
        anchorPoint = cc.p(0.5, 1),
        position = cc.p(490, 100),
        clickAction = function()
            self:requestGetReward({info.Id})
        end
    })
    layout:addChild(getBtn)
    getBtn:setSwallowTouches(false)

    -- 显示时间
    local time = MqTime.toDownFormat(Player:getCurrentTime() - info.SendTime)
    local timeLabel = ui.newLabel({
        text = time,
        size = 20,
        color = cc.c3b(0x59, 0x28, 0x17),
    })
    timeLabel:setAnchorPoint(cc.p(0.5, 0.5))
    timeLabel:setPosition(490, 30)
    layout:addChild(timeLabel)

    -- 显示头像
    local list = {}
    for index,value in pairs(info.ResourceList) do
        local card = {
            resourceTypeSub = value.ResourceTypeSub,
            modelId = value.ModelId,
            num = value.Count,
            cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum, CardShowAttr.eName},
        }
        table.insert(list, card)
    end

    local cardlist = ui.createCardList({
        cardDataList = list,
        maxViewWidth = 420,
    })
    cardlist:setAnchorPoint(cc.p(0, 1))
    cardlist:setPosition(20, 115)
    cardlist:setScale(0.9)
    layout:addChild(cardlist)

    return layout
end

-----------------------网络请求--------
-- 请求获取奖励列表
function RewardCenterLayer:requestRewardInfo()
	HttpClient:request({
        moduleName = "Reward",
        methodName = "Rewars",
        svrMethodData = {},
        callback = function(data)                
            self.mDataSrc = {}
            for index, value in pairs(data.Value) do
            	if Player:getCurrentTime() <= value.ExpireTime then
            		table.insert(self.mDataSrc, value)
            	end
            end
            table.sort(self.mDataSrc, function (a, b)
            	return a.SendTime > b.SendTime
            end)
            --dump(self.mDataSrc, "mDataSrc...")
            self:createListView()
        end,
    })
end

-- 请求领取奖励接口
--[[
params:
    rewardIdList:   奖励的ID表
]]--
function RewardCenterLayer:requestGetReward(rewardIdList)
	local requestData = {rewardIdList}
	HttpClient:request({
        moduleName = "Reward",
        methodName = "DrawGiftBags",
        svrMethodData = requestData,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return 
            end

            -- 提示得到的物品
            ui.ShowRewardGoods(response.Value.BaseGetGameResourceList, true)
            -- 检查 self 是否存在
            if tolua.isnull(self) then
                return 
            end

            for index = #self.mDataSrc, 1, -1 do
                if table.keyof(rewardIdList, self.mDataSrc[index].Id) then
                    table.remove(self.mDataSrc, index)
                    self.mListView:removeItem(index - 1)
                end
            end
            -- 如果领奖列表为空，则关闭这个页面
            if #self.mDataSrc == 0 then
            	LayerManager.removeLayer(self)
            end

            -- 检查是否升级
            PlayerAttrObj:showUpdateLayer()
        end,
    })
end

return RewardCenterLayer