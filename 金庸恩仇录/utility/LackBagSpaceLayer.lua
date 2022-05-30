require("data.data_error_error")
local LackBagSpaceLayer = class("LackBagSpaceLayer", function ()
	return display.newNode()
end)
function LackBagSpaceLayer:resetBag()
	if self._cleanup then
		self._cleanup()
		return
	end
	local firstBag = self._bagObj[1]
	if firstBag == nil then
		GameStateManager:ChangeState(GAME_STATE.STATE_BEIBAO)
		return
	end
	if firstBag.type == BAG_TYPE.zhuangbei then
		GameStateManager:ChangeState(GAME_STATE.STATE_EQUIPMENT, 1)
	elseif firstBag.type == BAG_TYPE.shizhuang then
		GameStateManager:ChangeState(GAME_STATE.STATE_BEIBAO)
	elseif firstBag.type == BAG_TYPE.zhuangbei_suipian then
		GameStateManager:ChangeState(GAME_STATE.STATE_EQUIPMENT, 2)
	elseif firstBag.type == BAG_TYPE.wuxue then
		GameStateManager:ChangeState(GAME_STATE.STATE_BEIBAO, 2)
	elseif firstBag.type == BAG_TYPE.canhun then
		GameStateManager:ChangeState(GAME_STATE.STATE_XIAKE, 2)
	elseif firstBag.type == BAG_TYPE.zhenqi then
		GameStateManager:ChangeState(GAME_STATE.STATE_JINGYUAN, 2)
	elseif firstBag.type == BAG_TYPE.daoju then
		GameStateManager:ChangeState(GAME_STATE.STATE_BEIBAO, 1)
	elseif firstBag.type == BAG_TYPE.xiake then
		GameStateManager:ChangeState(GAME_STATE.STATE_XIAKE, 1)
	elseif firstBag.type == BAG_TYPE.chongwu then
		GameStateManager:ChangeState(GAME_STATE.STATE_PET, 1)
	elseif firstBag.type == BAG_TYPE.cheats then
		GameStateManager:ChangeState(GAME_STATE.STATE_PET, 1)
	elseif firstBag.type == BAG_TYPE.cheats_suipian then
		GameStateManager:ChangeState(GAME_STATE.STATE_PET, 1)
	end
end
-- 扩展背包
function LackBagSpaceLayer:extendBag()
	local function extend(bag)
		RequestHelper.extendBag({
		callback = function (data)
			dump(data)
			if string.len(data["0"]) > 0 then
				CCMessageBox(data["0"], "Error")
			else
				if self._callback ~= nil then
					self._callback(data)
				end
				self:removeFromParentAndCleanup(true)
				local curGold = data["3"]
				game.player:setGold(curGold)
				PostNotice(NoticeKey.CommonUpdate_Label_Gold)
				game.player:updateMainMenu({gold = curGold})
				PostNotice(NoticeKey.MainMenuScene_Update)
				local str = common:getLanguageString("@gongxi") .. tostring(bag.size) .. common:getLanguageString("@GuildShopItemUnit") .. ResMgr.getBagTypeDes(bag.type) .. common:getLanguageString("@beibaowz")
				show_tip_label(str)
			end
		end,
		type = bag.type
		})
	end
	local firstBag = self._bagObj[1]
	if firstBag.cost < 0 then
		show_tip_label(ResMgr.getBagTypeDes(firstBag.type) .. common:getLanguageString("@beibaozd"))
	else
		local layer = require("utility.CostTipMsgBox").new({
		tip = common:getLanguageString("@OpenLocation", firstBag.size),
		listener = function ()
			if game.player.m_gold >= firstBag.cost then
				extend(firstBag)
			else
				show_tip_label(data_error_error[400004].prompt)
			end
		end,
		cost = firstBag.cost
		})
		self:addChild(layer)
	end
end
function LackBagSpaceLayer:ctor(param)
	self._bagObj = param.bagObj
	self._callback = param.callback
	self._cleanup = param.cleanup
	if type(self._bagObj) ~= "table" or #self._bagObj <= 0 then
		CCMessageBox("the  data of package from server is Error", "Tip")
		self:removeFromParentAndCleanup(true)
		return
	end
	local contentStr = ""
	for i, v in ipairs(self._bagObj) do
		contentStr = contentStr .. ResMgr.getBagTypeDes(v.type)
		if i < #self._bagObj then
			contentStr = contentStr .. "、"
		else
			contentStr = contentStr .. common:getLanguageString("@beibaobz")
		end
	end
	local msgBox = require("utility.MsgBox").new({
	size = CCSizeMake(500, 300),
	content = contentStr,
	leftBtnName = common:getLanguageString("@zhenglibb"),
	rightBtnName = common:getLanguageString("@kuozhankj"),
	showClose = true,
	leftBtnFunc = handler(self, LackBagSpaceLayer.resetBag),
	rightBtnFunc = handler(self, LackBagSpaceLayer.extendBag),
	directclose = true
	})
	self:addChild(msgBox)
end
return LackBagSpaceLayer