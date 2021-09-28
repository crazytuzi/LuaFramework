--------------------------------------------------------------------------------------
-- 文件名:	Game_GroupRequest.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:  陆奎安
-- 日  期:	2015-3-18 10:24
-- 版  本:	1.0
-- 描  述:	帮派申请列表
-- 应  用: 

---------------------------------------------------------------------------------------
Game_GroupRequest = class("Game_GroupRequest")
Game_GroupRequest.__index = Game_GroupRequest

function Game_GroupRequest:setListViewItem(Panel_Request, nIndex)
	local Button_Request = tolua.cast(Panel_Request:getChildByName("Button_Request"), "Button")
	local Label_MasterName = tolua.cast(Button_Request:getChildByName("Label_MasterName"), "Label")
	local Label_Desc = tolua.cast(Button_Request:getChildByName("Label_Desc"), "Label")
	local Label_MaterLevel = tolua.cast(Button_Request:getChildByName("Label_MaterLevel"), "Label")
	local Label_RequestTime = tolua.cast(Button_Request:getChildByName("Label_RequestTime"), "Label")
	local LabelAtlas_Sex = tolua.cast(Button_Request:getChildByName("LabelAtlas_Sex"), "LabelAtlas")
	--战力
	local Label_TeamStrengthenLB = tolua.cast(Button_Request:getChildByName("Label_TeamStrengthenLB"), "Label")
	Label_TeamStrengthenLB:setPositionX(40)
	local BitmapLabel_TeamStrengthen = tolua.cast(Button_Request:getChildByName("BitmapLabel_TeamStrengthen"), "LabelBMFont")

	local Image_Head = tolua.cast(Button_Request:getChildByName("Image_Head"), "ImageView")
	local tbMsg = g_Guild:getTbReqList()[nIndex]
	
	Label_MasterName:setText(tbMsg.name)
	LabelAtlas_Sex:setStringValue(tbMsg.gener)
	Label_MaterLevel:setText(_T("Lv.")..tbMsg.level)
	
	
	if g_LggV.LanguageVer == eLanguageVer.LANGUAGE_viet_VIET  then --越南版
		Label_Desc:setFontSize(20)
	end
	local desc = g_stringSize_insert(g_Guild:defaultSign(tbMsg.sign),"\n",20,400)
	Label_Desc:setText(desc)
	
	Label_RequestTime:setText(getStrTime(tbMsg.reqtime))
	
	BitmapLabel_TeamStrengthen:setText(tbMsg.fighting_point)
	
	-- g_adjustWidgetsRightPosition({BitmapLabel_TeamStrengthen, Label_TeamStrengthenLB})
	g_AdjustWidgetsPosition({Label_TeamStrengthenLB, BitmapLabel_TeamStrengthen},6)
	local tb_HeadInfo = {}
	local leaderID = tbMsg.cardcfgid
	local nStarLevel = tbMsg.starlv
	tb_HeadInfo.Image_Icon = getCardIconImg(leaderID,nStarLevel)
	tb_HeadInfo.vip = tbMsg.vip or 0
	tb_HeadInfo.uin = tbMsg.uin
	tb_HeadInfo.star = nStarLevel
	tb_HeadInfo.breachlv = tbMsg.breachlv
	g_SetPlayerHead(Image_Head, tb_HeadInfo, true)
	
	local function onClick(pSender,nTag)
		local tbmsg = {}
		tbmsg.uin = tbMsg.uin
		tbmsg.optype = nTag
		g_Guild:requestGuildApplyRespRequest(tbmsg)
	end 
	g_SetBtn(Panel_Request, "Button_Approve", onClick, true,true,1)
	g_SetBtn(Panel_Request, "Button_Refuse", onClick, true,true,2)
	
	local nameSize = Label_MasterName:getSize()
	local pos = Label_MasterName:getPosition()
	LabelAtlas_Sex:setPosition(ccp((pos.x + nameSize.width + 20),pos.y))
	Label_MaterLevel:setPosition(ccp((pos.x + nameSize.width + 120),pos.y))
	
	-- Label_MasterName
	-- LabelAtlas_Sex
	-- Label_MaterLevel
	-- Label_RequestTime
	

end

function Game_GroupRequest:initWnd()

	local Image_GroupRequestPNL = tolua.cast(self.rootWidget:getChildByName("Image_GroupRequestPNL"), "ImageView")
	local ListView_RequestList = tolua.cast(Image_GroupRequestPNL:getChildByName("ListView_RequestList"), "ListViewEx")
	local Panel_Request = tolua.cast(ListView_RequestList:getChildByName("Panel_Request"), "Layout")
	local function onUpdate_LuaListView_RequestList(Panel_Request, nIndex)
		self:setListViewItem(Panel_Request, nIndex)
	end
	self.LuaListView_RequestList = registerListViewEvent(ListView_RequestList, Panel_Request, onUpdate_LuaListView_RequestList)
	
	local imgScrollSlider = self.LuaListView_RequestList:getScrollSlider()
    g_tbScrollSliderXY = g_tbScrollSliderXY or {}
	if not g_tbScrollSliderXY.LuaListView_RequestList_X then
		g_tbScrollSliderXY.LuaListView_RequestList_X = imgScrollSlider:getPositionX()
	end
	imgScrollSlider = imgScrollSlider:setPositionX(g_tbScrollSliderXY.LuaListView_RequestList_X - 13)
end


function Game_GroupRequest:closeWnd()
	self.LuaListView_RequestList:updateItems(0)
end


function Game_GroupRequest:openWnd()
	if g_bReturn  then return  end
	self.LuaListView_RequestList:updateItems(g_Guild:getTbReqListCount())
end


function Game_GroupRequest:showWndOpenAnimation(funcWndOpenAniCall)
	local Image_GroupRequestPNL = tolua.cast(self.rootWidget:getChildByName("Image_GroupRequestPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIAppearAnimation_Scale(Image_GroupRequestPNL, funcWndOpenAniCall, 1.05, 0.2, Image_Background)
end

function Game_GroupRequest:showWndCloseAnimation(funcWndCloseAniCall)
	local Image_GroupRequestPNL = tolua.cast(self.rootWidget:getChildByName("Image_GroupRequestPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIDisappearAnimation_Scale(Image_GroupRequestPNL, funcWndCloseAniCall, 1.05, 0.2, Image_Background)
end