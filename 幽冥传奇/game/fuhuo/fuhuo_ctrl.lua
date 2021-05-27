require("scripts/game/fuhuo/fuhuo_view")
require("scripts/game/fuhuo/fuhuo_nobtn_view")

-- 复活
FuhuoCtrl = FuhuoCtrl or BaseClass(BaseController)

function FuhuoCtrl:__init()
	if FuhuoCtrl.Instance ~= nil then
		ErrorLog("[FuhuoCtrl] attempt to create singleton twice!")
		return
	end
	FuhuoCtrl.Instance = self

	self.view = FuhuoView.New()
	self.nobtn_view = FuhuoNoBtnView.New()

	self:RegisterAllEvents()
end

function FuhuoCtrl:__delete()
	if nil ~= self.view then
		self.view:DeleteMe()
		self.view = nil
	end
	if nil ~= self.nobtn_view then
		self.nobtn_view:DeleteMe()
		self.nobtn_view = nil
	end
	FuhuoCtrl.Instance = nil
end

function FuhuoCtrl:RegisterAllEvents()
	self:BindGlobalEvent(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.OnLoadingComplete, self))
	self:RegisterProtocol(SCFuhuoAck, "OnFuhuoAck")
end

function FuhuoCtrl:OnFuhuoAck(protocol)
	self:Open()
	self:SetKillerName(protocol.killer_name)
end

-- --(0复活石, 1元宝复活, 2安全复活, 4原地复活)
function FuhuoCtrl.SendFuhuoReq(fuhuo_type)
	local protocol = ProtocolPool.Instance:GetProtocol(CSFuhuoReq)
	protocol.fuhuo_type = fuhuo_type
	protocol:EncodeAndSend()
end

function FuhuoCtrl:OnLoadingComplete()
	if RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_HP) <= 0 then
		self:Open()
	end
	RoleData.Instance:AddEventListener(OBJ_ATTR.CREATURE_HP, BindTool.Bind(self.OnMainRoleHpChange, self))
end

function FuhuoCtrl:Open()
	-- local fuben_id = FubenData.Instance:GetFubenId()
	-- if fuben_id > 0 and fuben_id <= 30 then 
	-- 	PracticeCtrl.Instance:ShowLosePanel(1, 10, function() 
	-- 		FuhuoCtrl.SendFuhuoReq(REALIVE_TYPE.REALIVE_TYPE_BACK_HOME)
	-- 		PracticeCtrl.SendEnterPractice(3)
	-- 	end)
	-- 	return 
	-- end
	local view = self:GetFuhuoView()
	view:Open()
end

-- 设置击杀者名字
function FuhuoCtrl:SetKillerName(killer_name)
	local view = self:GetFuhuoView()
	view:SetKillerName(killer_name)
end

function FuhuoCtrl:OnMainRoleRealive()
	if self.nobtn_view:IsOpen() then
		self.nobtn_view:FuhuoCallback()
	elseif self.view:IsOpen() then
		self.view:FuhuoCallback()
	end
end

function FuhuoCtrl:OnMainRoleHpChange(vo)
	if vo.old_value == 0 and vo.value > 0 then
		self:OnMainRoleRealive()
	elseif vo.old_value > 0 and vo.value <= 0 then
		-- self:Open()
	end
end

function FuhuoCtrl:GetFuhuoView()
	return self.view
end