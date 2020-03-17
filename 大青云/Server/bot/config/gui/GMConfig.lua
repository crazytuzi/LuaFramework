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
		txt = "100万礼金：",
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
}