require"Lang"
UIActivityMakeMoney = {
	OPEN_TYPE_ENTER = 0,
	OPEN_TYPE_GETGOLD = 1,
	open = false,
	startGet = false,
	rolling = {false, false, false, false, false}
}

local ui = UIActivityMakeMoney
local DictActivity = nil

local kTagLabel = 1
local kTagNextLabel = 2
local kTagRollLabel = 3
local ROLL_NUM = 5
local MSG_COUNT = 4

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

local function refreshMessage(message)
    local view_list = ccui.Helper:seekNodeByName(ui.Widget, "view_list")
    local innerWidth = view_list:getInnerContainerSize().width
	local children = view_list:getChildren()
    for i, child in ipairs(children) do
        child:setVisible(false)
    end
	message = utils.stringSplit(message, ";")
	for i, record in ipairs(message) do
		local data = utils.stringSplit(record, "|")
		local child = children[i]
		if child then
			child:setVisible(true)
            local text_name = child:getChildByName("text_name")
            local text_number = child:getChildByName("text_number")
            local text_get = child:getChildByName("text_get")
			text_name:setString(data[1])
			text_number:setString(data[2])

            local leftWidth = text_name:getContentSize().width + text_get:getContentSize().width
            local width = leftWidth + child:getContentSize().width + text_number:getContentSize().width
            child:setPositionX((innerWidth - width) / 2 + leftWidth + child:getContentSize().width / 2)
		end
	end
end

local function refreshNextRound(cost, max)
	local text_hint = ccui.Helper:seekNodeByName(ui.Widget, "text_hint")
	local image_need = ccui.Helper:seekNodeByName(ui.Widget, "image_need")
	local btn_money = ccui.Helper:seekNodeByName(ui.Widget, "btn_money")

	if max and max > 0 then
		text_hint:setString(string.format(Lang.ui_activity_MakeMoney1, max))
		image_need:show():getChildByName("text_number"):setString(tostring(cost))
		btn_money:setEnabled(true)
        btn_money:setBright(true)
	else
		text_hint:setString(Lang.ui_activity_MakeMoney2)
		image_need:setVisible(false)
		btn_money:setEnabled(false)
        btn_money:setBright(false)
	end
end

local function refreshGold(lastGold)
	local image_basemap = ccui.Helper:seekNodeByName(ui.Widget, "image_basemap")
	local nums = getNums(lastGold, ROLL_NUM)
	for i = ROLL_NUM, 1, -1 do
		local panel = image_basemap:getChildByName("panel" .. i)
		local label = panel:getChildByTag(kTagLabel)
		local nextLabel = label:getChildByTag(kTagNextLabel)
		local rollLabel = panel:getChildByTag(kTagRollLabel)

		local size = panel:getContentSize()
		label:setPosition(size.width / 2, size.height / 2)
		rollLabel:setPosition(size.width / 2, size.height / 2)
		rollLabel:setVisible(false)

		label:setString(tostring(nums[i]))
		rollLabel:setString(tostring(nums[i]))
		nextLabel:setString(tostring(math.floor((nums[i] + 1) % 10)))
	end
end

local function showGetGold(gold)
	local ui_middle = ccui.Layout:create()
    ui_middle:setContentSize(display.size)
	ui_middle:setTouchEnabled(true)
	ui_middle:retain()

    local image_basemap = ccui.Helper:seekNodeByName(ui.Widget, "image_basemap")
    local effect = cc.ParticleSystemQuad:create("particle/action_effect_jinyuanbao.plist")
    effect:setAnchorPoint(0.5, 1)
    effect:setPosition(image_basemap:getContentSize().width / 2, image_basemap:getContentSize().height)
	image_basemap:addChild(effect, 100)

	local visibleSize = cc.Director:getInstance():getVisibleSize()
	local bg_image = cc.Scale9Sprite:create("ui/dialog_bg.png")
	bg_image:setAnchorPoint(cc.p(0.5, 0.5))
	bg_image:setPreferredSize(cc.size(380, 280))
	bg_image:setPosition(visibleSize.width / 2, visibleSize.height / 2)
	ui_middle:addChild(bg_image)

	local bgSize = bg_image:getPreferredSize()

	local title = ccui.Text:create()
	title:setString(Lang.ui_activity_MakeMoney3)
	title:setFontName(dp.FONT)
	title:setFontSize(30)
	title:setTextColor(cc.c4b(255,255,0,255))
	title:setPosition(bgSize.width / 2, bgSize.height - title:getContentSize().height)
	bg_image:addChild(title,3)

    local text_closed = ccui.Text:create()
	text_closed:setString(Lang.ui_activity_MakeMoney4)
	text_closed:setFontName(dp.FONT)
	text_closed:setFontSize(24)
	text_closed:setTextColor(cc.c4b(255,255,255,255))

    local image_zidi = cc.Scale9Sprite:create("ui/pai_zidi.png")
    image_zidi:setAnchorPoint(0.5, 1)
    image_zidi:setPreferredSize(cc.size(text_closed:getVirtualRendererSize().width + 40, text_closed:getVirtualRendererSize().height + 20))
	image_zidi:setPosition(bgSize.width / 2, -6)
    bg_image:addChild(image_zidi,4)

	text_closed:setPosition(image_zidi:getContentSize().width / 2, image_zidi:getContentSize().height / 2)
	image_zidi:addChild(text_closed)

	local node = cc.Node:create()
	local image_di = ccui.ImageView:create("ui/quality_small_blue.png")
	local image = ccui.ImageView:create()
	local description = ccui.Text:create()
	description:setFontSize(20)
	description:setFontName(dp.FONT)
	description:setAnchorPoint(cc.p(0.5,1))
	image:setPosition(image_di:getContentSize().width/2,image_di:getContentSize().height/2)
	image_di:addChild(image)
	image_di:setPosition(cc.p(0,0))
	description:setPosition(0,-image_di:getContentSize().height/2-5)
	node:addChild(image_di)
	node:addChild(description)
	node:setPosition(bgSize.width / 2, bgSize.height / 2)
	bg_image:addChild(node,3)

	local tableTypeId,tableFieldId, thingNum = StaticTableType.DictPlayerBaseProp, 1, gold
	utils.addBorderImage(tableTypeId,tableFieldId,image_di)
	local name,Icon = utils.getDropThing(tableTypeId,tableFieldId)
	image:loadTexture(Icon)
	description:setString(name .. "×" .. gold)

	UIManager.uiLayer:addChild(ui_middle, 99)

    local function touchevent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            bg_image:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 0.1), cc.CallFunc:create(function()
                effect:removeFromParent()
	            UIManager.uiLayer:removeChild(ui_middle, true)
	            cc.release(ui_middle)
             end)))
        end
    end
	ui_middle:addTouchEventListener(touchevent)
    ActionManager.PopUpWindow_SplashAction(bg_image)
end

local function netCallbackFunc(pack)
	local code = tonumber(pack.header)
	if code == StaticMsgRule.treasuresFillTheHome then
		local msgdata = pack.msgdata
		local lastGold = msgdata.int.lastGold
		local cost = msgdata.int.cost
		local max = msgdata.int.max
		local message = msgdata.string.message
		local obtainGold = msgdata.int.obtainGold

        UIActivityTime.refreshMoney()
		refreshMessage(message)
		if ui.open then
			local image_basemap = ccui.Helper:seekNodeByName(ui.Widget, "image_basemap")

			local nums = getNums(obtainGold, ROLL_NUM)
			local extra = 10
			for i = ROLL_NUM, 1, -1 do
				local panel = image_basemap:getChildByName("panel" .. i)
				local label = panel:getChildByTag(kTagLabel)
				local nextLabel = label:getChildByTag(kTagNextLabel)
				local rollLabel = panel:getChildByTag(kTagRollLabel)

				local size = panel:getContentSize()
				label:setPosition(size.width / 2, size.height / 2)
				rollLabel:setPosition(size.width / 2, size.height / 2)
				rollLabel:setVisible(false)

				local num = tonumber(label:getString())
				rollLabel:setString(tostring(num))
				nextLabel:setString(tostring(math.floor((num + 1) % 10)))

				local panelHeight = panel:getContentSize().height
				local rollCount = 3 * 10 + (ROLL_NUM - i) * extra + math.floor((nums[i] - num + 10) % 10)

				local action = cc.MoveBy:create(rollCount * 3 / 40, cc.p(0, -rollCount * panelHeight))
				action = cc.EaseCubicActionOut:create(action)

				ui.rolling[i] = true
				rollLabel:runAction(cc.Sequence:create(action, cc.CallFunc:create(function()
					ui.rolling[i] = false
					if i == 1 then
						refreshNextRound(cost, max)
						ui.startGet = false
						showGetGold(obtainGold)
					end
				end)))
				label:scheduleUpdate(function()
					if ui.rolling[i] then
						local d = size.height / 2 - rollLabel:getPositionY()
						local remain = math.floor(d % size.height)
						local count = math.floor(d / size.height)
						local curNum = math.floor((num + count) % 10)
						label:setString(tostring(curNum))
						nextLabel:setString(tostring(math.floor((curNum + 1) % 10)))
						label:setPosition(size.width / 2, size.height / 2 - remain)
					else
						label:setString(tostring(nums[i]))
						nextLabel:setString(tostring(math.floor((nums[i] + 1) % 10)))
						label:setPosition(size.width / 2, size.height / 2)
						rollLabel:setPosition(size.width / 2, size.height / 2)
						label:unscheduleUpdate()
					end
				end)
			end
		else
			refreshNextRound(cost, max)
			refreshGold(lastGold)
			ui.open = true
		end
	end
end

local function sendPacket(openType)
	UIManager.showLoading()
	netSendPackage({header = StaticMsgRule.treasuresFillTheHome, msgdata = {int = {type = openType}}}, netCallbackFunc)
end

function ui.onActivity(_params)
	DictActivity = _params
end

function ui.init()
	ui.open = false
	local btn_help = ccui.Helper:seekNodeByName(ui.Widget, "btn_help")
	local btn_money = ccui.Helper:seekNodeByName(ui.Widget, "btn_money")
	local image_need = ccui.Helper:seekNodeByName(ui.Widget, "image_need")

	local image_basemap = ccui.Helper:seekNodeByName(ui.Widget, "image_basemap")
	for i = 1, ROLL_NUM do
		local panel = image_basemap:getChildByName("panel" .. i)
		local label = panel:getChildByName("label_number" .. i)
		label:setTag(kTagLabel)

		local nextLabel = label:clone()
		nextLabel:setPosition(label:getContentSize().width / 2, panel:getContentSize().height + label:getContentSize().height / 2)
		nextLabel:setTag(kTagNextLabel)
		label:addChild(nextLabel)

		local rollLabel = label:clone()
		rollLabel:setVisible(false)
		rollLabel:setTag(kTagRollLabel)
		panel:addChild(rollLabel)
	end

	local view_list = ccui.Helper:seekNodeByName(ui.Widget, "view_list")
	local image_jin = view_list:getChildByName("image_jin")
	local innerHeight = view_list:getInnerContainerSize().height
	local size = image_jin:getContentSize()
	for i = 1, MSG_COUNT do
		local child = i == 1 and image_jin or image_jin:clone()
		child:setPosition(child:getPositionX(), innerHeight - (2 * i - 1) / 2 * innerHeight / MSG_COUNT)
		child:setVisible(false)
		if i > 1 then view_list:addChild(child) end
	end

	local function touchEvent(sender, touchType)
		if touchType == ccui.TouchEventType.ended then
			audio.playSound("sound/button.mp3")
			if sender == btn_help then
				UIAllianceHelp.show({titleName = Lang.ui_activity_MakeMoney5, type = 4})
			elseif sender == btn_money then
				if ui.startGet or table.keyof(ui.rolling, true) then
					UIManager.showToast(Lang.ui_activity_MakeMoney6)
					return
				end

				ui.startGet = true
				local cost = tonumber(image_need:getChildByName("text_number"):getString())
				if net.InstPlayer.int["5"] >= cost then
					sendPacket(ui.OPEN_TYPE_GETGOLD)
				else
					ui.startGet = false
					UIHintBuy.show(UIHintBuy.MONEY_TYPE_GOLD)
				end
			end
		end
	end

	btn_help:addTouchEventListener(touchEvent)
	btn_money:addTouchEventListener(touchEvent)
end

function ui.setup()
	ui.open = false
	sendPacket(ui.OPEN_TYPE_ENTER)
	local text_number = ccui.Helper:seekNodeByName(ui.Widget, "image_left"):getChildByName("text_number")
	text_number:scheduleUpdate(function()
		local gold = net.InstPlayer.int["5"]
		text_number:setString(tostring(gold))
	end)

	local text_time_open = ccui.Helper:seekNodeByName(ui.Widget, "text_time_open")
	local text_time_off = ccui.Helper:seekNodeByName(ui.Widget, "text_time_off")
	if DictActivity and DictActivity.string["4"] ~= "" and DictActivity.string["5"] ~= "" then
		local _startTime = utils.changeTimeFormat(DictActivity.string["4"])
		local _endTime = utils.changeTimeFormat(DictActivity.string["5"])
		text_time_open:setString(string.format(Lang.ui_activity_MakeMoney7, _startTime[2],_startTime[3],_startTime[5]))
		text_time_off:setString(string.format(Lang.ui_activity_MakeMoney8,_endTime[2],_endTime[3],_endTime[5]))
	end
end
