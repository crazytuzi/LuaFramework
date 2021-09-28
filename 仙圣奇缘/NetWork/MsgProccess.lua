--------------------------------------------------------------------------------------
-- 文件名:	MsgProcess.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	李玉平
-- 日  期:	2014-3-5 9:24
-- 版  本:	1.0
-- 描  述:	服务器消息处理
-- 应  用:
---------------------------------------------------------------------------------------

g_IsExistedActor = nil
local function CostMaterialByCfg(tbMaterialCfg)
	local cfg = tbMaterialCfg
	for materiaId = 1,6 do
		if cfg["MaterialID"..materiaId] ~= nil 
			and cfg["MaterialID"..materiaId] > 0 then 
			local nCsvID = cfg["MaterialID"..materiaId]
			local nStarLevel = cfg["MaterialStarLevel"..materiaId]
			local nCostNum = cfg["MaterialNum"..materiaId]
			local nLeaveNum = g_Hero:getItemNumByCsv(nCsvID, nStarLevel)
			g_Hero:setItemByCsvIdAndStar(nCsvID, nStarLevel, nLeaveNum - nCostNum)
		end
	end
end

--请求角色信息
local function requestRoleInfoResponse(tbMsg)
	cclog("---------requestRoleInfoResponse-收到角色信息-----------")
	g_MsgNetWorkWarning:closeNetWorkWarning()
	if(tbMsg == nil)then
		cclog("---------requestRole CheckReceiveMsg Error------------")
		return
	end

	if(not tbMsg.buffer or string.len(tbMsg.buffer) <= 0)then
		cclog("Error ")
		return
	end

	local listroleRespone = account_pb.ListRoleResponse()
	listroleRespone:ParseFromString(tbMsg.buffer)

    g_IsExistedActor = nil
    if  g_MsgMgr.szAccount ~= "" then
        AccountRegResponse()
    end
	if(listroleRespone:HasField("rolenum") )then
		g_IsExistedActor = listroleRespone.rolenum
		if(g_IsExistedActor > 0)then
			cclog("have Actror")
			AccountRegResponse()
			if(listroleRespone:HasField("role_summary") )then
				g_MsgMgr:setUserID(listroleRespone.role_summary.uin)
				--ping 开始工作
				if listroleRespone.role_summary.uin ~= 0 then
					--g_ClientPing:StartPing()
				end
			end
		else
			cclog("have no Actror")
		end
	else
		cclog("Error data ")
	end
	local bCreate = (g_IsExistedActor == nil or g_IsExistedActor == 0)
	g_ServerList:CheckNewServer(bCreate)
end

--随机名字
local function requestRandomNameResponse(tbMsg)
	cclog("---------requestRandomNameResponse-------------")
	local msgDetail = account_pb.RandomNameResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	local msgInfo = tostring(msgDetail)
	onResponseRandomName(msgDetail.name)
end

--检测重名
local function requestCheckNameResponse(tbMsg)
	cclog("---------requestCheckNameResponse-------------")
	onRespCheckName(tbMsg.result)
	g_MsgNetWorkWarning:closeNetWorkWarning()
end

--登陆返回
local function requestLoginResponse(tbMsg)
	cclog("---------requestLoginResponse-------------")
	local loginR = zone_pb.LoginResponse()
	local tbData = loginR:ParseFromString(tbMsg.buffer)
	local msgInfo = tostring(loginR)
	cclog(msgInfo)
	cclog("---------requestLoginResponse-------------end")
	--保存神像等级
	if loginR.god_level then 
		g_BaXianPary:setGodLevel(loginR.god_level)
	end
	g_shopSecret:setShopBaseInfo(loginR)
	
	--初始化主角信息
	g_Hero:setHeroBaseInfo(loginR)
	
	--加载布阵的角色的Spine
    g_Spine:loadBuZhenSpine()
	
	g_FarmData:setFarmBaseInfo(loginR.farm_info) --农田数据	
	
	--爱心转盘
	g_TurnTableInfoData:setTableInfo(loginR.turn_table_info)
	
	--小助手 成就
	g_AssistantData:setRecordList(loginR.achievement_info)
		

	--VIP信息	
	g_VIPBase:setVipData(loginR.vip_buy_times)
	--保存体力已经购买的次数
	g_VIPBase:setAddTableByNum(VipType.VipBuyOpType_BuyEnergy,loginR.buy_energy_times)	
	
    --护送信息
	g_BaXianGuoHaiSystem:Init(loginR.baxian_info)

    --FB信息
	g_FacebookRewardSys:init(loginR.facebook_info)

    --是否自动赠送爱心
    g_SocialMsg:setAutoHandselFriend(loginR.is_auto_return_heart)
    	
	g_MsgMgr:setWaitTimeOut(2)
	
	--服务器会主动下发
	-- --同步一下服务器时间
	-- g_MsgMgr:requestSyncServerTime()

	--感悟
	g_EliminateSystem:InitElementInfo(loginR.inspiration)
	
	-- 帮会变更冷却时间点,只有退出，解散帮会的时候才更新
	g_Guild:setGuildChangeColdat(loginR.guild_change_coldat)
 

	--//世界榜排名奖励领取状态(0:无奖励 1:有奖励但未领取 2:已领取)
	if g_ArenaKuaFuData and g_ArenaKuaFuData.setWorldRankRewardRecvStatus then 
		g_ArenaKuaFuData:setWorldRankRewardRecvStatus(loginR.world_rank_reward_recv_status)
	end
	-- g_WndMgr:openWnd("Game_Home")
	-- CCDirector:sharedDirector():replaceScene(mainWnd)
	
	-- g_MsgNetWorkWarning:closeNetWorkWarning()
	
	 --ping 开始工作
	 g_ClientPing:StartPing()
	 --添加重连状态 因为没有游戏内状态。。
	 g_ServerList:SetClientConnectState()

	 g_In_Game = true

	--设置基础信息 TalkingData
	local uid = g_MsgMgr:getZoneUin() or "unkown"
	local ilv = loginR.masterinfo.level or "unkown"
	local igend = loginR.masterinfo.sex or "unkown"
	local accname = loginR.masterinfo.name or "unkown"
	local servername = g_ServerList:GetLocalName() or "unkown"
    local deviceId = g_ServerList.deviceIDServer or "unkown"

--    local TDID = tonumber(g_ServerList.deviceIDServer)
--    if TDID == nil then TDID = 0 end
    if g_LggV.LanguageVer ~= eLanguageVer.LANGUAGE_cht_Taiwan and g_LggV.LanguageVer ~= eLanguageVer.LANGUAGE_viet_VIET then
	    gTalkingData:InitPlayerBaseInfo(deviceId, ilv, igend, accname, servername)
    end

    --平台sdk需要的扩展参数
    if g_GamePlatformSystem.m_PlatformInterface.submitExtendData ~= nil then
        g_GamePlatformSystem.m_PlatformInterface:submitExtendData(uid, accname, ilv, servername, g_ServerList:GetLocalServerID())
    end

    if CGamePlatform:SharedInstance().submitExtendDataEx then -- G_SubmitData then
    	local nyuanbao = 100
    	if g_Hero then
    		nyuanbao = g_Hero:getYuanBao()
    	end
    	local accname_new = ""
        if macro_pb.LOGIN_PLATFORM_UC == g_GamePlatformSystem:GetServerPlatformType() then
            local create_role_time = loginR.create_time
            accname_new = accname.."&"..create_role_time
        end 
    	CGamePlatform:SharedInstance():submitExtendDataEx(uid, accname_new, ilv, servername, nyuanbao, g_ServerList:GetLocalServerID(), 1)
    end

    if CGameDataAdTracking and CGameDataAdTracking.onLogin then
		CGameDataAdTracking:onLogin(g_GamePlatformSystem:GetAccount_PlatformID())
		cclog("CGameDataAdTracking:onLogin:"..g_GamePlatformSystem:GetAccount_PlatformID())
    end

    if CGameDataAppsFlyer and CGameDataAppsFlyer.onLoginFlayer then
        CGameDataAppsFlyer:onLoginFlayer(g_GamePlatformSystem:GetAccount_PlatformID())
        cclog("CGameDataAppsFlyer:onLoginFlayer:"..g_GamePlatformSystem:GetAccount_PlatformID())
    end

    --刷新token，现在应用宝适用
    if g_GamePlatformSystem.m_PlatformInterface ~=nil and  
    g_GamePlatformSystem.m_PlatformInterface.SendrefreshTokens ~=nil
    then
        g_GamePlatformSystem.m_PlatformInterface:SendrefreshTokens()
    end

    --登陆成功将玩家设备&网络等(deviceid,model,opersystem,ip),Jason格式扩展传给服务器
    if CGamePlatform:SharedInstance().getImei then
        local devise_info = string.split(CGamePlatform:SharedInstance():getImei(), "|")
        local retTable = {};    --最终产生json的表
        retTable["deviceid"] = g_ServerList.deviceIDServer or "no id"
        retTable["model"] = ((devise_info[1] == "") and "unkown" or devise_info[1]) or "unkown"           --手机型号
        retTable["opersystem"] = ((devise_info[2] == "") and "unkown" or devise_info[2]) or "unkown"      --系统版本
        retTable["ip"] = "127.0.0.1"
        local jsonStr = g_luaToJson(retTable) 
        local Msg = zone_pb.RoleDeviceInfoReportReq()
        Msg.role_opt_type = zone_pb.ENM_SDK_STAT_ROLE_OPT_LOGIN
        Msg.device_info = jsonStr
        if g_GamePlatformSystem:GetServerPlatformType() == macro_pb.LOGIN_PLATFORM_YI_JIE then
            Msg.sdk = g_GamePlatformSystem:GetChildPlatformType()
        end
	    g_MsgMgr:sendMsg(msgid_pb.MSGID_ROLE_DEVICE_INFO_REPORT_REQ, Msg)
    end
end

-- // 创建角色返回
-- message CreateRoleResponse
-- {
-- 	required int32 result = 1;			// 创建角色结果
-- 	required uint32 uin = 2;			// 创建角色成功后返回生成的角色的uin
-- 	required string Account = 3;		//账号
-- 	required string Name = 4;			//玩家名字
-- }
--创建角色返回
local function requestCreateRoleResponse(tbMsg)
	cclog("--------requestCreateRoleResponse--------------")
	local createRoleR = zone_pb.CreateRoleResponse()
	createRoleR:ParseFromString(tbMsg.buffer)

	if createRoleR.result == 0 then
		g_MsgMgr:setUserID(createRoleR.uin)
	end
	
	local loadingCity = Game_LoadingCity.new()
	loadingCity:initView() 
	CCDirector:sharedDirector():getRunningScene():addChild(loadingCity,10)
-- CCDirector:sharedDirector()
	--g_Hero:setHeroBaseInfo(createRoleR)

	-- local LoginScene = LYP_GetLoadingScene()
	-- local NextSence = CCTransitionFade:create(1, LoginScene)
	-- CCDirector:sharedDirector():replaceScene(NextSence)
	-- Game_CreateCharacter1 = nil

	-- if CGamePlatform:SharedInstance().submitExtendDataEx then
	-- 	local uid = g_MsgMgr:getZoneUin()
	-- 	local ilv = "1"
	-- 	local accname = g_Hero:getMasterName()
	-- 	local servername = g_ServerList:GetLocalName()

 --    	local nyuanbao = 100
 --    	if g_Hero then
 --    		nyuanbao = g_Hero:getYuanBao()
 --    	end 
 --    	CGamePlatform:SharedInstance():submitExtendDataEx(uid, accname, ilv, servername, nyuanbao, g_ServerList:GetLocalServerID(), 4)
 --    end

  --登陆成功将玩家设备&网络等(deviceid,model,opersystem,ip),Jason格式扩展传给服务器
    if CGamePlatform:SharedInstance().getImei then
        local devise_info = string.split(CGamePlatform:SharedInstance():getImei(), "|")
        local retTable = {};    --最终产生json的表
        retTable["deviceid"] = g_ServerList.deviceIDServer or "no id"
        retTable["model"] = ((devise_info[1] == "") and "unkown" or devise_info[1]) or "unkown"           --手机型号
        retTable["opersystem"] = ((devise_info[2] == "") and "unkown" or devise_info[2]) or "unkown"      --系统版本
        retTable["ip"] = "127.0.0.1"
        local jsonStr = g_luaToJson(retTable) 
        local Msg = zone_pb.RoleDeviceInfoReportReq()
        Msg.role_opt_type = zone_pb.ENM_SDK_STAT_ROLE_OPT_REGISTER
        Msg.device_info = jsonStr
	    g_MsgMgr:sendMsg(msgid_pb.MSGID_ROLE_DEVICE_INFO_REPORT_REQ, Msg)
    end

end

--请求、邀请、更换、移动伙伴
local function requestInviteChangeCallBack(tbMsg)
	local msgChangeBuZhen = zone_pb.ChangeArrayOpResponse()
	msgChangeBuZhen:ParseFromString(tbMsg.buffer)
    local msgInfo = tostring(msgChangeBuZhen)
	cclog(msgInfo)
	
	g_Hero:changeBuZhen(msgChangeBuZhen)
	
	if g_WndMgr:getWnd("Game_BattleBuZhen") and g_WndMgr:isVisible("Game_BattleBuZhen") then
		g_WndMgr:getWnd("Game_BattleBuZhen"):resetBattleBuZhen()

		if g_PlayerGuide:checkCurrentGuideSequenceNode("ServerResponse", "Game_BattleBuZhen") then
			g_PlayerGuide:showCurrentGuideSequenceNode()
		end
    elseif g_WndMgr:getWnd("Game_MainUI") and g_WndMgr:isVisible("Game_MainUI") then
       if g_PlayerGuide:checkCurrentGuideSequenceNode("ServerResponse", "Game_MainUI") then
			g_PlayerGuide:showCurrentGuideSequenceNode()
		end
        g_WndMgr:getWnd("Game_MainUI"):updateBuZhen(msgChangeBuZhen)
	else
		if TbBattleReport then
			g_battleChangePosition(msgChangeBuZhen)
		end
    end

   	g_ErrorMsg:RelieveListenMsg(msgid_pb.MSGID_CHANGE_ARRAYOP_REQUEST, msgid_pb.MSGID_CHANGE_ARRAYOP_RESPONSE)
    g_MsgNetWorkWarning:closeNetWorkWarning()
end

local function showTenTimesFromMarket(dropList)
	local list = {}
	for key,v in ipairs(dropList) do
		local tbList = {}
		tbList.types = v.drop_item_type--类型
		tbList.itemId = v.drop_item_id --物品id
		tbList.confingId = v.drop_item_config_id --配置id
		tbList.starLevel = v.drop_item_star_lv --星级
		tbList.itemLevel = v.drop_item_lv --物品等级
		tbList.ItemEvoluteLevel = v.drop_item_blv --物品等级
		tbList.cfgId = v.to_god_card_cfg_id
		tbList.nItemNum = v.drop_item_num
		table.insert(list,tbList)
	end
	
	if next(list) == nil then
		cclog("掉落来源数据为空")
		return 
	end
	local Game_SummonTenTimes = g_WndMgr:getWnd("Game_SummonTenTimes")
	if Game_SummonTenTimes then
		Game_SummonTenTimes:removeClone()
		Game_SummonTenTimes:addInfoMsgProcess(list)
	end

end

g_AniParamsSummon = {}
g_DropSourceType = {
	[macro_pb.DS_SUMMONCARD_COPPER] = 1,--铜钱召唤伙伴
	[macro_pb.DS_SUMMONCARD_COUPONS] = 2,--元宝召唤伙伴
}
local function showDropFromMarket(dropList, dropSrc)
	

	if dropList then
		local tbDropData = dropList[1]
		local nDropItemType = tbDropData.drop_item_type--类型
		local nDropItemID = tbDropData.drop_item_id --物品id
		local nDropItemCfgID = tbDropData.drop_item_config_id --配置id
		local nDropItemStarLevel = tbDropData.drop_item_star_lv --星级
		local nDropItemEvoluteLevel = tbDropData.drop_item_blv --突破等级
		local nItemNum = tbDropData.drop_item_num --
		local cfgId = tbDropData.to_god_card_cfg_id
		
		local strDropItemIcon, CSV_Data = getIconByType(nDropItemCfgID, nDropItemStarLevel, nDropItemType)
		g_AniParamsSummon = {
			nDropSourceType = g_DropSourceType[dropSrc],
			CSV_Data = CSV_Data,
			strItemIcon = strDropItemIcon,
			nItemID = nDropItemID,
			nItemType = nDropItemType,
			nItemEvoluteLevel = nDropItemEvoluteLevel,
			funcDisappearedCallBack = nil,
			funcEndCallBack = nil,
			cfgId = cfgId,
			nItemNum = nItemNum,
		}
		g_ShowSummonCardAnimation(g_AniParamsSummon)
	end

end

local function setTbYuanShenExchangeCard(dropList)
	for _,v in pairs(dropList) do
		if v.drop_item_type==macro_pb.ITEM_TYPE_CARD then
			local tbCard = g_Hero:getCardObjByServID(v.drop_item_id)
			local nDropItemCfgID = tbCard:getCsvID()
			local tbHunPo = g_DataMgr:getCardHunPoCsv(nDropItemCfgID)
			local nDropItemStarLevel = tbCard:getStarLevel()
			local nDropItemType = macro_pb.ITEM_TYPE_CARD
			local strDropItemIcon,CSV_Data = getIconByType(nDropItemCfgID, nDropItemStarLevel, nDropItemType)

			local param = {
				nDropSourceType = 1,
				CSV_Data = CSV_Data,
				strItemIcon = strDropItemIcon,
				nItemID = nDropItemID,
				nItemType = nDropItemType,
				nItemEvoluteLevel = tbCard:getEvoluteLevel(),
			}

			g_ShowSummonCardAnimation(param)
			break
		end
	end
	
	if g_PlayerGuide:checkCurrentGuideSequenceNode("ServerResponse", "Game_SummonAnimation") then
		g_PlayerGuide:showCurrentGuideSequenceNode()
	end
end

--请求掉落
local function requestAddDropItemRespone(tbMsg)
	g_ErrorMsg:RelieveListenMsg(msgid_pb.MSGID_SUMMON_CARD_REQUEST, msgid_pb.MSGID_DROP_RESULT_NOTIFY)
	
	if g_PlayerGuide:checkCurrentGuideSequenceNode("ServerResponse", "Game_RewardBox") then
		cclog("===================新手引导事件ServerResponse===================")
		g_PlayerGuide:showCurrentGuideSequenceNode()
	end
	
	cclog("---------requestAddDropItemRespone-------------")
	local dropInfoR = zone_pb.DropResultNotify()
	dropInfoR:ParseFromString(tbMsg.buffer)
	local msgInfo = tostring(dropInfoR)
	cclog("掉落信息通知"..msgInfo)
	
	g_MsgNetWorkWarning:closeNetWorkWarning()
	
	local dropSrc = dropInfoR.drop_src;--掉落来源
	local showFunc = nil
	if dropSrc == macro_pb.DS_EXCHANGE_GOD then
		showFunc = setTbYuanShenExchangeCard
	elseif dropSrc == macro_pb.DS_SHOPITEM then --天榜聚宝阁
	elseif dropSrc == macro_pb.DS_SUMMONCARD_COPPER  --铜钱召唤伙伴
		or dropSrc == macro_pb.DS_SUMMONCARD_COUPONS
	then --元宝召唤伙伴
		showFunc = showDropFromMarket
	elseif dropSrc == macro_pb.DS_TENCARD_COPPER 		-- 铜钱召唤十连抽
		or dropSrc == macro_pb.DS_TENCARD_COUPONS then --元宝召唤十连抽
		showFunc = showTenTimesFromMarket
	end
	
	if showFunc then
		local droplst = dropInfoR.drop_result.drop_lst;--掉落信息
		--初始掉落物品数据
		g_Hero:addDropInfo(dropInfoR)
		showFunc(droplst, dropSrc)
		return
	end
	
	----激活码兑换
	if dropSrc == macro_pb.DS_EXCHANGE_CODE then 
		local info =  dropInfoR.drop_result.drop_lst
		local tbData = {
			nRewardStatus = 1,
			tbParamentList = {},
			updateHeroResourceInfo = nil,
		}
		for k, v in ipairs(info)do
			local tbDropList = {}
			tbDropList.DropItemType = v.drop_item_type or 0
			tbDropList.DropItemID = v.drop_item_config_id or 0
			tbDropList.DropItemStarLevel = v.drop_item_star_lv or 0
			tbDropList.DropItemNum = v.drop_item_num or 0
			tbDropList.DropItemEvoluteLevel = v.drop_item_blv or 0
			table.insert(tbData.tbParamentList, tbDropList)
		end                                                                                                  
		tbData.updateHeroResourceInfo = function()
			g_Hero:addDropInfo(dropInfoR)
		end
		g_WndMgr:showWnd("Game_RewardBox",tbData)
		return 
	end

	--装备初始化、竞技场胜利
	if dropSrc == macro_pb.DS_EQUIP_INIT or dropSrc == macro_pb.DS_ARENA_WIN  then
		local droplst = dropInfoR.drop_result.drop_lst;--掉落信息
		--初始掉落物品数据
		g_Hero:addDropInfo(dropInfoR)
        return
	end

	if dropSrc == macro_pb.DS_TURNTABLE then
		
		if #dropInfoR.drop_result.drop_lst >= 1 then
			local info =  dropInfoR.drop_result.drop_lst[1]
			if info.drop_item_type >= 8 then
				g_Hero:addDropInfo(dropInfoR)
				local function call()
					g_ShowRewardMsgConfrim(info.drop_item_type, info.drop_item_num)
				end
				
				local Game_Turntable = g_WndMgr:getWnd("Game_Turntable")
				if Game_Turntable then
					Game_Turntable.callFunc = call
				end
				return
			end
		end
	end

	if (dropSrc == macro_pb.DS_REWARD
		or dropSrc == macro_pb.DS_GMDROP) 
	and #dropInfoR.drop_result.drop_lst == 1 then
		local info =  dropInfoR.drop_result.drop_lst[1]
		if info.drop_item_type == 8 or info.drop_item_type == 19 then
			local function updateHeroResourceInfo()
				g_Hero:addDropInfo(dropInfoR)
			end
			g_ShowRewardMsgConfrim(info.drop_item_type, info.drop_item_num, updateHeroResourceInfo)
			return
		elseif info.drop_item_type > 8 then
			g_Hero:addDropInfo(dropInfoR)
			g_ShowRewardMsgConfrim(info.drop_item_type, info.drop_item_num)
			return
		end
	end

	--天降元宝活动
	if dropSrc == macro_pb.DS_ACTIVITY_ONLINE_YC then
		local info =  dropInfoR.drop_result.drop_lst[1]
		Act_TianJiangYB:setResult(info)
		return
	end

    --节日天降元宝活动
	if dropSrc == macro_pb.DS_ACTIVITY_ONLINE_YC_JR then
		local info =  dropInfoR.drop_result.drop_lst[1]
		Act_TianJiangYBJR:setResult(info)
		return
	end
	
	--如果地图ID是1魂魄由创建角色添加，客户端构造假的魂魄掉落数量，防止引导卡住
	if dropSrc == macro_pb.DS_STAR_REWARD then
		local info =  dropInfoR.drop_result.drop_lst
		if #info > 1 then
			local tbData = {
				nRewardStatus = 1,
				tbParamentList = {},
				updateHeroResourceInfo = nil,
			}

			for k, v in ipairs(info)do
				local tbDropList = {}
				tbDropList.DropItemType = v.drop_item_type or 0
				tbDropList.DropItemID = v.drop_item_config_id or 0
				tbDropList.DropItemStarLevel = v.drop_item_star_lv or 0
				tbDropList.DropItemNum = v.drop_item_num or 0
				tbDropList.DropItemEvoluteLevel = v.drop_item_blv or 0
				table.insert(tbData.tbParamentList, tbDropList)
			end
			g_WndMgr:showWnd("Game_RewardBox", tbData)
            g_Hero:addDropInfo(dropInfoR)
			return
		end
	end
	
	-- 小助手活跃度礼包
	-- 注意有经验奖励的需要在Game_RewardBox的closeWnd回调里增加物品，其他的最好是先增加，然后弹出确认框
	if dropSrc == macro_pb.DS_ASSISTANT then
		local info =  dropInfoR.drop_result.drop_lst
		local tbData = {
			nRewardStatus = 1,
			tbParamentList = {},
			updateHeroResourceInfo = nil,
		}
		for k, v in ipairs(info)do
			local tbDropList = {}
			tbDropList.DropItemType = v.drop_item_type or 0
			tbDropList.DropItemID = v.drop_item_config_id or 0
			tbDropList.DropItemStarLevel = v.drop_item_star_lv or 5
			tbDropList.DropItemNum = v.drop_item_num or 0
			tbDropList.DropItemEvoluteLevel = v.drop_item_blv or 0
			table.insert(tbData.tbParamentList, tbDropList)
		end
		tbData.updateHeroResourceInfo = function()
			g_Hero:addDropInfo(dropInfoR)
		end
	
		local wndInstance = g_WndMgr:getWnd("Game_Assistant")
		if wndInstance then
			wndInstance:showActivenessPackageAni(tbData)
		end
		return
		
	-- 签到、七天奖励、邮件
	elseif dropSrc == macro_pb.DS_SEVENDAY
		or dropSrc == macro_pb.DS_MAIL
		or dropSrc == macro_pb.DS_ACTIVITY_ONLINE
		or dropSrc == macro_pb.DS_SIGN_IN
		or dropSrc == macro_pb.DS_PACKAGE
		or dropSrc == macro_pb.DS_DEFAULT  --运营活动
		or dropSrc == macro_pb.DS_DECOMPOSE_CARD
		or dropSrc == macro_pb.DS_CROSS_ARENA_RANK_REWARD --跨服掉落
		or dropSrc == macro_pb.DS_ACHIEVEMENT
	then
		local info =  dropInfoR.drop_result.drop_lst
		if #info > 1 then
			local tbData = {
				nRewardStatus = 1,
				tbParamentList = {},
				updateHeroResourceInfo = nil,
			}

			for k, v in ipairs(info)do
				local tbDropList = {}
				tbDropList.DropItemType = v.drop_item_type or 0
				tbDropList.DropItemID = v.drop_item_config_id or 0
				tbDropList.DropItemStarLevel = v.drop_item_star_lv or 0
				tbDropList.DropItemNum = v.drop_item_num or 0
				tbDropList.DropItemEvoluteLevel = v.drop_item_blv or 0
				table.insert(tbData.tbParamentList, tbDropList)
			end
			g_WndMgr:showWnd("Game_RewardBox", tbData)
            g_Hero:addDropInfo(dropInfoR)
		else
			local info =  dropInfoR.drop_result.drop_lst[1]
			if info.drop_item_type == 8 or info.drop_item_type == 19 then
				local function updateHeroResourceInfo()
					g_Hero:addDropInfo(dropInfoR)
				end
				g_ShowRewardMsgConfrim(info.drop_item_type, info.drop_item_num, updateHeroResourceInfo)
			elseif info.drop_item_type > 8 then
				g_Hero:addDropInfo(dropInfoR)
				g_ShowRewardMsgConfrim(info.drop_item_type, info.drop_item_num)				
			else
				local CSV_DropItem = {}
				CSV_DropItem.DropItemType = info.drop_item_type or 0
				CSV_DropItem.DropItemID = info.drop_item_config_id or 0
				CSV_DropItem.DropItemStarLevel = info.drop_item_star_lv or 0
				CSV_DropItem.DropItemNum = info.drop_item_num or 0
				CSV_DropItem.DropItemEvoluteLevel = info.drop_item_blv or 0
                g_Hero:addDropInfo(dropInfoR)
				
				if g_PlayerGuide:checkCurrentGuideSequenceNode("ServerResponse", "Game_TipDropReward") then
					g_PlayerGuide:showCurrentGuideSequenceNode()
				end
				g_ShowSingleRewardBox(CSV_DropItem)
			end
		end
		return
	end
	
	g_Hero:addDropInfo(dropInfoR)
end

--gm命令响应
local function requestGMAddItemRespone(tbMsg)
	local gmR = zone_pb.GMCommandResponse()
	gmR:ParseFromString(tbMsg.buffer)
	cclog("---------requestGMAddItem Succ  -------------"..gmR.gm_command)
end

--伙伴传功响应
local function requestChuanGongRespone(tbMsg)
	g_Hero:chuanGongCard()
end

--元神兑换伙伴响应
local function requestExChangeCardRespone(tbMsg)
	echoj("<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<元神<<")
	local tbServerMsg = zone_pb.ExchangeGodResponse()
	tbServerMsg:ParseFromString(tbMsg.buffer)
	cclog(tostring(tbServerMsg))
	echoj(">>>>>>>>>>>>>>>>元神>>>>>>>>>>>>")
	if tbServerMsg.exchange_card_god_id and tbServerMsg.leave_card_god_num then
		g_Hero:setHunPoNum(tbServerMsg.exchange_card_god_id, tbServerMsg.leave_card_god_num)
	end
	
	if tbServerMsg.replace_id and tbServerMsg.replace_num then
		g_Hero:setItemNum(tbServerMsg.replace_id, tbServerMsg.replace_num)
	end

	g_ErrorMsg:RelieveListenMsg(msgid_pb.MSGID_EXCHANGEGOD_REQUEST, msgid_pb.MSGID_EXCHANGEGOD_RESPONSE)
end

--出售伙伴响应
local function requestCardSellRespone(tbMsg)
	local tbSubMsg = zone_pb.SellCardResponse()
	tbSubMsg:ParseFromString(tbMsg.buffer)
	local msgInfo = tostring(tbSubMsg)
	cclog(msgInfo)
	local get = tbSubMsg.updated_money-g_Hero:getCoins()
	g_ShowRewardMsgConfrim(macro_pb.ITEM_TYPE_GOLDS, get)
end

--伙伴升级响应
local function requestCardLevUpRespone(tbMsg)
	local tbSubMsg = zone_pb.UpgradeCardResponse()
	tbSubMsg:ParseFromString(tbMsg.buffer)
	local msgInfo = tostring(tbSubMsg)
	cclog(msgInfo)

	ProcessMsgBackShowAnimation(tbSubMsg)
end

--伙伴装丹药
local function requestDressMedecineRespone(tbMsg)
	cclog("---------requestDressMedecineRespone-------------")
	local dressmedecine = zone_pb.InlayDanYaoToCardResponse()
	dressmedecine:ParseFromString(tbMsg.buffer)

	local msgInfo = tostring(dressmedecine)
	cclog(msgInfo)

	g_Hero:dressMedecine(dressmedecine)

	mainWnd.layerPickCardMedecine:setVisible(false)
end


--伙伴进化
local function requestEvoluteRespone(tbMsg)
	cclog("---------requestEvoluteRespone-------------")
	local protomessage = zone_pb.BreachCardResponse()
	protomessage:ParseFromString(tbMsg.buffer)
	cclog(tostring(protomessage))
	if g_WndMgr:getWnd("Game_Equip1") then
		g_WndMgr:getWnd("Game_Equip1"):refreshEvoluteWnd(protomessage)
	end

    g_ErrorMsg:RelieveListenMsg(msgid_pb.MSGID_BREACH_CARD_REQUEST, msgid_pb.MSGID_BREACH_CARD_RESPONSE)
end


local function requestActivityResponse(tbMsg)
	cclog("---------requestActivityResponse-------------")
	local protomessage = zone_pb.ActivityResponse()
	protomessage:ParseFromString(tbMsg.buffer)
	local msgInfo = tostring(protomessage)
	cclog(msgInfo)
	
	--
	local yuanBao = g_Hero:getYuanBao() - protomessage.update_coupons
	if yuanBao > 0 then 
		gTalkingData:onPurchase(TDPurchase_Type.TDP_ARENA_Activity, 1, yuanBao)	
	end
	g_Hero:setCoins(protomessage.update_money)
	g_Hero:setYuanBao(protomessage.update_coupons)
	g_Hero:setEnergy(protomessage.update_energy)
	g_ShowRewardMsgConfrim(macro_pb.ITEM_TYPE_GOLDS, g_Hero:getZhaoCaiCoins())
end

local function requestPickPeachInviteHeroResponse(tbMsg)
	--摘仙桃玩法去掉了
end

local function requestAssistantRefreshResponse(tbMsg)
	cclog("---------requestAssistantRefreshResponse-------------")
	local protomessage = zone_pb.AssistantRefreshResponse()
	protomessage:ParseFromString(tbMsg.buffer)

	local msgInfo = tostring(protomessage)
	cclog(msgInfo)
	--奖励信息
	g_Hero:refreshAssitantInfo(protomessage, true)
end

local function requestAssisActiveUpdateResponse(tbMsg)
	local protomessage = zone_pb.AssistantNotify()
	protomessage:ParseFromString(tbMsg.buffer)
	local msgInfo = tostring(protomessage)
	cclog(msgInfo)
	g_Hero:refreshAssitantInfo(protomessage, false)
end

local function requestAssistantRewardResponse(tbMsg)
	cclog("---------requestAssistantRewardResponse-------------")
	local protomessage = zone_pb.AssistantRewardResponse()
	protomessage:ParseFromString(tbMsg.buffer)
	cclog(tostring(protomessage))
	g_Hero:onAssistantReward(protomessage)
end

local function requestEctypeInfoResponse(tbMsg)
	cclog("lxlxlxlxlx ---副本信息响应---->vfunction requestEctypeInfoResponse")
	local protomessage = zone_pb.MapPointInfoResponse()
	protomessage:ParseFromString(tbMsg.buffer)

	local msgInfo = tostring(protomessage)
	cclog(msgInfo)
	
	g_EctypeListSystem:SetMapEctypeInfo(protomessage)
	g_Hero:setEctypePassStars(protomessage)
	
	--合成界面
	local wndInstance = g_WndMgr:getWnd("Game_Compose")
	if wndInstance then
		wndInstance:itemDropGuide()
	end
	
	--合成界面
	local wndInstance = g_WndMgr:getWnd("Game_ItemDropGuide")
	if wndInstance then
		wndInstance:openSelectGameLevel()
	end
	
	g_ErrorMsg:RelieveListenMsg(msgid_pb.MSGID_MAP_POINT_INFO_REQUEST, msgid_pb.MSGID_MAP_POINT_INFO_RESPONSE)
	--关闭 八卦
	g_MsgNetWorkWarning:closeNetWorkWarning()
end

--战斗过程数据
local function requestBattleReportResponse(tbMsg)
	local protomessage = zone_pb.BattleReportNotify()
	protomessage:ParseFromString(tbMsg.buffer)
	--local msgInfo = tostring(protomessage)

	g_WndMgr:openWnd("Game_Battle", protomessage)
end

--挑战副本返回
local function requestBattleResponse(tbMsg)
	local msgDetail = zone_pb.AttackSmallPassResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	local msgInfo = tostring(msgDetail)
	cclog(msgInfo)
	g_Hero:setBattleRespone(msgDetail)

	-- add by zgj
	if bAutoTest then
		return 
	end
	
	g_EctypeListSystem:SetSingleEctypeInfo(msgDetail)
	cclog("lxlxlxlxlx ---攻打某个副本响应---- requestBattleResponse")
end

local function requestSummonCardRefreshResponse(tbMsg)
	cclog("--------requestSummonCardRefreshResponse----------")
	local msgDetail = zone_pb.SummonCardRefreshResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog("召唤冷却时间======="..tostring(msgDetail))
	g_Hero:onSummonCardRefresh(msgDetail)
end


--伙伴召唤
local function requestSummonCardResponse(tbMsg)
	cclog("--------requestSummonCardResponse----------")
	local msgDetail = zone_pb.SummonCardResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))
	if msgDetail.success == 1 and  msgDetail.type >= 1 then
	
	    local yuanBao =  g_Hero:getYuanBao() - msgDetail.updated_coupons
		if yuanBao > 0 then 
			local itemType = nil
			if msgDetail.type == 1 then 
				itemType = TDPurchase_Type.TDP_CommonTenSummon
			else
				itemType = TDPurchase_Type.TDP_AdvancedTenSummon
			end
			gTalkingData:onPurchase(itemType, 1, yuanBao)
		end
	
		g_Hero:onSummonCard(msgDetail)
	end
	
	g_ErrorMsg:RelieveListenMsg(msgid_pb.MSGID_SUMMON_CARD_REQUEST, msgid_pb.MSGID_SUMMON_CARD_RESPONSE)
end

--伙伴装备装备或更换
local function requestCardDressEquipRespone(tbMsg)
	local tbSubMsg = zone_pb.ChangeEquipResponse()
	tbSubMsg:ParseFromString(tbMsg.buffer)
	if (not tbSubMsg) then
		cclog("requestCardDressEquipRespone tbSubMsg nil")
		return
	end
	local nCardID = tbSubMsg.change_cardid
	local nEquipID = tbSubMsg.put_equip_id
	local index = tbSubMsg.change_idx + 1
	
	local tbCard = g_Hero:getCardObjByServID(nCardID)
    if (not tbCard) then
		cclog(" requestCardDressEquipRespone tbCard nil ")
		return
	end
	local nEquipIDOld = tbCard:getEquipIDByPos(index)
	local GameObj_EquipOld = g_Hero:getEquipObjByServID(nEquipIDOld)
	
	local GameObj_EquipNew = g_Hero:getEquipObjByServID(nEquipID)
	if not GameObj_EquipNew then --表示取消装备
		if GameObj_EquipOld then
			GameObj_EquipOld:setOwnerID(nil)
			tbCard:changeEquipIDByPos(index, 0, "Undress",  GameObj_EquipOld, nil)
		end
		g_WndMgr:closeWnd("Game_TipEquip")
		local instance = g_WndMgr:getWnd("Game_Equip1")
		if instance then 
			instance:updateEquipIcon(tbCard,index) 
		end
	else
	    if nEquipIDOld ~= 0 then --更换
			if GameObj_EquipOld then
				GameObj_EquipOld:setOwnerID(nil)
				GameObj_EquipNew:setOwnerID(nCardID)
				tbCard:changeEquipIDByPos(index, nEquipID, "Exchange", GameObj_EquipOld, GameObj_EquipNew)
			end
		else --装备新装备
			GameObj_EquipNew:setOwnerID(nCardID)
			tbCard:changeEquipIDByPos(index, nEquipID, "Dress", nil, GameObj_EquipNew)
	    end
		
		local instance = g_WndMgr:getWnd("Game_Equip1")
	    if instance then instance:refrehWnd(tbCard, index) end
		
	end
	

end

--出售装备响应
local function requestSellEquipRespone(tbMsg)
	cclog("---------requestSellEquipRespone-------------")

	local msgDetail = zone_pb.SellEquipResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	local msgInfo = tostring(msgDetail)
	cclog(msgInfo)
	local nEquipID = msgDetail.sell_equip_id
	g_Hero:delEquopByServID(nEquipID)
	local nCurMoney = g_Hero:getCoins()

    local instance = g_WndMgr:getWnd("Game_Equip1")
    if instance then
        if instance.ckEquip:getCheckIndex()== 1 then
			instance:updateEquipIcon()
        end
    end
	
	local nAddMoney = msgDetail.updated_money - nCurMoney
	g_Hero:setCoins(msgDetail.updated_money)
    g_ShowRewardMsgConfrim(macro_pb.ITEM_TYPE_GOLDS, nAddMoney)
end

--强化装备返回
local function requestStrengthenEquipRespone(tbMsg)
	cclog("---------requestStrengthenEquipRespone-------------")

	local msgDetail = zone_pb.StrengthenEquipResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	local msgInfo = tostring(msgDetail)
	cclog(msgInfo)

	local nEquipID = msgDetail.strengthen_equip_id
	local tbMainEquip = g_Hero:getEquipObjByServID(nEquipID)
	if tbMainEquip then 
		tbMainEquip:setStrengthenLev(msgDetail.strengthen_equip_strlv)
	end
	
	g_Hero:setCoins(msgDetail.updated_money)
	
	refreshStrengthenWnd(nEquipID)
	
	echoj("====强化装备返回====")
	--刷新 强化的某一个装备
	if g_WndMgr:getWnd("Game_Equip1") then
		g_WndMgr:getWnd("Game_Equip1"):updateEquipIcon()
	end
	
	if g_PlayerGuide:checkCurrentGuideSequenceNode("ServerResponse", "Game_EquipStrengthen") then
		g_PlayerGuide:showCurrentGuideSequenceNode()
	end

	g_ErrorMsg:RelieveListenMsg(msgid_pb.MSGID_STRENGTHEN_EQUIP_REQUEST, msgid_pb.MSGID_STRENGTHEN_EQUIP_RESPONSE)
end

--一键强化装备返回
local function requestStrengthOneKeyResponse(tbMsg)
	cclog("---------requestStrengthOneKeyResponse-------------")
	cclog("---------一键强化装备返回-------------")

	local msgDetail = zone_pb.StrengthOneKeyResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	local msgInfo = tostring(msgDetail)
	cclog(msgInfo)
	
	local nEquipID = msgDetail.equip_id --一键强化装备id
	local strengthLevel = msgDetail.strength_lv --最终强化等级
	local updatedMoney = msgDetail.updated_money --剩余铜钱
	
	local tbMainEquip = g_Hero:getEquipObjByServID(nEquipID)
	if tbMainEquip then 
		tbMainEquip:setStrengthenLev(strengthLevel)
	end
	g_Hero:setCoins(updatedMoney)
	
	refreshStrengthenWnd(nEquipID)
	
	if g_WndMgr:getWnd("Game_Equip1") then
		g_WndMgr:getWnd("Game_Equip1"):updateEquipIcon()
	end
	
	if g_PlayerGuide:checkCurrentGuideSequenceNode("ServerResponse", "Game_EquipStrengthen") then
		g_PlayerGuide:showCurrentGuideSequenceNode()
	end
end

--合成装备响应
local function requestCompoundEquipRespone(tbMsg)
	cclog("---------requestCompoundEquipRespone-------------")

	local msgDetail = zone_pb.CompoundEquipResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	local msgInfo = tostring(msgDetail)
	cclog(msgInfo)

	local nEquipID = msgDetail.compound_equip_id
	local tbMainEquip = g_Hero:getEquipObjByServID(nEquipID)
	tbMainEquip.nStarLevel = msgDetail.compound_equip_starlv
	g_Hero:setCoins(msgDetail.updated_money)

	for i = 1, #msgDetail.cost_equip_idlst do
		g_Hero:delEquopByServID(msgDetail.cost_equip_idlst[i])
	end
	refreshEquipWork(3, tbMainEquip)
	refreshEquipWorkFromCard(3, tbMainEquip)

	
end

--重铸装备响应
local function requestRebuildEquipRespone(tbMsg)
	cclog("---------requestRebuildEquipRespone-------------")

	local msgDetail = zone_pb.RebuildEquipResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	local msgInfo = tostring(msgDetail)
	cclog(msgInfo)
	
	g_MsgNetWorkWarning:closeNetWorkWarning()
	
	local nEquipID = msgDetail.rebuild_equip_id
	local tbMainEquip = g_Hero:getEquipObjByServID(nEquipID)
	local tbCsvBase = tbMainEquip:getCsvBase()

	tbMainEquip:setEquipTbProp(msgDetail.rebuild_index, msgDetail.rebuild_random_prop)
	g_Hero:setCoins(msgDetail.updated_money)
	local tbMaterialCfg = g_DataMgr:getEquipWorkMaterialGroupCsv(tbCsvBase.ChongZhuMaterialGroupID)
	CostMaterialByCfg(tbMaterialCfg)
	freshChongZhuWnd(nEquipID)
	

end

local function requestSiginInRefreshResponse(tbMsg)
	cclog("---------requestSignInRefreshResponse-------------")
	local msgDetail = zone_pb.SignInRefreshResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	g_Hero:onSignInRefresh(msgDetail)
	g_WndMgr:showWnd("Game_Registration1")
	g_ErrorMsg:RelieveListenMsg(msgid_pb.MSGID_SIGNIN_REFRESH_REQUEST, msgid_pb.MSGID_SIGNIN_REFRESH_RESPONSE)
end

local function requestSiginInResponse(tbMsg)
	cclog("---------requestSignInResponse-------------")
	local msgDetail = zone_pb.SignInResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))
	g_Hero:onSignIn(msgDetail)
	if g_WndMgr:getWnd("Game_Registration1") then
		g_WndMgr:getWnd("Game_Registration1"):SignInResponse()
	end
end

local function requestRewardResponse(tbMsg)
	cclog("---------requestRewardResponse-------------")
	local msgDetail = zone_pb.ReWardInfoResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	local msgInfo = tostring(msgDetail)
	cclog(msgInfo)

	g_Hero:setRewardInfo(msgDetail.reward_info)

    setYueKaInfo(msgDetail.month_card_info)--月卡信息

	if g_WndMgr:getWnd("Game_Assistant") then
		g_WndMgr:getWnd("Game_Assistant"):updateList(2)
	end
end

local function requestGainRewardResponse(tbMsg)
	cclog("---------requestGainRewardResponse-------------")
	local msgDetail = zone_pb.GainRewardResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	local msgInfo = tostring(msgDetail)
	cclog(msgInfo)

	g_Hero:delRewardInfo(msgDetail.gain_reward_id)

	if g_WndMgr:getWnd("Game_Assistant") then
		g_WndMgr:getWnd("Game_Assistant"):updateList(2)
	end
end

local function requestMessageNotify(tbMsg)
	cclog("---------requestMessageNotify-------------")
	local msgDetail = zone_pb.MessageNotify()
	msgDetail:ParseFromString(tbMsg.buffer)
	local msgInfo = tostring(msgDetail)
	cclog(msgInfo)

	cclog("server date:"..msgDetail.notify_message)
end

local function requestSyncServerTimeNotify(tbMsg)
	cclog("---------requestSyncServerTimeNotify-------------")
	local msgDetail = zone_pb.SyncServerTimeNotify()
	msgDetail:ParseFromString(tbMsg.buffer)
	local msgInfo = tostring(msgDetail)
	cclog(msgInfo)

	g_SetServerTime(msgDetail.server_time)

	cclog("server time:"..msgDetail.server_time)
	cclog("year:"..g_GetServerYear().."month:"..g_GetServerMonth().."day:"..g_GetServerDay())
	cclog("hour:"..g_GetServerHour().."min:"..g_GetServerMin().."secs:"..g_GetServerSecs())
end

--渡劫成功响应
local function requestDujieCardResponse(tbMsg)
	cclog("---------requestDujieCardResponse-------------")
	local msgDetail = zone_pb.DujieCardResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	local msgInfo = tostring(msgDetail)
	cclog(msgInfo)
	TbBattleReport.tbDujie = msgDetail
	
	-- g_ErrorMsg:RelieveMsg(msgid_pb.MSGID_DUJIE_CARD_REQUEST)

	DU_JIE_S = true
	g_MsgNetWorkWarning:closeNetWorkWarning()
end
------------------------------------------------------------------------------------------------------------------
local function  requestRelationGetRoleInfoResponse(tbMsg)
	cclog("==========requestRelationGetRoleInfoResponse-------------")
	local msgDetail = zone_pb.RelationGetRoleInfoResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))
	g_SocialMsg:RelationGetRoleInfoResponse(msgDetail.role_info)

	g_ErrorMsg:RelieveListenMsg(msgid_pb.MSGID_RELATION_GET_ROLEINFO_REQUEST ,msgid_pb.MSGID_RELATION_GET_ROLEINFO_RESPONSE)
end

local function  requestRelationSetRoleInfoResponse(tbMsg)
	cclog("---------requestRelationSetRoleInfoResponse-------------")
	local msgDetail = zone_pb.RelationSetRoleInfoResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))

	g_SocialMsg:RelationSetRoleInfoResponse(msgDetail.role_info)
end

local function  requestRelationAddFriendResponse(tbMsg)
	cclog("---------requestRelationAddFriendResponse-------------")
	local msgDetail = zone_pb.RelationAddFriendResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))

	g_SocialMsg:RelationAddFriendResponse(msgDetail)
end

local function  requestRelationDealAddFriendResponse(tbMsg)
	cclog("---------requestRelationDealAddFriendResponse-------------")
	local msgDetail = zone_pb.RelationDealAddFriendResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))
	g_SocialMsg:RelationDealAddFriendResponse(msgDetail)
end

local function  requestRelationRmFriendResponse(tbMsg)
	cclog("---------requestRelationRmFriendResponse-------------")
	local msgDetail = zone_pb.RelationRmFriendResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))

	g_SocialMsg:RelationRmFriendResponse(msgDetail)
	wnd = g_WndMgr:getWnd("Game_ViewPlayer")
	if wnd then wnd:RelationRmFriend() end
end

local function  requestRelationGetFriendListResponse(tbMsg)
	cclog("---------requestRelationGetFriendListResponse-------------")
	local msgDetail = zone_pb.RelationGetFriendListResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))
	g_SocialMsg:RelationGetFriendListResponse(msgDetail)
end

local function requestRelationGetNearByListResponse(tbMsg)
	cclog("---------requestRelationGetNearByListResponse-------------")
	local msgDetail = zone_pb.RelationGetNearByListResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))
	g_SocialMsg:RelationGetNearByListResponse(msgDetail)
end

local function  requestRelationSendMsgResponse(tbMsg)
	cclog("---------requestRelationSendMsgResponse-------------")
	local msgDetail = zone_pb.RelationSendMsgResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))
	g_SocialMsg:RelationSendMsgResponse(msgDetail)
end

local function requestRelationLoginResponse(tbMsg)
	cclog("---------requestRelationLoginResponse-------------")
	local msgDetail = zone_pb.RelationLoginResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))
	g_Hero.bubbleNotify = g_Hero.bubbleNotify or {}
	g_Hero.bubbleNotify.social = msgDetail.num
end

local function requestRelationRecvMsg(tbMsg)
	cclog("---------requestRelationRecvMsg-------------")
	local msgDetail = zone_pb.RelationRecvMsg()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))

	g_SocialMsg:RelationRecvMsg(msgDetail,true)
end

local function requestRelationGetOfflineMsg(tbMsg)
	cclog("----111-----RelationGetOfflineMsgResponse-------1111111------")
	local msgDetail = zone_pb.RelationGetOfflineMsgResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))
	g_SocialMsg:RelationGetOfflineMsg(msgDetail)

	g_ErrorMsg:RelieveListenMsg(msgid_pb.MSGID_RELATION_GET_OFFLINE_MSG_REQUEST, msgid_pb.MSGID_RELATION_GET_OFFLINE_MSG_RESPONSE)
end

local function requestOperatorFateResponse(tbMsg)
	cclog("---------requestOperatorFateResponse-------------")
	local msgDetail = zone_pb.OperatorFateFromCardResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	local msgInfo = tostring(msgDetail)
	cclog(msgInfo)

	local GameObj_Card = g_Hero:getCardObjByServID(msgDetail.cardid)
	local GameObj_Fate = g_Hero:getFateInfoByID(msgDetail.fate_id)
	if msgDetail.operator_type == 1 then
		GameObj_Fate:equipToOwner(GameObj_Card, msgDetail.fate_index + 1)
		g_Hero:FreshUnDressFate()
	elseif msgDetail.operator_type == 2 then
		GameObj_Fate:equipFromOwner(GameObj_Card, msgDetail.fate_index + 1)
		g_Hero:FreshUnDressFate()
	elseif msgDetail.operator_type == 3 then
		GameObj_Fate:equipToOwner(GameObj_Card, msgDetail.fate_index + 1)
		g_Hero:FreshUnDressFate()
	end
	
	local wndInstance = g_WndMgr:getWnd("Game_CardFate1")
	if wndInstance then
		wndInstance:refreshWnd(true)
	end

    g_Hero:showTeamStrengthGrowAnimation()
end

local function requestUpgardeFateResponse(tbMsg)
	cclog("---------requestUpgardeFateResponse-------------")
	local msgDetail = zone_pb.UpgradeFateResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	local msgInfo = tostring(msgDetail)
	cclog(msgInfo)
	local tbFateInfo = g_Hero:getFateInfoByID(msgDetail.upgrade_fate_id)
	tbFateInfo:setFateLevelAndExp(msgDetail.upgrade_fate_starlv, msgDetail.upgrade_fate_exp)
	tbFateInfo:updateOwnerCardProps()
	if msgDetail.cost_fate_idlst then
		for i=1, #msgDetail.cost_fate_idlst do
			g_Hero:DelFate(msgDetail.cost_fate_idlst[i])
		end
		g_Hero:FreshUnDressFate()
	end

	local wndInstance = g_WndMgr:getWnd("Game_CardFate1")
	if wndInstance then
		wndInstance:refreshWnd(nil, msgDetail.upgrade_fate_id)
	end
	
	if tbFateInfo:checkOwnerIsInBattle() then
		g_Hero:showTeamStrengthGrowAnimation()
	end
end

local function requestShopSellResponse(tbMsg)
	cclog("---------requestShopSellResponse-------------")
	local msgDetail = zone_pb.ShopSellResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))
	g_Hero:BagSell(msgDetail)
	
	local nAddValue = 0
	if msgDetail.type == macro_pb.ITEM_TYPE_CARD_GOD then -- 出售的是魂魄，得到的是将魂
		nAddValue = msgDetail.value - g_Hero:getJiangHunShi()
	else
		nAddValue = msgDetail.value - g_Hero:getCoins()
	end
	
	if msgDetail.num_left <= 0 then
		if g_WndMgr:getWnd("Game_Package1") then
			local nIndex = g_WndMgr:getWnd("Game_Package1").CheckBoxGroup_Package:getCheckIndex()
			g_WndMgr:getWnd("Game_Package1").CheckBoxGroup_Package:Click(nIndex)
			g_WndMgr:getWnd("Game_Package1"):updateItemDetailNum(msgDetail.num_left)
		end
	else
		if g_WndMgr:getWnd("Game_Package1") then
			g_WndMgr:getWnd("Game_Package1"):updateItemDetailNum(msgDetail.num_left)
		end
	end
	
	if msgDetail.type == macro_pb.ITEM_TYPE_CARD_GOD then -- 出售的是魂魄，得到的是将魂
		g_Hero:setJiangHunShi(msgDetail.value)
		g_ShowRewardMsgConfrim(macro_pb.ITEM_TYPE_SECRET_JIANGHUN, nAddValue)
	else
		g_Hero:setCoins(msgDetail.value)
		g_ShowRewardMsgConfrim(macro_pb.ITEM_TYPE_GOLDS, nAddValue)
	end
	
end

local function requestArenaInfoNotifyResponse(tbMsg)
    g_MsgNetWorkWarning:closeNetWorkWarning()
	cclog("---------requestArenaInfoNotifyResponse-------------")
	local msgDetail = zone_pb.ArenainfoNotify()
	msgDetail:ParseFromString(tbMsg.buffer)
	local msgInfo = tostring(msgDetail)
	cclog(msgInfo)

    if msgDetail:HasField("update_prestige") then
		g_Hero:setPrestige(msgDetail.update_prestige)
	end

    if msgDetail:HasField("arena_info") then
        g_Hero:setRank(msgDetail.arena_info.self_rank)
	end
	onRecvArenaData(msgDetail)
    --不在战斗中
    if TbBattleReport == nil then
        g_WndMgr:openWnd("Game_Arena")

    end
end

local function refreshRankListResponse(tbMsg)
	cclog("---------refreshRankListResponseResponse-------------")
	local msgDetail = zone_pb.ArenaChallengRankNotify()
	msgDetail:ParseFromString(tbMsg.buffer)
	local msgInfo = tostring(msgDetail)
	cclog(msgInfo)
	onRecvArenaData(msgDetail)
end

local function ArenaRoleUpdateNotify(tbMsg)
	cclog("---------ArenaRoleUpdateNotify-------------")
	local msgDetail = zone_pb.ArenaUpdateNotify()
	msgDetail:ParseFromString(tbMsg.buffer)
	local msgInfo = tostring(msgDetail)
	cclog(msgInfo)
	onRecvArenaData(msgDetail)
end

local function ArenaRankListResponse(tbMsg)
    g_MsgNetWorkWarning:closeNetWorkWarning()

	cclog("---------ArenaRankListResponse-------------")
	local msgDetail = zone_pb.ArenaRankListResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	local msgInfo = tostring(msgDetail)
	-- cclog(msgInfo)
	UpdateArenaNotifyData(msgDetail)

	if g_WndMgr:getWnd("Game_ArenaRank") and g_WndMgr:isVisible("Game_ArenaRank") then
		g_WndMgr:getWnd("Game_ArenaRank"):openWnd()
	elseif g_WndMgr:getWnd("Game_Arena") and g_WndMgr:isVisible("Game_Arena") then
		g_WndMgr:showWnd("Game_ArenaRank")
	end
end

local function requestArenaChallengeResponse(tbMsg)
	cclog("---------requestArenaChallengeResponse----111---------")
	local msgDetail = zone_pb.ArenaChallengeResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	local msgInfo = tostring(msgDetail)
	cclog(msgInfo)
	onRecvArenaData(msgDetail, "challenge_rsp")
end

local function requestBuyChallengeTimesResponse(tbMsg)
	cclog("---------requestBuyChallengeTimesResponse-------------")
	local msgDetail = zone_pb.BuyChallengeTimesResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	local msgInfo = tostring(msgDetail)
	cclog(msgInfo)
	BuyChallengeTimesResponse(msgDetail)
	
	--购买挑战次数 付费点

end

local function requestBuyShopItemResponse(tbMsg)
	cclog("---------requestBuyShopItemResponse-------------")
	local msgDetail = zone_pb.BuyShopItemResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	local msgInfo = tostring(msgDetail)
	cclog(msgInfo)
	BuyShopItemResponse(msgDetail)
end

local function requestUpgardeOfficialRankResponse(tbMsg)
	cclog("---------requestUpgardeOfficialRankResponse-------------")
	local msgDetail = zone_pb.UpgradeOfficialRankResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	local msgInfo = tostring(msgDetail)
	cclog(msgInfo)
	UpgardeOfficialRankResponse(msgDetail)
end

local function requestGainPrestigeResponse(tbMsg)
	cclog("---------requestUpgardeOfficialRankResponse-------------")
	local msgDetail = zone_pb.GainPrestigeResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	local msgInfo = tostring(msgDetail)
	cclog(msgInfo)
    GainPrestigeResponse(msgDetail)
end

local function requestBuyEnergyResponse(tbMsg)
	cclog("---------requestBuyEnergyResponse-------------")
	local msgDetail = zone_pb.BuyEnergyResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	local msgInfo = tostring(msgDetail)
	cclog(msgInfo)
	
    local needCoupons = g_VIPBase:getVipLevelCntGold(VipType.VipBuyOpType_BuyEnergy)
    --购买体力 付费点
	gTalkingData:onPurchase(TDPurchase_Type.TDP_BuyPower, 1, needCoupons)

	local function update()
		g_HeadBar:refreshHeadBar()
		
		local nMaxBuyTimes = g_VIPBase:getVipValue("BuyMaxNum")
		local nBuyTimes = g_Hero:getBuyEnergyTimes()
		local nRemainTimes = nMaxBuyTimes - nBuyTimes
		g_ShowSysTips({text=string.format(_T("成功购买1次体力,您还可购买%d次"), nRemainTimes)})
	end
	g_Hero:setYuanBao(msgDetail.updated_coupons)
	
	g_ShowRewardMsgConfrim(macro_pb.ITEM_TYPE_MASTER_ENERGY, g_Hero:getMaxEnergy(), update)

	g_MsgMgr:ignoreCheckWaitTime(nil)
	
	--这样是以前加了的 没有去修改它
	g_Hero:setBuyEnergyTimes(msgDetail.buy_times)
	--vip记录 买体力次数
	g_VIPBase:setAddTableByNum(VipType.VipBuyOpType_BuyEnergy, msgDetail.buy_times)
end

local function requestViewPlayerResponse(tbMsg)
	cclog("---------requestViewPlayerResponse-------------")
	local msgDetail = zone_pb.ViewPlayerResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))
	onViewPlayer(msgDetail)
end

local function requestViewPlayerDetailResponse(tbMsg)
	cclog("---------requestViewPlayerDetailResponse-------------")
	local msgDetail = zone_pb.ViewPlayerDetailResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail).."其他人信息")

    --[[optional uint32 phy_attack = 13; // 武力攻击
	optional uint32 phy_defence = 14; // 武力防御
	optional uint32 mag_attack = 15; // 法术攻击
	optional uint32 mag_defence = 16; // 法术防御
	optional uint32 skill_attack = 17; // 绝技攻击
	optional uint32 skill_defence = 18; // 绝技防御
	optional uint32 critical_chance = 19; // 暴击(几率)
	optional uint32 critical_resistance = 20; // 韧性(几率)
	optional uint32 critical_strike = 21; // 必杀(几率)
	optional uint32 critical_strikeresistance = 22; // 刚毅(几率)
	optional uint32 hit_change = 23; // 命中(几率)
	optional uint32 dodge_chance = 24; // 闪避(几率)
	optional uint32 penetrate_chance = 25; // 穿透(几率)
	optional uint32 block_chance = 26; // 格挡(几率)
	optional uint32 damage_reduction = 27; // 伤害减免(百分比)
	optional bool is_def = 28; //是否防守方

    msgDetail.team_info.battle_info]]

    --cclog(tostring(msgDetail.team_info.battle_info.phy_defence))

	g_WndMgr:openWnd("Game_ViewPlayer", {msgDetail,  false})
end



-- local function requestBuyExtraSpaceResponse(tbMsg)
	-- cclog("---------requestBuyExtraSpaceResponse-------------")
	-- local msgDetail = zone_pb.BuyExtraSpaceResponse()
	-- msgDetail:ParseFromString(tbMsg.buffer)
	-- cclog(tostring(msgDetail))
	-- g_Hero:buyExtraSpace(msgDetail)

	-- local t = msgDetail.type
	-- if t==macro_pb.ITEM_TYPE_CARD then
	-- elseif t==macro_pb.ITEM_TYPE_EQUIP then
	-- elseif t==macro_pb.ITEM_TYPE_FATE then
	-- end
-- end

local function requestHandbookrecResponse(tbMsg)
	cclog("---------requestHandbookrecResponse-------------")
	local msgDetail = zone_pb.HandbookrecNotify()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))
	Handbookrec(msgDetail)
end

--该消息需要看下
local function requestClearItemResponse(tbMsg)
	cclog("---------requestClearItemResponse-------------")
	local msgDetail = zone_pb.ClearItemNotify()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))
	g_Hero:ClearItem(msgDetail)
end

local function relationCheckNameResponse(tbMsg)
	cclog("---------RelationCheckNameResponse-------------")
	local msgDetail = zone_pb.RelationCheckNameResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))
	g_SocialMsg:addCheckNameWnd(msgDetail)
end

local function requestAccountRegResponse(tbMsg)
	cclog("---------requestAccountRegResponse-------------")
	local msgDetail = account_pb.AccountRegResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))

	g_IsExistedActor = 0
	
	setUserRegData()
	onPressed_Button_Close()
    AccountRegResponse()
	
	g_MsgMgr:ResetGameUID()
    g_MsgMgr:setUserID(msgDetail.uin)

    --注册账号成功
    g_FormMsgSystem:PostFormMsg(FormMsg_ClientNet_AccountRegistSuccond, nil)
    g_FormMsgSystem:PostFormMsg(FormMsg_ClientNet_AccountSuccond, nil)
end

local function requestAccountLoginResponse(tbMsg)
	cclog("---------requestAccountLoginResponse-------------")
	local msgDetail = account_pb.AccountLoginResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))

	g_GamePlatformSystem:SetPlatformAccountInfo(msgDetail.uin)
	g_FormMsgSystem:PostFormMsg(FormMsg_ClientNet_AccountSuccond, nil)
end

--新手引导
local function requestNewPlayerGuidRespone(tbMsg)
	cclog("---------requestNewPlayerGuidRespone-------------")
	local msg = zone_pb.UpdateNewBieGuideResponse(tbMsg)
	msg:ParseFromString(tbMsg.buffer)
	cclog(tostring(msg))

	g_Hero:setNewPlayerGuideData(msg)

	g_ErrorMsg:RelieveListenMsg(msgid_pb.MSGID_UPDATE_NEWBIE_GUIDE_REQUEST, msgid_pb.MSGID_UPDATE_NEWBIE_GUIDE_RESPONSE)
end

local function requestReportIssueResponse(tbMsg)
	cclog("---------requestReportIssueResponse-------------")
	if g_WndMgr:getWnd("Game_System1") then
		g_WndMgr:getWnd("Game_System1"):updataBugWnd()
	end
end

--成就 小助手
local function requestAchievementRefreshResponse(tbMsg)
	cclog("---------requestAchievementRefreshResponse-------------")
	local msg = zone_pb.AchievementRefreshResponse(tbMsg)
	msg:ParseFromString(tbMsg.buffer)
	cclog(tostring(msg))
end
--[[
	
]]
local function achievementCompleteResponse(tbMsg)
	cclog("---------achievementCompleteResponse-------------")
	local msg = zone_pb.AchievementCompleteResponse(tbMsg)
	msg:ParseFromString(tbMsg.buffer)
	cclog(tostring(msg))
	local id = msg.info.id
	local key1 = math.floor(id/100)
	local key2 = id%100
	local CSV_ActivityChengJiu = g_DataMgr:getCsvConfigByTwoKey("ActivityChengJiu", key1, key2)
	local str = "成就『"..CSV_ActivityChengJiu.AffairsName.."』已达成！"
	cclog(str)
	if not g_Hero:achievementComplete(msg) then return end
	local wnd = g_WndMgr:getWnd("Game_Assistant")
	if wnd then setAchievementData() end
end

local function achievementGetRewardResponse(tbMsg)
	cclog("---------achievementGetRewardResponse-------------")
	local msg = zone_pb.AchievementGetRewardResponse(tbMsg)
	msg:ParseFromString(tbMsg.buffer)
	cclog(tostring(msg))
	g_Hero:achievementGetReward(msg)
	
	local wnd = g_WndMgr:getWnd("Game_Assistant")
	if wnd then setAchievementData() end
end

local function achievementOnEvent(tbMsg)
	cclog("-------achievementOnEvent--------------")
	local msg = zone_pb.AchievementOnEvent(tbMsg)
	msg:ParseFromString(tbMsg.buffer)
	cclog(tostring(msg))
	g_Hero:achievementOnEvent(msg)

	setAchievementData()	
end

local function requestDailyDataResponse(tbMsg)
	cclog("-------requestDailyDataResponse-------------")
	local msg = zone_pb.DailyDataNotify(tbMsg)
	msg:ParseFromString(tbMsg.buffer)
	cclog(tostring(msg))
	g_Hero:updateDailyNotice(msg.daily_data_list)
	local nLen = #msg.daily_data_list

	if nLen == 1 then
		local nType = nil
		local nNum = 0
		for k,v in ipairs(msg.daily_data_list) do
			nType = v.type
			nNum = v.daily_data
			break
		end
		if nType and nType >= macro_pb.Buy_Shop_Use_Prestige1 and nType <= macro_pb.Buy_Shop_Use_Prestige12 then
			freshShopItem()
		end
		if nType and g_WndMgr:getWnd("Game_ActivityFuLuDaoSub") and nType >= macro_pb.Activity_Money and  nType <= macro_pb.Activity_Exp then
			g_WndMgr:getWnd("Game_ActivityFuLuDaoSub"):setShiLianLabel(nNum)
		end
		if nType and g_WndMgr:getWnd("Game_ActivityFuLuDaoSub") and nType >= macro_pb.Activity_Tribute and  nType <= macro_pb.Activity_Knowledge then
			g_WndMgr:getWnd("Game_ActivityFuLuDaoSub"):setShiLianLabel(nNum)
		end
		if nType and g_WndMgr:getWnd("Game_ZhaoCaiFu") and nType == macro_pb.Activity_ZhaoCai then
			--g_WndMgr:openWnd("Game_ZhaoCaiFu")
			if g_PlayerGuide:checkCurrentGuideSequenceNode("ServerResponse", "Game_ZhaoCaiFu") then
				g_PlayerGuide:showCurrentGuideSequenceNode()
			end
		end
	end
end

local function refreshNotifyInfo(tbMsg)
	cclog("-------refreshNotifyInfo--------------")
	local msg = zone_pb.RefreshNotifyInfo(tbMsg)
	msg:ParseFromString(tbMsg.buffer)
	cclog(tostring(msg))
	g_Hero:setNotifyInfo(msg.notify_info)
	if g_WndMgr:getWnd("Game_Home") then
		g_WndMgr:getWnd("Game_Home"):refreshHomeBubbleNotify()
	end
end

local function enterBattleScene(tbMsg)
	cclog("-------enterBattleScene--------------")
	local tbServerMsg = zone_pb.BattleScenceNotify(tbMsg)
	tbServerMsg:ParseFromString(tbMsg.buffer)
	cclog(tostring(tbServerMsg))
	
	cclog("战斗流程Step1====初始化g_BattleMgr里面数据然后在初始化完成回调里面预加载资源")
	local function initBattleEndCall(tbBattleScenceInfo)
		cclog("战斗流程Step2====初始化g_BattleMgr初始化完成回调里执行预加载initBattleEndCall")
        proLoadBattleRersouce(tbBattleScenceInfo, tbServerMsg)
	end
	g_BattleMgr:initBattle(tbServerMsg, initBattleEndCall)

	gTalkingData:onBegin(tbServerMsg.mapid)
	
	g_MsgNetWorkWarning:closeNetWorkWarning()

	g_BattleDamage:setBattleResultDate(tbServerMsg)

	g_ErrorMsg:RelieveListenMsg(msgid_pb.MSGID_ATTACK_SMALLPASS_REQUEST, msgid_pb.MSGID_BATTLESCENE_NOTIFY)
end

local function BattleResult(tbMsg)
	cclog("-------BattleResult--------------")
	local msg = zone_pb.BattleResultNotify(tbMsg)
	msg:ParseFromString(tbMsg.buffer)
	cclog(tostring(msg))
	
	if g_PlayerGuide:checkCurrentGuideSequenceNode("ServerResponse", "Game_Battle") then
		g_PlayerGuide:showCurrentGuideSequenceNode()
	end
	
	--为了防止战斗胜利界面出不来，连续向服务端发两次保存
	if g_PlayerGuide:checkCurrentGuideSequenceNode("ServerResponse", "Game_Battle") then
		g_PlayerGuide:showCurrentGuideSequenceNode()
	end
	
	g_BattleMgr:recvBattleResult(msg)

	g_ErrorMsg:RelieveListenMsg(msgid_pb.MSGID_BATTLE_RESULT_REQUEST, msgid_pb.MSGID_BATTLE_RESULT_NOTIFY)

	g_MsgNetWorkWarning:closeNetWorkWarning()
end


local function MailBoxNotifyResponse(tbMsg)
	cclog("-------MailBoxNotifyResponse--------------")
	local msg = zone_pb.MailBoxListNotify(tbMsg)
	msg:ParseFromString(tbMsg.buffer)
    cclog(tostring(msg))
	MailResponse(msg)
end

local function ArrayHeartUpgradeResponse(tbMsg)
	cclog("-------ArrayHeartUpgradeResponse--------------")
	local msg = zone_pb.ArrayHeartUpgradeResponse(tbMsg)
	msg:ParseFromString(tbMsg.buffer)
	cclog(tostring(msg))
	g_Hero:setKnowledge(msg.updated_knowdge)
	
	local  nZhanShuCsvID = msg.arrayidx + 1
	local  nZhenXinIndex = msg.heartidx + 1
	
	g_Hero:setZhanShuZhenXinLev(nZhanShuCsvID, nZhenXinIndex, msg.heartlv)
	
	if g_WndMgr:getWnd("Game_ZhenXin") then
		g_WndMgr:getWnd("Game_ZhenXin"):updateZhenXinWnd(nZhanShuCsvID, nZhenXinIndex)
	end

    g_Hero:updateZhenXinProp(nZhanShuCsvID)
end

local function UseItemResponse(tbMsg)
	cclog("-------UseItemResponse--------------")
	local msg = zone_pb.UseItemResponse(tbMsg)
	msg:ParseFromString(tbMsg.buffer)
	cclog(tostring(msg))
	if msg.object_info then
		for i = 1,#msg.object_info do
			local id = msg.object_info[i]["object_id"]
			local lev = msg.object_info[i]["object_data1"]
			local exps = msg.object_info[i]["object_data2"]

			local tbCard = g_Hero:getCardObjByServID(id)
			tbCard:setLevel(lev)
			tbCard:setExp(exps)
		end
	end
	g_Hero:setItemNum(msg.item_id, msg.leave_num)
	if msg.leave_num <= 0 then
		if g_WndMgr:getWnd("Game_Package1") then
			g_WndMgr:getWnd("Game_Package1").CheckBoxGroup_Package:Click(2)
			g_WndMgr:getWnd("Game_Package1"):updateItemDetailNum(msg.leave_num)
		end
	else
		if g_WndMgr:getWnd("Game_Package1") then
			g_WndMgr:getWnd("Game_Package1"):updateItemDetailNum(msg.leave_num)
		end
	end
	
end

local function ChatNotifyResponse(tbMsg)
	cclog("-------ChatNotifyResponse--------------")
	local msg = zone_pb.ChatNotify(tbMsg)
	msg:ParseFromString(tbMsg.buffer)
	cclog(tostring(msg))
	setChatCenterMessage(msg)

	if not g_WndMgr:isVisible("Game_ChatCenter")  then
		cclog("========111111111=======")
		local numChatCenter = g_Hero:getBubbleNotify("ChatCenter")
		numChatCenter = numChatCenter + 1
		if g_WndMgr:getWnd("Game_Home") then
			g_SetBubbleNotify(g_WndMgr:getWnd("Game_Home").Button_ChatCenter, numChatCenter + g_TBSocial.NewChatNumber, 20, 20)
		end
		g_Hero:setBubbleNotify("ChatCenter",numChatCenter)
	end

	local tb_msg = msg.chat_info
	local wnd = g_WndMgr:getWnd("Game_ChatCenter")
	if not wnd then
		return
	end
	if #tb_msg == 1 and g_WndMgr:isVisible("Game_ChatCenter") then
		local v = tb_msg[1]
		if v.channel == 5 or v.channel == 6  or v.channel == 7 or v.channel == 8 then
			wnd.ButtonGroup:Click(5)
		else
			wnd.ButtonGroup:Click(v.channel)
		end
	end
	if wnd.checkWorldChat == true then
		g_WndMgr:openWnd("Game_ChatCenter")
		wnd.checkWorldChat = false
	end
end

local function userLoginResponse(tbMsg)
	cclog("userLoginResponse")
	g_MsgMgr:setAccount(tbMsg)

    g_MsgMgr:setUserID(tbMsg.uin)
    -- g_MsgMgr:requestRole()
end

local function SendHeartResponse(tbMsg)
	cclog("-------SendHeartResponse--------------")
	local msg = zone_pb.SendHeartResponse(tbMsg)
	msg:ParseFromString(tbMsg.buffer)
	cclog(tostring(msg))
	g_Hero:setSendFriendPointsStatus(msg.recv_uin)
	if g_WndMgr:getTopWndName() == "Game_Social1" then
		if g_WndMgr:getWnd("Game_Social1") then
			if g_WndMgr:getWnd("Game_Social1").ckEquip:getCheckIndex() == 1 then
				g_WndMgr:getWnd("Game_Social1"):upDateFriendList()
			end
		end
		g_WndMgr:showWnd("Game_SendLoveAnimation")
	end
end

local function sendHeartNotify(tbMsg)
	cclog("-------sendHeartNotify--------------")
	local msg = zone_pb.SendHeartNotify(tbMsg)
	msg:ParseFromString(tbMsg.buffer)
	cclog(tostring(msg))
	for i,v in ipairs(msg.send_heart_info)do
		g_Hero:setReceiveFriendPointsStatusByUin(v.sender_uin,0)
	end
	if g_WndMgr:getTopWndName() == "Game_Social1" then
		if g_WndMgr:getWnd("Game_Social1") then
			if g_WndMgr:getWnd("Game_Social1").ckEquip:getCheckIndex() == 1 then
				g_WndMgr:getWnd("Game_Social1"):upDateFriendList()
			end
		end
	end

	local HomeWnd = g_WndMgr:getWnd("Game_Home")
	if HomeWnd then
		HomeWnd:addNoticeAnimation_Friend()
	end
end

local function recvHeartResponse(tbMsg)
	cclog("-------recvHeartResponse--------------")
	local msg = zone_pb.RecvHeartResponse(tbMsg)
	msg:ParseFromString(tbMsg.buffer)
	cclog(tostring(msg))
	local curNum = g_Hero:getFriendPoints()
	local getNum = msg.update_heart_num - curNum
	g_Hero:setReceiveFriendPointsStatus(msg.recv_uin)
	if g_WndMgr:getTopWndName() == "Game_Social1" then
		if g_WndMgr:getWnd("Game_Social1") then
			if g_WndMgr:getWnd("Game_Social1").ckEquip:getCheckIndex() == 1 then
				g_WndMgr:getWnd("Game_Social1"):upDateFriendList()
			end
		end
	end
	if getNum <= 0 then
		getNum = 0
	end
	
	g_Hero:setFriendPoints(msg.update_heart_num)
	g_ShowRewardMsgConfrim(macro_pb.ITEM_TYPE_FRIENDHEART, getNum)
end

local function mailRewardResponse(tbMsg)
	cclog("-------mailRewardResponse--------------")
	local msg = zone_pb.MailRewardResponse(tbMsg)
	msg:ParseFromString(tbMsg.buffer)
	cclog(tostring(msg))
	if g_WndMgr:getWnd("Game_MailBox") then
		g_WndMgr:getWnd("Game_MailBox"):ItemRewardResponse(msg.mail_id)
	end
end

local function MailReadResponse(tbMsg)
	cclog("-------MailReadResponse--------------")
	local msg = zone_pb.MailReadResponse(tbMsg)
	msg:ParseFromString(tbMsg.buffer)
	cclog(tostring(msg))
	if g_WndMgr:getWnd("Game_MailBox") then
		g_WndMgr:getWnd("Game_MailBox"):ItemReadResponse(msg.mail_id)
	end
end

local function NoticeNotify(tbMsg)
	cclog("-------NoticeNotify--------------")
	local msg = zone_pb.NoticeNotify(tbMsg)
	msg:ParseFromString(tbMsg.buffer)
	cclog(tostring(msg))
	-- g_NoticeNotify(msg)
end

local function UpgradeStarResponse(tbMsg)
	local tbMsgDetail = zone_pb.UpgradeStarResponse(tbMsg)
	tbMsgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(tbMsgDetail))
	if g_WndMgr:getWnd("Game_Equip1") then
		g_WndMgr:getWnd("Game_Equip1"):showStarUpResponse(tbMsgDetail)
	end
end

function funcArraySelectResponse(tbMsg)
	cclog("===============serverCallArraySelectResponse=================")
	local rootMsg = zone_pb.ArraySelectResponse()
	rootMsg:ParseFromString(tbMsg.buffer)
	local msgInfo = tostring(rootMsg)
	cclog(msgInfo)
	
	local wndInstance = g_WndMgr:getWnd("Game_BattleBuZhen")
	if wndInstance then
		wndInstance:requestSelectZhenFaResponse(rootMsg)
		return
	end
	local wndInstance = g_WndMgr:getWnd("Game_ZhenFaSelect")
	if wndInstance and g_WndMgr:isVisible("Game_ZhenFaSelect") then
		g_WndMgr:getWnd("Game_ZhenFaSelect"):onZhenFaSelectRefresh(rootMsg)
	end
end

local function DelMailResponse(tbMsg)
	cclog("-------DelMailResponse--------------")
	local msg = zone_pb.DelMailResponse(tbMsg)
	msg:ParseFromString(tbMsg.buffer)
	cclog(tostring(msg))
	if g_WndMgr:getWnd("Game_MailBox") then 
		g_WndMgr:getWnd("Game_MailBox"):delMailResponse(msg)
	end
end

--[[
	一键升级技能响应	
]]
local function OnceUpgradeSkillResponse(tbMsg)
	cclog("-------OnceUpgradeSkillResponse--------------")
	local msg = zone_pb.OnceUpgradeSkillResponse(tbMsg)
	msg:ParseFromString(tbMsg.buffer)
	cclog(tostring(msg))
	
	local skill_index = msg.skill_index + 1-- 技能索引
	local upgrade_cardid = msg.upgrade_cardid--升级的卡牌id
	local skill_lv = msg.skill_lv--技能等级
	local leave_money = msg.leave_money-- 剩余的
	local danyao = msg.danyao--变化的丹药
	local cost_material = msg.cost_material--消耗的材料
	
	g_Hero:setCoins(leave_money)
	
	local tbCard = g_Hero:getCardObjByServID(upgrade_cardid)
	if not tbCard then 
		cclog(" g_Hero:getCardObjByServID(upgrade_cardid)取得值是为空")
		return
	end
	tbCard:setSkillLevel(skill_index,skill_lv)
	for i = 1,#danyao do
		local danyao_idx = danyao[i].danyao_idx + 1 --卡牌丹药索引
		local danyao_lv = danyao[i].danyao_lv --卡牌丹药等级
		danyao_idx = danyao_idx % 3
		if danyao_idx == 0 then danyao_idx = 3 end
		-- echoj()
		tbCard:setDanyaoLvList(skill_index, danyao_idx, danyao_lv)
	end
	
	for i = 1,#cost_material do
		local nServerID  = cost_material[i].material_id 	--消耗材料id
		local nRemainNum  = cost_material[i].material_num 	--剩余的材料数量
	
		g_Hero:setItemNum(nServerID,nRemainNum)
	end
	
	local isVisible = g_WndMgr:isVisible("Game_Equip1")
	if isVisible then 
		local instance = g_WndMgr:getWnd("Game_Compose")
		local isVisibleCompose = g_WndMgr:isVisible("Game_Compose")
		if instance and isVisibleCompose then 
			instance:skillUpgrade(upgrade_cardid,skill_index) 
		else
			--可以突破
			local instance = g_WndMgr:getWnd("Game_Equip1")
			if instance then 
				instance:updateFromMsg() 
				instance:upAnimation()
			end
		end
	end

	g_ErrorMsg:RelieveListenMsg(msgid_pb.MSGID_ONCE_LVUP_SKILL_REQUEST, msgid_pb.MSGID_ONCE_LVUP_SKILL_RESPONSE)
end

--材料副本信息响应
local function requestMaterialEctypeResponse(tbMsg)
	cclog("---------材料副本信息响应-------------")
	local msgDetail = zone_pb.MaterialEctypeResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	local msgInfo = tostring(msgDetail)
	cclog("材料副本信息响应"..msgInfo)
	local materialId = msgDetail.material_id--材料id
	local materialStar = msgDetail.material_star --材料星级
	local ectypeList = msgDetail.ectype_list --材料副本开启信息
	
	if g_WndMgr:getWnd("Game_Compose") and g_WndMgr:isVisible("Game_Compose") then 
		g_WndMgr:getWnd("Game_Compose"):ectypeListShow(ectypeList, ITEM_DROP_TYPE.PILL)
	end	

	g_FormMsgSystem:PostFormMsg(FormMsg_ItemDropGuide_Drop,ectypeList)
	
end

--物品合成响应
local function requestComPoseItemResponse(tbMsg)
	cclog("---------物品合成响应-------------")
	local msgDetail = zone_pb.ComPoseItemResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	local msgInfo = tostring(msgDetail)
	cclog(msgInfo)
	g_Hero:setCoins(msgDetail.updated_money)
	for i = 1,#msgDetail.cost_material do
		local detail = msgDetail.cost_material[i]		
		g_Hero:setItemNum(detail.material_id, detail.material_num) --背包里拥有多少材料
	end
	
	local targetCfgId = msgDetail.target_cfg_id 	--目标id
	local targetStarLevel = target_starlv		-- 目标星级
	local targetCurNum = target_cur_num		--目标当前数量
	g_Hero:setItemNum(targetCfgId,targetCurNum) --背包里拥有多少材料
	
	if g_WndMgr:getWnd("Game_ItemDropGuide") and g_WndMgr:isVisible("Game_ItemDropGuide") then 
		g_WndMgr:getWnd("Game_ItemDropGuide"):debrisCompound()
	end
	
	if g_WndMgr:getWnd("Game_Package1") then
		g_WndMgr:getWnd("Game_Package1").CheckBoxGroup_Package:Click(3)
	end
	
end

local function requestComUseItemResponse(tbMsg)
	cclog("---------------使用物品响应--")
	local msg = zone_pb.ComUseItemResponse(tbMsg)
	msg:ParseFromString(tbMsg.buffer)
	cclog(tostring(msg))
	
	local tbItem = msg.item
	for key = 1,#tbItem do 
		local itemId = tbItem[key].item_id-- 使用物品id
		local curNum =  tbItem[key].cur_num-- 使用数量
		g_Hero:setItemNum(itemId,curNum)
	end
	
	
	local wndInstance = g_WndMgr:getWnd("Game_CardLevelUpSingle")
	if wndInstance and wndInstance.CSV_ItemBase_ then
		local nNewLevel = wndInstance.tbCardInfo:getNewLvByAddExp(wndInstance.CSV_ItemBase_.AddValue) --提升后的等级
		local nNewExp = wndInstance.tbCardInfo:getExp() + wndInstance.CSV_ItemBase_.AddValue
		wndInstance.tbCardInfo:setLevel(nNewLevel)
		wndInstance.tbCardInfo:setExp(nNewExp)
	end
		
	local equip = g_WndMgr:getWnd("Game_Equip1")
	local tbObj = msg.obj
	for i =1,#tbObj do
		local id = tbObj[i].object_id			--使用对象id
		local level = tbObj[i].object_data1		--使用对象数据1	(卡牌等级)
		local exps = tbObj[i].object_data2		--使用对象数据2  (卡牌经验) 
		local tbCard = g_Hero:getCardObjByServID(id)
		tbCard:setLevel(level)
		tbCard:setExp(exps)
		
		if equip then 
			equip.tbEquip1.Label_Level_:setText(string.format(_T("Lv.%d"),level))
			local nExpPrecent = equip.tbEquip1.nExpPrecent
			equip.tbEquip1.ProgressBar_CardExp_:setPercent(nExpPrecent)	
			equip.tbEquip1.Label_CardExpPercent_:setText(nExpPrecent.."%")
		end
		
	end

	g_ErrorMsg:RelieveListenMsg(msgid_pb.MSGID_COM_USE_ITEM_REQUEST, msgid_pb.MSGID_COM_USE_ITEM_RESPONSE)
end


local function requestEveryDayResponse()
	
	cclog("=====================零点相关数据重置=====================")
	--vip 相关数据重置
	for key,value in pairs(VipType) do 
		--不包括 普通副本 和 精英副本 八仙过海护送刷新价格 神龙改运价格
		if value == VipType.VipBuyOpType_RefreshNpcCost or 
			value == VipType.VipBuyOpType_DragonChangeCost then 
		else
			g_VIPBase:setAddTableByNum(value,0)
		end
	end
	
	
	--普通副本 
	local nFinalClearMapID = g_Hero:getFinalClearMapID()
	local tbEctype = g_DataMgr:getEctypeListByMapBaseID(nFinalClearMapID) or {}
	for i = 1,#tbEctype do 
		local CSV_MapEctype = g_DataMgr:getMapEctypeCsv(tbEctype[i])
		g_VIPBase:setCommonEncryptByNum(CSV_MapEctype.EctypeID,0)
	end
	
	--精英副本
	local mapBattleJgingYing = g_DataMgr:getCsvConfig("MapEctypeJingYing")
	for key,value in ipairs(mapBattleJgingYing) do
		for j,v in ipairs(value) do 
			g_VIPBase:setJYEncryptByNum(key,j,0)
		end
	end
	
	--觉醒 消除技能次数重置 按VIp 表的数据重置
	for i = 1,7 do
		local CSV_PlayerXianMaiSkill = g_DataMgr:getCsvConfigByOneKey("PlayerXianMaiSkill",i)
		local num = CSV_PlayerXianMaiSkill.FreeTimes * g_VIPBase:getVipValue("FreeTimes")
		g_XianMaiInfoData:setTbXianmaiSkillNum(i,num)
	end

	--小助手奖励重置	
	cclog("小助手奖励礼包重置 activeness 为0,nCurRewardLv 为0")
	g_Hero.activenessInfo = { activeness = 0, nCurRewardLv = 1 }
	
	--小助手事项重置
	cclog("小助手事项重置========")
	g_Hero:resetAssitantInfo()
	
	--经验树 种植次数 清零
	g_FarmData:setExpTimesZero(0)
	
	--重新打开界面 tbWndJson 在 Class_WndMgr
	for key,value in pairs(tbWndJson) do
		if g_WndMgr:getWnd(key) and g_WndMgr:isVisible(key) then
			g_WndMgr:getWnd(key):openWnd()
		end
	end

	--关闭界面
	if g_WndMgr:isVisible("Game_DragonPray") then
		g_WndMgr:closeWnd("Game_DragonPray")
	end

	--爱心重置
	g_Hero.tbSendFriendPointsStatus = {}

	--签到重置
	g_Hero.SignDateStatus = 1

	--七天登录刷新
	g_act:refreshContinueDay()

	--副本，精英副本次数重置
	g_EctypeJY:refreshAttackNum()
	g_EctypeListSystem:refreshAttackNum()
	
	--重置帮派建造时间
	for i = 1, #g_Guild:getAllBuildTimeatList() do 
		g_Guild:setBuildTimeatList(i,0)
	end
	
	--月卡重置
	resetYueKaInfo()

    --八仙过海打劫次数和护送次数
    g_BaXianGuoHaiSystem:ZeroOClockUpdate()
	
	--神仙试炼零点重置
	g_Hero:setDailyNoticeByType(macro_pb.Activity_AMBoss, 0)
	
	--帮派神仙试炼零点重置
	g_Hero:setDailyNoticeByType(macro_pb.DT_GUILD_WORLD_BOSS, 0)
end

--服务器事件通知
local function serverEventResponse(tbMsg)
	cclog("-----serverEventResponse--")
	local msg = zone_pb.ServerEventNotify(tbMsg)
	msg:ParseFromString(tbMsg.buffer)
	cclog(tostring(msg))

	if macro_pb.ServerEventType_SCENE_BOSS_OPEN == msg.type then
		g_Hero:setBubbleNotify(macro_pb.NT_SceneBoss, 1)
	elseif macro_pb.ServerEventType_SCENE_BOSS_DEAD == msg.type or macro_pb.ServerEventType_SCENE_BOSS_TIME_OUT == msg.type then
		g_Hero:setBubbleNotify(macro_pb.NT_SceneBoss, 0)
	elseif macro_pb.ServerEventType_GUILD_SCENE_BOSS_OPEN == msg.type then
		g_Hero:setBubbleNotify(macro_pb.NT_GuildSceneBoss, 1)
	elseif macro_pb.ServerEventType_GUILD_SCENE_BOSS_DEAD == msg.type or macro_pb.ServerEventType_GUILD_SCENE_BOSS_TIME_OUT == msg.type then
		g_Hero:setBubbleNotify(macro_pb.NT_GuildSceneBoss, 0)
	elseif macro_pb.ServerEventType_WORLD_BOSS_DEAD == msg.type then
		g_Hero:setBubbleNotify(macro_pb.NT_WorldBoss, 0)
	elseif macro_pb.ServerEventType_GUILD_WORLD_BOSS_DEAD == msg.type then
		g_Hero:setBubbleNotify(macro_pb.NT_GuildWorldBoss, 0)
	end
end

--通用角色属性变化通知
local function propertyResponse(tbMsg)
	cclog("-----serverEventResponse--")
	local msg = zone_pb.PropertyUpdateNotify(tbMsg)
	msg:ParseFromString(tbMsg.buffer)
	cclog(tostring(msg))

	local update_list = msg.update_list
	for k, v in pairs(update_list) do
		if macro_pb.ITEM_TYPE_COUPONS == v.type then
			local nYuanBao = g_Hero:getYuanBao()
			local nChangeValue = nYuanBao - v.num
			if nChangeValue > 0 then
				gTalkingData:onPurchase(TDPurchase_Type.TDP_ARENA_Universal_Interface, 1, nChangeValue)
			end
			g_Hero:setYuanBao(v.num)
		elseif macro_pb.ITEM_TYPE_MASTER_ENERGY == v.type then 
			g_Hero:setCurEnergy(v.num)
        elseif macro_pb.ITEM_TYPE_TOTAL_COST == v.type then 
			g_Hero:setTotalCostYuanBao(v.num)
        elseif macro_pb.ITEM_TYPE_TOTAL_COST_JR == v.type then 
			g_Hero:setTotalCostYuanBaoJR(v.num)
        elseif macro_pb.ITEM_TYPE_TOTAL_CHARGE_JR == v.type then
            g_Hero:setTotalChargeYuanBoaJR(v.num)
        elseif macro_pb.ITEM_TYPE_TOTAL_SUMMON_JR == v.type then
            g_Hero:setTotalSummonJR(v.num)
        elseif macro_pb.ITEM_TYPE_TOTAL_SUMMON == v.type then
            g_Hero:setTotalSummon(v.num)
        elseif macro_pb.ITEM_TYPE_START_SERVER_DAY == v.type then
            g_Hero:setTotalSysDays(v.num)
        elseif macro_pb.ITEM_TYPE_GOLDS == v.type then --铜钱
            g_Hero:setCoins(v.num)
        elseif macro_pb.ITEM_TYPE_PRESTIGE == v.type then --声望
            g_Hero:setPrestige(v.num)
        elseif macro_pb.ITEM_TYPE_FRIENDHEART == v.type then --友情之心
            g_Hero:setFriendPoints(v.num)
        elseif macro_pb.ITEM_TYPE_SECRET_JIANGHUN == v.type then  --将魂石
            g_Hero:setJiangHunShi(v.num) 
		end
	end

end

local function RespondKickAccount()
	
	local function onClickConfirm()
		-- g_FormMsgSystem:SendFormMsg(FormMsg_ClientNet_LogOut, nil)
		g_GamePlatformSystem:OnClickGameLoginOut()
	 end--直接返回登陆界面

	local function onClickCancel()
		g_GamePlatformSystem:OnClickGameLoginOut()
	end

	g_ClientMsgTips:showConfirm(_T("你的帐号已被GM踢下线, 是否重新登入"), onClickConfirm, onClickCancel)
end

--带参数tip
local function NotifyTipsToRole(tbMsg)
	cclog("-----NotifyTipsToRole--")
	local msg = zone_pb.NotifyTipsToRole(tbMsg)
	msg:ParseFromString(tbMsg.buffer)
	cclog(tostring(msg))

    local strdate = {}
    local numdate = {}

	for k, v in ipairs (msg.param_list) do
        if v.param_type == macro_pb.TipParamType_Interger then
            local num =   tonumber(v.value);
            if num == nil then cclog("NotifyTipsToRole===tonumber fail") return end
            table.insert(numdate,  num)
        elseif v.param_type == macro_pb.TipParamType_String then
            table.insert(strdate,  v.value)
        end
    end
    
    local szText = g_DataMgr:getMsgContentCsv(msg.tips_id)
    if szText == nil then 
        cclog("提示字符串未找到。。。。")
    end

    local text = g_initMsgContent(szText.Description_ZH,100, strdate, numdate) 
    g_ClientMsgTips:showMsgConfirm(text)

end
 --客户端要做相关每天重置	N/A.		0时通知 或者 客户端醒来时，检查到睡觉期间跨过0时的时候通知
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_EVERY_DAY_RESET, requestEveryDayResponse)

--注册消息回调函数
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_TEMP_KICK_ROLE_RSP, RespondKickAccount) --账号登陆响应

g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_ACCOUNT_REG_RESPONSE, requestAccountRegResponse) --账号登陆响应
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_ACCOUNT_LOGIN_RESPONSE, requestAccountLoginResponse) --账号登陆响应

g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_LISTROLE_RESPONSE, requestRoleInfoResponse) --请求角色信息响应
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_RANDOMNAME_RESPONSE, requestRandomNameResponse) --请求角色信息响应
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_CHECKNAME_RESPONSE, requestCheckNameResponse) --请求检测重名响应
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_CREATEROLE_RESPONSE, requestCreateRoleResponse) --创建角色响应
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_LOGIN_RESPONSE, requestLoginResponse) --登陆响应
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_ATTACK_SMALLPASS_RESPONSE, requestBattleResponse) --攻打某个副本响应
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_DROP_RESULT_NOTIFY, requestAddDropItemRespone) --掉落信息通知
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_EXCHANGEGOD_RESPONSE, requestExChangeCardRespone) --元神兑换伙伴响应
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_GM_COMMMAND_RESPONSE, requestGMAddItemRespone) --gm命令响应
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_TRANSMIT_REALM_RESPONSE, requestChuanGongRespone) --伙伴传功响应
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_SELL_CARD_RESPONSE, requestCardSellRespone) --出售伙伴响应
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_CHANGE_EQUIP_RESPONSE, requestCardDressEquipRespone) --伙伴装装备响应
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_UPGRADE_CARD_RESPONSE, requestCardLevUpRespone) --伙伴升级响应

g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_BREACH_CARD_RESPONSE, requestEvoluteRespone) --进化伙伴响应

g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_STRENGTHEN_EQUIP_RESPONSE, requestStrengthenEquipRespone) --强化装备响应
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_STRENGTHEN_ONEKEY_RESPONSE, requestStrengthOneKeyResponse) --一键强化装备响应
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_SELL_EQUIP_RESPONSE, requestSellEquipRespone) --出售装备响应
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_COMPOUND_EQUIP_RESPONSE, requestCompoundEquipRespone) --合成装备响应
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_REBUILD_EQUIP_RESPONSE, requestRebuildEquipRespone) --重铸装备响应

g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_ACTIVITY_RESPONSE, requestActivityResponse) --参加活动响应
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_ASSISTANT_REFRESH_RESPONSE, requestAssistantRefreshResponse) --小助手活动刷新响应
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_ASSISTANT_REFRESH_NOTIFY, requestAssisActiveUpdateResponse) --小助手活动变化响应
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_ASSISTANT_REWARD_RESPONSE, requestAssistantRewardResponse) --小助手奖励响应
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_PICK_PEACH_INVITE_HERO_RESPONSE, requestPickPeachInviteHeroResponse) --摘仙桃邀请帮手响应
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_MAP_POINT_INFO_RESPONSE, requestEctypeInfoResponse) --请求副本列表响应
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_BATTLE_REPORT_NOTIFY, requestBattleReportResponse) --请求战报响应

g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_SUMMON_CARD_RESPONSE, requestSummonCardResponse) --卡牌召唤响应
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_SUMMON_CARD_REFRESH_RESPONSE, requestSummonCardRefreshResponse) --卡牌召唤刷新响应


g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_SIGNIN_REFRESH_RESPONSE, requestSiginInRefreshResponse)
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_SIGNIN_RESPONSE, requestSiginInResponse) --响应
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_REWARD_INFO_RESPONSE, requestRewardResponse) --奖励信息响应
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_GAIN_REWARD_RESPONSE, requestGainRewardResponse) --领取奖励响应
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_MESSAGE_NOTIFY, requestMessageNotify) --信息通知
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_SYNCSERVERTIME_NOTIFY, requestSyncServerTimeNotify) --同步服务器时间
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_DUJIE_CARD_RESPONSE, requestDujieCardResponse) --渡劫响应
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_RELATION_LOGIN_RESPONSE, requestRelationLoginResponse) --好友登录响应
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_RELATION_GET_ROLEINFO_RESPONSE, requestRelationGetRoleInfoResponse) --查看玩家信息响应
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_RELATION_SET_ROLEINFO_RESPONSE, requestRelationSetRoleInfoResponse) --设置玩家信息响应
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_RELATION_ADD_FRIEND_RESPONSE, requestRelationAddFriendResponse) --添加好友响应
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_RELATION_DEAL_ADD_FRIEND_RESPONSE, requestRelationDealAddFriendResponse) --好友删除响应
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_RELATION_RM_FRIEND_RESPONSE, requestRelationRmFriendResponse) --好友相关信息响应
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_RELATION_SEND_MSG_RESPONSE, requestRelationSendMsgResponse) --请求添加好友响应
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_RELATION_GET_FRIENDLIST_RESPONSE, requestRelationGetFriendListResponse) --获取好友列表信息响应
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_RELATION_GET_NEARBY_LIST_RESPONSE, requestRelationGetNearByListResponse) --获取附近的人信息响应
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_RELATION_RECV_MSG, requestRelationRecvMsg) --建立好友关系信息响应
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_RELATION_GET_OFFLINE_MSG_RESPONSE, requestRelationGetOfflineMsg) --玩家离线响应
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_OPERATOR_FATE_FROMCARD_RESPONSE, requestOperatorFateResponse) --异兽操作响应
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_UPGRADE_FATE_RESPONSE, requestUpgardeFateResponse) --异兽升级响应

g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_BAG_SELL_RESPONSE, requestShopSellResponse) --商店出售响应
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_ARENAINFO_NOTIFY, requestArenaInfoNotifyResponse) --竞技场信息通知
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_ARENA_CHALLENGE_RESPONSE, requestArenaChallengeResponse) --竞技场挑战响应
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_BUY_CHALLENGE_TIMES_RESPONSE, requestBuyChallengeTimesResponse) --竞技场挑战次数购买响应
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_ARENA_REFRESH_CHALLENGE_RESPONSE, refreshRankListResponse) --竞技场刷新排名通知
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_BUY_SHOP_ITEM_RESPONSE, requestBuyShopItemResponse) --购买商店物品响应
-- g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_BUY_EXTRA_SPACE_RESPONSE, requestBuyExtraSpaceResponse) --购买额外空间响应
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_UPGRADE_OFFICIAL_RANK_RESPONSE, requestUpgardeOfficialRankResponse) --用声望升级官阶响应
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_GAIN_PRESTIGE_RESPONSE, requestGainPrestigeResponse) --领取竞技场声望响应
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_BUY_ENERGY_RESPONSE, requestBuyEnergyResponse)	--购买体力响应
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_VIEW_PLAYER_RESPONSE, requestViewPlayerResponse) --查看其它玩家阵容响应
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_VIEW_PLAYER_DETAIL_RESPONSE, requestViewPlayerDetailResponse) --查看其它玩家详细信息响应

g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_HANDBOOKREC_NOTIFY, requestHandbookrecResponse) --图鉴响应
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_CLEAR_ITEM_NOTIFY, requestClearItemResponse) --清空物品
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_RELATION_CHECK_NAME_RESPONSE, relationCheckNameResponse) --清空物品
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_UPDATE_NEWBIE_GUIDE_RESPONSE , requestNewPlayerGuidRespone) --新手引导响应
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_REPORT_ISSUE_RESPONSE, requestReportIssueResponse) --Bug报告响应
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_ACHIEVEMENT_REFRESH_RESPONSE, requestAchievementRefreshResponse) --请求刷新成就响应
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_ACHIEVEMENT_COMPLETE_RESPONSE, achievementCompleteResponse) --成就完成响应
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_ACHIEVEMENT_GET_REWARD_RESPONSE, achievementGetRewardResponse) --成就获取奖励响应
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_ACHIEVEMENT_ON_EVENT, achievementOnEvent) --成就更新响应
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_DAILY_DATA_NOTIFY, requestDailyDataResponse) --小助手每日数据响应
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_CHANGE_ARRAYOP_RESPONSE, requestInviteChangeCallBack)	--更换卡牌响应
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_REFRESH_NOTIFY_INFO, refreshNotifyInfo) --更新通知响应
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_BATTLESCENE_NOTIFY, enterBattleScene) --战斗场景通知
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_BATTLE_RESULT_NOTIFY, BattleResult) --战斗结果通知

g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_MAILBOX_INFO_NOTIFY, MailBoxNotifyResponse) --邮件通知响应
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_ARENA_RANKLIST_RESPONSE, ArenaRankListResponse) --竞技场排名更新响应
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_ARENA_ROLE_UPDATE_NOTIFY, ArenaRoleUpdateNotify) --竞技场角色数据更新响应
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_ARRAY_HEART_UPGRADE_RESPONSE, ArrayHeartUpgradeResponse) --阵心升级响应
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_CHAT_NOTIFY, ChatNotifyResponse) --聊天通知响应
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_USE_ITEM_RESPONSE, UseItemResponse) --使用道具响应
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_ACCOUNT_AUTH_RESPONSE, userLoginResponse) --玩家登陆响应
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_SENDHEART_NOTIFY, sendHeartNotify) --赠送爱心通知
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_SENDHEART_RESPONSE, SendHeartResponse) --赠送别人爱心响应
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_RECVHEART_RESPONSE, recvHeartResponse) --领取别人赠送的爱心响应
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_MAIL_REWARD_RESPONSE, mailRewardResponse) --领取邮件奖励响应
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_MAIL_READ_RESPONSE, MailReadResponse) --邮件读取响应
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_NOTICE_NOTIFY, NoticeNotify) --通知响应
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_UPGRADE_CARDSTAR_RESPONSE, UpgradeStarResponse) --卡牌升星响应
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_ARRAY_SELECT_RESPONSE, funcArraySelectResponse) --选择阵法响应
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_DELMAIL_RESPONSE, DelMailResponse) --删除邮件响应
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_ONCE_LVUP_SKILL_RESPONSE,OnceUpgradeSkillResponse) --一键升级技能响应

g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_MATERIAL_ECTYPE_RESPONSE,requestMaterialEctypeResponse) --材料副本信息响应
g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_COMPOSE_ITEM_RESPONSE,requestComPoseItemResponse) --物品合成

g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_COM_USE_ITEM_RESPONSE, requestComUseItemResponse) --使用物品响应

g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_SERVER_EVENT_NOTIFY, serverEventResponse) --服务器事件通知

g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_PROPERTY_UPDATE_NOTIFY, propertyResponse) --通用角色属性变化通知

g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_NOTIFY_TIPS_TO_ROLE, NotifyTipsToRole) 