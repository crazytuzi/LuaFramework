local CWarriorReplaceHud = class("CWarriorReplaceHud", CAsyncHud)

function CWarriorReplaceHud.ctor(self, cb)
	CAsyncHud.ctor(self, "UI/Hud/WarriorReplaceHud.prefab", cb, true)
end

return CWarriorReplaceHud