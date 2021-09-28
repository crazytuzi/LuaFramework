--------------------------------------------------------------------------------------
-- 文件名:	Game_GroupUpgrade.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:  陆奎安
-- 日  期:	2015-3-18 10:24
-- 版  本:	1.0
-- 描  述:	帮派管理
-- 应  用:  本例子使用一般方法的实现Scene

---------------------------------------------------------------------------------------
Game_GroupUpgrade = class("Game_GroupUpgrade")
Game_GroupUpgrade.__index = Game_GroupUpgrade

function Game_GroupUpgrade:setGroupUpgradeBtn()
	local Image_UpgradePNL = tolua.cast(self.rootWidget:getChildByName("Image_UpgradePNL"), "ImageView")
	local Label_NeedContribution = tolua.cast(Image_UpgradePNL:getChildByName("Label_NeedContribution"), "Label")

	local guildLevel = g_DataMgr:getCsvConfigByOneKey("GuildLevel",g_Guild:getUserGuildLevel())
	local curGroupCont = g_Guild:getGuildExp() --帮派经验 也是帮贡
	local costExp = guildLevel.CostExp --需要的经验
	
	g_SetLabelRed(Label_NeedContribution, (curGroupCont < costExp))
	g_SetBtnEnable(self.Button_Upgrade,  not (curGroupCont < costExp))
end

function Game_GroupUpgrade:setWnd()
	local Image_UpgradePNL = tolua.cast(self.rootWidget:getChildByName("Image_UpgradePNL"), "ImageView")
	local Label_LevelSource = tolua.cast(Image_UpgradePNL:getChildByName("Label_LevelSource"), "Label")
	local Label_LevelTarget = tolua.cast(Image_UpgradePNL:getChildByName("Label_LevelTarget"), "Label")
	
	local Label_NeedContributionLB = tolua.cast(Image_UpgradePNL:getChildByName("Label_NeedContributionLB"), "Label")
	
	local Label_NeedContribution = tolua.cast(Image_UpgradePNL:getChildByName("Label_NeedContribution"), "Label")
	local Label_MemberCountGrow = tolua.cast(Image_UpgradePNL:getChildByName("Label_MemberCountGrow"), "Label")
	
	local curLevel = g_Guild:getUserGuildLevel()
	local CSV_GuildLevel = g_DataMgr:getCsvConfigByOneKey("GuildLevel", curLevel)
	self:setGroupUpgradeBtn()
	
	Label_LevelSource:setText(_T("Lv.")..curLevel)
	local Next_CSV_tbMsg = g_DataMgr:getCsvConfigByOneKey("GuildLevel", curLevel+1)
	if  Next_CSV_tbMsg.MemberLimit == 0 then
		g_SetBtnEnable(self.Button_Upgrade, false)
		Label_LevelTarget:setText(_T("已满级"))
		Label_NeedContribution:setText(_T("已满级"))
		Label_MemberCountGrow:setText(_T("已满级"))
		return
	else
		g_SetBtnEnable(self.Button_Upgrade, true)
	end
	
	Label_LevelTarget:setText(_T("Lv.")..(curLevel+1))

	Label_NeedContribution:setText(CSV_GuildLevel.CostExp)
	Label_MemberCountGrow:setText(_T("帮众上限增加至")..Next_CSV_tbMsg.MemberLimit)
	
	Label_MemberCountGrow:setPositionX(Label_NeedContribution:getSize().width + 30)
end

function Game_GroupUpgrade:initWnd()
	local Image_UpgradePNL = tolua.cast(self.rootWidget:getChildByName("Image_UpgradePNL"), "ImageView")
	self.Button_Upgrade = tolua.cast(Image_UpgradePNL:getChildByName("Button_Upgrade"), "Button")
	
	local function onClickButton(pSender, nTag)
		local guildLevel = g_DataMgr:getCsvConfigByOneKey("GuildLevel",g_Guild:getUserGuildLevel())
		local curGroupCont = g_Guild:getGuildExp() --帮派经验 也是帮贡
		local costExp = guildLevel.CostExp --需要的经验
		if curGroupCont < costExp then 
			g_ClientMsgTips:showMsgConfirm(_T("帮贡不足,去赚更多帮贡吧"))
		else
			-- self:requestGuildUpGradeRequest()
		end
	end
	g_SetBtn(self.rootWidget, "Button_Upgrade", onClickButton, true,true,1)

	--帮派升级响应
	local order = msgid_pb.MSGID_GUILD_UPGRADE_RESPONSE
	g_MsgMgr:registerCallBackFunc(order,handler(self,self.requestGuildUpGradeResponse))	
end


function Game_GroupUpgrade:openWnd()
	if g_bReturn  then return  end 
	-- curLevel = g_Guild:getUserGuildLevel() or 1
	self:setWnd()
end


--帮派升级请求 3004689
-- function Game_GroupUpgrade:requestGuildUpGradeRequest()
	-- cclog("---------requestGuildUpGradeRequest-------------")
	-- cclog("---------帮派升级请求-------------")
	-- --local msg = zone_pb.GuildChangeNoticeRequest() 
	-- g_MsgMgr:sendMsg(msgid_pb.MSGID_GUILD_UPGRADE_REQUEST) 
-- end

--帮派升级响应
-- function Game_GroupUpgrade:requestGuildUpGradeResponse(tbMsg)
	-- cclog("---------requestGuildUpGradeResponse----帮派升级响应---------")
	-- local msgDetail = zone_pb.GuildUpgradeResponse()
	-- msgDetail:ParseFromString(tbMsg.buffer)
	-- local msgInfo = tostring(msgDetail)
	-- cclog(msgInfo)
	-- local curLevel = msgDetail.guild_level		-- 帮派等级
	-- local guildExp = msgDetail.guild_exp 		-- 剩余的经验 (帮贡)
	-- g_Guild:setUserGuildLevel(curLevel)
	-- g_Guild:setGuildExp(guildExp)
	
	-- local guild = g_DataMgr:getCsvConfigByOneKey("GuildLevel",g_Guild:getUserGuildLevel())
	-- g_Guild:setGuildMaxMemNum(guild.MemberLimit)
	
	-- self:setWnd()
	-- --刷新界面的 帮派等级
	-- if g_WndMgr:getWnd("Game_Group") then 
		-- g_WndMgr:getWnd("Game_Group").groupfunc_[TB_FUNC_TYPE_NAME.GroupPNL]:g_UpdataGroupLevel()
		
		-- g_WndMgr:getWnd("Game_Group"):setGroupRequestNotice(TB_FUNC_TYPE_NAME.GroupBuildingPNL)
		-- g_WndMgr:getWnd("Game_Group"):setGroupRequestNotice(TB_FUNC_TYPE_NAME.GroupActivityPNL)
		
	-- end
-- end

function Game_GroupUpgrade:showWndOpenAnimation(funcWndOpenAniCall)
	local Image_UpgradePNL = tolua.cast(self.rootWidget:getChildByName("Image_UpgradePNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIAppearAnimation_Scale(Image_UpgradePNL, funcWndOpenAniCall, 1.05, 0.2, Image_Background)
end

function Game_GroupUpgrade:showWndCloseAnimation(funcWndCloseAniCall)
	local Image_UpgradePNL = tolua.cast(self.rootWidget:getChildByName("Image_UpgradePNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIDisappearAnimation_Scale(Image_UpgradePNL, funcWndCloseAniCall, 1.05, 0.2, Image_Background)
end

