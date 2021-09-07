require("game/guide/guide_config")
require("game/guide/function_guide")
require("game/guide/normal_guide_view")
require("game/guide/girl_guide_view")
require("game/guide/fun_gesture_view")

-- 引导
GuideCtrl = GuideCtrl or BaseClass(BaseController)

function GuideCtrl:__init()
	if GuideCtrl.Instance ~= nil then
		ErrorLog("[GuideCtrl] attempt to create singleton twice!")
		return
	end
	GuideCtrl.Instance = self

	self.function_guide = FunctionGuide.New()
end

function GuideCtrl:__delete()
	GuideCtrl.Instance = nil

	self.function_guide:DeleteMe()
	self.function_guide = nil
end