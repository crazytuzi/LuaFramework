--[[
    文件名: JianghuKillForceBoxLayer.lua
    描述: 江湖杀势力等级预览界面
    创建人: yanghongsheng
    创建时间: 2018.09.06
-- ]]
local JianghuKillForceBoxLayer = class("JianghuKillForceBoxLayer", function(params)
	return display.newLayer()
end)

--[[
	params:
		forceId 		-- 势力id
		forceLv 		-- 势力等级
		isCanReceive 		-- 是否领每日福利
		callback 		-- 回调
]]
function JianghuKillForceBoxLayer:ctor(params)
	self.mForceId = params.forceId
	self.mForceLv = params.forceLv
	self.mIsCanReceive = params.isCanReceive
	self.mCallback = params.callback

	self.ForceLvList = table.keys(JianghukillForcelvModel.items)
	table.sort(self.ForceLvList, function (lv1, lv2)
		return lv1 < lv2
	end)
	-- -- 剔除0级
	-- local index = table.indexof(self.ForceLvList, 0)
	if index then
		table.remove(self.ForceLvList, index)
	end
	self.curLvIndex = table.indexof(self.ForceLvList, self.mForceLv) or 1
	-- 弹窗
    local parentLayer = require("commonLayer.PopBgLayer").new({
    	bgSize = cc.size(580, 593),
    	title = TR("势力福利"),
    })
    self:addChild(parentLayer)

    -- 保存弹框控件信息
    self.mBgSprite = parentLayer.mBgSprite
    self.mBgSize = self.mBgSprite:getContentSize()

	self:initUI()
end

function JianghuKillForceBoxLayer:initUI()
	-- 黑背景
	local blackSize = cc.size(500, 210)
	local blackBg = ui.newScale9Sprite("c_17.png", blackSize)
	blackBg:setAnchorPoint(cc.p(0.5, 1))
	blackBg:setPosition(self.mBgSize.width*0.5, self.mBgSize.height-70)
	self.mBgSprite:addChild(blackBg)

	-- 左箭头
	local leftSprite = ui.newSprite("c_26.png")
	leftSprite:setPosition(cc.p(10, 410))
	leftSprite:setScaleX(-1)
	self.mBgSprite:addChild(leftSprite)
	self.mLeftArrow = leftSprite

	-- 右箭头
	local rightSprite = ui.newSprite("c_26.png")
	rightSprite:setPosition(cc.p(self.mBgSize.width-10, 410))
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

	-- 刷新箭头显示
	self:refreshArrow()

	-- 领取按钮
	local getBtn = ui.newButton({
        normalImage = "c_28.png",
        text = TR("领取"),
        clickAction = function()
        	if not self.mIsCanReceive then
        		ui.showFlashView(TR("今日福利已领取"))
        		return
        	end
        	-- 领取奖励
        	self:requestReward()
        end
    })
    getBtn:setPosition(self.mBgSize.width*0.5, 58)
    self.mBgSprite:addChild(getBtn)
    self.mGetBtn = getBtn
    -- 刷新领取按钮显示
	self.mGetBtn:setVisible(self.mForceLv > 0)
	-- 已领取
	getBtn:setEnabled(self.mIsCanReceive or false)
	getBtn:setTitleText(self.mIsCanReceive and TR("领取") or TR("已领取"))

	-- 添加当前职业标识
    local curSprite = ui.newSprite("jhs_121.png")
    curSprite:setPosition(self.mBgSize.width-80, self.mBgSize.height*0.5+50)
    curSprite:setScale(1.2)
    self.mBgSprite:addChild(curSprite)
    self.mCurSprite = curSprite

    -- 创建滑动显示
    self:createSliderView()
end

-- 刷新箭头
function JianghuKillForceBoxLayer:refreshArrow()
	if self.curLvIndex > 1 then
		self.mLeftArrow:setVisible(true)
	else
		self.mLeftArrow:setVisible(false)
	end

	if self.curLvIndex < #self.ForceLvList then
		self.mRightArrow:setVisible(true)
	else
		self.mRightArrow:setVisible(false)
	end
end

-- 创建滑动窗口
function JianghuKillForceBoxLayer:createSliderView()
	local sliderSize = cc.size(500, 410)
	local sliderView = ui.newSliderTableView({
		width = sliderSize.width,
        height = sliderSize.height,
        isVertical = false,
        selItemOnMiddle = true,
        selectIndex = self.curLvIndex-1,
        itemCountOfSlider = function(sliderView)
        	return #self.ForceLvList
        end,
        itemSizeOfSlider = function(sliderView)
            return sliderSize.width, sliderSize.height
        end,
        sliderItemAtIndex = function(sliderView, itemNode, index)
        	local forceLv = self.ForceLvList[index+1]
    		self:createItem(itemNode, forceLv, sliderSize)
        end,
        selectItemChanged = function(sliderView, selectIndex)
        	self.curLvIndex = selectIndex+1
			local forceLv = self.ForceLvList[self.curLvIndex]

			-- 刷新箭头显示
			self:refreshArrow()
			-- 刷新领取按钮显示
			self.mGetBtn:setVisible(self.mForceLv > 0 and forceLv == self.mForceLv)
			-- 刷新当前图标
			self.mCurSprite:setVisible(forceLv == self.mForceLv)
        end
	})
	sliderView:setAnchorPoint(cc.p(0.5, 1))
	sliderView:setPosition(self.mBgSize.width*0.5, self.mBgSize.height-100)
	self.mBgSprite:addChild(sliderView)
end

-- 创建显示项
function JianghuKillForceBoxLayer:createItem(parent, forceLv, itemSize)
	parent:removeAllChildren()
	local forceModel = JianghukillForcelvModel.items[forceLv]
	-- 势力等级显示
	local after = self.mForceId == 1 and TR("员") or TR("徒")
	local forceLvLabel = ui.newLabel({
			text = TR("%s%d级", Enums.JHKCampName[self.mForceId]..after, forceLv),
			color = cc.c3b(0xff, 0xe7, 0x48),
			outlineColor = cc.c3b(0x25, 0x87, 0x11),
			size = 27,
		})
	forceLvLabel:setPosition(itemSize.width*0.5, itemSize.height-30)
	parent:addChild(forceLvLabel)
	-- 江湖杀加成
	local tempLabel = ui.newLabel({
		text = TR("江湖杀加成"),
		color = cc.c3b(0x46, 0x22, 0x0d),
	})
	tempLabel:setPosition(itemSize.width*0.5, itemSize.height-70)
	parent:addChild(tempLabel)
	-- 属性
	if forceModel.killAddition and forceModel.killAddition ~= "" then
		local attrList = Utility.analysisStrAttrList(forceModel.killAddition)
		local attrPosYList = {itemSize.height-105, itemSize.height-135, itemSize.height-165}
		for i, attrInfo in ipairs(attrList) do
			local nameStr = FightattrName[attrInfo.fightattr]
	        local valueStr = Utility.getAttrViewStr(attrInfo.fightattr, attrInfo.value)

	        local attrLabel = ui.newLabel({
	        		text = nameStr..valueStr,
					color = cc.c3b(0x46, 0x22, 0x0d),
	        	})
	        attrLabel:setPosition(itemSize.width*0.5, attrPosYList[i])
	        parent:addChild(attrLabel)
		end
	else
		local emptyLabel = ui.newLabel({
        		text = TR("无加成"),
				color = cc.c3b(0x46, 0x22, 0x0d),
        	})
        emptyLabel:setPosition(itemSize.width*0.5, itemSize.height-135)
        parent:addChild(emptyLabel)
	end
	-- 势力等级显示
	local forceLvLabel = ui.newLabel({
			text = TR("%s%d级", Enums.JHKCampName[self.mForceId]..after, forceLv),
			color = cc.c3b(0xff, 0xe7, 0x48),
			outlineColor = cc.c3b(0x25, 0x87, 0x11),
			size = 27,
		})
	forceLvLabel:setPosition(itemSize.width*0.5, itemSize.height-220)
	parent:addChild(forceLvLabel)
	-- 每日福利
	local tempLabel = ui.newLabel({
		text = TR("每日福利"),
		color = cc.c3b(0x46, 0x22, 0x0d),
	})
	tempLabel:setPosition(itemSize.width*0.5, itemSize.height-260)
	parent:addChild(tempLabel)
	-- 奖励列表
	if forceModel.levelRewards and forceModel.levelRewards ~= "" then
		local forceRewardList = Utility.analysisStrResList(forceModel.levelRewards)
		local rewardCardList = ui.createCardList({
				maxViewWidth = 530,
				cardDataList = forceRewardList,
			})
		rewardCardList:setAnchorPoint(cc.p(0.5, 0.5))
		rewardCardList:setPosition(itemSize.width*0.5, 70)
		parent:addChild(rewardCardList)
	else
		local emptyLabel = ui.newLabel({
        		text = TR("无福利"),
				color = cc.c3b(0x46, 0x22, 0x0d),
        	})
        emptyLabel:setPosition(itemSize.width*0.5, 70)
        parent:addChild(emptyLabel)
	end
end

--===================================网络相关===================================
-- 请求任务数据
function JianghuKillForceBoxLayer:requestReward()
    HttpClient:request({
        moduleName = "Jianghukill",
        methodName = "ForceSign",
        svrMethodData = {},
        callbackNode = self,
        callback = function(response)
            -- 容错处理
            if response.Status ~= 0 then
                return
            end

            -- dump(response, "JianghuKillForceBoxLayer")

            -- 飘窗显示获得的物品
            ui.ShowRewardGoods(response.Value.BaseGetGameResourceList)
            
            self.mIsCanReceive = false
            self.mGetBtn:setEnabled(false)
			self.mGetBtn:setTitleText(TR("已领取"))

            if self.mCallback then
            	self.mCallback(self.mIsCanReceive)
            end
        end
    })
end

return JianghuKillForceBoxLayer