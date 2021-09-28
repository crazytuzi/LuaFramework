--[[
	文件名：TeambattleBossLayer.lua
	描述：西漠BOSS难度选择界面
	创建人：yanxingrui
	创建时间： 2016.7.18
--]]

local TeambattleBossLayer = class("TeambattleBossLayer", function (params)
	return display.newLayer()
end)

local difficultyBtns = {
	-- 四种难度
	{
		pic = "c_86.png",
		pos = cc.p(110, 460)
	},
	{
		pic = "c_87.png",
		pos = cc.p(250, 460)
	},
	{
		pic = "c_89.png",
		pos = cc.p(390, 460)
	},
	{
		pic = "c_90.png",
		pos = cc.p(530, 460)
	}
}

-- 初始化页面
--[[
    params:
    Table params:
    {
        chapterModelID:   章节ID 父页面传值，必要
        crusadeInfo: 节点信息
    }
]]--
function TeambattleBossLayer:ctor(params)
	ui.registerSwallowTouch({node = self})
	if params.chapterModelID == nil then
		return
	end
	-- 章节id
	self.mChapterModelID = params.chapterModelID
	-- 当前选择的难度，1.普通 2.困难 3.噩梦 4.地狱 默认普通
	self.mCurrDiff = 0

	self.mIsBossJimp = true 	--是否显示动画
	self.mIsshow = false		--是否隐藏文字描述和人物下方背景
	-- 节点讨伐信息
	self.mCrusadeInfo = params.crusadeInfo or {}

	--显示难度的标示处理
	local id = self.mChapterModelID - 10
	for key, value in pairs(self.mCrusadeInfo) do
		if key == id then
			for k,v in pairs(value) do
				self.mCurrDiff = self.mCurrDiff + 1
			end
		end
	end

	-- 该页面的Parent
	self.mParentLayer = ui.newStdLayer()
	self:addChild(self.mParentLayer)

	self:initUI()
end

-- 初始化页面控件
function TeambattleBossLayer:initUI()
	-- 背景
	local bgSprite = ui.newSprite("jsxy_20.png")
	bgSprite:setPosition(320, 568)
	self.mParentLayer:addChild(bgSprite)

	-- 难度选择按钮
	local btns = {}
	for index = 1, #difficultyBtns do
		btns[index] = {}
		btns[index].btn = ui.newButton({
			normalImage = difficultyBtns[index].pic,
			text = "",
			fontSize = 20,
			outlineColor = Enums.Color.eBlack,
			titlePosRateY = 0.6,
			clickAction = function()
				if self.mCurrDiff ~= index then
					btns[self.mCurrDiff].light:setVisible(false)
					btns[index].light:setVisible(true)
					self.mCurrDiff = index

					self:refreshLayer(index)
				end
			end
		})
		btns[index].btn:setPosition(difficultyBtns[index].pos)
		self.mParentLayer:addChild(btns[index].btn, 100)
		btns[index].light = ui.newSprite("c_91.png")
		btns[index].light:setPosition(difficultyBtns[index].pos.x, difficultyBtns[index].pos.y+7)
		btns[index].light:setVisible(self.mCurrDiff == index)
		self.mParentLayer:addChild(btns[index].light, 99)

		local nodeId = self.mChapterModelID * 100 + 10 + index
		if PlayerAttrObj:getPlayerAttrByName("Lv") < TeambattleNodeModel.items[nodeId].needLV then
			btns[index].btn:setEnabled(false)

			local lab = ui.newLabel({
    			text = (TR("需等级%s开启", TeambattleNodeModel.items[nodeId].needLV)),
    			color = cc.c3b(0xfe, 0xf5, 0xce),
				outlineColor = cc.c3b(0x4a, 0x2d, 0x0d),
    			size = 18,
    			align = cc.TEXT_ALIGNMENT_CENTER,
    			dimensions = cc.size(150, 0),
    		})
    		lab:setPosition(difficultyBtns[index].pos.x + 5,
    			difficultyBtns[index].pos.y - 65)
    		self.mParentLayer:addChild(lab, 101)
		else
			-- 前置节点
            local qianZhiIDString = TeambattleNodeModel.items[nodeId].needNodeModelID
            if qianZhiIDString ~= "" then
            	local t = string.split(qianZhiIDString, ",")
            	-- 判断开启需要节点是否全都通过，0为全部通过，小于0则表示有未通过的节点
            	local isqianZhiIDDone = false
            	for index, info in ipairs(self.mCrusadeInfo) do
        			for _, key in ipairs(info) do
        				if type(key) == "table" then
			            	for _, value in ipairs(t) do
		            			if key.NodeModelID == tonumber(value) then
		            				if key.SuccessFightCount > 0 then
		                                isqianZhiIDDone = true
		                            end
		            			end
		            		end
		            	end
            		end
            	end


            	if not isqianZhiIDDone then
            		btns[index].btn:setEnabled(false)

            		local termTextLabel = ui.newLabel({
            			text = "",
            			color = cc.c3b(0xfe, 0xf5, 0xce),
						outlineColor = cc.c3b(0x4a, 0x2d, 0x0d),
            			size = 18,
            			align = cc.TEXT_ALIGNMENT_CENTER,
            			dimensions = cc.size(100, 0),
            		})
            		termTextLabel:setPosition(difficultyBtns[index].pos.x ,
            			difficultyBtns[index].pos.y - 65 )
            		self.mParentLayer:addChild(termTextLabel, 101)
           			termTextLabel:setString(TR("需通%s", TeambattleNodeModel.items[tonumber(t[1])].name))
            	end
            end
		end
	end

    -- 布阵按钮
    local layoutBtn = ui.newButton({
        normalImage = "tb_11.png",
        clickAction = function()
            LayerManager.addLayer({
                name = "team.CampLayer",
                cleanUp = false,
            })
        end
    })
    layoutBtn:setPosition(cc.p(585, 570))
    self.mParentLayer:addChild(layoutBtn)

	-- 文字描述背景
	self.TestSprite = ui.newSprite("jsxy_21.png")
	self.TestSprite:setPosition(230, 810)
	self.mParentLayer:addChild(self.TestSprite, 10)

	if self.mIsshow then
		self.TestSprite:setVisible(true)
	else
		self.TestSprite:setVisible(false)
	end
	if self.mIsBossJimp then
		Utility.performWithDelay(self, function()
				self.mRecommendLabel:runAction(cc.MoveTo:create(0.5, cc.p(15, 235)))
				self.testLabel1:runAction(cc.MoveTo:create(0.5, cc.p(45, 45)))
				self.testLabel2:runAction(cc.MoveTo:create(0.5, cc.p(45, -20)))
				self.detailLabel2:runAction(cc.MoveTo:create(0.5, cc.p(45, 15)))
				self.detailLabel3:runAction(cc.MoveTo:create(0.5, cc.p(45, -65)))
	    	end, 0.7)
	end

	self.mRecommendLabel = ui.newLabel({
		text = "",
		size = 21,
		color = cc.c3b(0xd1, 0xcb, 0x6d),
		outlineColor = cc.c3b(0x4a, 0x2d, 0x0d)
	})
    self.mRecommendLabel:setAnchorPoint(0, 0.5)
	self.TestSprite:addChild(self.mRecommendLabel)
	self.mRecommendLabel:setPosition(-200, 235)

	self.testLabel1 = ui.newLabel({
		text = TR("技能效果", Enums.Color.eNormalYellowH),
		size = 26,
		color = cc.c3b(0xff, 0xf5, 0xcd),
		outlineColor = cc.c3b(0xaf, 0x58, 0x23)
	})
    self.testLabel1:setAnchorPoint(0, 0.5)
	self.TestSprite:addChild(self.testLabel1)
	self.testLabel2 = ui.newLabel({
		text = TR("攻略", Enums.Color.eNormalYellowH),
		size = 26,
		color = cc.c3b(0xff, 0xf5, 0xcd),
		outlineColor = cc.c3b(0xaf, 0x58, 0x23)
	})
    self.testLabel2:setAnchorPoint(0, 0.5)
	self.TestSprite:addChild(self.testLabel2)
	self.testLabel1:setPosition(700, 55)
	self.testLabel2:setPosition(700, -15)

	--具体技能描述
	self.detailLabel2 = ui.newLabel({
		text = "",
		size = 20,
		outlineColor = cc.c3b(0x4a, 0x2d, 0x0d)
	})
    self.detailLabel2:setAnchorPoint(0, 0.5)
	self.TestSprite:addChild(self.detailLabel2)
	--具体攻略描述
	self.detailLabel3 = ui.newLabel({
		text = "",
		size = 20,
		outlineColor = cc.c3b(0x4a, 0x2d, 0x0d),
		dimensions = cc.size(430, 0)
	})
    self.detailLabel3:setAnchorPoint(0, 0.5)
	self.TestSprite:addChild(self.detailLabel3)
	self.detailLabel2:setPosition(850, 15)
	self.detailLabel3:setPosition(850, -30)

	-- 首通掉落道具
	self.luckySprite = ui.newSprite("jsxy_22.png")
	self.luckySprite:setPosition(320, 290)
	self.mParentLayer:addChild(self.luckySprite)
    self.luckySprite:setVisible(false)

    -- 产出道具
    local goodsSize = cc.size(580, 170)
    self.goodsSprite = ui.newScale9Sprite("c_65.png", goodsSize)
    self.goodsSprite:setPosition(320, 280)
    self.mParentLayer:addChild(self.goodsSprite)
    self.goodsSprite:setVisible(false)
	self.mLuckyLabel = ui.newLabel({
		text = TR(""),
        color = cc.c3b(0x46, 0x22, 0x0d),
		size = 22,
        font = _FONT_PANGWA,
	})
	self.mLuckyLabel:setPosition(290, 140)
	self.goodsSprite:addChild(self.mLuckyLabel)

	self.cardList = ui.createCardList({
		maxViewWidth = 520,
		cardShape = Enums.CardShape.eCircle,
	})
	self.cardList:setAnchorPoint(cc.p(0.5, 0.5))
	self.cardList:setPosition(320, 250)
	self.mParentLayer:addChild(self.cardList)

	-- 组队开战
	local zhenshouBtn = ui.newButton({
		normalImage = "c_28.png",
		text = TR("组队开战"),
		clickAction = function()
			self:requestMakeTeam(self.mCurrDiff)
		end
	})
	zhenshouBtn:setPosition(320, 148)
	self.mParentLayer:addChild(zhenshouBtn)
	if btns[self.mCurrDiff].btn:isEnabled() == false then
		zhenshouBtn:setEnabled(false)
	else
		zhenshouBtn:setEnabled(true)
	end
    -- 保存按钮，引导使用
    self.zhenshouBtn = zhenshouBtn

	-- 退出按钮
    self.mCloseBtn = ui.newButton({
        normalImage = "c_29.png",
        position = Enums.StardardRootPos.eCloseBtn,
        clickAction = function(pSender)
            LayerManager.removeLayer(self)
        end
    })
    self.mParentLayer:addChild(self.mCloseBtn)

    -- 创建顶部资源
    local topResource = require("commonLayer.CommonLayer"):create({
        needMainNav = true,
        needFAP = true,
        topInfos = {ResourcetypeSub.eVIT, ResourcetypeSub.eGold, ResourcetypeSub.eDiamond},
        currentLayerType = Enums.MainNav.ePractice,
    })
    self:addChild(topResource)
    self:refreshLayer(self.mCurrDiff)
end

-- 选择不同难度时刷新页面
function TeambattleBossLayer:refreshLayer(index)
    self.goodsSprite:setVisible(false)
    self.luckySprite:setVisible(false)
	local nodeId = self.mChapterModelID * 100 + 10 + index
	local diffText = ""
	if index == 1 then
		diffText = TR("简单")
	elseif index == 2 then
		diffText = TR("困难")
	elseif index == 3 then
		diffText = TR("噩梦")
	elseif index == 4 then
		diffText = TR("地狱")
	end

	local node = TeambattleNodeModel.items[nodeId]

	-- 推荐战力
	if PlayerAttrObj:getPlayerAttrByName("FAP") < node.proposeFAP then
		self.mRecommendLabel:setString(TR("个人战力达到%s%s", Enums.Color.eRedH, Utility.numberFapWithUnit(node.proposeFAP)))
	else
		self.mRecommendLabel:setString(TR("个人战力达到%s%s", Enums.Color.eGreenH, Utility.numberFapWithUnit(node.proposeFAP)))
	end

	-- 人物模型
	if self.mBoss then
		self.mBoss:removeFromParent()
		self.mBoss = nil
	end
	self.mBoss = Figure.newHero({
		heroModelID = node.heroModelID,
		scale = 0.25,
	})
	self.mBoss:setPosition(800, 700)
	self.mParentLayer:addChild(self.mBoss)
	self.mBoss:setRotationSkewY(180)
	self.mBoss:runAction(cc.JumpTo:create(0.3, cc.p(425, 660), 90, 1))

	if not self.mIsshow then
		self.mIsshow = true
		Utility.performWithDelay(self, function()
				self.TestSprite:setVisible(true)
	    	end, 0.3)
	end

	if self.mIsBossJimp then
		self.mIsBossJimp = false
		Utility.performWithDelay(self, function()
				self.TestSprite:runAction(cc.Blink:create(0.4, 2))
	    	end, 0.3)
	end

	-- 镇守者详情
	self.detailLabel2:setString(string.format("%s", node.skillChatText))

	self.detailLabel3:setString(string.format("%s", node.strategyText))

	local isPass = false
	for _, temp in ipairs(self.mCrusadeInfo) do
		for _, value in ipairs(temp) do
			if value.NodeModelID == nodeId and value.SuccessFightCount > 0 then
				isPass = true
				break
			end
		end
	end
	local list = {}
	local rewards = ""
	if isPass then
		-- 概率掉落道具
        self.goodsSprite:setVisible(true)
		rewards = node.fightRewards
		self.mLuckyLabel:setString(TR("挑战该关卡，有概率掉落下列道具"))
	else
		-- 首通奖励
        self.luckySprite:setVisible(true)
		rewards = node.firstReward
		-- self.mLuckyLabel:setString(TR("%s首通奖励", Enums.Color.eWhiteH))
	end

	-- 奖励列表
	for i = 1, #Utility.analysisStrResList(rewards) do

        local headerInfo = Utility.analysisStrResList(rewards)[i]
        local card = {
            resourceTypeSub = headerInfo.resourceTypeSub,
            modelId = headerInfo.modelId,
            num = headerInfo.num,
            cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum}
        }

        table.insert(list, card)
    end
	self.cardList.refreshList(list)
end

---------------------------网络请求--------
-- 请求创建队伍
function TeambattleBossLayer:requestMakeTeam(diff)
	local nodeId = self.mChapterModelID * 100 + 10 + diff
	HttpClient:request({
        moduleName = "TeambattleInfo",
        methodName = "GetMyTeamInfo",
        callbackNode = self,
        svrMethodData = {},
        callback = function(response)
        	if not response or response.Status ~= 0 then
        		return
        	end

            if response.Value.IsInTeam == nil then
            	-- 退出队伍
				HttpClient:request({
			        moduleName = "TeambattleInfo",
			        methodName = "DismissTeam",
			        svrMethodData = {nodeId},
			        callback = function(response)
			        end
			    })
            end
        end
    })
	-- 请求创建队伍
	HttpClient:request({
        moduleName = "TeambattleInfo",
        methodName = "CreatTeams",
        callbackNode = self,
        svrMethodData = {nodeId},
        callback = function(response)
            if not response or response.Status ~= 0 then
                return
            end
            LayerManager.addLayer({
            	name = "teambattle.TeambattleMakeTeamLayer",
            	data = {
            		teamInfo = response.Value,
            		nodeId = nodeId,
            		crusadeInfo = self.mCrusadeInfo,
					diffTag = diff,
            	},
            	cleanUp = false,
            })
        end
    })
end

----[[---------------------新手引导---------------------]]--
function TeambattleBossLayer:onEnterTransitionFinish()
    self:executeGuide()
end

-- 执行新手引导
function TeambattleBossLayer:executeGuide()
    Guide.helper:executeGuide({
        -- 组队开战
        [1190301] = {clickNode = self.zhenshouBtn},
    })
end

return TeambattleBossLayer
