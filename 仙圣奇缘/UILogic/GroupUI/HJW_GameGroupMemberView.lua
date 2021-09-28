--------------------------------------------------------------------------------------
-- 文件名:	HJW_GameGroupMemberView.lua
-- 版  权:	(C)深圳市美天互动有限公司
-- 创建人:	
-- 日  期:	2015-04-01
-- 版  本:	1.0
-- 描  述:	
-- 应  用:  帮主管理界面
---------------------------------------------------------------------------------------

Game_GroupMemberView = class("Game_GroupMemberView")
Game_GroupMemberView.__index = Game_GroupMemberView

function Game_GroupMemberView:initWnd()

	--帮派退位响应	
	local order = msgid_pb.MSGID_GUILD_GIVEUP_MASTER_RESPONSE
	g_MsgMgr:registerCallBackFunc(order,handler(self,self.requestGuildGiveUpMasterResponse))	
end

function Game_GroupMemberView:openWnd(emList)
	if g_bReturn  then return  end 
	if not emList then return end
	self.emList_ = emList
	--帮众信息
	self:groupInfoViwe()
	--切磋一下
	self:groupMenberButtonQieCuo()
	--添加好友
	self:groupMenberButtonDaZhaoHu()
	--退位让贤
	self:groupMenberButtonPromote()
	--移出帮派
	self:groupMenberButtonRemove()
end

function Game_GroupMemberView:closeWnd()

	
end


--[[
	帮众信息
]]
function Game_GroupMemberView:groupInfoViwe()
	local Image_GroupMemberViewPNL = tolua.cast(self.rootWidget:getChildByName("Image_GroupMemberViewPNL"),"ImageView")
	local Image_ContentPNL = tolua.cast(Image_GroupMemberViewPNL:getChildByName("Image_ContentPNL"),"ImageView")

	local cardcfgid = self.emList_.cardcfgid --伙伴ID
	local sign = self.emList_.sign 
	local viplv = self.emList_.viplv or 0		--
	-- local contribution = self.emList_[nIndex].contribution
	local fight = self.emList_.fight --
	local breachlv = self.emList_.breachlv --突破等级
	local starlv = self.emList_.starlv --玩家星级
	-- local logintime = self.emList_[nIndex].logintime --玩家登陆时间
	local nLevel = self.emList_.level --玩家等级
	-- local ident = self.emList_[nIndex].ident --玩家身份
	local gener = self.emList_.gener --玩家性别
	local uin = self.emList_.uin --玩家Id
	local name = self.emList_.name--玩家名称
	--帮众头像
	local Image_Head = tolua.cast(Image_ContentPNL:getChildByName("Image_Head"),"ImageView")
	
	local Image_Icon = getCardIconImg(cardcfgid,starlv)
	g_SetPlayerHead(Image_Head,{vip = viplv,uin = uin,star = starlv,breachlv = breachlv,Image_Icon = Image_Icon},true)
	--帮众名称
	local Label_Name = tolua.cast(Image_ContentPNL:getChildByName("Label_Name"),"Label")
	-- Label_Name:setText(name.."+"..breachlv)
	local param = {
		name = name,breachLevel = breachlv,lableObj = Label_Name
	}
	g_Guild:setLableByColor(param)
	--帮众性别
	local LabelAtlas_Sex = tolua.cast(Image_ContentPNL:getChildByName("LabelAtlas_Sex"),"LabelAtlas")
	LabelAtlas_Sex:setStringValue(gener)
	
	g_AdjustWidgetsPosition({Label_Name,LabelAtlas_Sex},10)
	--帮众等级
	local Label_Level = tolua.cast(Image_ContentPNL:getChildByName("Label_Level"),"Label")	
	
	Label_Level:setText(_T("等级").." "..nLevel)
	
	local Label_TeamStrengthLB = tolua.cast(Image_ContentPNL:getChildByName("Label_TeamStrengthLB"),"Label")	
	
	--战力数值
	local BitmapLabel_TeamStrength = tolua.cast(Image_ContentPNL:getChildByName("BitmapLabel_TeamStrength"),"LabelBMFont")
	BitmapLabel_TeamStrength:setText(fight)
	-- BitmapLabel_TeamStrength:setPositionX(Image_ContentPNL:getSize().width)
	g_AdjustWidgetsPosition({Label_TeamStrengthLB, BitmapLabel_TeamStrength},4)
	--个性签名
	local Image_Signature = tolua.cast(Image_ContentPNL:getChildByName("Image_Signature"),"ImageView")
	
	local Label_Signature = tolua.cast(Image_Signature:getChildByName("Label_Signature"),"Label")	
	Label_Signature:setText(g_Guild:defaultSign(sign)=="" and _T("人的一生确实是需要一个伟大的签名...") or g_Guild:defaultSign(sign))
end

--[[
	切磋一下
]]
function Game_GroupMemberView:groupMenberButtonQieCuo()
	local Image_GroupMemberViewPNL = tolua.cast(self.rootWidget:getChildByName("Image_GroupMemberViewPNL"),"ImageView")
	local Button_QieCuo = tolua.cast(Image_GroupMemberViewPNL:getChildByName("Button_QieCuo"),"Button")
	local function onQieCuo(pSender, nTag)
		g_MsgMgr:requestViewPlayerPk(self.emList_.uin)
	end	
	g_SetBtnWithOpenCheck(Button_QieCuo, 1, onQieCuo, true)

	if g_Guild:getUserGildHost(g_MsgMgr:getUin()) and g_MsgMgr:getUin() ~= self.emList_.uin  then
		Button_QieCuo:setPositionY(-98)
	else
		Button_QieCuo:setPositionY(-138)
	end	
end
--[[
	添加好友
]]
function Game_GroupMemberView:groupMenberButtonDaZhaoHu()
	local Image_GroupMemberViewPNL = tolua.cast(self.rootWidget:getChildByName("Image_GroupMemberViewPNL"),"ImageView")
	local Button_DaZhaoHu = tolua.cast(Image_GroupMemberViewPNL:getChildByName("Button_DaZhaoHu"),"Button")
	local function onDaZhaoHu(pSender,eventType)
		if eventType == ccs.TouchEventType.ended then	
			local FindMsg = {}
			FindMsg.uin =  self.emList_.uin 
			-- FindMsg.msg = "你好"
			g_MsgMgr:requestRelationAddFriend(FindMsg)
		end
	end
	Button_DaZhaoHu:setTouchEnabled(true)	
	Button_DaZhaoHu:addTouchEventListener(onDaZhaoHu)
	Button_DaZhaoHu:setBright(true)

	if g_Guild:getUserGildHost(g_MsgMgr:getUin()) and g_MsgMgr:getUin() ~= self.emList_.uin  then 
		Button_DaZhaoHu:setPositionY(-98)
	else
		Button_DaZhaoHu:setPositionY(-138)
	end	
	
end
--[[
	退位让贤
]]
function Game_GroupMemberView:groupMenberButtonPromote()
	local Image_GroupMemberViewPNL = tolua.cast(self.rootWidget:getChildByName("Image_GroupMemberViewPNL"),"ImageView")
	local Button_Promote = tolua.cast(Image_GroupMemberViewPNL:getChildByName("Button_Promote"),"Button")
	local function onPromote(pSender,eventType)
		if eventType == ccs.TouchEventType.ended then	
			local name = self.emList_.name--玩家名称
			local tips = string.format(_T("是否确定要将帮主的位置转让给【%s】？"), name)
			g_ClientMsgTips:showConfirm(tips, function()
				local uin = self.emList_.uin --玩家Id
				self:requestGuildGiveUpMasterRequest(uin)
				g_WndMgr:closeWnd("Game_GroupMemberView")
			end)
		end
	end
	if g_Guild:getUserGildHost(g_MsgMgr:getUin()) and g_MsgMgr:getUin() ~= self.emList_.uin  then 
		Button_Promote:setTouchEnabled(true)	
		Button_Promote:addTouchEventListener(onPromote)
		Button_Promote:setBright(true)
		Button_Promote:setVisible(true)
	else
		Button_Promote:setTouchEnabled(false)	
		Button_Promote:setBright(false)
		Button_Promote:setVisible(false)
	end

end
--[[
	移出帮派
]]
function Game_GroupMemberView:groupMenberButtonRemove()

	local Image_GroupMemberViewPNL = tolua.cast(self.rootWidget:getChildByName("Image_GroupMemberViewPNL"),"ImageView")
	local Button_Remove = tolua.cast(Image_GroupMemberViewPNL:getChildByName("Button_Remove"),"Button")
	local function onRemove(pSender,eventType)
		if eventType == ccs.TouchEventType.ended then	
			local name = self.emList_.name--玩家名称
			local tips = string.format(_T("是否确认将【%s】移出帮派？"), name)
			g_ClientMsgTips:showConfirm(tips, function()
				local uin = self.emList_.uin --玩家Id
				g_Guild:requestGuildKickOutRequest(uin)
				
			end)
		end
	end
	
	if g_Guild:getUserGildHost(g_MsgMgr:getUin()) and g_MsgMgr:getUin() ~= self.emList_.uin then 
		Button_Remove:setTouchEnabled(true)	
		Button_Remove:addTouchEventListener(onRemove)
		Button_Remove:setBright(true)
		Button_Remove:setVisible(true)
	else
		Button_Remove:setTouchEnabled(false)	
		Button_Remove:setBright(false)
		Button_Remove:setVisible(false)
		
	end

	local BitmapLabel_FuncName = tolua.cast(Button_Remove:getChildByName("BitmapLabel_FuncName"),"LabelBMFont")
	if g_LggV.LanguageVer == eLanguageVer.LANGUAGE_viet_VIET  then --越南版
		BitmapLabel_FuncName:setScale(0.8)
	end
end

--帮派退位请求
function Game_GroupMemberView:requestGuildGiveUpMasterRequest(nToUin)
	cclog("---------requestGuildGiveUpMasterRequest-------------")
	cclog("---------帮派退位请求-------------")
	local msg = zone_pb.GuildGiveUpMasterRequest() 
	msg.to_uin = nToUin --
	g_MsgMgr:sendMsg(msgid_pb.MSGID_GUILD_GIVEUP_MASTER_REQUEST, msg)
end

--帮派退位响应
function Game_GroupMemberView:requestGuildGiveUpMasterResponse(tbMsg)
	cclog("---------requestGuildGiveUpMasterResponse-------------")
	cclog("---------帮派退位响应-------------")
	local msgDetail = zone_pb.GuildGiveUpMasterResponse()
	msgDetail:ParseFromString(tbMsg.buffer)
	cclog(tostring(msgDetail))
	local toUin = msgDetail.to_uin -- 
	-- if g_MsgMgr:getUin() == toUin then
	-- end
	local masterInfo = msgDetail.master_info --帮主的信息
	g_Guild:setGiveMemList(masterInfo,toUin)
	
	if g_WndMgr:getWnd("Game_Group") then
		g_Guild:setUserIdent(0) --身份
		g_WndMgr:getWnd("Game_Group"):setVisiblePnl()
		g_WndMgr:getWnd("Game_Group"):adjustOverFunc(g_WndMgr:getWnd("Game_Group").LuaListView:getChildByIndex(0),1)
	end

end

function Game_GroupMemberView:showWndOpenAnimation(funcWndOpenAniCall)
	local Image_GroupMemberViewPNL = tolua.cast(self.rootWidget:getChildByName("Image_GroupMemberViewPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIAppearAnimation_Scale(Image_GroupMemberViewPNL, funcWndOpenAniCall, 1.05, 0.2, Image_Background)
end

function Game_GroupMemberView:showWndCloseAnimation(funcWndCloseAniCall)
	local Image_GroupMemberViewPNL = tolua.cast(self.rootWidget:getChildByName("Image_GroupMemberViewPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIDisappearAnimation_Scale(Image_GroupMemberViewPNL, funcWndCloseAniCall, 1.05, 0.2, Image_Background)
end


