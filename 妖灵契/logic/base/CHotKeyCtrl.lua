local CHotKeyCtrl = class("CHotKeyCtrl")

function CHotKeyCtrl.ctor(self)
	if not C_api.HotkeyHandler.Instance then
		return
	end
	C_api.HotkeyHandler.Instance:SetKeyUpCallback(callback(self, "OnKey", false))
	C_api.HotkeyHandler.Instance:SetKeyDownCallback(callback(self, "OnKey", true))
	self.m_Key2Name = {}
	for k, v in pairs(data.hotkeydata.SINGLE) do
		local iKey = enum.KeyCode[k]
		self.m_Key2Name[iKey] = k
		C_api.HotkeyHandler.Instance:AddHotKey(iKey)
	end

	for k1, v in pairs(data.hotkeydata.MULTI) do

		for k2, _ in pairs(v) do

		end
	end
end

function CHotKeyCtrl.OnKey(self, bDown,keys)
	local len = keys.Count
	if len == 1 then
		local iKey = keys[0]
		local sName = self.m_Key2Name[iKey]
		local sFuncName = data.hotkeydata.SINGLE[sName]
		local func = self[sFuncName]
		if func then
			func(self, bDown)
		end
	end
end

--单键的回调
function CHotKeyCtrl.OnSingle(self, bDown)
	if bDown then
	end
end

function CHotKeyCtrl.OnEscape(self, bDown)
	if bDown then
		Utils.QuitGame()
	end
end
--组合键的回调

return CHotKeyCtrl