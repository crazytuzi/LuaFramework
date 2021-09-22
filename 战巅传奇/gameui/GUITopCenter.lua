local GUITopCenter = {}
local var = {}
function GUITopCenter.init_ui(topCenter)
	var = {
		topCenter,
		layerFuben,
		layerPassStar,
		lblCoundDown,
	}
	var.topCenter = topCenter
	var.topCenter:align(display.TOP_CENTER, display.cx, display.height)
	var.layerFuben = topCenter:getWidgetByName("layerFuben"):hide()
	var.layerPassStar = topCenter:getWidgetByName("layerPassStar"):hide()

	topCenter:getWidgetByName("progress_bar_bg"):setPositionY(display.height*-0.25):hide()
	var.progressBar = topCenter:getWidgetByName("progress_bar"):setFormatString("")
	var.progressBar:getLabel():setPositionY(-25):setTextColor(GameBaseLogic.getColor(0xF1E8D0))

	cc.EventProxy.new(GameSocket, var.topCenter)
		:addEventListener(GameMessageCode.EVENT_PUSH_PANEL_DATA, GUITopCenter.handlePanelData)
		:addEventListener(GameMessageCode.EVENT_FRESH_FUBEN,GUITopCenter.freshLayerFuBen)
end

function GUITopCenter.handlePanelData(event)
	local data = GameUtilSenior.decode(event.data)
	if event.type =="showPassStar" then
		GUITopCenter.showPassStar(data)
	end
end

function GUITopCenter.freshLayerFuBen(event)
	var.layerFuben:setVisible(event.visible and true or false)
	var.layerFuben:getWidgetByName("img_fb_countDown"):setVisible(event.second ~=nil)
	var.layerFuben:getWidgetByName("lbl_fuben_info2"):setVisible(event.second ~=nil)

	local img_fuben_info3 = var.layerFuben:getWidgetByName("img_fuben_info3")
	local imgs = {"img_bu_susha","img_bu_quanmie","img_bu_zhanjiang"}
	if event.imgindex~=nil then
		local imgindex = event.imgindex or 1
		img_fuben_info3:loadTexture(imgs[imgindex],ccui.TextureResType.plistType)
		img_fuben_info3:pos(300,100):show()
		img_fuben_info3:stopAllActions():runAction(cca.seq({
			cc.EaseIn:create(cca.moveTo(0.5, 100, 100),0.5),
			cca.delay(5),
			cca.hide(),
		}))
	end
	local leftsecond = event.second
	if tonumber(leftsecond) then
		if not var.lblCoundDown then
			var.lblCoundDown = display.newBMFontLabel({font = "image/typeface/num_14.fnt",})
			:align(display.CENTER, 0, 0)
			:setName("lblCoundDown")
			:setString("0")
			:addTo(var.layerFuben:getWidgetByName("lbl_fuben_info2"))
		end
		var.layerFuben:stopAllActions()
		var.lblCoundDown:setString(leftsecond)
		var.layerFuben:runAction(cca.rep(cca.seq({
			cca.delay(1),
			cca.cb(function()
				leftsecond = leftsecond - 1
				var.lblCoundDown:setString(leftsecond)
			end)
		}),leftsecond))
	else
		var.layerFuben:stopAllActions()
	end
end
--65090,65091
function GUITopCenter.showPassStar(data)
	var.layerPassStar:setVisible(true)
	local passStar = tonumber(data.passStar)
	 --if passStar ==3 then
		--local startPos = {cc.p(137,295),cc.p(216,324),cc.p(293,293)}

		for i=1,3 do
			 star = var.layerPassStar:getWidgetByName("img_star"..i):setVisible(passStar>=i)
			 --star = var.layerPassStar:getWidgetByName("img_star"..i):setVisible(true)
			star:setPositionX(84+i*64)
			-- star:loadTexture("img_star_big", ccui.TextureResType.plistType)
			 --star:getVirtualRenderer():setState(passStar>=i and 0 or 1)
			 --star:runAction(cca.seq({
			 	--cca.moveTo(0, 217, 137),
			 	--cca.moveTo(0.3+0.2*i, startPos[i].x, startPos[i].y)
			 	--cca.show(),
			 --}))
		end
		-- local star
		--[[for i=1,3 do
			-- star = var.layerPassStar:getWidgetByName("img_star"..i)
			-- star:loadTexture("img_star_big", ccui.TextureResType.plistType)
			-- star:getVirtualRenderer():setState(passStar>=i and 0 or 1)
			-- star:runAction(cca.seq({
			-- 	cca.moveTo(0, 217, 137),
			-- 	cca.moveTo(0.3+0.2*i, startPos[i].x, startPos[i].y)
			-- }))
			local effectSprite = var.layerPassStar:getChildByName("effectSprite"..i)
			if not effectSprite then
				effectSprite = cc.Sprite:create()
				:align(display.CENTER, startPos[i].x, startPos[i].y)
				:addTo(var.layerPassStar)
				:setName("effectSprite"..i)
			end
			effectSprite:stopAllActions():hide()
			local animate1 = cc.AnimManager:getInstance():(4, 65090, 4, 5)
			local animate2 = cc.AnimManager:getInstance():getPlistAnimate(4, 65091, 4, 5)
			effectSprite:runAction(cca.seq({
				cca.delay(0.3*i),
				cca.show(),
				animate1,
				cca.rep(animate2,16),
				cca.hide()
			}))
		end]]
	--[[else
		for i=1,3 do
			local effectSprite = var.layerPassStar:getChildByName("effectSprite"..i)
			if effectSprite then
				effectSprite:stopAllActions():hide()
			end
		end]]
	 --end
	var.layerPassStar:getWidgetByName("lbl_pass"):setString(passStar==3 and "三星通关(完美通关)" or GameUtilSenior.numberToChinese(passStar).."星通关")

	var.layerPassStar:stopAllActions()
	var.layerPassStar:runAction(cca.seq({
		cca.delay(4),
		cca.cb(function(target)
			target:hide()
			for i=1,3 do
				local effectSprite = var.layerPassStar:getChildByName("effectSprite"..i)
				if effectSprite then
					effectSprite:stopAllActions()
				end
			end
		end)
	}))
end

function GUITopCenter.showProgressBar(event)
	var.topCenter:getWidgetByName("progress_bar_bg"):show()
	if event.info then
		var.progressBar:setFontSize( 16 ):setFormatString(event.info)
	end
	if event.time then
		var.progressBar:setProgressTime(event.time)
	end
	GameSocket.m_bCollecting = true
	var.progressBar:setPercent(0,100)
	var.progressBar:setPercentWithAnimation(100,100,function()
		GUITopCenter.hideProgressBar()
		-- GameSocket.m_bCollecting = false
	end)
end

function GUITopCenter.hideProgressBar()
	var.topCenter:getWidgetByName("progress_bar_bg"):hide()

	var.progressBar:stopAllActions()
	var.progressBar:setPercent(0)

end

return GUITopCenter