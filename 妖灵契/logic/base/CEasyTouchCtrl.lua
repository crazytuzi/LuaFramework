local CEasyTouchCtrl = class("CEasyTouchCtrl")

CEasyTouchCtrl.EventType = {
	TouchDown = 1,
	TouchUp = 2,
	Swipe = 3,
	LongTabStart = 4,
	SwipeStart2Finger = 5,
	Swipe2Finger = 6,
	SwipeEnd2Finger = 7,
	Pinch = 8,
	TouchStart = 9,
	Cancel = 10,
	-- UIElementTouchUp = 11,
	SwipeStart = 12,
	SwipeEnd = 13,
}

CEasyTouchCtrl.EventFunc = {
	[CEasyTouchCtrl.EventType.TouchDown] = "OnTouchDown",
	[CEasyTouchCtrl.EventType.TouchUp] = "OnTouchUp",
	[CEasyTouchCtrl.EventType.Swipe] = "OnSwipe",
	[CEasyTouchCtrl.EventType.LongTabStart] = "OnLongTabStart",
	[CEasyTouchCtrl.EventType.SwipeStart2Finger] = "OnSwipeStart2Finger",
	[CEasyTouchCtrl.EventType.Swipe2Finger] = "OnSwipe2Finger",
	[CEasyTouchCtrl.EventType.SwipeEnd2Finger] = "OnSwipeEnd2Finger",
	[CEasyTouchCtrl.EventType.Pinch] = "OnPinch",
	[CEasyTouchCtrl.EventType.TouchStart] = "OnTouchStart",
	[CEasyTouchCtrl.EventType.Cancel] = "OnCacel",
	-- [CEasyTouchCtrl.EventType.UIElementTouchUp] = "OnOverUIElement",
	[CEasyTouchCtrl.EventType.SwipeStart] = "OnSwipeStart",
	[CEasyTouchCtrl.EventType.SwipeEnd] = "OnSwipeEnd",
}

function CEasyTouchCtrl.ctor(self)
	self.m_Toucher = {}
end

function CEasyTouchCtrl.InitCtrl(self)
	C_api.EasyTouchHandler.AddCamera(g_CameraCtrl:GetMainCamera().m_Camera, false)
	C_api.EasyTouchHandler.AddCamera(g_CameraCtrl:GetWarCamera().m_Camera, false)
	C_api.EasyTouchHandler.AddCamera(g_CameraCtrl:GetHouseCamera().m_Camera, false)
	C_api.EasyTouchHandler.SetCallback(callback(self, "OnTouchEvent"))

	g_EasyTouchCtrl:AddTouch("maptouch", g_MapTouchCtrl)
	g_EasyTouchCtrl:AddTouch("wartouch", g_WarTouchCtrl)
	g_EasyTouchCtrl:AddTouch("housetouch", g_HouseTouchCtrl)
	g_EasyTouchCtrl:AddTouch("guidetouch", g_GuideCtrl)
end

function CEasyTouchCtrl.ResetCtrl(self)
	self.m_Toucher = {}
end

function CEasyTouchCtrl.AddTouch(self, skey, dispatchobj)
	self.m_Toucher[skey] = dispatchobj
end

function CEasyTouchCtrl.DelTouch(self, skey)
	self.m_Toucher[skey] = nil
end

function CEasyTouchCtrl.GetTouchCount(self)
	return C_api.EasyTouchHandler.GetTouchCount()
end


function CEasyTouchCtrl.OnTouchEvent(self, eventType, ...)
	local func = CEasyTouchCtrl.EventFunc[eventType]
	if func then
		for _, v in pairs(self.m_Toucher) do
			if v and v[func] then
				v[func](v, ...)
			end
		end
	end
end

return CEasyTouchCtrl