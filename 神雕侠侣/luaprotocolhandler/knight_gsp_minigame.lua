--require "protocoldef.knight.gsp.minigame.srspmoneytree"
local srspmoneytree_imp = require "protocoldef.knight.gsp.minigame.srspmoneytree"

function srspmoneytree_imp:process()
	print("enter srspmoneytree process")
	print("cd_time " .. self.cd_time)
	print("unpayremaintimes " .. self.unpayremaintimes)
	print("payremaintimes " .. self.payremaintimes)
	print("yuanbao " .. self.yuanbao)
	print("takemoneysuc" .. self.takemoneysuc)
	
	YaoQianShuEntrance.HandleSRspMoneyTree(self.cd_time, self.unpayremaintimes, self.payremaintimes, self.yuanbao, self.takemoneysuc)
end
