require("scripts/game/equipment/data/refine_data")

RefineCtrl = RefineCtrl or BaseClass(BaseController)
function RefineCtrl:__init()
	if RefineCtrl.Instance then
		ErrorLog("[RefineCtrl]:Attempt to create singleton twice!")
	end
	RefineCtrl.Instance = self
	self.data = RefineData.New()
end

function RefineCtrl:__delete()
	self.data:DeleteMe()
	self.data = nil
    RefineCtrl.Instance = nil
end

function RefineCtrl.SendEquipRefineReq(series, lock1, lock2, lock3)
    local protocol = ProtocolPool.Instance:GetProtocol(CSEquipRefineReq)
    protocol.series = series
    protocol.lock_1 = lock1 or 0
    protocol.lock_2 = lock2 or 0
    protocol.lock_3 = lock3 or 0
    protocol:EncodeAndSend()
end