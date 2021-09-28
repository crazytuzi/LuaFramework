
--------------------------------------------------------------------------------------
-- 文件名:	HJW_BuildingElement.lua
-- 版  权:	(C)深圳市美天互动有限公司
-- 创建人:	
-- 日  期:	2016-01-15
-- 版  本:	1.0
-- 描  述:	
-- 应  用:  
---------------------------------------------------------------------------------------

BuildingElement = class("BuildingElement")
BuildingElement.__index = BuildingElement

local tbDesc = {
	["Game_GuildBank"] = _T("当前等级万宝楼的利率为每小时%s%%"),
	["Game_GuildSchool"] = _T("当前等级书画院的进修效率为每小时%s%%"),
	["Game_GuildSkill"] = _T("当前等级%s学习的功法等级上限为%s级"),
}

local tbDetailDesc = {
	["Game_GuildBank"] = _T("下一等级万宝楼的利率为每小时%s%%"),
	["Game_GuildSchool"] = _T("下一等级书画院的进修效率为每小时%s%%"),
	["Game_GuildSkill"] = _T("下一等级%s学习的功法等级上限为%s级"),
}

BUILD_TYPE ={
	BANK = 1,
	SCHOOL = 2,
	SKILL = 3,
}

local tbBuildName = {
	[2] = _T("万宝楼"),
	[3] = _T("书画院"),
	[4] = _T("炼神塔"),
	[5] = _T("金刚堂"),
	[6] = _T("神兵殿"),
}

function BuildingElement:ctor()
	self.buildType_ = 1;
	self.widget_ = nil
	self.buildFuncElement = {}

	--帮派建筑
	--响应领取帮派体力
	local order = msgid_pb.MSGID_GUILDBUILDING_RECV_TILI_RESP 
	g_MsgMgr:registerCallBackFunc(order,handler(self,self.requestGuildBuildingRecvTiliResponse))	
	
	--建设万宝楼响应
	local order = msgid_pb.MSGID_GUILDBUILDING_BUILD_WANBAOLOU_RESP 
	g_MsgMgr:registerCallBackFunc(order,handler(self,self.requestGuildBuildWanbaolouResp))		
	
	--建设其他响应
	local order = msgid_pb.MSGID_GUILDBUILDING_BUILD_COST_KNOWNLEDGE_RESP 
	g_MsgMgr:registerCallBackFunc(order,handler(self,self.requestGuildBuildCostKnownledgeResp))		
	
	--万宝楼认购响应
	local order = msgid_pb.MSGID_GUILDBUILDING_BUILD_WANBAOLOU_BUY_RSP 
	g_MsgMgr:registerCallBackFunc(order,handler(self,self.requestGuildBuildWanbaolouBuyRsp))	
	
	--书画院认购响应
	local order = msgid_pb.MSGID_GUILDBUILDING_BUILD_SHUHUAYUAN_BUY_RSP 
	g_MsgMgr:registerCallBackFunc(order,handler(self,self.requestGuildBuildShuhuayuanBuyRsp))		
	
	--炼神塔, 金刚堂, 神兵殿升级统一响应 

	local order = msgid_pb.MSGID_GUILDBUILDING_BUILD_SKILL_LVUP_RSP 
	g_MsgMgr:registerCallBackFunc(order,handler(self,self.requestGuildBuildSkillLvUpRsp))	
	


	
end

--[[
	@widget 
	@buildName
	@param param = {
		buildLevel = "建筑等级", 
		buildExp = "升级需要的经验",
		buildNeedMoney = "建设需要的铜钱", 
		buildReward = "",
		nextBuildReward = "",
		buildType = ,
	}
]]
function BuildingElement:setBuildInfoView(widget,buildName,param)
	
	if not widget then return end
	self.widget_ = widget
	
	if not buildName then return end 
	local desc = tbDesc[buildName]
	if not desc then desc = "%s" end
	
	local detailDesc = tbDetailDesc[buildName]
	if not detailDesc then detailDesc = "%s" end
	
	if not param then return end
	local bLevel = param.buildLevel or 1
	local bExp = param.buildExp 
	local bNeedMoney = param.buildNeedMoney or 0
	local bReward = param.buildReward or 0
	local bNextReward = param.nextBuildReward or 0
	local buildType = param.buildType 
	
	local Image_BuildingInfoPNL = tolua.cast(widget:getChildByName("Image_BuildingInfoPNL"), "ImageView")
	
	local itemList = g_DataMgr:getCsvConfig("GuildBuilding")
	
	--建筑图案
	local Image_Icon = tolua.cast(Image_BuildingInfoPNL:getChildByName("Image_Icon"), "ImageView")
	Image_Icon:loadTexture(getImgByPath(itemList[buildType]["IconPath"], itemList[buildType]["Icon"]))

	--建筑名称 Lv.1
	local Label_Name = tolua.cast(Image_BuildingInfoPNL:getChildByName("Label_Name"), "Label")
	Label_Name:setText(tbBuildName[buildType].." ".._T("Lv.")..bLevel)
	
	local txt = ""
	local txt2 = ""
	if buildType >= 4 then 
		txt = string.format( desc, tbBuildName[buildType], tostring(bReward))
		txt2 = string.format( detailDesc, tbBuildName[buildType], tostring(bNextReward))
	else
		txt = string.format( desc, tostring(bReward))
		txt2 = string.format( detailDesc, tostring(bNextReward)) 
	end
	
	local flag = true
	if bLevel >= g_Guild:getUserGuildLevel() and g_Guild:getBuildingExp(buildType) >= bExp then 
		-- "建筑等级不能超过帮派等级！加油升级帮派吧！"
		flag = false
	end
	
	--已经建筑了
	if g_Guild:getBuildTimeatList(buildType) > 0 then 
		flag = false
	end
	
	local guildMaxLevel = #g_DataMgr:getCsvConfig("GuildLevel")
	if bLevel >= guildMaxLevel and g_Guild:getBuildingExp(buildType) >= bExp then
		txt2= tbBuildName[buildType].._T("已满级")
		flag = false
	end
	
	--建筑功能描述
	local Label_Desc = tolua.cast(Image_BuildingInfoPNL:getChildByName("Label_Desc"), "Label")
	Label_Desc:setText(txt)
	
	--建筑功能描述 （下一等级）
	local Label_DetailDesc = tolua.cast(Image_BuildingInfoPNL:getChildByName("Label_DetailDesc"), "Label")
	Label_DetailDesc:setText(txt2)
	
	local Image_BuildingExp = tolua.cast(Image_BuildingInfoPNL:getChildByName("Image_BuildingExp"), "ImageView")
	local ProgressBar_BuildingExp = tolua.cast(Image_BuildingExp:getChildByName("ProgressBar_BuildingExp"), "LoadingBar")
	local percent = (g_Guild:getBuildingExp(buildType) / bExp) * 100
	ProgressBar_BuildingExp:setPercent(percent)
	
	local Label_BuildingExp = tolua.cast(ProgressBar_BuildingExp:getChildByName("Label_BuildingExp"), "Label")
	Label_BuildingExp:setText(g_Guild:getBuildingExp(buildType).."/"..bExp)

	--建设
	local Button_Build = tolua.cast(Image_BuildingInfoPNL:getChildByName("Button_Build"), "Button")
	local function onBuilding(pSender,eventType)
		if eventType == ccs.TouchEventType.ended then	
			--pSender:getParent()
			--铜钱不足
			
			if g_Guild:getBuildTimeatList(buildType) > 0 then 
				-- g_ShowSysTips({text = "今天已经建造了"})
				return 
			end
			
			if bLevel >= g_Guild:getUserGuildLevel() and g_Guild:getBuildingExp(buildType) >= bExp then 
				g_ShowSysTips({text = _T("建筑等级不能超过帮派等级！加油升级帮派吧！")})
				return
			end
			
			local flag = true
			if buildType >= 3 then --阅历

				if  bNeedMoney >= g_Hero:getKnowledge() then 
					g_ClientMsgTips:showMsgConfirm(_T("阅历不足，无法建造"))
					return 
				end
					
			else
				--铜钱
				local txt = string.format(_T("建设需要消耗%d铜钱，您的铜钱不足是否进行招财?"), bNeedMoney)
				if not g_CheckMoneyConfirm(bNeedMoney, txt) then return end
			end
			
			self:requestGuildBuildReq(buildType)
			
		end
	end
	Button_Build:setTouchEnabled(flag)	
	Button_Build:addTouchEventListener(onBuilding)
	Button_Build:setBright(flag)

	
end


--[[
	@listView
	@imagePnl
	@btnPnl
	@buildType
	@param local param = {
		upItemNum = ,
		buildType = ,
	}
	
]]
function BuildingElement:setListImage(listView, imagePnl, btnPnl, param)
	
	if not param then return end 
	local upItemNum = param.upItemNum / 2 or 0
	local buildType = param.buildType
	
	self.buildFuncElement = {}
	
    local LuaListView = Class_LuaListView:new()
    LuaListView:setListView(listView)
    LuaListView:setModel(imagePnl)
	local function updateServerList(imagePnl, nRowIndex)
        for i = 1, 2 do
			local nIndex = (nRowIndex - 1) * 2 + i
            local btn = tolua.cast(imagePnl:getChildByName(btnPnl..i), "Button")
			table.insert(self.buildFuncElement, btn)
			
			if macro_pb.GuildBuildType_Wanbaolou == buildType then 
				local wndInstance = g_WndMgr:getWnd("Game_GuildBank")
				if wndInstance then 
					wndInstance:buttonBank(btn, nIndex, buildType)
				end
				
			elseif macro_pb.GuildBuildType_Shuhuayuan == buildType then 
				local wndInstance = g_WndMgr:getWnd("Game_GuildSchool")
				if wndInstance then 
					wndInstance:buttonSchool(btn, nIndex, buildType)
				end
			elseif macro_pb.GuildBuildType_Lianshenta  == buildType or
				macro_pb.GuildBuildType_Jingangtang  == buildType or 
				macro_pb.GuildBuildType_Shenbingdian  == buildType then 
				
				local wndInstance = g_WndMgr:getWnd("Game_GuildSkill")
				if wndInstance then 
					wndInstance:buttonSkill(btn, nIndex, buildType)
				end
			end
			
			local function onClick(pSender,eventType)
				if eventType == ccs.TouchEventType.ended then
					
				end
			end
			btn:setTouchEnabled(true)
			btn:addTouchEventListener(onClick)
			-- btn:setTag(buildType)
			btn:setVisible(true)
			
		end
   end
    LuaListView:setUpdateFunc(updateServerList)
	LuaListView:updateItems(upItemNum)

end

-- macro_pb.GuildBuildChooseType_Lv1 = 1;		// 普通1
-- macro_pb.GuildBuildChooseType_Lv2 = 2;		// 高级1
-- macro_pb.GuildBuildChooseType_Lv3 = 3;		// 普通2
-- macro_pb.GuildBuildChooseType_Lv4 = 4;		// 高级2
	
function BuildingElement:getBuildSkillValue(csvData, buildIndex, skillIndex)
	local skillLevel = g_Guild:getBuildSkillLevel(buildIndex, skillIndex)
	return math.floor( csvData.PropBase + ( skillLevel - 1) * csvData.PropGrowth )
end

--获取属性值字符串
function BuildingElement:getBuildSillPropString(csvData, buildIndex, skillIndex)
	local bIsPercent, nBasePrecent = g_CheckPropIsPercent(csvData.PropID)
	if bIsPercent then 
		return g_PropName[csvData.PropID].."+"..self:getBuildSkillValue(csvData, buildIndex, skillIndex)
	else
		return g_PropName[csvData.PropID].."+"..self:getBuildSkillValue(csvData, buildIndex, skillIndex)
	end
end

function BuildingElement:getBuildSkillLevelInfoStringcsvData(csvData)
	local bIsPercent, nBasePrecent = g_CheckPropIsPercent(csvData.PropID)
	if bIsPercent then 
		return _T("每级增加")..g_PropName[csvData.PropID].." "..csvData.PropGrowth
	else
		return _T("每级增加")..g_PropName[csvData.PropID].." "..csvData.PropGrowth
	end
end

--取建筑的下一等级 如果超过最大了返回最大值
function BuildingElement:SkillBuillNextLevel(cvsName, buildLeve )
	local maxLevel = g_DataMgr:getCsvConfig(cvsName)
	local nextSchoolLv = buildLeve + 1 
	if nextSchoolLv >= #maxLevel  then nextSchoolLv = #maxLevel end
	return nextSchoolLv
end
		
--请求领取帮派体力 
function BuildingElement:requestGuildBuildingRecvTili()
	cclog("---------requestGuildBuildingRecvTiliReq---请求领取帮派体力----------")
	g_MsgMgr:sendMsg(msgid_pb.MSGID_GUILDBUILDING_RECV_TILI_REQ)
end

--响应领取帮派体力
function BuildingElement:requestGuildBuildingRecvTiliResponse(tbMsg)
	cclog("---------响应领取帮派体力-------------")
	local msgDetail = zone_pb.GuildBuildingRecvTiliResp()
	msgDetail:ParseFromString(tbMsg.buffer)
	local msgInfo = tostring(msgDetail)
	cclog(msgInfo)
	
	local energy = msgDetail.energy -- 领取之后总的体力
		
	local energy = g_DataMgr:getCsvConfigByOneKey("GuildLevel",g_Guild:getUserGuildLevel()).EnergyReward
	-- local txt = _T("您领取")..energy.._T("体力")
	-- g_ShowSysTips({text = txt})
	g_ShowRewardMsgConfrim(macro_pb.ITEM_TYPE_MASTER_ENERGY, energy)
	g_Guild:setBuildTimeatList(macro_pb.GuildBuildType_Jingxinzai, os.time())
	
	if g_WndMgr:getWnd("Game_Group") then 
		g_WndMgr:getWnd("Game_Group").groupfunc_[TB_FUNC_TYPE_NAME.GroupBuildingPNL]:refreshBtnView()
		-- g_WndMgr:getWnd("Game_Group"):setGroupRequestNotice(TB_FUNC_TYPE_NAME.GroupBuildingPNL)
	end
	
	
end		
-----------------------------------以下是协议是 对应的----
--帮派建筑建设请求 
function BuildingElement:requestGuildBuildReq(buildType)
	cclog("---------requestGuildBuildReq---帮派建筑建设请求----------")
	local msg = zone_pb.GuildBuildReq() 
	msg.build_type = buildType 
	g_MsgMgr:sendMsg(msgid_pb.MSGID_GUILDBUILDING_BUILD_REQ, msg)
	
end

--建设万宝楼响应 MSGID_GUILDBUILDING_BUILD_WANBAOLOU_RESP
function BuildingElement:requestGuildBuildWanbaolouResp(tbMsg)
	cclog("---------建设万宝楼响应-------------")
	local msgDetail = zone_pb.GuildBuildWanbaolouResp()
	msgDetail:ParseFromString(tbMsg.buffer)
	local msgInfo = tostring(msgDetail)
	cclog("-建设万宝楼响应"..msgInfo)

	local prestige = msgDetail.prestige 		-- 领取后的总的声望
	local money = msgDetail.money 				--建设后玩家身上总的铜钱
	local buildExp = msgDetail.build_exp 		-- 建筑当前经验
	local buildLevel = msgDetail.build_level	-- 建筑当前等级
	
	local tipsNum = prestige - g_Hero:getPrestige()
	--在测试先注释了 测试完成后要打开
	g_Guild:setBuildTimeatList(macro_pb.GuildBuildType_Wanbaolou, os.time())

	
	g_Hero:setPrestige(prestige) --更新玩家的声望
	g_Hero:setCoins(money) --更新铜钱信息

	if buildLevel then 
		g_Guild:setBuildingLevel(macro_pb.GuildBuildType_Wanbaolou, buildLevel)
	end
	
	g_Guild:setBuildingExp(macro_pb.GuildBuildType_Wanbaolou, buildExp)

	local bankLv = g_Guild:getBuildingLevel(macro_pb.GuildBuildType_Wanbaolou);--万宝楼等级
	
	local bankData = g_DataMgr:getCsvConfigByOneKey("GuildBuildingBankLevel",bankLv)
	if not bankData then return end 
	
	local nextBankLv = bankLv + 1 
	if nextBankLv >= #g_DataMgr:getCsvConfig("GuildBuildingBankLevel") then nextBankLv = bankLv end

	local bankNextData = g_DataMgr:getCsvConfigByOneKey("GuildBuildingBankLevel",nextBankLv)
	if not bankNextData then return end
	
	-- bankData.PrestigeReward--建设获得的声望
	local param = {
		buildLevel = bankLv, 
		buildExp = bankData.BuildingExp,--升级需要的经验
		buildNeedMoney = bankData.BuildNeedMoney, --建设需要的铜钱
		buildReward = bankData.RewardInterest,--客户端显示的利率
		nextBuildReward = bankNextData.RewardInterest,--客户端显示的利率
		buildType = macro_pb.GuildBuildType_Wanbaolou,
	}
	self:setBuildInfoView(self.widget_ ,"Game_GuildBank", param)
	

	if g_WndMgr:getWnd("Game_Group") then 
		g_WndMgr:getWnd("Game_Group").groupfunc_[TB_FUNC_TYPE_NAME.GroupBuildingPNL]:refreshBtnView()
		-- g_WndMgr:getWnd("Game_Group"):setGroupRequestNotice(TB_FUNC_TYPE_NAME.GroupBuildingPNL)
	end
	
	local txt = string.format(_T("万宝楼建设成功并获得%d点声望"),tipsNum)
	g_ShowSysTips({text = txt})
	
	self:updataElement(macro_pb.GuildBuildType_Wanbaolou)
	
end

--建设 其他建筑 响应 MSGID_GUILDBUILDING_BUILD_COST_KNOWNLEDGE_RESP
function BuildingElement:requestGuildBuildCostKnownledgeResp(tbMsg)
	cclog("---------建设 其他建筑 响应-------------")
	local msgDetail = zone_pb.GuildBuildCostKnownledgeResp()
	msgDetail:ParseFromString(tbMsg.buffer)
	local msgInfo = tostring(msgDetail)
	cclog("建设 其他建筑 响应"..msgInfo)
	local prestige = msgDetail.prestige -- 领取后的总的声望
	local knowledge = msgDetail.knowledge --建设后玩家身上总的学识
	local buildExp = msgDetail.build_exp -- 建筑当前经验
	local buildLevel = msgDetail.build_level -- 建筑当前等级
	local buildType = msgDetail.build_type -- 建筑类型 GuildBuildType

	local tipsNum = prestige - g_Hero:getPrestige()
	--在测试先注释了 测试完成后要打开
	g_Guild:setBuildTimeatList(buildType, os.time())

	
	g_Hero:setPrestige(prestige) --更新玩家的声望
	-- g_Hero:setCoins(money) --更新铜钱信息
	g_Hero:setKnowledge(knowledge)

	-- if buildLevel then 
	g_Guild:setBuildingLevel(buildType, buildLevel)
	-- end
	
	g_Guild:setBuildingExp(buildType, buildExp)

	local buildLv = g_Guild:getBuildingLevel(buildType);--等级

	local param = {}
	
	if buildType == macro_pb.GuildBuildType_Shuhuayuan then --书画院
	
		local schoolData = g_DataMgr:getCsvConfigByOneKey("GuildBuildingSchoolLevel",buildLv)
		
		local maxLevel = g_DataMgr:getCsvConfig("GuildBuildingSchoolLevel")
		local nextSchoolLv = buildLv + 1 
		if nextSchoolLv >= #maxLevel  then nextSchoolLv = buildLv end
		
		local schoolNextData = g_DataMgr:getCsvConfigByOneKey("GuildBuildingSchoolLevel",nextSchoolLv)

		param = {
			buildLevel = buildLv, 
			buildExp = schoolData.BuildingExp,--升级需要的经验
			buildNeedMoney = schoolData.BuildNeedKnowledge, --建设需要的学识
			buildReward = schoolData.RewardInterest,--客户端显示的利率
			nextBuildReward = schoolNextData.RewardInterest,--客户端显示的利率
			buildType = buildType,
		}
	
	elseif buildType == macro_pb.GuildBuildType_Lianshenta then 
		local skillData = g_DataMgr:getCsvConfigByOneKey("GuildBuildingSkillHpLevel",buildLv)
		local nextSkillLv = self:SkillBuillNextLevel("GuildBuildingSkillHpLevel", buildLv)
		local skillNextData = g_DataMgr:getCsvConfigByOneKey("GuildBuildingSkillHpLevel",nextSkillLv)
		param = {
			buildLevel = buildLv, 
			buildExp = skillData.BuildingExp,--升级需要的经验
			buildNeedMoney = skillData.BuildNeedKnowledge, --建设需要的铜钱
			buildReward = skillData.MaxSkillLevel,--功法升级上限
			nextBuildReward = skillNextData.MaxSkillLevel,--功法升级上限
			buildType = buildType,
		}
	elseif buildType == macro_pb.GuildBuildType_Jingangtang then --金刚堂
			
		local skillData = g_DataMgr:getCsvConfigByOneKey("GuildBuildingSkillDefenceLevel",buildLv)
		local nextSkillLv = self:SkillBuillNextLevel("GuildBuildingSkillDefenceLevel", buildLv)
		local skillNextData = g_DataMgr:getCsvConfigByOneKey("GuildBuildingSkillDefenceLevel",nextSkillLv)
		param = {
			buildLevel = buildLv, 
			buildExp = skillData.BuildingExp,--升级需要的经验
			buildNeedMoney = skillData.BuildNeedKnowledge, --建设需要的铜钱
			buildReward = skillData.MaxSkillLevel,--功法升级上限
			nextBuildReward = skillNextData.MaxSkillLevel,--功法升级上限
			buildType = buildType,
		}
	elseif buildType == macro_pb.GuildBuildType_Shenbingdian then --神兵殿
		local skillData = g_DataMgr:getCsvConfigByOneKey("GuildBuildingSkillAttackLevel",buildLv)
		local nextSkillLv = self:SkillBuillNextLevel("GuildBuildingSkillAttackLevel", buildLv)
		local skillNextData = g_DataMgr:getCsvConfigByOneKey("GuildBuildingSkillAttackLevel",nextSkillLv)
		param = {
			buildLevel = buildLv, 
			buildExp = skillData.BuildingExp,--升级需要的经验
			buildNeedMoney = skillData.BuildNeedKnowledge, --建设需要的铜钱
			buildReward = skillData.MaxSkillLevel,--功法升级上限
			nextBuildReward = skillNextData.MaxSkillLevel,--功法升级上限
			buildType = buildType,
		}
	end
	
	local typeName = {
		"",
		"Game_GuildBank",
		"Game_GuildSchool",
		"Game_GuildSkill",
		"Game_GuildSkill",
		"Game_GuildSkill",
	}
	self:setBuildInfoView(self.widget_, typeName[buildType], param)
	
	self:updataElement(buildType)
	
	if g_WndMgr:getWnd("Game_Group") then 
		g_WndMgr:getWnd("Game_Group").groupfunc_[TB_FUNC_TYPE_NAME.GroupBuildingPNL]:refreshBtnView()
		-- g_WndMgr:getWnd("Game_Group"):setGroupRequestNotice(TB_FUNC_TYPE_NAME.GroupBuildingPNL)
	end
	
	g_ShowSysTips({text = tbBuildName[buildType].._T("建设成功并获得")..tipsNum.._T("点声望")})

end
-------------------------------以上的协议---------------------

	
--帮派建筑认购请求 
function BuildingElement:requestGuildBuildBuyReq(buildType,chooseType)
	cclog("---------requestGuildBuildBuyReq---帮派建筑认购请求----------")
	local msg = zone_pb.GuildBuildBuyReq() 
	msg.build_type = buildType-- 参见GuildBuildType
	msg.choose_type = chooseType -- 券类型, 参见GuildBuildChooseType
	g_MsgMgr:sendMsg(msgid_pb.MSGID_GUILDBUILDING_BUILD_BUY_REQ, msg)
end

--万宝楼认购响应 MSGID_GUILDBUILDING_BUILD_WANBAOLOU_BUY_RSP
function BuildingElement:requestGuildBuildWanbaolouBuyRsp(tbMsg)
	cclog("---------万宝楼认购响应-------------")
	local msgDetail = zone_pb.GuildBuildWanbaolouBuyRsp()
	msgDetail:ParseFromString(tbMsg.buffer)
	local msgInfo = tostring(msgDetail)
	cclog(msgInfo)
	local money = msgDetail.money 				--玩家身上的总的铜钱
	local chooseType = msgDetail.choose_type	--券类型, 参见GuildBuildChooseType
	local chooseTimeat = msgDetail.choose_timeat --认购的时间点
	
	g_Hero:setCoins(money) --更新铜钱信息
	
	g_Guild:setLastChooseType(1, chooseType)
	g_Guild:setLastChooseTimeat(1, chooseTimeat)

	self:updataElement(macro_pb.GuildBuildType_Wanbaolou)
	
	if g_WndMgr:getWnd("Game_Group") then 
		g_WndMgr:getWnd("Game_Group").groupfunc_[TB_FUNC_TYPE_NAME.GroupBuildingPNL]:refreshBtnView()
		-- g_WndMgr:getWnd("Game_Group"):setGroupRequestNotice(TB_FUNC_TYPE_NAME.GroupBuildingPNL)
	end

	g_ShowSysTips({text = _T("认购成功,本金和利息将在24小时之后通过邮件返回")})
	
end

--书画院认购响应 MSGID_GUILDBUILDING_BUILD_SHUHUAYUAN_BUY_RSP
function BuildingElement:requestGuildBuildShuhuayuanBuyRsp(tbMsg)
	cclog("---------书画院认购响应-------------")
	local msgDetail = zone_pb.GuildBuildShuhuayuanBuyRsp()
	msgDetail:ParseFromString(tbMsg.buffer)
	local msgInfo = tostring(msgDetail)
	cclog(msgInfo)
	local knownledge = msgDetail.knownledge -- 玩家身上的总的学识
	local chooseType = msgDetail.choose_type	--券类型, 参见GuildBuildChooseType
	local chooseTimeat = msgDetail.choose_timeat --认购的时间点
		
	g_Hero:setKnowledge(knownledge)
	
	g_Guild:setLastChooseType(2, chooseType)
	g_Guild:setLastChooseTimeat(2, chooseTimeat)
	
	self:updataElement(macro_pb.GuildBuildType_Shuhuayuan)
	
	if g_WndMgr:getWnd("Game_Group") then 
		g_WndMgr:getWnd("Game_Group").groupfunc_[TB_FUNC_TYPE_NAME.GroupBuildingPNL]:refreshBtnView()
		-- g_WndMgr:getWnd("Game_Group"):setGroupRequestNotice(TB_FUNC_TYPE_NAME.GroupBuildingPNL)
	end
	g_ShowSysTips({text = _T("阅读成功,24小时后将通过邮件返回阅历值")})
end

--炼神塔, 金刚堂, 神兵殿升级统一请求 
function BuildingElement:requestGuildBuildSkillLvUpReq(buildType,chooseType)
	cclog("---------requestGuildBuildSkillLvUpReq---炼神塔, 金刚堂, 神兵殿升级统一请求 ----------")
	local msg = zone_pb.GuildBuildSkillLvUpReq() 
	msg.build_type = buildType;-- 参见GuildBuildType
	msg.choose_type = chooseType --券类型, 参见GuildBuildChooseType
	g_MsgMgr:sendMsg(msgid_pb.MSGID_GUILDBUILDING_BUILD_SKILL_LVUP_REQ, msg)
	
end

--炼神塔, 金刚堂, 神兵殿升级统一响应 MSGID_GUILDBUILDING_BUILD_SKILL_LVUP_RSP
function BuildingElement:requestGuildBuildSkillLvUpRsp(tbMsg)
	cclog("---------炼神塔, 金刚堂, 神兵殿升级统一响应-------------")
	local msgDetail = zone_pb.GuildBuildSkillLvUpRsp()
	msgDetail:ParseFromString(tbMsg.buffer)
	local msgInfo = tostring(msgDetail)
	cclog(msgInfo)
	
	local addValue = msgDetail.add_value --玩家增加的hp
	local knownledge = msgDetail.knownledge --玩家身上的总的学识
	local skillLv = msgDetail.skill_lv --升级后技能等级
	local chooseType = msgDetail.choose_type	--券类型, 参见GuildBuildChooseType
	local buildType = msgDetail.build_type
	
	
	g_Hero:setKnowledge(knownledge)
	
	local buildIndex = 1
	if buildType == 4 then 
		buildIndex = 1
	elseif buildType == 5 then --金刚堂
		buildIndex = 2
	elseif buildType == 6 then --神兵殿
		buildIndex = 3
	end
	
	g_Guild:setBuildSkillLevel(buildIndex, chooseType, skillLv)
	
	self:updataElement(buildType)
	
	if g_WndMgr:getWnd("Game_Group") then 
		g_WndMgr:getWnd("Game_Group").groupfunc_[TB_FUNC_TYPE_NAME.GroupBuildingPNL]:refreshBtnView()
		-- g_WndMgr:getWnd("Game_Group"):setGroupRequestNotice(TB_FUNC_TYPE_NAME.GroupBuildingPNL)
	end
	
	g_Hero:refreshTeamMemberAddProps()
	
end

--	-- GuildBuildType_Jingxinzai = 1;			// 静心斋
	-- GuildBuildType_Wanbaolou = 2;			// 万宝楼
	-- GuildBuildType_Shuhuayuan = 3;			// 书画院
	-- GuildBuildType_Lianshenta = 4;			// 炼神塔
	-- GuildBuildType_Jingangtang = 5;			// 金刚堂
	-- GuildBuildType_Shenbingdian = 6;		// 神兵殿
function BuildingElement:updataElement(buildType)
	for nIndex = 1, #self.buildFuncElement do
		local btn = self.buildFuncElement[nIndex]
		if macro_pb.GuildBuildType_Wanbaolou == buildType then 
			local wndInstance = g_WndMgr:getWnd("Game_GuildBank")
			if wndInstance then 
				wndInstance:buttonBank(btn, nIndex, buildType)
			end
			
		elseif macro_pb.GuildBuildType_Shuhuayuan == buildType then 
			local wndInstance = g_WndMgr:getWnd("Game_GuildSchool")
			if wndInstance then 
				wndInstance:buttonSchool(btn, nIndex, buildType)
			end
		elseif macro_pb.GuildBuildType_Lianshenta  == buildType or
			macro_pb.GuildBuildType_Jingangtang  == buildType or 
			macro_pb.GuildBuildType_Shenbingdian  == buildType then 
			
			local wndInstance = g_WndMgr:getWnd("Game_GuildSkill")
			if wndInstance then 
				wndInstance:buttonSkill(btn, nIndex, buildType)
			end
		end
	end
end




g_BuildingElement = BuildingElement.new()

