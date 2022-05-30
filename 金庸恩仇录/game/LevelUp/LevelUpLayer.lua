local data_shengji_shengji = require("data.data_shengji_shengji")
local data_level_level = require("data.data_level_level")

local LevelUpLayer = class("LevelUpLayer", function()
	return require("utility.ShadeLayer").new()
end)

LevelUpLayer.effect = nil

function LevelUpLayer:onEnter()
	TutoMgr.addBtn("juqingzhandoujieshu_btn_quedinganniu", self._rootnode.confirmBtn)
	TutoMgr.active()
	self.effect:getAnimation():playWithIndex(0)
end

function LevelUpLayer:onExit()
	TutoMgr.removeBtn("juqingzhandoujieshu_btn_quedinganniu")
	display.removeSpriteFramesWithFile("ui/ui_shengji.plist", "ui/ui_shengji.png")
	self:releaseUI()
end

function LevelUpLayer:ctor(param)
	self:setNodeEventEnabled(true)
	self._rootnode = {}
	local proxy = CCBProxy:create()
	local node = CCBuilderReaderLoad("shengji/shengji_layer.ccbi", proxy, self._rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	self._rootnode.confirmBtn:addHandleOfControlEvent(function(sender, eventName)
		self:confirmHandler()
	end,
	CCControlEventTouchUpInside)
	
	local effect = ResMgr.createArma({
	resType = ResMgr.UI_EFFECT,
	armaName = "shengji",
	isRetain = true
	})
	effect:setScale(1.3)
	self.effect = effect
	effect:setPosition(display.cx, display.cy)
	self:addChild(effect, 100)
end

function LevelUpLayer:init(param)
	self.confirmFunc = param.confirmFunc
	self._level = param.level 		-- 升级前等级
	self._uplevel = param.uplevel 	-- 升级后等级
	self._naili = param.naili 		-- 升级前耐力
	self._curExp = param.curExp 	-- 当前经验值
	if self._level < 6 and self._uplevel >= 6 then
		SDKTKData.onCustEvent(4)
	elseif self._level < 10 and self._uplevel >= 10 then
		SDKTKData.onCustEvent(7)
	end
	game.player:updateLevelUpData({
	isLevelUp = true,
	beforeLevel = self._level,
	curLevel = self._uplevel
	})
	TutoMgr.lvlupSet(self._uplevel)
	GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_shengji))
	local addNaili, addCoin, xiakeNum = self:getLevelupData()
	dump("________________LevelUpLayer:init_____________________")
	dump(self)
	self:refresh(addNaili, addCoin, xiakeNum)
	self:updatePlayerData(addNaili, addCoin)
	CSDKShell.submitExtData({isLevelUp = true})
end

function LevelUpLayer:releaseUI()
	ResMgr.ReleaseUIArmature("shengji")
end

function LevelUpLayer:confirmHandler()
	PostNotice(NoticeKey.REMOVE_TUTOLAYER)
	if self.confirmFunc ~= nil then
		self.confirmFunc()
	end
	self:removeSelf()
end

function LevelUpLayer:getLevelupData()
	local naili = 0
	local coin = 0
	local xiakeNum = 0
	local start_index = 1
	local end_index = 1
	for i, v in ipairs(data_shengji_shengji) do
		if v.level == self._level then
			start_index = i
			if self._uplevel == v.uplevel then
				end_index = i
				xiakeNum = v.num
				break
			end
			for j, vd in ipairs(data_shengji_shengji) do
				if vd.uplevel == self._uplevel then
					end_index = j
					xiakeNum = vd.num
					break
				end
			end
			break
		end
	end
	for j = start_index, end_index do
		local v = data_shengji_shengji[j]
		naili = naili + v.naili
		coin = coin + v.coin
	end
	return naili, coin, xiakeNum
end

function LevelUpLayer:refresh(addNaili, addCoin, xiakeNum)
	-- 等级
	local lvLeft = self._rootnode.level_left
	local lvRight = self._rootnode.level_right
	local lvArrow = self._rootnode.level_arrow
	lvLeft:setString("LV " .. self._level)
	lvRight:setString("LV " .. self._uplevel)
	alignNodesOneByAll({
	self._rootnode.levelup_label_1,
	self._rootnode.level_left,
	self._rootnode.level_arrow,
	self._rootnode.level_right
	}, 2)
	
	-- 耐力 九-零 -一-起 玩-w-w-w-.9 -0-1- 7 -5-.-com
	local nailiLeft = self._rootnode.naili_left
	local nailiRight = self._rootnode.naili_right
	local nailiArrow = self._rootnode.naili_arrow
	nailiLeft:setString(self._naili)
	nailiRight:setString(tostring(self._naili + addNaili))
	self._rootnode.nailiLbl:setString("+" .. addNaili)
	alignNodesOneByAll({
	self._rootnode.levelup_label_2,
	self._rootnode.naili_left,
	self._rootnode.naili_arrow,
	self._rootnode.naili_right
	}, 2)
	
	-- 上阵侠客数
	self._rootnode.xiakeNumLbl:setString(xiakeNum)
	alignNodesOneByAll({
	self._rootnode.levelup_label_3,
	self._rootnode.xiakeNumLbl
	}, 2)
	
	-- 升级奖励
	self._rootnode.rewardLbl:setString(addCoin)
	alignNodesOneByAll({
	self._rootnode.levelup_label_4,
	self._rootnode.reward_icon,
	self._rootnode.rewardLbl
	}, 2)
end

-- 更新玩家数据
function LevelUpLayer:updatePlayerData(addNaili, addCoin)
	local endNali = self._naili + addNaili
	local endGold = game.player:getGold() + addCoin
	game.player:updateMainMenu({
	naili = endNali,
	lv = self._uplevel,
	gold = endGold
	})
end

return LevelUpLayer