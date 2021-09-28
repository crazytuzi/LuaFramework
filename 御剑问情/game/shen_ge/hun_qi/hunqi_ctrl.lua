require("game/shen_ge/hun_qi/hunqi_data")
require("game/shen_ge/hun_qi/skill_tips")
require("game/shen_ge/hun_qi/damo_exchange_tips")
require("game/shen_ge/hun_qi/hunqi_view")
require("game/shen_ge/hun_qi/soul_allattr_view")
require("game/shen_ge/hun_qi/hunyin_suit_view")
require("game/shen_ge/hun_qi/hunyin_resolve_view")
require("game/shen_ge/hun_qi/hunyin_all_view")
require("game/shen_ge/hun_qi/hunyin_exchange_view")
require("game/shen_ge/hun_qi/hunyin_replace_tips_view")
require("game/shen_ge/hun_qi/hunyin_inlay_tips_view")
require("game/shen_ge/hun_qi/gather_soul_view")
require("game/shen_ge/hun_qi/select_stuff_view")

HunQiCtrl = HunQiCtrl or BaseClass(BaseController)

function HunQiCtrl:__init()
	if nil ~= HunQiCtrl.Instance then
		return
	end

	HunQiCtrl.Instance = self

	self.data = HunQiData.New()
	self.skill_tips_view = SkillTipsView.New(ViewName.HunQiSkillTips)
	self.damo_exchange_tips = DaMoExChangeTips.New(ViewName.DaMoExChangeTips)
	self.view = HunQiView.New(ViewName.HunQiView)
	self.soul_allattr_view = SoulAllAttrView.New(ViewName.SoulAllAttrView)
	self.hunyin_suit_view = HunYinSuitView.New(ViewName.HunYinSuitView)
	self.hunyin_resolve_view = HunYinResolve.New(ViewName.HunYinResolve)
	self.hunyin_all_view = HunYinAllView.New(ViewName.HunYinAllView)
	self.hunyin_exchange_view = HunYinExchangView.New(ViewName.HunYinExchangView)
	self.hunyin_replace_tips_view = HunYinReplaceTipsView.New(ViewName.HunYinReplaceTipsView)
	self.hunyin_inlay_tips_view = HunYinInlayTips.New(ViewName.HunYinInlayTips)
	self.gather_soul_view = GatherSoulView.New(ViewName.GatherSoulView)
	self.hunyin_select_stuff_view = SelectStuffView.New(ViewName.HunQiXiLianStuffView)

	self:RegisterAllProtocols()

	self.baozang_time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.BaoZangCD, self), 1)

	
	self.curent_open_box_type = 1;  --宝藏开启的类型，1或10
end

function HunQiCtrl:__delete()
	HunQiCtrl.Instance = nil

	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.skill_tips_view then
		self.skill_tips_view:DeleteMe()
		self.skill_tips_view = nil
	end

	if self.damo_exchange_tips then
		self.damo_exchange_tips:DeleteMe()
		self.damo_exchange_tips = nil
	end

	if self.soul_allattr_view then
		self.soul_allattr_view:DeleteMe()
		self.soul_allattr_view = nil
	end

	if self.hunyin_suit_view then
		self.hunyin_suit_view:DeleteMe()
		self.hunyin_suit_view = nil
	end

	if self.hunyin_resolve_view then
		self.hunyin_resolve_view:DeleteMe()
		self.hunyin_resolve_view = nil
	end

	if self.hunyin_all_view then
		self.hunyin_all_view:DeleteMe()
		self.hunyin_all_view = nil
	end

	if self.hunyin_exchange_view then
		self.hunyin_exchange_view:DeleteMe()
		self.hunyin_exchange_view = nil
	end

	if self.hunyin_replace_tips_view then
		self.hunyin_replace_tips_view:DeleteMe()
		self.hunyin_replace_tips_view = nil
	end

	if self.hunyin_inlay_tips_view then
		self.hunyin_inlay_tips_view:DeleteMe()
		self.hunyin_inlay_tips_view = nil
	end

	if self.gather_soul_view then
		self.gather_soul_view:DeleteMe()
		self.gather_soul_view = nil
	end

	if self.hunyin_select_stuff_view then
		self.hunyin_select_stuff_view:DeleteMe()
		self.hunyin_select_stuff_view = nil
	end

	if self.baozang_time_quest then
		GlobalTimerQuest:CancelQuest(self.baozang_time_quest)
		self.baozang_time_quest = nil
	end

	if self.delay_baozang_time_quest then
		GlobalTimerQuest:CancelQuest(self.delay_baozang_time_quest)
		self.delay_baozang_time_quest = nil
	end
end

function HunQiCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCShenzhouWeapondAllInfo, "OnShenzhouWeapondAllInfo") 							--魂器信息
	self:RegisterProtocol(SCShenzhouBoxInfo, "OnShenzhouBoxInfo") 											--魂器宝箱信息
	self:RegisterProtocol(SCShenzhouSpecialHunyinInfo, "OnSCShenzhouSpecialHunyinInfo")						--特殊签文
	self:RegisterProtocol(CSSHenzhouWeaponOperaReq)
	self:RegisterProtocol(CSSHenzhouWeaponOneKeyIdentifyReq)												--一键鉴定
	self:RegisterProtocol(CSShenzhouHunyinResolveReq)														--魂印分解
end

function HunQiCtrl:OnShenzhouWeapondAllInfo(protocol)
	self.data:SetHunQiAllInfo(protocol)
	if self.view:IsOpen() then
		self.view:Flush("hunqi")
		self.view:Flush("damo")
		self.view:Flush("juling")
		self.view:Flush("xilian")
		self.view:Flush("resolve")
		if not self.hunyin_resolve_view:IsOpen() then
			self.view:Flush("hunyin")
		end
	end

	self.gather_soul_view:Flush()
	
	if self.damo_exchange_tips:IsOpen() then
		self.damo_exchange_tips:Flush()
	end
	if self.hunyin_resolve_view:IsOpen() then
		self.hunyin_resolve_view:Flush("beibao")
	end
	RemindManager.Instance:Fire(RemindName.HunYin_LingShu)
	RemindManager.Instance:Fire(RemindName.HunQi_XiLian)
end

function HunQiCtrl:OnShenzhouBoxInfo(protocol)
	self.data:SetBaoZangInfo(protocol)
	RemindManager.Instance:Fire(RemindName.HunQi_BaoZang)
	if self.view:IsOpen() then
		self.view:Flush("baozang")
	end
end

-- 特殊魂印信息返回
function HunQiCtrl:OnSCShenzhouSpecialHunyinInfo(protocol)
	self.data:SetSpecialHunyinInfo(protocol)
	if self.view:IsOpen() then
		self.view:Flush("hunyin")
	end
end

-- 一键鉴定
function HunQiCtrl:SendOneKeyOperaReq()
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSSHenzhouWeaponOneKeyIdentifyReq)
	send_protocol:EncodeAndSend()
end

-- 魂器操作请求
function HunQiCtrl:SendHunQiOperaReq(opera_type, param1, param2, param3, param4, param5)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSSHenzhouWeaponOperaReq)
	send_protocol.opera_type = opera_type or 0
	send_protocol.param_1 = param1 or 0
	send_protocol.param_2 = param2 or 0
	send_protocol.param_3 = param3 or 0
	send_protocol.param_4 = param4 or 0
	send_protocol.param_5 = param5 or 0
	send_protocol:EncodeAndSend()
end

-- 魂印分解请求
function HunQiCtrl:SendHunYiResolveReq(index_count, index_in_bag_list)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSShenzhouHunyinResolveReq)
	send_protocol.index_count = index_count or 0
	send_protocol.index_in_bag_list = index_in_bag_list or {}
	send_protocol:EncodeAndSend()
end

--展示技能描述
function HunQiCtrl:ShowSkillTips(skill_name, skill_level, now_des, next_des, levelup_des, asset, bunble)
	self.skill_tips_view:SetSkillName(skill_name)
	self.skill_tips_view:SetSkillLevel(skill_level)
	self.skill_tips_view:SetNowDes(now_des)
	self.skill_tips_view:SetNextDes(next_des)
	self.skill_tips_view:SetLevelUpDes(levelup_des)
	self.skill_tips_view:SetSkillRes(asset, bunble)
	self.skill_tips_view:Open()
end

function HunQiCtrl:FlushHunQiTimes()
	if self.view:IsOpen() then
		self.view:Flush("gather_time")
	end
end

function HunQiCtrl:HunQiUpGrade(result)
	if self.view:IsOpen() then
		self.view:Flush("hunqi_upgrade", {result})
	end
end

function HunQiCtrl:ShowSoulAttrView(hunqi_index)
	self.soul_allattr_view:SetHunQiIndex(hunqi_index)
	self.soul_allattr_view:Open()
end

function HunQiCtrl:BaoZangCD()
	if RemindManager.Instance:GetRemind(RemindName.HunQi_BaoZang) > 0 then
		return
	end
	if self.data:GetTodayOpenFreeBoxNum() < self.data:GetMaxFreeBoxTimes() then
		local server_time = TimeCtrl.Instance:GetServerTime()
		local times = server_time - self.data:GetLastOpenFreeBoxTimeStamp()
		if times >= self.data:GetFreeBoxCD() then
			RemindManager.Instance:Fire(RemindName.HunQi_BaoZang)
		end
	end
end

function HunQiCtrl:SetReplaceCallBack(callback)
	self.hunyin_replace_tips_view:SetCloseCallBack(callback)
end

function HunQiCtrl:SetReplaceOpenCallBack(callback)
	self.hunyin_replace_tips_view:SetOpenCallBack(callback)
end

function HunQiCtrl:SetInlayCallBack(callback)
	self.hunyin_inlay_tips_view:SetCloseCallBack(callback)
end

function HunQiCtrl:SetInlayOpenCallBack(callback)
	self.hunyin_inlay_tips_view:SetOpenCallBack(callback)
end

function HunQiCtrl:SetSuitOpenCallBack(callback)
	self.hunyin_suit_view:SetOpenCallBack(callback)
end

--发送协助宝藏协议
function HunQiCtrl:CheckToSendHelpBox()
	--没有宝箱无法请求协助
	local box_id = self.data:GetBoxId()
	if box_id <= 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.HunQi.NotHaveBaoXiang)
		return
	end

	if self.delay_baozang_time_quest then
		--有计时器存在弹错误码
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.OperaTooFast)
		return
	end

	local help_num = 0
	local function start_time_quest()
		self.delay_baozang_time_quest = GlobalTimerQuest:AddDelayTimer(function()
			if help_num >= HunQiData.BAOZANG_HELP_NUM then
				GlobalTimerQuest:CancelQuest(self.delay_baozang_time_quest)
				self.delay_baozang_time_quest = nil
				return
			end
			help_num = help_num + 1

			HunQiCtrl.Instance:SendHunQiOperaReq(SHENZHOU_REQ_TYPE.SHENZHOU_REQ_TYPE_INVITE_HELP_OTHER_BOX)
			
			start_time_quest()
		end, math.random(1, 2))
	end
	start_time_quest()
	SysMsgCtrl.Instance:ErrorRemind(Language.HunQi.HelpTextSuc)
end

function HunQiCtrl:GetCurrentSelectHunQi()
	return self.view:GetCurrentSelectHunQi()
end