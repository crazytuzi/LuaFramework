require("scripts/game/advanced_level/advanced_level_data")
require("scripts/game/advanced_level/advanced_level_view")
require("scripts/game/advanced_level/advanced_level_moshu_up_view")
AdvancedLevelCtrl = AdvancedLevelCtrl or BaseClass(BaseController)

function AdvancedLevelCtrl:__init()
	if AdvancedLevelCtrl.Instance then
		ErrorLog("[AdvancedLevelCtrl] attempt to create singleton twice!")
		return
	end
	AdvancedLevelCtrl.Instance = self

	self.data =  AdvancedLevelData.New()
	self.view = AdvancedLevelView.New(ViewDef.Advanced)
	self.zizhi_view = AdVancedLevelMoshuUpView.New(ViewDef.AdVanced_Tips) 
	self:RegisterAllProtocols()
end

function AdvancedLevelCtrl:__delete()
	AdvancedLevelCtrl.Instance = nil
	
	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end
	if self.view then
		self.view:DeleteMe()
		self.view = nil 
	end
	if self.zizhi_view then
		self.zizhi_view:DeleteMe()
		self.zizhi_view = nil 
	end

	if self.time_quest ~= nil then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil 
	end	
end

-- AdvancedLevelCtrl:RegisterAllProtocols()
-- 	self:RegisterProtocol(SCBabelData, "OnBabelData")
-- 	self:RegisterProtocol(SCBabelRankingListData, "OnBabelRankingListData")
-- 	GlobalEventSystem:Bind(SceneEventType.SCENE_LOADING_STATE_ENTER, BindTool.Bind(self.OnSceneLoadingStateEnter, self))

-- 	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.TongTianTaSangdang)
-- 	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.TongTiantaChouJiang)

-- -- 	[RemindName.TongTianTaSangdang] = {RemindGroupName.TrialView, RemindGroupName.BabelTabbar},
-- -- 	[RemindName.TongTiantaChouJiang] = {RemindGroupName.TrialView, RemindGroupName.BabelTabbar},
--end


function AdvancedLevelCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCInnerEquipResult, "OnInnerEquipResult")
	self:RegisterProtocol(SCInnerEquipData, "OnInnerEquipData")

	--元素
	self:RegisterProtocol(SCCrestInfo, "OnCrestInfo")
	self:RegisterProtocol(SCUpCrestSlotResult, "OnUpCrestSlotResult")

	--圣兽升级
	self:RegisterProtocol(SCMeridiansResult, "OnSCMeridiansResult")

	self:BindGlobalEvent(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.OnRecvMainRoleInfo))

	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.YuanSuCanUp)
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.MoshuCanUp)
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.MoShuGuanliang)
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindNum, self), RemindName.ShengShouCanup)

	EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.RoleDataChangeCallback, self))
	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.ItemDataListChangeCallback, self))
	self.is_had_yuansu = false
	self.is_had_shengshou = false
end


function AdvancedLevelCtrl:OnInnerEquipResult(protocol)
	self.data:SetEquipNum(protocol.slot, protocol.item_num)
	RemindManager.Instance:DoRemindDelayTime(RemindName.MoShuGuanliang, 0.2)
end

function AdvancedLevelCtrl:OnInnerEquipData(protocol)
	for k, v in pairs(protocol.slot_list) do
		self.data:SetEquipNum(k, v)
	end
	RemindManager.Instance:DoRemindDelayTime(RemindName.MoShuGuanliang, 0.2)
end

--内功升级请求
function AdvancedLevelCtrl.SendInnerUpReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSInnerUpReq)
	protocol:EncodeAndSend()
end

--内功一键升级请求
function AdvancedLevelCtrl.SendInnerOneKeyUpReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSInnerOneKeyUpReq)
	protocol:EncodeAndSend()
end

--内功资质注入
function AdvancedLevelCtrl.SendInnerEquipReq(series)
	local protocol = ProtocolPool.Instance:GetProtocol(CSInnerEquip)
	protocol.series = series
	protocol:EncodeAndSend()
end


function AdvancedLevelCtrl:OpenView(data)
	if self.zizhi_view then
		self.zizhi_view:Open()
		self.zizhi_view:SetData(data)
	end
end


function AdvancedLevelCtrl:OnRecvMainRoleInfo( ... )
	GlobalTimerQuest:AddDelayTimer(function ()
		RemindManager.Instance:DoRemindDelayTime(RemindName.MoshuCanUp, 0.1)
		if ViewManager.Instance:CanOpen(ViewDef.Advanced.YuanSu) then --面板开放才请求协议
			AdvancedLevelCtrl.SendCrestInfoReq()
		end
		if ViewManager.Instance:CanOpen(ViewDef.Advanced.ShengShou) then
			AdvancedLevelCtrl.Instance:SendMeridiansReq(1)
		end
		end, 2)
end

--元素
function AdvancedLevelCtrl.SendCrestInfoReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSCrestInfoReq)
	protocol:EncodeAndSend()
end

function AdvancedLevelCtrl.SendUpCrestSlotReq(slot)
	local protocol = ProtocolPool.Instance:GetProtocol(CSUpCrestSlotReq)
	protocol.crest_slot = slot
	protocol:EncodeAndSend()
end

--所有数据
function AdvancedLevelCtrl:OnCrestInfo(protocol)
	self.data:SetCrestInfo(protocol)
	RemindManager.Instance:DoRemindDelayTime(RemindName.YuanSuCanUp, 0.2)
	self.is_had_yuansu = true
end

--单个升级结果
function AdvancedLevelCtrl:OnUpCrestSlotResult(protocol)
	self.data:SetUpCrestSlotResult(protocol)
	RemindManager.Instance:DoRemindDelayTime(RemindName.YuanSuCanUp, 0.2)
end

--圣兽升级 -- 原经脉系统
function AdvancedLevelCtrl:SendMeridiansReq(index)
	local protocol = ProtocolPool.Instance:GetProtocol(CSSendMeridiansReq)
	protocol.index = index
	protocol:EncodeAndSend()
end

--
function AdvancedLevelCtrl:OnSCMeridiansResult(protocol)
	self.data:SetMeridiansResult(protocol)
	self.is_had_shengshou = true
	RemindManager.Instance:DoRemindDelayTime(RemindName.ShengShouCanup, 0.2)
end


function AdvancedLevelCtrl:RoleDataChangeCallback(vo)
	if vo.key == OBJ_ATTR.ACTOR_INNER_LEVEL or vo.key == OBJ_ATTR.ACTOR_STONE or vo.key == OBJ_ATTR.ACTOR_INNER_EXP then
		RemindManager.Instance:DoRemindDelayTime(RemindName.MoshuCanUp, 0.1)
	elseif vo.key == OBJ_ATTR.ACTOR_ENERGY then
		RemindManager.Instance:DoRemindDelayTime(RemindName.ShengShouCanup, 0.1)
	elseif vo.key == OBJ_ATTR.CREATURE_LEVEL or vo.key == OBJ_ATTR.ACTOR_CIRCLE then
		
		if self.time_quest ~= nil then
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil 
		end	

		self.time_quest	 = GlobalTimerQuest:AddDelayTimer(function ()
			if ViewManager.Instance:CanOpen(ViewDef.Advanced.YuanSu) then --再线请求上线未请求到的数据 --延时发送请求数据
				if not self.is_had_yuansu then --
					AdvancedLevelCtrl.SendCrestInfoReq()
				end
			end
			if ViewManager.Instance:CanOpen(ViewDef.Advanced.ShengShou) then --再线请求上线未请求到的数据 -- 延时发送请求数据
				if not self.is_had_shengshou then --
					AdvancedLevelCtrl.Instance:SendMeridiansReq(1)
				end
			end
		end, 2)
	end
end

function AdvancedLevelCtrl:ItemDataListChangeCallback()
	RemindManager.Instance:DoRemindDelayTime(RemindName.YuanSuCanUp, 0.2)
	RemindManager.Instance:DoRemindDelayTime(RemindName.MoShuGuanliang, 0.2)
end


function AdvancedLevelCtrl:GetRemindNum(remind_name)
	if remind_name ==  RemindName.YuanSuCanUp then
		return self.data:GetCanUpYuansu()
	elseif  remind_name == RemindName.MoshuCanUp then
		return self.data:GetMoshuCanUp()
	elseif remind_name == RemindName.MoShuGuanliang then
		return self.data:GetCanGuangliang()
	elseif remind_name == RemindName.ShengShouCanup then
		return self.data:GetIsCanUp()
	end
end