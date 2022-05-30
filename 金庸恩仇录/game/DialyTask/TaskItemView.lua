local btnGoRes = {
normal = "#btn_go.png",
pressed = "#btn_go.png",
disabled = "#btn_go.png"
}
local GameConst = require("game.GameConst")
require("data.data_channelid")

local TaskItemView = class("TaskItemView", function()
	return display.newLayer("TaskItemView")
end)

function TaskItemView:ctor(size, data, mainScene)
	self:setContentSize(size)
	self._leftToRightOffset = 10
	self._topToDownOffset = 2
	self._frameSize = size
	self._data = data
	self._containner = nil
	self._padding = {
	left = 20,
	right = 10,
	top = 15,
	down = 10
	}
	self:setUpView()
	self._icon = nil
	self._mainMenuScene = mainScene
end

function TaskItemView:setUpView()
	self._containner = display.newScale9Sprite("#reward_item_bg.png", 0, 0, cc.size(self._frameSize.width - self._leftToRightOffset * 2, self._frameSize.height - self._topToDownOffset * 2)):pos(self._frameSize.width / 2, self._frameSize.height / 2)
	local containnerSize = self._containner:getContentSize()
	self._containner:setAnchorPoint(cc.p(0.5, 0.5))
	self:addChild(self._containner)
	self._icon = display.newSprite("items/icon/" .. self._data.icon .. ".png"):pos(self._padding.left, containnerSize.height / 2):addTo(self._containner)
	self._icon:setAnchorPoint(cc.p(0, 0.5))
	local iconSize = self._icon:getContentSize()
	local iconPosX = self._icon:getPositionX()
	local titleBngSize = cc.size(280, 40)
	local marginLeft = 15
	local titleBng = display.newScale9Sprite("#panel_bng.png", 0, 0, titleBngSize):pos(iconPosX + iconSize.width + marginLeft, containnerSize.height - self._padding.top):addTo(self._containner)
	titleBng:setAnchorPoint(cc.p(0, 1))
	local marginLeft = 10
	local marginRight = 10
	self._titleLabel = ui.newTTFLabelWithShadow({
	text = self._data.name,
	font = FONTS_NAME.font_fzcy,
	size = 22,
	color = cc.c3b(255, 255, 255),
	shadowColor = cc.c3b(255, 255, 255),
	align = ui.TEXT_ALIGN_LEFT
	}):pos(marginLeft, titleBngSize.height / 2):addTo(titleBng)
	self._titleLabel:setAnchorPoint(cc.p(0, 0.5))
	self._progresslabel = ui.newTTFLabel({
	text = "/" .. self._data.totalStep,
	font = FONTS_NAME.font_fzcy,
	align = ui.TEXT_ALIGN_LEFT,
	size = 22,
	color = cc.c3b(0, 219, 52)
	}):pos(titleBngSize.width - marginRight, titleBngSize.height / 2):addTo(titleBng)
	self._progresslabel:setAnchorPoint(cc.p(1, 0.5))
	local posPreX = self._progresslabel:getPositionX()
	local posPreY = self._progresslabel:getPositionY()
	local preWidth = self._progresslabel:getContentSize().width
	if not (tonumber(self._data.missionDetail) >= tonumber(self._data.totalStep)) or not tonumber(self._data.totalStep) then
	end
	self._data.missionDetail = tonumber(self._data.missionDetail)
	self._progresslabel = ui.newTTFLabel({
	text = self._data.missionDetail,
	font = FONTS_NAME.font_fzcy,
	align = ui.TEXT_ALIGN_LEFT,
	size = 22,
	color = cc.c3b(255, 222, 0)
	}):pos(posPreX - preWidth, posPreY):addTo(titleBng)
	self._progresslabel:setAnchorPoint(cc.p(1, 0.5))
	local posPreX = self._progresslabel:getPositionX()
	local posPreY = self._progresslabel:getPositionY()
	local preWidth = self._progresslabel:getContentSize().width
	local marginRight = 60
	local titleBngPosX = titleBng:getPositionX()
	local titleBngPosY = titleBng:getPositionY()
	
	--积分获取描述
	local marginLeft = 10
	local marginTop = 15
	self._disLabel = ui.newTTFLabelWithShadow({
	text = self._data.dis,
	size = 20,
	align = ui.TEXT_ALIGN_LEFT,
	font = FONTS_NAME.font_fzcy,
	color = cc.c3b(170, 91, 28),
	shadowColor = display.COLOR_BLACK,
	}):pos(titleBngPosX + marginLeft, titleBngPosY - titleBngSize.height - marginTop):addTo(self._containner)
	self._disLabel:setAnchorPoint(cc.p(0, 1))
	local dislabelPosY = self._disLabel:getPositionY()
	local dislabelSize = self._disLabel:getContentSize()
	
	--获取积分
	local marginLeft = 10
	local marginTop = 10
	self._disLabel = ui.newTTFLabelWithShadow({
	text = common:getLanguageString("@GetScore"),
	size = 20,
	align = ui.TEXT_ALIGN_LEFT,
	font = FONTS_NAME.font_fzcy,
	color = cc.c3b(170, 91, 28),
	shadowColor = display.COLOR_BLACK,
	})
	self._disLabel:align(display.LEFT_TOP, titleBngPosX + marginLeft, dislabelPosY - dislabelSize.height - marginTop)
	self._disLabel:addTo(self._containner)
	self._disLabel:setVisible(self._data.missionCategory == 1)
	local size = self._disLabel:getContentSize()
	
	--积分值
	self._disLabel = ui.newTTFLabel({
	text = self._data.jifen,
	size = 20,
	align = ui.TEXT_ALIGN_LEFT,
	font = FONTS_NAME.font_fzcy,
	color = cc.c3b(147, 5, 5)
	})
	self._disLabel:align(display.LEFT_TOP, titleBngPosX + marginLeft + size.width + 10, dislabelPosY - dislabelSize.height - marginTop)
	self._disLabel:addTo(self._containner)
	self._disLabel:setVisible(self._data.missionCategory == 1)
	
	--成就奖励
	local marginLeft = 10
	local marginTop = 10
	self._disLabel = ui.newTTFLabelWithShadow({
	text = common:getLanguageString("@Rewards"),
	size = 20,
	align = ui.TEXT_ALIGN_LEFT,
	font = FONTS_NAME.font_fzcy,
	color = cc.c3b(170, 91, 28),
	shadowColor = display.COLOR_BLACK,
	})
	self._disLabel:align(display.LEFT_TOP, titleBngPosX + marginLeft, dislabelPosY - dislabelSize.height)
	self._disLabel:addTo(self._containner)
	self._disLabel:setVisible(self._data.missionCategory == 2)
	
	--奖励物品
	local x, y = self._disLabel:getPosition()
	local width = self._disLabel:getContentSize().width
	local marginLeft = 10
	local itemOne = self:createMoney(1, 10)
	itemOne:addTo(self._containner)
	itemOne:setAnchorPoint(cc.p(0, 1))
	itemOne:setPosition(x + width + marginLeft, y)
	itemOne:setVisible(self._data.missionCategory == 2)
	local x, y = itemOne:getPosition()
	local width = itemOne:getContentSize().width
	local marginLeft = 10
	local itemTwo = self:createMoney(2, 10)
	itemTwo:addTo(self._containner)
	itemTwo:setAnchorPoint(cc.p(0, 1))
	itemTwo:setPosition(x + width + marginLeft, y)
	itemTwo:setVisible(self._data.missionCategory == 2)
	
	--前往
	local function GoTo()
		dump(self._data)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		if self._data.goto == 33 then
			RequestHelper.worldBoss.history({
			callback = function(data)
				dump(data)
				if data["0"] ~= "" then
					CCMessageBox(data["0"], "Error")
				elseif data["1"] <= 0 then
					GameStateManager:ChangeState(GAME_STATE.STATE_WORLD_BOSS)
				else
					GameStateManager:ChangeState(GAME_STATE.STATE_WORLD_BOSS_NORMAL, data)
				end
			end
			})
		elseif self._data.goto == 42 then
			RequestHelper.dialyTask.checkBPSignIn({
			callback = function(data)
				if data.rtnObj.success == 0 then
					GameStateManager:ChangeState(GAME_STATE.STATE_GUILD)
					--GameStateManager:ChangeState(GAME_STATE.STATE_GUILD_DADIAN)
				else
					show_tip_label(data_error_error[1200006].prompt)
					return
				end
			end
			})
		elseif self._data.goto == GAME_STATE.STATE_FUBEN then
			local msg = {}
			msg.bigMapID = game.player.bigmapData["1"]
			msg.subMapID = game.player.bigmapData["2"]
			GameStateManager:ChangeState(self._data.goto, msg)
		elseif self._data.goto == 2 then
			self._mainMenuScene:btnTouchFunc("tag_liaotian")
		elseif self._data.goto ~= GAME_STATE.STATE_JINGYUAN then
			GameStateManager:ChangeState(self._data.goto)
		end
	end
	
	if self._data.status == 3 then
		--完成
		self.completeTag = display.newSprite("#complete.png"):pos(containnerSize.width - self._padding.right, containnerSize.height / 2):addTo(self._containner)
		self.completeTag:setAnchorPoint(cc.p(1, 0.5))
		--self.completeTag:setVisible(self._data.status == 3)
	elseif self._data.status == 1 then
		--前往
		self.goBtn = ResMgr.newNormalButton({
		scaleBegan = 1.1,
		sprite = btnGoRes.normal,
		handle = GoTo
		})
		self.goBtn:align(display.CENTER, containnerSize.width - self._padding.right - 70, containnerSize.height / 2)
		self.goBtn:addTo(self._containner)
		--self.goBtn:setVisible(self._data.status == 1)
		--self.goBtn:setTouchEnabled(self._data.status == 1)
	end
end

function TaskItemView:createMoney(type, count)
	local node = CCNode:create()
	local icon
	if type == 1 then
		icon = display.newSprite("#spirit_gold_icon.png")
	elseif type == 2 then
		icon = display.newSprite("#spirit_silver_icon.png")
	else
		icon = display.newSprite("#spirit_item_icon.png")
	end
	local offset = 10
	local iconSize = icon:getContentSize()
	
	local countLabel = ui.newTTFLabel({
	text = count,
	size = 20,
	align = ui.TEXT_ALIGN_LEFT,
	font = FONTS_NAME.font_fzcy,
	color = cc.c3b(147, 5, 5)
	}):pos(iconSize.width + offset, 0)
	local labelSize = countLabel:getContentSize()
	icon:setAnchorPoint(cc.p(0, 0))
	countLabel:setAnchorPoint(cc.p(0, 0))
	node:addChild(icon)
	node:addChild(countLabel)
	node:setContentSize(cc.size(iconSize.width + labelSize.width + offset, iconSize.height))
	return node
end

function TaskItemView:setData()
end

return TaskItemView