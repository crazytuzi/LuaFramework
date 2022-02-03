ForgeHouseModel = ForgeHouseModel or BaseClass()

function ForgeHouseModel:__init(ctrl)
    self.ctrl = ctrl
    self:config()
end

function ForgeHouseModel:config()
end

function ForgeHouseModel:setCompSendID(id)
	self.comp_send_id = id
end
function ForgeHouseModel:getCompSendID()
	return self.comp_send_id or nil
end
function ForgeHouseModel:__delete()
end