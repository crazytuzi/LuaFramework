Game_ViewProfile1 = class("Game_ViewProfile1")
Game_ViewProfile1.__index = Game_ViewProfile1

function Game_ViewProfile1:initWnd()
end

function Game_ViewProfile1:openWnd(info)
	if not info then return end
	
	local Image_ViewProfilePNL = tolua.cast(self.rootWidget:getChildByName("Image_ViewProfilePNL"), "ImageView")
	local Image_ContentPNL = tolua.cast(Image_ViewProfilePNL:getChildByName("Image_ContentPNL"), "ImageView")

	local Image_Head = tolua.cast(Image_ContentPNL:getChildByName("Image_Head"), "ImageView")
	local Image_Icon = tolua.cast(Image_Head:getChildByName("Image_Icon"), "ImageView")
	local strIcon = getIconByType(info.main_card_id, info.main_card_slv, macro_pb.ITEM_TYPE_CARD)
	Image_Icon:loadTexture(strIcon)
	
	local LabelBMFont_VipLevel = tolua.cast(Image_Head:getChildByName("LabelBMFont_VipLevel"), "LabelBMFont")
	LabelBMFont_VipLevel:setText(_T("VIP")..info.viplv)
	
	local Label_Name = tolua.cast(Image_ContentPNL:getChildByName("Label_Name"), "Label")
	Label_Name:setText(info.name)
	
	local LabelAtlas_Sex = tolua.cast(Image_ContentPNL:getChildByName("LabelAtlas_Sex"), "LabelAtlas")
	LabelAtlas_Sex:setStringValue(info.sex==1 and 2 or 1)
	LabelAtlas_Sex:setPositionX(Label_Name:getPositionX()+Label_Name:getContentSize().width+15)
	
	local Label_Level = tolua.cast(Image_ContentPNL:getChildByName("Label_Level"), "Label")
	Label_Level:setText(_T("等级").." "..info.lv)
	
	local BitmapLabel_TeamStrength = tolua.cast(Image_ContentPNL:getChildByName("BitmapLabel_TeamStrength"), "LabelBMFont")
	BitmapLabel_TeamStrength:setText(info.fighting)
	
	local Image_Industry = tolua.cast(Image_ContentPNL:getChildByName("Image_Industry"), "ImageView")
	local Label_Industry = tolua.cast(Image_Industry:getChildByName("Label_Industry"), "Label")
	Label_Industry:setText(g_profession[info.industry])
	
	local Image_Profession = tolua.cast(Image_ContentPNL:getChildByName("Image_Profession"), "ImageView")
	local Label_Profession = tolua.cast(Image_Profession:getChildByName("Label_Profession"), "Label")
	Label_Profession:setText(info.profession=="" and _T("无业游民") or info.profession)
	
	local Image_AreaInfo = tolua.cast(Image_ContentPNL:getChildByName("Image_AreaInfo"), "ImageView")
	local Label_Area = tolua.cast(Image_AreaInfo:getChildByName("Label_Area"), "Label")
	local mCity, mArea = g_GetSoCityText(info.area)
	Label_Area:setText(mCity.." - "..mArea)
	
	local Image_Signature = tolua.cast(Image_ContentPNL:getChildByName("Image_Signature"), "ImageView")
	local Label_Signature = tolua.cast(Image_Signature:getChildByName("Label_Signature"), "Label")
	Label_Signature:setText(info.signature=="" and _T("人的一生确实是需要一个伟大的签名...") or info.signature)
	
	local Panel_Background = tolua.cast(Image_ContentPNL:getChildByName("Panel_Background"), "Layout")
	local Image_SymbolBlueLight1 = tolua.cast(Panel_Background:getChildByName("Image_SymbolBlueLight1"), "ImageView")
	local ccSprite = tolua.cast(Image_SymbolBlueLight1:getVirtualRenderer(),"CCSprite")
	g_SetBlendFuncSprite(ccSprite,4)
	local Image_SymbolBlueLight2 = tolua.cast(Panel_Background:getChildByName("Image_SymbolBlueLight2"), "ImageView")
	local ccSprite = tolua.cast(Image_SymbolBlueLight2:getVirtualRenderer(),"CCSprite")
	g_SetBlendFuncSprite(ccSprite,4)
end

function Game_ViewProfile1:showWndOpenAnimation(funcWndOpenAniCall)
	local Image_ViewProfilePNL = tolua.cast(self.rootWidget:getChildByName("Image_ViewProfilePNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIAppearAnimation_Scale(Image_ViewProfilePNL, funcWndOpenAniCall, 1.05, 0.2)
end

function Game_ViewProfile1:showWndCloseAnimation(funcWndCloseAniCall)
	local Image_ViewProfilePNL = tolua.cast(self.rootWidget:getChildByName("Image_ViewProfilePNL"), "ImageView")
	local Image_Background = tolua.cast(self.rootWidget:getChildByName("Image_Background"), "ImageView")
	g_CreateUIDisappearAnimation_Scale(Image_ViewProfilePNL, funcWndCloseAniCall, 1.05, 0.2)
end

function Game_ViewProfile1:ModifyWnd_viet_VIET()
    local Label_TeamStrengthLB = self.rootWidget:getChildAllByName("Label_TeamStrengthLB")
	local BitmapLabel_TeamStrength = self.rootWidget:getChildAllByName("BitmapLabel_TeamStrength")
    g_AdjustWidgetsPosition({Label_TeamStrengthLB, BitmapLabel_TeamStrength}, 3)
end