require "SKGame/Modules/Tower/TowerModel"
require "SKGame/Modules/Tower/TowerView"
require "SKGame/Modules/Tower/TowerConst"
require "SKGame/Modules/Tower/View/VictorySettlePanel"
require "SKGame/Modules/Tower/View/FailSettlePanel"
require "SKGame/Modules/Tower/Vo/RewardVo"

TowerController = BaseClass(LuaController)
function TowerController:__init()
	self.view = TowerView.New()
	self.model = TowerModel:GetInstance()
	self:RegistProto()
	self:InitEvent()
end

function TowerController:RegistProto()
	self:RegistProtocal("S_TowerEnd","TowerEnd")  --服务器发来大荒塔的结算
end

function TowerController:InitEvent()
	self.handler1=GlobalDispatcher:AddEventListener(EventName.REQ_CHANGE_SCENE, function(data)
		self:ClearCDUpdate(data)
	end)
	self.handler2=GlobalDispatcher:AddEventListener(EventName.UNLOAD_SCENE, function(data)
		self:ClearCDUpdate(data)
	end)
	
end

function TowerController:RemoveEvent()
	GlobalDispatcher:RemoveEventListener(self.handler1)
	GlobalDispatcher:RemoveEventListener(self.handler2)
end

--大荒塔进入结算
function TowerController:TowerEnd(buffer)
	if not SceneModel:GetInstance():IsTower() then return end
	local rev = self:ParseMsg(tower_pb.S_TowerEnd(),buffer)
	local t = {}
	if rev then 
		t.result = rev.result--1 成功  2： 失败
		t.curLayerId = rev.curLayerId--当前层数
		t.rewardInfo = rev.rewardInfo--奖励信息  参考邮件附件
	end
	if  t.rewardInfo and t.rewardInfo ~= "" then 
		local txx = StringToTable(t.rewardInfo)
		if txx then 
			self.model:SetCurrentReward(txx)
		end
	end
	self.model.curLevel = t.curLayerId --当前层

	if t then 
		if t.result == 1 then  --成功
			LoginModel:GetInstance():SetTowerLayer(t.curLayerId + 1)
			--等待3秒后打开胜利界面
			self.waitVictoryTime = 4
			RenderMgr.Add(function () self:NextLevelCDUpdate() end, "waitAndOpenVictoryPanel")
			-- self:OpenVictoryPanel()  --打开胜利界面
		end
		
		if t.result == 2 then 
			LoginModel:GetInstance():SetTowerLayer( math.max(1, t.curLayerId - 2) )
			self.waitFailTime = 3
			RenderMgr.Add(function () self:FailCDUpdate() end, "FailCDUpdate")
			-- self:OpenFailPanel()  --打开失败界面
		end
	end
end

function TowerController:ClearCDUpdate()
	RenderMgr.Remove("waitAndOpenVictoryPanel")
	RenderMgr.Remove("FailCDUpdate")
end

function TowerController:NextLevelCDUpdate()
	if not SceneModel:GetInstance():IsTower() then self:ClearCDUpdate() return end
	self.waitVictoryTime = self.waitVictoryTime - Time.deltaTime
	if self.waitVictoryTime <=0 then 
		RenderMgr.Remove("waitAndOpenVictoryPanel")
		self:OpenVictoryPanel()  --打开胜利界面
		GlobalDispatcher:DispatchEvent(EventName.TowerLayerChange)
	end
end

function TowerController:FailCDUpdate()
	if not SceneModel:GetInstance():IsTower() then self:ClearCDUpdate() return end
	self.waitFailTime = self.waitFailTime - Time.deltaTime
	if self.waitFailTime <=0 then 
		RenderMgr.Remove("FailCDUpdate")
		self:OpenFailPanel()  --打开失败界面
		GlobalDispatcher:DispatchEvent(EventName.TowerLayerChange)
	end
end

function TowerController:OpenVictoryPanel()  --打开胜利界面
	if self.view then
		self.view:OpenVictoryPanel()  --打开胜利界面
	end
end

function TowerController:OpenFailPanel()  --打开失败界面
	if self.view then
		self.view:OpenFailPanel()  --打开失败界面
	end
end

--请求进入大荒塔
function TowerController:RequireEnterTower()
	local send = tower_pb.C_EnterTower()
	self:SendMsg("C_EnterTower",send)
end

--请求退出大荒塔
function TowerController:RequireQuiteTower()
	local send = tower_pb.C_QuitTower()
	self:SendMsg("C_QuitTower",send)
	self.model:Reset()
end

--请求重置大荒塔
function TowerController:RequireResetTower()
	local send = tower_pb.C_ResetTower()
	self:SendMsg("C_ResetTower",send)
end

--单例
function TowerController:GetInstance()
	if TowerController.inst == nil then 
		TowerController.inst = TowerController.New()
	end
	return TowerController.inst
end

function TowerController:__delete()
	self:RemoveEvent()
	if self.view then
		self.view:Destroy()
	end
	self.view = nil

	if self.model then
		self.model:Destroy()
	end
	self.model = nil

	TowerController.inst = nil
end