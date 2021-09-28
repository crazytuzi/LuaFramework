--------------------------------------------------------------------------------------
-- 文件名:	HJW_GroupPNL_View.lua
-- 版  权:	(C)深圳市美天互动有限公司
-- 创建人:	
-- 日  期:	2015-11-20
-- 版  本:	1.0
-- 描  述:	
-- 应  用:  帮派基本信息
---------------------------------------------------------------------------------------
GroupPNL = class("GroupPNL")
GroupPNL.__index = GroupPNL


function GroupPNL:init(widget)
	self.widget = widget
	self:groupInfo(widget)


end

function GroupPNL:groupInfo(widget)
	if not widget then return end 
	self:g_UpdataGroupLevel()
	local Image_GroupPNL = tolua.cast(widget:getChildByName("Image_GroupPNL"), "ImageView")
	local Image_InfoPNL = tolua.cast(Image_GroupPNL:getChildByName("Image_InfoPNL"), "ImageView")

	--是否是帮主 暂定帮主才有管理权
	-- local flag,quit = false,true
	-- if g_Guild:getUserGildHost(g_MsgMgr:getUin()) then 
		-- flag,quit = true,false
	-- end
	self:groupButtonManageMent()
	self:groupButtonQuit()

	local ButtonGroup = ButtonGroup:create()
	--帮派聊天
	local Button_GroupChat = tolua.cast(Image_GroupPNL:getChildByName("Button_GroupChat"), "Button")
	ButtonGroup:PushBack(Button_GroupChat, nil, function() 	
		g_Guild:setViewState(GUILD_VIEW_STATE.CHAT)
		
		local Image_GroupPNL = tolua.cast(widget:getChildByName("Image_GroupPNL"), "ImageView")
		local Image_MemberPNL = tolua.cast(Image_GroupPNL:getChildByName("Image_MemberPNL"), "ImageView")
		Image_MemberPNL:setVisible(false)
		local Image_GroupChatPNL = tolua.cast(Image_GroupPNL:getChildByName("Image_GroupChatPNL"), "ImageView")
		Image_GroupChatPNL:setVisible(true)
	end)
	
	--成员列表
	local Button_MemberList = tolua.cast(Image_GroupPNL:getChildByName("Button_MemberList"), "Button")
	ButtonGroup:PushBack(Button_MemberList, nil, function() 	
		g_Guild:setViewState(GUILD_VIEW_STATE.MEMBER)
		local Image_GroupPNL = tolua.cast(widget:getChildByName("Image_GroupPNL"), "ImageView")
		local Image_MemberPNL = tolua.cast(Image_GroupPNL:getChildByName("Image_MemberPNL"), "ImageView")
		Image_MemberPNL:setVisible(true)
		local Image_GroupChatPNL = tolua.cast(Image_GroupPNL:getChildByName("Image_GroupChatPNL"), "ImageView")
		Image_GroupChatPNL:setVisible(false)
	end)
	
	ButtonGroup:Click(g_Guild:getViewState())

end

--[[
	退出按钮
	帮众时显示为退出
	帮主时显示为管理
]]
function GroupPNL:groupButtonQuit()
	if not self.widget then return end 
	local Image_GroupPNL = tolua.cast(self.widget:getChildByName("Image_GroupPNL"), "ImageView")
	local Image_InfoPNL = tolua.cast(Image_GroupPNL:getChildByName("Image_InfoPNL"), "ImageView")
	local Button_Quit = tolua.cast(Image_InfoPNL:getChildByName("Button_Quit"), "Button")
	local function onGroupQuit(pSender,eventType)
		if eventType == ccs.TouchEventType.ended then
			local nGuildQuitCD = g_DataMgr:getGlobalCfgCsv("guild_quit_cd")/3600
			local tips = string.format(_T("退出帮派%d小时之后才能重新加入新帮派，是否确定退出帮派?"), nGuildQuitCD)
			g_ClientMsgTips:showConfirm(tips, function()
				g_Guild:requestGuildOuitRequest()
			end)	
			
		end
	end
	local flag = g_Guild:getUserGildHost(g_MsgMgr:getUin())
	Button_Quit:setVisible(not flag)
	Button_Quit:setTouchEnabled(not flag)	
	Button_Quit:addTouchEventListener(onGroupQuit)
	
end

--[[
	帮派管理
]]
function GroupPNL:groupButtonManageMent()
	if not self.widget then return end 
	local Image_GroupPNL = tolua.cast(self.widget:getChildByName("Image_GroupPNL"), "ImageView")
	local Image_InfoPNL = tolua.cast(Image_GroupPNL:getChildByName("Image_InfoPNL"), "ImageView")
	
	local Button_ManageMent = tolua.cast(Image_InfoPNL:getChildByName("Button_ManageMent"), "Button")
	local function onGroupManageMent(pSender,eventType)
		if eventType == ccs.TouchEventType.ended then	
			g_WndMgr:showWnd("Game_GroupManage")
		end
	end

	local flag = g_Guild:getUserGildHost(g_MsgMgr:getUin())
	Button_ManageMent:setVisible(flag)
	Button_ManageMent:setTouchEnabled(flag)	
	Button_ManageMent:addTouchEventListener(onGroupManageMent)

	self:setGroupRequestNotice()
end

function GroupPNL:setGroupRequestNotice()
	if not self.widget then return end 
	local Image_GroupPNL = tolua.cast(self.widget:getChildByName("Image_GroupPNL"), "ImageView")
	local Image_InfoPNL = tolua.cast(Image_GroupPNL:getChildByName("Image_InfoPNL"), "ImageView")
	local Button_ManageMent = tolua.cast(Image_InfoPNL:getChildByName("Button_ManageMent"), "Button")
	g_SetBubbleNotify(Button_ManageMent, g_GetNoticeNum_GroupRequest(), 80, 20)

	local Button_Quit = tolua.cast(Image_InfoPNL:getChildByName("Button_Quit"), "Button")
	g_SetBubbleNotify(Button_ManageMent, g_GetNoticeNum_GroupUpgrade(), 80, 20)
end

function GroupPNL:sortMemList()
	--首先显示在线的玩家
	--同样是在线的玩家则根据等级从大到小排序，等级相同则根据UIN从小到大排序
	--其次显示离线玩家
	--规则同上
	--同样是离线的玩家则根据等级从大到小排序，等级相同则根据UIN从小到大排序
	local memList = g_Guild:getMEMList()
	local function sortTable(one,two)
		local logintimeOne = one.logintime --玩家登陆时间
		local outTimeOne = one.logouttime --离线时间
			
		local logintimeTwo = two.logintime --玩家登陆时间
		local outTimeTwo = two.logouttime --离线时间
		
		local nLevelOne = one.level --玩家等级
		local nLevelTwo = two.level --玩家等级
		
		local uinOne = one.uin --玩家Id
		local uinTwo = two.uin --玩家Id

		local zaione = logintimeOne > outTimeOne and 1 or 0
		local zaitwo = logintimeTwo > outTimeTwo and 1 or 0

		if zaione ~= zaitwo then
			return zaione > zaitwo
		end

		if nLevelOne ~= nLevelTwo then
			return nLevelOne > nLevelTwo
		end
	
		return uinOne < uinTwo
		
	end
	table.sort(memList, sortTable)	
	return memList
end

function GroupPNL:listViewShow()

	if not self.widget then return end
	local Image_GroupPNL = tolua.cast(self.widget:getChildByName("Image_GroupPNL"), "ImageView")
	local Image_MemberPNL = tolua.cast(Image_GroupPNL:getChildByName("Image_MemberPNL"), "ImageView")
		
	local ListView_GroupMember = tolua.cast(Image_MemberPNL:getChildByName("ListView_GroupMember"), "ListViewEx")
	local Panel_GroupMemberItem = tolua.cast(ListView_GroupMember:getChildByName("Panel_GroupMemberItem"), "Layout")

	self.tbMemList_ = self:sortMemList()
	
	local groupRequestList = Class_LuaListView:new()
    self.listView = groupRequestList
	local function updateListViewItem(Panel_GroupMemberItem, nIndex)
		local memList = self.tbMemList_
		local cardcfgid = memList[nIndex].cardcfgid --伙伴ID
		local sign = memList[nIndex].sign 
		local viplv = memList[nIndex].viplv 		--
		local contribution = memList[nIndex].contribution --贡献
		local fight = memList[nIndex].fight --战斗力
		local breachlv = memList[nIndex].breachlv --突破等级
		local starlv = memList[nIndex].starlv --玩家星级
		local logintime = memList[nIndex].logintime --玩家登陆时间
		local nLevel = memList[nIndex].level --玩家等级
		local ident = memList[nIndex].ident --玩家身份
		local gener = memList[nIndex].gener --玩家性别
		local uin = memList[nIndex].uin --玩家Id
		local name = memList[nIndex].name--玩家名称
		local logOutTime =	memList[nIndex].logouttime --离线时间
		local Button_GroupMemberItem = tolua.cast(Panel_GroupMemberItem:getChildByName("Button_GroupMemberItem"), "Button")
		if uin == g_MsgMgr:getUin() then 
			Button_GroupMemberItem:loadTextureNormal(getUIImg("ListView_GroupMember_Check"))
			Button_GroupMemberItem:loadTexturePressed(getUIImg("ListView_GroupMember_Check_Press"))
			Button_GroupMemberItem:loadTextureDisabled(getUIImg("ListView_GroupMember_Disabled"))
		else
			Button_GroupMemberItem:loadTextureNormal(getUIImg("ListView_GroupMember"))
			Button_GroupMemberItem:loadTexturePressed(getUIImg("ListView_GroupMember_Press"))
			Button_GroupMemberItem:loadTextureDisabled(getUIImg("ListView_GroupMember_Disabled"))
		end
		
		local function onUserInfo(pSender,eventType)
			if eventType == ccs.TouchEventType.ended then	
				if uin == g_MsgMgr:getUin() then 
					g_ShowSysTips({text = _T("这是你自己哟亲~")})
					return
				else
					local tag = pSender:getTag()
					g_WndMgr:showWnd("Game_GroupMemberView",memList[tag])
				end
			end
		end
	
		Button_GroupMemberItem:setTouchEnabled(true)
		Button_GroupMemberItem:setTag(nIndex)
		Button_GroupMemberItem:addTouchEventListener(onUserInfo)
		
		local Button_View = tolua.cast(Button_GroupMemberItem:getChildByName("Button_View"), "Button")
		Button_View:setTouchEnabled(true)
		Button_View:setTag(nIndex)
		Button_View:addTouchEventListener(onUserInfo)
		
		--帮众名称(包括帮主的)
		local Label_MasterName = tolua.cast(Button_GroupMemberItem:getChildByName("Label_MasterName"), "Label")
		local param = {
			name = name,breachLevel = breachlv,lableObj = Label_MasterName,
		}
		g_Guild:setLableByColor(param)
		--帮众等级
		local Label_Level = tolua.cast(Button_GroupMemberItem:getChildByName("Label_Level"), "Label")
		Label_Level:setText(_T("Lv.")..nLevel)
		--帮主头像 
		
		--底框
		local Image_Head = tolua.cast(Button_GroupMemberItem:getChildByName("Image_Head"), "ImageView")
		local Image_Icon = getCardIconImg(cardcfgid,starlv)
		g_SetPlayerHead(Image_Head,{vip = viplv,uin = uin,star = starlv,breachlv = breachlv,Image_Icon = Image_Icon},true)

		local labelPosittion = _T("帮众")
		if ident == 1 then 
			labelPosittion = _T("帮主")
		end
		--职位
		local Label_Position = tolua.cast(Button_GroupMemberItem:getChildByName("Label_Position"), "Label")
		Label_Position:setText(labelPosittion)
		--登录时间
		local Label_LogoutDate = tolua.cast(Button_GroupMemberItem:getChildByName("Label_LogoutDate"), "Label")
		local nTime = getStrTime(logintime,logOutTime)
		Label_LogoutDate:setText(nTime)
		--历史贡献: 
		local Label_ContributionHistoryLB = tolua.cast(Button_GroupMemberItem:getChildByName("Label_ContributionHistoryLB"), "Label")
		local Label_ContributionHistory = tolua.cast(Label_ContributionHistoryLB:getChildByName("Label_ContributionHistory"), "Label")
		Label_ContributionHistory:setText(contribution)
		Label_ContributionHistory:setPositionX(Label_ContributionHistoryLB:getSize().width)
		--战力
		local Label_TeamStrengthenLB = tolua.cast(Button_GroupMemberItem:getChildByName("Label_TeamStrengthenLB"), "Label")
		local BitmapLabel_TeamStrengthen = tolua.cast(Label_TeamStrengthenLB:getChildByName("BitmapLabel_TeamStrengthen"), "LabelBMFont")
		BitmapLabel_TeamStrengthen:setText(fight)
		BitmapLabel_TeamStrengthen:setPositionX(Label_TeamStrengthenLB:getSize().width+10)
	end

	local memList = self:sortMemList()
    groupRequestList:setModel(Panel_GroupMemberItem)
    groupRequestList:setUpdateFunc(updateListViewItem)
    groupRequestList:setListView(ListView_GroupMember)
	groupRequestList:updateItems(#memList)
end

function GroupPNL:g_UpdataGroupLevel()
	
	if not self.widget then return end
	local guildLevel = g_DataMgr:getCsvConfigByOneKey("GuildLevel",g_Guild:getUserGuildLevel())
	-- --帮派经验 
	local exps = g_Guild:getGuildExp() --经验
	local costExp = guildLevel.CostExp --需要的经验
	
	local Image_GroupPNL = tolua.cast(self.widget:getChildByName("Image_GroupPNL"), "ImageView")
	Image_GroupPNL:setVisible(true)
	
	local Image_InfoPNL = tolua.cast(Image_GroupPNL:getChildByName("Image_InfoPNL"), "ImageView")
	--帮派名称
	local Label_GroupName = tolua.cast(Image_InfoPNL:getChildByName("Label_GroupName"), "Label")
	Label_GroupName:setText(g_Guild:getUserGuildName())
	--帮主
	local Label_PresidentNameLB = tolua.cast(Image_InfoPNL:getChildByName("Label_PresidentNameLB"), "Label")
	local Label_PresidentName = tolua.cast(Label_PresidentNameLB:getChildByName("Label_PresidentName"), "Label")
	local param = {
		name = g_Guild:getUserName(),breachLevel = g_Guild:getUserBreachlv(),lableObj = Label_PresidentName,
	}
	g_Guild:setLableByColor(param)
	
	Label_PresidentName:setPositionX(Label_PresidentNameLB:getSize().width)
	
	--帮派排名
	local Label_GroupRankLB = tolua.cast(Image_InfoPNL:getChildByName("Label_GroupRankLB"), "Label")
	local rank = g_Guild:getUserGuildRank()
	local Label_GroupRank = tolua.cast(Label_GroupRankLB:getChildByName("Label_GroupRank"), "Label")
	Label_GroupRank:setText(rank)
	
	--成员数量
	local Label_MemberCountLB = tolua.cast(Image_InfoPNL:getChildByName("Label_MemberCountLB"), "Label")
	local Label_MemberCount = tolua.cast(Label_MemberCountLB:getChildByName("Label_MemberCount"), "Label")
	Label_MemberCount:setText(g_Guild:getGuildCurMemNum().."/"..g_Guild:getGuildMaxMemNum())
	
	local curLevel = g_Guild:getUserGuildLevel()
	local Next_CSV_tbMsg = g_DataMgr:getCsvConfigByOneKey("GuildLevel", curLevel+1)
	
	local Label_GroupLevelLB = tolua.cast(Image_InfoPNL:getChildByName("Label_GroupLevelLB"), "Label")
	local Label_GroupLevel = tolua.cast(Image_InfoPNL:getChildByName("Label_GroupLevel"), "Label")
	Label_GroupLevel:setText(curLevel)
	
	local Label_GroupRemainExpLB = tolua.cast(Image_InfoPNL:getChildByName("Label_GroupRemainExpLB"), "Label")
	--需要多少经验可以升级
	local Label_GroupRemainExp = tolua.cast(Image_InfoPNL:getChildByName("Label_GroupRemainExp"), "Label")
	
	if Next_CSV_tbMsg.MemberLimit == 0 then
		Label_GroupRemainExpLB:setText(", ".._T("已达到最高等级！"))
		Label_GroupRemainExp:setVisible(false)
	else
		Label_GroupRemainExpLB:setText(_T("级, 升级还需经验"))
		local costExps = 0
		if exps < costExp then  costExps =	costExp - exps end
		Label_GroupRemainExp:setText(costExps)
		Label_GroupRemainExp:setVisible(true)
	end
	-- g_AdjustWidgetsPosition({Label_GroupRankLB,Label_GroupRank,Label_MemberCountLB,Label_MemberCount})
	
	-- if g_LggV.LanguageVer == eLanguageVer.LANGUAGE_viet_VIET  then --越南版
	Label_GroupRank:setPositionX(Label_GroupRankLB:getSize().width)
	local w = Label_GroupRank:getSize().width + 20
	g_AdjustWidgetsPosition({Label_GroupRankLB,Label_MemberCountLB}, w)
	Label_MemberCount:setPositionX( Label_MemberCountLB:getSize().width)
	-- end
	
	
	g_AdjustWidgetsPosition({Label_GroupLevelLB,Label_GroupLevel,Label_GroupRemainExpLB,Label_GroupRemainExp})
end

--聊天
function GroupPNL:groupChatView()
	if not self.widget then return end
	local Image_GroupPNL = tolua.cast(self.widget:getChildByName("Image_GroupPNL"), "ImageView")
	local Image_GroupChatPNL = tolua.cast(Image_GroupPNL:getChildByName("Image_GroupChatPNL"), "ImageView")
	GroupChat:init(Image_GroupChatPNL)
end
