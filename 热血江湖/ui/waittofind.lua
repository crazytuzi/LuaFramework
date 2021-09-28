module(..., package.seeall)
local require = require;
local ui = require("ui/base");
-------------------------------------------------------
wnd_waitToFind = i3k_class("wnd_waitToFind", ui.wnd_base)

function wnd_waitToFind:ctor()

end

function wnd_waitToFind:configure()
	self._flag = false
	local widgets = self._layout.vars
	widgets.tip_btn:onClick(self, self.noMovement)
	
	self._inteText = 
	{
		[e_TYPE_MOONCAKE] = function()
			widgets.memoryCardTips:hide()
		end,
		[e_TYPE_DIGLETT] = function()
			widgets.memoryCardTips:hide()
		end,
		[e_TYPE_PROTECTMELON] = function()
			widgets.findMooncake:hide()
			widgets.memoryCardTips:hide()
		end,
		[e_TYPE_MEMORYCARD] = function()
			widgets.findMooncake:hide()
		end
	}
end

function wnd_waitToFind:onUpdate(dTime)	
end

function wnd_waitToFind:refresh(gameType)
	if gameType ~= nil and self._inteText[gameType] ~= nil then
		self._inteText[gameType]()
	end
end

function wnd_waitToFind:noMovement()
	g_i3k_ui_mgr:PopupTipMessage(i3k_get_string(16500))
end

function wnd_waitToFind:onHide()
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_FindMooncake, "countDown")
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_ProtectMelon, "startCountTime")
	g_i3k_ui_mgr:InvokeUIFunction(eUIID_MemoryCard, "startCountTime")
end

function wnd_create(layout)
	local wnd = wnd_waitToFind.new();
		wnd:create(layout);
	return wnd;
end
