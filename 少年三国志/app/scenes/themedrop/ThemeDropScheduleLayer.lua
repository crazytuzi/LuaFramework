local MoShenConst = require("app.const.MoShenConst")
local CommonFunc = require("app.scenes.moshen.rebelboss.RebelBossCommonFunc")
local ThemeDropScheduleLayer = class("ThemeDropScheduleLayer", UFCCSModelLayer)

function ThemeDropScheduleLayer.create(nCurGroup, nChangeTime, ...)
	return ThemeDropScheduleLayer.new("ui_layout/themedrop_ScheduleLayer.json", Colors.modelColor, nCurGroup, nChangeTime, ...)
end

function ThemeDropScheduleLayer:ctor(json, param, nCurGroup, nChangeTime, ...)
	self.super.ctor(self, json, param, ...)

	self._nCurGroup = nCurGroup or MoShenConst.GROUP.WEI
	self._nChangeTime = nChangeTime or 0
    self._nNextGroup = 1

    self._labelTime = nil
    self._labelTimeDesc = nil

    if self._nCurGroup ~= MoShenConst.GROUP.QUN then
        self._nNextGroup = self._nCurGroup + 1
    else
        self._nNextGroup = MoShenConst.GROUP.WEI
    end

    self:_initWidgets()
end

function ThemeDropScheduleLayer:onLayerEnter()
	self:showAtCenter(true)
	self:closeAtReturn(true)
	self:setClickClose(true)

    require("app.common.effects.EffectSingleMoving").run(self:getWidgetByName("Image_Bg"), "smoving_bounce")
end

function ThemeDropScheduleLayer:onLayerExit()
	self:_removeTimer()
end

function ThemeDropScheduleLayer:_initWidgets()
	for i=1, 4 do
		if i == self._nCurGroup then
			-- 当前阵营
			self:showWidgetByName("Label_kaiqi0"..i, false)
			CommonFunc._updateImageView(self, "Image_Arrow"..i, {texture="ui/yangcheng/arrow_jinjie.png"})
			self._labelTime = self:getLabelByName("Label_time0"..i)
			self._labelTimeDesc = self:getLabelByName("Label_timeTag0"..i)
			self._labelTime:createStroke(Colors.strokeBrown, 1)
			self._labelTimeDesc:createStroke(Colors.strokeBrown, 1)
			self._labelTime:setText("")
			self._labelTimeDesc:setText("")
		elseif i == self._nNextGroup then
			-- 下一个开启的阵营
			self:showWidgetByName("Label_kaiqi0"..i, true)
			self:getLabelByName("Label_kaiqi0"..i):createStroke(Colors.strokeBrown, 1)
		else
			self:showWidgetByName("Label_kaiqi0"..i, false)
		end

		self:showWidgetByName("Image_Time0"..i, i==self._nCurGroup)
		CommonFunc._updateLabel(self, "Label_title0"..i, {text=G_lang:get("LANG_THEME_DROP_GROUP_"..i), stroke=Colors.strokeBrown})
	end

	self:_addTimer()

	self:registerBtnClickEvent("Button_close", function()
		self:animationToClose()
	end)

	local labelDesc = self:getLabelByName("Label_Desc")
	if labelDesc then
		labelDesc:createStroke(Colors.strokeBrown, 1)
	end
end

function ThemeDropScheduleLayer:_addTimer()
	if not self._tTimer then
		self._tTimer = G_GlobalFunc.addTimer(1, function()
			local szTime = G_ServerTime:getLeftSecondsString(self._nChangeTime)
			if szTime == "-" then
				szTime = "00:00:00"
				if self._tTimer then
					G_GlobalFunc.removeTimer(self._tTimer)
					self._tTimer = nil
				end
				self:animationToClose()
			end
			if self._labelTime and self._labelTimeDesc then
				self._labelTime:setText(szTime)
				self._labelTimeDesc:setText(G_lang:get("LANG_THEME_DROP_THEN_END"))

				local alignFunc = CommonFunc._autoAlignNew(ccp(0, 0), {
		            self._labelTime,
		            self._labelTimeDesc,
		        }, "C")
		        self._labelTime:setPositionXY(alignFunc(1))
		        self._labelTimeDesc:setPositionXY(alignFunc(2))    
			end
		end)
	end
end

function ThemeDropScheduleLayer:_removeTimer()
	if self._tTimer then
		G_GlobalFunc.removeTimer(self._tTimer)
		self._tTimer = nil
	end
end

return ThemeDropScheduleLayer