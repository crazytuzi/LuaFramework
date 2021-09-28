--GuideScene.lua

require("app.cfg.newplay_guide_info")

local GuideScene = class("GuideScene", UFCCSBaseScene)

function GuideScene._guide_create_( step_id )
	return require("app.scenes.guide.GuideScene").new( step_id )
end

function GuideScene:ctor( step_id, ...  )
	self.super.ctor( self, step_id, ...)	
end

function GuideScene:onSceneLoad( step_id )
	if not step_id then
		return __LogError("invalid step_id")
	end

	--local guideInfo = newplay_guide_info.get(step_id)
	--if not guideInfo then
	--	return __LogError("invalid step_id:", step_id)
	--end

	--if guideInfo.text_id > 0 then
	--	uf_notifyLayer:getModelNode():addChild(require("app.scenes.dungeon.DungeonStoryTalkLayer").create(
	--		{storyId = guideInfo.text_id, func = callbackFunc }))
	--end
end

return GuideScene

