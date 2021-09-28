require("game/marry_gift/backqingyuangift_view")
require("game/marry_gift/marry_gift_view")
require("game/marry_gift/marry_gift_data")

MarryGiftCtrl = MarryGiftCtrl or BaseClass(BaseController)

function MarryGiftCtrl:__init()
	if MarryGiftCtrl.Instance ~= nil then
		print_error("[MarryGiftCtrl] attempt to create singleton twice!")
		return
	end

	MarryGiftCtrl.Instance = self
	self:RegisterAllProtocols()

	self.view = MarryGiftView.New(ViewName.MarryGift)
	self.data = MarryGiftData.New()
	self.back_gift_view = BackQingYuanGiftView.New(ViewName.BackQingYuanGiftView)
end

function MarryGiftCtrl:__delete()
	MarryGiftCtrl.Instance = nil
	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end
	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end
	if self.back_gift_view then
		self.back_gift_view:DeleteMe()
		self.back_gift_view = nil
	end
	self:ClearCheckRoleInfo()
end

function MarryGiftCtrl:RegisterAllProtocols()
	---------------情缘限时礼包------------------
	self:RegisterProtocol(SCQingyuanTimeLimitInfo, "OnQingyuanTimeLimitInfo")
	self:RegisterProtocol(SCQingyuanTimeLimitGiftRemindInfo, "OnQingyuanTimeLimitGiftRemindInfo")
end

function MarryGiftCtrl:RoleInfo(role_id, protocol)
    if role_id == self.from_uid then
        self.from_uid = 0
        self:ClearCheckRoleInfo()
        self.back_gift_view:SetRoleInfotable(protocol)
        self.back_gift_view:Open()
    end
end

function MarryGiftCtrl:ClearCheckRoleInfo()
    if self.role_info then
        GlobalEventSystem:UnBind(self.role_info)
        self.role_info = nil
    end
end

----------------------限时情缘礼包-----------------

--限时礼包信息
function MarryGiftCtrl:OnQingyuanTimeLimitInfo(protocol)
	self.data:SetCurPurchasedSeq(protocol)
	self.view:Flush()
	ViewManager.Instance:FlushView(ViewName.Marriage, "marry_gift")
	RemindManager.Instance:Fire(RemindName.MarryGift)
end

--限时礼包购买通知
function MarryGiftCtrl:OnQingyuanTimeLimitGiftRemindInfo(protocol)
	self.data:SetGiftRemindInfo(protocol)
    if protocol.is_open_panel == 1 then
    	self:OpenBackGiftView()
    end
    RemindManager.Instance:Fire(RemindName.MarryGiftBack)
end

function MarryGiftCtrl:OpenBackGiftView()
	MarryGiftData.HAS_NEW_REMIND = false
   	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	local lover_id = main_role_vo.lover_uid
	self.from_uid = lover_id
    self.role_info = GlobalEventSystem:Bind(OtherEventType.RoleInfo, BindTool.Bind(self.RoleInfo, self))
    CheckCtrl.Instance:SendQueryRoleInfoReq(lover_id)
end