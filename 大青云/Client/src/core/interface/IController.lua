--
-- Created by IntelliJ IDEA.
-- User: Stefan
-- Date: 2014/7/17
-- Time: 18:23
-- entry point
--
_G.classlist['IController'] = 'IController'
_G.IController = {}
IController.objName = 'IController'
function IController:Create()
	self.name = "IController"
end

function IController:Destroy()
end

function IController:Update(dwInterval)
end

function IController:OnEnterGame()
end

--切换场景完成后的回调
function IController:OnChangeSceneMap()
end

--离开当前场景立即执行
function IController:OnLeaveSceneMap()

end

--场景失去焦点
function IController:OnSceneFocusOut()
	
end

function IController:sendNotification(name, body)
	Notifier:sendNotification(name, body);
end
