local GUIFocusPoint={}

GUIFocusPoint.UIBtnTab = {}
GUIFocusPoint.ShowRed = {}

function GUIFocusPoint.addUIPoint(parent, callback ,moreEvent)

	local function btnCall(pSender,touch_type)
		if touch_type == ccui.TouchEventType.ended then
			if pSender:getName()=="panel_close" then
				GameMusic.play("music/30.mp3")
			else
				GameMusic.play("music/29.mp3")
			end
            callback(pSender,touch_type)
		end
		if moreEvent and touch_type ~= ccui.TouchEventType.ended then
			callback(pSender,touch_type)
		end
	end
	parent:addTouchEventListener(btnCall)
end

function GUIFocusPoint.IsNeedBright(parent,callback)
	for i=1,#GUIFocusPoint.ShowRed do
		local show_tab=GUIFocusPoint.ShowRed[i]
		for j=1,#show_tab do
			if show_tab[j] == parent:getName() then
				GUIFocusPoint.addUIPoint(parent,callback)
			end
		end
	end
end

function GUIFocusPoint.RemoveRed(name)
	for i=1,#GUIFocusPoint.ShowRed do
		local show_tab=GUIFocusPoint.ShowRed[i]
		if show_tab and name == show_tab[#show_tab] then
			table.remove(GUIFocusPoint.ShowRed,i)
		end
	end
end

return GUIFocusPoint