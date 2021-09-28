--[[
	文件名:SlotZhenyuanView.lua
	描述：队伍卡槽真元展示页面（该页面没有做适配处理，需要创建者考虑适配问题）
	创建人：peiyaoqiang
	创建时间：2017.12.13
--]]

local SlotZhenyuanView = class("SlotZhenyuanView", function(params)
    return display.newLayer()
end)

--[[
-- 参数 params中的每项为：
    {
    	viewSize: 显示大小
    	showSlotId: 当前显示的阵容卡槽Id
    	formationObj: 阵容数据缓存对象
		onClickItem = nil, -- 点击装备卡牌的回调 onItemClick(ResourcetypeSub)
    }
--]]
function SlotZhenyuanView:ctor(params)
	package.loaded["team.teamSubView.SlotZhenyuanView"] = nil
	self.mViewSize = params.viewSize or cc.size(640, 550)
	-- 当前显示的阵容卡槽Id
    self.mShowSlotId = params.showSlotId or 1
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
		[1] = { 
			cardNode = nil, 	-- 该类型对应的CardNode对象
			posIndex = 1, 		-- 位置编号
		},    
	    [2] = { 
	    	cardNode = nil,
	    	posIndex = 2,
	    },    
	    [3] = { 
	    	cardNode = nil,
	    	posIndex = 3,
	    },    
	    [5] = { 
	    	cardNode = nil,
	    	posIndex = 4,
	    },   
	    [6] = { 
	    	cardNode = nil,
	    	posIndex = 5,
	    },
	    [7] = { 
	    	cardNode = nil,
	    	posIndex = 6,
	    },
	    [4] = { 
	    	cardNode = nil,
	    	posIndex = 7,
	    },
	}
	
	-- 创建页面控件
	self:initUI()
	-- 刷新页面显示
	self:refresh()
end

-- 创建页面控件
function SlotZhenyuanView:initUI()
	local radius = 270 -- 卡牌距离控件中心的距离
	local squareSpace = 135 -- 方形排列时每行之间的距离
	local cardCount = 6
	local startPosY = (math.ceil(cardCount / 2) * squareSpace + self.mViewSize.height) / 2
	for key, item in pairs(self.mCardInfo) do
		local tempPosX = (math.mod(item.posIndex, 2) == 1) and 70 or (self.mViewSize.width - 70)
		local tempIndex = math.ceil(item.posIndex / 2)
		local tempPosY = startPosY - (tempIndex - 1) * squareSpace - squareSpace / 2

		if item.posIndex == 7 then --天命真元
			tempPosX = self.mViewSize.width / 2
			tempPosY = startPosY - 2.5 * squareSpace

			local headBg = ui.newSprite("zy_21.png")
		    headBg:setPosition(tempPosX, tempPosY)
		    self:addChild(headBg)
		    -- 最上面有一张透明图片
		    local blankSprite = ui.newSprite("zy_22.png")
		    blankSprite:setPosition(tempPosX, tempPosY+5)
		    self:addChild(blankSprite, 1)	

		    -- 后面card的位置需要根据背景框微调
		    tempPosX = self.mViewSize.width / 2 + 2
			tempPosY = startPosY - 2.5 * squareSpace + 9		
		end
		-- 头像
		local tempCard = CardNode:create({
			cardShape = Enums.CardShape.eCircle,
	        allowClick = true,
	        onClickCallback = function()
	        	if self.onClickItem then
	        		self.onClickItem(key, item.posIndex)
	        	end
	        end,
		})
		tempCard:setPosition(tempPosX, tempPosY)
		self:addChild(tempCard)
		item.cardNode = tempCard
	end
end

-- 刷新页面显示
function SlotZhenyuanView:refresh()
	local slotInfo = self.mFormationObj:getSlotInfoBySlotId(self.mShowSlotId)
	local zhenyuanList = {}
	if slotInfo and slotInfo.ZhenYuan then
		zhenyuanList = slotInfo.ZhenYuan
	end
	for index, item in pairs(self.mCardInfo) do
		local tempCard = item.cardNode
		local tempSize = tempCard:getContentSize()
		if not ConfigFunc:getZhenyuanGridIsOpen(slotInfo.HeroId, index) then
			tempCard:setEmpty({}, "zy_12.png", "c_35.png")

			if not self.mFormationObj:slotIsEmpty(self.mShowSlotId) then
				-- 显示开启条件
				local needQuenchNum = ConfigFunc:getZhenyuanGridOpenConfig(index)
				local introStr = Utility.getQuenchName(needQuenchNum) .. "\n" .. TR("开启")
				-- if item.posIndex > 6 then 
				-- 	introStr = TR("开启三个\n真元卡槽")
				-- end 
				local tempLabel = ui.newLabel({
					text = introStr, --Utility.getQuenchName(needQuenchNum) .. "\n" .. TR("开启"),
					size = 18,
	                outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
	                outlineSize = 2,
					align = cc.TEXT_ALIGNMENT_CENTER,
	        		valign = cc.VERTICAL_TEXT_ALIGNMENT_CENTER,
					dimensions = cc.size(tempSize.width - 10, 0)
				})
				tempLabel:setAnchorPoint(cc.p(0.5, 0.5))
				tempLabel:setPosition(tempSize.width * 0.5, tempSize.height * 0.46)
				tempCard:addChild(tempLabel)
			end
		else
			local zhenyuanInfo = zhenyuanList[item.posIndex]
			if not zhenyuanInfo or not Utility.isEntityId(zhenyuanInfo.Id) then
				tempCard:setEmpty({}, "zy_12.png", "c_22.png")
			else
				local tempZhenyuan = self.mIsMyself and ZhenyuanObj:getZhenyuan(zhenyuanInfo.Id) or zhenyuanInfo
				tempCard:setZhenyuan(tempZhenyuan, {CardShowAttr.eBorder, CardShowAttr.eName, CardShowAttr.eLevel})

				if index > 6 then 
					tempCard.mShowAttrControl[CardShowAttr.eName].label:setPositionY(-10)
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
function SlotZhenyuanView:changeShowSlot(showSlotId)
	self.mShowSlotId = showSlotId or self.mShowSlotId
	self:refresh()
end

return SlotZhenyuanView
