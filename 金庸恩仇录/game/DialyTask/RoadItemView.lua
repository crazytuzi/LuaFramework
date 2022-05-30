local btnGoRes = {
normal = "#btn_go.png",
pressed = "#btn_go.png",
disabled = "#btn_go.png"
}

local btnGetRes = {
normal = "#btn_get_n.png",
pressed = "#btn_get_p.png",
disabled = "#btn_get_p.png"
}

local GameConst = require("game.GameConst")
require("data.data_error_error")
require("data.data_channelid")

local RoadItemView = class("RoadItemView", function()
	return display.newLayer("RoadItemView")
end)

function RoadItemView:ctor(size, data, mainscene, parent)
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
	self._mainMenuScene = mainscene
	self._parent = parent
	self:setUpView()
	self._icon = nil
end

function RoadItemView:setUpView()
	self._containner = display.newScale9Sprite("#reward_item_bg.png", 0, 0, cc.size(self._frameSize.width - self._leftToRightOffset * 2, self._frameSize.height - self._topToDownOffset * 2)):pos(self._frameSize.width / 2, self._frameSize.height / 2)
	local containnerSize = self._containner:getContentSize()
	self._containner:setAnchorPoint(cc.p(0.5, 0.5))
	self:addChild(self._containner)
	self._icon = display.newSprite("items/icon/" .. self._data.icon .. ".png"):pos(self._padding.left, containnerSize.height / 2):addTo(self._containner, 1)
	self._iconframe = display.newSprite("#icon_frame_board_" .. self._data.quality .. ".png"):pos(self._padding.left, containnerSize.height / 2):addTo(self._containner, 2)
	self._buttomframe = display.newSprite("#icon_frame_bg_" .. self._data.quality .. ".png"):pos(self._padding.left, containnerSize.height / 2):addTo(self._containner, 0)
	self._icon:setAnchorPoint(cc.p(0, 0.5))
	self._iconframe:setAnchorPoint(cc.p(0, 0.5))
	self._buttomframe:setAnchorPoint(cc.p(0, 0.5))
	local iconSize = self._iconframe:getContentSize()
	local iconPosX = self._iconframe:getPositionX()
	local titleBngSize = cc.size(420, 40)
	local marginLeft = 10
	local titleBng = display.newScale9Sprite("#panel_bng.png", 0, 0, titleBngSize):pos(iconPosX + iconSize.width + marginLeft, containnerSize.height - self._padding.top):addTo(self._containner)
	titleBng:setAnchorPoint(cc.p(0, 1))
	local marginLeft = 20
	local marginRight = 30
	--名称
	self._titleLabel = ui.newTTFLabelWithShadow({
	text = self._data.name,
	font = FONTS_NAME.font_fzcy,
	size = 22,
	color = cc.c3b(255, 255, 255),
	shadowColor = cc.c3b(255, 255, 255),
	align = ui.TEXT_ALIGN_LEFT
	}):pos(marginLeft, titleBngSize.height / 2):addTo(titleBng)
	self._titleLabel:setAnchorPoint(cc.p(0, 0.5))
	local text = tonumber(self._data.totalStep) >= 10000 and math.floor(tonumber(self._data.totalStep) / 10000) .. common:getLanguageString("@Wan") or tonumber(self._data.totalStep)
	--需要次数
	self._progresslabel = ui.newTTFLabel({
	text = "/" .. text,
	font = FONTS_NAME.font_fzcy,
	align = ui.TEXT_ALIGN_LEFT,
	size = 22,
	color = cc.c3b(0, 219, 52)
	}):pos(titleBngSize.width - marginRight, titleBngSize.height / 2):addTo(titleBng)
	self._progresslabel:setAnchorPoint(cc.p(1, 0.5))
	local posPreX = self._progresslabel:getPositionX()
	local posPreY = self._progresslabel:getPositionY()
	local preWidth = self._progresslabel:getContentSize().width
	local text = 10000 <= tonumber(self._data.missionDetail) and math.floor(tonumber(self._data.missionDetail) / 10000) .. common:getLanguageString("@Wan") or tonumber(self._data.missionDetail)
	--完成次数
	self._progresslabel = ui.newTTFLabel({
	text = text,
	font = FONTS_NAME.font_fzcy,
	align = ui.TEXT_ALIGN_LEFT,
	size = 22,
	color = cc.c3b(255, 222, 0)
	}):pos(posPreX - preWidth, posPreY):addTo(titleBng)
	self._progresslabel:setAnchorPoint(cc.p(1, 0.5))
	if tonumber(self._data.missionDetail) >= tonumber(self._data.totalStep) then
		self._progresslabel:setColor(cc.c3b(0, 219, 52))
	else
		self._progresslabel:setColor(cc.c3b(255, 222, 0))
	end
	local posPreX = self._progresslabel:getPositionX()
	local posPreY = self._progresslabel:getPositionY()
	local preWidth = self._progresslabel:getContentSize().width
	local marginRight = 130
	local titleBngPosX = titleBng:getPositionX()
	local titleBngPosY = titleBng:getPositionY()
	
	--描述
	local marginLeft = 5
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
	
	--奖励
	local marginLeft = 5
	local marginTop = 15
	self._disLabel = ui.newTTFLabelWithShadow({
	text = common:getLanguageString("@Rewards"),
	size = 20,
	align = ui.TEXT_ALIGN_LEFT,
	font = FONTS_NAME.font_fzcy,
	color = cc.c3b(170, 91, 28),
	shadowColor = display.COLOR_BLACK,
	}):pos(titleBngPosX + marginLeft, dislabelPosY - dislabelSize.height - marginTop):addTo(self._containner)
	self._disLabel:setAnchorPoint(cc.p(0, 1))
	self._disLabel:setVisible(self._data.missionCategory == 2)
	local x, y = self._disLabel:getPosition()
	y = y - 16
	local width = self._disLabel:getContentSize().width + 10
	local marginLeft = 60
	self._giftData = TaskModel:getInstance():getTaskGiftList(self._data.id)
	for k, v in pairs(self._giftData) do
		local node = self:createMoney(k, v)
		node:setAnchorPoint(cc.p(0, 0))
		node:setPosition(x + width + marginLeft * (k - 1), y)
		self._containner:addChild(node)
	end
	
	--前往
	--[[
	self.goBtn = ResMgr.newNormalButton({
	scaleBegan = 1.1,
	sprite = btnGoRes.normal,
	handle = function()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		GameStateManager:ChangeState(self._data.goto)
	end
	})
	
	self.goBtn:pos(containnerSize.width - self._padding.right, containnerSize.height / 2):addTo(self._containner)
	self.goBtn:setAnchorPoint(cc.p(1, 0.5))
	self.goBtn:setVisible(false)
	]]
	
	local function getReward()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		RequestHelper.dialyTask.getTaskGift({
		id = self._data.id,
		callback = function(data)
			dump(data)
			display.newSprite("#getok.png"):pos(self.getOkBtn:getPosition()):addTo(self._containner):setAnchorPoint(cc.p(1, 0.5))
			self.getOkBtn:setVisible(false)
			self.getOkBtn:setTouchEnabled(false)			
			
			TaskModel:getInstance():insertNewTask(data.acceptMissions)
			for k, v in pairs(self._giftData) do
				if v.id == 1 then
					game.player:setGold(game.player.m_gold + v.num)
				elseif v.id == 2 then
					game.player:setSilver(game.player.m_silver + v.num)
				end
			end
			PostNotice(NoticeKey.MainMenuScene_Update)
			TaskModel:getInstance():removeTaskById(self._data.id)
			self._parent:update()
			local title = common:getLanguageString("@GetRewards")
			local msgBox = require("game.Huodong.RewardMsgBox").new({
			title = title,
			cellDatas = self._giftData
			})
			CCDirector:sharedDirector():getRunningScene():addChild(msgBox, 1000)
		end
		})
	end
	
	--已领取
	self.getOkTag = display.newSprite("#getok.png")
	self.getOkTag:align(display.CENTER, containnerSize.width - self._padding.right - self.getOkTag:getContentSize().width/2, containnerSize.height / 2 - 35)
	self.getOkTag:addTo(self._containner)
	self.getOkTag:setVisible(false)
	
	--领取
	self.getOkBtn = ResMgr.newNormalButton({
	scaleBegan = 1.1,
	sprite = btnGetRes.normal,
	handle = getReward,
	})
	self.getOkBtn:align(display.CENTER)
	self.getOkBtn:setPosition(self.getOkTag:getPosition())
	self.getOkBtn:addTo(self._containner)	
	local canGet = self._data.status == 2
	self.getOkBtn:setVisible(canGet)
	self.getOkBtn:setTouchEnabled(canGet)	
	
end

function RoadItemView:createMoney(index, v)
	local iconKeys = {
	["1"] = "#icon_gold.png",
	["2"] = "#icon_lv_silver.png",
	["7"] = "#icon_lv_xiahun.png",
	["10"] = "#icon_hunyu.png",
	["11"] = "#icon_xlingshi.png",
	["5"] = "#icon_shengwang.png",
	["8"] = "#icon_banggong.png",
	["13"] = "#icon_rongyu.png"
	}
	local node = CCNode:create()
	local icon = display.newSprite(iconKeys[tostring(v.id)])
	local offset = 10
	local iconSize = icon:getContentSize()
	local countLabel = ui.newTTFLabel({
	text = v.num,
	size = 20,
	align = ui.TEXT_ALIGN_LEFT,
	font = FONTS_NAME.font_fzcy,
	color = cc.c3b(147, 5, 5)
	}):pos(iconSize.width + offset, 0)
	local labelSize = countLabel:getContentSize()
	icon:setAnchorPoint(cc.p(0, 0))
	countLabel:setAnchorPoint(cc.p(0, 0))
	node:addChild(countLabel)
	node:setPosition(cc.p(50 * (index - 1), 0))
	node:setContentSize(cc.size(iconSize.width + labelSize.width + offset, iconSize.height))
	local namelabel
	if v.id > 13 then
		local nameColor = cc.c3b(255, 255, 255)
		if v.iconType == ResMgr.HERO then
			nameColor = ResMgr.getHeroNameColor(v.id)
		elseif v.iconType == ResMgr.ITEM or v.iconType == ResMgr.EQUIP then
			nameColor = ResMgr.getItemNameColor(v.id)
		end
		namelabel = ui.newTTFLabel({
		text = v.name,
		size = 20,
		color = nameColor,
		font = FONTS_NAME.font_fzcy,
		align = ui.TEXT_ALIGN_CENTER,
		}):addTo(node)
		namelabel:setAnchorPoint(cc.p(0, 0))
		countLabel:setPositionX(namelabel:getContentSize().width + offset)
		return node
	end
	node:addChild(icon)
	return node
end

function RoadItemView:setData()
end

return RoadItemView