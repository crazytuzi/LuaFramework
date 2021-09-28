--[[
	文件名：ActivityBossDropLayer.lua
	描述：活动Boss特殊掉落页面
	创建人：lengjiazhi	
	创建时间：2017.4.7
	修改人：yanghongsheng
	修改时间：2017.9.22
--]]
local ActivityBossDropLayer = class("ActivityBossDropLayer", function (params)
	return display.newLayer()
end)

function ActivityBossDropLayer:ctor(params)
	params = params or {}
	-- 活动实体Id列表
	self.mActivityIdList = params.activityIdList
	-- 该活动的主模块Id
	self.mParentModuleId = params.parentModuleId
	-- 该页面的数据信息
	self.mLayerData = params.cacheData

	self:requestData()
end

--添加UI
function ActivityBossDropLayer:initUI()
	--页面父节点
	self.mParentLayer = ui.newStdLayer()
	self:addChild(self.mParentLayer)

	--背景
	local bgSprite = ui.newSprite("jrhd_24.jpg")
	bgSprite:setPosition(320, 568)
	self.mParentLayer:addChild(bgSprite)

	-- 李莫愁
	local heroSprite = ui.newSprite("zdlh_12422a.png")
	heroSprite:setPosition(300, 430)
	self.mParentLayer:addChild(heroSprite)
	
	-- 提示图
	local hintSprite = ui.newSprite("jrhd_86.png")
	hintSprite:setPosition(320, 850)
	self.mParentLayer:addChild(hintSprite)

	--返回按钮
    local closeBtn = ui.newButton({
        normalImage = "c_29.png",
        position = cc.p(594, 930),
        clickAction = function(pSender)
            LayerManager.addLayer({
                name = "home.HomeLayer"
            })
        end
    })
    self.mCloseBtn = closeBtn
    self.mParentLayer:addChild(closeBtn)

    self:createDropView()
end

--创建掉落奖励
function ActivityBossDropLayer:createDropView()
	--奖励背景
	local bgSprite = ui.newScale9Sprite("c_17.png", cc.size(573, 214))
	bgSprite:setPosition(320, 220)
	self.mParentLayer:addChild(bgSprite)

	--整理列表用的数据
	local tempList = {}
	for _, value in pairs(self.mDropInfo) do
		for _, v in pairs(value.Reward) do
			local item = {}
			item.modelId = v.ModelId
			item.num = v.Count
			item.resourceTypeSub = v.ResourceTypeSub
			item.cardShowAttrs = {CardShowAttr.eBorder, CardShowAttr.eNum}
			table.insert(tempList, item)
		end
	end
	--奖励列表
	local cardList = ui.createCardList({
			maxViewWidth = 460,
			space = 10,
			cardDataList = tempList,
			needArrows = true,
		})
	cardList:setAnchorPoint(0.5, 0.5)
	cardList:setPosition(bgSprite:getContentSize().width * 0.5, bgSprite:getContentSize().height * 0.65)
	bgSprite:addChild(cardList)

	--前往按钮
    local gotoBtn = ui.newButton({
    	text = TR("立即前往"),
        normalImage = "c_28.png",
        position = cc.p(320, 150),
        clickAction = function(pSender)
        	LayerManager.addLayer({
        		name = "challenge.BattleBossLayer",
        		data = {}
        		})
        end
    })
    self.mParentLayer:addChild(gotoBtn)

    -- 倒计时标签
    self.mTimeLabel = ui.newLabel({
        text = TR("1111"),
        color = cc.c3b(0xeb, 0xff, 0xc9),
        outlineColor = cc.c3b(0x2b, 0x66, 0x14),
        anchorPoint = cc.p(0, 0.5),
        size = 20,
        x = 400,
        y = 150,
        align = ui.TEXT_ALIGN_CENTER
    })
    self.mParentLayer:addChild(self.mTimeLabel)

        -- 刷新时间，开始倒计时
    if self.mSchelTime then
        self:stopAction(self.mSchelTime)
        self.mSchelTime = nil
    end
    self:updateTime()
    self.mSchelTime = Utility.schedule(self, self.updateTime, 1.0)
end

-- 更新时间
function ActivityBossDropLayer:updateTime()
    local timeLeft = self.mEndTime - Player:getCurrentTime()
    if timeLeft > 0 then
        self.mTimeLabel:setString(TR("活动倒计时：%s",MqTime.formatAsDay(timeLeft)))
        --print("更新时间")
    else
        self.mTimeLabel:setString(TR("活动倒计时：00:00:00"))

        -- 停止倒计时
        if self.mSchelTime then
            self:stopAction(self.mSchelTime)
            self.mSchelTime = nil
        end

        -- 重新进入提示
        MsgBoxLayer.addOKLayer(
            TR("%s活动已结束，请重新进入", self.mActivityIdList[1].Name),
            TR("提示"),
            {
                normalImage = "c_28.png",
            },
            {
                normalImage = "c_29.png",
                clickAction = function()
                    LayerManager.addLayer({
                        name = "activity.ActivityMainLayer",
                        data = {moduleId = ModuleSub.eTimedActivity},
                    })
                end
            }
        )
    end
end

--获取页面恢复信息
function ActivityBossDropLayer:getRestoreData()
	local retData = {
		activityIdList = self.mActivityIdList,
		parentModuleId = self.mParentModuleId,
		cacheData = self.mLayerData
	}

	return retData
end

---------------------------网络相关---------------------------------
--请求信息
function ActivityBossDropLayer:requestData()
	HttpClient:request({
        moduleName = "BossBattle", 
        methodName = "GetTimedBossSpecialDrop",
        svrMethodData = {self.mActivityId},
        callbackNode = self,
        callback = function (data)
	        if data.Status ~= 0 then
	        	ui.showFlashView(TR("活动未开启"))
	        	return
	        end
	        dump(data.Value)
        	self.mDropInfo = data.Value.SpecialDropOutInfo
        	self.mEndTime = data.Value.EndDate
        	self:initUI()

        end
    })
end

return ActivityBossDropLayer