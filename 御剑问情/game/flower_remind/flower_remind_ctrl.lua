require("game/flower_remind/flower_remind_view")

FlowerRemindCtrl = FlowerRemindCtrl or BaseClass(BaseController)

function FlowerRemindCtrl:__init()
	if nil ~= FlowerRemindCtrl.Instance then
		print_error("[FlowerRemindCtrl] Attemp to create a singleton twice !")
		return
	end
	FlowerRemindCtrl.Instance = self
	self.view = FlowerRemindView.New(ViewName.FlowerReMindView)
end

function  FlowerRemindCtrl:__delete()
	FlowerRemindCtrl.Instance = nil
	if self.view ~= nil then
		self.view:DeleteMe()
		self.view = nil
	end
end