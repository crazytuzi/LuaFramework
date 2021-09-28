--[[
	NationalSaiziSubLayer.lua
	描述：节日活动摇塞子的分页面
	创建人: lichunsheng
	创建时间: 2017.09.22
--]]

local NationalSaiziSubLayer = class("NationalSaiziSubLayer", function()
	return display.newLayer(cc.c4b(0, 0, 0, 150))
end)


-- 构造函数
--[[
	params说明：
		subLayerType：活动页面的tag值
		guid: 相关活动数据
]]
function NationalSaiziSubLayer:ctor(params)
	--判断启动self监听
	self.mTouchTag = 0
	--屏蔽下册触控
	ui.registerSwallowTouch({node = self,
							 endedEvent = function(pSender)
								 if self.mTouchTag == 1 then
									LayerManager.removeLayer(self)
								 end
							end})
	-- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

	--副本类型(1:答题，2:挑战)
	self.mActivtyType = params.subLayerType or 0
	self.mGuid = params.guid
	self.callback = params.callback

	--答案的table
	self.mAnswerList = {}
	--问答表
	self.mAQData = clone(DiceQaModel.items) or {}

	-- 初始化UI
	self:initUI()
end

-- 初始化UI
function NationalSaiziSubLayer:initUI()
	--触发活动
	if self.mActivtyType == 1 then
		self:requestGetQaInfo()
	elseif self.mActivtyType == 2 then
		self:requestGetChallengeInfo()
	end
end

--触发挑战
function NationalSaiziSubLayer:openFight()
	local mBgSprite = ui.newScale9Sprite("c_30.png", cc.size(555, 405))
	mBgSprite:setPosition(320, 568)
	self.mParentLayer:addChild(mBgSprite)

	-- 显示弹出动画
	ui.showPopAction(mBgSprite)

	--返回按钮
	local closeBtn = ui.newButton({
		normalImage = "c_29.png",
        clickAction = function()
			LayerManager.removeLayer(self)
        end,
	})
	closeBtn:setPosition(cc.p(515, 380))
	mBgSprite:addChild(closeBtn)

	-- 人物背景光
	local heroBgSprite = ui.newSprite("fb_32.png")
	heroBgSprite:setAnchorPoint(cc.p(0.5, 0))
	heroBgSprite:setPosition(cc.p(155, 80))
	mBgSprite:addChild(heroBgSprite)

	-- 当前关卡人物形象
	dump(self.mShowFightData, "战斗人物信息：")
	local heorId = DiceChallengeModel.items[self.mShowFightData.TargetId].heroModelId or "12011301"
	local heroFigure = Figure.newHero({
		parent = mBgSprite,
		heroModelID = heorId,
		scale = 0.22,
		position = cc.p(155, 90),
		needAction = true,
	})

	-- 显示名字
	local name = HeroModel.items[heorId].name or ""
	local nameLabel = ui.newLabel({
		text = name,
		size = 30,
		color = cc.c3b(0x46, 0x22, 0x0d),
	})
	nameLabel:setAnchorPoint(cc.p(0, 0.5))
	nameLabel:setPosition(300, 310)
	mBgSprite:addChild(nameLabel)

	-- 显示战斗力
	local fightNum = self.mShowFightData.FAP or 0
	local text = TR("战力:#258711%s", Utility.numberWithUnit(fightNum))
	local fightLabel = ui.newLabel({
		text = text,
		size = 24,
		color = cc.c3b(0x46, 0x22, 0x0d)
	})
	fightLabel:setAnchorPoint(cc.p(0, 0.5))
	fightLabel:setPosition(300, 270)
	mBgSprite:addChild(fightLabel)

	--显示剩余血量百分比
	local curHp = self.mShowFightData.CurHP or 0
	local totalHP = self.mShowFightData.TotalHP or 0
	local count = math.floor((self.mShowFightData.CurHP / self.mShowFightData.TotalHP) * 100)
	local hpLabel = ui.newLabel({
		text = TR("剩余血量:#258711%s%%", count),
		size = 24,
		color = cc.c3b(0x46, 0x22, 0x0d)
	})
	hpLabel:setAnchorPoint(cc.p(0, 0.5))
	hpLabel:setPosition(300, 230)
	mBgSprite:addChild(hpLabel)

	-- 显示布阵按钮
	local changeTeamBtn = ui.newButton({
		normalImage = "tb_11.png",
		clickAction = function()
			LayerManager.addLayer({name = "team.CampLayer", cleanUp = false,})
		end
	})
	changeTeamBtn:setPosition(475, 180)
	mBgSprite:addChild(changeTeamBtn)

	-- 显示开始挑战按钮
	 local fightBtn = ui.newButton({
		normalImage = "c_28.png",
		text = TR("开始挑战"),
		clickAction = function()
			-- 判断体力是否足够
			if not Utility.isResourceEnough(ResourcetypeSub.eVIT, VitConfig.items[1].perUseNum, true) then
				return
			end
			-- 判断背包是否已满
			if not Utility.checkBagSpace(nil, true) then
				return
			end
			self:requestGetChallengeFightInfo()
		end,
	})
	fightBtn:setPosition(400, 70)
	mBgSprite:addChild(fightBtn)

	-- 显示放弃按钮
	-- local sweepBtn = ui.newButton({
	-- 	normalImage = "c_28.png",
	-- 	text = TR("放 弃"),
	-- 	clickAction = function()
	-- 		LayerManager.removeLayer(self)
	-- 	end,
	-- })
	-- sweepBtn:setPosition(450, 70)
	-- mBgSprite:addChild(sweepBtn)
end

--答题
function NationalSaiziSubLayer:openAnswerQuiction()
	local questionInfo = self.mAQData[self.mTargetId].question

	-- 背景
	local bgSprite = ui.newSprite("jrhd_23.png")
	local bgSize = bgSprite:getContentSize()
	bgSprite:setPosition(320, 568)
	self.mParentLayer:addChild(bgSprite)

	-- 问题label
	local quesionLabel = ui.newLabel({
		text = questionInfo,
		color = Enums.Color.eBlack,
		size = 22,
		dimensions = cc.size(bgSize.width*0.8, 0),
		x = 80,
		y = bgSize.height - 120
		})
	quesionLabel:setAnchorPoint(cc.p(0, 0.5))
	bgSprite:addChild(quesionLabel)

	--获取不重复的随机数
	function RandomIndex(tabNum,indexNum)
		indexNum = indexNum or tabNum
		local t = {}
		local rt = {}
		for i = 1,indexNum do
			local ri = math.random(1,tabNum + 1 - i)
			local v = ri
			for j = 1,tabNum do
				if not t[j] then
					ri = ri - 1
					if ri == 0 then
						table.insert(rt,j)
						t[j] = true
					end
				end
			end
		end
		return rt
	end
	local randomTable = RandomIndex(4, 4)

	--答案整理
	self.mAnswerTable = {}
	table.insert(self.mAnswerTable, self.mAQData[self.mTargetId].answer)
	table.insert(self.mAnswerTable, self.mAQData[self.mTargetId].wrong1)
	table.insert(self.mAnswerTable, self.mAQData[self.mTargetId].wrong2)
	table.insert(self.mAnswerTable, self.mAQData[self.mTargetId].wrong3)
	-- 答案
	for index, items in pairs(randomTable) do
		self:createAnswerBox(items, index)
	end
end

--[[
	描述：创建答案ui
	参数：
		index:第index个答案
		tag：位置的tag
]]
function NationalSaiziSubLayer:createAnswerBox(index, tag)
	--答案位置
	local answerPostion = {
		[1] = cc.p(200, 530),
		[2] = cc.p(460, 530),
		[3] = cc.p(200, 450),
		[4] = cc.p(460, 450),
	}

	local answerPos = answerPostion[tag]

	--答案内容
	local text = self.mAnswerTable[index]

	-- 答案背景图
	local answerBgSize = cc.size(228, 50)
	local answerBg = ui.newScale9Sprite("cdjh_9.png", answerBgSize)
	answerBg:setPosition(answerPos)
	self.mParentLayer:addChild(answerBg)

	-- 答案复选框
	local answerBox = ui.newCheckbox({
		normalImage = "c_60.png",
		selectImage = "c_61.png",
		text = text,
		textColor = Enums.Color.eBlack,
		callback = function ()
			local isCorrect = false
			--找出正确答案的index
			if text == self.mAQData[self.mTargetId].answer then
				isCorrect = true
			end
			--找出正确答案的index
			local correctIndex = 0
			for key, value in pairs(self.mAnswerTable) do
				if value == self.mAQData[self.mTargetId].answer then
					correctIndex = key
					break
				end
			end

			--判断答题是否正确
			self:requestDiceQaOp(isCorrect, index, correctIndex)
		end
		})
	answerBox:setAnchorPoint(cc.p(0, 0.5))
	answerBox:setPosition(30, answerBgSize.height / 2)
	answerBg:addChild(answerBox)

	self.mAnswerList[index] = answerBox

	return answerBg
end

--================网络数据=================
--	获取挑战副本信息
function NationalSaiziSubLayer:requestGetChallengeInfo()
	HttpClient:request({
		moduleName = "TimedDiceInfo",
		methodName = "GetChallengeInfo",
		svrMethodData = {self.mGuid},
		callbackNode = self,
		callback = function(response)
			if not response or response.Status ~= 0 then
				return
			end
			self.mShowFightData = response.Value
			self:openFight()
		end
	})
end

--	获取寻宝挑战副本战斗信息
function NationalSaiziSubLayer:requestGetChallengeFightInfo()
	HttpClient:request({
		moduleName = "TimedDiceInfo",
		methodName = "GetChallengeFightInfo",
		svrMethodData = {self.mGuid},
		callbackNode = self,
		callback = function(response)
			if not response or response.Status ~= 0 then
				return
			end
			--调用战斗
			local guildData = clone(self.mGuid)
			local fightData = response.Value.FightInfo
			local controlParams = Utility.getBattleControl(ModuleSub.eQuickExpMeetChallenge)
			LayerManager.addLayer({
				name = "ComBattle.BattleLayer",
				data = {
					data = fightData,
					skip = controlParams.skip,
					trustee = controlParams.trustee,
					map = Utility.getBattleBgFile(ModuleSub.eQuickExpMeetChallenge),
					callback = function(ret)
						CheckPve.requestVerifyChallengeFightInfo(guildData, ret)
					end
				},
			})
		end
	})
end


--获取寻宝答题副本信息
function NationalSaiziSubLayer:requestGetQaInfo()
	HttpClient:request({
		moduleName = "TimedDiceInfo",
		methodName = "GetQaInfo",
		svrMethodData = {self.mGuid},
		callbackNode = self,
		callback = function(response)
			if not response or response.Status ~= 0 then
				return
			end
			--问题配置id
			self.mTargetId = response.Value.TargetId
			self:openAnswerQuiction()
		end
	})
end

--获取当前答题信息
--[[
	isCorrect：是否正确
	index：选择问题的结果
	correctIndex:正确答案的index
]]
function NationalSaiziSubLayer:requestDiceQaOp(isCorrect, index, correctIndex)
    HttpClient:request({
        moduleName = "TimedDiceInfo",
        methodName = "DiceQaOp",
        svrMethodData = {self.mGuid, isCorrect},
        callbackNode = self,
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
			local topSprite = isCorrect and "cdjh_63.png" or "cdjh_64.png"

			local addSprite = {
				[1] = {
					["node"] = ui.newSprite(topSprite),
					["position"] = cc.p(320, 180)
				}
			}
			LayerManager.addLayer({
				name = "commonLayer.FlashDropLayer",
				data = {baseDrop = response.Value.BaseGetGameResourceList, customAdd = addSprite},
				cleanUp = false}
			)

			--刷新
			if not isCorrect and correctIndex ~= 0 then
				self.mAnswerList[correctIndex]:setCheckState(true)
				self.mAnswerList[index].button:loadTextures("c_136.png", "c_136.png")
			end

			for index, item in ipairs(self.mAnswerList) do
				item:setTouchEnabled(false)
			end

			self.mTouchTag = 1

			if self.callback then
            	self.callback()
            end
			--LayerManager.removeLayer(self)

        end
    })
end


return NationalSaiziSubLayer
