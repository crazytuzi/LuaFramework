--[[
    文件名: JianghuKillJobBoxLayer.lua
    描述: 江湖杀职业等级预览界面
    创建人: yanghongsheng
    创建时间: 2018.09.06
-- ]]
local JianghuKillJobBoxLayer = class("JianghuKillJobBoxLayer", function(params)
	return display.newLayer()
end)

--[[
	params:
		jobId 		-- 职业id
		jobLv 		-- 职业等级
]]
function JianghuKillJobBoxLayer:ctor(params)
	self.mJobId = params.jobId
	self.mJobLv = params.jobLv

	self.JobLvList = table.keys(JianghukillOccupationalprope.items[self.mJobId])
	table.sort(self.JobLvList, function (lv1, lv2)
		return lv1 < lv2
	end)
	self.curLvIndex = table.indexof(self.JobLvList, self.mJobLv) or 1
	-- 弹窗
    local parentLayer = require("commonLayer.PopBgLayer").new({
    	bgSize = cc.size(580, 320),
    	title = TR("职业效果"),
    })
    self:addChild(parentLayer)

    -- 保存弹框控件信息
    self.mBgSprite = parentLayer.mBgSprite
    self.mBgSize = self.mBgSprite:getContentSize()

	self:initUI()
end

function JianghuKillJobBoxLayer:initUI()
	-- 黑背景
	local blackSize = cc.size(500, 210)
	local blackBg = ui.newScale9Sprite("c_17.png", blackSize)
	blackBg:setAnchorPoint(cc.p(0.5, 1))
	blackBg:setPosition(self.mBgSize.width*0.5, self.mBgSize.height-70)
	self.mBgSprite:addChild(blackBg)

	-- 左箭头
	local leftSprite = ui.newSprite("c_26.png")
	leftSprite:setPosition(cc.p(10, self.mBgSize.height*0.5))
	leftSprite:setScaleX(-1)
	self.mBgSprite:addChild(leftSprite)
	self.mLeftArrow = leftSprite

	-- 右箭头
	local rightSprite = ui.newSprite("c_26.png")
	rightSprite:setPosition(cc.p(self.mBgSize.width-10, self.mBgSize.height*0.5))
	rightSprite:setScaleX(1)
	self.mBgSprite:addChild(rightSprite)
	self.mRightArrow = rightSprite

	-- 提示
	local hintLabel = ui.newLabel({
			text = TR("属性加成升级需要下赛季生效"),
			color = cc.c3b(0x46, 0x22, 0x0d),
		})
	hintLabel:setPosition(self.mBgSize.width*0.5, self.mBgSize.height-85)
	self.mBgSprite:addChild(hintLabel)

	-- 当前等级
	local curSprite = ui.newSprite("jhs_121.png")
	curSprite:setPosition(self.mBgSize.width-80, 80)
	curSprite:setScale(1.2)
	self.mBgSprite:addChild(curSprite)
	self.mCurSprite = curSprite

	-- 刷新箭头显示
	self:refreshArrow()

    -- 创建滑动显示
    self:createSliderView()
end

-- 刷新箭头
function JianghuKillJobBoxLayer:refreshArrow()
	if self.curLvIndex > 1 then
		self.mLeftArrow:setVisible(true)
	else
		self.mLeftArrow:setVisible(false)
	end

	if self.curLvIndex < #self.JobLvList then
		self.mRightArrow:setVisible(true)
	else
		self.mRightArrow:setVisible(false)
	end
end

-- 创建滑动窗口
function JianghuKillJobBoxLayer:createSliderView()
	local sliderSize = cc.size(500, 410)
	local sliderView = ui.newSliderTableView({
		width = sliderSize.width,
        height = sliderSize.height,
        isVertical = false,
        selItemOnMiddle = true,
        selectIndex = self.curLvIndex-1,
        itemCountOfSlider = function(sliderView)
        	return #self.JobLvList
        end,
        itemSizeOfSlider = function(sliderView)
            return sliderSize.width, sliderSize.height
        end,
        sliderItemAtIndex = function(sliderView, itemNode, index)
        	local jobLv = self.JobLvList[index+1]
    		self:createItem(itemNode, jobLv, sliderSize)
        end,
        selectItemChanged = function(sliderView, selectIndex)
        	self.curLvIndex = selectIndex+1

			-- 刷新箭头显示
			self:refreshArrow()

			-- 刷新当前图标
			local jobLv = self.JobLvList[self.curLvIndex]
			self.mCurSprite:setVisible(jobLv == self.mJobLv)
        end
	})
	sliderView:setAnchorPoint(cc.p(0.5, 1))
	sliderView:setPosition(self.mBgSize.width*0.5, self.mBgSize.height-95)
	self.mBgSprite:addChild(sliderView)
end

-- 创建显示项
function JianghuKillJobBoxLayer:createItem(parent, jobLv, itemSize)
	parent:removeAllChildren()
	local jobModel = JianghukillOccupationalprope.items[self.mJobId][jobLv]
	-- 势力等级显示
	local jobLvLabel = ui.newLabel({
			text = TR("%s%d级", JianghukillJobModel.items[self.mJobId].name, jobLv),
			color = cc.c3b(0xff, 0xe7, 0x48),
			outlineColor = cc.c3b(0x25, 0x87, 0x11),
			size = 27,
		})
	jobLvLabel:setPosition(itemSize.width*0.5, itemSize.height-30)
	parent:addChild(jobLvLabel)
	-- 江湖杀加成
	local tempLabel = ui.newLabel({
		text = TR("职业加成"),
		color = cc.c3b(0x46, 0x22, 0x0d),
	})
	tempLabel:setPosition(itemSize.width*0.5, itemSize.height-70)
	parent:addChild(tempLabel)
	-- 属性
	local attrList = self:analysisAttrStr(JianghukillJobModel.items[self.mJobId].attr)
	local attrPosYList = {itemSize.height-105, itemSize.height-135, itemSize.height-165}
	for i, attrInfo in ipairs(attrList) do
		local nameStr = attrInfo.value
        local valueStr = self:dealAttrFileld(attrInfo.fightattr, jobModel[attrInfo.fightattr])

        local attrLabel = ui.newLabel({
        		text = nameStr..valueStr,
				color = cc.c3b(0x46, 0x22, 0x0d),
        	})
        attrLabel:setPosition(itemSize.width*0.5, attrPosYList[i])
        parent:addChild(attrLabel)
	end
end

function JianghuKillJobBoxLayer:dealAttrFileld(name, value)
	-- 恢复时间
	if string.find(name, "Recover") then
		return value..TR("秒")
	-- 突袭触发概率（刺客),心有灵犀触发概率（书生)
	elseif name == "attackOdds" or name == "lingXi" then
		return (value/100).."%"
	end

	return tostring(value)
end

function JianghuKillJobBoxLayer:analysisAttrStr(attrStr)
	local ret = {}
	local itemList = string.split(attrStr, ",")
	for index, item in pairs(itemList) do
	    local tempList = string.split(item, "|")
	    if #tempList == 2 then
	        local tempItem = {}
	        tempItem.fightattr = tempList[1]
	        tempItem.value = tempList[2]

	        table.insert(ret, tempItem)
	    end
	end

	return ret
end

return JianghuKillJobBoxLayer