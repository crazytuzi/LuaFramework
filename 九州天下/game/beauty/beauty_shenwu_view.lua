require("game/beauty/beauty_item")
BeautyShenwuView = BeautyShenwuView or BaseClass(BaseView)

local UPGRADE = 0			-- 升级
local HUANHUA = 1			-- 幻化

function BeautyShenwuView:__init()
	self.ui_config = {"uis/views/beauty","BeautyShenWuView"}
	self:SetMaskBg()
	self.play_audio = true
	self.types = nil
end

function BeautyShenwuView:ReleaseCallBack()
	if self.model_display then
		self.model_display:DeleteMe()
		self.model_display = nil
	end
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
	self.gongji = nil
	self.pvp_hurt = nil
	self.fangyu = nil
	self.shengming = nil
	self.mingzhong = nil
	self.shanbi = nil

	self.activate_text = nil
	self.activate_state = nil
	self.cur_count = nil
	self.need_count = nil
	self.activate_btn_gray = nil
	self.display = nil
	self.item_name = nil
	self.icon = nil
	self.name = nil
	self.fight_power = nil
	self.show_btn_red = nil
end

function BeautyShenwuView:LoadCallBack()
	self:ListenEvent("Close", BindTool.Bind(self.OnClickClose, self))
	self:ListenEvent("OnClickActivate", BindTool.Bind(self.OnClickActivate, self))

	self.gongji = self:FindVariable("GongJi")
	self.pvp_hurt = self:FindVariable("PvpHurt")
	self.fangyu = self:FindVariable("FangYu")
	self.shengming = self:FindVariable("ShengMing")
	self.mingzhong = self:FindVariable("MingZhong")
	self.shanbi = self:FindVariable("ShanBi")
	self.fight_power = self:FindVariable("FightPower")

	self.activate_text = self:FindVariable("ActivateText")
	self.activate_state = self:FindVariable("ActivateState")
	self.cur_count = self:FindVariable("ActivateProNum")
	self.need_count = self:FindVariable("ExchangeNeedNum")
	self.activate_btn_gray = self:FindVariable("ActivateBtnGray")
	self.item_name = self:FindVariable("ItemName")
	self.icon = self:FindVariable("Icon")
	self.name = self:FindVariable("Name")
	self.display = self:FindObj("Display")
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("ItemCell"))

	self.show_btn_red = self:FindVariable("ShowBtnRed")
end

function BeautyShenwuView:ShowIndexCallBack(index)
	self:Flush()
end

-- 初始化模型处理函数
function BeautyShenwuView:FlushModel()
	local cfg = {} 
	if self.types == UPGRADE then
		cfg = BeautyData.Instance:GetBeautyActiveInfo(self.seq)
	else
		cfg = BeautyData.Instance:GetBeautyHuanhuaCfg(self.seq)
	end

	if nil == self.model_display then
		self.model_display = RoleModel.New("beauty_panel", 2000)
		self.model_display:SetDisplay(self.display.ui3d_display)
	end
	if self.model_display and cfg then
		local bundle, asset = ResPath.GetGoddessNotLModel(cfg.model)
		self.model_display:SetMainAsset(bundle, asset)
	end
end

function BeautyShenwuView:OnClickClose()
	self:Close()
end

function BeautyShenwuView:OnClickActivate()
	BeautyCtrl.Instance:SendBeautyCommonReq(BEAUTY_COMMON_REQ_TYPE.BEAUTY_COMMON_REQ_TYPE_ACTIVE_SHENGWU, self.seq, self.types)	--是否是幻化先用types
end

function BeautyShenwuView:OnFlush(param_list)
	for k, v in pairs(param_list) do
		if k == "beauty_upgrade" then
			self.seq = v.seq - 1
			self.types = UPGRADE
		elseif k == "beauty_huanhua" then
			self.seq = v.seq
			self.types = HUANHUA
		elseif v.item_id then
			self.seq, self.types = BeautyData.Instance:ItemJump()
		end
		if self.seq ~= nil then
			self:UpData()
			self:FlushModel()
		end
	end
end

function BeautyShenwuView:UpData()
	local index = self.seq 
	if self.types == HUANHUA then
		index = index + 100
	end
	local shenwu_cfg = BeautyData.Instance:GetBeautyShenwu(index)
	if shenwu_cfg then
		self.name:SetValue(shenwu_cfg.beauty_name)
		self.gongji:SetValue(shenwu_cfg.gongji)
		self.pvp_hurt:SetValue(MojieData.Instance:GetAttrRate(shenwu_cfg.per_pvp_hurt_increase))
		-- self.fangyu:SetValue(shenwu_cfg.fangyu)
		-- self.shengming:SetValue(shenwu_cfg.maxhp)
		-- self.mingzhong:SetValue(shenwu_cfg.mingzhong)
		-- self.shanbi:SetValue(shenwu_cfg.shanbi)
		local power = CommonDataManager.GetCapabilityCalculation(shenwu_cfg)
		self.fight_power:SetValue(power)

		local has_stuff = ItemData.Instance:GetItemNumInBagById(shenwu_cfg.active_item_id)
		self.item_cell:SetData({item_id = shenwu_cfg.active_item_id})
		local stuff_color = has_stuff < shenwu_cfg.active_item_count and "ff0000" or "00931f"
		self.cur_count:SetValue(string.format("<color=#%s>%d</color>", stuff_color, has_stuff))
		self.need_count:SetValue(shenwu_cfg.active_item_count)
		self.item_name:SetValue(shenwu_cfg.name)
	end

	local beauty_info = {}
	if self.types == UPGRADE then
		beauty_info = BeautyData.Instance:GetBeautyInfo()[self.seq + 1]
	else
		beauty_info = BeautyData.Instance:GetHuanhuaInfo(self.seq)
	end
	if beauty_info and beauty_info.is_active_shenwu then
		self.activate_btn_gray:SetValue(beauty_info.is_active_shenwu == 1)
		self.activate_state:SetValue(beauty_info.is_active_shenwu == 1 and Language.Beaut.BeautHadActive or Language.Beaut.BeautNotActive)
		self.activate_text:SetValue(beauty_info.is_active_shenwu == 1 and Language.Common.YiActivate or Language.Common.Activate)
	end

	if self.show_btn_red ~= nil then
		self.show_btn_red:SetValue(BeautyData.Instance:GetIsCanActiveShenWu(self.seq + 1, self.types == HUANHUA))
	end
end