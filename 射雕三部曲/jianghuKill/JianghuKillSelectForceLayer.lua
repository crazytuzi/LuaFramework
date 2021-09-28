--[[
    文件名: JianghuKillSelectForceLayer.lua
    描述: 江湖杀选择势力界面
    创建人: 杨宏生
    创建时间: 2018.09.3
-- ]]
local JianghuKillSelectForceLayer = class("JianghuKillSelectForceLayer", function(params)
	return display.newLayer()
end)

--[[
	params:
		isRecomReward 		-- 是否有推荐奖励(默认nil)
]]

function JianghuKillSelectForceLayer:ctor(params)
	self.mIsRecomReward = params.isRecomReward
	self.myForceId = PlayerAttrObj:getPlayerAttrByName("JianghuKillForceId") or 0
	--屏蔽下层点击
    ui.registerSwallowTouch({node = self})

	self.mParentLayer = ui.newStdLayer()
	self:addChild(self.mParentLayer)

	self:requestGetCommendForce()
end

function JianghuKillSelectForceLayer:initUI()

	self:createHero()

	self:createUI()
	-- 加入武林盟按钮
	local joinWBtn = ui.newButton({
            normalImage = "jhs_37.png",
            clickAction = function()
            	self:joinForceAction(Enums.JHKCampType.eWulinmeng)
            end
        })
	joinWBtn:setPosition(558, 898)
	self.mParentLayer:addChild(joinWBtn)
	-- 加入浑天教按钮
	local joinHBtn = ui.newButton({
            normalImage = "jhs_37.png",
            clickAction = function()
            	self:joinForceAction(Enums.JHKCampType.eHuntianjiao)
            end
        })
	joinHBtn:setPosition(105, 368)
	self.mParentLayer:addChild(joinHBtn)

	if self.mIsRecomReward then
		-- 加入奖励
		local rewardRes = Utility.analysisStrResList(JianghukillModel.items[1].friendGift)[1]
		local rewardWLabel = ui.newLabel({
				text = TR("奖励{%s}%d", Utility.getDaibiImage(rewardRes.resourceTypeSub), rewardRes.num),
			})
		rewardWLabel:setPosition(558, 830)
		self.mParentLayer:addChild(rewardWLabel)
		-- 设置位置
		if self.mRecomForceId == Enums.JHKCampType.eWulinmeng then
			rewardWLabel:setPosition(558, 830)
		else
			rewardWLabel:setPosition(105, 300)
		end
	else
		-- 当前势力标识
		local curSprite = ui.newSprite("jhs_121.png")
		curSprite:setScale(1.5)
		self.mParentLayer:addChild(curSprite)
		-- 设置位置
		if self.myForceId == Enums.JHKCampType.eWulinmeng then
			curSprite:setPosition(565, 820)
		elseif self.myForceId == Enums.JHKCampType.eHuntianjiao then
			curSprite:setPosition(110, 280)
		else
			curSprite:setVisible(false)
		end
	end

	-- 退出按钮
	if not self.mIsRecomReward then
		local closeBtn = ui.newButton({
				normalImage = "c_29.png",
				clickAction = function ()
					LayerManager.removeLayer(self)
				end
			})
		closeBtn:setPosition(595, 1050)
		self.mParentLayer:addChild(closeBtn)
	end
end

function JianghuKillSelectForceLayer:joinForceAction(forceId)
	if self.mIsRecomReward and self.mRecomForceId ~= forceId then
		MsgBoxLayer.addOKCancelLayer(
			TR("加入%s可获得额外奖励，少侠是否确认加入%s？", Enums.JHKCampName[self.mRecomForceId], Enums.JHKCampName[forceId]),
			TR("提示"),
			{
				text = TR("确认"),
				clickAction = function (layerObj)
					self:chooseForce(forceId)
					LayerManager.removeLayer(layerObj)
				end,
			}
		)
	else
		self:chooseForce(forceId)
	end
end

function JianghuKillSelectForceLayer:createHero()

	local gjBg = ui.newSprite("jhs_105.png")
	gjBg:setPosition(320, 790)
	self.mParentLayer:addChild(gjBg)

	local gjBg = ui.newSprite("jhs_104.png")
	gjBg:setPosition(320, 350)
	self.mParentLayer:addChild(gjBg)

	-- 郭靖
	-- 裁剪节点
	local clippingNode = cc.ClippingNode:create()
	clippingNode:setPosition(320, 790)
	self.mParentLayer:addChild(clippingNode)
	clippingNode:setAlphaThreshold(0.5)
	local stencilNode = ui.newSprite("jhs_105.png")
	clippingNode:setStencil(stencilNode)
	
	local gjPos = cc.p(-70, 80)
	local gjEffect = ui.newEffect({
		parent = clippingNode,
		effectName = "effect_lihui_guojing",
		loop = true,
		scale = 0.9,
		position = gjPos,
	})

	local actionTime = 2

	local moveAction1 = cc.MoveTo:create(actionTime, cc.p(gjPos.x, gjPos.y + 20))
	local moveAction2 = cc.MoveTo:create(actionTime, cc.p(gjPos.x, gjPos.y + 10))
	local moveAction3 = cc.MoveTo:create(actionTime, cc.p(gjPos.x, gjPos.y))
	gjEffect:runAction(cc.RepeatForever:create(cc.Sequence:create(
	    cc.EaseSineIn:create(moveAction2),
	    cc.EaseSineOut:create(moveAction1),
	    cc.EaseSineIn:create(moveAction2),
	    cc.EaseSineOut:create(moveAction3)
	)))

	-- 张无忌
	-- 裁剪节点
	local clippingNode = cc.ClippingNode:create()
	clippingNode:setPosition(320, 350)
	self.mParentLayer:addChild(clippingNode)
	clippingNode:setAlphaThreshold(0.5)
	local stencilNode = ui.newSprite("jhs_104.png")
	-- stencilNode:setContentSize(cc.size(640, 700))
	clippingNode:setStencil(stencilNode)
	
	local zwjPos = cc.p(150, -150)
	local zwjEffect = ui.newEffect({
		parent = clippingNode,
		effectName = "effect_lihui_zhangwuji",
		loop = true,
		scale = 0.8,
		position = zwjPos,
	})

	Utility.performWithDelay(zwjEffect, function ()
		local moveAction1 = cc.MoveTo:create(actionTime, cc.p(zwjPos.x, zwjPos.y + 20))
		local moveAction2 = cc.MoveTo:create(actionTime, cc.p(zwjPos.x, zwjPos.y + 10))
		local moveAction3 = cc.MoveTo:create(actionTime, cc.p(zwjPos.x, zwjPos.y))
		zwjEffect:runAction(cc.RepeatForever:create(cc.Sequence:create(
		    cc.EaseSineIn:create(moveAction2),
		    cc.EaseSineOut:create(moveAction1),
		    cc.EaseSineIn:create(moveAction2),
		    cc.EaseSineOut:create(moveAction3)
		)))
	end, actionTime)
end

function JianghuKillSelectForceLayer:createUI()
	-- 天下双势
	local forceSprite = ui.newSprite("jhs_103.png")
	forceSprite:setPosition(320, 568)
	self.mParentLayer:addChild(forceSprite)

	local forceZSprite = ui.newSprite("jhs_106.png")
	forceZSprite:setPosition(320, 568)
	self.mParentLayer:addChild(forceZSprite)

	-- 武林盟
	local forceName = ui.newSprite("jhs_95.png")
	forceName:setPosition(53, 970)
	self.mParentLayer:addChild(forceName)

	local heroBg = ui.newSprite("jhs_97.png")
	heroBg:setPosition(131, 850)
	self.mParentLayer:addChild(heroBg)

	local heroName = ui.newSprite("jhs_98.png")
	heroName:setPosition(141, 860)
	self.mParentLayer:addChild(heroName)

	local descSprite = ui.newSprite("jhs_101.png")
	descSprite:setPosition(144, 675)
	self.mParentLayer:addChild(descSprite)

	-- 浑天教
	local forceName = ui.newSprite("jhs_96.png")
	forceName:setPosition(552, 500)
	self.mParentLayer:addChild(forceName)

	local heroBg = ui.newSprite("jhs_97.png")
	heroBg:setPosition(480, 390)
	self.mParentLayer:addChild(heroBg)

	local heroName = ui.newSprite("jhs_99.png")
	heroName:setPosition(490, 390)
	self.mParentLayer:addChild(heroName)

	local descSprite = ui.newSprite("jhs_102.png")
	descSprite:setPosition(490, 180)
	self.mParentLayer:addChild(descSprite)

end

-- 是否在开战期间
function JianghuKillSelectForceLayer.isWarTime()
    --转换出服务器日期
    local curDate = MqTime.getLocalDate()

	local weekList = {
		["1"] = 2,
		["2"] = 3,
		["3"] = 4,
		["4"] = 5,
		["5"] = 6,
		["6"] = 7,
		["7"] = 1,
	}
	-- 是否在休战时间
	local truceWeekList = string.splitBySep(JianghukillModel.items[1].truceDate or "", ",")
	local function isWarDate(wday)
		for _, weekStr in pairs(truceWeekList) do
			if wday == weekList[weekStr] then return false end
		end
		return true
	end
	-- 是否在休战时间
	if not isWarDate(curDate.wday) then return false end

	-- 开战具体时间
	local startTimeList = string.splitBySep(JianghukillModel.items[1].startTime or "", ":")
	local endTimeList = string.splitBySep(JianghukillModel.items[1].endTime or "", ":")
	-- 转化成秒
	local function exchangeSecond(timeList)
		local secondSum = 0
		for i, time in ipairs(timeList) do
			if i == 1 then
				secondSum = secondSum + tonumber(time)*60*60
			elseif i == 2 then
				secondSum = secondSum+tonumber(time)*60
			elseif i == 3 then
				secondSum = secondSum+tonumber(time)
			end
		end

		return secondSum
	end
	local startSecond = exchangeSecond(startTimeList)
	local endSecond = exchangeSecond(endTimeList)
	-- 当前小时转成秒
	local curSecond = curDate.hour*60*60+curDate.month*60+curDate.sec

	local lastDay = curDate.wday-1 < 1 and 7 or curDate.wday-1 -- 前一天
	local nextDay = curDate.wday+1 > 7 and 1 or curDate.wday+1 -- 下一天
	-- 比较当前是否在开战时间内
	if startSecond <= curSecond and endSecond > curSecond then
		return true
	-- 当前时间在开始之前，判断上一天是否是开战星期
	elseif startSecond > curSecond and isWarDate(lastDay) then
		return true
	-- 当前时间在结束之后，判断下一天是否是开战星期
	elseif endSecond <= curSecond and isWarDate(nextDay) then
		return true
	end

	return false
end

function JianghuKillSelectForceLayer:chooseForce(forceId)
	-- 重选势力,需要在休战期间才能重选
	if not self.mIsRecomReward and self.isWarTime() then
		ui.showFlashView(TR("需休战期间才能重选势力！"))
		return
	end

	-- 重选势力,需要退帮派才能选其他势力
	if not self.mIsRecomReward and self.myForceId ~= forceId and Utility.isEntityId(GuildObj:getGuildInfo().Id) then
		ui.showFlashView(TR("您要加入的势力和您当前帮派势力不同，请先退出帮派"))
		return
	end

	-- 重选势力(重选势力提示)
	if not self.mIsRecomReward then
		if self.myForceId ~= forceId then
			MsgBoxLayer.addOKCancelLayer(TR("当天只能更换一次势力，是否确认更换？"), TR("提示"), {
			        text = TR("确定"),
			        clickAction = function (layerObj)
			            self:requestChooseForce(forceId)
			        end,
			    })
		else
			ui.showFlashView(TR("已加入该势力"))
			return
		end
	else
	    self:requestChooseForce(forceId)
	end
end

--===================================网络相关===================================
-- 获取推荐势力
function JianghuKillSelectForceLayer:requestGetCommendForce(forceId)
    HttpClient:request({
        moduleName = "Jianghukill",
        methodName = "GetCommendForceId",
        svrMethodData = {},
        callbackNode = self,
        callback = function(response)
            -- 容错处理
            if response.Status ~= 0 then
                return
            end
            self.mRecomForceId = response.Value.ForceId

            self:initUI()

            -- 屏蔽新手引导层
            local guideID, ordinal, eventID = Guide.manager:getGuideInfo()
            if eventID == 904 then
            	LayerManager.removeGuideLayer()
            end
        end
    })
end
--选择势力
function JianghuKillSelectForceLayer:requestChooseForce(forceId)
    HttpClient:request({
        moduleName = "Jianghukill",
        methodName = "ChooseForce",
        svrMethodData = {forceId},
        callbackNode = self,
        guideInfo = Guide.helper:tryGetGuideSaveInfo(904),
        callback = function(response)
            -- 容错处理
            if response.Status ~= 0 then
                return
            end
            -- dump(response, "势力")

            if response.Value.BaseGetGameResourceList then
	            ui.ShowRewardGoods(response.Value.BaseGetGameResourceList)
	        end

            -- 结束引导
            local _, _, eventID = Guide.manager:getGuideInfo()
            if eventID == 904 then
            	Guide.manager:nextStep(eventID, true)
		        Guide.manager:removeGuideLayer()
            end

            local endLayerName = "jianghuKill.JianghuKillEndLayer"
            local endLayerParams = LayerManager.getRestoreData(endLayerName)
            if endLayerParams then
            	endLayerParams.forceId = forceId
            	endLayerParams.forceLv = 0

            	LayerManager.setRestoreData(endLayerName, endLayerParams)
	        end

	        ui.showFlashView(TR("您已加入%s", Enums.JHKCampName[forceId]))

            LayerManager.removeLayer(self)
        end
    })
end

return JianghuKillSelectForceLayer