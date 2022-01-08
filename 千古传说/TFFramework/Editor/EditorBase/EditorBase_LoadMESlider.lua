local tMESlider = {}
-- tMESlider.__index = tMESlider
-- setmetatable(tMESlider, EditLua)

function EditLua:createSlider(szId, tParams)
	print("createSlider")
	if targets[szId] ~= nil then
		return
	end
	local slider = TFSlider:create()
	slider:setBarTexture("test/slider_bar.png");
	slider:setSlidBallTextureNormal("test/sliderThumb.png")
	slider:setProgressBarTexture("test/silder_progressBar.png");
	
	tTouchEventManager:registerEvents(slider)
	targets[szId] = slider

	EditLua:addToParent(szId, tParams)

	print("create success")
end

function tMESlider:setPercent(szId, tParams)
	print("setPercent")
	if tParams.nPercent ~= nil and targets[szId] ~= nil and targets[szId].setPercent then
		targets[szId]:setPercent(tParams.nPercent)
		print("setPercent run success")
	end
end


function tMESlider:loadBarTexture(szId, tParams)
	print("loadBarTexture")
	print(tParams.szBarTexture, targets[szId].setBarTexture)
	if tParams.szBarTexture ~= nil and targets[szId] ~= nil and targets[szId].setBarTexture then

		targets[szId]:setBarTexture(tParams.szBarTexture)
		if tParams.szBarTexture == "" then
			targets[szId]:setBarTexture("test/slider_bar.png")
		end

		print("loadBarTexture run success",targets[szId]:getSize())
	end
end

function tMESlider:loadSlidBallTextureNormal(szId, tParams)
	print("loadSlidBallTextureNormal")
	if tParams.szSlidBallTextureNormal ~= nil and targets[szId] ~= nil and targets[szId].setSlidBallTextureNormal then

		targets[szId]:setSlidBallTextureNormal(tParams.szSlidBallTextureNormal)
		if tParams.szSlidBallTextureNormal == "" then
			targets[szId]:setSlidBallTextureNormal("test/sliderThumb.png")
		end

		print("loadSlidBallTextureNormal run success")
	end
end

function tMESlider:loadSlidBallTexturePressed(szId, tParams)
	print("loadSlidBallTexturePressed", tParams.szSlidBallTexturePressed)
	if tParams.szSlidBallTexturePressed ~= nil and targets[szId] ~= nil and targets[szId].setSlidBallTexturePressed then
		targets[szId]:setSlidBallTexturePressed(tParams.szSlidBallTexturePressed)
		print("loadSlidBallTexturePressed run success")
	end
end

function tMESlider:loadSlidBallTextureDisabled(szId, tParams)
	print("loadSlidBallTextureDisabled")
	if tParams.szSlidBallTextureDisabled ~= nil and targets[szId] ~= nil and targets[szId].setSlidBallTextureDisabled then
		targets[szId]:setSlidBallTextureDisabled(tParams.szSlidBallTextureDisabled)
		print("loadSlidBallTextureDisabled run success")
	end
end

function tMESlider:loadProgressBarTexture(szId, tParams)
	print("loadProgressBarTexture")
	if tParams.szProgressBarTexture ~= nil and targets[szId] ~= nil and targets[szId].setProgressBarTexture then

		targets[szId]:setProgressBarTexture(tParams.szProgressBarTexture)
		if tParams.szProgressBarTexture == "" then
			targets[szId]:setProgressBarTexture("test/silder_progressBar.png")
		end
		print("loadProgressBarTexture run success",targets[szId]:getSize())
	end
end

return tMESlider