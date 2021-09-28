--------------------------------------------------------------------------------------
-- 文件名:	Game_TipYuanSu.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	huangjingwei
-- 日  期:	2015-1-8 11:53
-- 版  本:	1.0
-- 描  述:	
-- 应  用:   
---------------------------------------------------------------------------------------
Game_TipYuanSu = class("Game_TipYuanSu")
Game_TipYuanSu.__index = Game_TipYuanSu

function Game_TipYuanSu:initWnd()
end 


function Game_TipYuanSu:openWnd(nIndex)
	if not nIndex then return end
	self:initView(nIndex)
end

function Game_TipYuanSu:initView(nIndex)

	local tbText = {
		_T("消耗金灵核，可提升主角金属性灵根的强度。"),
		_T("消耗木灵核，可提升主角木属性灵根的强度。"),
		_T("消耗水灵核，可提升主角水属性灵根的强度。"),
		_T("消耗火灵核，可提升主角火属性灵根的强度。"),
		_T("消耗土灵核，可提升主角土属性灵根的强度。"),
		_T("消耗风灵核，可提升主角风属性灵根的强度。"),
		_T("消耗雷灵核，可提升主角雷属性灵根的强度。"),
	}
	local element = { _T("金灵核"), _T("木灵核"), _T("水灵核"), _T("火灵核"), _T("土灵核"), _T("风灵核"), _T("雷灵核")}

	local Image_TipYuanSuPNL = tolua.cast(self.rootWidget:getChildByName("Image_TipYuanSuPNL"), "ImageView")
	--元素名称
	local Label_Name = tolua.cast(Image_TipYuanSuPNL:getChildByName("Label_Name"),"Label")
	Label_Name:setText(element[nIndex])
	--元素描述
	local Label_MiaoShu = tolua.cast(Image_TipYuanSuPNL:getChildByName("Label_MiaoShu"),"Label")
	Label_MiaoShu:setText(tbText[nIndex])
	local Image_Icon = tolua.cast(Image_TipYuanSuPNL:getChildByName("Image_Icon"),"ImageView")
	Image_Icon:loadTexture(getXianMaiImg("XueMai"..nIndex))
end

function Game_TipYuanSu:showWndOpenAnimation(funcWndOpenAniCall)
	local Image_TipYuanSuPNL = tolua.cast(self.rootWidget:getChildByName("Image_TipYuanSuPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIAppearAnimation_Scale(Image_TipYuanSuPNL, funcWndOpenAniCall, 1.05, 0.2)
end

function Game_TipYuanSu:showWndCloseAnimation(funcWndCloseAniCall)
	local Image_TipYuanSuPNL = tolua.cast(self.rootWidget:getChildByName("Image_TipYuanSuPNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIDisappearAnimation_Scale(Image_TipYuanSuPNL, funcWndCloseAniCall, 1.05, 0.2)
end
