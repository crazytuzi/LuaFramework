local ZhenYingPaiQi = class("ZhenYingPaiQi",UFCCSModelLayer)
function ZhenYingPaiQi.show()
    local layer = ZhenYingPaiQi.new("ui_layout/shop_ZhenYingPaiQi.json",Colors.modelColor)
    uf_sceneManager:getCurScene():addChild(layer)
end

function ZhenYingPaiQi:ctor(json,color,...)
    self.super.ctor(self,...)
    self:showAtCenter(true)
    self:registerTouchEvent(false, true, 0)
    self._groupImageList = {
    	self:getImageViewByName("Image_wei"),
    	self:getImageViewByName("Image_shu"),
    	self:getImageViewByName("Image_wu"),
    	self:getImageViewByName("Image_qun"),
	}

	self._langList = {
		"LANG_ZHEN_YING_WEI_JIANG_ZHAO_MU",
		"LANG_ZHEN_YING_SHU_JIANG_ZHAO_MU",
		"LANG_ZHEN_YING_WU_JIANG_ZHAO_MU",
		"LANG_ZHEN_YING_QUN_JIANG_ZHAO_MU",
	}

	self._arrowImageList = {
		self:getImageViewByName("Image_wei2shu"),
		self:getImageViewByName("Image_shu2wu"),
		self:getImageViewByName("Image_wu2qun"),
		self:getImageViewByName("Image_qun2wei"),
	}
	self:_initWidgets()
	self:_refreshWidgets()
	self._timerHandler = G_GlobalFunc.addTimer(1, function()
        self:_refreshWidgets()
	end)

	self:registerBtnClickEvent("Button_close",function()
		self:animationToClose()
		end)

end


function ZhenYingPaiQi:_initWidgets()
	for i=1,4 do
		self:getLabelByName("Label_title0" .. i):setText(G_lang:get(self._langList[i]))
		self:getLabelByName("Label_title0" .. i):createStroke(Colors.strokeBrown,1)
		self:getLabelByName("Label_kaiqi0" .. i):setText(G_lang:get('LANG_ZHEN_YING_JI_JIANG_KAI_QI'))
		self:getLabelByName("Label_kaiqi0" .. i):createStroke(Colors.strokeBrown, 1)
		self:getLabelByName("Label_time0" .. i):createStroke(Colors.strokeBrown,1)
		self:getLabelByName("Label_timeTag0" .. i):createStroke(Colors.strokeBrown,1)
	end

	self:getLabelByName("Label_23"):createStroke(Colors.strokeBrown, 1)
end

function ZhenYingPaiQi:_refreshWidgets()
	local tInitInfo = G_Me.themeDropData:getInitializeInfo()
	if not tInitInfo then
		return
	end

	self._group = math.ceil((tInitInfo._nGroupCycle+1)/2) or 1
	for i=1,4 do
		if self._group == i then
			self._groupImageList[i]:loadTexture(G_Path.getKnightGroupIconSelected(i))
			self._arrowImageList[i]:loadTexture("ui/yangcheng/arrow_jinjie.png")
			self:showWidgetByName("Panel_time0" .. i,true)
			self:showWidgetByName("Label_kaiqi0" .. i,false)
			--[[
			--剩余时间
			local timeString = G_ServerTime:secondToString(G_Me.shopData:getZhenYingDropKnightLeftTime())
			self:getLabelByName("Label_time0" .. i):setText(timeString)
			self:getLabelByName("Label_time0" .. i):setText(timeString)
			]]

			--剩余时间
			local nChangeTime = G_Me.themeDropData:getChangeGroupRemainTime()
			local szTime = G_ServerTime:getLeftSecondsString(nChangeTime)
			if szTime == "-" then
				szTime = "00:00:00"
			end
			self:getLabelByName("Label_time0" .. i):setText(szTime)

		else
			self._arrowImageList[i]:loadTexture("ui/shop/knight_drop/arrow_gray.png")
			self._groupImageList[i]:loadTexture(G_Path.getKnightGroupIcon(i))
			local nextGroup =  self._group+1
			nextGroup = nextGroup > 4 and nextGroup%4 or nextGroup
			if nextGroup == i then
				--即将开启
				self:showWidgetByName("Panel_time0" .. i,false)
				self:showWidgetByName("Label_kaiqi0" .. i,true)
			else
				self:showWidgetByName("Panel_time0" .. i,false)
				self:showWidgetByName("Label_kaiqi0" .. i,false)
			end
		end
	end


end

function ZhenYingPaiQi:onLayerEnter()
	self:closeAtReturn(true)
	local EffectSingleMoving = require "app.common.effects.EffectSingleMoving"
	EffectSingleMoving.run(self:getWidgetByName("Image_xixu"), "smoving_wait", nil , {position = true} )
	require("app.common.effects.EffectSingleMoving").run(self, "smoving_bounce")
end

function ZhenYingPaiQi:onLayerExit()
	if self._timerHandler ~= nil then
	    G_GlobalFunc.removeTimer(self._timerHandler)
	end
end

function ZhenYingPaiQi:onTouchEnd( xpos, ypos )
    self:animationToClose()
end

return ZhenYingPaiQi

