local ActivityPageTaoBaoGift = class("ActivityPageTaoBaoGift", UFCCSNormalLayer)

function ActivityPageTaoBaoGift.create(...)
	return ActivityPageTaoBaoGift.new("ui_layout/activity_ActivityTaoBaoGift.json", nil, ...)
end

ActivityPageTaoBaoGift.URL = "http://huodong.m.taobao.com/pailitao/xrener.html"

function ActivityPageTaoBaoGift:ctor(json, param, ...)
	self._isInited = false

	self.super.ctor(self, json, param, ...)
end

function ActivityPageTaoBaoGift:onLayerLoad()
	self:_initGifts()
	self:_initWidgets()
end

function ActivityPageTaoBaoGift:onLayerEnter()
	
end

function ActivityPageTaoBaoGift:onLayerExit()
	
end

function ActivityPageTaoBaoGift:onLayerUnload()
	
end

function ActivityPageTaoBaoGift:adapterLayer()
    local panel = self:getPanelByName("Panel_alot")
    local height = display.height
    local y = 128 - (display.height - 853)/2 
    local pos = ccp(panel:getPosition())
    panel:setPosition(ccp(pos.x,y))
end

function ActivityPageTaoBaoGift:_initWidgets()
	local tIconList = {41052, 41053}
	for i=1, 2 do
		local imgIcon = self:getImageViewByName("Image_Icon"..i)
		if imgIcon then
			imgIcon:loadTexture(G_Path.getItemIcon(tIconList[i]))
		end

		self:registerWidgetClickEvent("Image_QualityFrame"..i, function()
			local tGiftList = self["_tGiftList"..i]
			local tLayer = require("app.scenes.common.AwardPreview").create(tGiftList)
			if tLayer then
				uf_sceneManager:getCurScene():addChild(tLayer)
			end
		end)
	end

	self:registerBtnClickEvent("Button_GoToTaoBao", function()
		self:_onShowWebInfo(ActivityPageTaoBaoGift.URL)
	end)
end

function ActivityPageTaoBaoGift:_onShowWebInfo(szURL)
    if G_NativeProxy.platform == "ios" then
        if G_NativeProxy.openURL then 
            G_NativeProxy.openURL(szURL)
        end
    elseif G_NativeProxy.platform == "android" then
        if GAME_VERSION_NO >= 10700 then
        	G_NativeProxy.native_call("shareGame",{{uri=szURL}})
        else
        	G_NativeProxy.openInnerUrl(szURL, G_lang:get("LANG_ACTIVITY_TAOBAO_GIFT"))
        end  
    elseif G_NativeProxy.platform == "wp8" or G_NativeProxy.platform == "winrt" then
        if G_NativeProxy.openInnerUrl then 
            G_NativeProxy.openInnerUrl(szURL, G_lang:get("LANG_ACTIVITY_TAOBAO_GIFT"))
        end
    end
end


function ActivityPageTaoBaoGift:showPage()
	-- 这里拉协议
	-- TODO：
end

function ActivityPageTaoBaoGift:updatePage()
	if self._isInited then
		return
	end
	self._isInited = true
end

function ActivityPageTaoBaoGift:_initGifts()
	-- 秒杀礼包
	self._tGiftList1 = {
		{type = 1, value = 0, size = 40000},
		{type = 2, value = 0, size = 30},
		{type = 3, value = 4, size = 1},
		{type = 3, value = 5, size = 1},
	}

	-- 淘金币礼包
	self._tGiftList2 = {
		{type = 2,  value = 0, size = 200},
		{type = 13, value = 0, size = 200},
		{type = 3,  value = 3, size = 2},
	}
end

return ActivityPageTaoBaoGift