require("game/beauty/beauty_data")
require("game/beauty/beauty_view")
require("game/beauty/beauty_huanhua_view")
require("game/beauty/beauty_shenwu_view")
require("game/beauty/beauty_tryst_panel")
require("game/beauty/heti_attr_view")
require("game/beauty/beauty_skill_smmary")
require("game/beauty/beauty_attr_tip_view")
require("game/beauty/select_stuff_view")
require("game/beauty/beauty_lock_skill_tip")
BeautyCtrl = BeautyCtrl or BaseClass(BaseController)

local FLOATING_X = 400
local FLOATING_Y = -75

function BeautyCtrl:__init()
	if BeautyCtrl.Instance then
		print_error("[BeautyCtrl] Attemp to create a singleton twice !")
	end
	BeautyCtrl.Instance = self

	self.data = BeautyData.New()
	self.view = BeautyView.New(ViewName.Beauty)
	self.huanhua_view = BeautyHuanhuaView.New(ViewName.BeautyHuanhua)
	self.shenwu_view = BeautyShenwuView.New(ViewName.BeautyShenwu)
	self.tryst_panel = BeautyTrystPanel.New(ViewName.BeautyTryst)
	self.skill_smmary = BeautySkillSmmaryView.New()
	self.heti_attr_view = HetiBuffView.New()
	self.beauty_attr_view = BeautyAttrTipView.New()
	self.beauty_select_stuff_view = SelectStuffView.New(ViewName.BeautyXiLianStuffView)
	self.beauty_lock_skill_tip = BeautyLockSkillTip.New()

	self:RegisterAllProtocols()
end

function BeautyCtrl:__delete()
	if self.view ~= nil then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data ~= nil then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.huanhua_view then
		self.huanhua_view:DeleteMe()
		self.huanhua_view = nil
	end

	if self.heti_attr_view then
		self.heti_attr_view:DeleteMe()
		self.heti_attr_view = nil
	end	

	if self.floating_view then
		self.floating_view:DeleteMe()
		self.floating_view = nil
	end

	if self.beauty_select_stuff_view then
		self.beauty_select_stuff_view:DeleteMe()
		self.beauty_select_stuff_view = nil
	end

	if self.beauty_attr_view ~= nil then
		self.beauty_attr_view:DeleteMe()
		self.beauty_attr_view = nil
	end

	if self.beauty_lock_skill_tip ~= nil then
		self.beauty_lock_skill_tip:DeleteMe()
		self.beauty_lock_skill_tip = nil
	end

	BeautyCtrl.Instance = nil
end

function BeautyCtrl:GetView()
	return self.view
end

function BeautyCtrl:RegisterAllProtocols()
	self:RegisterProtocol(CSBeautyCommonReq)

	self:RegisterProtocol(SCBeautyBaseInfo, "OnSCBeautyBaseInfo")
	self:RegisterProtocol(SCBeautyItemInfo, "OnSCBeautyItemInfo")
	self:RegisterProtocol(SCBeautySkillTrigger, "OnSCBeautySkillTrigger")
	self:RegisterProtocol(SCBeautyXinjiTypeInfo, "OnSCBeautyXinjiTypeInfo")
	self:RegisterProtocol(SCBeautyHuanhuaInfo, "OnBeautyHuanhuaInfo")
	self:RegisterProtocol(SCBeautyHetiAttrs, "OnSCBeautyHetiAttrs")
end


-- 角色美人信息请求
function BeautyCtrl:SendBeautyCommonReq(req_type, param_1, param_2, param_3)	
	local cmd = ProtocolPool.Instance:GetProtocol(CSBeautyCommonReq)
	cmd.req_type = req_type or 0
	cmd.param_1 = param_1 or 0
	cmd.param_2 = param_2 or 0
	cmd.param_3 = param_3 or 0
	cmd:EncodeAndSend()
end

-- 美人全部信息
function BeautyCtrl:OnSCBeautyBaseInfo(protocol)
	self.data:SetBeautyInfo(protocol)
	self.view:Flush()
	if self.huanhua_view:IsOpen() then
		self.huanhua_view:Flush()
	end

	RemindManager.Instance:Fire(RemindName.BeautyInfo)
	RemindManager.Instance:Fire(RemindName.BeautyUpgrade)
	RemindManager.Instance:Fire(RemindName.BeautyWish)
	RemindManager.Instance:Fire(RemindName.BeautyScheming)
	RemindManager.Instance:Fire(RemindName.BeautyPray)
	RemindManager.Instance:Fire(RemindName.BeautyXiLian)
end

-- 美人信息
function BeautyCtrl:OnSCBeautyItemInfo(protocol)
	self.data:SetBeautyListInfo(protocol)
	self.view:Flush()
	self.shenwu_view:Flush()
	self.huanhua_view:Flush()
	RemindManager.Instance:Fire(RemindName.BeautyInfo)
	RemindManager.Instance:Fire(RemindName.BeautyUpgrade)
end

--美人技能广播
function BeautyCtrl:OnSCBeautySkillTrigger(protocol)
	local obj = Scene.Instance:GetObj(protocol.obj_id)
	if nil == obj then
		return
	end
	if obj:IsMainRole() then
		if protocol.skill_type >= BEAUTY_SKILL_TYPE.BEAUTY_SKILL_TYPE_KUANGRE then --后面4个技能才有buff显示
			FightData.Instance:SetBeautyEffectLest(protocol)
		end
	end
	self:ActChangeBlood(protocol)
	RemindManager.Instance:Fire(RemindName.BeautyScheming)
end
	
function BeautyCtrl:ActChangeBlood(protocol)
	if nil == Scene.Instance:GetMainRole() then
		return
	end

	local role_obj = Scene.Instance:GetObjectByObjId(protocol.obj_id)
	if nil == role_obj or (SceneObjType.MainRole ~= role_obj:GetType() and SceneObjType.Role ~= role_obj:GetType()) then
		return
	end
	if protocol.skill_type == BEAUTY_SKILL_TYPE.BEAUTY_SKILL_TYPE_HUDUN then
		role_obj:AddBuff(BUFF_TYPE.EBT_BEAUTY_DUN, protocol.param2)
	elseif protocol.skill_type == BEAUTY_SKILL_TYPE.BEAUTY_SKILL_TYPE_RECOVER then
		self:PlayAni(role_obj)
	end
end

--播放加血特效
function BeautyCtrl:PlayAni(role_obj)
	local beauty_obj = role_obj:GetBeautyObj()
	if nil == beauty_obj or SettingData.Instance:IsShieldOtherRole(Scene.Instance:GetSceneId()) then return end
	local role_obj_transform = role_obj:GetRoot().transform
	if IsNil(role_obj_transform) then
		return
	end
	local effect = AsyncLoader.New(role_obj_transform)
	beauty_obj:SetIsSkill(role_obj_transform.position)
	local call_back = function(effect_obj)
		if effect_obj and not IsNil(effect_obj) then
			local beauty_obj_root = beauty_obj:GetRoot()
			if beauty_obj_root and not IsNil(beauty_obj_root.gameObject) then
				local beauty_pos = beauty_obj_root.transform.position
				local beautypos = u3d.vec3(beauty_pos.x, beauty_pos.y + 1.5, beauty_pos.z)
				effect_obj.transform:DOMove(beautypos, 0)
			end

			if role_obj_transform ~= nil and not IsNil(role_obj_transform) and role_obj_transform.position ~= nil then
				local role_pos = role_obj_transform.position
				local rolepos = u3d.vec3(role_pos.x, role_pos.y + 1.5, role_pos.z)
				local tween = effect_obj.transform:DOMove(rolepos, 0.1)
				tween:SetEase(DG.Tweening.Ease.Linear)
				tween:OnComplete(function ()
					EffectManager.Instance:PlayControlEffect(
					"effects2/prefab/misc/ns_zhiliao_prefab",
					"ns_zhiliao",
					role_obj_transform.position,
					nil,
					role_obj_transform)
				end)				
			end
		end
	end
	effect:Load("effects2/prefab/misc/zhiliao_zidan_prefab", "zhiliao_zidan", call_back)
	GlobalTimerQuest:AddDelayTimer(function() effect:Destroy() effect:DeleteMe() end, 0.2)
end

function BeautyCtrl:OnSCBeautyXinjiTypeInfo(protocol)
	self.data:SetBeautyXinjiTypeInfo(protocol)
	self.view:Flush()
	RemindManager.Instance:Fire(RemindName.Beauty)
end

function BeautyCtrl:OnBeautyHuanhuaInfo(protocol)
	self.data:SetHuanhuaItemList(protocol)
	self.huanhua_view:Flush()
	self.tryst_panel:Flush()
	RemindManager.Instance:Fire(RemindName.Beauty)
end

function BeautyCtrl:OnSCBeautyHetiAttrs(protocol)
	if protocol.count > 0 then
		if self.view:IsOpen() then
			for k,v in pairs(protocol.attr_list) do
				if BeautyData.Instance:GetIsShowFloatingAttr(v)then
					TipsCtrl.Instance:ShowFloatingLabel(ToColorStr(Language.Common.AttrNameNoUnderline[Language.Beaut.HetiAttrType[v.attr_type]]  .. "+" .. v.attr_value, TEXT_COLOR.GOLD), 220, 0, nil, nil, nil, nil, 8)
				end
			end
		end
		self.data:SetHetiAttrsData(protocol)
	end
	self.view:Flush()
	RemindManager.Instance:Fire(RemindName.Beauty)
end

function BeautyCtrl:FlushViewInfo(...)
	if self.view:IsOpen() then
		self.view:Flush(...)
	end
end

function BeautyCtrl:ShowSkliiUplevel(types, index)
	self.view:ShowSkliiUplevel(types, index)
end

function BeautyCtrl:OnBeautyUpGradeOptResult(result)
	if self.view:IsOpen() then
		self.view:SetAutoBeautyGrade(result)
		self:ShowFloatingTips()
	end
end

function BeautyCtrl:OnBeautyChanMianOptResult(result, param1)
	if self.view:IsOpen() and 1 == param1 then
		self:ShowChanMianTips()
	end
end

-- 显示仓库
function BeautyCtrl:PrayShowDepot()
	self.view:ShowDepot()
end

function BeautyCtrl:HetiAttrView()
	self.heti_attr_view:Open()
end

function BeautyCtrl:SkillSmmaryView()
	self.skill_smmary:Open()
end

function BeautyCtrl:ShowFloatingTips()
	local last_bless = self.data:GetBeautyLastBless()
	local last_grade = self.data:GetBeautyLastGrade()
	local info_list = self.data:GetBeautyListInfo()
	local cur_bless = info_list.upgrade_val or 0
	local cur_grade = info_list.grade or 0
	local msg = "+" .. (cur_bless - last_bless)
	local color_msg = ToColorStr(msg, TEXT_COLOR.GREEN)

	if last_grade ~= cur_grade then
		--升阶提示
		TipsCtrl.Instance:ShowFloatingLabel(nil, 250, 30, false, true, ResPath.GetFloatTextRes("WordAdvenceSuccess"))
		return 
	end
	if cur_bless == last_bless then return end
	self.floating_view = TipsFloatingView.New()
	self.floating_view:Show(color_msg, FLOATING_X, FLOATING_Y, nil, nil, nil, nil, true)
	--升阶暴击提示
	if(cur_bless - last_bless > 100)  then
		TipsCtrl.Instance:ShowFloatingLabel(nil, 250, 30, false, true, ResPath.GetFloatTextRes("WordBaojiUpgrade"))
	end
end

function BeautyCtrl:ShowChanMianTips()
	TipsCtrl.Instance:ShowFloatingLabel(nil, 250, 30, false, true, ResPath.GetFloatTextRes("WordUpgradeSuccess"))
end

function BeautyCtrl:OpenAttrView()
	self.beauty_attr_view:Open()
end

function BeautyCtrl:CloseView()
	if self.view:IsOpen() then
		self.view:Close()
	end
end

function BeautyCtrl:FlushXiLian()
	if self.view:IsOpen() then
		self.view:Flush("xilian")
	end
end

function BeautyCtrl:OpenLockSkillTip(skill_type, skill_index, call)
	self.beauty_lock_skill_tip:SetData(skill_type, skill_index, call)
end