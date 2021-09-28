
--------------------------------------------------------------------------------------
-- 文件名:	LKA_LKA_TipTuDiGong.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	陆奎安
-- 日  期:	2013-1-22 9:37
-- 版  本:	1.0
-- 描  述:	tip阵心界面
-- 应  用:  本例子是用类对象的方式实现
---------------------------------------------------------------------------------------
Game_TipZhenXin = class("Game_TipZhenXin")
Game_TipZhenXin.__index = Game_TipZhenXin
--服务器位置
local ZhenXinIconPos = {
	[1] = {x = -33, y = 33},
	[2] = {x = 0,y = 33},
	[3] = {x = 33,y = 33},
	[4] = {x = -33,y = 0},
	[5] = {x = 0,y = 0},
	[6] = {x = 33,y = 0},
	[7] = {x = -33,y = -33},
	[8] = {x = 0,y = -33},
	[9] = {x = 33,y = -33},
}
function Game_TipZhenXin:initWnd(widget)
	return true
end
function Game_TipZhenXin:setImage_TipZhenXinPNL(CSV_QiShuZhanShu)
	local Image_TipZhenXinPNL = tolua.cast(self.rootWidget:getChildByName("Image_TipZhenXinPNL"), "ImageView")
	local Label_Name = tolua.cast(Image_TipZhenXinPNL:getChildByName("Label_Name"),"Label")
	local Label_ZhenXinProp = tolua.cast(Image_TipZhenXinPNL:getChildByName("Label_ZhenXinProp"),"Label")
	local Label_ZhenXinPropGrow = tolua.cast(Image_TipZhenXinPNL:getChildByName("Label_ZhenXinPropGrow"),"Label")
	local Label_NeedLevelLB = tolua.cast(Image_TipZhenXinPNL:getChildByName("Label_NeedLevelLB"),"Label")
	local Label_NeedLevel = tolua.cast(Label_NeedLevelLB:getChildByName("Label_NeedLevel"),"Label")
	local Label_NeedXueShiLB = tolua.cast(Image_TipZhenXinPNL:getChildByName("Label_NeedXueShiLB"),"Label")
	local Label_NeedXueShi = tolua.cast(Label_NeedXueShiLB:getChildByName("Label_NeedXueShi"),"Label")
	local Label_ZhenXinDesc = tolua.cast(Image_TipZhenXinPNL:getChildByName("Label_ZhenXinDesc"),"Label")
	
	Label_Name:setText(CSV_QiShuZhanShu.ZhenXinName.." ".._T("Lv.")..self.nZhenXinLevel)
	local PropText =  g_PropName[CSV_QiShuZhanShu.ZhenXinPropID1]
	local proV = 15 + 10 * (self.nZhenXinLevel - 1)
	Label_ZhenXinProp:setText(PropText.." +"..proV)
	Label_ZhenXinPropGrow:setText(_T("每级增加")..PropText..""..proV)
	Label_NeedLevel:setText(CSV_QiShuZhanShu.OpenLevel)
	
	Label_NeedLevel:setPositionX(Label_NeedLevelLB:getSize().width)
	Label_NeedXueShi:setPositionX(Label_NeedXueShiLB:getSize().width)
	
	local CSV_QiShuUpgradeCost = g_DataMgr:getCsvConfigByOneKey("QiShuUpgradeCost",self.nZhenXinLevel)
	local NeedXueShi = CSV_QiShuUpgradeCost.ZhenXinCost * CSV_QiShuZhanShu.ZhenXinCostFactor --阵心升系消耗系数

	
	Label_NeedXueShi:setText(NeedXueShi)
	
	local Knowledge = g_Hero:getKnowledge()
	if  Knowledge >= NeedXueShi  then
		g_setTextColor(Label_NeedXueShi,ccs.COLOR.BRIGHT_GREEN)
	else
		g_setTextColor(Label_NeedXueShi,ccs.COLOR.RED )
	end
	local  ActorLev = g_Hero:getMasterCardLevel()
	if  ActorLev >= CSV_QiShuZhanShu.OpenLevel  then
		g_setTextColor(Label_NeedXueShi,ccs.COLOR.BRIGHT_GREEN)
	else
		g_setTextColor(Label_NeedXueShi,ccs.COLOR.RED)
	end
	local str_Des = g_stringSize_insert(CSV_QiShuZhanShu.ZhenXinDesc,"\n",20,505) 
	Label_ZhenXinDesc:setText(str_Des)
	
	local Image_ZhenFaIcon = tolua.cast(Image_TipZhenXinPNL:getChildByName("Image_ZhenFaIcon"), "ImageView")
	local icon = getIconImg(self.ZhenFaIcon)
	Image_ZhenFaIcon:loadTexture(icon)
		
	local Image_ZhenXinIcon = tolua.cast(Image_ZhenFaIcon:getChildByName("Image_ZhenXinIcon"), "ImageView")
	local CSV_ZhenFa =  g_DataMgr:getQiShuZhenfaCsv(self.tbParam.nZhanShuCsvID, self.tbParam.nIndex)
	Image_ZhenXinIcon:setPositionXY(ZhenXinIconPos[CSV_ZhenFa.BuZhenPosIndex].x, ZhenXinIconPos[CSV_ZhenFa.BuZhenPosIndex].y)
end

function Game_TipZhenXin:closeWnd()
	
end

function Game_TipZhenXin:openWnd(tbParam)
	if g_bReturn then return end
	if not tbParam then return end
	
	local CSV_QiShuZhanShu = g_DataMgr:getCsvConfig_FirstAndSecondKeyData("QiShuZhanShu", tbParam.nZhanShuCsvID, tbParam.nIndex)
	self.tbParam = tbParam
	self.nZhenXinLevel = tbParam.nZhenXinLevel
	self.ZhenFaIcon = tbParam.ZhenFaIcon 
	self:setImage_TipZhenXinPNL(CSV_QiShuZhanShu)
end

function Game_TipZhenXin:showWndOpenAnimation(funcWndOpenAniCall)
	local Image_TipZhenXinPNL = tolua.cast(self.rootWidget:getChildByName("Image_TipZhenXinPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIAppearAnimation_Scale(Image_TipZhenXinPNL, funcWndOpenAniCall, 1.05, 0.2)
end

function Game_TipZhenXin:showWndCloseAnimation(funcWndCloseAniCall)
	local Image_TipZhenXinPNL = tolua.cast(self.rootWidget:getChildByName("Image_TipZhenXinPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIDisappearAnimation_Scale(Image_TipZhenXinPNL, funcWndCloseAniCall, 1.05, 0.2)
end