--[[
跨服场景任务2
]]

_G.UIInterSSQuestTwo= UIInterSSQuest:new("UIInterSSQuestTwo");


function UIInterSSQuestTwo:Create()
	self:AddSWF("interSerSceneQuestList.swf", true, "interserver");
end;


function UIInterSSQuestTwo:ESCHide()
	return true;
end;
