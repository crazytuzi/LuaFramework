RegistModules("Clan/ClanConst")
RegistModules("Clan/Vo/ClanInfoVo")

RegistModules("Clan/ClanModel")
RegistModules("Clan/View/ClanCJPanel")
RegistModules("Clan/View/ClanSQItem")
RegistModules("Clan/View/ClanSQPanel")
RegistModules("Clan/View/ClanXXPanel")
RegistModules("Clan/View/ClanCYEventItem")
RegistModules("Clan/View/ClanCYEventPane")
RegistModules("Clan/View/ClanCYMemberItem")
RegistModules("Clan/View/ClanCYMemberPane")
RegistModules("Clan/View/ClanCYMemberSQItem")
RegistModules("Clan/View/ClanCYMemberSQPane")
RegistModules("Clan/View/ClanChangeJobPane")
RegistModules("Clan/View/ClanCYPanel")
RegistModules("Clan/View/ClanHDFightItem")
RegistModules("Clan/View/ClanHDFightPane")
RegistModules("Clan/View/ClanHDUpGradePane")
RegistModules("Clan/View/ClanHDContributeItem")
RegistModules("Clan/View/ClanHDContributePane")
RegistModules("Clan/View/ClanHDPanel")
RegistModules("Clan/View/ClanSkillCell")
RegistModules("Clan/View/ClanJNPane")
RegistModules("Clan/View/ClanJNPanel")
RegistModules("Clan/View/ClanGuildBossPane")

RegistModules("Clan/War/WarBaomingPane")
RegistModules("Clan/War/WarBeginPane")
RegistModules("Clan/War/WarJieshaoPane")
RegistModules("Clan/War/WarLeagueItemII")
RegistModules("Clan/War/WarLeagueItemI")
RegistModules("Clan/War/WarLeaguePane")
RegistModules("Clan/War/WarReadyPane")
RegistModules("Clan/War/WarUsualPane")
RegistModules("Clan/War/WarMemItem")
RegistModules("Clan/War/WarMemPane")
RegistModules("Clan/War/WarTaxPane")
RegistModules("Clan/War/WarRelifePane")

RegistModules("Clan/War/WarGiftAlert")
RegistModules("Clan/War/WarGiftItem")
RegistModules("Clan/War/WarGiftMall")

RegistModules("Clan/ClanMainPanel")

-- 氏族控制器
ClanCtrl = BaseClass(LuaController)
function ClanCtrl:GetInstance()
	if ClanCtrl.inst == nil then
		ClanCtrl.inst = ClanCtrl.New()
	end
	return ClanCtrl.inst
end

function ClanCtrl:__init()
	self:Config()
	self:InitEvent()
	self:RegistProto()
end
function ClanCtrl:Config()
	self.view = nil
	resMgr:AddUIAB("clan")
	self.model = ClanModel:GetInstance()
end
function ClanCtrl:Open(t)
	self:GetMainPanel():Open(tabIndex)
end
-- 获取主面板
function ClanCtrl:GetMainPanel()
	if not self:IsExistView() then
		self.view = ClanMainPanel.New(self)
	end
	return self.view
end
-- 判断主面板是否存在
function ClanCtrl:IsExistView()
	return self.view and self.view.isInited
end
local PreWarPanel = nil
function ClanCtrl:InitEvent()
	local updateCurView = function ()
		if not self:IsExistView() or not self.view:IsOpen() then return end
		self.view:Update()
	end
	self.clanInfoUpdated = self.model:AddEventListener(ClanConst.clanInfoUpdated, function ()
		GlobalDispatcher:DispatchEvent(EventName.CLAN_INFOCHANGED)
		updateCurView()
	end)
	self.membersChanged = self.model:AddEventListener(ClanConst.membersChanged, function ()
		updateCurView()
	end)

	self.cityWarMsgChanged = self.model:AddEventListener(ClanConst.cityWarMsgChanged, function ()
		local model = self.model
		local msg = model.cityWar
		-- msg.defendName -- 守城方
		-- msg.attackName -- 攻城方
		local state = msg.state--0：平常状态 1：报名状态  2：战前准备  3：开始状态
		local pane = nil
		if state == 0 then
			pane = WarUsualPane.New()
			PreWarPanel = WarUsualPane
		elseif state == 1 then
			pane = WarBaomingPane.New()
			PreWarPanel = WarBaomingPane
		elseif state == 2 then
			pane = WarReadyPane.New()
			PreWarPanel = WarReadyPane
		elseif state == 3 then
			pane = WarBeginPane.New()
			PreWarPanel = WarBeginPane
		end
		UIMgr.ShowCenterPopup(pane, nil, true)
	end)

end
function ClanCtrl:RegistProto()
	self:RegistProtocal("S_GetGuildList") --都护府列表返回
	self:RegistProtocal("S_GetGuild") --获取都护府信息返回
	self:RegistProtocal("S_CreateGuild") --创建都护府返回
	self:RegistProtocal("S_ModifyNotice") --修改公告
	self:RegistProtocal("S_GetGuildPlayerList") --获取成员列表
	self:RegistProtocal("S_ApplyGuild") --申请都护府返回
	self:RegistProtocal("S_QuickApply") --一键申请都护府
	self:RegistProtocal("S_GetApplyList") --申请列表
	self:RegistProtocal("S_AgreeApply") --同意申请
	self:RegistProtocal("S_RefuseApply") --拒绝申请
	self:RegistProtocal("S_ClearApplys") --清空申请列表
	self:RegistProtocal("S_AutoApply") --设置自动接受申请
	self:RegistProtocal("S_InviteJoin") --邀请进入都护府
	self:RegistProtocal("S_OfferInviteJoin") --通知被邀请者
	self:RegistProtocal("S_AgreeInviteJoin") --同意邀请进入
	self:RegistProtocal("S_QuitGuild") --退出都护府
	-- self:RegistProtocal("S_ChangeGuilder") --转让帮主
	self:RegistProtocal("S_KickGuild") --踢出帮派
	self:RegistProtocal("S_ChangeGuildRole") --任免职位


	self:RegistProtocal("S_UpgradeGuild") --升级帮派

	self:RegistProtocal("S_GetDonateTimes") --获取捐献各次数
	self:RegistProtocal("S_Donate") --捐献

	self:RegistProtocal("S_GetGuildWarList") --宣战信息列表
	self:RegistProtocal("S_GuildWar") --发起宣战
	self:RegistProtocal("S_UpgradeGuildSkill") --研发都护府技能
	self:RegistProtocal("S_StudyGuildSkill") --学习都护府技能
	self:RegistProtocal("S_GetGuildSkills") --获取已学习和研发的技能列表


	self:RegistProtocal("S_GetGuildFightData") --城战面板数据返回
	self:RegistProtocal("S_GetGuildFights") --已报名攻城列表返回
	self:RegistProtocal("S_GetUnions") --联盟列表返回
	self:RegistProtocal("S_ApplyGuildFight") --报名城战返回
	self:RegistProtocal("S_ApplyUnion") --申请联盟
	self:RegistProtocal("S_AgreeJoinUnion") --同意加入联盟
	self:RegistProtocal("S_SubmitItem") --提交攻城令

	self:RegistProtocal("S_GetRevenueData")--获取税收面板数据
	self:RegistProtocal("S_ReceiveRevenue")--领取税收
	self:RegistProtocal("S_ReceiveSalary")--领取俸禄
	self:RegistProtocal("S_ReceiveGift")--领取礼包
	self:RegistProtocal("S_GetGuildBuyData")--优惠购买记录
	self:RegistProtocal("S_GuildBuy")--优惠购买
	self:RegistProtocal("S_GuildFB")--凌烟阁

	self:RegistProtocal("S_GetManorData")--获取领地面板数据
	self:RegistProtocal("S_CallManorBoss")--成功召唤boss
	self:RegistProtocal("S_FeedManorBoss")--喂养boss

end

-- 响应
	local clanGuildBossPane =nil
	function ClanCtrl:S_GetManorData(buff)
		local msg = self:ParseMsg(guild_pb.S_GetManorData(),buff)
		-- msg.callNum -- 今日领地已召唤次数 -- msg.feedNum -- 当前喂养精华数量
		if clanGuildBossPane == nil then
			clanGuildBossPane = ClanGuildBossPane.New()
			UIMgr.ShowCenterPopup(clanGuildBossPane, function ()
				clanGuildBossPane=nil
			end, true)
		end
		clanGuildBossPane:Update(msg)

		print(">>>>>>>>>>>获取领地面板数据>", msg.callNum , msg.feedNum)
	end
	function ClanCtrl:S_CallManorBoss(buff)
		-- callNum++  feedNum=0
	end
	function ClanCtrl:S_FeedManorBoss(buff)
		local msg = self:ParseMsg(guild_pb.S_FeedManorBoss(),buff)
		-- msg.feedNum -- 当前喂养精华数量
		if clanGuildBossPane ~= nil then
			local t = {}
			local tmp = clanGuildBossPane.msg
			t.feedNum = msg.feedNum
			t.callNum = tmp.callNum
			clanGuildBossPane:Update(t)
		end
	end

	--城战面板数据返回
	function ClanCtrl:S_GetGuildFightData(buff)
		local msg = self:ParseMsg(guild_pb.S_GetGuildFightData(),buff)
		self.model:SetCityWar(msg)
		self.model:Fire(ClanConst.cityWarMsgChanged)
		-- print("城战面板数据返回")
	end
	--已报名攻城列表返回
	function ClanCtrl:S_GetGuildFights(buff)
		local msg = self:ParseMsg(guild_pb.S_GetGuildFights(),buff)
		-- local list = msg.guildFights
		-- v.guildName = 1 // 都护府名
		-- v.unionName = 2 // 联盟名
		-- v.createFlag = 3 // 是否盟主
		UIMgr.HidePopup()
		UIMgr.ShowCenterPopup(WarMemPane.New(msg.guildFights),function ()
			DelayCall(function ()
				UIMgr.ShowCenterPopup(PreWarPanel.New(), nil, true)
			end, 0.1)
		end, true)
		-- print("已报名攻城列表返回")
	end
	--联盟列表返回
	function ClanCtrl:S_GetUnions(buff)
		local msg = self:ParseMsg(guild_pb.S_GetUnions(),buff)
		-- msg.myUnionId --已加入的联盟
		-- msg.unions --联盟列表
		-- v.unionId = 1;  // 联盟编号
		-- v.unionName = 2;  // 联盟名
		-- v.applyFlag = 3;   // 是否已申请  1：是
		-- msg.applys --联盟列表
		-- v.guildId = 1;  // 都护府编号
		-- v.guildName = 2;  // 都护府名	d
		-- v.agreeFlag = 3;  // 是否有权操作同意 1：是
		self.model:SetUnionInfo(UnionInfo.New(msg))
		UIMgr.HidePopup()
		local pane = WarLeaguePane.New()
		local unionChanged = self.model:AddEventListener(ClanConst.unionChanged, function ()
			if pane then
				pane:Update(self.model.unionInfo)
			end
		end)
		UIMgr.ShowCenterPopup(pane,function ()
			self.model:RemoveEventListener(unionChanged)
			pane=nil
			DelayCall(function ()
				UIMgr.ShowCenterPopup(PreWarPanel.New(), nil, true)
			end, 0.1)
		end, true)
		-- print("联盟列表返回")
	end
	--报名城战返回
	function ClanCtrl:S_ApplyGuildFight(buff)
		--local msg = self:ParseMsg(guild_pb.S_ApplyGuildFight(),buff)
		UIMgr.Win_FloatTip("报名成功")
	end
	--申请联盟
	function ClanCtrl:S_ApplyUnion(buff)
		local msg = self:ParseMsg(guild_pb.S_ApplyUnion(),buff)
		local unionInfo = self.model.unionInfo
		if unionInfo == nil then return end
		local unions = unionInfo.unions
		for i=1,#unions do
			if unions[i].guildId == msg.unionId then
				unions[i].applyFlag = 1
				break
			end 
		end
		self.model:DispatchEvent(ClanConst.unionChanged)
		-- print("申请联盟")
		UIMgr.Win_FloatTip("申请联盟成功")
	end
	--同意加入联盟
	function ClanCtrl:S_AgreeJoinUnion(buff)
		local msg = self:ParseMsg(guild_pb.S_AgreeJoinUnion(),buff)
		local unionInfo = self.model.unionInfo
		if unionInfo == nil then return end
		local applys = unionInfo.applys
		local list = {}
		local x = 1
		for i=1,#applys do
			if applys[i].guildId ~= msg.guildId then
				list[x]=applys[i]
				x = x + 1
			end 
		end
		unionInfo.applys = list
		self.model:DispatchEvent(ClanConst.unionChanged)
		-- print("同意加入联盟")
		UIMgr.Win_FloatTip("已经同意加入联盟")
	end
	--提交攻城令
	function ClanCtrl:S_SubmitItem(buff)
		-- local msg = self:ParseMsg(guild_pb.S_SubmitItem(),buff)
		-- print("提交攻城令")
		UIMgr.Win_FloatTip("提交攻城令成功")
	end
	-- 获取税收面板数据
	function ClanCtrl:S_GetRevenueData(buff)
		local msg = self:ParseMsg(guild_pb.S_GetRevenueData(),buff)
		local model = self.model
		model:SetTax(msg)
		UIMgr.ShowCenterPopup(WarTaxPane.New(), nil, true)
	end
	-- 领取税收
	function ClanCtrl:S_ReceiveRevenue(buff)
		UIMgr.Win_FloatTip("领取税收成功")
		UIMgr.ShowCenterPopup(WarTaxPane.New(), nil, true)
	end
	-- 领取俸禄
	function ClanCtrl:S_ReceiveSalary(buff)
		local msg = self:ParseMsg(guild_pb.S_ReceiveSalary(),buff)
		local tax = self.model.tax or {}
		tax.salaryNum = msg.salaryNum -- 剩余俸禄份数
		UIMgr.Win_FloatTip("领取俸禄成功")
		UIMgr.ShowCenterPopup(WarTaxPane.New(), nil, true)
	end
	-- 领取礼包
	function ClanCtrl:S_ReceiveGift(buff)
		UIMgr.Win_FloatTip("领取礼包成功")
	end
	-- 优惠购买记录
	function ClanCtrl:S_GetGuildBuyData(buff)
		local msg = self:ParseMsg(guild_pb.S_GetGuildBuyData(),buff)
		UIMgr.HidePopup()
		self.model:SetBuyList( msg.guildBuys )
		UIMgr.ShowCenterPopup(WarGiftMall.New(), function ()
			DelayCall(function ()
				UIMgr.ShowCenterPopup(WarTaxPane.New(), nil, true)
			end, 0.1)
		end, true)
		-- print("优惠购买记录")
	end
	-- 优惠购买
	function ClanCtrl:S_GuildBuy(buff)
		local msg = self:ParseMsg(guild_pb.S_GuildBuy(),buff)
		local list = self.model.buyList
		local b = false
		for i=1,#list do
			if list[i].itemId == msg.guildBuy.itemId then
				list[i] = msg.guildBuy
				b = true
				break
			end
		end
		if not b then
			table.insert(list, msg.guildBuy)
		end
		-- print("优惠购买")
	end
	-- 凌烟阁
	function ClanCtrl:S_GuildFB(buff)
		local msg = self:ParseMsg(guild_pb.S_GuildFB(),buff)
		-- msg.type --1：开启  2：进入
		-- print("凌烟阁")
	end

	function ClanCtrl:S_GetGuildList(buff)
		local msg = self:ParseMsg(guild_pb.S_GetGuildList(),buff)
		self.model:UpdateGuildItems(CollectProtobufList(msg.guilds))
		if self.model.clanId == 0 then
			if not self:IsExistView() or not self.view:IsOpen() then return end
			self.view:Update()
		end
	end
	function ClanCtrl:S_GetGuild(buff)
		local msg = self:ParseMsg(guild_pb.S_GetGuild(),buff)
		self.model:SetBaseInfo(msg.guild, msg.roleId, msg.contribution)
	end
	function ClanCtrl:S_CreateGuild(buff)
		--创建都护府返回
	end
	function ClanCtrl:S_ModifyNotice(buff)
		local msg = self:ParseMsg(guild_pb.S_ModifyNotice(),buff)
		if self.model then
			self.model.clanInfo.notice = msg.notice
			if self:IsExistView() and self.view:IsOpen() then
				self.view:Update()
			end
		end
	end
	function ClanCtrl:S_GetGuildPlayerList(buff)
		local msg = self:ParseMsg(guild_pb.S_GetGuildPlayerList(),buff)
		self.model:UpdateMembers(CollectProtobufList(msg.guildPlayers), msg.onlineNum)
	end
	function ClanCtrl:S_ApplyGuild(buff)
		local msg = self:ParseMsg(guild_pb.S_ApplyGuild(),buff)
		self.model:DispatchEvent(ClanConst.sqResultList, {msg.guildId})
		-- print("申请都护府结果",msg.guildId)
	end
	function ClanCtrl:S_QuickApply(buff)
		local msg = self:ParseMsg(guild_pb.S_QuickApply(),buff)
		-- print("一键申请都护府结果",#msg.guildIds)
		self.model:DispatchEvent(ClanConst.sqResultList, msg.guildIds)
	end
	function ClanCtrl:S_GetApplyList(buff)
		local msg = self:ParseMsg(guild_pb.S_GetApplyList(),buff)
		self.model:UpdateApplyList(CollectProtobufList(msg.applyers))
	end
	function ClanCtrl:S_AgreeApply(buff)
		local msg = self:ParseMsg(guild_pb.S_AgreeApply(),buff)

	end
	function ClanCtrl:S_RefuseApply(buff)
		local msg = self:ParseMsg(guild_pb.S_RefuseApply(),buff)

	end
	function ClanCtrl:S_ClearApplys(buff)
		self.model:UpdateApplyList({})
	end
	function ClanCtrl:S_AutoApply(buff)
	end
	function ClanCtrl:S_InviteJoin(buff)
		local msg = self:ParseMsg(guild_pb.S_InviteJoin(),buff)

	end
	function ClanCtrl:S_OfferInviteJoin(buff)
		local msg = self:ParseMsg(guild_pb.S_OfferInviteJoin(),buff)

	end
	function ClanCtrl:S_AgreeInviteJoin(buff)
		local msg = self:ParseMsg(guild_pb.S_AgreeInviteJoin(),buff)

	end
	function ClanCtrl:S_QuitGuild(buff)
		self.model:ClearInfo()
	end
	-- function ClanCtrl:S_ChangeGuilder(buff)
	-- 	local msg = self:ParseMsg(guild_pb.S_ChangeGuilder(),buff)

	-- end
	function ClanCtrl:S_KickGuild(buff)
		local msg = self:ParseMsg(guild_pb.S_KickGuild(),buff)
		local members = self.model.members
		for i=1,#members do
			if members[i].playerId == msg.targetId then
				table.remove(members,i)
				break
			end
		end
		self.model:Fire(ClanConst.membersChanged)

	end
	function ClanCtrl:S_ChangeGuildRole(buff)
		local msg = self:ParseMsg(guild_pb.S_ChangeGuildRole(),buff)
		local members = self.model.members
		for i=1,#members do
			if members[i].playerId == msg.targetId then
				members[i].roleId = msg.newRoleId
				break
			end
		end
		self.model:Fire(ClanConst.membersChanged)
	end

	function ClanCtrl:S_UpgradeGuild(buff)
	end

	function ClanCtrl:S_GetDonateTimes(buff)
		local msg = self:ParseMsg(guild_pb.S_GetDonateTimes(),buff)
		self.model:UpdateDonate( CollectProtobufList(msg.donateTimes) )
		self.model:Fire(ClanConst.donateChanged)
	end
	function ClanCtrl:S_Donate(buff)
		local msg = self:ParseMsg(guild_pb.S_Donate(),buff)
		local donateList = self.model.donateList
		for i=1,#donateList do
			local item = donateList[i]
			item.times = item.times or 0
			if item.id == msg.id then
				item.times = item.times + 1
				self.model:Fire(ClanConst.donateChanged)
				return
			end
		end
	end

	function ClanCtrl:S_GetGuildWarList(buff)
		local msg = self:ParseMsg(guild_pb.S_GetGuildWarList(),buff)
		self.model:UpdateWarList( CollectProtobufList(msg.guilds))
		self.model:Fire(ClanConst.warListChanged)
	end
	function ClanCtrl:S_GuildWar(buff)
		local msg = self:ParseMsg(guild_pb.S_GuildWar(),buff)
		local list = self.model.warList
		for i=1,#list do
			if list[i].guildId == msg.guildId then
				list[i].endWarTime = msg.endWarTime
				self.model:Fire(ClanConst.warListChanged)
				return
			end
		end
		
	end
	function ClanCtrl:S_UpgradeGuildSkill(buff)
		local msg = self:ParseMsg(guild_pb.S_UpgradeGuildSkill(),buff)
		local list = self.model.devList
		local changed = false
		for i=1,#list do
			if list[i].type == msg.type then
				list[i].level = msg.level
				changed=true
				break
			end
		end
		if not changed then
			table.insert(list, {type=msg.type,level=msg.level})
		end
		-- print("研发都护府技能",msg.type, msg.level)
		if not self:IsExistView() or not self.view:IsOpen() then return end
		self.view:Update()
	end
	function ClanCtrl:S_StudyGuildSkill(buff)
		local msg = self:ParseMsg(guild_pb.S_StudyGuildSkill(),buff)
		local list = self.model.learnList
		local changed = false
		for i=1,#list do
			if list[i].type == msg.type then
				list[i].level = msg.level
				changed=true
				break
			end
		end
		if not changed then
			table.insert(list, {type=msg.type,level=msg.level})
		end
		-- print("学习都护府技能",msg.type, msg.level)
		if not self:IsExistView() or not self.view:IsOpen() then return end
		self.view:Update()
	end
	function ClanCtrl:S_GetGuildSkills(buff)
		local msg = self:ParseMsg(guild_pb.S_GetGuildSkills(),buff)
		-- print("已经学习与研发的",#msg.playerGuildSkills, #msg.guildSkills)
		self.model:LearnSkill( CollectProtobufList(msg.playerGuildSkills))--已学习技能列表
		self.model:DevSkill( CollectProtobufList(msg.guildSkills))--已研发技能列表
		if not self:IsExistView() or not self.view:IsOpen() then return end
		self.view:Update()
	end

-- 请求
	-- 获取领地面板数据
	function ClanCtrl:C_GetManorData()
		self:SendEmptyMsg(guild_pb,"C_GetManorData")
	end
	-- 进入领地
	function ClanCtrl:C_GuildManor()
		self:SendEmptyMsg(guild_pb,"C_GuildManor")
	end
	-- 召唤boss
	function ClanCtrl:C_CallManorBoss()
		self:SendEmptyMsg(guild_pb,"C_CallManorBoss")
	end
	-- 喂养boss
	function ClanCtrl:C_FeedManorBoss(itemNum)
		local msg=guild_pb.C_FeedManorBoss()
		msg.itemNum = itemNum
		self:SendMsg("C_FeedManorBoss", msg)
	end

	--城战面板数据
	function ClanCtrl:C_GetGuildFightData()
		-- print("城战面板数据")
		self:SendEmptyMsg(guild_pb,"C_GetGuildFightData")
	end
	--已报名攻城列表
	function ClanCtrl:C_GetGuildFights()
		-- print("已报名攻城列表")
		self:SendEmptyMsg(guild_pb,"C_GetGuildFights")
	end
	--联盟列表
	function ClanCtrl:C_GetUnions()
		-- print("联盟列表")
		self:SendEmptyMsg(guild_pb,"C_GetUnions")
	end
	--报名城战
	function ClanCtrl:C_ApplyGuildFight()
		-- print("报名城战")
		self:SendEmptyMsg(guild_pb,"C_ApplyGuildFight")
	end
	--创建联盟成功返回联盟列表
	function ClanCtrl:C_CreateUnion(unionName)
		-- print("创建联盟成功返回联盟列表")
		local msg=guild_pb.C_CreateUnion()
		msg.unionName = unionName
		self:SendMsg("C_CreateUnion", msg)
	end
	--申请联盟
	function ClanCtrl:C_ApplyUnion(unionId)
		-- print("申请联盟")
		local msg=guild_pb.C_ApplyUnion()
		msg.unionId = unionId
		self:SendMsg("C_ApplyUnion", msg)
	end
	--同意加入联盟
	function ClanCtrl:C_AgreeJoinUnion(guildId)
		-- print("同意加入联盟")
		local msg=guild_pb.C_AgreeJoinUnion()
		msg.guildId = guildId
		self:SendMsg("C_AgreeJoinUnion", msg)
	end
	--提交攻城令
	function ClanCtrl:C_SubmitItem(num)
		-- print("提交攻城令")
		local msg=guild_pb.C_SubmitItem()
		msg.itemNum = num
		self:SendMsg("C_SubmitItem", msg)
	end
	--进入城战
	function ClanCtrl:C_EnterGuildFight()
		-- print("进入城战")
		self:SendEmptyMsg(guild_pb,"C_EnterGuildFight")
	end
	-- 获取税收面板数据
	function ClanCtrl:C_GetRevenueData()
		-- print("获取税收面板数据")
		self:SendEmptyMsg(guild_pb,"C_GetRevenueData")
	end
	-- 领取税收
	function ClanCtrl:C_ReceiveRevenue()
		-- print("领取税收")
		self:SendEmptyMsg(guild_pb,"C_ReceiveRevenue")
	end
	-- 领取俸禄
	function ClanCtrl:C_ReceiveSalary()
		-- print("领取俸禄")
		self:SendEmptyMsg(guild_pb,"C_ReceiveSalary")
	end
	-- 领取礼包
	function ClanCtrl:C_ReceiveGift()
		-- print("领取礼包")
		self:SendEmptyMsg(guild_pb,"C_ReceiveGift")
	end
	-- 优惠购买记录
	function ClanCtrl:C_GetGuildBuyData()
		-- print("优惠购买记录")
		self:SendEmptyMsg(guild_pb,"C_GetGuildBuyData")
	end
	-- 优惠购买
	function ClanCtrl:C_GuildBuy(itemId, itemNum)
		-- print("优惠购买")
		local msg=guild_pb.C_GuildBuy()
		msg.itemId = itemId
		msg.itemNum = itemNum
		self:SendMsg("C_GuildBuy", msg)
	end
	-- 凌烟阁
	function ClanCtrl:C_GuildFB(type)
		-- print("凌烟阁")
		local msg=guild_pb.C_GuildFB()
		msg.type = type
		self:SendMsg("C_GuildFB", msg)
	end



	function ClanCtrl:C_GetGuildList() --都护府列表
		self:SendEmptyMsg(guild_pb,"C_GetGuildList")
	end

	function ClanCtrl:C_GetGuild() --获取都护府信息
		self:SendEmptyMsg(guild_pb,"C_GetGuild")
	end

	function ClanCtrl:C_CreateGuild(name, notice) --创建都护府
		local msg=guild_pb.C_CreateGuild()
		msg.guildName = name
		msg.notice = notice
		self:SendMsg("C_CreateGuild", msg)
	end

	function ClanCtrl:C_ModifyNotice(info) --修改公告
		local msg=guild_pb.C_ModifyNotice()
		msg.notice = info
		self:SendMsg("C_ModifyNotice", msg)
	end

	function ClanCtrl:C_GetGuildPlayerList() --获取成员列表
		local msg=guild_pb.C_GetGuildPlayerList()
		self:SendMsg("C_GetGuildPlayerList", msg)
	end

	function ClanCtrl:C_ApplyGuild(guildId) --申请都护府
		local msg=guild_pb.C_ApplyGuild()
		msg.guildId = guildId
		self:SendMsg("C_ApplyGuild", msg)
	end

	function ClanCtrl:C_QuickApply() --一键申请都护府
		self:SendEmptyMsg(guild_pb,"C_QuickApply")
	end

	function ClanCtrl:C_GetApplyList() --申请列表
		self:SendEmptyMsg(guild_pb,"C_GetApplyList")
	end

	function ClanCtrl:C_AgreeApply(id) --同意申请
		local msg=guild_pb.C_AgreeApply()
		msg.applyId = id
		self:SendMsg("C_AgreeApply", msg)
	end

	function ClanCtrl:C_RefuseApply(id) --拒绝申请
		local msg=guild_pb.C_RefuseApply()
		msg.applyId = id
		self:SendMsg("C_RefuseApply", msg)
	end

	function ClanCtrl:C_ClearApplys() --清空申请列表
		self:SendEmptyMsg(guild_pb, "C_ClearApplys")
	end

	function ClanCtrl:C_AutoApply(a,b,c) --设置自动接受申请
		local msg=guild_pb.C_AutoApply()
		msg.selected = a
		msg.autoMinLv = b
		msg.autoMaxLv = c
		self:SendMsg("C_AutoApply", msg)
	end

	function ClanCtrl:C_InviteJoin() --邀请进入都护府
		local msg=guild_pb.C_InviteJoin()
		self:SendMsg("C_InviteJoin", msg)
	end

	function ClanCtrl:C_AgreeInviteJoin() --同意邀请进入
		local msg=guild_pb.C_AgreeInviteJoin()
		self:SendMsg("C_AgreeInviteJoin", msg)
	end

	function ClanCtrl:C_QuitGuild() --退出都护府
		self:SendEmptyMsg(guild_pb,"C_QuitGuild")
	end

	-- function ClanCtrl:C_ChangeGuilder() --转让帮主
	-- 	local msg=guild_pb.C_ChangeGuilder()
	-- 	self:SendMsg("C_ChangeGuilder", msg)
	-- end

	function ClanCtrl:C_KickGuild(id) --踢出帮派
		local msg=guild_pb.C_KickGuild()
		msg.targetId = id
		self:SendMsg("C_KickGuild", msg)
	end

	function ClanCtrl:C_ChangeGuildRole(id, job) --任免职位
		local msg=guild_pb.C_ChangeGuildRole()
		msg.targetId = id
		msg.newRoleId = job
		self:SendMsg("C_ChangeGuildRole", msg)
	end

	function ClanCtrl:C_UpgradeGuild() --升级帮派
		self:SendEmptyMsg(guild_pb,"C_UpgradeGuild")
	end

	function ClanCtrl:C_GetDonateTimes() --获取捐献各次数
		self:SendEmptyMsg(guild_pb,"C_GetDonateTimes")
	end

	function ClanCtrl:C_Donate(id) --捐献
		local msg=guild_pb.C_Donate()
		msg.id = id
		self:SendMsg("C_Donate", msg)
	end

	function ClanCtrl:C_GetGuildWarList()
		self:SendEmptyMsg(guild_pb,"C_GetGuildWarList")
	end
	function ClanCtrl:C_GuildWar(id)
		local msg=guild_pb.C_GuildWar()
		msg.guildId = id
		self:SendMsg("C_GuildWar", msg)
	end
	function ClanCtrl:C_UpgradeGuildSkill(t)
		local msg=guild_pb.C_UpgradeGuildSkill()
		msg.type = t
		self:SendMsg("C_UpgradeGuildSkill", msg)
	end
	function ClanCtrl:C_StudyGuildSkill(t)
		local msg=guild_pb.C_StudyGuildSkill()
		msg.type = t
		self:SendMsg("C_StudyGuildSkill", msg)
	end
	function ClanCtrl:C_GetGuildSkills()
		self:SendEmptyMsg(guild_pb,"C_GetGuildSkills")
	end


-- 销毁
function ClanCtrl:__delete()
	ClanCtrl.inst = nil
	if self:IsExistView() then
		self.view:Destroy()
	end
	self.view = nil
	if self.model then
		self.model:Destroy()
		self.model = nil
	end
	PreWarPanel = nil
end