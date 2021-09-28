--[[
    文件名: NationalZYTLayer.lua
	描述: 国庆活动——铸倚天
	创建人: lengjiazhi
	创建时间: 2017.09.22
-- ]]
local NationalZYTLayer = class("NationalZYTLayer", function (params)
	return display.newLayer()
end)

function NationalZYTLayer:ctor(params)

	params = params or {}
	-- 活动实体Id列表
	self.mActivityIdList = params.activityIdList
	-- 该活动的主模块Id
	self.mParentModuleId = params.parentModuleId
	-- 该页面的数据信息
	self.mLayerData = params.cacheData


	self.mBoxBtnList = {}
	self:requestGetInfo()

	self.mParentLayer = ui.newStdLayer()
	self:addChild(self.mParentLayer)

	self:initUI()

end

-- 初始化ui
function NationalZYTLayer:initUI()
	--背景图
	local bgSprite = ui.newSprite("jrhd_07.jpg")
	bgSprite:setPosition(320, 568)
	self.mParentLayer:addChild(bgSprite)

	--倚天剑图片
	-- local swordSprite = ui.newSprite("jrhd_11.png")
	-- swordSprite:setPosition(320, 500)
	-- self.mParentLayer:addChild(swordSprite)

	--规则按钮
    local ruleBtn = ui.newButton({
        normalImage = "c_72.png",
        position = cc.p(60, 920),
        clickAction = function()
            MsgBoxLayer.addRuleHintLayer(TR("规则"),
            {
                [1] = TR("1.活动期间参与指定玩法或者充值，可以贡献铸造值"),
                [2] = TR("2.当全服玩家贡献的铸造值达到一定值以后，会激活全服奖励"),
                [3] = TR("3.全服奖励激活后，玩家个人贡献的铸造值需要达到一定要求，才能领取奖励"),
                [4] = TR("4.活动结束后，根据全服玩家贡献的铸造值排名发放排名奖励"),
        	})
        end})
    self.mParentLayer:addChild(ruleBtn, 1)

    --返回按钮
    local closeBtn = ui.newButton({
        normalImage = "c_29.png",
        position = cc.p(594, 920),
        clickAction = function(pSender)
            LayerManager.addLayer({
                name = "home.HomeLayer"
            })
        end
    })
    self.mCloseBtn = closeBtn
    self.mParentLayer:addChild(closeBtn)

    local rankBtn = ui.newButton({
    	normalImage = "tb_16.png",
    	clickAction = function ()
    		LayerManager.addLayer({
    			name = "festival.NationalZYTRankLayer",
    			})
    	end
    	})
    rankBtn:setPosition(540, 680)
    self.mParentLayer:addChild(rankBtn)
end

local swordEff = {
	"effect_ui_zhuyitian_01",
	"effect_ui_zhuyitian_02",
	"effect_ui_zhuyitian_03",
	"effect_ui_zhuyitian_04",
}

--创建显示信息的部分
function NationalZYTLayer:createInfoView()
	local timeBgSprite = ui.newScale9Sprite("c_25.png", cc.size(410, 45))
	timeBgSprite:setPosition(320, 925)
	self.mParentLayer:addChild(timeBgSprite)
	local timeBgSpriteSize = timeBgSprite:getContentSize()
	local timeLabel = ui.newLabel({
		text = TR("活动未开启"),
		size = 22,
		outlineColor = Enums.Color.eBlack,
		})
	timeLabel:setPosition(timeBgSpriteSize.width / 2, timeBgSpriteSize.height / 2)
	timeBgSprite:addChild(timeLabel)
	self.mTimeLable = timeLabel

	local scaleLabel = ui.newLabel({
		text = TR("活动期间全服玩家每充值#F6D9081#FFFFFF元铸造值#F6D908+%s", self.mScaleNum*1),
		size = 22,
		outlineColor = Enums.Color.eBlack,
		})
	scaleLabel:setPosition(320, 890)
	self.mParentLayer:addChild(scaleLabel)

	local totalMakeLabel = ui.newLabel({
		text = TR("全服铸造值：%s", self.mGlobalNum),
		size = 22,
		outlineColor = Enums.Color.eBlack,
		})
	totalMakeLabel:setPosition(320, 860)
	self.mParentLayer:addChild(totalMakeLabel)

	local myScoreBgSprite = ui.newScale9Sprite("c_145.png", cc.size(420, 80))
	myScoreBgSprite:setPosition(320, 205)
	self.mParentLayer:addChild(myScoreBgSprite)

	local myScoreLabel = ui.newLabel({
	text = TR("我贡献的铸造值：%s%s", Enums.Color.eOrangeH, self.mPersonNum),
		size = 22,
		outlineColor = Enums.Color.eBlack,
		})
	myScoreLabel:setPosition(320, 220)
	self.mParentLayer:addChild(myScoreLabel)

	local tipLabel = ui.newLabel({
		text = TR("完成活动任务或充值均可获得铸造值"),
		size = 22,
		outlineColor = Enums.Color.eBlack,
		})
	tipLabel:setPosition(320, 190)
	self.mParentLayer:addChild(tipLabel)

	local ScoreBar = require("common.ProgressBar"):create({
            bgImage = "zr_14.png",
            barImage = "zr_15.png",
            currValue = self.mCurProgress,
            maxValue = 100,
            -- needLabel = true,
            -- percentView = false,
            -- size = 20,
            -- color = Enums.Color.eBrown
        })
	ScoreBar:setPosition(320, 775)
	self.mParentLayer:addChild(ScoreBar)

	local action = cc.Sequence:create({
		cc.MoveBy:create(1, cc.p(0, 3)),
		cc.MoveBy:create(1, cc.p(0, -3)),
		cc.MoveBy:create(1, cc.p(0, -3)),
		cc.MoveBy:create(1, cc.p(0, 3)),
		})

	local yitianEff = ui.newEffect({
		parent = self.mParentLayer,
        effectName = swordEff[self.mOrderId+1] or swordEff[4],
        position = cc.p(320, 500),
        loop = true,
		})
	yitianEff:runAction(cc.RepeatForever:create(action))

	self:updateTime()
	self.mSchelTime = Utility.schedule(self, self.updateTime, 1.0)

	self:createRewardView()
end

local boxPicClose = {
	"r_09.png",
    "r_08.png",
    "r_07.png",
    "r_06.png",
    "r_05.png",
}

local boxPicOpen = {
    "r_10.png",
    "r_11.png",
    "r_12.png",
    "r_13.png",
    "r_14.png",
}

--创建奖励宝箱
function NationalZYTLayer:createRewardView()
	if #self.mBoxBtnList ~= 0 then
		for i,v in ipairs(self.mBoxBtnList) do
			v:removeFromParent()
			v = nil
		end
	end

	self.mBoxBtnList = {}
	local stepOff = 470 / (#self.mRewardInfo - 1)
	for i,v in ipairs(self.mRewardInfo) do
		local node = cc.Node:create()
		node:setPosition(i*stepOff, 805)
		if #self.mRewardInfo == 1 then
			node:setPosition(585, 805)
		end
		self.mParentLayer:addChild(node)

		local boxBtn = ui.newButton({
			normalImage = boxPicClose[i] or "r_05.png",
			clickAction = function()
				self:showRewardPop(v)
			end
			})
		boxBtn:setScale(0.95)
		boxBtn:setPosition(0, 10)
		node:addChild(boxBtn)

		local needBgSprite = ui.createLabelWithBg({
			bgFilename = "r_03.png",
	        labelStr = Utility.numberWithUnit(v.NeedGlobalNum),
	        fontSize = 20,
	        alignType = ui.TEXT_ALIGN_CENTER,
	        outlineColor = Enums.Color.eBlack,
	        offset = -5,
		})
		needBgSprite:setPosition(0, -20)
		node:addChild(needBgSprite)

		table.insert(self.mBoxBtnList, boxBtn)
	end
	self:refreshBoxStatus()
end

--宝箱弹窗
function NationalZYTLayer:showRewardPop(info)
	local function DIYFuncion(layer, layerBgSprite, layerSize)
		local grayBgSprite = ui.newScale9Sprite("c_17.png", cc.size(420, 175))
		grayBgSprite:setPosition(layerSize.width * 0.5 + 5, layerSize.height * 0.6)
		layerBgSprite:addChild(grayBgSprite)

		local tempRewardList = {}
		for i,v in ipairs(info.RewardList) do
			tempRewardList[i] = {}
			tempRewardList[i].resourceTypeSub = v.ResourceTypeSub
			tempRewardList[i].modelId = v.ModelId
			tempRewardList[i].num = v.Count
		end

		--奖励列表
		local rewardList = ui.createCardList({
			maxViewWidth = 370,
	        viewHeight = 120,
	        space = 10,
	        cardDataList = tempRewardList,
	        allowClick = false, 
	        needArrows = true, 
		})
		rewardList:setAnchorPoint(cc.p(0.5, 0.5))
		rewardList:setPosition(layerSize.width * 0.5 + 5, layerSize.height * 0.6)
		layerBgSprite:addChild(rewardList)

		local tipLabelGloble = ui.newLabel({
			text = TR("全服铸造值达到%s可领取", Utility.numberWithUnit(info.NeedGlobalNum)),
			size = 20,
			color = Enums.Color.eNormalWhite,
        	outlineColor = cc.c3b(0x46, 0x22, 0x0d),
			})
		tipLabelGloble:setPosition(layerSize.width * 0.5 + 5, layerSize.height * 0.32)
		layerBgSprite:addChild(tipLabelGloble)

		local tipLabelPerson = ui.newLabel({
			text = TR("个人铸造值达到%s可领取", Utility.numberWithUnit(info.NeedPersonNum)),
			size = 20,
			color = Enums.Color.eNormalWhite,
        	outlineColor = cc.c3b(0x46, 0x22, 0x0d),
			})
		tipLabelPerson:setPosition(layerSize.width * 0.5 + 5, layerSize.height * 0.25)
		layerBgSprite:addChild(tipLabelPerson)

		local getBtn = ui.newButton({
			normalImage = "c_28.png",
			text = TR("领取"),
			clickAction = function(pSender)
				LayerManager.removeLayer(layer)
				self:requestGetReward()
			end
		})
		getBtn:setPosition(layerSize.width * 0.5 + 5, layerSize.height * 0.13)
		layerBgSprite:addChild(getBtn)

		if info.NeedGlobalNum > self.mGlobalNum then
			tipLabelGloble:setString(TR("%s全服铸造值达到%s可领取", Enums.Color.eRedH, Utility.numberWithUnit(info.NeedGlobalNum)))
			getBtn:setEnabled(false)
		end
		if info.NeedPersonNum > self.mPersonNum then
			tipLabelPerson:setString(TR("%s个人铸造值达到%s可领取", Enums.Color.eRedH, Utility.numberWithUnit(info.NeedPersonNum)))
			getBtn:setEnabled(false)
		end

		if info.Status == 2 then
			getBtn:setTitleText(TR("已领取"))
			getBtn:setEnabled(false)
		end
	end

	MsgBoxLayer.addDIYLayer({
	 	title = TR("全服奖励"),
        closeBtnInfo = {},
        DIYUiCallback = DIYFuncion,
        btnInfos = {},
        notNeedBlack = true,
        bgSize = cc.size(490, 380)
		})
end

--刷新宝箱状态
function NationalZYTLayer:refreshBoxStatus()
	for i,v in ipairs(self.mBoxBtnList) do
		if not tolua.isnull(v) then
			if v.flashNode then
				v:stopAllActions()
				v:setRotation(0)
				v.flashNode:removeFromParent()
				v.flashNode = nil
			end
		end
	end
	for i,v in ipairs(self.mRewardInfo) do
		local openPic = boxPicOpen[i] or "r_14"
		if v.Status == 1 then
			ui.setWaveAnimation(self.mBoxBtnList[i])
		elseif v.Status == 2 then
			self.mBoxBtnList[i]:loadTextures(openPic, openPic)
		end
	end
end

-- 活动倒计时
function NationalZYTLayer:updateTime()
    local timeLeft = self.mEndTime - Player:getCurrentTime()
    if timeLeft > 0 then
        self.mTimeLable:setString(TR("活动剩余时间：%s%s", Enums.Color.eGreenH, MqTime.formatAsDay(timeLeft)))
    else
        self.mTimeLable:setString(TR("00:00:00"))

        -- 停止倒计时
        if self.mSchelTime then
            self:stopAction(self.mSchelTime)
            self.mSchelTime = nil
        end

  --       -- 重新进入提示
		-- MsgBoxLayer.addOKLayer(
  --           TR("%s活动已结束，请重新进入", self.mActivityIdList[1].Name),
  --           TR("提示"),
  --           {
  --               normalImage = "c_28.png",
  --           },
  --           {
  --               normalImage = "c_29.png",
  --               clickAction = function()
  --                   LayerManager.addLayer({
  --                       name = "activity.ActivityMainLayer",
  --                       data = {moduleId = ModuleSub.eTimedActivity},
  --                   })
  --               end
  --           }
  --       )
    end
end

-- 获取恢复数据
function NationalZYTLayer:getRestoreData()
	local retData = {
		activityIdList = self.mActivityIdList,
		parentModuleId = self.mParentModuleId,
		cacheData = self.mLayerData
	}

	return retData
end

-- 处理进度条数据
function NationalZYTLayer:handleProgressData()
	local tempTotal = 100
	local oneStep = 100 / #self.mRewardInfo
	local LastNeedNum = self.mRewardInfo[self.mOrderId] and self.mRewardInfo[self.mOrderId].NeedGlobalNum or 0
	local curNeedNum = self.mRewardInfo[self.mOrderId + 1] and self.mRewardInfo[self.mOrderId + 1].NeedGlobalNum or self.mMaxGlobalCfgNum

	local oneStepPerL = self.mGlobalNum - LastNeedNum
	local oneStepPerN = curNeedNum - LastNeedNum
	local curPro = self.mOrderId * oneStep + oneStepPerL/oneStepPerN * oneStep

	self.mCurProgress = curPro
end

--====================================网络接口=========================================
--获取信息
function NationalZYTLayer:requestGetInfo()
	HttpClient:request({
        moduleName = "TimedPolaroid", 
        methodName = "GetInfo",
        svrMethodData = {},
        callbackNode = self,
        callback = function (data)
	        if data.Status ~= 0 then
	        	ui.showFlashView(TR("活动未开启"))
	        	return
	        end
	        -- dump(data, "ssssss")
	        self.mRewardInfo = data.Value.RewardInfo
	        self.mGlobalNum = data.Value.GlobalNum
	        self.mPersonNum = data.Value.PersonNum
	        self.mMaxGlobalCfgNum = data.Value.MaxGlobalCfgNum
	        self.mEndTime = data.Value.EndDate
	        self.mOrderId = data.Value.OrderId
	        self.mScaleNum = data.Value.Scale
	        self:handleProgressData()
	        self:createInfoView()
        end
    })
end

--领取宝箱(一键领取)
function NationalZYTLayer:requestGetReward()
	HttpClient:request({
        moduleName = "TimedPolaroid", 
        methodName = "ReceiveReward",
        svrMethodData = {},
        callbackNode = self,
        callback = function (data)
	        if data.Status ~= 0 then
	        	return
	        end
	        dump(data, "ReceiveReward")
	        self.mRewardInfo = data.Value.RewardInfo
	        self.mGlobalNum = data.Value.GlobalNum
	        self.mPersonNum = data.Value.PersonNum
	        self.mMaxGlobalCfgNum = data.Value.MaxGlobalCfgNum
	        self:createRewardView()

	        ui.ShowRewardGoods(data.Value.BaseGetGameResourceList)
        end
    })
end

return NationalZYTLayer