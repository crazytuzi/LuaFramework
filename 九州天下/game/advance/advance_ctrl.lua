require("game/advance/advance_view")
require("game/advance/advance_data")
require("game/advance/advance_mount_view")
--require("game/advance/tip_chengzhang_view")
require("game/advance/tip_zizhi_view")
require("game/advance/tip_skill_upgrade_view")
require("game/advance/advance_wing_view")
require("game/advance/advance_halo_view")
require("game/advance/advance_shengong_view")
require("game/advance/advance_shenyi_view")
require("game/advance/advance_huashen_view")
require("game/advance/advance_huashen_protect_view")
require("game/advance/advance_fazhen_view")
require("game/advance/advance_beauty_halo_view")
require("game/advance/advance_halidom_view")
require("game/advance/advance_equip_view")
require("game/advance/advance_equip_skill_view")
require("game/advance/advance_multi_mount_viewl")


local FLOATING_X = 400
local FLOATING_Y = -50

AdvanceCtrl = AdvanceCtrl or BaseClass(BaseController)

function AdvanceCtrl:__init()
	if AdvanceCtrl.Instance then
		print_error("[AdvanceCtrl] Attemp to create a singleton twice !")
		return
	end
	AdvanceCtrl.Instance = self
	self.advance_view = AdvanceView.New(ViewName.Advance)
	self.advance_data = AdvanceData.New()
	-- self.tip_chengzhang_view = TipChengZhangView.New(ViewName.TipChengZhang)
	self.tip_zizhi_view = TipZiZhiView.New(ViewName.TipZiZhi)
	self.tip_skill_upgrade_view = TipSkillUpgradeView.New(ViewName.TipSkillUpgrade)
	self.floating_view = TipsFloatingView.New()
	self.equip_view = AdvanceEquipView.New(ViewName.AdvanceEquipView)
	self.equip_skill_view = AdvanceEquipSkillView.New(ViewName.AdvanceEquipSkillView)
	self.set_mount_attr = GlobalEventSystem:Bind(OtherEventType.MOUNT_INFO_CHANGE, BindTool.Bind1(self.FlushView, self, "mount"))
end

function AdvanceCtrl:__delete()
	if nil ~= self.set_mount_attr then
		GlobalEventSystem:UnBind(self.set_mount_attr)
		self.set_mount_attr = nil
	end

	if self.tip_skill_upgrade_view ~= nil then
		self.tip_skill_upgrade_view:DeleteMe()
		self.tip_skill_upgrade_view = nil
	end

	-- if self.tip_chengzhang_view ~= nil then
	-- 	self.tip_chengzhang_view:DeleteMe()
	-- 	self.tip_chengzhang_view = nil
	-- end

	if self.tip_zizhi_view ~= nil then
		self.tip_zizhi_view:DeleteMe()
		self.tip_zizhi_view = nil
	end

	if self.advance_data ~= nil then
		self.advance_data:DeleteMe()
		self.advance_data = nil
	end

	if self.advance_view then
		self.advance_view:DeleteMe()
		self.advance_view = nil
	end

	if self.floating_view then
		self.floating_view:DeleteMe()
		self.floating_view = nil
	end

	if self.equip_view then
		self.equip_view:DeleteMe()
		self.equip_view = nil
	end

	if self.equip_skill_view then
		self.equip_skill_view:DeleteMe()
		self.equip_skill_view = nil
	end

	AdvanceCtrl.Instance = nil
end

function AdvanceCtrl:GetAdvanceView()
	return self.advance_view
end

function AdvanceCtrl:FlushView(...)
	if self.advance_view:IsOpen() then
		self.advance_view:Flush(...)
	end
	-- self.tip_skill_upgrade_view:Flush()
	-- self.tip_chengzhang_view:Flush()
	self.tip_zizhi_view:Flush()
	KaifuActivityCtrl.Instance:FlushView()
	RemindManager.Instance:Fire(RemindName.Advance)
	-- MainUICtrl.Instance:ChangeRedPoint(MainUIData.RemindingName.Advance, AdvanceData.Instance:GetCanUplevel()
	-- 			or AdvanceData.Instance:IsShowRedPoint())
end

function AdvanceCtrl:FlushOpenView()
	if self.advance_view:IsOpen() then
		self.advance_view:Flush()
	end
end

function AdvanceCtrl:FlushHuashen(...)
	-- self.advance_view:Flush(...)
end

function AdvanceCtrl:FlushViewFromZiZhi(...)
	self.advance_view:FlushSonView(...)
end

function AdvanceCtrl:FlushHuashenProtect(...)
	-- self.advance_view:Flush(...)
end

function AdvanceCtrl:OnHuashenUpgradeResult(result)
	self.advance_view:OnHuashenUpgradeResult(result)
end

function AdvanceCtrl:OnSpiritUpgradeResult(result)
	self.advance_view:OnSpiritUpgradeResult(result)
end

-- 战斗坐骑
function AdvanceCtrl:OnFightMountUpgradeResult(result)
	local info_list = FaZhenData.Instance:GetFightMountInfo()
	self:ShowFloatingTips(FaZhenData.Instance, info_list)
	self.advance_view:OnFightMountUpgradeResult(result)
end

-- 美人光环
function AdvanceCtrl:OnBeautyHaloUppGradeOptResult(result)
	local info_list = BeautyHaloData.Instance:GetBeautyHaloInfo()
	self:ShowFloatingTips(BeautyHaloData.Instance, info_list)
	self.advance_view:BeautyHaloUppGradeOptResult(result)
end

-- 圣物返回
function AdvanceCtrl:OnHalidomUppGradeOptResult(result)
	local info_list = HalidomData.Instance:GetHalidomInfo()
	self:ShowFloatingTips(HalidomData.Instance, info_list)
	self.advance_view:HalidomUpGradeResult(result)
end

-- 坐骑进阶结果返回
function AdvanceCtrl:MountUpgradeResult(result)
	local info_list = MountData.Instance:GetMountInfo()
	self:ShowFloatingTips(MountData.Instance, info_list)
	self.advance_view:MountUpgradeResult(result)
end

-- 羽翼进阶结果返回
function AdvanceCtrl:WingUpgradeResult(result)
	local info_list = WingData.Instance:GetWingInfo()
	self:ShowFloatingTips(WingData.Instance, info_list)
	self.advance_view:WingUpgradeResult(result)
end

-- 光环返回
function AdvanceCtrl:HaloUpgradeResult(result)
	local info_list = HaloData.Instance:GetHaloInfo()
	self:ShowFloatingTips(HaloData.Instance, info_list)
	self.advance_view:HaloUpgradeResult(result)
end

-- 足迹返回
function AdvanceCtrl:OnShengongUpGradeResult(result)
	local info_list = ShengongData.Instance:GetShengongInfo()
	self:ShowFloatingTips(ShengongData.Instance, info_list)
	self.advance_view:ShengongUpGradeResult(result)
end

-- 披风返回
function AdvanceCtrl:OnShenyiUpGradeResult(result)
	local info_list = ShenyiData.Instance:GetShenyiInfo()
	self:ShowFloatingTips(ShenyiData.Instance, info_list)
	self.advance_view:ShenyiUpGradeResult(result)
end

-- 双人返回
function AdvanceCtrl:MultiMountUpGradeResult(result)
	local info_list = MultiMountData.Instance:GetMultiMountInfo()
	self:ShowFloatingTips(MultiMountData.Instance, info_list)
	self.advance_view:MultiMountUpGradeResult(result)
end

function AdvanceCtrl:ShowFloatingTips(data_source, info)
	local last_bless = data_source:GetShowBless()
	local last_grade = data_source:GetLastGrade()
	local cur_bless = info.grade_bless_val or 0
	local cur_grade = info.grade or 0
	if last_bless >= cur_bless then return end
	local msg = "+" .. (cur_bless - last_bless)
	local color_msg = ToColorStr(msg, TEXT_COLOR.GREEN)
	data_source:ChangeShowInfo()
	if last_grade ~= cur_grade then return end
	self.floating_view = TipsFloatingView.New()
	self.floating_view:Show(color_msg, FLOATING_X, FLOATING_Y, nil, nil, nil, nil, true)
end

function AdvanceCtrl:FlushEquipView(...)
	self.equip_view:Flush(...)
end

function AdvanceCtrl:FlushTipZiZhiView(...)
	if self.tip_zizhi_view:IsOpen() then
		self.tip_zizhi_view:Flush(...)
	end
end
