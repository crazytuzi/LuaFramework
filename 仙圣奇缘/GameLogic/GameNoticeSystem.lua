--------------------------------------------------------------------------------------
-- 文件名:	GameNoticeSystem.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	李旭
-- 日  期:	
-- 版  本:	
-- 描  述:	游戏公告 客户端只纪录十条纪录 跟账号,角色无关
-- 应  用:  
--http://blog.csdn.net/cagehe/article/details/18017019
---------------------------------------------------------------------------------------
local nMax = 11					    --最多纪录十条
local NoticeDBName = "NoticeDB"		--纪录在DB中的标签名

function sortfunc(a, b)
		return a:GetServerID() > b:GetServerID()
end

--游戏公告界面的公告 ，
--登陆时候的 显示规则 。列表中的第一个并且没打开过的

GameNotice = class("GameNotice")
GameNotice.__index = GameNotice

local notVisable = 1
local visabel = 2

function GameNotice:ctor()
	self.nServerId = 0
	self.strTitle = nil
	self.strContext = nil

	self.Buffer = ""

	-- 1没看过 2 为已看过 
	self.state = notVisable

	--状态存在db里面的结构是 第一个字符串为 状态 后边是 buffer
	-- self.state..self.Buffer
end


function GameNotice:Init(ServerID, strTitle, strContext, szBuffer)
	self.nServerId 	= ServerID
	self.strTitle 	=  strTitle
	self.strContext = strContext --g_stringSize_insert(strContext,"\n",22,160)
	self.Buffer 	= szBuffer
end


function GameNotice:GetTitle()
	return self.strTitle
end


function GameNotice:GetContext()
	return self.strContext
end


function GameNotice:GetServerID()
	return self.nServerId
end


function GameNotice:GetBuffer()
	return self.Buffer
end

--此文件用的
function GameNotice:GetState()
	return self.state
end

function GameNotice:SetState()
	self.state = visabel
end

function GameNotice:isfirstOpen()
	if self.state == notVisable then
		return true
	end
	return  false
end

function GameNotice:SetDBState(istate)
	if type(istate) ~= "number" then return false end

	self.state = istate
	return true
end

--直接写入DB
function GameNotice:UpdataState()
	if self:isfirstOpen() then
		local strbuf = string.format("2%s", self.Buffer)
		if 0 == g_DbMgr:UpdateRecordDB(NoticeDBName, self.nServerId, strbuf) then
			self:SetState()
		end
	end
end

--公告界面的item
local NoticeItem =  class("NoticeItem")
NoticeItem.__index = NoticeItem

function NoticeItem:ctor()
	self.text = ""
	self.utc = 0
end

function NoticeItem:setData(context, utc_time)
	self.text = tostring(context)
	self.utc = tonumber(utc_time)
end

function NoticeItem:getDataTxt_time()
	return self.text, self.utc
end

------------------------------------------------------------
--[[     ]]
------------------------------------------------------------
GameNoticeSystem = class("GameNoticeSystem")
GameNoticeSystem.__index = GameNoticeSystem


function GameNoticeSystem:ctor()
	--客户端公告
	self.tbNotice = {}

	--游戏内主界面显示的公告
	self.tbGameNotice = {}

	--游戏内实时公告
	self.tbOnlineNotice = {}

	self.DBReading = false

	--通知服务器已经接收过的公告
	self.tbSeverID = {}

	--游戏公告界面的纪录
	self.tbNoticeForm = {} --NoticeItem 容器
end

function GameNoticeSystem:Init()

	self.DBReading = ( g_DbMgr:CreateRecordDB(NoticeDBName) == 0)

	if self.DBReading  then
		for row  in g_DbMgr:GetRecordDBRow(NoticeDBName)do
			--先截取一个字符 后面的才是buffer

			local state = string.sub(row.buffer,1, 2)
			state = tonumber(state)

			local strbuffer = string.sub(row.buffer,2, string.len(row.buffer))
			local tb = g_DbMgr:StringToTable(strbuffer)
			if tb ~= nil then
				local notice = GameNotice.new()
				notice:Init(tb.event_id, tb.title, tb.context, strbuffer)
				notice:SetDBState(state)
				table.insert(self.tbNotice, notice)
			end
		end
		table.sort(self.tbNotice, sortfunc)
	end

	--公告
	--g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_PUBLIC_NOTICE_NOTIFY, handler(self, self.RespondNoticeNotity))

	-- 即时公告
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_SHOR_TIME_NOTICE_NOTIFY, handler(self, self.RespondGameNoticy))

	--游戏功能公告
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_GAME_SHOR_TIME_NOTICE_NOTIFY, handler(self, self.RespondGameModleNoticy))

	--游戏公告界面初始化
	g_MsgMgr:registerCallBackFunc(msgid_pb.MSGID_HISTORY_SHOR_TIME_NOTICE_NOTIFY, handler(self, self.GameNoticeRecode))

	--
	g_FormMsgSystem:RegisterFormMsg(FormMsg_GameNotice_ActionOver, handler(self, self.ShowGameNextNotice))
end


function GameNoticeSystem:GetNoticeNum()
	return #self.tbNotice
end


function GameNoticeSystem:GetNoticeByPage(nPage)
	if 0 == nPage or nPage > #self.tbNotice then return  nil end

	return self.tbNotice[nPage]
end


--现实主界面的公告
function GameNoticeSystem:GetFirstGameNotice()
	return self.tbGameNotice[1]
end

--删除所有的纪录
function GameNoticeSystem:DeleteLoaclRecord()

	local nIndex = 1
	for row  in g_DbMgr:GetRecordDBRow(NoticeDBName)do

			local tb = g_DbMgr:StringToTable(row.buffer)
			if tb ~= nil then
				g_DbMgr:DeleteRecordDB(NoticeDBName, tb.event_id)
				nIndex = nIndex + 1
			end
			
	end

	return nIndex
end


function GameNoticeSystem:UpdatetbNoticeForm(notice)
	if not notice then return false end

	if #self.tbNoticeForm > 30 then
		table.remove(self.tbNoticeForm, 1)
	end
	local item = NoticeItem.new()
	item:setData(notice:getDataTxt_time())
	table.insert(self.tbNoticeForm, notice)

	g_FormMsgSystem:SendFormMsg(FormMsg_ChatNotice_UpdataForm, nil)
	return true
end

--上一个消息结束后 首先显示及时公告 
function GameNoticeSystem:ShowGameNextNotice(Tbcontext)

	if Tbcontext  == EnumNotice.EnumNotice_Mian then

		-- for k, v in pairs(self.tbGameNotice)do self.tbGameNotice[k]=nil break end
		self:UpdatetbNoticeForm(self.tbGameNotice[1])
		table.remove(self.tbGameNotice, 1)

	elseif Tbcontext == EnumNotice.EnumNotice_RunScene then

		-- for k, v in pairs(self.tbOnlineNotice)do self.tbOnlineNotice[k]=nil break end
		self:UpdatetbNoticeForm(self.tbOnlineNotice[1])
		table.remove(self.tbOnlineNotice, 1)

	end

	--优先及时公告
	if #self.tbOnlineNotice ~= 0 then
		g_GameNoticeForm:ShowOnlineNotice(self.tbOnlineNotice[1].text)
		return
	end

	if #self.tbGameNotice ~= 0 then
		g_FormMsgSystem:SendFormMsg(FormMsg_GameNotice_NoticeMainWnd, nil)
		return
	end


	return 
end

--获取公告界面的公告
function GameNoticeSystem:GetNoticFormRecode()
	return self.tbNoticeForm
end

---------------------------------------Msg--------------------------------
function GameNoticeSystem:SendRespondNoticeID()
	if #self.tbSeverID > 0 and g_MsgMgr:GetCurConnectType() == Class_MsgMgr_Zone then
		------接收公告成功通知服务器，服务器下次就不会发这条公告-------
		local  RootMsg = zone_pb.RevPublicNoticeRequest()
		for i=1, #self.tbSeverID do
			table.insert(RootMsg.event_id, self.tbSeverID[i])
		end
		g_MsgMgr:sendMsg(msgid_pb.MSGID_REV_PUBLIC_NOTICE_REQUEST, RootMsg)

		self.tbSeverID = {}
	end
end


function GameNoticeSystem:RespondNoticeNotity(tbMsg)
	--删除本地纪录
	self:DeleteLoaclRecord()

	local Msg = zone_pb.PublicNoticeNotify()
	Msg:ParseFromString(tbMsg.buffer)
 	local msgInfo = tostring(Msg)

	local tbSub = {}
	tbSub = self.tbNotice

	self.tbNotice = {}

	--
	local function findNotice(eventID)
		for k, v in ipairs(tbSub)do
			if v:GetServerID() == eventID then
				return true
			end
		end

		return false
	end

	
	for k, v in ipairs(Msg.notice_list) do
		--纪录已收到的公告
		table.insert(self.tbSeverID , v.event_id)
		
		if findNotice(v.event_id) == false then
		
			local szBuffer = g_DbMgr:TableToString(v)
			local notice = GameNotice.new()
			notice:Init(v.event_id, v.title, v.context, szBuffer)
			table.insert(self.tbNotice, notice)
		end
		
	end

	--需要记录的数量 最多10条
	local total = #self.tbNotice
	for i=1, #tbSub  do
		if i + total < nMax then
			table.insert(self.tbNotice, tbSub[i])
		end
	end

	table.sort(self.tbNotice, sortfunc)

	--写入本地 第一个字符为公告的状态 后面是服务器下发的buffer
	local string_buf = ""
	for k,v in ipairs(self.tbNotice)do
		string_buf = string.format("%d%s",v:GetState(), v:GetBuffer())
		g_DbMgr:insert(NoticeDBName, v:GetServerID(), string_buf)
	end

	if g_WndMgr:getWnd("MainScene") then
		self:SendRespondNoticeID()
	end
	
end


--游戏内公告 gm公告
function GameNoticeSystem:RespondGameNoticy(tbMsg)
	local Msg = common_pb.ShortTimeNoticeNotify()
	Msg:ParseFromString(tbMsg.buffer)
 	local msgInfo = tostring(Msg)
	cclog(msgInfo)

	local item = NoticeItem.new()
	item:setData(Msg.text, Msg.utc_time)

	if Msg.type == macro_pb.STNT_LV_1 then	   --加入队列里面 回主界面显示

		table.insert(self.tbGameNotice, item)
		g_FormMsgSystem:SendFormMsg(FormMsg_GameNotice_NoticeMainWnd, nil)
		
	elseif Msg.type == macro_pb.STNT_LV_2 then --及时显示

		table.insert(self.tbOnlineNotice, item)
		g_GameNoticeForm:ShowOnlineNotice(Msg.text)

	end

end

--查找格式中的转义字符的个数
local function find_cNum(txt)
	local count = 0
	local beg = 1
	local byte_left = string.byte("%")
	local byte_righy = string.byte("s")
	local byte_upper = string.byte("S")
	while(beg <= string.len(txt))do
		local c = string.byte(txt, beg)
	    local shift = 1
	    if c > 0 and c <= 127 then --英文字符
	        shift = 1
	        if c == byte_left then --find_byte = '%'
	        	c = string.byte(txt, beg+1) -- 下一个字符
	        	if c == byte_righy or c == byte_upper then
	        		count = count + 1
	        	end
	        end
	    else
			shift = 3
	    end
	  
	    beg = beg + shift
	end
	return count
end

--游戏内功能模块的公告
function GameNoticeSystem:RespondGameModleNoticy(tbMsg)
	local Msg = common_pb.GameShortTimeNoticeNotify()
	Msg:ParseFromString(tbMsg.buffer)
 	local msgInfo = tostring(Msg)
	cclog(msgInfo)

	--游戏模块的公告默认加入到任意界面播放
	local config_id = Msg.cfg_id or 0
	local context = g_DataMgr:getMsgContentCsv(config_id)

	if context then
		local text = context.Description_ZH
		if text then
			--获取%s的个数 与 参数的个数匹配 不然回报错
			local dirNum = #Msg.para
			local SrcNum = find_cNum(text)
			if dirNum == SrcNum then
				local notice = ""
                if dirNum == 0 then
                    notice = text 
				elseif dirNum == 1 then
					notice = string.format(text,_TC(tostring(Msg.para[1])))
				elseif dirNum == 2 then
					notice = string.format(text,_TC(tostring(Msg.para[1])), _TC(tostring(Msg.para[2])))
				elseif dirNum == 3 then
					notice = string.format(text,_TC(tostring(Msg.para[1])), _TC(tostring(Msg.para[2])), _TC(tostring(Msg.para[3])))
				elseif dirNum == 4 then
					notice = string.format(text,_TC(tostring(Msg.para[1])), _TC(tostring(Msg.para[2])), _TC(tostring(Msg.para[3])), _TC(tostring(Msg.para[4])))
				elseif dirNum == 5 then
					notice = string.format(text,_TC(tostring(Msg.para[1])), _TC(tostring(Msg.para[2])), _TC(tostring(Msg.para[3])), _TC(tostring(Msg.para[4])), _TC(tostring(Msg.para[5])))
				end
				if notice ~= "" then
					local item = NoticeItem.new()
					item:setData(notice, Msg.utc_time)
					table.insert(self.tbOnlineNotice, item)
					g_GameNoticeForm:ShowOnlineNotice(notice)
				end
			else
				print("=GameNoticeSystem:RespondGameModleNoticy=参数与格式 不匹配".."format ="..text)
			end
			
		end
	end
end


--游戏公告界面
function GameNoticeSystem:GameNoticeRecode(tbMsg)
	local Msg = common_pb.HistoryShortTimeNotice()
	Msg:ParseFromString(tbMsg.buffer)
 	local msgInfo = tostring(Msg)
	cclog(msgInfo)
		for k, v in ipairs(Msg.short_time_notice)do
				local item = NoticeItem.new()
				if v.type == common_pb.STNBT_GM then --客服，GM工具跑马灯
					item:setData(v.gm_notice.text, v.gm_notice.utc_time)
					table.insert(self.tbNoticeForm, item)

				elseif v.type == common_pb.STNBT_GAME then --游戏系统跑马灯

						local config_id = v.game_notice.cfg_id or 0
						local context = g_DataMgr:getMsgContentCsv(config_id)
						if context then
								local text = context.Description_ZH
								if text then
									--获取%s的个数 与 参数的个数匹配 不然回报错
									local dirNum = #v.game_notice.para
									local SrcNum = find_cNum(text)
									if dirNum == SrcNum then
										local notice = ""
                                        if dirNum == 0 then
                                            notice = text
										elseif dirNum == 1 then
											notice = string.format(text,_TC(tostring(v.game_notice.para[1])))
										elseif dirNum == 2 then
											notice = string.format(text,_TC(tostring(v.game_notice.para[1])), _TC(tostring(v.game_notice.para[2])))
										elseif dirNum == 3 then
											notice = string.format(text,_TC(tostring(v.game_notice.para[1])), _TC(tostring(v.game_notice.para[2])), _TC(tostring(v.game_notice.para[3])))
										elseif dirNum == 4 then
											notice = string.format(text,_TC(tostring(v.game_notice.para[1])), _TC(tostring(v.game_notice.para[2])), _TC(tostring(v.game_notice.para[3])), _TC(tostring(v.game_notice.para[4])))
										elseif dirNum == 5 then
											notice = string.format(text,_TC(tostring(v.game_notice.para[1])), _TC(tostring(v.game_notice.para[2])), _TC(tostring(v.game_notice.para[3])), _TC(tostring(v.game_notice.para[4])), _TC(tostring(v.game_notice.para[5])))
										end
										if notice ~= "" then
											item:setData(notice, v.game_notice.utc_time)
											table.insert(self.tbNoticeForm, item)
										else
											cclog("==GameNoticeSystem:GameNoticeRecode==string.format error paranum = "..tostring(dirNum))
										end
									else
										print("=GameNoticeSystem:RespondGameModleNoticy=参数与格式 不匹配".."format ="..text)
									end
									
								end
						end
				end
		end
end




-----------------
g_GameNoticeSystem = GameNoticeSystem.new()
g_GameNoticeSystem:Init()
