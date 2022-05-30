local data_ui_ui = require("data.data_ui_ui")

local DuobaoDebrisInfo = class("DuobaoDebrisInfo", function()
	return require("utility.ShadeLayer").new()
end)

function DuobaoDebrisInfo:getSnatchList()
	RequestHelper.Duobao.getSnatchList({
	id = tostring(self._id),
	callback = function(data)
		self:initDuobaoListScene(data)
	end
	})
end

function DuobaoDebrisInfo:initDuobaoListScene(data)
	if string.len(data["0"]) > 0 then
		show_tip_label(data["0"])
		self._snatchBtn:setEnabled(true)
		return
	end
	local warFreeTime = 0
	if self._getMianzhanTime ~= nil then
		warFreeTime = self._getMianzhanTime()
	end
	push_scene(require("game.Duobao.DuobaoQiangduoListScene").new({
	data = data,
	id = self._id,
	title = self._title,
	warFreeTime = warFreeTime
	}))
	self:removeSelf()
end

function DuobaoDebrisInfo:onExit()
	TutoMgr.removeBtn("qiangduo_info_btn")
end

function DuobaoDebrisInfo:onEnter()
	if self.tutoBtn:isVisible() then
		TutoMgr.addBtn("qiangduo_info_btn", self.tutoBtn)
		TutoMgr.active()
	end
end

function DuobaoDebrisInfo:ctor(param)
	self._id = param.id
	self._getMianzhanTime = param.getMianzhanTime
	self:setNodeEventEnabled(true)
	self.closeListener = param.closeListener
	local proxy = CCBProxy:create()
	local rootnode = {}
	local node = CCBuilderReaderLoad("duobao/duobao_debris_info.ccbi", proxy, rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	
	--¹Ø±Õ
	rootnode.closeBtn:addHandleOfControlEvent(function(sender, eventName)
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
		sender:runAction(transition.sequence({
		CCCallFunc:create(function()
			if self.closeListener ~= nil then
				self.closeListener()
			end
			self:removeSelf()
		end)
		}))
	end,
	CCControlEventTouchUpInside)
	
	--ÇÀ¶á
	self._snatchBtn = rootnode.snatchBtn
	self._snatchBtn:addHandleOfControlEvent(function(sender, eventName)
		if self.closeListener ~= nil then
			self.closeListener()
		end
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		PostNotice(NoticeKey.REMOVE_TUTOLAYER)
		self._snatchBtn:setEnabled(false)
		self:getSnatchList()
	end,
	CCControlEventTouchUpInside)
	
	self.tutoBtn = rootnode.snatchBtn
	local resType = ResMgr.getResType(param.type)
	ResMgr.refreshIcon({
	itemBg = rootnode.icon,
	id = self._id,
	resType = resType,
	itemType = param.type
	})
	self._title = param.title
	local nameColor = ResMgr.getItemNameColor(self._id)
	local nameLbl = ui.newTTFLabelWithShadow({
	text = self._title,
	size = 24,
	color = nameColor,
	shadowColor = FONT_COLOR.BLACK,
	font = FONTS_NAME.font_fzcy,
	align = ui.TEXT_ALIGN_LEFT
	})
	
	ResMgr.replaceKeyLableEx(nameLbl, rootnode, "nameLbl", 0, nameLbl:getContentSize().height / 2)
	nameLbl:align(display.LEFT_CENTER)
	
	rootnode.describeLbl:setString(param.describe)
	rootnode.bottom_describe_lbl:setString(data_ui_ui[3].content)
	if 0 < param.num then
		rootnode.numDescLbl:setVisible(true)
		rootnode.snatchBtn:setVisible(false)
		rootnode.numLbl:setString(common:getLanguageString("@CurrentNumber", tostring(param.num)))
	else
		rootnode.numDescLbl:setVisible(false)
		rootnode.snatchBtn:setVisible(true)
	end
end

return DuobaoDebrisInfo