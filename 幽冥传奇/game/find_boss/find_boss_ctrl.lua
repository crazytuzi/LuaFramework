require("scripts/game/find_boss/find_boss_data")
require("scripts/game/find_boss/find_boss_view")

--------------------------------------------------------
-- 发现BOSS
--------------------------------------------------------

FindBossCtrl = FindBossCtrl or BaseClass(BaseController)

function FindBossCtrl:__init()
	if	FindBossCtrl.Instance then
		ErrorLog("[FindBossCtrl]:Attempt to create singleton twice!")
	end
	FindBossCtrl.Instance = self

	self.data = FindBossData.New()
	self.view = FindBossView.New(ViewDef.FindBoss)

	self:RegisterAllProtocols()
	self:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.OnRecvMainRoleInfo, self))
end

function FindBossCtrl:__delete()
	FindBossCtrl.Instance = nil

	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end


end

--登记所有协议
function FindBossCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCFindBossInfo, "OnFindBossInfo")
end

-- 上线请求数据
function FindBossCtrl:OnRecvMainRoleInfo()
	local level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL) -- 人物等级
	if level >= GameCond.CondId98.RoleLevel then
		-- FindBossCtrl.Instance:SendDiamondsCreateReq(1)
	end
end

----------接收----------

-- 接收发现boss信息 请求(139, 44)
function FindBossCtrl:OnFindBossInfo(protocol)
	self.data:SetData(protocol)
end

----------发送----------

-- 请求发现boss处理 返回(139, 55)
function FindBossCtrl:SendDiamondsCreateReq(type)
	local protocol = ProtocolPool.Instance:GetProtocol(CSFindBossReq)
	protocol.type = type -- 1获取信息, 2抽取boss, 3进入副本
	protocol:EncodeAndSend()
end

--------------------
