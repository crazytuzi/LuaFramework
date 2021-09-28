--[[
	文件名：BsxyLayer.lua
	描述：拜师学艺页面
	创建人：lengjiazhi
	创建时间：2017.4.7
--]]
local BsxyLayer = class("BsxyLayer", function (params)
	return display.newLayer()
end)


--[[
	页面恢复信息
	selectIndex --选中人物
	
--]]
local TeacherList = TeacherModel.items
local MAXLV = #TeacherFavorLvRelation.items[1]
function BsxyLayer:ctor(params)

	self.mGiftExp = nil
	self.mCurLv = nil

	--页面父节点
	self.mParentLayer = ui.newStdLayer()
	self:addChild(self.mParentLayer)

	--用于刷新界面的子父节点
	self.mSubLayer = ui.newStdLayer()
	self:addChild(self.mSubLayer)

	--特效父节点
	self.mEffStdLayer = ui.newStdLayer()
	self:addChild(self.mEffStdLayer)

	-- 创建底部导航和顶部玩家信息部分
    local tempLayer = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        currentLayerType = Enums.MainNav.ePractice,
        topInfos = {ResourcetypeSub.eVIT, ResourcetypeSub.eGold, ResourcetypeSub.eDiamond}
    })
    self:addChild(tempLayer)

    --背景图
	local bgSprite = ui.newSprite("bsxy_16.jpg")
	bgSprite:setPosition(320, 568)
	self.mParentLayer:addChild(bgSprite)

	-- 设置规则按钮
    local ruleBtn = ui.newButton({
        normalImage = "c_72.png",
        anchorPoint = cc.p(0.5, 1),
        position = cc.p(60, 957),
        clickAction = function()
            MsgBoxLayer.addRuleHintLayer(TR("规则"),
            {
                [1] = TR("1.送礼可以提升主角属性"),
                [2] = TR("2.每个师傅都有自己的喜好，师傅只会收取他喜好的礼物"),
                [3] = TR("3.好感度达到满值后能提升好感等级"),
                [4] = TR("4.好感达到一定等级后会有神秘奖励"),
        	})
        end})
    self.mParentLayer:addChild(ruleBtn, 1)


	self.mSelectIndex = params.selectIndex or 1
	self.mOldLv = nil
	self.mIsNewTal = false
	self.mOldStepNum = nil

	self:initUI()
	self:requestGetTeacherInfo(self.mSelectIndex)
end

--创建基本UI
function BsxyLayer:initUI()
	--顶部选择背景
	local topBgSprite = ui.newScale9Sprite("wldh_03.png", cc.size(640, 130))
	topBgSprite:setPosition(320, 1025)
	self.mParentLayer:addChild(topBgSprite)
	--左箭头
	local arrowL = ui.newSprite("c_26.png")
	arrowL:setPosition(24, 1025)
	arrowL:setRotation(180)
	self.mParentLayer:addChild(arrowL)
	--右箭头
	local arrowR = ui.newSprite("c_26.png")
	arrowR:setPosition(611, 1025)
	self.mParentLayer:addChild(arrowR)
	--顶部选择列表
	self.mListView = ccui.ListView:create()
    self.mListView:setDirection(ccui.ScrollViewDir.horizontal)
    self.mListView:setBounceEnabled(true)
    self.mListView:setGravity(ccui.ListViewGravity.centerVertical)
    self.mListView:setContentSize(cc.size(553, 113))
    self.mListView:setItemsMargin(10)
    self.mListView:setChildrenActionType(ui.LISTVIEW_ACTION_NONE)
    self.mListView:setAnchorPoint(cc.p(0.5, 0.5))
    self.mListView:setPosition(320, 1020)
    self.mParentLayer:addChild(self.mListView)

    self:refreshTeacherList()

	--返回按钮
	local backBtn = ui.newButton({
			normalImage = "c_29.png",
			position = cc.p(595, 913),
			clickAction = function ()
            	LayerManager.removeLayer(self)
			end
		})
	self.mParentLayer:addChild(backBtn)
end
--刷新师傅列表
function BsxyLayer:refreshTeacherList()
	self.mListView:removeAllItems()
	self.mTeacherList = {}
	for index, item in ipairs(TeacherModel.items) do
		local info = TeacherList[index]

		local layout = ccui.Layout:create()
		layout:setContentSize(cc.size(104, 106))

		local teacherCard = CardNode.createCardNode({
			onClickCallback = function (pSender)
				local oldIndex = self.mSelectIndex
				if oldIndex ~= index then
					self.mSelectIndex = index
					for i,v in ipairs(self.mTeacherList) do
						if i == self.mSelectIndex then
							v.selectSprite:setVisible(true)
						else
							v.selectSprite:setVisible(false)
						end
					end
					self.mSubLayer:removeAllChildren()
					self:requestGetTeacherInfo(self.mSelectIndex)
				else
					return
				end
			end
		})
		local borderPic = teacherCard:getQualitySmallImage(info.quality)
		local headPic = info.minPic..".png"
		teacherCard:setEmpty({CardShowAttr.eBorder}, borderPic, headPic)
		teacherCard:setPosition(52, 58)
		--锁定提示图
		teacherCard.lockSprite = ui.newSprite("bsxy_14.png")
		teacherCard.lockSprite:setPosition(48, 48)
		teacherCard:addChild(teacherCard.lockSprite, 2)
		table.insert(self.mTeacherList, teacherCard)
		
		-- if self.mSelectIndex == index then
		teacherCard.selectSprite = ui.newSprite("c_31.png")
		teacherCard.selectSprite:setPosition(48, 48)
		teacherCard:addChild(teacherCard.selectSprite, 2)
		teacherCard.selectSprite:setVisible(false)

		-- end

		layout:addChild(teacherCard)
		self.mListView:pushBackCustomItem(layout)

    	-- 师傅头上小红点
    	local subKeyId = "Teacher" .. index
    	local function dealRedDotVisible(redDotSprite)
    	    local redDotData = RedDotInfoObj:isValid(ModuleSub.eTeacher, subKeyId)
    	    redDotSprite:setVisible(redDotData)
    	end
    	ui.createAutoBubble({refreshFunc = dealRedDotVisible, parent = layout,
    		eventName = RedDotInfoObj:getEvents(ModuleSub.eTeacher, subKeyId)})
	end
	self.mTeacherList[self.mSelectIndex].selectSprite:setVisible(true)
end

-- 刷新师傅锁定状态
function BsxyLayer:refreshLockInfo()	
	for i,v in ipairs(self.mLockInfo) do
		if not v.Status then
			self.mTeacherList[i].mExtraSprite:setGray(true)
			self.mTeacherList[i].lockSprite:setVisible(true)
		else
			self.mTeacherList[i].mExtraSprite:setGray(false)
			self.mTeacherList[i].lockSprite:setVisible(false)
		end
	end
end

--创建中间信息
function BsxyLayer:createInfoView(index)

	--信息处理
	local teacherInfo = TeacherList[index]
	local likeList = {}
	local tempList = string.splitBySep(teacherInfo.likeGiftStr, ",")
	for i,v in ipairs(tempList) do
		local tempModel = tonumber(v)
		table.insert(likeList, tempModel)
	end
	--人物形象
	self.mTeacherImg = teacherInfo.pic..".png"
	local teacherSprite = ui.newSprite(self.mTeacherImg)
	teacherSprite:setPosition(182, 640)
	self.mSubLayer:addChild(teacherSprite)

	local playerLv = PlayerAttrObj:getPlayerAttrByName("Lv")
	if playerLv < teacherInfo.openLv then
		local lvTipLabel = ui.newLabel({
			text = TR("达到%s%s%s等级即可解锁拜师",Enums.Color.eGreenH, teacherInfo.openLv, Enums.Color.eNormalWhiteH),
			outlineColor = Enums.Color.eOutlineColor,
			})
		lvTipLabel:setPosition(450, 870)
		self.mSubLayer:addChild(lvTipLabel)
	end

	--介绍背景
	local introBgSize = #likeList>8 and cc.size(320, 240) or cc.size(320, 180)
	local introBgSprite = ui.newScale9Sprite("bsxy_03.png", introBgSize)
	introBgSprite:setPosition(450, 740)
	self.mSubLayer:addChild(introBgSprite)
	self.mIntroBgSprite = introBgSprite

	--介绍名字
	local introNameLabel = ui.newLabel({
		text = teacherInfo.name,
		color = cc.c3b(0x69, 0xf6, 0xff),
		outlineColor = Enums.Color.eBlack,
		outlineSize = 2,
		size = 24,
		})
	introNameLabel:setPosition(introBgSize.width * 0.5, introBgSize.height - 30)
	introBgSprite:addChild(introNameLabel)
	--介绍武功
	local introTypeLabel = ui.newLabel({
		text = TR("武功特点: %s", teacherInfo.kungfuIntro),
		color = cc.c3b(0xff, 0xf0, 0x6e),
		outlineColor = Enums.Color.eBlack,
		outlineSize = 2,
		size = 21,
		})
	introTypeLabel:setAnchorPoint(0, 1)
	introTypeLabel:setPosition(20, introBgSize.height - 50)
	introBgSprite:addChild(introTypeLabel)
	--介绍喜好
	local likeStr = ""
	for i,v in ipairs(likeList) do
		if i == 1 then
			likeStr = likeStr..GoodsModel.items[v].name
			
		else
			likeStr = likeStr.."、"..GoodsModel.items[v].name
		end
	end
	local introLikeLabel = ui.newLabel({
		text = TR("喜好: %s", likeStr),
		color = cc.c3b(0xff, 0xf0, 0x6e),
		outlineColor = Enums.Color.eBlack,
		outlineSize = 2,
		size = 21,
		dimensions = cc.size(introBgSize.width - 40, 0),
		})
	introLikeLabel:setAnchorPoint(0, 1)
	introLikeLabel:setPosition(20, introBgSize.height - 80)
	introBgSprite:addChild(introLikeLabel)
end

--创建下方信息
function BsxyLayer:createBottomView(index)
	local teacherInfo = TeacherList[index]
	--下方信息背景
	local bgSprite = ui.newScale9Sprite("wldh_01.png", cc.size(640, 324))
	bgSprite:setAnchorPoint(0.5, 0)
	bgSprite:setPosition(320, 113)
	self.mSubLayer:addChild(bgSprite)
	self.mBottomBgSprite = bgSprite
	local bgSize = bgSprite:getContentSize()

	--好感度文字
	local perferDeep = ui.newLabel({
		text = TR("好感度"),
		color = Enums.Color.eBlack,
		size = 24,
		})
	perferDeep:setAnchorPoint(0, 0.5)
	perferDeep:setPosition(bgSize.width * 0.1, bgSize.height - 80)
	bgSprite:addChild(perferDeep)
	self.mPerferDeep = perferDeep
	
	--好感度爱心
	self.mHeartList = {}
	for i = 1, 10 do
		local heartSprite = ui.newSprite("bsxy_07.png")
		heartSprite:setPosition(bgSize.width * 0.2 + (40*i), bgSize.height - 80)
		bgSprite:addChild(heartSprite)
		table.insert(self.mHeartList, heartSprite)
	end
	local curStepLv = self.mTeacherInfo.Lv - self.mStepNum * 10
	if curStepLv > 0 then
		for  i = 1, curStepLv do
			self.mHeartList[i]:setTexture("bsxy_06.png")
		end
	end

	--进度条
	local curMaxExp
	if self.mTeacherInfo.Lv >= MAXLV then
		curMaxExp = TeacherFavorLvRelation.items[index][self.mTeacherInfo.Lv].exp
	else
		curMaxExp = TeacherFavorLvRelation.items[index][self.mTeacherInfo.Lv+1].exp
	end
	local perferBar = require("common.ProgressBar").new({
	     	bgImage = "bsxy_12.png",   
	        barImage = "bsxy_11.png", 
	        contentSize = cc.size(460, 24),
	        currValue = self.mTeacherInfo.Exp,  
	        maxValue = curMaxExp,
	        needLabel = true, 
	        color = Enums.Color.eNormalWhite,
	        size = 17,
		})
	perferBar:setPosition(bgSize.width * 0.5, bgSize.height - 120)
	bgSprite:addChild(perferBar)
	self.mPerferBar = perferBar
	self.mMaxExp = curMaxExp

	if self.mTeacherInfo.Lv >= MAXLV then
		self.mPerferBar:setCurrValue(self.mMaxExp)
	end

	--称号图片
	local lvStepPic= TeacherTitleRelation.items[self.mStepNum+1].titlePic..".png"
	local titleSprite = ui.newSprite(lvStepPic)
	titleSprite:setPosition(320, 300)
	bgSprite:addChild(titleSprite)
	self.mTitleSprite = titleSprite

	--属性背景透明框
	local attrBgSprite = ui.newScale9Sprite("bsxy_10.png", cc.size(526, 100))
	attrBgSprite:setPosition(bgSize.width * 0.5, bgSize.height * 0.41)
	bgSprite:addChild(attrBgSprite)
	self.mAttrBgSprtie = attrBgSprite
	--中间箭头
	local arrow = ui.newSprite("bsxy_01.png")
	arrow:setPosition(263, 50)
	attrBgSprite:addChild(arrow)

	--解析配置的属性 lv是师傅等级
	local function handleAttr(lv)
		local attrStr = ""
		if lv > MAXLV then
			attrStr = TR("已经达到最高的等级")
		else
			local tempAttr = Utility.analyzeAttrAddString(TeacherFavorLvRelation.items[index][lv].totalAttrStr)
			for i,v in ipairs(tempAttr) do
				-- if i%2 == 0 then
					attrStr = attrStr..TR("主角")..v.name.." #249029+"..v.value.."#61311e\n"
				-- else
				-- 	attrStr = attrStr..v.name.." #249029+"..v.value.." "
				-- end
			end
		end
		return attrStr
	end 
	--当前属性标题
	local curAttrLabelNow = ui.newLabel({
		text = TR("当前属性"),
		color = cc.c3b(0x61, 0x31, 0x1e),
		size = 21,
		})
	curAttrLabelNow:setPosition(135, 86)
	attrBgSprite:addChild(curAttrLabelNow)
	--当前属性
	local attrLabelNow = ui.newLabel({
		text = handleAttr(self.mTeacherInfo.Lv),
		color = cc.c3b(0x61, 0x31, 0x1e),
		size = 19,
		})
	attrLabelNow:setAnchorPoint(0, 0.5)
	attrLabelNow:setPosition(75, 40)
	attrBgSprite:addChild(attrLabelNow)
	--下一阶属性标题
	local nextAttrLabelNext = ui.newLabel({
		text = TR("下一阶属性"),
		color = cc.c3b(0x61, 0x31, 0x1e),
		size = 21,
		})
	nextAttrLabelNext:setPosition(400, 86)
	attrBgSprite:addChild(nextAttrLabelNext)
	--下一阶属性
	local attrLabelNext = ui.newLabel({
		text = handleAttr(self.mTeacherInfo.Lv + 1),
		color = cc.c3b(0x61, 0x31, 0x1e),
		size = 19,
		-- dimensions = cc.size(2390, 0),
		})
	attrLabelNext:setAnchorPoint(0, 0.5)
	attrLabelNext:setPosition(330, 40)
	attrBgSprite:addChild(attrLabelNext)

	if self.mTeacherInfo.Lv >= MAXLV then
		curAttrLabelNow:setPosition(263, 86)
		attrLabelNow:setPosition(200, 40)
		nextAttrLabelNext:setVisible(false)
		attrLabelNext:setVisible(false)
		arrow:setVisible(false)
	end

	--送礼按钮
	local giftBtn = ui.newButton({
		text = TR("送礼"),
		normalImage = "jc_16.png",
		clickAction = function ()
			if self.mTeacherInfo.Lv >= MAXLV then
				ui.showFlashView(TR("师傅已经达到最高的亲密度"))
			else
				self:refreshGiftShow()
			end

			-- 执行下一步引导
            local _, _, eventID = Guide.manager:getGuideInfo()
            if eventID == 10904 then
				Guide.manager:nextStep(eventID)
				self:executeGuide()
			end
		end
		})
	giftBtn:setPosition(bgSize.width * 0.5, bgSize.height * 0.15)
	bgSprite:addChild(giftBtn)
	self.mGiftBtn = giftBtn

    -- 按钮上小红点
    local subKeyId = "Teacher" .. index
    local function dealRedDotVisible(redDotSprite)
        local redDotData = RedDotInfoObj:isValid(ModuleSub.eTeacher, subKeyId)
        redDotSprite:setVisible(redDotData)
    end
    ui.createAutoBubble({refreshFunc = dealRedDotVisible, parent = giftBtn, 
    	eventName = RedDotInfoObj:getEvents(ModuleSub.eTeacher, subKeyId)})


	--属性总览按钮(透明背景)
	local attrBtnSize = cc.size(130, 30)
	local attrTotalBtn = ui.newButton({
		normalImage = "c_83.png",
		size = attrBtnSize,
		clickAction = function ()
			self:requestGetAttrInfo()
		end
	})
	attrTotalBtn:setPosition(bgSize.width * 0.81, bgSize.height * 0.13)
	bgSprite:addChild(attrTotalBtn)
	self.mAttrTotalBtn = attrTotalBtn
	self.mAttrTotalBtn:setEnabled(false)

	local attrTitleLabel = ui.newLabel({
		text = TR("属性总览>>"),
		color = cc.c3b(0x7c, 0x43, 0x26),
		size = 20,
		}) 
	attrTitleLabel:setPosition(attrBtnSize.width * 0.5 + 20, attrBtnSize.height * 0.5)
	attrTotalBtn:addChild(attrTitleLabel)

	-----------------------------送礼部分的显示-------------------------------------
	--配置数据整理
	local tempgiftList = {}
	local likeList = {}
	local tempList = string.splitBySep(teacherInfo.likeGiftStr, ",")
	for i,v in ipairs(tempList) do
		local tempModel = tonumber(v)
		table.insert(tempgiftList, tempModel)
	end
	for i,v in ipairs(tempgiftList) do
		local num = GoodsObj:getCountByModelId(v)
		if num > 0 then
			table.insert(likeList, v)
		end
	end

	-- 背景底板透明框
	local giftBgSprite = ui.newScale9Sprite("bsxy_10.png", cc.size(526, 166))
	giftBgSprite:setPosition(bgSize.width * 0.5, bgSize.height * 0.5)
	bgSprite:addChild(giftBgSprite)
	local giftBgSize = giftBgSprite:getContentSize()
	self.mGiftBgSprite = giftBgSprite
	giftBgSprite:setVisible(false)

	--白色主背景
	local whiteBgSprite = ui.newScale9Sprite("sc_06.png", cc.size(490, 138))
	whiteBgSprite:setPosition(giftBgSize.width * 0.5, giftBgSize.height * 0.5)
	giftBgSprite:addChild(whiteBgSprite)

	--送礼标识
	local tipSprite = ui.newSprite("bsxy_05.png")
	tipSprite:setPosition(40, giftBgSize.height - 10)
	giftBgSprite:addChild(tipSprite)

	--好感度背景
	-- local totalAddSprite = ui.newSprite("bsxy_02.png")
	-- totalAddSprite:setPosition(giftBgSize.width * 0.5, giftBgSize.height * 0.31)
	-- giftBgSprite:addChild(totalAddSprite)
	--好感度
	-- local totalAddLabel = ui.newLabel({
	-- 	text = TR("好感度 +%d", 0),
	-- 	color = cc.c3b(0xff, 0x44, 0x25),
	-- 	size = 19,
	-- 	})
	-- totalAddLabel:setAnchorPoint(0, 0.5)
	-- totalAddLabel:setPosition(giftBgSize.width * 0.39, giftBgSize.height * 0.31)
	-- giftBgSprite:addChild(totalAddLabel)

	--处理总的好感度统计
	-- local chooseNumList = {}
	-- for i,v in ipairs(likeList) do
	-- 	chooseNumList[v] = 0
	-- end
	-- local function refreshPerferDeep()
	-- 	local totalAttrPerfer = 0
	-- 	for modelId, num in pairs(chooseNumList) do
	-- 		totalAttrPerfer = totalAttrPerfer + GoodsModel.items[modelId].outputNum * num 
	-- 	end
	-- 	totalAddLabel:setString(TR("好感度 +%d", totalAttrPerfer))
	-- 	self.mGiftExp = totalAttrPerfer
	-- end 
	-- refreshPerferDeep()

	--礼物列表
	local giftList = {}
	local giftListView = ccui.ListView:create()
	giftListView:setDirection(ccui.ScrollViewDir.horizontal)
    giftListView:setContentSize(cc.size(432, 152))
    giftListView:setAnchorPoint(cc.p(0.5, 1))
    giftListView:setPosition(giftBgSize.width * 0.5, giftBgSize.height + 5)
    giftBgSprite:addChild(giftListView)
	--左箭头
	local arrowL = ui.newSprite("c_26.png")
	arrowL:setPosition(giftBgSize.width * 0.05, giftBgSize.height * 0.5)
	arrowL:setRotation(180)
	giftBgSprite:addChild(arrowL)
	--右箭头
	local arrowR = ui.newSprite("c_26.png")
	arrowR:setPosition(giftBgSize.width * 0.95, giftBgSize.height * 0.5)
	giftBgSprite:addChild(arrowR)

    local function createGiftItem(modelId)
    	local layout = ccui.Layout:create()
    	layout:setContentSize(130, 152)

    	local goodInfo = GoodsModel.items[modelId]
		local maxNum = GoodsObj:getCountByModelId(modelId)
		local tempCardNode = CardNode.createCardNode({
			modelId = goodInfo.ID,
			resourceTypeSub = goodInfo.typeID,
			num = maxNum,
			})
		tempCardNode:setPosition(65, 76)
		layout:addChild(tempCardNode)

		return layout
    end 
    table.sort(likeList, function (a, b)
    	local infoA = GoodsModel.items[a]
    	local infoB = GoodsModel.items[b]
    	if infoA.quality ~= infoB.quality then
    		return infoA.quality > infoB.quality
    	end
    	return infoA.ID > infoB.ID
    end)
	for i, modelId in ipairs(likeList) do
		giftListView:pushBackCustomItem(createGiftItem(modelId))
	end

	--取消按钮
	local cancleBtn = ui.newButton({
		text = TR("取消"),
		normalImage = "c_28.png",
		outlineColor = cc.c3b(0x8e, 0x4f, 0x09),
		clickAction = function (pSender)
			self:refreshGiftHide()
		end
		})
	cancleBtn:setPosition(giftBgSize.width * 0.75, giftBgSize.height * 0.1 - 45)
	giftBgSprite:addChild(cancleBtn)

	--确定按钮
	local sendGiftBtn = ui.newButton({
		text = TR("一键送礼"),
		normalImage = "c_28.png",
		outlineColor = cc.c3b(0x8e, 0x4f, 0x09),
		clickAction = function (pSender)
			self:requestSendGift(index)
			-- refreshGiftList()
		end
		})
	sendGiftBtn:setPosition(giftBgSize.width * 0.25, giftBgSize.height * 0.1 - 45)
	giftBgSprite:addChild(sendGiftBtn)

	if table.maxn(likeList) == 0 then
		local noGiftTip = ui.newLabel({
			text = TR("你还没有师傅喜欢的礼物哦"),
			color = Enums.Color.eBlack,
			size = 24,
			})
		noGiftTip:setPosition(giftBgSize.width * 0.5, giftBgSize.height * 0.5)
		giftBgSprite:addChild(noGiftTip)
		sendGiftBtn:setTitleText(TR("去获取"))
		sendGiftBtn:setClickAction(function()
				Utility.showTeacherLikeGiftWay()
			end)
	end

	self:createBaishiView(teacherInfo)
	
	--如果需要小游戏的展示
	if self.mNeedGame ~= 0 then
		self:showLearnView()
		self.mGiftBtn:setVisible(false)
		sendGiftBtn:setVisible(false)
		cancleBtn:setVisible(false)
		self.mPerferBar:setCurrValue(self.mMaxExp)

		local learnBtn = ui.newButton({
			text = TR("开始学习"),
			normalImage = "c_28.png",
			outlineColor = cc.c3b(0x8e, 0x4f, 0x09),
			clickAction = function()
				LayerManager.addLayer({
					name = "practice.BsxyGameLayer",
					data = {gameId = self.mNeedGame, teacherId = self.mSelectIndex}
				})
			end
		})
		learnBtn:setPosition(bgSize.width * 0.5, bgSize.height * 0.15)
		bgSprite:addChild(learnBtn,10)
	end
end

-- 拜师界面
function BsxyLayer:createBaishiView(teacherInfo)
	local BsBgSprite = ui.newScale9Sprite("wldh_01.png", cc.size(640, 324))
	BsBgSprite:setAnchorPoint(0.5, 0)
	BsBgSprite:setPosition(320, 113)
	self.mSubLayer:addChild(BsBgSprite)
	self.mBsBgSprite = BsBgSprite
	local bgSizeBs = BsBgSprite:getContentSize()

	local bstInfo = Utility.analysisStrResList(teacherInfo.openNeedGoods)
	local needItem = bstInfo[1] or {}
	local goodsNum = Utility.getOwnedGoodsCount(needItem.resourceTypeSub, needItem.modelId)
	local bstCard = CardNode.createCardNode({
		resourceTypeSub = needItem.resourceTypeSub,
    	modelId = needItem.modelId,
    	cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eName}
		})
	bstCard:setCardCount(goodsNum, needItem.num)
	bstCard:setPosition(bgSizeBs.width * 0.5, bgSizeBs.height * 0.5)
	BsBgSprite:addChild(bstCard)

	local bstBtn = ui.newButton({
		normalImage = "c_95.png",
		text = (goodsNum < needItem.num) and TR("去获取") or TR("拜师"),
		outlineColor = cc.c3b(0xc0, 0x49, 0x4b),
		clickAction = function ()
			if (goodsNum < needItem.num) then
				Utility.showResLackLayer(needItem.resourceTypeSub, needItem.modelId)
			else
				if PlayerAttrObj:getPlayerAttrByName("Lv") < teacherInfo.openLv then
					ui.showFlashView(TR("等级不足，先去升等级再来拜师吧~"))
					return
				end
				self:requestBaishi(teacherInfo.ID)
			end
		end
		})
	bstBtn:setPosition(bgSizeBs.width * 0.5, bgSizeBs.height * 0.15)
	BsBgSprite:addChild(bstBtn)
	self.bstBtn = bstBtn

	self:refresBaishiStatus()
end

-- 小游戏引导层
function BsxyLayer:showLearnView()
	local blackLayer = cc.LayerColor:create(cc.c4b(0, 0, 0, 200))
	blackLayer:setContentSize(640, 1136)
	self.mSubLayer:addChild(blackLayer)

	ui.registerSwallowTouch({node = blackLayer})

	local removeBlackBtn = ui.newButton({
		normalImage = "c_29.png",
		clickAction = function ()
			blackLayer:removeFromParent()
		end
		})
	removeBlackBtn:setPosition(590, 918)
	blackLayer:addChild(removeBlackBtn)

	local teacherSprite = ui.newSprite(self.mTeacherImg)
	teacherSprite:setPosition(175, 603)
	blackLayer:addChild(teacherSprite)

	local showWordSprite = ui.newScale9Sprite("cdjh_54.png", cc.size(295, 125))
	showWordSprite:runAction(cc.FlipX:create(true))
	showWordSprite:setPosition(424, 784)
	blackLayer:addChild(showWordSprite)

	local wordLabel = ui.newLabel({
		text = TR("礼物我很喜欢，但不能白拿你的东西，我教你一些防身之术吧？"),
		size = 22,
		color = Enums.Color.eNormalWhite,
		outlineColor = Enums.Color.eBlack,
		dimensions = cc.size(245, 0)
		})
	wordLabel:setPosition(424, 790)
	blackLayer:addChild(wordLabel)

	local inLearnBtn = ui.newButton({
		normalImage = "bsxy_26.png",
		clickAction = function()
			LayerManager.addLayer({
					name = "practice.BsxyGameLayer",
					data = {gameId = self.mNeedGame, teacherId = self.mSelectIndex}
				})
		end
		})
	inLearnBtn:setPosition(481, 574)
	blackLayer:addChild(inLearnBtn)

end

--属性总览层
function BsxyLayer:createAttrView()
	--处理属性字符串
	local function dataHandle()
		
		local totalAttrList = {}
		local fightattrList = {}

		for i,v in ipairs(self.mAttrInfo) do
			local tempData = Utility.analysisStrAttrList(v.AttrStr)

			for n, m in ipairs(tempData) do
				fightattrList[m.fightattr] = 0
			end
		end

		for i,v in ipairs(self.mAttrInfo) do
			local tempData = Utility.analysisStrAttrList(v.AttrStr)
			for n, m in ipairs(tempData) do
				fightattrList[m.fightattr] = fightattrList[m.fightattr] + m.value
			end
		end

		for k, v in pairs(fightattrList) do
			table.insert(totalAttrList, k, v)
		end

		local tempToPercent = {}
		for k,v in pairs(totalAttrList) do
			table.insert(tempToPercent, k , v)
			local needPercent = ConfigFunc:fightAttrIsPercentByValue(k)
			if needPercent then
				local tempV = tostring(tonumber(v) / 100) .. "%"	
				table.insert(tempToPercent, k , tempV)
			end
		end
		return tempToPercent
	end 

	local totalAttrList = dataHandle()

	--黑色底层
	local bgLayer = cc.LayerColor:create(cc.c4b(0, 0, 0, 150))
	bgLayer:setContentSize(640, 1136)
	self.mSubLayer:addChild(bgLayer)
	
	--背景图
	local showBgSprite = ui.newScale9Sprite("mrjl_02.png", cc.size(520, 400))
	showBgSprite:setPosition(320, 568)
	bgLayer:addChild(showBgSprite)
	local bgSize = showBgSprite:getContentSize()
	--标题
	local titleLabel = ui.newLabel({
		text = TR("属性总览"),
		size = 30,
        color = cc.c3b(0xff, 0xee, 0xd0),
        outlineColor = cc.c3b(0x3a, 0x24, 0x18),
        outlineSize = 2,
		}) 
	titleLabel:setPosition(bgSize.width * 0.5, bgSize.height * 0.9 + 5)
	showBgSprite:addChild(titleLabel)
	
	--灰色背景
	local greyBgSprite = ui.newScale9Sprite("c_17.png", cc.size(460, 220))
	greyBgSprite:setPosition(bgSize.width * 0.5, bgSize.height * 0.5 + 25)
	showBgSprite:addChild(greyBgSprite)
	--文字背景图
	local wordBgSprite = ui.newScale9Sprite("c_18.png", cc.size(450, 210))
	wordBgSprite:setPosition(bgSize.width * 0.5, bgSize.height * 0.5 + 25)
	showBgSprite:addChild(wordBgSprite)

	local attrLabelList = {}
	for k,v in pairs(totalAttrList) do
		local attrLabel = ui.newLabel({
			text = TR("%s + %s", FightattrName[k], v),
			size = 24,
			color = Enums.Color.eBlack,
			})
		attrLabel:setAnchorPoint(0, 0.5)
		showBgSprite:addChild(attrLabel)
		table.insert(attrLabelList, attrLabel)  
	end
	local LableposX = 0
	local LableposY = 0
	for i,v in ipairs(attrLabelList) do
		if i == 1 then
			LableposX = bgSize.width * 0.25 - 55
			LableposY = 300
		elseif i%2 == 0 then
			LableposX = LableposX + 200
			-- LableposY = LableposY - 40*(i%2)(i - 1)
		else
			LableposX = LableposX - 200
			LableposY = LableposY - 40*(math.floor(i/2))
		end
		v:setPosition(LableposX, LableposY)
	end
	
	--确定按钮
	local okBtn = ui.newButton({
		normalImage = "c_28.png",
		text = TR("确定"),
		outlineColor = cc.c3b(0x8e, 0x4f, 0x09),
		clickAction = function ( )
			bgLayer:removeFromParent()
		end
		})
	okBtn:setPosition(bgSize.width * 0.5, bgSize.height * 0.18)
	showBgSprite:addChild(okBtn)
end

--拜师刷新
function BsxyLayer:refresBaishiStatus()
	if self.mIsUnLock then
		self.mBsBgSprite:removeFromParent()
		self.mAttrTotalBtn:setEnabled(true)
	end
end

--显示送礼界面
function BsxyLayer:refreshGiftShow()
	self.mBottomBgSprite:setContentSize(cc.size(640, 384))
	local bgSize = self.mBottomBgSprite:getContentSize()
	self.mPerferDeep:setPosition(bgSize.width * 0.1, bgSize.height - 70)
	self.mPerferBar:setPosition(bgSize.width * 0.5, bgSize.height - 110)
	for i = 1, #self.mHeartList do
		self.mHeartList[i]:setPosition(bgSize.width * 0.2 + (40*i), bgSize.height - 70)
	end
	self.mTitleSprite:setPosition(320, 360)
	self.mGiftBtn:setVisible(false)
	self.mAttrTotalBtn:setVisible(false)
	self.mAttrBgSprtie:setVisible(false)
	self.mGiftBgSprite:setVisible(true)
	self.mIntroBgSprite:setPosition(450, 801)

end

--隐藏送礼界面
function BsxyLayer:refreshGiftHide()
	self.mBottomBgSprite:setContentSize(cc.size(640, 324))
	local bgSize = self.mBottomBgSprite:getContentSize()
	self.mPerferDeep:setPosition(bgSize.width * 0.1, bgSize.height - 80)
	self.mPerferBar:setPosition(bgSize.width * 0.5, bgSize.height - 120)
	for i = 1, #self.mHeartList do
		self.mHeartList[i]:setPosition(bgSize.width * 0.2 + (40*i), bgSize.height - 80)
	end
	self.mTitleSprite:setPosition(320, 300)
	self.mGiftBtn:setVisible(true)
	self.mAttrTotalBtn:setVisible(true)
	self.mAttrBgSprtie:setVisible(true)
	self.mGiftBgSprite:setVisible(false)
	self.mIntroBgSprite:setPosition(450, 727)
end


function BsxyLayer:getRestoreData()
	local retData = {
		selectIndex = self.mSelectIndex,
	}
	return retData
end
--------------------------------------网络相关----------------------
--获取师傅信息
function BsxyLayer:requestGetTeacherInfo(index)
	HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "TeacherInfo",
        methodName = "GetTeacherInfo",
        svrMethodData = {index},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            self.mIsUnLock = response.Value.TeachInfo.IsLock
            self.mLockInfo = response.Value.TeachInfo.LockStatus
            self.mTeacherInfo = response.Value.TeachInfo            
            self.mNeedGame = response.Value.TeachInfo.NeedSmallGame
    		self.mOldLv = self.mTeacherInfo.Lv
    		self.mStepNum = self:handleStepNum()
    		self.mOldStepNum = self.mStepNum

			self.mSubLayer:removeAllChildren()
			self:refreshLockInfo()
        	self:createInfoView(index)
			self:createBottomView(index)

			-- 执行新手引导
			self:executeGuide()
        end
    })
end
--送礼接口
function BsxyLayer:requestSendGift(index)
	HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "TeacherInfo",
        methodName = "SendGift",
        svrMethodData = {index},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            self.mTeacherInfo = response.Value.TeachInfo
            self.mNeedGame = response.Value.TeachInfo.NeedSmallGame
            self.mIsNewTal = response.Value.ChoiceTalent
            self.mOldTalNum = 0
            self.mStepNum = self:handleStepNum()
            local action = cc.Sequence:create({
            	cc.CallFunc:create(function()
            		if self.mOldLv ~= self.mTeacherInfo.Lv then
            			ui.newEffect({
            				parent = self.mHeartList[self.mTeacherInfo.Lv],
					        effectName = "effect_ui_tianfu",
					        position = cc.p(17, 16),
					        loop = true,
					        animation = "taoxin",
        				})
        				MqAudio.playEffect("baishi_up.mp3")
            			self.mPerferBar:setCurrValue(self.mMaxExp)
            			if self.mOldStepNum ~= self.mStepNum then
            				ui.newEffect({
	            				parent = self.mEffStdLayer,
						        effectName = "effect_ui_baishishengji",
						        zorder = 1000000,
						        position = cc.p(320, 405),
						        -- loop = true,
        					})
            			end
            		else
            			self.mPerferBar:setCurrValue(self.mTeacherInfo.Exp)
            		end
            	end),
            	cc.DelayTime:create(0.5),
            	cc.CallFunc:create(function()
            		self.mOldLv = self.mTeacherInfo.Lv
    				self.mOldStepNum = self.mStepNum
            		self.mSubLayer:removeAllChildren()
		        	self:createInfoView(index)
					self:createBottomView(index)
					if self.mTeacherInfo.Lv < MAXLV then
						self:refreshGiftShow()
					end
            	end),
            	})
			self:runAction(action)

        end
    })
end

function BsxyLayer:handleStepNum()
	local tempNum
	if self.mTeacherInfo.Lv <= 10 then
		tempNum = 0
	else
		tempNum = math.floor((self.mTeacherInfo.Lv-1) / 10)
	end
	return tempNum
end

--拜师接口
function BsxyLayer:requestBaishi(index)
	HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "TeacherInfo",
        methodName = "UnLock",
        svrMethodData = {index},
        guideInfo = Guide.helper:tryGetGuideSaveInfo(10902),
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            self.mIsUnLock = response.Value.TeachInfo.IsLock
            self.mLockInfo = response.Value.TeachInfo.LockStatus
            ui.showFlashView(TR("拜师成功"))
            self.mTeacherInfo = response.Value.TeachInfo
    		self.mOldLv = self.mTeacherInfo.Lv
    		self.mOldStepNum = self:handleStepNum()

			self.mSubLayer:removeAllChildren()
			self:refreshLockInfo()
        	self:createInfoView(index)
			self:createBottomView(index)

            --[[--------新手引导--------]]--
            local _, _, eventID = Guide.manager:getGuideInfo()
            if eventID == 10902 then
                -- 不删除引导界面，后续还在此界面引导
                Guide.manager:nextStep(eventID)
                self:executeGuide()
            end
        end
    })
end
--获取属性总览
function BsxyLayer:requestGetAttrInfo()
	HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "TeacherInfo",
        methodName = "GetAttrInfo",
        svrMethodData = {index},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end

            self.mAttrInfo = response.Value
			self:createAttrView()
        end
    })
end

-- ========================== 新手引导 ===========================
-- 执行新手引导
function BsxyLayer:executeGuide()
	local _, _, eventID = Guide.manager:getGuideInfo()
    if eventID == 10902 and GoodsObj:getCountByModelId(16040010) == 0 then
        -- 未找到拜师贴，退出引导
        Guide.helper:guideError(eventID, -1)
        return
    end
    Guide.helper:executeGuide({
        -- 点击拜师
        [10902] = {clickNode = self.bstBtn},
        -- 点击送礼
        [10904] = {clickNode = self.mGiftBtn},
    })
end

return BsxyLayer