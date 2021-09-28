--------------------------------------------------------------------------------------
-- 文件名: LKA_Social1Wnd.lua
-- 版  权:    (C)深圳美天互动科技有限公司
-- 创建人: 陆奎安
-- 日  期:    2013-4-5 9:37
-- 版  本:    1.0
-- 描  述:    公告界面
-- 应  用:  本例子是用类对象的方式实现
---------------------------------------------------------------------------------------

Game_Social1 = class("Game_Social1")
Game_Social1.__index = Game_Social1

g_TBSocial = 
{	
	curChat_uin = 1 ,--当前聊天对象uin
	curApplicatNum = 0, --当前申请个数
	curFriendNum = 0, --当前新加好友个 数
	g_FriendNum = 0,
	NewChatNumber = 0, -- 新来消息个数
	gamerMsg = {}, --玩家信息
	ChatMSGNum = {}, ---聊天记录
	ChatMSG = {},
	friendList = {} ,---好友列表
	ApplicationList = {}, --好友申请列表
	NeighborList = {}--附近的人
}

--默认值
g_textSignature = _T("人的一生确实是需要一个伟大的签名...")
local tbSocial = 
{
	textArea = _T("广州-深圳"), --地区
	textProfession = _T("无业游民"),  --职业
	textIndustry = _T("其他") , --行业
	textSignature = g_textSignature,  --签名
}
--一键送爱心
function Game_Social1:oneSendFP()
	local tbFPStatus = g_Hero:getSendFriendPointsStatus()
	local tbMsg = {}
	for i,v in pairs(g_TBSocial.friendList)do
		if tbFPStatus[i] then
		else
			table.insert(tbMsg,i)
		end
	end
	if #tbMsg == 0 then return end
	g_MsgMgr:SendHeartRequest(tbMsg)
end
--一键收爱心
function Game_Social1:oneRecvFP()
	local tbFPStatus = g_Hero:getReceiveFriendPointsStatus()

	local tbMsg = {}
	for i,v in pairs(g_TBSocial.friendList)do
		if tbFPStatus[i] and tbFPStatus[i] == 0 then
			table.insert(tbMsg,i)
		end
	end
	if #tbMsg == 0 then return end
	g_MsgMgr:RecvHeartRequest(tbMsg)
end

-- // 爱心领取状态
-- enum FriendHeartRecvState
-- {
-- 	FriendHeartRecvState_CanRecv = 0;	// 可以领
-- 	FriendHeartRecvState_AlreadyRecv = 1;	// 已领取
-- 	FriendHeartRecvState_NULL = 2;		// 空状态，比如隔天已领取状态重置
-- }

--设置爱心相关按钮状态
function Game_Social1:setFPButton(Button_SocialItem, uin)
	local Button_Social1 = tolua.cast(Button_SocialItem:getChildByName("Button_Social1"),"Button")
	local Button_Social2 = tolua.cast(Button_SocialItem:getChildByName("Button_Social2"),"Button")
	local tbFPStatus = g_Hero:getSendFriendPointsStatus()
	local nStatus = tbFPStatus[uin]

	--发送爱心状态
	local Image_FuncIcon2 = tolua.cast(Button_Social2:getChildByName("Image_FuncIcon2"),"ImageView")
	local Image_FuncIcon3 = tolua.cast(Button_Social2:getChildByName("Image_FuncIcon3"),"ImageView")
	if nStatus then
		Image_FuncIcon2:setVisible(nStatus == 0)
		Image_FuncIcon3:setVisible(nStatus == 1)
	else
		Image_FuncIcon2:setVisible(true)
		Image_FuncIcon3:setVisible(false)
	end
	
	--收到爱心状态
	tbFPStatus = g_Hero:getReceiveFriendPointsStatus()
	local nStatus = tbFPStatus[uin]
	Button_Social1:setVisible(true)
	local Image_FuncIcon2 = tolua.cast(Button_Social1:getChildByName("Image_FuncIcon2"),"ImageView")
	local Image_FuncIcon3 = tolua.cast(Button_Social1:getChildByName("Image_FuncIcon3"),"ImageView")
	if nStatus == macro_pb.FriendHeartRecvState_CanRecv then
		Image_FuncIcon2:setVisible(true)
		Image_FuncIcon3:setVisible(false)
	elseif nStatus == macro_pb.FriendHeartRecvState_AlreadyRecv then
		Image_FuncIcon2:setVisible(false)
		Image_FuncIcon3:setVisible(true)
	else
		Button_Social1:setVisible(false)
	end
end

--设置Button——lable
function Game_Social1:setButtonText(Button_SocialItem, nBtnTag)
	local nSwap = math.floor(nBtnTag/1000)
	local nTag = nSwap % 10
	
	for i = 1, 2 do
		local Button_Social = tolua.cast(Button_SocialItem:getChildByName("Button_Social"..i),"Button")
		local nTag = nBtnTag + 100*(i-1)
		Button_Social:setTag(nTag)
		local function onClick()
			self:SocialBtnOnclick(nTag)
		end
		g_SetBtn(Button_SocialItem, "Button_Social"..i, onClick, true,true)	
	end
end

--在单个聊天列表Item里显示冒泡
function Game_Social1:showNotesChatItem(isVisible,uin,widget)
	local number 
	if isVisible then
	else
		g_TBSocial.ChatMSGNum[uin].number = 0
	end 
	g_TBSocial.ChatMSGNum[uin] = g_TBSocial.ChatMSGNum[uin] or {}
	if not g_TBSocial.ChatMSGNum[uin] or  not g_TBSocial.ChatMSGNum[uin].number then
		number = 0
	else
		number = g_TBSocial.ChatMSGNum[uin].number 
	end 

	g_SetBubbleNotify(widget, number,50,50)
end	

--显示冒泡
function Game_Social1:showNotes(isVisible,nTag,Number)
	local x = 70
	local y = 20
	if isVisible then
	else
		Number = 0
	end
	if nTag == 1 then
	elseif nTag == 2 then
		g_SetBubbleNotify(self.CheckBox_Friend, g_Hero:getBubbleNotify("heart"),x,y)
	elseif nTag == 3 then
		g_TBSocial.curApplicatNum = Number or g_TBSocial.curApplicatNum
		g_SetBubbleNotify(self.CheckBox_Application,g_TBSocial.curApplicatNum,x,y)	
		g_Hero.bubbleNotify.social = g_TBSocial.curApplicatNum
	end
end
--设置listViewEx
function Game_Social1:initListView_Social(nTag, ListView, ListModel, onUpdateFunc, onAdjustFunc, nNum, nMaxNum)
	if not ListView then
		return
	end 
	local nMaxNum = nMaxNum or 4
	local nNum = nNum or 0
	local Listparent = ListView:getParent()
	local Listccp = ListView:getPosition()
	local ListSize = ListView:getSize()

	LuaListView = Class_LuaListView:create()
	LuaListView:setSize(ListSize)
	LuaListView:setPosition(Listccp)
	LuaListView:setDirection(LISTVIEW_DIR_VERTICAL)
	if ListModel then
		LuaListView:setModel(ListModel)
	end
	LuaListView:setMaxCount(nMaxNum)
	if onUpdateFunc then
		LuaListView:setUpdateFunc(onUpdateFunc)
	end
	if onAdjustFunc then
		LuaListView:setAdjustFunc(onAdjustFunc)
	end
	Listparent:addChild(LuaListView:getListView(), 11)
	
	if nTag == 1 then
		self.LuaListView_Message = LuaListView
	elseif nTag == 2 then
		self.LuaListView_Friend = LuaListView
	elseif nTag == 3 then
		self.LuaListView_Application = LuaListView
	elseif nTag == 4 then
		self.LuaListView_Neighbor = LuaListView
	else
	end
	
	local imgScrollSlider = LuaListView:getScrollSlider()
	if not g_tbScrollSliderXY.ListView_Social_X then
		g_tbScrollSliderXY.ListView_Social_X = imgScrollSlider:getPositionX()
	end
	imgScrollSlider = imgScrollSlider:setPositionX(g_tbScrollSliderXY.ListView_Social_X + 8)
	
	return LuaListView
end
--好友排序
local function sortTbFriend(tb1,tb2)
	--是否赠送table 1 已赠送   0 or nil 未赠送
	local tbFPStatus = g_Hero:getSendFriendPointsStatus() 
	local status1 = tbFPStatus[tb1.key] == nil and 0 or tbFPStatus[tb1.key]
	local status2 = tbFPStatus[tb2.key] == nil and 0 or tbFPStatus[tb2.key]

	--是否领取 0未领取 1已领取 nil是没有发送
	local tbFPGet = g_Hero:getReceiveFriendPointsStatus()
	local staget1 = tbFPGet[tb1.key]
	local staget2 = tbFPGet[tb2.key]

	--存等级 vip uin的地方
	local value1 = tb1.value
	local value2 = tb2.value

	if status1 == 1 and status2 == 0 then
		return true
	elseif status1 == 0 and status2 == 1 then
		return false
	end

	if staget1 == 0 and  staget2 == 1 then
		return true
	elseif staget1 == 1 and  staget2 == 0 then
		return false
	elseif staget1 == nil and  staget2 ~= nil then
		return false
	elseif staget1 ~= nil and  staget2 == nil then
		return true
	end


	if value1.vip > value2.vip then
		return true
	elseif value1.vip < value2.vip then
		return false
	end

	if value1.level > value2.level then
		return true
	elseif value1.level < value2.level then
		return false
	end
	
	return value1.uin < value2.uin 

end
 
function Game_Social1:upDateTable(tabel, listViewEx, ListViewType)
	local number = 0
	local self_TbMSg = {}
	for i,v in pairs(tabel) do
		number = number + 1
		table.insert(self_TbMSg,{key=i,value = v})
	end
	
	if ListViewType ==1 then
		g_TBSocial.NewChatNumber = 0
		table.sort(self_TbMSg, sortTbFriend)
	end
	
	local function ListViewExItemInfo(mItem, nIndex)
		local i, v= self_TbMSg[nIndex].key, self_TbMSg[nIndex].value
		self:setListView_Social(mItem, nIndex, ListViewType, v, i)
	end
	listViewEx:setUpdateFunc(ListViewExItemInfo)
	if ListViewType == 1 then --好友列表
		listViewEx:updateItems(#self_TbMSg, self.ListView_Frient_Index or 1)
	elseif ListViewType == 2 then --好友请求
		listViewEx:updateItems(#self_TbMSg, self.ListView_Application_Index or 1)
	end
	
	return number 
end
 
--刷新游戏好友
function Game_Social1:upDateFriendList()
	local number = self:upDateTable(g_TBSocial.friendList, self.LuaListView_Friend, 1)
	g_FriendNum = number
	self:setFriendCapacity()
end
--刷新好友请求
function Game_Social1:upDateApplicationPNL()
	local number = self:upDateTable(g_TBSocial.ApplicationList, self.LuaListView_Application, 2)
end
--刷新附近的人
function Game_Social1:upDateNeighborPNL()
	self.LuaListView_Neighbor:updateItems(#g_TBSocial.NeighborList, self.ListView_Neighbor_Index or 1)
end

--listViewItem里按钮回调
function Game_Social1:SocialBtnOnclick(number)
	local FindMsg = {}
	local nIndex = number % 100
	local swp = math.floor( number / 100)
	local nTag = swp % 100
	local uin = math.floor( swp / 100)
	if nTag ==11 then		  --接收体力
		local tbFPStatus = g_Hero:getReceiveFriendPointsStatus()
		if tbFPStatus[uin] and tbFPStatus[uin] == 0 then
			local tbMsg = {}
			tbMsg[1] = uin
			g_MsgMgr:RecvHeartRequest(tbMsg)
		end
	elseif nTag == 12 then       --送体力
		local tbFPStatus = g_Hero:getSendFriendPointsStatus()
		if tbFPStatus[uin] then
		else
			local tbMsg = {}
			tbMsg[1] = uin
			g_MsgMgr:SendHeartRequest(tbMsg)
		end
	elseif nTag == 21 then                     --同意请求
		self:showNotes(false,3)
		g_SocialMsg:setDealAddFmsg(uin,true)
		
	elseif nTag == 22 then                      --忽略请求
		self:showNotes(false,3)
		g_SocialMsg:setDealAddFmsg(uin,false)
	elseif nTag == 31 then
		if g_CheckFuncCanOpenByWidgetName("Button_QieCuo") then
			self.NextReturn = false
			g_MsgMgr:requestViewPlayerPk(uin)
		else
			local nOpenLevel = getFunctionOpenLevelCsvByStr("Button_QieCuo").OpenLevel
			local strOpenFuncName = getFunctionOpenLevelCsvByStr("Button_QieCuo").OpenFuncName
			local nOpenVipLevel = getFunctionOpenLevelCsvByStr("Button_QieCuo").OpenVipLevel
			if nOpenLevel <= 200 then
				if nOpenVipLevel >= 1 then
					g_ShowSysWarningTips({text = string.format(_T("%s将在%d级开放, 加油练级哦~亲~！\n或在VIP等级达到VIP%d后开放~"), strOpenFuncName, nOpenLevel, nOpenVipLevel)})
				else
					g_ShowSysWarningTips({text = string.format(_T("%s将在%d级开放, 加油练级哦~亲~！"), strOpenFuncName, nOpenLevel)})
				end
			else
				g_ShowSysWarningTips({text =_T("功能暂未开放敬请期待...")})
			end
		end
	elseif nTag == 32 then                     
		FindMsg.uin = uin
		FindMsg.msg = _T("你好")
		g_MsgMgr:requestRelationAddFriend(FindMsg)
	end
end
--设置头像
function Game_Social1:setHeadInfo(Image_Head, tbHeadInfo, strName)
	Image_Head:loadTexture(getCardBackByEvoluteLev(tbHeadInfo.breachlv))
	
	local LabelBMFont_VipLevel = tolua.cast(Image_Head:getChildByName("LabelBMFont_VipLevel"),"LabelBMFont")
	LabelBMFont_VipLevel:setText(_T("VIP")..tbHeadInfo.vip)
	
	local Image_Frame = tolua.cast(Image_Head:getChildByName("Image_Frame"),"ImageView")
	Image_Frame:loadTexture(getCardFrameByEvoluteLev(tbHeadInfo.breachlv))

	local Image_Icon = tolua.cast(Image_Head:getChildByName("Image_Icon"),"ImageView")
	if strName == "小语" then
		Image_Icon:loadTexture(getIconImg("XiaoYu"))
		Image_Icon:setVisible(true)
	else
		Image_Icon:loadTexture(tbHeadInfo.strIcon)
		Image_Icon:setVisible(true)
	end
	
	if tbHeadInfo.uin ~= g_MsgMgr:getUin() then
		Image_Icon:setTouchEnabled(true)
		Image_Icon:addTouchEventListener(function(pSender, eventType)
			if eventType ==ccs.TouchEventType.ended then
				if strName == "小语" then
					g_ShowSysTips({text=_T("暂时还无法查看官方Npc哦亲")})
				else
					local nTag = pSender:getTag()
					g_MsgMgr:requestViewPlayer(tbHeadInfo.uin)
					self.NextReturn = false
				end
			end
		end)
	end 
end
--设置性别
function Game_Social1:setItemSex(LabelAtlas_Sex, is_man)
	if is_man and is_man == true or is_man == 1 or is_man == "1" then
		LabelAtlas_Sex:setStringValue(1)
	else
		LabelAtlas_Sex:setStringValue(2)
	end
end
--设置职业
function Game_Social1:setProfession(Label_Profession,professionMsg)
	if professionMsg and professionMsg ~= "" then
		Label_Profession:setText(professionMsg)
	else
		Label_Profession:setText(tbSocial.textProfession)
	end
end
--设置行业
function Game_Social1:setIndustry(Label_Industry,industryMsg)
	if industryMsg and industryMsg ~= "" then
		Label_Industry:setText(g_profession[industryMsg])
	else
		Label_Industry:setText(tbSocial.textIndustry)
	end
end
--设置地区
function Game_Social1:setArea(Label_Area, areaMsg)
	if areaMsg then
		local mCity, mArea = g_GetSoCityText(areaMsg)
        if mArea then
		    Label_Area:setText(mCity.." - "..mArea)
        else
            Label_Area:setText(mCity)
        end
	else
		Label_Area:setText(tbSocial.textArea)
	end
end

--设置爱心按钮
function Game_Social1:setFriendPoints(widget,uin,tb_msg)
	
end
--设置签名
function Game_Social1:setSignature(Label_Signature,signatureMsg)
	Label_Signature:setText(signatureMsg=="" and _T("人的一生确实是需要一个伟大的签名...") or signatureMsg)
end

function Game_Social1:setListView_Social(Panel_SocialItem, nIndex, nTag, tbServerMsg, uin)
	if not tbServerMsg then	return end
	local Button_SocialItem = tolua.cast(Panel_SocialItem:getChildByName("Button_SocialItem"), "Button")

	local nBtnTag = tbServerMsg.uin*10000 + (nTag*10+1)*100 + nIndex
	self:setButtonText(Button_SocialItem, nBtnTag)
	
	local strLabel_Text 
	if nTag == 1 then -- 好友
		strLabel_Text = tbServerMsg.signature
		local function onChatClick()
			g_TBSocial.curChat_uin = tbServerMsg.uin
			g_SALMgr:upDateChatData(tbServerMsg.uin)
			g_WndMgr:showWnd("Game_ChatCenter", tbServerMsg.uin)
		end
		self:setFPButton(Button_SocialItem, tbServerMsg.uin)
	elseif nTag == 2 then --申请
		strLabel_Text = tbServerMsg.msg
	elseif nTag == 3 then --附近的人
		tbServerMsg = g_TBSocial.NeighborList[nIndex] 
		strLabel_Text = tbServerMsg.signature
	end
	
	--头像
	local Image_Head = tolua.cast(Button_SocialItem:getChildByName("Image_Head"),"ImageView")
	Image_Head:setTag(tbServerMsg.uin)
	local tb_HeadInfo = {}
	if tbServerMsg.card_info[1] then
		tb_HeadInfo.strIcon = getCardIconImg(tbServerMsg.card_info[1].configid, tbServerMsg.card_info[1].star_lv)
		tb_HeadInfo.vip = tbServerMsg.vip
		tb_HeadInfo.uin = tbServerMsg.uin
		tb_HeadInfo.star = tbServerMsg.card_info[1].star_lv
		tb_HeadInfo.breachlv = tbServerMsg.card_info[1].breachlv
		self:setHeadInfo(Image_Head, tb_HeadInfo, tbServerMsg.name)
	end

	--名字
	local Label_Name = tolua.cast(Button_SocialItem:getChildByName("Label_Name"),"Label")
	if tbServerMsg.name == "小语" then
		Label_Name:setText(getFormatSuffixLevel(_T("小语"), g_GetCardEvoluteSuffixByEvoLev(tb_HeadInfo.breachlv)))
	else
		Label_Name:setText(getFormatSuffixLevel(tbServerMsg.name, g_GetCardEvoluteSuffixByEvoLev(tb_HeadInfo.breachlv)))
	end
	g_SetCardNameColorByEvoluteLev(Label_Name, tb_HeadInfo.breachlv or 1)

	--性别
	local LabelAtlas_Sex = tolua.cast(Label_Name:getChildByName("LabelAtlas_Sex"),"LabelAtlas")
	self:setItemSex(LabelAtlas_Sex, tbServerMsg.is_man)
	LabelAtlas_Sex:setPositionX(Label_Name:getSize().width + 15)
	--地区
	local Label_Distance = tolua.cast(Button_SocialItem:getChildByName("Label_Distance"),"Label")
	self:setArea(Label_Distance,tbServerMsg.area)
	--签名
	local Label_Text = tolua.cast(Button_SocialItem:getChildByName("Label_Text"),"Label")
	if strLabel_Text == "人的一生确实是需要一个伟大的签名..." then
		self:setSignature(Label_Text, _T("人的一生确实是需要一个伟大的签名..."))
	else
		self:setSignature(Label_Text, strLabel_Text)
	end
	--等级
	local Label_Level = tolua.cast(Button_SocialItem:getChildByName("Label_Level"),"Label")
	Label_Level:setText(tbServerMsg.level.._T("级")	)
	
	local BitmapLabel_TeamStrengthen = tolua.cast(Button_SocialItem:getChildByName("BitmapLabel_TeamStrengthen"),"LabelBMFont")	
	BitmapLabel_TeamStrengthen:setText(tbServerMsg.fighting )
end

--Init同城
function Game_Social1:initImageNeighborPNL()
	local function onUpdate_ListView_Social(Panel_SocialItem, nIndex)
        self:setListView_Social(Panel_SocialItem, nIndex, 3, g_TBSocial.NeighborList[nIndex])
    end
	local function onAdjust_ListView_Social(Panel_SocialItem, nIndex)
		self.ListView_Neighbor_Index = nIndex
    end
	local ListView_Social = tolua.cast(self.Image_NeighborPNL:getChildByName("ListView_Social"), "ListViewEx")
	local Panel_SocialItem = tolua.cast(g_WidgetModel.Panel_SocialItem_Neighbor:clone(),"Layout")
	self:initListView_Social(4, ListView_Social, Panel_SocialItem, onUpdate_ListView_Social, onAdjust_ListView_Social)
end
--Init好友请求
function Game_Social1:initApplicationPNL()
	local function onUpdate_ListView_Social(Panel_SocialItem, nIndex)
		Panel_SocialItem:setVisible(true)
        self:setListView_Social(Panel_SocialItem, nIndex, 2, g_TBSocial.ApplicationList[nIndex])
    end
	local function onAdjust_ListView_Social(Panel_SocialItem, nIndex)
		self.ListView_Application_Index = nIndex
    end
	local ListView_Social = tolua.cast(self.Image_ApplicationPNL:getChildByName("ListView_Social"),"ListViewEx")
	local Panel_SocialItem = tolua.cast(g_WidgetModel.Panel_SocialItem_Application:clone(),"Layout")
	self:initListView_Social(3, ListView_Social, Panel_SocialItem, onUpdate_ListView_Social, onAdjust_ListView_Social)
end
--init好友
function Game_Social1:initFriendPNL()
	local function onUpdate_ListView_Social(Panel_SocialItem, nIndex)
		Panel_SocialItem:setVisible(true)
        self:setListView_Social(Panel_SocialItem, nIndex, 1, g_TBSocial.friendList[nIndex])
    end
	local function onAdjust_ListView_Social(Panel_SocialItem, nIndex)
		self.ListView_Frient_Index = nIndex
    end
	local ListView_Social = tolua.cast(self.Image_FriendPNL:getChildByName("ListView_Social"),"ListViewEx")
	local Panel_SocialItem = tolua.cast(g_WidgetModel.Panel_SocialItem_Friend:clone(),"Layout")
	self:initListView_Social(2, ListView_Social, Panel_SocialItem, onUpdate_ListView_Social, onAdjust_ListView_Social)
end

--发送个人信息tb
function Game_Social1:setTbRlInfomsg()
    local tb = {}
    local tbMsg =  g_TBSocial.gamerMsg[g_MsgMgr:getUin()]
    tb.is_man = tbMsg.is_man
	tb.profession = tbMsg.profession
	tb.area = tbMsg.area
	tb.signature = tbMsg.signature
    tb.industry = tbMsg.industry
	if not tbMsg.industry then
       	tb.industry = 16
    end 
    if not tbMsg.area then
       	tb.area = 101
    end
    if not tbMsg.signature then
       	tb.signature = "22"
    end
    if not tbMsg.profession then
        tb.profession = "111"
    end
	g_MsgMgr:requestRelationSetRoleInfo(tb)
end

--Init我的资料
function Game_Social1:initMyProfilePNL()
	local ListView_MyProfile = tolua.cast(self.Image_MyProfilePNL:getChildByName("ListView_MyProfile"),"ListViewEx")
	local Button_Sex = tolua.cast(ListView_MyProfile:getChildByName("Button_Sex"),"Button")
	local Button_Signature = tolua.cast(ListView_MyProfile:getChildByName("Button_Signature"),"Button")	
	local Button_Profession = tolua.cast(ListView_MyProfile:getChildByName("Button_Profession"),"Button")	
	local Button_Industry = tolua.cast(ListView_MyProfile:getChildByName("Button_Industry"),"Button")	
	local Button_Area = tolua.cast(ListView_MyProfile:getChildByName("Button_Area"),"Button")
	
	--设置城市回调
	local function setCityText()
        g_TBSocial.gamerMsg[g_MsgMgr:getUin()].area = g_CheckListIndex
        self:setTbRlInfomsg()
    end 
	--设置行业回调
    local function setIndustryText()
        g_TBSocial.gamerMsg[g_MsgMgr:getUin()].industry = g_CheckListIndex
        self:setTbRlInfomsg()
    end 
	--设置性别回调
    local function setSexText()
        if g_CheckListIndex == 1 then
            g_TBSocial.gamerMsg[g_MsgMgr:getUin()].is_man = true
        else
            g_TBSocial.gamerMsg[g_MsgMgr:getUin()].is_man= false
        end
        self:setTbRlInfomsg()
    end 
	--设置职业回调
    local function sendProfessionMsgMgr(ConfirmInputText)
		if ConfirmInputText  then
			g_TBSocial.gamerMsg[g_MsgMgr:getUin()].profession = ConfirmInputText
			self:setTbRlInfomsg()
		end
    end 
	--设置签名回调
    local function sendSignatureLBMsgMgr(ConfirmInputText)
		if ConfirmInputText  then
			g_TBSocial.gamerMsg[g_MsgMgr:getUin()].signature = ConfirmInputText
			self:setTbRlInfomsg()
		end
    end 
	--按钮设置
	local function onClick_ProfileButton(pSender, eventType)
        if eventType ==ccs.TouchEventType.ended then
        	local nTag = pSender:getTag()
        	if nTag == 1 then
				--
        	elseif nTag == 2 then
                --性别弄成跟男女主角一致，暂时不提供修改性别
				--g_ShowCheckListWnd(g_social_sex,1,_T("性别"),setSexText) 
        	elseif nTag == 3 then
				g_ShowCheckListWnd(g_profession,1,_T("行业"),setIndustryText)
        	elseif nTag == 4 then  		
                g_ClientMsgTips:showConfirmInput(_T("职业信息"),_T("请输入你的职业"),7,sendProfessionMsgMgr,nil)
        	elseif nTag == 5 then
				if eLanguageVer.LANGUAGE_viet_VIET == g_LggV:getLanguageVer() then
					g_ShowCheckListWnd(g_ProvinceCity_Viet, 2,_T("地区"),setCityText)
				elseif eLanguageVer.LANGUAGE_cht_Taiwan == g_LggV:getLanguageVer() then
					g_ShowCheckListWnd(g_ProvinceCity_Taiwan, 2,_T("地区"),setCityText)
				else
					g_ShowCheckListWnd(g_ProvinceCity, 2,_T("地区"),setCityText)
				end
			elseif nTag == 6 then
                g_ClientMsgTips:showConfirmInput(_T("个性签名"),_T("请输入您的个性签名"),20,sendSignatureLBMsgMgr,nil)
        	end
        end
    end 

	local function registerProfileButton(widgetBtn, nTag)
        widgetBtn:setTouchEnabled(true)
        widgetBtn:setTag(nTag)
        widgetBtn:addTouchEventListener(onClick_ProfileButton)
    end
 	registerProfileButton(Button_Sex,2)
    registerProfileButton(Button_Industry,3)
    registerProfileButton(Button_Profession,4)
    registerProfileButton(Button_Area,5)
    registerProfileButton(Button_Signature,6)
end

function Game_Social1:setImageMyProfilePNL()
	self.MyProfileFirst = false
	local ListView_MyProfile = tolua.cast(self.Image_MyProfilePNL:getChildByName("ListView_MyProfile"),"ListViewEx")
	
	--头像
	local Button_HeadPotrait = tolua.cast(ListView_MyProfile:getChildByName("Button_HeadPotrait"),"Button")
	local Image_Head = tolua.cast(Button_HeadPotrait:getChildByName("Image_Head"),"ImageView")
	local GameObj_MasterCard = g_Hero:getBattleCardByIndex(1)
	local CSV_CardBase = GameObj_MasterCard:getCsvBase()
	local tb_HeadInfo = {}
	tb_HeadInfo.strIcon = getIconImg(CSV_CardBase.SpineAnimation)
	tb_HeadInfo.vip = g_VIPBase:getVIPLevelId()
	tb_HeadInfo.uin = g_MsgMgr:getUin()
	tb_HeadInfo.star = GameObj_MasterCard:getStarLevel()
	tb_HeadInfo.breachlv = GameObj_MasterCard:getEvoluteLevel()
	self:setHeadInfo(Image_Head, tb_HeadInfo)
	
	--名字
	local Button_Name = tolua.cast(ListView_MyProfile:getChildByName("Button_Name"),"Button")
	local Label_Name = tolua.cast(Button_Name:getChildByName("Label_Name"),"Label")
	Label_Name:setText(g_Hero:getMasterNameSuffix(Label_Name))
	g_SetCardNameColorByEvoluteLev(Label_Name, tb_HeadInfo.breachlv or 1)
	
	--同步资料
	local tbServerMsg = g_TBSocial.gamerMsg[g_MsgMgr:getUin()]
	if not tbServerMsg then
		g_ClientMsgTips:showWarning(_T("与服务端同步角色资料失败"))
	else
		local Button_Sex = tolua.cast(ListView_MyProfile:getChildByName("Button_Sex"),"Button")
		local Label_Sex = tolua.cast(Button_Sex:getChildByName("Label_Sex"),"Label")
		if tbServerMsg.is_man then
			Label_Sex:setText(_T("男"))
		else
			Label_Sex:setText(_T("女"))
		end
		--职业

		local Button_Profession = tolua.cast(ListView_MyProfile:getChildByName("Button_Profession"),"Button")	
		local Label_Profession = tolua.cast(Button_Profession:getChildByName("Label_Profession"),"Label")
		self:setProfession(Label_Profession, tbServerMsg.profession)
		--行业
		local Button_Industry = tolua.cast(ListView_MyProfile:getChildByName("Button_Industry"),"Button")	
		local Label_Industry = tolua.cast(Button_Industry:getChildByName("Label_Industry"),"Label")
		self:setIndustry(Label_Industry, tbServerMsg.industry)
		--地区
		local Button_Area = tolua.cast(ListView_MyProfile:getChildByName("Button_Area"),"Button")
		local Label_Area = tolua.cast(Button_Area:getChildByName("Label_Area"),"Label")
		self:setArea(Label_Area, tbServerMsg.area)
		--签名
		local Button_Signature = tolua.cast(ListView_MyProfile:getChildByName("Button_Signature"),"Button")	
		local Label_Signature = tolua.cast(Button_Signature:getChildByName("Label_Signature"),"Label")
		self:setSignature(Label_Signature, tbServerMsg.signature)
	end
end
--好友数量设置
function Game_Social1:setFriendCapacity()
	local Label_FriendCapacity =  tolua.cast(self.rootWidget:getChildByName("Label_FriendCapacity"),"Label")
	Label_FriendCapacity:setText(g_FriendNum .."/"..g_Hero:getFriendNumMax())
end

function Game_Social1:initTextField_Input()
	local Image_InputFindFriend =  tolua.cast(self.Image_ApplicationPNL:getChildByName("Image_InputFindFriend"),"ImageView")
	local TextField_Input =  tolua.cast(Image_InputFindFriend:getChildByName("TextField_Input"),"TextField")
	local Button_Find =  tolua.cast(Image_InputFindFriend:getChildByName("Button_Find"),"Button")

	self.TextField_Input = TextField_Input
	TextField_Input:setTouchEnabled(true)
	TextField_Input:setMaxLength((26))
    local Findtext = ""
	local function onClickButtonFind(pSender,eventType)
		if eventType ==ccs.TouchEventType.ended then
		    local nTag = pSender:getTag()
		    Findtext = TextField_Input:getStringValue()
			if Findtext and Findtext ~= "" then
				g_MsgMgr:relationCheckNameRequest(Findtext)
			end	       
		end
	end
	Button_Find:setTag(1)
	Button_Find:setTouchEnabled(true)
	Button_Find:addTouchEventListener(onClickButtonFind)
end

function Game_Social1:initWnd()
	self.ListView_Frient_Index = 1
	self.ListView_Application_Index = 1
	self.ListView_Neighbor_Index = 1
	self.nCurrentPageIndex = 1

	local Image_ContentPNL = tolua.cast(self.rootWidget:getChildByName("Image_ContentPNL"), "ImageView")

	self.Image_FriendPNL = tolua.cast(Image_ContentPNL:getChildByName("Image_FriendPNL"), "ImageView")
	self.Image_ApplicationPNL = tolua.cast(Image_ContentPNL:getChildByName("Image_ApplicationPNL"), "ImageView")
	self.Image_NeighborPNL = tolua.cast(Image_ContentPNL:getChildByName("Image_NeighborPNL"), "ImageView")
	self.Image_MyProfilePNL = tolua.cast(Image_ContentPNL:getChildByName("Image_MyProfilePNL"), "ImageView")
	
	local Image_FriendIcon = tolua.cast(self.rootWidget:getChildByName("Image_FriendIcon"), "ImageView")
	local Label_FriendCapacity = tolua.cast(self.rootWidget:getChildByName("Label_FriendCapacity"), "Label")
	g_SetBtnWithPressingEvent(Label_FriendCapacity, nil, g_OnShowTip, nil, g_OnCloseTip, true, 0.0)
	g_SetBtnWithPressingEvent(Image_FriendIcon, nil, g_OnShowTip, nil, g_OnCloseTip, true, 0.0)
	
	local Panel_TabBtnPNL = tolua.cast(self.rootWidget:getChildByName("Panel_TabBtnPNL"), "Layout")
	self.CheckBox_Friend = tolua.cast(Panel_TabBtnPNL:getChildByName("CheckBox_Friend"), "CheckBox")
    self.CheckBox_Application = tolua.cast(Panel_TabBtnPNL:getChildByName("CheckBox_Application"), "CheckBox")
	self.CheckBox_Neighbor = tolua.cast(Panel_TabBtnPNL:getChildByName("CheckBox_Neighbor"), "CheckBox")
	self.CheckBox_MyProfile = tolua.cast(Panel_TabBtnPNL:getChildByName("CheckBox_MyProfile"), "CheckBox")
	self.CheckBox_Friend:setTag(1)
	self.CheckBox_Application:setTag(2)
	self.CheckBox_Neighbor:setTag(3)
	self.CheckBox_MyProfile:setTag(4)
	self.Image_FriendPNL:setVisible(false)
	self.Image_ApplicationPNL:setVisible(false)
	self.Image_NeighborPNL:setVisible(false)
	self.Image_MyProfilePNL:setVisible(false)
	
	self.curImagePNL = self.Image_FriendPNL
	local function onClickCheckBox(nTag,pSender,eventType)
		self.curImagePNL:setVisible(false)
		if nTag == 1 then
			self.curImagePNL = self.Image_FriendPNL
			self:upDateFriendList()
			self:showNotes(false,2)
			self.nCurrentPageIndex = nTag
		elseif nTag == 2 then
			self.curImagePNL = self.Image_ApplicationPNL
			self:upDateApplicationPNL()
			self:showNotes(false,3)
			self.nCurrentPageIndex = nTag
		elseif nTag == 3 then
			self.curImagePNL = self.Image_NeighborPNL
			self.fLastClickTime = self.fLastClickTime or 0
			if (API_GetCurrentTime() - self.fLastClickTime) < 30 then
				cclog("=============Click Too Fast===========")
			else
				self.fLastClickTime = API_GetCurrentTime()
				g_MsgMgr:requestRelationGetNearByList()
			end
			self.nCurrentPageIndex = nTag
		elseif nTag == 4 then
			self.curImagePNL = self.Image_MyProfilePNL
			self:setImageMyProfilePNL()
			self.nCurrentPageIndex = nTag
		end	
		self.curImagePNL:setVisible(true)
	end
	self.ckEquip = CheckBoxGroup:New()
    self.ckEquip:PushBack(self.CheckBox_Friend, onClickCheckBox)
	self.ckEquip:PushBack(self.CheckBox_Application, onClickCheckBox)
    self.ckEquip:PushBack(self.CheckBox_Neighbor, onClickCheckBox)
	self.ckEquip:PushBack(self.CheckBox_MyProfile, onClickCheckBox)
	
	--界面初始化设置
	self:initMyProfilePNL()
	self:initTextField_Input()
	self:initImageNeighborPNL()
	self:initApplicationPNL()
	self:initFriendPNL()
	
	local function onQuick(pSender, nTag)
		if nTag == 1 then
			self:oneRecvFP()
		else
			self:oneSendFP()
		end
	end
	self.Button_QuickGet = g_SetBtn(self.rootWidget, "Button_QuickGet", onQuick, true,nil,1)
	self.Button_QuickGive = g_SetBtn(self.rootWidget, "Button_QuickGive", onQuick, true,nil,2)
    self.CheckBox_Handsel = tolua.cast(self.Image_FriendPNL:getChildByName("CheckBox_Handsel"), "CheckBox")
    self.CheckBox_Handsel:setSelectedState(false)
    if g_SocialMsg:getAutoHandselFriend() then
        self.CheckBox_Handsel:setSelectedState(true)
    end
    local function ckHandsel(pSender, eventType)
        if eventType == ccs.CheckBoxEventType.selected then
            g_SocialMsg:autoHandselFriendRequest(true)
            g_SocialMsg:setAutoHandselFriend(true)    
        else
            g_SocialMsg:autoHandselFriendRequest(false)
            g_SocialMsg:setAutoHandselFriend(false) 
        end
    end
    self.CheckBox_Handsel:addEventListenerCheckBox(ckHandsel)
end

function Game_Social1:closeWnd(nWndID)
	self.LuaListView_Friend:updateItems(0)
	self.LuaListView_Application:updateItems(0)
	self.LuaListView_Neighbor:updateItems(0)
end

function Game_Social1:showAllNotify()
	self:showNotes(true,2)
	self:showNotes(true,3)
end

function Game_Social1:openWnd()
	if g_bReturn then self.ckEquip:Click(self.nCurrentPageIndex) return end
	if self.NextReturn == false then
		self.NextReturn = true 
		return
	end
	self.ckEquip:Click(self.nCurrentPageIndex)
	self:showAllNotify()
	self:setFriendCapacity()
end
function Game_Social1:destroyWnd()
end