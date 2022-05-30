local data_item_item = require("data.data_item_item")
local data_config_yabiao_config_yabiao = require("data.data_config_yabiao_config_yabiao")
local btnCloseRes = {
normal = "#win_base_close.png",
pressed = "#win_base_close.png",
disabled = "#win_base_close.png"
}

local YabiaoDetailView = class("YabiaoDetailView", function()
	return require("utility.ShadeLayer").new(cc.c4b(0,0,0,150))
end)

function YabiaoDetailView:ctor(param)
	self:loadRes()
	self._dartkey = param.dartkey
	self._roleId = param.roleId
	self._erroCallBack = param.erroFunc
	local function func()
		self:setUpView(param)
	end
	self:_getData(func)
end

local heroIconSize

function YabiaoDetailView:setUpView(param)
	for k, v in pairs(param) do
		dump(k, v)
	end
	local padding = {
	left = 30,
	right = 30,
	top = 20,
	down = 20
	}
	self:createMask()
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("huodong/yabiao_msgBox", proxy, self._rootnode)
	self:addChild(node)
	node:setPosition(cc.p(display.cx, display.cy))
	
	--¹Ø±Õ
	local closeBtn = self._rootnode.closeBtn
	closeBtn:addHandleOfControlEvent(function(sender, eventName)
		self:close()
	end,
	cc.CONTROL_EVENTTYPE_TOUCH_UP_INSIDE)
	
	self._rootnode.zhanli_lbl:setString(self.data.attack)
	self._rootnode.lv_num:setString("LV:" .. self.data.lv)
	local heroBng = self._rootnode.inner_bg
	local heroBngSize = heroBng:getContentSize()
	if not heroIconSize then
		local icon = ResMgr.refreshIcon({
		id = self.data.cardData[1].resId,
		resType = ResMgr.HERO,
		cls = self.data.cardData[1].cls
		})
		heroIconSize = icon:getContentSize()
		heroIconSize.width = heroIconSize.width + 10
	end
	self.heroIconSize = heroIconSize
	CCTableViewCell:new()
	local function refreshHeroIcon(cell, hero)
		cell:removeAllChildren()
		local icon = ResMgr.refreshIcon({
		id = hero.resId,
		resType = ResMgr.HERO,
		cls = hero.cls
		})
		icon:setAnchorPoint(cc.p(0, 0.5))
		icon:setPosition(cc.p(10, heroBngSize.height * 0.5))
		cell:addChild(icon)
	end
	local offsetX = 9
	if not self.heroListTab then
		self.heroListTab = require("utility.TableViewExt").new({
		size = cc.size(heroBngSize.width - offsetX * 2, heroBngSize.height),
		direction = kCCScrollViewDirectionHorizontal,
		createFunc = function(idx)
			local cell = CCTableViewCell:new()
			refreshHeroIcon(cell, self.data.cardData[idx + 1])
			return cell
		end,
		refreshFunc = function(cell, idx)
			refreshHeroIcon(cell, self.data.cardData[idx + 1])
		end,
		cellNum = #self.data.cardData,
		cellSize = heroIconSize
		})
		heroBng:addChild(self.heroListTab)
		self.heroListTab:setPositionX(offsetX)
	else
		self.heroListTab:reload()
	end
	local cardName = {
	common:getLanguageString("@lvsebc"),
	common:getLanguageString("@lansebc"),
	common:getLanguageString("@zisebc"),
	common:getLanguageString("@jinsebc")
	}
	local typeColor = {
	cc.c3b(0, 228, 48),
	cc.c3b(0, 168, 255),
	cc.c3b(192, 0, 255),
	cc.c3b(255, 165, 0)
	}
	self._rootnode.yabiaoLbl:setString(cardName[self.data.quality])
	self._rootnode.yabiaoLbl:setColor(typeColor[self.data.quality])
	alignNodesOneByOne(self._rootnode.yabiao_1, self._rootnode.yabiaoLbl)
	self._rootnode.yinbi_1:setString(data_item_item[self.data.getCoin[1].id].name .. ":")
	self._rootnode.yinbiLbl:setString(self.data.getCoin[1].n)
	alignNodesOneByOne(self._rootnode.yinbi_1, self._rootnode.yinbiLbl)
	self._rootnode.shengwang_1:setString(data_item_item[self.data.getCoin[2].id].name .. ":")
	self._rootnode.shengwangLbl:setString(self.data.getCoin[2].n)
	alignNodesOneByOne(self._rootnode.shengwang_1, self._rootnode.shengwangLbl)
	self._rootnode.qiangduoLbl:setString(self.data.beRobTimes .. " / " .. data_config_yabiao_config_yabiao[14].value)
	alignNodesOneByOne(self._rootnode.qiangduo_1, self._rootnode.qiangduoLbl)
	self._rootnode.playerNameLbl:setString(self.data.name)
	if not self.unionName or self.unionName == "" then
		self._rootnode.unionNameLbl:setVisible(false)
	else
		self._rootnode.unionNameLbl:setVisible(true)
		self._rootnode.unionNameLbl:setString(common:getLanguageString("@GuildName") .. ":[" .. self.unionName .. "]")
	end
	local qiangduoBtn = self._rootnode.qiangduoBtn
	self._rootnode.qiangduoBtn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		if self.data.beRobTimes >= data_config_yabiao_config_yabiao[14].value then
			show_tip_label(data_error_error[3400005].prompt)
			return
		end
		self:fight()
	end,
	cc.CONTROL_EVENTTYPE_TOUCH_UP_INSIDE)
	
	local guanbiBtn = self._rootnode.guanbiBtn
	self._rootnode.guanbiBtn:addHandleOfControlEvent(function(sender, eventName)
		self:close()
	end,
	cc.CONTROL_EVENTTYPE_TOUCH_UP_INSIDE)
	
	local likaiBtn = self._rootnode.likaiBtn
	self._rootnode.likaiBtn:addHandleOfControlEvent(function(sender, eventName)
		self:close()
	end,
	cc.CONTROL_EVENTTYPE_TOUCH_UP_INSIDE)
	
	if param and param.type == 1 then
		qiangduoBtn:setVisible(true)
		likaiBtn:setVisible(true)
		guanbiBtn:setVisible(false)
	else
		qiangduoBtn:setVisible(false)
		likaiBtn:setVisible(false)
		guanbiBtn:setVisible(true)
	end
	alignNodesOneByOne(self._rootnode.qiangduo_1, self._rootnode.qiangduoLbl, 2)
	alignNodesOneByAll({
	self._rootnode.yabiao_1,
	self._rootnode.yabiaoLbl,
	self._rootnode.yinbi_1,
	self._rootnode.yinbiLbl,
	self._rootnode.shengwang_1,
	self._rootnode.shengwangLbl
	}, 2)
end

function YabiaoDetailView:createHeroView(index, node)
	local i = index
	local marginTop = 10
	local marginLeft = 10
	local offset = 100
	local icon = ResMgr.refreshIcon({
	id = self.data.cardData[index].resId,
	resType = ResMgr.HERO,
	cls = self.data.cardData[index].cls
	})
	icon:setAnchorPoint(cc.p(0, 0.5))
	icon:setPosition(node:getContentSize().width / 5 * i - 20 + 10 * (i - 1), node:getContentSize().height / 2)
	icon:setAnchorPoint(cc.p(0.5, 0.5))
	node:addChild(icon)
	return icon
end

function YabiaoDetailView:loadRes()
	display.addSpriteFramesWithFile("ui/ui_common_button.plist", "ui/ui_common_button.png")
	display.addSpriteFramesWithFile("ui/ui_coin_icon.plist", "ui/ui_coin_icon.png")
	display.addSpriteFramesWithFile("ui/ui_arena.plist", "ui/ui_arena.png")
	display.addSpriteFramesWithFile("ui/ui_xiakelu.plist", "ui/ui_xiakelu.png")
	display.addSpriteFramesWithFile("ui/ui_heroinfo.plist", "ui/ui_heroinfo.png")
end

function YabiaoDetailView:releaseRes()
	display.removeSpriteFramesWithFile("ui/ui_common_button.plist", "ui/ui_common_button.png")
	display.removeSpriteFramesWithFile("ui/ui_coin_icon.plist", "ui/ui_coin_icon.png")
	display.removeSpriteFramesWithFile("ui/ui_arena.plist", "ui/ui_arena.png")
	display.removeSpriteFramesWithFile("ui/ui_xiakelu.plist", "ui/ui_xiakelu.png")
end

function YabiaoDetailView:createMask()
	local winSize = CCDirector:sharedDirector():getWinSize()
	local mask = CCLayerColor:create()
	mask:setContentSize(winSize)
	mask:setColor(cc.c3b(0, 0, 0))
	mask:setOpacity(150)
	mask:setAnchorPoint(cc.p(0, 0))
	mask:setTouchEnabled(true)
	self:addChild(mask)
end

function YabiaoDetailView:close()
	GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
	self:releaseRes()
	self:removeSelf()
end

function YabiaoDetailView:_getData(func)
	local function initData(data)
		self.data = data.dartData
		self.unionName = data.unionName
		if data.dartState == 1 then
			self._erroCallBack()
			return
		end
		func()
	end
	RequestHelper.yaBiaoSystem.getCarInfo({
	roleID = self._roleId,
	dartkey = self._dartkey,
	callback = function(data)
		dump(data)
		initData(data)
	end
	})
end

function YabiaoDetailView:fight()
	RequestHelper.yaBiaoSystem.forceGetCar({
	otherID = self._roleId,
	dartkey = self._dartkey,
	callback = function(data)
		dump(data)
		if data["0"] == 1 then
			self._rootnode.qiangduoLbl:setString(data_config_yabiao_config_yabiao[14].value .. " / " .. data_config_yabiao_config_yabiao[14].value)
			show_tip_label(data_error_error[3400005].prompt)
		else
			if data.dartState == 1 then
				self._erroCallBack()
				return
			end
			ResMgr.oppName = self.data.name
			data["extra-enemy"] = {
			name = self.data.name,
			attack = self.data.attack
			}
			GameStateManager:ChangeState(GAME_STATE.STATE_YABIAO_BATTLE_SCENE, {data = data})
		end
	end
	})
end

return YabiaoDetailView