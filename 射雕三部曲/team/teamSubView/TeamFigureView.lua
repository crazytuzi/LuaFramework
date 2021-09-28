--[[
	文件名:TeamFigureView.lua
	描述：队伍人物形象列表（该页面没有做适配处理，需要创建者考虑适配问题）
	创建人: peiyaoqiang
	创建时间: 2017.03.08
--]]

local TeamFigureView = class("TeamFigureView", function(params)
    return display.newLayer()
end)

--[[
-- 参数 params中的每项为：
    {
    	viewSize: 显示大小
        showSlotId: 当前显示的阵容卡槽Id
        viewEmptySlot: 是否可以显示空卡槽， 默认为true
        formationObj: 阵容数据缓存对象
    	figureScale: 人物形象需要缩放的比例，相对于设计尺寸（1）的缩放比例，不是屏幕分辨率适配的缩放比例

		onSelectChange = nil, -- 当选中卡槽改变的回调函数
		onClickItem = nil, -- 点击卡槽的回调函数
    }
--]]
function TeamFigureView:ctor(params)
	params = params or {}
	-- 显示大小
	self.mViewSize = params.viewSize or cc.size(640, 550)
	-- 当前选中的Index
	self.mShowSlotId = params.showSlotId or 1
	-- 是否可以显示空卡槽
	self.mViewEmptySlot = params.viewEmptySlot ~= false
	-- 阵容数据对象
    self.mFormationObj = params.formationObj
    -- 是否是玩家自己的阵容信息
    self.mIsMyself = self.mFormationObj:isMyself()
	-- 人物形象需要缩放的比例
	self.mFigureScale = params.figureScale or 1
	-- 当选中卡槽改变的回调函数
	self.onSelectChange = params.onSelectChange
	-- 点击卡槽的回调函数
	self.onClickItem = params.onClickItem

	-- 卡槽Id与列表index对照表 ［index］= slotId
	self.mSlotIdMap = {}

	self:setContentSize(self.mViewSize)
	self:setAnchorPoint(cc.p(0.5, 0.5))
	self:setIgnoreAnchorPointForPosition(false)

    -- 注册退出事件
    self:registerScriptHandler(function(eventType)
        if eventType == "exit" then
            -- 界面关闭时，关闭未播放完的音效
            if self.mCurrSoundId then
                MqAudio.stopEffect(self.mCurrSoundId)
            end
        end
    end)

	-- 创建页面控件
	self:initUI()
end

-- 创建页面控件
function TeamFigureView:initUI()
	self:refreshSlotIdMap()

	self.mSliderView = ui.newSliderTableView({
        width = self.mViewSize.width,
        height = self.mViewSize.height,
        isVertical = false,
        selItemOnMiddle = true,
        selectIndex = self:getSlotIdIndex(self.mShowSlotId) - 1,
        itemCountOfSlider = function(sliderView)
        	return #self.mSlotIdMap
        end,
        itemSizeOfSlider = function(sliderView)
            return self.mViewSize.width, self.mViewSize.height
        end,
        sliderItemAtIndex = function(sliderView, itemNode, index)
        	local slotId = self.mSlotIdMap[index + 1]
        	local tempSlot = self.mFormationObj:getSlotInfoBySlotId(slotId)
        	if Utility.isEntityId(tempSlot.HeroId) then -- 该卡槽已上阵
        		local heroData = self.mIsMyself and HeroObj:getHero(tempSlot.HeroId) or tempSlot.Hero
                local tmpFashionId = self.mIsMyself and PlayerAttrObj:getPlayerAttrByName("FashionModelId") or self.mFormationObj:getThisPlayerInfo().FashionModelId
        		local rebornId = nil
        		if heroData and heroData.RebornId and (heroData.RebornId % 1000) > 0 then
        			rebornId = heroData.RebornId
        		end
        		Figure.newHero({
	            	parent = itemNode,
	            	heroModelID = tempSlot.ModelId,
                    fashionModelID = tmpFashionId,
                    IllusionModelId = heroData.IllusionModelId,
                    heroFashionId = heroData.CombatFashionOrder,
	        		position = cc.p(self.mViewSize.width / 2, 80),
	        		scale = self.mFigureScale,
	        		rebornId = rebornId,
	        		async = function (figureNode)
	        		end,
	        		needRace = true,
	        		buttonAction = function()
	        			if self.onClickItem then
	        				self.onClickItem(slotId)
	        			end
	        		end
	        	})
        	else -- 该卡槽未上阵
        		if self.onClickItem and self.mIsMyself then
        			local tempBtn = ui.newButton({
	        			normalImage = "c_36.png",
	        			titleImage = "sy_20.png",
	        			clickAction = function()
	        				self.onClickItem(slotId)
	        			end
	        		})
	        		tempBtn:setAnchorPoint(cc.p(0.5, 0))
	        		tempBtn:setPosition(self.mViewSize.width / 2, 0)
	        		itemNode:addChild(tempBtn)

	        		local move1 = cc.ScaleTo:create(1, 1.2)
	        		local move2 = cc.ScaleTo:create(1, 1)
	        		tempBtn.titleSprite:runAction(cc.RepeatForever:create(cc.Sequence:create(move1, move2)))
        		else

        		end
        	end
        end,
        selectItemChanged = function(sliderView, selectIndex)
        	local slotId = self.mSlotIdMap[selectIndex + 1]
        	local oldShowSlotId = self.mShowSlotId
        	self.mShowSlotId = slotId
        	if oldShowSlotId ~= self.mShowSlotId and self.onSelectChange then
        		self.onSelectChange(slotId)

                -- 播放人物音效
                self:playSlotHeroAudio(slotId)
        	end
        end
    })

    self.mSliderView:setTouchEnabled(true)

    self.mSliderView:setAnchorPoint(cc.p(0.5, 0.5))
    self.mSliderView:setPosition(self.mViewSize.width / 2, self.mViewSize.height / 2)
    self:addChild(self.mSliderView)

    -- 播放初始人物音效
    self:playSlotHeroAudio(self.mShowSlotId)
end

-- 刷新列表Id与卡槽Id的对照表
function TeamFigureView:refreshSlotIdMap()
	self.mSlotIdMap = {}

	local slotInfos = self.mFormationObj:getSlotInfos()
	for index, slotItem in ipairs(slotInfos) do
		if self.mViewEmptySlot or Utility.isEntityId(slotItem.HeroId) then
			table.insert(self.mSlotIdMap, index)
		end
	end
end

-- 获取 slotId 对应的index
function TeamFigureView:getSlotIdIndex(slotId)
	local ret = 1
	for index, Id in pairs(self.mSlotIdMap) do
		if Id == slotId then
			ret = index
		end
	end
	return ret
end

-- 显示的阵容卡槽改变
--[[
-- 参数
	showSlotId: 当前显示的阵容卡槽Id
]]
function TeamFigureView:changeShowSlot(showSlotId)
	if self.mShowSlotId == showSlotId then
		return
	end
	self.mShowSlotId = showSlotId
	local tempIndex = self:getSlotIdIndex(self.mShowSlotId)
	self.mSliderView:setSelectItemIndex(tempIndex - 1)

    -- 播放人物音效
    self:playSlotHeroAudio(showSlotId)
end

-- 刷新阵容卡槽
--[[
-- 参数
    showSlotId: 当前显示的阵容卡槽Id
]]
function TeamFigureView:refreshShowSlot(showSlotId)
    local tempIndex = self:getSlotIdIndex(self.mShowSlotId)
    self.mSliderView:refreshItem(tempIndex - 1)
end

-- 播放对应slot人物的音效
function TeamFigureView:playSlotHeroAudio(slot)
    if slot then
        local tempSlot = self.mFormationObj:getSlotInfoBySlotId(slot)
        if Utility.isEntityId(tempSlot.HeroId) then
            if self.mCurrSoundId then
                MqAudio.stopEffect(self.mCurrSoundId)
                self.mCurrSoundId = nil
            end

            local heroModel = HeroModel.items[tempSlot.ModelId]
            local _, staySound = Utility.getHeroSound(heroModel)
            local audioFile = Utility.randomStayAudio(staySound)
            
            -- 时装音效
            local fashionModelID = self.mIsMyself and PlayerAttrObj:getPlayerAttrByName("FashionModelId") or self.mFormationObj:getThisPlayerInfo().FashionModelId
            if (heroModel.specialType == Enums.HeroType.eMainHero) and (fashionModelID ~= nil) and (fashionModelID > 0) then
                local _, staySound = Utility.getHeroSound(fashionModelID)
                audioFile = Utility.randomStayAudio(staySound)
            end

            -- 幻化音效
            local heroData = self.mIsMyself and HeroObj:getHero(tempSlot.HeroId) or tempSlot.Hero
            if (heroData.IllusionModelId ~= nil) and (heroData.IllusionModelId > 0) then
                 local _, staySound = Utility.getHeroSound(heroData.IllusionModelId)
                audioFile = Utility.randomStayAudio(staySound)
            end

            self.mCurrSoundId = MqAudio.playEffect(audioFile)
        end
    end
end

-- 重新加载列表数据
function TeamFigureView:reloadData()
	self:refreshSlotIdMap()
	self.mSliderView:reloadData()
end

return TeamFigureView
