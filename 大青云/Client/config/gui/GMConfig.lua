--[[
gm指令配置
wangshuai

type =
1 = create
2 = open

需要参数

]]

_G.GMCfg = {
	[1] = {
		txt = "升10级",
		gmTxt = { -- gm指令需要输入几个
			[1] = "/levelup/10",
		},
	},
	[2] = {
		txt = "1百万经验",
		gmTxt = {
			[1] = "/addexp/1000000",
		},
	},
	[3] = {
		txt = "100万绑元：",
		gmTxt = {
			[1] = "/addbindmoney/1000000",
		},
	},
	[4] = {
		txt = "十万元宝",
		gmTxt = {
			[1] = "/addyuanbao/100000",
		},
	},
	[5] = {
		txt = "银两元宝灵力全满",
		gmTxt = {
			[1] = "/greedisgood",
		},
	},
	[6] = {
		txt = "满血",
		gmTxt = {
			[1] = "/full",
		},
	},
	[7] = {
		txt = "增加噬魂、魂值10万，需要重启客户端，",
		gmTxt = {
			[1] = "/addsoul/100000",
		},
	},
	[8] = {
		txt = "加满打造活力值",
		gmTxt = {
			[1] = "/addequipval/100000",
		},
	},
	[9] = {
		txt = "开仙魔战场",
		gmTxt = {
			[1] = "/activity/10002/1/1",
		},
	},
	[10] = {
		txt = "关仙魔战场",
		gmTxt = {
			[1] = "/activity/10002/0/1",
		},
	},
	[11] = {
		txt = "开至尊灵藏",
		gmTxt = {
			[1] = "/activity/10003/1/1",
		},
	},
	[12] = {
		txt = "关至尊灵藏",
		gmTxt = {
			[1] = "/activity/10003/0/1",
		},
	},
	[13] = {
		txt = "开北苍界",
		gmTxt = {
			[1] = "/activity/10006/1/1",
		},
	},
	[14] = {
		txt = "关北苍界",
		gmTxt = {
			[1] = "/activity/10006/0/1",
		},
	},
	[15] = {
		txt = "开帮派战",
		gmTxt = {
			[1] = "/guildwarop/1",
		},
	},
	[16] = {
		txt = "关帮派战",
		gmTxt = {
			[1] = "/guildwarop/3",
		},
	},
	[17] = {
		txt = "重置副本次数",
		gmTxt = {
			[1] = "/debug/1",
		},
	},
	[18] = {
		txt = "开灵光封魔难度1",
		gmTxt = {
			[1] = "/debug/1",
			[2] = "/entertiming/1",
		},
	},	
	[19] = {
		txt = "开灵光封魔难度2",
		gmTxt = {
			[1] = "/debug/1",
			[2] = "/entertiming/2",
		},
	},	
	[20] = {
		txt = "开灵光封魔难度3",
		gmTxt = {
			[1] = "/debug/1",
			[2] = "/entertiming/3",
		},
	},	
	[21] = {
		txt = "开灵光封魔难度4",
		gmTxt = {
			[1] = "/debug/1",
			[2] = "/entertiming/4",
		},
	},	
	[22] = {
		txt = "开灵光封魔难度5",
		gmTxt = {
			[1] = "/debug/1",
			[2] = "/entertiming/5",
		},
	},	
	[23] = {
		txt = "刻普通灵光封魔卷轴",
		gmTxt = {
			[1] = "/createitem/140620009/10",
		},
	},
	[24] = {
		txt = "全身Gm装备",
		gmTxt = {
			[1] = "/createitem/221000001/1",
			[2] = "/createitem/221000002/1",
			[3] = "/createitem/221000003/1",
			[4] = "/createitem/221000004/1",
			[5] = "/createitem/221000005/1",
			[6] = "/createitem/221000006/1",
			[7] = "/createitem/221000007/1",
			[8] = "/createitem/221000008/1",
			[9] = "/createitem/221000009/1",
			[10] = "/createitem/221000010/1",
			[11] = "/createitem/221000011/1",
		},
	},
	[25] = {
		txt = "开帮派王城战",
		gmTxt = {
			[1] = "/guildwarop/7",
			[2] = "/guildwarop/4",
		},
	},
	[26] = {
		txt = "关帮派王城战",
		gmTxt = {
			[1] = "/guildwarop/5",
		},
	},
	[27] = {
		txt = "功能全开",
		gmTxt = {},
		execute = function()
			for i=1,150 do
				local s = "/funcopen/"..i;
				ChatController:SendChat(ChatConsts.Channel_World,s)
			end
		end
	},
	[28] = {
		txt = "摄像机自由转动-开(Alt+鼠标滚轮按下)",
		gmTxt = {},
		execute = function()
			ToolsController.cameraFree = true;
		end
	},
	[29] = {
		txt = "摄像机自由转动-关",
		gmTxt = {},
		execute = function()
			ToolsController.cameraFree = false;
		end
	},
	[30] = {
		txt = "场景自由拖动-开(鼠标滚轮按下)",
		gmTxt = {},
		execute = function()
			ToolsController.sceneFree = true;
			local player =  MainPlayerController:GetPlayer();
			if player then
				player:GetAvatar():DisableCameraFollow();
			end
		end
	},
	[31] = {
		txt = "场景自由拖动-关",
		gmTxt = {},
		execute = function()
			ToolsController.sceneFree = false;
			CPlayerControl:ResetCameraPos(1000);
			local player =  MainPlayerController:GetPlayer();
			if player then
				player:GetAvatar():SetCameraFollow();
			end
		end
	},
	[32] = {
		txt = "隐藏UI(ESC恢复)",
		gmTxt = {},
		execute = function()
			UIManager:Switch();
			ToolsController.hideUI = true;
		end
	},
	[33] = {
		txt = "隐藏光标(ESC恢复)",
		gmTxt = {},
		execute = function()
			CCursorManager:AddState("hide");
			ToolsController.hideCursors = true;
		end
	},
	[34] = {
		txt = "save shader",
		gmTxt = {},
		execute = function()
			local sceneFile;
			if CLoginScene.objSceneMap then
				sceneFile = CLoginScene.objSceneMap.sSceneInfo.res
			else
				sceneFile = CPlayerMap.objSceneMap.sSceneInfo.res;
			end
			
			local index = string.find( sceneFile, '.sen' );
			local fname = string.sub( sceneFile, 1, index - 1 );
			fname = string.lower(fname);
			_sys:saveShader("resfile\\shr\\" .. fname .. ".shr")
		end
	},
	----------------------------test jeuxue-----------------------------
	[35] = {
		txt = "绝学残卷",
		gmTxt = {
			[1] = "/createitem/151200201/8500",
		},
	},
	[36] = {
		txt = "修为",
		gmTxt = {
			[1] = "/createitem/14/8000000",
		},
	},
	[37] = {
		txt = "狂风漫天技能书",
		gmTxt = {
			[1] = "/createitem/151200001/500",
		},
	},
	[38] = {
		txt = "烈火燎原技能书", 
		gmTxt = {
			[1] = "/createitem/151200002/500",
		},
	},
	[39] = {
		txt = "寒冰之劫技能书",  
		gmTxt = {
			[1] = "/createitem/151200007/500",
		},
	},
	[40] = {
		txt = "炫火岚光技能书",   
		gmTxt = {
			[1] = "/createitem/151200009/500",
		},
	},
	----------------------------test xinfa-----------------------------
	[41] = {
		txt = "地藏心经技能书",   
		gmTxt = {
			[1] = "/createitem/151200101/500",
		},
	},
	[42] = {
		txt = "金刚心经技能书",   
		gmTxt = {
			[1] = "/createitem/151200102/500",
		},
	},
	[43] = {
		txt = "无量寿经技能书",   
		gmTxt = {
			[1] = "/createitem/151200103/500",
		},
	},
	[44] = {
		txt = "观自在经技能书",   
		gmTxt = {
			[1] = "/createitem/151200104/500",
		},
	},
	[45] = {
		txt = "心法残卷",   
		gmTxt = {
			[1] = "/createitem/151200202/500",
		},
	},
	[46] = {
		txt = "加速移动(10)",
		gmTxt = {
			[1] = "/quickly/10",
		},
	},
	[47] = {
		txt = "场景编辑",
		gmTxt = {},
		execute = function()
			EditeController:SetEnabled(true);
			ToolsController.hideCursors = true;
		end
	},
	[48] = {
		txt = "新号+200等级和潜力点",
		gmTxt = {
			[1] = "/levelup/200",
			[2] = "/addpoint/999999999",
		},
	},
	[49] = {
		txt = "增加灵宝",
		gmTxt = {
			[1] = "/addlingbao/1002001",
		},
	},
	[50] = {
		txt = "变形测试",
		gmTxt = {},
		execute = function()
			local model = TransformController:HasTransform(MainPlayerModel.mainRoleID) and 0 or 1;
			TransformController:SetTransform(MainPlayerModel.mainRoleID,model,true);
			
			ToolsController.hideCursors = true;
		end
	},
}

_G.DebugActived = false;
_G.GMInput = {
	['start'] = {
		execute = function(params)
			_G.isDebug = false;
			local info = params[3];
			if info then
				_G.isDebug = info == 'true';
			end
		end,
	},
	['system'] = {
		execute = function(params)
			if #params<3 then
				return;
			end
			
			local type = params[3];
			local state = params[4];
			if state then
				state = state == 'true';
			end
			if type == 'state' then
				_sys.showStat = state;
			elseif type == 'record' then
				if  _G.Recording then
					if not state then
						_Archive.endRecord()
						local files = _Archive:getRecord()
						local str = '';	
						local list = '';
						local date = _localDate();
						local name = tostring(date.day)..'-'..tostring(date.hour)..'-'..tostring(date.minute)..'-'..tostring(date.second);
						name = 'record-'..name;
						for i,file in ipairs(files) do
							str = str ..'copy '..'..\\'..file..'\r\n';
							list = list..GetFileName(file)..'\r\n';
						end
						
						WriteFile(list,name,'.lua','list');
						WriteFile(str,name,'.bat','copy');
						-- _sys:command("copy.bat", true, false);
						_G.Recording = false;
						
						--[[local name = '文件录制';
						local str = '';
						local list = '';						
						for i,file in ipairs(files) do
							local sfs = split(file,"\\");
							local ffs = "";
							for i=1,#sfs-1 do
								ffs = ffs.."\\"..sfs[i];
							end
							str = str ..'copy '..'..\\'..file..' .\\'..ffs..'\\'..'\r\n';
							list = list..GetFileName(file)..'\r\n';
							ffs = name..ffs;
							_sys:createFolder(ffs);
						end
						WriteFile(list,name,'.lua','list');
						WriteFile(str,name,'.bat','copy');
						_G.Recording = false;]]
					end
				else
					if state then
						_G.Recording = true;
						_Archive.beginRecord();
					end
				end
			elseif type == 'loader' then
				local loader = _Loader.new()
				local count = #params;
				local url = '';
				for i=4,count-1 do
					url = url..params[i]..'/';
				end
				loader:loadHttp(url, params[count]);
				UIChat:ClientText("<font color = '#00ff00'>"..url.."下载开始</font>");
				loader:onFinish(function()
					UIChat:ClientText("<font color = '#ff0000'>"..params[count].."下载完成</font>");
				end);
			end
		end,
	},
	['print'] = {
		help = '/print/fps  启动帧频跟踪<br/>',
		execute = function(params)
			local type = params[3];
			if type == 'ui' then
				
			elseif type == 'fps' then
				local interval = toint(params[4]);
				if interval >0 then
					_G.GMInput.FPSTimer = TimerManager:RegisterTimer(function()
						local desc = 'PFS:'.._sys.fps;
						print(desc);
						if _sys.fps > 45 then
							desc = "<font color = '#ff0000'>" .. desc .. "</font>";
						else
							desc = "<font color = '#00ff00'>" .. desc .. "</font>";
						end
					end,interval);
				else
					TimerManager:UnRegisterTimer(_G.GMInput.FPSTimer);
				end
			end
		end,
	},
	['ui'] = {
		help = '/ui/all/true  开关所有UI<br/>/ui/xxx/true  开关某一个UI<br/>/ui/gc  销毁隐藏的UI<br/>',
		execute = function(params)
			if #params<3 then
				return;
			end
			
			local state = params[4];
			if state then
				state = state == 'true';
			end
			
			local type = params[3];
			if type == 'all' then
				local result = state and UIManager:RecoverAll() or UIManager:HideAll();
				return;
			end
			
			if type == 'gc' then
				UIManager:DeleteUI();
				_G.GMInput['gc'].execute();
				return;
			end
			
			local ui = UIManager:GetUI(params[3]);
			if not ui then
				return;
			end
			
			if state then
				ui:Show();
			else
				ui:DoHide();
				ui:DeleteSWF();
				_G.GMInput['gc'].execute();
			end
		end,
	},
	['gc'] = {
		help = '/gc  执行一次GC<br/>',
		execute = function(params)
			local tm = _sys.totalMemory;
			local um = _sys.usedMemory;
			LuaGC();
			tm = _sys.totalMemory - tm;
			um = _sys.usedMemory - um;
			local desc = 'TotalMemory:' .. tm .. ' UsedMemory:' .. um;
			print(desc);
			UIChat:ClientText(desc);
		end
	},
	['fmt'] = {
		help = '/fmt/all/true  开关FMT读取<br/>',
		execute = function(params)
			if #params<4 then
				return;
			end
			
			local state = params[4];
			if state then
				state = state == 'true';
			end
			
			if params[3] == 'all' then
				CPlayerMap.objSceneMap.useFmt.state = state;
				return;
			end
			
		end
	},
	['shadow'] = {
		help = '/shadow/true  开关影子<br/>',
		execute = function(params)
			if #params<3 then
				return;
			end
			
			local state = params[3];
			if state then
				state = state == 'true';
			end
			CPlayerMap.objSceneMap.useShadow = state;
		end
	},
	['model'] = {
		help = '/model/bianxing/true  开关变形<br/>/model/jianmo/true  是否使用简模<br/>',
		execute = function(params)
			if #params<4 then
				return;
			end
			
			
			local type = params[3];
			if type == 'bianxing' then
				local state = params[4];
				if state then
					state = state == 'true';
				end
				CPlayerMap:SetPlayerEquipActState(start);
			elseif type == 'equip' then
				local player = MainPlayerController:GetPlayer();
				if player then
					local avatar = player:GetAvatar();
					if avatar then
						local id = toint(params[4]);
						if id == -1 then
							avatar:RemoveAllEquips();
						else
							if not avatar:RemoveEquip(id) then
								avatar:AddEquip(id,true);
							end
						end
					end
				end
			end
			
		end
	},
	['weather'] = {
		help = '/weather/true  开关天气<br/>',
		execute = function(params)
			if #params<3 then
				return;
			end
			
			local state = params[3];
			if state then
				state = state == 'true';
			end
			local result = state and WeatherController:OnCheckMapArea() or WeatherController:clearWeatherPfx();
		end
	},
	['scene'] = {
		help = '/scene/effect/true  开关场景特效<br/>/scene/limit/charType/count  限制场景生物数量<br/>/scene/goto/mapid	客户端跳转地图<br/>',
		execute = function(params)
			if #params<4 then
				return;
			end
			
			local type = params[3];
			if type == 'effect' then
				local state = params[4];
				if state then
					state = state == 'true';
				end
				
				if not state then
					CPlayerMap.objSceneMap.objScene.pfxPlayer:stopAll(true);
					CPlayerMap.objSceneMap.objScene.pfxPlayer:clearParams()
				end
				
			elseif type == 'limit' then
				if #params<5 then
					return;
				end
				
				local count = toint(params[5]);
				if count == -1 then
					CharController:ResetLimits();
				elseif count<-1 then
					CharController:ClearAllLimits();
				else
					CharController:SetCountLimit(toint(params[4]),count);
				end
			elseif type == 'goto' then
				local id = tonumber(params[4]);
				local point = MapUtils:GetMapBirthPoint(id);
				if point then
					local msg = {};
					msg.msgId = 8001;
					msg.msgType = "SC_SCENE_ENTER_GAME";
					msg.msgClassName = "RespSceneEnterGameMsg";
					msg.result = 0; -- 结果
					msg.lineID = 1; -- 线
					msg.posX = point.x; -- X坐标
					msg.posY = point.y; -- Y坐标
					msg.dir = 0; -- 方向
					msg.mapID = id; -- 地图ID
					msg.dungeonId = 0; -- 副本ID
					msg.type = 1; -- 0:登录游戏 1:切换场景
					msg.serverSTime = 0; -- 开服时间,时间戳,秒
					msg.MergeSTime = 0; -- 合服时间,时间戳,秒
					MainPlayerController:OnEnterGameMsg(msg);
				end
			end
			
		end
	},
	['pause'] = {
		help = '/pause/timer/true  开关计时器<br/>/pause/event/true  开关事件派发器<br/>',
		execute = function(params)
			if #params<4 then
				return;
			end
			
			local state = params[4];
			if state then
				state = state == 'true';
			end
			
			local type = params[3];
			if type == 'timer' then
				TimerManager:SetEnabled(not state);
			elseif type == 'event' then
				Notifier:SetEnabled(not state);
			end
		end
	},
	['help'] = {
		execute = function(params)
			local desc = '';
			for i,gm in pairs(_G.GMInput) do
				if gm.help then
					desc = desc..gm.help;
				end
			end
			UIChat:ClientText(desc);
		end
	},
}

_G.RecordScene = {
	[10200003] = 0,
	[10430001] = 0,
	[10430002] = 0,
	[10430003] = 0,
	[10430004] = 0,
	[10400021] = 0,
	[10320001] = 0,
	[10400010] = 0,
	[10400023] = 0,
	[10400029] = 0,
	[11000001] = 0,
	[11000006] = 0,
	[11000017] = 0,
	[11000008] = 0,
	[11000009] = 0,
	[11000010] = 0,
	[11000002] = 0,
	[11000003] = 0,
	[11300002] = 0,
	[11300003] = 0,
	[11300004] = 0,
	[11300005] = 0,
	[11300006] = 0,
	[11300007] = 0,
	[11301001] = 0,
	[11301002] = 0,
	[11301004] = 0,
	[11400001] = 0,
	[11401001] = 0,
	[11401102] = 0,
	[11401106] = 0,
	[11401107] = 0,
	[11402003] = 0,
	[11402005] = 0,
	[11402006] = 0,
	[10400022] = 0,
}
_G.RecordTimer = nil;
_G.SceneRecord = false;
_G.OnRecordScene = function(mapId,start)
	if not _G.SceneRecord then
		return;
	end
	
	TimerManager:UnRegisterTimer(_G.RecordTimer);
	if start then
		local nowrecord = nil;
		for id,f in pairs(_G.RecordScene) do
			if f == 1 then
				nowrecord = id;
				break;
			end
		end
		
		if nowrecord then
			_G.RecordScene[nowrecord] = 2;
			_G.StepRecord(false);
		end
		
		nowrecord = mapId;
		local flag = _G.RecordScene[nowrecord];
		if flag ~=0 then
			nowrecord = nil;
			for id,f in pairs(_G.RecordScene) do
				if f == 0 then
					nowrecord = id;
					break;
				end
			end		
		end
		
		if not nowrecord then
			_G.StepRecord(false);
			UIChat:ClientText("<font color = '#ff0000'>完成所有录制</font>");
			return;
		end
		_G.RecordScene[nowrecord]=1;
		_G.StepRecord(true);
		return true;
	else
		local fun = function()
			local record = nil;
			for id,f in pairs(_G.RecordScene) do
				if f == 0 then
					record = id;
					break;
				end
			end
			if not record then
				_G.OnRecordScene(CPlayerMap:GetCurMapID(),true);
			else
				local params = {};
				params[1] = 'scene';
				params[2] = 'scene';
				params[3] = 'goto';
				params[4] = tostring(record);
				_G.GMInput['scene'].execute(params);
			end
		end
		_G.RecordTimer = TimerManager:RegisterTimer(fun,20000,1);
		return true;
	end
end

















