--[[
--
-- add by vicky
-- 2014.08.08
--
--]]

local data_item_item = require("data.data_item_item")


local ZORDER = 100

local OnlineRewardLayer = class("OnlineRewardLayer", function ()
	return require("utility.ShadeLayer").new()
end)


--[[请求服务器端在线奖励的数据]]
function OnlineRewardLayer:getOnlineData()
	RequestHelper.onlineReward.getRewardList({
	callback = function (data, err)
		if data["0"] ~= "" then
			self:removeSelf()
			dump(data["0"])
			return
		elseif data["4"] == false then
			self:removeSelf()
			return
		end
		dump(data["5"])
		self:initData(data)
	end
	})
end


-- 点击领取奖励功能
function OnlineRewardLayer:onReward()
	-- 判断当前背包是否已满，若背包已满则提示背包空间不足

	
	
	if self.isFull then
		self:addChild(require("utility.LackBagSpaceLayer").new({
		bagObj = self.bagObj,
		callback = function ()
			self.isFull = false
		end
		}), ZORDER)
	else
		-- 若背包未满，则向服务器端请求获取奖励，服务器端成功返回领取奖励数据后，弹出获得奖励的提示框

		
		
		RequestHelper.onlineReward.getReward({
		callback = function (data)
			dump(data)
			if string.len(data["0"]) > 0 then
				CCMessageBox(data["0"], "Tip")
				return
			else
				-- 更新金币银币等

				
				
				
				
				
				game.player:updateMainMenu({silver = data["1"].silver, gold = data["1"].gold})
				PostNotice(NoticeKey.MainMenuScene_Update)
				
				game.player.m_onlineRewardTime = data["3"]
				self.delayTime = game.player.m_onlineRewardTime
				
				-- 是否显示在线奖励，如否，则按钮消失

				
				
				
				
				
				game.player.m_isShowOnlineReward = data["2"]
				
				local title = common:getLanguageString("@GetRewards")
				local msgBox = require("game.Huodong.RewardMsgBox").new({
				title = title,
				cellDatas = self.cellDatas
				})
				self:getParent():addChild(msgBox)
				PostNotice(NoticeKey.MainMenuScene_OnlineReward)
				self:removeSelf()
			end
		end
		})
	end
end


function OnlineRewardLayer:initTimeSchedule()
	self:schedule(function ()
		if self.delayTime > 0 then
			self.delayTime = self.delayTime - 1
			self._rootnode["time_label"]:setString(format_time(self.delayTime))
			self._rootnode["getRewardBtn"]:setEnabled(false)
		end
		
		if self.delayTime <= 0 then
			self._rootnode["getRewardBtn"]:setEnabled(true)
		end
	end,
	1)
end


-- 点击图标，显示道具详细信息






function OnlineRewardLayer:onInformation(index)
	dump(index)
	local icon_data = self.cellDatas[index]
	
	local itemInfo = require("game.Huodong.ItemInformation").new({
	id = icon_data.id,
	type = icon_data.type,
	name = icon_data.name,
	describe = icon_data.describe
	})
	
	self:addChild(itemInfo, ZORDER)
end


function OnlineRewardLayer:initData(data)
	-- 距离领取奖励的时间

	
	
	
	
	
	game.player.m_onlineRewardTime = data["3"]
	self.delayTime = game.player.m_onlineRewardTime
	game.player.m_isShowOnlineReward = data["4"]
	self.isFull = data["2"] or false
	local rewardId = data["1"]
	self.giftList = data["5"]
	self.bagObj = data["6"]
	
	if not game.player.m_isShowOnlineReward then
		self:removeSelf()
		return
	end
	
	self:initTimeSchedule()
	
	if (self.delayTime <= 0) then
		self._rootnode["getRewardBtn"]:setEnabled(true)
	else
		self._rootnode["getRewardBtn"]:setEnabled(false)
	end
	
	self._rootnode["time_label"]:setString(format_time(self.delayTime))
	
	-- 初始化奖励相关数据

	
	
	
	
	
	self.cellDatas = {}
	
	for i,v in ipairs(self.giftList) do
		--print(">>>>>>>>>>>>>>>>>>>>>>giftList: "..i)
		local iconData = data_item_item[v.id]
		local itemType = ResMgr.getResType(v.type)
		local rewardIcon = self._rootnode["reward_icon_" ..tostring(i)]
		ResMgr.refreshIcon({
		id = iconData.id,
		resType = itemType,
		itemBg = rewardIcon,
		iconNum = v.num,
		isShowIconNum = false,
		numLblSize = 22,
		numLblColor = cc.c3b(0, 255, 0),
		numLblOutColor = cc.c3b(0, 0, 0)
		})
		-- 属性图标

		
		
		
		
		
		local canhunIcon = self._rootnode["reward_canhun_" .. i]
		local suipianIcon = self._rootnode["reward_suipian_" .. i]
		canhunIcon:setVisible(false)
		suipianIcon:setVisible(false)
		if v.type == 3 then
			-- 装备碎片
			suipianIcon:setVisible(true)
		elseif v.type == 5 then
			-- 残魂(武将碎片)
			canhunIcon:setVisible(true)
		end
		
		-- 名称
		local nameKey = "reward_name_" .. tostring(i)
		local nameColor = cc.c3b(255, 255, 255)
		if itemType == ResMgr.ITEM or itemType == ResMgr.EQUIP then
			nameColor = ResMgr.getItemNameColor(v.id)
		elseif itemType == ResMgr.HERO then
			nameColor = ResMgr.getHeroNameColor(v.id)
		end
		
		local nameLbl = ui.newTTFLabelWithShadow({
		text = iconData.name,
		size = 20,
		color = nameColor,
		shadowColor = display.COLOR_BLACK,
		font = FONTS_NAME.font_fzcy,
		align = ui.TEXT_ALIGN_LEFT
		})
		ResMgr.replaceKeyLableEx(nameLbl, self._rootnode, nameKey, 0, 0)
		nameLbl:align(display.BOTTOM_CENTER)
		
		table.insert(self.cellDatas, {
		id = iconData.id,
		type = v.type,
		name = iconData.name,
		describe = iconData.describe,
		num = v.num or 0,
		iconType = itemType
		})
	end
	
	-- 道具类型达不到4个时，剩余的道具框隐藏

	
	
	
	
	
	local count = #self.giftList
	while (count < 4) do
		self._rootnode["reward_" ..tostring(count + 1)]:setVisible(false)
		count = count + 1
	end
	
	PostNotice(NoticeKey.MainMenuScene_OnlineReward)
	
end


function OnlineRewardLayer:ctor(data)
	self.delayTime = 0
	local proxy = CCBProxy:create()
	self._rootnode = {}
	
	local node = CCBuilderReaderLoad("reward/online_reward_layer.ccbi", proxy, self._rootnode)
	--node = tolua.cast(node, "cc.Node")
	--node:setTouchEnabled(true)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	
	self._rootnode["title_label"]:setString(common:getLanguageString("@OnlineReward"))
	
	--for i = 1, 4 do
	--	-- 点击道具，显示道具功能信息

	
	
	
	
	
	--	local rewardIcon = self._rootnode["reward_icon_" ..tostring(i)]
	--	rewardIcon:setTouchEnabled(true)
	--	rewardIcon:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
	--        if (event.name == "began") then
	--        	return true
	--        elseif (event.name == "ended") then
	--         	self:onInformation(i)
	--        end
	--    end)
	--end
	
	local index = 0
	self:setTouchHandler(function (event)
		if event.name == "ended" then
			for i = 1, 4 do
				local rewardIcon = self._rootnode["reward_icon_" ..tostring(i)]
				if cc.rectContainsPoint(rewardIcon:getBoundingBox(), rewardIcon:convertToNodeSpace(cc.p(event.x, event.y))) then
					self:onInformation(i)
				end
			end
		end
	end)
	
	
	
	local closeBtn = self._rootnode["closeBtn"]
	closeBtn:addHandleOfControlEvent(function (sender, eventId)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		sender:runAction(transition.sequence({
		CCCallFunc:create(function ()
			self:removeFromParentAndCleanup(true)
		end)
		}))
	end,
	CCControlEventTouchUpInside)
	
	local getRewardBtn = self._rootnode["getRewardBtn"]
	getRewardBtn:addHandleOfControlEvent(function (sender, eventId)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		getRewardBtn:setEnabled(false)
		sender:runAction(transition.sequence({
		CCCallFunc:create(function ()
			self:onReward()
		end)
		}))
	end,
	CCControlEventTouchUpInside)
	
	getRewardBtn:setEnabled(false)
	self:initData(data)
	
end


--退出奖励界面




function OnlineRewardLayer:onExit()
	self:unscheduleUpdate()
	CCTextureCache:sharedTextureCache():removeUnusedTextures()
end

return OnlineRewardLayer