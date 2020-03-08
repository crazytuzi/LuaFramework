--选择创建角色
Require("Script/Sdk.lua")

local RepresentMgr = luanet.import_type("RepresentMgr");
local ReprentEvent = luanet.import_type("ReprentEvent");
local AvatarHeadInfoMgr = luanet.import_type("AvatarHeadInfoMgr");
local NpcViewMgr = Ui.NpcViewMgr
local SceneMgr = luanet.import_type("SceneMgr");
local SdkMgr = luanet.import_type("SdkInterface");

--登陆场景参数
Login.szSceneMapName = "choose6"; --
Login.szSceneCameraName = "Main Camera";

local szCameraObjPathName = "/Npclight/choose4_cam/Camera001_Ctrl001"
local szCameraObjRootName = "/Npclight/choose4_cam"
local szSelectAniDefault = "all_s01"; --全部人时的默认动画
local szAnimatorController = "select1";
local tbDirectionEffect = {
	"/Npclight/choose4_cam/Camera001_Ctrl001/Main Camera/Choose4_Camera001_Ctrl001_guangyun/changjing_guangyun_Z",
	"/Npclight/choose4_cam/Camera001_Ctrl001/Main Camera/Choose4_Camera001_Ctrl001_guangyun/changjing_guangyun_Y",
}

Login.nBlackBgSoundId = 8015; --打开黑色幕布时

local tbDefaultSelRoleInfo = { --key 为 门派id ,key需要从1按顺序
	[1] = {
		[Player.SEX_MALE] = {
			szSceneSelObjName = "tw_dld", --选中单个时的选人
			szCameraAniSelect = "tw_cam1",
			szModelShowAniName= "denglu",
			szEffectName = "NormalEffect",
			szFirstSelEffectName = "FirstEffect",
			fSelAniLen = 1.5, --选中动画的时长
			nSounId = 8016,
			nSounId2 = version_kor and 5101 or nil,
		};
		[Player.SEX_FEMALE] = {
			szSceneSelObjName = "f1_tw_dld", --选中单个时的选人
			szCameraAniSelect = "f1_tw_cam1",
			szModelShowAniName= "denglu",
			szEffectName = "NormalEffect",
			szFirstSelEffectName = "FirstEffect",
			fSelAniLen = 1.5, --选中动画的时长
			nSounId = 8047,
			nSounId2 = version_kor and 5125 or nil,
		};
		szFaction = "天王",
	};
	[2] = {
			szSceneSelObjName = "em_dld", --选中单个时的选人
			szCameraAniSelect = "em_cam1",
			szModelShowAniName= "denglu01",
			szEffectName = "NormalEffect",
			szFirstSelEffectName = "FirstEffect",
			fSelAniLen = 1.5, --选中动画的时长
			nSounId = 8042,
			nSounId2 = version_kor and 5102 or nil,

			szFaction = "峨眉",
		  };

	[3] = {
			szSceneSelObjName = "th_dld", --选中单个时的选人
			szCameraAniSelect = "th_cam1",
			szModelShowAniName= "denglu01",
			szEffectName = "NormalEffect",
			szFirstSelEffectName = "FirstEffect",
			fSelAniLen = 1.5, --选中动画的时长
			nSounId = 8018,
			nSounId2 = version_kor and 5103 or nil,

			szFaction = "桃花",
		};

	[4] = {
		[Player.SEX_MALE] 	= {
			szSceneSelObjName = "xy_dld", --选中单个时的选人
			szCameraAniSelect = "xy_cam1",
			szModelShowAniName= "denglu01",
			szEffectName = "NormalEffect",
			szFirstSelEffectName = "FirstEffect",
			fSelAniLen = 1.5, --选中动画的时长
			nSounId = 8019,
			nSounId2 = version_kor and 5104 or nil,
		};
		[Player.SEX_FEMALE] = {
			szSceneSelObjName = "f2_xy_dl", --选中单个时的选人
			szCameraAniSelect = "f2_xy_cam1",
			szModelShowAniName= "f2_xy_dl",
			szEffectName = "NormalEffect",
			szFirstSelEffectName = "FirstEffect",
			fSelAniLen = 1.5, --选中动画的时长
			nSounId = 5530,
			nSounId2 = version_kor and 5104 or nil,
		};
		szFaction = "逍遥",
		  };
	[5] = {
		[Player.SEX_MALE] = {
			szSceneSelObjName = "wd_dld", --选中单个时的选人
			szCameraAniSelect = "wd_cam1",
			szModelShowAniName= "Take 001",
			szEffectName = "NormalEffect",
			szFirstSelEffectName = "FirstEffect",
			fSelAniLen = 1.5, --选中动画的时长
			nSounId = 8020,
			nSounId2 = version_kor and 5105 or nil,
		};
		[Player.SEX_FEMALE] = {
			szSceneSelObjName = "f2_wd_dld", --选中单个时的选人
			szCameraAniSelect = "f2_wd_cam1",
			szModelShowAniName= "Take 001",
			szEffectName = "NormalEffect",
			szFirstSelEffectName = "FirstEffect",
			fSelAniLen = 1.5, --选中动画的时长
			nSounId = 5627,
			nSounId2 = version_kor and 5119 or nil,
		};
		szFaction = "武当",

		  };
	[6] = {
		[Player.SEX_MALE] = {
			szSceneSelObjName = "m1_tr_dl", --选中单个时的选人
			szCameraAniSelect = "m1_tr_cam1",
			szModelShowAniName= "m1_tr_dl",
			szEffectName = "NormalEffect",
			szFirstSelEffectName = "FirstEffect",
			fSelAniLen = 1.5, --选中动画的时长
			nSounId = 8048,
			nSounId2 = version_kor and 5106 or nil,
		};
		[Player.SEX_FEMALE] = {
			szSceneSelObjName = "tr_dld", --选中单个时的选人
			szCameraAniSelect = "tr_cam1",
			szModelShowAniName= "denglu01",
			szEffectName = "NormalEffect",
			szFirstSelEffectName = "FirstEffect",
			fSelAniLen = 1.5, --选中动画的时长
			nSounId = 8021,
			nSounId2 = version_kor and 5106 or nil,

		};
		szFaction = "天忍",
		  };
	[7] = {
			szSceneSelObjName = "sl_dld", --选中单个时的选人
			szCameraAniSelect = "sl_cam1",
			szModelShowAniName= "denglu01",
			szEffectName = "NormalEffect",
			szFirstSelEffectName = "FirstEffect",
			fSelAniLen = 1.5, --选中动画的时长
			nSounId = 8022,
			nSounId2 = version_kor and 5107 or nil,

			szFaction = "少林",
		  };
	[8] = {
			szSceneSelObjName = "cy_dld", --选中单个时的选人
			szCameraAniSelect = "cy_cam1",

			szFirstSelObjName1 = "/scenes/cy_dld/F4_001_h2",
			szFirstSelObjName2 = "/scenes/cy_dld/F4_001_h3",
			szModelShowAniName1= "xiongmaodenglu",
			szModelShowAniName2 = "cy_denglu",
			szEffectName = "NormalEffect",
			szFirstSelEffectName = "FirstEffect",
			fSelAniLen = 1.5, --选中动画的时长
			nSounId = 8023,
			nSounId2 = version_kor and 5108 or nil,

			szFaction = "翠烟",
		  };
	[9] = {
			szSceneSelObjName = "tm_dld", --选中单个时的选人
			szCameraAniSelect = "tm_cam1",
			szModelShowAniName= "denglu01",
			szEffectName = "NormalEffect",
			szFirstSelEffectName = "FirstEffect",
			fSelAniLen = 1.5, --选中动画的时长
			nSounId = 8040,
			nSounId2 = version_kor and 5109 or nil,

			szFaction = "唐门",
		  };
  	[10] = {
  			[Player.SEX_MALE]  = {
  				szSceneSelObjName = "m2_kl_dld", --选中单个时的选人
				szCameraAniSelect = "m2_kl_cam1",
				szModelShowAniName= "m2_kl_dl",
				szEffectName = "NormalEffect",
				szFirstSelEffectName = "FirstEffect",
				fSelAniLen = 1.5, --选中动画的时长
				nSounId = 8046,
				nSounId2 = version_kor and 5122 or nil,
  			};
  			[Player.SEX_FEMALE] = {
  				szSceneSelObjName = "kl_dld", --选中单个时的选人
				szCameraAniSelect = "kl_cam1",
				szModelShowAniName= "denglu01",
				szEffectName = "NormalEffect",
				szFirstSelEffectName = "FirstEffect",
				fSelAniLen = 1.5, --选中动画的时长
				nSounId = 8043,
				nSounId2 = version_kor and 5110 or nil,
  			};
			szFaction = "昆仑",
	 	 };
 	[11] = {
	 		[Player.SEX_MALE] = {
	 			szSceneSelObjName = "gaibang_dld", --选中单个时的选人
				szCameraAniSelect = "gaibang_cam1",
				szModelShowAniName= "denglu",
				szEffectName = "NormalEffect",
				szFirstSelEffectName = "FirstEffect",
				fSelAniLen = 1.5, --选中动画的时长
				nSounId = 5971,
				nSounId2 = version_kor and 5111 or nil,
	 		};
	 		[Player.SEX_FEMALE] = {
	 			szSceneSelObjName = "f1_gb", --选中单个时的选人
				szCameraAniSelect = "f1_gb_cam1",
				szModelShowAniName= "denglu01",
				szEffectName = "NormalEffect",
				szFirstSelEffectName = "FirstEffect",
				fSelAniLen = 1.5, --选中动画的时长
				nSounId = 5974,
				nSounId2 = version_kor and 5111 or nil,
	 		};

			szFaction = "丐帮",
		  };
  	[12] = {
			szSceneSelObjName = "wudu_dld", --选中单个时的选人
			szCameraAniSelect = "wudu_cam1",
			szModelShowAniName= "denglu",

			szFirstSelObjName1 = "/scenes/wudu_dld/wudu_denglu",
			szFirstSelObjName2 = "/scenes/wudu_dld/wudu_denglu2",
			szModelShowAniName1= "denglu",
			szModelShowAniName2 = "Take 001",

			szEffectName = "NormalEffect",
			szFirstSelEffectName = "FirstEffect",
			fSelAniLen = 1.5, --选中动画的时长
			nSounId = 5993,
			nSounId2 = version_kor and 5112 or nil,

			szFaction = "五毒",
		  };
 	[13] = {
		szSceneSelObjName = "cj_dld", --选中单个时的选人
		szCameraAniSelect = "cj_cam1",
		szModelShowAniName= "denglu01",
		szEffectName = "NormalEffect",
		szFirstSelEffectName = "FirstEffect",
		fSelAniLen = 1.5, --选中动画的时长
		nSounId = 6010,
		nSounId2 = version_kor and 5113 or nil,

		szFaction = "藏剑",
	  };
   	[14] = {
		szSceneSelObjName = "cg_dld", --选中单个时的选人
		szCameraAniSelect = "cg_cam1",
		szModelShowAniName= "denglu01",
		szEffectName = "NormalEffect",
		szFirstSelEffectName = "FirstEffect",

		szFirstSelObjName1 = "/scenes/cg_dld/cg_dl",
		szModelShowAniName1= "denglu01",
		fSelAniLen = 1.5, --选中动画的时长
		nSounId = 6030,
		nSounId2 = version_kor and 5114 or nil,

		szFaction = "长歌",
	  };
	[15] = {
		[Player.SEX_MALE] = {
			szSceneSelObjName = "m1_ts_dld", --选中单个时的选人
			szCameraAniSelect = "m1_ts_cam1",
			szModelShowAniName= "m1_ts_denglu",
			szEffectName = "NormalEffect",
			szFirstSelEffectName = "FirstEffect",
			fSelAniLen = 1.5, --选中动画的时长
			nSounId = 8045,
			nSounId2 = version_kor and 5115 or nil,

		};
		[Player.SEX_FEMALE] = {
			szSceneSelObjName = "f2_ts_dld", --选中单个时的选人
			szCameraAniSelect = "f2_ts_cam1",
			szModelShowAniName= "f2_ts_denglu",
			szEffectName = "NormalEffect",
			szFirstSelEffectName = "FirstEffect",
			fSelAniLen = 1.5, --选中动画的时长
			nSounId = 8044,
			nSounId2 = version_kor and 5116 or nil,
		};
		szFaction = "天山",
	  };
	  [16] = {
		[Player.SEX_MALE] = {
			szSceneSelObjName = "m2_bd_dld", --选中单个时的选人
			szCameraAniSelect = "m2_bd_cam1",
			szModelShowAniName= "Take 001",
			szEffectName = "NormalEffect",
			szFirstSelEffectName = "FirstEffect",
			fSelAniLen = 1.5, --选中动画的时长
			nSounId = 6084,
			nSounId2 = version_kor and 5117 or nil,
		};
		[Player.SEX_FEMALE] = {
			szSceneSelObjName = "f1_bd_dld", --选中单个时的选人
			szCameraAniSelect = "f1_bd_cam1",
			szModelShowAniName= "Take 001",
			szEffectName = "NormalEffect",
			szFirstSelEffectName = "FirstEffect",
			fSelAniLen = 1.5, --选中动画的时长
			nSounId = 6085,
			nSounId2 = version_kor and 5118 or nil,
		};
		szFaction = "霸刀",
	  };
	  [17] = {
		[Player.SEX_MALE] = {
			szSceneSelObjName = "m1_hs_dld", --选中单个时的选人
			szCameraAniSelect = "m1_hs_cam1",
			szModelShowAniName= "m1_hs_dl",
			szEffectName = "NormalEffect",
			szFirstSelEffectName = "FirstEffect",
			fSelAniLen = 1.5, --选中动画的时长
			nSounId = 6117,
			nSounId2 = version_kor and 5120 or nil,
		};
		[Player.SEX_FEMALE] = {
			szSceneSelObjName = "f2_hs_dld", --选中单个时的选人
			szCameraAniSelect = "f2_hs_cam1",
			szModelShowAniName= "f2_hs_dl",
			szEffectName = "NormalEffect",
			szFirstSelEffectName = "FirstEffect",
			fSelAniLen = 1.5, --选中动画的时长
			nSounId = 6118,
			nSounId2 = version_kor and 5121 or nil,
		};
		szFaction = "华山",
	  };
	  [18] = {
		[Player.SEX_MALE] = {
			szSceneSelObjName = "m1_mj_dld", --选中单个时的选人
			szCameraAniSelect = "m1_mj_cam1",
			szModelShowAniName= "Take 001",
			szEffectName = "NormalEffect",
			szFirstSelEffectName = "FirstEffect",
			fSelAniLen = 1.5, --选中动画的时长
			nSounId = 6135,
			nSounId2 = version_kor and 5123 or nil,
		};
		[Player.SEX_FEMALE] = {
			szSceneSelObjName = "f2_mj_dld", --选中单个时的选人
			szCameraAniSelect = "f2_mj_cam1",
			szModelShowAniName= "Take 001",
			szEffectName = "NormalEffect",
			szFirstSelEffectName = "FirstEffect",
			fSelAniLen = 1.5, --选中动画的时长
			nSounId = 6136,
			nSounId2 = version_kor and 5124 or nil,
		};
		szFaction = "明教",
	  };
  	  [19] = {
		[Player.SEX_MALE] = {
			szSceneSelObjName = "m1_ds_dl", --选中单个时的选人
			szCameraAniSelect = "m1_ds_cam1",
			szModelShowAniName= "m1_ds_dl",
			szEffectName = "NormalEffect",
			szFirstSelEffectName = "FirstEffect",
			fSelAniLen = 1.5, --选中动画的时长
			nSounId = 6153,
			nSounId2 = version_kor and 5117 or nil,
		};
		[Player.SEX_FEMALE] = {
			szSceneSelObjName = "f1_ds_dl", --选中单个时的选人
			szCameraAniSelect = "f1_ds_cam1",
			szModelShowAniName= "f1_ds_dl",
			szEffectName = "NormalEffect",
			szFirstSelEffectName = "FirstEffect",
			fSelAniLen = 1.5, --选中动画的时长
			nSounId = 6154,
			nSounId2 = version_kor and 5118 or nil,
		};
		szFaction = "段氏",
	  };
	  [20] = {
	  	[Player.SEX_MALE] = {
			szSceneSelObjName = "m1_wh", --选中单个时的选人
			szCameraAniSelect = "m1_wh_cam1",
			szModelShowAniName= "denglu01",
			szEffectName = "NormalEffect",
			szFirstSelEffectName = "FirstEffect",
			fSelAniLen = 1.5, --选中动画的时长
			nSounId = 6174,
			nSounId2 = version_kor and 5117 or nil,
		};
		[Player.SEX_FEMALE] = {
			szSceneSelObjName = "f2_wh", --选中单个时的选人
			szCameraAniSelect = "f2_wh_cam1",
			szModelShowAniName= "denglu01",
			szEffectName = "NormalEffect",
			szFirstSelEffectName = "FirstEffect",
			fSelAniLen = 1.5, --选中动画的时长
			nSounId = 6175,
			nSounId2 = version_kor and 5118 or nil,
		};
		szFaction = "万花",
	  };
  	  [21] = {
	  	[Player.SEX_MALE] = {
			szSceneSelObjName = "m1_ym_dl", --选中单个时的选人
			szCameraAniSelect = "m1_ym_cam1",
			szModelShowAniName= "m1_ym_dl",

			szFirstSelObjName1 = "/scenes/m1_ym_dl/m1_m1_ym_h",
			szFirstSelObjName2 = "/scenes/m1_ym_dl/m1_f2_ym_h",
			szModelShowAniName1= "m1_ym_dl",
			szModelShowAniName2 = "m1_ym_dl",

			szEffectName = "NormalEffect",
			szFirstSelEffectName = "FirstEffect",
			fSelAniLen = 1.5, --选中动画的时长
			nSounId = 8049,
			nSounId2 = version_kor and 5117 or nil,
		};
		[Player.SEX_FEMALE] = {
			szSceneSelObjName = "f2_ym_dl", --选中单个时的选人
			szCameraAniSelect = "f2_ym_cam1",
			szModelShowAniName= "f2_ym_dl",

			szFirstSelObjName1 = "/scenes/f2_ym_dl/f2_f2_ym_dl",
			szFirstSelObjName2 = "/scenes/f2_ym_dl/f2_m1_ym_dl",
			szModelShowAniName1= "f2_ym_dl",
			szModelShowAniName2 = "f2_ym_dl",

			szEffectName = "NormalEffect",
			szFirstSelEffectName = "FirstEffect",
			fSelAniLen = 1.5, --选中动画的时长
			nSounId = 8050,
			nSounId2 = version_kor and 5118 or nil,
		};
		szFaction = "杨门",
	  };
}

Login.SERVER_TYPE_NORMAL 		= 0;		-- 正常
Login.SERVER_TYPE_OFFLINE 		= 1;		-- 维护
Login.SERVER_TYPE_RECOMMAND 	= 2;		-- 推荐
Login.SERVER_TYPE_NEW 		= 3;		-- 新服
Login.SERVER_TYPE_HOT			= 4;		--  火爆
Login.SERVER_TYPE_BUSY		= 5;		--  繁忙

Login.ACCOUNT_MAX_ROLE_COUNT = 6;

Login.SOUND_BG = {10, 11, 12, 17}  --每次登录歌曲从里面循环
if version_vn then
	Login.SOUND_BG = {10, 11, 12, 14, 16, 21, 18}  --每次登录歌曲从里面循环
elseif version_kor then
	Login.SOUND_BG = {17}
end

function Login:OpenLoginScene(bShowLoading)
	self.tbSelRoleInfo = Lib:CopyTB(tbDefaultSelRoleInfo);
	self.bMapLoaded = false;
	self.bRoleListDone = false;

	if bShowLoading then
		Ui:OpenWindow("MapLoading", 0, me.nMapTemplateId);
	end
	if SceneMgr.s_nMapTemplateID == 0 then
		self:BackToRoleList(true)
		self:OnMapLoaded();
	else
		self.tbLoadRoleResInfo = {["cj"] = true};
		if bShowLoading then
			Ui.ToolFunction.LoadMap(self.szSceneMapName, self.szSceneCameraName, 0, false);
		else
			Ui:OpenWindow("MapLoading", 0, 0);
		end
	end

	Ui:PreLoadWindow("CreateRole")
end


function Login:OnSyncRoleListDone()
	Log(">>> role list done !!");
	if self.nCurSelNpc then --选角色页上断线重连 重新载入选角场景会清
		return
	end
	self.bRoleListDone = true;

	local tbRole = GetRoleList()
	table.sort( tbRole, function ( a, b )
		return a.nLevel > b.nLevel
	end )

	local tbReportRoleList = {}

	for i, v in ipairs(tbRole) do
		local tbSelInfo = self:GetRealRoleInfo(v.nFaction, v.nSex)

		if not tbSelInfo.tbCreateRole then
			tbSelInfo.tbCreateRole = v;
		else
			--有出现同门派创建重名的
			if not tbSelInfo.tbCreateRole.tbOhters then
				local tbTemp = Lib:CopyTB(tbSelInfo.tbCreateRole)
				tbSelInfo.tbCreateRole.tbOhters = {};
				table.insert(tbSelInfo.tbCreateRole.tbOhters, tbTemp)
			end
			table.insert(tbSelInfo.tbCreateRole.tbOhters, v)
		end

		table.insert(tbReportRoleList, { role_id = v.nRoleID, role_name = v.szName })
	end
	self.szReportRoleList = Lib:EncodeJson(tbReportRoleList)

	SdkMgr.ReportDataLoadRole("0", Sdk:GetCurAppId(), tostring(SERVER_ID), self.szReportRoleList, 2)

	self:OnRoleListDoneAndMapLoaded();
end

function Login:ClearNpcs()
	for nFaction,v in pairs(self.tbSelRoleInfo) do
		local tbSexes = Player:GetFactionSexs(nFaction)
		for _, nSex in ipairs(tbSexes) do
			local tbRealV = self:GetRealRoleInfo(nFaction, nSex)
			local szPrefbName = string.gsub(tbRealV.szSceneSelObjName, "_dld$", "");
			if self.tbLoadRoleResInfo[szPrefbName]  then
				AvatarHeadInfoMgr.DestroyAvatarHeadInfo(tbRealV.szSceneSelObjName)
			end
		end
	end

	self:ClearTimers()
end

function Login:fnOpenCreateRoleWindow( tbRoleInfo, nNpcId, nSex )
	local tbParam = {
		tbRoleInfo = tbRoleInfo;
		nNpcId = nNpcId;
		nSex = nSex;
		tbSelRoleInfo = Login.tbSelRoleInfo;
	};
	if Ui:WindowVisible("CreateRole") == 1 then
		Ui("CreateRole"):OnOpen(tbParam)
	else
		Ui:OpenWindow("CreateRole", tbParam)
	end
	local nPlayerLevel = 1;
	if nNpcId then
		local tbSelInfo = Login:GetRealRoleInfo(nNpcId, nSex)
		if tbSelInfo and tbSelInfo.tbCreateRole then
			nPlayerLevel = tbSelInfo.tbCreateRole.nLevel
		end
		if  tbSelInfo and tbSelInfo.tbCreateRole and tbSelInfo.tbCreateRole.tbOhters then
			AvatarHeadInfoMgr.SetAvatarHeadInfoVisible(tbRoleInfo.szSceneSelObjName, false)
		else
			AvatarHeadInfoMgr.SetAvatarHeadInfoVisible(tbRoleInfo.szSceneSelObjName, true)
		end
	end
	Item.tbRefinement:PreLoadTypeAttribValue(nPlayerLevel)
end


function Login:UpdateRoleHeadInfo(tbCreateRole)
	local nFaction = tbCreateRole.nFaction
	local szBanInfo = ""
	if tbCreateRole.nBanEndTime < 0 or (tbCreateRole.nBanEndTime > 0 and tbCreateRole.nBanEndTime > GetTime()) then
		szBanInfo = "(已冻结)"
	end
	local v = self:GetRealRoleInfo(nFaction, tbCreateRole.nSex)
	AvatarHeadInfoMgr.SetAvatarHeadInfo(v.szSceneSelObjName, tbCreateRole.szName, szBanInfo, string.format("%d级", tbCreateRole.nLevel))
end

function Login:OnRoleListDoneAndMapLoaded()
	if not self.bMapLoaded or not self.bRoleListDone then --or not self.bModelLoaded
		return
	end


	local bHasNoCreateRole = true
	for nFaction, v in pairs(self.tbSelRoleInfo) do
		local tbSexes = Player:GetFactionSexs(nFaction)
		for _,nSex in ipairs(tbSexes) do
			local vReal = self:GetRealRoleInfo(nFaction, nSex)
			if vReal.tbCreateRole then
				bHasNoCreateRole = false
			end
		end
	end

	self.bMapLoaded = nil; --重登录时清状态
	self.bRoleListDone = nil;

	-- Ui("LoginBg"):HideAllMovie()

	self.bHasNoCreateRole = bHasNoCreateRole

	local tbUi = Ui("Login") or Ui("MapLoading");
	if tbUi then
		local tbSceenszie = tbUi.pPanel:Panel_GetSize("Main")
		if tbSceenszie.y ~= 0 then
			-- 根据屏幕分辨率设置 fov
			-- (1.778646, 26)，  (1.333333, 30)   -- 1366/768 , 4/3
			local fnFov = (30 - 26) / (1.333333 - 1.778646) * ( tbSceenszie.x / tbSceenszie.y - 1.778646) + 26
			if fnFov > 0 then
				Ui.CameraMgr.DirectChangeCameraFov(fnFov); --todo
			end
		end
	end

	-- Ui:CloseAllWindow();
	Ui:CloseWindow("Login")

	if not bHasNoCreateRole then
		self:OnPlayCGEnd()
	else
		Ui.CameraMgr.SetMainCameraActive(false)
		-- if IOS then
		-- 	Ui("LoginBg"):ShowCG()
		-- 	Ui:SetMusicVolume(0)
		-- else
		Ui.ToolFunction.PlayCGMovie(true)
		-- end
	end
end

function Login:AutoSelectRoleById(dwRoleId)
	if not dwRoleId then
		return
	end
	for nFaction,v in ipairs(self.tbSelRoleInfo) do
		local tbSexes = Player:GetFactionSexs(nFaction)
		for _,nSex in ipairs(tbSexes) do
			local vReal = self:GetRealRoleInfo(nFaction, nSex)
			if vReal.tbCreateRole then
				if vReal.tbCreateRole.nRoleID == dwRoleId then
					self:SelRole(nFaction, true, nSex);
					return true
				elseif vReal.tbCreateRole.tbOhters then
					for nIndex,v2 in ipairs(vReal.tbCreateRole.tbOhters) do
						if v2.nRoleID == dwRoleId then
							self:SwitchRoleSelIndex(vReal.tbCreateRole, nIndex)
							self:SelRole(nFaction, true, nSex);
							return true
						end
					end
				end
			end
		end
	end
end

function Login:OnPlayCGEnd()
	Ui:CloseWindow("LoginBg")
	Ui.UiManager.DestroyUi("LoginBg")
	Ui.CameraMgr.SetMainCameraActive(true)
	Ui:UpdateSoundSetting()

	self.nCurSelNpc = nil;
	self.nCurSelSex = nil;

	local tbLastLoginfo = Client:GetUserInfo("LoginRole", -1)
	local tbRoles = GetRoleList()
	local dwRoleId	 = tbLastLoginfo[GetAccountName()]
	if dwRoleId then --可能换了服务器或数据库，这个默认角色还是无效的
		local bFind = false
		for i,v in ipairs(tbRoles) do
			if v.nRoleID == dwRoleId then
				bFind = true
				break;
			end
		end
		if not bFind then
			dwRoleId = nil;
		end
	end
	if not dwRoleId then --如果没有记录上次角色，就默认选中等级最大的
		local nMaxLevel = 0;
		for i,v in ipairs(tbRoles) do
			if v.nLevel > nMaxLevel then
				dwRoleId = v.nRoleID;
				nMaxLevel = v.nLevel
			end
		end
	end
	if not self:AutoSelectRoleById(dwRoleId) then
		self.bHasNoCreateRole = true
		local nDefaultSel =  IS_OLD_SERVER and MathRandom(#self.tbSelRoleInfo - 1) or MathRandom(#self.tbSelRoleInfo);
		local nSex = Player:Faction2Sex(nDefaultSel, Player.SEX_MALE)
		self:SelRole(nDefaultSel, false, nSex);
	end
	self.bHasNoCreateRole = nil;


	if version_kor and ANDROID then
		Sdk:XGOpenAnnounce();
	end
end

function Login:SwitchRoleSelIndex(tbCreateRole, nIndex)
	local tbOhters = tbCreateRole.tbOhters
	if tbOhters  and nIndex then
		local v = tbOhters[nIndex]
		if v  then
			local tbReapalce = Lib:CopyTB(v)
			for k2, v2 in pairs(tbReapalce) do
				tbCreateRole[k2] = v2
			end

			local tbNewtbOhters = { tbReapalce }
			for i=nIndex + 1,#tbOhters do
				table.insert(tbNewtbOhters, tbOhters[i])
			end
			for i=1,nIndex - 1 do
				table.insert(tbNewtbOhters, tbOhters[i])
			end
			tbCreateRole.tbOhters = tbNewtbOhters

			Login:UpdateRoleHeadInfo(tbCreateRole)
		end
	end
end

function Login:PlayFirsetCamerAni()
	-- RepresentMgr.PlayActivedSceneAnimation(szCameraObjRootName, "all")
	-- RepresentMgr.PlayActivedSceneAnimation(szCameraObjRootName, "choose5cam1", true)
	-- RepresentMgr.SetSceneObjAnimatorEnable(szAnimatorController, false)
	-- RepresentMgr.SetSceneObjAnimatorEnable(szAnimatorController, true, szSelectAniDefault)

end

function Login:OnMapLoaded()
	if not IOS and Ui:WindowVisible("MapLoading") == 1 then --返回登陆时 会先显示一下角色列表
		Ui.CameraMgr.SetMainCameraActive(false)
	end
	self.bMapLoaded = true;
	self.nCurSelNpc = nil;
	self.nCurSelSex = nil

	self.tbAddHeadUiNameInfo = {};

	for nFaction, v in pairs(self.tbSelRoleInfo) do
		local tbSexes = Player:GetFactionSexs(nFaction)
		for _, nSex in ipairs(tbSexes) do
			local vReal = self:GetRealRoleInfo(nFaction, nSex)
			vReal.tbCreateRole = nil;
		end
	end
	self:PlayFirsetCamerAni()

	--Ui:CloseWindow("MapLoading");
	Ui:PreloadUiList()

	Ui:OpenWindow("LoginBg")
	-- Ui:OpenWindow("Login")

	Ui:CloseWindow("MessageBox")

	--如果先加载完角色列表，再加载完地图的情况
	self:OnRoleListDoneAndMapLoaded();
end

function Login:ClearTimers()
end

function Login:GetRealRoleInfo(nNpcId, nSex)
	local v = self.tbSelRoleInfo[nNpcId]
	local tbSexes = Player:GetFactionSexs(nNpcId)
	if #tbSexes == 2 then
		nSex = Player:Faction2Sex(nNpcId, nSex)
		v = v[nSex]
		v.nSex = nSex
	end
	return v
end

function Login:TryLoadRoleRes(nNpcId, nSex,nDelay)
	nDelay = nDelay or 1;  -- nCurSelNpc 是该函数之后设上
	local v = self:GetRealRoleInfo(nNpcId, nSex)
	local szPrefbName = string.gsub(v.szSceneSelObjName, "_dld$", "");
	if not self.tbLoadRoleResInfo[szPrefbName] or nDelay > 1 then
		Ui:PlaySceneSound(Login.nBlackBgSoundId)
		Ui:OpenWindow("BgBlackAll")
	end

	if not self.tbLoadRoleResInfo[szPrefbName] then
		self.tbLoadRoleResInfo[szPrefbName] = true
		RepresentMgr.LoadLoginRes(string.format("Player/Login/%s.prefab", szPrefbName), v.szSceneSelObjName );
	else
		Timer:Register(nDelay, function ()
			Login:OnLoadRes(szPrefbName);
		end)
	end
end


function Login:OnLoadRes(szSceneSelObjName)
	local nNpcId, nSex = self.nCurSelNpc, self.nCurSelSex;
	local v = self:GetRealRoleInfo(nNpcId, nSex)
	if not self.tbAddHeadUiNameInfo[v.szSceneSelObjName] then
		self.tbAddHeadUiNameInfo[v.szSceneSelObjName] = true
		AvatarHeadInfoMgr.AddHeadUiToGameObj(v.szSceneSelObjName)
		local tbCreateRole = v.tbCreateRole
		if tbCreateRole then
			self:UpdateRoleHeadInfo(tbCreateRole)
		else
			AvatarHeadInfoMgr.SetAvatarHeadInfo(v.szSceneSelObjName, "", "", "")
		end
		AvatarHeadInfoMgr.SetAvatarHeadInfoVisible(v.szSceneSelObjName, false)
	end

	Ui:CloseWindow("BgBlackAll")
	if not self.bAtuoChoose then
		RepresentMgr.SetSceneObjActive(v.szSceneSelObjName, true)
		if v.szEffectName then
			RepresentMgr.SetSceneObjActive(string.format("%s/%s", v.szSceneSelObjName, v.szEffectName), true);
			RepresentMgr.SetSceneObjActive(string.format("%s/%s", v.szSceneSelObjName, v.szFirstSelEffectName), false);
		end
		Ui:PlayUISound(v.nSounId)
		if v.nSounId2 then
			Ui:PlaySceneSound(v.nSounId2)
		end
		local fAniLength = RepresentMgr.PlayActivedSceneAnimation(szCameraObjRootName, v.szCameraAniSelect)
		Timer:Register(Env.GAME_FPS * fAniLength , function ()
			Login:fnOpenCreateRoleWindow(v, nNpcId, nSex)
			Ui:UpdateSoundSetting()
		end)
	else
		RepresentMgr.SetSceneObjActive(v.szSceneSelObjName, true) --最后帧
		if v.szEffectName then
			RepresentMgr.SetSceneObjActive(string.format("%s/%s", v.szSceneSelObjName, v.szEffectName), false);
			RepresentMgr.SetSceneObjActive(string.format("%s/%s", v.szSceneSelObjName, v.szFirstSelEffectName), true);
		end
		RepresentMgr.PlayActivedSceneAnimation(szCameraObjRootName, v.szCameraAniSelect)

		--有的是2个模型动作
		if v.szFirstSelObjName1 then
			RepresentMgr.SetActivedSceneAnimationEnd(v.szFirstSelObjName1, v.szModelShowAniName1)
			if v.szFirstSelObjName2 then
				RepresentMgr.SetActivedSceneAnimationEnd(v.szFirstSelObjName2, v.szModelShowAniName2)
			end
		else
			RepresentMgr.SetActivedSceneAnimationEnd(v.szSceneSelObjName, v.szModelShowAniName)
		end

		RepresentMgr.SetActivedSceneAnimationEnd(szCameraObjRootName, v.szCameraAniSelect)

		Login:fnOpenCreateRoleWindow(v, nNpcId, nSex)
	end
end

function Login:IsForbitFaction(nFaction, nSex )
--[[
	if IS_OLD_SERVER then
		if nFaction == 21 then
			return true
		end
		if nFaction == 6 and nSex == Player.SEX_MALE then
			return true, Player.SEX_FEMALE
		end
	end
]]

	return false
end

function Login:SelRole(nNpcId, bAtuoChoose, nSex)
	if  self.nCurSelNpc == nNpcId and self.nCurSelSex == nSex then
		return
	end

	if self:IsForbitFaction(nNpcId, nSex) then
		me.CenterMsg("暂未开放，敬请期待")
		return
	end


	self:ClearTimers()
	self.bAtuoChoose = bAtuoChoose

	local v = self:GetRealRoleInfo(nNpcId, nSex)

	Ui:CloseWindow("CreateRole")

	--没选中， 直接从外面进去时
	if not self.nCurSelNpc then
		if not bAtuoChoose then
			self:TryLoadRoleRes(nNpcId, nSex, 5)

		else --默认选中时候 显示最后帧
			self:TryLoadRoleRes(nNpcId, nSex)
		end

	else --已经选中其他的
		local v_old = self:GetRealRoleInfo(self.nCurSelNpc, self.nCurSelSex)

		RepresentMgr.SetSceneObjActive(v_old.szSceneSelObjName, false)

		AvatarHeadInfoMgr.SetAvatarHeadInfoVisible(v_old.szSceneSelObjName,  false)
		self:TryLoadRoleRes(nNpcId, nSex)
	end

	self.nCurSelNpc = nNpcId
	self.nCurSelSex = nSex
end

function Login:BackToRoleList(bHideWindow)
	if self.nCurSelNpc then
		local v = self:GetRealRoleInfo(self.nCurSelNpc, self.nCurSelSex)
		RepresentMgr.SetSceneObjActive(v.szSceneSelObjName, false)
		AvatarHeadInfoMgr.SetAvatarHeadInfoVisible(v.szSceneSelObjName,  false)

		self.nCurSelNpc = nil;
		self.nCurSelSex = nil;
	end

	self:PlayFirsetCamerAni()
end

function Login:EnterXinShouFuben()
	assert(self.nCurSelNpc)

	if XinShouLogin:CheckEnterFuben(self.nCurSelNpc, self.nCurSelSex) then
		Ui:CloseWindow("CreateRole")
	end

	XinShouLogin:EnterFuben(self.nCurSelNpc, self.nCurSelSex);
end

function Login:LoginRole(dwRoleId)
	assert(self.nCurSelNpc)

	local tbLastLoginfo = Client:GetUserInfo("LoginRole", -1)
	tbLastLoginfo[GetAccountName()] = dwRoleId
	if me.nMapTemplateId ~= 0 then
		LoginRole(dwRoleId)
		Lib:CallBack({Pandora.OnLogin, Pandora, dwRoleId, self.nCurSelNpc, self.nCurSelSex});
		return
	end

	SdkMgr.SetReportTime();
	LoginRole(dwRoleId)
	if not self.nTimerCheckTimeOutLogin then
		self.nTimerCheckTimeOutLogin = Timer:Register(Env.GAME_FPS * 4, function ()
			self.nTimerCheckTimeOutLogin = nil;
			if not PlayerEvent.bLogin then
				SdkMgr.ReportDataEnterGame("98002", Sdk:GetCurAppId(),  tostring(SERVER_ID), Login.szReportRoleList)
			end
		end)
	end
	Lib:CallBack({Pandora.OnLogin, Pandora, dwRoleId, self.nCurSelNpc, self.nCurSelSex});
end

function Login:Init()
 	Login.tbAccSerInfo = {};

 	--初始化登录信息
 	self.ClientSet = Lib:LoadIniFile("Setting/Client.ini");
 	self.ClientSet.Network.GatewayPort = tonumber(self.ClientSet.Network.GatewayPort)
 	self.ClientSet.Sdk.Skip = (self.ClientSet.Sdk.Skip == "1");
 end

Login:Init()


function Login:CheckNameinValid(szName)
	if not szName or szName == "" then
		Ui:OpenWindow("MessageBox", "请输入您的角色名")
		return;
	end
	if version_tx then
		local nlen = Lib:Utf8Len(szName)
		if nlen < 2 or nlen > 6 then
			Ui:OpenWindow("MessageBox", "名字长度需要在2~6个汉字内")
			return
		end
		if string.find(szName, "%w") then
			Ui:OpenWindow("MessageBox", "名字长度需要在2~6个汉字内")
			return
		end
		if not CheckNameAvailable(szName) then
			Ui:OpenWindow("MessageBox", "名字中包含非法字符")
			return
		end
	elseif version_th and MAX_ROLE_NAME_LEN > 14*3 then
		local szNameLen = Lib:Utf8Len(szName)
		if szNameLen < 4 then
			Ui:OpenWindow("MessageBox", "您的名字太短")
			return
		end
		if szNameLen > 14 then
			Ui:OpenWindow("MessageBox", "您的名字过长")
			return
		end
		if not CheckNameAvailable(szName) then
			Ui:OpenWindow("MessageBox", "名字中包含非法字符")
			return
		end

		if string.find(szName, "^%d") then
			Ui:OpenWindow("MessageBox", "名字不可以数字开头")
			return;
		end
	else
		local szNameLen = string.len(szName);
		if version_vn and szNameLen < 6 then
			Ui:OpenWindow("MessageBox", "您的名字太短")
			return
		end
		if szNameLen > 18 then
			Ui:OpenWindow("MessageBox", "您的名字过长")
			return
		end
		if not CheckNameAvailable(szName) then
			Ui:OpenWindow("MessageBox", "名字中包含非法字符")
			return
		end

		if string.find(szName, "^%d") then
			Ui:OpenWindow("MessageBox", "名字不可以数字开头")
			return;
		end
	end
	return true
end


--从gateway取的帐号等级信息 --到时也是直接移到Ui里了
function Login:OnSynAccSerInfo(...)
	--TODO 改成从 C调lua时把Gateclient里的帐号传过来
	local tbData = {}
	for i,v in ipairs( {...} ) do
		tbData[ v[1] ]  = v[2]; --nIndex = , nMaxLevel
	end
	Login.tbAccSerInfo[GetAccountName()] = tbData; --因为这是在加载角色之前的帐号

	UiNotify.OnNotify(UiNotify.emNOTIFY_SYNC_ACC_SER_INFO);
end

function Login:GetAccSerInfo()
	return Login.tbAccSerInfo[GetAccountName()] or {}

	--TODO 非敏感数据，如果存的是当天的也不用请求了把
	-- 获取本地的 暂时不存了，因为不知道和服务器上哪个是最新的
	-- local tbAccSerInfo = Client:GetUserInfo("AccSerInfo")
	-- return tbAccSerInfo[szAccount]

end

Login.tbCREATE_ROLE_RESPOND_CODE = {
	"已经有大虾叫这个名字了！请重新输入！",
	"名字中包含非法字符，请重新输入",
	"角色名必须是2-6个字，请重新输入",
	"角色名必须是2-6个字，请重新输入",
	"服务器人数过多，无法创建新角色",
	"无法创建角色",
	"服务器关闭创建角色功能",
	"此名字只能由指定帐号使用",
	string.format("一个帐号下最多创建%d个角色", Login.ACCOUNT_MAX_ROLE_COUNT),
}

function Login:OnCreateRoleRespond(nCode, nRoleID)
	if nCode ~= 0 then
		Ui:OpenWindow("MessageBox", self.tbCREATE_ROLE_RESPOND_CODE[nCode] or "未知错误！创建角色失败！",
			{ {} },
	 		{"同意"})
	end

	UiNotify.OnNotify(UiNotify.emNOTIFY_CREATE_ROLE_RESPOND, nCode, nRoleID)
	Log("OnCreateRoleRespond", nCode, nRoleID);
end

function Login:PlaySceneSound()
	if not self.nBackSoundPlayed then
		local tbLoginMusic = Client:GetUserInfo("LoginMusicIndex", -1)
		local nIndex = tbLoginMusic[1] or 0;
		nIndex = nIndex + 1;
		if nIndex > #self.SOUND_BG then
			nIndex = 1
		end

		Ui:PlaySceneSound(self.SOUND_BG[nIndex])
		tbLoginMusic[1] = nIndex;
		Client:SaveUserInfo()
		self.nBackSoundPlayed = self.SOUND_BG[nIndex]
	end
end

function Login:StopSceneSound()
	if self.nBackSoundPlayed then
		Ui:StopSceneSound(self.nBackSoundPlayed)
	end
	self.nBackSoundPlayed = nil;
end

function Login:CheckShowUserProtol()
	if version_tx or version_vn	then
		local tbInfo = Client:GetUserInfo("LoginAgreeUserProtol", -1)
		if tbInfo[1] then
			return
		end

		--Ui:OpenWindow("AgreementPanel")
	elseif version_kor then
		local tbInfo = Client:GetUserInfo("LoginAgreeUserProtol", -1)
		if tbInfo[1] then
			return
		end

		--Ui:OpenWindow("AgreementLargePanel")
	end
end

function Login:AllowLogin()
	local nNextLoginTime = Client:GetFlag("NextLoginTime") or 0;
	local nLeftWaitingTime = nNextLoginTime - os.time();

	local fnWait = function ()
	end

	local fnTimeUp = function ()
		Ui:CloseWindow("MessageBox");
	end

	if nLeftWaitingTime > 0 then
		Ui:OpenWindow("MessageBox", "由于连续登录失败多次\n请于[ffff00]%d[-]秒后进行尝试", {{fnWait},nil,{fnTimeUp}}, {"确认"}, nil, nLeftWaitingTime);
	end

	return nLeftWaitingTime <= 0;
end

function Login:SetNextLoginTime()
	local nFailCount = Client:GetFlag("LoginFailCount") or 0;
	nFailCount = nFailCount + 1;
	Client:SetFlag("LoginFailCount", nFailCount);

	local nNextLoginTime = os.time();
	if nFailCount >= 6 and version_tx then
		nNextLoginTime = nNextLoginTime + 5 * 60; -- 登入失败超过6次后, 5分钟内不可再登入
	elseif nFailCount >= 3 then
		nNextLoginTime = nNextLoginTime + 10; -- 连续失败3次后, 10秒内不可再登入
	end

	Client:SetFlag("NextLoginTime", nNextLoginTime);
end

function Login:ResetNextLoginTime()
	Client:ClearFlag("NextLoginTime");
	Client:ClearFlag("LoginFailCount");
end

function Login:ConnectGateWay(szAccount, szAuthInfo, nPlatfrom)
	local NetworkSet = Login.ClientSet.Network;
	local szGatewayIP = NetworkSet.GatewayIP;
	local nGatewayPort = NetworkSet.GatewayPort;

	-- QQ和微信平台可选择不同的GateWay地址
	if Sdk:IsLoginByQQ() then
		if IOS or Sdk:IsLoginForIOS() then
			szGatewayIP = NetworkSet.iOSQQGatewayIP or szGatewayIP;
			nGatewayPort = tonumber(NetworkSet.iOSQQGatewayPort) or nGatewayPort;
		else
			szGatewayIP = NetworkSet.AndroidQQGatewayIP or szGatewayIP;
			nGatewayPort = tonumber(NetworkSet.AndroidQQGatewayPort) or nGatewayPort;
		end
	elseif Sdk:IsLoginByWeixin() then
		if IOS or Sdk:IsLoginForIOS() then
			szGatewayIP = NetworkSet.iOSWXGatewayIP or szGatewayIP;
			nGatewayPort = tonumber(NetworkSet.iOSWXGatewayPort) or nGatewayPort;
		else
			szGatewayIP = NetworkSet.AndroidWXGatewayIP or szGatewayIP;
			nGatewayPort = tonumber(NetworkSet.AndroidWXGatewayPort) or nGatewayPort;
		end
	elseif Sdk:IsLoginByGuest() then
		szGatewayIP = NetworkSet.GuestGatewayIP or szGatewayIP;
		nGatewayPort = tonumber(NetworkSet.GuestGatewayPort) or nGatewayPort;
	end

	szGatewayIP = Ui.FTDebug.szGatewayIP == "" and szGatewayIP or Ui.FTDebug.szGatewayIP;
	nGatewayPort = Ui.FTDebug.nGatewayPort <= 0 and nGatewayPort or Ui.FTDebug.nGatewayPort;

	Login:ClearFreeFlowInfo();
	Login:ClearPfLoginInfo();

	if Sdk:IsLoginForIOS() then
		local bPCVersion, szRegisterChannel, szInstallChannel, szOfferId = Sdk:GetLoginExtraInfo();
		ConnectGateway(szGatewayIP, nGatewayPort, szAccount, szAuthInfo, nPlatfrom or Sdk.ePlatform_None,
			bPCVersion, szRegisterChannel, szInstallChannel, szOfferId);
	else
		ConnectGateway(szGatewayIP, nGatewayPort, szAccount, szAuthInfo, nPlatfrom or Sdk.ePlatform_None);
	end

	local nLoginWaitingTime = version_xm and 15 or 8;
	Ui:OpenWindow("LoadingTips", "正在登录剑侠情缘..", nLoginWaitingTime, function ()
		Login:SetNextLoginTime();
		Ui:AddCenterMsg("登入超时, 请重新登入");
		Ui:CloseWindow("LoadingTips");
	end);
end

function Login:GetEquipId()
	if ANDROID then
		return Ui.UiManager.GetEquipId() or "";
	elseif IOS then
		return GetAppleEquipId() or "";
	else
		return "PC"
	end
end

function Login:GetICCID()
	if ANDROID then
		return Ui.UiManager.GetICCID() or ""
	elseif IOS then --越狱才有
		return "";
	else
		return ""
	end
end

--获取手机型号信息, 网络类型，运营商
function Login:GetPhoneBasicInfo()
	local szModel, nPlatfrom, nNetWorkType, nTelecomOper, nPlatFriends, nGameVersion = "PC", 2, 0, 0, #FriendShip.tbPlatFriendsInfo, GAME_VERSION;
	local szEquipId = Login:GetEquipId();
	local nLoginChanalId = Sdk:GetLoginChannelId()
	if ANDROID then
		szModel = Ui.ToolFunction.GetPhoneModel();
		nPlatfrom = 1;
		nNetWorkType = Ui.ToolFunction.GetNetWorkType(); -- NETWORKTYPE_INVALID,NETWORKTYPE_2G,NETWORKTYPE_3G,NETWORKTYPE_WIFI,
		nTelecomOper = Ui.ToolFunction.GetTelecomOper(); -- TELECOM_TYEP_UNKOWN TELECOM_TYEP_MOBI , TELECOM_TYEP_UNI , TELECOM_TYEP_TELE
	elseif IOS then
		szModel = GetAppleModelName();
		nPlatfrom = 0;
		nNetWorkType = GetAppletNetWorkType();
		nTelecomOper = GetAppletTelecomOper();
	end
	szEquipId = tostring(szEquipId) or "unkown";
	szModel = tostring(szModel) or "unkown";

	if Sdk:IsPCVersion() then
		szEquipId = Sdk:GetAssistChannelId() or szEquipId;
	end

	return szEquipId, szModel, nPlatfrom, nNetWorkType, nTelecomOper, nLoginChanalId, nPlatFriends, nGameVersion, Sdk:GetMsdkInfoStr() or "{}";
end

function Login:GetLoginRoleProtocolParams()
	local nIsEmulator = 0;
	if ANDROID then
		nIsEmulator = Ui.ToolFunction.IsEmulator() and 1 or 0;
	end
	return nIsEmulator;
end

function Login:GetIDFA()
	if IOS then
		return GetAppleIdfa() or "";
	end
	return ""
end

 -- 新手村实时数据上报
Login.tbXinshouTransmitData = {
	gamename = "jxft";
	os = "other";
	channelcode = Sdk:GetLoginChannelId();
	equdid = Login:GetEquipId();
	dbname = "";
	stat_time = "2015-03-09 15:00:00";
	accountid = "";
	roleid = "";
	msg = "";
	eventid = 800; --
}

if ANDROID then
	Login.tbXinshouTransmitData.os = "android"
elseif IOS then
	Login.tbXinshouTransmitData.os = "ios"
end

--szReportJsonUrl = "http://syonline.extgame.xsjom.com:10021/custom_event"  --"http://127.0.0.1:3000/"

function Login:PostXinshouFubenData(nIndex)
	local tbData = self.tbXinshouTransmitData
	tbData.stat_time = os.date("%Y-%m-%d %H:%M:%S");
	tbData.accountid = GetAccountName()
	tbData.roleid = me.dwID
	tbData.msg = string.format("unlock:%d", nIndex)
	tbData.dbname = Client:GetCurServerInfo();
	Ui.UiManager.PostWebRequest(Lib:EncodeJson(tbData) )
end

function Login:OnNotifyAccountBanned(banTime, szErrorMsg)
	local szMsgBoxType = "MessageBox"
	local nPivot = nil
	local szMsg = ""

	if banTime == -100 then
		-- 家长禁玩
		szMsgBoxType = "MessageBoxBig"
		nPivot = 3
		szMsg = (szErrorMsg ~= "" and szErrorMsg) or XT("您的账号已被家长设定为暂时无法登录游戏。\n如有疑问，请拨打服务热线0755-86013799进行咨询。共筑绿色健康游戏环境，感谢您的理解与支持。")
	else
		szErrorMsg = szErrorMsg or "违反游戏规则"

		local szErrorMsg, nNoTimeNotice = string.gsub(szErrorMsg, "(%[no_time_notice%])", "")

		if banTime == -1 then
			szMsg = string.format(XT("%s, 被永久冻结。"), szErrorMsg)
		elseif banTime == -2 or nNoTimeNotice > 0 then
			szMsg = szErrorMsg
		else
			szMsg = string.format(XT("%s，解除时间: %s。"), szErrorMsg, Lib:GetTimeStr3(banTime))
		end
	end
	Ui:OpenWindow(szMsgBoxType, szMsg, nil, nil, nPivot);
end

function Login:IsAutoLogin()
	-- 韩国版本无论什么情况都是自动登入的
	if version_kor then
		return true;
	end
	return not self.bIgnoreAutoLogin;
end

function Login:SetAutoLogin(bAuto)
	self.bIgnoreAutoLogin = not bAuto;
end

function Login:ClearFreeFlowInfo()
	self.bFreeFlow = nil;
	self.szFreeFlowWorldIp = nil;
	self.szFreeFlowFileServerIp = nil;
end

function Login:IsFreeFlow()
	return self.bFreeFlow or false;
end

function Login:FreeFlowReceived()
	return self.bFreeFlow ~= nil;
end

function Login:GetFileServerFreeIp()
	if self.bFreeFlow then
		return self.szFreeFlowFileServerIp;
	end
end

function Login:SetFreeFlowInfo(nFree, szFreeIp)
	Log("Login:SetFreeFlowInfo", nFree, szFreeIp);
	self.bFreeFlow = (nFree == 1);
	local tbFreeFlowIp = Lib:SplitStr(szFreeIp, ";");
	self.szFreeFlowWorldIp = tbFreeFlowIp[1];
	self.szFreeFlowFileServerIp = tbFreeFlowIp[2];
	Log("FreeFlowWorldUrl:", self.szFreeFlowWorldIp)
	Log("FreeFlowFileServerUrl:", self.szFreeFlowFileServerIp)
end

function Login:LoginServerRsp(szAddr, nPort)
	Log("Login:LoginServerRsp", szAddr, nPort);
	if self.bFreeFlow and self.szFreeFlowWorldIp then
		szAddr = self.szFreeFlowWorldIp;
	end
	ConnectWorldServer(szAddr, nPort);
end

function Login:CheckRoleCountLimit()
	local tbRole = GetRoleList()
	if #tbRole >= self.ACCOUNT_MAX_ROLE_COUNT then
		Ui:OpenWindow("MessageBox", string.format("每个帐号下最多创建%d个角色，少侠可以在游戏内对已有角色进行转门派操作", self.ACCOUNT_MAX_ROLE_COUNT));
		return
	end
	return true
end

function Login:OnQueryPfInfoRsp(szPfInfoJson)
	Log("OnQueryPfInfoRsp", szPfInfoJson);
	local tbPfInfo = Lib:DecodeJson(szPfInfoJson) or {};
	if tbPfInfo.ret ~= 0 then
		me.CenterMsg(tbPfInfo.msg);
		return;
	end
	Sdk:SetServerPfInfo(tbPfInfo.pf, tbPfInfo.pfKey);

	if self.nGateWayVerrifyRetCode then
		UiNotify.OnNotify(UiNotify.emNOTIFY_GATEWAY_LOGIN_RSP, self.nGateWayVerrifyRetCode);
	end
end

function Login:OnGatewayHandSuccess(nRetCode)
	Log("OnGatewayHandSuccess", nRetCode);
	if not Sdk:IsLoginForIOS() or nRetCode ~= 0 then
		UiNotify.OnNotify(UiNotify.emNOTIFY_GATEWAY_LOGIN_RSP, nRetCode);
		return;
	end

	if Sdk:HasServerPfInfo() then
		UiNotify.OnNotify(UiNotify.emNOTIFY_GATEWAY_LOGIN_RSP, nRetCode);
	else
		self.nGateWayVerrifyRetCode = nRetCode;
	end
end

function Login:NoticeUserProperties()
	if version_tx then
		local tbInfo = Client:GetUserInfo("AccessJurisdiction", -1)
		if tbInfo[1] then
			return
		end

		Ui:OpenWindow("JurisdictionPanel");
	end

end
function Login:ClearPfLoginInfo()
	self.nGateWayVerrifyRetCode = nil;
	Sdk:SetServerPfInfo(nil, nil);
end

if not Login.bRegisterInit then
	UiNotify:RegistNotify(UiNotify.emNOTIFY_SYNC_ROLE_LIST_DONE, Login.OnSyncRoleListDone, Login)
	UiNotify:RegistNotify(UiNotify.emNOTIFY_GATEWAY_HANDED, Login.OnGatewayHandSuccess, Login)
	Login.bRegisterInit = true;
end
