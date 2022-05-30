--¬€Ω£’Û»›
local HuaShanFormLayer = class("", function()
	return require("utility.ShadeLayer").new()
end)

function HuaShanFormLayer:ctor(param)
	local _info = param.info
	local _heros = param.heros
	local _floor = param.floor
	local _index = param.index
	local proxy = CCBProxy:create()
	self._rootnode = {}
	local node = CCBuilderReaderLoad("huashan/huashan_form_layer", proxy, self._rootnode)
	node:setPosition(display.cx, display.cy)
	self:addChild(node)
	
	self._rootnode.titleLabel:setString(common:getLanguageString("@TalkSwordLevel", _index))
	self._rootnode.tag_close:addHandleOfControlEvent(function()
		self:removeSelf()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
	end,
	CCControlEventTouchUpInside)
	
	self._rootnode.enterBtn:addHandleOfControlEvent(function()
		if _index <= _floor then
			show_tip_label(common:getLanguageString("@CurrentLevelFinished"))
			return
		end
		if _floor == 0 or _floor == -1 or _index == _floor + 1 then
			self._rootnode.enterBtn:setEnabled(false)
			self:performWithDelay(function()
				self._rootnode.enterBtn:setEnabled(true)
				push_scene(require("game.scenes.formSettingBaseScene").new({
				heros = _heros,
				floor = _index,
				save_form_title = "huashan_form_info" .. tostring(game.player.m_uid),
				formSettingType = FormSettingType.HuaShanType,
				confirmFunc = function(fmtstr)
					RequestHelper.huashan.fight({
					fmt = fmtstr,
					floor = _index,
					callback = function(data)
						pop_scene()
						local scene = require("game.huashan.HuaShanBattleScene").new({
						data = data,
						enemyName = _info.name,
						enemyCombat = _info.combat
						})
						display.replaceScene(scene)
						GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
					end
					})
				end
				}))
			end,
			0.1)
		end
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
	end,
	CCControlEventTouchUpInside)
	
	self._rootnode.zdlLabel:setString(tostring(_info.combat))
	
	ResMgr.oppName = _info.name
	local heroNameLabel = ui.newTTFLabelWithOutline({
	text = _info.name,
	font = FONTS_NAME.font_fzcy,
	size = 20,
	color = NAME_COLOR[_info.cards[1].star or 3],
	outlineColor = FONT_COLOR.WHITE,
	align = ui.TEXT_ALIGN_LEFT
	})
	
	ResMgr.replaceKeyLableEx(heroNameLabel, self._rootnode, "playerNameLabel", 0, 0)
	heroNameLabel:align(display.LEFT_CENTER)
	
	for i = 1, 6 do
		self._rootnode[string.format("headIcon_%d", i)]:setVisible(false)
	end
	
	for i = 1, 6 do
		if _info.cards[i] then
			local _baseInfo = ResMgr.getCardData(_info.cards[i].cardId)
			local name
			if _info.cards[i].cardId == 1 or _info.cards[i].cardId == 2 then
				name = _info.name
			else
				name = _baseInfo.name
			end
			local heroNameLabel = ui.newTTFLabelWithShadow({
			text = name,
			font = FONTS_NAME.font_fzcy,
			size = 18,
			align = ui.TEXT_ALIGN_CENTER,
			color = NAME_COLOR[_info.cards[i].star],
			shadowColor = FONT_COLOR.BLACK,
			})
			
			ResMgr.replaceKeyLableEx(heroNameLabel, self._rootnode, string.format("heroNameLabel_%d", _info.cards[i].pos), 0, 0)
			heroNameLabel:align(display.CENTER)
			
			if _info.cards[i].cls > 0 then
				local clsLabel = ui.newTTFLabelWithShadow({
				text = "+" .. tostring(_info.cards[i].cls),
				font = FONTS_NAME.font_fzcy,
				size = 18,
				color = cc.c3b(0, 228, 62),
				shadowColor = FONT_COLOR.BLACK,
				align = ui.TEXT_ALIGN_CENTER,
				})
				ResMgr.replaceKeyLable(clsLabel, self._rootnode[string.format("heroNameLabel_%d", _info.cards[i].pos)], heroNameLabel:getContentSize().width / 2, 0)
				clsLabel:align(display.LEFT_CENTER)
			end
			
			ResMgr.refreshIcon({
			id = _baseInfo.id,
			resType = ResMgr.HERO,
			cls = _info.cards[i].cls,
			itemBg = self._rootnode[string.format("iconSprite_%d", _info.cards[i].pos)]
			})
			local jobIcon = display.newSprite(string.format("#icon_frame_%d.png", _baseInfo.job))
			jobIcon:setPosition(15, 15)
			jobIcon:setScale(0.7)
			self._rootnode[string.format("iconSprite_%d", _info.cards[i].pos)]:addChild(jobIcon)
			local levelLabel = ui.newTTFLabelWithShadow({
			text = tostring(_info.cards[i].level),
			font = FONTS_NAME.font_fzcy,
			size = 20,
			align = ui.TEXT_ALIGN_RIGHT,
			color = FONT_COLOR.WHITE,
			shadowColor = FONT_COLOR.BLACK
			})
			levelLabel:align(display.RIGHT_BOTTOM, self._rootnode[string.format("iconSprite_%d", _info.cards[i].pos)]:getContentSize().width - 4, 4)
			self._rootnode[string.format("iconSprite_%d", _info.cards[i].pos)]:addChild(levelLabel)
			self._rootnode[string.format("headIcon_%d", _info.cards[i].pos)]:setVisible(true)
		end
	end
end

return HuaShanFormLayer