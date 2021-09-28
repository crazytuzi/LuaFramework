require "Core.Module.Pattern.Proxy"

AutoFightProxy = Proxy:New();
function AutoFightProxy:OnRegister()
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.Exit_Game, AutoFightProxy.ExitGameCallBack);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.GiftCode, AutoFightProxy._RspSendGiftCode);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.ChangeRoleName, AutoFightProxy._OnChangeRoleName);	
end

function AutoFightProxy:OnRemove()
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.Exit_Game, AutoFightProxy.ExitGameCallBack);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.GiftCode, AutoFightProxy._RspSendGiftCode);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.ChangeRoleName, AutoFightProxy._OnChangeRoleName);	
end

-- 0 为退出账号 1为退出角色
function AutoFightProxy.SendExitGame(t)
	SocketClientLua.Get_ins():SendMessage(CmdType.Exit_Game, {t = t});
end

function AutoFightProxy.ExitGameCallBack(cmd_int, data)
	if(data.errCode == nil) then
		
		if(PlayerManager.hero) then
			PlayerManager.hero:CheckAndOutMountNyNotSendToServer(true, false);
		end
		
		ModuleManager.SendNotification(AutoFightNotes.CLOSE_AUTOFIGHTPANEL)
		
		if(data.t == 0) then
			AutoFightProxy.ChangeAccount()
		elseif(data.t == 1) then
			PlayerManager.SetPlayerInfo(data)
			PlayerManager.ChangePlayer()
		end
	end
	
end


function AutoFightProxy.ChangeAccount()
	--    PanelManager.RemoveAllPanel()
	--    PlayerManager.DisposeHero()
	--    SocketClientLua.Get_ins():Close()
	--    local func = function()
	--        ModuleManager.GotoModule(LoginModule)
	--    end;
	--    GameSceneManager.SetMap(700002, func);
	ReStartGame()
end

function AutoFightProxy.ReqSendGiftCode(code)
	SocketClientLua.Get_ins():SendMessage(CmdType.GiftCode, {code = code});
end

function AutoFightProxy._RspSendGiftCode(cmd, data)
	if(data == nil or data.errCode ~= nil) then
		--MsgUtils.ShowTips("giftCode/error");
		return;
	end
	MsgUtils.ShowTips("giftCode/suc");
	MessageManager.Dispatch(AutoFightNotes, AutoFightNotes.ENV_GIFTCODE_SUC);
end

function AutoFightProxy.TryChangeRoleName(name)
	SocketClientLua.Get_ins():SendMessage(CmdType.ChangeRoleName, {name = name})
end
function AutoFightProxy._OnChangeRoleName(cmd, data)
	if not data or data.errCode then return end
	local id = data.id
	if id == PlayerManager.playerId then
		local playerInfo = PlayerManager.GetPlayerInfo()
		playerInfo.name = data.name
		local hero = HeroController.GetInstance()
		hero.info.name = data.name;
		hero:RefreshRoleName()
	end
	local roles = MapRoleList.GetInstance()
	local role = roles and roles:GetRole(id) or nil
	if role and role.info then
		role.info.name = data.name
		role:RefreshRoleName()
	end
	PartData.SetTeamNumberName(id, data.name)
	MessageManager.Dispatch(AutoFightNotes, AutoFightNotes.ENV_CHANGE_ROLE_NAME, data)
end
