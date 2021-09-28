require "Core.Module.Pattern.Proxy"
require "Core.Role.Controller.HeroController";
require "net/CmdType";
require "net/SocketClientLua";

ChoosePKTypeProxy = Proxy:New();
function ChoosePKTypeProxy:OnRegister()
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.ChoosePkType, ChoosePKTypeProxy._CmdChoosePkTypeHandler);
	SocketClientLua.Get_ins():AddDataPacketListener(CmdType.DisplayPkData, ChoosePKTypeProxy._CmdPkDataHandler);
end

function ChoosePKTypeProxy:OnRemove()
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.ChoosePkType, ChoosePKTypeProxy._CmdChoosePkTypeHandler);
	SocketClientLua.Get_ins():RemoveDataPacketListener(CmdType.DisplayPkData, ChoosePKTypeProxy._CmdPkDataHandler);
end

function ChoosePKTypeProxy.ChooseType(pkType)
	local hero = HeroController.GetInstance();
	if(hero and hero.info and hero.info.pkType ~= pkType and pkType >= PlayerPKType.Peace and pkType <= PlayerPKType.Killing) then
		if(ChoosePKTypeProxy.pkType) then
			ChoosePKTypeProxy.pkType = nil;
		end
        hero.info.pkType = pkType
        ChoosePKTypeProxy._ChoosePkType(pkType)
	end
end

function ChoosePKTypeProxy.DisplayPkData()
	SocketClientLua.Get_ins():SendMessage(CmdType.DisplayPkData, {});
end

function ChoosePKTypeProxy.ForcePeace(type)
	local hero = HeroController.GetInstance();
	local iType = type or PlayerPKType.Peace;
	--if (hero and hero.info and hero.info.pkType ~= iType) then
	if(ChoosePKTypeProxy.pkType == nil) then
		ChoosePKTypeProxy.pkType = hero.info.pkType
	end
	if(hero.info.pkType ~= PlayerPKType.Killing) then
        hero.info.pkType = iType
        ChoosePKTypeProxy._ChoosePkType(iType)
	end
--ChoosePKTypeProxy.ChooseType(iType);
--end
end
--强转禁忌之地战斗模式
function ChoosePKTypeProxy.ForceTaboo()
	local hero = HeroController.GetInstance();
    if(hero.info.pkType ~= PlayerPKType.Taboo) then
        ChoosePKTypeProxy.pkType = hero.info.pkType
        hero.info.pkType = PlayerPKType.Taboo
        ChoosePKTypeProxy._ChoosePkType(PlayerPKType.Taboo)
	end
end
--还原上次的战斗模式
function ChoosePKTypeProxy.RevertLast()
	local hero = HeroController.GetInstance();
	if hero.info.pkType ~= ChoosePKTypeProxy.pkType then
        hero.info.pkType = ChoosePKTypeProxy.pkType
		ChoosePKTypeProxy._ChoosePkType(ChoosePKTypeProxy.pkType)
	end
end

function ChoosePKTypeProxy.CancelForcePeace()
	if(ChoosePKTypeProxy.pkType) then
		local hero = HeroController.GetInstance();
		if(hero and hero.info and hero.info.PKState ~= PlayerPKState.Red and ChoosePKTypeProxy.pkType ~= nil) then
            hero.info.pkType = ChoosePKTypeProxy.pkType
            ChoosePKTypeProxy._ChoosePkType(ChoosePKTypeProxy.pkType)
		end
		ChoosePKTypeProxy.pkType = nil;
	end
end
function ChoosePKTypeProxy._ChoosePkType(t)
	SocketClientLua.Get_ins():SendMessage(CmdType.ChoosePkType, { m = t });
        SceneSelecter.GetInstance():RefreshSelect()
end

function ChoosePKTypeProxy._CmdChoosePkTypeHandler(cmd, data)
    --Warning(cmd .. '---' .. data.errCode)
	if(data and data.errCode == nil) then
        SceneSelecter.GetInstance():RefreshSelect()
	end
end

function ChoosePKTypeProxy._CmdPkDataHandler(cmd, data)
	if(data and data.errCode == nil) then
		MessageManager.Dispatch(ChoosePKTypeNotes, ChoosePKTypeNotes.EVENT_DISPLAYPKDATA, data);
	end
end