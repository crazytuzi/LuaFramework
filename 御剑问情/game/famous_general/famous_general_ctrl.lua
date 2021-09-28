require("game/famous_general/item/famous_general_item")
require("game/famous_general/info/famous_general_info_content")
require("game/famous_general/potential/famous_general_potential")
require("game/famous_general/talent/famous_talent_bag_view")
require("game/famous_general/talent/famous_talent_upgrade_view")
require("game/famous_general/talent/famous_talent_skill_upgrade_view")
require("game/famous_general/talent/famous_talent_content")
require("game/famous_general/talent/famous_talent_data")
require("game/famous_general/famous_general_view")
require("game/famous_general/famous_general_data")
require("game/famous_general/focus/wakeup_focus_data")
require("game/famous_general/focus/wakeup_focus_view")
require("game/famous_general/famous_general_wakeup_view")
require("game/famous_general/famous_general_wakeup_data")
require("game/famous_general/skill/general_skill_data")
require("game/famous_general/advance/advance_fazhen")
require("game/famous_general/advance/advance_guangwu")
require("game/famous_general/special/special_general_data")
require("game/famous_general/special/special_general_view")

FamousGeneralCtrl = FamousGeneralCtrl or BaseClass(BaseController)

function FamousGeneralCtrl:__init()
	if FamousGeneralCtrl.Instance ~= nil then
		print_error("[FamousGeneralCtrl] attempt to create singleton twice!")
		return
	end
	FamousGeneralCtrl.Instance = self
	self.select_index = 0
	self.is_bianshen = false
	self:RegisterAllProtocols()

	self.view = FamousGeneralView.New(ViewName.FamousGeneralView)
	self.fazhen_view = FamousGeneralFaZhenView.New(ViewName.FamousGeneralFaZhenView)
	self.guangwu_view = FamousGeneralGuangWuView.New(ViewName.FamousGeneralGuangWuView)
	self.data = FamousGeneralData.New()
	self.skill_data = GeneralSkillData.New()
	self.wake_data = FamousGeneralWakeUpData.New()
	self.focus_data = WakeUpFocusData.New()

	self.talent_data = FamousTalentData.New()
	self.talent_bag_view = FamousTalentBagView.New(ViewName.FamousTalentBagView)
	self.talent_upgrade_view = FamousTalentUpgradeView.New(ViewName.FamousTalentUpgradeView)
	self.talent_skill_upgrade_view = FamousTalentSkillUpgradeView.New(ViewName.FamousTalentSkillUpgradeView)
	self.focus_view = WakeUpFocusView.New(ViewName.WakeUpFocusView)

	self.special_general_data = SpecialGeneralData.New()
	self.special_general_view = SpecialGeneralView.New(ViewName.SpecialGeneralView)

	self:BindGlobalEvent(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.OnMainuiComplete, self))
	self.item_change_callback = BindTool.Bind(self.OnItemChange, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.item_change_callback)
end

function FamousGeneralCtrl:__delete()
	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.talent_data then
		self.talent_data:DeleteMe()
		self.talent_data = nil
	end

	if self.talent_bag_view then
		self.talent_bag_view:DeleteMe()
		self.talent_bag_view = nil
	end

	if self.talent_upgrade_view ~= nil then
		self.talent_upgrade_view:DeleteMe()
		self.talent_upgrade_view = nil
	end

	if self.talent_skill_upgrade_view then
		self.talent_skill_upgrade_view:DeleteMe()
		self.talent_skill_upgrade_view = nil
	end

	if self.special_general_view then
		self.special_general_view:DeleteMe()
		self.special_general_view = nil
	end

	if self.special_general_data then
		self.special_general_data:DeleteMe()
		self.special_general_data = nil
	end

	if self.wake_data then
		self.wake_data:DeleteMe()
		self.wake_data = nil
	end

	if self.focus_view then
		self.focus_view:DeleteMe()
		self.focus_view = nil
	end
	if self.focus_data then
		self.focus_data:DeleteMe()
		self.focus_data = nil
	end
	ItemData.Instance:UnNotifyDataChangeCallBack(self.item_change_callback)
	FamousGeneralCtrl.Instance = nil
end

function FamousGeneralCtrl:RegisterAllProtocols()
	self:RegisterProtocol(CSGreateSoldierOpera)
	self:RegisterProtocol(SCGreateSoldierItemInfo, "OnGreateSoldierItemInfo")
	self:RegisterProtocol(SCGreateSoldierOtherInfo, "OnGreateSoldierOtherInfo")
	self:RegisterProtocol(SCGreateSoldierSlotInfo, "OnGreateSoldierSlotInfo")

	self:RegisterProtocol(CSTalentOperaReqAll)
	self:RegisterProtocol(SCTalentAllInfo, "OnTalentAllInfo")
	self:RegisterProtocol(SCTalentUpdateSingleGrid, "OnTalentUpdateSingleGrid")
	self:RegisterProtocol(SCTalentChoujiangPage, "OnTalentChoujiangPage")
	self:RegisterProtocol(SCTalentAttentionSkillID, "TalentAttentionSkillID")

end

-- 绑定事件bangding
function FamousGeneralCtrl:OnMainuiComplete()
	self:SendRequest(GREATE_SOLDIER_REQ_TYPE.GREATE_SOLDIER_REQ_TYPE_INFO)
	self:SendTalentOperaReq(TALENT_OPERATE_TYPE.TALENT_OPERATE_TYPE_INFO)
	self:SendTalentOperaReq(TALENT_OPERATE_TYPE.TALENT_OPERATE_TYPE_CHOUJIANG_INFO)
end

-- 绑定事件bangding
function FamousGeneralCtrl:OnItemChange(change_item_id, change_item_index, change_reason, put_reason, old_num, new_num, old_data)
	RemindManager.Instance:Fire(RemindName.General_Info)
	RemindManager.Instance:Fire(RemindName.General_Potential)
	self.view:Flush()
end

-- 名将信息xieyi
function FamousGeneralCtrl:OnGreateSoldierItemInfo(protocol)
	self.data:SetGreateSoldierItemInfo(protocol)
	self.view:Flush()
	RemindManager.Instance:Fire(RemindName.General_Info)
	RemindManager.Instance:Fire(RemindName.General_Potential)
end

function FamousGeneralCtrl:FlushAnim()
	self.view:Flush("anim")
end

--  名将苏醒xieyi
function FamousGeneralCtrl:OnTalentChoujiangPage(protocol)
	self.wake_data:SetTalentChoujiangPageInfo(protocol)
	self.view:Flush()
	self.view:GetChouJiangData()
	RemindManager.Instance:Fire(RemindName.FamousTalent)
end

--  名将其他信息xieyi
function FamousGeneralCtrl:OnGreateSoldierOtherInfo(protocol)
	self.skill_data:SetGreateSoldierOtherInfo(protocol)
	self.special_general_data:SetGeneralInfo(protocol)
	self.view:Flush()
	self:FlushSpecialFamousTipView()
	if protocol.cur_used_seq ~= -1 then
		self.is_bianshen = true
		self:ShowBianShen()
		MainUICtrl.Instance:FlushView("check_skill")
	end
	if protocol.main_slot_seq ~= -1 then
		MainUICtrl.Instance:FlushView("check_skill")
	end
	MainUICtrl.Instance:FlushView("flush_bianshen_cd")
	MainUICtrl.Instance:FlushView("general_bianshen", {"skill"})
end

-- 名将将位信息xieyi
function FamousGeneralCtrl:OnGreateSoldierSlotInfo(protocol)
end

-- 名将请求xieyi
function FamousGeneralCtrl:SendRequest(req_type, param_1, param_2, param_3)
	local protocol = ProtocolPool.Instance:GetProtocol(CSGreateSoldierOpera)
	protocol.req_type = req_type or 0
	protocol.param_1 = param_1 or 0
	protocol.param_2 = param_2 or 0
	protocol.param_3 = param_3 or 0
	protocol:EncodeAndSend()
end

-- xieyi
function FamousGeneralCtrl:OnTalentAllInfo(protocol)
	if nil == protocol.talent_info_list then return end
	
	self.talent_data:SetTalentAllInfo(protocol.talent_info_list)
	RemindManager.Instance:Fire(RemindName.FamousTalent)
	self.view:Flush()
	self.talent_upgrade_view:Flush()
	self.talent_skill_upgrade_view:Flush()
end

-- xieyi
function FamousGeneralCtrl:OnTalentUpdateSingleGrid(protocol)
	self.talent_data:SetTalentOneGridInfo(protocol)
	RemindManager.Instance:Fire(RemindName.FamousTalent)
	self.view:Flush()
	self.talent_upgrade_view:Flush()
	self.talent_skill_upgrade_view:Flush()
end

-- xieyi
function FamousGeneralCtrl:SendTalentOperaReq(operate_type, param_1, param_2, param_3)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSTalentOperaReqAll)
	send_protocol.operate_type = operate_type or 0
	send_protocol.param_1 = param_1 or 0
	send_protocol.param_2 = param_2 or 0
	send_protocol.param_3 = param_3 or 0
	send_protocol:EncodeAndSend()
end

-- xieyi
function FamousGeneralCtrl:TalentAttentionSkillID(protocol)
	self.focus_data:SetData(protocol)
	self.view:Flush()
end


function FamousGeneralCtrl:OpenTalentSkillUpgradeView(select_info)
	self.talent_skill_upgrade_view:SetSelectInfo(select_info)
	self.talent_skill_upgrade_view:Open()
end

function FamousGeneralCtrl:OpenTalentUpgradeView(select_info)
	self.talent_upgrade_view:SetSelectInfo(select_info)
	self.talent_upgrade_view:Open()
end

function FamousGeneralCtrl:FlushView(viewname, reason)
	self.view:Flush(viewname, {reason})
end

function FamousGeneralCtrl:CheckEffect(res_id, obj)
	if res_id == nil or obj == nil then
		print_error("屏蔽特效失败")
		return
	end

	local general_list = FamousGeneralData.Instance:GetSortGeneralList()
	for k,v in pairs(general_list) do
		if v.model_res_id == res_id then
			local fazhen_objs = FindObjsByName(obj.transform, "fazhen_effect")
			local weapon_objs = FindObjsByName(obj.transform, "weapon_effect")
			for k1,v1 in ipairs(fazhen_objs) do
				v1.gameObject:SetActive(FamousGeneralData.Instance:IsShowFaZhen(k))
			end

			for k2,v2 in ipairs(weapon_objs) do
				v2.gameObject:SetActive(FamousGeneralData.Instance:IsShowGuangWu(k))
			end

			break
		end
	end
end

function FamousGeneralCtrl:ShowBianShen(cur_use_imageid)
	local prefab = PreloadManager.Instance:GetPrefab("uis/views/miscpreload_prefab", "PaintingEffect")
	local obj = GameObject.Instantiate(prefab)	
	local obj_transform = obj.transform
	obj_transform:SetParent(UIRoot, false)

	local tab = obj:GetComponent(typeof(UIVariableTable))
	local animator = obj:GetComponent(typeof(UnityEngine.Animator))
	local raw_image = tab:FindVariable("ShowBG")
	raw_image_left = tab:FindVariable("ShowBGLeft")
	if cur_use_imageid then
		local ues_seq = FamousGeneralData.Instance:GetSeqByImageId(cur_use_imageid)
		local bundle, asset = ResPath.GetRawImage("BianShen_" .. ues_seq .. ".png")
		raw_image:SetAsset(bundle, asset)
		bundle, asset = ResPath.GetRawImage("effect_left" .. ".png")
		raw_image_left:SetAsset(bundle, asset)
		animator:ListenEvent("EffectStop", function ()
			GameObject.Destroy(obj)
		end)
	else
		local use_seq = GeneralSkillData.Instance:GetCurUseSeq()
		local is_use, cur_used_special_img_id = SpecialGeneralData.Instance:GetCurIsUsedSpecialImgIdAndSpecialImgId()
		if is_use then						--使用特殊天神(幻化形象)
			use_seq = cur_used_special_img_id
		end

		local bundle, asset = ResPath.GetRawImage("BianShen_" .. use_seq .. ".png")
		raw_image:SetAsset(bundle, asset)
		bundle, asset = ResPath.GetRawImage("effect_left" .. ".png")
		raw_image_left:SetAsset(bundle, asset)
		animator:ListenEvent("EffectStop", function ()
		GameObject.Destroy(obj)
		end)
	end
	
end

function FamousGeneralCtrl:FlushModel()
	self.view:Flush("flush_model")
end

function FamousGeneralCtrl:GetMainViewShowIndex()
	if self.view then
		return self.view:GetShowIndex()
	end
end

function FamousGeneralCtrl:ShowPotentialEffect()
	if self.view and self.view:IsOpen() then
		self.view:ShowPotentialEffect()
	end
end

function FamousGeneralCtrl:SetGeneralAnim()
	if self.view and self.view:IsOpen() then
		self.view:SetInfoAnim()
	end
end

function FamousGeneralCtrl:ShowInfoEffect()
	if self.view and self.view:IsOpen() then
		self.view:ShowInfoEffect()
	end
end

function FamousGeneralCtrl:ShowGuangwuEffect()
	if self.guangwu_view and self.guangwu_view:IsOpen() then
		self.guangwu_view:ShowEffect()
	end
end

function FamousGeneralCtrl:ShowFaZhenEffect()
	if self.fazhen_view and self.fazhen_view:IsOpen() then
		self.fazhen_view:ShowEffect()
	end
end

function FamousGeneralCtrl:CheckBianShen()
	if self:CheckFlag() and not self.guaiji_send then
		print_error(GeneralSkillData.Instance:CheckShowSkill(), GeneralSkillData.Instance:GetBianShenCds(), MainUICtrl.Instance:GetGeneralCD(), GeneralSkillData.Instance:GetBianShenTime(), MainUICtrl.Instance:GetShowGeneral(), self.guaiji_send)
		self:SendRequest(GREATE_SOLDIER_REQ_TYPE.GREATE_SOLDIER_REQ_TYPE_BIANSHEN)
		self.guaiji_send = true
		GlobalTimerQuest:AddDelayTimer(function ()
			self.guaiji_send = false
		end,1)
		return true
	else
		return false
	end
end

function FamousGeneralCtrl:CheckFlag()
	if not SettingData.Instance:GetSettingData(SETTING_TYPE.AUTO_USE_GENERAL_SKILL) then
		return false
	end
	if GeneralSkillData.Instance:CheckShowSkill() then
		if GeneralSkillData.Instance:GetBianShenCds() <= 0 or MainUICtrl.Instance:GetGeneralCD() <= 0 then
			if GeneralSkillData.Instance:GetBianShenTime() <= 0 then 
				if GeneralSkillData.Instance:GetCurUseSeq() == -1 then
					if MainUICtrl.Instance:GetShowGeneral() then
						return true
					end
				end
			end
		end
	end
	return false
end

--打开特殊名将提示面板
function FamousGeneralCtrl:OpenSpecialFamousTipView(data)
	if self.special_general_view and not self.special_general_view:IsOpen() and data then
		self.special_general_view:SetData(data)
	end
end

--刷新特殊名将提示面板
function FamousGeneralCtrl:FlushSpecialFamousTipView()
	if self.special_general_view and self.special_general_view:IsOpen()then
		self.special_general_view:Flush()
	end
	RemindManager.Instance:Fire(RemindName.General_Info)
end