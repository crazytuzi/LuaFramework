local STATE_TYPE = {
normal = 1,
canGet = 2,
hasGet = 3
}
local MAX_ZORDER = 100

local SubmapRewardLayer = class("SubmapRewardLayer", function()
	return require("utility.ShadeLayer").new()
end)

function SubmapRewardLayer:onEnter()
	self.isOk = false
	self._time = 0
end

function SubmapRewardLayer:onExit()
	TutoMgr.removeBtn("guankajiangli_lingqu")
	TutoMgr.removeBtn("lingqu_confirm")
	PostNotice(NoticeKey.REMOVE_TUTOLAYER)
	if self.closeListener ~= nil then
		self.closeListener()
	end
end

function SubmapRewardLayer:ctor(param)
	self:setNodeEventEnabled(true)
	local needStar = param.needStar
	local state = param.state
	self._itemData = param.itemData
	self._id = param.id
	self._updateListener = param.updateListener
	self._bagObj = param.bagState
	self._hard = param.hard
	self._isFull = false
	if #self._bagObj > 0 then
		self._isFull = true
	end
	self.closeListener = param.closeListener
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("fuben/sub_map_reward_layer.ccbi", proxy, self._rootnode)
	node:setPosition(display.width / 2, display.height / 2)
	self:addChild(node)
	self._rootnode.titleLabel:setString(common:getLanguageString("@StarReward"))
	self._rootnode.msg_1:setColor(ccc3(99, 47, 8))
	self._rootnode.msg_2:setColor(ccc3(99, 47, 8))
	local starIcon = self._rootnode.star_icon
	local starNumLbl = self._rootnode.star_num_lbl
	starNumLbl:setString(tostring(needStar))
	self._rootnode.msg_1:setPositionX(starIcon:getPositionX() - starNumLbl:getContentSize().width)
	
	local rewardBtn = self._rootnode.rewardBtn
	rewardBtn:addHandleOfControlEvent(function()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		PostNotice(NoticeKey.REMOVE_TUTOLAYER)
		rewardBtn:setEnabled(false)
		self:getReward()
	end,
	CCControlEventTouchUpInside)
	
	self._rootnode.tag_close:addHandleOfControlEvent(function()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		self:removeFromParentAndCleanup(true)
	end,
	CCControlEventTouchUpInside)
	local hasNode = self._rootnode.tag_has_get
	if state == STATE_TYPE.normal then
		rewardBtn:setVisible(true)
		rewardBtn:setEnabled(false)
		hasNode:setVisible(false)
	elseif state == STATE_TYPE.canGet then
		rewardBtn:setVisible(true)
		rewardBtn:setEnabled(true)
		hasNode:setVisible(false)
	elseif state == STATE_TYPE.hasGet then
		rewardBtn:setVisible(false)
		hasNode:setVisible(true)
	end
	self:refreshItem()
	node:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, handler(self, self.tick))
	node:scheduleUpdate()
	TutoMgr.addBtn("guankajiangli_lingqu", self._rootnode.rewardBtn)
	TutoMgr.addBtn("lingqu_confirm", self._rootnode.tag_close)
	TutoMgr.active()
end

function SubmapRewardLayer:getReward()
	local function extendBag(data)
		if self._bagObj[1].curCnt < data["1"] then
			table.remove(self._bagObj, 1)
		else
			self._bagObj[1].cost = data["4"]
			self._bagObj[1].size = data["5"]
		end
		if #self._bagObj > 0 then
			self:addChild(require("utility.LackBagSpaceLayer").new({
			bagObj = self._bagObj,
			callback = function(data)
				extendBag(data)
			end
			}), MAX_ZORDER)
		else
			self._isFull = false
			self._rootnode.rewardBtn:setEnabled(true)
		end
	end
	if self._isFull then
		self:addChild(require("utility.LackBagSpaceLayer").new({
		bagObj = self._bagObj,
		callback = function(data)
			extendBag(data)
		end
		}), MAX_ZORDER)
	else
		RequestHelper.getBattleReward({
		id = self._id,
		t = self._hard,
		callback = function(data)
			if data["0"] ~= "" then
				dump(data["0"])
			else
				ResMgr.removeMaskLayer()
				self._rootnode.rewardBtn:setVisible(false)
				self._rootnode.tag_has_get:setVisible(true)
				if self._updateListener ~= nil then
					self._updateListener(self._hard)
				end
				self.isOk = true
				self._time = 0
				local redState = data["3"]
				game.player:setJiangHuBoxNum(redState)
				PostNotice(NoticeKey.BottomLayer_JiangHu)
			end
		end
		})
	end
end

function SubmapRewardLayer:tick(dt)
	if self.isOk then
		self._time = self._time + dt * 100
		if self._time > 800 then
			self.isOk = false
		end
	end
end
function SubmapRewardLayer:refreshItem()
	for i, v in ipairs(self._itemData) do
		local reward = self._rootnode["reward_" .. tostring(i)]
		reward:setVisible(true)
		local rewardIcon = self._rootnode["reward_icon_" .. tostring(i)]
		ResMgr.refreshIcon({
		id = v.id,
		resType = v.iconType,
		itemBg = rewardIcon,
		iconNum = v.num,
		isShowIconNum = false,
		numLblSize = 22,
		numLblColor = cc.c3b(0, 255, 0),
		numLblOutColor = cc.c3b(0, 0, 0),
		itemType = v.type
		})
		local canhunIcon = self._rootnode["reward_canhun_" .. i]
		local suipianIcon = self._rootnode["reward_suipian_" .. i]
		canhunIcon:setVisible(false)
		suipianIcon:setVisible(false)
		local nameKey = "reward_name_" .. tostring(i)
		local nameColor = ResMgr.getItemNameColorByType(v.id, v.iconType)
		local nameLbl = ui.newTTFLabelWithShadow({
		text = v.name,
		size = 20,
		color = nameColor,
		shadowColor = FONT_COLOR.BLACK,
		font = FONTS_NAME.font_fzcy,
		align = ui.TEXT_ALIGN_LEFT
		})
		--nameLbl:setPosition(-nameLbl:getContentSize().width / 2, nameLbl:getContentSize().height / 2)
		--self._rootnode[nameKey]:removeAllChildren()
		--self._rootnode[nameKey]:addChild(nameLbl)
		
		ResMgr.replaceKeyLableEx(nameLbl, self._rootnode, nameKey, 0, 0)
		nameLbl:align(display.CENTER)
		
		
		
	end
	local count = #self._itemData
	while count < 4 do
		self._rootnode["reward_" .. tostring(count + 1)]:setVisible(false)
		count = count + 1
	end
end

return SubmapRewardLayer