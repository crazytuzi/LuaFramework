require("game/baoju/item_cell_reward")
require("game/baoju/baoju_view")

BaoJuCtrl = BaoJuCtrl or BaseClass(BaseController)

function BaoJuCtrl:__init()
	if BaoJuCtrl.Instance then
		print_error("[BaoJuCtrl]:Attempt to create singleton twice!")
		return
	end
	BaoJuCtrl.Instance = self

	self.baoju_view = BaoJuView.New(ViewName.BaoJu)
end

function BaoJuCtrl:__delete()
	self.baoju_view:DeleteMe()
	self.baoju_view = nil

	BaoJuCtrl.Instance = nil
end

function BaoJuCtrl:Flush()
	self.baoju_view:Flush()
end