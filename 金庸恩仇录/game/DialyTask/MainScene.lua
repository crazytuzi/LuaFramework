local buttonRes = {
normal = "task/btn_get_n.png",
pressed = "task/btn_get_p.png",
disabled = "task/btn_get_p.png"
}
local TaskPopup = import(".TaskPopup")

local MainScene = class("MainScene", function()
	return display.newScene("MainScene")
end)

function MainScene:ctor()
	--[[
	ui.newTTFLabel({
	text = "zhengshiyu",
	size = 64,
	align = ui.TEXT_ALIGN_CENTER
	}):pos(display.cx, display.cy):addTo(self)
	cc.ui.UIPushButton.new(buttonRes):onButtonClicked(function()
		dump("click")
		local taskPopup = TaskPopup.new()
		self:addChild(taskPopup)
	end)
	:pos(display.cx, display.cy - 200):addTo(self)
	]]
end

function MainScene:onEnter()
end

function MainScene:onExit()
end

return MainScene