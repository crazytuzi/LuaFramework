--[[
	文件名：QFashionSelectLayer.lua
	描述：Q版时装选择页面
	创建人: yanghongsheng
	创建时间: 2019.04.09
--]]

local QFashionSelectLayer = class("QFashionSelectLayer", function()
	return display.newLayer()
end)

--[[
	params:
		combatType 		上阵类型（1：桃花岛 2：绝情谷 3：其他）
		callback 		回调
]]

-- 构造函数
function QFashionSelectLayer:ctor(params)
    -- 读取参数
	self.mCombatType = params.combatType
    self.callback = params.callback

	self.fashionList = {}
	-- 添加弹出框层
	local bgLayer = require("commonLayer.PopBgLayer").new({
		title = TR("更换时装"),
		bgSize = cc.size(630, 900),
		closeImg = "c_29.png",
		closeAction = function()
			LayerManager.removeLayer(self)
		end
	})
	self:addChild(bgLayer)

	-- 保存弹窗控件信息
	self.bgSprite = bgLayer.mBgSprite
	self.bgSize = bgLayer.mBgSprite:getContentSize()

	-- 初始化UI
	self:initUI()

	self:refreshData()
	self:refreshUI()
end

-- 显示页签
function QFashionSelectLayer:showTabLayer()
    -- 创建分页
    local buttonInfos = {
        {
            text = TR("更换"),
            tag = 1,
        },
    }
    -- 创建分页
    local tabLayer = ui.newTabLayer({
        btnInfos = buttonInfos,
        needLine = false,
        viewSize = cc.size(self.bgSize.width-50, 80),
    })

    tabLayer:setPosition(cc.p(self.bgSize.width * 0.5, self.bgSize.height-105))
    self.bgSprite:addChild(tabLayer)
end

-- 初始化UI
function QFashionSelectLayer:initUI()
	self:showTabLayer()

	local viewSize = cc.size(self.bgSize.width-50, self.bgSize.height - 150)
	-- 中间背景
	local centerBgSprite = ui.newSprite("sz_4.png")
	centerBgSprite:setAnchorPoint(cc.p(0.5, 0))
	centerBgSprite:setPosition(self.bgSize.width * 0.5, 320)
	self.bgSprite:addChild(centerBgSprite)
	self.centerBgSprite = centerBgSprite
	-- 列表背景
	local listBgSize = cc.size(viewSize.width - 20, 144)
	local listBgSprite = ui.newScale9Sprite("c_65.png", listBgSize)
	listBgSprite:setAnchorPoint(cc.p(0.5, 0))
	listBgSprite:setPosition(cc.p(self.bgSize.width * 0.5, 130))
	self.bgSprite:addChild(listBgSprite)

	-- 头像列表
	local mCellSize = cc.size(130, listBgSize.height)
	local mSliderView = ui.newSliderTableView({
        width = listBgSize.width - 20,
        height = listBgSize.height,
        isVertical = false,
        selItemOnMiddle = false,
        itemCountOfSlider = function(sliderView)
        	return #self.fashionList
        end,
        itemSizeOfSlider = function(sliderView)
            return mCellSize.width, mCellSize.height
        end,
        sliderItemAtIndex = function(sliderView, itemNode, index)
        	local itemData = self.fashionList[index + 1]
        	local showAttrs = {CardShowAttr.eBorder}
        	if (itemData.baseInfo.ID > 0) then
        		-- 主角不显示名字和进阶
        		table.insert(showAttrs, CardShowAttr.eName)
        		table.insert(showAttrs, CardShowAttr.eNum)
        		table.insert(showAttrs, CardShowAttr.eStep)
        	end
        	if (self.selectModelId == itemData.baseInfo.ID) then
        		-- 选中框
        		table.insert(showAttrs, CardShowAttr.eSelected)
        	end
        	if (itemData.isDressIn ~= nil) and (itemData.isDressIn == true) then
        		-- 已上阵
        		table.insert(showAttrs, CardShowAttr.eBattle)
        	end
        	local tempCard = require("common.CardNode").new({
				allowClick = true,
				onClickCallback = function()
					self.selectModelId = itemData.baseInfo.ID
					self:refreshUI()
				end
			})
			tempCard:setPosition(mCellSize.width / 2, mCellSize.height / 2 + 12)
			if (itemData.baseInfo.ID == 0) then
				tempCard:setHero({ModelId = FormationObj:getSlotInfoBySlotId(1).ModelId}, showAttrs)
			else
				tempCard:setQFashion({ModelId = itemData.baseInfo.ID, Num = itemData.ownNum, Step = QFashionObj:getOneItemStep(itemData.baseInfo.ID)}, showAttrs)
			end
			if (itemData.isOwned == nil) or (itemData.isOwned == false) then
				local lockSprite = ui.newSprite("bsxy_14.png")
				lockSprite:setPosition(48, 48)
				tempCard:addChild(lockSprite, 2)
				tempCard.mBgSprite:setGray(true)
			end
			itemNode:addChild(tempCard)
        end,
        selectItemChanged = function(sliderView, selectIndex)
        end
    })
    mSliderView:setTouchEnabled(true)
    mSliderView:setAnchorPoint(cc.p(0.5, 0.5))
    mSliderView:setPosition(listBgSize.width / 2, listBgSize.height / 2)
    listBgSprite:addChild(mSliderView)
    self.mSliderView = mSliderView

	-- 保存按钮
	local btnSave = ui.newButton({
		normalImage = "c_28.png",
		text = TR("更换"),
		clickAction = function()
			local currData = self:getSelectedFashion()
			if (currData.isOwned ~= nil) and (currData.isOwned == true) then
				-- 使用
				self:requestDressUp(currData.baseInfo.ID)
			else
				-- 获取
				-- Utility.getFashionWay(currData.baseInfo.ID)
				ui.showFlashView(TR("请关注运营活动"))
			end
		end
	})
	btnSave:setPosition(viewSize.width * 0.5, 80)
	self.bgSprite:addChild(btnSave)
	self.btnSave = btnSave
end

-- 刷新数据
function QFashionSelectLayer:refreshData()
	self.fashionList = {}

	-- 添加主角（主角有3个，需要分别单独配置）
	local playerModelId = FormationObj:getSlotInfoBySlotId(1).ModelId
	local playerInfo = HeroModel.items[playerModelId]
	local playerItem = {
		baseInfo = {
			ID = 0, 
			name = ConfigFunc:getHeroName(playerModelId),
			positivePic = QFashionObj:getQFashionLargePic(playerModelId),
		},
		Step = 0,
		isOwned = QFashionObj:getOneItemOwned(0),
		isDressIn = QFashionObj:getOneItemDressIn(0, self.mCombatType),
		ownNum = QFashionObj:getFashionCount(0)
	}
	table.insert(self.fashionList, playerItem)

	-- 添加所有时装
	for _,v in pairs(ShizhuangModel.items) do
		local tmpV = {baseInfo = clone(v)}
		tmpV.isOwned = QFashionObj:getOneItemOwned(v.ID)
		tmpV.isDressIn = QFashionObj:getOneItemDressIn(v.ID, self.mCombatType)
		tmpV.ownNum = QFashionObj:getFashionCount(v.ID)

		-- 添加时装的实体id和当前阶数
		local fashionInfo = QFashionObj:getStepFashionInfo(v.ID)
		tmpV.Id = fashionInfo and fashionInfo.Id or nil
		tmpV.Step = fashionInfo and fashionInfo.Step or 0
		-- tmpV.BackUpUseSteps = fashionInfo and fashionInfo.BackUpUseSteps or ""

		table.insert(self.fashionList, tmpV)
	end
	table.sort(self.fashionList, function (a, b)
			if (a.baseInfo.ID == 0) then
				return true
			end
			if (b.baseInfo.ID == 0) then
				return false
			end
			if (a.isOwned ~= b.isOwned) then
				return (a.isOwned == true)
			end
			return a.baseInfo.ID < b.baseInfo.ID
		end)

	-- 默认选择顺序：优先选择已上阵，如果没有的话就选主角
	if (self.selectModelId == nil) then
		self.selectModelId = 0
		for _,v in ipairs(self.fashionList) do
			if QFashionObj.isDressIn(v.CombatType, self.mCombatType) then
				self.selectModelId = v.baseInfo.ID
				break
			end
		end
	end
end

-- 刷新界面
function QFashionSelectLayer:refreshUI()
	-- 读取选中的绝学
	local currData = self:getSelectedFashion()
	
	-- 刷新列表
	self.mSliderView:reloadData()

	-- 刷新详情
	if (self.centerBgSprite.refreshNode == nil) then
		self.centerBgSprite.refreshNode = function (target, newData)
			target:removeAllChildren()
			if (newData == nil) then
				return
			end

			-- 显示名字
			local strName = newData.baseInfo.name
			local nStep = FashionObj:getOneItemStep(newData.baseInfo.ID)
			if (nStep > 0) then
				strName = strName .. "+" .. nStep
			end
			local centerBgSize = target:getContentSize()
			local nameLabel = ui.createLabelWithBg({
				bgFilename = "zr_50.png",
				labelStr = strName,
				fontSize = 24,
				color = cc.c3b(0x51, 0x18, 0x0d),
				alignType = ui.TEXT_ALIGN_CENTER
			})
			nameLabel:setPosition(centerBgSize.width * 0.5, centerBgSize.height - 50)
			target:addChild(nameLabel)

			-- 显示大图
			Figure.newHero({
	        	parent = target,
	        	figureName = newData.baseInfo.positivePic,
	    		position = cc.p(centerBgSize.width / 2, 90),
	    		scale = 1.2,
	    		async = function (figureNode)
	    		end,
	    	})

	    	-- 显示限定标志
	    	if (newData.baseInfo.pricePic ~= nil) and (newData.baseInfo.pricePic ~= "") then
	    		local flagSprite = ui.newSprite(newData.baseInfo.pricePic .. ".png")
	    		flagSprite:setPosition(centerBgSize.width / 2 - 100, 320)
	    		target:addChild(flagSprite, 1)
	    	end

	    	-- 时装技能描述
	    	local skillDescStr = ""
	    	if self.mCombatType == 1 then
	    		skillDescStr = newData.baseInfo.shengyuanIntro and newData.baseInfo.shengyuanIntro or ""
	    	elseif self.mCombatType == 2 then
	    		skillDescStr = newData.baseInfo.killValleyIntro and newData.baseInfo.killValleyIntro or ""
	    	end

	    	local skillDescLabel = ui.newLabel({
	    		text = TR("时装技能：%s", skillDescStr == "" and TR("无") or skillDescStr),
	    	})
	    	skillDescLabel:setAnchorPoint(cc.p(0, 0.5))
	    	skillDescLabel:setPosition(20, 35)
	    	target:addChild(skillDescLabel)
		end
	end
	self.centerBgSprite:refreshNode(currData)

	-- 刷新按钮状态
	if (currData.isOwned ~= nil) and (currData.isOwned == true) then
		-- 已拥有
		self.btnSave.mTitleLabel:setString(TR("更换"))
		-- self.btnStep:setEnabled(currData.baseInfo.ID > 0)
	else
		-- 未拥有
		self.btnSave.mTitleLabel:setString(TR("去获取"))
		-- self.btnStep:setEnabled(false)
	end
	-- 已经穿戴的禁止点击
	self.btnSave:setEnabled(not ((currData.isDressIn ~= nil) and (currData.isDressIn == true)))
end

----------------------------------------------------------------------------------------------------
-- 辅助接口

-- 获取当前选中的时装数据
function QFashionSelectLayer:getSelectedFashion()
	-- 读取选中的绝学
	local currData = nil
	for _,v in ipairs(self.fashionList) do
		if (self.selectModelId == v.baseInfo.ID) then
			currData = clone(v)
			break
		end
	end
	return currData
end

-- 穿戴时装
function QFashionSelectLayer:requestDressUp(modelId)
	local fashionId = nil
	if modelId == 0 then
		fashionId = EMPTY_ENTITY_ID
	else
		local fashionInfo = QFashionObj:getStepFashionInfo(modelId)
		if (fashionInfo == nil) then
			return
		end
		fashionId = fashionInfo.Id
	end
	
	HttpClient:request({
        moduleName = "Shizhuang",
        methodName = "Combat",
        svrMethodData = {fashionId, self.mCombatType},
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end

            QFashionObj:updateFashionList(response.Value.ShiZhuangInfo)
            self:refreshData()
			self:refreshUI()
			if self.callback then
				self.callback(modelId)
			end

			LayerManager.removeLayer(self)
        end,
    })
end

----------------------------------------------------------------------------------------------------

return QFashionSelectLayer
