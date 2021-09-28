--[[
    文件名: ActivityMonthSignLayer.lua
	描述: 月签到页面, 模块Id为：ModuleSub.eMonthSign
	效果图: j精彩活动_月签到.jpg
	创建人: yanghongsheng
	创建时间: 2017.3.13
--]]

local ActivityMonthSignLayer = class("ActivityMonthSignLayer", function()
    return display.newLayer()
end)

--[[
-- 参数 params 中的各项为：
	{
		activityIdList: 活动实体Id列表
		parentModuleId: 该活动的主模块Id

		cacheData: 该页面的缓存信息，主要用于恢复该页面时使用，普通调用者一般不会使用该参数
	}
]]
function ActivityMonthSignLayer:ctor(params)
	params = params or {}
	-- 活动实体Id列表
	self.mActivityIdList = params.activityIdList
	-- 该活动的主模块Id
	self.mParentModuleId = params.parentModuleId
	-- 该页面的数据信息
	self.mLayerData = params.cacheData

	-- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer) 

	-- 初始化页面控件
	self:initUI()

	if not self.mLayerData then  -- 证明是第一次进入该页面
		self:requestMonthSignInfo()
	else 	
		self:refreshData()
	end
end

-- 获取恢复数据
function ActivityMonthSignLayer:getRestoreData()
	local retData = {
		activityIdList = self.mActivityIdList,
		parentModuleId = self.mParentModuleId,
		cacheData = self.mLayerData
	}

	return retData
end

-- 初始化页面控件
function ActivityMonthSignLayer:initUI()
    -- 背景
    local bg = ui.newSprite("jc_25.jpg")
    bg:setAnchorPoint(cc.p(0.5, 0.5))
    bg:setPosition(320,568)
    self.mParentLayer:addChild(bg)

    -- title图
    local titleSprite = ui.newSprite("jc_08.png")
    titleSprite:setAnchorPoint(cc.p(0, 0.5))
    titleSprite:setPosition(0,900)
    self.mParentLayer:addChild(titleSprite)

    --说明背景
    local decBgSize = cc.size(520, 50)
    local decBg = ui.newScale9Sprite("c_145.png", decBgSize)
    decBg:setPosition(cc.p(-10, 715))
    decBg:setAnchorPoint(cc.p(0,0.5))
    self.mParentLayer:addChild(decBg)

    -- --人物
    -- local figureSprite = ui.newSprite("jc_18.png")
    -- figureSprite:setPosition(480, 465)
    -- self.mParentLayer:addChild(figureSprite)

    -- 感叹号icon
    local gantan = ui.newSprite("c_63.png")
    gantan:setPosition(40, decBgSize.height*0.5)
    decBg:addChild(gantan)

    -- 时间标签
    self.mTimesLabel = ui.newLabel({
        text = TR("累计签到:  %s%d%s次", "#ffe033", 0, Enums.Color.eWhiteH),
        color = Enums.Color.eWhite,
        align = ui.TEXT_ALIGN_CENTER,
        size = Enums.Fontsize.eBtnDefault,
        outlineColor = cc.c3b(0x30, 0x30, 0x30),
    })
    self.mTimesLabel:setAnchorPoint(cc.p(0, 0.5))
    self.mTimesLabel:setPosition(decBgSize.width*0.1+20, decBgSize.height*0.5)
    decBg:addChild(self.mTimesLabel)

    -- 下半部分背景图片大小
    local downBgSize = cc.size(640,700)
    -- 下半部分背景图片
    self.downBgSprite = ui.newScale9Sprite("c_19.png",downBgSize)
    self.downBgSprite:setAnchorPoint(cc.p(0.5, 0))
    self.downBgSprite:setPosition(320, 0)
    self.mParentLayer:addChild(self.downBgSprite)

    -- listView背景图大小
    local listViewBgSize = cc.size(downBgSize.width*0.90,downBgSize.height*0.80)
    -- listView背景图
    local listViewBgSprite = ui.newScale9Sprite("c_17.png",listViewBgSize)
    listViewBgSprite:setAnchorPoint(cc.p(0.5, 1))
    listViewBgSprite:setPosition(320, 665)
    self.downBgSprite:addChild(listViewBgSprite)

    -- 创建月签到的奖励ListView列表
    self.mListView = ccui.ListView:create()
    self.mListView:setDirection(ccui.ScrollViewDir.vertical)
    self.mListView:setBounceEnabled(true)
    self.mListView:setContentSize(cc.size(downBgSize.width*0.95,listViewBgSize.height-10))
    self.mListView:setGravity(ccui.ListViewGravity.centerVertical)
    self.mListView:setAnchorPoint(cc.p(0.5, 1))
    self.mListView:setPosition(downBgSize.width*0.5-30, 660)
    self.downBgSprite:addChild(self.mListView)

    --返回按钮
    local closeBtn = ui.newButton({
        normalImage = "c_29.png",
        position = cc.p(594, 930),
        clickAction = function(pSender)
            LayerManager.addLayer({
                name = "home.HomeLayer"
            })
        end
    })
    self.mCloseBtn = closeBtn
    self.mParentLayer:addChild(closeBtn)
end

--刷新数据
function ActivityMonthSignLayer:refreshData()
	--刷新签到次数
	local totalSign = 0
	for k, v in ipairs(self.mLayerData) do 
		if v.CanDraw == 2 then
			totalSign = totalSign + 1
		end
	end
	self.mTimesLabel:setString(TR("累计签到:  %s%d%s次", "#ffe033", totalSign, Enums.Color.eWhiteH))

	--移除存在的ListView
	self.mListView:removeAllItems()

	--刷新签到奖励ListView
	local width = self.mListView:getContentSize().width
    local height = 135

    -- 一排几个
    local colNum = 4
    -- 计算出总共有多少排（每4个为一排）
	for index = 1, math.ceil(#self.mLayerData / colNum) do
        local lvItem = ccui.Layout:create()
        lvItem:setContentSize(cc.size(width, height))
        self.mListView:pushBackCustomItem(lvItem)

        -- 判断当前排是否为四个
        local itemNum
		if index <= math.floor(#self.mLayerData / colNum) then
			itemNum = colNum
		else
			itemNum = #self.mLayerData % colNum
		end

        -- colNum个奖励头像的位置
        local positionList = {}
        for i = 1, colNum do
            -- 计算间隔
            local moreInterval = -width*(1/(8*(colNum+1)))+i*width*(1/(8*(colNum+1)))   
            positionList[i] = cc.p(width * i/(colNum+1)+moreInterval, 85)
        end

		-- 显示每一排的奖励的图标
		for k = 1, itemNum do
			-- 获取每一个的奖励图标信息
			local info = self.mLayerData[colNum * (index - 1) + k]
			local headerInfo = Utility.analysisStrResList(info.ResourceList)[1]

			-- 创建奖励图标
    		local header = CardNode.createCardNode({
                resourceTypeSub = headerInfo.resourceTypeSub,
                modelId = headerInfo.modelId,
                num = headerInfo.num,
                cardShape = Enums.CardShape.eCircle,
                onClickCallback = function()
                    local canDraw = self.mLayerData[colNum * (index - 1) + k].CanDraw
                    if canDraw == 0 then
                        -- ui.showFlashView({text = "今天不能领取"})
                        CardNode.defaultCardClick(headerInfo)
                    elseif canDraw == 1 then
                        self:requestDrawReward()
                    elseif canDraw == 2 then
                        ui.showFlashView({text = TR("已领取")})
                    end
                end
            })
            header:setAnchorPoint(cc.p(0.5, 0.5))
            header:setPosition(positionList[k])
            header:setSwallowTouches(false)

            -- 判断是否奖励加倍
            if info.NeedVip > 0 then
                if info.Multiple == 2 then
                    local sprite = ui.newSprite("jc_03.png")
        			sprite:setAnchorPoint(cc.p(0, 1))
        			sprite:setPosition(0, header:getContentSize().height-3)
                    header:addChild(sprite, 10)

                    local label = ui.newLabel({
                        text = TR("V%s双倍", info.NeedVip),
                        align = ui.TEXT_ALIGN_CENTER,
                        color = Enums.Color.eWhite,
                        outlineColor = cc.c3b(0xea, 0x30, 0x0b),
                        outlineSize = 1,
                        size = 15
                    })
                    label:setPosition(sprite:getContentSize().width * 0.5 - 5, sprite:getContentSize().height * 0.5 + 8)
                    sprite:addChild(label)
                    label:setRotation(-43) 
                elseif info.Multiple == 3 then
                    local sprite = ui.newSprite("jc_03.png")
                    sprite:setAnchorPoint(cc.p(0, 1))
                    sprite:setPosition(0, header:getContentSize().height-5)
                    header:addChild(sprite, 10)

                    local label = ui.newLabel({
                        text = TR("三倍"),
                        color = Enums.Color.eWhite,
                        outlineColor = cc.c3b(0xea, 0x30, 0x0b),
                        outlineSize = 1,
                        align = ui.TEXT_ALIGN_CENTER,
                        size = 15
                    })
                    label:setPosition(sprite:getContentSize().width * 0.5 - 5, sprite:getContentSize().height * 0.5 + 8)
                    sprite:addChild(label)
                    label:setRotation(-43)  
                end
            end
            lvItem:addChild(header)

            -- 添加可以领取的动画
            if info.CanDraw == 1 then
                header.effect = ui.newEffect({
                    parent = header, 
                    effectName = "effect_ui_liubian",
                    animation = "animation",
                    position = cc.p(header:getContentSize().width * 0.5, header:getContentSize().height * 0.5),
                    loop = true,
                    endRelease = true,
                    speed = 1,
                })
                self.mToChangeHeader = header
            elseif info.CanDraw == 2 then
            	-- 添加已将领取的Sprite
                local doneSprite = ui.newSprite("jc_21.png")
                doneSprite:setAnchorPoint(cc.p(0.5, 0.5))
                doneSprite:setPosition(header:getContentSize().width*0.5, header:getContentSize().height*0.5)
                header:addChild(doneSprite)
            end
	    end    
    end
end

-------------------------网络相关-----------------------------------------
-- 获取玩家月签到信息
function ActivityMonthSignLayer:requestMonthSignInfo()
    HttpClient:request({
        moduleName = "MonthSignInfo",
        methodName = "GetInfo",
        svrMethodData = {},
        callbackNode = self,
        callback = function (response)
        	if not response.Value or response.Status ~= 0 then
                return
            end

        	self.mLayerData = response.Value
            
            --刷新数据
            self:refreshData()
            -- 签到列表从第17天开始，自动滑到最下面去
            if self.mLayerData[17].CanDraw == 1 or self.mLayerData[17].CanDraw == 2 then -- 1:今天签到 2:已签到
                self.mListView:jumpToBottom()
            end
        end
    })
end

-- 领取月签到的奖励
function ActivityMonthSignLayer:requestDrawReward()
    HttpClient:request({
        moduleName = "MonthSignInfo",
        methodName = "DrawReward",
        svrMethodData = {},
        callbackNode = self,
        callback = function (response)
        	if not response.Value or response.Status ~= 0 then
                return
            end

        	self.mToChangeHeader.effect:setVisible(false)

        	--添加已签到标记
        	local signTagSprite = ui.newSprite("jc_21.png")
        	signTagSprite:setAnchorPoint(cc.p(0.5, 0.5))
        	signTagSprite:setPosition(self.mToChangeHeader:getContentSize().width*0.5, self.mToChangeHeader:getContentSize().height*0.5)
            self.mToChangeHeader:addChild(signTagSprite)

            ui.ShowRewardGoods(response.Value.BaseGetGameResourceList)

            --刷新签到次数
            self.mLayerData = response.Value.Info
            local totalSign = 0
            for k, v in ipairs(self.mLayerData) do 
                if v.CanDraw == 2 then
                    totalSign = totalSign + 1
                end
            end
            self.mTimesLabel:setString(TR("%s累计签到 %s%d 次", Enums.Color.eWhiteH, "#03E3F1", totalSign))
        end
    })
end

return ActivityMonthSignLayer

