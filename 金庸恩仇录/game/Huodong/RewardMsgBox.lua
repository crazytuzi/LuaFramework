local RewardMsgBox = class("RewardMsgBox", function ()
	return require("utility.ShadeLayer").new()
end)

function RewardMsgBox:initButton(isShowConfirmBtn)
	isShowConfirmBtn = true
	local function closeFun(eventName, sender)
		self._rootnode.closeBtn:setEnabled(false)
		self._rootnode.confirmBtn:setEnabled(false)
		if self._confirmFunc ~= nil then
			self._confirmFunc()
		end
		PostNotice(NoticeKey.REMOVE_TUTOLAYER)
		self:removeSelf()
		TutoMgr.active()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
	end
	self._rootnode.closeBtn:addHandleOfControlEvent(closeFun, CCControlEventTouchUpInside)
	self._rootnode.confirmBtn:addHandleOfControlEvent(closeFun, CCControlEventTouchUpInside)
	TutoMgr.addBtn("lingqu_close_btn", self._rootnode.closeBtn)
	TutoMgr.addBtn("lingqu_confirm", self._rootnode.confirmBtn)
	TutoMgr.active()
	self._rootnode.closeBtn:setVisible(false)
	self._rootnode.confirmBtn:setVisible(true)
	local sprite_bg = self._rootnode.sprite_bg
	if isShowConfirmBtn ~= true then
		local action = transition.sequence({
		CCDelayTime:create(1),
		CCCallFunc:create(closeFun)
		})
		self:runAction(action)
		self._rootnode.confirmBtn:setVisible(false)
		sprite_bg:setContentSize(CCSize(sprite_bg:getContentSize().width, sprite_bg:getContentSize().height - self._rootnode.confirmBtn:getContentSize().height + 14))
	end
end

function RewardMsgBox:initRewardListView(cellDatas)
	local boardWidth = self._rootnode.listView:getContentSize().width
	local boardHeight = self._rootnode.listView:getContentSize().height * 0.97
	local function createFunc(index)
		local data = {}
		for i = 1, 5 do
			if cellDatas[index * 5 + i] ~= nil then
				data[i] = cellDatas[index * 5 + i]
			end
		end
		data.width = boardWidth
		data.height = 128
		data.index = index
		return require("game.Huodong.RewardItemGroup").new(data)
	end
	local function refreshFunc(cell, index)
		local data = {}
		for i = 1, 5 do
			if cellDatas[index * 5 + i] ~= nil then
				data[i] = cellDatas[index * 5 + i]
			end
		end
		data.width = boardWidth
		data.height = 128
		data.index = index
		cell:refresh(data)
	end
	local cellContentSize = cc.size(478, 128)
	local cellCount = math.ceil(table.getn(cellDatas) / 5)
	self.ListTable = require("utility.TableViewExt").new({
	size = cc.size(boardWidth, boardHeight),
	direction = kCCScrollViewDirectionVertical,
	createFunc = createFunc,
	refreshFunc = refreshFunc,
	cellNum = cellCount,
	cellSize = cellContentSize
	})
	self.ListTable:setPosition(0, self._rootnode.listView:getContentSize().height * 0.015)
	self._rootnode.listView:addChild(self.ListTable)
end

function RewardMsgBox:onExit()
	TutoMgr.removeBtn("lingqu_confirm")
end

function RewardMsgBox:ctor(param)
	self:setNodeEventEnabled(true)
	self._confirmFunc = param.confirmFunc
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("reward/reward_msg_box.ccbi", proxy, self._rootnode)
	self:addChild(node)
	self._rootnode.title:setString(param.title or common:getLanguageString("GetRewards"))
	local cellDatas = param.cellDatas
	if table.getn(cellDatas) > 5 then
		self:rewardModel(true)
	else
		self:rewardModel(false)
	end
	self:initButton(param.isShowConfirmBtn)
	self:initRewardListView(cellDatas)
end

function RewardMsgBox:rewardModel(double)
	if double == true then
		self._rootnode.bgView:setContentSize(cc.size(563, 424))
		self._rootnode.listView:setContentSize(cc.size(478, 260))
		self._rootnode.confirmBtn:setPosition(282, -41)
		self._rootnode.title:setPosition(282, 303)
	else
		self._rootnode.bgView:setContentSize(cc.size(563, 304))
		self._rootnode.listView:setContentSize(cc.size(478, 130))
		self._rootnode.confirmBtn:setPosition(282, 22)
		self._rootnode.title:setPosition(282, 243)
	end
	local posY = self._rootnode.bgView:getPositionY()
	self._rootnode.listView:setPositionY(posY - 27)
end

return RewardMsgBox