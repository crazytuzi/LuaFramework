require"Lang"

UIActivityBigNumber = {}

local LUCK_ANIMATION_PATH = "ani/ui_anim/ui_anim_wuxingyunshuzi/ui_anim_wuxingyunshuzi.ExportJson"
local LUCK_ANIMATION_NAME = "ui_anim_wuxingyunshuzi"

local thisActivityDict
local text_my_ranking
local text_my_num
local text_mymaximum
local text_time
local text_countdown
local text_myintegral
local btn_extract
local btn_help
local btn_refresh
local btn_reduction
local btn_luck
local text_extract_price
local text_reduction_price
local view_people
local panel_people
local panels = {}
local image_prize_di

local luckRewards
local luckDigit = 0
local myLuckCount = 0
local curNumber = 0
local maxNumber = 0
local rank = 0
local rankList
local freeTimes = 0
local getScore = 0
local myLuckRewards

local function countDown()
	countdownSeconds = countdownSeconds - 1
	if countdownSeconds < 0 then
		countdownSeconds = 0
	end
	if UIActivityBigNumber.Widget then
		local dd = math.floor(countdownSeconds / 3600 / 24) --天
		local hh = math.floor(countdownSeconds / 3600 % 24) --小时
		local mm = math.floor(countdownSeconds / 60 % 60) --分
		local ss = math.floor(countdownSeconds % 60) --秒
		text_countdown:setString(string.format(Lang.ui_activity_BigNumber1, dd, hh, mm, ss))
	end
end

local function resetRankList(rankList)
	view_people:removeAllChildren()
	local rankArray = utils.stringSplit(rankList, ";")
	local x,y = panel_people:getPosition()
	local s   = panel_people:getContentSize()
	for i=1,#rankArray do
		local temp = utils.stringSplit(rankArray[i],"\1")
		local item = panel_people:clone()
		item:getChildByName("label_1"):setString(temp[1])
		item:getChildByName("text_name1"):setString(temp[2])
		item:getChildByName("text_integral1"):setString(temp[3])
		item:setPosition(x,-y+i*s.height)
		view_people:addChild(item)
	end
	local innerHeight = s.height * #rankArray
	if innerHeight < view_people:getContentSize().height then
		innerHeight = view_people:getContentSize().height
	end
	view_people:setInnerContainerSize(cc.size(view_people:getContentSize().width, innerHeight))
	local children = view_people:getChildren()
	for i = 1, #children do
		innerHeight = innerHeight - s.height
		children[i]:setPosition(x, innerHeight)
	end
end

local kTagLabel = 1
local kTagNextLabel = 2
local kTagRollLabel = 3
local DIGIT_COUNT = 5

local function getNums(num, limit)
	local nums = {}
	num = tostring(num)
	for i = string.len(num), 1, -1 do
		table.insert(nums, 1, tonumber(string.sub(num, i, i)))
	end
	while #nums > limit do
		table.remove(#num, 1)
	end
	while #nums < limit do
		table.insert(nums, 1, 0)
	end
	return nums
end

local function rock(number,immediately)
	local nums = getNums(number, DIGIT_COUNT)
	if immediately then
		for i = 1,DIGIT_COUNT do
			local panel = panels[i]
			panel:unscheduleUpdate()
			local panel_size = panel:getContentSize()
			local label_number = panel.label_number
			label_number:setPosition(panel_size.width / 2, panel_size.height / 2)
			label_number:setString(nums[i])
			local label_roll = panel.label_roll
			label_roll:setPosition(panel_size.width / 2, panel_size.height / 2)
			label_roll:stopAllActions()
		end
		text_my_num:setString(curNumber)
		text_mymaximum:setString(maxNumber)
		text_my_ranking:setString(rank)
		resetRankList(rankList)
		return
	end
	local extra = 10
	for i = 1,DIGIT_COUNT do
		local panel = panels[i]
		local panel_size = panel:getContentSize()
		local label_number= panel.label_number
		local label_next  = panel.label_next
		local label_roll  = panel.label_roll
		
		label_number:setPosition(panel_size.width / 2, panel_size.height / 2)
		label_roll:setPosition(panel_size.width / 2, panel_size.height / 2)
		label_roll:setVisible(false)

		local num = tonumber(label_number:getString())
		label_roll:setString(tostring(num))
		label_next:setString(tostring(math.floor((num + 1) % 10)))

		local rollCount = 3 * 10 + (DIGIT_COUNT - i) * extra + math.floor((nums[i] - num + 10) % 10)

		local action = cc.MoveBy:create(rollCount * 3 / 40, cc.p(0, -rollCount * panel_size.height))
		action = cc.EaseCubicActionOut:create(action)
		btn_extract:setEnabled(false)
		btn_reduction:setEnabled(false)
		btn_refresh:setEnabled(false)
		btn_help:setEnabled(false)
		btn_luck:setEnabled(false)
		panel.rolling = true
		label_roll:runAction(cc.Sequence:create(action,cc.CallFunc:create(
					function()
						panel.rolling = false
						if i == 1 then
							text_my_num:setString(curNumber)
							text_mymaximum:setString(maxNumber)
							text_my_ranking:setString(rank)
							resetRankList(rankList)
							--幸运数字
							if myLuckCount > 0 then
								local luckArmature = ccs.Armature:create(LUCK_ANIMATION_NAME)
								luckArmature:setVisible(true)
								luckArmature:setPosition(320,568)
								luckArmature:getAnimation():setMovementEventCallFunc(
									function(armature,movementType,movementName)
										if movementType == ccs.MovementEventType.complete then
											btn_extract:setEnabled(true)
											btn_reduction:setEnabled(true)
											btn_refresh:setEnabled(true)
											btn_help:setEnabled(true)
											btn_luck:setEnabled(true)
											UIActivityBigNumber.Widget:removeChild(luckArmature,true)
											if myLuckRewards then
												UIAwardGet.setOperateType(UIAwardGet.operateType.award,utils.stringSplit(myLuckRewards,';'))
												UIManager.pushScene("ui_award_get")
												myLuckRewards = nil
												UIActivityTime.refreshMoney()
											end
										end
									end
								)
								UIActivityBigNumber.Widget:addChild(luckArmature)
								luckArmature:setLocalZOrder(999)
								for i=1,myLuckCount do
									luckArmature:getBone(tostring(i)):changeDisplayWithIndex(luckDigit,true)
								end
								luckArmature:getAnimation():playWithIndex(myLuckCount-1,-1,0)
							else
								btn_extract:setEnabled(true)
								btn_reduction:setEnabled(true)
								btn_refresh:setEnabled(true)
								btn_help:setEnabled(true)
								btn_luck:setEnabled(true)
							end
						end
					end
				)
			)
		)
		panel:scheduleUpdate(
			function()
				if panel.rolling then
					local d = panel_size.height / 2 - label_roll:getPositionY()
					local remain = math.floor(d % panel_size.height)
					local count = math.floor(d / panel_size.height)
					local curNum = math.floor((num + count) % 10)
					label_number:setPosition(panel_size.width / 2, panel_size.height / 2 - remain)
					label_number:setString(tostring(curNum))
					label_next:setString(tostring(math.floor((curNum + 1) % 10)))
				else
					label_number:setString(tostring(nums[i]))
					label_next:setString(tostring(math.floor((nums[i] + 1) % 10)))
					label_number:setPosition(panel_size.width / 2, panel_size.height / 2)
					label_roll:setPosition(panel_size.width / 2, panel_size.height / 2)
					panel:unscheduleUpdate()
				end
			end
		)
	end
end

local function netCallbackFunc(_msgData)
	local code = tonumber(_msgData.header)
	rank = _msgData.msgdata.int.rank
	rankList = _msgData.msgdata.string.rankList
	if code == StaticMsgRule.bigNumberEnter then
		luckDigit = _msgData.msgdata.int.luckDigit
		curNumber = _msgData.msgdata.int.cur
		maxNumber = _msgData.msgdata.int.max
		rank = _msgData.msgdata.int.rank
		rankList = _msgData.msgdata.string.rankList
		text_myintegral:setString(_msgData.msgdata.int.score)
		freeTimes = _msgData.msgdata.int.freeTimes
		getScore = _msgData.msgdata.int.getScore
		text_reduction_price:setString(Lang.ui_activity_BigNumber2 .. _msgData.msgdata.int.recoverScore)
		luckRewards = _msgData.msgdata.message.luckRewards
		rock(curNumber,true)
		for i=1,4 do
			local text_ranking_prize_ = image_prize_di:getChildByName("text_ranking_prize_" .. i)
			local image_frame_good = text_ranking_prize_:getChildByName("image_frame_good")
			local image_good = image_frame_good:getChildByName("image_good")
			local text_integral = text_ranking_prize_:getChildByName("text_integral")
			local item =  _msgData.msgdata.message.rankRewards.message[tostring(i)]
			local itemProps = utils.getItemProp(item.string.rewards)
			text_ranking_prize_:setString(item.int.rankUpper .. "-" .. item.int.rankLower .. Lang.ui_activity_BigNumber3)
			image_good:loadTexture(itemProps.smallIcon)
			text_integral:setString(itemProps.name .. "x" .. itemProps.count)
		end
	elseif code == StaticMsgRule.bigNumberGet then
		curNumber = _msgData.msgdata.int.cur
		maxNumber = _msgData.msgdata.int.max
		rank = _msgData.msgdata.int.rank
		rankList = _msgData.msgdata.string.rankList
		text_myintegral:setString(_msgData.msgdata.int.score)
		freeTimes = _msgData.msgdata.int.freeTimes
		myLuckCount = _msgData.msgdata.int.myLuckCount
		myLuckRewards = _msgData.msgdata.string.myLuckRewards
		rock(curNumber,false)
	elseif code == StaticMsgRule.bigNumberRecover then
		curNumber = _msgData.msgdata.int.cur
		maxNumber = _msgData.msgdata.int.max
		rank = _msgData.msgdata.int.rank
		rankList = _msgData.msgdata.string.rankList
		text_myintegral:setString(_msgData.msgdata.int.score)
		rock(curNumber,true)
		resetRankList(_msgData.msgdata.string.rankList)
	elseif code == StaticMsgRule.bigNumberRefresh then
		rank = _msgData.msgdata.int.rank
		rankList = _msgData.msgdata.string.rankList
		rock(curNumber,true)
	end
	if freeTimes > 0 then
		text_extract_price:setString(Lang.ui_activity_BigNumber4 .. freeTimes .. Lang.ui_activity_BigNumber5)
	else
		text_extract_price:setString(Lang.ui_activity_BigNumber6 .. getScore)
	end
end

function UIActivityBigNumber.onActivity(params)
	thisActivityDict = params
end

function UIActivityBigNumber.init()
	local image_basemap = UIActivityBigNumber.Widget:getChildByName("image_basemap")
	local image_number_di = image_basemap:getChildByName("image_number_di")
	local image_rank_di = image_basemap:getChildByName("image_rank_di")
	local image_ranking_di = image_basemap:getChildByName("image_ranking_di")
	local text_time_get = image_number_di:getChildByName("text_time_get")
	local text_digital_ranking_title_di = image_ranking_di:getChildByName("text_digital_ranking_title_di")
	for i = 1,DIGIT_COUNT do
		local panel = image_number_di:getChildByName("panel" .. i)
		local label_number = panel:getChildByName("label_num")
		local lacal_size = label_number:getContentSize()
		
		local label_next = label_number:clone()
		label_next:setPosition(lacal_size.width / 2, panel:getContentSize().height + lacal_size.height / 2)
		label_number:addChild(label_next)
		
		local label_roll = label_number:clone()
		label_roll:setVisible(false)
		panel:addChild(label_roll)
		
		panel.label_next  = label_next
		panel.label_number= label_number
		panel.label_roll  = label_roll
		panels[i] = panel
	end
	view_people = image_ranking_di:getChildByName("view_people")
	panel_people = view_people:getChildByName("panel_people")
	panel_people:retain()
	view_people:removeAllChildren()
	text_time = image_basemap:getChildByName("text_time")
	text_countdown = image_basemap:getChildByName("text_countdown")
	--text_time_get:setString("排行榜发奖时间：每天21:30")
	text_my_ranking = image_ranking_di:getChildByName("text_my_ranking")
	text_my_num = image_ranking_di:getChildByName("text_my_num")
	text_mymaximum = image_rank_di:getChildByName("text_mymaximum")
	text_myintegral = image_rank_di:getChildByName("text_myintegral")
	btn_refresh = text_digital_ranking_title_di:getChildByName("btn_refresh")
	btn_help = image_basemap:getChildByName("btn_help")
	btn_luck = image_number_di:getChildByName("btn_luck")
	btn_reduction = image_rank_di:getChildByName("btn_reduction")
	btn_extract = image_rank_di:getChildByName("btn_extract")
	text_extract_price = btn_extract:getChildByName("text_extract_price")
	text_reduction_price = btn_reduction:getChildByName("text_reduction_price")
	image_prize_di = image_basemap:getChildByName("image_prize_di")
	btn_refresh:setPressedActionEnabled(true)
	btn_help:setPressedActionEnabled(true)
	btn_luck:setPressedActionEnabled(true)
	btn_reduction:setPressedActionEnabled(true)
	btn_extract:setPressedActionEnabled(true)
	local function onButtonEvent(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if sender == btn_help then
				UIAllianceHelp.show({titleName = Lang.ui_activity_BigNumber7, type = 37})
			elseif sender == btn_refresh then
					netSendPackage({header=StaticMsgRule.bigNumberRefresh}, netCallbackFunc)
			elseif sender == btn_luck then
				UIActivityBigNumberRewardPreview.setLuckDigitAndRewards(luckDigit,luckRewards)
				UIManager.pushScene("ui_activity_lucky_reward_preview")
			elseif sender == btn_reduction then
				if tonumber(curNumber) == tonumber(text_mymaximum:getString()) then
					UIManager.showToast(Lang.ui_activity_BigNumber8)
				else
					netSendPackage({header=StaticMsgRule.bigNumberRecover}, netCallbackFunc)
				end
			elseif sender == btn_extract then
				netSendPackage({header=StaticMsgRule.bigNumberGet}, netCallbackFunc)
			end
		end
	end
	btn_refresh:addTouchEventListener(onButtonEvent)
	btn_help:addTouchEventListener(onButtonEvent)
	btn_luck:addTouchEventListener(onButtonEvent)
	btn_reduction:addTouchEventListener(onButtonEvent)
	btn_extract:addTouchEventListener(onButtonEvent)
	ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(LUCK_ANIMATION_PATH)
end

function UIActivityBigNumber.setup()
	if thisActivityDict and thisActivityDict.string["4"] ~= "" and thisActivityDict.string["5"] ~= "" then
		dp.addTimerListener(countDown)
		local startTime = utils.changeTimeFormat(thisActivityDict.string["4"])
		local endTime = utils.changeTimeFormat(thisActivityDict.string["5"])
		text_time:setString(string.format(Lang.ui_activity_BigNumber9, startTime[2],startTime[3],startTime[5],endTime[2],endTime[3],endTime[5]))
		countdownSeconds = utils.GetTimeByDate(thisActivityDict.string["5"]) - utils.getCurrentTime()
	else
		text_time:setString("")
		text_countdown:setString("")
	end
	rock(curNumber,true)
	btn_extract:setEnabled(true)
	btn_reduction:setEnabled(true)
	btn_help:setEnabled(true)
	btn_refresh:setEnabled(true)
	btn_luck:setEnabled(true)
	UIManager.showLoading()
	netSendPackage({header=StaticMsgRule.bigNumberEnter}, netCallbackFunc)
	UIActivityTime.refreshMoney()
end

function UIActivityBigNumber.free()
	--ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(LUCK_ANIMATION_PATH)
	--panel_people:release()
	dp.removeTimerListener(countDown)
end
