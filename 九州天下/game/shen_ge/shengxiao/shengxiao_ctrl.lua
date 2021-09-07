require("game/shen_ge/shengxiao/shengxiao_data")
require("game/shen_ge/shengxiao/shengxiao_view")
require("game/shen_ge/shengxiao/shengxiao_uplevel_view")
require("game/shen_ge/shengxiao/shengxiao_equip_view")
require("game/shen_ge/shengxiao/shengxiao_piece_view")
require("game/shen_ge/shengxiao/shengxiao_skill_view")
require("game/shen_ge/shengxiao/shengxiao_bag_view")
require("game/shen_ge/shengxiao/shengxiao_miji_view")
require("game/shen_ge/shengxiao/shengxiao_miji_bag_view")

ShengXiaoCtrl = ShengXiaoCtrl or BaseClass(BaseController)

function ShengXiaoCtrl:__init()
	if nil ~= ShengXiaoCtrl.Instance then
		print_error("[ShengXiaoCtrl] Attemp to create a singleton twice !")
		return
	end

	ShengXiaoCtrl.Instance = self

	self.data = ShengXiaoData.New()
	self.view = ShengXiaoView.New(ViewName.ShengXiaoView)
	self.shengxiao_skill_view = ShengXiaoSkillView.New(ViewName.ShengXiaoSkillView)
	self.shengxiao_bag_view = ShengXiaoBagView.New(ViewName.ShengXiaoBagView)
	self.shengxiao_miji_view = ShengXiaoMijiView.New(ViewName.ShengXiaoMijiView)
	self.miji_bag_view = MijiBagView.New(ViewName.MijiBagView)

	self:BindGlobalEvent(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind1(self.MainuiOpenCreate, self))
	self:RegisterAllProtocols()
end

function ShengXiaoCtrl:__delete()
	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end
	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end
	if self.shengxiao_skill_view then
		self.shengxiao_skill_view:DeleteMe()
		self.shengxiao_skill_view = nil
	end
	if self.shengxiao_bag_view then
		self.shengxiao_bag_view:DeleteMe()
		self.shengxiao_bag_view = nil
	end
	if self.shengxiao_miji_view then
		self.shengxiao_miji_view:DeleteMe()
		self.shengxiao_miji_view = nil
	end
	if self.miji_bag_view then
		self.miji_bag_view:DeleteMe()
		self.miji_bag_view = nil
	end

	ShengXiaoCtrl.Instance = nil
end

function ShengXiaoCtrl:RegisterAllProtocols()
	self:RegisterProtocol(CSChineseZodiacPromoteEquip)
	self:RegisterProtocol(CSChineseZodiacPromote)
	self:RegisterProtocol(CSTianxiangReq)
	--self:RegisterProtocol(SCChineseZodiacAllInfo, "OnChineseZodiacAllInfo")
	self:RegisterProtocol(SCChineseZodiacEquipInfo, "OnChineseZodiacEquipInfo")
	self:RegisterProtocol(SCTianXiangAllInfo, "OnTianXiangAllInfo")
	self:RegisterProtocol(SCTianXiangSignBead, "OnTianXiangSignBead")
	self:RegisterProtocol(SCTianXiangCombind, "OnTianXiangCombind")
	self:RegisterProtocol(SCGunGunLeInfo, "OnGunGunLeInfo")
	self:RegisterProtocol(SCMijiCombineSucc, "OnMijiCombineSucc")
	self:RegisterProtocol(SCMijiSingleChange, "OnMijiSingleChange")
end

function ShengXiaoCtrl:MainuiOpenCreate()
	self:SendTianxiangReq(CS_TIAN_XIANG_TYPE.CS_TIAN_XIANG_TYPE_ALL_INFO)
end

function ShengXiaoCtrl:OpenShengXiaoSkill(chapter)
	self.shengxiao_skill_view:SetChapter(chapter)
end

function ShengXiaoCtrl:OpenShengXiaoBag()
	self.shengxiao_bag_view:Open()
end

function ShengXiaoCtrl:GetBagView()
	return self.shengxiao_bag_view
end

function ShengXiaoCtrl:OnChineseZodiacAllInfo(protocol)
	self.data:SetShengXiaoAllInfo(protocol)
	self.view:Flush("shengxiao_all_info")
	RemindManager.Instance:Fire(RemindName.ShengXiao_Equip)
	RemindManager.Instance:Fire(RemindName.ShengXiao_Uplevel)
end

function ShengXiaoCtrl:OnChineseZodiacEquipInfo(protocol)
	self.data:SetOneEquipInfo(protocol.zodiac_type, protocol.equip_type, protocol.equip_level)
	self.view:Flush("shengxiao_equip_change")
	RemindManager.Instance:Fire(RemindName.ShengXiao_Equip)
	RemindManager.Instance:Fire(RemindName.ShengXiao_Uplevel)
end

function ShengXiaoCtrl:OnTianXiangAllInfo(protocol)
	self.data:SetTianXianAllInfo(protocol)
	self.view:Flush("tianxian_all_info")
end

function ShengXiaoCtrl:OnTianXiangSignBead(protocol)
	self.data:SetTianXiangSignBead(protocol)
	self.view:Flush("tianxian_cell_change")
end

function ShengXiaoCtrl:OnTianXiangCombind(protocol)
	self.data:SetTianXiangCombind(protocol)
	self.view:Flush("tianxian_combin_change")
end

-- 摇奖机
function ShengXiaoCtrl:OnGunGunLeInfo(protocol)
	self.data.Instance:SetGunGunLeInfo(protocol)
	ViewManager.Instance:FlushView(ViewName.ErnieView, "combine_type", protocol.combine_type)
	RemindManager.Instance:Fire(RemindName.ShengXiao_Piece)
end

-- 合成成功
function ShengXiaoCtrl:OnMijiCombineSucc(protocol)
	local miji_cfg = self.data:GetMijiCfgByIndex(protocol.miji_index)
	TipsCtrl.Instance:OpenGuildRewardView({item_id = miji_cfg.item_id, num = 1},true)
end

function ShengXiaoCtrl:SendHechengRequst(index1)
	self:SendTianxiangReq(CS_TIAN_XIANG_TYPE.CS_TIAN_XIANG_TYPE_MIJI_COMPOUND, index1)
end

-- 秘籍单个修改
function ShengXiaoCtrl:OnMijiSingleChange(protocol)
	if protocol.zodiac_type == -1 then
		self.data:SetEndTurnIndex(protocol.kong_index)
	else
		self.data:SetEndTurnIndex(protocol.kong_index)
		self.data:SetOneMijiInfo(protocol)
	end
	if self.shengxiao_miji_view:IsOpen() then
		self.shengxiao_miji_view:StarRoller()
	end
end

function ShengXiaoCtrl:SendPromoteEquipRequest(zodiac_type, equip_slot)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSChineseZodiacPromoteEquip)
	send_protocol.zodiac_type = zodiac_type or 0
	send_protocol.equip_slot = equip_slot or 0
	send_protocol:EncodeAndSend()
end

function ShengXiaoCtrl:SendPromoteZodiacRequest(zodiac_type, is_auto_buy)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSChineseZodiacPromote)
	send_protocol.zodiac_type = zodiac_type or 0
	send_protocol.is_auto_buy = is_auto_buy or 0
	send_protocol:EncodeAndSend()
end

function ShengXiaoCtrl:SendTianxiangReq(info_type, param1, param2, param3, param4, param5)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSTianxiangReq)
	send_protocol.info_type = info_type or 0
	send_protocol.param1 = param1 or 0
	send_protocol.param2 = param2 or 0
	send_protocol.param3 = param3 or 0
	send_protocol.param4 = param4 or 0
	send_protocol.param5 = param5 or 0
	send_protocol:EncodeAndSend()
end

function ShengXiaoCtrl:SetSelectStudyData(data)
	self.shengxiao_miji_view:SetStudyData(data)
end