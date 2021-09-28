local ZhenYingDropButton = class("ZhenYingDropButton",function()
	return CCSItemCellBase:create("ui_layout/shop_ZhenYingDropButton.json")
	end)
require("app.cfg.camp_drop_info")
local FunctionLevelConst = require("app.const.FunctionLevelConst")
function ZhenYingDropButton:ctor(group)
	self._group = group or 1
	local Button = self:getButtonByName("Button_zhenying")
	Button:loadTextureNormal(G_Path.getZhenYingDropImage(group))
	self:registerBtnClickEvent("Button_zhenying",function()
		local FunctionLevelConst = require("app.const.FunctionLevelConst")
		if not G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.THEME_DROP) then 
	        return 
	    end
	    --[[
		local layer = require("app.scenes.shop.ShopDropZhenYingKnightLayer").new(self._group)
		uf_sceneManager:getCurScene():addChild(layer)
		]]

		local pack = G_GlobalFunc.sceneToPack("app.scenes.shop.ShopScene")
		uf_sceneManager:replaceScene(require("app.scenes.themedrop.ThemeDropMainScene").new(pack))
	end)

	self:registerBtnClickEvent("Button_wenhao",function()
		local FunctionLevelConst = require("app.const.FunctionLevelConst")
		if not G_moduleUnlock:checkModuleUnlockStatus(FunctionLevelConst.THEME_DROP) then 
	        return 
	    end
		require("app.scenes.shop.ZhenYingPaiQi").show()
	end)
	self._timeLabel = self:getLabelByName("Label_leftTime")
	self._priceLabel = self:getLabelByName("Label_price")
	self:getLabelByName("Label_finish"):setText(G_lang:get("LANG_ZHEN_YING_CHOU_JIANG_FINISH_FOR_BUTTON"))
	self:_createStroke()
	self:updateButton()
end

function ZhenYingDropButton:_createStroke( ... )
	self._timeLabel:createStroke(Colors.strokeBrown,1)
	self._priceLabel:createStroke(Colors.strokeBrown,1)
	self:getLabelByName("Label_priceTag"):createStroke(Colors.strokeBrown,1)
	self:getLabelByName("Label_leftTimeTag"):createStroke(Colors.strokeBrown,1)
	self:getLabelByName("Label_finish"):createStroke(Colors.strokeBrown,1)
end


function ZhenYingDropButton:updateButton(group)
	if G_moduleUnlock:isModuleUnlock(FunctionLevelConst.THEME_DROP) then
		--锁相关
		self:showWidgetByName("Image_lock",false)
		self:showWidgetByName("Label_kaiqi",false)

		local tInitInfo = G_Me.themeDropData:getInitializeInfo()
		local nCurGroup = math.ceil((tInitInfo._nGroupCycle+1)/2)
		if nCurGroup ~= self._group then
			self._group = nCurGroup
			local Button = self:getButtonByName("Button_zhenying")
			Button:loadTextureNormal(G_Path.getZhenYingDropImage(self._group))
		end

		local nFreeTimes = G_Me.themeDropData:getFreeTimes()
		local nRemainTimes = G_Me.themeDropData:getRemainDropTimes()
		if nFreeTimes == 0 and nRemainTimes == 0 then
			self:showWidgetByName("Panel_jpxiaohao",false)
			self:showWidgetByName("Panel_leftTime",false)
			self:showWidgetByName("Panel_Free",false)
			self:showWidgetByName("Label_finish",true)
		else 
			self:showWidgetByName("Panel_leftTime",true)
			self:showWidgetByName("Label_finish",false)
			local price = G_Me.themeDropData:getOnceAstrologyCost()
			if price ~= -1 then
				self:getLabelByName("Label_price"):setText(tostring(price))
			else
				self:getLabelByName("Label_price"):setText("")
			end
			-- 剩余多少次数，可能要显示免费的次数
			if nFreeTimes > 0 then
				self:showWidgetByName("Panel_jpxiaohao",false)
				self:showWidgetByName("Panel_Free",true)
				local labelFreeTag = self:getLabelByName("Label_FreeTag")
				if labelFreeTag then
					labelFreeTag:createStroke(Colors.strokeBrown, 1)
				end
				local labelRemain = self:getLabelByName("Label_RemainTime0")
				if labelRemain then
					labelRemain:createStroke(Colors.strokeBrown, 1)
					labelRemain:setText(G_lang:get("LANG_THEME_DROP_REMAIN_TIMES", {num=nRemainTimes}))
				end
			else
				self:showWidgetByName("Panel_jpxiaohao",true)
				self:showWidgetByName("Panel_Free",false)
				local labelRemain = self:getLabelByName("Label_RemainTime")
				if labelRemain then
					labelRemain:createStroke(Colors.strokeBrown, 1)
					labelRemain:setText(G_lang:get("LANG_THEME_DROP_REMAIN_TIMES", {num=nRemainTimes}))
				end
			end

			--剩余时间
			local nChangeTime = G_Me.themeDropData:getChangeGroupRemainTime()
			local szTime = G_ServerTime:getLeftSecondsString(nChangeTime)
			if szTime == "-" then
				szTime = "00:00:00"
			end
			self._timeLabel:setText(szTime)
		end

		-- 显示红点
		self:showWidgetByName("Image_tips", G_Me.themeDropData:hasFreeTimes() or G_Me.themeDropData:couldExtractKnight())
	else
		self:showLock()
	end
end

--显示开启等级
function ZhenYingDropButton:showLock()
	-- 40级预览
	if G_Me.userData.level >= 40 and not G_moduleUnlock:isModuleUnlock(FunctionLevelConst.THEME_DROP) then
		self:showWidgetByName("Image_lock",true)
		self:showWidgetByName("Label_kaiqi",true)
		self:showWidgetByName("Panel_leftTime",false)
		self:showWidgetByName("Panel_Free",false)
		self:showWidgetByName("Panel_jpxiaohao",false)
		self:showWidgetByName("Label_finish",false)
		local _level = G_moduleUnlock:getModuleUnlockLevel(FunctionLevelConst.THEME_DROP)
		self:getLabelByName("Label_kaiqi"):setText(G_lang:get("LANG_ZHEN_YING_KAI_QI_LEVEL",{level=_level}))
		self:getLabelByName("Label_kaiqi"):createStroke(Colors.strokeBrown,1)
		GlobalFunc.setDark(self:getButtonByName("Button_zhenying"), true)
		self:getButtonByName("Button_zhenying"):setColor(ccc3(255/3, 255/3, 255/3))
	else
		self:showWidgetByName("Image_lock",false)
		self:showWidgetByName("Label_kaiqi",false)
		self:showWidgetByName("Panel_leftTime",true)
		self:showWidgetByName("Panel_Free",true)
		self:showWidgetByName("Panel_jpxiaohao",true)
		self:showWidgetByName("Label_finish",true)
		GlobalFunc.setDark(self:getButtonByName("Button_zhenying"), false)
	end
end

return ZhenYingDropButton