require("game/shenqi/shenqi_data")
require("game/shenqi/shenqi_view")
require("game/shenqi/tip_shenqi_view")

local SHENQI_TEXT_FLOATING_X = 450
local SHENQI_TEXT_FLOATING_Y = -170
local SHENQI_PIC_FLOATING_X = 0
local SHENQI_PIC_FLOATING_Y = 0

ShenqiCtrl = ShenqiCtrl or BaseClass(BaseController)

function ShenqiCtrl:__init()
	if ShenqiCtrl.Instance ~= nil then
		print_error("[ShenqiCtrl]error:create a singleton twice")
		return
	end
	ShenqiCtrl.Instance = self

	self.data = ShenqiData.New()
	self.view = ShenqiView.New(ViewName.Shenqi)					-- 神器面板
	self.tip_shenqi_view = TipShenQiView.New(ViewName.TipShenQiView)
	
	self:RegisterAllProtocols()

	RemindManager.Instance:Register(RemindName.ShenBingXiangQian, BindTool.Bind(self.GetGemChangeRemind, self, RemindName.ShenBingXiangQian))
	RemindManager.Instance:Register(RemindName.BaoJiaXiangQian, BindTool.Bind(self.GetGemChangeRemind, self, RemindName.BaoJiaXiangQian))
	RemindManager.Instance:Register(RemindName.ShenBingJianLing, BindTool.Bind(self.GetGemChangeRemind, self, RemindName.ShenBingJianLing))
	RemindManager.Instance:Register(RemindName.BaoJiaQiLing, BindTool.Bind(self.GetGemChangeRemind, self, RemindName.BaoJiaQiLing))
end

function ShenqiCtrl:__delete()
	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.floating_view then
		self.floating_view:DeleteMe()
		self.floating_view = nil
	end

	if self.tip_shenqi_view ~= nil then
		self.tip_shenqi_view:DeleteMe()
		self.tip_shenqi_view = nil
	end

	RemindManager.Instance:UnRegister(RemindName.ShenBingXiangQian)
	RemindManager.Instance:UnRegister(RemindName.BaoJiaXiangQian)
	RemindManager.Instance:UnRegister(RemindName.ShenBingJianLing)
	RemindManager.Instance:UnRegister(RemindName.BaoJiaQiLing)

	ShenqiCtrl.Instance = nil
end

function ShenqiCtrl:RegisterAllProtocols()
	self:RegisterProtocol(CSShenqiOperaReq)
	self:RegisterProtocol(SCShenqiAllInfo, "OnShenqiAllInfo")
	self:RegisterProtocol(SCShenqiSingleInfo, "OnShenqiSingleInfo")
	self:RegisterProtocol(SCShenqiImageInfo, "OnShenqiImageInfo")
	self:RegisterProtocol(SCShenqiDecomposeResult, "OnShenqiDecomposeResult")
end

-- 请求神器所有信息
function ShenqiCtrl:SendReqShenqiAllInfo(opera_type, param_1, param_2, param_3)
	local protocol_send = ProtocolPool.Instance:GetProtocol(CSShenqiOperaReq)
	protocol_send.opera_type = opera_type or 0
	protocol_send.param_1 = param_1 or 0
	protocol_send.param_2 = param_2 or 0
	protocol_send.param_3 = param_3 or 0
	protocol_send:EncodeAndSend()
end

-- 神兵所有信息
function ShenqiCtrl:OnShenqiAllInfo(protocol)
	RemindManager.Instance:Fire(RemindName.ShenBingXiangQian)
	RemindManager.Instance:Fire(RemindName.BaoJiaXiangQian)
	RemindManager.Instance:Fire(RemindName.ShenBingJianLing)
	RemindManager.Instance:Fire(RemindName.BaoJiaQiLing)

	local old_check_data = TableCopy(self.data:GetShenqiAllInfo())
	self.data:SetShenqiAllInfo(protocol)
	self.view:Flush()

	local baojia_id = 0
	local role = Scene.Instance:GetMainRole()


	if protocol.baojia_cur_image_id > 0 and role then
		local check_falg = false
		local cur_data = protocol.baojia_list[protocol.baojia_cur_image_id]
		if cur_data == nil or next(cur_data) == nil then
			return
		end

		for k, v in pairs(cur_data.quality_list) do
			check_falg = v >= 3
			if not check_falg then
				break
			end
		end


		local other_cfg = self.data:GetShenqiOtherCfg()
		local limlit = 30
		if other_cfg ~= nil and other_cfg.baojia_suit_trigger_level then
			limlit = other_cfg.baojia_suit_trigger_level
		end
		if cur_data.level < limlit then
			check_falg = false
		end

		if check_falg then
			baojia_id = protocol.baojia_cur_image_id
		end
	end

	if old_check_data ~= nil and old_check_data.baojia_cur_image_id ~= nil and old_check_data.baojia_cur_image_id ~= protocol.baojia_cur_image_id then
		role:SetAttr("baojia_id", baojia_id)
	else
		if old_check_data == nil then
			role:SetAttr("baojia_id", protocol.baojia_cur_image_id)
		end
	end
end

-- 单个神器信息
function ShenqiCtrl:OnShenqiSingleInfo(protocol)
	local shenqi_data = self.data:GetShenqiAllInfo()
	self:ShowFloatingTips(shenqi_data.shenbing_list[protocol.item_index], protocol.shenqi_item)
	self:ShowFloatingTips(shenqi_data.baojia_list[protocol.item_index], protocol.shenqi_item)

	RemindManager.Instance:Fire(RemindName.ShenBingXiangQian)
	RemindManager.Instance:Fire(RemindName.BaoJiaXiangQian)
	RemindManager.Instance:Fire(RemindName.ShenBingJianLing)
	RemindManager.Instance:Fire(RemindName.BaoJiaQiLing)
	self.data:SetShenBingListByIndex(protocol)
	self.view:Flush()

	self:CheckBaoJia()
end

function ShenqiCtrl:CheckBaoJia(is_change)
	local check_data = self.data:GetShenqiAllInfo()
	local baojia_id = 0
	local role = Scene.Instance:GetMainRole()
	local check_falg = false

	if check_data ~= nil and next(check_data) ~= nil and check_data.baojia_cur_image_id > 0 and role then
		local cur_data = check_data.baojia_list[check_data.baojia_cur_image_id]
		if cur_data == nil or next(cur_data) == nil then
			return
		end

		for k, v in pairs(cur_data.quality_list) do
			check_falg = v >= 3
			if not check_falg then
				break
			end
		end


		local other_cfg = self.data:GetShenqiOtherCfg()
		local limlit = 30
		if other_cfg ~= nil and other_cfg.baojia_suit_trigger_level then
			limlit = other_cfg.baojia_suit_trigger_level
		end
		if cur_data.level < limlit then
			check_falg = false
		end

		if check_falg then
			baojia_id = check_data.baojia_cur_image_id
		end

		if not is_change then
			role:SetAttr("baojia_id", baojia_id)
		end
	end

	if is_change then
		role:SetAttr("baojia_id", baojia_id)
	end
end

function ShenqiCtrl:ShowFloatingTips(old_data, cur_data)
	local old_exp = old_data.exp or 0
	local cur_exp = cur_data.exp or 0

	local old_level = old_data.level or 0
	local cur_level = cur_data.level or 0
	if old_level ~= cur_level then return end

	self.floating_view = TipsFloatingView.New()
	local msg = ToColorStr("+" .. (cur_exp - old_exp), TEXT_COLOR.GREEN)
	if cur_exp - old_exp > 0 then
		self.floating_view:Show(msg,SHENQI_TEXT_FLOATING_X,SHENQI_TEXT_FLOATING_Y, nil, nil, nil, nil, true)
	end
	if cur_exp - old_exp >= 50 then
		self.floating_view = TipsFloatingView.New()
		self.floating_view:Show(string.format(Language.Shenqi.AddBaoJi, cur_exp - old_exp) , SHENQI_PIC_FLOATING_X, SHENQI_PIC_FLOATING_Y, true)
	end
end

-- 神器特效信息8537
function ShenqiCtrl:OnShenqiImageInfo(protocol)
	-- local main_role = Scene.Instance:GetMainRole()
	-- if not main_role then return end
	-- local main_role_appearance_vo = GameVoManager.Instance:GetMainRoleVo().appearance
	-- if nil == main_role_appearance_vo then
	-- 	main_role_appearance_vo = {}
	-- end
	-- if protocol.info_type == SHENQI_SC_INFO_TYPE.SHENQI_SC_INFO_TYPE_SHENBING then
	-- 	-- main_role_appearance_vo.shengbing_image_id = protocol.cur_use_imgage_id
	-- 	main_role:SetAttr("shengbing_image_id", protocol.cur_use_imgage_id)
	-- elseif protocol.info_type == SHENQI_SC_INFO_TYPE.SHENQI_SC_INFO_TYPE_BAOJIA then
	-- 	-- main_role_appearance_vo.baojia_image_id = protocol.cur_use_imgage_id
	-- 	main_role:SetAttr("baojia_image_id", protocol.cur_use_imgage_id)
	-- end

	self.data:SetShenqiImageInfo(protocol)
	self.view:Flush()

	self:CheckBaoJia(true)
end

-- 神兵升级结果返回
function ShenqiCtrl:OnShenbingUpGradeOptResult(result)
	self.view:ShenbingUpgradeOptResult(result)
end

-- 宝甲升级结果返回
function ShenqiCtrl:OnBaojiaUpGradeOptResult(result)
	self.view:BaojiaUpgradeOptResult(result)
end

-- 材料分解结果
function ShenqiCtrl:OnShenqiDecomposeResult(protocol)
	self:ShowFenjieResultFloatingTips(protocol)
	self.data:SetShenqiDecomposeResultInfo(protocol)
	self.view:Flush()
end

function ShenqiCtrl:ShowFenjieResultFloatingTips(protocol)
	if protocol.item_count >=1 then
		TipsCtrl.Instance:ShowFloatingLabel(nil, 0, 0, false, true, ResPath.GetFloatTextRes("WordDecomposeSuccess"))
	end
end

function ShenqiCtrl:GetGemChangeRemind(remind_type)
	local flag = 0
	if remind_type == RemindName.ShenBingXiangQian then
		if OpenFunData.Instance:CheckIsHide("shenbing_xiangqian") and self.data:GetIsShowSbXiangQiangRp() then
			flag = 1
		end
	elseif remind_type == RemindName.BaoJiaXiangQian then
		if OpenFunData.Instance:CheckIsHide("baojia_xiangqian") and self.data:GetIsShowBjXiangQiangRp() then
			flag = 1
		end
	elseif remind_type == RemindName.ShenBingJianLing then
		if OpenFunData.Instance:CheckIsHide("shenbing_jianling") and self.data:GetIsShowSbJianLingRp() then
			flag = 1
		end
	elseif remind_type == RemindName.BaoJiaQiLing then
		if OpenFunData.Instance:CheckIsHide("baojia_qiling") and self.data:GetIsShowBjQiLingRp() then
			flag = 1
		end
	end

	return flag
end

function ShenqiCtrl:OpenShenQiTip(show_type, id)
	if show_type ~= nil and id ~= nil then
		self.tip_shenqi_view:SetData(show_type, id)
	end
end