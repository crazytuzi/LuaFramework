--------------------------------------------------------------------------------------
-- 文件名:	Class_Guild.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	
-- 日  期:	2015-4-7 15:24
-- 版  本:	1.0
-- 描  述:	帮派数据
-- 应  用:
---------------------------------------------------------------------------------------

Class_Guild = class("Class_Guild")
Class_Guild.__index = Class_Guild

-- 帮派入口 区分是打开帮派申请还是帮派主界面
--@param flag 如果是true 表示是从 帮派按钮进入的 如果是false 就是从集会所进入的
function Class_Guild:openGroupView(flag)
	local guildId = self:getGuildID()
	if guildId <= 0 then 
		--打开帮派申请
		Game_Group:offlineChatRequest(false)
		
		self:removeGuildListAll()
		self:GuildListRequest(0)
	else
		--打开帮派主界面
		Game_Group:offlineChatRequest(true)
		if flag then 
			self:requestGuildInfoRequest(guildId)
		else
			g_WndMgr:openWnd("Game_JiHuiSuo")
		end
	end
end

--帮派列表信息
function Class_Guild:getGuildListInfo()
	return self.guildListInfo
end

function Class_Guild:setGuildListInfo(tbData)
	table.insert(self.guildListInfo,tbData)
end

function Class_Guild:setSingleGuildListInfo(key, tbData)
	self.guildListInfo[key] = tbData
end

function Class_Guild:removeGuildListAll()
	self.guildListInfo = {}
end


--玩家是否已经申请了这个帮派
function Class_Guild:getIsreq(nIndex)
	return self.guildListInfo[nIndex].is_req
end

function Class_Guild:setIsreq(nIndex,nIsReq)
	self.guildListInfo[nIndex].is_req = nIsReq
end


--根据帮派Id 来设置 当前玩的对这个帮派的申请状态
function Class_Guild:setGuildListIsReq(GuildId,nIsReq)
	local guildList = self:getGuildListInfo()
	for i = 1,#guildList do
		if GuildId == guildList[i].id then 
			guildList[i].is_req = nIsReq
			return
		end
	end
end

--申请列表
function Class_Guild:getReqlist(nUin)
	local tbmag = self:getKingData(nUin)
	if not self.guildListInfo[nUin] or self.guildListInfo[nUin].reqlist then
		return {}
	end
	return self.guildListInfo[nUin].reqlist["guild_req_lst"]
end
--[[
	帮派申请条件文字
]]
-- macro_pb.GUILD_REQ_TYPE_ANYBODY = 0;			// 任何人可加入
-- macro_pb.GUILD_REQ_TYPE_APPLY = 1;			// 需要批准
-- macro_pb.GUILD_REQ_TYPE_REFUSE = 2;			// 拒绝任何人加入
local tbStatus = {
	[1] = _T("任何人都可加入"),
	[2] = _T("需要批准才能加入"),
	[3] = _T("拒绝任何人加入"),
}
function Class_Guild:getGuildConditionText()
	return tbStatus
end

--[[
	帮派名称
]]
function Class_Guild:getUserGildName(guildId)
	local guildList = self:getGuildListInfo()
	for i = 1,#guildList do
		if guildId == guildList[i].id then 
			return guildList[i].name
		end
	end
	return ""
end

--帮会变更冷却时间点,只有退出，解散帮会的时候才更新
function Class_Guild:setGuildChangeColdat(nTime)
	self.guildChangeColdat  = nTime or 0
end

function Class_Guild:getGuildChangeColdat()
	return self.guildChangeColdat 
end
-----------------------------------以上是帮派列表数据函数-------------------------------------------


---------------------------------以下是 本帮派数据函数---------------------------------------------

--帮派ID  为零表示还没有拥有帮派
function Class_Guild:getGuildID()
	return self.guildID or 0
end
function Class_Guild:setGuildID(guildId)
	self.guildID = guildId
end

--帮派等级
function Class_Guild:getUserGuildLevel()
	return self.guildLevel
end
--帮派等级
function Class_Guild:setUserGuildLevel(Level)
	self.guildLevel = Level
end

--帮派排名
function Class_Guild:getUserGuildRank()
	if self.guildRank then
		return self.guildRank + 1
	end
	return 0
end
function Class_Guild:setUserGuildRank(rank)
	self.guildRank = rank
end

--帮派经验
function Class_Guild:getGuildExp()
	return self.guildExp or 0
end

function Class_Guild:setGuildExp(nExp)
	self.guildExp = nExp
end

--公告
function Class_Guild:getGuildAnnouncement()
	if not self.guildAnnouncement 
		or self.guildAnnouncement == ""
		or  self.guildAnnouncement == "notice" then 
		self.guildAnnouncement = _T("帮主很懒，什么东西也没写")
	end
	return self.guildAnnouncement
end

function Class_Guild:setGuildAnnouncement(nAnnouncement)
	self.guildAnnouncement = nAnnouncement
end

--当前成员人数
function Class_Guild:getGuildCurMemNum()
	return self.guildCurMemNum or 0
end

function Class_Guild:setGuildCurMemNum(nNum)
	self.guildCurMemNum = nNum
end

--最大成员人数
function Class_Guild:getGuildMaxMemNum()
	return self.guildMaxMemNum or 0
end

function Class_Guild:setGuildMaxMemNum(num)
	self.guildMaxMemNum = num
end

--[[
	玩家名称 颜色设置和突破等级
	local param = {
		name = "",breachLevel = "",lableObj = object,nLeftString = "",nRightString=""
	}
]]
function Class_Guild:setLableByColor(param)
	local name = param.name 
	local breachLevel = param.breachLevel
	local lableObj = param.lableObj
	g_SetCardNameColorByEvoluteLev(lableObj,breachLevel)
	local nLeftString = param.nLeftString or ""
	local nRightString = param.nRightString or ""
	local nString = nLeftString..g_GetCardNameWithSuffix({Name = name},breachLevel,lableObj)..nRightString
	lableObj:setText(nString)
end

--申请类型（设置为三种情况）
function Class_Guild:getReqType()
	if self.guildSetReqType then
		return self.guildSetReqType + 1
	end
	
	return 1
end

function Class_Guild:setReqType(nType)
	self.guildSetReqType = nType
end

--申请限制等级
function Class_Guild:getReqLevel()
	local minLv = g_DataMgr:getGlobalCfgCsv("min_request_group_level")
	if self.guildSetReqLevel then 
		return self.guildSetReqLevel
	end 
	return minLv
end
function Class_Guild:setReqLevel(nLv)
	self.guildSetReqLevel = nLv
end



--本帮派成员列表
function Class_Guild:getMEMList()
	return self.guildMemList_
end

function Class_Guild:setMemList(memList)
	self.guildMemList_ = memList
	for i = 1,#self.guildMemList_ do
		if self.guildMemList_[i].ident == 1 then 
			self:setUserIdent(self.guildMemList_[i].ident)
			self:setUserBreachlv(self.guildMemList_[i].breachlv)
			self:setUserName(self.guildMemList_[i].name)
			return
		end
	end

end
-- optional uint32 uin = 1;	// 玩家id
-- optional string name = 2[(stFFOptions) = {strMacroSize : "MAX_ROLE_NAME"}];	// 名字
-- optional uint32 gener = 3;	// 性别
-- optional uint32 level = 4;	// 等级
-- optional uint32 ident = 5;	// 身份
-- optional uint32 contribution = 6;	// 历史贡献
-- optional uint32 logintime = 7;	// 登录时间
-- optional uint32 cardcfgid = 8;	// 卡牌配置id
-- optional uint32 starlv = 9;	// 星级
-- optional uint32 breachlv = 10;	// 突破等级
-- optional uint32 fight = 11;	// 战斗力
-- optional uint32 viplv = 12;	// vip等级
-- optional string sign = 13;	// 签名 
function Class_Guild:setGiveMemList(memList,toUin)
	--被提为帮主 修改 身份
	for i = 1,#self.guildMemList_ do
		if self.guildMemList_[i].uin == toUin then 
			self.guildMemList_[i].ident = memList.ident
			self.guildMemList_[i].breachlv = memList.breachlv
			self.guildMemList_[i].name = memList.name
			g_Guild:setUserIdent(memList.ident) --身份
			g_Guild:setUserBreachlv(memList.breachlv)-- 突破等级
			g_Guild:setUserName(memList.name)
		elseif self.guildMemList_[i].uin ==  g_MsgMgr:getUin() 
			and self.guildMemList_[i].ident == 1 then 
			--帮主身份 降为帮众
			self.guildMemList_[i].ident = 0
			g_Guild:setUserIdent(0) --身份
		end
	end

end


--帮派名称
function Class_Guild:getUserGuildName()
	return self.guildName or ""
end

function Class_Guild:setUserGuildName(guildName)
	self.guildName = guildName
end
------------------帮主个人信息---------------------------------

--帮主ID
function Class_Guild:getGuildKingid()
	return self.kingId
end
function Class_Guild:setGuildKingid(kingid)
	self.kingId = kingid
end

--[[
	是否是帮主
]]
function Class_Guild:getUserGildHost(nUin)
	local memList = self:getMEMList()
	if memList then
		for i = 1,#memList do
			if memList[i].ident == 1 and nUin == memList[i].uin then 
				return true
			end
		end
	end
	return false
end


--帮主标识
function Class_Guild:setUserIdent(ident)
	self.ident_ = ident
end
function Class_Guild:getUserIdent()
	return self.ident_
end

function Class_Guild:setUserName(name)
	self.userName_ = name
end

function Class_Guild:getUserName()
	return self.userName_
end
--帮主的突破等级
function Class_Guild:setUserBreachlv(lv)
	self.breachLv_ = lv
end

function Class_Guild:getUserBreachlv()
	return self.breachLv_
end
------------------^^^---以上---帮主个人信息--------------------------------------

--保存帮派申请列表信息
function Class_Guild:setTbReqList(tbMsg)
	self.tbReqList = {}
	local function MailSort(tb1,tb2)
		return tb1.reqtime > tb2.reqtime
	end
	for i,v in ipairs(tbMsg.req_list)do
		local tb_Item = {}
		tb_Item.cardcfgid = v.cardcfgid
		tb_Item.breachlv = v.breachlv
		tb_Item.gener = v.gener
		tb_Item.starlv = v.starlv
		tb_Item.sign = v.sign
		tb_Item.level = v.level
		tb_Item.name = v.name
		tb_Item.uin = v.uin
		tb_Item.reqtime = v.reqtime
		tb_Item.rank = v.rank
		tb_Item.fighting_point = v.fighting_point
		table.insert(self.tbReqList,tb_Item)
	end
	table.sort(self.tbReqList,MailSort)
end

--同意或者拒绝后删除某个信息
function Class_Guild:removeTbReqList(uin)
	if not self.tbReqList then return end
	for i,v in pairs(self.tbReqList)do
		if v.uin == uin then
			table.remove(self.tbReqList,i)
		end
	end
end

function Class_Guild:getTbReqList()
	return self.tbReqList
end

function Class_Guild:getTbReqListCount()
	if self.tbReqList then
		return #self.tbReqList
	end
	return 0
end

--签名
function Class_Guild:defaultSign(sing)
	if not sing or sing == "no sign" then 
		return _T("人的一生确实是需要一个伟大的签名...")
	end
	return sing
end

GUILD_VIEW_STATE = {
	CHAT = 1,
	MEMBER = 2,
}

function Class_Guild:ctor()
	self.viewState_ = GUILD_VIEW_STATE.CHAT
	
	self.guildListInfo = {}
	self.guildMemList_ = {}
	------计算滑动到第几页
	self.default = 20
	self.offset = self.default
	self.pageNum = 0
	
	------------------------
	
	self.buildTimeatList_ = {} --记录当天操作建筑 建造升级的状态
	self.buildingInfo_  = {} --建筑信息 经验与等级
	self.skillLvList_ = {} --建筑等级中的技能等级  （炼神塔等）
	self.lastChooseType_ = {}--记录万宝楼和书画院已经认购了什么类型的物品
	--帮派创建响应
	local order = msgid_pb.MSGID_GUILD_CREATE_RESPONSE
	g_MsgMgr:registerCallBackFunc(order, handler(self,self.requestGuildCreateResponse))	
	
	--帮派退出响应
	local order = msgid_pb.MSGID_GUILD_QUIT_RESPONSE
	g_MsgMgr:registerCallBackFunc(order, handler(self,self.requestGuildOuitResponse))	
	
	--帮派成员列表响应
	local order = msgid_pb.MSGID_GUILD_MEM_LIST_RESPONSE
	g_MsgMgr:registerCallBackFunc(order, handler(self,self.requestGuildMemListResponse))	
	
	--帮派信息响应
	local order = msgid_pb.MSGID_GUILD_INFO_RESPONSE
	g_MsgMgr:registerCallBackFunc(order, handler(self,self.requestGuildInfoResponse))	
	--帮派列表
	local order = msgid_pb.MSGID_GUILD_LIST_RESPONSE
	g_MsgMgr:registerCallBackFunc(order, handler(self,self.requestGuildListResponse)) 
	
	--帮派日志响应
	local order = msgid_pb.MSGID_GUILD_LOG_RESPONSE
	g_MsgMgr:registerCallBackFunc(order, handler(self,self.requestGuildLogResponse))	
	
	--帮派申请加入限制设置
	local order = msgid_pb.MSGID_GUILD_SETREQCONTI_RESPONSE
	g_MsgMgr:registerCallBackFunc(order, handler(self,self.GuildSetReqContiResponse))	
	
	--帮派申请列表
	local order = msgid_pb.MSGID_GUILD_REQINFO_RESPONSE
	g_MsgMgr:registerCallBackFunc(order, handler(self,self.requestGuildReqListResponse))	
	
	--帮派申请审批响应
	local order = msgid_pb.MSGID_GUILD_APPLY_RESPOND_RESPONSE
	g_MsgMgr:registerCallBackFunc(order, handler(self,self.requestGuildApplyRespResponse)) 
	
	--帮派解散响应
	local order = msgid_pb.MSGID_GUILD_DISMISS_RESPONSE
	g_MsgMgr:registerCallBackFunc(order,handler(self,self.requestGuildDismissResponse)) 	
	
	--帮派踢人响应	
	local order = msgid_pb.MSGID_GUILD_KICKOUT_RESPONSE
	g_MsgMgr:registerCallBackFunc(order,handler(self,self.requestGuildKickOutResponse))		
	
	--申请人数变化
	local order = msgid_pb.MSGID_GUILD_NOTIFY_REQLIST_NUM
	g_MsgMgr:registerCallBackFunc(order,handler(self,self.requestNotifyGuildReqListNum)) 
	
	--帮派公告响应
	local order = msgid_pb.MSGID_GUILD_CHANGENOTICE_RESPONSE
	g_MsgMgr:registerCallBackFunc(order,handler(self,self.requestGuildChangeNoticeResponse))		
	
	--帮会成员改变时通知客户端刷新请求响应
	local order = msgid_pb.MSGID_GUILD_NOTIFY_MEMBER_CHANGE 
	g_MsgMgr:registerCallBackFunc(order,handler(self,self.memberChangeUpdate))	
	

		--帮派升级响应
	local order = msgid_pb.MSGID_GUILD_UPGRADE_RESPONSE
	g_MsgMgr:registerCallBackFunc(order,handler(self,self.requestGuildUpGradeResponse))	
	
	
end
-----------------------↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓----以下为 翻页数据使用---------------

function Class_Guild:addOffset(offset)
	self.offset = self.offset + offset
end
function Class_Guild:getOffset()
	return self.offset  
end
function Class_Guild:setOffset(offset)
	self.offset = offset
end

function Class_Guild:getDefaultPageNum()
	return self.default
end

function Class_Guild:addPageNum(pageNum)
	self.pageNum = self.pageNum + pageNum 
end
function Class_Guild:getPageNum()
	return self.pageNum
end
function Class_Guild:setPageNum(num)
	self.pageNum = num
end
------------------------^^^^^^^^^^^^^^^^---以上为 翻页数据使用---------------
function Class_Guild:getViewState()
	return self.viewState_
end

function Class_Guild:setViewState(state)
	self.viewState_ = state
end

function Class_Guild:guildInfoTable(single)
	local t = {}
	t.king_star = single.king_star
	t.level = single.level
	t.king_uin = single.king_uin
	t.name = single.name
	t.reqconti = single.reqconti
	-- local req_lev = reqconti.req_lev
	-- local req_type = reqconti.req_type
	t.is_req = single.is_req
	t.id = single.id
	t.king_breachlv = single.king_breachlv
	t.cur_mem_num = single.cur_mem_num
	t.max_mem_num = single.max_mem_num
	t.king_name = single.king_name
	t.king_card = single.king_card
	t.announcement = single.announcement
	return t
end

--帮派列表请求  		--帮派列表翻页 
function Class_Guild:GuildListRequest(pageId)
	cclog("========GuildListRequest=帮派列表请求======"..pageId)
	local msgDetail = zone_pb.GuildListRequest()
	msgDetail.page_id = pageId
	g_MsgMgr:sendMsg(msgid_pb.MSGID_GUILD_LIST_REQUEST,msgDetail)
end
--[[
	帮派列表
]]
function Class_Guild:requestGuildListResponse(tbMsg)
	cclog("-------requestGuildListResponse-----帮派列表---------")
	local msg = zone_pb.GuildListResponse(tbMsg)
	msg:ParseFromString(tbMsg.buffer)
	cclog(tostring(msg))

	local alikeFlag = false
	local guildKey = 1
	local guildLst = msg.guild_lst
	for i = 1,#guildLst do
		local singleTable = guildLst[i]
		
		--已经缓存的帮派列表 判断是否和新下发的有一样的,如果有，需要更新数据
		local guildListInfo = self:getGuildListInfo()
		for index = 1, #guildListInfo do 
			if guildListInfo[index].id == singleTable.id then 
				alikeFlag = true
				guildKey = index
				break
			end
		end

		local singleList = self:guildInfoTable(singleTable)
		if alikeFlag then 
			self:setSingleGuildListInfo(guildKey, singleList)
			alikeFlag = false
		else
			self:setGuildListInfo(singleList)
		end
	end
	
	
	local guildId = g_Guild:getGuildID()
	if guildId <= 0 then 
		--创建帮派，申请帮派 查询 界面
		g_WndMgr:openWnd("Game_GroupCreate")
	else
		--帮派信息界面
		if g_WndMgr:getWnd("Game_Group") then 
			g_WndMgr:getWnd("Game_Group").groupfunc_[TB_FUNC_TYPE_NAME.GroupRankPNL]:listViewShow()
		end
	end
end

--帮派解散请求 
function Class_Guild:requestGuildDismissRequest()
	cclog("---------requestGuildDismissRespRequest-----帮派解散请求--------")
	g_MsgMgr:sendMsg(msgid_pb.MSGID_GUILD_DISMISS_REQUEST)
end

--帮派解散响应 
function Class_Guild:requestGuildDismissResponse(tbMsg)
	cclog("---------requestGuildDismissResponse-----帮派解散响应--------")
	g_Guild:setGuildID(0)
	
	local nGuildQuitCD = g_DataMgr:getGlobalCfgCsv("guild_quit_cd")
	self:setGuildChangeColdat(nGuildQuitCD + os.time())
	
	g_WndMgr:closeWnd("Game_GroupManage")
	g_WndMgr:closeWnd("Game_Group")
	g_WndMgr:closeWnd("Game_DragonPrayGuild")
	g_WndMgr:closeWnd("Game_WorldBossGuild")
	g_WndMgr:closeWnd("Game_SceneBossGuild")
	
end

--帮派创建请求
function Class_Guild:requestGuildCreateRequest(guildName)
	cclog("---------requestGuildCreateRequest------帮派创建请求-------")
	local msg = zone_pb.GuildCreateRequest() 
	msg.guild_name = guildName
	g_MsgMgr:sendMsg(msgid_pb.MSGID_GUILD_CREATE_REQUEST, msg)
end

--帮派创建响应 notice
function Class_Guild:requestGuildCreateResponse(tbMsg)
	cclog("---------requestGuildCreateResponse------帮派创建响应-------")
	local msgDetail = zone_pb.GuildCreateResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	local msgInfo = tostring(msgDetail)
	cclog(msgInfo)
	
	local guildInfo = msgDetail.guild_info -- 帮派信息
	
	g_Hero:setYuanBao(msgDetail.update_coupons) --更新元宝信息
	gTalkingData:onPurchase(TDPurchase_Type.TDP_ARENA_GUILD_CREATE,1,msgDetail.update_coupons)	
		
	g_Hero:setCoins(msgDetail.update_money ) --更新铜钱信息

	
	local guildId = guildInfo.id
	self:setGuildID(guildId) --帮派Id

	local name = guildInfo.name --帮派名称
	local level = guildInfo.level --帮派等级
	local kingid = guildInfo.kingid --帮主ID
	local exps = guildInfo.exp	--帮贡
	local announcement = guildInfo.announcement --公告
	
	self:setUserGuildName(name)
	self:setUserGuildLevel(level)
	self:setGuildKingid(kingid)
	self:setGuildExp(exps)
	self:setGuildAnnouncement(announcement)
	
	local guildExtend = guildInfo.extend
	local memList = guildExtend.memberlist -- 帮派成员
	local tbMemList = memList.guild_mem_lst --b帮派成员详细信息
	local memList = {}
	for i = 1, #tbMemList do 
		local t = {}
		t.uin = tbMemList[i].uin -- 玩家id
		t.name =  tbMemList[i].name -- 名字
		t.gener = tbMemList[i].gener -- 性别
		t.level = tbMemList[i].level -- 等级
		t.ident = tbMemList[i].ident -- 身份
		t.contribution = tbMemList[i].contribution -- 历史贡献
		t.logintime = tbMemList[i].logintime -- 上次登陆时间点
		t.cardcfgid = tbMemList[i].cardcfgid -- 卡牌配置id
		t.starlv = tbMemList[i].starlv -- 星级
		t.breachlv = tbMemList[i].breachlv -- 突破等级
		t.fight = tbMemList[i].fight -- 战斗力
		t.viplv = tbMemList[i].viplv -- vip等级
		t.sign = tbMemList[i].sign -- 签名  最大长度检查做了没有？　有空记得查查代码
		t.logouttime = tbMemList[i].logouttime -- 上次登出时间点
		table.insert(memList,t)
	end
	
	-- 成员列表
	self:setMemList(memList)

	local reqconti = guildExtend.reqconti -- 申请条件
	self:setReqType(reqconti.req_type )
	self:setReqLevel(reqconti.req_lev)	
	-- local loglist = guildExtend.loglist --日志列表
	-- local tbLogList = loglist.guild_log_lst
	-- local reqList = guildExtend.reqlist -- 申请列表
	-- local tbReqList = reqList.guild_req_lst
	
	self.buildingInfo_ = {}
	local buildingInfo = guildExtend.building_info --建筑信息
	for i = 1, #buildingInfo do 
		local t = {}
		t.level = buildingInfo[i].level --建筑等级
		t.exp = buildingInfo[i].exp		-- 建筑当前经验
		table.insert(self.buildingInfo_, t)
	end

	
	
	g_WndMgr:closeWnd("Game_GroupCreate")
	self:openGroupView(true)
	
	--创建一帮派后 先清理帮派列表缓存数据 在查看帮派排名的时候刷出最新数据 
	--在小于服务器下发的数据时候会出现刚创建的帮派没有显示出来
	self:removeGuildListAll()
	--清除聊天记录
	GroupChat:deleteChatList()
end

--帮派退出请求
function Class_Guild:requestGuildOuitRequest()
	cclog("---------requestGuildOuitRequest--帮派退出请求-----------")
	g_MsgMgr:sendMsg(msgid_pb.MSGID_GUILD_QUIT_REQUEST)
end

--帮派退出响应
function Class_Guild:requestGuildOuitResponse()
	cclog("---------requestGuildOuitResponse--帮派退出响应-----------")
	self:setGuildID(0)
	self:setOffset(self:getDefaultPageNum())
	self:setPageNum(0)
	--退出后的冷却时间
	local nGuildQuitCD = g_DataMgr:getGlobalCfgCsv("guild_quit_cd")
	self:setGuildChangeColdat(nGuildQuitCD + os.time())
	g_WndMgr:closeWnd("Game_Group")

end

--帮派成员列表请求
function Class_Guild:requestGuildMemListRequest()
	cclog("---------requestGuildMemListRequest---帮派成员列表请求----------")
	g_MsgMgr:sendMsg(msgid_pb.MSGID_GUILD_MEM_LIST_REQUEST, msg)
end

--帮派成员列表响应
function Class_Guild:requestGuildMemListResponse(tbMsg)
	cclog("---------requestGuildMemListResponse----帮派成员列表响应---------")
	local msgDetail = zone_pb.GuildMemListResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	local msgInfo = tostring(msgDetail)
	cclog(msgInfo)
	local guildMemLst = msgDetail.guild_mem_lst -- 帮派成员列表
	local memList = {}
	for i = 1, #guildMemLst do 
		local t = {}
		t.uin = guildMemLst[i].uin -- 玩家id
		t.name =  guildMemLst[i].name -- 名字
		t.gener = guildMemLst[i].gener -- 性别
		t.level = guildMemLst[i].level -- 等级
		t.ident = guildMemLst[i].ident -- 身份
		t.contribution = guildMemLst[i].contribution -- 历史贡献
		t.logintime = guildMemLst[i].logintime -- 上次登陆时间点
		t.cardcfgid = guildMemLst[i].cardcfgid -- 卡牌配置id
		t.starlv = guildMemLst[i].starlv -- 星级
		t.breachlv = guildMemLst[i].breachlv -- 突破等级
		t.fight = guildMemLst[i].fight -- 战斗力
		t.viplv = guildMemLst[i].viplv -- vip等级
		t.sign = guildMemLst[i].sign -- 签名  最大长度检查做了没有？　有空记得查查代码
		t.logouttime = guildMemLst[i].logouttime -- 上次登出时间点
		table.insert(memList,t)
	end
	self:setMemList(memList)

	self:setGuildCurMemNum(#guildMemLst)
	
	--帮派信息界面
	if g_WndMgr:getWnd("Game_Group") then 
	
		g_WndMgr:getWnd("Game_Group").groupfunc_[TB_FUNC_TYPE_NAME.GroupPNL]:init(g_WndMgr:getWnd("Game_Group").rootWidget)
		g_WndMgr:getWnd("Game_Group").groupfunc_[TB_FUNC_TYPE_NAME.GroupPNL]:listViewShow()
		
		g_WndMgr:getWnd("Game_Group").groupfunc_[TB_FUNC_TYPE_NAME.GroupPNL]:g_UpdataGroupLevel()
	end
end

--帮派信息请求
function Class_Guild:requestGuildInfoRequest(guildId)
	cclog("---------requestGuildInfoRequest------帮派信息请求-------")
	local msg = zone_pb.GuildInfoRequest() 
	msg.guild_id = guildId
	g_MsgMgr:sendMsg(msgid_pb.MSGID_GUILD_INFO_REQUEST, msg)
end

--帮派信息响应
function Class_Guild:requestGuildInfoResponse(tbMsg)
	cclog("---------requestGuildInfoResponse-----帮派信息响应--------")
	local msgDetail = zone_pb.GuildInfoResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog( tostring(msgDetail))

	local tbMemList = msgDetail.mem_lst --成员列表
	-- 成员列表
	self:setMemList(tbMemList)
	
	local reqConti = msgDetail.req_conti
	self:setReqType(reqConti.req_type )
	self:setReqLevel(reqConti.req_lev)	
	
	local id = msgDetail.id --帮派ID
	local name = msgDetail.name
	local level = msgDetail.level
	local exps = msgDetail.exp
	local guildRank = msgDetail.guild_rank
	local curMemNum = msgDetail.cur_mem_num
	local maxMemNum = msgDetail.max_mem_num
	local announcement = msgDetail.announcement 
	
	self:setGuildID(id)
	self:setUserGuildRank(guildRank)
	self:setUserGuildName(name)
	self:setUserGuildLevel(level)
	self:setGuildExp(exps)
	self:setGuildAnnouncement(announcement)
	self:setGuildCurMemNum(curMemNum)
	self:setGuildMaxMemNum(maxMemNum)
	
	
	 self.buildingInfo_ = {}
	local buildingInfo = msgDetail.building_info --建筑信息
	for i = 1, #buildingInfo do 
		local t = {}
		t.level = buildingInfo[i].level --建筑等级
		t.exp = buildingInfo[i].exp		-- 建筑当前经验
		table.insert(self.buildingInfo_, t)
	end
	
	g_WndMgr:openWnd("Game_Group")
end

--帮派日志请求
function Class_Guild:requestGuildLogRequest()
	cclog("---------requestGuildLogRequest-------------")
	cclog("---------帮派日志请求-------------")
	g_MsgMgr:sendMsg(msgid_pb.MSGID_GUILD_LOG_REQUEST,msg)
end

--帮派日志响应
function Class_Guild:requestGuildLogResponse(tbMsg)
	cclog("---------requestGuildCreateResponse-------------")
	cclog("---------帮派日志响应-------------")
	local msgDetail = zone_pb.GuildLogResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	local msgInfo = tostring(msgDetail)
	cclog(msgInfo)
	local logList = msgDetail.log_list -- 帮派日志
	if g_WndMgr:getWnd("Game_Group") then 
		g_WndMgr:getWnd("Game_Group").groupfunc_[TB_FUNC_TYPE_NAME.GroupLogPNL]:getImageGroupLogPNLView(logList)
	end
end

--帮派设置请求 
function Class_Guild:GuildSetReqContiRequest(TbReq)
	cclog("---------GuildSetReqContiRequest---帮派设置审批请求----------")
	local msg = zone_pb.GuildSetReqContiRequest() 
	msg.req_type = TbReq.req_type - 1
	msg.req_lev = TbReq.req_lev
	g_MsgMgr:sendMsg(msgid_pb.MSGID_GUILD_SETREQCONTI_REQUEST, msg)
end

--帮派设置请求响应
function Class_Guild:GuildSetReqContiResponse(tbMsg)
	cclog("---------GuildSetReqContiResponse--帮派设置请求响应-----------")
	local msgDetail = zone_pb.GuildSetReqContiResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	local msgInfo = tostring(msgDetail)
	cclog(msgInfo)
	
	self:setReqType(msgDetail.req_type )
	self:setReqLevel(msgDetail.req_lev)	
	
	if g_WndMgr:getWnd("Game_GroupSetting") 
		and g_WndMgr:isVisible("Game_GroupSetting") then
		g_WndMgr:closeWnd("Game_GroupSetting")
	end
end

--帮派申请审批列表请求
function Class_Guild:requestGuildReqListRequest(guild_id)
	cclog("------帮派申请审批列表请求---requestGuildReqListRequest------"..guild_id)
	local msg = zone_pb.GuildReqListRequest() 
	msg.guild_id = guild_id 
	g_MsgMgr:sendMsg(msgid_pb.MSGID_GUILD_REQINFO_REQUEST, msg)
end

--帮派申请审批列表响应
function Class_Guild:requestGuildReqListResponse(tbMsg)
	cclog("---------requestGuildReqListResponse--------帮派申请审批列表响应-----")
	local msgDetail = zone_pb.GuildReqListResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))
	self:setTbReqList(msgDetail)
	
	local wndInstance = g_WndMgr:getWnd("Game_GroupRequest")
	if wndInstance and g_WndMgr:isVisible("Game_GroupRequest") then
		wndInstance.LuaListView_RequestList:updateItems(self:getTbReqListCount())
	else
		g_WndMgr:showWnd("Game_GroupRequest")
	end
end

--帮派申请审批请求 
function Class_Guild:requestGuildApplyRespRequest(tbMsg)
	cclog("---------requestGuildApplyRespRequest-------帮派申请审批请求------")
	local msg = zone_pb.GuildApplyRespRequest() 
	msg.uin = tbMsg.uin 
	msg.optype = tbMsg.optype 
	g_MsgMgr:sendMsg(msgid_pb.MSGID_GUILD_APPLY_RESPOND_REQUEST, msg)
end

--帮派申请审批响应 
function Class_Guild:requestGuildApplyRespResponse(tbMsg)
	cclog("---------requestGuildApplyRespResponse----帮派申请审批响应---------")
	local msgDetail = zone_pb.GuildApplyRespResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	local msgInfo = tostring(msgDetail)
	cclog(msgInfo)
	
	local optype = msgDetail.optype
	local uin = msgDetail.uin
	local guildId = msgDetail.guild_id
	local guildName = msgDetail.guild_name or ""

	if self:getUserGildHost(g_MsgMgr:getUin()) then
		self:removeTbReqList(msgDetail.uin)
		g_Hero:setBubbleNotify(macro_pb.NT_Guild, self:getTbReqListCount())
	else
		if optype == 1 then  --同意
			self:setGuildID(guildId)
		else 
			--忽略
			--设置申请状态为0
			self:setGuildListIsReq(guildId,0)
			self:setGuildID(0)
		end
	end
	
	if self:getUserGildHost(g_MsgMgr:getUin()) then --帮主ID
		local wndInstance = g_WndMgr:getWnd("Game_GroupRequest")
		if wndInstance and g_WndMgr:isVisible("Game_GroupRequest") then --帮主
			wndInstance.LuaListView_RequestList:updateItems(self:getTbReqListCount())
		end
		
		if g_WndMgr:getWnd("Game_Group") then 
			g_WndMgr:getWnd("Game_Group").groupfunc_[TB_FUNC_TYPE_NAME.GroupPNL]:setGroupRequestNotice()
		end
		
		if g_WndMgr:getWnd("Game_Home") then
			g_WndMgr:getWnd("Game_Home"):addNoticeAnimation_Group()
		end
		
		if g_WndMgr:getWnd("Game_GroupManage") then
			g_WndMgr:getWnd("Game_GroupManage"):setGroupRequestNotice()
		end
	else
		if optype == 1 then  --同意
			g_ShowSysTips({text = _T("您已经成功加入").."["..g_Guild:getUserGildName(guildId).."]".._T("帮派")})
			if g_WndMgr:isVisible("Game_GroupCreate") then
				g_WndMgr:closeWnd("Game_GroupCreate")
				self:requestGuildInfoRequest(guildId)
			end
			
			--清除聊天记录
			GroupChat:deleteChatList()
			
		else 
			g_ShowSysTips({text = _T("您加入").."["..g_Guild:getUserGildName(guildId).."]".._T("帮派的申请已被拒绝")})
			if g_WndMgr:getWnd("Game_GroupCreate") then
				--创建帮派，申请帮派 查询 界面
				g_WndMgr:showWnd("Game_GroupCreate")
			end
		end	
	end
end


--帮派踢人请求
function Class_Guild:requestGuildKickOutRequest(nUin)
	cclog("---------requestGuildKickOutRequest-------------")
	cclog("---------帮派踢人请求-------------")
	local msg = zone_pb.GuildKickOutRequest() 
	msg.uin = nUin --
	g_MsgMgr:sendMsg(msgid_pb.MSGID_GUILD_KICKOUT_REQUEST, msg)
end

--帮派踢人响应
function Class_Guild:requestGuildKickOutResponse(tbMsg)
	cclog("---------requestGuildKickOutResponse-帮派踢人响应------------")
	local msgDetail = zone_pb.GuildKickOutResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	local msgInfo = tostring(msgDetail)
	cclog(msgInfo)
	
	local nUin = msgDetail.uin -- 
	if g_MsgMgr:getUin() == nUin then
		g_ClientMsgTips:showMsgConfirm(_T("你已经被踢出帮派"))
		g_Guild:setGuildID(0)
		g_WndMgr:closeWnd("Game_Group")
		g_WndMgr:closeWnd("Game_DragonPrayGuild")
		g_WndMgr:closeWnd("Game_WorldBossGuild")
		g_WndMgr:closeWnd("Game_SceneBossGuild")
	end
	if g_WndMgr:getWnd("Game_Group") then 
		g_WndMgr:getWnd("Game_Group"):setVisiblePnl()
		g_WndMgr:getWnd("Game_Group"):adjustOverFunc(g_WndMgr:getWnd("Game_Group").LuaListView:getChildByIndex(0),1)
	end
	g_WndMgr:closeWnd("Game_GroupMemberView")
	
end

	
--帮派公告请求 3004689
function Class_Guild:requestGuildChangeNoticeRequest(nString)
	cclog("---------requestGuildApplyRespRequest-------------")
	cclog("---------帮派申请审批请求-------------")
	local msg = zone_pb.GuildChangeNoticeRequest() 
	msg.notice = nString 
	g_MsgMgr:sendMsg(msgid_pb.MSGID_GUILD_CHANGENOTICE_REQUEST, msg)
end

--帮派公告请求响应
function Class_Guild:requestGuildChangeNoticeResponse(tbMsg)
	cclog("---------帮派公告请求响应-------------")
	local msgDetail = zone_pb.GuildChangeNoticeResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	local msgInfo = tostring(msgDetail)
	cclog(msgInfo)
	-- local mString = self.TextField_Input:getStringValue()
	if g_WndMgr:getWnd("Game_Group") then
		self:setGuildAnnouncement(msgDetail.notice)
		
		g_WndMgr:getWnd("Game_Group"):groupNotice()
	end
	g_WndMgr:closeWnd("Game_GroupChangeNotice")
end

--有申请的时候给管理通知
function Class_Guild:requestNotifyGuildReqListNum(tbMsg)
	cclog("-----requestNotifyGuildReqListNum------有新申请入帮的请求----------")
	local msgDetail = zone_pb.NotifyGuildReqListNum()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog( tostring(msgDetail))

	g_Hero:setBubbleNotify(macro_pb.NT_Guild, msgDetail.apply_num)
	
	if g_WndMgr:getWnd("Game_Group") then 
		g_WndMgr:getWnd("Game_Group").groupfunc_[TB_FUNC_TYPE_NAME.GroupPNL]:setGroupRequestNotice()
	end
	
	if g_WndMgr:getWnd("Game_Home") then
		g_WndMgr:getWnd("Game_Home"):addNoticeAnimation_Group()
	end
	
	if g_WndMgr:getWnd("Game_GroupManage") then
		g_WndMgr:getWnd("Game_GroupManage"):setGroupRequestNotice()
	end
	
	local wndInstance = g_WndMgr:getWnd("Game_GroupRequest")
	if wndInstance and g_WndMgr:isVisible("Game_GroupRequest") then
		g_Guild:requestGuildReqListRequest(self:getGuildID())
	end
end


--帮派升级响应
function Class_Guild:requestGuildUpGradeResponse(tbMsg)
	cclog("---------requestGuildUpGradeResponse----帮派升级响应---------")
	local msgDetail = zone_pb.GuildUpgradeResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	local msgInfo = tostring(msgDetail)
	cclog(msgInfo)
	local curLevel = msgDetail.guild_level		-- 帮派等级
	local guildExp = msgDetail.guild_exp 		-- 剩余的经验 (帮贡)
	self:setUserGuildLevel(curLevel)
	self:setGuildExp(guildExp)
	
	local guild = g_DataMgr:getCsvConfigByOneKey("GuildLevel",self:getUserGuildLevel())
	self:setGuildMaxMemNum(guild.MemberLimit)

	--刷新界面的 帮派等级
	-- if g_WndMgr:getWnd("Game_Group") then 
		-- g_WndMgr:getWnd("Game_Group").groupfunc_[TB_FUNC_TYPE_NAME.GroupPNL]:g_UpdataGroupLevel()
		
		-- g_WndMgr:getWnd("Game_Group"):setGroupRequestNotice(TB_FUNC_TYPE_NAME.GroupBuildingPNL)
		-- g_WndMgr:getWnd("Game_Group"):setGroupRequestNotice(TB_FUNC_TYPE_NAME.GroupActivityPNL)
		
	-- end
end



function Class_Guild:memberChangeUpdate()
	cclog("==帮派成员列表 成员改变===")
	if g_WndMgr:getWnd("Game_Group") then
		g_Guild:requestGuildMemListRequest()
	end
end

--------------------------------------帮派建筑------------
--保存登录时发下的信息
function Class_Guild:guildBuildingData(data)
	-- guild_building
	-- self.guildingData = data
	
	-- echoj("帮派建筑===========",data)
	
	self.buildTimeatList_ = {}
	
	local buildTimeatList =  data.build_timeat_list --每天建筑只能升级一次	
	for i = 1,#buildTimeatList do 
		table.insert(self.buildTimeatList_,buildTimeatList[i])
	end

	
	local skillList = data.skill_list -- 帮派技能类型等级

	self.skillLvList_ = {}
	local t = {}
	for i = 1, #skillList do 
		t = {}
		for j = 1, #skillList[i].skill_lv_list do 
			local lv = skillList[i].skill_lv_list[j]
			table.insert(t,lv)
		end
		table.insert(self.skillLvList_,t)
	end
	
	-- macro_pb.GuildBuildChooseType_Lv1 = 1;		// 普通1
	-- macro_pb.GuildBuildChooseType_Lv2 = 2;		// 高级1
	-- macro_pb.GuildBuildChooseType_Lv3 = 3;		// 普通2
	-- macro_pb.GuildBuildChooseType_Lv4 = 4;		// 高级2
	
	local lastChooseType = data.last_choose_type
	self.lastChooseType_ = {}
	for i = 1, #lastChooseType do
		local t = {}
		t.last_choose_type = lastChooseType[i].last_choose_type
		t.choose_timeat = lastChooseType[i].choose_timeat
		table.insert(self.lastChooseType_, t)
	end
	
	--  
	-- echoj("=======================建筑状态====",self.skillLvList_)
end

function Class_Guild:getAllBuildTimeatList()
	return self.buildTimeatList_
end

function Class_Guild:getBuildTimeatList(key)
	return self.buildTimeatList_[key]
end

function Class_Guild:setBuildTimeatList(key,num)
	self.buildTimeatList_[key] = num
end

--帮派建筑等级和经验	
function Class_Guild:getBuildingLevel(key)
	if not self.buildingInfo_[key] then return 1 end
	return self.buildingInfo_[key].level or 1
end

function Class_Guild:setBuildingLevel(key, lv)
	self.buildingInfo_[key].level = lv 
end

function Class_Guild:getBuildingExp(key)
	if not self.buildingInfo_[key] then return 0 end
	return self.buildingInfo_[key].exp or 0
end

function Class_Guild:setBuildingExp(key, nExp)
	self.buildingInfo_[key].exp = nExp
end

--取出某个建筑的中的某一个技能等级
--buildIndex 建筑索引  从炼神塔开始 1~
function Class_Guild:getBuildSkillLevel(buildIndex, skillIndex)
	return self.skillLvList_[buildIndex][skillIndex]
end

function Class_Guild:setBuildSkillLevel(buildIndex, skillIndex, level)
	self.skillLvList_[buildIndex][skillIndex] = level
end

function Class_Guild:getAllBuildSkillLevel()
	return self.skillLvList_
end

--1 万宝楼，2书画院
function Class_Guild:getAllLastChooseType(buildType)
	return self.lastChooseType_[buildType]
end

--获取此建筑内那个物品的状态 0表示没有操作
function Class_Guild:getLastChooseType(buildType)
	return self.lastChooseType_[buildType].last_choose_type
end

function Class_Guild:setLastChooseType(buildType, nType)
	self.lastChooseType_[buildType].last_choose_type = nType
end

--获取此建筑内那个物品的状态 操作的时间
function Class_Guild:getLastChooseTimeat(buildType)
	return self.lastChooseType_[buildType].choose_timeat
end

function Class_Guild:setLastChooseTimeat(buildType, timeat)
	self.lastChooseType_[buildType].choose_timeat = timeat
end

-- g_MsgMgr:getUin()
---帮派数据
g_Guild = Class_Guild.new()