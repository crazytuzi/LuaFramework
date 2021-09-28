
local UIBase = require "ui/common/UIBase"

local UIButton=class("UIButton", UIBase)

local UIDefault = require "ui/common/DefaultValue"

local UICommon = require "ui/common/UICommon"

function UIButton:ctor(ccNode, propConfig)
    UIButton.super.ctor(self, ccNode, propConfig)

	self.imageNormal_ = propConfig.imageNormal or UIDefault.DefButton.imageNormal
	self.imagePressed_ = propConfig.imagePressed or UIDefault.DefButton.imagePressed
	self.imageDisable_ = propConfig.imageDisable or UIDefault.DefButton.imageDisable
	self.disablePressScale = propConfig.disablePressScale

	self.name = propConfig.name

	self.sound = propConfig.soundEffectClick
	self.textColor = {}
	self._isPressed = false

	self.etype = propConfig.etype
	if propConfig.roundButton then
		self.ccNode_:setRoundButton(true)
	end
	
	self.stateColor = nil --定制按下和普通的文本颜色
end

function UIButton:setTitleText(text)
	error("deprecated")
	--self.ccNode_:setTitleText(text)
end

-- 按钮不同状态的颜色 {{主体，描边}，{主体，描边}} 分别是选中和正常
function UIButton:setTitleTextColor(color)
	self.textColor = color
end 

function UIButton:onTouchEvent(hoster, cb, arg)
	self._click = { hoster = hoster, cb = cb, arg = arg}
	local function touchEvent(sender, eventType)
		if eventType == ccui.TouchEventType.began then
			if not self.disablePressScale then
				self:setScale(0.85)
			end
		elseif eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
			self:setScale(1)
		end
		if cb then
			cb(hoster, self, eventType, arg);
		end
	end
	self.ccNode_:setTouchEnabled(true);
	self.ccNode_:addTouchEventListener(touchEvent);
end

function UIButton:onClick(hoster, cb, arg)
	self._click = { hoster = hoster, cb = cb, arg = arg}
	local function touchEvent(sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			if cb then
				if not self.sound then
					if self.name=="gb" then
						self.sound = g_i3k_db.i3k_db_get_sound_path(502)
					end
				end
				i3k_game_play_sound(self.sound, 1)
				cb(hoster, self, arg);
			end
		end
	end
	self.ccNode_:setTouchEnabled(true);
	self.ccNode_:addTouchEventListener(touchEvent);
end

function UIButton:setScale9Enabled(able)
	self.ccNode_:setScale9Enabled(able)
end

function UIButton:stateToPressed(unusual, ignoreTxt)
	self:setImage(self.imagePressed_, self.imagePressed_)
	self:resetScale9()
	self._isPressed = true
	if ignoreTxt then
		return
	end
	local children = self:getChildren()
	for i,v in pairs(children) do
		if v:getDescription()=="Label" then
			if self.stateColor then
				v:setTextColor(UICommon.getColorC4BByStr(self.stateColor.pressedColor))
			else
				local color = self.textColor[1]
				if unusual then
					v:setTextColor(UICommon.getColorC4BByStr(color and color[1] or "FF914a15"))
				else
					v:setTextColor(UICommon.getColorC4BByStr("FF8d5328"))
				end
				v:enableOutline(UICommon.getColorC4BByStr(color and color[2] or "FFFFFF00"), 0)
			end
		end
	end
end

--  按钮恢复正常状态
function UIButton:stateToNormal(unusual, ignoreTxt)
	self:setImage(self.imageNormal_, self.imagePressed_)
	self:resetScale9()
	self._isPressed = false
	if ignoreTxt then
		return
	end
	local children = self:getChildren()
	for i,v in pairs(children) do
		if v:getDescription()=="Label" then
			if self.stateColor then
				v:setTextColor(UICommon.getColorC4BByStr(self.stateColor.normalColor))
			else
				local color = self.textColor[2]
				if unusual then
					v:setTextColor(UICommon.getColorC4BByStr(color and color[1] or "FF966856"))
				else
					v:setTextColor(UICommon.getColorC4BByStr("FFebc6b4"))
				end
				v:enableOutline(UICommon.getColorC4BByStr(color and color[2] or "FF51361C"), 0)
			end
		end
	end
	self.ccNode_:setEnabled(true)
end

function UIButton:isStatePressed()
	return self._isPressed
end

function UIButton:resetScale9()
	if self.propScale9Rect then
		self.ccNode_:setCapInsets(self.propScale9Rect)
	end
end

function UIButton:setButtonStateColor(normalColor,pressedColor)
	self.stateColor = {
		normalColor = normalColor,
		pressedColor = pressedColor
	}
end

function UIButton:setNormalImage(normal)
	self.ccNode_:loadTextureNormal(i3k_checkPList(normal))
	return self
end

function UIButton:setImage(normal, pressed)
	pressed = pressed or normal
	self.ccNode_:loadTextureNormal(i3k_checkPList(normal))
	self.ccNode_:loadTexturePressed(i3k_checkPList(pressed))
	return self
end
function UIButton:setPressedImgs(normalImg, pressedImg)
    self.imageNormal_ = normalImg
    self.imagePressed_ = pressedImg
end

--  按钮处于被点击状态(不再可点击)
function UIButton:stateToPressedAndDisable(unusual)
	self.ccNode_:setEnabled(false)
	self:stateToPressed(unusual)
end

--  按钮处于正常状态(可点击)
--[[function UIButton:stateToNormalAndEnable()
	self.ccNode_:setEnabled(true)
	self:stateToNormal()
end--]]

return UIButton
