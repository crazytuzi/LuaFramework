require('scripts/game/practice/practice_win_view')
require('scripts/game/practice/practice_lose_view')

PracticeCtrl = PracticeCtrl or BaseClass(BaseController)

function PracticeCtrl:__init()
	if PracticeCtrl.Instance then
		ErrorLog("[PracticeCtrl]:Attempt to create singleton twice!")
	end
	PracticeCtrl.Instance = self
	self.cur_bless = 0 --祝福值
	self.need_bless = 0	--当前关卡最大祝福值
	self.gate_lev = 0	--关卡等级
	self.win_view = PracticeWinView.New(ViewDef.PracticeWin) --胜利面板
	self.lose_win = PracticeLoseView.New(ViewDef.PracticeLose)
	local role_vo = GameVoManager.Instance:GetMainRoleVo()
	self.gate_lev = role_vo[OBJ_ATTR.ACTOR_SOUL2] or 0
	self:RegisterAllEvents();
end	

function PracticeCtrl:__delete()
	PracticeCtrl.Instance = nil
end

function PracticeCtrl:RegisterAllEvents()
	self:RegisterProtocol(SCPracticeInfo,"OnPracticeInfo")
	self:RegisterProtocol(SCPracticeRefreshBless,"OnChangeBless")
	EventProxy.New(RoleData.Instance, self):AddEventListener(OBJ_ATTR.ACTOR_SOUL2, BindTool.Bind(self.OnAttChange, self))
end

function PracticeCtrl:OnAttChange()
	local role_vo = GameVoManager.Instance:GetMainRoleVo()
	self.gate_lev = role_vo[OBJ_ATTR.ACTOR_SOUL2] or 0
	self:UpdateView()
end

function PracticeCtrl:UpdateView()

end

function PracticeCtrl:OnPracticeInfo(protocol)
	local type = protocol.type;
	local decode_data = protocol.decode_data[type];
	if 1 == type then
		self:OnEnterPracticeInfo(decode_data.next_floor,decode_data.cur_bless,decode_data.need_bless);
		GlobalEventSystem:Fire(OtherEventType.TARGET_HEAD_CHANGE, true)
	elseif 2 == type then
		self:OnChallengeResult(decode_data.panel_type,decode_data.awards);
	elseif 3 == type then
		self:MoveToTransfer()
	end
end

function PracticeCtrl:MoveToTransfer()
	local scene_cfg = Scene.Instance:GetSceneConfig()
	if scene_cfg then
		local decoration = scene_cfg.decorations
		if next(decoration) then
			GuajiCtrl.Instance:ClearAllOperate()
			GlobalTimerQuest:AddDelayTimer(function()
				MoveCache.end_type = MoveEndType.PracticeTP
				GuajiCtrl.Instance:MoveToPos(scene_cfg.id, decoration[1].x, decoration[1].y, 1)
			end,1)
		end
	end
end

function PracticeCtrl:OnChangeBless(protocol)
	self.cur_bless = protocol.cur_bless
	self.need_bless = protocol.need_bless
	GlobalEventSystem:Fire(OtherEventType.PRACTICE_BLESS_CHANGE)
	if (self.cur_bless == self.need_bless) and BagData.Instance:GetBagGridNum() - BagData.Instance:GetBagItemCount() < 20 then
		PracticeCtrl.SendEnterPractice(EnterPracticeTab.cEnterFloor)
	end
end

function PracticeCtrl:OnEnterPracticeInfo(gate_lev, cur_bless, need_bless)
	self.gate_lev = gate_lev
	self.cur_bless = cur_bless
	self.need_bless = need_bless
end

function PracticeCtrl:OnChallengeResult(result_code,awards)
	if 1 == result_code then  -- 胜利
		self:OnChallengeSuccess()
	elseif 0 == result_code then --失败
		self.lose_win:SetData(1, 10, function ()
			PracticeCtrl.SendEnterPractice(3) end)
		self.lose_win:Open()
	end
end

function PracticeCtrl:OnChallengeSuccess()
	GuajiCtrl.Instance:SetGuajiType(GuajiType.None)
	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
	self.cur_pick_fuben_id = main_role_vo.fb_id

	local function pick_fun()
		local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
		local fuben_id = main_role_vo.fb_id
		if self.cur_pick_fuben_id == fuben_id then
			Scene.Instance:PickAllItemByFly(function(awards) 
				PracticeCtrl.Instance:ShowWinPanel(awards, fuben_id, function() 
					FubenCtrl.OutFubenReq(fuben_id)
				end)
			end,0.6)
		end
	end
	GlobalTimerQuest:AddDelayTimer(pick_fun,1)
end

--打开胜利面板
function PracticeCtrl:ShowWinPanel(awards, fb_id, callback)
	if self.win_view then
		self.win_view:SetData(awards, fb_id, callback)
		ViewManager.Instance:OpenViewByDef(ViewDef.PracticeWin)
	end
end

--打开失败面板
function PracticeCtrl:ShowLosePanel(streng_type,cd_time,callback)
	if self.lose_win then
		self.lose_win:SetData(streng_type,cd_time,callback)
		self.lose_win:Open()
	end
end

EnterPracticeTab = 
{
	cEnterMap = 1,		--请求进入试炼地图
	cEnterFloor = 2,	--请求进入试炼关卡
	cOutFloor = 3,		--请求退出试炼关卡
}
--进入试炼副本
function PracticeCtrl.SendEnterPractice(enter_type)
	if BagData.Instance:GetBagGridNum() - BagData.Instance:GetBagItemCount() < 20 and (enter_type == EnterPracticeTab.cEnterMap or enter_type == EnterPracticeTab.cEnterFloor) then
		Scene.Instance:GetMainRole():StopMove()
		local start_alert = Alert.New()
		start_alert:SetLableString(string.format(Language.Fuben.NoEnoughGrid, 20))
		start_alert:SetOkFunc(function()
			ViewManager.Instance:OpenViewByDef(ViewDef.Recycle)
		end)
		-- self.start_alert:SetShowCheckBox(false)
		start_alert:SetOkString(Language.Fuben.GotoRecycle)
		start_alert:Open()
	else
		if enter_type == EnterPracticeTab.cOutFloor then GuajiCtrl.Instance:SetGuajiType(GuajiType.None) end --失败回到主城 切换挂机状态
		if enter_type == EnterPracticeTab.cEnterFloor and false == PracticeCtrl.Instance:CheckCanEnterParctice(true) then return end
		local protocol = ProtocolPool.Instance:GetProtocol(CSEnterPracticeReq)
		protocol.type = enter_type
		protocol:EncodeAndSend()
	end
end

--是否在试炼副本
-- function PracticeCtrl.IsInPracticeMap()
-- 	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
-- 	local scene_id = main_role_vo.scene_id
-- 	local scene_list = TrialMapConfig.tabSceneId
-- 	for k,v in pairs(scene_list) do
-- 		if v.nSceneId == scene_id then return true end
-- 	end
-- 	return false
-- end

--是否在试炼关卡
-- function PracticeCtrl.IsInPracticeGate()
-- 	local main_role_vo = GameVoManager.Instance:GetMainRoleVo()
-- 	local fuben_id = main_role_vo.fb_id
-- 	local floor = TrialFloorConfig.Floor
-- 	for i,v in ipairs(floor) do
-- 		if v.nFbId == fuben_id then
-- 			return true
-- 		end
-- 	end
-- 	return false
-- end

function PracticeCtrl.OnEnterFailCallback(type)
	if type == 1 then  --打开转生面板
		ViewManager.Instance:OpenViewByDef(ViewDef.Role.ZhuanSheng)
	elseif type == 2 then  --打开熔炼面板
		ViewManager.Instance:OpenViewByDef(ViewDef.Recycle)
	end
end

--是否能进入试炼关卡
function PracticeCtrl:CheckCanEnterParctice (isTips)
	-- body
	local b = self.cur_bless >= self.need_bless
	local role_vo = GameVoManager.Instance:GetMainRoleVo()
	local gate_lev = role_vo[OBJ_ATTR.ACTOR_SOUL2] or 0
	local circle = role_vo[OBJ_ATTR.ACTOR_CIRCLE] or 0
	local empty_num = BagData.Instance:GetEmptyNum()
	local cfg = TrialMapConfig
	local nJourneyMult = TrialMapConfig.nJourneyMult
	local scene = TrialFloorConfig.Floor[gate_lev+1]
	if scene then
		if b == false and isTips then
			SysMsgCtrl.Instance:ErrorRemind(Language.Practice.BlessNOEnough)	
			return false
		end

		if circle < scene.circle then --转生等级不足 弹出转生面板
			self.pop_alert = self.pop_alert or Alert.New()
			self.pop_alert:SetLableString(string.format(Language.Practice.CircleNOEnough, scene.circle))
			self.pop_alert:SetOkFunc(BindTool.Bind1(function ()
				PracticeCtrl.OnEnterFailCallback(1)
			end, self))
			self.pop_alert:SetOkString(Language.Common.Confirm)
			self.pop_alert:Open()
			return true  --修改服务端自动挑战挂卡属性
		end

		if empty_num < 20 then  --背包格子不足  弹出熔炼关卡
			self.pop_alert = self.pop_alert or Alert.New()
			self.pop_alert:SetLableString(string.format(Language.Practice.BagGridNoEnough, 20))
			self.pop_alert:SetOkFunc(BindTool.Bind1(function ()
				PracticeCtrl.OnEnterFailCallback(2)
			end, self))
			self.pop_alert:SetOkString(Language.Common.Confirm)
			self.pop_alert:Open()
			return true -- 修改服务端自动挑战挂卡属性
		end

		return b
	end
	return false
end