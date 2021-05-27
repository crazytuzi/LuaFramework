------------------------------------------------------------
-- 试炼
------------------------------------------------------------

local TrialView = BaseClass(SubView)

function TrialView:__init()
	
	self.btn_info = {
		ViewDef.Experiment.Trial.TrialChild,
		-- ViewDef.Experiment.Trial,
	}
	
	require("scripts/game/experiment/trial_child_view").New(ViewDef.Experiment.Trial.TrialChild)
	require("scripts/game/experiment/trial_world_view").New(ViewDef.Experiment.Trial.TrialWorld)
end

function TrialView:__delete()
end

function TrialView:ReleaseCallBack()

end

function TrialView:LoadCallBack(index, loaded_times)

end

--显示索引回调
function TrialView:ShowIndexCallBack(index)

end

----------视图函数----------

----------end----------

--------------------


return TrialView