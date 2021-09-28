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
require("game/advance/advance_fight_mount_view")
require("game/advance/advance_equip_view")
require("game/advance/advance_equip_skill_view")
require("game/advance/advance_foot_view")
require("game/advance/advance_cloak_view")
require("game/advance/advance_lingchong_view")
require("game/advance/clear_bless_tip_view")

AdvanceCtrl = AdvanceCtrl or BaseClass(BaseController)

AdvanceCtrl.HAS_TIPS_CLEAR_BLESS_T = {}
function AdvanceCtrl:__init()
	if AdvanceCtrl.Instance then
		return
	end
	AdvanceCtrl.Instance = self
	self.advance_view = AdvanceView.New(ViewName.Advance)
	self.advance_data = AdvanceData.New()
	-- self.tip_chengzhang_view = TipChengZhangView.New(ViewName.TipChengZhang)
	self.tip_zizhi_view = TipZiZhiView.New(ViewName.TipZiZhi)
	self.tip_skill_upgrade_view = TipSkillUpgradeView.New(ViewName.TipSkillUpgrade)
	self.equip_view = AdvanceEquipView.New(ViewName.AdvanceEquipView)
	self.equip_skill_view = AdvanceEquipSkillView.New(ViewName.AdvanceEquipSkillView)
	self.clear_bless_tip_view = ClearBlessTipView.New(ViewName.ClearBlessTipView)

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

	if self.equip_view then
		self.equip_view:DeleteMe()
		self.equip_view = nil
	end

	if self.equip_skill_view then
		self.equip_skill_view:DeleteMe()
		self.equip_skill_view = nil
	end

	if self.clear_bless_tip_view then
		self.clear_bless_tip_view:DeleteMe()
		self.clear_bless_tip_view = nil
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
	self.tip_skill_upgrade_view:Flush()
	-- self.tip_chengzhang_view:Flush()

	self.tip_zizhi_view:Flush()
	KaifuActivityCtrl.Instance:FlushView()
	RemindManager.Instance:Fire(RemindName.Advance)
end

function AdvanceCtrl:FlushHuashen(...)
	-- self.advance_view:Flush(...)
end

function AdvanceCtrl:FlushZiZhiTips()
	if self.tip_zizhi_view:IsOpen() then
		self.tip_zizhi_view:Flush()
	end
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

function AdvanceCtrl:OnFightMountUpgradeResult(result)
	self.advance_view:OnFightMountUpgradeResult(result)
end

-- 坐骑进阶结果返回
function AdvanceCtrl:MountUpgradeResult(result)
	self.advance_view:MountUpgradeResult(result)
end

-- 羽翼进阶结果返回
function AdvanceCtrl:WingUpgradeResult(result)
	self.advance_view:WingUpgradeResult(result)
end

-- 足迹进阶结果返回
function AdvanceCtrl:FootUpgradeResult(result)
	self.advance_view:FootUpgradeResult(result)
end

-- 披风进阶结果返回
function AdvanceCtrl:CloakUpgradeResult(result)
	self.advance_view:CloakUpgradeResult(result)
end

function AdvanceCtrl:HaloUpgradeResult(result)
	self.advance_view:HaloUpgradeResult(result)
end

function AdvanceCtrl:FlushEquipView(...)
	self.equip_view:Flush(...)
end

--根据不同界面判断是否打开清除祝福值提示
function AdvanceCtrl:OpenClearBlessView(view_name, view_index, call_back)
	local data = {}
	local info = {}
	local grade_cfg = nil
	local grade = 0
	if view_name == ViewName.Advance then
		if view_index == TabIndex.mount_jinjie then
			info = MountData.Instance:GetMountInfo()
			_, grade = MountData.Instance:GetClearBlessGrade()
			grade_cfg = MountData.Instance:GetMountGradeCfg()
		elseif view_index == TabIndex.wing_jinjie then
			info = WingData.Instance:GetWingInfo()
			_, grade = WingData.Instance:GetClearBlessGrade()
			grade_cfg = WingData.Instance:GetWingGradeCfg()
		elseif view_index == TabIndex.halo_jinjie then
			info = HaloData.Instance:GetHaloInfo()
			_, grade = HaloData.Instance:GetClearBlessGrade()
			grade_cfg = HaloData.Instance:GetHaloGradeCfg()
		elseif view_index == TabIndex.fight_mount then
			info = FightMountData.Instance:GetFightMountInfo()
			_, grade = FightMountData.Instance:GetClearBlessGrade()
			grade_cfg = FightMountData.Instance:GetMountGradeCfg()
		elseif view_index == TabIndex.foot_jinjie then
			info = FootData.Instance:GetFootInfo()
			_, grade = FootData.Instance:GetClearBlessGrade()
			grade_cfg = FootData.Instance:GetFootGradeCfg()
		elseif view_index == TabIndex.lingchong_jinjie then
			info = LingChongData.Instance:GetLingChongInfo()
			_, grade = LingChongData.Instance:GetClearBlessGradeLimit()
			grade_cfg = LingChongData.Instance:GetLingChongGradeCfgInfoByGrade()
		end
	elseif view_name == ViewName.Goddess then
		if view_index == TabIndex.goddess_shengong then
			info = ShengongData.Instance:GetShengongInfo()
			_, grade = ShengongData.Instance:GetClearBlessGrade()
			grade_cfg = ShengongData.Instance:GetShengongGradeCfg()
		elseif view_index == TabIndex.goddess_shenyi then
			info = ShenyiData.Instance:GetShenyiInfo()
			_, grade = ShenyiData.Instance:GetClearBlessGrade()
			grade_cfg = ShenyiData.Instance:GetShenyiGradeCfg()
		end
	end
	if not AdvanceCtrl.HAS_TIPS_CLEAR_BLESS_T[view_index] and
		grade_cfg and grade_cfg.is_clear_bless == 1 and info and info.grade_bless_val and info.grade_bless_val > 0 then
		data.view_name = view_name
		data.view_index = view_index
		data.call_back = call_back
		data.max_val = grade_cfg.bless_val_limit
		data.cur_val = info.grade_bless_val
		data.grade = grade
		self.clear_bless_tip_view:SetData(data)
		AdvanceCtrl.HAS_TIPS_CLEAR_BLESS_T[view_index] = true
	else
		if call_back then
			call_back()
		else
			ViewManager.Instance:Close(view_name)
		end
	end
end