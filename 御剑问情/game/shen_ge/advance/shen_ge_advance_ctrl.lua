require("game/shen_ge/advance/shen_ge_advance_data")
require("game/shen_ge/advance/shen_ge_advance_content")

ShenGeAdvanceCtrl = ShenGeAdvanceCtrl or BaseClass(BaseController)

function ShenGeAdvanceCtrl:__init()
	ShenGeAdvanceCtrl.Instance = self
	self.data = ShenGeAdvanceData.New()
	self:RegisterAllProtocols()
	self:BindGlobalEvent(OtherEventType.ROLE_LEVEL_UP, BindTool.Bind(self.OnRoleUp,self))
end

function ShenGeAdvanceCtrl:__delete()
	self.data:DeleteMe()
end

function ShenGeAdvanceCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCXuantuCuiLianInfo,"OnSCXuantuCuiLianInfo")	--	神格神躯所有信息
	self:RegisterProtocol(SCXuantuCuiLianAllInfo,"OnSCXuantuCuiLianAllInfo")	--	神格神躯单个信息	--	神格掌控单个信息
end

function ShenGeAdvanceCtrl:OnSCXuantuCuiLianInfo(protocol)
	self.data:UpdateCellByIndex(protocol)
	RemindManager.Instance:Fire(RemindName.ShenGe_Advance)
	ViewManager.Instance:FlushView(ViewName.ShenGeView,"FlushAttr",{index = protocol.grid_id})
end

function ShenGeAdvanceCtrl:OnSCXuantuCuiLianAllInfo(protocol)
	self.data:UpdateCellInfoList(protocol)
end

function ShenGeAdvanceCtrl:OnRoleUp()
	self.data:InitOpenList()
end