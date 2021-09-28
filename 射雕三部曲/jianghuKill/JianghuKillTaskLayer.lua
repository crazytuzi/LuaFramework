--[[
    文件名: JianghuKillTaskLayer.lua
    描述: 江湖杀任务界面
    创建人: yanghongsheng
    创建时间: 2018.09.06
-- ]]
local JianghuKillTaskLayer = class("JianghuKillTaskLayer", function(params)
	return display.newLayer()
end)

--[[
	params:
		taskType 	任务类型（1：势力任务 2：职业任务）（必须）
]]

function JianghuKillTaskLayer:ctor(params)
	self.mTaskType = params.taskType
	self.mTaskConfigInfo = self:getTaskConfig()	-- 配置数据
	self.mTaskInfo = {}							-- 服务器数据
	self.mReceivedTaskTypeList = {}				-- 已完成任务类型列表
	-- 弹窗
    local parentLayer = require("commonLayer.PopBgLayer").new({
    	bgImage = "jhs_40.png",
    	bgSize = cc.size(615, 916),
    	closeImg = "",
    	title = self.mTaskConfigInfo.titleImg,
    	titlePos = cc.p(310, 895),
    })
    self:addChild(parentLayer)

    -- 保存弹框控件信息
    self.mBgSprite = parentLayer.mBgSprite
    self.mBgSize = self.mBgSprite:getContentSize()

	self:initUI()

	-- 请求服务器数据
	self:requestTaskInfo()
	-- self.mTaskConfigInfo.refreshTaskList()
end

-- 初始化
function JianghuKillTaskLayer:initUI()
    -- 背景图
    local bgSprite1 = ui.newSprite("jhs_39.png")
    bgSprite1:setPosition(self.mBgSize.width*0.5, 800)
    self.mBgSprite:addChild(bgSprite1)
    -- 显示势力（职业）
    local forceLabel = ui.newLabel({
    		text = "",
    		color = cc.c3b(0xff, 0xee, 0xd0),
    		outlineColor = Enums.Color.eRed,
    		size = 27,
    		outlineSize = 1,
    	})
    forceLabel:setPosition(95, 835)
    self.mBgSprite:addChild(forceLabel)
    self.mForceLabel = forceLabel
    -- 显示等级
    local lvLabel = ui.newLabel({
    		text = "",
    		color = cc.c3b(0xff, 0xee, 0xd0),
    		outlineColor = Enums.Color.eRed,
    		size = 24,
    		outlineSize = 1,
    	})
    lvLabel:setPosition(95, 800)
    self.mBgSprite:addChild(lvLabel)
    self.mLvLabel = lvLabel
    -- 显示进度条
    local progBar = require("common.ProgressBar"):create({
        bgImage = "jhs_44.png",
        barImage = "jhs_45.png",
        currValue = 0,
        maxValue = 10,
        contentSize = cc.size(400, 30),
        -- needLabel = true,
        percentView = false,
        size = 20,
        color = Enums.Color.eWhite,
        outlineColor = cc.c3b(0x46, 0x22, 0x0d),
    })
    progBar:setPosition(370, 830)
    self.mBgSprite:addChild(progBar)
    self.mProgBar = progBar
    -- 进度数字
    local progLabel = ui.newLabel({
            text = "0/10",
            color = Enums.Color.eWhite,
            size = 18,
        })
    progLabel:setPosition(progBar:getContentSize().width*0.5, progBar:getContentSize().height*0.5)
    progBar:addChild(progLabel)
    self.mProgLabel = progLabel
    -- 进度条标签
    local progTag = ui.newSprite(self.mTaskConfigInfo.progTagTexture)
    progTag:setPosition(170, 830)
    self.mBgSprite:addChild(progTag)
    -- 提示文字
    if self.mTaskType == 1 then
        local hintLabel = ui.newLabel({
                text = TR("累计荣誉点达到要求后自动升级"),
                color = cc.c3b(255, 231, 72),
                size = 20,
            })
        hintLabel:setPosition(350, 800)
        self.mBgSprite:addChild(hintLabel)
    end
    -- 更换职业
    if self.mTaskConfigInfo.isChangeBtn then
    	local changeBtn = ui.newButton({
    			normalImage = "c_28.png",
    			text = self.mTaskConfigInfo.changeText,
    			clickAction = function ()
    				if self.mTaskConfigInfo.changeCb then
    					self.mTaskConfigInfo.changeCb()
    				end
    			end
    		})
    	changeBtn:setPosition(420, 770)
    	self.mBgSprite:addChild(changeBtn)
    end
    -- 升级效果
    local upLvBtn = ui.newButton({
    		normalImage = self.mTaskConfigInfo.upLvImg,
    		clickAction = function ()
    			if self.mTaskConfigInfo.upLvCb then
					self.mTaskConfigInfo.upLvCb()
				end
    		end
    	})
    upLvBtn:setPosition(540, 770)
    self.mShowLvBoxBtn = upLvBtn
	self.mBgSprite:addChild(upLvBtn)
    -- 福利小红点
    if self.mTaskConfigInfo.upLvReddotEvent then
        local function dealReddot(redDotSprite)
            redDotSprite:setVisible(RedDotInfoObj:isValid(unpack(self.mTaskConfigInfo.upLvReddotEvent)))
        end
        ui.createAutoBubble({parent = upLvBtn,eventName = RedDotInfoObj:getEvents(unpack(self.mTaskConfigInfo.upLvReddotEvent)), refreshFunc = dealReddot})
    end
	-- 任务列表背景
	local listBgSize = cc.size(560, 690)
	local listBg = ui.newScale9Sprite("c_17.png", listBgSize)
	listBg:setAnchorPoint(cc.p(0.5, 0))
	listBg:setPosition(self.mBgSize.width*0.5, 25)
	self.mBgSprite:addChild(listBg)
	-- 任务列表
	self.mTaskListView = ccui.ListView:create()
    self.mTaskListView:setDirection(ccui.ScrollViewDir.vertical)
    self.mTaskListView:setBounceEnabled(true)
    self.mTaskListView:setContentSize(cc.size(listBgSize.width-30, listBgSize.height-20))
    self.mTaskListView:setItemsMargin(5)
    self.mTaskListView:setGravity(ccui.ListViewGravity.centerHorizontal)
    self.mTaskListView:setAnchorPoint(cc.p(0.5, 0.5))
    self.mTaskListView:setPosition(listBgSize.width*0.5, listBgSize.height*0.5)
    listBg:addChild(self.mTaskListView)

    -- 规则按钮
	local ruleBtn = ui.newButton({
        normalImage = "c_72.png",
        clickAction = function()
        	MsgBoxLayer.addRuleHintLayer(TR("规则"), self.mTaskConfigInfo.ruleTextList)
        end,
    })
    ruleBtn:setPosition(35, 890)
    self.mBgSprite:addChild(ruleBtn)

    -- 返回按钮
    local closeBtn = ui.newButton({
		normalImage = "c_29.png",
		clickAction = function()
    		LayerManager.removeLayer(self)
        end,
	})
	closeBtn:setPosition(580, 890)
    self.mBgSprite:addChild(closeBtn)

end

-- 刷新势力任务列表
function JianghuKillTaskLayer:refreshForceTaskListView()
    self.mTaskList = {}
	for i, taskModel in ipairs(self.mTaskConfigInfo.taskModelList) do
        if self.mTaskInfo[taskModel.taskType] then
            self.mTaskList[taskModel.taskType] = self.mTaskConfigInfo.taskModelList[self.mTaskInfo[taskModel.taskType].TaskId]
        else
            self.mTaskList[taskModel.taskType] = self.mTaskList[taskModel.taskType] or taskModel
        end
    end

    self:refreshListView()
end

-- 刷新职业任务列表
function JianghuKillTaskLayer:refreshJobTaskListView()
    self.mTaskList = {}
    for i, taskModel in ipairs(self.mTaskConfigInfo.taskModelList) do
        if taskModel.ID == self.mId then
            if self.mTaskInfo[taskModel.taskType] then
                self.mTaskList[taskModel.taskType] = self.mTaskConfigInfo.taskModelList[self.mTaskInfo[taskModel.taskType].TaskId]
            else
                self.mTaskList[taskModel.taskType] = self.mTaskList[taskModel.taskType] or taskModel
            end
        end
    end

    self:refreshListView()
end

function JianghuKillTaskLayer:refreshListView()
    local taskTypeList = table.keys(self.mTaskList or {})
    -- 排序
    table.sort(taskTypeList, function(taskType1, taskType2)
        local taskModel1 = self.mTaskList[taskType1]
        local taskModel2 = self.mTaskList[taskType2]

        local taskInfo1 = self.mTaskInfo[taskType1]
        local taskInfo2 = self.mTaskInfo[taskType2]

        local taskProg1 = taskInfo1 and taskInfo1.Progress or 0
        local taskProg2 = taskInfo2 and taskInfo2.Progress or 0
        local taskIsReceived1 = taskInfo1 and taskInfo1.IsReceived or false
        local taskIsReceived2 = taskInfo2 and taskInfo2.IsReceived or false

        -- 可领取
        if (taskProg1 >= taskModel1.taskAim) ~= (taskProg2 >= taskModel2.taskAim) then
            return (taskProg1 >= taskModel1.taskAim)
        end

        -- 完成
        if taskIsReceived1 ~= taskIsReceived2 then
            return not taskIsReceived1
        end

        return taskType1 < taskType2
    end)

    for i, taskType in ipairs(taskTypeList) do
        self:refreshItem(i, taskType)
    end
end

function JianghuKillTaskLayer:refreshItem(index, taskType)
	local cellSize = cc.size(self.mTaskListView:getContentSize().width, 145)

	local cellItem = self.mTaskListView:getItem(index-1)
	if not cellItem then
		cellItem = ccui.Layout:create()
		cellItem:setContentSize(cellSize)
		self.mTaskListView:pushBackCustomItem(cellItem)
	end
	cellItem:removeAllChildren()

	local taskProg = self.mTaskInfo[taskType] and self.mTaskInfo[taskType].Progress or 0
	local taskId = self.mTaskList[taskType].taskID
	local taskModel = self.mTaskConfigInfo.taskModelList[taskId]

	-- 背景
	local bgSprite = ui.newScale9Sprite("jhs_42.png", cellSize)
	bgSprite:setPosition(cellSize.width*0.5, cellSize.height*0.5)
	cellItem:addChild(bgSprite)
	-- 图标
    local taskSprite = ui.newSprite(taskModel.pic..".png")
    taskSprite:setPosition(60, cellSize.height*0.5)
    cellItem:addChild(taskSprite)

	-- 进度文字
	local progLabel = ui.newLabel({
			text = TR("#a0461f进度：%s%d/%d", taskProg >= taskModel.taskAim and "#258711" or "#ea2c00",taskProg, taskModel.taskAim),
			color = cc.c3b(0x37, 0xff, 0x40),
		})
	progLabel:setAnchorPoint(cc.p(0, 0))
	progLabel:setPosition(130, 90)
	cellItem:addChild(progLabel)

	-- 任务描述
	local taskDesLabel = ui.newLabel({
			text = string.format(taskModel.taskDescribe, tostring(taskModel.taskAim)),
			color = cc.c3b(0x46, 0x22, 0x0d),
			dimensions = cc.size(260, 0)
		})
	taskDesLabel:setAnchorPoint(cc.p(0, 1))
	taskDesLabel:setPosition(130, 70)
	cellItem:addChild(taskDesLabel)

	-- 领取按钮
	local getBtn = ui.newButton({
			normalImage = "c_28.png",
			text = TR("领取"),
			clickAction = function (pSender)
                local actionStartPos = pSender:getParent():convertToWorldSpace(cc.p(pSender:getPosition()))
				self:requestTaskReward(taskId, actionStartPos)
			end,
		})
	getBtn:setPosition(450, cellSize.height*0.35)
	cellItem:addChild(getBtn)
	-- 领取按钮状态
	-- 已完成
	if self.mTaskInfo[taskType] and self.mTaskInfo[taskType].IsReceived then
		getBtn:setEnabled(false)
		getBtn:setTitleText(TR("已完成"))
	-- 进度不足
	elseif taskProg < taskModel.taskAim then
		getBtn:setEnabled(false)
	end

    if not self.IsCanReceive and taskProg >= taskModel.taskAim and (not self.mTaskInfo[taskType] or not self.mTaskInfo[taskType].IsReceived) then
        self.IsCanReceive = true
    end

	-- 奖励
	local rewardLabel = ui.newLabel({
			text = string.format("{jhs_123.png}%s  {jhs_122.png}%s",
				Utility.numberWithUnit(taskModel.taskExpReward),
				Utility.numberWithUnit(taskModel.taskHonorReward)),
			color = cc.c3b(0x46, 0x22, 0x0d),
		})
	rewardLabel:setAnchorPoint(1, 0.5)
	rewardLabel:setPosition(cellSize.width-10, cellSize.height*0.75)
	cellItem:addChild(rewardLabel)
end

function JianghuKillTaskLayer:refreshUI()
	-- 刷新等级显示
	self.mLvLabel:setString(TR("%d级", self.mLv))
	-- 刷新进度条
    local curProg, maxPorg = self.mTaskConfigInfo.getProgInfo()
    self.mProgBar:setMaxValue(maxPorg)
    self.mProgBar:setCurrValue(curProg)
    if curProg == maxPorg then
        self.mProgLabel:setString(TR("已满级"))
    else
        self.mProgLabel:setString(string.format("%d/%d", curProg, maxPorg))
    end
    -- 刷新职业
    self.mForceLabel:setString(self:getName())

    -- -- 刷新升级福利弹窗按钮
    -- self.mShowLvBoxBtn:setVisible(self.mLv > 0)

	-- 刷新列表
	self.mTaskConfigInfo.refreshTaskList()
end

function JianghuKillTaskLayer:getName()
    if self.mTaskType == 1 then
        return self.mId == 1 and Enums.JHKCampName[self.mId]..TR("员") or Enums.JHKCampName[self.mId]..TR("徒")
    elseif self.mTaskType == 2 then
        return JianghukillJobModel.items[self.mId].name
    end
end

-- 势力经验进度
function JianghuKillTaskLayer:getForceExpProg()
    local forceLvModel = JianghukillForcelvModel.items[self.mLv+1]
    if forceLvModel then
        return self.mExp or 0, forceLvModel.requestHonor
    else
        return JianghukillForcelvModel.items[self.mLv].requestHonor, JianghukillForcelvModel.items[self.mLv].requestHonor
    end
end

-- 职业经验进度
function JianghuKillTaskLayer:getJobExpProg()
    local jobLvModel = JianghukillOccupationalprope.items[self.mId][self.mLv+1]
    if jobLvModel then
        local curLvExp = JianghukillOccupationalprope.items[self.mId][self.mLv] and JianghukillOccupationalprope.items[self.mId][self.mLv].exp or 0
        return self.mExp or 0, jobLvModel.exp
    else
        local lvExpNum = JianghukillOccupationalprope.items[self.mId][self.mLv].exp
        return lvExpNum, lvExpNum
    end
end

-- 获取不同任务类型的配置数据
function JianghuKillTaskLayer:getTaskConfig()
	local ConfigData = {
		[1] = {
			titleImg = "jhs_46.png",							-- 标题图片
			ruleTextList = {									-- 规则文本
                TR("1.势力等级是指玩家个人在当前势力的等级。"),
                TR("2.势力等级可通过累计获得荣誉点来提升，累计荣誉点满足要求后自动升级，不会消耗荣誉点。"),
                TR("3.提升势力等级，可以提升在江湖杀中的属性加成和势力的每日福利奖励。"),
                TR("4.如果是在江湖杀赛季中提升势力等级，升级后的江湖杀属性加成需要下赛季才会生效。"),
			},
			isChangeBtn = false,								-- 是否有更换按钮
			upLvImg = "jhs_43.png", 								-- 升级预览按钮图片
            upLvReddotEvent = {ModuleSub.eJiangHuKillForce, "Sign"}, -- 升级预览按钮是小红点
			upLvCb = handler(self, self.perviewForceBox),		-- 查看势力加成弹窗回调
			taskModelList = JianghukillForcetaskModel.items, 	-- 任务模型列表
            refreshTaskList = handler(self, self.refreshForceTaskListView),      -- 刷新势力任务列表
            getInfoMethod = "GetForceTaskInfo",                 -- 获取任务数据接口
            getRewardMethod = "ReceiveForceTaskReward",         -- 获取奖励接口
            getProgInfo = handler(self, self.getForceExpProg),  -- 获取经验数据
            progTagTexture = "jhs_122.png",                     -- 进度条标识图标
		},
		[2] = {
			titleImg = "jhs_47.png",							-- 标题图片
			ruleTextList = {									-- 规则文本
                TR("1.完成任务可以获得职业经验来提升当前职业等级。"),
                TR("2.江湖杀赛季中不可更换职业。"),
                TR("3.提升职业等级可以提升相应职业特性。"),
                TR("4.排行榜按照职业划分，每个职业排行榜相互独立。"),
			},
			isChangeBtn = true,									-- 是否有更换按钮
			changeText = TR("查看职业"),							-- 更换按钮标题
			changeCb = handler(self, self.changeJob), 			-- 更换职业回调
			upLvImg = "jhs_60.png", 								-- 升级预览按钮图片
			upLvCb = handler(self, self.perviewJobBox),			-- 查看职业加成弹窗回调
			taskModelList = JianghukillJobTaskModel.items,       -- 任务模型列表
            refreshTaskList = handler(self, self.refreshJobTaskListView),      -- 刷新职业任务列表
            getInfoMethod = "GetJobTaskInfo",                   -- 获取任务数据接口
            getRewardMethod = "ReceiveJobTaskReward",           -- 获取奖励接口
            getProgInfo = handler(self, self.getJobExpProg),    -- 获取经验数据
            progTagTexture = "jhs_123.png",                     -- 进度条标识图标
		},
	}

	return ConfigData[self.mTaskType]
end

-- 更换职业回调
function JianghuKillTaskLayer:changeJob()
    LayerManager.addLayer({
            name = "jianghuKill.JianghuKillSeleJobLayer",
            data = {
                jobId = self.mId,
                isLook = true,
            },
            cleanUp = false,
        })
end

-- 查看势力加成弹窗回调
function JianghuKillTaskLayer:perviewForceBox()
    LayerManager.addLayer({
            name = "jianghuKill.JianghuKillForceBoxLayer",
            data = {
                forceId = self.mId,
                forceLv = self.mLv,
                isCanReceive = self.mIsCanReceive,
                callback = function (isCanReceive)
                    self.mIsCanReceive = isCanReceive
                end,
            },
            cleanUp = false,
        })
end

-- 查看职业加成弹窗回调
function JianghuKillTaskLayer:perviewJobBox()
    LayerManager.addLayer({
            name = "jianghuKill.JianghuKillJobBoxLayer",
            data = {
                jobId = self.mId,
                jobLv = self.mLv,
            },
            cleanUp = false,
        })
end

-- 播放图标飞去进度条动作
function JianghuKillTaskLayer:playFlyAction(startPos)
    local testSprite = ui.newSprite(self.mTaskConfigInfo.progTagTexture)
    testSprite:setPosition(startPos.x, startPos.y-100)
    self.mBgSprite:addChild(testSprite)
    -- 积分领取动画
    testSprite:runAction(cc.Sequence:create({
        cc.Spawn:create(cc.MoveTo:create(0.75, cc.p(370, 830)), cc.ScaleTo:create(0.75, 0.1)),
        cc.CallFunc:create(function ()
            testSprite:removeFromParent()
        end),
    }))
end

-- 查看职业加成弹窗回调
function JianghuKillTaskLayer:refreshLayer(response)
    local tempTaskList = {}

    if response.Value.JianghuKillJobTaskInfo then
        self.mId = response.Value.JianghuKillJobTaskInfo.JobId
        self.mLv = response.Value.JianghuKillJobTaskInfo.JobLv
        self.mExp = response.Value.JianghuKillJobTaskInfo.JobExp
        tempTaskList = response.Value.JianghuKillJobTaskInfo.TaskInfo
    elseif response.Value.JianghuKillForceTaskInfo then
        self.mId = response.Value.JianghuKillForceTaskInfo.ForceId
        self.mLv = response.Value.JianghuKillForceTaskInfo.ForceLv
        self.mExp = response.Value.JianghuKillForceTaskInfo.ForceTotalExp
        self.mIsCanReceive = not response.Value.JianghuKillForceTaskInfo.Sign
        tempTaskList = response.Value.JianghuKillForceTaskInfo.TaskInfo
    end

    self.mTaskInfo = {}
    for _, taskInfo in pairs(tempTaskList) do
        self.mTaskInfo[taskInfo.TaskType] = taskInfo
    end

    self:refreshUI()
end

--===================================网络相关===================================
-- 请求任务数据
function JianghuKillTaskLayer:requestTaskInfo()
    HttpClient:request({
        moduleName = "Jianghukill",
        methodName = self.mTaskConfigInfo.getInfoMethod,
        svrMethodData = {},
        callbackNode = self,
        callback = function(response)
            -- 容错处理
            if response.Status ~= 0 then
                return
            end
            -- dump(response, "任务")
            
            self:refreshLayer(response)
        end
    })
end

-- 请求任务奖励
function JianghuKillTaskLayer:requestTaskReward(taskId, startPos)
    HttpClient:request({
        moduleName = "Jianghukill",
        methodName = self.mTaskConfigInfo.getRewardMethod,
        svrMethodData = {taskId},
        callbackNode = self,
        callback = function(response)
            -- 容错处理
            if response.Status ~= 0 then
                return
            end
            -- dump(response, "奖励")
            self:playFlyAction(startPos)

            ui.showFlashView(TR("领取成功"))

            self:refreshLayer(response)
        end
    })
end

return JianghuKillTaskLayer