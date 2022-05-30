local data_item_item = require("data.data_item_item")
local data_error_error = require("data.data_error_error")
local data_kuafu_configelse_kuafu_configelse = require("data.data_kuafu_configelse_kuafu_configelse")

local jingjiuLayer = class("jingjiuLayer", function()
	return require("utility.ShadeLayer").new()
end)

local jingjiuMsg = {
jingjiu = function(param)
	local msg = {
	m = "cross",
	a = "crossToast",
	operType = param.operType
	}
	RequestHelper.request(msg, param.callback, param.errback)
end
}

function jingjiuLayer:ctor(param)
	self.func = param.fun
	self._number = param._number
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("kuafu/toast_msgBox.ccbi", proxy, self._rootnode)
	local layer = tolua.cast(node, "CCLayer")
	layer:setPosition(display.width / 2, display.height / 2)
	self._baseLayer = layer
	self:addChild(layer)
	self.isCanJingjiu = true
	local function callback(data)
		local cellDatas = {}
		for k, v in ipairs(data.rtnObj) do
			local itemType = v.t
			local itemId = v.id
			local itemNum = v.n
			local iconType = ResMgr.getResType(v.t)
			local itemInfo
			if iconType == ResMgr.HERO then
				itemInfo = ResMgr.getCardData(itemId)
			else
				itemInfo = data_item_item[itemId]
			end
			if v.id == 1 then
				game.player:setGold(game.player.m_gold + itemNum)
			end
			if v.id == 2 then
				game.player:setSilver(game.player.m_silver + itemNum)
			end
			local datas = {
			id = itemId,
			type = itemType,
			iconType = iconType,
			name = itemInfo.name,
			describe = itemInfo.describe,
			num = itemNum
			}
			table.insert(cellDatas, datas)
		end
		self.isCanJingjiu = false
		if #cellDatas > 0 then
			self:getParent():addChild(require("game.Huodong.RewardMsgBox").new({cellDatas = cellDatas, num = 1}), 9999)
		end
		self:close()
	end
	local errback = function(data)
		CCLuaLog("data")
	end
	self._rootnode.jingjiu_btn01:addHandleOfControlEvent(function(eventName, sender)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		local jingjiudata = data_kuafu_configelse_kuafu_configelse[11]
		if jingjiudata.num > self._number then
			show_tip_label(data_error_error[300001].prompt)
			return
		end
		self._subNum = jingjiudata.num
		jingjiuMsg.jingjiu({
		callback = callback,
		errback = errback,
		operType = 0
		})
	end,
	CCControlEventTouchUpInside)
	
	self._rootnode.jingjiu_btn02:addHandleOfControlEvent(function(eventName, sender)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		local jingjiudata = data_kuafu_configelse_kuafu_configelse[13]
		if jingjiudata.num > self._number then
			show_tip_label(data_error_error[300001].prompt)
			return
		end
		self._subNum = jingjiudata.num
		jingjiuMsg.jingjiu({
		callback = callback,
		errback = errback,
		operType = 1
		})
	end,
	CCControlEventTouchUpInside)
	
	self._rootnode.backBtn:addHandleOfControlEvent(function(eventName, sender)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		self:close()
	end,
	CCControlEventTouchUpInside)
	
	self:initUI()
end

function jingjiuLayer:close()
	if self.func then
		self.func(self.isCanJingjiu, self._subNum or 0)
	end
	self:removeFromParentAndCleanup(true)
end

function jingjiuLayer:initUI()
	local locdata = {
	{
	configid = 11,
	huode = "@kfs_jingjiuhuode"
	},
	{
	configid = 13,
	huode = "@kfs_yizuifangxiuhuode"
	}
	}
	for i = 1, 2 do
		do
			local jingjiudata = data_kuafu_configelse_kuafu_configelse[locdata[i].configid]
			local jingjiuIcon = self._rootnode["iconSprite0" .. i]
			jingjiuIcon:removeAllChildrenWithCleanup(true)
			if jingjiudata.type ~= ITEM_TYPE.zhenqi then
				ResMgr.refreshItemWithTagNumName({
				id = jingjiudata.item,
				resType = ResMgr.getResType(jingjiudata.type),
				itemBg = jingjiuIcon,
				itemNum = self._number .. "/" .. jingjiudata.num,
				isShowIconNum = 0,
				itemType = jingjiudata.type
				})
				local textcolor = cc.c3b(58, 209, 73)
				if jingjiudata.num > self._number then
					textcolor = cc.c3b(255, 0, 0)
				end
				local haveTTF = ResMgr.createShadowMsgTTF({
				text = self._number,
				color = textcolor,
				size = 22
				})
				haveTTF:setAnchorPoint(cc.p(1, 0))
				jingjiuIcon:addChild(haveTTF, 10000)
				local numTTF = ResMgr.createShadowMsgTTF({
				text = "/" .. jingjiudata.num,
				color = cc.c3b(58, 209, 73),
				size = 22
				})
				numTTF:setAnchorPoint(cc.p(1, 0))
				jingjiuIcon:addChild(numTTF, 10000)
				haveTTF:setPosition(jingjiuIcon:getContentSize().width - haveTTF:getContentSize().width - numTTF:getContentSize().width - 5, haveTTF:getContentSize().height / 2 + 3)
				numTTF:setPosition(jingjiuIcon:getContentSize().width - numTTF:getContentSize().width - 5, haveTTF:getContentSize().height / 2 + 3)
			else
				local icon = require("game.Spirit.SpiritIcon").new({
				resId = jingjiudata.item,
				bShowName = true
				})
				icon:setAnchorPoint(cc.p(0.5, 0.5))
				icon:setPositionY(-10)
				jingjiuIcon:addChild(icon)
			end
			self._rootnode["iconSprite0" .. i]:setTouchEnabled(true)
			self._rootnode["iconSprite0" .. i]:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
				local itemInfo = require("game.Huodong.ItemInformation").new({
				id = jingjiudata.item,
				type = jingjiudata.type
				})
				self:addChild(itemInfo, 100000)
			end)
			self._rootnode["descLabel0" .. i]:setString(common:getLanguageString(locdata[i].huode))
		end
	end
end

function jingjiuLayer:onEnter()
end

function jingjiuLayer:onExit()
end

return jingjiuLayer