local p = require "protocoldef.knight.gsp.specialquest.saddexpafterfinishtzquest1"
function p:process()
	require "ui.arttextmanager"(self.addexpnum)
end

local p = require "protocoldef.knight.gsp.specialquest.schoosetianyapets"
function p:process()
--	local PetPropertyDlg = require "ui.pet.petpropertydlg"
--	PetPropertyDlg.getInstanceAndShow():Init(PetPropertyDlg.SUBMIT)
end
