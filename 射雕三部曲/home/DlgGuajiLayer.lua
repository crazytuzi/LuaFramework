--[[
	文件名：DlgGuajiLayer.lua
	描述：侠客助手界面
	创建人：yanghongsheng
	创建时间： 2019.10.10
--]]

local DlgGuajiLayer = class("DlgGuajiLayer", function(params)
	return display.newLayer()
end)


function DlgGuajiLayer:ctor(params)
	params = params or {}
	-- 弹窗
    local parentLayer = require("commonLayer.PopBgLayer").new({
        bgSize = cc.size(630, 905),
        title = TR("代理侠客"),
    })
    self:addChild(parentLayer)

    -- 保存弹框控件信息
    self.mBgSprite = parentLayer.mBgSprite
    self.mBgSize = self.mBgSprite:getContentSize()

	-- 创建页面控件
	self:initUI()

	-- 请求服务器数据
	self:requestInfo()
end

function DlgGuajiLayer:initUI()
	-- 当前体力，耐力
	self.mVitLabel = self.createAttrLabel(ResourcetypeSub.eVIT)
	self.mVitLabel:setPosition(115, self.mBgSize.height-90)
	self.mBgSprite:addChild(self.mVitLabel)
	
	self.mStaLabel = self.createAttrLabel(ResourcetypeSub.eSTA)
	self.mStaLabel:setPosition(390, self.mBgSize.height-90)
	self.mBgSprite:addChild(self.mStaLabel)
	-- 挂机列表
	local listBgSize = cc.size(575, 290)
	local listBg = ui.newScale9Sprite("dlxk_6.png", listBgSize)
	listBg:setPosition(self.mBgSize.width*0.5, 640)
	self.mBgSprite:addChild(listBg)

	self.mGuajiListView = ccui.ListView:create()
    self.mGuajiListView:setDirection(ccui.ScrollViewDir.vertical)
    self.mGuajiListView:setBounceEnabled(true)
    self.mGuajiListView:setContentSize(cc.size(listBgSize.width-20, listBgSize.height-10))
    self.mGuajiListView:setItemsMargin(5)
    self.mGuajiListView:setGravity(ccui.ListViewGravity.centerHorizontal)
    self.mGuajiListView:setAnchorPoint(cc.p(0.5, 0.5))
    self.mGuajiListView:setPosition(listBgSize.width*0.5, listBgSize.height*0.5)
    listBg:addChild(self.mGuajiListView)
	-- 挂机按钮
	self.mGuajiBtn = ui.newButton({
		normalImage = "c_28.png",
		text = TR("开始挂机"),
		clickAction = function ()
			self:startGuaji()
		end
	})
	self.mGuajiBtn:setPosition(self.mBgSize.width*0.5, 463)
	self.mBgSprite:addChild(self.mGuajiBtn)
	-- 当前进度提示
	self.mHintLabel = ui.newLabel({
		text = TR("当前没有进行挂机"),
		color = cc.c3b(0x46, 0x22, 0x2d),
		size = 20,
	})
	self.mHintLabel:setPosition(self.mBgSize.width*0.5, 420)
	self.mBgSprite:addChild(self.mHintLabel)
	-- 挂机日志列表
	local listBgSize = cc.size(575, 145)
	local listBg = ui.newScale9Sprite("dlxk_6.png", listBgSize)
	listBg:setPosition(self.mBgSize.width*0.5, 330)
	self.mBgSprite:addChild(listBg)

	self.mLogListView = ccui.ListView:create()
    self.mLogListView:setDirection(ccui.ScrollViewDir.vertical)
    self.mLogListView:setBounceEnabled(true)
    self.mLogListView:setContentSize(cc.size(listBgSize.width-20, listBgSize.height-10))
    self.mLogListView:setGravity(ccui.ListViewGravity.centerHorizontal)
    self.mLogListView:setAnchorPoint(cc.p(0.5, 0.5))
    self.mLogListView:setPosition(listBgSize.width*0.5, listBgSize.height*0.5)
    listBg:addChild(self.mLogListView)
	-- 挂机奖励背景
	local rewardBgSize = cc.size(575, 160)
	local rewardBg = ui.newScale9Sprite("dlxk_1.png", rewardBgSize)
	rewardBg:setPosition(self.mBgSize.width*0.5, 170)
	self.mBgSprite:addChild(rewardBg)

	local rewardTitle = ui.newLabel({
		text = TR("挂机获得以下奖励"),
		outlineColor = cc.c3b(0x46, 0x22, 0x2d),
	})
	rewardTitle:setPosition(rewardBgSize.width*0.5, rewardBgSize.height-15)
	rewardBg:addChild(rewardTitle)
	-- 挂机奖励列表
	self.mRewardListView = ui.createCardList({
		maxViewWidth = rewardBgSize.width,
		cardDataList = {},
	})
	self.mRewardListView:setAnchorPoint(cc.p(0.5, 0.5))
	self.mRewardListView:setPosition(rewardBgSize.width*0.5, 60)
	self.mRewardListView:setScale(0.9)
	rewardBg:addChild(self.mRewardListView)
	-- 领奖按钮
	self.mGetBtn = ui.newButton({
		text = TR("领取奖励"),
		normalImage = "c_28.png",
		clickAction = function ()
			self:requestReward()
		end,
	})
	self.mGetBtn:setPosition(self.mBgSize.width*0.5, 55)
	self.mBgSprite:addChild(self.mGetBtn)
end

-- 创建体力，耐力显示节点
function DlgGuajiLayer.createAttrLabel(attr)
	-- 父节点
	local attrNode = cc.Node:create()
	-- 属性值
	local attrLabel = ui.newLabel({
		text = string.format("%s：#258711%s", Utility.getGoodsName(attr, 0), Utility.getOwnedGoodsCount(attr, 0)),
		color = cc.c3b(0x46, 0x22, 0x2d),
	})
	attrLabel:setAnchorPoint(cc.p(0, 0.5))
	attrNode:addChild(attrLabel)
	-- 增加按钮
	local addBtn = ui.newButton({
		normalImage = "dlxk_2.png",
		clickAction = function ()
			MsgBoxLayer.addGetStaOrVitHintLayer(attr, 1, function (layObj)
				attrNode.refresh()
				LayerManager.removeLayer(layObj)
			end)
		end,
	})
	attrNode:addChild(addBtn)
	-- 刷新
	attrNode.refresh = function ()
		attrLabel:setString(string.format("%s：#258711%s", Utility.getGoodsName(attr, 0), Utility.numberWithUnit(Utility.getOwnedGoodsCount(attr, 0))))
		addBtn:setPositionX(attrLabel:getContentSize().width+30)
	end

	attrNode.refresh()
	
	return attrNode
end

function DlgGuajiLayer:createUpdateTime(label, timeLeft, desc)
	if label.updateTime then
		label:stopAction(label.updateTime)
		label.updateTime = nil
	end

	label.updateTime = Utility.schedule(label, function ()
        if timeLeft > 0 then
            label:setString(string.format("%s：%s", desc, MqTime.formatAsDay(timeLeft)))
        else
            label:setString(string.format("%s：00:00:00", desc))

            -- 停止倒计时
            if label.updateTime then
                label:stopAction(label.updateTime)
                label.updateTime = nil
            end

			self:requestInfo()
		end
		
		timeLeft = timeLeft - 1
    end, 1)
end

-- 开始挂机回调
function DlgGuajiLayer:startGuaji()
	local guajiModuleList = table.keys(self.mSelectdTaskList)
	if not next(guajiModuleList) then
		ui.showFlashView(TR("请先选择挂机任务"))
		return
	end
	-- 一轮体力消耗，耐力消耗
	local turnVitUse = 0
	local turnStaUse = 0
	for _, moduleID in pairs(guajiModuleList) do
		-- 华山论剑(每次挑战消耗2点耐力)
		if moduleID == ModuleSub.eChallengeArena then
			turnStaUse = turnStaUse + 2*GuajiModel.items[moduleID].times
		-- 武林争霸(每次挑战消耗2点耐力)
		elseif moduleID == ModuleSub.ePVPInter then
			turnStaUse = turnStaUse + 2*GuajiModel.items[moduleID].times
		end
	end
	-- 体力耐力最大轮次
	local maxVitTurn = turnVitUse == 0 and -1 or math.floor(Utility.getOwnedGoodsCount(ResourcetypeSub.eVIT, 0)/turnVitUse)
	local maxStaTurn = turnStaUse == 0 and -1 or math.floor(Utility.getOwnedGoodsCount(ResourcetypeSub.eSTA, 0)/turnStaUse)
	if maxVitTurn == 0 then
		ui.showFlashView(TR("体力不足！"))
		return
	elseif maxStaTurn == 0 then
		ui.showFlashView(TR("耐力不足！"))
		return
	end
	-- 最大轮次
	local maxTurn = maxVitTurn
	if maxStaTurn ~= -1 and ((maxTurn ~= -1 and maxStaTurn < maxTurn) or (maxTurn == -1)) then
		maxTurn = maxStaTurn
	end
	if maxTurn >= 10 then maxTurn = 10 end
	-- 不消化体力耐力只有一轮
	if maxTurn == -1 then
		self:requestGuaji(guajiModuleList, 1)
	else
		MsgBoxLayer.selectCountLayer({
			title = TR("选择轮次"),
			msgtext = TR("请选择任务循环轮次"),
			maxNum = maxTurn,
			OkCallback = function(seleNum, layerObj)
				self:requestGuaji(guajiModuleList, seleNum)
				LayerManager.removeLayer(layerObj)
			end,
		})
	end
end

-- 刷新挂机列表
function DlgGuajiLayer:refreshGuajiList()
	-- 创建挂机任务项
	local function createTaskItem(index)
		-- 数据
		local cellSize = cc.size(self.mGuajiListView:getContentSize().width, 55)
		local cellData = self.mGuajiTaskList[index]
		if not cellData then
			return
		end
		-- 创建项
		local taskItem = self.mGuajiListView:getItem(index-1)
		if not taskItem then
			taskItem = ccui.Layout:create()
			taskItem:setContentSize(cellSize)
			self.mGuajiListView:pushBackCustomItem(taskItem)
		end
		taskItem:removeAllChildren()
		-- 背景
		local bgSprite = ui.newScale9Sprite("dlxk_5.png", cellSize)
		bgSprite:setPosition(cellSize.width*0.5, cellSize.height*0.5)
		taskItem:addChild(bgSprite)
		-- 任务描述
		local descStr = ""
		if cellData.times > 0 then
			descStr = TR("%s：自动挑战%s%s次", cellData.name, cellData.name, cellData.times)
		else
			descStr = TR("%s：自动完成剩余%s次数", cellData.name, cellData.name)
		end
		local descLabel = ui.newLabel({
			text = descStr,
			color = cc.c3b(0x46, 0x22, 0x2d),
			size = 20,
		})
		descLabel:setAnchorPoint(cc.p(0, 0.5))
		descLabel:setPosition(20, cellSize.height*0.5)
		taskItem:addChild(descLabel)
		-- 选择按钮
		local selectBtn = ui.newButton({
			normalImage = "dlxk_3.png",
			clickAction = function ()
				-- 已开始挂机不准选择了
				if self.mIsBegin then return end
				-- 修改任务选中
				self.mSelectdTaskList[cellData.moduleID] = not self.mSelectdTaskList[cellData.moduleID]
				if not self.mSelectdTaskList[cellData.moduleID] then
					self.mSelectdTaskList[cellData.moduleID] = nil
				end
				taskItem.selectSprite:setVisible(self.mSelectdTaskList[cellData.moduleID] and true or false)
			end,
		})
		selectBtn:setPosition(cellSize.width-50, cellSize.height*0.5)
		taskItem:addChild(selectBtn)
		-- 打钩图片
		taskItem.selectSprite = ui.newSprite("dlxk_4.png")
		selectBtn:getExtendNode2():addChild(taskItem.selectSprite)
		taskItem.selectSprite:setVisible(self.mSelectdTaskList[cellData.moduleID] and true or false)
	end

	-- 刷新列表
	for i, _ in ipairs(self.mGuajiTaskList) do
		createTaskItem(i)
	end
end

-- 刷新日志列表
function DlgGuajiLayer:refreshLogList()
	self.mLogListView:removeAllChildren()
	-- 创建日志项
	local function createLogItem(taskInfo, isRunning)
		-- 大小
		local cellSize = cc.size(self.mLogListView:getContentSize().width, 30)
		-- 创建项
		local logItem = ccui.Layout:create()
		logItem:setContentSize(cellSize)
		self.mLogListView:pushBackCustomItem(logItem)
		-- 日志描述
		local logDescLabel = ui.newLabel({
			text = "",
			color = cc.c3b(0x46, 0x22, 0x2d),
			size = 20,
		})
		logDescLabel:setAnchorPoint(cc.p(0.5, 0.5))
		logDescLabel:setPosition(cellSize.width*0.5, cellSize.height*0.5)
		logItem:addChild(logDescLabel)
		-- 当前任务倒计时
		if isRunning then
			self:createCurTaskTimeUpdate(logDescLabel)
		-- 已完成任务
		else
			logDescLabel:setString(TR("第%s轮%s挂机成功，挑战成功%s次，奖励已发放", taskInfo.GuajiTimes, GuajiModel.items[taskInfo.ModuleId].name, taskInfo.WinCount))
		end
	end

	-- 已完成任务
	local runningTask = nil
	for _, taskInfo in ipairs(self.mGuajiData.GuajiInfo) do
		local endModuleIdList = self.mGuajiData.EndModuleId[tostring(taskInfo.GuajiTimes)]
		if endModuleIdList and table.indexof(endModuleIdList, taskInfo.ModuleId) then
			createLogItem(taskInfo)
		else
			runningTask = taskInfo
			break
		end
	end
	-- 正在进行任务
	if runningTask then
		createLogItem(runningTask, true)
	end
end

-- 刷新奖励列表
function DlgGuajiLayer:refreshRewardList()
	-- 奖励列表
	self.mRewardListView.refreshList(self.mGuajiData.BaseGetGameResourceList)
	-- 空提示
	if self.mRewardListView.emptyHint and not tolua.isnull(self.mRewardListView.emptyHint) then
		self.mRewardListView.emptyHint:removeFromParent()
		self.mRewardListView.emptyHint = nil
	end
	if not next(self.mGuajiData.BaseGetGameResourceList) then
		self.mRewardListView.emptyHint = ui.newLabel({
			text = TR("暂无奖励"),
			color = cc.c3b(0x46, 0x22, 0x2d),
		})
		self.mRewardListView.emptyHint:setPosition(0, 60)
		self.mRewardListView:addChild(self.mRewardListView.emptyHint)
	end
end

-- 刷新界面
function DlgGuajiLayer:refreshUI()
	-- 刷新体力，耐力
	self.mVitLabel.refresh()
	self.mStaLabel.refresh()
	-- 刷新挂机列表
	self:refreshGuajiList()
	-- 开始挂机按钮
	self.mGuajiBtn:setEnabled(not self.mIsBegin)
	self.mGuajiBtn:setTitleText(self.mIsBegin and TR("正在挂机") or TR("开始挂机"))
	-- 正在进行任务倒计时提示
	self:createCurTaskTimeUpdate(self.mHintLabel)
	-- 日志列表
	self:refreshLogList()
	-- 刷新奖励列表
	self:refreshRewardList()
	-- 领取按钮
	self.mGetBtn:setEnabled(next(self.mGuajiData.BaseGetGameResourceList) and true or false)
end

-- 获取正在进行任务信息
function DlgGuajiLayer:getRuningTaskInfo()
	local runningTask = nil
	for _, moduleInfo in ipairs(self.mGuajiData.GuajiInfo) do
		local endModuleIdList = self.mGuajiData.EndModuleId[tostring(moduleInfo.GuajiTimes)]
		if not endModuleIdList or not table.indexof(endModuleIdList, moduleInfo.ModuleId) then
			runningTask = moduleInfo
			break
		end
	end

	return runningTask
end

-- 创建当前任务倒计时
function DlgGuajiLayer:createCurTaskTimeUpdate(label)
	local runningTask = self:getRuningTaskInfo()
	if not runningTask then
		label:setString(TR("当前没有进行的任务"))
		return
	end
	-- 描述
	local descStr = TR("正在进行【%s】挂机，剩余时间", GuajiModel.items[runningTask.ModuleId].name)
	-- 计算任务剩余时间
	-- 其他任务消耗的时间
	local otherUseTime = 0
	for _, taskInfo in ipairs(self.mGuajiData.GuajiInfo) do
		local endModuleIdList = self.mGuajiData.EndModuleId[tostring(taskInfo.GuajiTimes)]
		if endModuleIdList and table.indexof(endModuleIdList, taskInfo.ModuleId) then
			otherUseTime = otherUseTime + taskInfo.NeedSeconds
		end
	end
	-- 总共消耗的时间
	local allUseTime = Player:getCurrentTime() - self.mGuajiData.BeginTime
	-- 任务剩余时间
	local timeLeft = runningTask.NeedSeconds - (allUseTime - otherUseTime)
	-- 创建倒计时
	self:createUpdateTime(label, timeLeft, descStr)
end

-- 整理数据
function DlgGuajiLayer:dealData()
	-- 服务器数据

	-- 表中数据
	-- 所有挂机任务
	self.mGuajiTaskList = self.mGuajiTaskList or table.values(GuajiModel.items)

	-- 衍生数据
	-- 已选任务
	self.mSelectdTaskList = {}
	for _, taskInfo in pairs(self.mGuajiData.GuajiInfo) do
		self.mSelectdTaskList[taskInfo.ModuleId] = true
	end
	-- 是否已开始挂机
	self.mIsBegin = next(self.mGuajiData.GuajiInfo) or next(self.mGuajiData.BaseGetGameResourceList)
end

--=========================服务器相关============================
-- 请求数据
function DlgGuajiLayer:requestInfo()
    HttpClient:request({
        moduleName = "Guaji",
        methodName = "GetGuajiInfo",
        svrMethodData = {},
        callback = function(response)
            if response and response.Status ~= 0 then
                return
            end
			dump(response.Value)
			self.mGuajiData = response.Value
			self:dealData()
			self:refreshUI()
        end
    })
    
end

-- 挂机请求
function DlgGuajiLayer:requestGuaji(moduleList, num)
	HttpClient:request({
        moduleName = "Guaji",
        methodName = "Guaji",
        svrMethodData = {moduleList, num},
        callback = function(response)
            if response and response.Status ~= 0 then
                return
            end
			-- dump(response.Value)
			self.mGuajiData = response.Value.Guaji
			self:dealData()
			self:refreshUI()
        end
    })
end

-- 奖励领取
function DlgGuajiLayer:requestReward()
	HttpClient:request({
        moduleName = "Guaji",
        methodName = "Reward",
        svrMethodData = {moduleList, num},
        callback = function(response)
            if response and response.Status ~= 0 then
                return
			end
			dump(response.Value)
			ui.ShowRewardGoods(response.Value.BaseGetGameResourceList)
			self.mGuajiData = response.Value.Guaji
			self:dealData()
			self:refreshUI()
			-- 检查是否升级
			PlayerAttrObj:showUpdateLayer()
        end
    })
end

return DlgGuajiLayer