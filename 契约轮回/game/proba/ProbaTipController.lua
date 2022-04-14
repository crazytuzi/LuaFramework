require('game.proba.RequireProbaTip')
ProbaTipController = ProbaTipController or class("ProbaTipController",BaseController)
local ProbaTipController = ProbaTipController

function ProbaTipController:ctor()
	ProbaTipController.Instance = self
	self.model = ProbaTipModel:GetInstance()
	self:AddEvents()
	self:RegisterAllProtocal()
end

function ProbaTipController:dctor()
end

function ProbaTipController:GetInstance()
	if not ProbaTipController.Instance then
		ProbaTipController.new()
	end
	return ProbaTipController.Instance
end

function ProbaTipController:RegisterAllProtocal(  )
	-- protobuff的模块名字，用到pb一定要写
	--self.pb_module_name = ""
    -- self:RegisterProtocal(35025, self.RequestLoginVerify)
end

function ProbaTipController:AddEvents()
	-- --请求基本信息
	-- local function ON_REQ_BASE_INFO()
		-- self:RequestLoginVerify()
	-- end
	-- self.model:AddListener(ProbaTipModel.REQ_BASE_INFO, ON_REQ_BASE_INFO)
end

-- overwrite
function ProbaTipController:GameStart()
	self.model:InitList()
end

----请求基本信息
--function LoginController:RequestLoginVerify()
	-- local pb = self:GetPbObject("m_login_verify_tos")
	-- self:WriteMsg(proto.LOGIN_VERIFY,pb)
--end

----服务的返回信息
--function ProbaTipController:HandleLoginVerify(  )
	-- local data = self:ReadMsg("m_login_verify_toc")
--end

