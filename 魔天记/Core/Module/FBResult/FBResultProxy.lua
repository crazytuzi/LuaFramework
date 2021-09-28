require "Core.Module.Pattern.Proxy"

FBResultProxy = Proxy:New();
function FBResultProxy:OnRegister()
	
end

function FBResultProxy:OnRemove()
	
end

function FBResultProxy.PlaySingleFbAgain()
	-- Todo 判断是否有次数能重新跳转
	GameSceneManager._0x0301ErrorHandler = FBResultProxy.PlaySingleFbAgainError;
	GameSceneManager._0x0302Handler = FBResultProxy.PlaySingleFbAgainClose;
	
	
	local fid = GameSceneManager.fid;
	if fid == nil then
		local obj = InstanceDataManager.GetInsByMapId(GameSceneManager.id);
		fid = obj.id;
	end
	
	 
   
	HeroController.GetInstance():StopAction(3)
	HeroController.GetInstance():Stand()
	GameSceneManager.GoToFB(GameSceneManager.fid)
end

function FBResultProxy.PlaySingleFbAgainError(data)
	--MsgUtils.ShowTips(nil, nil, nil, data.errMsg);
end

function FBResultProxy.PlaySingleFbAgainClose()
	
	ModuleManager.SendNotification(FBResultNotes.CLOSE_SINGLEFBWINRESULTPANEL);
	ModuleManager.SendNotification(FBResultNotes.CLOSE_SINGLEFBFAILRESULTPANEL);
end



function FBResultProxy.TryShowInstancePanel()
	ModuleManager.SendNotification(InstancePanelNotes.OPEN_INSTANCEPANEL);
end

function FBResultProxy.TryCloseAllPanel()
	
	ModuleManager.SendNotification(FBResultNotes.CLOSE_SINGLEFBWINRESULTPANEL);
	ModuleManager.SendNotification(FBResultNotes.CLOSE_SINGLEFBFAILRESULTPANEL);
	ModuleManager.SendNotification(FBResultNotes.CLOSE_TEAMFBWINRESULTPANEL);
	ModuleManager.SendNotification(FBResultNotes.CLOSE_TEAMFBFAILRESULTPANEL);
	ModuleManager.SendNotification(FBResultNotes.CLOSE_PVPFBWINPANEL);
	ModuleManager.SendNotification(FBResultNotes.CLOSE_PVPFBFAILRESULTPANEL);
	
end

function FBResultProxy.PlaySingleFbExit(oldScene, returnAfterHandler)
	
	
	local tem = ConfigManager.Clone(oldScene);
	
	FBResultProxy.TryCloseAllPanel();
	
	HeroController.GetInstance():StopAction(3)
	
	local toScene = {};
	toScene.sid = tem.sid;
	toScene.position = Convert.PointFromServer(tem.x, tem.y, tem.z);
	-- GameSceneManager.to = toScene;
    GameSceneManager.SetInitSceneCallBack(returnAfterHandler)
	GameSceneManager.GotoScene(toScene.sid,nil,toScene);
	
	
	
end 