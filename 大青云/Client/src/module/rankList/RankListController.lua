--[[
排行榜 
wangshuai
]]
_G.RankListController = setmetatable({},{__index=IController})
RankListController.name = "RankListController";

function RankListController:Create()

	MsgManager:RegisterCallBack(MsgType.WC_RankList,self,self.LvlAndfightInfo); -- 7110
	MsgManager:RegisterCallBack(MsgType.WC_MountRankList,self,self.MountInfo); -- 7111
	MsgManager:RegisterCallBack(MsgType.WC_NoticeRankList,self,self.IsNeedToReqinfo); -- 7112
	MsgManager:RegisterCallBack(MsgType.WC_AllRankList,self,self.AllRankList); -- 7114


	MsgManager:RegisterCallBack(MsgType.WC_AllServerRankList,self,self.AtServerFightList); -- 7118
	MsgManager:RegisterCallBack(MsgType.WC_AllServerMountRankList,self,self.AtServerMountList); -- 7119
	MsgManager:RegisterCallBack(MsgType.WC_AllServerNoticeRankList,self,self.AtServerIsUpdata); -- 7120
	RankListModel:SetUpdatalistInit()
end;

-------------------------- 全服----
function RankListController:AtServerFightList(msg) -- 7118
	if msg.type == RankListConsts.InterService then
		-- 跨服排行
		-- InterServicePvpModel:SetInterServiceRankList(msg.rankList)
	elseif msg.type == RankListConsts.LvlRank then 
		-- 等级
		RankListModel:AtserverLvlList(msg.rankList)
	elseif msg.type == RankListConsts.FigRank then 
		-- 战力
		RankListModel:AtServerFightList(msg.rankList)
	elseif msg.type == RankListConsts.jingJie then 
	-- 	--境界
		RankListModel:AtserverJingjieList(msg.rankList)
	-- elseif msg.type == RankListConsts.Lingshou then 
	-- 	--灵兽
	-- 	RankListModel:AtserverlingShouList(msg.rankList)
	-- elseif msg.type == RankListConsts.LingZhen then 
	-- 	--灵阵
	-- 	RankListModel:AtserverlingZhenList(msg.rankList)
	-- elseif msg.type == RankListConsts.JixianBoss then
	-- 	-- 极限挑战boss 
	-- 	RankListModel:AtserverjxtzBossList(msg.rankList)
	-- elseif msg.type == RankListConsts.JixianMonster then 
	-- 	-- 极限挑战monster
	-- 	RankListModel:AtserverjxtzMonsterList(msg.rankList)
	-- elseif msg.type == RankListConsts.Shengbing then 
	-- 	--神兵
	-- 	RankListModel:AtserverShengbList(msg.rankList)
	end;
end;

function RankListController:AtServerMountList(msg) -- 7119
	RankListModel:AtserverMountList(msg.rankList)
end;

function RankListController:AtServerIsUpdata(msg) -- 7120
	-- if msg.type == 10 then --跨服pvp排行榜
		-- InterServicePvpModel:AtServerSetCurListboo(true)	
		-- return 
	-- end;
	RankListModel:AtServerSetCurListboo(msg.type,true);
end;

function RankListController:AtServerReqList(type)
	local msg = ReqAllServerRanklistMsg:new()
	msg.type = type;
	MsgManager:Send(msg)
end;

-- 请求查看全服人物信息，详细信息
function RankListController:AtServerReqRoleinfo(roleId,type,type2)
	local roletype = type;
	if not roletype then
		roletype = 0;
	end
	
	if roletype == 0 then
		local typebase = bit.band(255, OtherRoleConsts.OtherRole_Base);
		local typegem = bit.band(255, OtherRoleConsts.OtherRole_Gem);
		local typebodytool = bit.band(255, OtherRoleConsts.OtherRole_BodyTool);
		
		roletype = typebase + typegem + typebodytool;
	end
	
	local msg = ReqAllServerRankHumanInfoMsg:new();
	msg.roleID = roleId;
	msg.typec = type2;
	msg.type = roletype;
	MsgManager:Send(msg)
end;	

-------------------s  to  c ---

--  排行榜第一
function RankListController:AllRankList(msg)
	RankListModel:SetRankFrist(msg.rankList)
end;

--等级排行，和的战斗力排行
function RankListController:LvlAndfightInfo(msg)
	
	--trace(msg)
	if msg.type == RankListConsts.LvlRank then 
		-- 等级
	
		-- trace(msg.rankList[1])
		RankListModel:SetRoleLvl(msg.rankList)
	elseif msg.type == RankListConsts.FigRank then 
		-- 战力\
		RankListModel:SetRoleFight(msg.rankList)
	elseif msg.type == RankListConsts.jingJie then 
	-- 	--境界
		RankListModel:SetJingJinglist(msg.rankList)

	-- elseif msg.type == RankListConsts.Lingshou then 
	-- 	--灵兽
	-- 	RankListModel:SetLingShouList(msg.rankList)
	-- -- elseif msg.type == RankListConsts.LingZhen then 
	-- -- 	--灵阵
	-- -- 	RankListModel:SetLingZhenList(msg.rankList)
	-- elseif msg.type == RankListConsts.JixianBoss then
	-- 	-- 极限挑战boss 
	-- 	RankListModel:SetjxtzBossList(msg.rankList)
	-- elseif msg.type == RankListConsts.JixianMonster then 
	-- 	-- 极限挑战monster
	-- 	RankListModel:SetjxtzMonsterList(msg.rankList)
	elseif msg.type == RankListConsts.Shengbing then
	 	-- 神兵
	 	RankListModel:SetShengBingList(msg.rankList)
	elseif msg.type == RankListConsts.LingQi then
		RankListModel:SetLingQiList(msg.rankList)
	elseif msg.type == RankListConsts.Armor then
		RankListModel:SetArmorList(msg.rankList)
	elseif msg.type == RankListConsts.MingYu then
		RankListModel:SetMingYuList(msg.rankList)
	elseif msg.type == RankListConsts.NewTianShen then
		RankListModel:SetMingYuList(msg.rankList)
	end;
end;
	
-- 坐骑排行榜
function RankListController:MountInfo(msg)
	RankListModel:SetMountRank(msg.rankList)
end;



-- 需要请求那个信息分
function RankListController:IsNeedToReqinfo(msg)
	--self:ReqRanlist(msg.type) 
	if msg.type == 10 then  --过滤不属于排行榜的信息
		print("server return no belong to ranklist data")
		return 
	end;

	RankListModel:SetCurListboo(msg.type,true)
end;

----------------------c  to s 
-- 请求排行榜信息
function RankListController:ReqRanlist(type)
	-- 0 =  首名 1等级，2 战力，3 坐骑 4 境界
	local msg = ReqRanklistMsg:new();
	msg.type = type;
	MsgManager:Send(msg);
	print("请求排行榜信息",type)
end;

-- 请求详细信息 -- type 1 基本信息，2详细信息，3坐骑，4武魂
function RankListController:ReqHumanInfo(roleid,type)
	local roletype = type;
	if not roletype then
		roletype = 0;
	end
	
	if roletype == 0 then
		local typebase = bit.band(255, OtherRoleConsts.OtherRole_Base);
		local typegem = bit.band(255, OtherRoleConsts.OtherRole_Gem);
		local typebodytool = bit.band(255, OtherRoleConsts.OtherRole_BodyTool);
		
		roletype = typebase + typegem + typebodytool;
	end
	
	--printguid(roleid)
	 local msg = ReqRankHumanInfoMsg:new();
	 msg.roleID = roleid;
	 msg.type = roletype;
	 MsgManager:Send(msg);
end;



--- 详细信息返回处理
function RankListController:DetaiedInfoDeal(type,msg)
	if type == 1 then
		-- 人物基础信息
	---	print("得到人物基础信息")
		RankListModel:SetRoleDetaiedInfo(msg)
	elseif type == 2 then 
		-- 坐骑基础信息
		--print("得到坐骑详细信息")
		RankListModel:SetMountInfo(msg)
	end
end;