require("game/serveractivity/collective_goals/collective_goals_data")
require("game/serveractivity/collective_goals/collective_goals_view")

CollectiveGoalsCtrl = CollectiveGoalsCtrl or BaseClass(BaseController)

function CollectiveGoalsCtrl:__init()
	if CollectiveGoalsCtrl.Instance then
		print_error("[CollectiveGoalsCtrl]:Attempt to create singleton twice!")
	end
	CollectiveGoalsCtrl.Instance = self

	-- self.view = CollectiveGoalsView.New(ViewName.CollectGoals)
	self.data = CollectiveGoalsData.New()
end

function CollectiveGoalsCtrl:__delete()
	self.data:DeleteMe()
	self.data = nil

	CollectiveGoalsCtrl.Instance = nil
end