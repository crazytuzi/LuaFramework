--[[
	文件名:SubEquipStepUpView.lua
	描述：装备锻造的子页面
	创建人：peiyaoqiang
	创建时间：2017.05.12
--]]

local SubEquipStepUpView = class("SubEquipStepUpView", function(params)
    return cc.Node:create()
end)

--[[
-- 参数 params 中各项为：
	{
		viewSize: 显示大小，必选参数
		equipId: 装备实例Id，必选参数
		callback: 回调接口，可选参数
		parent:	父结点
	}
]]
function SubEquipStepUpView:ctor(params)
	params = params or {}

	-- 读取参数
	self.viewSize = params.viewSize
	self.equipId = params.equipId
	self.callback = params.callback
	self.parent = params.parent

	self.maxStep = table.maxn(EquipStepRelation.items)
	self.mateNodeList = {}				-- 保存消耗材料的node
	self.isRequesting = false 			-- 是否正在请求接口

	-- 初始化
	self:setContentSize(self.viewSize)

	-- 显示界面
	local equipInfo = EquipObj:getEquip(self.equipId)
	local equipBase = EquipModel.items[equipInfo.ModelId]
	if (equipBase.valueLv < 3) then
		local infoLabel = ui.newLabel({
			text = TR("蓝色或更高品质的装备才能进行锻造"),
			color = cc.c3b(0x46, 0x22, 0x0d),
			size = 30,
		})
		infoLabel:setAnchorPoint(cc.p(0.5, 0.5))
		infoLabel:setPosition(cc.p(self.viewSize.width * 0.5, self.viewSize.height * 0.5))
		self:addChild(infoLabel)
	else
		self:initLocalClass()
		self:initUI()
		self:refreshUI()
	end

	-- 注册关闭监控事件
    self:registerScriptHandler(function(eventType)
        if eventType == "exit" then
            FormationObj:enableShowAttrChangeAction(true)
        end
    end)
end

-- 初始化UI
function SubEquipStepUpView:initUI()
	-- 创建灰色背景图
	local centerBgSize = cc.size(self.viewSize.width - 40, self.viewSize.height - 36)
	local centerBgSprite = ui.newScale9Sprite("c_38.png", centerBgSize)
	centerBgSprite:setAnchorPoint(cc.p(0.5, 0))
	centerBgSprite:setPosition(cc.p(self.viewSize.width / 2, 5))
	self:addChild(centerBgSprite)

	-- 添加提示长按的Label
	self.showLongPressAction = function ()
		local actionLabel = ui.newLabel({
	        text = TR("长按道具可连续使用"),
	        size = 24,
	        color = cc.c3b(0xff, 0x97, 0x4a),
	    	outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
	        outlineSize = 2,
	    })
	    actionLabel:setPosition(centerBgSize.width * 0.50, centerBgSize.height * 0.45)
	    centerBgSprite:addChild(actionLabel, 1)

		local array = {}
		table.insert(array, cc.Show:create())
		table.insert(array, cc.MoveBy:create(0.8, cc.p(0, 50)))
		table.insert(array, cc.Hide:create())
		table.insert(array, cc.CallFunc:create(function ()
			actionLabel:removeFromParent()
		end))
		actionLabel:runAction(cc.Sequence:create(array))
	end

	-- 创建箭头
	local arrowSprite = ui.newSprite("c_67.png")
	arrowSprite:setPosition(centerBgSize.width * 0.5 - 5, 290)
	centerBgSprite:addChild(arrowSprite)

	-- 创建属性背景图
	local function createAttrBg(size, pos)
		local attrBgSprite = ui.newScale9Sprite("c_54.png", size)
		attrBgSprite:setPosition(pos)
		attrBgSprite.addTitle = function(target, titleText)
			local titleLabel = ui.newLabel({
		        text = titleText,
		        size = 24,
		        color = Enums.Color.eWhite,
		        outlineColor = cc.c3b(0x8d, 0x4b, 0x3b),
		        outlineSize = 2,
		    })
		    titleLabel:setPosition(size.width / 2, size.height - 22)
		    target:addChild(titleLabel)
		end
		centerBgSprite:addChild(attrBgSprite)
		return attrBgSprite
	end
	self.oldAttrBg = createAttrBg(cc.size(centerBgSize.width * 0.4, 150), cc.p(centerBgSize.width * 0.23, 288))
	self.newAttrBg = createAttrBg(cc.size(centerBgSize.width * 0.4, 150), cc.p(centerBgSize.width * 0.77, 288))

	-- 等级需求Label
	local lvNeedLabel = ui.newLabel({
		text = "",
		color = cc.c3b(0x46, 0x22, 0x0d),
		size = 22
	})
	lvNeedLabel:setAnchorPoint(cc.p(0.5, 0.5))
	lvNeedLabel:setPosition(self.viewSize.width * 0.5, self.viewSize.height - 49)
	self:addChild(lvNeedLabel)
	self.lvNeedLabel = lvNeedLabel

	-- 创建锻造阶位对话框
	local bottomBgSize = cc.size(centerBgSize.width - 40, 200)
	local bottomBg = createAttrBg(bottomBgSize, cc.p(centerBgSize.width * 0.5, 110))

	-- 创建当前阶位文字
	local stepSprite = ui.newSprite("zb_09.png")
	stepSprite:setAnchorPoint(cc.p(1, 0.5))
	stepSprite:setPosition(bottomBgSize.width * 0.5 + 1, 180)
	bottomBg:addChild(stepSprite)
	self.mStepSprite = stepSprite

	local stepLabel = ui.newNumberLabel({
        text = "",
        imgFile = "zb_08.png",
        charCount = 10,
        startChar = 48,
    })
    stepLabel:setAnchorPoint(cc.p(0, 0.5))
    stepLabel:setPosition(bottomBgSize.width * 0.5 - 1, 180)
    bottomBg:addChild(stepLabel)
    self.mStepLabel = stepLabel
    self.mStepLabel.parentSize = bottomBgSize

	-- 创建进度条
    local mainProgressBar = require("common.ProgressBar").new({
		bgImage = "zb_12.png",
		barImage = "zb_11.png",
		currValue = 0,
		maxValue = 1,
		barType = ProgressBarType.eHorizontal,
		})
    mainProgressBar:setAnchorPoint(cc.p(0.5, 0.5))
	mainProgressBar:setPosition(cc.p(bottomBgSize.width * 0.5, 138))
	bottomBg:addChild(mainProgressBar)

	local progressBarSize = mainProgressBar:getContentSize()
	local subProgressBar = require("common.ProgressBar").new({
		contentSize = progressBarSize,
		bgImage = "c_83.png",
		barImage = "zb_13.png",
		currValue = 0,
		maxValue = 1,
		barType = ProgressBarType.eHorizontal,
		})
	subProgressBar:setPosition(cc.p(progressBarSize.width * 0.5, progressBarSize.height * 0.5))
	mainProgressBar:addChild(subProgressBar)

	local progressLabel = ui.newLabel({
		text = "",
		color = cc.c3b(0xff, 0xfd, 0xfd),
		size = 20,
		outlineColor = Enums.Color.eBlack,
	    outlineSize = 2,
	})
	progressLabel:setPosition(bottomBgSize.width * 0.5, 138)
	bottomBg:addChild(progressLabel)

	self.progressLabel = progressLabel
	self.mainProgressBar = mainProgressBar
	self.subProgressBar = subProgressBar

	-- 创建材料背景
	local mateBgSize = cc.size(bottomBgSize.width, 120)
	local mateBgNode = cc.Node:create()
    mateBgNode:setContentSize(mateBgSize)
    mateBgNode:setIgnoreAnchorPointForPosition(false)
    mateBgNode:setAnchorPoint(cc.p(0.5, 0))
    mateBgNode:setPosition(cc.p(bottomBgSize.width / 2, 0))
    bottomBg:addChild(mateBgNode)
    self.mateBgNode = mateBgNode

    -- 显示一键锻造
    local btnAutoStep = ui.newButton({
		normalImage = "tb_177.png",
		clickAction = function()
			self:autoStepClickAction()
		end
	})
	btnAutoStep:setPosition(502, 60)
	bottomBg:addChild(btnAutoStep, 1)
	self.btnAutoStep = btnAutoStep
end

-- 刷新界面
function SubEquipStepUpView:refreshUI()
	local equipInfo = EquipObj:getEquip(self.equipId)
	local equipBase = EquipModel.items[equipInfo.ModelId]
	local stepConfig = EquipStepRelation.items[equipInfo.Step or 0]

	self.currLv = equipInfo.Lv or 0
	self.currStep = equipInfo.Step or 0
	self.currStepExp = equipInfo.StepExp or 0
	self.maxExp = stepConfig.perExp * equipBase.stepUseR
	self.needUpLv = stepConfig.needUpLv

	-- 重建当前属性
	local function resetAttrShow(attrBg, titleText, step)
		attrBg:removeAllChildren()
		attrBg:addTitle(titleText)

		local attrList = {
			{posY = 86, text = FightattrName[Fightattr.eHP], attrBase = "HP", stepUp = "HPStep"},
			{posY = 54, text = FightattrName[Fightattr.eAP], attrBase = "AP", stepUp = "APStep"},
			{posY = 22, text = FightattrName[Fightattr.eDEF], attrBase = "DEF", stepUp = "DEFStep"},
		}
		for _,v in ipairs(attrList) do
			local tempPerAttr = equipBase[v.stepUp]
			local tempAllAttr = "??"
			if (step <= self.maxStep) then
				tempAllAttr = math.floor(tempPerAttr * step)
			end
			local tempLabel = ui.newLabel({
				text = string.format("%s: %s%s", v.text, "#087E05", tempAllAttr),
				color = cc.c3b(0x46, 0x22, 0x0d),
				size = 22,
			})
			tempLabel:setAnchorPoint(cc.p(0, 0.5))
			tempLabel:setPosition(50, v.posY)
			attrBg:addChild(tempLabel)
		end
	end
	resetAttrShow(self.oldAttrBg, TR("本阶属性"), self.currStep)
	resetAttrShow(self.newAttrBg, TR("下阶属性"), self.currStep + 1)

	-- 刷新等级需求
	local strLvNeed = TR("锻造到下一阶，需要先强化到%d级", self.needUpLv)
	local strColorH = (self.currLv >= self.needUpLv) and "#087E05" or "#EF0008"
	self.lvNeedLabel:setString(strColorH .. strLvNeed)
	self.lvNeedLabel:setVisible(self.currStep < self.maxStep)

	-- 刷新阶位文字
	self.mStepLabel:setString(self.currStep)
	local labelWidth = self.mStepLabel:getContentSize().width + self.mStepSprite:getContentSize().width + 2
	local halfWidth = (self.mStepLabel.parentSize.width - labelWidth) / 2
	self.mStepLabel:setPositionX(halfWidth)
	self.mStepSprite:setPositionX(self.mStepLabel.parentSize.width - halfWidth)
	
	-- 刷新进度条
	self:resetProgressBar(0)

	-- 刷新材料显示
	self.selectClass:init()
	self:stopAllActions()
	self:showStepMates(self.mateBgNode, self.mateBgNode:getContentSize())
end

-- 显示锻造材料列表
--[[
	parent: 显示页面
	bgSize: 显示页面的大小
--]]
function SubEquipStepUpView:showStepMates(parent, bgSize)
	-- 初始化
	self.mateNodeList = {}
	self.isRequesting = false
	self.clickMateId = nil
	self.actionHandler = nil
	self.mateClickFunc = nil
	parent:removeAllChildren()

	-- 辅助接口
	local function addOneMate(mateId, mateExp, xPos)
		local mateBase = GoodsModel.items[mateId]
		local backSprite = ui.newSprite(Utility.getBorderImg(Utility.getQualityColorLv(mateBase.quality), Enums.CardShape.eSquare))
		local backPos = cc.p(xPos, 70)
		local backSize = backSprite:getContentSize()
		backSprite:setAnchorPoint(cc.p(0.5, 0.5))
		backSprite:setPosition(backPos)
		backSprite:setScale(0.9)
		parent:addChild(backSprite)
		self.mateNodeList[mateId] = {node = backSprite, pos = backPos, size = backSize}

		-- 显示材料图
		local mateSprite = ui.newSprite(mateBase.pic .. ".png")
		mateSprite:setPosition(backSize.width / 2, backSize.height / 2)
		backSprite:addChild(mateSprite)

		-- 显示数量
		local countLabel = ui.newLabel({
	        text = "",
	        size = 24,
	        color = Enums.Color.eNormalWhite,
        	outlineColor = Enums.Color.eBlack,
	        outlineSize = 2,
	    })
	    countLabel:setAnchorPoint(cc.p(1, 0))
	    countLabel:setPosition(backSize.width - 15, 5)
	    backSprite:addChild(countLabel)

	    -- 显示经验
		local expLabel = ui.newLabel({
			text = TR("经验+%d", mateExp),
			color = cc.c3b(0x46, 0x22, 0x0d),
		})
		expLabel:setAnchorPoint(cc.p(0.5, 1))
		expLabel:setPosition(backSize.width * 0.5, 0)
		backSprite:addChild(expLabel)

		-- 接口：修改数量
		backSprite.setCount = function(target, count)
			countLabel:setString(count)
			target.num = count
		end
		backSprite:setCount(GoodsObj:getCountByModelId(mateId))

		return backSprite
	end

	-- 处理锻造石列表
	local tmpList = {}
	local tmpPosXList = {58, 169, 280, 391}
	for _,v in pairs(EquipStepGoodsexpRelation.items) do
		table.insert(tmpList, clone(v))
	end
	table.sort(tmpList, function (a, b)
			return a.exp < b.exp
		end)
	for i,v in ipairs(tmpList) do
		addOneMate(v.goodsModelID, v.exp, tmpPosXList[i])
	end

	-- 辅助函数：材料点击处理
	self.speedClass:init()
	self.mateClickFunc = function()
		if (self.clickMateId == nil) then
			self:stopTimer()
			return
		end
		
		-- 判断一些前置条件（这里会偶发mateNode为nil的报错，可能是中途弹出了其他页面）
		local mateNode = self.mateNodeList[self.clickMateId]
		if (mateNode == nil) or (mateNode.node == nil) then
			self.clickMateId = nil
			self:stopTimer()
			return
		end

		-- 判断当前材料是否还有剩余
		if (mateNode.node.num == 0) then
			self:stopTimer()

			-- 数量不足的时候弹窗显示
		    local function DIYNormalFunction(layer, layerBgSprite, layerSize) 
		    	-- 重新设置提示内容的位置
				layer.mMsgLabel:setPosition(layerSize.width / 2, 170)
		        -- 创建物品的头像
		        local tempCard = CardNode.createCardNode({
		            resourceTypeSub = ResourcetypeSub.eFunctionProps,
		            modelId = self.clickMateId,
		        })
		        tempCard:setPosition(layerSize.width / 2, layerSize.height - 125)

		        layerBgSprite:addChild(tempCard)
		    end
		    -- 设置弹窗按钮
		    local buttonInfo1 = {text = TR("前往获取"), clickAction = function()
	            if ModuleInfoObj:modulePlayerIsOpen(ModuleSub.eBDDShop, true) then
					LayerManager.addLayer({name = "challenge.BddExchangeLayer", cleanUp = true})
				else
					ui.showFlashView(TR("比武招亲商店未开启！"))	
				end
	        end}
		    local tempData = {
		        title = TR("锻造石详情"),
		        msgText = GoodsModel.items[self.clickMateId].intro or " ",
		        bgSize = cc.size(572, 400),
		        btnInfos = {buttonInfo1},
		        closeBtnInfo = {},
		        DIYUiCallback = DIYNormalFunction,
		    }
		    LayerManager.addLayer({name = "commonLayer.MsgBoxLayer", data = tempData, cleanUp = false})

		    -- 恢复初始值
		    self.clickMateId = nil
			return
		end
		
		-- 控制速度
		if (self.speedClass:step() == true) then
			self:addOneItem()
		end
	end

	ui.registerSwallowTouch({node = parent,
		beganEvent = function (touch, event)
			-- 判断点击位置并保存
			local touchPos = parent:convertTouchToNodeSpace(touch)
			for k,v in pairs(self.mateNodeList) do
				local halfWidth, halfHeight = v.size.width / 2 - 5, v.size.height / 2 - 5
				if ((touchPos.x >= v.pos.x - halfWidth) and (touchPos.x <= v.pos.x + halfWidth) and
					(touchPos.y >= v.pos.y - halfHeight) and (touchPos.y <= v.pos.y + halfHeight)) then
					self.clickMateId = k
					break
				end
			end

			if (self.clickMateId ~= nil) then
				self:startTimer()
				return true
			end
			return false
		end,
		movedEvent = function (touch, event)
			-- 判断是否还在开始点击的格子里
			local touchPos = parent:convertTouchToNodeSpace(touch)
			local tempId = nil
			for k,v in pairs(self.mateNodeList) do
				local halfWidth, halfHeight = v.size.width / 2 - 5, v.size.height / 2 - 5
				if ((touchPos.x >= v.pos.x - halfWidth) and (touchPos.x <= v.pos.x + halfWidth) and
					(touchPos.y >= v.pos.y - v.size.height) and (touchPos.y <= v.pos.y)) then
					tempId = k
					break
				end
			end
			if ((tempId ~= nil) and (tempId == self.clickMateId)) then
				return
			end

			-- 停止计数
			self:stopTimer()
		end,
		endedEvent = function (touch, event)
			-- 停止计数
			self:stopTimer()
		end})
end

----------------------------------------------------------------------------------------------------

-- 创建本地类
function SubEquipStepUpView:initLocalClass()
	-- 速度控制类：控制点击材料时的消耗速度
	local mSpeedClass = {}

	-- 计时器每次间隔时间
	mSpeedClass.scheduleTime = 0.05

	-- 初始化接口
	mSpeedClass.init = function (target)
		target.repeatOfPer = 6 		-- 每循环6次执行一次回调，这个数值会递减
		target.repeatCount = 6 		-- 初始值设为6，首次轻点的时候就能执行回调
		target.repeatCallback = 0
	end
	-- 步进接口：返回true则可以执行回调，返回false则忽略
	mSpeedClass.step = function (target)
		target.repeatCount = target.repeatCount + 1
		if (target.repeatCount < target.repeatOfPer) then
			return false
		end
		target.repeatCount = 0
		target.repeatCallback = target.repeatCallback + 1
		if ((target.repeatCallback >= 2) and (target.repeatOfPer > 1)) then
			-- 回调达到2次，速度增加
			target.repeatCallback = 0
			target.repeatOfPer = target.repeatOfPer - 1
		end
		return true
	end

	-- 初始化
	self.speedClass = mSpeedClass
	self.speedClass:init()

	--------------------------------------------------------------------------------

	-- 选择材料类：连续点击的时候，在提交之前进行内容保存
	local mSelectClass = {}

	-- 初始化接口
	mSelectClass.init = function (target)
		target.selectCount = 0 		-- 选中的数量
	end
	-- 添加材料的接口
	mSelectClass.addItem = function (target)
		target.selectCount = target.selectCount + 1
	end
	-- 获取选择的材料数量
	mSelectClass.getCount = function (target)
		return target.selectCount
	end

	-- 初始化
	self.selectClass = mSelectClass
	self.selectClass:init()
end

-- 辅助函数：点击开始计数
function SubEquipStepUpView:startTimer()
	if (self.clickMateId == nil) then
		return
	end

	-- 检查参数
	local function tempStopFunc(strText)
		self.clickMateId = nil
		if (strText ~= nil) then
			ui.showFlashView(strText)
		end
	end
	if (self.isRequesting == true) then
		tempStopFunc()
		return
	end
	if (self.currStep >= self.maxStep) then
		tempStopFunc(TR("该装备已经锻造到最高阶位"))
		return
	end
	if (self.currLv < self.needUpLv) then
		tempStopFunc(TR("该装备需强化到%d级才能继续锻造", self.needUpLv))
		return
	end

	-- 初始化选择列表
	self.selectClass:init()

	-- 正式开始计数
	local actionArray = cc.RepeatForever:create(
		cc.Sequence:create({
			cc.CallFunc:create(self.mateClickFunc),
			cc.DelayTime:create(self.speedClass.scheduleTime),
		})
	)
	self.actionHandler = self:runAction(actionArray)

	-- 被点击的材料也显示动画
	local mateNode = self.mateNodeList[self.clickMateId]
	local backSize = mateNode.node:getContentSize()
	if (self.bombEffect ~= nil) then
		self.bombEffect:removeFromParent()
		self.bombEffect = nil
	end
	self.bombEffect = ui.newEffect({
        parent = mateNode.node,
        effectName = "effect_ui_tianfu",
        animation = "jihuo",
        position = cc.p(backSize.width / 2, backSize.height / 2),
        loop = true,
        endRelease = true,
    })
end

-- 辅助函数：点击停止计数
function SubEquipStepUpView:stopTimer()
	if (self.actionHandler ~= nil) then
		self:stopAction(self.actionHandler)
		self.actionHandler = nil
	end

	-- 被点击的材料关闭动画
	if (self.clickMateId ~= nil) then
		if (self.bombEffect ~= nil) then
			self.bombEffect:removeFromParent()
			self.bombEffect = nil
		end

		-- 提交到服务器
		if (self.selectClass:getCount() > 0) then
			self:stepUpRequest()
		end
	end
	self.speedClass:init()
end

-- 辅助函数：增加一个锻造石材料
function SubEquipStepUpView:addOneItem()
	if (self.clickMateId == nil) then
		return
	end

	-- 保存当前锻造石
	local perExp = EquipStepGoodsexpRelation.items[self.clickMateId].exp
	self.selectClass:addItem()

	-- 播放音效
	MqAudio.playEffect("jingyan_up.mp3")

	-- 弹出动画
	local mateNode = self.mateNodeList[self.clickMateId]
	local tempLabel = ui.newLabel({
        text = "+" .. perExp,
        size = 20,
        color = cc.c3b(0x9b, 0xff, 0x6a),
    	outlineColor = cc.c3b(0x6b, 0x48, 0x2b),
        outlineSize = 2,
    })
    tempLabel:setAnchorPoint(cc.p(0.5, 1))
    tempLabel:setPosition(mateNode.size.width / 2, mateNode.size.height)
    tempLabel:runAction(cc.Sequence:create({
		cc.MoveBy:create(1.1, cc.p(0, 130)),
		cc.CallFunc:create(function ()
			tempLabel:removeFromParent()
			tempLabel = nil
		end),
	}))
	mateNode.node:addChild(tempLabel)
    mateNode.node:setCount(mateNode.node.num - 1) 		-- 刷新当前材料数量

    -- 刷新进度条
    local addAllExp = perExp * self.selectClass:getCount()
    self:resetProgressBar(addAllExp)

    -- 判断当前选择的经验是否足够升级了
    if ((addAllExp + self.currStepExp) >= self.maxExp) then
    	self:stopTimer()
    	return
	end
end

----------------------------------------------------------------------------------------------------

-- 装备一键锻造阶数选择框
--[[
    title               名字
    curStep             装备当前阶数
    maxNum              最大数量
    OkCallback          回调
]]
function SubEquipStepUpView:addOnekeyCount(title, curStep, maxNum, OkCallback)
    local selCount = 1 -- 当前选择的数量
    local showCount = curStep + selCount

    -- 提示窗体自定义控件函数
    local function DIYFuncion(layer, layerBgSprite, layerSize)
        -- 提示文字
        local hintLabel = ui.newLabel({
                text = TR("请选择您要锻造到的阶数"),
                color = cc.c3b(0x46, 0x22, 0x0d),
                size = 24,
            })
        hintLabel:setPosition(layerSize.width*0.5, layerSize.height*0.75)
        layerBgSprite:addChild(hintLabel)
        -- 黑背景
        local blackBgSize = cc.size(layerSize.width*0.9, layerSize.height*0.43)
        local blackBg = ui.newScale9Sprite("c_17.png", blackBgSize)
        blackBg:setPosition(layerSize.width*0.5, layerSize.height*0.45)
        layerBgSprite:addChild(blackBg)
        -- 数量显示
        local labelNode, labelNum = ui.createSpriteAndLabel({
        		imgName = "c_24.png",
        		scale9Size = cc.size(130, 32),
        		labelStr = TR("%d阶", showCount),
        		fontColor = cc.c3b(0x11, 0x11, 0x11),
        		alignType = cc.TEXT_ALIGNMENT_CENTER,
        	})
        labelNode:setPosition(blackBgSize.width*0.5, blackBgSize.height*0.5)
        blackBg:addChild(labelNode)
        local function refreshLabel()
        	labelNum:setString(TR("%d阶", showCount))
        end
        -- 加减按钮
        local tempPosY = blackBgSize.height*0.5
        local btnList = {
        	{
        		text = "-5",
	    		position = cc.p(blackBgSize.width*0.1, tempPosY),
	    		clickAction = function()
	    			selCount = math.max(1, selCount - 5)
	    			showCount = curStep + selCount
	    			refreshLabel()
	    		end,
        	},
        	{
        		text = "-1",
	    		position = cc.p(blackBgSize.width*0.25, tempPosY),
	    		clickAction = function()
	    			selCount = math.max(1, selCount - 1)
	    			showCount = curStep + selCount
	    			refreshLabel()
	    		end,
        	},
        	{
        		text = "+1",
	    		position = cc.p(blackBgSize.width*0.75, tempPosY),
	    		clickAction = function()
	    			selCount = math.min(maxNum, selCount + 1)
	    			showCount = curStep + selCount
	    			refreshLabel()
	    		end,
        	},
        	{
        		text = "+5",
	    		position = cc.p(blackBgSize.width*0.9, tempPosY),
	    		clickAction = function()
	    			selCount = math.min(maxNum, selCount + 5)
	    			showCount = curStep + selCount
	    			refreshLabel()
	    		end,
        	},
	    }
	    for _, btnInfo in pairs(btnList) do
	    	btnInfo.normalImage = "bg_05.png"
	    	local tempBtn = ui.newButton(btnInfo)
	    	blackBg:addChild(tempBtn)
	    end
    end

    local okBtnInfo = {
        text = TR("确定"),
        clickAction = function(layerObj, btnObj)
            OkCallback(selCount, layerObj, btnObj)
        end,
    }

    return MsgBoxLayer.addDIYLayer({
        title = title or TR("选择"),
        bgSize = cc.size(570, 350),
        btnInfos = {okBtnInfo},
        closeBtnInfo = {},
        DIYUiCallback = DIYFuncion,
        notNeedBlack = true,
    })
end

-- 根据增加经验重新设置进度条
--[[
	addExp: 锻造增加的强化经验
--]]
function SubEquipStepUpView:resetProgressBar(addExp)
	self.subProgressBar:setMaxValue(self.maxExp)
	self.mainProgressBar:setMaxValue(self.maxExp)
	self.mainProgressBar:setCurrValue(self.currStepExp)

	local newExp = self.currStepExp + addExp
	if (newExp >= self.maxExp) then 	-- 可以升级
		self.subProgressBar:setCurrValue(self.maxExp)
		self.progressLabel:setString(string.format("%d/%d", self.maxExp, self.maxExp))
	else
		self.subProgressBar:setCurrValue(newExp)
		self.progressLabel:setString(string.format("%d/%d", newExp, self.maxExp))
	end
end

-- 一键锻造
--[[
	自动按照品质从低到高读取当前装备锻造升级需要消耗的数量，如果选中的材料不能升级，就全部消耗掉
--]]
function SubEquipStepUpView:autoStepClickAction()
	-- 首先判断是否有可用的材料
	local isHaveMates = false
	for _,v in pairs(self.mateNodeList) do
		if (v.node ~= nil) and (v.node.num > 0) then
			isHaveMates = true
			break
		end
	end
	if (isHaveMates == false) then
		MsgBoxLayer.addOKCancelLayer(
            TR("没有可用的锻造石了，是否前往获取?"),
            TR("提示"),
            {
                text = TR("是"),
                clickAction = function(layerObj, btnObj)
                    LayerManager.removeLayer(layerObj)

                    -- 跳转到比武招亲
                    if ModuleInfoObj:modulePlayerIsOpen(ModuleSub.eBDDShop, true) then
						LayerManager.addLayer({name = "challenge.BddExchangeLayer", cleanUp = true})
					else
						ui.showFlashView(TR("比武招亲商店未开启！"))	
					end
                end
            },
            {
                text = TR("否")
            }
        )
		return
	end

	if (self.currStep >= self.maxStep) then
		ui.showFlashView(TR("该装备已经锻造到最高阶位"))
		return
	end
	if (self.currLv < self.needUpLv) then
		ui.showFlashView(TR("该装备需强化到%d级才能继续锻造", self.needUpLv))
		return
	end

	-- 装备信息
	local equipInfo = EquipObj:getEquip(self.equipId)
	local equipBase = EquipModel.items[equipInfo.ModelId]
	-- 拥有经验
	local haveExp = 0
	for _, expInfo in pairs(EquipStepGoodsexpRelation.items) do
		local count = GoodsObj:getCountByModelId(expInfo.goodsModelID) or 0
		haveExp = haveExp + count*expInfo.exp
	end
	haveExp = haveExp + equipInfo.StepExp

	-- 可以升多少级
	local stepCount = 0
	while haveExp >= 0 do
		local stepConfig = EquipStepRelation.items[equipInfo.Step+stepCount]
		local beforeStepConfig = EquipStepRelation.items[equipInfo.Step+stepCount-1]
		if stepConfig and equipBase.stepUseR ~= 0 and equipInfo.Lv >= (beforeStepConfig and beforeStepConfig.needUpLv or 0) then
			local needExp = stepConfig.perExp * equipBase.stepUseR
			haveExp = haveExp - needExp
		else
			break
		end
		stepCount = stepCount + 1
	end
	-- 减去多加的一
	stepCount = stepCount - 1

	-- 如果小于两级不弹窗弹窗
	if stepCount < 2 then
		self:autoStepRequest(1)
	else
		self.countBox = self:addOnekeyCount(TR("一键锻造"), equipInfo.Step, stepCount, function (stepNum)
			print("stepNum", stepNum)
			dump(equipInfo, "装备信息")

			-- 请求接口
			self:autoStepRequest(stepNum)
			LayerManager.removeLayer(self.countBox)
		end)
	end
end

----------------------------------------------------------------------------------------------------

-- 处理锻造接口返回的数据
function SubEquipStepUpView:dealWithResponseData(data, oldSlotInfos, oldMasterLvs)
	-- 如果没有进阶，则只需刷新进度条即可
    local newStep = data.EquipInfo.Step or 0
    if (newStep <= self.currStep) then
    	self.currStepExp = data.EquipInfo.StepExp or 0
    	self:resetProgressBar(0)
    	self.btnAutoStep:setEnabled(true)
    	return
    end

    -- 播放装备锻造特效和声音
    local progressBarSize = self.mainProgressBar:getContentSize()
	ui.newEffect({
        parent = self.mainProgressBar,
        effectName = "effect_ui_jingyantiao",
        position = cc.p(progressBarSize.width / 2, progressBarSize.height / 2),
        loop = false,
        endRelease = true,
        endListener = function ()
	        -- 执行回调
            if (self.callback ~= nil) then
            	self.callback(ModuleSub.eEquipStepUp)
            end

            -- 判断共鸣是否变化
            local newMasterLvs = ConfigFunc:getMasterLv(FormationObj:getSlotInfos()) or {}
            local function endFunc()
            	local slotDiffInfos = FormationObj:getSlotDiff(oldSlotInfos, FormationObj:getSlotInfos())
		        FormationObj:showSlotAttrChange(slotDiffInfos)
		    end
            local ret = FormationObj:showEquipMasterTips(oldMasterLvs, newMasterLvs, endFunc)
            if (ret == nil) then
            	endFunc()
            end
            FormationObj:enableShowAttrChangeAction(true)
    	end
    })
    MqAudio.playEffect("zhuangbei_duanzao.mp3")
end

-- 辅助函数：装备锻造请求接口
function SubEquipStepUpView:stepUpRequest()
	-- 判断选中的材料是否有效
	if (self.clickMateId == nil) then
		return
	end

	-- 判断材料数量
	local nCount = self.selectClass:getCount()
	if (nCount == 0) then
		self.clickMateId = nil
		return
	end

	-- 判断当前是否正在执行接口
	if (self.isRequesting == true) then
		self.clickMateId = nil
		return
	end
	self.isRequesting = true

	-- 判断是否单次点击
	if (nCount == 1) then
		self.showLongPressAction()
	end

	-- 预处理
	local oldSlotInfos = clone(FormationObj:getSlotInfos())
	local oldMasterLvs = ConfigFunc:getMasterLv(oldSlotInfos) or {}
	FormationObj:enableShowAttrChangeAction(false)
	
	-- 请求接口
	HttpClient:request({
        moduleName = "Equip",
        methodName = "EquipStepUp",
		guideInfo = Guide.helper:tryGetGuideSaveInfo(11805),
        svrMethodData = {self.equipId, self.clickMateId, nCount},
        callback = function(response)
        	self.isRequesting = false
    		self.clickMateId = nil

    		--
            if not response or response.Status ~= 0 then
            	self:refreshUI()
                return
            end

			-- 执行下一步引导
            local _, _, eventID = Guide.manager:getGuideInfo()
            if eventID == 11805 then
				Guide.manager:nextStep(eventID)
				self:executeGuide()
			end

            -- 刷新缓存
            EquipObj:modifyEquipItem(response.Value.EquipInfo)

            -- 处理数据
            self:dealWithResponseData(response.Value, oldSlotInfos, oldMasterLvs)
        end
    })
end

-- 辅助函数：一键锻造请求接口
function SubEquipStepUpView:autoStepRequest(stepNum)
	-- 判断当前是否正在执行接口
	if (self.isRequesting == true) then
		return
	end
	self.isRequesting = true
	self.btnAutoStep:setEnabled(false)

	-- 预处理
	local oldSlotInfos = clone(FormationObj:getSlotInfos())
	local oldMasterLvs = ConfigFunc:getMasterLv(oldSlotInfos) or {}
	FormationObj:enableShowAttrChangeAction(false)
	
	-- 请求接口
	HttpClient:request({
        moduleName = "Equip",
        methodName = "OneKeyEquipStepUp",
		guideInfo = nil,
        svrMethodData = {self.equipId, stepNum},
        callback = function(response)
        	self.isRequesting = false
    		self.clickMateId = nil

    		--
            if not response or response.Status ~= 0 then
            	self:refreshUI()
                return
            end
            
            -- 刷新缓存
            EquipObj:modifyEquipItem(response.Value.EquipInfo)

            -- 刷新材料数量
            local function resetMateCount(modelId, consumeCount)
            	for k,v in pairs(self.mateNodeList) do
            		if (k == modelId) then
            			v.node:setCount(v.node.num - consumeCount)
						break
					end
				end
        	end
        	for _,v in pairs(response.Value.UseConsume) do
        		resetMateCount(v.ModelId, v.Count)
        	end

        	-- 处理数据
            self:dealWithResponseData(response.Value, oldSlotInfos, oldMasterLvs)
        end
    })
end

-- ========================== 新手引导 ===========================
function SubEquipStepUpView:executeGuide()
	local guideMateNode = self.mateNodeList[16050239]
	Guide.helper:executeGuide({
		-- 点击锻造石
        [11805] = {clickRect = guideMateNode and cc.rect(guideMateNode.pos.x + 50 * Adapter.MinScale, guideMateNode.pos.y + 50 * Adapter.MinScale,
        	guideMateNode.size.width, guideMateNode.size.height),},
        -- 点击返回按钮
        [11806] = {clickNode = self.parent.mCloseBtn},
    })
end

return SubEquipStepUpView
