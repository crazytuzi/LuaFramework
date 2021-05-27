require("scripts/game/carnival_activity/carnival_data")
require("scripts/game/carnival_activity/carnival_view")
require("scripts/game/carnival_activity/carnival_gold_boss_page")
require("scripts/game/carnival_activity/carnival_gold_lease_page")
require("scripts/game/carnival_activity/carnival_pool_page")
require("scripts/game/carnival_activity/carnival_rank_page")
require("scripts/game/carnival_activity/carnival_wellfare_page")
require("scripts/game/carnival_activity/carnival_rank")
CarnivarCtrl = CarnivarCtrl or BaseClass(BaseController)

function CarnivarCtrl:__init()
	if CarnivarCtrl.Instance then
		ErrorLog("[CarnivarCtrl] attempt to create singleton twice!")
		return
	end
	CarnivarCtrl.Instance = self

	self:CreateRelatedObjs()
	self:RegisterAllProtocols()

end

function CarnivarCtrl:__delete()
	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.rank_view then
		self.rank_view:DeleteMe()
		self.rank_view = nil
	end

	CarnivarCtrl.Instance = nil
end	

function CarnivarCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCCarnivalRankResult, "OnRankResult")
	self:RegisterProtocol(SCCarnivalPoolResult, "CarnivalPoolResult")
	self:RegisterProtocol(SCCarnivalBossResult, "CarnivalBossResult")
	self:RegisterProtocol(SCCarnivalLeaseResult,"CarnivalLeaseResult")
	self:RegisterProtocol(SCCarnivalWelfareResult,"CarnivalWelfareResult")  
	GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.RecvMainRoleInfo, self))
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.SuperMe)
end

function CarnivarCtrl:GetRemindNum(remind_name)
	if remind_name == RemindName.SuperMe then
		return self.data:RemindData()
	end
end

function CarnivarCtrl:CreateRelatedObjs()
	self.data = CarnivalData.New()
	self.view = CarnivalView.New(ViewName.Carnival)
	self.rank_view = CarnivalRankView.New(ViewName.CarnivalRank)
end

function CarnivarCtrl:RecvMainRoleInfo()
	for i=1,6 do
		if i == 1 then
			for k=1,6 do
				self:SendCarnivalData(i,k)
			end
		else
			self:SendCarnivalData(i,0)
		end
	end
end

function CarnivarCtrl:SendCarnivalData(activity_type,activity_index)
	local protocol = ProtocolPool.Instance:GetProtocol(CSCarnivalBaseInfo)
	protocol.activity_type = activity_type
	protocol.activity_index = activity_index
	protocol:EncodeAndSend()
end

function CarnivarCtrl:SendCarnivalPool(itemid)
	local protocol = ProtocolPool.Instance:GetProtocol(CSCarnivalToPool)
	protocol.itemid = itemid
	protocol:EncodeAndSend()
end

function CarnivarCtrl:SendCarnivalBoss()
	local protocol = ProtocolPool.Instance:GetProtocol(CSCarnivalFitBoss)
	protocol:EncodeAndSend()
end

function CarnivarCtrl:OnRankResult(protocol)
	self.data:setRankData(protocol)
	if ViewManager.Instance then
		ViewManager.Instance:FlushView(ViewName.MainUi, 0, "icon_pos")
	end
end

function CarnivarCtrl:CarnivalPoolResult(protocol)
	self.data:setPoolData(protocol)
	self.view:Flush(TabIndex.carnival_pool)
	RemindManager.Instance:DoRemind(RemindName.SuperMe)
	if ViewManager.Instance then
		ViewManager.Instance:FlushView(ViewName.MainUi, 0, "icon_pos")
	end
end

function CarnivarCtrl:CarnivalBossResult(protocol)
	self.data:setBossData(protocol)
	self.view:Flush(TabIndex.carnival_goldBoss)
	if ViewManager.Instance then
		ViewManager.Instance:FlushView(ViewName.MainUi, 0, "icon_pos")
	end
	GlobalEventSystem:Fire(HeroGoldEvent.CarnivalBoss,protocol)
end

function CarnivarCtrl:CarnivalLeaseResult(protocol)
	self.data:setCarnivaGoldLeaseInfo(protocol)
	self.view:Flush(TabIndex.carnival_goldLease)
	if ViewManager.Instance then
		ViewManager.Instance:FlushView(ViewName.MainUi, 0, "icon_pos")
	end
end

function CarnivarCtrl:CarnivalWelfareResult(protocol)
	self.data:setCarnivaWelfareInfo(protocol)
	self.view:Flush(TabIndex.carnival_returnWelfare)
	if ViewManager.Instance then
		ViewManager.Instance:FlushView(ViewName.MainUi, 0, "icon_pos")
	end
end

function CarnivarCtrl:SendCarnivalLease(itemid)
	local protocol = ProtocolPool.Instance:GetProtocol(CSCarnivalLeaseInfo)
	protocol.itemid = itemid
	protocol:EncodeAndSend()
end

