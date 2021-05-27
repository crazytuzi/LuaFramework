ShiMuSaoZhuFbLogic = ShiMuSaoZhuFbLogic or BaseClass(FbSceneLogic)

function ShiMuSaoZhuFbLogic:__init()
end

function ShiMuSaoZhuFbLogic:__delete()
end

function ShiMuSaoZhuFbLogic:Enter(old_scene_type, new_scene_type)
	FbSceneLogic.Enter(self, old_scene_type, new_scene_type)
	FubenCtrl.Instance:OpenShiMuSaoZhuView()
	self.toggle_handle = GlobalEventSystem:Bind(MainUIEventType.BOTTOMAREA_TOGGLE,BindTool.Bind(self.OnToggle,self))
end

function ShiMuSaoZhuFbLogic:Out()
	if self.toggle_handle then
		GlobalEventSystem:UnBind(self.toggle_handle)
		self.toggle_handle = nil
	end

	FbSceneLogic.Out(self)
	FubenCtrl.Instance:CloseShiMuSaoZhuView()
end

function ShiMuSaoZhuFbLogic:OnToggle(visible)
	if not visible then
		FubenCtrl.Instance:OpenShiMuSaoZhuView()
	else
		FubenCtrl.Instance:CloseShiMuSaoZhuView()
	end	
end
