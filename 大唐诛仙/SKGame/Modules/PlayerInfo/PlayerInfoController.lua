RegistModules("PlayerInfo/PlayerInfoConst")
RegistModules("PlayerInfo/PlayerInfoModel")
RegistModules("PlayerInfo/PlayerInfoView")

RegistModules("Tips/EquipmentInfoTips")
RegistModules("PlayerInfo/View/PlayerEquipListPage")
RegistModules("PlayerInfo/View/PlayerInfoUI")
RegistModules("PlayerInfo/View/PropInfo")
RegistModules("PlayerInfo/View/PlayerEquipItem")
RegistModules("PlayerInfo/View/PlayerEquipList")
RegistModules("PlayerInfo/View/PlayerEquipSkepList")
RegistModules("PlayerInfo/View/PlayerEquipSkepListItem")
RegistModules("PlayerInfo/View/DescBaseProUI")
RegistModules("PlayerInfo/View/DescSpecialProUI")

RegistModules("PlayerInfo/View/OtherPlayerInfoPanel")

PlayerInfoController =BaseClass(LuaController)

function PlayerInfoController:GetInstance()
	if PlayerInfoController.inst == nil then
		PlayerInfoController.inst = PlayerInfoController.New()
	end
	return PlayerInfoController.inst
end

function PlayerInfoController:__init()
	self.model = PlayerInfoModel:GetInstance()
	self:InitEvent()
	self:RegistProto()
end

function PlayerInfoController:InitEvent()
	self.handler6 = GlobalDispatcher:AddEventListener(EventName.MAINPLAYER_UPDATE, function ( key, value, pre ) self:RefreshPlayerInfo(key, value, pre) end)  --刷新主角信息
	self.handler7 = GlobalDispatcher:AddEventListener(EventName.CheckOtherPlayerInfo, function ( data ) self:ReqCheckOtherPlayerInfo(data) end)  --查询角色信息
end

 function PlayerInfoController:RegistProto()
	self:RegistProtocal("S_ShowPlayer") -- 查看其他玩家信息
end

-- 查看其他玩家信息返回
-- guid = 1;  //全局编号
-- severNo = 2; //服务器编号
-- playerId = 3; //角色编号
-- playerName = 4; // 角色名称	
-- career = 5; // 角色职业	
-- vipLevel = 6; // 角色vip等级	
-- playerFamilyId = 7; // 角色家族ID
-- familyName = 8; // 角色家族名称
-- familySortId = 9; // 角色排位
-- guildId = 13;   		//帮派编号
-- guildName = 14;   	//帮派名称
function PlayerInfoController:S_ShowPlayer(buff)
	local model = SceneModel:GetInstance()
	local msg = self:ParseMsg(scene_pb.S_ShowPlayer(), buff)

	if model:IsMain() and model.headerId ~= 0 and not model.isHasReqShixiang then
		model.isHasReqShixiang = true
		local go = GameObject.Find("diaoxiang")
		-- local tf = go.transform
		-- local pos = tf.localPosition
		-- local dir = tf.localEulerAngles
		local vo = {
			type=1,
			inScene=1001,
			name=StringFormat("{0} (城主)",msg.playerName),
			dialog="",
			speak="",
			speakTime=10000,
			dressStyle=msg.career,
			head="0",
			isvisible=1,
			field=300,
			interactive=200,
			relax="idle",
			relaxTime={500000000,1000000000},
			functionId={}
		}
		-- local cfgNpc = GetCfgData("npc")
		-- cfgNpc[1]=vo
		vo.eid = 1
		vo.guid = "npc_shixiang"
		vo.position = Vector3.New(82, 0.02, 94.5) --pos
		vo.direction = Vector3.zero
		model:AddNpc(vo)
		GameObject.Destroy(go)

		ClanModel:GetInstance().warHoster =msg.guildId
	else
		local infoPanel = OtherPlayerInfoPanel.New()
		UIMgr.ShowCenterPopup(infoPanel)
		infoPanel:Update(PlayerInfoModel.ParseCheckData(msg))
	end

	
	
end
-- 查看其他玩家信息
function PlayerInfoController:ReqCheckOtherPlayerInfo(data)
	local msg = scene_pb.C_ShowPlayer()
	msg.playerId = data
	self:SendMsg("C_ShowPlayer", msg)
end

function PlayerInfoController:Open(tabIndex)
	self.model:FillPlayerEquipList()
	if self.view == nil or not self.view.Inited then
		self.view = PlayerInfoView.New()
	end
	self.view:Open(tabIndex or 0)
end
function PlayerInfoController:Close()
	if self.view and self.view.Inited then
		self.view:Close()
	end
end

function PlayerInfoController:RefreshPlayerInfo()
	if self.view and self.view.Inited and self.view.infoPanel then
		self.view.infoPanel:Refresh()
	end
end

function PlayerInfoController:__delete()
	GlobalDispatcher:RemoveEventListener(self.handler6)
	GlobalDispatcher:RemoveEventListener(self.handler7)
	if self.model then
		self.model:Destroy()
	end
	self.model = nil
	if self.view and self.view.Inited then
		self.view:Destroy()
	end
	
	self.view = nil

	PlayerInfoController.inst = nil
end