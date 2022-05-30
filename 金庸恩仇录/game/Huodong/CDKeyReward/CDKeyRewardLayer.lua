require("data.data_error_error")
local data_item_item = require("data.data_item_item")
local ZORDER = 100

local CDKeyRewardLayer = class("CDKeyRewardLayer", function()
	return require("utility.ShadeLayer").new()
end)

function CDKeyRewardLayer:sendReq(cdkey)
	RequestHelper.getCDKeyReward({
	pfid = CSDKShell.getChannelID(),
	chn_flag = game.player.chn_flag or "",
	cdkey = cdkey,
	callback = function(data)
		dump(data)
		if data["0"] ~= "" then
			dump(data["0"])
		else
			if data["2"] ~= nil then
				game.player:updateMainMenu({
				gold = data["2"][1],
				silver = data["2"][2]
				})
				PostNotice(NoticeKey.MainMenuScene_Update)
			end
			local itemData = {}
			for i, v in ipairs(data["1"]) do
				local item = data_item_item[v.id]
				local iconType = ResMgr.getResType(v.t)
				if iconType == ResMgr.HERO then
					item = ResMgr.getCardData(v.id)
				end
				table.insert(itemData, {
				id = v.id,
				type = v.t,
				num = v.n,
				iconType = iconType,
				name = item.name
				})
			end
			local title = common:getLanguageString("GetRewards")
			local msgBox = require("game.Huodong.RewardMsgBox").new({
			title = title,
			cellDatas = itemData,
			confirmFunc = function()
				self._editBox:setVisible(true)
			end,
			isShowConfirmBtn = true
			})
			self._editBox:setVisible(false)
			self:addChild(msgBox, ZORDER)
		end
	end
	})
end
function CDKeyRewardLayer:ctor(param)
	self:setNodeEventEnabled(true)
	local endFunc = param.endFunc
	local proxy = CCBProxy:create()
	local rootnode = {}
	local node = CCBuilderReaderLoad("huodong/cdkey_msg_box.ccbi", proxy, rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	
	local function closeFun(eventName, sender)
		if endFunc ~= nil then
			endFunc()
		end
		self:removeSelf()
	end
	
	rootnode.closeBtn:addHandleOfControlEvent(closeFun, CCControlEventTouchUpInside)
	
	rootnode.confirmBtn:registerScriptTapHandler(function(tag)
		if endFunc ~= nil then
			endFunc()
		end
		self:removeSelf()
	end)
	
	rootnode.exchangeBtn:registerScriptTapHandler(function(tag)
		if self._editBox:getText() == "" then
			show_tip_label(data_error_error[1303].prompt)
		else
			self:sendReq(self._editBox:getText())
			self._editBox:setText("")
		end
	end)
	local boxNode = rootnode.box_tag
	local cntSize = boxNode:getContentSize()
	self._editBox = ui.newEditBox({
	image = "#s_cdkey_input_bg.png",
	size = cc.size(cntSize.width * 0.98, cntSize.height * 0.98),
	x = cntSize.width / 2,
	y = cntSize.height / 2
	})
	self._editBox:setFont(FONTS_NAME.font_fzcy, 25)
	self._editBox:setFontColor(FONT_COLOR.BLACK)
	self._editBox:setPlaceholderFont(FONTS_NAME.font_haibao, 25)
	self._editBox:setPlaceHolder(common:getLanguageString("@ExchangeCode"))
	self._editBox:setPlaceholderFontColor(FONT_COLOR.WHITE)
	self._editBox:setReturnType(1)
	self._editBox:setInputMode(0)
	boxNode:addChild(self._editBox, 10)
	
end

function CDKeyRewardLayer:onEnter()
end

function CDKeyRewardLayer:onExit()
end

return CDKeyRewardLayer