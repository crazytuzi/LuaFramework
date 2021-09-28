--[[
    文件名: NationalTimeDropLayer.lua
	描述: 限时掉落, 模块Id为：
		ModuleSub.eTimedHolidayDrop-- "节日活动-限时掉落"
	创建人: yanghongsheng
	创建时间: 2017.09.21
--]]

--[[
-- 参数 params 中的各项为：
    {
        activityIdList: 活动实体Id列表
        parentModuleId: 该活动的主模块Id

        cacheData: 该页面的缓存信息，主要用于恢复该页面时使用，普通调用者一般不会使用该参数
    }
]]

local NationalTimeDropLayer = class("NationalTimeDropLayer", function()
    return display.newLayer()
end)

function NationalTimeDropLayer:ctor(params)
	params = params or {}
	-- 活动实体Id列表
	self.mActivityIdList = params.activityIdList
	-- 该活动的主模块Id
	self.mParentModuleId = params.parentModuleId
	-- 该页面的数据信息
	self.mLayerData = params.cacheData

	self.mEndTime = params.endTime

	-- 获取活动数据id
	self.ActivityId = ActivityObj:getActivityItem(ModuleSub.eTimedHolidayDrop)[1].ActivityId
	
	-- 页面元素父节点
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)

    -- 初始化界面
    self:initUI()
    -- 请求服务器
    if not self.mLayerData then
		self:requestData()
	else
		self:refreshUI()
	end
end

--获取页面恢复信息
function NationalTimeDropLayer:getRestoreData()
	local retData = {
		activityIdList = self.mActivityIdList,
		parentModuleId = self.mParentModuleId,
		cacheData = self.mLayerData,
		endTime = self.mEndTime
	}

	return retData
end

function NationalTimeDropLayer:initUI()
	-- 上半部背景
	local upBgSprite = ui.newSprite("jrhd_10.jpg")
	upBgSprite:setAnchorPoint(cc.p(0.5, 1))
	upBgSprite:setPosition(320, 1136)
	self.mParentLayer:addChild(upBgSprite)
	-- 下半部背景
	local downBgSize = cc.size(640, 660)
	local downBgSprite = ui.newScale9Sprite("c_19.png", downBgSize)
	downBgSprite:setAnchorPoint(cc.p(0.5, 0))
	downBgSprite:setPosition(320, 0)
	self.mParentLayer:addChild(downBgSprite)
	-- 跳转按钮背景
	local btnsBg = ui.newSprite("jrhd_08.png")
	btnsBg:setAnchorPoint(cc.p(0.5, 1))
	btnsBg:setPosition(downBgSize.width*0.5, downBgSize.height*0.95)
	downBgSprite:addChild(btnsBg)
	local btnsBgSize = btnsBg:getContentSize()
	-- 提示文字
	local hintLabel = ui.newLabel({
			text = TR("活动期间，以下玩法会额外产出稀有道具"),
			color = cc.c3b(0x46, 0x22, 0x0d),
			size = 24,
		})
	hintLabel:setAnchorPoint(cc.p(0.5, 0.5))
	hintLabel:setPosition(btnsBgSize.width*0.5, btnsBgSize.height*0.85)
	btnsBg:addChild(hintLabel)
	-- 按钮列表大小
	self.btnListSize = cc.size(btnsBgSize.width, btnsBgSize.height*0.65)
	-- 创建按钮列表
	local btnsListView = ccui.ListView:create()
	btnsListView:setDirection(ccui.ScrollViewDir.horizontal)
	btnsListView:setBounceEnabled(true)
	btnsListView:setContentSize(self.btnListSize)
	btnsListView:setItemsMargin(5)
	btnsListView:setPosition(btnsBgSize.width*0.5, btnsBgSize.height*0.35)
	btnsListView:setAnchorPoint(cc.p(0.5, 0.5))
	btnsBg:addChild(btnsListView)
	self.btnsListView = btnsListView
	-- 左箭头
	local leftArrSprite = ui.newSprite("c_26.png")
	leftArrSprite:setRotation(180)
	leftArrSprite:setPosition(0, self.btnListSize.height*0.5)
	btnsBg:addChild(leftArrSprite, 1)
	-- 右箭头
	local rightArrSprite = ui.newSprite("c_26.png")
	rightArrSprite:setPosition(btnsBgSize.width, self.btnListSize.height*0.5)
	btnsBg:addChild(rightArrSprite, 1)
	-- 列表背景
	local listBgSize = cc.size(btnsBgSize.width, 380)
	local listBg = ui.newScale9Sprite("c_17.png", listBgSize)
	listBg:setPosition(320, 260)
	downBgSprite:addChild(listBg)
	-- 项背景
	local itemSize = cc.size(btnsBgSize.width-20, 140)
	local itemBg = ui.newScale9Sprite("c_18.png", itemSize)
	itemBg:setAnchorPoint(cc.p(0.5, 1))
	itemBg:setPosition(listBgSize.width*0.5, listBgSize.height-10)
	listBg:addChild(itemBg)
	-- 限时掉落提示
	local timeDropLabel = ui.newLabel({
			text = TR("限时掉落"),
			color = cc.c3b(0x24, 0x90, 0x29),
			size = 24,
		})
	timeDropLabel:setAnchorPoint(cc.p(0, 0.5))
	timeDropLabel:setPosition(20, itemSize.height*0.5)
	itemBg:addChild(timeDropLabel)
	-- 限时掉落物品列表
	local dropCardList = ui.createCardList({
			maxViewWidth = itemSize.width*0.7,
		})
	dropCardList:setAnchorPoint(cc.p(0, 0.5))
	dropCardList:setPosition(itemSize.width*0.25, itemSize.height*0.5)
	itemBg:addChild(dropCardList)
	self.dropCardList = dropCardList
	-- 前往模块
	local goBtn = ui.newButton({
			normalImage = "c_28.png",
			text = TR("前往"),
			clickAction = function ()
				if self.mLayerData.selectItem then
					LayerManager.showSubModule(self.mLayerData.selectItem.moduleId)
				end
			end,
		})
	goBtn:setPosition(320, 200)
	self.mParentLayer:addChild(goBtn)
	-- 规则按钮
	--[[
	local ruleBtn = ui.newButton({
			normalImage = "c_72.png",
			clickAction = function ()
			    MsgBoxLayer.addRuleHintLayer("规则",
			    {
			        [1] = TR("1.进行江湖副本挑战，单次挑战成功有概率获得1铸造值；"),
			        [2] = TR("2.进行挖矿，单次成功有概率获得1铸造值；"),
			        [3] = TR("3.进行华山论剑挑战，单次挑战成功有概率获得1铸造值；"),
			        [4] = TR("4.进行武林大会挑战，单次挑战成功有概率获得1铸造值；"),
			        [5] = TR("5.进行守卫光明顶副本挑战，单次挑战成功有概率获得2铸造值；"),
			        [6] = TR("6.进行围剿恶人挑战，消耗1次挑战次数获得2铸造值；"),
			        [7] = TR("7.进行江湖悬赏挑战，单次挑战成功获得3铸造值；"),
			        [8] = TR("8.进行武林争霸挑战，单次挑战成功获得1铸造值；"),
			        [9] = TR("9.进行决战桃花岛副本挑战，每日任务宝箱可得10铸造值；"),
			        [10] = TR("10.进行武林谱副本挑战，单次挑战成功获得3铸造值.")
				})
			end,
		})
	ruleBtn:setPosition(50, 930)
	self.mParentLayer:addChild(ruleBtn) --]]
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
    self.mParentLayer:addChild(closeBtn)
end

function NationalTimeDropLayer:refreshData(serverData)
	-- 初始化页面数据
	self.mLayerData = {}
	-- 活动数据
	local activityInfo = {}
	-- 整理活动数据
	for key, value in pairs(serverData.ActivityInfo or {}) do
		local tempList = {}
		tempList.moduleId = tonumber(key)
		tempList.dropList = value

		table.insert(activityInfo, tempList)
	end
	-- 默认选中项
	self.mLayerData.selectItem = activityInfo[1]
	-- 活动列表
	self.mLayerData.activityInfo = activityInfo
	-- 刷新界面
	self:refreshUI()
end

function NationalTimeDropLayer:refreshUI()
	-- 模块数量
	local btnsNum = #self.mLayerData.activityInfo
	-- 项大小
	local cellSize = cc.size(self.btnListSize.width/btnsNum, self.btnListSize.height)
	if btnsNum > 4 then
		cellSize = cc.size(self.btnListSize.width/4, self.btnListSize.height)
	end
	-- 创建项
	function createItem(data)
		local layout = ccui.Layout:create()
		layout:setContentSize(cellSize)

		-- 选中框
		local selectSprite = ui.newSprite("c_116.png")
		selectSprite:setPosition(cellSize.width*0.5, cellSize.height*0.5)
		layout:addChild(selectSprite)
		selectSprite:setVisible(false)
		if self.mLayerData.selectItem.moduleId == data.moduleId then
			selectSprite:setVisible(true)
			self.selectSprite = selectSprite
		end
		-- 模块按钮
		local moduleIcon = Utility.getModuleIcon(data.moduleId)
		local moduleBtn = ui.newButton({
				normalImage = moduleIcon..".png",
				clickAction = function ()
					-- 相同id返回
					if self.mLayerData.selectItem.moduleId == data.moduleId then return end
					-- 更新当前数据
					self.mLayerData.selectItem = data
					-- 原来选中框隐藏
					self.selectSprite:setVisible(false)
					-- 当前选中显示
					selectSprite:setVisible(true)
					-- 更新选中项的选中框
					self.selectSprite = selectSprite
					-- 刷新掉了列表
					self.dropCardList.refreshList(data.dropList)
				end,
			})
		moduleBtn:setPosition(cellSize.width*0.5, cellSize.height*0.5)
		layout:addChild(moduleBtn)

		return layout
	end
	-- 填充列表
	for _, value in pairs(self.mLayerData.activityInfo) do
		local item = createItem(value)
		self.btnsListView:pushBackCustomItem(item)
	end
	-- 默认项
	self.dropCardList.refreshList(self.mLayerData.selectItem.dropList)


	-- 倒计时标签
    self.mTimeLabel = ui.newLabel({
        text = TR("1111"),
        color = cc.c3b(0xeb, 0xff, 0xc9),
        outlineColor = cc.c3b(0x2b, 0x66, 0x14),
        anchorPoint = cc.p(0, 0.5),
        size = 22,
        x = 360,
        y = 680,
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
function NationalTimeDropLayer:updateTime()
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
    end
end


---------------------------网络相关---------------------------------
--请求信息
function NationalTimeDropLayer:requestData()
	print("self.ActivityId", self.ActivityId)
	HttpClient:request({
        moduleName = "TimedInfo", 
        methodName = "GetHolidayDropInfo",
        svrMethodData = {self.ActivityId},
        callbackNode = self,
        callback = function (data)
	        if data.Status ~= 0 then
	        	return
	        end
	        dump(data, "限时掉落数据")
	        self.mEndTime = data.Value.EndDate
	        self:refreshData(data.Value)

        end
    })
end


return NationalTimeDropLayer