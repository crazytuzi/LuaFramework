--[[
	文件名:TeamHeadView.lua
	描述：队伍顶部小头像列表（该页面没有做适配处理，需要创建者考虑适配）
	创建人: peiyaoqiang
	创建时间: 2017.03.08
--]]

local TeamHeadView = class("TeamHeadView", function(params)
    return display.newLayer()
end)

--[[
-- 参数 params中的每项为：
    {
        needPet: -- 是否需要外功秘籍按钮，默认为true
    	needMate: -- 是否需要江湖后援团按钮， 默认为true
    	viewSize: 显示大小, 默认为：cc.size(640, 100)
    	bgImgName: 背景图片， 默认为不需要背景图
        showSlotId: 当前显示的阵容卡槽Id（0:外功秘籍; 1-6:阵容卡槽Id; 7:江湖后援团）
        formationObj: 阵容数据缓存对象

		checkReddotId = nil -- 人物头像小红点判断的模块ID(Enum中客户端定义)
		onClickItem = nil, -- 点击人物头像的回调函数 onClickItem(slotId)
    }
--]]
function TeamHeadView:ctor(params)
	params = params or {}
	
	-- 判断外功秘籍模块是否已开启
	self.mNeedPet = (params.needPet ~= false) and self:isPetModuleOpen()
	-- 是否需要江湖后援团按钮
	self.mNeedMate = params.needMate ~= false 
	-- 显示大小
	self.mViewSize = params.viewSize or cc.size(640, 100)
	-- 背景图片
	self.mBgImgName = params.bgImgName 
	-- 当前显示的阵容卡槽Id
    self.mShowSlotId = params.showSlotId or 1
    -- 阵容数据对象
    self.mFormationObj = params.formationObj
    -- 是否是玩家自己的阵容信息
    self.mIsMyself = self.mFormationObj:isMyself()
	-- 阵容最大的卡槽数
	self.mSlotMaxCount = self.mFormationObj:getMaxSlotCount()
	-- 检查是否需要显示小红点点回调
	self.checkReddotId = params.checkReddotId
	-- 当选中卡槽改变的回调函数
	self.onClickItem = params.onClickItem

	-- 卡槽头像对象列表
	self.mSlotCardList = {}

	-- 设置该layer的大小
	self:setContentSize(self.mViewSize)
	self:setAnchorPoint(cc.p(0.5, 1))
	self:setIgnoreAnchorPointForPosition(false)

	-- 创建页面控件
	self:initUI()
end

-- 创建页面控件
function TeamHeadView:initUI()
	-- 头像的背景图片
	if string.isImageFile(self.mBgImgName) then
		local tempSize = ui.getImageSize(self.mBgImgName)
		local tempSprite = ui.newScale9Sprite(self.mBgImgName, cc.size(640, tempSize.height))
		tempSprite:setAnchorPoint(cc.p(0.5, 1))
		tempSprite:setPosition(self.mViewSize.width / 2, self.mViewSize.height)
		self:addChild(tempSprite)
	end
	
	-- 外功秘籍按钮的大小
	local petBtnSize = ui.getImageSize("tb_35.png")
	-- 头像的大小
	local cardSize = ui.getImageSize("c_04.png")
	-- 箭头的大小
	local arrowSize = ui.getImageSize("c_26.png")
	-- X方向间距
	local spaceX = 10
	-- 从左向右排列的x坐标
	local leftPosX = spaceX
	-- 外功秘籍按钮
	if self.mNeedPet then
		local tempCard = require("common.CardNode").new({
			allowClick = true,
			onClickCallback = function()
				if self.onClickItem then
					self.onClickItem(0)
				end
			end
		})
		tempCard:setPosition(petBtnSize.width / 2, self.mViewSize.height / 2)
		self:addChild(tempCard)
		self.mSlotCardList[0] = tempCard
		self:setCardNodeData(0)
		--
		leftPosX = leftPosX  + petBtnSize.width + spaceX
	end

	
	-- 主角头像
	local mainCardPosX = 1
	local tempCard = require("common.CardNode").new({
		allowClick = true,
		onClickCallback = function()
			if self.onClickItem then
				self.onClickItem(1)
			end
		end
	})
	tempCard:setPosition(leftPosX + cardSize.width / 2, self.mViewSize.height / 2)
	self:addChild(tempCard)
	self.mSlotCardList[1] = tempCard
	self:setCardNodeData(1)
	--
	leftPosX = leftPosX + cardSize.width + spaceX

	-- 其他上阵人物头像列表
	local listWidth = self.mViewSize.width - leftPosX - arrowSize.width * 2
	self.mSlotListView = ccui.ListView:create()
    self.mSlotListView:setDirection(ccui.ScrollViewDir.horizontal)
    self.mSlotListView:setBounceEnabled(true)
    self.mSlotListView:setContentSize(cc.size(listWidth, self.mViewSize.height))
    self.mSlotListView:setAnchorPoint(cc.p(0, 0.5))
    self.mSlotListView:setPosition(cc.p(leftPosX + arrowSize.width, self.mViewSize.height / 2))
    self.mSlotListView:setChildrenActionType(ui.LISTVIEW_ACTION_NONE)
    self:addChild(self.mSlotListView)
    -- 添加卡槽Item
    local cellSize = cc.size(cardSize.width + spaceX, self.mViewSize.height)
    for index = 2, self.mNeedMate and self.mSlotMaxCount or (self.mSlotMaxCount - 1) do 
    	local lvItem = ccui.Layout:create()
        lvItem:setContentSize(cellSize)
        self.mSlotListView:pushBackCustomItem(lvItem)

        local tempCard = require("common.CardNode").new({
        	allowClick = true,
			onClickCallback = function()
				if self.onClickItem then
					self.onClickItem(index)
				end
			end
		})
		tempCard:setPosition(cellSize.width / 2, cellSize.height / 2)
		lvItem:addChild(tempCard)
		self.mSlotCardList[index] = tempCard
		self:setCardNodeData(index)
    end

	-- 左箭头
	local tempSprite = ui.newSprite("c_26.png")
	tempSprite:setPosition(leftPosX + arrowSize.width / 2, self.mViewSize.height / 2)
	tempSprite:setScaleX(-1)
	self:addChild(tempSprite)

	-- 右箭头
	local tempPosX = self.mViewSize.width - arrowSize.width / 2
	local tempSprite = ui.newSprite("c_26.png")
	tempSprite:setPosition(tempPosX, self.mViewSize.height / 2)
	self:addChild(tempSprite)

	--
	self:changeShowSlot(self.mShowSlotId)
end

-- 设置卡牌对象的显示内容
--[[
-- 参数
	slotIndex： 卡槽的index
]]
function TeamHeadView:setCardNodeData(slotIndex)
	local tempCard = self.mSlotCardList[slotIndex]
	if not tempCard then
		return 
	end

	-- 江湖后援团按钮
	if self.mSlotMaxCount == slotIndex then
		tempCard:setEmpty((slotIndex == self.mShowSlotId) and {CardShowAttr.eSelected} or {}, "tb_12.png")
		return 
	end

	-- 外功秘籍按钮
	if slotIndex == 0 then
		tempCard:setEmpty((slotIndex == self.mShowSlotId) and {CardShowAttr.eSelected} or {}, "tb_35.png")
		return 
	end

	-- 其他人物头像
	local tempSlot = self.mFormationObj:getSlotInfoBySlotId(slotIndex)
	if not tempSlot then
		tempCard:setEmpty({}, "c_04.png", "c_35.png")
		return
	end
	if Utility.isEntityId(tempSlot.HeroId) then
		local showAttrs = {CardShowAttr.eBorder, CardShowAttr.eLevel, CardShowAttr.eStep}
		if slotIndex == self.mShowSlotId then
			table.insert(showAttrs, CardShowAttr.eSelected)
		end
		local tmpHeroInfo = {}
		if self.mIsMyself then
			tmpHeroInfo = clone(HeroObj:getHero(tempSlot.HeroId))
			tmpHeroInfo.FashionModelID = PlayerAttrObj:getPlayerAttrByName("FashionModelId")
			
		else
			tmpHeroInfo = clone(tempSlot.Hero)
			tmpHeroInfo.FashionModelID = self.mFormationObj:getThisPlayerInfo().FashionModelId
		end
		tempCard:setHero(tmpHeroInfo, showAttrs)

		-- 是否显示可更换标识
		if self.mIsMyself and self.mFormationObj:haveBetterHero(tempSlot.ModelId) then
			tempCard:createStrImgMark("c_58.png", TR("可更换"))
		end
	else
		tempCard:setEmpty({CardShowAttr.eBgHero}, "c_04.png", nil)
		if self.mIsMyself then
			tempCard:showGlitterAddMark("c_144.png", 1.2)
		end
	end

	-- 需要判断显示小红点
	if self.checkReddotId and tolua.isnull(tempCard.redDotSprite) then
		-- 注册小红点点事件名
		local eventNames = RedDotInfoObj:getEvents(self.checkReddotId)
		if self.mSlotMaxCount == slotIndex then -- 江湖后援团按钮
			-- Todo
		elseif slotIndex == 0 then -- 外功秘籍按钮
			-- Todo
		else  -- 阵容卡槽
			local tempSlot = self.mFormationObj:getSlotInfoBySlotId(slotIndex)
			if tempSlot and Utility.isEntityId(tempSlot.HeroId) then
				table.insert(eventNames, EventsName.eSlotRedDotPrefix .. tostring(slotIndex)) -- 卡槽信息变化
				table.insert(eventNames, EventsName.eRedDotPrefix .. tostring(ModuleSub.eFormation)) -- 内功进阶变化是通过卡槽0返回的，无法通过上一个得到通知，所以这里需要注册整个阵容变化的通知
			end
		end
		
		if #eventNames > 0 then
			-- 设置小红点是否需要显示
			local function dealRedDotVisible(redDotSprite)
				redDotSprite:setVisible(RedDotInfoObj:isValid(self.checkReddotId, nil ,slotIndex))
			end

			-- 注册小红点点通知事件
			local posx = (slotIndex==1) and (self:isPetModuleOpen() and 0.3 or 0.15) or 0.8
			tempCard.redDotSprite = ui.createAutoBubble({refreshFunc = dealRedDotVisible, 
				position = cc.p(posx, 0.8),
				eventName = eventNames, parent = tempCard:getParent()})
		end
	end
end

-- 判断外功是否开放，本界面多地方使用
function TeamHeadView:isPetModuleOpen()
	return ModuleInfoObj:moduleIsOpen(ModuleSub.ePet, false)
end

-- 显示的阵容卡槽改变
--[[
-- 参数
	showSlotId: 当前显示的阵容卡槽Id
	isSelfChange: 是否是本控件内修改选择条目, 默认为 false
]]
function TeamHeadView:changeShowSlot(showSlotId)
	local oldShowSlotId = self.mShowSlotId
	self.mShowSlotId = showSlotId
	self:setCardNodeData(oldShowSlotId)
	self:setCardNodeData(showSlotId)

	if self.mShowSlotId > 1 then -- 如果选中的不是主角卡槽，则需要设置选中条目在显示区域内
    	ui.setListviewItemShow(self.mSlotListView, self.mShowSlotId - 1)
	end
end

return TeamHeadView