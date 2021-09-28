local WingAndRidingNoticeLayer = class("WingAndRidingNoticeLayer", function() return cc.Layer:create() end )

local function getCenterPos(node)
	return cc.p(node:getContentSize().width/2, node:getContentSize().height/2)
end

function WingAndRidingNoticeLayer:ctor(bless, rate, time, callBack, id)
	dump(time)
	self.blessLeftTime = time
	self.timeFlag = os.time()

	local bg = createSprite(self, "res/common/5.png", cc.p(display.cx, display.cy), cc.p(0.5, 0.5))

	if id == 1 then
		createLabel(bg, game.getStrByKey("wr_notice_wing_bless"), cc.p(bg:getContentSize().width/2, 250), cc.p(0.5, 0), 28, true, nil, nil, MColor.yellow)
	elseif id == 2 then
		createLabel(bg, game.getStrByKey("wr_notice_ride_bless"), cc.p(bg:getContentSize().width/2, 250), cc.p(0.5, 0), 28, true, nil, nil, MColor.yellow)
	elseif id == 3 then
		createLabel(bg, game.getStrByKey("wr_notice_zhr_bless"), cc.p(bg:getContentSize().width/2, 250), cc.p(0.5, 0), 28, true, nil, nil, MColor.yellow)
	elseif id == 4 then
		createLabel(bg, game.getStrByKey("wr_notice_zhj_bless"), cc.p(bg:getContentSize().width/2, 250), cc.p(0.5, 0), 28, true, nil, nil, MColor.yellow)
	end

	--进度条
	local progressBg = createSprite(bg, "res/common/progress/bg.png", cc.p(bg:getContentSize().width/2, 205), cc.p(0.5, 0))
	self.progress = cc.ProgressTimer:create(cc.Sprite:create("res/common/progress/p2.png"))  
	progressBg:addChild(self.progress)
    self.progress:setPosition(getCenterPos(progressBg))
    self.progress:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    self.progress:setAnchorPoint(cc.p(0.5, 0.5))
    self.progress:setBarChangeRate(cc.p(1, 0))
    self.progress:setMidpoint(cc.p(0, 1))
    self.progress:setPercentage(rate)

    --进度
	self.progressLabel = createLabel(progressBg, bless, getCenterPos(progressBg), cc.p(0.5, 0.5), 24, true, nil, nil, MColor.yellow)

	createLabel(bg, game.getStrByKey("wr_notice_count_down"), cc.p(55, 180), cc.p(0, 0), 20, true, nil, nil, MColor.green)
	self.blessTimeLeftLabel = createLabel(bg, time, cc.p(270, 180), cc.p(0, 0), 26, true, nil, nil, MColor.red)

	local colorRect = cc.LayerColor:create(cc.c4b(192, 192, 192, 100), 455, 100)
	bg:addChild(colorRect)
	colorRect:setPosition(cc.p(8, 75))

	local richText = require("src/RichText").new(bg, cc.p(bg:getContentSize().width/2, 170), cc.size(340, 50), cc.p(0.5, 1), 28, 20, MColor.white)
	richText:addText(game.getStrByKey("wr_notice_content"), nil, true)
	richText:format()

	local continueBtnFunc = function()
		removeFromParent(self)
	end
	local continueBtn = createMenuItem(bg, "res/component/button/15.png", cc.p(bg:getContentSize().width/2 - 100, 50), continueBtnFunc)
	createLabel(continueBtn, game.getStrByKey("wr_notice_button_continue"), getCenterPos(continueBtn), cc.p(0.5, 0.5), 24, true, nil, nil, MColor.white)

	local laterBtnFunc = function()
		if callBack then
			callBack()
		end
		G_WR_ADVANCE_INFO = {}
		removeFromParent(self)
	end
	local laterBtn = createMenuItem(bg, "res/component/button/15.png", cc.p(bg:getContentSize().width/2 + 100, 50), laterBtnFunc)
	createLabel(laterBtn, game.getStrByKey("wr_notice_button_delay"), getCenterPos(laterBtn), cc.p(0.5, 0.5), 24, true, nil, nil, MColor.white)

	local updateTime = function()
		if self.blessLeftTime and self.timeFlag then
			local time =  self.blessLeftTime + (self.timeFlag - os.time())
			log("time = "..time)
			--local timeStr = os.date("%X", time)
			local toInt = function(num)
				num = num - num%1
				return num
			end
			local timeStr = string.format("%02d", toInt(time/3600))..":"..string.format("%02d", (toInt(time/60)%60))..":"..string.format("%02d", (time%60))
			self.blessTimeLeftLabel:setString(timeStr)

			if time <= 0 then
				self.blessValue = 0
				if self.progress then
					self.progress:setPercentage(0)
				end
				self.progressLabel:setString(self.blessValue)
				self.blessTimeLeftLabel:setString("00:00:00")
				self.blessLeftTime = nil
				self.timeFlag = nil
				if self.timeAction then
					self:stopAction(self.timeAction)
					self.timeAction = nil
				end
			end
		end
	end

	updateTime()
	self.timeAction = startTimerAction(self, 1, true, updateTime)
end

return WingAndRidingNoticeLayer