local EquipQuickChose = class("EquipQuickChose", function(param)
	return require("utility.ShadeLayer").new()
end)
local btn_effect = function(sender, callback)
	if callback then
		callback()
	end
end

function EquipQuickChose:ctor(callback)
	local baseNode = display.newNode()
	self:addChild(baseNode)
	local rootProxy = CCBProxy:create()
	self._rootnode = {}
	local rootnode = CCBuilderReaderLoad("equip/equip_quick_select", rootProxy, self._rootnode)
	baseNode:setPosition(display.cx, display.cy)
	baseNode:addChild(rootnode, 1)
	local selected = {
	[1] = false,
	[2] = false,
	[3] = false,
	[4] = false
	}
	local function onSelecteAllBtn()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		for i = 1, 4 do
			selected[i] = true
			self._rootnode["selectedFlag_" .. tostring(i)]:setVisible(true)
		end
	end
	self._rootnode.titleLabel:setString(common:getLanguageString("@SelectStar"))
	local function onConfirmBtn()
		GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_queding))
		if callback then
			callback(selected)
		end
		self:removeSelf()
	end
	
	local function onSelectedStar(tag)
		if selected[tag] then
			selected[tag] = false
		else
			selected[tag] = true
		end
		self._rootnode["selectedFlag_" .. tostring(tag)]:setVisible(selected[tag])
	end
	
	self._rootnode.closeBtn:addHandleOfControlEvent(function(sender, eventName)
		btn_effect(sender, function()
			GameAudio.playSound(ResMgr.getSFX(SFX_NAME.u_guanbi))
			self:removeSelf()
		end)
	end,
	CCControlEventTouchUpInside)
	
	self._rootnode.chooseAllBtn:addHandleOfControlEvent(function(sender, eventName)
		btn_effect(sender, onSelecteAllBtn)
	end,
	CCControlEventTouchUpInside)
	
	self._rootnode.confirmBtn:addHandleOfControlEvent(function(eventName, sender)
		btn_effect(sender, onConfirmBtn)
	end,
	CCControlEventTouchUpInside)
	
	for i = 1, 4 do
		self._rootnode["chooseStarBtn_" .. tostring(i)]:registerScriptTapHandler(onSelectedStar)
	end
end

return EquipQuickChose