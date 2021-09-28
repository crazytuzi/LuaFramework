--[[
    文件名: ActivityVIPWelfareLayer.lua
	描述: VIP福利页面, 模块Id为：ModuleSub.eExtraActivityVIPWelfare
	效果图: 会员福利.png
	创建人: yanghongsheng
	创建时间: 2017.3.11
--]]

local ActivityVIPWelfareLayer = class("ActivityVIPWelfareLayer", function()
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
function ActivityVIPWelfareLayer:ctor(params)
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
		--请求数据
		self:requestGetVipWelfare()
	end
end

-- 获取恢复数据
function ActivityVIPWelfareLayer:getRestoreData()
	local retData = {
		activityIdList = self.mActivityIdList,
		parentModuleId = self.mParentModuleId,
		cacheData = self.mLayerData
	}

	return retData
end

-- 位置
local TipsPosY = 935
local PrivilegePosY = 675

-- 初始化页面控件
function ActivityVIPWelfareLayer:initUI()
	-- 背景图
    local bgSprite = ui.newSprite("jc_24.jpg")
    bgSprite:setAnchorPoint(cc.p(0.5, 0.5))
    bgSprite:setPosition(320,568)
    self.mParentLayer:addChild(bgSprite)

    -- title图
    local titleSprite = ui.newSprite("jc_11.png")
    titleSprite:setAnchorPoint(cc.p(0, 0.5))
    titleSprite:setPosition(0,860)
    self.mParentLayer:addChild(titleSprite)

    -- -- 人物
    -- local figureSprite = ui.newSprite("jc_18.png")
    -- figureSprite:setPosition(420, 500)
    -- self.mParentLayer:addChild(figureSprite)

    -- 提示背景图
    local hintBgSize =  cc.size(600, 35)
    local hintLabelBg = ui.newScale9Sprite("jc_02.png", hintBgSize)
    hintLabelBg:setPosition(320, 950)
    self.mParentLayer:addChild(hintLabelBg)

    -- 提示
    local textLabel = ui.newLabel({
        text = TR("每天登录，都可根据当前VIP等级领取相应奖励"),
        size = 20,
        x = hintBgSize.width * 0.5,
        y = hintBgSize.height * 0.5,
        outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
        outlineSize = 2,
        align = ui.TEXT_ALIGN_CENTER
    })
    hintLabelBg:addChild(textLabel)

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

    -- 创建Vip会员信息控件
   	self:initPrivilegeUI()
   	-- 创建Vip奖励信息控件
   	self:initRewardUI()
end   

-- 创建Vip会员信息控件
function ActivityVIPWelfareLayer:initPrivilegeUI( ... )
    -- VIP会员背景
    local vipBg = ui.newScale9Sprite("c_94.png", cc.size(620, 380))
    vipBg:setPosition(320, 600)
    self.mParentLayer:addChild(vipBg)
    -- VIP会员背景大小
    local vipBgSize = vipBg:getContentSize()
    --VIP%d会员标签
    local vipSprite = ui.newSprite("jc_35.png")
    vipSprite:setPosition(vipBgSize.width*0.5, vipBgSize.height-20)
    vipBg:addChild(vipSprite)
    local vipNode = ui.newNumberLabel({
        text = "0",
        imgFile = "c_49.png",
    })
    vipNode:setPosition(vipBgSize.width*0.5, vipBgSize.height-20)
    vipBg:addChild(vipNode)

    -- 创建 显示Vip会员信息的listView
    local listViewSize = cc.size(vipBgSize.width*0.8, vipBgSize.height*0.8)
    local vipListView = ccui.ListView:create()
    vipListView:setItemsMargin(7)
    vipListView:setDirection(ccui.ScrollViewDir.vertical)
    vipListView:setBounceEnabled(true)
    vipListView:setContentSize(listViewSize)
    vipListView:setPosition(vipBgSize.width*0.5, vipBgSize.height*0.85)
    vipListView:setAnchorPoint(cc.p(0.5, 1))
    vipListView:setChildrenActionType(0)
    vipBg:addChild(vipListView)

    -- 获取玩家VIP等级
    local currViewVipLv = PlayerAttrObj:getPlayerAttrByName("Vip") or 0
    -- 刷新Vip会员信息列表
    local function refreshVipInfo(vipLv)
        currViewVipLv = vipLv
        -- 刷新vip会员标签
        vipSprite:setTexture(vipLv > Utility.getVipStep() and "jc_50.png" or "jc_35.png")
        vipNode:setString(TR("%s",vipLv > Utility.getVipStep() and vipLv-Utility.getVipStep() or vipLv))

        -- 刷新会员信息
        vipListView:removeAllChildren()
        local vipIntroItem = VipLvIntroRelation.items[vipLv]
        for index, item in ipairs(vipIntroItem) do
            local cellItem = ccui.Layout:create()

            local newIntro = nil
            if vipLv > Utility.getVipStep() then
                -- 替换“会员”为尊享
                local subStr = string.match(vipIntroItem[index].intro, TR("会员(#%w+)"))
                if subStr then
                    local colorStr = string.sub(subStr, 1, 7)
                    newIntro = string.gsub(vipIntroItem[index].intro, TR("会员#%w+"), TR("尊享")..colorStr..(vipLv - Utility.getVipStep()))
                end
            end
            -- 显示一条会员信息
            local tempLabel = ui.newLabel({
                text = newIntro or vipIntroItem[index].intro,
                size = 20,
                dimensions = cc.size(listViewSize.width - 30, 0),
                outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
                outlineSize = 2,
            })
            -- 设置显示label的属性
            tempLabel:setAnchorPoint(cc.p(0.5, 1))
            -- 获取显示label的大小
            local cellSize = cc.size(listViewSize.width, tempLabel:getContentSize().height)
            tempLabel:setPosition(cc.p(cellSize.width * 0.5 - 6, cellSize.height))
            cellItem:addChild(tempLabel)
            -- 设置 cell的属性
            cellItem:setContentSize(cellSize)
            vipListView:pushBackCustomItem(cellItem)
        end
    end 
    --
    refreshVipInfo(currViewVipLv)

    --  左箭头
    local leftBtn = ui.newButton({
        normalImage = "c_26.png",
        clickAction = function()
            local tempLv = currViewVipLv - 1
            if tempLv < 0 then
                return 
            end
            refreshVipInfo(tempLv)
        end
    })
    leftBtn:setPosition(15, vipBgSize.height*0.5)
    leftBtn:setRotation(180)
    vipBg:addChild(leftBtn)

    -- 右箭头
    local rightBtn = ui.newButton({
        normalImage = "c_26.png",
        clickAction = function()
            local tempLv = currViewVipLv + 1 
            if tempLv >= VipLvIntroRelation.items_count then
                return
            end
            refreshVipInfo(tempLv)
        end
    })
    rightBtn:setPosition(vipBgSize.width-15, vipBgSize.height*0.5)
    vipBg:addChild(rightBtn)
end

-- 创建Vip奖励信息控件
function ActivityVIPWelfareLayer:initRewardUI()
    -- VIP每日福利背景
    local vipWelfareBg = ui.newScale9Sprite("c_93.png",
        cc.size(640, 220))
    vipWelfareBg:setPosition(320, 300)
    self.mParentLayer:addChild(vipWelfareBg)
    -- VIP每日福利大小
    local vipBgSize = vipWelfareBg:getContentSize()
	--获取玩家VIP等级
	local vipLevel = PlayerAttrObj:getPlayerAttrByName("Vip") or 0
    --VIP%d会员标签
    local vipSprite = ui.newSprite(vipLevel > Utility.getVipStep() and "jc_51.png" or "jc_36.png")
    vipSprite:setPosition(vipBgSize.width*0.5, 170)
    vipWelfareBg:addChild(vipSprite)
    local titleLabel = ui.newNumberLabel({
        text = TR("%s", vipLevel > Utility.getVipStep() and vipLevel - Utility.getVipStep() or vipLevel),
        imgFile = "jc_37.png",
    })
    titleLabel:setPosition(vipBgSize.width*0.46, 170)
    vipWelfareBg:addChild(titleLabel)
    -- VIP福利奖励列表
    local viewSize = cc.size(vipBgSize.width, 150)
    local cellSize = cc.size(120, viewSize.height)
    self.mRewardListView = ui.newSliderTableView({
        width = viewSize.width,
        height = viewSize.height,
        isVertical = false,
        selItemOnMiddle = false,
        itemCountOfSlider = function(sliderView)
            return self.mLayerData and #self.mLayerData.ResourceList or 0
        end,
        itemSizeOfSlider = function(sliderView)
            return cellSize.width, cellSize.height
        end,
        sliderItemAtIndex = function(sliderView, itemNode, index)
            local info = self.mLayerData.ResourceList[index + 1]

            local tempCard = CardNode.createCardNode({
                resourceTypeSub = info.ResourceTypeSub,
                modelId = info.ModelId,
                num = info.Count,
                nameColor = Enums.Color.eYellow
            })
            tempCard:setPosition(cc.p(cellSize.width / 2, cellSize.height / 2))
            itemNode:addChild(tempCard)
        end,
        selectItemChanged = function(sliderView, selectIndex)
            -- Todo
        end,
    })
    self.mRewardListView:setAnchorPoint(cc.p(0.5, 0.5))
    self.mRewardListView:setPosition(vipBgSize.width*0.5, vipBgSize.height*0.4)
    vipWelfareBg:addChild(self.mRewardListView)

    -- 领取按钮
    self.mGetBtn = ui.newButton({
        normalImage = "c_28.png",
        text = TR("领取"),
        fontSize = 24,
        clickAction = function()
            self:requestDrawVipWelfare()
        end,
    })
    self.mGetBtn:setPosition(320, 140)
    self.mParentLayer:addChild(self.mGetBtn)
    --  判断是否已经领取奖励
    if self.mLayerData and self.mLayerData.CanDraw == false then 
        self.mGetBtn:setEnabled(false)
    end    
end

--刷新函数
function ActivityVIPWelfareLayer:refreshData()
    -- 刷新奖励列表
    self.mRewardListView:reloadData()
    -- 判断是否已经领取奖励
    if self.mLayerData.CanDraw == false then
        self.mGetBtn:setEnabled(false)
    end
end

-----------------网络相关-------------------
--获取VIP等级对应的奖励单
function ActivityVIPWelfareLayer:requestGetVipWelfare()
    HttpClient:request({
        moduleName = "VipWelfare", 
        methodName = "GetVipWelfare",
        svrMethodData = {},
        callbackNode = self,
        callback = function (response)
        	if not response.Value or response.Status ~= 0 then
                return
            end
            
        	self.mLayerData = response.Value
            --刷新函数
            self:refreshData()
        end
    })
end

--判断是否已经领奖  没有则点击领取  否则按钮设置为灰色
function ActivityVIPWelfareLayer:requestDrawVipWelfare()
    HttpClient:request({
        moduleName = "VipWelfare",
        methodName = "DrawVipWelfare",
        svrMethodData = {},
        callbackNode = self,
        callback = function (response)
        	--dump(response,"aaaaaaaa")
            if not response.Value or response.Status ~= 0 then
                return
            end
            
            self.mLayerData.CanDraw = false

            self:refreshData()

            ui.ShowRewardGoods(response.Value.BaseGetGameResourceList)
        end
    })
end

return ActivityVIPWelfareLayer