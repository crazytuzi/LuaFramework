--[[
	文件名：WeChatRedBagMainLayer.lua
	描述：微信红包主页面
	创建人：libowen
	创建时间：2016.8.5
--]]

local WeChatRedBagMainLayer = class("WeChatRedBagMainLayer", function()
	return display.newLayer()
end)

-- 红包类型，枚举值从1依次递增，对应不同的子页面
local RedBagType = {
	eWorldCelebration = 1,					-- 普天同庆
	eChargeAndLogin = 2						-- 充值登录
	-- 待后续增加...		
}

-- 红包页面配置表
local RedBagConfig = {
	-- 普天同庆红包
	[RedBagType.eWorldCelebration] = {
		name = TR("普天同庆"),
		icon = "tb_187.png",
		redBagType = RedBagType.eWorldCelebration,
		fileName = "redbag.WeChatWorldCelebrationLayer",
        isOpen = PlayerAttrObj:getRedBagInfo().WechatWorldIfOpen                    -- 全服微信红包(普天同庆)是否开启
	},

	-- 充值登录红包
	[RedBagType.eChargeAndLogin] = {
		name = TR("微信红包"),
		icon = "tb_201.png",
		redBagType = RedBagType.eChargeAndLogin,
		fileName = "redbag.WeChatChargeAndLoginLayer",
        isOpen = PlayerAttrObj:getRedBagInfo().WechatChargeAndLoginIfOpen           -- 充值登录微信红包是否开启 
	}

	-- 待后续增加...
}

-- 构造函数
--[[
	params:
	Table params:
	{
		redBagType 					-- [可选参数] 红包类型，见 RedBagType 中的枚举值，默认显示第一个已开启的红包页面
	}
--]]
function WeChatRedBagMainLayer:ctor(params)
	params = params or {}

    -- 指定了页面类型，判断是否开启
    local tempType = nil
    if params.redBagType then
        if RedBagConfig[params.redBagType].isOpen then
            tempType = params.redBagType
        end
    end

    -- 未指定页面类型或指定的类型未开启，则显示第一个开启的红包页面
    if not tempType then
        for k, v in pairs(RedBagConfig) do
            if v.isOpen then
                tempType = k
                break
            end
        end
    end
	-- 当前要显示的红包页面
	self.mCurrType = params.redBagType or tempType

    -- UI相关
    self:initUI()
end

-- 添加UI
function WeChatRedBagMainLayer:initUI()
	-- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    -- 包含顶部资源栏和底部导航按钮的layer
    self.mCommonLayer = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        needFAP = false,
        topInfos = {ResourcetypeSub.eSTA, ResourcetypeSub.eVIT, ResourcetypeSub.eGold, ResourcetypeSub.eDiamond}
    })
    self:addChild(self.mCommonLayer)

    -- 存放子页面的layer
    self.mChildLayer = display.newLayer()
    self.mChildLayer:setContentSize(640, 1136)
    self.mParentLayer:addChild(self.mChildLayer)

    --列表背景
    local bg = ui.newScale9Sprite("c_83.png", cc.size(640, 110))
    bg:setPosition(320, 1030)
    self.mParentLayer:addChild(bg)

    --2边箭头
    -- 左箭头
    local leftSprite = ui.newSprite("lm_28.png")
    leftSprite:setPosition(cc.p(30, 1030))
    leftSprite:setScaleX(-1)
    self.mParentLayer:addChild(leftSprite)
    -- 右箭头
    local rightSprite = ui.newSprite("lm_28.png")
    rightSprite:setPosition(cc.p(610, 1030))
    rightSprite:setScaleX(1)
    self.mParentLayer:addChild(rightSprite)

    -- 添加上方ListView
    self:addListView()

    local tempType = self.mCurrType
    self.mCurrType = -1
    -- 显示指定页面
    self:showSubPage(tempType)
end

-- 创建上方ListView
function WeChatRedBagMainLayer:addListView()
	self.mListView = ccui.ListView:create()
    self.mListView:setDirection(ccui.ScrollViewDir.horizontal)
    self.mListView:setBounceEnabled(true)
    self.mListView:setContentSize(cc.size(560, 110))
    self.mListView:setAnchorPoint(cc.p(0.5, 0.5))
    self.mListView:setPosition(320, 1030)
    self.mListView:setChildrenActionType(ui.LISTVIEW_ACTION_NONE)
    self.mListView:setItemsMargin(5)
    self.mParentLayer:addChild(self.mListView)

    -- 根据配置创建每一个cell
    local function createCellByConfig(itemConfig)
    	-- 创建自定义cell
    	local cellWidth, cellHeight = 110, 110
    	local customCell = ccui.Layout:create()
    	customCell:setContentSize(cc.size(cellWidth, cellHeight))
    	customCell.redBagType = itemConfig.redBagType

    	-- 类型按钮
    	local btn = ui.newButton({
    		normalImage = itemConfig.icon,
    		text = itemConfig.name ~= "" and TR(itemConfig.name) or "",
    		fontSize = 22,
    		textColor = cc.c3b(251, 234, 8),			
    		outlineColor = cc.c3b(128, 71, 21), 		
    		outlineSize = 2,  	
    		fixedSize = true,
    		titlePosRateY = 0.2,
    		position = cc.p(cellWidth * 0.5, cellHeight * 0.5),
    		clickAction = function()
    			self:showSubPage(itemConfig.redBagType)
    		end
    	})
    	customCell:addChild(btn)

    	return customCell 
    end

    for k, v in pairs(RedBagConfig) do
        -- 活动开启才创建按钮，此处先默认开启
        --v.isOpen = true
        -------------------------------
        
        if v.isOpen then
    	   self.mListView:pushBackCustomItem(createCellByConfig(v))
        end
    end
end

--获取跳转场景需要保留的数据
function WeChatRedBagMainLayer:getRestoreData()
    local retData = {}
    retData.redBagType = self.mCurrType
    return retData
end

-- 显示相应的红包页面
--[[
	redBagType 				-- 红包类型
--]]
function WeChatRedBagMainLayer:showSubPage(redBagType)
	-- 重复点击不予响应
	if self.mCurrType == redBagType then
		return
	end
	self.mCurrType = redBagType

	-- 选中框
	for k, v in pairs(self.mListView:getItems()) do
		-- 先移除再添加
		if v.selSpr then
			v.selSpr:removeFromParent()
			v.selSpr = nil
		end

		-- 添加选中框
		if v.redBagType == redBagType then
			local posX = v:getContentSize().width * 0.5
			local posY = v:getContentSize().height * 0.5
			local selSpr = ui.newSprite("c_116.png")
			selSpr:setPosition(posX, posY)
			v:addChild(selSpr, -1)
			-- 保存引用
			v.selSpr = selSpr
		end
	end

    -- 先移除再添加
    self.mChildLayer:removeAllChildren()

	-- 显示子页面
	local subLayer = require(RedBagConfig[redBagType].fileName):create()
    self.mChildLayer:addChild(subLayer)
end

return WeChatRedBagMainLayer