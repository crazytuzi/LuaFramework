--------------------------------------------------------------------------------------
-- 文件名:	LYP_BattleData.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	李玉平
-- 日  期:	2014-3-19 15:32
-- 版  本:	1.0
-- 描  述:	战斗数据
-- 应  用:  本例子是用类对象的方式实现
---------------------------------------------------------------------------------------


CBattleData = class("CBattleData")
CBattleData.__index = CBattleData


function CBattleData:initBattleData()
	self.nEctypeType = TbBattleReport.tbBattleScenceInfo["battle_type"]
	local nEctypeID = TbBattleReport.tbBattleScenceInfo["mapid"]
	self.nEctypeID = nEctypeID
    local szEctypeName = nil
		
	--竞技场、切磋、渡劫、世界Boss，把左下角的信息隐藏
	if (
		self.nEctypeType == macro_pb.Battle_Atk_Type_normal_pass or
		self.nEctypeType == macro_pb.Battle_Atk_Type_advanced_pass or
		self.nEctypeType == macro_pb.Battle_Atk_Type_master_pass
	) then--表示是普通 高手 宗师副本
        local Csv_MapEctypeSub  = g_DataMgr:getMapEctypeSubCsv(nEctypeID)
        szEctypeName = Csv_MapEctypeSub.EctypeName
		self.CSV_Ectype = g_DataMgr:getMapEctypeCsv(Csv_MapEctypeSub.EctypeID)
	elseif self.nEctypeType == macro_pb.Battle_Atk_Type_Jing_Ying_pass then  --精英副本 20150702 by zgj
		self.CSV_Ectype = g_DataMgr:getCsvConfigByTwoKey("MapEctypeJingYing", g_EctypeJY:getCurAttackJY())
	elseif(self.nEctypeType == macro_pb.Battle_Atk_Type_dujie) then -- 渡劫
		self.CSV_Ectype = g_DataMgr:getCsvConfigByOneKey("CardRealmEctype", nEctypeID)
	elseif(self.nEctypeType == macro_pb.Battle_Atk_Type_RichGod) then --财神试炼
		self.CSV_Ectype = g_DataMgr:getCsvConfigByOneKey("ActivityEctype", nEctypeID)
	elseif(self.nEctypeType == macro_pb.Battle_Atk_Type_GodTrial) then --神仙试炼
		self.CSV_Ectype = g_DataMgr:getCsvConfigByOneKey("ActivityEctype", nEctypeID)
	elseif(self.nEctypeType == macro_pb.Battle_Atk_Type_PickPeach) then --摘仙桃
		self.CSV_Ectype = g_DataMgr:getCsvConfigByOneKey("ActivityEctype", nEctypeID)
	elseif(self.nEctypeType == macro_pb.Battle_Atk_Type_WorldBoss) or
	 	  (self.nEctypeType == macro_pb.Battle_Atk_Type_SceneBoss) or 
	 	  (self.nEctypeType == macro_pb.Battle_Atk_Type_GuildWorldBoss) or 
	 	  (self.nEctypeType == macro_pb.Battle_Atk_Type_GuildSceneBoss) then --世界Boss
		self.CSV_Ectype = g_DataMgr:getCsvConfigByOneKey("ActivityEctype", nEctypeID)
		local instance = g_WndMgr:getWnd("Game_WorldBoss1")
		if instance then
			instance:updateChallengeColdDown()
		end
	elseif(self.nEctypeType == macro_pb.Battle_Atk_Type_Rotational) then --六道轮回
		self.CSV_Ectype = g_DataMgr:getCsvConfigByOneKey("ActivityEctype", nEctypeID)
	elseif(self.nEctypeType == macro_pb.Battle_Atk_Type_ArenaRobot
		or self.nEctypeType == macro_pb.Battle_Atk_Type_ArenaPlayer
		or self.nEctypeType == macro_pb.Battle_Atk_Type_Player) 
		or self.nEctypeType == macro_pb.Battle_Atk_Type_CrossArenaPlayer
		then --竞技场、切磋
		self.CSV_Ectype = g_DataMgr:getCsvConfigByOneKey("ActivityEctype", nEctypeID)
	elseif(self.nEctypeType == 100) then--图鉴
		self.CSV_Ectype = g_DataMgr:getCsvConfigByOneKey("ActivityEctype", nEctypeID)
	elseif self.nEctypeType ==  macro_pb.Battle_Atk_Type_Money then --财神岛
		self.CSV_Ectype = g_DataMgr:getCsvConfigByOneKey("ActivityEctype", nEctypeID)
	elseif self.nEctypeType ==  macro_pb.Battle_Atk_Type_Exp then --百草图
		self.CSV_Ectype = g_DataMgr:getCsvConfigByOneKey("ActivityEctype", nEctypeID)
	elseif self.nEctypeType ==  macro_pb.Battle_Atk_Type_Tribute then --龙王庙
		self.CSV_Ectype = g_DataMgr:getCsvConfigByOneKey("ActivityEctype", nEctypeID)
	elseif self.nEctypeType ==  macro_pb.Battle_Atk_Type_Aura then --灵兽山
		self.CSV_Ectype = g_DataMgr:getCsvConfigByOneKey("ActivityEctype", nEctypeID)
    elseif self.nEctypeType ==  macro_pb.Battle_Atk_Type_Knowledge then --藏经阁
		self.CSV_Ectype = g_DataMgr:getCsvConfigByOneKey("ActivityEctype", nEctypeID)
    elseif self.nEctypeType ==  macro_pb.Battle_Atk_Type_BaXian_Rob then --八仙过海
        self.CSV_Ectype = g_DataMgr:getCsvConfigByOneKey("ActivityEctype", nEctypeID)
	else
		error(self.nEctypeType.."===副本类型错误===="..nEctypeID)
	end
	g_IsExitBattleProcess = false

    if szEctypeName then
       self.CSV_Ectype.EctypeName = szEctypeName
    else
        szEctypeName = TbBattleReport.tbBattleScenceInfo.def_name
        if szEctypeName and szEctypeName ~= "" then
            self.CSV_Ectype.EctypeName = szEctypeName
        end
    end
end


function CBattleData:getEctypeType()
	return self.nEctypeType
end

function CBattleData:getEctypeID()
	return self.nEctypeID
end

function CBattleData:getMapID()
	return self.CSV_Ectype.MapID
end

function CBattleData:getEctypeName()
	return self.CSV_Ectype.EctypeName
end

function CBattleData:getBackgroundPic(nBattleRound)
	local nBattleRound = nBattleRound or 1
	nBattleRound = math.min(nBattleRound, 3)
	nBattleRound = math.max(nBattleRound, 1)
	return getSceneImg(self.CSV_Ectype["SceneBackground"..nBattleRound])
end

function CBattleData:getBGMusic()
	return "Sound/Music/Battle.mp3"
end

function CBattleData:getFrontPic()
	local szFrontPic = nil
	if(self.nEctypeType  == 1)then--表示是普通 精英 宗师副本
		szFrontPic = self.CSV_Ectype.BossPotrait
	end
	
	if(szFrontPic == "" or szFrontPic =="null")then
		return nil
	else
		return getSceneFrontPicImg(szFrontPic)
	end
end

function CBattleData:checkWorldBoss()
	return self.nEctypeType == macro_pb.Battle_Atk_Type_WorldBoss or self.nEctypeType == macro_pb.Battle_Atk_Type_GuildWorldBoss
end

function CBattleData:getClientMaxRound()
	if self.nEctypeType == macro_pb.Battle_Atk_Type_normal_pass or
		self.nEctypeType == macro_pb.Battle_Atk_Type_advanced_pass or
		self.nEctypeType == macro_pb.Battle_Atk_Type_master_pass then
		local Csv_MapEctypeSub = g_DataMgr:getMapEctypeSubCsv(self.nEctypeID)
		return Csv_MapEctypeSub.BattleNum
	else
		return self.CSV_Ectype.BattleNum
	end
end

g_BattleData = CBattleData.new()