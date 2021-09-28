RegistModules("Tianti/TiantiConst")
RegistModules("Tianti/Vo/TiantiVo")

RegistModules("Tianti/View/TiantiItem")
RegistModules("Tianti/View/TiantiOwnerRankItem")
RegistModules("Tianti/View/TiantiStar")
RegistModules("Tianti/View/TiantiLevelLogo")
RegistModules("Tianti/View/PoPFinishTianti")
RegistModules("Tianti/View/TiantiPanel")
RegistModules("Tianti/TiantiModel")

TiantiController = BaseClass(LuaController)

function TiantiController:__init()
	self.model = TiantiModel:GetInstance()
	resMgr:AddUIAB("Tianti")
	self:InitEvent()
	self:RegistProto()
end
-- 事件
	function TiantiController:InitEvent()
		local getRankDataHandle = function ()
			self:C_GetRankPageList()
		end
		self.handler1=self.model:AddEventListener(TiantiConst.GET_RANKDATA, getRankDataHandle)

		local onRankChange = function ()
			if self:GetView() then
				self:GetView():UpdateRank()
			end
		end
		self.handler2=self.model:AddEventListener(TiantiConst.Rank_CHANGE, onRankChange)
		local onInfoChange = function ()
			if self:GetView() then
				self:GetView():UpdateInfo()
			end
		end
		self.handler3=self.model:AddEventListener(TiantiConst.INFO_CHANGE, onInfoChange)
		
		-- 统一打开界面事件
		-- self.handler_open = GlobalDispatcher:AddEventListener(EventName.OPENVIEW, function ()
		-- 	self:Open()
		-- end)
		self.handler4=GlobalDispatcher:AddEventListener(EventName.TiantiFinishCutDown, function(data)
			self:OnFinishCutDown(data)
		end)

		self.handler5 = GlobalDispatcher:AddEventListener(EventName.UNLOAD_SCENE,function ()
			self:DestroyTips()
		end)

		if not self.reloginHandle then
			self.reloginHandle = GlobalDispatcher:AddEventListener(EventName.RELOGIN_ROLE,function ()
				self:DestroyTips()
				self.model:Reset()
			end)
		end

		self.handler6 = GlobalDispatcher:AddEventListener(EventName.TiantiRoleEnter, function(data)
			self:OnTiantiRoleEnter(data)
		end)
	end
-- 协议
	function TiantiController:RegistProto()
		self:RegistProtocal("S_GetTianti")
		self:RegistProtocal("S_GetRankPageList")
		self:RegistProtocal("S_SynLoadPkPlayer")
		self:RegistProtocal("S_SynEndTiantiPkPlayer")
		self:RegistProtocal("S_CancelMatch")
		self:RegistProtocal("S_UseTiantiItem")
		self:RegistProtocal("S_GetStageReward")
		self:RegistProtocal("S_Match")
	end
	-- 排行列表 分页
	function TiantiController:S_GetRankPageList(buffer)
		local msg = self:ParseMsg(tianti_pb.S_GetRankPageList(),buffer)
		self.model:SetRankPageList(msg)
	end
	-- 总信息
	function TiantiController:S_GetTianti(buffer)
		local msg = self:ParseMsg(tianti_pb.S_GetTianti(),buffer)
		self.model:SetTiantiInfo( msg )
	end
	-- 获取面板数据
	function TiantiController:C_GetTianti()
		self:SendEmptyMsg(tianti_pb, "C_GetTianti")
	end
	-- 获取排行列表 分页(起始 数量)
	function TiantiController:C_GetRankPageList()
		local msg = tianti_pb.C_GetRankPageList()
		msg.start = self.model:GetCurNum() + 1
		msg.offset = TiantiConst.offset
		self:SendMsg("C_GetRankPageList",msg)
	end
	-- 开始匹配
	function TiantiController:C_Match()
		self:SendEmptyMsg(tianti_pb, "C_Match")
	end
	-- 取消匹配
	function TiantiController:C_CancelMatch()
		self:SendEmptyMsg(tianti_pb, "C_CancelMatch")
	end
	-- 认输
	function TiantiController:C_GiveUp()
		self:SendEmptyMsg(tianti_pb, "C_GiveUp")
	end
	-- 使用竞技场物品
	function TiantiController:C_UseTiantiItem(itemId, num)
		local msg = tianti_pb.C_UseTiantiItem()
		msg.itemId = itemId
		msg.num = num
		self:SendMsg("C_UseTiantiItem",msg)
	end
	-- 领取段位奖励
	function TiantiController:C_GetStageReward(stage)
		local msg = tianti_pb.C_GetStageReward()
		msg.stage = stage
		self:SendMsg("C_GetStageReward",msg)
	end
	
	
-- 面板
	function TiantiController:Open(e) -- 参数 e.data.id, e.data.v: (nil|0) 主面 (1)排行 (2)信息
		local t = self.model.openType
		if e and e.data and e.data.id == "TiantiPanel"  then
			t = e.data.v or 0
		else
			t = 0
		end
		self.model:SetOpenType(t)
		if not self:GetView() then
			self.view = TiantiPanel.New()
			self.view:Open()
			self:C_GetTianti()
			self:C_GetRankPageList()
		else
			if self:GetView():IsOpen() then
				self:GetView():Update()
			else
				self:GetView():Open()
				self:C_GetTianti()
			end
		end
		
	end
	function TiantiController:Close()
		if self:GetView() then
			self.view:Close()
		end
	end
	function TiantiController:GetView()
		if self.view and self.view.isInited then
			return self.view
		end
		return nil
	end

function TiantiController:GetInstance()
	if not TiantiController.inst then
		TiantiController.inst = TiantiController.New()
	end
	return TiantiController.inst
end
function TiantiController:__delete()
	self.model:RemoveEventListener(self.handler1)
	self.model:RemoveEventListener(self.handler2)
	self.model:RemoveEventListener(self.handler3)
	--GlobalDispatcher:RemoveEventListener(self.handler_open)
	GlobalDispatcher:RemoveEventListener(self.handler4)
	GlobalDispatcher:RemoveEventListener(self.handler5)
	GlobalDispatcher:RemoveEventListener(self.handler6)
	GlobalDispatcher:RemoveEventListener(self.reloginHandle)
	if self:GetView() then
		self.view:Destroy()
	end
	if self.model then
		self.model:Destroy()
	end
	self.view = nil
	self.model = nil
	TiantiController.inst = nil
end

function TiantiController:OnFinishCutDown(data)
	local sceneModel = SceneModel:GetInstance()
	local isTianti = sceneModel:IsTianti()
	if self.FinishTiantiCutDownTips == nil and isTianti then
		local rev = self.model:GetEndPkPlayerMsg(true)
		self.FinishTiantiCutDownTips = PoPFinishTianti.New()
		self.FinishTiantiCutDownTips:AddTo(layerMgr:GetMSGLayer())
		self.FinishTiantiCutDownTips.ui:SetXY(0,0)
		self.FinishTiantiCutDownTips:OnEnable(rev)
	end
end

function TiantiController:DestroyTips()
	if self.FinishTiantiCutDownTips then 
		self.FinishTiantiCutDownTips:Destroy()
	end
	self.FinishTiantiCutDownTips = nil
end

function TiantiController:S_SynLoadPkPlayer(buffer)
	local msg = self:ParseMsg(tianti_pb.S_SynLoadPkPlayer(), buffer)
	if self.model then
		self.model:SetLoadPkPlayer(msg)
	end
end

function TiantiController:S_SynEndTiantiPkPlayer(buffer)
	local msg = self:ParseMsg(tianti_pb.S_SynEndTiantiPkPlayer(), buffer)
	if self.model then
		self.model:SetEndPkPlayer(msg)
	end
end

function TiantiController:S_CancelMatch(buffer)
	--local msg = self:ParseMsg(tianti_pb.S_CancelMatch(), buffer)
	if self.model then
		UIMgr.Win_FloatTip("匹配超时!")
		self.model:SetMatchState(0)
	end
end

function TiantiController:S_UseTiantiItem(buffer)
	local msg = self:ParseMsg(tianti_pb.S_UseTiantiItem(), buffer)
	if self.model then
		self.model:SetTiantiItemInfo(msg)
	end
end

function TiantiController:S_GetStageReward(buffer)
	local msg = self:ParseMsg(tianti_pb.S_GetStageReward(), buffer)
	if self.model then
		self.model:SetStageReward(msg)
	end
end

function TiantiController:S_Match(buffer)
	local msg = self:ParseMsg(tianti_pb.S_Match(), buffer)
	if self.model then
		self.model:SetMatchEnter(msg.state)
	end
end

function TiantiController:OnTiantiRoleEnter(data)
	if self.model then
		self.model:ResetPkItemInfo()
	end
end