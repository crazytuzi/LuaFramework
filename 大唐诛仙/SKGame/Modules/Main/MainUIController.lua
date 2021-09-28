
RegistModules("Function/FunctionConst")
RegistModules("Main/MainUIConst")
RegistModules("Main/MainUIModel")
RegistModules("Main/MainUIView")
RegistModules("Main/Vo/MainUIVo")
------------------pk--------------
RegistModules("Main/View/PkModel/PkItem")
RegistModules("Main/View/PkModel/PkContent")
RegistModules("Main/View/PkModel/PkSelect")
RegistModules("Main/View/PkModel/PkModel")
RegistModules("Main/View/Activites")
RegistModules("Main/View/MainCityUI")
RegistModules("Main/View/FightControllerUI")
RegistModules("Main/View/FunctionConn")
RegistModules("Main/View/PlayerInfo")
RegistModules("Main/View/PlayerInfoRight")
RegistModules("Main/View/FBFlag")
RegistModules("Main/View/MiniMap")
RegistModules("Main/View/MapScalPanel")
RegistModules("Main/View/SmallMap")

RegistModules("Main/View/MonsterHeadComponent"	)
RegistModules("Main/View/ChatMain")

RegistModules("Main/View/BuffUI/BuffDescItem")
RegistModules("Main/View/BuffUI/BuffUIItem")
RegistModules("Main/View/BuffUI/BuffUIManager")

-----------------skill----------------
local SkillBtnUI = "Main/View/SkillBtnUI/"
RegistModules(SkillBtnUI.."SkillBtnUI_Base")
RegistModules(SkillBtnUI.."SkillBtnUI_AngleRangeBase")
RegistModules(SkillBtnUI.."SkillBtnUI_360Range")
RegistModules(SkillBtnUI.."SkillBtnUI_180Range")
RegistModules(SkillBtnUI.."SkillBtnUI_90Range")
RegistModules(SkillBtnUI.."SkillBtnUI_60Range")
RegistModules(SkillBtnUI.."SkillBtnUI_ArrowSmall")
RegistModules(SkillBtnUI.."SkillBtnUI_ArrowBig")
RegistModules(SkillBtnUI.."SkillBtnUI_GroundAttack")
RegistModules(SkillBtnUI.."SkillBtnUI_PointToSectorBase")
RegistModules(SkillBtnUI.."SkillBtnUI_PointToRangeSector180")
RegistModules(SkillBtnUI.."SkillBtnUI_PointToRangeSector90")
RegistModules(SkillBtnUI.."SkillBtnUI_PointToRangeSector60")
RegistModules(SkillBtnUI.."SkillBtnUI_PointToCenterSector90")
RegistModules("Main/BtnSkillView")

----------------Task-----------------------
local TaskUI = "Main/View/TaskUI/"
RegistModules(TaskUI.."TaskTraceItem")
RegistModules(TaskUI.."TaskTraceList")
RegistModules(TaskUI.."TeamItem")
RegistModules(TaskUI.."TaskTeam")
RegistModules(TaskUI.."TaskTeamConst")

----------------查看------------------
RegistModules("Main/View/PlayerFunBtn")
RegistModules("Main/View/PlayerFuncPanel")

----------------复活------------------
RegistModules("Main/View/ReLifePanel")
RegistModules("Main/View/ReLifeBtnPanel")
RegistModules("Main/View/QuickEquipCell")
RegistModules("Main/Vo/QuickEquipVo")

MainUIController = BaseClass(LuaController)
--单例
function MainUIController:GetInstance()
	if MainUIController.inst == nil then
		MainUIController.inst = MainUIController.New()
	end
	return MainUIController.inst
end

function MainUIController:__init()
	self:Config()
	self:InitEvent()
	self:RegistProto()
end
--配置
function MainUIController:Config()
	if self.model == nil then
		self.model = MainUIModel:GetInstance()
	end
	if self.view == nil then
		self.view = MainUIView.New()
	end
end
function MainUIController:GetMainUI()
	if self.view and self.view:GetPanelUI() then
		return self.view:GetPanelUI()
	end
	return nil
end

function MainUIController:SetMainUIVisible(isVisible)
	if self.view then
		local mainUI = self.view:GetPanelUI()
		if mainUI then
			mainUI.visible = isVisible
		end
	end
end

function MainUIController:GetMainUIVisible()
	if self.view then
		local mainUI = self.view:GetPanelUI()
		if mainUI then
			return mainUI.visible
		end
	end
	return nil
end

function MainUIController:GetPanel()
	if self.view then
		return self.view:GetPanel()
	end
	return nil
end

function MainUIController:GetView()
	return self.view
end
--事件监听
function MainUIController:InitEvent()
	self.handler2=GlobalDispatcher:AddEventListener(EventName.MAIN_ROLE_ADDED, function (data)
		self:InitPlayerInfo(data)
	end) --主玩家进入游戏
	self.handler3=GlobalDispatcher:AddEventListener(EventName.MAINPLAYER_UPDATE, function (key, value, pre)
		self:RefreshPlayerInfo(key, value, pre)
		local panel = self:GetPanel()
		if key == "level" then
			if panel then
				if value == 12 then
					panel.furnaceBtn.visible = true
				elseif value == GetCfgData("constant"):Get(59).value then
					panel.gangBtn.visible = true
				end
			end
		end
	end)  --刷新主角信息
	self.handler4=GlobalDispatcher:AddEventListener(EventName.BOSS_ENTER, function (data)
		self:InitMonInfo(data)
	end)  --需要显示怪物信息的怪物入场了
	self.handler5=GlobalDispatcher:AddEventListener(EventName.BOSS_INFO_UPDATE, function (data)
		self:RefreshMonInfo(data)
	end)  --刷新怪物信息
	self.handler6=GlobalDispatcher:AddEventListener(EventName.BOSS_OUTTER, function (data)
		self:HideMonInfo(data)
	end)  --boss离场
	self.handler7=GlobalDispatcher:AddEventListener(EventName.MONSTER_DEAD, function (data)
		self:OnMonDie(data)
	end)  --boss死亡
	self.handler8=GlobalDispatcher:AddEventListener(EventName.SCENE_LOAD_FINISH, function ()
		self:OnSceneLoadFinish()
	end)  --场景加载完成
	self.handler9=GlobalDispatcher:AddEventListener(EventName.ShowPlayerFuncPanel, function (data)
		self:OnShowPlayerFuncPanel(data)
	end)  --角色选中界面
	self.handler10 = GlobalDispatcher:AddEventListener(EventName.MAINUI_CLOSE , function (data)
		self:CloseMainCityUI(data)
	end)
	self.handler11 = GlobalDispatcher:AddEventListener(EventName.FinishTask ,function (data)
		self:HandleFinishTask(data)
	end)
	self.handler12 = GlobalDispatcher:AddEventListener(EventName.InitTaskList , function ()
		self:HandleInitTask()
	end)
	self.handler13 = GlobalDispatcher:AddEventListener(EventName.SCENE_LOAD_FINISH , function(data)
		self:OpenMainCityUI(data)
		if self:GetPanel() then self:GetPanel():SetActivitesUIState() end
		GlobalDispatcher:DispatchEvent(EventName.MAINUI_EXIST)
		GlobalDispatcher:RemoveEventListener(self.handler13)
	end)
	self.handler14 = GlobalDispatcher:AddEventListener(EventName.BAG_CHANGE, function(data)
		self:HandleBagChange(data)
	end)
	self.handler15 = self.model:AddEventListener(MainUIConst.E_QuickEquipDelete, function(data)
		self:HandleQuickEquipDelete(data)
	end)
	self.handler16 = GlobalDispatcher:AddEventListener(EventName.PlayerEquipStateChange, function(data)
		self:HandlePlayerEquipStateChange(data)
	end)
	self.handler17 = GlobalDispatcher:AddEventListener(EventName.RELOGIN_ROLE , function ()
		if self.model then
			self.model:Reset()
		end
		if self.view then
			self.view:Reset()
		end
	end)
	self.handler18 = GlobalDispatcher:AddEventListener(EventName.MAINROLE_DIE, function(data)
		self:HandleMainPlayerDie(data)
	end)
	self.handler19 = GlobalDispatcher:AddEventListener(EventName.PopCheckStateChange, function(data)
		self:HandlePopStateChange(data)
	end)
	self.handler20 = GlobalDispatcher:AddEventListener(EventName.TiantiRoleEnter, function(data)
		self:InitTiantiRoleInfo(data)
	end)
	self.handler21 = GlobalDispatcher:AddEventListener(EventName.TiantiRoleAttrUpdate, function (key, value, pre)
		self:RefreshTiantiRoleInfo(key, value, pre)
	end)
	self.handler22 = GlobalDispatcher:AddEventListener(EventName.ExitGame , function ()
		self:HandleExitGame()
	end)
end
--事件删除
function MainUIController:RemoveEvent()
	GlobalDispatcher:RemoveEventListener(self.handler1)
	GlobalDispatcher:RemoveEventListener(self.handler2)
	GlobalDispatcher:RemoveEventListener(self.handler3)
	GlobalDispatcher:RemoveEventListener(self.handler4)
	GlobalDispatcher:RemoveEventListener(self.handler5)
	GlobalDispatcher:RemoveEventListener(self.handler6)
	GlobalDispatcher:RemoveEventListener(self.handler7)
	GlobalDispatcher:RemoveEventListener(self.handler8)
	GlobalDispatcher:RemoveEventListener(self.handler9)
	GlobalDispatcher:RemoveEventListener(self.handler10)
	GlobalDispatcher:RemoveEventListener(self.handler11)
	GlobalDispatcher:RemoveEventListener(self.handler12)
	GlobalDispatcher:RemoveEventListener(self.handler14)
	if self.model then
		self.model:RemoveEventListener(self.handler15)
	end
	GlobalDispatcher:RemoveEventListener(self.handler16)
	GlobalDispatcher:RemoveEventListener(self.handler17)
	GlobalDispatcher:RemoveEventListener(self.handler18)
	GlobalDispatcher:RemoveEventListener(self.handler19)
	GlobalDispatcher:RemoveEventListener(self.handler20)
	GlobalDispatcher:RemoveEventListener(self.handler21)
	GlobalDispatcher:RemoveEventListener(self.handler22)
end

-- 协议注册
function MainUIController:RegistProto()
	self:RegistProtocal("S_QuickTips")
end

--打开主界面
function MainUIController:OpenMainCityUI(data)
	if self.view then
		self.view:OpenMainCityUI()
	end
end

--关闭主界面
function MainUIController:CloseMainCityUI()
	if self.view then
		self.view:CloseMainCityUI()
	end
end

--主界面是否打开初始化过
function MainUIController:IsHasMainCityUI()
	local rtnIsHas = false
	if self.view then
		if self.view.mainPanel ~= nil then
			rtnIsHas = true
		end
	end
	return rtnIsHas
end

function MainUIController:Lock()
	if self.view and self.view:GetPanel() then
		self.view:GetPanel():SetTouchable(false)
	end
end

function MainUIController:UnLock()
	if self.view and self.view:GetPanel() then
		self.view:GetPanel():SetTouchable(true)
	end
end

function MainUIController:LockInTime(lockTime)
	self:Lock()
	DelayCall(function() 
			self:UnLock()
		end, lockTime)
end

--------------------选中弹框--------------------
MainUIController.CurShowPlayer = nil
function MainUIController:OnShowPlayerFuncPanel(data)
	if toLong(SceneModel:GetInstance():GetMainPlayer().playerId) == toLong(data.playerId) then
		return
	end

	local msg = player_pb.C_QuickTips()
	msg.playerId = data.playerId
	self:SendMsg("C_QuickTips", msg)

	MainUIController.CurShowPlayer = data
end

function MainUIController:S_QuickTips(buff)
	local msg = self:ParseMsg(player_pb.S_QuickTips(), buff)
	local curShow = MainUIController.CurShowPlayer
	if curShow and tonumber(curShow.playerId) == tonumber(msg.playerId) then
		local data = curShow
		local playerFuncPanel = PlayerFuncPanel.New()
		playerFuncPanel:Update(msg, data.funcIds)
		DelayCall(function ()
			UIMgr.ShowPopup(playerFuncPanel, false, 0, 0, function()  end)
		end, 0)
	end
	
end
--

function MainUIController:OnSceneLoadFinish()
	if self:GetPanel() then
		self:GetPanel():UIMapping()
		self:GetPanel():SetActivitesUIState()
	end
end

------------------------------------------------------------------------------
--怪物信息操作区域--目前只针对boss
function MainUIController:InitMonInfo(data)
	if data and self:GetPanel() then
		self:GetPanel():InitMonInfo(data)
	end
end

function MainUIController:RefreshMonInfo(data)
	if data and self:GetPanel() then
		self:GetPanel():RefreshMonInfo(data)
	end
end

function MainUIController:HideMonInfo(data)
	if data and self:GetPanel() then
		self:GetPanel():HideMonInfo(data)
	end
end

function MainUIController:OnMonDie(data)
	--死亡数据不为空&&是否为boss&&是否为延时死亡事件&&面板是否不为空
	if data and data[3] and data[2] == 1 and self:GetPanel() then
		self:GetPanel():HideMonInfo(data[1])
	end
end
------------------------------------------------------------------------------
--玩家信息操作区域
function MainUIController:InitPlayerInfo(data)
	if data  then
		if self:GetPanel() then
			self:InitBtnSkillView()
			self:GetPanel():InitPlayerInfo(data.vo)
		end
		
		self.model:RefershMainUIVoList()
	end
end
function MainUIController:RefreshPlayerInfo(key, value, pre)
	if self:GetPanel() then
		if key == "hp" or key == "mp" or key == "battleValue" or key == "level"or key == "mpMax"or key == "career" or key == "hpMax" then
			self:GetPanel():RefreshPlayerInfo(key, value)
		end
		if key == "exp" then
			self:GetPanel():RefreshPlayerExp()
		end
		if key == "level" then
			self.model:RefershMainUIVoList(true)
		end
	end
end
--主玩家进入游戏初始化技能界面(后续要干掉这个直接跟着数据初始化)
function MainUIController:InitBtnSkillView()
	if self:GetPanel() then
		self:GetPanel():InitBtnSkillView()
	end
end

function MainUIController:HandleFinishTask(data)
	if data and self.model then
		self.model:RefershMainUIVoList()
	end
end

function MainUIController:HandleInitTask()
	if self.model then
		self.model:RefershMainUIVoList()
	end
end
-- get新装备处理快捷穿戴
function MainUIController:HandleBagChange(data)
	if self.model then
		self.model:RefreshQuickEquip(data)
	end
end

function MainUIController:HandleQuickEquipDelete(data)
	if self.model then
		self.model:EraseQuickEquip(data)
	end
end

function MainUIController:HandleEquipToBag(id)
	if self.model then
		self.model:HandleEquipToBag(id)
	end
end

function MainUIController:HandleBagToEquip(id)
	if self.model then
		self.model:HandleBagToEquip(id)
	end
end

function MainUIController:HandlePlayerEquipStateChange(data)
	if data and data.state and data.data then
		if data.state == 1 then
			self:HandleEquipToBag(data.data)
		else
			self:HandleBagToEquip(data.data)
		end
	end
end

function MainUIController:HandleMainPlayerDie(data)
	if self.model then
		self.model:HandleMainPlayerDie(data)
	end
end

function MainUIController:HandlePopStateChange(data)
	if self.model then
		self.model:HandlePopStateChange(data)
	end
end

function MainUIController:HandleExitGame()
	self:SetMainUIVisible(false)
end

------------------------------------------------------------------------------
--天梯右上角对手信息
function MainUIController:InitTiantiRoleInfo(data)
	if data and self:GetPanel() then
		self:GetPanel():InitPlayerInfoRight(data)
	end
end

function MainUIController:RefreshTiantiRoleInfo(key, value, pre)
	if self:GetPanel() then
		if key == "hp" or key == "mp" or key == "battleValue" or key == "level"or key == "mpMax" or key == "career" or key == "hpMax" then
			self:GetPanel():RefreshPlayerInfoRight(key, value)
		end
	end
end

function MainUIController:__delete()
	if self.view then
		self.view:Destroy()
	end
	self.view = nil
	self:RemoveEvent()
	if self.model then
		self.model:Destroy()
	end
	self.model = nil
	MainUIController.inst = nil

	BuffDescItem.DestoryPool()
end