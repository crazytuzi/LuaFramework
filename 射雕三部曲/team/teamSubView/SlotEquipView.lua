--[[
	文件名:SlotEquipView.lua
	描述：队伍卡槽装备展示页面（该页面没有做适配处理，需要创建者考虑适配问题）
	创建人：peiyaoqiang
	创建时间：2017.03.08
--]]

local SlotEquipView = class("SlotEquipView", function(params)
    return display.newLayer()
end)

--[[
-- 参数 params中的每项为：
    {
    	viewSize: 显示大小
    	selectType: 选中的装备类型，如果为nil表示不需要选中状态，取值在 EnumsConfig.lua 文件的 ResourcetypeSub 中定义
    	showSlotId: 当前显示的阵容卡槽Id
    	onlyShowEquip: 是否只显示装备，不显示神兵和秘籍，默认为false
        formationObj: 阵容数据缓存对象
		onClickItem = nil, -- 点击装备卡牌的回调 onItemClick(ResourcetypeSub)
    }
--]]
function SlotEquipView:ctor(params)
	self.mViewSize = params.viewSize or cc.size(640, 550)
	-- 是否需要显示装备选中状态
	self.mNeedSelect = params.selectType ~= nil
	-- 当前选中的装备类型
	self.mSelectType = params.selectType
	-- 当前显示的阵容卡槽Id
    self.mShowSlotId = params.showSlotId or 1
    -- 是否只显示装备，不显示神兵和秘籍
    self.onlyShowEquip = params.onlyShowEquip or false
    -- 阵容数据对象
    self.mFormationObj = params.formationObj
    -- 是否是玩家自己的阵容信息
    self.mIsMyself = self.mFormationObj:isMyself()
    -- 点击装备的回调函数
	self.onClickItem = params.onClickItem

	self:setContentSize(self.mViewSize)
	self:setAnchorPoint(cc.p(0.5, 0.5))
	self:setIgnoreAnchorPointForPosition(false)

	-- 装备CardNode信息
	self.mCardInfo = {
		[ResourcetypeSub.eClothes] = { -- "战甲"
	    	slotName = "Clothes",
	    	cardNode = nil,
	    	posIndex = 1, -- 位置编号
	    },
	    [ResourcetypeSub.eHelmet] = { -- "头盔"
	    	slotName = "Helmet",
	    	cardNode = nil,
	    	posIndex = 2, -- 位置编号
	    },
	    [ResourcetypeSub.ePants] = { -- 裤子
	    	slotName = "Pants",
	    	cardNode = nil,
	    	posIndex = 3, -- 位置编号
	    },
	    [ResourcetypeSub.eWeapon] = { -- "武器"
			slotName = "Weapon",  -- 在阵容卡槽中该类型数据的 key
			cardNode = nil, -- 该类型对应的CardNode对象
			posIndex = 4, -- 位置编号
		},
		[ResourcetypeSub.eShoe] = { -- 鞋子
	    	slotName = "Shoes",
	    	cardNode = nil,
	    	posIndex = 5, -- 位置编号
	    },
	    [ResourcetypeSub.eNecklace] = { -- "饰品
	    	slotName = "Necklace",
	    	cardNode = nil,
	    	posIndex = 6, -- 位置编号
	    },
	}
	if not self.onlyShowEquip then
		self.mCardInfo[ResourcetypeSub.eBook] = { -- "神兵"
	    	slotName = "Book",
	    	cardNode = nil,
	    	posIndex = 7, -- 位置编号
	    	redDotId = ModuleSub.eTreasureStepUp,
	    }
		self.mCardInfo[ResourcetypeSub.ePet] = {  -- "秘籍"
    		slotName = "Pet",
    		cardNode = nil,
    		posIndex = 8, -- 位置编号
    		redDotId = ModuleSub.ePetActiveTal, 
    	}
	end

	-- 创建页面控件
	self:initUI()
	-- 刷新页面显示
	self:refresh()
	-- 注册加号刷新事件
	Notification:registerAutoObserver(self.mCardInfo[ResourcetypeSub.eClothes].cardNode, function ()
    		-- 不是自己则忽略
    		if not self.mIsMyself then
    			return
    		end

    		-- 当前卡槽未上阵人物则忽略
    		local slotInfo = self.mFormationObj:getSlotInfoBySlotId(self.mShowSlotId)
    		if not Utility.isEntityId(slotInfo and slotInfo.HeroId) then
    			return
    		end

    		-- 遍历寻找空卡槽，判断是否有可用装备
    		for key, item in pairs(self.mCardInfo) do
				local tempCard = item.cardNode
				local tempData = slotInfo[item.slotName]
				if not tempData or not Utility.isEntityId(type(tempData) == "table" and tempData.Id or tempData) then
					-- 判断是否有可用的装备
					local prefEquip = SlotPrefObj:havePreferableEquip(self.mShowSlotId)
					if (prefEquip and prefEquip[key]) then
						tempCard:showGlitterAddMark("c_144.png", 1.2)
					end
				end
				
			end
    	end, EventsName.eSlotEquipNodeAddFlagVisible)
end

-- 创建页面控件
function SlotEquipView:initUI()
	local radius = 270 -- 卡牌距离控件中心的距离
	local squareSpace = 125 -- 方形排列时每行之间的距离
	--local cardCount = table.nums(self.mCardInfo)
	local cardCount = 8
	local startPosY = (math.ceil(cardCount / 2) * squareSpace + self.mViewSize.height) / 2
	for key, item in pairs(self.mCardInfo) do
		local tempPosX = (math.mod(item.posIndex, 2) == 1) and 70 or (self.mViewSize.width - 70)
		local tempIndex = math.ceil(item.posIndex / 2)
		local tempPosY = startPosY - (tempIndex - 1) * squareSpace - squareSpace / 2

		-- 头像
		local tempCard = CardNode:create({
			cardShape = Enums.CardShape.eSquare,
	        allowClick = true,
	        onClickCallback = function()
	        	if self.onClickItem then
	        		self.onClickItem(key)
	        	end
	        	if self.mNeedSelect then
	        		self.mSelectType = key
	        		self:refresh()
	        	end
	        end,
		})
		tempCard:setPosition(tempPosX, tempPosY)
		self:addChild(tempCard)
		item.cardNode = tempCard
	end
end

-- 刷新页面显示
function SlotEquipView:refresh()
	local slotInfo = self.mFormationObj:getSlotInfoBySlotId(self.mShowSlotId)
	for key, item in pairs(self.mCardInfo) do
		local tempCard = item.cardNode

		local showAttrs = {}
		if self.mSelectType == key then
			table.insert(showAttrs, CardShowAttr.eSelected)
		end
		local tempSize = tempCard:getContentSize()

		-- 如果该卡槽上没有人物，则所有的装备卡槽都是锁住状态()
		if not Utility.isEntityId(slotInfo and slotInfo.HeroId) then
			-- 显示空的卡槽
			tempCard:setEmptyEquip(showAttrs, key)
			
			-- 显示锁定图片
			local tempSprite = ui.newSprite("c_35.png")
			tempSprite:setPosition(tempSize.width / 2, tempSize.height / 2)
			tempCard:addChild(tempSprite)
		else
			-- 判断是否有可用的装备
			local havePref = false
			if self.mIsMyself then
				local prefEquip = SlotPrefObj:havePreferableEquip(self.mShowSlotId)
				havePref = (prefEquip and prefEquip[key]) and true or false
			end

			-- 读取当前卡槽的装备信息
			local tempData = slotInfo[item.slotName]
			if not tempData or not Utility.isEntityId(type(tempData) == "table" and tempData.Id or tempData) then
				tempCard:setEmptyEquip(showAttrs, key)
				tempCard:setCardName(ResourcetypeSubName[key], 1)

				-- 如果有装备可以上阵
				if havePref then
					tempCard:showGlitterAddMark("c_144.png", 1.2)
				end
			else
				table.insert(showAttrs, CardShowAttr.eBorder)
				table.insert(showAttrs, CardShowAttr.eLevel)
				table.insert(showAttrs, CardShowAttr.eStep)
				table.insert(showAttrs, CardShowAttr.eName)

				if Utility.isEquip(key) then  -- 装备
					local tempEquip = self.mIsMyself and EquipObj:getEquip(tempData.Id) or tempData
					tempCard:setEquipment(tempEquip, showAttrs)
					tempCard:showEquipStar(tempEquip)
				elseif Utility.isTreasure(key) then -- 神兵
					local tempTreasure = self.mIsMyself and TreasureObj:getTreasure(tempData.Id) or tempData
					tempCard:setTreasure(tempTreasure, showAttrs)
            	elseif Utility.isPet(key) then -- 秘籍
            		local tempPet = self.mIsMyself and PetObj:getPet(tempData) or tempData
            		tempCard:setPet(tempPet, showAttrs)
				end
			end
		end
		-- 神兵和外功添加特殊边框
		if (key == ResourcetypeSub.eBook) or (key == ResourcetypeSub.ePet) then
			tempCard:setTreasureBorder()

			-- 自己的阵容信息，神兵和外功上的小红点
			if item.redDotId and self.mIsMyself then
				local redDotModuleId = item.redDotId
				local function dealRedDotVisible(redDotSprite)
					redDotSprite:setVisible(RedDotInfoObj:isValid(redDotModuleId, nil, self.mShowSlotId))
				end
				local events = RedDotInfoObj:getEvents(redDotModuleId)
				table.insert(events, EventsName.eSlotRedDotPrefix .. tostring(self.mShowSlotId)) -- 卡槽信息变化
    			ui.createAutoBubble({parent = tempCard, eventName = events, refreshFunc = dealRedDotVisible})
			end
		end

        -- 添加宝石显示
        if tempCard.imprint and not tolua.isnull(tempCard.imprint) then
            tempCard.imprint:removeFromParent()
            tempCard.imprint = nil
        end
        local imprintInfo = self.mFormationObj:getSlotImprint(self.mShowSlotId, key)
        if imprintInfo and next(imprintInfo) then
            local imprintModel = ImprintModel.items[imprintInfo.ModelId]
            tempCard.imprint = ui.newSprite(imprintModel.pic..".png")
            tempCard.imprint:setScale(0.5)
            tempCard.imprint:setPosition(85, 85)
            tempCard:addChild(tempCard.imprint, 1)
        end
	end
end

-- 显示的阵容卡槽改变
--[[
-- 参数
    showSlotId: 当前显示的阵容卡槽Id
]]
function SlotEquipView:changeShowSlot(showSlotId)
	self.mShowSlotId = showSlotId or self.mShowSlotId
	self:refresh()
end

-- 根据装备id获取属性发生改变的装备列表
function SlotEquipView:getChangeEquipList(idList)
	local ret = {}

	for _, id in ipairs(idList) do
		local equipInfo = EquipObj:getEquip(id)

		if equipInfo then
			local tempModel = EquipModel.items[equipInfo.ModelId]
			for key, item in pairs(self.mCardInfo) do
				if tempModel.typeID == key then
					table.insert(ret, item.cardNode)
					break
				end
			end
		end
	end

	return ret
end

-- 查找第一个可以锻造的装备
function SlotEquipView:findItemCanStepUp(slotIndex)
	local maxStep = table.maxn(EquipStepRelation.items)
	local function isItemCanStepUp(item)
		if (item == nil) or (item.Id == nil) then
			return false
		end

		-- 判断品质
		local equipBase = EquipModel.items[item.ModelId]
		if (equipBase == nil) or (equipBase.valueLv < 3) then
			return false
		end

		-- 判断是否满级
		local currStep = item.Step or 0
		if (currStep >= maxStep) then
			return false
		end

		-- 判断需求等级
		local currLv = item.Lv or 0
		local stepConfig = EquipStepRelation.items[currStep]
		if (currLv < stepConfig.needUpLv) then
			return false
		end

		return true
	end
	
	-- 查找当前卡槽的所有装备
	local slotInfo = self.mFormationObj:getSlotInfoBySlotId(slotIndex)
	local tempList = {}
	for _,v in pairs(self.mCardInfo) do
		table.insert(tempList, v)
	end
	table.sort(tempList, function (a, b)
			return a.posIndex < b.posIndex
		end)
	for key, item in ipairs(tempList) do
		if (isItemCanStepUp(slotInfo[item.slotName]) == true) then
			return item.cardNode:getPosition()
		end
	end
	return nil
end

-- 播放升级特效和音效
-- type: 装备类型
function SlotEquipView:palyLevelUpEffectAudio(type)
	local typeNode = self.mCardInfo[type].cardNode
	if typeNode then
    	-- 播放升级成功的特效
    	MqAudio.playEffect("zhuangbei_qianghua.mp3")
    	ui.newEffect({
    		parent = typeNode,
    	    effectName = "effect_ui_zhuangbeiqianghua",
    	    position = cc.p(48, 48),
    	    loop = false,
    	    endRelease = true,
    	})
    end
end

-- 检查是否已上阵神兵
function SlotEquipView:isTreasureEquiped()
	local slotInfo = self.mFormationObj:getSlotInfoBySlotId(self.mShowSlotId)
	if not Utility.isEntityId(slotInfo and slotInfo.HeroId) then
		return false
	end

	local tempData = slotInfo["Book"]
	if not tempData or not Utility.isEntityId(type(tempData) == "table" and tempData.Id or tempData) then
		return false
	end

	return true
end

return SlotEquipView
