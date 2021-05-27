require("scripts/game/qiege/qiege_data")
require("scripts/game/qiege/qiege_view")
require("scripts/game/qiege/shenbin_upgrade_panel")
require("scripts/game/qiege/qiege_tip_view")
require("scripts/game/qiege/qiege_skill_tip_view")
QieGeCtrl = QieGeCtrl or BaseClass(BaseController)
function QieGeCtrl:__init()
	if	QieGeCtrl.Instance then
		ErrorLog("[QieGeCtrl]:Attempt to create singleton twice!")
	end
	QieGeCtrl.Instance = self
	self.qiege_data =QieGeData.New()
	self.qiege_view = QieGeView.New(ViewDef.QieGeView)
	self.qiege_tip_view = QieGeTipView.New(ViewDef.QieGeTipView)
	self.qiege_skill_tip_view = QiegeSkillTipView.New(ViewDef.QieGeSkillView)
	self.index = 0
	self:RegisterAllProtocols()
end

function QieGeCtrl:__delete( ... )
	if self.qiege_data then
		self.qiege_data:DeleteMe()
		self.qiege_data = nil
	end

	if self.qiege_view then
		self.qiege_view:DeleteMe()
		self.qiege_view = nil
	end
	if self.shenbin_upgrade_panel then
		self.shenbin_upgrade_panel:DeleteMe()
		self.shenbin_upgrade_panel = nil
	end
	if self.qiege_tip_view then
		self.qiege_tip_view:DeleteMe()
		self.qiege_tip_view = nil
	end
	if self.qiege_skill_tip_view then
		self.qiege_skill_tip_view:DeleteMe()
		self.qiege_skill_tip_view = nil
	end
	if self.delay_timer then
		GlobalTimerQuest:CancelQuest(self.delay_timer)
		self.delay_timer = nil
	end
	if self.delay_timer2 then
		GlobalTimerQuest:CancelQuest(self.delay_timer2)
		self.delay_timer2 = nil
	end
end

function QieGeCtrl:RegisterAllProtocols(  )
	-- 所有数据

	self:RegisterProtocol(SCAllQieGeData, "OnAllQieGeData")
	--切割升级结果
	self:RegisterProtocol(SCUpgradeQieGeResult, "OnUpgradeQieGeResult")

	--切割神兵的所有数据
	self:RegisterProtocol(SCQieGeShenBinData, "OnQieGeShenBinData")

	--升级切割神兵结果

	self:RegisterProtocol(SCUpgradeQieGeShenbinResult, "OnUpgradeQieGeShenbinResult")

	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.ShenBin)
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.QieGe)
	EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.RoleDataChangeCallback, self))
	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.ItemDataListChangeCallback, self))
end


function QieGeCtrl:OnAllQieGeData(protocol)
	self.index = 1 -- 切割数据下发
	self.qiege_data:SetAllQieGeData(protocol)
	RemindManager.Instance:DoRemind(RemindName.QieGe)
	RemindManager.Instance:DoRemind(RemindName.ShenBin)
end

function QieGeCtrl:OnUpgradeQieGeResult(protocol)
	self.qiege_data:SetQieGeResult(protocol)
	RemindManager.Instance:DoRemind(RemindName.ShenBin)
	RemindManager.Instance:DoRemind(RemindName.QieGe)
	local config = self.qiege_data:GetUpGradeConfigLevel(protocol.qiege_level)
	if config then
		if config.virtualItemId then
			ViewManager.Instance:OpenViewByDef(ViewDef.QieGeTipView)
		end
	end
end


function QieGeCtrl:OnQieGeShenBinData(protocol)
	self.qiege_data:SetQieGeShenBinData(protocol)
	RemindManager.Instance:DoRemind(RemindName.ShenBin)
end

function QieGeCtrl:OnUpgradeQieGeShenbinResult(protocol)
	self.qiege_data:SetUpgradeQieGeShenbinResult(protocol)

	RemindManager.Instance:DoRemind(RemindName.ShenBin)
end

--切割升级
function QieGeCtrl:SendQieGeUpgradeReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSQieGeUpgrade)
	protocol:EncodeAndSend()
end

--领取切割效果
function QieGeCtrl:SendGetQieGeReweardReq(index)
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetQieGeReweard)
	protocol.index = index
	protocol:EncodeAndSend()
end

--领取任务奖励
function QieGeCtrl:SendGetTaskReward(index)
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetTaskReward)
	protocol.index = index
	protocol:EncodeAndSend()

end

--升级神兵请求
function QieGeCtrl:SendQieGeShenBinUpgradeReq(index)
	local protocol = ProtocolPool.Instance:GetProtocol(CSQieGeShenBinUpgrade)
	protocol.index = index
	protocol:EncodeAndSend()
end

--请求切割数据
function QieGeCtrl:ReqQieGeData()
	local protocol = ProtocolPool.Instance:GetProtocol(CSReqQieGeData)
	protocol:EncodeAndSend()
end

function QieGeCtrl:OpenUpgradeView(data)
	self.shenbin_upgrade_panel  = self.shenbin_upgrade_panel or ShenBinUpgradePanel.New(ViewDef.QieGeUpgrade)
	self.shenbin_upgrade_panel:Open()
	self.shenbin_upgrade_panel:SetWeaponData(data)
end

function QieGeCtrl:OpenSkillTipView(data)
	if self.qiege_skill_tip_view  then
		self.qiege_skill_tip_view:Open()
		self.qiege_skill_tip_view:SetQieGeTipData(data)
	end
end


function QieGeCtrl:GetRemindNum(remind_name)
	if remind_name == RemindName.ShenBin then
		return QieGeData.Instance:GetShenBinCanUp() and 1 or 0
	elseif remind_name == RemindName.QieGe then
		return QieGeData.Instance:GetAllCanup() and 1 or 0
	end
end

function QieGeCtrl:ItemDataListChangeCallback( ... )
	if self.delay_timer2 then
		GlobalTimerQuest:CancelQuest(self.delay_timer2)
		self.delay_timer2 = nil
	end
	
	self.delay_timer2 = GlobalTimerQuest:AddDelayTimer(function ( ... )
			RemindManager.Instance:DoRemindDelayTime(RemindName.BagCompose)
			if self.delay_timer2 then
				GlobalTimerQuest:CancelQuest(self.delay_timer2)
				self.delay_timer2 = nil
			end
			RemindManager.Instance:DoRemind(RemindName.QieGe)
			RemindManager.Instance:DoRemind(RemindName.ShenBin)
	end, 0.5)
end

function QieGeCtrl:RoleDataChangeCallback(vo)
	if vo.key == OBJ_ATTR.CREATURE_LEVEL then
		if self.index == 0 then	--如果没有下发过切割数据，且在线升级的情况
			
			if self.delay_timer then
				GlobalTimerQuest:CancelQuest(self.delay_timer)
				self.delay_timer = nil
			end
		self.delay_timer = GlobalTimerQuest:AddDelayTimer(function ( ... )
				if ViewManager.Instance:CanOpen(ViewDef.QieGeView) then
					self:ReqQieGeData()
				end
				if self.delay_timer then
					GlobalTimerQuest:CancelQuest(self.delay_timer)
					self.delay_timer = nil
				end
		end, 2)
		end
		RemindManager.Instance:DoRemind(RemindName.QieGe)
	end
end
