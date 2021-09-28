--[[
	文件名：BrewHomeLayer.lua
	描述：酿酒主界面
	创建人：yanghongsheng
	创建时间： 2018.5.21
--]]

local BrewHomeLayer = class("BrewHomeLayer", function()
	return display.newLayer()
end)

function BrewHomeLayer:ctor()
	-- 屏蔽下层触摸
	ui.registerSwallowTouch({node = self})
	-- 创建标准容器
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)
    -- 创建底部导航和顶部玩家信息部分
    local tempLayer = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        currentLayerType = Enums.MainNav.ePractice,
        topInfos = {ResourcetypeSub.eVIT, ResourcetypeSub.eGold, ResourcetypeSub.eDiamond}
    })
    self:addChild(tempLayer)
    self.mCommonLayer_ = tempLayer
    -- 初始化
    self:initUI()
end

function BrewHomeLayer:initUI()
	-- 背景
	local bgSprite = ui.newSprite("hj_1.jpg")
	bgSprite:setPosition(320, 568)
	self.mParentLayer:addChild(bgSprite)
	-- 标题
	local titleSprite = ui.newSprite("hj_9.png")
	titleSprite:setPosition(320, 1011)
	self.mParentLayer:addChild(titleSprite)
	-- 创建按钮
	self:createBtn()
	-- 创建喝酒小页面
	self:createHejiuLayer()
end

-- 创建页面按钮
function BrewHomeLayer:createBtn()
	-- 按钮列表
	local btnList = {
		-- 去喝酒
		{
			normalImage = "c_28.png",
			text = TR("去喝酒"),
			tag = 1,
			position = cc.p(210, 160),
			clickAction = function ()
				self:createHejiuLayer()
			end,
		},
		-- 酿酒
		{
			normalImage = "c_28.png",
			text = TR("酿酒"),
			tag = 2,
			position = cc.p(432, 160),
			clickAction = function ()
				self:createLiangjiuLayer()
			end,
		},
		-- 规则
		{
			normalImage = "c_72.png",
			position = cc.p(50, 1033),
			clickAction = function ()
                MsgBoxLayer.addRuleHintLayer(TR("规则"),
                    {
                        TR("1.酿酒需要消耗酒引和酒材，酿制一壶酒只需要消耗一个酒引，酒材则需要多次加入。"),
                        TR("2.限时掉落活动掉落的材料道具均可作为酒材，部分特殊道具除外。"),
                        TR("3.酿制成的酒可以赠送给侠客增加亲密度。"),
                        TR("4.酿制高级酒才需要酒引，高级酒可以增加更多的亲密度。"),
                        TR("5.亲密度每提升一级都可以提升相应侠客的属性。"),
                        TR("6.重生可以返还赠送的酒。"),
                    })
			end,
		},
		-- 返回
		{
			normalImage = "c_29.png",
			position = cc.p(590, 1033),
			clickAction = function ()
				LayerManager.removeLayer(self)
			end,
		},
	}

	-- 创建按钮
	for _, btnInfo in pairs(btnList) do
		local tempBtn = ui.newButton(btnInfo)
		self.mParentLayer:addChild(tempBtn, 1)

		-- 喝酒按钮
		if btnInfo.tag == 1 then
			self.mHejiuBtn = tempBtn
		-- 酿酒按钮
		elseif btnInfo.tag == 2 then
			self.mLiangjiuBtn = tempBtn
		end
	end
end

-- 创建喝酒页面
function BrewHomeLayer:createHejiuLayer()
	if not self.mHejiuLayer then
		self.mHejiuLayer = require("brew.BrewEatLayer").new({
				cbQualitySelect = handler(self, self.showQalityBox),
			})
		self.mParentLayer:addChild(self.mHejiuLayer)
	end

	-- 显示喝酒界面
	self.mHejiuLayer:setVisible(true)
    -- 刷新界面
    self.mHejiuLayer:refreshWineList(self.mHejiuLayer.mQualitySelList)
	-- 隐藏酿酒页面
	if self.mLiangjiuLayer then
		self.mLiangjiuLayer:setVisible(false)
	end

	-- 隐藏喝酒按钮
	self.mHejiuBtn:setVisible(false)
	-- 显示酿酒按钮
	self.mLiangjiuBtn:setVisible(true)
end

-- 创建酿酒页面
function BrewHomeLayer:createLiangjiuLayer()
	if not self.mLiangjiuLayer then
		self.mLiangjiuLayer = require("brew.BrewWineLayer").new({
				cbQualitySelect = handler(self, self.showQalityBox),
			})
		self.mParentLayer:addChild(self.mLiangjiuLayer)
	end

	-- 显示酿酒界面
	self.mLiangjiuLayer:setVisible(true)
    -- 刷新界面
    self.mLiangjiuLayer:refreshWineList(self.mLiangjiuLayer.mQualitySelList)
	-- 隐藏喝酒页面
	if self.mHejiuLayer then
		self.mHejiuLayer:setVisible(false)
	end

	-- 隐藏酿酒按钮
	self.mLiangjiuBtn:setVisible(false)
	-- 显示喝酒按钮
	self.mHejiuBtn:setVisible(true)
end

-- 筛选品质
--[[
	描述：弹出品质选择框，可以根据选择的品质刷新列表
	参数：params = {
			refreshCallBack	刷新回调（参数应是选择的品质列表),
			boxPosition 	弹窗位置
		}
]]
function BrewHomeLayer:showQalityBox(params)
	params = params or {}

	--保存菜单选择状态
    self.mSelectStatus = {
        -- [1] = false, -- 白色
        [2] = false,    -- 绿色
        [3] = false,    -- 蓝色
        [4] = false,    -- 紫色
        [5] = false,    -- 橙色
        [6] = false,    -- 红色
        [7] = false,    -- 金色
    }
    -- 是否已打开选择盒
    if self.isOpenBox then return end
    self.isOpenBox = true
    -- 添加一个当前最上层的层
    local touchLayer = ui.newStdLayer()
    self:addChild(touchLayer, 999)
    -- 添加选择盒背景
    local selBgSprite = ui.newScale9Sprite("gd_01.png", cc.size(100, 100))
    selBgSprite:setAnchorPoint(0.5, 0)
    selBgSprite:setPosition(params.boxPosition or cc.p(450, 200))
    selBgSprite:setScale(0.1)
    touchLayer:addChild(selBgSprite)
    -- 播放变大动画
    local scale = cc.ScaleTo:create(0.3, 1)
    selBgSprite:runAction(scale)
    -- 关闭选择盒
    local function closeBox()
        local callfunDelete = cc.CallFunc:create(function()
            touchLayer:removeFromParent()
            self.isOpenBox = false
        end)
        local scale = cc.ScaleTo:create(0.3, 0.1)
        selBgSprite:runAction(cc.Sequence:create(scale, callfunDelete))
    end
    -- 注册触摸监听关闭选择盒
    ui.registerSwallowTouch({
        node = touchLayer,
        allowTouch = true,
        endedEvent = function(touch, event)
            closeBox()
        end
    })
    -- 创建选择列表
    local function createCheckBoxList(cellSize)
        -- 列表view
        local selectList = ccui.ListView:create()
        selectList:setDirection(ccui.ScrollViewDir.vertical)
        -- 列表高度计数
        local listHight = 0

        for key, _ in pairs(self.mSelectStatus) do
            local layout = ccui.Layout:create()
            layout:setContentSize(cellSize)

            local cellSprite = ui.newScale9Sprite("zl_09.png", cc.size(cellSize.width, cellSize.height-5))
            cellSprite:setPosition(cellSize.width*0.5, cellSize.height*0.5)
            layout:addChild(cellSprite)

            local color = Utility.getColorValue(key, 1)
            local checkBtn = ui.newCheckbox({
                text = TR("%s品质",Utility.getColorName(key)),
                isRevert = true,
                textColor = color,
                outlineColor = Enums.Color.eBlack,
                outlineSize = 2,
                callback = function(pSenderC)
                    self.mSelectStatus[key] = not self.mSelectStatus[key]
                end
                })
            checkBtn:setPosition(cellSize.width*0.5, cellSize.height*0.5)
            layout:addChild(checkBtn)
            checkBtn:setCheckState(self.mSelectStatus[key])
            
            -- 透明按钮（点击列表项改变复选框状态）
            local touchBtn = ui.newButton({
                normalImage = "c_83.png",
                size = cellSize,
                clickAction = function()
                    self.mSelectStatus[key] = not self.mSelectStatus[key]
                    checkBtn:setCheckState(self.mSelectStatus[key])
                end
            })
            touchBtn:setPosition(cellSize.width*0.5, cellSize.height*0.5)
            cellSprite:addChild(touchBtn)
            
            -- 加入列表
            selectList:pushBackCustomItem(layout)
            -- 列表长度计数
            listHight = listHight + cellSize.height
        end
        -- 设置列表大小
        selectList:setContentSize(cellSize.width, listHight+10)

        return selectList
    end
    -- 创建列表
    local selectListView = createCheckBoxList(cc.size(200, 50))
    local listSize = selectListView:getContentSize()
    -- 重设背景图大小
    local bgSize = cc.size(listSize.width+40, listSize.height+100)
    selBgSprite:setContentSize(bgSize)
    -- 设置列表位置
    selectListView:setAnchorPoint(cc.p(0.5, 0))
    selectListView:setPosition(bgSize.width*0.5, 60)
    selBgSprite:addChild(selectListView)

    -- 关闭按钮
    local closeButton = ui.newButton({
        normalImage = "zl_10.png",
        clickAction = function()
            touchLayer:removeFromParent()
            self.isOpenBox = false
        end
    })
    closeButton:setPosition(bgSize.width * 0.87, bgSize.height-25)
    selBgSprite:addChild(closeButton)

    -- 确定按钮
    local confirmButton = ui.newButton({
        normalImage = "c_28.png",
        text = TR("确认"),
        clickAction = function()
            -- 是否有选择品质
            local qualityLvList = {}
            for lv, state in pairs(self.mSelectStatus) do
                if state then
                    qualityLvList[lv] = true
                end
            end
            -- 若选了
            if params.refreshCallBack then
            	params.refreshCallBack(qualityLvList)
            end
            -- 关闭选择盒
            closeBox()
        end
    })
    confirmButton:setScale(0.9)
    confirmButton:setPosition(bgSize.width * 0.5, 40)
    selBgSprite:addChild(confirmButton)
end


return BrewHomeLayer