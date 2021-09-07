require("game/dress_up/dress_up_view")
require("game/dress_up/dress_up_data")
require("game/dress_up/dress_up_headwear_view")
require("game/dress_up/dress_up_mask_view")
require("game/dress_up/dress_up_waist_view")
require("game/dress_up/dress_up_bead_view")
require("game/dress_up/dress_up_fabao_view")
require("game/dress_up/dress_up_kirin_arm_view")

local FLOATING_X = 400
local FLOATING_Y = -50

DressUpCtrl = DressUpCtrl or BaseClass(BaseController)

function DressUpCtrl:__init()
	if DressUpCtrl.Instance then
		print_error("[DressUpCtrl] Attemp to create a singleton twice !")
		return
	end
	DressUpCtrl.Instance = self
	self.dress_up_view = DressUpView.New(ViewName.DressUp)
	self.dress_up_data = DressUpData.New()
end

function DressUpCtrl:__delete()
	if self.dress_up_data ~= nil then
		self.dress_up_data:DeleteMe()
		self.dress_up_data = nil
	end

	if self.dress_up_view then
		self.dress_up_view:DeleteMe()
		self.dress_up_view = nil
	end

	if self.floating_view then
		self.floating_view:DeleteMe()
		self.floating_view = nil
	end

	self.equip_view = nil

	DressUpCtrl.Instance = nil
end

function DressUpCtrl:GetDressUpView()
	return self.dress_up_view
end

function DressUpCtrl:FlushView(...)
	if self.dress_up_view:IsOpen() then
		self.dress_up_view:Flush(...)
	end
	-- self.tip_skill_upgrade_view:Flush()
	-- self.tip_chengzhang_view:Flush()
	AdvanceCtrl.Instance:FlushTipZiZhiView()
	KaifuActivityCtrl.Instance:FlushView()
	RemindManager.Instance:Fire(RemindName.DressUp)
	-- MainUICtrl.Instance:ChangeRedPoint(MainUIData.RemindingName.Advance, AdvanceData.Instance:GetCanUplevel()
	-- 			or AdvanceData.Instance:IsShowRedPoint())
end

function DressUpCtrl:FlushOpenView()
	if self.dress_up_view:IsOpen() then
		self.dress_up_view:Flush()
	end
end

function DressUpCtrl:FlushViewFromZiZhi(...)
	self.dress_up_view:FlushSonView(...)
end

function DressUpCtrl:OnHuashenUpgradeResult(result)
	self.dress_up_view:OnHuashenUpgradeResult(result)
end

function DressUpCtrl:OnSpiritUpgradeResult(result)
	self.dress_up_view:OnSpiritUpgradeResult(result)
end

-- 头饰
function DressUpCtrl:HeadwearUpgradeResult(result)
	local info_list = HeadwearData.Instance:GetHeadwearInfo()
	self:ShowFloatingTips(HeadwearData.Instance, info_list)
	self.dress_up_view:HeadwearUpgradeResult(result)
end

-- 面饰
function DressUpCtrl:MaskUpgradeResult(result)
	local info_list = MaskData.Instance:GetMaskInfo()
	self:ShowFloatingTips(MaskData.Instance, info_list)
	self.dress_up_view:MaskUpgradeResult(result)
end

-- 腰饰
function DressUpCtrl:WaistUpgradeResult(result)
	local info_list = WaistData.Instance:GetWaistInfo()
	self:ShowFloatingTips(WaistData.Instance, info_list)
	self.dress_up_view:WaistUpgradeResult(result)
end

-- 灵珠
function DressUpCtrl:BeadUpgradeResult(result)
	local info_list = BeadData.Instance:GetBeadInfo()
	self:ShowFloatingTips(BeadData.Instance, info_list)
	self.dress_up_view:BeadUpgradeResult(result)
end

-- 法宝
function DressUpCtrl:FaBaoUpgradeResult(result)
	local info_list = FaBaoData.Instance:GetFaBaoInfo()
	self:ShowFloatingTips(FaBaoData.Instance, info_list)
	self.dress_up_view:FaBaoUpgradeResult(result)
end

-- 麒麟臂
function DressUpCtrl:KirinArmUpgradeResult(result)
	local info_list = KirinArmData.Instance:GetKirinArmInfo()
	self:ShowFloatingTips(KirinArmData.Instance, info_list)
	self.dress_up_view:KirinArmUpgradeResult(result)
end

function DressUpCtrl:ShowFloatingTips(data_source, info)
	local last_bless = data_source:GetShowBless()
	local last_grade = data_source:GetLastGrade()
	local cur_bless = info.grade_bless_val or 0
	local cur_grade = info.grade or 0
	if last_bless >= cur_bless then 
		data_source:ChangeShowInfo()
		return 
	end
	local msg = "+" .. (cur_bless - last_bless)
	local color_msg = ToColorStr(msg, TEXT_COLOR.GREEN)
	data_source:ChangeShowInfo()
	if last_grade ~= cur_grade then return end
	self.floating_view = TipsFloatingView.New()
	self.floating_view:Show(color_msg, FLOATING_X, FLOATING_Y, nil, nil, nil, nil, true)
end