--[[
	文件名:SlotZhenjueView.lua
	描述：队伍卡槽内功心法展示页面（该页面没有做适配处理，需要创建者考虑适配问题）
	创建人: peiyaoqiang
	创建时间: 2017.03.08
--]]

local SlotZhenjueView = class("SlotZhenjueView", function(params)
    return display.newLayer()
end)

--[[
-- 参数 params中的每项为：
    {
    	viewSize: 显示大小
    	showSlotId: 当前显示的阵容卡槽Id
    	zhenjueSlotIndex: 选中的内功心法卡槽Id，如果为nil表示不需要选中状态
    	isCircleView: 是否把卡槽装备放在圆形上，默认为 false
    	spaceY: 方形分布时的行间距，默认为 150， 如果 isCircleView 参数为true，该参数无效
        formationObj: 阵容数据缓存对象
		onClickItem = nil, -- 点击装备卡牌的回调 onItemClick(zhenjueSlotIndex)
    }
--]]
function SlotZhenjueView:ctor(params)
	self.mViewSize = params.viewSize or cc.size(640, 550)
	--
	self.mSpaceY = params.spaceY or 150
	-- 当前显示的阵容卡槽Id
    self.mShowSlotId = params.showSlotId or 1
	-- 当前选中内功心法的内功心法卡槽Id
	self.mZhenjueSlotIndex = params.zhenjueSlotIndex 
	-- 是否需要显示内功心法选中状态
	self.mNeedSelect = params.zhenjueSlotIndex ~= nil
	-- 是否把卡槽装备放在圆形上
    self.mIsCircleView = params.isCircleView
    -- 阵容数据对象
    self.mFormationObj = params.formationObj
    -- 是否是玩家自己的阵容信息
    self.mIsMyself = self.mFormationObj:isMyself()
	
    -- 点击装备的回调函数
	self.onClickItem = params.onClickItem

	self:setContentSize(self.mViewSize)
	self:setAnchorPoint(cc.p(0.5, 0.5))
	self:setIgnoreAnchorPointForPosition(false)

	local spaceAngle = 40  --
	local rightStartAngle = 40
	local leftStartAngle = 140
	-- 装备CardNode信息
	self.mCardInfo = {
		{ 
			cardNode = nil, -- 该类型对应的CardNode对象
			posIndex = 1, -- 位置编号
			angle = leftStartAngle, -- CardNode的位置相对于中心的角度
		},    
	    { 
	    	cardNode = nil,
	    	posIndex = 2, -- 位置编号
	    	angle = rightStartAngle,
	    },    
	    { 
	    	cardNode = nil,
	    	posIndex = 3, -- 位置编号
	    	angle = leftStartAngle + spaceAngle,
	    },    
	    { 
	    	cardNode = nil,
	    	posIndex = 4, -- 位置编号
	    	angle = rightStartAngle - spaceAngle,
	    },   
	    { 
	    	cardNode = nil,
	    	posIndex = 5, -- 位置编号
	    	angle = leftStartAngle + spaceAngle * 2,
	    },
	    { 
	    	cardNode = nil,
	    	posIndex = 6, -- 位置编号
	    	angle = rightStartAngle - spaceAngle * 2,
	    },
	}

	-- 创建页面控件
	self:initUI()
	-- 刷新页面显示
	self:refresh()
	-- 注册加号刷新事件
	Notification:registerAutoObserver(self.mCardInfo[1].cardNode, function ()
    		-- 不是自己则忽略
    		if not self.mIsMyself then
    			return
    		end

    		-- 当前卡槽未上阵人物则忽略
    		local slotInfo = self.mFormationObj:getSlotInfoBySlotId(self.mShowSlotId)
    		if not Utility.isEntityId(slotInfo and slotInfo.HeroId) then
    			return
    		end

    		-- 遍历寻找空卡槽，判断是否有可用的内功心法
    		local zhenjueList = slotInfo.Zhenjue
			for index, item in pairs(self.mCardInfo) do
				local tempCard = item.cardNode
				if self:slotIsUnlock(index) then
					local prefZhenjue = SlotPrefObj:havePreferableZhenjue(self.mShowSlotId)
					local havePref = (prefZhenjue and prefZhenjue[index]) and true or false
					local zhenjueInfo = zhenjueList[index]
					if not zhenjueInfo or not Utility.isEntityId(zhenjueInfo.Id) then
						if havePref then -- 有更优内功心法可以上阵
							tempCard:showGlitterAddMark("c_144.png", 1.2)
						end
					end
				end
			end
    	end, EventsName.eSlotEquipNodeAddFlagVisible)
end

-- 创建页面控件
function SlotZhenjueView:initUI()
	local radius = 250 -- 卡牌距离控件中心的距离
	local cardCount = table.nums(self.mCardInfo)
	local startPosY = (math.ceil(cardCount / 2) * self.mSpaceY + self.mViewSize.height) / 2
	for index, item in pairs(self.mCardInfo) do
		local tempPosX, tempPosY
		if self.mIsCircleView then
			local tempRad = math.rad(item.angle)
			tempPosX = self.mViewSize.width / 2 + radius *  math.cos(tempRad)
			tempPosY = self.mViewSize.height / 2 + radius * math.sin(tempRad) - 20
		else
			local tempIndex = math.ceil(item.posIndex / 2)
			tempPosX = (math.mod(item.posIndex, 2) == 1) and 70 or (self.mViewSize.width - 70)
			tempPosY = startPosY - (tempIndex - 1) * self.mSpaceY - self.mSpaceY / 2
		end

		local tempCard = CardNode:create({
			cardShape = Enums.CardShape.eCircle,
	        allowClick = true, 
	        onClickCallback = function()
	        	-- 未解锁
	        	if self:slotIsUnlock(index) then
		        	if self.mNeedSelect then
		        		self.mZhenjueSlotIndex = index
		        		self:refresh()
		        	end
	        	end

	        	if self.onClickItem then
	        		self.onClickItem(index)
	        	end
	        end,  
		})
		tempCard:setPosition(tempPosX, tempPosY)
		self:addChild(tempCard)
		item.cardNode = tempCard
	end
end

-- 检查内功心法卡槽是否已解锁
function SlotZhenjueView:slotIsUnlock(zhenjueSlotIndex)
	-- 判断改卡槽是否已经开启
	if self.mFormationObj:slotIsEmpty(self.mShowSlotId) then
		return false
	end

	local slotInfo = self.mFormationObj:getSlotInfoBySlotId(self.mShowSlotId)
	local tempModel = HeroModel.items[slotInfo.ModelId]
	if zhenjueSlotIndex > tempModel.zhenjueSlotMax then
		return false
	end
	return true
end

-- 刷新页面显示
function SlotZhenjueView:refresh()
	local slotInfo = self.mFormationObj:getSlotInfoBySlotId(self.mShowSlotId)
	local zhenjueList = slotInfo and slotInfo.Zhenjue
	for index, item in pairs(self.mCardInfo) do
		local tempCard = item.cardNode

		-- 空卡槽的图片
		local typeId = self.mFormationObj:getZhenjueSlotType(item.posIndex)
		local viewInfo = Utility.getZhenjueViewInfo(typeId)
		
		-- 
		local showAttrs = {}
		if self.mNeedSelect and self.mZhenjueSlotIndex == index then
			table.insert(showAttrs, CardShowAttr.eSelected)
		end

		local tempSize = tempCard:getContentSize()
		if not self:slotIsUnlock(index) then
			tempCard:setEmpty(showAttrs, "c_04.png", "c_35.png")
		else
			local prefZhenjue = SlotPrefObj:havePreferableZhenjue(self.mShowSlotId)
			local havePref = (prefZhenjue and prefZhenjue[index]) and true or false
			local zhenjueInfo = zhenjueList[index]
			if not zhenjueInfo or not Utility.isEntityId(zhenjueInfo.Id) then
				if havePref then -- 有更优内功心法可以上阵
					tempCard:setEmpty({}, "c_04.png", viewInfo.emptyImg)
					tempCard:showGlitterAddMark("c_144.png", 1.2)
				else
					tempCard:setEmpty(showAttrs, "c_04.png", viewInfo.emptyImg)
				end
			else
				table.insert(showAttrs, CardShowAttr.eBorder)
				table.insert(showAttrs, CardShowAttr.eName)
				table.insert(showAttrs, CardShowAttr.eZhenjueType)
				table.insert(showAttrs, CardShowAttr.eStep)
				
				local tempZhenjue = self.mIsMyself and ZhenjueObj:getZhenjue(zhenjueInfo.Id) or zhenjueInfo
            	tempCard:setZhenjue(tempZhenjue, showAttrs)

            	-- 显示小红点
            	if self.mIsMyself then
            		local eventNames = {EventsName.eRedDotPrefix .. tostring(ModuleSub.eFormation)}
			        local function dealRedDotVisible(redDotSprite)
			            redDotSprite:setVisible(SlotPrefObj:itemZhenjueCanStep(zhenjueInfo.Id))
			        end
	                ui.createAutoBubble({refreshFunc = dealRedDotVisible, eventName = eventNames, parent = tempCard})
            	end
			end
		end
	end
end

-- 显示的阵容卡槽改变
--[[
-- 参数
    showSlotId: 当前显示的阵容卡槽Id
]]
function SlotZhenjueView:changeShowSlot(showSlotId)
	self.mShowSlotId = showSlotId or self.mShowSlotId
	-- if self.mNeedSelect and not self:slotIsUnlock(self.mZhenjueSlotIndex) then
	-- 	self.mZhenjueSlotIndex = 1
	-- end
	self:refresh()
end

return SlotZhenjueView
