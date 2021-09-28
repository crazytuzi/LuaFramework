--[[
	文件名:TeamZhenjueExtraLayer.lua
	描述：阵容的内功心法洗炼页面
	创建人: peiyaoqiang
	创建时间: 2017.04.05
--]]

local TeamZhenjueExtraLayer = class("TeamZhenjueExtraLayer", function(params)
    return display.newLayer()
end)

--[[
-- 参数 params 中各项为：
	{
		showIndex: 当前显示的人物卡槽Id
		showZhenjueIndex: 当前显示的内功心法所在的Index

		extraData: 内功心法洗炼页面信息，主要用于恢复页面使用，一般不用手动传入改参数
	}
]]
function TeamZhenjueExtraLayer:ctor(params)
	self.mShowIndex = params and params.showIndex or 1 -- 默认显示卡槽的index
	self.mShowZhenjueIndex = params and params.showZhenjueIndex  or 1  -- 默认为第一个内功心法卡槽
	self.mExtraData = params and params.extraData -- 内功心法洗炼页面信息，
	-- 上阵卡槽数，包含江湖后援团入口
	self.mSlotMaxCount = FormationObj:getMaxSlotCount()

	-- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer) 
	-- 初始化页面控件
	self:initUI()

	-- 创建底部导航和顶部玩家信息部分
	local tempLayer = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
    })
    self:addChild(tempLayer)

    -- 当选中的卡槽改变后的处理逻辑
	self:dealSelectChange()
end

-- 初始化页面控件
function TeamZhenjueExtraLayer:initUI()
	-- 背景图片
	local bgSprite = ui.newSprite("ng_17.jpg")
	bgSprite:setPosition(320, 568)
	self.mParentLayer:addChild(bgSprite)

	-- 创建内功心法的大图片展示
	self.mFigureNode = Figure.newZhenjue({
		needAction = true,
        viewSize = cc.size(640, 400)
	})
	self.mFigureNode:setAnchorPoint(cc.p(0.5, 1))
	self.mFigureNode:setPosition(320, 1020)
	self.mParentLayer:addChild(self.mFigureNode)

	-- 页面顶部的人物头像列表
    self.mSmallHeadView = require("team.teamSubView.TeamHeadView"):create({
        needPet = false, -- 是否需要外功秘籍按钮，默认为true
        needMate = false, -- 不需要江湖后援团
        showSlotId = self.mShowIndex,
        formationObj = FormationObj,
        viewSize = cc.size(620, 106),
        bgImgName = "c_01.png",
        onClickItem = function(slotIndex)
        	-- 该卡槽未开启，则需要提示用户去点星
        	if not FormationObj:slotIsOpen(slotIndex) then
        		MsgBoxLayer.gotoLightenStarHintLayer(slotIndex, false, FormationObj)
        		return
        	end
        	self.mShowIndex = slotIndex

        	-- 当选中的卡槽改变后的处理逻辑
			self:dealSelectChange()

        	-- 如果是阵容卡槽并且未上阵人物，则需要打开选择人物页面
        	if FormationObj:slotIsEmpty(slotIndex) then
        		LayerManager.addLayer({name = "team.TeamSelectHeroLayer", 
        			data = {
        				slotId = slotIndex,
        				alwaysIdList = {},
        			}
        		})
        	end
        end
    })
    self.mSmallHeadView:setPosition(320, 1136)
    self.mParentLayer:addChild(self.mSmallHeadView)

    -- 创建内功心法卡牌展示
	self.mZhenjueView = require("team.teamSubView.SlotZhenjueView"):create({
    	viewSize = cc.size(640, 400),
    	spaceY = 124,
        showSlotId = self.mShowIndex,
        zhenjueSlotIndex = self.mShowZhenjueIndex,
        formationObj = FormationObj,
		onClickItem = function(zhenjueSlotIndex)
			-- 判断改卡槽是否已经开启
			if not FormationObj:slotZhenjueIsOpen(self.mShowIndex, zhenjueSlotIndex) then
				local tempStr = nil
				if zhenjueSlotIndex > 4 then
					tempStr = TR("传说侠客才能开启该卡槽")
				elseif zhenjueSlotIndex > 3 then
					tempStr = TR("神话侠客才能开启该卡槽")
				else
					tempStr = TR("宗师侠客才能开启该卡槽")
				end
				ui.showFlashView(tempStr)
				return 
			end
			
			self.mShowZhenjueIndex = zhenjueSlotIndex
			self:dealSelectChange()
			-- 如果该卡槽上没有内功心法，则调用内功心法选择页面
			if FormationObj:slotZhenjueIsEmpty(self.mShowIndex, self.mShowZhenjueIndex) then
				local tempData = {
					slotId = self.mShowIndex,
	        		zhenjueSlotId = self.mShowZhenjueIndex,
	        		alwaysIdList = {},
				}
				LayerManager.addLayer({name = "team.TeamSelectZhenjueLayer", data = tempData})
			end
		end,
	})
	self.mZhenjueView:setAnchorPoint(cc.p(0.5, 1))
	self.mZhenjueView:setPosition(320, 1040)
	self.mParentLayer:addChild(self.mZhenjueView)

	Notification:registerAutoObserver(self.mZhenjueView, function()
		self:dealSelectChange()
	end, "eZhenjueExtraTempUpAttrDataChange")

	-- 创建洗炼模块
	self.mExtraView = require("zhenjue.ZhenjueExtraView"):create(self.mExtraData or {})
	self.mExtraView:setAnchorPoint(cc.p(0.5, 0))
	self.mExtraView:setPosition(320, 85)
	self.mParentLayer:addChild(self.mExtraView)

	-- 关闭按钮
	self.mCloseBtn = ui.newButton({
		normalImage = "c_29.png",
		clickAction = function()
			LayerManager.removeLayer(self)
		end
	})
	self.mCloseBtn:setPosition(470, 980)
	self.mParentLayer:addChild(self.mCloseBtn)
end

-- 获取恢复该页面的参数
function TeamZhenjueExtraLayer:getRestoreData()
	local retData = {}
	retData.showIndex = self.mShowIndex
	retData.showZhenjueIndex = self.mShowZhenjueIndex
	retData.extraData = self.mExtraView.getRestoreData and self.mExtraView:getRestoreData()

	return retData
end

-- 当选中的卡槽改变后的处理逻辑
function TeamZhenjueExtraLayer:dealSelectChange()
	-- 内功心法实体对象
	local zhenjueItem = FormationObj:getSlotZhenjue(self.mShowIndex, self.mShowZhenjueIndex)

	if self.mZhenjueView then
		self.mZhenjueView:changeShowSlot(self.mShowIndex)
	end

	if self.mSmallHeadView then
		self.mSmallHeadView:changeShowSlot(self.mShowIndex)
	end

	if self.mExtraView then	
		self.mExtraView:changeZhenjue(zhenjueItem)
	end

	if self.mFigureNode then
		self.mFigureNode:changeZhenjue(zhenjueItem and zhenjueItem.ModelId)
	end
end

return TeamZhenjueExtraLayer