--[[
    文件名: JianghuKillEndLayer.lua
    描述: 江湖杀赛季结束界面
    创建人: 杨宏生
    创建时间: 2018.09.3
-- ]]
local JianghuKillEndLayer = class("JianghuKillEndLayer", function(params)
	return display.newLayer()
end)

--[[
	params:
		forceId 	势力id
		forceLv 	势力等级
		jobId 		职业id
		jobLv 		职业等级
		isCanReceive 	是否领每日福利
		openTime 	开战时间
]]

function JianghuKillEndLayer:ctor(params)
	self.mHadForce = params.forceId
	self.mHadJob = params.jobId
	self.mForceId = params.forceId or 1
	self.mForceLv = params.forceLv or 0
	self.mJobId = params.jobId or 1
	self.mJobLv = params.jobLv or 0
	self.mIsCanReceive = params.isCanReceive or false
	self.mOpenTime = params.openTime
	--屏蔽下层点击
    ui.registerSwallowTouch({node = self})

	self.mParentLayer = ui.newStdLayer()
	self:addChild(self.mParentLayer)

	-- 创建顶部资源栏和底部导航栏
	local topResource = require("commonLayer.CommonLayer"):create({
	    needMainNav = true,
	    topInfos = {
	        ResourcetypeSub.eVIT,
	        ResourcetypeSub.eDiamond,
	        ResourcetypeSub.eGold
	    }
	})
	self:addChild(topResource)

	self:initUI()
end

function JianghuKillEndLayer:onEnterTransitionFinish()
	-- 没有势力选择势力
	if not self.mHadForce then
		LayerManager.addLayer({name = "jianghuKill.JianghuKillSelectForceLayer", data = {isRecomReward = true}})
	end

	-- 没有职业选择职业
	if not self.mHadJob then
		LayerManager.addLayer({name = "jianghuKill.JianghuKillSeleJobLayer", data = {
				jobId = self.mJobId,
				isFirst = true,
				callback = function (response)
					-- dump(response)
					self.mJobId = response.Value.JobInfo.JobId
					self.mJobLv = response.Value.JobInfo.JobLv
				end,
			}, cleanUp = false})
	end
end

function JianghuKillEndLayer:getRestoreData()
	local ret = {
		forceId = self.mForceId,
		forceLv = self.mForceLv,
		jobId = self.mJobId,
		jobLv = self.mJobLv,
		isCanReceive = self.mIsCanReceive,
		openTime = self.mOpenTime,
	}

	return ret
end

function JianghuKillEndLayer:initUI()
	-- 背景
	local bgSprite = ui.newSprite("jhs_94.jpg")
	bgSprite:setPosition(320, 568)
	self.mParentLayer:addChild(bgSprite)

	-- 倒计时背景
	local timeBgSize = cc.size(400, 50)
	local timeBg = ui.newScale9Sprite("c_25.png", timeBgSize)
	timeBg:setPosition(320, 880)
	self.mParentLayer:addChild(timeBg)
	-- 倒计时
	local timeLabel = ui.newLabel({
			text = "",
			color = Enums.Color.eWhite,
			outlineColor = cc.c3b(0x46, 0x22, 0x0d),
			size = 20,
		})
	timeLabel:setPosition(timeBgSize.width*0.5, timeBgSize.height*0.5)
	timeBg:addChild(timeLabel)
	self.mTimeLabel = timeLabel

	-- 退出按钮
	local closeBtn = ui.newButton({
			normalImage = "c_29.png",
			clickAction = function ()
				LayerManager.addLayer({name = "home.HomeLayer"})
			end
		})
	closeBtn:setPosition(595, 1050)
	self.mParentLayer:addChild(closeBtn)

	-- 创建其他按钮
	self:createBtnList()

	-- 创建下个赛季倒计时
	self:createTimeUpdate()
end

function JianghuKillEndLayer:createTimeUpdate()

	if self.mTimeLabel.timeUpdate then
	    self.mTimeLabel:stopAction(self.mTimeLabel.timeUpdate)
	    self.mTimeLabel.timeUpdate = nil
	end

	self.mTimeLabel.timeUpdate = Utility.schedule(self.mTimeLabel, function ()
	    local timeLeft = self.mOpenTime - Player:getCurrentTime()
	    if timeLeft > 0 then
	        self.mTimeLabel:setString(TR("距下个赛季开启还有：#ffe748%s", MqTime.formatAsDay(timeLeft)))
	    else
	    	self.mTimeLabel:setString(TR("距下个赛季开启还有：#ffe74800:00:00"))
	        self.mTimeLabel:stopAction(self.mTimeLabel.timeUpdate)
	        self.mTimeLabel.timeUpdate = nil
	        LayerManager.removeLayer(self)
	    end
	end, 1)
end

function JianghuKillEndLayer:createBtnList()
	local btnList = {
		-- 退出
		{
			normalImage = "c_29.png",
			position = cc.p(595, 1050),
			clickAction = function ()
				LayerManager.addLayer({name = "home.HomeLayer"})
			end,
		},
		-- 规则
		{
			normalImage = "c_72.png",
			position = cc.p(50, 1050),
			clickAction = function ()
				MsgBoxLayer.addRuleHintLayer(TR("规则"), {
				        TR("1.62级开启江湖杀。"),
	                    TR("2.开启时间：周五、周六的10：00至21:59:59，一周为一个赛季，周五22：00至周六10:00为休息时间，所有玩家在江湖杀中不能进行任何行动。"),
	                    TR("3.江湖杀为武林盟与浑天教俩个势力间的大型跨服竞技玩法，玩家代表各自势力争夺并领悟散落在众多门派中的天机残页，最终领悟天机残页最多的势力获得胜利。"),
	                    TR("4.挑战、防守、完成势力任务和职业任务都可以获得荣誉点，最终会根据玩家本赛季获得的荣誉点对每个职业进行排名并发放排行奖励，每个职业的排行榜是相互独立的。小提示：选择人数较少的职业，获得更高排名的机会更大哦~"),
	                    TR("5.赛季开始后不能更换职业和势力。"),
	                    TR("6.赛季开始时，所有玩家都在各自的势力总部，武林盟的势力总部是桃花岛，浑天教总部是明教。"),
	                    TR("7.江湖杀中玩家可以进行四种操作："),
	                    TR("①　驻守：可在自己所属势力进行驻守，如果被击败则回到势力总部。"),
	                    TR("②　挑战：可以对敌方势力门派内驻守的玩家进行挑战，击败最后一个驻守玩家即可占领该门派。"),
	                    TR("③　移动：只能移动到相邻门派，并且不能从敌方门派移动到另一个敌方门派。"),
	                    TR("④　领悟：可以去己方势力门派领悟天机残页，个人领悟的页数会累计到势力总页数。"),
	                    TR("8.江湖杀中每个人都有四种状态："),
	                    TR("①　精神：如果精神被耗尽则回到势力总部；"),
	                    TR("②　功力：发起挑战时需要消耗；"),
	                    TR("③　粮草：在门派间移动时需要消耗；"),
	                    TR("④　悟性：领悟天机残页时需要消耗。"),
				    },
				    cc.size(590, 840))
			end,
		},
		-- 排行
		{
			normalImage = "jhs_88.png",
			position = cc.p(315, 757),
			clickAction = function ()
				LayerManager.addLayer({name = "jianghuKill.JianghuKillRankLayer", data = {jobId = self.mJobId}})
			end,
		},
		-- 势力等级
		{
			normalImage = "jhs_89.png",
			position = cc.p(145, 589),
			clickAction = function ()
				LayerManager.addLayer({name = "jianghuKill.JianghuKillForceBoxLayer", data = {
		                forceId = self.mForceId,
		                forceLv = self.mForceLv,
		                isCanReceive = self.mIsCanReceive,
		                callback = function (isCanReceive)
		                    self.mIsCanReceive = isCanReceive
		                end,
		            },
		            cleanUp = false,
	            })
			end,
		},
		-- 职业等级
		{
			normalImage = "jhs_90.png",
			position = cc.p(500, 589),
			clickAction = function ()
				LayerManager.addLayer({name = "jianghuKill.JianghuKillJobBoxLayer", data = {
		                jobId = self.mJobId,
		                jobLv = self.mJobLv,
		            },
		            cleanUp = false,
	            })
			end,
		},
		-- 商店
		{
			normalImage = "jhs_91.png",
			position = cc.p(320, 460),
			clickAction = function ()
				LayerManager.addLayer({name = "jianghuKill.JianghuKillShopLayer", cleanUp = false})
			end,
		},
		-- 更换职业
		{
			normalImage = "jhs_93.png",
			position = cc.p(153, 309),
			clickAction = function ()
				LayerManager.addLayer({name = "jianghuKill.JianghuKillSeleJobLayer", data = {
						jobId = self.mJobId,
						callback = function (response)
							-- dump(response)
							self.mJobId = response.Value.JobInfo.JobId
							self.mJobLv = response.Value.JobInfo.JobLv
						end,
					}, cleanUp = false})
			end,
		},
		-- 更换势力
		{
			normalImage = "jhs_92.png",
			position = cc.p(501, 309),
			clickAction = function ()
				LayerManager.addLayer({name = "jianghuKill.JianghuKillSelectForceLayer", data = {myForceId = self.mForceId}})
			end,
		},
	}

	for _, btnInfo in pairs(btnList) do
		local tempBtn = ui.newButton(btnInfo)
		self.mParentLayer:addChild(tempBtn)
	end
end

return JianghuKillEndLayer