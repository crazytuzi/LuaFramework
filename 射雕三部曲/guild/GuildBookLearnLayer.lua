--[[
    文件名：GuildBookLearnLayer.lua
    描述：帮派秘籍学习
    创建人：yanghongsheng
    创建时间：2018.1.26
-- ]]

local GuildBookLearnLayer = class("GuildBookLearnLayer", function(params)
    return display.newLayer(cc.c4b(0, 0, 0, 128))
end)

--[[
	params:
		cheatsId 	秘籍id
		callback	回调
]]

function GuildBookLearnLayer:ctor(params)
	self.mCheatsId = params.cheatsId
	self.callback = params.callback

	-- 招式数据
	self.mBookInfoList = {}
	-- 当前学习的总次数
	self.mTotalStep = 0
	-- 需要学习的总次数
	self.mTotalLearnNum = 0

	--屏蔽下层触控
    ui.registerSwallowTouch({node = self})
    -- 创建标准容器
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    -- 初始化
    self:initUI()

    self:requestInfo()
end

function GuildBookLearnLayer:initData(ServerBookData)
	self.mBookInfoList = {}
	self.mTotalStep = 0
	self.mTotalLearnNum = 0

	for _, bookInfo in pairs(clone(GuildBookModel.items)) do
		-- 表中数据
		if bookInfo.bookID == self.mCheatsId then
			self.mBookInfoList[bookInfo.ID] = bookInfo

			self.mTotalLearnNum = self.mTotalLearnNum + bookInfo.learnNum
		end
	end

	-- 服务器数据
	if ServerBookData then
		for _, bookStepInfo in pairs(ServerBookData.BookInfo or {}) do
			self.mBookInfoList[bookStepInfo.BookId].Step = bookStepInfo.Step

			self.mTotalStep = self.mTotalStep + bookStepInfo.Step
		end
	end

	local tempList = {}
	for _, bookInfo in pairs(self.mBookInfoList) do
		table.insert(tempList, bookInfo)
	end
	self.mBookInfoList = tempList

	-- 排序
	table.sort(self.mBookInfoList, function (item1, item2)
		local isOver1 = (item1.Step or 0) >= item1.learnNum
		local isOver2 = (item2.Step or 0) >= item2.learnNum

		-- 是否学完（学完放后面）
		if isOver1 ~= isOver2 then
			return not isOver1
		end

		return item1.ID < item2.ID
	end)
	
end

function GuildBookLearnLayer:initUI()
	-- 创建页面背景
    local bgSprite = ui.newSprite("bpz_49.png")
    bgSprite:setPosition(320, 568)
    self.mParentLayer:addChild(bgSprite)

    local bgSize = bgSprite:getContentSize()

    -- 秘籍题目
    local titleSprite = ui.newSprite(GuildLibraryModel.items[self.mCheatsId].smallPic..".png")
    titleSprite:setPosition(bgSize.width*0.5, bgSize.height-100)
    bgSprite:addChild(titleSprite)

    -- 当前学习总进度
    local totalStepNode, totalStepLabel = ui.createSpriteAndLabel({
    		imgName = "bpz_55.png",
    		labelStr = "0",
    		fontSize = 22,
    		fontColor = cc.c3b(0x46, 0x22, 0x0d),
    	})
    totalStepNode:setPosition(bgSize.width*0.8, bgSize.height-170)
    bgSprite:addChild(totalStepNode)
    self.mTotalStepLabel = totalStepLabel

    -- 当前代币数
    local daibiImage = Utility.getDaibiImage(ResourcetypeSub.eGuildGongfuCoin)
    local ownCoin = Utility.getOwnedGoodsCount(ResourcetypeSub.eGuildGongfuCoin)
    local coinLabel = ui.newLabel{
    	text = string.format("{%s}%d", daibiImage, ownCoin),
    	color = cc.c3b(0x46, 0x22, 0x0d),
    	size = 24,
	}
	coinLabel:setPosition(bgSize.width*0.2, bgSize.height-170)
	bgSprite:addChild(coinLabel)
	self.mCoinLabel = coinLabel

	self.mCoinLabel.refreshNumber = function (Obj)
		local ownCoin = Utility.getOwnedGoodsCount(ResourcetypeSub.eGuildGongfuCoin)
		Obj:setString(string.format("{%s}%d", daibiImage, ownCoin))
	end

    -- 秘籍列表
    self.mBookListView = ccui.ListView:create()
	self.mBookListView:setDirection(ccui.ScrollViewDir.vertical)
	self.mBookListView:setContentSize(cc.size(560, 720))
	self.mBookListView:setAnchorPoint(cc.p(0.5, 0))
	self.mBookListView:setPosition(bgSize.width*0.5-2, 25)
	bgSprite:addChild(self.mBookListView)

	-- 上箭头
	local upArrow = ui.newSprite("c_43.png")
	upArrow:setRotation(180)
	upArrow:setPosition(bgSize.width*0.5, bgSize.height-190)
	bgSprite:addChild(upArrow)

	-- 下箭头
	local downArrow = ui.newSprite("c_43.png")
	downArrow:setPosition(bgSize.width*0.5, 20)
	bgSprite:addChild(downArrow)

	-- 关闭按钮
    self.mCloseBtn = ui.newButton({
        normalImage = "c_29.png",
        clickAction = function()
            LayerManager.removeLayer(self)
        end
    })
    self.mCloseBtn:setPosition(cc.p(590, 980))
    self.mParentLayer:addChild(self.mCloseBtn)
end

function GuildBookLearnLayer:createItem(itemInfo)
	-- 大小
	local cellSize = cc.size(self.mBookListView:getContentSize().width, 120)

	-- 项
	local cellItem = ccui.Layout:create()
	cellItem:setContentSize(cellSize)

	-- 背景
	local cellBg = ui.newSprite("bpz_52.png")
	cellBg:setAnchorPoint(cc.p(0.5, 0))
	cellBg:setPosition(cellSize.width*0.5, 0)
	cellItem:addChild(cellBg)

	-- title
	local titleSprite = ui.newSprite(itemInfo.pic..".png")
	titleSprite:setAnchorPoint(cc.p(0, 0.5))
	titleSprite:setPosition(cellSize.width*0.05, cellSize.height*0.5)
	cellItem:addChild(titleSprite)

	-- 当前学习进度
	local curStep = itemInfo.Step or 0
	
	-- 招式（天赋）
	if itemInfo.attrStr == "" and itemInfo.TALModelID ~= 0 then
		local talIntro = TalModel.items[itemInfo.TALModelID].intro
		local talDescLabel = ui.newLabel({
				text = talIntro,
				color = cc.c3b(0x46, 0x22, 0x0d),
				size = 22,
				align = ui.TEXT_ALIGN_CENTER,
				dimensions = cc.size(cellSize.width*0.5, 0)
			})
		talDescLabel:setAnchorPoint(cc.p(0.5, 0.5))
		talDescLabel:setPosition(cellSize.width*0.5, cellSize.height*0.6)
		cellItem:addChild(talDescLabel)
	-- 绝学（时装）
	elseif itemInfo.attrStr == "" and itemInfo.fashionID ~= 0 then
		local fashionName = FashionModel.items[itemInfo.fashionID].name
		local fashionLabel = ui.newLabel({
				text = TR("绝学: ")..fashionName,
				color = cc.c3b(0x46, 0x22, 0x0d),
				size = 22,
			})
		fashionLabel:setAnchorPoint(cc.p(0.5, 0.5))
		fashionLabel:setPosition(cellSize.width*0.5, cellSize.height*0.6)
		cellItem:addChild(fashionLabel)
	-- 心法（加属性）
	elseif itemInfo.attrStr ~= "" then
		local curTextList = {}	-- 当前加成字符串列表
		local nextTextList = {}	-- 下一级加成字符串列表

		-- 填充字符串列表
		local attrList = Utility.analysisStrAttrList(itemInfo.attrStr)
		for _, attrInfo in pairs(attrList) do
			local curValueText = Utility.getAttrViewStr(attrInfo.fightattr, attrInfo.value*curStep, true)
			local nextValueText = Utility.getAttrViewStr(attrInfo.fightattr, attrInfo.value*(curStep+1), true)

			curValueText = "#249029"..curValueText
			nextValueText = "#249029"..nextValueText

			curValueText = "#46220d"..FightattrName[attrInfo.fightattr]..curValueText
			nextValueText = "#46220d"..nextValueText

			table.insert(curTextList, curValueText)
			table.insert(nextTextList, nextValueText)
		end

		-- 当前加成显示
		local curAttrLabel = ui.newLabel({
				text = table.concat(curTextList, ", "),
				color = cc.c3b(0x46, 0x22, 0x0d),
				size = 22,
			})
		curAttrLabel:setAnchorPoint(cc.p(0.5, 0.5))
		curAttrLabel:setPosition(cellSize.width*0.5, cellSize.height*0.8)
		cellItem:addChild(curAttrLabel)

		-- 下一级加成显示
		local nextAttrLabel = ui.newLabel({
				text = TR("下一级: ")..table.concat(nextTextList, ", "),
				color = cc.c3b(0x46, 0x22, 0x0d),
				size = 22,
			})
		nextAttrLabel:setAnchorPoint(cc.p(0.5, 0.5))
		nextAttrLabel:setPosition(cellSize.width*0.5, cellSize.height*0.5)
		cellItem:addChild(nextAttrLabel)

		-- 学满
		if curStep >= itemInfo.learnNum then
			curAttrLabel:setPosition(cellSize.width*0.5, cellSize.height*0.6)
			nextAttrLabel:setVisible(false)
		end
	end

	-- 当前学习次数显示
	local stepLabel = ui.newLabel({
			text = TR("当前重数: %s%d/%d", "#d17b00", curStep, itemInfo.learnNum),
			color = cc.c3b(0x46, 0x22, 0x0d),
			size = 22,
		})
	stepLabel:setAnchorPoint(cc.p(0.5, 0.5))
	stepLabel:setPosition(cellSize.width*0.5, cellSize.height*0.2)
	cellItem:addChild(stepLabel)

	-- 帮派武技消耗列表
	local stepUseList = self:anlaysisUseList(itemInfo.gongfuCoinConsum)
	-- 当前拥有帮派武技
	local ownCoin = Utility.getOwnedGoodsCount(ResourcetypeSub.eGuildGongfuCoin)

	-- 已学完
	if itemInfo.learnNum <= curStep then
		local completeSprite = ui.newSprite("bpz_54.png")
		completeSprite:setPosition(cellSize.width*0.85, cellSize.height*0.5)
		cellItem:addChild(completeSprite)
	-- 学习重数不足
	elseif itemInfo.needLearnNum > self.mTotalStep then
		local learnHintLabel = ui.newLabel({
				text = TR("%s\n%d重解锁", GuildLibraryModel.items[itemInfo.bookID].name, itemInfo.needLearnNum),
				color = Enums.Color.eRed,
				size = 22,
				align = ui.TEXT_ALIGN_CENTER,
				dimensions = cc.size(cellSize.width*0.2, 0)
			})
		learnHintLabel:setAnchorPoint(cc.p(0.5, 0.5))
		learnHintLabel:setPosition(cellSize.width*0.85, cellSize.height*0.5)
		cellItem:addChild(learnHintLabel)
	else
		-- 按钮
		local learnBtn = ui.newButton({
				normalImage = "bpz_51.png",
				clickAction = function ()
					-- 帮派武技是否足够
					if ownCoin < stepUseList[curStep+1] then
						ui.showFlashView({text = TR("%s不足", Utility.getGoodsName(ResourcetypeSub.eGuildGongfuCoin))})
						return
					end

					-- 学习次数是否达到要求
					if itemInfo.needLearnNum > self.mTotalStep then
						ui.showFlashView({text = TR("该秘籍需要先学习到%d重", itemInfo.needLearnNum)})
						return
					end
					local pos = self.mBookListView:getInnerContainerPosition()
					self:requestLearn(itemInfo.ID, pos, cellItem)
				end
			})
		learnBtn:setPosition(cellSize.width*0.85-5, cellSize.height*0.6)
		cellItem:addChild(learnBtn)
		-- 消耗
		local daibiImage = Utility.getDaibiImage(ResourcetypeSub.eGuildGongfuCoin)
		local useLabel = ui.newLabel({
				text = TR("{%s}%s", daibiImage, stepUseList[curStep+1]),
				color = cc.c3b(0x46, 0x22, 0x0d),
				size = 22,
			})
		useLabel:setPosition(cellSize.width*0.83, cellSize.height*0.25)
		cellItem:addChild(useLabel)
	end

	return cellItem
end

function GuildBookLearnLayer:anlaysisUseList(str)
	local stepUseStrList = string.splitBySep(str or "", ",")
	local stepUseList = {}

	for _, useStr in pairs(stepUseStrList) do
		local useInfo = string.splitBySep(useStr or "", "|")
		stepUseList[tonumber(useInfo[1])] = tonumber(useInfo[2])
	end

	return stepUseList
end

function GuildBookLearnLayer:createEmptyItem()
	-- 大小
	local cellSize = cc.size(self.mBookListView:getContentSize().width, 120)

	-- 项
	local cellItem = ccui.Layout:create()
	cellItem:setContentSize(cellSize)

	-- 背景
	local cellBg = ui.newSprite("bpz_52.png")
	cellBg:setAnchorPoint(cc.p(0.5, 0))
	cellBg:setPosition(cellSize.width*0.5, 0)
	cellItem:addChild(cellBg)

	return cellItem
end

function GuildBookLearnLayer:refreshList()

	self.mBookListView:removeAllChildren()

	for _, bookInfo in ipairs(self.mBookInfoList) do
		-- 创建项
		if bookInfo.fashionID == 0 then -- 不现实绝学项
			local item = self:createItem(bookInfo)
			self.mBookListView:pushBackCustomItem(item)
		end
	end

	for i = 1, 6 - #self.mBookInfoList do
		-- 创建空项
		local item = self:createEmptyItem()
		self.mBookListView:pushBackCustomItem(item)
	end
end

-- 去领悟绝学弹窗
function GuildBookLearnLayer:createSkipLayer()
    if self.mTotalStep >= GuildLibraryModel.items[self.mCheatsId].fashionNeedLearnNum then
	    self.hintBox = MsgBoxLayer.addOKCancelLayer(
	        TR("恭喜少侠学完秘籍，是否立即前往领悟绝学?"),
	        TR("提示"),
            {
                text = TR("前往"),
                clickAction = function ()
                    LayerManager.addLayer({
                    		name = "guild.GuildBookOverViewLayer",
                    	})
                end,
            },
            {
                text = TR("稍后再说"),
                clickAction = function ()
                    LayerManager.removeLayer(self.hintBox)
                end,
            },
	        {}
	    )
	end
end

function GuildBookLearnLayer:refreshUI()
	self.mTotalStepLabel:setString(self.mTotalStep)

	self:refreshList()
end

--====================网络相关==================
-- 秘籍信息
function GuildBookLearnLayer:requestInfo()
	HttpClient:request({
	    moduleName = "Guild",
	    methodName = "GetGuildBookInfo",
	    svrMethodData = {},
	    callback = function (response)
	        if not response or response.Status ~= 0 then
	            return
	        end

	        self:initData(response.Value.GuildBookInfo[tostring(self.mCheatsId)])

		    self:refreshUI()
	    end
	})
end

-- 学习
function GuildBookLearnLayer:requestLearn(id, pos, cellItem)
	HttpClient:request({
	    moduleName = "Guild",
	    methodName = "LearnGuildBook",
	    svrMethodData = {id},
	    callback = function (response)
	        if not response or response.Status ~= 0 then
	            return
	        end

	        ui.showFlashView({text = TR("学习成功")})

	        self:initData(response.Value.GuildBookInfo[tostring(self.mCheatsId)])

	        if self.callback then
	        	self.callback(response)
	        end

	        -- 刷新当前代币数量显示
	        self.mCoinLabel:refreshNumber()

	        -- 去领悟绝学弹窗
	        self:createSkipLayer()

	        -- 播放学习音效
	        MqAudio.playEffect("banghuimiji.mp3")

	        -- 播放学习特效
	        if cellItem and not tolua.isnull(cellItem) then
		        ui.newEffect({
		        		parent = cellItem,
		        		position = cc.p(cellItem:getContentSize().width*0.5, cellItem:getContentSize().height*0.5),
		        		effectName = "effect_ui_bpmj",
		        		loop = false,
		        		endRelease = true,
		        		endListener = function ()
		        			self:refreshUI()

						    -- 滑动列表到当前项
						    Utility.performWithDelay(self, function()
					            self.mBookListView:setInnerContainerPosition(pos)
				            end,0.01)
		        		end
		        	})
		    else
		    	self:refreshUI()

			    -- 滑动列表到当前项
			    Utility.performWithDelay(self, function()
		            self.mBookListView:setInnerContainerPosition(pos)
	            end,0.01)
		    end
	    end
	})
end

return GuildBookLearnLayer