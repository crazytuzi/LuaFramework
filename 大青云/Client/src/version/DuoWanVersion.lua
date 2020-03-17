--[[
联运：多玩版本
lizhuangzhuang
2015年11月11日00:11:00
]]

_G.DuoWanVersion = LianYunVersion:new(VersionConsts.DuoWan);

function DuoWanVersion:DuoWanChangeScene()
	local cfg = LianYunCfg[self.name];
	if not cfg then return; end
	local url = cfg.reportUrl;
	if not url then return; end
	local to_user_role_name = string.enurl(MainPlayerModel.humanDetailInfo.eaName);
	local game_scene_id = CPlayerMap:GetCurMapID();
	local server_id = "s".._sys:getGlobal("skey");
	local game_id = "DZZ";
	url = url .. string.format("?to_user_role_name=%s&game_scene_id=%s&server_id=%s&game_id=%s",
				to_user_role_name,game_scene_id,server_id,game_id);
	_sys:httpGet(url);
end

function DuoWanVersion:DuoWanUserCreate(roleName)
	local cfg = LianYunCfg[self.name];
	if not cfg then return; end
	local url = cfg.reportProfileUrl;
	if not url then return; end
	url = url .."?act=/game_profile&ya_appid=udblogin&pas=&pro=logingame&gam=DZZ"
	local udbid = _sys:getGlobal("uid");
	local gse = "s".._sys:getGlobal("skey");
	local jsondata = {};
	jsondata.game_event = "new_role";
	jsondata.role_name = string.enurl(roleName);
	jsondata.role_level = 1;
	local jsonStr = json.encode(jsondata);
	url = url .. string.format("&udbid=%s&gse=%s&json_data=%s",udbid,gse,jsonStr);
	_sys:httpGet(url);
end

function DuoWanVersion:DuoWanUserLevelUp(roleName,roleLevel)
	local cfg = LianYunCfg[self.name];
	if not cfg then return; end
	local url = cfg.reportProfileUrl;
	if not url then return; end
	url = url .."?act=/game_profile&ya_appid=udblogin&pas=&pro=logingame&gam=DZZ"
	local udbid = _sys:getGlobal("uid");
	local gse = "s".._sys:getGlobal("skey");
	local jsondata = {};
	jsondata.game_event = "level_change";
	jsondata.role_name = string.enurl(roleName);
	jsondata.role_level = roleLevel;
	local jsonStr = json.encode(jsondata);
	url = url .. string.format("&udbid=%s&gse=%s&json_data=%s",udbid,gse,jsonStr);
	_sys:httpGet(url);
end

function DuoWanVersion:DuoWanCollectMsg(from_user_role_name,to_user_role_name,chat_content,message_type)
	local cfg = LianYunCfg[self.name];
	if not cfg then return; end
	local url = cfg.collectUrl;
	if not url then return; end
	from_user_role_name = string.enurl(from_user_role_name);
	to_user_role_name = string.enurl(to_user_role_name);
	chat_content = string.enurl(chat_content);
	local game_scene_id = CPlayerMap:GetCurMapID();
	local server_id = "s".._sys:getGlobal("skey");
	local game_id = "DZZ";
	url = url .. string.format("?from_user_role_name=%s&to_user_role_name=%s&chat_content=%s&message_type=%s&game_scene_id=%s&server_id=%s&game_id=%s",
				from_user_role_name,to_user_role_name,chat_content,message_type,game_scene_id,server_id,game_id);
	_sys:httpGet(url);	
end

function DuoWanVersion:DuoWanBaifuAct()
	local cfg = LianYunCfg[self.name];
	if not cfg then return; end
	local url = cfg.baifuAct;
	if not url then return; end
	_sys:browse(url);
end;

function DuoWanVersion:DuowanisShowBaifuAct()
	return false;
end;