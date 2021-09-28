-------------------------------------------------------
module(..., package.seeall)

local require = require;

local ui = require("ui/base");

-------------------------------------------------------
wnd_dice = i3k_class("wnd_dice", ui.wnd_base)

local UI_LIST =
{
	"ui/widgets/dafuweng1",
	"ui/widgets/dafuweng2",
}

local PAGE_NODES = 20 -- 单页有多少个节点
local SPEED_RATE = 10 -- 人物移动速度

--1下，2左，3上，4右
local DIRE_DOWN = 1
local DIRE_LEFT = 2
local DIRE_UP   = 3
local DIRE_RIGHT= 4

function wnd_dice:ctor()
	self._curNodeID = nil -- 当前位置的节点id（同布局）
	self._timeCounter = 0
	self._info = nil
	self._playAnisFlag = false -- 是否在移动（播放动画，协程）
end

function wnd_dice:configure()
	local widgets = self._layout.vars
	widgets.close:onClick(self, self.onCloseUI)
	widgets.diceBtn:onClick(self, self.onDiceBtn)
	widgets.eventBtn:onClick(self, self.onEventBtn)
	widgets.helpBtn:onClick(self, self.onHelpBtn)
end

function wnd_dice:onShow()
	math.randomseed(tostring(os.time()):reverse():sub(1, 7))
end

function wnd_dice:onHide()
	if self.co1 then
		g_i3k_coroutine_mgr:StopCoroutine(self.co1)
		self.co1 = nil
	end
	if self.co2 then
		g_i3k_coroutine_mgr:StopCoroutine(self.co2)
		self.co2 = nil
	end
end

function wnd_dice:refresh(info)
	self._info = info
	self:initNodeAndModel(info. groupId, info.pos)
	local diceTimes = i3k_db_dice_cfg[info.groupId].times
	self:setTimesLabel(diceTimes - info.dayUseCnt)
	self:updateDiceEventStatus(self._info.eventStatus)
end

function wnd_dice:clearDiceEventCount()
	self._info.nowEventCounts = 0
end
function wnd_dice:setDiceEventCount(count)
	self._info.nowEventCounts = count
end


function wnd_dice:onUpdate(dTime)
	self:moveOneStepTimer(dTime)
end


function wnd_dice:getPageIDbyNode(nodeID)
	if 2 * PAGE_NODES >= nodeID and nodeID > PAGE_NODES then
		return 2
	else
		return 1
	end
end

-- 设置3个筛子的buff，如果遇到减速buff，则将这个字段置为0
function wnd_dice:setFastBuff(count)
	self._info.fastLastCnt = count
end
function wnd_dice:getFastBuff()
	return self._info.fastLastCnt
end


function wnd_dice:initNodeAndModel(groupID, nodeID)
	self._curNodeID = nodeID
	local widgets = self._layout.vars
	local page = self:getPageIDbyNode(nodeID)
	local node = require(UI_LIST[page])() -- test
	self._nodeUI = node
	widgets.parent:addChild(node)
	-- error(page, nodeID)
	self:setUIImages(node, page)
	local nodeImg = node.vars["img"..nodeID]
	local pos = nodeImg:getPosition()

	self:setNpcModelPos(pos)

end

-- 显示模型
function wnd_dice:setNpcModelPos(pos)
	local widgets = self._layout.vars
	local npcmodule = widgets.model
	npcmodule:setPosition(pos)
	npcmodule:setLocalZOrder(99)
	local modelID = 1291
	local mcfg = i3k_db_models[modelID];
	if mcfg then
		npcmodule:setSprite(mcfg.path);
		npcmodule:setSprSize(mcfg.uiscale);
		npcmodule:playAction("stand")
	end
end

-- "stand" "walk"
function wnd_dice:setNpcNodelAction(actionName)
	local widgets = self._layout.vars
	local npcmodule = widgets.model
	npcmodule:playAction(actionName)
end

-- 1下，2左，3上，4右
function wnd_dice:setNpcFaceDirection(id)
	local widgets = self._layout.vars
	local npcmodule = widgets.model
	dir =
	{
		[DIRE_DOWN]  = math.pi / 2,
		[DIRE_LEFT]  = -math.pi,
		[DIRE_UP]    = -math.pi / 2,
		[DIRE_RIGHT] = math.pi / 6
	}

	npcmodule:setRotation(dir[id], 0)
end

function wnd_dice:OpenUINextFrame(eUIID, data)
	g_i3k_ui_mgr:AddTask(self, {}, function(ui)
		g_i3k_ui_mgr:OpenUI(eUIID)
		g_i3k_ui_mgr:InvokeUIFunction(eUIID, "setData", data)
	end,1)
end

-- 跳转页签，跳转到第几个页签，剩余的步数-- 播放完动画 InvokeUIFunction
function wnd_dice:jumpUI(page, lastSteps)
	-- TODO 播放特效
	local widgets = self._layout.vars
	local node = self._nodeUI
	widgets.parent:removeChild(node)
	local newNode = require(UI_LIST[page])()
	self._nodeUI = newNode
	widgets.parent:addChild(newNode)
	self:setUIImages(newNode, page)
end

function wnd_dice:moveNextSteps(page, lastSteps)
	local newNode = self._nodeUI
	local initNodePos = 1
	local imgID = page == 1 and initNodePos or (PAGE_NODES + initNodePos)
	local nodeImg = newNode.vars["img"..imgID]
	local pos = nodeImg:getPosition()
	self:setNpcModelPos(pos)
	self:setNpcNodelAction("walk") -- 切换ui也要播放一次动作
	-- move lastSteps
	self:moveSteps(imgID, lastSteps)
end

-- 设置每个位置显示的图片
function wnd_dice:setUIImages(node, page)
	for i = 1, PAGE_NODES do
		local initNodePos = i
		local imgID = page == 1 and initNodePos or (PAGE_NODES + initNodePos)
		local nodeImg = node.vars["img"..imgID]
		local info = self._info
		local eventID = g_i3k_db.i3k_db_get_dice_event(info.groupId, imgID)
		local iconID = self:getImageID(eventID)
		nodeImg:setImage(g_i3k_db.i3k_db_get_icon_path(iconID))
	end
end

function wnd_dice:getImageID(eventID)
	local cfg = i3k_db_dice_event[eventID]
	return cfg.icon[1]
end

function wnd_dice:getLeftDiceTimes()
	local info = self._info
	local diceTimes = i3k_db_dice_cfg[info.groupId].times
	local times = diceTimes - info.dayUseCnt -- + info.addCnt
	times = times < 0 and 0 or times
	return times
end
function wnd_dice:setTimesLabel()
	local times = self:getLeftDiceTimes()
	local widgets = self._layout.vars
	widgets.timesLabel:setText("剩余次数："..times)
end

function wnd_dice:useThrowCount()
	self._info.dayUseCnt = self._info.dayUseCnt + 1
end
function wnd_dice:addThrowCount(times)
	self._info.dayUseCnt = self._info.dayUseCnt - times
end


function wnd_dice:onEventBtn(sender)
	self:handleEvent()
end

function wnd_dice:setDiceBtnEnable(enable)
	local widgets = self._layout.vars
	-- widgets.diceBtn:setEnabled(enable)
	if enable then
		widgets.diceBtn:enable()
	else
		widgets.diceBtn:disable()
	end
end


function wnd_dice:onDiceBtn(sender)
	if self:getLeftDiceTimes() <= 0 then
		g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16391))
		return
	end

	if self._playAnisFlag then
		return
	end

	local groupID = self._info.groupId
	-- 如果领完奖或者放弃了
	if self._info.eventStatus == DICE_STATUS_FINISH or self._info.eventStatus == DICE_STATUS_GIVEUP then
		i3k_sbean.throwDice(groupID)
	else
		local msg = ""
		if self._info.eventStatus == DICE_STATUS_DOING then
			msg = "当前有未完成的任务，是否放弃当前任务并掷股子？"
		elseif self._info.eventStatus == DICE_STATUS_REWARD then
			msg = "当前有未领奖的任务，是否放弃当前任务并掷股子？"
		end
		local callback = function (ok)
			if ok then
				i3k_sbean.throwDice(groupID)
			else
				self:handleEvent()
			end
		end
		g_i3k_ui_mgr:ShowMessageBox2(msg, callback)
	end
end

-- 客户端自己维护一份状态
function wnd_dice:updateDiceEventStatus(status)
	self._info.eventStatus = status
	local widgets = self._layout.vars
	if not self._playAnisFlag then
		if self._info.eventStatus == DICE_STATUS_FINISH or self._info.eventStatus == DICE_STATUS_GIVEUP then
			widgets.diceBtn:show()
			widgets.eventBtn:hide()
		else
			widgets.diceBtn:hide()
			widgets.eventBtn:show()
		end
	end
end



function wnd_dice:throwDice(num)

	self._playAnisFlag = true
	self:setDiceBtnEnable(false)
	self:updateDiceEventStatus(DICE_STATUS_DOING) -- 收到协议，设置为未完成状态
	-- g_i3k_ui_mgr:PopupTipMessage("移动"..num.."步")
	self:useThrowCount()
	self:setTimesLabel()



	if #num == 1 then -- 只有一个字段
		self:onThrowOneDice(num[1])
	else
		self:setFastBuff(self:getFastBuff() - 1) -- 用一次加速buff
		self:onThrowThreeDice(num)
	end

end

function wnd_dice:onThrowOneDice(num)
	local widgets = self._layout.vars
	local model = widgets.diceModel
	model:show()
	model:setLocalZOrder(999)
	local modelID = 1307
	local mcfg = i3k_db_models[modelID];
	if mcfg then
		model:setSprite(mcfg.path);
		model:setSprSize(mcfg.uiscale);
		model:playAction("start")
	end
	self.co2 = g_i3k_coroutine_mgr:StartCoroutine(function()
		g_i3k_coroutine_mgr.WaitForSeconds(1.2) --延时
		-- TODO  如果次数大于6次，就用3个骰子(判断6是不对的。)
		model:playAction("number_"..num, 1)
		g_i3k_coroutine_mgr.WaitForSeconds(3) --延时
		self:setNpcNodelAction("walk")
		model:hide()
		self:testMove(num)
		g_i3k_coroutine_mgr:StopCoroutine(self.co2)
		self.co2 = nil
	end)
end


function wnd_dice:onThrowThreeDice(range)
	local allSteps = 0
	for k, v in ipairs(range) do
		allSteps = allSteps + v
	end
	local list = range
	local widgets = self._layout.vars
	local modelList = { widgets.diceModel, widgets.diceModel2, widgets.diceModel3}
	for k, v in ipairs(modelList) do
		local model = v
		model:show()
		model:setLocalZOrder(999)
		local modelID = 1307
		local mcfg = i3k_db_models[modelID];
		if mcfg then
			model:setSprite(mcfg.path);
			model:setSprSize(mcfg.uiscale);
			model:playAction("start")
		end
	end
	self.co2 = g_i3k_coroutine_mgr:StartCoroutine(function()
		g_i3k_coroutine_mgr.WaitForSeconds(1.2) --延时
		for k, v in ipairs(modelList) do
			local num = list[k]
			v:playAction("number_"..num, 1)
		end

		g_i3k_coroutine_mgr.WaitForSeconds(3) --延时
		self:setNpcNodelAction("walk")
		for k, v in ipairs(modelList) do
			v:hide()
		end
		self:testMove(allSteps)
		g_i3k_coroutine_mgr:StopCoroutine(self.co2)
		self.co2 = nil
	end)
end

-- 分段切割，第一次切割，小于6，并且给后面至少留2个位置，第二次切割小于6，并且留一个，剩下的就是最后一个了
-- range 最小为3, 最大18.(伪随机)
function wnd_dice:getRandList(range)
	local result = {}
	local rand1 = math.ceil(range / 3)
	if rand1 == 5 then
		rand1 = 6
	end

	local left2 = (range - rand1)
	local dev2 = math.ceil(left2 / 2)
	local range2 = 0
	local rand2 = 0
	if dev2 > 3 then -- >= 6
		range2 = 6 - dev2
		rand2 = 6 - math.random(0, range2)
	else
		rand2 = dev2
	end

	local rand3 = range - rand1 - rand2
	return {rand1, rand2, rand3}
end

-- test function
function wnd_dice:testMove(steps)
	local curPos = self._curNodeID
	self._curNodeID = curPos + steps
	if self._curNodeID > 2 * PAGE_NODES then
		self._curNodeID = self._curNodeID -  2 * PAGE_NODES
	end
	self:moveSteps(curPos, steps)
	-- g_i3k_ui_mgr:PopupTipMessage("目标位置：".. self._curNodeID)
end

-- 从开始节点， 移动n步
function wnd_dice:moveSteps(nodeID, steps)
	self.co1 = g_i3k_coroutine_mgr:StartCoroutine(function()
		local startNodeID = nodeID
		for i = 1, steps do
			local flag = self:moveOneStep(startNodeID + i - 1, steps - i)
			if flag then
				return -- 第一页的路线已经行走完
			end
			g_i3k_coroutine_mgr.WaitForSeconds(0.15 * SPEED_RATE) --延时
		end
		g_i3k_coroutine_mgr.WaitForNextFrame() -- 当steps == 1时，上面等待的时间可能不会执行，会出现在onUpdate方法中打开ui的报错
		self._playAnisFlag = false
		self:setDiceBtnEnable(true)
		self:handleEvent()
		g_i3k_coroutine_mgr:StopCoroutine(self.co1)
		self.co1 = nil
	end)
end


-- 移动一步
function wnd_dice:moveOneStep(nodeID, lastSteps)
	local node = self._nodeUI
	local startNode = node.vars["img"..nodeID]
	local endNode = node.vars["img"..(nodeID + 1)]
	if not endNode then
		local page = self:getPageIDbyNode(nodeID + 1)
		g_i3k_coroutine_mgr:StopCoroutine(self.co1) -- 停掉上一个协程（这里并不会立即停止掉co1这个协程，return一个标记）
		self.co1 = nil
		self._jumpUIData = {page = page, lastSteps = lastSteps} -- 数据保存一下，在停掉协程之后，当onUpdate()检查到非空，马上立即开启一个新的协程，完成切换ui的剩余步骤
		return true

	else
		local startPos = startNode:getPosition()
		local endPos = endNode:getPosition()
		self._startPos = startPos
		self._endPos = endPos
		local groupID = self._info.groupId
		local dir = i3k_db_dice[groupID][nodeID].directionID
		self:setNpcFaceDirection(dir)
		self._moveOneStepTimerFlag = true
	end
end

function wnd_dice:moveOneStepTimer(dTime)
	if self._moveOneStepTimerFlag then
		local startPos = self._startPos
		local endPos = self._endPos
		local deltX = - (startPos.x - endPos.x)
		local deltY = - (startPos.y - endPos.y)
		local duringTime = 0.1 * SPEED_RATE -- 持续时间
		local speedX = deltX / duringTime
		local speedY = deltY / duringTime

		self._timeCounter = self._timeCounter + dTime
		local posX = speedX * self._timeCounter
		local posY = speedY * self._timeCounter

		local pos = {x = posX + startPos.x, y = posY + startPos.y}
		local model = self._layout.vars.model
		model:setPosition(pos)
		if self._timeCounter > duringTime then
			self._timeCounter = 0
			self._moveOneStepTimerFlag = false
		end
	end

	if self._jumpUIData then
		-- self:jumpUI(self._jumpUIData.page, self._jumpUIData.lastSteps)
		local data = {page = self._jumpUIData.page, steps = self._jumpUIData.lastSteps}
		self:OpenUINextFrame(eUIID_DiceYun, data)
		self._jumpUIData = nil
	end
end

-----------------处理任务事件-----------------------
function wnd_dice:handleEvent()
	self:setNpcNodelAction("stand")
	self:setNpcFaceDirection(DIRE_DOWN) -- 默认朝下
	local nodeID = self._curNodeID
	local groupID = self._info.groupId
	local info = self._info
	g_i3k_db.i3k_db_dice_handle_event(groupID, nodeID, info)
end

function wnd_dice:onHelpBtn(sender)
	g_i3k_ui_mgr:ShowHelp(i3k_get_string(16403))
end


function wnd_create(layout, ...)
	local wnd = wnd_dice.new()
	wnd:create(layout, ...)
	return wnd;
end
