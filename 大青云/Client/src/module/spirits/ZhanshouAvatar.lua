--[[
灵兽：外观
liyuan
]]
_G.CZhanshouAvatar = {}
setmetatable(CZhanshouAvatar,{__index = CAvatar})

function CZhanshouAvatar:new(modelId)
	local cfg = t_lingshoumodel[modelId]

	local mesh = cfg.skn
	local skl = cfg.skl
	local san = cfg.follow_idle		
	local obj = CAvatar:new()
	
	obj.pickFlag = enPickFlag.EPF_Null
	obj.avtName = "lingshou"
    local sm = obj:SetPart("Body", mesh)
	obj:ChangeSkl(skl)
    obj:SetIdleAction(san, true)	
	
    setmetatable(obj, {__index = CZhanshouAvatar})
    return obj
end

function CZhanshouAvatar:DoAction(szFile, isLoop, callBack)
	if szFile then
		self:ExecAction(szFile, isLoop, callBack)
	end
end

function CZhanshouAvatar:ExitMap()
	self:ExitSceneMap()
	self:Destroy()
end;