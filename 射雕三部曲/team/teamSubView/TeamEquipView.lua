--[[
	文件名:TeamEquipView.lua
	描述：队伍装备形象列表（该页面没有做适配处理，需要创建者考虑适配问题）
	创建人: peiyaoqiang
	创建时间: 2017.08.03
--]]

local TeamEquipView = class("TeamEquipView", function(params)
    return display.newLayer()
end)

--[[
-- 参数 params中的每项为：
    {
    	showSlotId: 当前显示的阵容卡槽Id
        showEquipType: 当前显示的装备类型

		onSelectChange = nil, -- 当选中卡槽改变的回调函数
		onClickItem = nil, -- 点击卡槽的回调函数
    }
--]]
function TeamEquipView:ctor(params)
	params = params or {}
	-- 当前选中的Index
	self.mShowSlotId = params.showSlotId or 1
	-- 当前选中的装备类型
	self.mShowEquipType = params.showEquipType or ResourcetypeSub.eClothes
	-- 当选中卡槽改变的回调函数
	self.onSelectChange = params.onSelectChange
	-- 点击卡槽的回调函数
	self.onClickItem = params.onClickItem

	-- 卡槽Id与列表index对照表 ［index］= slotId
	self.mSlotIdMap = {}

	-- 处理界面
	self.mViewSize = cc.size(640, 400)
	self:setContentSize(self.mViewSize)
	self:setAnchorPoint(cc.p(0.5, 0.5))
	self:setIgnoreAnchorPointForPosition(false)
    
	-- 创建页面控件
	self:initUI()
end

-- 创建页面控件
function TeamEquipView:initUI()
	self:refreshSlotIdMap()

	-- 创建拖动列表
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
        	local pos = cc.p(self.mViewSize.width * 0.5, self.mViewSize.height * 0.5)
        	local function addCustomButton(image, titleImg, scale)
        		local tempBtn = ui.newButton({
        			normalImage = image,
        			titleImage = titleImg,
        			scale = scale or 1,
        			clickAction = function ()
        				self.onClickItem(slotId, self.mShowEquipType)
        			end
        		})
        		tempBtn:setAnchorPoint(cc.p(0.5, 0.5))
        		tempBtn:setPosition(pos)
        		itemNode:addChild(tempBtn)

        		-- 上下浮动的效果
        		local moveAction1 = cc.MoveTo:create(1.3, cc.p(pos.x, pos.y + 20))
			    local moveAction2 = cc.MoveTo:create(1.3, cc.p(pos.x, pos.y + 10))
			    local moveAction3 = cc.MoveTo:create(1.3, cc.p(pos.x, pos.y))
			    tempBtn:runAction(cc.RepeatForever:create(cc.Sequence:create(
			        cc.EaseSineIn:create(moveAction2),
			        cc.EaseSineOut:create(moveAction1),
			        cc.EaseSineIn:create(moveAction2),
			        cc.EaseSineOut:create(moveAction3)
			    )))
			    return tempBtn
        	end
        	
        	if FormationObj:slotIsEmpty(slotId) then
        		-- 该卡槽未上阵侠客
        		addCustomButton("c_36.png", "sy_20.png", 0.5)
        	else
        		local tempEquip = FormationObj:getSlotEquip(slotId, self.mShowEquipType)
        		if (not tempEquip) or (not Utility.isEntityId(tempEquip.Id)) then
					-- 装备未上阵
					local grayImgList = {
						[ResourcetypeSub.eClothes] = "zr_32.png", [ResourcetypeSub.eHelmet] = "zr_31.png", [ResourcetypeSub.ePants] = "zr_34.png",
						[ResourcetypeSub.eWeapon] = "zr_30.png", [ResourcetypeSub.eShoe] = "zr_35.png", [ResourcetypeSub.eNecklace] = "zr_33.png",
					}
	        		addCustomButton(grayImgList[self.mShowEquipType], "zr_29.png")
				else
					-- 装备已上阵
					local figureNode = Figure.newEquip({
						modelId = tempEquip.modelId,
						needAction = true,
						viewSize = self.mViewSize,
						clickCallback = function ()
							self.onClickItem(slotId, self.mShowEquipType)
						end,
					})
					figureNode:setAnchorPoint(cc.p(0.5, 0.5))
					figureNode:setPosition(pos)
					itemNode:addChild(figureNode)
				end
        	end
        end,
        selectItemChanged = function(sliderView, selectIndex)
        	local slotId = self.mSlotIdMap[selectIndex + 1]
        	local oldShowSlotId = self.mShowSlotId
        	self.mShowSlotId = slotId
        	if oldShowSlotId ~= self.mShowSlotId and self.onSelectChange then
        		self.onSelectChange(slotId)
        	end
        end
    })
    self.mSliderView:setTouchEnabled(true)
    self.mSliderView:setAnchorPoint(cc.p(0.5, 0.5))
    self.mSliderView:setPosition(self.mViewSize.width / 2, self.mViewSize.height / 2)
    self:addChild(self.mSliderView)
end

-- 刷新列表Id与卡槽Id的对照表
function TeamEquipView:refreshSlotIdMap()
	self.mSlotIdMap = {}
	for i=1,6 do
		if FormationObj:slotIsOpen(i) then
			table.insert(self.mSlotIdMap, i)
		end
	end
end

-- 获取 slotId 对应的index
function TeamEquipView:getSlotIdIndex(slotId)
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
	showEquipType: 当前显示的装备类型
]]
function TeamEquipView:changeShowSlot(showSlotId, showEquipType)
	if (self.mShowSlotId == showSlotId) and (self.mShowEquipType == showEquipType) then
		return
	end
	self.mShowSlotId = showSlotId
	self.mShowEquipType = showEquipType

	local tempIndex = self:getSlotIdIndex(self.mShowSlotId)
	self.mSliderView:reloadData()
	self.mSliderView:setSelectItemIndex(tempIndex - 1)
end

-- 重新加载列表数据
function TeamEquipView:reloadData()
	self:refreshSlotIdMap()
	self.mSliderView:reloadData()
end

return TeamEquipView
