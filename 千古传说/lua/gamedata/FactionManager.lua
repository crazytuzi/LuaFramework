--[[
******帮派数据管理类*******

	-- by quanhuan
	-- 2015/10/23
	
]]

local FactionManager = class("FactionManager")


FactionManager.Leader = 1
FactionManager.DeputyLeader = 2
FactionManager.Member = 3

FactionManager.requestJoinFactionMsg = "FactionManager.requestJoinFactionMsg"
FactionManager.lookupOtherInfo = "FactionManager.lookupOtherInfo"

FactionManager.updateZhongYiLayer = "FactionManager.updateZhongYiLayer"

FactionManager.modifyNoticeUpdate = "FactionManager.modifyNoticeUpdate"
FactionManager.getCoinUpdate = "FactionManager.getCoinUpdate"
FactionManager.levelUpUpdate = "FactionManager.levelUpUpdate"
FactionManager.refreshWindow = "FactionManager.refreshWindow"
FactionManager.windowAllClose = "FactionManager.windowAllClose"
FactionManager.refreshWindowAndClose = "FactionManager.refreshWindowAndClose"
FactionManager.updateRedPoint = "FactionManager.updateRedPoint"

FactionManager.guildNotExist = "FactionManager.guildNotExist"

FactionManager.newGuildApply = "FactionManager.newGuildApply"

FactionManager.refreshAccountInfo = "FactionManager.refreshAccountInfo"

FactionManager.OpenZoneSucess = 'FactionManager.OpenZoneSucess'
FactionManager.ResetZoneSucess = 'FactionManager.ResetZoneSucess'

FactionManager.guildZonePassRank = 'FactionManager.guildZonePassRank'
FactionManager.guildCheckPointRank = 'FactionManager.guildCheckPointRank'
FactionManager.guildDpsAwardSucess = 'FactionManager.guildDpsAwardSucess'
FactionManager.bannerUpdate = 'FactionManager.bannerUpdate'



--1 禅让 2 提升为副帮主 3降级为成员 4请离 5弹劾 6解散 7 取消解散 8升级工会 9取消禅让 10取消弹劾
OperateType = {
	Demise 			= 1,
	DeputyLeader 	= 2,
	Member 			= 3,
	Leave			= 4,
	Impeach			= 5,
	dissolved		= 6,
	Canceldissolved	= 7,
	levelup			= 8,
	cancelDemise	= 9,
	cancelImpeach	= 10
}
GuildDynamicType = {
	JOIN=1,--加入帮会  name
	EXIT=2,--退出帮派 name
	LEVEL_UP=3,--升级 level
	WORSHIP = 4,--祭拜 权限,祭拜类型,繁荣度,经验
	DEMISE=5,--禅让 name
	ELEVATE=6,--提升为副帮主 name
	DEMOTION=7,--降级为成员 name
	FIRED=8,--请离 name
	CANCEL_DEMISE=9,--取消禅让
	DEMISE_SUCESS = 10,--禅让成功 name
	IMPEACHMENT = 11,--弹劾 name
	IMPEACHMENT_SUCESS = 12,--弹劾成功
	IMPEACHMENT_FAILURE = 13,--弹劾失败
	IMPEACHMENT_CANCEL = 14,--弹劾取消
	UPDATE_GUILD_DECLARATION = 15,--修改帮派宣言
	UPDATE_GUILD_NOTICE = 16,--修改帮派公告	
	GUILD_ZONE_FIRST_PASS = 17, --公会副本首次通关
	GUILD_ZONE_RANK = 18, --公会副本排名
	GUILD_KILL_BOSS = 19, --公会击杀BOSS
	OPEN_GUILD_ZONE = 20, --开启
	RESET_GUILD_ZONE = 21, --重置
	PRACTICE_STUDY = 22, --修炼场研究 type,level
	UPDATE_GUILD_NAME = 23, --修改公会名
	UPDATE_GUILD_BANNER = 24, --修改公会旗帜
}
local msgPostTemplate = localizable.FactionManager_msgPostTemplate
-- {
-- 	"帮主",
-- 	"副帮主",
-- 	"帮众"
-- }
local msgDrinkTemplate = localizable.FactionManager_msgDrinkTemplate
-- {
-- 	"八摆酒",
-- 	"饮血酒",
-- 	"盟书誓词"
-- }

local msgRecordTemplate = localizable.FactionManager_msgRecordTemplate
-- {
-- 	"欢迎%s加入帮派，让我们为日益强大的帮派欢呼吧",
-- 	"%s退出了帮派",
-- 	"通过所有人的不懈努力，帮派终于升到%d级！",
-- 	"%s%s进行了%s祭拜",
-- 	"%s被禅让为帮主，24小时后生效",
-- 	"%s被任命为副帮主",
-- 	"%s被降职为帮众",
-- 	"%s被请离帮派",
-- 	"帮主取消了禅让",
-- 	"恭喜%s成为新帮主，公会必将更加强大！",
-- 	"帮主长期没有上线，受到弹劾，24小时后生效",
-- 	"弹劾成功，恭喜%s成为新帮主",
-- 	"帮主%s及时上线，弹劾失败",
-- 	"%s取消弹劾",
-- 	"-----",
-- 	"-----",
-- 	'帮派完成第%d章节的首次通关，它将永久保存在排行榜中',
-- 	'本帮派后山第%d章节通关速度上升为第%d名',
-- 	'%s击杀了%s，帮派获得%s经验，%s繁荣度',
-- 	'%s在后山中开启了第%d章',
-- 	'%s在后山中重置了第%d章',
-- 	'修炼场%s开启',
-- 	'帮派改名为“%s”，真是个响亮的名字',
-- 	'帮派修改旗帜成功',
-- }

function FactionManager:ctor(data)

	--用户登录服务器推送公会个人消息,只有第一次推
	TFDirector:addProto(s2c.MY_GUILD_MEMBER_INFO, self, self.personalMsgReceive)
	--创建帮派消息回调-公会信息
	TFDirector:addProto(s2c.CREATE_GUILD, self, self.createFactionMsgReceive)
	TFDirector:addProto(s2c.GUILD_INFO, self, self.factionMsgReceive)	
	--公会成员信息回调
	TFDirector:addProto(s2c.GUILD_MEMBER_INFO_LIST, self, self.memberMsgReceive)

	--同意申请
	TFDirector:addProto(s2c.AGREED_APPLY, self, self.agreedJionMsgReceive)
	TFDirector:addProto(s2c.DELETE_APPLY, self, self.deleteJionMsgReceive)

	--公会申请
	TFDirector:addProto(s2c.APPLY_GUILD_SUCESS, self, self.requestJoinFactionMsgReceive)
	TFDirector:addProto(s2c.CANCEL_APPLY_SUCESS, self, self.requestCancelJoinFactionMsgReceive)

	--公会申请入帮列表
	TFDirector:addProto(s2c.APPLY_GUILD_INFO_LIST, self, self.requestOtherMemberListReceive)
	
	-- 忠义堂相关
	TFDirector:addProto(s2c.GUILD_STAT_INFO_REULT, self, self.onGuildStateInfo)
	TFDirector:addProto(s2c.WORSHIP_REULT, self, self.onWorship)
	TFDirector:addProto(s2c.OPEN_WORSHIP_BOX_REULT, self, self.onOpenWorshipBox)
	
	--退出帮派
	TFDirector:addProto(s2c.EXIT_GUILD, self, self.requestExitFactionReceive)
	--修改公告
	TFDirector:addProto(s2c.UPDATE_GUILD_INFO_SUCESS, self, self.modifyFactionNoticeReceive)

	TFDirector:addProto(s2c.MAKE_PLAYER_REULT, self, self.MakePlayerReceive)
	--任命
	TFDirector:addProto(s2c.OPERATE_GUILD_SUCESS, self, self.requestAppointReceive)

	--帮派动态
	TFDirector:addProto(s2c.GUILD_DYNAMIC, self,self.factionRecordReceive)

	--公会被操作
	TFDirector:addProto(s2c.OPTED_GUILD, self, self.optedFactionReceive)

	--领取好友结交奖励
	TFDirector:addProto(s2c.DRAW_MAKE_PLAYER_AWARD_REULT, self, self.requestCoinReceive)
	--推送结交奖励
	TFDirector:addProto(s2c.UPDATE_MAKE_COIN, self, self.serverPushCoin)

	--推送申请消息
	TFDirector:addProto(s2c.NEW_GUILD_APPLY, self, self.newGuildApplyReceive)
	

	TFDirector:addProto(s2c.SEND_GUILD_INVITATION_REULT, self, self.onGuildInvitation)
	TFDirector:addProto(s2c.GAIN_GUILD_INVITATION_REULT, self, self.onGainGuildInvitation)
	TFDirector:addProto(s2c.OPERATE_INVITATION_REULT, self, self.onOperateInvitation)
	TFDirector:addProto(s2c.GUILD_INVITATION_INFO, self, self.onGuildInvitationInfo)

	TFDirector:addProto(s2c.GUILD_DYNAMIC_INFO, self, self.recordTableReceive)

	--帮派副本
	TFDirector:addProto(s2c.GUILD_ZONE_INFO, self, self.onGuildZoneInfoReceive)
	TFDirector:addProto(s2c.RESET_ZONE_SUCESS, self, self.onResetZoneSucess)
	TFDirector:addProto(s2c.OPEN_ZONE_SUCESS, self, self.onOpenZoneSucess)
	TFDirector:addProto(s2c.GUILD_ZONE_PASS_INFO, self, self.onGuildZonePassRank)
	TFDirector:addProto(s2c.GUILD_CHECKPOINT_RANK_INFOS, self, self.onGuildCheckPointRank)
	TFDirector:addProto(s2c.DRAW_DPS_AWARD_SUCESS, self, self.onDrawDpsAwardSucess)
	TFDirector:addProto(s2c.GUILD_ZONE, self, self.onGuildZoneReceive)
	
	-- 帮派更名
	TFDirector:addProto(s2c.UPDATE_GUILD_NAME_RESULT, self, self.onReNameCom)

	--帮派修改旗帜
	TFDirector:addProto(s2c.UPDATE_GUILD_BANNER_ID_RESULT, self, self.onBannerUpdate)

	--新的公告信息
	TFDirector:addProto(s2c.NEW_NOTICE, self, self.onNewNoticeUpdate)

	--帮派邮件
	TFDirector:addProto(s2c.SEND_GUILD_MAIL_SUCESS, self, self.onGuildMailSucess)

	self:restart()

	self.isRequestInvite = false
end

function FactionManager:restart()           

	self.factionInfo = {}		--公会信息	
	self.personalInfo = {} 		--公会个人信息
	self.memberInfo = {}		--公会成员信息
	self.otherListInfo = {}		--公会申请入帮列表
	self.factionRecordTable = {}--公会动态
	self.secondlyProgress = 0	--忠义堂进度
	self.guildZoneInfo = {}		--帮派副本信息

	self.layerCount = false

	self.isRequestInvite = false
	self.isHaveRecord = nil

	self.mailInfo = {}
	self.popNoticeContent = nil
	--self:initBloodForZone()
end

function FactionManager:reConnect()
	self.mailInfo = {}
	self.popNoticeContent = nil
end
function FactionManager:reLoad()
	-- body
end



---=======================================================
-- 	↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓ 界面跳转操作 ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
---=======================================================
--创建帮派界面
function FactionManager:openCreateFaction()
	local layer  = require("lua.logic.faction.createFaction"):new()
	AlertManager:addLayer(layer,AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_NONE)
	AlertManager:show()
end
--主界面点击进入帮派按钮
function FactionManager:openFactionFromHomeIcon()

	-- print("self.personalInfo = ",self.personalInfo)
	-- print("self.factionInfo = ",self.factionInfo)
	if self:isJoinFaction() then
		self:requestFactionInfoWithOpen()
	else
		local layer  = require("lua.logic.faction.ApplyLayer"):new()
		AlertManager:addLayer(layer,AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_NONE)
		layer:initDataList()
		AlertManager:show()
	end
end
--打开帮派主界面
function FactionManager:openFactionHomeLayer()
	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.faction.FactionHomeLayer",AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_NONE)
	AlertManager:show() 
end
--打开帮派宣言或者公告的编辑界面
function FactionManager:showNoticePopLayer( okhandle,cancelhandle,param )
    local flieName = "lua.logic.faction.NoticePop"
    param = param or {}
    param.showtype = param.showtype or AlertManager.BLOCK_AND_GRAY_CLOSE;
    param.tweentype = param.tweentype or AlertManager.TWEEN_1;

    local layer = AlertManager:addLayerByFile(flieName,param.showtype,param.tweentype);
    layer:setBtnHandle(okhandle, cancelhandle);
    layer:setTitle(param.title);
    layer:setMsg(param.msg);
    layer:setContectMaxLength(param.MaxLength)
    AlertManager:show()
    return layer;
end
--打开聚义厅
function FactionManager:openFactinoBaseLayer()
	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.faction.FactinoBaseLayer",AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_NONE)
	self:setCurrIdentity("self")
	layer:loadData(1)
	AlertManager:show()
end
function FactionManager:openFactinoMemberLayer()
	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.faction.FactinoBaseLayer",AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_NONE)
	self:setCurrIdentity("self")
	layer:loadData(2)
	AlertManager:show()
end

--打开结交界面
function FactionManager:openMakeFriendsLayer()
	local layer  = require("lua.logic.faction.MakeFriends"):new()
	AlertManager:addLayer(layer,AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_NONE)
	layer:refreshWindow()
	AlertManager:show()
end
--打开忠义堂
function FactionManager:openZhongYiLayer()
	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.faction.ZhongYi",AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_NONE)
	AlertManager:show()
end
--打开帮派排行榜
function FactionManager:openFactionRankLayer()
	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.faction.RankingList",AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_NONE)
	layer:setEnterFirst(1)
	AlertManager:show()
end
--打开查看其它帮派信息
function FactionManager:lookupOtherFactinoInfo()
	local layer = AlertManager:addLayerToQueueAndCacheByFile("lua.logic.faction.FactinoBaseLayer",AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_NONE)
	self:setCurrIdentity("others")
	layer:loadData(1)
	AlertManager:show()
end
--打开任命界面
function FactionManager:openAppointLayer(playerId)
	local layer  = require("lua.logic.faction.AppointLayer"):new()
	layer:setPlayerId(playerId)
	AlertManager:addLayer(layer,AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_NONE)
	AlertManager:show()
end


---=======================================================
-- 	↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓帮派申请列表处理 ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
---=======================================================
function FactionManager:optedFactionReceive( event )
	local data = event.data
	if data.type == 1 then
		--同意加入帮派
		self:exitAndClearData()
		local currentScene = Public:currentScene()
    	if currentScene.__cname ~= "FightResultScene" and currentScene.__cname ~= "FightScene" then       	
       		-- toastMessage("恭喜您加入帮派！")
       		toastMessage(localizable.FactionManager_join_fation)
    	end		
		self:initPersonalInfo(data.guildId,3)
		RankManager:applyFlagSet({data.guildId}, false)
		
		if self.personalInfo.guildId >= 1 then
			self:requestFactionInfo()
			self:requestMemberInfo()
			self:requestGuildStateInfo()
			if self.personalInfo.competence == 1 or self.personalInfo.competence == 2 then
				self.requestOtherMemberList()		
			end
		end	
		if self.layerCount then
			AlertManager:closeAll()
			self:openFactionFromHomeIcon()
		end
	elseif data.type == 2 then
		--请离帮派
		-- toastMessage("你被请离了帮派")
		toastMessage(localizable.FactionManager_leave_fation)
		if self.layerCount then
			AlertManager:closeAll()
		end
		self:initPersonalInfo(0,3)
		self:exitAndClearData()			
	end
end
--申请公会
function FactionManager:requestJoinFaction( guildIds )
	TFDirector:send(c2s.APPLY_GUILD,{{guildIds}})
	showLoading();
end
function FactionManager:requestJoinFactionMsgReceive( event )
	local guildIds = event.data.guildIds
	if guildIds then
		RankManager:applyFlagSet(guildIds, true)
		TFDirector:dispatchGlobalEventWith(FactionManager.requestJoinFactionMsg ,{guildIds})
		self.personalInfo.applyCount = self.personalInfo.applyCount + #guildIds
	end
	
	hideLoading();
end
--取消申请
function FactionManager:requestCancelJoinFaction( guildIds )
	TFDirector:send(c2s.CANCEL_APPLY,{guildIds})
	self.CancelJoinGuildIds = guildIds
	showLoading();
end
function FactionManager:requestCancelJoinFactionMsgReceive( event )
	if self.CancelJoinGuildIds then
		RankManager:applyFlagSet({self.CancelJoinGuildIds}, false)
		self.CancelJoinGuildIds = nil
		self.personalInfo.applyCount = self.personalInfo.applyCount - 1
	end
	TFDirector:dispatchGlobalEventWith(FactionManager.requestJoinFactionMsg ,{guildIds})
	hideLoading();
end
--一键申请公会
function FactionManager:requestJoinFactionOneKey(ids)
	TFDirector:send(c2s.APPLY_GUILD,{ids})
	showLoading();
end
function FactionManager:getRequestOneKeyTimes()
	local times = 10 - self.personalInfo.applyCount
	return times
end
--创建公会
function FactionManager:sendMsgCreateFaction( name, bannerStr)
	TFDirector:send(c2s.CREATE_GUILD,{name,bannerStr})
	showLoading();
end

function FactionManager:initPersonalInfo(guildId, post)
	self.personalInfo = self.personalInfo or {}
	self.personalInfo.guildId = guildId
	self.personalInfo.competence = post
	self.personalInfo.dedication = self.personalInfo.dedication or 0 
	self.personalInfo.worship = self.personalInfo.worship or 0
	self.personalInfo.coin = self.personalInfo.coin or 0
	self.personalInfo.applyCount = self.personalInfo.applyCount or 0
	self.personalInfo.makePlayers = self.personalInfo.makePlayers or {}
	self.personalInfo.drawTreasureChests = self.personalInfo.drawTreasureChests or {}
	self.personalInfo.lastOutTime = self.personalInfo.lastOutTime or 0

end
--创建公会成功并打开公会主界面
function FactionManager:createFactionMsgReceive( event )
	self:exitAndClearData()
	self.factionInfo = event.data.info or {}
	self:initPersonalInfo(self.factionInfo.guildId, 1)

	if self.personalInfo.guildId >= 1 then
		self:requestFactionInfo()
		self:requestMemberInfo()
		self:requestGuildStateInfo()
		if self.personalInfo.competence == 1 or self.personalInfo.competence == 2 then
			self.requestOtherMemberList()		
		end
	end

	-- print("factionInfo = ",self.factionInfo)
	-- print("personalInfo = ",self.personalInfo)

    -- toastMessage("恭喜您创建了自己的帮派！")
    toastMessage(localizable.FactionManager_create_fation)
    AlertManager:closeAll()
    self:openFactionHomeLayer()

	hideLoading();
end
function FactionManager:requestOtherFactinoInfo(guildId)
	TFDirector:send(c2s.GAIN_GUILD_INFO,{guildId})
	self.otherGuildId = true
	showLoading();
end




---=======================================================
-- 	↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓公会基本信息处理 ↓↓↓↓↓↓↓↓↓↓↓↓
---=======================================================
function FactionManager:updateDedication( dedication )
	self.personalInfo.dedication = dedication
end
--后台主动推送个人信息
function FactionManager:personalMsgReceive( event )
	self:exitAndClearData()
	self.personalInfo = event.data or {}
	self.personalInfo.makePlayers = event.data.makePlayers or {}
	self.personalInfo.drawTreasureChests = event.data.drawTreasureChests or {}
	self:initPersonalInfo(event.data.guildId, event.data.competence)

	MainPlayer:updateDedication( self.personalInfo.dedication )

	self.isHaveRecord = nil
	
	if self.personalInfo.guildId >= 1 then
		self:requestFactionInfo()
		self:requestMemberInfo()
		self:requestGuildStateInfo()
		if self.personalInfo.competence == 1 or self.personalInfo.competence == 2 then
			self.requestOtherMemberList()		
		end
	end

	-- print("get personalInfo = ",self.personalInfo)
end
function FactionManager:getPersonalInfo()
	return self.personalInfo
end
--请求公会信息
function FactionManager:requestFactionInfo()
	if not self.personalInfo.guildId then
		print("公会不存在")
		return
	end
	local guildId = self.personalInfo.guildId
	TFDirector:send(c2s.GAIN_GUILD_INFO,{guildId})
	showLoading();
end
--请求公会信息并打开公会主界面
function FactionManager:requestFactionInfoWithOpen()
	if not self.personalInfo.guildId then
		print("公会不存在")
		return
	end
	self.needOpenLayer = true
	local guildId = self.personalInfo.guildId
	TFDirector:send(c2s.GAIN_GUILD_INFO,{guildId})
	showLoading();
end
--接收公会信息
function FactionManager:factionMsgReceive( event )
	
	self.factionInfo = event.data or {}

	hideLoading();

	if self.otherGuildId then
		self.otherGuildId = false
		TFDirector:dispatchGlobalEventWith(FactionManager.lookupOtherInfo ,{})
		return
	end

	if self.needOpenLayer then
		self:openFactionHomeLayer()
	else
		TFDirector:dispatchGlobalEventWith(FactionManager.refreshWindow ,{})
	end

	local openLevel = FactionPracticeManager:getPracticeOpenLevel() or 0
	local currLevel = self.factionInfo.level or 0
    if currLevel >= openLevel then
       FactionPracticeManager:requestGuildPracticeInfo(false)
    end    

	self.needOpenLayer = false
end
function FactionManager:getFactionInfo()
	return self.factionInfo
end
--退出帮派
function FactionManager:requestExitFaction()
	TFDirector:send(c2s.EXIT_GUILD,{})
	showLoading();
end
function FactionManager:requestExitFactionReceive(event)
	
	self.personalInfo.lastOutTime = MainPlayer:getNowtime()*1000
	hideLoading();

	TFDirector:dispatchGlobalEventWith(FactionManager.windowAllClose,{})
	self:initPersonalInfo(0,3)
	self:exitAndClearData()
end
--修改公告、宣言
function FactionManager:modifyFactionNotice(msg)
	self.modifyStr = msg
	TFDirector:send(c2s.UPDATE_GUILD_INFO,msg)
	showLoading()
end
function FactionManager:modifyFactionNoticeReceive(event)

	print("modifyFactionNoticeReceive = ++++++++++++++++++++++++++++++++++")
	if self.modifyStr then
		if self.modifyStr[1] == 1 then
			self.factionInfo.notice = self.modifyStr[2]
		elseif self.modifyStr[2] == 2 then
			self.factionInfo.declaration = self.modifyStr[2]
		end
		self.modifyStr = nil
	end
	toastMessage(localizable.FactionManager_modify)
	TFDirector:dispatchGlobalEventWith(FactionManager.modifyNoticeUpdate,{})
	hideLoading()
end




---=======================================================
-- 	↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓公会成员列表处理 ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
---=======================================================
--请求公会成员信息
function FactionManager:requestMemberInfo()
	TFDirector:send(c2s.GAIN_GUILD_MEMBER,{})
	showLoading();
end
--接收公会成员信息
function FactionManager:memberMsgReceive( event )
	self.memberInfo = event.data.infos or {}
	-- print("self.memberInfo = ",self.memberInfo)
	hideLoading();
	TFDirector:dispatchGlobalEventWith(FactionManager.refreshWindow ,{})
	TFDirector:dispatchGlobalEventWith(FactionManager.updateRedPoint ,{})
end
function FactionManager:getMemberInfo()

	local function sortOffTime( a,b )
		if a.lastLoginTime > b.lastLoginTime then
			return false
		else
			return true
		end	
	end

	local function sortPower( a,b )
		if a.power > b.power then
			return true
		elseif a.power < b.power then
			return false
		else
			return sortOffTime(a,b)
		end
	end

	local sortFunc = function(a, b) 
  		if a.competence<b.competence then
			return true
		elseif a.competence > b.competence then
			return false
		else
			return sortPower(a,b)
		end
  	end
	table.sort(self.memberInfo, sortFunc )

	return self.memberInfo
end
--结交
function FactionManager:requestMakePlayer(type)
	self.makePlayerType = type
	local msg = {type, self.makePlayerId}
	TFDirector:send(c2s.MAKE_PLAYER,msg)
	showLoading();
end
function FactionManager:MakePlayerReceive(event)
	hideLoading();
	local index = #self.personalInfo.makePlayers + 1
	self.personalInfo.makePlayers[index] = self.makePlayerId

	self:updateMemberMakePlayerTimes(self.makePlayerId)
	if self.makePlayerType then
		local tili = {5,10,20}
		-- toastMessage("结交成功,增加"..tili[self.makePlayerType].."点体力")
		toastMessage(stringUtils.format(localizable.FactionManager_jiejiao_fation, tili[self.makePlayerType]))
	end
	self.makePlayerType = nil	
	TFDirector:dispatchGlobalEventWith(FactionManager.refreshWindowAndClose ,{})	
end
function FactionManager:makePlayerIdSet( playerId )
	self.makePlayerId = playerId
	self:openMakeFriendsLayer()
end
function FactionManager:isTimesToMakePlayer()
	local currCount = self:getCurrMakePlayerTimes()
	local maxCount = self:getTotalMakePlayerTimes()
	-- print("currCount = ",currCount)
	-- print("maxCount = ",maxCount)
	if currCount >= maxCount then
		return false
	end
	return true
end
function FactionManager:isMakePlayerDoneWithID( playerId )
	for _,v in pairs(self.personalInfo.makePlayers) do
		if v == playerId then
			return true
		end
	end
	return false
end
function FactionManager:isCanMakePlayerWithType( Type )
	local currType = self:getCurrMakePlayerType()
	if Type <= currType then
		return true
	else
		return false
	end
end
function FactionManager:getMemberMakePlayerTimes( playerId )
	self.memberInfo = self.memberInfo or {}
	local times = 0
	for _,v in pairs(self.memberInfo) do
		if v.playerId == playerId then
			times = self:getFactionMaxMember(self.factionInfo.level) - 1
			times = times - v.makedCoubt
			if times < 0 then
				times = 0
			end
			return times
		end
	end
	return times
end
function FactionManager:updateMemberMakePlayerTimes( playerId )
	self.memberInfo = self.memberInfo or {}
	for i=1,#self.memberInfo do
		if self.memberInfo[i].playerId == playerId then
			self.memberInfo[i].makedCoubt = self.memberInfo[i].makedCoubt + 1
		end
	end
end
--任命
function FactionManager:AppointPlayerIdSet( playerId )
	self:openAppointLayer(playerId)
end
function FactionManager:requestAppoint(type, playerId)
	self.AppointType = type
	self.AppointId = playerId
	local msg = {type, self.AppointId}
	TFDirector:send(c2s.OPERATE_GUILD,msg)
	showLoading();
end

function FactionManager:requestAppointReceive(event)
	--print("1 禅让 2 提升为副帮主 3降级为成员 4请离 5弹劾 6解散 7 取消解散 8升级工会 9取消禅让 10取消弹劾")
	if self.AppointType == OperateType.Demise then
		--禅让
		local currTime = MainPlayer:getNowtime()
		currTime = currTime + 24*60*60 - 1
		self.factionInfo.state = 1
		self.factionInfo.operateId = self.AppointId
		self.factionInfo.operateTime = currTime*1000
		-- toastMessage("您已经将帮主之位禅让于人，请等待24小时")
		toastMessage(localizable.FactionManager_shanrang_fation)
		TFDirector:dispatchGlobalEventWith(FactionManager.refreshWindowAndClose ,{})
	elseif self.AppointType == OperateType.cancelDemise then
		--取消禅让
		self.factionInfo.state = 0
		self.factionInfo.operateId = 0
		self.factionInfo.operateTime = 0
		-- toastMessage("您已取消禅让")
		toastMessage(localizable.FactionManager_shanrang_qx)
		TFDirector:dispatchGlobalEventWith(FactionManager.refreshWindow ,{})
	elseif self.AppointType == OperateType.DeputyLeader then
		--副帮主
		self:setMemberPost(self.AppointId, 2)
		-- toastMessage("任命成功")
		toastMessage(localizable.FactionManager_rengming)
		TFDirector:dispatchGlobalEventWith(FactionManager.refreshWindowAndClose ,{})
	elseif self.AppointType == OperateType.Member then
		--帮众
		-- toastMessage("任命成功")
		toastMessage(localizable.FactionManager_rengming)
		self:setMemberPost(self.AppointId, 3)
		TFDirector:dispatchGlobalEventWith(FactionManager.refreshWindowAndClose ,{})
	elseif self.AppointType == OperateType.Leave then
		--请离
		self:deleteMember(self.AppointId)
		TFDirector:dispatchGlobalEventWith(FactionManager.refreshWindowAndClose ,{})
	elseif self.AppointType == OperateType.Impeach then
		--弹劾
		local currTime = MainPlayer:getNowtime()
		currTime = currTime + 24*60*60 - 1
		self.factionInfo.state = 3
		self.factionInfo.operateId = self.AppointId
		self.factionInfo.operateTime = currTime*1000
		TFDirector:dispatchGlobalEventWith(FactionManager.refreshWindow ,{})
	elseif self.AppointType == OperateType.dissolved then
		--解散
		local currTime = MainPlayer:getNowtime()
		currTime = currTime + 24*60*60 - 1
		self.factionInfo.state = 2
		self.factionInfo.operateId = self.AppointId
		self.factionInfo.operateTime = currTime*1000
		-- toastMessage("帮派将于24小时后解散")
		toastMessage(localizable.FactionManager_24_jiesan)
		TFDirector:dispatchGlobalEventWith(FactionManager.refreshWindow ,{})		
	elseif self.AppointType == OperateType.Canceldissolved then
		--取消解散
		self.factionInfo.state = 0
		self.factionInfo.operateId = 0
		self.factionInfo.operateTime = 0
		-- toastMessage("已终止解散帮派")
		toastMessage(localizable.FactionManager_zhongzhi_jiesan)
		TFDirector:dispatchGlobalEventWith(FactionManager.refreshWindow ,{})
	elseif self.AppointType == OperateType.levelup then
		local maxExp = FactionManager:getFactionLevelUpExp(self.factionInfo.level+1)
		self.factionInfo.exp = self.factionInfo.exp - maxExp
		self.factionInfo.level = self.factionInfo.level + 1
		TFDirector:dispatchGlobalEventWith(FactionManager.levelUpUpdate ,{})
	elseif self.AppointType == OperateType.cancelImpeach then
		--10取消弹劾
		self.factionInfo.state = 0
		self.factionInfo.operateId = 0
		self.factionInfo.operateTime = 0
		TFDirector:dispatchGlobalEventWith(FactionManager.refreshWindow ,{})
	end
	hideLoading();	
end
function FactionManager:setMemberPost(playerId, post)
	for i = 1,#self.memberInfo do
		if self.memberInfo[i].playerId == playerId then
			self.memberInfo[i].competence = post
			return
		end
	end
end
--结交奖励
function FactionManager:requestCoin()
	TFDirector:send(c2s.DRAW_MAKE_PLAYER_AWARD,{})
	showLoading();
end
function FactionManager:requestCoinReceive(event)

	local coin = self.personalInfo.coin
	self.personalInfo.coin = 0
	TFDirector:dispatchGlobalEventWith(FactionManager.getCoinUpdate ,{coin})
	hideLoading()
end
function FactionManager:serverPushCoin(event)
	self.personalInfo.coin = event.data.coin
	TFDirector:dispatchGlobalEventWith(FactionManager.updateRedPoint ,{})
end

---=======================================================
-- 	↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓公会动态列表处理 ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
---=======================================================
function FactionManager:factionRecordReceive( event )
	-- print("event.data = ",event.data)

	local info = event.data
	local msgTab = string.split(info.mess,',')
	local factionName = msgTab[1]
	for i=1,#msgTab do
		msgTab[i] = msgTab[i+1]
	end

	local currDate = os.date("*t", math.floor(msgTab[1]/1000))
	local time = self:timeFormat(math.floor(msgTab[1]/1000))
	local textTemplete = msgRecordTemplate[info.type]
	local textSub = nil
	local textColor = ccc3(61,61,61)

	if info.type == GuildDynamicType.UPDATE_GUILD_NOTICE then
		self.factionInfo.notice = msgTab[2]
		for i=3,#msgTab do
			self.factionInfo.notice = self.factionInfo.notice..","..msgTab[i]
		end
		if self:getGonggaoView() == false then
			self.noticeRed = true
		end
		if event.dataFromSelf == nil then
			-- toastMessage("内容已修改")
			-- toastMessage(localizable.FactionManager_modify)
			TFDirector:dispatchGlobalEventWith(FactionManager.updateRedPoint ,{})			
		end
		return
	elseif info.type == GuildDynamicType.UPDATE_GUILD_DECLARATION then
		return
	end

	if info.type == GuildDynamicType.WORSHIP then
		--祭拜 祭拜 权限,祭拜类型,繁荣度,经验
		local post = tonumber(msgTab[2])
		local drinktype = tonumber(msgTab[3])
		textSub = stringUtils.format(textTemplete, msgPostTemplate[post], msgTab[6], msgDrinkTemplate[drinktype])
		if drinktype == 3 then
			textColor = ccc3(190,74,48)
			local playerInfo = {}
			playerInfo.playerId = msgTab[7]
			playerInfo.roleId = msgTab[10]
			playerInfo.quality = msgTab[9]
			playerInfo.name = msgTab[6]
			playerInfo.vipLevel = msgTab[8]
			playerInfo.level = msgTab[11]
			playerInfo.headPicFrame = msgTab[13]
			playerInfo.competence = post
			playerInfo.icon = msgTab[12] or playerInfo.roleId
			if event.dataFromSelf == nil then
				self:pushFactionMsgToChat(textSub, msgTab[1], factionName, playerInfo)
			end
		end
	elseif info.type == GuildDynamicType.GUILD_ZONE_RANK then
		textSub = stringUtils.format(textTemplete, msgTab[2], msgTab[3])
	elseif info.type == GuildDynamicType.GUILD_KILL_BOSS then
		textSub = stringUtils.format(textTemplete, msgTab[2], msgTab[4], msgTab[5], msgTab[6])
	elseif info.type == GuildDynamicType.OPEN_GUILD_ZONE then
		textSub = stringUtils.format(textTemplete, msgTab[2], tonumber(msgTab[3]))
	elseif info.type == GuildDynamicType.RESET_GUILD_ZONE then
		textSub = stringUtils.format(textTemplete, msgTab[2], tonumber(msgTab[3]))
	elseif info.type == GuildDynamicType.PRACTICE_STUDY then
		local practiceType = tonumber(msgTab[2])
		local practiceLevel = tonumber(msgTab[3])
		local practiceData = GuildPracticeData:getPracticeInfoByTypeAndLevel( practiceType,practiceLevel,1 )
		if practiceLevel == 1 then
			-- textSub = string.format('修炼场%s开启', practiceData.title)
			textSub = stringUtils.format(localizable.FactionManager_open_practice, practiceData.title)
		else
			-- textSub = string.format('修炼场%s等级研究到%d级', practiceData.title,practiceLevel)
			textSub = stringUtils.format(localizable.FactionManager_uplevel_practice, practiceData.title,practiceLevel)
		end
	else
		textSub = stringUtils.format(textTemplete, msgTab[2])
	end

	--push data
	local spilt,spiltTime = self:checkSpiltState( currDate )
	if spilt then
		self:pushMsgToRecordTable( spiltTime, textColor, spilt )
		spilt = false
	end
	self:pushMsgToRecordTable( time..textSub, textColor, spilt )
	if event.dataFromSelf then
		return
	end

	if info.type == GuildDynamicType.ELEVATE then
		local playerId = tonumber(msgTab[3])
		if playerId == MainPlayer:getPlayerId() then
			self.personalInfo.competence = 2
		end
		self:setMemberPost(playerId, 2)
		TFDirector:dispatchGlobalEventWith(FactionManager.refreshWindow ,{})
	elseif info.type == GuildDynamicType.DEMOTION then
		local playerId = tonumber(msgTab[3])
		if playerId == MainPlayer:getPlayerId() then
			self.personalInfo.competence = 3
		end
		self:setMemberPost(playerId, 3)
		TFDirector:dispatchGlobalEventWith(FactionManager.refreshWindow ,{})
	elseif (info.type == GuildDynamicType.DEMISE_SUCESS) then
		local playerId = tonumber(msgTab[3])
		for i=1,#(self.memberInfo) do
			if self.memberInfo[i].competence == 1 then
				self.memberInfo[i].competence = 3
				if self.memberInfo[i].playerId == MainPlayer:getPlayerId() then
					self.personalInfo.competence = 3
				end
			end
		end

		self:setMemberPost(playerId, 1)
		if playerId == MainPlayer:getPlayerId() then
			self.personalInfo.competence = 1
		end
		self.factionInfo.state = 0
		self:pushFactionMsgToChat(textSub, math.floor(msgTab[1]),factionName)
		TFDirector:dispatchGlobalEventWith(FactionManager.refreshWindow ,{})
	elseif info.type == GuildDynamicType.IMPEACHMENT_SUCESS then
		local playerId = tonumber(msgTab[3])
		for i=1,#(self.memberInfo) do
			if self.memberInfo[i].competence == 1 then
				self.memberInfo[i].competence = 3
			end
		end
		self:setMemberPost(playerId, 1)
		if playerId == MainPlayer:getPlayerId() then
			self.personalInfo.competence = 1
		end
		self.factionInfo.state = 0
		self:pushFactionMsgToChat(textSub, math.floor(msgTab[1]),factionName)
		TFDirector:dispatchGlobalEventWith(FactionManager.refreshWindow ,{})	
	elseif info.type == GuildDynamicType.DEMISE then
		self:pushFactionMsgToChat(textSub, math.floor(msgTab[1]),factionName)
	elseif info.type == GuildDynamicType.CANCEL_DEMISE then
		self:pushFactionMsgToChat(textSub, math.floor(msgTab[1]),factionName)
	elseif info.type == GuildDynamicType.IMPEACHMENT then
		self:pushFactionMsgToChat(textSub, math.floor(msgTab[1]),factionName)
	elseif info.type == GuildDynamicType.IMPEACHMENT_FAILURE then
		self:pushFactionMsgToChat(textSub, math.floor(msgTab[1]),factionName)
	elseif info.type == GuildDynamicType.IMPEACHMENT_CANCEL then
		self:pushFactionMsgToChat(textSub, math.floor(msgTab[1]),factionName)
	elseif info.type == GuildDynamicType.GUILD_ZONE_FIRST_PASS then
		self:pushFactionMsgToChat(textSub, math.floor(msgTab[1]),factionName)
	elseif info.type == GuildDynamicType.GUILD_ZONE_RANK then
		self:pushFactionMsgToChat(textSub, math.floor(msgTab[1]),factionName)
	elseif info.type == GuildDynamicType.OPEN_GUILD_ZONE then
		self:pushFactionMsgToChat(textSub, math.floor(msgTab[1]),factionName)
	elseif info.type == GuildDynamicType.RESET_GUILD_ZONE then
		self:pushFactionMsgToChat(textSub, math.floor(msgTab[1]),factionName)
	elseif info.type == GuildDynamicType.GUILD_KILL_BOSS then
		-- local strTemplete = string.format('%s完成了第%d章%s的击杀，奖励已通过邮件发送！', msgTab[2], tonumber(msgTab[3]), msgTab[4])
		local strTemplete = stringUtils.format(localizable.FactionManager_kill_boss, msgTab[2], tonumber(msgTab[3]), msgTab[4])

		self:pushFactionMsgToChat(strTemplete, math.floor(msgTab[1]),factionName)
		if self.factionInfo then
			self.factionInfo.exp = self.factionInfo.exp + tonumber(msgTab[5])
			self.factionInfo.boom = self.factionInfo.boom + tonumber(msgTab[6])
		end
	elseif info.type == GuildDynamicType.PRACTICE_STUDY then
		local practiceType = tonumber(msgTab[2])
		local practiceLevel = tonumber(msgTab[3])
		local practiceData = GuildPracticeData:getPracticeInfoByTypeAndLevel( practiceType,practiceLevel,1 )
		if practiceLevel == 1 then
			-- strTemplete = string.format('修炼场%s开启，大家可以去修炼了', practiceData.title)
			strTemplete = stringUtils.format(localizable.FactionManager_open_practice2, practiceData.title)
		else
			-- strTemplete = string.format('修炼场%s等级研究到%d级，大家可以去升级了', practiceData.title,practiceLevel)
			strTemplete = stringUtils.format(localizable.FactionManager_uplevel_practice2, practiceData.title,practiceLevel)
		end
		self:pushFactionMsgToChat(strTemplete, math.floor(msgTab[1]),factionName)
	elseif info.type == GuildDynamicType.UPDATE_GUILD_NAME then		
		-- strTemplete = string.format('帮派改名为“%s”，真是个响亮的名字，大家让他扬名江湖吧', msgTab[2])
		strTemplete = stringUtils.format(localizable.FactionManager_modify_qizhi, msgTab[2])		
		self:pushFactionMsgToChat(strTemplete, math.floor(msgTab[1]),factionName)

		TFDirector:dispatchGlobalEventWith(FactionManager.refreshWindow ,{})
	elseif info.type == GuildDynamicType.UPDATE_GUILD_BANNER then		
		strTemplete = localizable.FactionManager_modify_qizhi2 --'帮派修改旗帜成功，各位大侠快去围观吧'
		self:pushFactionMsgToChat(strTemplete, math.floor(msgTab[1]),factionName)
	end
end

--请求帮派动态信息
function FactionManager:requestRecordTable()
	if self.isHaveRecord then
		return
	end
	self.spiltLastDate = nil
	self.factionRecordTable = nil
	self.factionRecordTable = {}

	TFDirector:send(c2s.GAIN_GUILD_DYNAMIC,{})
	showLoading();
end

function FactionManager:recordTableReceive( event )
	hideLoading()
	
	self.isHaveRecord = true
	local dataTable = event.data.dyns
	if dataTable then
		for i=1,#dataTable do
			local event = {}
			event.data = dataTable[i]
			event.dataFromSelf = true
			self:factionRecordReceive(event)
		end
	end

	TFDirector:dispatchGlobalEventWith(FactionManager.refreshAccountInfo ,{})
end

--获取帮派动态表
function FactionManager:getFactionRecordTable()
	local recordList = TFArray:new()
	if self.factionRecordTable then
		for _,v in pairs(self.factionRecordTable) do
			recordList:push(v)
		end
	end
	
	return recordList
end

function FactionManager:pushMsgToRecordTable( str, color, spilt )
	local index = #self.factionRecordTable + 1
	if index == 1 then
		self.factionRecordTable[1] = {}
		self.factionRecordTable[1].str = str
		self.factionRecordTable[1].color = color
		self.factionRecordTable[1].spilt = spilt
	else
		local dataTbl = {}
		dataTbl.str = str
		dataTbl.color = color
		dataTbl.spilt = spilt
		table.insert(self.factionRecordTable, 1, dataTbl)
	end
end
function FactionManager:resetLatestSpilt(list)
	if list and list:length() > 0 then
		local timeStr = self.latestSpilt.year..'-'..self.latestSpilt.month..'-'..self.latestSpilt.day
		local dataTbl = {}
		dataTbl.str = timeStr
		dataTbl.color = 0
		dataTbl.spilt = true
		list:pushFront(dataTbl)
	end	
end

function FactionManager:checkSpiltState( currDate )
	self.latestSpilt = currDate
	if self.spiltLastDate == nil then
		self.spiltLastDate = currDate
		return false
	end
	 
	if (currDate.year == self.spiltLastDate.year and currDate.month == self.spiltLastDate.month) and currDate.day == self.spiltLastDate.day then
		return false
	end
	local timeStr = self.spiltLastDate.year..'-'..self.spiltLastDate.month..'-'..self.spiltLastDate.day
	self.spiltLastDate = currDate
	return true,timeStr
end

--帮派动态推送到聊天窗口
function FactionManager:pushFactionMsgToChat(textSub, timestamp, factionName, playerInfo)

	local msg = {}
	msg.content = textSub
	msg.quality = 5
	msg.timestamp = timestamp
	msg.name = factionName	
	msg.vipLevel = self.factionInfo.level
	msg.level = self.factionInfo.level
	msg.inviteMsg = true
	msg.chatType = EnumChatType.FactionNotice
	if playerInfo then
		msg.chatType = EnumChatType.Gang
		msg.playerId = tonumber(playerInfo.playerId)
		msg.roleId = tonumber(playerInfo.roleId)
		msg.quality = tonumber(playerInfo.quality)
		msg.name = playerInfo.name
		msg.vipLevel = tonumber(playerInfo.vipLevel)
		msg.level = tonumber(playerInfo.level)
		msg.competence = tonumber(playerInfo.competence)
		msg.icon = tonumber( playerInfo.icon )
		msg.headPicFrame = tonumber( playerInfo.headPicFrame )
	end
	ChatManager:addGang(msg)
end

---=======================================================
-- 	↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓申请入帮列表处理 ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
---=======================================================
--请求列表
function FactionManager:requestOtherMemberList()
	TFDirector:send(c2s.GAIN_GUILD_APPLY,{})
	showLoading();
end
--接收列表信息
function FactionManager:requestOtherMemberListReceive(event)
	self.otherListInfo = event.data.list or {}
	-- print(self.otherListInfo)
	self.otherListInfoNew = false
	TFDirector:dispatchGlobalEventWith(FactionManager.refreshWindow ,{})
	TFDirector:dispatchGlobalEventWith(FactionManager.updateRedPoint ,{})
	hideLoading()
end
--获取列表信息
function FactionManager:getOtherMemberList()
	return self.otherListInfo
end
--同意加入
function FactionManager:agreenJoin( playerId,playerName )
	self.agreenJoinId = playerId
	self.agreenJoinName = playerName
	TFDirector:send(c2s.AGREED_APPLY,{playerId})
	showLoading();
end
function FactionManager:agreedJionMsgReceive(event)
	if self.agreenJoinId then
		for i,v in pairs(self.otherListInfo) do
			if v.playerId == self.agreenJoinId then
				table.remove(self.otherListInfo, i)
			end
		end
		self.agreenJoinId = nil
		if #self.otherListInfo > 0 then
			self.otherListInfoNew = true
		else
			self.otherListInfoNew = false
		end
		if self.agreenJoinName then
			-- toastMessage(self.agreenJoinName.."成功加入帮派")
			toastMessage(stringUtils.format(localizable.FactionManager_xx_join_fation, self.agreenJoinName))
		end
	end
	TFDirector:dispatchGlobalEventWith(FactionManager.refreshWindow ,{})
	hideLoading();
end
--忽略加入
function FactionManager:deleteJoin( playerId )
	self.deleteJoinId = playerId
	TFDirector:send(c2s.DELETE_APPLY,{playerId})
	showLoading();
end
function FactionManager:deleteJionMsgReceive( event )

	-- print("deleteJionMsgReceive = ",event.data)
	local playerId = event.data.playerId

	if playerId == 0 then
		self.otherListInfo = nil
		self.otherListInfo = {}
		self.otherListInfoNew = false
		-- toastMessage("已清空申请消息")
		toastMessage(localizable.FactionManager_clear_msg)

	elseif playerId then
		for i,v in pairs(self.otherListInfo) do
			if v.playerId == playerId then
				table.remove(self.otherListInfo, i)
			end
		end
		if #self.otherListInfo > 0 then
			self.otherListInfoNew = true
		else
			self.otherListInfoNew = false
		end
	end
	self.deleteJoinId = nil
	TFDirector:dispatchGlobalEventWith(FactionManager.refreshWindow ,{})
	hideLoading();
end

function FactionManager:requestGuildStateInfo()
	-- print("FactionManager:requestGuildStateInfo()")
	TFDirector:send(c2s.GUILD_STAT_INFO, {})
	showLoading()
end

function FactionManager:onGuildStateInfo(event)
	event.data.userdata = "info"
	TFDirector:dispatchGlobalEventWith(FactionManager.updateZhongYiLayer, event.data)
	hideLoading()

	self.currWorshipCount = event.data.worshipCount
	self.secondlyProgress = event.data.secondlyProgress
end

function FactionManager:worship(index)
	-- print("FactionManager:worship()", index)
	TFDirector:send(c2s.WORSHIP, {index})
	showLoading()
end

function FactionManager:onWorship(event)
	event.data.userdata = "worship"
	TFDirector:dispatchGlobalEventWith(FactionManager.updateZhongYiLayer, event.data)
	hideLoading()
	play_jibaichenggong()
end

function FactionManager:OpenWorshipBox(index)
	-- print("FactionManager:OpenWorshipBox()", index)
	TFDirector:send(c2s.OPEN_WORSHIP_BOX, {index})
	showLoading()
end

function FactionManager:onOpenWorshipBox(event)
	event.data.userdata = "worshipbox"
	TFDirector:dispatchGlobalEventWith(FactionManager.updateZhongYiLayer, event.data)
	hideLoading()
	play_lingqu()
end

function FactionManager:sendGuildInvitation(playerId)
	self.invitePlayerId = playerId

	-- print("FactionManager:sendGuildInvitation(playerId)", playerId)
	TFDirector:send(c2s.SEND_GUILD_INVITATION, {playerId})
	showLoading()
end

function FactionManager:onGuildInvitation(event)
	-- print("FactionManager:onGuildInvitation(event)")
	hideLoading()
	-- toastMessage("邀请成功")
	toastMessage(localizable.FactionManager_invite_suc)

	ChatManager:addInviteFactionData(self.invitePlayerId)
end

function FactionManager:gainGuildInvitation()
	print("FactionManager:gainGuildInvitation()")

	if not self.isRequestInvite then
		TFDirector:send(c2s.GAIN_GUILD_INVITATION, {})
	end
end

function FactionManager:onGainGuildInvitation(event)
	print("FactionManager:onGainGuildInvitation(event)")
	-- print(event.data)

	self.isRequestInvite = true

	if event.data.infos and #event.data.infos > 0 then
		ChatManager:clearGangChat()

		for _, v in pairs(event.data.infos) do
			local msg = {}
			msg.chatType = 2
			msg.content = stringUtils.format(localizable.FactionManager_invite_req, v.name, v.guildName) --"“" .. v.name .. "”邀请您加入"..v.guildName.."，是否同意？"
			msg.playerId = v.playerId
			msg.roleId = v.profession
			msg.quality = v.quality
			msg.name = v.name
			msg.vipLevel = v.vip
			msg.level = v.level
			msg.timestamp = v.createTime
			msg.guildId = v.guildId
			msg.guildName = v.guildName
			msg.systemMsg = true
			msg.showInviteBtns = true
			msg.showGuidNameOrPosition = 1
			msg.icon = v.icon
			msg.headPicFrame = v.headPicFrame

			ChatManager:addGang(msg)
		end
	end
end

function FactionManager:operateInvitation(type, guildId)
	self.invitationOperateType = type
	self.invitationOperateGuildID = guildId

	print("FactionManager:operateInvitation(type, guildId)", type, guildId)
	TFDirector:send(c2s.OPERATE_INVITATION, {type, guildId})
	showLoading()
end

function FactionManager:onOperateInvitation(event)
	print("FactionManager:onOperateInvitation(event)")

	if self.invitationOperateType == 1 then
		self:exitAndClearData()
		-- toastMessage("恭喜您加入帮派！")
   		toastMessage(localizable.FactionManager_join_fation)
		ChatManager:hideGuildInviteButtons(0)
		self:initPersonalInfo(self.invitationOperateGuildID, 3)

		RankManager:applyFlagSet({self.invitationOperateGuildID}, false)
		if self.personalInfo.guildId >= 1 then
			self:requestFactionInfo()
			self:requestMemberInfo()
			self:requestGuildStateInfo()
			if self.personalInfo.competence == 1 or self.personalInfo.competence == 2 then
				self.requestOtherMemberList()		
			end
		end	

	else
		ChatManager:hideGuildInviteButtons(self.invitationOperateGuildID)
	end

	hideLoading()
end

function FactionManager:newGuildApplyReceive(event)
	self.otherListInfoNew = true	
	TFDirector:dispatchGlobalEventWith(FactionManager.newGuildApply, {})
	TFDirector:dispatchGlobalEventWith(FactionManager.updateRedPoint, {})
end

function FactionManager:onGuildInvitationInfo(event)
	print("FactionManager:onGuildInvitationInfo(event)")
	-- print(event.data)

	if event.data then
		local msg = {}
		msg.chatType = 2
		msg.content = stringUtils.format(localizable.FactionManager_invite_req, event.data.name, event.data.guildName) --"“" .. event.data.name .. "”邀请您加入"..event.data.guildName.."，是否同意？"
		msg.playerId = event.data.playerId
		msg.roleId = event.data.profession
		msg.quality = event.data.quality
		msg.name = event.data.name
		msg.vipLevel = event.data.vip
		msg.level = event.data.level
		msg.timestamp = event.data.createTime
		msg.guildId = event.data.guildId
		msg.guildName = event.data.guildName
		msg.systemMsg = true
		msg.showInviteBtns = true
		msg.showGuidNameOrPosition = 1
		msg.icon = event.data.icon
		msg.headPicFrame = event.data.headPicFrame

		ChatManager:addGang(msg)
	end
end

---=======================================================
-- 	↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓ 功能函数相关 ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
---=======================================================
--初始化公告的默认显示
function FactionManager:initGonggaoView()
	if self.gonggaoView == nil then
		self.gonggaoView = true
	end
end
function FactionManager:setGonggaoView(stats)
	self.gonggaoView = stats
end
function FactionManager:getGonggaoView()
	return self.gonggaoView
end

--处理不同身份查看帮派信息
function FactionManager:setCurrIdentity( identity )
	self.identity = identity
end
function FactionManager:getCurrIdentity()
	return self.identity
end

--查看是否加入了帮派
function FactionManager:isJoinFaction()
	if self.personalInfo.guildId == nil then
		return false
	end
	if self.personalInfo.guildId == 0 then
		return false
	else
		return true
	end
	return false
end

--检测是否能够加入公会
function FactionManager:checkCanJoinFaction()
	local nowTime = MainPlayer:getNowtime()
	local delayTime = nowTime - math.floor(self.personalInfo.lastOutTime/1000)
	-- local dTime = nowTime - delayTime
	local oneDay = 24*60*60
	if delayTime > oneDay then
		return true
	else
		return false
	end
end

--获取自己的职位
function FactionManager:getPostInFaction()
	
	if self.personalInfo.competence == 1 then
		return FactionManager.Leader
	elseif self.personalInfo.competence == 2 then
		return FactionManager.DeputyLeader
	else
		return FactionManager.Member
	end

end
--获取当前的结交次数
function FactionManager:getCurrMakePlayerTimes()
	local info = self.personalInfo
	if info == nil then
		return 0
	end
	if info.makePlayers then
		local times = #info.makePlayers
		return times
	end
	return 0
end
--获取总共的结交次数
function FactionManager:getTotalMakePlayerTimes()
    local vipTable = {}
    for v in VipData:iterator() do
        if v.benefit_code == 7001 then
            local idx = #vipTable + 1
            vipTable[idx] = v.vip_level
        end
    end

	if MainPlayer:getVipLevel() >= vipTable[3] then
		return 3
	elseif MainPlayer:getVipLevel() >= vipTable[2] then
		return 2
	else
		return 1
	end
end
--获取当前能够结交的结交方式
function FactionManager:getCurrMakePlayerType()

    local vipTable = {}
    for v in VipData:iterator() do
        if v.benefit_code == 7000 then
            local idx = #vipTable + 1
            vipTable[idx] = v.vip_level
        end
    end

	if MainPlayer:getVipLevel() >= vipTable[3] then
		return 3
	elseif MainPlayer:getVipLevel() >= vipTable[2] then
		return 2
	else
		return 1
	end
end

-- 祭拜后更新数据
function FactionManager:updateDataAfterWorship(addExp, addBoom, addDedication, worship)
	self.factionInfo.exp = self.factionInfo.exp + addExp
	self.factionInfo.boom = self.factionInfo.boom + addBoom
	self.personalInfo.dedication = self.personalInfo.dedication + addDedication
	self.personalInfo.worship = worship
end

function FactionManager:updateDataAfterOpenWorshipBox(idx)
	self.personalInfo.drawTreasureChests = self.personalInfo.drawTreasureChests or {}
	table.insert(self.personalInfo.drawTreasureChests, idx)
end

function FactionManager:timeFormat(time)
	local nowDate = os.date("*t", time)
	local month = nowDate.month
	if month < 10 then
		month = "0"..month
	end
	local day = nowDate.day
	if day < 10 then
		day = "0"..day
	end
	local hour = nowDate.hour
	if hour < 10 then
		hour = "0"..hour
	end
	local min = nowDate.min
	if min < 10 then
		min = "0"..min
	end

	local textString = "["..month.."-"..day.." "..hour..":"..min.."] "

	return textString
end

function FactionManager:getCurrServerTime()
	local time = MainPlayer:getNowtime() + 8*60*60
	return time
end
function FactionManager:deleteMember(playerId)
	for i,v in pairs(self.memberInfo) do
		if v.playerId == playerId then
			table.remove(self.memberInfo, i)
			return
		end
	end
end
function FactionManager:getMemberPost( playerId )
	for i = 1,#self.memberInfo do
		if self.memberInfo[i].playerId == playerId then
			return self.memberInfo[i].competence
		end
	end
	return FactionManager.Member
end
function FactionManager:getDeputyLeaderNum()
	local count = 0
	for i = 1,#self.memberInfo do
		if self.memberInfo[i].competence == FactionManager.DeputyLeader then
			count = count + 1
		end
	end
	return count
end
function FactionManager:getMemberNum()
	local count = #self.memberInfo
	return count	
end
function FactionManager:getFactionLevelUpExp(level)
	local lenth = FactionLevelUpData:size()
	if level >= lenth then
		level = lenth
	end
	local expInfo = FactionLevelUpData:getObjectAt(level)

	return expInfo.exp
end
function FactionManager:getFactionMaxMember(level)
	local lenth = FactionLevelUpData:size()
	if level >= lenth then
		level = lenth
	end	
	local expInfo = FactionLevelUpData:getObjectAt(level)
	return expInfo.max_member_num
end
function FactionManager:getMemberInfoByPlayerid( playerId )
	for k,v in pairs(self.memberInfo) do
		if v.playerId == playerId then
			return v
		end
	end
	return nil
end
function FactionManager:isCanImpeach()

	for k,v in pairs(self.memberInfo) do
		if v.competence == 1 then
			local currTime = MainPlayer:getNowtime()
			currTime = currTime - math.floor(v.lastLoginTime/1000)
			if currTime >= (7*24*60*60) then
				return true
			else
				return false
			end
		end
	end
	return false
end

function FactionManager:addLayerInFaction()
	self.layerCount = true
end
function FactionManager:deleteLayerInFaction()
	self.layerCount = false
end

function FactionManager:resetDataInfo_24()
	self.personalInfo.applyCount = 0
	self.personalInfo.makePlayers = {}
	self.personalInfo.worship = 0
	self.personalInfo.drawTreasureChests = {}
	self.currWorshipCount = 0

	for i=1,#self.memberInfo do
		self.memberInfo[i].makedCoubt = 0
	end
end

function FactionManager:canViewRedPointMakeFriends()
	-- print(self.personalInfo)

	if self.personalInfo.coin then
		if self.personalInfo.coin > 0 then
			return true
		end
	end
	local maxTimes = self:getTotalMakePlayerTimes()
	local currTimes = self:getCurrMakePlayerTimes()
	currTimes = maxTimes - currTimes
	if currTimes <= 0 then 
		return false
	end

	local function isInMakePlayerList( playerId )
		for _,v in pairs(self.personalInfo.makePlayers) do
			if v == playerId then
				return false
			end
		end
		return true
	end
	-- print("self.factionInfo.level = ",self.factionInfo.level)
	local maxMakeTimes = self:getFactionMaxMember(self.factionInfo.level) - 1
	for _,v in pairs(self.memberInfo) do
		if ((v.level > MainPlayer:getLevel()) and ((maxMakeTimes - v.makedCoubt) > 0)) and isInMakePlayerList(v.playerId) then
			return true
		end
	end
	return false
end

function FactionManager:canViewRedPointApply()
	if self.personalInfo.competence ~= 1 and self.personalInfo.competence ~= 2 then
		return false
	end
	if self.otherListInfoNew then
		return true
	elseif #self.otherListInfo > 0 then
		return true
	end
	return false
end

function FactionManager:canViewRedLevelUp()
	if self.personalInfo.competence ~= 1 and self.personalInfo.competence ~= 2 then
		return false
	end
    local info = self:getFactionInfo()
    local currExp = info.exp
    local maxExp = self:getFactionLevelUpExp(info.level+1)
    if info.level >= 6 then
        return false
    end
    if currExp >= maxExp then
        return true
    end
	return false
end

function FactionManager:canViewRedPointInHomeLayer()
	if self:canViewRedPointMakeFriends() then
		return true
	end
	if self:canViewRedPointApply() then
		return true
	end
	if self:canViewRedLevelUp() then
		return true
	end

	return false
end
function FactionManager:canViewRedPointInMainLayer()

	-- print('self.factionInfo.guildId = ',self.factionInfo)
	if self.personalInfo.guildId == nil or self.personalInfo.guildId == 0 then
		return false
	end
	if self.factionInfo.guildId == nil or self.factionInfo.guildId == 0 then
		return false
	end
	if self.noticeRed then
		return true
	end
	if self:canRedPointWorShip() then
		return true
	end

	if self:canRedPointHouShan() then
		return true
	end	

	if FactionPracticeManager:canRedPointPractice() then
		return true
	end	

	if self:canViewRedPointInHomeLayer() then
		return true
	end
	return false
end

function FactionManager:getTimeString( times ,viewType)
	local str
	if viewType == 2 then
		if times <= 0 then
			str = "0:0"
		else
			local hour = math.floor(times/3600)
			local min = math.floor((times - hour*3600)/60)
			str = hour..":"..min
		end
	else
		if times <= 0 then
			str = "00:00:00"
		else
			local hour = math.floor(times/3600)
			local min = math.floor((times - hour*3600)/60)
			local sec = math.floor((times - hour*3600 - min*60))
			str = string.format("%02d",hour)..":"..string.format("%02d",min)..":"..string.format("%02d",sec)
		end
	end
	return str
end
function FactionManager:getTimeStringChinese( times )
	local str
	if times <= 0 then
		-- str = "0小时0分钟"
		str = stringUtils.format(localizable.FactionManager_time, 0 , 0)
	else
		local hour = math.floor(times/3600)
		local min = math.floor((times - hour*3600)/60)
		local sec = math.floor((times - hour*3600 - min*60))
		-- str = hour.."小时"..min.."分钟"
		str = stringUtils.format(localizable.FactionManager_time, hour , min)
	end
	return str
end

function FactionManager:exitAndClearData()

	self.factionRecordTable = nil
	self.factionRecordTable = {}
	self.otherListInfo = nil
	self.otherListInfo = {}
	self.factionInfo = nil
	self.factionInfo = {}
	self.memberInfo = nil
	self.memberInfo = {}
	self.guildZoneInfo = {}
	self.mailInfo = {}
end
function FactionManager:canRedPointWorShip()

	if self.factionInfo.level == nil then
		return false
	end

	--是否能够领取宝箱
    local canCheckPoint = {}
    local worshipPlanConfig = WorshipPlanConfig:getDataByLevel(1)
    local boxPlan = string.split(worshipPlanConfig.box1,',')
    canCheckPoint[1] = tonumber(boxPlan[2])
    boxPlan = string.split(worshipPlanConfig.box2,',')
    canCheckPoint[2] = tonumber(boxPlan[2])
    boxPlan = string.split(worshipPlanConfig.box3,',')
    canCheckPoint[3] = tonumber(boxPlan[2])

    local function searchFun( exp )
        for i=1,#self.personalInfo.drawTreasureChests do
            if self.personalInfo.drawTreasureChests[i] == exp then
                return false
            end
        end
        return true
    end    

    for i=1, #canCheckPoint do
        if self.secondlyProgress >= canCheckPoint[i] then
            if searchFun(canCheckPoint[i]) then
                return true
            end
        end
    end

	if self:isCanWorShip() then
		return true
	end    

    return false
end

function FactionManager:getWorshipMaxCount()
	return self:getFactionMaxMember(self.factionInfo.level)
end

--是否达到当日最大祭拜次数
function FactionManager:isCanWorShip()
	local maxMember = self:getWorshipMaxCount()
	self.currWorshipCount = self.currWorshipCount or 0
	if self.currWorshipCount < maxMember and self.personalInfo.worship == 0 then
		return true
	end
	return false
end

function FactionManager:getShopLevel()
	if self.factionInfo and self.factionInfo.level then
		local level = self.factionInfo.level
		local lenth = FactionLevelUpData:size()
		if level >= lenth then
			level = lenth
		end
		local expInfo = FactionLevelUpData:getObjectAt(level)
		if expInfo then
			return expInfo.treasure_level
		end
	end
	return 0
end

function FactionManager:getZhongyiLevel()
	if self.factionInfo and self.factionInfo.level then
		local level = self.factionInfo.level
		local lenth = FactionLevelUpData:size()
		if level >= lenth then
			level = lenth
		end
		local expInfo = FactionLevelUpData:getObjectAt(level)
		if expInfo then
			return expInfo.secondly_level
		end
	end
	return 0
end

function FactionManager:getShopOpenLevel()
	for v in FactionLevelUpData:iterator() do
		if v.treasure_level ~= 0 then
			return v.id
		end
	end
	return 0
end

function FactionManager:printByte(str)
	local stringIndex = 1
	local strLength = string.len(str)
	local currStr = ""
	
	for i=1,strLength do
		if stringIndex > strLength then
			-- print('输出完成',currStr)  
			return currStr
		end
		local c = string.sub(str,stringIndex,stringIndex)
		local b = string.byte(c)
		-- print(b)
		if b >= 240 then
            stringIndex = stringIndex + 4
        elseif b >= 224 then
        	if b~= 237 then
            	currStr = currStr..string.sub(str,stringIndex,stringIndex+2)
        	end
            stringIndex = stringIndex + 3
		elseif b >= 192 then
            currStr = currStr..string.sub(str,stringIndex,stringIndex+1)
            stringIndex = stringIndex + 2
        else
            currStr = currStr..c
            stringIndex = stringIndex + 1
        end
	end 
	-- print('输出完成',currStr)  
	return currStr     		
end

---=======================================================
-- 	↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓ 帮派副本 ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
---=======================================================

--打开后山
function FactionManager:openChapterListLayer()
	local layer  = require("lua.logic.faction.ChapterListLayer"):new()
	AlertManager:addLayer(layer,AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_NONE)
	layer:loadData()
	AlertManager:show()
end

--获取帮派繁荣度
function FactionManager:getFactionBoom()
	if self.factionInfo and self.factionInfo.boom then
		return self.factionInfo.boom
	end
	return 0
end

function FactionManager:useFactionBoom( boom )
	self.factionInfo = self.factionInfo or {}
	self.factionInfo.boom = self.factionInfo.boom or 0
	self.factionInfo.boom = self.factionInfo.boom - boom
	if self.factionInfo.boom < 0 then
		self.factionInfo.boom = 0
	end
end

function FactionManager:addFactionBoom( boom )
	self.factionInfo = self.factionInfo or {}
	self.factionInfo.boom = self.factionInfo.boom or 0
	self.factionInfo.boom = self.factionInfo.boom + boom
end

--进入后山
function FactionManager:enterHoushanLayer()
	local openLevel = self:getHoushanOpenLevel()
    if openLevel == 0 then
        -- toastMessage("即将开放，敬请期待！")
        toastMessage(localizable.common_function_will_open)
        return
    elseif self.factionInfo.level < openLevel then
        -- toastMessage("后山需要帮派等级"..openLevel.."级")
        toastMessage(stringUtils.format(localizable.FactionManager_houshan_dengji,openLevel))
        return
    end    
    self:requestGuildZoneInfo( 'lua.logic.faction.ChapterListLayer' )    
end

--请求副本信息
function FactionManager:requestGuildZoneInfo( fileName )

	self.needOpenChapterListLayer = fileName
	TFDirector:send(c2s.GUILD_ZONE_INFO,{})
	showLoading()
end
function FactionManager:onGuildZoneInfoReceive( event )
	hideLoading()
	self.guildZoneInfo = event.data or {}

	if self.needOpenChapterListLayer then
		local layer  = require(self.needOpenChapterListLayer):new()
		AlertManager:addLayer(layer,AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_NONE)
		layer:loadData()
		AlertManager:show()
		self.needOpenChapterListLayer = nil
	else	
		TFDirector:dispatchGlobalEventWith(HoushanManager.EVENT_UPDATE_HOUSHANDETAIL, {})
		TFDirector:dispatchGlobalEventWith(HoushanManager.EVENT_UPDATE_HOUSHAN, {})
	end
end
function FactionManager:getZoneBaseInfo()
	if self.guildZoneInfo and self.guildZoneInfo.guildZones then
		return self.guildZoneInfo.guildZones
	end
	return {}
end
function FactionManager:getZonePersonalInfo()
	if self.guildZoneInfo and self.guildZoneInfo.playerZones then
		return self.guildZoneInfo.playerZones
	end
	return {}
end

--获取章节进度
function FactionManager:getZonePercentList()
	local zoneMax = GuildZoneData:size() or 0	
	local guildZoneMsg = self:getZoneBaseInfo()

	local zonePercentInfo = {}
	local zoneLast = nil
	for i=1,zoneMax do
		zonePercentInfo[i] = {}
		zonePercentInfo[i].percent = 0
		zonePercentInfo[i].resetCount = 0

		local serverData = nil
		for k,v in pairs(guildZoneMsg) do
			if v.zoneId == i then
				serverData = v
				break
			end
		end

		if serverData then
			zonePercentInfo[i].resetCount = serverData.resetCount
			zonePercentInfo[i].state = 4
			--[[
			state:
				local StateAlreadyOpen = 1
				local StateCanOpen = 2
				local StateCanReset = 3
				local StateCannotOpen = 4
			]]
			if serverData.pass then
				zonePercentInfo[i].state = 3	
				zonePercentInfo[i].percent = 100
			else
				local checkpoint = serverData.checkpoints or {}
				local currCheckPointInfo = nil
				local currBossIndex = 1
				local function sortCheckPointId(a,b)
					return a.checkpointId < b.checkpointId
				end
				table.sort(checkpoint, sortCheckPointId)
				-- print(checkpoint)
				for k,v in pairs(checkpoint) do
					if v.pass == false then
						currCheckPointInfo = v
						currBossIndex = k
						break
					end
				end
				if currCheckPointInfo then
					local percent = self:getCheckPointPercentHp(i, currCheckPointInfo.checkpointId)	
					percent = 100 - percent
					percent = math.floor(percent*25/100)
					zonePercentInfo[i].percent = percent + (currBossIndex - 1)*25
					zonePercentInfo[i].state = 1
				else
					zonePercentInfo[i].state = 3	
					zonePercentInfo[i].percent = 100
				end
			end
		elseif zoneLast and (zoneLast.bastPassTime and zoneLast.bastPassTime > 0) then
			zonePercentInfo[i].percent = 0
			zonePercentInfo[i].state = 2
		else
			zonePercentInfo[i].percent = 0
			zonePercentInfo[i].state = 4
		end
		zoneLast = serverData
	end

	if zonePercentInfo[1].state == 4 then
		zonePercentInfo[1].state = 2
	end
	return zonePercentInfo
end

--开启副本
function FactionManager:requestOpenZone( zone_id, costFr )
	self.openZoneId = zone_id
	self.openZoneCost = costFr or 0

	TFDirector:send(c2s.OPEN_ZONE,{zone_id})
	showLoading()
end
function FactionManager:onOpenZoneSucess( event )
	hideLoading()
	self:useFactionBoom(self.openZoneCost)
	TFDirector:dispatchGlobalEventWith(FactionManager.OpenZoneSucess, {self.openZoneId})
	play_zhaomu_chouquxiake()	
end

--重置副本
function FactionManager:requestResetZone( zone_id, costFr )
	self.resetZoneId = zone_id
	self.resetZoneCost = costFr or 0
	TFDirector:send(c2s.RESET_ZONE,{zone_id})
	showLoading()
end
function FactionManager:onResetZoneSucess( event )
	hideLoading()
	self:useFactionBoom(self.resetZoneCost)
	TFDirector:dispatchGlobalEventWith(FactionManager.ResetZoneSucess, {self.resetZoneId})
	play_zhaomu_chouquxiake()
end

--公会通关排行
function FactionManager:requestGuildZonePassRank(zone_id, checkpoint_id)

	local Msg = {
		1,
		0,
		3,
		1,
		zone_id,
		checkpoint_id,
	}
	TFDirector:send(c2s.QUERY_RANKING_BASE_INFO,Msg)
	showLoading()
end
function FactionManager:onGuildZonePassRank( event )
	hideLoading()
	-- local data = {}
	-- data.myRank = 1
	-- data.rankInfos = {}
	-- data.rankInfos[1] = {}
	-- data.rankInfos[1].guildId = 1
	-- data.rankInfos[1].name = '123'
	-- data.rankInfos[1].presidentName = '234'
	-- data.rankInfos[1].power = 456
	-- data.rankInfos[1].level = 3
	-- data.rankInfos[1].passTime = 60*60*25
	-- data.firstPass = {}
	-- data.firstPass.guildId = 1
	-- data.firstPass.name = '123'
	-- data.firstPass.presidentName = '234'
	-- data.firstPass.power = 456
	-- data.firstPass.level = 3
	-- data.firstPass.passTime = 60*60*25

	TFDirector:dispatchGlobalEventWith(FactionManager.guildZonePassRank, {event.data})
	-- TFDirector:dispatchGlobalEventWith(FactionManager.guildZonePassRank, {data})
end
function FactionManager:openZonePassRank( zone_id )
	local layer  = require('lua.logic.faction.HoushanChapterRank'):new()
	AlertManager:addLayer(layer,AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_NONE)
	layer:loadData(zone_id)
	AlertManager:show()
end

--公会伤害排行
function FactionManager:requestGuildCheckPointRank(zone_id, checkpoint_id)
	--self:getFactionMaxMember(self.factionInfo.level) or 1
	--策划确定只取前30
	local maxMember = 30
	local Msg = {
		1,
		0,
		maxMember,
		2,
		zone_id,
		checkpoint_id,
	}
	TFDirector:send(c2s.QUERY_RANKING_BASE_INFO,Msg)
	showLoading()
end
function FactionManager:onGuildCheckPointRank( event )
	hideLoading()

	-- local data = {}
	-- data.infos = {}
	-- for i=1,9 do
	-- 	data.infos[i] = {}
	-- 	data.infos[i].playerId = i
	-- 	data.infos[i].name = i*10
	-- 	data.infos[i].level = i
	-- 	data.infos[i].profession = 77
	-- 	data.infos[i].hurt = 10000
	-- end
	-- print('onGuildCheckPointRankdata = ',event.data)

	TFDirector:dispatchGlobalEventWith(FactionManager.guildCheckPointRank, {event.data})
end
function FactionManager:openCheckPointRank( zone_id )
	local layer  = require('lua.logic.faction.HoushanDamageRank'):new()
	AlertManager:addLayer(layer,AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_NONE)
	layer:loadData(zone_id)
	AlertManager:show()
end

function FactionManager:getMyGuildPassTime( zone_id )
	local baseInfo = self:getZoneBaseInfo()
	for k,v in pairs(baseInfo) do
		if v.zoneId == zone_id then
			return v.bastPassTime
		end
	end
	return 0
end

function FactionManager:isFirstTimeInZone(zone_id, checkpoint_id)
	local playerInfo = self:getZonePersonalInfo()
	for k,v in pairs(playerInfo) do
		if v.zoneId == zone_id then
			if not v.checkpoints then
				return true
			end
			for _,checkpoints in pairs(v.checkpoints) do
				if checkpoints.checkpointId == checkpoint_id then
					return false
				end
			end
			return true
		end
	end
	return true
end

function FactionManager:isHaveBeginTip()
	local info = HoushanManager:getHoushanChapterAndBossId()
	return self:isHaveTipInMission(info.chapter,info.checkpointid,11)
end

function FactionManager:isHaveEndTip()
	local info = HoushanManager:getHoushanChapterAndBossId()
	return self:isHaveTipInMission(info.chapter,info.checkpointid,12)
end

function FactionManager:isHaveTipInMission( zone_id, checkpoint_id,stageType )
	if not self:isFirstTimeInZone(zone_id, checkpoint_id) then
        return false;
    end
    for tip in MissionManager.missionTipList:iterator() do
        if tip.stageid == checkpoint_id and tip.type == stageType then
            return true;
        end
    end
    return false;
end

function FactionManager:showTip(stageType)
	local info = HoushanManager:getHoushanChapterAndBossId()
    if not self:isHaveTipInMission(info.chapter,info.checkpointid,stageType) then
        return;
    end
    
    local tipList = MissionManager:getTipListByMissionId(info.checkpointid,stageType);

    local tipData = {};
    tipData.mapId        = self.mapId;
    tipData.missionId    = info.checkpointid;
    tipData.delegate     = MissionManager;
    tipData.tiplist      = tipList; 
    tipData.stageType    = stageType;
    local tipLayer = require("lua.logic.mission.MissionTipLayer"):new(tipData);
    local currentScene = Public:currentScene();
    currentScene:addLayer(tipLayer);
end

function FactionManager:getTotalHurtByZoneId(zone_id)
	local playerInfo = self:getZonePersonalInfo()
	local totalHurt = 0
	for k,v in pairs(playerInfo) do
		if v.zoneId == zone_id  and v.checkpoints then
			for _,checkpoints in pairs(v.checkpoints) do
				totalHurt = totalHurt + checkpoints.hurt
			end
		end
	end
	return totalHurt
end

function FactionManager:openHoushanRewardLayer( zone_id )
	local layer  = require('lua.logic.faction.HoushanReward'):new()
	AlertManager:addLayer(layer,AlertManager.BLOCK_AND_GRAY,AlertManager.TWEEN_NONE)
	layer:loadData(zone_id)
	AlertManager:show()
end

--领取dps奖励
function FactionManager:onDrawDpsAwardSucess(event)
	hideLoading()

	local playerInfo = self:getZonePersonalInfo()

	for i=1,#playerInfo do
		if playerInfo[i].zoneId == self.DpsAwardZoneId then

			playerInfo[i].dropAwards = playerInfo[i].dropAwards or {}
			local dropAwards = playerInfo[i].dropAwards			
			local index = #dropAwards + 1
			dropAwards[index] = self.DpsAwardAwardId
			break
		end
	end
	TFDirector:dispatchGlobalEventWith(FactionManager.guildDpsAwardSucess, {})
	TFDirector:dispatchGlobalEventWith(HoushanManager.EVENT_UPDATE_HOUSHANREWARDEFFECT, {})
end

function FactionManager:requestDrawDpsAwardSucess(zone_id, award_id)
	self.DpsAwardZoneId = zone_id
	self.DpsAwardAwardId = award_id

	local Msg = {		
		zone_id,
		award_id
	}
	TFDirector:send(c2s.DRAW_DPS_AWARD,Msg)
	showLoading()
end

function FactionManager:getAwardGetList(zone_id)
	local playerInfo = self:getZonePersonalInfo()
	local totalHurt = 0
	for k,v in pairs(playerInfo) do
		if v.zoneId == zone_id then
			return v.dropAwards or {}	
		end
	end
	return {}
end

function FactionManager:getCheckPointPercentHp(zone_id, checkpoint_id)
	local zoneBaseInfo = self:getZoneBaseInfo()
	for _,zoneInfo in pairs(zoneBaseInfo) do
		if zoneInfo.zoneId == zone_id then
			local checkPointBase = zoneInfo.checkpoints
			for _,checkpoint in pairs(checkPointBase) do
				if checkpoint.checkpointId == checkpoint_id then
					local currHp = 0
					local totalHp = 0
					for _,npcInfo in pairs(checkpoint.states) do
						currHp = currHp + npcInfo.hp
						totalHp = totalHp + npcInfo.maxHp
					end
					-- currHp = totalHp - currHp
					local percent = math.floor(currHp*100/totalHp)
					if percent >= 100 then
						percent = 100
					end
					return percent
				end
			end
		end
	end
	return 100
end


function FactionManager:getNpcPercentHp(zone_id, checkpoint_id, pos)
	local zoneBaseInfo = self:getZoneBaseInfo()
	for _,zoneInfo in pairs(zoneBaseInfo) do
		if zoneInfo.zoneId == zone_id then
			local checkPointBase = zoneInfo.checkpoints
			for _,checkpoint in pairs(checkPointBase) do
				if checkpoint.checkpointId == checkpoint_id then
					for _,npcInfo in pairs(checkpoint.states) do
						if npcInfo.index == pos then
							local percent = math.floor(npcInfo.hp*100/npcInfo.maxHp)
							return percent
						end
					end
				end
			end
		end
	end
	return 100
end

function FactionManager:getZoneTotalHp(zone_id)
	local zoneBaseInfo = self:getZoneBaseInfo()
	for _,zoneInfo in pairs(zoneBaseInfo) do
		if zoneInfo.zoneId == zone_id then
			local checkPointBase = zoneInfo.checkpoints
			local taotalHp = 0
			for _,checkpoint in pairs(checkPointBase) do
				for _,npcInfo in pairs(checkpoint.states) do
					taotalHp = taotalHp + npcInfo.maxHp								
				end
			end
			return taotalHp
		end
	end
	return 100
end

function FactionManager:getCheckpointTotalHp(zone_id, checkpoint_id)
	local zoneBaseInfo = self:getZoneBaseInfo()
	for _,zoneInfo in pairs(zoneBaseInfo) do
		if zoneInfo.zoneId == zone_id then
			local checkPointBase = zoneInfo.checkpoints
			for _,checkpoint in pairs(checkPointBase) do
				if checkpoint.checkpointId == checkpoint_id then
					local taotalHp = 0
					for _,npcInfo in pairs(checkpoint.states) do
						taotalHp = taotalHp + npcInfo.maxHp	
					end
					return taotalHp
				end
			end
		end
	end
	return 100
end

function FactionManager:isCanGetRewardByZoneId(zone_id)
	local totalHurt = self:getTotalHurtByZoneId(zone_id)
	local dateTable = GuildZoneDpsAwardData:GetInfoByZoneId( zone_id )
	local awardGetTable = self:getAwardGetList(zone_id)

	local function isInGotTable( award_id )
		for k,v in pairs(awardGetTable) do
			if v == award_id then
				return true
			end
        end
        return false
	end 

	for k,v in pairs(dateTable) do
        if totalHurt >= v.hurt then
            if isInGotTable(v.id) == false then
            	return true
            end
        end
    end
    return false
end

function FactionManager:getMaxHurtOutPut(zone_id)

	local dateTable = GuildZoneDpsAwardData:GetInfoByZoneId( zone_id )

	local maxHurt = 0
	for k,v in pairs(dateTable) do
		if v.zone_id == zone_id and v.hurt > maxHurt then
			maxHurt = v.hurt
		end
    end
    return maxHurt
end

function FactionManager:getHoushanOpenLevel()
	for v in FactionLevelUpData:iterator() do
		if v.hills_level ~= 0 then
			return v.id
		end
	end
	return 0
end

function FactionManager:getAtkSuppress( attack , target )
    if attack == target then
        return 1
    end
    local zoneInfo = HoushanManager:getHoushanChapterAndBossId()
    local zone_id = zoneInfo.chapter
    local checkpoint_id = zoneInfo.checkpointid
    local strategyPower = StrategyManager:getPower()
    local recommendPower = GuildZoneCheckPointData:GetRecommendPower( zone_id , checkpoint_id )
    local percent = strategyPower/recommendPower
    if percent >= 1 then
        return 1
    end
    local rule = ClimbRuleConfigure:getRuleDataByType( 17, checkpoint_id , percent )
    if rule == nil then
        return 1
    end
    if attack == false then
        return 1 + rule.user_atk
    end
    return 1 + rule.npc_atk
end

function FactionManager:getBufRateSuppress( attack , target )
    if attack == target then
        return 0
    end
    local zoneInfo = HoushanManager:getHoushanChapterAndBossId()
    local zone_id = zoneInfo.chapter
    local checkpoint_id = zoneInfo.checkpointid
    local strategyPower = StrategyManager:getPower()
    local recommendPower = GuildZoneCheckPointData:GetRecommendPower( zone_id , checkpoint_id )
    local percent = strategyPower/recommendPower
    if percent >= 1 then
        return 0
    end   
    local rule = ClimbRuleConfigure:getRuleDataByType(17, checkpoint_id, percent )
    if rule == nil then
        return 0
    end
    if attack == false then
        return rule.user_buff_rate
    end
    return rule.npc_buff_rate
end

function FactionManager:canRedPointHouShan()
	local maxZone = GuildZoneData:GetZoneMaxNum()
	for i=1,maxZone do
		if self:isCanGetRewardByZoneId(i) then
			return true
		end
	end
	return false
end

function FactionManager:onGuildZoneReceive( event )
	hideLoading()
 	local zoneData = event.data
 	if zoneData then
 		local zone_id = zoneData.zoneId
 		local zoneBaseInfo = self:getZoneBaseInfo()
 		local currZoneInfo = nil
 		for i=1,#zoneBaseInfo do
 			if zoneBaseInfo[i].zoneId == zone_id then
 				zoneBaseInfo[i] = zoneData
 				break;
 			end
 		end
 		-- print('onGuildZoneReceiveonGuildZoneReceive = ', zoneData)
 		TFDirector:dispatchGlobalEventWith(HoushanManager.EVENT_UPDATE_HOUSHANDETAIL, {})
 		TFDirector:dispatchGlobalEventWith(HoushanManager.EVENT_UPDATE_HOUSHAN, {})
 	end
end

function FactionManager:requestGuildZone( zone_id )
	-- body
	-- pp.pp = 1
	TFDirector:send(c2s.GAIN_GUILD_ZONE_INFO,{zone_id})
	showLoading()
end

function FactionManager:getZoneInfoByID( zone_id )
	local zoneBaseInfo = self:getZoneBaseInfo()
	for _,zoneInfo in pairs(zoneBaseInfo) do
		if zoneInfo.zoneId == zone_id then
			return zoneInfo
		end
	end
	return nil
end
function FactionManager:getZoneCheckPointState( zone_id, checkpoint_id )
	
	local zoneInfo = self:getZoneInfoByID(zone_id)
	if zoneInfo == nil then
		--未开启
		return 0
	end
	local checkPointBase = zoneInfo.checkpoints or {}
	for _,checkpoint in pairs(checkPointBase) do
		if checkpoint.checkpointId == checkpoint_id then
			local killAll = true
			for _,npcInfo in pairs(checkpoint.states) do
				if npcInfo.hp ~= 0 then
					killAll = false
					break
				end
			end
			if killAll then
				--boss被击杀
				return 1
			end
		end
	end	
	
	local currTime = MainPlayer:getNowtime()
	local lockTime = math.floor(zoneInfo.lockTime/1000)

	if (zoneInfo.lockPlayerId == 0 or currTime > lockTime) or zoneInfo.lockPlayerId == MainPlayer:getPlayerId() then
		--没有锁定玩家
		return 2
	else
		--有锁定玩家
		return 3
	end
end


function FactionManager:EnterModifyFationName()
    local layer =  AlertManager:addLayerByFile("lua.logic.faction.FactionReNameLayer", AlertManager.BLOCK_AND_GRAY)
    AlertManager:show()
    return
end

function FactionManager:RequestModifyFationName(newFationName)
    showLoading();
    TFDirector:send(c2s.UPDATE_GUILD_NAME, {newFationName})
end


function FactionManager:onReNameCom(event)
    hideLoading();
    self.factionInfo.name = event.data.name
    -- toastMessage("更名成功")
    toastMessage(localizable.CommonManager_change_name)
    AlertManager:close();
end

function FactionManager:getRandomBannerInfo()
	local ChoseInfo = {}
	math.randomseed(os.time())
    ChoseInfo.bannerBg = 1 + math.ceil(math.random()*100)%5
    ChoseInfo.bannerBgColor = 1 + math.ceil(math.random()*100)%6
    ChoseInfo.bannerIcon = 1 + math.ceil(math.random()*100)%20
    ChoseInfo.bannerIconColor = 1 + math.ceil(math.random()*100)%6
    return ChoseInfo
end

function FactionManager:requestUpdateBanner(bannerStr)
	showLoading();
	TFDirector:send(c2s.UPDATE_GUILD_BANNER, {bannerStr})
end

function FactionManager:onBannerUpdate( event )
	hideLoading()
	print(event.data.bannerId)
	if self.factionInfo then
		self.factionInfo.bannerId = event.data.bannerId
	end
	TFDirector:dispatchGlobalEventWith(FactionManager.bannerUpdate, {event.data.bannerId})
end

function FactionManager:getBannerBgPath(bg,bgcolor)
	local strTemplete = 'ui_new/faction/qizhi/bg_qizhi1_1.png'
	if bg and bgcolor then
		strTemplete = string.format('ui_new/faction/qizhi/bg_qizhi%d_%d.png', bg,bgcolor)
	end
	return strTemplete
end

function FactionManager:getBannerIconPath(icon,iconcolor)
	local strTemplete = 'ui_new/faction/qizhi/qb1_1.png'
	if icon and iconcolor then
		strTemplete = string.format('ui_new/faction/qizhi/qb%d_%d.png', icon,iconcolor)
	end
	return strTemplete
end

function FactionManager:getMyBannerIconPath()
	local factionInfo = self.factionInfo or {}
	local bannerId = factionInfo.bannerId or '1_1_1_1'
	local bannerInfo = stringToNumberTable(bannerId, '_')
	local strTemplete = self:getBannerIconPath(bannerInfo[3],bannerInfo[4])
	return strTemplete
end

function FactionManager:getMyBannerBgPath()
	local factionInfo = self.factionInfo or {}
	local bannerId = factionInfo.bannerId or '1_1_1_1'
	local bannerInfo = stringToNumberTable(bannerId, '_')
	local strTemplete = self:getBannerBgPath(bannerInfo[1],bannerInfo[2])
	return strTemplete
end

function FactionManager:getGuildBannerBgPath(str)
	local bannerId = str or '1_1_1_1'
	local bannerInfo = stringToNumberTable(bannerId, '_')
	local strTemplete = self:getBannerBgPath(bannerInfo[1],bannerInfo[2])
	return strTemplete
end

function FactionManager:getGuildBannerIconPath(str)
	local bannerId = str or '1_1_1_1'
	local bannerInfo = stringToNumberTable(bannerId, '_')
	local strTemplete = self:getBannerIconPath(bannerInfo[3],bannerInfo[4])
	return strTemplete
end

function FactionManager:getFactionMailInfo()
	--tips
	--content
	return self.mailInfo
end

function FactionManager:setFactionMailTips( tips )
	print('tips = ',tips)
	self.mailInfo = self.mailInfo or {}
	self.mailInfo.tips = tips
	--
end

function FactionManager:setFactionMailContent( content )
	self.mailInfo = self.mailInfo or {}
	self.mailInfo.content = content
end

function FactionManager:requestFactionMail()
	-- body
	showLoading()
	local msg = {
		self.mailInfo.tips,
		self.mailInfo.content
	}
	print('msg = ',msg)
	TFDirector:send(c2s.SEND_GUILD_MAIL, msg)
end

function FactionManager:onGuildMailSucess( event )
	hideLoading()
	AlertManager:close()
	toastMessage(localizable.factionMail_sucess)
	self.mailInfo = {}
end

--更新公告
function FactionManager:isNeedPopNotice()
	return self.popNoticeContent
end

function FactionManager:onNewNoticeUpdate( event )
	self.popNoticeContent = true
end

function FactionManager:newNoticeShow()
	self.popNoticeContent = nil
end

function FactionManager:getNoticeContent()
	local content = ""
	if self.factionInfo then
		content = self.factionInfo.notice or ""
	end
	return content
end

return FactionManager:new()