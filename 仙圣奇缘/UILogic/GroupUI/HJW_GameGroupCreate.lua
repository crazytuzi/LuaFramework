--------------------------------------------------------------------------------------
-- 文件名:	HJW_Game_GroupCreate.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	
-- 日  期:	
-- 版  本:	1.0
-- 描  述:	
-- 应  用:  创建帮派与申请帮派，帮派查询
---------------------------------------------------------------------------------------

Game_GroupCreate = class("Game_GroupCreate")
Game_GroupCreate.__index = Game_GroupCreate

local FLAG = {
	applyFor = 1,
	refer = 2,
}

local g_ListView_GroupList_Index = 1


function Game_GroupCreate:initWnd()
	
	--帮派申请响应
	local order = msgid_pb.MSGID_GUILD_APPLY_RESPONSE
	g_MsgMgr:registerCallBackFunc(order,handler(self,self.requestGuildApplyResponse))

	g_ListView_GroupList_Index = 1
end

function Game_GroupCreate:openWnd()

	self.distinguish = 0
	--创建帮派与申请帮派，帮派查询 按钮功能
	self:initSelectButtonFunc()


end

function Game_GroupCreate:closeWnd()
	g_Guild:setPageNum(0)
	g_Guild:setOffset(g_Guild:getDefaultPageNum())
end

function Game_GroupCreate:showPNLView(nIndex)
	nIndex = nIndex or 1
	local Image_GroupRequestPNL = tolua.cast(self.rootWidget:getChildByName("Image_GroupRequestPNL"), "ImageView")
	Image_GroupRequestPNL:setVisible(false)
	local Image_GroupSetUpPNL = tolua.cast(self.rootWidget:getChildByName("Image_GroupSetUpPNL"), "ImageView")
	Image_GroupSetUpPNL:setVisible(false)
	local Image_GroupSearchPNL = tolua.cast(self.rootWidget:getChildByName("Image_GroupSearchPNL"), "ImageView")
	Image_GroupSearchPNL:setVisible(false)
	if nIndex == 1 then 
		Image_GroupRequestPNL:setVisible(true)	
	elseif nIndex == 2 then 
		Image_GroupSetUpPNL:setVisible(true)
	elseif nIndex == 3 then 
		Image_GroupSearchPNL:setVisible(true)
	end
end

function Game_GroupCreate:initSelectButtonFunc()	

	self.ButtonGroup = ButtonGroup:create()
	--帮派申请
	local Button_TabRequest = tolua.cast(self.rootWidget:getChildByName("Button_TabRequest"), "Button")
	self.ButtonGroup:PushBack(Button_TabRequest, nil, function() 	
		self:showPNLView(1)
		self:groupRequest()
	end)
	--帮派创建
	local Button_TabCreate = tolua.cast(self.rootWidget:getChildByName("Button_TabCreate"), "Button")
	self.ButtonGroup:PushBack(Button_TabCreate, nil, function() 	
		self:showPNLView(2)
		self:groupCreate()
	end)
	--帮派查询
	local Button_TabSearch = tolua.cast(self.rootWidget:getChildByName("Button_TabSearch"), "Button")
	self.ButtonGroup:PushBack(Button_TabSearch, nil, function() 	
		self:showPNLView(3)
		self:groupSearch()
	end)
	
	self.ButtonGroup:Click(1)
end

function Game_GroupCreate:listViewShow(tbData)
	if not tbData then  return end
	if not self.rootWidget then return end 
	local image = nil
	if self.distinguish == FLAG.refer then 
		image = tolua.cast(self.rootWidget:getChildByName("Image_GroupSearchPNL"), "ImageView")
	elseif self.distinguish == FLAG.applyFor then 
		image = tolua.cast(self.rootWidget:getChildByName("Image_GroupRequestPNL"), "ImageView")
	end
	if not image then return end
	local ListView_GroupList = tolua.cast(image:getChildByName("ListView_GroupList"), "ListViewEx")
	local Panel_GroupItem = tolua.cast(ListView_GroupList:getChildByName("Panel_GroupItem"), "Layout")
 
	local nCount = 0
	local groupRequestList = Class_LuaListView:new()
    self.listView = groupRequestList
	local function updateListViewItem(Panel_GroupItem, nIndex)
		Panel_GroupItem:setName("Panel_GroupItem"..nIndex)
		Panel_GroupItem:setTag(tbData[nIndex].id)

		local Button_GroupItem = tolua.cast(Panel_GroupItem:getChildByName("Button_GroupItem"), "Button")
		
		local guildName = tbData[nIndex].name
		local kingid = tbData[nIndex].kingid
		local nLevel = tbData[nIndex].level
		local kingName = tbData[nIndex].king_name
		local kingBreachlv = tbData[nIndex].king_breachlv
		local kingStar = tbData[nIndex].king_star
		local kingCard = tbData[nIndex].king_card
		local isReq = tbData[nIndex].is_req
		
		--帮派申请条件
		local reqType = tbData[nIndex]["reqconti"]["req_type"]
		--帮派申请等级
		local reqLevel = tbData[nIndex]["reqconti"]["req_lev"]
		if reqLevel <= 0 then 
			reqLevel = g_DataMgr:getGlobalCfgCsv("guild_req_lev_default")
		end
		--帮主名称
		local Label_PresidentNameLB = tolua.cast(Button_GroupItem:getChildByName("Label_PresidentNameLB"), "Label")
		local Label_PresidentName = tolua.cast(Label_PresidentNameLB:getChildByName("Label_PresidentName"), "Label")
		local param = {
			name = kingName,breachLevel = kingBreachlv,lableObj = Label_PresidentName,
		}
		g_Guild:setLableByColor(param)
		-- if g_LggV.LanguageVer == eLanguageVer.LANGUAGE_viet_VIET  then --越南版
		Label_PresidentName:setPositionX(Label_PresidentNameLB:getSize().width)
		-- end
		--底框
		local Image_Head = tolua.cast(Button_GroupItem:getChildByName("Image_Head"), "ImageView")
		local Image_Icon = getCardIconImg(kingCard,kingStar)
		local kingUin = tbData[nIndex].king_uin or 0
		local vip = tbData[nIndex].vip or 0
		g_SetPlayerHead(Image_Head,{vip = vip,uin = kingUin,star = kingStar,breachlv = kingBreachlv,Image_Icon = Image_Icon},true)
		
		--帮派名称
		local Label_GroupName = tolua.cast(Button_GroupItem:getChildByName("Label_GroupName"), "Label")
		Label_GroupName:setText(guildName)
		--帮派等级
		local Label_GroupLevel = tolua.cast(Button_GroupItem:getChildByName("Label_GroupLevel"), "Label")
		Label_GroupLevel:setText(nLevel.._T("级"))
		g_AdjustWidgetsPosition({Label_GroupName, Label_GroupLevel},10)
		--帮派申请条件
		local Label_Condition = tolua.cast(Button_GroupItem:getChildByName("Label_Condition"), "Label")
		local tbStatus = g_Guild:getGuildConditionText()
		Label_Condition:setText(tbStatus[reqType + 1])
		--加入需要多少等级
		local Label_NeedLevel = tolua.cast(Button_GroupItem:getChildByName("Label_NeedLevel"), "Label")
		Label_NeedLevel:setText(string.format(_T("需要%d级"),reqLevel))
		
		if isReq == 1 then 
			nCount = nCount + 1
		end
		
		local function onBtnFuncRequest(pSender, eventType)
			if eventType == ccs.TouchEventType.ended then
				if reqType == macro_pb.GUILD_REQ_TYPE_REFUSE then --拒绝任何人加入
					g_ClientMsgTips:showMsgConfirm(_T("拒绝任何人加入"))
					return 
				end

				local times = g_Guild:getGuildChangeColdat() - os.time()
				if times > 0 then 
					-- g_ClientMsgTips:showMsgConfirm("帮派关系发生变动之后需要"..math.floor(times/60).."分钟之后才可再次操作")
					local nGuildQuitCD = math.floor(g_DataMgr:getGlobalCfgCsv("guild_quit_cd")/3600)
					g_ClientMsgTips:showMsgConfirm(string.format(_T("帮派关系发生变动之后需要%d小时之后才可再次操作"),nGuildQuitCD))
					return 
				end
				if reqLevel > g_Hero:getMasterCardLevel() then 
					g_ClientMsgTips:showMsgConfirm(string.format(_T("您需要达到%d级方可加入"),reqLevel))
					return 
				elseif nCount >= 20 then 
					g_ClientMsgTips:showMsgConfirm(_T("该帮派的申请记录已满"))
					return
				end
			
				if reqType == macro_pb.GUILD_REQ_TYPE_APPLY or 
					reqType == macro_pb.GUILD_REQ_TYPE_ANYBODY then -- 需要批准
					--帮派Id
					local nGuildId = pSender:getTag()
					self:requestGuildApplyRequest(nGuildId)
				end
			end
		end

		--按钮
		local Button_Request = tolua.cast(Button_GroupItem:getChildByName("Button_Request"), "Button")
		Button_Request:setTouchEnabled(true)
		Button_Request:setTag(tbData[nIndex].id)
		Button_Request:addTouchEventListener(onBtnFuncRequest)
		Button_Request:setBright(true)
		local Image_FuncName = tolua.cast(Button_Request:getChildByName("Image_FuncName"), "ImageView")
		Image_FuncName:loadTexture(getSocialGroupImg("Btn_FuncName_ShenQing"))
		
		if reqType == macro_pb.GUILD_REQ_TYPE_REFUSE then --拒绝任何人加入
			Button_Request:setBright(false)
			Button_Request:setTouchEnabled(false)
			Image_FuncName:loadTexture(getSocialGroupImg("Btn_FuncName_WuFaShenQing"))
		end
		--控制申请过的帮派 申请按钮灰化 不能再申请
		if isReq == 1 then 
			Button_Request:setBright(false)
			Button_Request:setTouchEnabled(false)
			Image_FuncName:loadTexture(getSocialGroupImg("Btn_FuncName_YiShenQing"))
		end
		
		--帮派排名
		local LabelBMFont_Rank = tolua.cast(Button_GroupItem:getChildByName("LabelBMFont_Rank"), "LabelBMFont")
		local ranking = nIndex
		if tbData[nIndex].ranking then 
			ranking = tbData[nIndex].ranking
		end
		if ranking > 3 then
			LabelBMFont_Rank:setFntFile("Char/Char_AreanaRank2.fnt")
			LabelBMFont_Rank:setText(ranking)
		else 
			LabelBMFont_Rank:setFntFile("Char/Char_AreanaRank1.fnt")
			LabelBMFont_Rank:setText(ranking)
		end
		--帮派成员 拥有多少人员/人员上限
		local Label_MemberCount = tolua.cast(Button_GroupItem:getChildByName("Label_MemberCount"), "Label")
		local cur_mem_num = tbData[nIndex].cur_mem_num
		local max_mem_num = tbData[nIndex].max_mem_num
		Label_MemberCount:setText(cur_mem_num.."/"..max_mem_num)
	end
		
	--记录滑动到什么位置了
	local function onAdjustListView(Panel_GroupItem, nIndex)
		g_ListView_GroupList_Index = nIndex
		if nIndex == g_Guild:getOffset() then 
			-- 向服务器请求
			g_Guild:addPageNum(1)
			g_Guild:GuildListRequest(g_Guild:getPageNum())
			g_Guild:addOffset(20)
		end
    end
    groupRequestList:setModel(Panel_GroupItem)
	groupRequestList:setAdjustFunc(onAdjustListView)
    groupRequestList:setUpdateFunc(updateListViewItem)
    groupRequestList:setListView(ListView_GroupList)
	g_ListView_GroupList_Index = g_ListView_GroupList_Index or 1
	groupRequestList:updateItems(#tbData, g_ListView_GroupList_Index)
end

--帮派申请
function Game_GroupCreate:groupRequest()
	self.distinguish = FLAG.applyFor
	local Image_GroupRequestPNL = tolua.cast(self.rootWidget:getChildByName("Image_GroupRequestPNL"), "ImageView")
	local Image_SearchPNL = tolua.cast(Image_GroupRequestPNL:getChildByName("Image_SearchPNL"), "ImageView")
	
	local Label_Tips = tolua.cast(Image_SearchPNL:getChildByName("Label_Tips"), "ImageView")

	local CheckBox_ShowAvailable = tolua.cast(Image_SearchPNL:getChildAllByName("CheckBox_ShowAvailable"), "CheckBox")
	local function onShowAvailable(pSender, eventType)
		if eventType == ccs.CheckBoxEventType.selected then
			pSender:loadTextureBackGround(getSocialGroupImg("CKB_ShowCanRequest_Check"))
			pSender:loadTextureBackGroundSelected(getSocialGroupImg("CKB_ShowCanRequest_Check"))
			pSender:loadTextureBackGroundDisabled(getSocialGroupImg("CKB_ShowCanRequest_Check"))
			self.listView:updateItems(0)
			local tbGuildList = g_Guild:getGuildListInfo()
			local tb = {}
			for key, value in ipairs(tbGuildList) do
				--帮派申请条件
				local reqType = value["reqconti"]["req_type"]
				if reqType == macro_pb.GUILD_REQ_TYPE_ANYBODY then 
					table.insert(tb,value)
				end
			end
			self:listViewShow(tb)
		else
			pSender:loadTextureBackGround(getSocialGroupImg("CKB_ShowCanRequest"))
			pSender:loadTextureBackGroundSelected(getSocialGroupImg("CKB_ShowCanRequest"))
			pSender:loadTextureBackGroundDisabled(getSocialGroupImg("CKB_ShowCanRequest"))
			local tbGuildList = g_Guild:getGuildListInfo()
			self:listViewShow(tbGuildList)
		end
	end
    CheckBox_ShowAvailable:setTouchEnabled(true)
    CheckBox_ShowAvailable:addEventListenerCheckBox(onShowAvailable)
	
	Label_Tips:setPositionX(-(Label_Tips:getSize().width+CheckBox_ShowAvailable:getSize().width+10)/2)
	g_AdjustWidgetsPosition({Label_Tips, CheckBox_ShowAvailable}, 10)

	local tbGuildList = g_Guild:getGuildListInfo()
	self:listViewShow(tbGuildList)

end

function Game_GroupCreate:stringSub(mystring)
    for i = 1,string.len(mystring) do 
        local account = string.sub(mystring,i,i) 
        local temp = string.byte(account) 
		if temp == 32 then 
			return temp 
		end
    end 
	return nil 
end

--帮派创建
function Game_GroupCreate:groupCreate()
	local Image_GroupSetUpPNL = tolua.cast(self.rootWidget:getChildByName("Image_GroupSetUpPNL"), "ImageView")
	local Image_ConditionPNL = tolua.cast(Image_GroupSetUpPNL:getChildByName("Image_ConditionPNL"), "ImageView")
	
	local golds = g_Hero:getCoins()
	local coupons = g_Hero:getYuanBao()

	local needMoney = g_DataMgr:getGlobalCfgCsv("group_create_money")
	local needYuanBao = g_DataMgr:getGlobalCfgCsv("group_create_yuanbao")
	--铜钱
	local Label_NeedMoney = tolua.cast(Image_ConditionPNL:getChildByName("Label_NeedMoney"), "Label")
	Label_NeedMoney:setText(needMoney)	
	g_SetLabelRed(Label_NeedMoney,needMoney >= golds )
	--元宝
	local Label_NeedYuanBao = tolua.cast(Image_ConditionPNL:getChildByName("Label_NeedYuanBao"), "Label")
	Label_NeedYuanBao:setText(needYuanBao)
	g_SetLabelRed(Label_NeedYuanBao,needYuanBao >= coupons)
	
	local Button_Create = tolua.cast(Image_GroupSetUpPNL:getChildByName("Button_Create"), "Button")
	
	local TextField_GroupName = tolua.cast(Image_ConditionPNL:getChildByName("TextField_GroupName"), "TextField")
	TextField_GroupName:setText("")
		
	if g_LggV:getLanguageVer() == eLanguageVer.LANGUAGE_zh_CN then
		TextField_GroupName:setMaxLength(7)
	elseif g_LggV:getLanguageVer() == eLanguageVer.LANGUAGE_cht_Taiwan then
		TextField_GroupName:setMaxLength(7)
	elseif g_LggV:getLanguageVer() == eLanguageVer.LANGUAGE_zh_AUDIT then
		TextField_GroupName:setMaxLength(7)
	else
		TextField_GroupName:setMaxLength(12)
	end
	
	local function textFieldEvent(pSender,eventType)
		if eventType == ccs.TextFiledEventType.insert_text 
			or eventType == ccs.TextFiledEventType.delete_backward then
			local mString = TextField_GroupName:getStringValue()
			if 	mString ~= "" then 
				Button_Create:setBright(true)
				Button_Create:setTouchEnabled(true)
			else
				Button_Create:setBright(false)
				Button_Create:setTouchEnabled(false)
			end
		end
	end
	TextField_GroupName:addEventListenerTextField(textFieldEvent) 
	
	local function onButtonCreate(pSender,eventType)
		if eventType == ccs.TouchEventType.ended then
			if golds < needMoney then
				local txt = string.format(_T("创建帮派需要消耗%d铜钱, 您的铜钱不足"), needMoney)
				g_ClientMsgTips:showMsgConfirm(txt)
				return
			end
			
			if coupons < needYuanBao then
				local txt = string.format(_T("创建帮派需要消耗%d元宝, 您的元宝不足"), needYuanBao)
				g_ClientMsgTips:showMsgConfirm(txt)
				return
			end
			
			local account = TextField_GroupName:getStringValue()
			local strSub = self:stringSub(account)
			if strSub == 32 then 
				g_ClientMsgTips:showMsgConfirm(_T("帮派名称不能包含空格"))
			else
				-- local accountIndex = 0
				-- local nIndex = 1
				-- local nLen = tonumber( string.len(account))
				-- while nIndex <= nLen do
					-- local c = string.byte(account, nIndex)
					-- local nShift = 1
					-- if c > 0 and c <= 127 then
						-- nShift = 1
					-- else
						-- nShift = 3
					-- end
					-- local substr = string.sub(account,nIndex,nIndex+nShift-1)
					-- nIndex = nIndex + nShift
					-- accountIndex = accountIndex + 1
				-- end
				
				-- if accountIndex > 7 then 
					-- g_ClientMsgTips:showMsgConfirm(_T("名字不能大于7个字"))
				-- else
					--要判断玩家是否处于帮派关系发生变动之后需要24小时之后
					local times = g_Guild:getGuildChangeColdat()-os.time()
					if times > 0 then
						local txt = string.format(_T("帮派关系发生变动之后需要%d分钟之后才可再次操作"), math.floor(times/60))
						g_ClientMsgTips:showMsgConfirm(txt)
					else
						g_Guild:requestGuildCreateRequest(account)
					end
				-- end
			end
		end
	end
	
	Button_Create:addTouchEventListener(onButtonCreate)
	
	local flag = true
	if TextField_GroupName:getStringValue() == "" then 
		flag = false
	end
	
	Button_Create:setBright(flag)
	Button_Create:setTouchEnabled(flag)	
	
end

--帮派查询
function Game_GroupCreate:groupSearch()
	self.distinguish = FLAG.refer
	
	local Image_GroupSearchPNL = tolua.cast(self.rootWidget:getChildByName("Image_GroupSearchPNL"), "ImageView")
	local tbGuildList = g_Guild:getGuildListInfo()
	self:listViewShow(tbGuildList)
	
	local Image_SearchPNL = tolua.cast(Image_GroupSearchPNL:getChildByName("Image_SearchPNL"), "ImageView")
	local Image_GroupName = tolua.cast(Image_SearchPNL:getChildByName("Image_GroupName"), "ImageView")
	local TextField_GroupName = tolua.cast(Image_GroupName:getChildByName("TextField_GroupName"), "TextField")
	TextField_GroupName:setText("")
	
	local function textFieldEvent(sender,eventType)
		if eventType == ccs.TextFiledEventType.insert_text 
			or eventType == ccs.TextFiledEventType.delete_backward then
			local mString = TextField_GroupName:getStringValue()
			if mString == "" then 
				local tbGuildList = g_Guild:getGuildListInfo()
				self:listViewShow(tbGuildList)
			end
		end
	end
	TextField_GroupName:addEventListenerTextField(textFieldEvent) 
		
	local function onButtonSearch(pSender,eventType)
		if eventType == ccs.TouchEventType.ended then	
			local account = TextField_GroupName:getStringValue()
			local strSub = self:stringSub(account)
			if strSub == 32 then 
				g_ClientMsgTips:showMsgConfirm(_T("无法查询到对应的帮派，请确认输入是否有误"))
			else
				local accountIndex = 0
				local nIndex = 1
				local nLen = tonumber( string.len(account))
				while nIndex <= nLen do
					local c = string.byte(account, nIndex)
					local nShift = 1
					if c > 0 and c <= 127 then
						nShift = 1
					else
						nShift = 3
					end
					local substr = string.sub(account,nIndex,nIndex+nShift-1)
					nIndex = nIndex + nShift
					accountIndex = accountIndex + 1
				end
				if accountIndex > 7 then
					cclog("名字不能大于7个字")
				else
					local tbSearch = {}
					for i = 1,#tbGuildList do
						local name = tbGuildList[i].name 
						if account == name then 
							local tb = {}
							tb.id = tbGuildList[i].id
							tb.king_breachlv =  tbGuildList[i].king_breachlv
							tb.is_req =  tbGuildList[i].is_req
							tb.reqconti = {
								["req_type"] = tbGuildList[i].reqconti.req_type,
								["req_lev"] = tbGuildList[i].reqconti.req_lev
							}
							tb.max_mem_num =  tbGuildList[i].max_mem_num
							tb.cur_mem_num =  tbGuildList[i].cur_mem_num
							tb.king_card =  tbGuildList[i].king_card
							tb.king_uin =  tbGuildList[i].king_uin
							tb.name =  tbGuildList[i].name
							tb.king_star =  tbGuildList[i].king_star
							tb.king_name =  tbGuildList[i].king_name
							tb.level =  tbGuildList[i].level
							tb.ranking = i
							table.insert(tbSearch,tb)
						end
					end
					if next(tbSearch) ~= nil then 
						self:listViewShow(tbSearch)
						tbSearch = {}
					else
						g_ClientMsgTips:showMsgConfirm(_T("无法查询到对应的帮派，请确认输入是否有误"))
					end
				end
			end
		end
	end
	local Button_Search = tolua.cast(Image_SearchPNL:getChildByName("Button_Search"), "Button")
	Button_Search:setTouchEnabled(true)
	Button_Search:addTouchEventListener(onButtonSearch)
end



--帮派申请请求
function Game_GroupCreate:requestGuildApplyRequest(guildId)
	cclog("---------requestGuildApplyRequest-------------")
	cclog("---------帮派申请请求-------------")
	local msg = zone_pb.GuildApplyRequest() 
	msg.guild_id = guildId --申请帮派id
	g_MsgMgr:sendMsg(msgid_pb.MSGID_GUILD_APPLY_REQUEST, msg)
end

--需要审批的帮派申请响应
function Game_GroupCreate:requestGuildApplyResponse(tbMsg)
	cclog("---------requestGuildApplyResponse-------------")
	cclog("---------需要审批的帮派申请响应-------------")
	local msgDetail = zone_pb.GuildApplyResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	local msgInfo = tostring(msgDetail)
	cclog(msgInfo)
	
	local nGuildId = msgDetail.guild_id
	
	local tbGuildList = g_Guild:getGuildListInfo()
	
	for i = 1,#tbGuildList do
		if tbGuildList[i].id == nGuildId then 
			g_Guild:setIsreq(i,1)
		end
	end
	
	local wndInstance = g_WndMgr:getWnd("Game_GroupCreate")
	if wndInstance then 
		local nCurPageIndex = wndInstance.ButtonGroup:getButtonCurIndex()
		if nCurPageIndex == 1 then
			local Image_GroupRequestPNL = tolua.cast(wndInstance.rootWidget:getChildByName("Image_GroupRequestPNL"), "ImageView")
			local ListView_GroupList = tolua.cast(Image_GroupRequestPNL:getChildByName("ListView_GroupList"), "ListViewEx")
			local Panel_GroupItem = tolua.cast(ListView_GroupList:getChildByTag(nGuildId), "Layout")
			if Panel_GroupItem then
				local Button_GroupItem = tolua.cast(Panel_GroupItem:getChildByName("Button_GroupItem"), "Button")
				local Button_Request = tolua.cast(Button_GroupItem:getChildByName("Button_Request"), "Button")
				Button_Request:setBright(false)
				Button_Request:setTouchEnabled(false)
				local Image_FuncName = tolua.cast(Button_Request:getChildByName("Image_FuncName"), "ImageView")
				Image_FuncName:loadTexture(getSocialGroupImg("Btn_FuncName_YiShenQing"))
			end
		elseif nCurPageIndex == 3 then
			local Image_GroupSearchPNL = tolua.cast(wndInstance.rootWidget:getChildByName("Image_GroupSearchPNL"), "ImageView")
			local ListView_GroupList = tolua.cast(Image_GroupSearchPNL:getChildByName("ListView_GroupList"), "ListViewEx")
			local Panel_GroupItem = tolua.cast(ListView_GroupList:getChildByTag(nGuildId), "Layout")
			if Panel_GroupItem then
				local Button_GroupItem = tolua.cast(Panel_GroupItem:getChildByName("Button_GroupItem"), "Button")
				local Button_Request = tolua.cast(Button_GroupItem:getChildByName("Button_Request"), "Button")
				Button_Request:setBright(false)
				Button_Request:setTouchEnabled(false)
				local Image_FuncName = tolua.cast(Button_Request:getChildByName("Image_FuncName"), "ImageView")
				Image_FuncName:loadTexture(getSocialGroupImg("Btn_FuncName_YiShenQing"))
			end
		end
	end
end