BaseScene=classGc(view,function(self)

end)

function BaseScene.loadResources(self,sceneId,filelist)
	ScenesManger.loadScene(self,sceneId,filelist,ScenesManger.sceneResType)
end

function BaseScene.show(self,sceneId)
	local theScene = self:scene()
	cc.Director:getInstance():popToRootScene()

	if sceneId == _G.Cfg.UI_SelectSeverScene then
    	cc.Director:getInstance():replaceScene(CCTransitionFade:create(1.2, theScene))
    else
    	cc.Director:getInstance():replaceScene(theScene)
    end
end

BaseLayer = classGc(view,function(self)
	
end)

function BaseLayer.loadResources(self,sceneId,filelist)
	ScenesManger.loadScene(self,sceneId,filelist,ScenesManger.layerResType)
end

function BaseLayer.show(self,sceneId)
	local layer =self:layer()
	local runningScene = cc.Director:getInstance():getRunningScene()
    runningScene:addChild(layer,_G.Const.CONST_MAP_ZORDER_LAYER)
end
