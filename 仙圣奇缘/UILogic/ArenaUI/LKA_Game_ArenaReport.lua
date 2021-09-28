--------------------------------------------------------------------------------------
-- 文件名:	LKA_ArenaReport.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:  陆奎安
-- 日  期:	2013-12-10 10:24
-- 版  本:	1.0
-- 描  述:	竞技场界面
-- 应  用:  本例子使用一般方法的实现Scene

---------------------------------------------------------------------------------------
Game_ArenaReport = class("Game_ArenaReport")
Game_ArenaReport.__index = Game_ArenaReport

Game_ArenaReport.ArenaReportList = nil
Game_ArenaReport.myRank = 0

local CArenaReport = 
{
	win = {
		ReportPNL = getArenaImg("Frame_Arena_ReportL"),
		ReportReport = getArenaImg("Frame_Arena_ReportUp"),
		ReportResult = getUIImg("Frame_Arena_ReportWin"),
		posY = 20
	},
	lost = {
		ReportPNL = getArenaImg("Frame_Arena_ReportR"),
		ReportReport = getArenaImg("Frame_Arena_ReportDown"),
		ReportResult = getUIImg("Frame_Arena_ReportLose"),
		posY = -10
	}
}
--设置更换PNL图片
local function setPlayerPNLUI(widget,tb_date)
	local Image_ResultStatus = tolua.cast(widget:getChildByName("Image_ResultStatus"), "ImageView")
	local Image_RankChangeStatus = tolua.cast(widget:getChildByName("Image_RankChangeStatus"), "ImageView")
	Image_ResultStatus:loadTexture(tb_date.ReportResult)
	Image_RankChangeStatus:loadTexture(tb_date.ReportReport)
	widget:loadTexture(tb_date.ReportPNL)
	local pos = widget:getPosition()
	widget:setPosition(ccp(pos.x,tb_date.posY))
	is_win = is_win or true
	local tag = widget:getTag()
	if tag == 2 then
		widget:setFlipX(true)
		widget:setFlipY(true)
	end
end
--设置PNL内容
local function setPlayerPNLInfo(widget,tbMsg)
	if not tbMsg then
		cclog("===setPlayerPNLInfo (#2 tbMsg is nil) =======")
		return
	end
	local Label_Name = tolua.cast(widget:getChildByName("Label_Name"), "Label")
	local Label_Rank = tolua.cast(widget:getChildByName("Label_Rank"), "Label")
	local BitmapLabel_TeamStrength = tolua.cast(widget:getChildByName("BitmapLabel_TeamStrength"), "LabelBMFont")
	local Label_RankChange = tolua.cast(widget:getChildByName("Label_RankChange"), "Label")
	Label_Name:setText(tbMsg.role_name)
	Label_Rank:setText(tbMsg.rank_old)
	BitmapLabel_TeamStrength:setText(tbMsg.fightpoint)
	Label_RankChange:setText(tbMsg.RankChange..tbMsg.rank_new)
	
	local Label_RankLB = tolua.cast(widget:getChildByName("Label_RankLB"), "Label")
	local Label_TeamStrengthLB = tolua.cast(widget:getChildByName("Label_TeamStrengthLB"), "Label")
	local Image_RankChangeStatus = tolua.cast(widget:getChildByName("Image_RankChangeStatus"), "ImageView")
	
	local tag = widget:getTag()
	local function setWidgePosition(Widge,label,SizeWidth)
		local SizeWidth = SizeWidth or label:getSize().width
		local labelPos = label:getPosition()
		local WidgePos = Widge:getPosition()
		
		if tag == 1 then
			SizeWidth = 0 - SizeWidth
		end
		Widge:setPosition(ccp((labelPos.x + SizeWidth),WidgePos.y))
	end
	setWidgePosition(Label_RankLB,Label_Rank)
	local nNum = PrintDigits(tbMsg.fightpoint) 
	setWidgePosition(Label_TeamStrengthLB,BitmapLabel_TeamStrength,(47+21*(nNum-1))*0.65)
	setWidgePosition(Image_RankChangeStatus,Label_RankChange)
end
--设置PNL
function Game_ArenaReport:setPlayerPNL(widget,tbMsg,isWin)
	local myText = ""

	if tbMsg.rank_new == myRank then
		myText = _T("你")
	else
		myText = _T("他")
	end
	if isWin then
		tbMsg.RankChange = myText.._T("的排名升至")
		setPlayerPNLInfo(widget,tbMsg)
		setPlayerPNLUI(widget,CArenaReport.win)
	else
		tbMsg.RankChange = myText.._T("的排名降至")
		setPlayerPNLInfo(widget,tbMsg)
		setPlayerPNLUI(widget,CArenaReport.lost)
	end
end 
function Game_ArenaReport:setListViewItem(Panel_RankItem, nindex)
	local ArenaReport = ArenaReportList[#ArenaReportList - nindex + 1]
	local Button_RankItem = tolua.cast(Panel_RankItem:getChildByName("Button_RankItem"), "Button")
	
	local Image_PlayerLeftPNL = tolua.cast(Button_RankItem:getChildByName("Image_PlayerLeftPNL"), "ImageView")
	local Image_PlayerRightPNL = tolua.cast(Button_RankItem:getChildByName("Image_PlayerRightPNL"), "ImageView")
	Image_PlayerLeftPNL:setTag(1)
	Image_PlayerRightPNL:setTag(2)
	if ArenaReport.result == 1 then
		self:setPlayerPNL(Image_PlayerLeftPNL, ArenaReport.tb_ArenaReport1, true)
		self:setPlayerPNL(Image_PlayerRightPNL, ArenaReport.tb_ArenaReport2, false)
	elseif ArenaReport.result == 0 then
		self:setPlayerPNL(Image_PlayerLeftPNL,ArenaReport.tb_ArenaReport1,false)
		self:setPlayerPNL(Image_PlayerRightPNL,ArenaReport.tb_ArenaReport2,true)
	end
end

------------initListViewListEx---------
function Game_ArenaReport:registerListViewEvent(listViewPackage,model)
    local listView = Class_LuaListView:new()
    listView:setListView(listViewPackage)
    local function updateFunction(widget, nIndex)
        self:setListViewItem(widget, nIndex)
    end
    listView:setUpdateFunc(updateFunction)
    listView:setModel(model)
    self.listView = listView
end

function Game_ArenaReport:initWnd(layerArenaReward)
	local Image_ArenaReportPNL = tolua.cast(self.rootWidget:getChildByName("Image_ArenaReportPNL"), "ImageView")
	local Image_ContentPNL = tolua.cast(Image_ArenaReportPNL:getChildByName("Image_ContentPNL"), "ImageView")
	local ListView_ArenaReportList = tolua.cast(Image_ContentPNL:getChildByName("ListView_ArenaReportList"), "ListViewEx")
	local Panel_RankItem = tolua.cast(g_WidgetModel.Panel_RankItem, "Layout")
	if eLanguageVer.LANGUAGE_viet_VIET == g_LggV:getLanguageVer() then
		local Image_PlayerLeftPNL = Panel_RankItem:getChildAllByName("Image_PlayerLeftPNL")
		local Image_ResultStatus = Image_PlayerLeftPNL:getChildByName("Image_ResultStatus")
		Image_ResultStatus:setScale(0.8)

		local Image_PlayerRightPNL = Panel_RankItem:getChildAllByName("Image_PlayerRightPNL")
		local Image_ResultStatus = Image_PlayerRightPNL:getChildByName("Image_ResultStatus")
		Image_ResultStatus:setScale(0.8)
	end 
	self:registerListViewEvent(ListView_ArenaReportList, Panel_RankItem)
	
	local imgScrollSlider = ListView_ArenaReportList:getScrollSlider()
	if not g_tbScrollSliderXY.ListView_ArenaReportList_X then
		g_tbScrollSliderXY.ListView_ArenaReportList_X = imgScrollSlider:getPositionX()
	end
	imgScrollSlider = imgScrollSlider:setPositionX(g_tbScrollSliderXY.ListView_ArenaReportList_X - 2)
end

function Game_ArenaReport:openWnd()
	if g_bReturn  then  return  end
	myRank = g_Hero:getRank()
	local wndInstance = g_WndMgr:getWnd("Game_Arena")
	if wndInstance then
		ArenaReportList = wndInstance:getArenaReports()
		if ArenaReportList then
			self.listView:updateItems(#ArenaReportList)
			
			local Image_ArenaReportPNL = tolua.cast(self.rootWidget:getChildByName("Image_ArenaReportPNL"), "ImageView")
			local Image_ArenaReportIsNil = tolua.cast(Image_ArenaReportPNL:getChildByName("Image_ArenaReportIsNil"), "ImageView")
			if #ArenaReportList == 0 then
				Image_ArenaReportIsNil:setVisible(true)
			else
				Image_ArenaReportIsNil:setVisible(false)
			end
		end
	end
end

function Game_ArenaReport:closeWnd()
	self.listView:updateItems(0)
end

function Game_ArenaReport:showWndOpenAnimation(funcWndOpenAniCall)
	local Image_ArenaReportPNL = tolua.cast(self.rootWidget:getChildByName("Image_ArenaReportPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIAppearAnimation_Scale(Image_ArenaReportPNL, funcWndOpenAniCall, 1.05, 0.2, Image_Background)
end

function Game_ArenaReport:showWndCloseAnimation(funcWndCloseAniCall)
	local Image_ArenaReportPNL = tolua.cast(self.rootWidget:getChildByName("Image_ArenaReportPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIDisappearAnimation_Scale(Image_ArenaReportPNL, funcWndCloseAniCall, 1.05, 0.2, Image_Background)
end
