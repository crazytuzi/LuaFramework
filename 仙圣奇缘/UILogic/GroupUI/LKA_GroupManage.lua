--------------------------------------------------------------------------------------
-- 文件名:	Game_GroupManage.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:  陆奎安
-- 日  期:	2015-3-18 10:24
-- 版  本:	1.0
-- 描  述:	帮派管理
-- 应  用:  本例子使用一般方法的实现Scene

---------------------------------------------------------------------------------------
Game_GroupManage = class("Game_GroupManage")
Game_GroupManage.__index = Game_GroupManage

function Game_GroupManage:setGroupRequestNotice()
	g_SetBubbleNotify(self.Button_RequestList, g_GetNoticeNum_GroupRequest(), 80, 20)
	g_SetBubbleNotify(self.Button_Upgrade, g_GetNoticeNum_GroupUpgrade(), 80, 20)
end

function Game_GroupManage:initWnd()
	local Image_GroupManagePNL = tolua.cast(self.rootWidget:getChildByName("Image_GroupManagePNL"), "ImageView")
	
	local function onClickButton(pSender, nTag)
		if nTag == 1 then
			--帮派申请列表
			local guild_id = g_Guild:getGuildID()
			g_Guild:requestGuildReqListRequest(guild_id)
		elseif nTag == 2 then
			g_WndMgr:showWnd("Game_GroupChangeNotice")
		elseif nTag == 3 then
			g_WndMgr:showWnd("Game_GroupUpgrade")
		elseif nTag == 4 then
			g_WndMgr:showWnd("Game_GroupSetting")
		elseif nTag == 5 then
			g_WndMgr:showWnd("Game_GroupMail")
		elseif nTag == 6 then
			local tips = _T("帮派解散后将无可挽回，您确定要解散吗？")
			g_ClientMsgTips:showConfirm(tips, function()
				g_Guild:requestGuildDismissRequest()
			end)
		end
	end
	self.Button_RequestList = g_SetBtn(self.rootWidget, "Button_RequestList", onClickButton, true,true,1)
	g_SetBtn(self.rootWidget, "Button_ChangeNotice", onClickButton, true,true,2)
	self.Button_Upgrade = g_SetBtn(self.rootWidget, "Button_Upgrade", onClickButton, true,true,3)
	g_SetBtn(self.rootWidget, "Button_Setting", onClickButton, true,true,4)
	g_SetBtn(self.rootWidget, "Button_GroupMail", onClickButton, true,true,5)
	g_SetBtn(self.rootWidget, "Button_Dismiss", onClickButton, true,true,6)
end

function Game_GroupManage:openWnd()
	self:setGroupRequestNotice()
end

function Game_GroupManage:closeWnd()
	--关闭管理界面的时 刷新管理按钮
	if g_WndMgr:getWnd("Game_Group") then 
		g_WndMgr:getWnd("Game_Group").groupfunc_[TB_FUNC_TYPE_NAME.GroupPNL]:groupButtonManageMent()
	end
end

function Game_GroupManage:showWndOpenAnimation(funcWndOpenAniCall)
	local Image_GroupManagePNL = tolua.cast(self.rootWidget:getChildByName("Image_GroupManagePNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIAppearAnimation_Scale(Image_GroupManagePNL, funcWndOpenAniCall, 1.05, 0.2, Image_Background)
end

function Game_GroupManage:showWndCloseAnimation(funcWndCloseAniCall)
	local Image_GroupManagePNL = tolua.cast(self.rootWidget:getChildByName("Image_GroupManagePNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIDisappearAnimation_Scale(Image_GroupManagePNL, funcWndCloseAniCall, 1.05, 0.2, Image_Background)
end

