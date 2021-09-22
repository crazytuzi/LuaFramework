local GUIFunctionBeta={}
local var = {}

--添加功能预告
local function initFuncPreview()
	if not var.uiFuncPreview then
		var.uiFuncPreview = GUIAnalysis.load("ui/layout/GUIFunctionBeta.uif")
		if var.uiFuncPreview then
			-- print("initFuncPreview")
			var.uiFuncPreview:align(display.RIGHT_TOP, var.panelPosx, display.height - 195):addTo(var.scene, 10)
		end
	end
end

--刷新功能预告
local function updateFuncPreview(data)
	-- print("updateFuncPreview", GameUtilSenior.encode(data))
	if not var.uiFuncPreview then
		initFuncPreview()
	end
	if var.uiFuncPreview then
		if data.level and data.level >= 1 and data.level <= 5 then
			var.uiFuncPreview:getWidgetByName("word_func_level"):loadTexture("word_func_level_"..data.level, ccui.TextureResType.plistType)
		end
		
		if data.pushicon and data.pushicon ~= "null" then
			GameUtilSenior.asyncload(var.uiFuncPreview, "img_func_icon", "ui/image/MenuIcon/"..data.pushicon..".png")
			GameUtilSenior.asyncload(var.uiFuncPreview, "word_func_name", "ui/image/MenuIcon/word_func_"..data.pushicon..".png")
			var.uiFuncPreview:getWidgetByName("img_func_icon"):setScale(0.7)
		end
		var.uiFuncPreview:show()
	end
end

--隐藏功能预告
local function hideFuncPreview()
	-- print("hideFuncPreview")
	if var.uiFuncPreview then var.uiFuncPreview:hide() end
end

local function handleFuncPreview(event)
	if not event then return end
	-- print("EVENT_HANDLE_FUNC_PREVIEW", event.visible)
	if event.visible then
		updateFuncPreview(event.data)
	else
		hideFuncPreview()
	end
end

function GUIFunctionBeta.init(scene)
	var = {
		scene,
		uiFuncPreview,
		panelPosx = display.width,
	}

	if scene then
		var.scene = scene
		handleFuncPreview(GameSocket.mFuncPreview)

		cc.EventProxy.new(GameSocket, scene)
			:addEventListener(GameMessageCode.EVENT_HANDLE_FUNC_PREVIEW, handleFuncPreview)
	end
end

function GUIFunctionBeta.set_GUIFunctionBeta_visible( vis )
	var.panelPosx = display.width + (248*(vis and 0 or 1))
	if var.uiFuncPreview then
		var.uiFuncPreview:runAction(cca.seq({
			cca.moveTo(0.2, var.panelPosx, var.uiFuncPreview:getPositionY())
		}))
	end
end

return GUIFunctionBeta