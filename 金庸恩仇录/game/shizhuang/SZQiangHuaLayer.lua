local data_fashion_fashion = require("data.data_fashion_fashion")
local data_item_item = require("data.data_item_item")
local data_fashionup_fashionup = require("data.data_fashionup_fashionup")
local data_talent_talent = require("data.data_talent_talent")
local data_battleskill_battleskill = require("data.data_battleskill_battleskill")
local data_shentong_shentong = require("data.data_shentong_shentong")
local ccs = ccs or {}

ccs.MovementEventType = {
START = 0,
COMPLETE = 1,
LOOP_COMPLETE = 2
}

local qianghuaMsg = {
szUpLevel = function(param)
	local msg = {
	m = "fashion",
	a = "lvUp",
	id = param.id
	}
	RequestHelper.request(msg, param.callback, param.errback)
end
}

--[[强化需要材料]]
local function get_fashionup_data(level)
	for k, v in ipairs(data_fashionup_fashionup) do
		if v.strengthenlevel == level then
			return v
		end
	end
	return nil
end

local SZQiangHuaLayer = class("SZQiangHuaLayer", function(param)
	return require("utility.ShadeLayer").new()
end)

function SZQiangHuaLayer:ctor(param)
	local _closeFunc = param.closeFunc
	local proxy = CCBProxy:create()
	self._rootnode = {}
	self.hasQH = false
	local node = CCBuilderReaderLoad("shizhuang/shizhuang_qianghua.ccbi", proxy, self._rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	
	--返回
	self._rootnode.backBtn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		if _closeFunc then
			_closeFunc(self.hasQH)
		end
		self:removeSelf()
	end,
	CCControlEventTouchUpInside)
	
	--强化
	self._rootnode.qianghuaBtn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		local staticdata = data_item_item[self.onlinedata.resId]
		local propupdata = get_fashionup_data(self.onlinedata.level)
		local nextlevelpropupdata = get_fashionup_data(self.onlinedata.level + 1)
		if not nextlevelpropupdata then
			show_tip_label(common:getLanguageString("@sz_yijingdingji"))
			return
		end
		if propupdata.leadlevel > game.player:getLevel() then
			show_tip_label(common:getLanguageString("@sz_needlevel", propupdata.leadlevel))
			return
		end
		local cyls_num = 0
		local cost_coin = 0
		if staticdata.quality == 5 then
			cyls_num = propupdata.exp[2]
			cost_coin = propupdata.coin[2]
		else
			cyls_num = propupdata.exp[1]
			cost_coin = propupdata.coin[1]
		end
		if cost_coin > game.player.m_silver then
			show_tip_label(common:getLanguageString("@yinbibz"))
			return
		end
		if cyls_num > self.has_cyls_num then
			show_tip_label(common:getLanguageString("@sz_cuiyunliusubuzu"))
			return
		end
		self._rootnode.qianghuaBtn:setEnabled(false)
		qianghuaMsg.szUpLevel({
		id = param.data._id,
		callback = function(data)
			dump(data)
			game.player:setSilver(data[3])
			PostNotice(NoticeKey.MainMenuScene_Update)
			self.hasQH = true
			if param.cb then
				param.cb(param.idx, data[2], data[3], data[4])
			end
			self:qiangHuaAnim()
			self:reload(data[2], data[4])
			self._rootnode.qianghuaBtn:setEnabled(true)
		end,
		errback = function(data)
		end
		})
	end,
	CCControlEventTouchUpInside)
	
	local staticdata = data_item_item[param.data.resId]
	local fashionFrame = ResMgr.getHeroFrame(game.player.getGender(), 0, param.data.resId)
	self._rootnode.image:setDisplayFrame(fashionFrame)
	self._rootnode.qh_card_bg:setDisplayFrame(display.newSprite("#card_ui_bg_" .. staticdata.quality .. ".png"):getDisplayFrame())
	self.cardBg = self._rootnode.qh_card_bg
	self:reload(param.data, param.cyls_num)
end

function SZQiangHuaLayer:shake(direction)
	if direction ~= 0 then
		do
			local rate = 0.01
			local delayTime = 0.08
			local cPosX = self.cardBg:getPositionX()
			local cPosY = self.cardBg:getPositionY()
			local xDirection = 1
			local yDirection = -1
			if direction == 1 then
				xDirection = 1
				yDirection = -1
			elseif direction == 2 then
				xDirection = 1
				yDirection = -1
			end
			local delayAct = CCDelayTime:create(delayTime)
			local offSetWidth = display.width * rate
			local offSetcHeight = display.height * rate
			local moveAct1 = CCCallFunc:create(function()
				self.cardBg:setPosition(cc.p(cPosX + offSetWidth * xDirection, cPosY + offSetcHeight * yDirection))
			end)
			local moveAct2 = CCCallFunc:create(function()
				self.cardBg:setPosition(cc.p(cPosX, cPosY))
			end)
			local sequence = transition.sequence({
			moveAct1,
			delayAct,
			moveAct2
			})
			self.cardBg:runAction(sequence)
		end
	end
end

function SZQiangHuaLayer:qiangHuaAnim(finishFunc)
	local effect = ResMgr.createArma({
	resType = ResMgr.UI_EFFECT,
	armaName = "zhuangbeiqianghua",
	isRetain = false,
	finishFunc = function()
	end
	})
	GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_xiakeqianghua))
	if self.cardBg then
		local efPos = ResMgr:getPosInScene(self.cardBg)
		effect:setPosition(efPos)
		display.getRunningScene():addChild(effect, 10000)
	end
end

function SZQiangHuaLayer:reload(onlinedata, has_cyls_num)
	--has_cyls_num = 100 --翠云彩缎  亲   测 源  码 网  w w w. q c y   m w .c o m
	local staticdata = data_item_item[onlinedata.resId]
	local propupdata = get_fashionup_data(onlinedata.level)
	self.onlinedata = onlinedata
	self.has_cyls_num = has_cyls_num
	
	if self._shiZhuangName == nil then
		self._shiZhuangName = ui.newTTFLabelWithShadow({
		text = "",
		font = FONTS_NAME.font_fzcy,
		size = 24,
		shadowColor = FONT_COLOR.BLACK,
		})
		self._shiZhuangName:align(display.CENTER)
		ResMgr.replaceKeyLableEx(self._shiZhuangName, self._rootnode, "kongfuName", 0, 0)
	end
	
	if staticdata.quality == 5 then
		self._rootnode.star5:setVisible(true)
	else
		self._rootnode.star5:setVisible(false)
	end
	
	self._shiZhuangName:setString(staticdata.name)
	self._shiZhuangName:setColor(NAME_COLOR[staticdata.quality])
	
	self._rootnode.jibie_val:setString(onlinedata.level)
	alignNodesOneByAll({
	self._rootnode.jibie_tag,
	self._rootnode.jibie_val,
	self._rootnode.jibie_val_add
	}, 5)
	
	self._rootnode.shengming_val:setString(staticdata.arr_value[4] + staticdata.arr_addition[4] * onlinedata.level)
	self._rootnode.shengming_val_add:setString("+" .. staticdata.arr_addition[4])
	alignNodesOneByAll({
	self._rootnode.shengming_tag,
	self._rootnode.shengming_val,
	self._rootnode.shengming_val_add
	}, 5)
	
	self._rootnode.gongji_val:setString(staticdata.arr_value[5] + staticdata.arr_addition[5] * onlinedata.level)
	self._rootnode.gongji_val_add:setString("+" .. staticdata.arr_addition[5])
	alignNodesOneByAll({
	self._rootnode.gongji_tag,
	self._rootnode.gongji_val,
	self._rootnode.gongji_val_add
	}, 5)
	for i = 1, 2 do
		local talentId = data_shentong_shentong[staticdata.talent[i]].arr_talent[5]
		local shentongname = data_talent_talent[talentId].name
		self._rootnode["shentong_tag_" .. i]:setString(shentongname .. ":")
		if onlinedata.level < staticdata.unlocktalent[i] then
			self._rootnode["shentong_val_" .. i]:setString(common:getLanguageString("@sz_xuyaodengji", staticdata.unlocktalent[i]))
			self._rootnode["shentong_val_" .. i]:setColor(FONT_COLOR.GRAY)
		else
			self._rootnode["shentong_val_" .. i]:setString(common:getLanguageString("@sz_yijiesuo"))
			self._rootnode["shentong_val_" .. i]:setColor(FONT_COLOR.GREEN)
		end
		alignNodesOneByAll({
		self._rootnode["shentong_tag_" .. i],
		self._rootnode["shentong_val_" .. i]
		}, 5)
	end
	if staticdata.skill == 0 then
		self._rootnode.jineng_tag_1:setVisible(false)
		self._rootnode.jineng_val_1:setVisible(false)
	else
		self._rootnode.jineng_tag_1:setString(data_battleskill_battleskill[staticdata.skill].name .. ":")
		if onlinedata.level < staticdata.unlockskill then
			self._rootnode.jineng_val_1:setString(common:getLanguageString("@sz_xuyaodengji", staticdata.unlockskill))
			self._rootnode.jineng_val_1:setColor(FONT_COLOR.GRAY)
		else
			self._rootnode.jineng_val_1:setString(common:getLanguageString("@sz_yijiesuo"))
			self._rootnode.jineng_val_1:setColor(FONT_COLOR.GREEN)
		end
	end
	alignNodesOneByAll({
	self._rootnode.jineng_tag_1,
	self._rootnode.jineng_val_1
	}, 5)
	local cyls_num = 0
	local cost_coin = 0
	if staticdata.quality == 5 then
		cyls_num = propupdata.exp[2]
		cost_coin = propupdata.coin[2]
	else
		cyls_num = propupdata.exp[1]
		cost_coin = propupdata.coin[1]
	end
	self._rootnode.cost_silver_num_2:setString(cost_coin)
	self._rootnode.cost_prop_num_1:setString(has_cyls_num)
	if has_cyls_num < cyls_num then
		self._rootnode.cost_prop_num_1:setColor(FONT_COLOR.RED)
	else
		self._rootnode.cost_prop_num_1:setColor(FONT_COLOR.WHITE)
	end
	self._rootnode.cost_prop_num_2:setString("/" .. cyls_num)
	alignNodesOneByAll({
	self._rootnode.cost_prop_num_1,
	self._rootnode.cost_prop_num_2
	})
end

return SZQiangHuaLayer