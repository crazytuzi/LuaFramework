--[[
帮派副本controller
2015年1月8日14:34:38
haohu
]]

_G.UnionDungeonController = setmetatable({}, {__index = IController});
UnionDungeonController.name = "UnionController";

function UnionDungeonController:Create()

end

function UnionDungeonController:OnEnterGame()
	UnionDungeonModel:Init()
end

