--[[
    文件名: QFashionStepUpLayer.lua
    创建人: yanghongsheng
    创建时间: 2019-04-15
    描述:时装进阶对话框
--]]

local QFashionStepUpLayer = class("QFashionStepUpLayer", function()
    return display.newLayer()
end)

--[[
params:
	fashionModelId 		模型id
	callback 			回调
]]

function QFashionStepUpLayer:ctor(params)
    -- 读取参数
	self.mFashionModelId = params.fashionModelId or 29010001
    self.mCallback = params.callback

	self.mFashionInfo = QFashionObj:getStepFashionInfo(self.mFashionModelId)
	self.mCurGoodsModelId = 0
    -- 屏蔽下层触摸事件
    ui.registerSwallowTouch({node = self})

    
    -- 添加弹出框层
    local parentLayer = require("commonLayer.PopBgLayer").new({
        bgSize = cc.size(630, 1085),
        title = TR("时装进阶"),
        closeAction = function()
            LayerManager.removeLayer(self)
        end
    })
    self:addChild(parentLayer)
    self.mBgSprite = parentLayer.mBgSprite
    self.mBgSize = self.mBgSprite:getContentSize()

    -- 
    self:initUI()
    self:refreshUI()
end

-- 初始化页面
function QFashionStepUpLayer:initUI()
	-- 黑背景
	local blackSprite = ui.newScale9Sprite("c_17.png", cc.size(570, 610))
	blackSprite:setPosition(self.mBgSize.width*0.5, self.mBgSize.height-130)
	blackSprite:setAnchorPoint(cc.p(0.5, 1))
	self.mBgSprite:addChild(blackSprite)

	-- 时装形象
	local centerBgSize = cc.size(565, 450)
	local centerBgSprite = ui.newScale9Sprite("sz_1.png", centerBgSize)
	centerBgSprite:setAnchorPoint(cc.p(0.5, 0))
	centerBgSprite:setPosition(self.mBgSize.width * 0.5, 350)
	self.mBgSprite:addChild(centerBgSprite)

	Figure.newHero({
    	parent = centerBgSprite,
    	figureName = QFashionObj:getQFashionLargePic(self.mFashionModelId),
		position = cc.p(centerBgSize.width / 2, 60),
		scale = 1.2,
	})

	-- 培养按钮
	local upStepBtn = ui.newButton({
		normalImage = "c_28.png",
		text = TR("培养"),
		clickAction = function ()
			self:requestStepUp()
		end
	})
	upStepBtn:setPosition(self.mBgSize.width*0.5, 60)
	self.mBgSprite:addChild(upStepBtn)

	-- 道具经验
	self.mExpLabel = ui.newLabel({
		text = "",
		color = Enums.Color.eWhite,
		outlineColor = cc.c3b(0x46, 0x22, 0x0d),
	})
	self.mExpLabel:setPosition(self.mBgSize.width*0.5, 160)
	self.mBgSprite:addChild(self.mExpLabel)

	-- 创建顶部进阶显示
	self:createTopStepShow()
	-- 创建进阶属性显示
	self:createAttrShow()
	-- 进度条
	self:createProgressBar()
	-- 道具列表
	self:createGoodsList()
end

-- 创建顶部进阶显示
function QFashionStepUpLayer:createTopStepShow()
	local topBgSize = cc.size(600, 50)
	if not self.mTopStepBg then
		self.mTopStepBg = ui.newScale9Sprite("c_25.png", topBgSize)
		self.mTopStepBg:setPosition(self.mBgSize.width*0.5, self.mBgSize.height-100)
		self.mBgSprite:addChild(self.mTopStepBg)
	end
	self.mTopStepBg:removeAllChildren()

	local curStep = self.mFashionInfo.Step
	local nextStep = ShizhuangLvRelation.items[curStep+1] and curStep+1 or nil

	-- 满级
	if not nextStep then
		local hintLabel = ui.newLabel({
			text = TR("已进阶满级"),
			color = Enums.Color.eWhite,
		})
		hintLabel:setPosition(topBgSize.width*0.5, topBgSize.height*0.5)
		self.mTopStepBg:addChild(hintLabel)
	else
		local hintLabel = ui.newLabel({
			text = TR("进阶#ff4a46+%s    {c_66.png}    #F7F5F0进阶#ff4a46+%s", curStep, nextStep),
			color = Enums.Color.eWhite,
			outlineColor = cc.c3b(0x46, 0x22, 0x0d),
		})
		hintLabel:setPosition(topBgSize.width*0.5, topBgSize.height*0.5)
		self.mTopStepBg:addChild(hintLabel)
	end
end

-- 创建进阶属性显示
function QFashionStepUpLayer:createAttrShow()
	local bgSize = cc.size(565, 150)
	if not self.mAttrBg then
		self.mAttrBg = ui.newScale9Sprite("c_18.png", bgSize)
		self.mAttrBg:setPosition(self.mBgSize.width*0.5, self.mBgSize.height-210)
		self.mBgSprite:addChild(self.mAttrBg)
	end
	self.mAttrBg:removeAllChildren()

	-- 基础属性图
	local tempSprite = ui.newSprite("zr_68.png")
	tempSprite:setPosition(60, bgSize.height*0.5)
	self.mAttrBg:addChild(tempSprite)

	local curStep = self.mFashionInfo.Step
	local nextStep = ShizhuangLvRelation.items[curStep+1] and curStep+1 or nil

	-- 满级
	if not nextStep then
		local lvModel = ShizhuangLvRelation.items[curStep]
		local attrLabel = ui.newLabel({
			text = TR("桃花岛属性加成的#258711%s%%#46220d转化为全体的属性加成", lvModel.attrConverR*100),
			color = cc.c3b(0x46, 0x22, 0x0d),
			dimensions = cc.size(400, 0),
		})
		attrLabel:setAnchorPoint(cc.p(0, 0.5))
		attrLabel:setPosition(130, bgSize.height*0.5)
		self.mAttrBg:addChild(attrLabel)
	else
		-- 当前等级
		local lvModel = ShizhuangLvRelation.items[curStep]
		local attrLabel = ui.newLabel({
			text = TR("桃花岛属性加成的#258711%s%%#46220d转化为全体的属性加成", lvModel.attrConverR*100),
			color = cc.c3b(0x46, 0x22, 0x0d),
			dimensions = cc.size(160, 0),
		})
		attrLabel:setAnchorPoint(cc.p(0, 0.5))
		attrLabel:setPosition(130, bgSize.height*0.5)
		self.mAttrBg:addChild(attrLabel)
		-- 下一等级
		local lvModel = ShizhuangLvRelation.items[nextStep]
		local attrLabel = ui.newLabel({
			text = TR("桃花岛属性加成的#258711%s%%#46220d转化为全体的属性加成", lvModel.attrConverR*100),
			color = cc.c3b(0x46, 0x22, 0x0d),
			dimensions = cc.size(160, 0),
		})
		attrLabel:setAnchorPoint(cc.p(0, 0.5))
		attrLabel:setPosition(380, bgSize.height*0.5)
		self.mAttrBg:addChild(attrLabel)
		-- 箭头图
		local tempSprite = ui.newSprite("c_67.png")
		tempSprite:setPosition(320, bgSize.height*0.5)
		self.mAttrBg:addChild(tempSprite)
	end
end

-- 创建经验进度条
function QFashionStepUpLayer:createProgressBar()
	if not self.mProgressBar then
		self.mProgressBar = require("common.ProgressBar").new({
	        bgImage = "zr_14.png",
	        barImage = "zr_15.png",
	        currValue = 50,
	        maxValue = 100,
	        barType = ProgressBarType.eHorizontal,
	        contentSize = cc.size(570, 26)
	    })
	    self.mProgressBar:setAnchorPoint(cc.p(0.5, 0.5))
	    self.mProgressBar:setPosition(cc.p(self.mBgSize.width*0.5, 120))
	    self.mBgSprite:addChild(self.mProgressBar)

	    local progressLabel = ui.newLabel({
	    	text = "",
	    	color = Enums.Color.eWhite,
	    	size = 20,
	    	outlineColor = cc.c3b(0x46, 0x22, 0x0d),
	    })
	    self.mProgressBar:addChild(progressLabel)
	    progressLabel:setPosition(self.mProgressBar:getContentSize().width*0.5, self.mProgressBar:getContentSize().height*0.5)
	    self.mProgressBar.progressLabel = progressLabel
	end

	local curStep = self.mFashionInfo.Step
	local nextStep = ShizhuangLvRelation.items[curStep+1] and curStep+1 or nil

	-- 满级
	if not nextStep then
		local maxExp = ShizhuangLvRelation.items[curStep].totalExp
		self.mProgressBar:setMaxValue(maxExp)
		self.mProgressBar:setCurrValue(maxExp)

		self.mProgressBar.progressLabel:setString(TR("当前经验：%s/%s", maxExp, maxExp))
	else
		local maxExp = ShizhuangLvRelation.items[nextStep].totalExp
		self.mProgressBar:setMaxValue(maxExp)
		self.mProgressBar:setCurrValue(self.mFashionInfo.Exp)

		self.mProgressBar.progressLabel:setString(TR("当前经验：%s/%s", self.mFashionInfo.Exp, maxExp))
	end
end

-- 创建培养道具列表
function QFashionStepUpLayer:createGoodsList()
	if not self.mListView then
		local bgSize = cc.size(570, 144)
		local bgSprite = ui.newScale9Sprite("c_65.png", bgSize)
		bgSprite:setPosition(self.mBgSize.width*0.5, 260)
		self.mBgSprite:addChild(bgSprite)

		self.mListView = ccui.ListView:create()
	    self.mListView:setDirection(ccui.ScrollViewDir.horizontal)
	    self.mListView:setBounceEnabled(true)
	    self.mListView:setChildrenActionType(ui.LISTVIEW_ACTION_NONE)
	    self.mListView:setItemsMargin(8)
	    self.mListView:setAnchorPoint(cc.p(0.5, 0.5))
	    self.mListView:setPosition(bgSize.width*0.5, bgSize.height*0.5)
	    self.mListView:setContentSize(cc.size(bgSize.width-40, bgSize.height))
	    bgSprite:addChild(self.mListView)
	end
	-- 刷新列表
	self.mListView.refreshList = function (target)
		local goodsIdList = table.keys(ShizhuangDebrisExp.items)
		table.sort(goodsIdList, function (id1, id2)
			local goodsModel1 = GoodsModel.items[id1]
			local ownNum1 = Utility.getOwnedGoodsCount(goodsModel1.typeID, goodsModel1.ID)
			local goodsModel2 = GoodsModel.items[id2]
			local ownNum2 = Utility.getOwnedGoodsCount(goodsModel2.typeID, goodsModel2.ID)

			if (ownNum1 ~= 0) ~= (ownNum2 ~= 0) then
				return (ownNum1 ~= 0)
			end

			return id1 < id2
		end)
		-- 当前选中道具数量为0时，重置选中项
		local curGoodsModel = GoodsModel.items[self.mCurGoodsModelId]
		if curGoodsModel then
			local curOwnNum = Utility.getOwnedGoodsCount(curGoodsModel.typeID, curGoodsModel.ID)
			if curOwnNum <= 0 then
				self.mCurGoodsModelId = 0
			end
		end
		-- 刷新列表
		for i, goodsId in ipairs(goodsIdList) do
			local cellItem = target:getItem(i-1)
			local cellSize = cc.size(120, target:getContentSize().height)
			if not cellItem then
				cellItem = ccui.Layout:create()
				cellItem:setContentSize(cellSize)
				target:pushBackCustomItem(cellItem)
			end
			cellItem:removeAllChildren()

			-- 选择框
			local selectSprite = ui.newSprite("c_31.png")
            selectSprite:setPosition(cellSize.width*0.5, cellSize.height*0.55)
            selectSprite:setVisible(false)
            cellItem:addChild(selectSprite)
            -- 道具卡
			local goodsModel = GoodsModel.items[goodsId]
			local goodsCard = CardNode.createCardNode({
				resourceTypeSub = goodsModel.typeID,
				modelId = goodsModel.ID,
				num = Utility.getOwnedGoodsCount(goodsModel.typeID, goodsModel.ID),
				onClickCallback = function ()
					if self.mCurGoodsModelId == goodsModel.ID then
						return
					end

					self.mCurGoodsModelId = goodsModel.ID
					-- 更新经验显示
					if self.mExpLabel then
						self.mExpLabel:setString(TR("时装经验#ff4a46+%s", ShizhuangDebrisExp.items[self.mCurGoodsModelId].exp))
					end
					-- 更新选中显示
					if self.mBoforeSelect then
						self.mBoforeSelect:setVisible(false)
					end
					selectSprite:setVisible(true)
					self.mBoforeSelect = selectSprite
				end
			})
			goodsCard:setPosition(cellSize.width*0.5, cellSize.height*0.55)
			cellItem:addChild(goodsCard)

			-- 初始化
			if self.mCurGoodsModelId == 0 then
				self.mCurGoodsModelId = goodsId
				selectSprite:setVisible(true)
				self.mBoforeSelect = selectSprite
				self.mExpLabel:setString(TR("时装经验#ff4a46+%s", ShizhuangDebrisExp.items[self.mCurGoodsModelId].exp))
			elseif self.mCurGoodsModelId == goodsId then
				selectSprite:setVisible(true)
				self.mBoforeSelect = selectSprite
				self.mExpLabel:setString(TR("时装经验#ff4a46+%s", ShizhuangDebrisExp.items[self.mCurGoodsModelId].exp))
			end
		end
	end

	self.mListView:refreshList()
end

-- 刷新界面
function QFashionStepUpLayer:refreshUI()
	-- 创建顶部进阶显示
	self:createTopStepShow()
	-- 创建进阶属性显示
	self:createAttrShow()
	-- 进度条
	self:createProgressBar()
	-- 道具列表
	self.mListView:refreshList()
end

-- 翻倍动画
function QFashionStepUpLayer:playerExpAction(multiple)
	local expNum = ShizhuangDebrisExp.items[self.mCurGoodsModelId].exp
	expNum = expNum*multiple

	local parentNode = cc.Node:create()
	parentNode:setPosition(self.mBgSize.width*0.5, self.mBgSize.height*0.5+100)
	self.mBgSprite:addChild(parentNode)

	local multiplePicList = {[2] = "sz_5.png", [3] = "sz_6.png"}
	local multipleColorList = {
		cc.c3b(0xff, 0xf8, 0xea),
		cc.c3b(0x37, 0xff, 0x40),
		cc.c3b(0xff, 0x66, 0xf3),
	}

	local multiplePic = multiplePicList[multiple]
	local color = multipleColorList[multiple]
	local posY = 0

	-- 经验值
	local expLabel = ui.newLabel({
		text = TR("经验+%s", expNum),
		color = color,
		outlineColor = cc.c3b(0x46, 0x22, 0x0d),
	})
	expLabel:setPosition(0, posY)
	parentNode:addChild(expLabel)

	posY = posY + 40
	-- 倍数图片
	if multiplePic then
		local multipleSprite = ui.newSprite(multiplePic)
		multipleSprite:setPosition(0, posY)
		parentNode:addChild(multipleSprite)
	end


	-- 动作
	parentNode:setCascadeOpacityEnabled(true)
	local move = cc.MoveBy:create(1, cc.p(0, 100))
	local fadeOut = cc.FadeOut:create(1)
	local callFunc = cc.CallFunc:create(function (node)
		node:removeFromParent()
	end)
	parentNode:runAction(cc.Sequence:create({
		cc.Spawn:create({move, fadeOut}),
		callFunc
	}))
end

-- 时装进阶
function QFashionStepUpLayer:requestStepUp()
	local curStep = self.mFashionInfo.Step
	local nextStep = ShizhuangLvRelation.items[curStep+1] and curStep+1 or nil
    -- 判断是否已到最高
    if (nextStep == nil) then
        ui.showFlashView(TR("该时装已经进阶到最高"))
        return
    end

    -- 判断材料是否充足
    local curGoodsModel = GoodsModel.items[self.mCurGoodsModelId]
	if curGoodsModel then
		local curOwnNum = Utility.getOwnedGoodsCount(curGoodsModel.typeID, curGoodsModel.ID)
		if curOwnNum <= 0 then
			ui.showFlashView(TR("该时装碎片不足"))
			return
		end
	else
		ui.showFlashView(TR("请先选择时装碎片"))
		return
	end
    
    -- 请求接口
    HttpClient:request({
        moduleName = "Shizhuang",
        methodName = "StepUp",
        svrMethodData = {self.mFashionInfo.Id, self.mCurGoodsModelId},
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            local oldStep = self.mFashionInfo.Step
            -- 修改进阶
            QFashionObj:modifyFashionItem(response.Value.ShiZhuang)

            self.mFashionInfo = response.Value.ShiZhuang

            -- 倍率显示
            self:playerExpAction(response.Value.Multiple)

            -- 播放进阶特效
            if oldStep < self.mFashionInfo.Step then
            	ui.newEffect({
            		parent = self.mBgSprite,
            		effectName = "effect_ui_ruwutupo",
            		scale = 0.5,
            		position = cc.p(self.mBgSize.width * 0.5, 430),
            		loop = false,
            	})
            end

            -- 刷新界面
            self:refreshUI()

            -- 通知上层刷新
            if self.mCallback then
                self.mCallback()
            end
        end,
    })
end

return QFashionStepUpLayer