--------------------------------------------------------------------------------------
-- 文件名:	HJW_GameGroupView.lua
-- 版  权:	(C)深圳市美天互动有限公司
-- 创建人:	
-- 日  期:	2015-11-20
-- 版  本:	1.0
-- 描  述:	
-- 应  用:  帮派概要信息
---------------------------------------------------------------------------------------

Game_GroupView = class("Game_GroupView")
Game_GroupView.__index = Game_GroupView

function Game_GroupView:initWnd()

end

function Game_GroupView:openWnd(data)
	if not data then return end 

	local guildName = data.name
	local kingid = data.kingid
	local nLevel = data.level
	local kingName = data.king_name
	local kingBreachlv = data.king_breachlv
	local kingStar = data.king_star
	local kingCard = data.king_card
	local isReq = data.is_req

	local announcement = data.announcement

	if not announcement 
		or announcement == ""
		or  announcement == "notice" then 
		announcement = _T("帮主很懒，什么东西也没写")
	end
	
	
	if not self.rootWidget then return end
	
	local Image_GroupViewPNL = tolua.cast(self.rootWidget:getChildByName("Image_GroupViewPNL"), "ImageView")
	local Image_ContentPNL = tolua.cast(Image_GroupViewPNL:getChildByName("Image_ContentPNL"), "ImageView")
	--帮派名称
	local Label_GroupNameLB = tolua.cast(Image_ContentPNL:getChildByName("Label_GroupNameLB"), "Label")
	local Label_GroupName = tolua.cast(Label_GroupNameLB:getChildByName("Label_GroupName"), "Label")
	Label_GroupName:setText(guildName)
	-- g_AdjustWidgetsPosition({Label_GroupNameLB, Label_GroupName})
	Label_GroupName:setPositionX(Label_GroupNameLB:getSize().width)
	--帮主名称
	local Label_GroupMasterNameLB = tolua.cast(Image_ContentPNL:getChildByName("Label_GroupMasterNameLB"), "Label")
	local Label_GroupMasterName = tolua.cast(Label_GroupMasterNameLB:getChildByName("Label_GroupMasterName"), "Label")
		local param = {
		name = kingName, breachLevel = kingBreachlv, lableObj = Label_GroupMasterName,
	}
	g_Guild:setLableByColor(param)
	-- g_AdjustWidgetsPosition({Label_GroupMasterNameLB, Label_GroupMasterName})
	Label_GroupMasterName:setPositionX(Label_GroupMasterNameLB:getSize().width)	
		
	local Label_GroupLevelLB = tolua.cast(Image_ContentPNL:getChildByName("Label_GroupLevelLB"), "Label")
	local Label_GroupLevel = tolua.cast(Label_GroupLevelLB:getChildByName("Label_GroupLevel"), "Label")
	Label_GroupLevel:setText(nLevel)	
	-- g_AdjustWidgetsPosition({Label_GroupLevelLB, Label_GroupLevel})
	Label_GroupLevel:setPositionX(Label_GroupLevelLB:getSize().width)	
	--帮派成员数量
	local Label_GroupMemberLB = tolua.cast(Image_ContentPNL:getChildByName("Label_GroupMemberLB"), "Label")
	local Label_GroupMember = tolua.cast(Label_GroupMemberLB:getChildByName("Label_GroupMember"), "Label")
	local cur_mem_num = data.cur_mem_num
	local max_mem_num = data.max_mem_num
	Label_GroupMember:setText(cur_mem_num.."/"..max_mem_num)
	Label_GroupMember:setPositionX(Label_GroupMemberLB:getSize().width)
	
	local ScrollView_Notice = tolua.cast(Image_ContentPNL:getChildByName("ScrollView_Notice"), "ScrollView")
	local Label_Notice = tolua.cast(ScrollView_Notice:getChildByName("Label_Notice"), "Label")
	Label_Notice:setText(g_stringSize_insert(announcement,"\n",24,300))
	local nHeight = math.max(Label_Notice:getSize().height + 40, 130)
	ScrollView_Notice:setInnerContainerSize(CCSize(300, nHeight))
	Label_Notice:setPositionXY(5, nHeight)
	
	local Button_Close = tolua.cast(Image_GroupViewPNL:getChildByName("Button_Close"), "Button")
	local function onClose(pSender,eventType)
		if eventType == ccs.TouchEventType.ended then	
			g_WndMgr:closeWnd("Game_GroupView")
		end
	end
	Button_Close:setTouchEnabled(true)	
	Button_Close:addTouchEventListener(onClose)
	
	
end

function Game_GroupView:closeWnd()
end

function Game_GroupView:showWndOpenAnimation(funcWndOpenAniCall)
	local Image_GroupViewPNL = tolua.cast(self.rootWidget:getChildByName("Image_GroupViewPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	
	g_CreateUIAppearAnimation_Scale(Image_GroupViewPNL, funcWndOpenAniCall, 1.05, 0.2, Image_Background)
end

function Game_GroupView:showWndCloseAnimation(funcWndCloseAniCall)
	local Image_GroupViewPNL = tolua.cast(self.rootWidget:getChildByName("Image_GroupViewPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	local function actionEndCall()
		if funcWndCloseAniCall then
			funcWndCloseAniCall()
		end
	end
	g_CreateUIDisappearAnimation_Scale(Image_GroupViewPNL, actionEndCall, 1.05, 0.15, Image_Background)
end