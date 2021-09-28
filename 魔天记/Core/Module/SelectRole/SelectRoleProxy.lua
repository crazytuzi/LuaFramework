require "Core.Module.Pattern.Proxy"
require "net/SocketClientLua"
require "net/CmdType"
require "Core.Manager.PlayerManager"
require "Core.Manager.GameSceneManager"
require "Core.Module.MainUI.MainUINotes"
require "Core.Net.Reconnect";
require "Core.Manager.Item.ChatManager";

SelectRoleProxy = Proxy:New()
SelectRoleProxy.token = 0

function SelectRoleProxy:OnRegister()
	SelectRoleProxy.token = 0
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Get_Role_Name, SelectRoleProxy.Reseulr_Get_Role_Name);
	
end

function SelectRoleProxy:OnRemove()
	SelectRoleProxy.token = 0
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Get_Role_Name, SelectRoleProxy.Reseulr_Get_Role_Name);
	
end

function SelectRoleProxy.TryInGame(heroInfo)
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.In_Game, SelectRoleProxy.DataInHandler);
	SocketClientLua.Get_ins():SendMessage(CmdType.In_Game, {id = heroInfo.id});
end

function SelectRoleProxy.DataInHandler(cmd, data)
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.In_Game, SelectRoleProxy.DataInHandler);
	if(data and data.errCode == nil) then
		PlayerManager.SetCurPlayerData(data);
		--    PlayerManager.SetLastPlayerIndex(data.id)
		-- 跳转场景进入游戏
		-- local action = DelegateFactory.Action(function()  end)
		-- SceneManager.GetIns():InitGameScene()
		
		ModuleManager.SendNotification(SelectRoleNotes.CLOSE_SELECTROLE_PANEL);
		ModuleManager.SendNotification(SelectRoleNotes.CLOSE_CREATEROLEPANEL);
		-- ModuleManager.SendNotification(LoginNotes.CLOSE_GOTOGAME_PANEL);
		GameSceneManager.InitGameScene();
		local toScene = {};
		toScene.sid = data.scene.sid;
		toScene.fid = data.scene.fid;
		toScene.position = Convert.PointFromServer(data.scene.x, data.scene.y, data.scene.z);
		-- GameSceneManager.to = toScene
		local flg = GameSceneManager.GotoScene(toScene.sid, nil, toScene);
		
		SocketClientLua.Get_ins():ChangeStatuHandler(Reconnect.SocketConnectState);
		-- tangping
		ChatManager.VoiceLogin()
		
        if GameConfig.instance.autoLogin then  return end
		if not flg then
			local id = 701000
			local mapInfo = GameSceneManager.GetMapInfo(id);
			local to =
			{
				sid = mapInfo.map;
				position = Convert.PointFromServer(mapInfo.born_x, mapInfo.born_y, mapInfo.born_z);
			}
			GameSceneManager.GotoScene(id, nil, to)
		end		
	end
end

function SelectRoleProxy.TryCreateRole(data, hname)
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Create_Role, SelectRoleProxy.Reseulr_Create_Role);
	SocketClientLua.Get_ins():SendMessage(CmdType.Create_Role, {kind = data.id, sex = data.sex, name = hname});
end

-- {"level":1,"kind":101000,"sex":0,"name":"东方天奕","id":"10100335"}
function SelectRoleProxy.Reseulr_Create_Role(cmd, data)
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Create_Role, SelectRoleProxy.Reseulr_Create_Role);
	if(data.errCode == nil) then
		PlayerManager.SubmitExtraData(2, {roleLevel = data.level, roleID = data.id, roleName = data.name, career = data.kind, careerId = data.kind,
		sex = data.sex == 0 and "男" or "女", careerName = PlayerManager.GetCareerById(data.kind).career,createRoleTime = data.createRoleTime})
		SelectRoleProxy.TryInGame(data)
	end
end

function SelectRoleProxy.GetRandomName(_sex)		
	SocketClientLua.Get_ins():SendMessage(CmdType.Get_Role_Name, {sex = _sex});
end

function SelectRoleProxy.Reseulr_Get_Role_Name(cmd, data)
	if(data and data.errCode == nil) then
		ModuleManager.SendNotification(SelectRoleNotes.UPDATE_NAME, data.name)
	end
	
end 