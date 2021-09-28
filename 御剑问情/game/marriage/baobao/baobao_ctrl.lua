require("game/marriage/baobao/baobao_data")
require("game/marriage/baobao/marry_baobao_view")
require("game/marriage/baobao/super_baobao_view")
--------------------------------------------------------------
--宝宝
--------------------------------------------------------------
BaobaoCtrl = BaobaoCtrl or BaseClass(BaseController)

function BaobaoCtrl:__init()
	if BaobaoCtrl.Instance then
		print_error("[BaobaoCtrl] Attemp to create a singleton twice !")
	end
	BaobaoCtrl.Instance = self
	self.data = BaobaoData.New()
	self.view = MarryBaoBaoView.New(ViewName.MarryBaby)
	self.super_baobao_view = SuperBaoBaoView.New(ViewName.SuperBaoBaoView)
	self:RegisterAllProtocols()
end

function BaobaoCtrl:__delete()
	self.data:DeleteMe()
	self.data = nil
	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.super_baobao_view then
		self.super_baobao_view:DeleteMe()
		self.super_baobao_view = nil
	end
	BaobaoCtrl.Instance = nil
end

function BaobaoCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCBabyInfo, "OnBabyInfo")
	self:RegisterProtocol(SCBabyAllInfo, "OnBabyAllInfo")
	self:RegisterProtocol(SCBabyBornRoute, "OnBabyBornRoute")
	self:RegisterProtocol(SCBabySpiritInfo, "OnBabySpiritInfo")
	self:RegisterProtocol(CSSupBabyRenameReq)
	self:RegisterProtocol(SCSupBabyInfo, "OnSupBabyInfo")
	self:RegisterProtocol(SCSupBabyViewBroadcast, "OnSupBabyViewBroadcast")
	self:RegisterProtocol(SCSupBabyAwardFlag, "OnSupBabyAwardFlag")
end

-- 请求单个宝宝信息  参数1 宝宝ID
function BaobaoCtrl.SendOneBabyInfoReq(param_1, param_2, param_3)
	BaobaoCtrl.SendBabyOperaReq(BABY_REQ_TYPE.BABY_REQ_TYPE_INFO, param_1, param_2, param_3)
end

-- 请求所有宝宝信息
function BaobaoCtrl.SendAllBabyInfoReq(param_1, param_2, param_3)
	BaobaoCtrl.SendBabyOperaReq(BABY_REQ_TYPE.BABY_REQ_TYPE_ALL_INFO, param_1, param_2, param_3)
end

-- 升级请求	参数1 宝宝ID
function BaobaoCtrl.SendUpBabyReq(param_1, param_2, param_3)
	BaobaoCtrl.SendBabyOperaReq(BABY_REQ_TYPE.BABY_REQ_TYPE_UPLEVEL, param_1, param_2, param_3)
end

-- 祈福请求 参数1 祈福类型
function BaobaoCtrl.SendBabyBlessReq(param_1, param_2, param_3)
	BaobaoCtrl.SendBabyOperaReq(BABY_REQ_TYPE.BABY_REQ_TYPE_QIFU, param_1, param_2, param_3)
end

-- 祈福答应请求 参数1 祈福类型，参数2 是否接受
function BaobaoCtrl.SendBabyBlessReply(param_1, param_2, param_3)
	BaobaoCtrl.SendBabyOperaReq(BABY_REQ_TYPE.BABY_REQ_TYPE_QIFU_RET, param_1, param_2, param_3)
end

-- 宝宝超生
function BaobaoCtrl.SendBabyChaoshengReq(param_1, param_2, param_3)
	BaobaoCtrl.SendBabyOperaReq(BABY_REQ_TYPE.BABY_REQ_TYPE_CHAOSHENG, param_1, param_2, param_3)
end

-- 请求单个宝宝的守护精灵的信息，发baby_index
function BaobaoCtrl.SendOneBabySpiritInfoReq(param_1, param_2, param_3)
	BaobaoCtrl.SendBabyOperaReq(BABY_REQ_TYPE.BABY_REQ_TYPE_SPIRIT_INFO, param_1, param_2, param_3)
end

-- 培育精灵请求，发baby_index(param1)，spirit_id（param2, 从0开始，0-3）
function BaobaoCtrl.SendBabyTrainSpiritReq(param_1, param_2, param_3,param_0)
	BaobaoCtrl.SendBabyOperaReq(BABY_REQ_TYPE.BABY_REQ_TYPE_TRAIN_SPIRIT, param_1, param_2, param_3,param_0)
end

-- 遗弃宝宝请求
function BaobaoCtrl.SendRemoveBabyReq(param_1, param_2, param_3)
	BaobaoCtrl.SendBabyOperaReq(BABY_REQ_TYPE.BABY_REQ_TYPE_REMOVE_BABY, param_1, param_2, param_3)
end

-- 协议请求
function BaobaoCtrl.SendBabyOperaReq(opera_type, param_1, param_2, param_3, param_0)
	local protocol = ProtocolPool.Instance:GetProtocol(CSBabyOperaReq)
	protocol.opera_type = opera_type
	protocol.param_1 = param_1 or 0
	protocol.param_2 = param_2 or 0
	protocol.param_3 = param_3 or 0
	protocol.param_0 = param_0 or 0                      -- 新加字段发包数
	protocol:EncodeAndSend()
end

-- 请求改名
function BaobaoCtrl:SendBabyRenameReq(baby_index, newname)
	local protocol = ProtocolPool.Instance:GetProtocol(CSBabyRenameReq)
	protocol.baby_index = baby_index or 0
	protocol.newname = newname or ""
	protocol:EncodeAndSend()
end

function BaobaoCtrl:OpenRenameView()
	self.rename_view:Open()
end

function BaobaoCtrl:OpenTotalTipView(data)
	self.total_tip_view:SetData(data)
end

function BaobaoCtrl:OnBabyInfo(protocol)
	self.data:SetBabyInfo(protocol)
	self.view:Flush()
	RemindManager.Instance:Fire(RemindName.MarryBaoBaoAttr)
	RemindManager.Instance:Fire(RemindName.MarryBaoBaoZiZhi)
	RemindManager.Instance:Fire(RemindName.MarryBaoBaoGuard)
end

function BaobaoCtrl:OnBabyAllInfo(protocol)
	self.data:SetBabyAllInfo(protocol)
	self.view:Flush()
	if self.super_baobao_view:IsOpen() then
		self.super_baobao_view:Flush()
	end

	RemindManager.Instance:Fire(RemindName.MarryBaoBaoAttr)
	RemindManager.Instance:Fire(RemindName.MarryBaoBaoZiZhi)
	RemindManager.Instance:Fire(RemindName.MarryBaoBaoGuard)
end

function BaobaoCtrl:OnBabySpiritInfo(protocol)
	self.data:SetBabySpiritInfo(protocol)
	self.view:Flush()
	RemindManager.Instance:Fire(RemindName.MarryBaoBaoGuard)
end

function BaobaoCtrl:SendBabyBlessRet(bless_type, is_ok)
	BaobaoCtrl.SendBabyBlessReply(bless_type, is_ok)
end

function BaobaoCtrl:OnBabyBornRoute(protocol)
	if protocol.type ~= nil then
		local func = function()
			BossCtrl.SendEnterBossFamily(BOSS_ENTER_TYPE.LEAVE_BOSS_SCENE)
		end
		local no_func = function()
			BossCtrl.SendEnterBossFamily(BOSS_ENTER_TYPE.LEAVE_BOSS_SCENE)
		end
		local baobao_cfg = self.data:GetBabyInfoCfg(protocol.type - 1)
		TipsCtrl.Instance:ShowCommonTip(BindTool.Bind3(self.SendBabyBlessRet, self, protocol.type, 1), nil,
			string.format(Language.Marriage.BabyBornAlert, PlayerData.Instance.role_vo.lover_name or "",
			baobao_cfg and ToColorStr(baobao_cfg.name or "",BAOBAO_COLOR[protocol.type])), nil, BindTool.Bind3(self.SendBabyBlessRet, self, protocol.type, 0), false)
	end
end

-- 宝宝进阶结果返回
function BaobaoCtrl:OnBabyUpgradeResult(result,index)
	ViewManager.Instance:FlushView(ViewName.MarryBaby)
end

-- 宝宝升阶请求
function BaobaoCtrl:SendBabyUpgradeReq(baby_index, auto_buy, is_one_key)
	local protocol = ProtocolPool.Instance:GetProtocol(CSBabyUpgradeReq)
	protocol.auto_buy = auto_buy
	protocol.is_auto_upgrade = is_one_key
	if 1 == protocol.auto_buy and is_one_key then
		local baby_list = self.data:GetListBabyData()
		if nil == baby_list or nil == baby_index or nil == next(baby_list) then return end

		local grade = 1
		for k,v in pairs(baby_list) do
			if v.baby_index == baby_index then
				grade = v.grade
			end
		end
		protocol.baby_index = baby_index or 0
		protocol.repeat_times = self.data:GetBabyUpgradeCfg(grade) and self.data:GetBabyUpgradeCfg(grade).pack_num or 1
	else
		protocol.baby_index = baby_index or 0
		protocol.repeat_times = 1
	end
	protocol:EncodeAndSend()
end

function BaobaoCtrl:OnOperateResult(result,index)
	-- if self.view then
	-- 	if self.view.guard_view then
	-- 		self.view.guard_view:OnOperateResult()
	-- 	end
	-- end
end

function BaobaoCtrl:FlushImageViewRed()
	self.view:FlushImageView()
end

function BaobaoCtrl:ResetValue()
    self.view:ResetValue()
end

function BaobaoCtrl:OnSupBabyInfo(protocol)
	self.data:SetSuperBabyInfo(protocol.super_baby_info)
	if self.view:IsOpen() then
		self.view:Flush("special")
	end

	if self.super_baobao_view:IsOpen() then
		self.super_baobao_view:Flush()
	end
end

function BaobaoCtrl:OnSupBabyViewBroadcast(protocol)
	local obj = Scene.Instance:GetRoleByObjId(protocol.role_obj_id)
	if obj ~= nil then
		local super_baby_info = protocol.super_baby_info
		if super_baby_info.fight_flag == 1 then
			obj:SetAttr("sup_baby_id", super_baby_info.baby_id)
			obj:SetAttr("sup_baby_name", super_baby_info.baby_name)
		else
			obj:SetAttr("sup_baby_id", -1)
			obj:SetAttr("sup_baby_name", "")
		end
	end
end

function BaobaoCtrl:OnSupBabyAwardFlag(protocol)
	self.data:SetAwardFlag(protocol)

	if self.view:IsOpen() then
		self.view:Flush("special")
	end

	if self.super_baobao_view:IsOpen() then
		self.super_baobao_view:Flush()
	end

	RemindManager.Instance:Fire(RemindName.MarryBaoBaoAttr)
end

function BaobaoCtrl:ReqSupBabyRename(new_name)
	local protocol = ProtocolPool.Instance:GetProtocol(CSSupBabyRenameReq)
	protocol.new_name = new_name or ""
	protocol:EncodeAndSend()
end