require("game/shenqi/shenqi_data")
require("game/shenqi/shenqi_view")

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
	
	self:RegisterAllProtocols()

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

	RemindManager.Instance:Fire(RemindName.ShenQiJiangLing)
	RemindManager.Instance:Fire(RemindName.ShenQiBaoJia)
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
		role:SetAttr("baojia_image_id", baojia_id)
	else
		if old_check_data == nil then
			role:SetAttr("baojia_image_id", protocol.baojia_cur_image_id)
		end
	end
end

-- 单个神器信息
function ShenqiCtrl:OnShenqiSingleInfo(protocol)
	local shenqi_data = self.data:GetShenqiAllInfo()

	self:ShowFloatingTips(shenqi_data.shenbing_list[protocol.item_index], protocol.shenqi_item)
	self:ShowFloatingTips(shenqi_data.baojia_list[protocol.item_index], protocol.shenqi_item)

	RemindManager.Instance:Fire(RemindName.ShenQiJiangLing)
	RemindManager.Instance:Fire(RemindName.ShenQiBaoJia)
	self.data:SetShenBingListByIndex(protocol)
	self.view:Flush()
	self.view:FlushCellUpLevelState()
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
			role:SetAttr("baojia_image_id", baojia_id)
		end
	end

	if is_change then
		role:SetAttr("baojia_image_id", baojia_id)
	end
end

function ShenqiCtrl:ShowFloatingTips(old_data, cur_data)
	local old_exp = old_data.exp or 0
	local cur_exp = cur_data.exp or 0

	local old_level = old_data.level or 0
	local cur_level = cur_data.level or 0
	if old_level ~= cur_level then return end

	
	local msg = ("+" .. (cur_exp - old_exp))
	if cur_exp - old_exp > 0 then
		TipsFloatingManager.Instance:ShowFloatingTips(msg)
	end

	if cur_exp - old_exp >= 50 then
		TipsFloatingManager.Instance:ShowFloatingTips(string.format(Language.ShenQi.AddBaoJi, cur_exp - old_exp))
	end
end

-- 神器特效信息8537
function ShenqiCtrl:OnShenqiImageInfo(protocol)

	self.data:SetShenqiImageInfo(protocol)
	self.view:Flush()
	TipsCtrl.Instance:FlushShenQiEffectTips()
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
	-- self:ShowFenjieResultFloatingTips(protocol)
	self.data:SetShenqiDecomposeResultInfo(protocol)
	self.view:Flush()
end

function ShenqiCtrl:OpenShenQiTip(show_type, id)
	if show_type ~= nil and id ~= nil then
		self.tip_shenqi_view:SetData(show_type, id)
	end
end