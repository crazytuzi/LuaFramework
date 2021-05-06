local CWarriorJiHuoHud = class("CWarriorJiHuoHud", CAsyncHud)

function CWarriorJiHuoHud.ctor(self, cb)
	CAsyncHud.ctor(self, "UI/Hud/WarriorJiHuoHud.prefab", cb, true)
end

function CWarriorJiHuoHud.OnCreateHud(self)
	
end


return CWarriorJiHuoHud