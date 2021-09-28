--------------------------------------------------------------------------------------
-- 文件名:	CResrouceFuncIos.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	李玉平
-- 日  期:	2014-12-15 11:24
-- 版  本:	1.0
-- 描  述:	
-- 应  用:    关于资源处理的
---------------------------------------------------------------------------------------

--每个路径下面的资源通用访问接口
function getImgByPathRoot(strPath, strName)
	if not strName or not strPath then
		return ""
	end
	
    if g_Cfg.Platform == kTargetWindows then
		return strPath.."/"..strName..".png"
	elseif g_Cfg.Platform == kTargetAndroid then
		return strPath.."/"..strName..".png"
	else
		return strPath.."/"..strName..".png"
	end 
end


--每个路径下面的资源通用访问接口
function getImgByPath(strPath, strName)
	if not strName or not strPath then
		return ""
	end
	
    if g_Cfg.Platform == kTargetWindows then
		return "UI/"..strPath.."/"..strName..".png"
	elseif g_Cfg.Platform == kTargetAndroid then
		return "UI/"..strPath.."/"..strName..".png"
	else
		return "UI/"..strPath.."/"..strName..".png"
	end 
end

--GameUI\Assitant 路径下面的资源
function getAssitantImg(strName)
	if not strName then
		return ""
	end
	
    if g_Cfg.Platform == kTargetWindows then
		return "UI/Assitant/"..strName..".png"
	elseif g_Cfg.Platform == kTargetAndroid then
		return "UI/Assitant/"..strName..".png"
	else
		return "UI/Assitant/"..strName..".png"
	end 
end

--GameUI\ActivityShiLian 路径下面的资源
function getActivityShiLianImg(strName)
	if not strName then
		return ""
	end
	
    if g_Cfg.Platform == kTargetWindows then
		return "UI/ActivityShiLian/"..strName..".png"
	elseif g_Cfg.Platform == kTargetAndroid then
		return "UI/ActivityShiLian/"..strName..".png"
	else
		return "UI/ActivityShiLian/"..strName..".png"
	end 
end

--GameUI\ActivityCenter 路径下面的资源
function getActivityCenterImg(strName)
	if not strName then
		return ""
	end
	
	if g_Cfg.Platform == kTargetWindows then
		 return "UI/ActivityCenter/"..strName..".png"
	elseif g_Cfg.Platform == kTargetAndroid then
		return "UI/ActivityCenter/"..strName..".png"
	else
		return "UI/ActivityCenter/"..strName..".png" 
	end
end

--GameUI\ActivityTask 路径下面的资源
function getActivityTaskImg(strName)
	if not strName then
		return ""
	end
	
	if g_Cfg.Platform == kTargetWindows then
		 return "UI/ActivityTask/"..strName..".png"
	elseif g_Cfg.Platform == kTargetAndroid then
		return "UI/ActivityTask/"..strName..".png"
	else
		return "UI/ActivityTask/"..strName..".png" 
	end
end


--GameUI\Arena 路径下面的资源
function getArenaImg(strName)
	if not strName then
		return ""
	end
	
    if g_Cfg.Platform == kTargetWindows then
		return "UI/Arena/"..strName..".png"
	elseif g_Cfg.Platform == kTargetAndroid then
		return "UI/Arena/"..strName..".png"
	else
		return "UI/Arena/"..strName..".png"
	end 
end

--GameUI\BackgroundJpg 路径下面的资源
function getBackgroundJpgImg(strName)
	if not strName then
		return ""
	end
	
	if g_Cfg.Platform == kTargetWindows then
		return "BackgroundJpg/"..strName..".jpg"	 
	elseif g_Cfg.Platform == kTargetAndroid then
	 	return "BackgroundJpg/"..strName..".jpg"
	else
		return "BackgroundJpg/"..strName..".jpg" 
	end

end

--GameUI\BackgroundPng 路径下面的资源
function getBackgroundPngImg(strName)
	if not strName then
		return ""
	end
	
	if g_Cfg.Platform == kTargetWindows then
		 return "BackgroundPng/"..strName..".png"
	elseif g_Cfg.Platform == kTargetAndroid then
	 	return "BackgroundPng/"..strName..".png"
	else
		 return "BackgroundPng/"..strName..".png"
	end
end

--GameUI\Battle	路径下面的资源
function getBattleImg(strName)
	if not strName then
		return ""
	end
	
	if g_Cfg.Platform == kTargetWindows then
		return "UI/Battle/"..strName..".png"
	elseif g_Cfg.Platform == kTargetAndroid then
		return "UI/Battle/"..strName..".png"
	else
		return "UI/Battle/"..strName..".png"
	end 
end

--GameUI\Buzhen	路径下面的资源
function getBuZhenImg(strName)
	if not strName then
		return ""
	end
	
	if g_Cfg.Platform == kTargetWindows then
		return "UI/Buzhen/"..strName..".png"
	elseif g_Cfg.Platform == kTargetAndroid then
		return "UI/Buzhen/"..strName..".png"
	else
		return "UI/Buzhen/"..strName..".png"
	end 
end

--GameUI\Card 路径下面的资源
function getCardImg(strName)
	if not strName then
		return ""
	end
	
	if g_Cfg.Platform == kTargetWindows then
		return "UI/Card/"..strName..".png"
	elseif g_Cfg.Platform == kTargetAndroid then
		return "UI/Card/"..strName..".png"
	else
		return "UI/Card/"..strName..".png"
	end 
end

--GameUI\Effect\Particle 路径下面的资源
function getEffectParticleImg(strName)
	if not strName then
		return ""
	end
	
	if g_Cfg.Platform == kTargetWindows then
		return "Effect_IOS/Particle/"..strName..".png"
	elseif g_Cfg.Platform == kTargetAndroid then
		return "Effect_IOS/Particle/"..strName..".png"
	else
		return "Effect_IOS/Particle/"..strName..".png"
	end 
end

--GameUI\Effect\Particle 路径下面的资源
function getEffectParticlePlist(strName)
	if not strName then
		return ""
	end
	
	if g_Cfg.Platform == kTargetWindows then
		return "Effect_IOS/Particle/"..strName..".plist"
	elseif g_Cfg.Platform == kTargetAndroid then
		return "Effect_IOS/Particle/"..strName..".plist"
	else
		return "Effect_IOS/Particle/"..strName..".plist"
	end 
end

--GameUI\Effect\Skill 路径下面的资源
function getEffectSkillJson(strName)
	if not strName then
		return ""
	end
	
	if g_Cfg.Platform == kTargetWindows then
		return "Effect_IOS/Skill/"..strName..".ExportJson"
	elseif g_Cfg.Platform == kTargetAndroid then
		return "Effect_IOS/Skill/"..strName..".ExportJson"
	else
		return "Effect_IOS/Skill/"..strName..".ExportJson"
	end 
end

--GameUI\Effect\Skill 路径下面的资源
function getEffectSkillPlist(strName)
	if not strName then
		return ""
	end
	
	if g_Cfg.Platform == kTargetWindows then
		return "Effect_IOS/Particle/"..strName..".plist"
	elseif g_Cfg.Platform == kTargetAndroid then
		return "Effect_IOS/Particle/"..strName..".plist"
	else
		return "Effect_IOS/Particle/"..strName..".plist"
	end 
end

--GameUI\Effect\Skill 路径下面的资源
function getEffectSkillSpine(strName)
	if not strName then
		return ""
	end
	
	if g_Cfg.Platform == kTargetWindows then
		return "Effect_IOS/SkillSpine/"..strName..".json"
	elseif g_Cfg.Platform == kTargetAndroid then
		return "Effect_IOS/SkillSpine/"..strName..".json"
	else
		return "Effect_IOS/SkillSpine/"..strName..".json"
	end 
end

--GameUI\Compose 路径下面的资源
function getComposeImg(strName)
	if not strName then
		return ""
	end
	
	if g_Cfg.Platform == kTargetWindows then
		return "UI/Compose/"..strName..".png"
	elseif g_Cfg.Platform == kTargetAndroid then
		return "UI/Compose/"..strName..".png"
	else
		return "UI/Compose/"..strName..".png"
	end 
end

--GameUI\Ectype 路径下面的资源
function getEctypeImg(strName)
	if not strName then
		return ""
	end
	
	if g_Cfg.Platform == kTargetWindows then
		return "UI/Ectype/"..strName..".png"
	elseif g_Cfg.Platform == kTargetAndroid then
		return "UI/Ectype/"..strName..".png"
	else
		return "UI/Ectype/"..strName..".png"
	end 
end

--GameUI\Farm 路径下面的资源
function getFarmImg(strName)
	if not strName then
		return ""
	end
	
	if g_Cfg.Platform == kTargetWindows then
		 return "UI/Farm/"..strName..".png"
	elseif g_Cfg.Platform == kTargetAndroid then
		return "UI/Farm/"..strName..".png"
	else
		 return "UI/Farm/"..strName..".png"
	end
end

--GameUI\HuntFate 路径下面的资源
function getHuntFateImg(strName)
	if not strName then
		return ""
	end
	
	if g_Cfg.Platform == kTargetWindows then
		return "UI/HuntFate/"..strName..".png"
	elseif g_Cfg.Platform == kTargetAndroid then
		return "UI/HuntFate/"..strName..".png"
	else
		return "UI/HuntFate/"..strName..".png"
	end 
end

--GameUI\Icon 路径下面的资源
function getIconImg(strName)
	if not strName then
		return ""
	end
	
	if g_Cfg.Platform == kTargetWindows then
		return "Icon/"..strName..".png" 
	elseif g_Cfg.Platform == kTargetAndroid then
	 	return "Icon/"..strName..".png"
	else
		return "Icon/"..strName..".png" 
	end
end

--GameUI\Map 路径下面的资源
function getMapImg(strName)
	if not strName then
		return ""
	end
	
	if g_Cfg.Platform == kTargetWindows then
		return "UI/Map/"..strName..".png"
	elseif g_Cfg.Platform == kTargetAndroid then
		return "UI/Map/"..strName..".png"
	else
		return "UI/Map/"..strName..".png"
	end 
end

--GameUI\QiShu 路径下面的资源
function getQiShuImg(strName)
	if not strName then
		return ""
	end
	
	if g_Cfg.Platform == kTargetWindows then
		 return "UI/QiShu/"..strName..".png"
	elseif g_Cfg.Platform == kTargetAndroid then
		return "UI/QiShu/"..strName..".png"
	else
		 return "UI/QiShu/"..strName..".png"
	end
end

--GameUI\Scene 路径下面的资源
function getSceneImg(strName)
	if not strName then
		return ""
	end
	
	if g_Cfg.Platform == kTargetWindows then
		 return "Scene/"..strName..".jpg"
	elseif g_Cfg.Platform == kTargetAndroid then
		return "Scene/"..strName..".jpg"
	else
		 return "Scene/"..strName..".jpg"
	end
end

--GameUI\Scene 路径下面的资源
function getSceneFrontPicImg(strName)
	if not strName then
		return ""
	end
	
	if g_Cfg.Platform == kTargetWindows then
		 return "Scene/"..strName..".png"
	elseif g_Cfg.Platform == kTargetAndroid then
		return "Scene/"..strName..".png"
	else
		 return "Scene/"..strName..".png"
	end
end

--GameUI\ShangXiang 路径下面的资源
function getShangXiangImg(strName)
	if not strName then
		return ""
	end
	
	if g_Cfg.Platform == kTargetWindows then
		return "UI/ShangXiang/"..strName..".png"
	elseif g_Cfg.Platform == kTargetAndroid then
		return "UI/ShangXiang/"..strName..".png"
	else
		return "UI/ShangXiang/"..strName..".png"
	end 
end

--GameUI\Shop 路径下面的资源
function getShopImg(strName)
	if not strName then
		return ""
	end
	
	if g_Cfg.Platform == kTargetWindows then
		return "UI/Shop/"..strName..".png"
	elseif g_Cfg.Platform == kTargetAndroid then
	 	return "UI/Shop/"..strName..".png"
	else
		return "UI/Shop/"..strName..".png"	 
	end
end

--GameUI\ShoppingMall 路径下面的资源
function getShopMallImg(strName)
	if not strName then
		return ""
	end
	
	if g_Cfg.Platform == kTargetWindows then
		return "UI/ShoppingMall/"..strName..".png"
	elseif g_Cfg.Platform == kTargetAndroid then
	 	return "UI/ShoppingMall/"..strName..".png"
	else
		return "UI/ShoppingMall/"..strName..".png"	 
	end
end

--GameUI\Social 路径下面的资源
function getSocialImg(strName)
	if not strName then
		return ""
	end
	
	if g_Cfg.Platform == kTargetWindows then
		return "UI/Social/"..strName..".png"
	elseif g_Cfg.Platform == kTargetAndroid then
	 	return "UI/Social/"..strName..".png"
	else
		return "UI/Social/"..strName..".png"	 
	end
end

--GameUI\SocialGroup 路径下面的资源
function getSocialGroupImg(strName)
	if not strName then
		return ""
	end
	
	if g_Cfg.Platform == kTargetWindows then
		return "UI/SocialGroup/"..strName..".png"
	elseif g_Cfg.Platform == kTargetAndroid then
	 	return "UI/SocialGroup/"..strName..".png"
	else
		return "UI/SocialGroup/"..strName..".png"	 
	end
end

--GameUI\SpineCharacter 路径下面的资源
function getSpineCharacterAtlas(strName)
	if not strName then
		return ""
	end
	
	if g_Cfg.Platform == kTargetWindows then
		return "SpineCharacter/"..strName..".atlas"
	elseif g_Cfg.Platform == kTargetAndroid then
	 	return "SpineCharacter/"..strName..".atlas"
	else
		return "SpineCharacter/"..strName..".atlas"	 
	end
end

--GameUI\SpineCharacter 路径下面的资源
function getSpineCharacterJson(strName)
	if not strName then
		return ""
	end
	
	if g_Cfg.Platform == kTargetWindows then
		return "SpineCharacter/"..strName..".json"
	elseif g_Cfg.Platform == kTargetAndroid then
	 	return "SpineCharacter/"..strName..".json"
	else
		return "SpineCharacter/"..strName..".json"	 
	end
end

--GameUI\StartGame 路径下面的资源
function getStartGameImg(strName)
	if not strName then
		return ""
	end
	
	if g_Cfg.Platform == kTargetWindows then
		 return "StartGame/"..strName..".png"
	elseif g_Cfg.Platform == kTargetAndroid then
		return "StartGame/"..strName..".png"
	else
		return "StartGame/"..strName..".png" 
	end
end

--GameUI\StartGame 路径下面的资源
function getStartGameImgJpg(strName)
	if not strName then
		return ""
	end
	
	if g_Cfg.Platform == kTargetWindows then
		 return "StartGame/"..strName..".jpg"
	elseif g_Cfg.Platform == kTargetAndroid then
		return "StartGame/"..strName..".jpg"
	else
		return "StartGame/"..strName..".jpg" 
	end
end

--GameUI\Summon 路径下面的资源
function getSummonImg(strName)
	if not strName then
		return ""
	end
	
	if g_Cfg.Platform == kTargetWindows then
		return "UI/Summon/"..strName..".png"
	elseif g_Cfg.Platform == kTargetAndroid then
		return "UI/Summon/"..strName..".png"
	else
		return "UI/Summon/"..strName..".png"
	end 
end

--GameUI\Turntable 路径下面的资源
function getTurntableImg(strName)
	if not strName then
		return ""
	end
	
	if g_Cfg.Platform == kTargetWindows then
		return "UI/Turntable/"..strName..".png"
	elseif g_Cfg.Platform == kTargetAndroid then
		return "UI/Turntable/"..strName..".png"
	else
		return "UI/Turntable/"..strName..".png"
	end 
end

--GameUI\UI\DragonPray 路径下面的资源
function getDragonPrayImg(strName)
	if not strName then
		return ""
	end
	
	if g_Cfg.Platform == kTargetWindows then
		 return "UI/DragonPray/"..strName..".png"
	elseif g_Cfg.Platform == kTargetAndroid then
		return "UI/DragonPray/"..strName..".png"
	else
		return "UI/DragonPray/"..strName..".png" 
	end
end

--GameUI\UI 路径下面的资源
function getUIImg(strName)
	if not strName then
		return ""
	end
	
	if g_Cfg.Platform == kTargetWindows then
		 return "UI/Common/"..strName..".png"
	elseif g_Cfg.Platform == kTargetAndroid then
		return "UI/Common/"..strName..".png"
	else
		return "UI/Common/"..strName..".png" 
	end
end

--GameUI\XianMai 路径下面的资源
function getXianMaiImg(strName)
	if not strName then
		return ""
	end
	
	if g_Cfg.Platform == kTargetWindows then
		return "UI/XianMai/"..strName..".png"
	elseif g_Cfg.Platform == kTargetAndroid then
		return "UI/XianMai/"..strName..".png"
	else
		return "UI/XianMai/"..strName..".png"
	end 
end

--获取道具、卡牌等通用颜色边框
function getIconFrame(nColorType)
	if not nColorType or nColorType <= 0 then nColorType =1 cclog("getIconFrame error") end
	
	if g_Cfg.Platform == kTargetWindows then
		return "UI/Common/Frame"..nColorType..".png"		 
	elseif g_Cfg.Platform == kTargetAndroid then
		return "UI/Common/Frame"..nColorType..".png"	 
	else
		return "UI/Common/Frame"..nColorType..".png"	 
	end
end

--获取道具、卡牌等通用颜色背景
function getFrameBackGround(nColorType)
	if not nColorType or nColorType <= 0  then
        nColorType =1
        cclog("getFrameBackGround error") 
    end
	
	if g_Cfg.Platform == kTargetWindows then
		return "UI/Common/FrameBack"..nColorType..".png" 
	elseif g_Cfg.Platform == kTargetAndroid then
	 	return "UI/Common/FrameBack"..nColorType..".png"
	else
		return "UI/Common/FrameBack"..nColorType..".png" 
	end
end

--根据伙伴突破等级获得边框
function getCardFrameByEvoluteLev(nEvoluteLevel)
	if not nEvoluteLevel or nEvoluteLevel <= 0 then 
        nEvoluteLevel =1
        cclog("getIconFrame error") 
    end

	local nColorType = g_GetCardColorTypeByEvoLev(nEvoluteLevel)
	
	if g_Cfg.Platform == kTargetWindows then
		return "UI/Common/Frame"..nColorType..".png"		 
	elseif g_Cfg.Platform == kTargetAndroid then
		return "UI/Common/Frame"..nColorType..".png"	 
	else
		return "UI/Common/Frame"..nColorType..".png"	 
	end
end

--根据伙伴突破等级获得遮罩
function getCardCoverByEvoluteLev(nEvoluteLevel)
	if not nEvoluteLevel or nEvoluteLevel <= 0 then 
        nEvoluteLevel =1
        cclog("getIconFrame error") 
    end

	local nColorType = g_GetCardColorTypeByEvoLev(nEvoluteLevel)
	
	if g_Cfg.Platform == kTargetWindows then
		return "UI/Common/SummonFragCoverB"..nColorType..".png"		 
	elseif g_Cfg.Platform == kTargetAndroid then
		return "UI/Common/SummonFragCoverB"..nColorType..".png"	 
	else
		return "UI/Common/SummonFragCoverB"..nColorType..".png"	 
	end
end

--根据伙伴突破等级获得布阵那里的边框
function getCardBuZhenFrameByEvoluteLev(nEvoluteLevel)
	if not nEvoluteLevel or nEvoluteLevel <= 0 then 
        nEvoluteLevel =1
        cclog("getIconFrame error") 
    end

	local nColorType = g_GetCardColorTypeByEvoLev(nEvoluteLevel)
	
	if g_Cfg.Platform == kTargetWindows then
		return "UI/Common/Image_IconBack9_Frame"..nColorType..".png"		 
	elseif g_Cfg.Platform == kTargetAndroid then
		return "UI/Common/Image_IconBack9_Frame"..nColorType..".png"	 
	else
		return "UI/Common/Image_IconBack9_Frame"..nColorType..".png"	 
	end
end

--根据伙伴突破等级获得颜色底图
function getCardBackByEvoluteLev(nEvoluteLevel)
	if not nEvoluteLevel or nEvoluteLevel <= 0  then 
        nEvoluteLevel =1 
        cclog("getFrameBackGround error") 
    end

	local nColorType = g_GetCardColorTypeByEvoLev(nEvoluteLevel)
	
	if g_Cfg.Platform == kTargetWindows then
		return "UI/Common/FrameBack"..nColorType..".png" 
	elseif g_Cfg.Platform == kTargetAndroid then
	 	return "UI/Common/FrameBack"..nColorType..".png"
	else
		return "UI/Common/FrameBack"..nColorType..".png" 
	end
end

--获取不同颜色的配方图标边框左下角的标志
function getFrameSymbolFormula(nColorType)
	if not nColorType or nColorType <= 0  then 
        nColorType =1 
        cclog("getFrameSymbol error") 
    end
	
	if g_Cfg.Platform == kTargetWindows then
		return "UI/Common/FrameSymbolFormula"..nColorType..".png" 
	elseif g_Cfg.Platform == kTargetAndroid then
	 	return "UI/Common/FrameSymbolFormula"..nColorType..".png"
	else
		return "UI/Common/FrameSymbolFormula"..nColorType..".png" 
	end
end

--获取不用颜色的碎片图标边框右上角的标志
function getFrameSymbolSkillFrag(nColorType)
	if not nColorType or nColorType <= 0  then nColorType =1 cclog("getFrameSymbol error") end
	
	if g_Cfg.Platform == kTargetWindows then
		return "UI/Common/FrameSymbolFrag"..nColorType..".png" 
	elseif g_Cfg.Platform == kTargetAndroid then
	 	return "UI/Common/FrameSymbolFrag"..nColorType..".png"
	else
		return "UI/Common/FrameSymbolFrag"..nColorType..".png" 
	end
end

--获取不同颜色的魂魄的玻璃罩
function getFrameCoverHunPo(nColorType)
	if not nColorType or nColorType <= 0  then nColorType = 1 cclog("getFrameHunPoCover error") end
	
	if g_Cfg.Platform == kTargetWindows then
		return "UI/Common/FrameCoverHunPo"..nColorType..".png" 
	elseif g_Cfg.Platform == kTargetAndroid then
	 	return "UI/Common/FrameCoverHunPo"..nColorType..".png"
	else
		return "UI/Common/FrameCoverHunPo"..nColorType..".png" 
	end
end

--获取不同颜色的元神的玻璃罩
function getFrameCoverSoul(nColorType)
	if not nColorType or nColorType <= 0  then nColorType =1 cclog("getFrameHunPoCover error") end
	
	if g_Cfg.Platform == kTargetWindows then
		return "UI/Common/FrameCoverSoul"..nColorType..".png" 
	elseif g_Cfg.Platform == kTargetAndroid then
	 	return "UI/Common/FrameCoverSoul"..nColorType..".png"
	else
		return "UI/Common/FrameCoverSoul"..nColorType..".png" 
	end
end

--获取不同等级的星级图片
function getIconStarLev(nColorType)
	if g_Cfg.Platform == kTargetWindows then
		 return "UI/Common/Icon_StarLevel"..nColorType..".png"
	elseif g_Cfg.Platform == kTargetAndroid then
		return "UI/Common/Icon_StarLevel"..nColorType..".png"
	else
		 return "UI/Common/Icon_StarLevel"..nColorType..".png"
	end
end

--获取不同颜色的异兽背景底图
function getFateBackImg(nStarLev)
	if g_Cfg.Platform == kTargetWindows then
		return "UI/Common/FateBack"..nStarLev..".png"
	elseif g_Cfg.Platform == kTargetAndroid then
		return "UI/Common/FateBack"..nStarLev..".png"
	else
		return "UI/Common/FateBack"..nStarLev..".png"
	end 
end

--获取不同颜色的异兽背景底图
function getFateBaseImg(nStarLev)
	if g_Cfg.Platform == kTargetWindows then
		return "UI/Common/FateBase"..nStarLev..".png"
	elseif g_Cfg.Platform == kTargetAndroid then
		return "UI/Common/FateBase"..nStarLev..".png"
	else
		return "UI/Common/FateBase"..nStarLev..".png"
	end 
end

--获取不同颜色的异兽背景底图
function getFateBaseAImg(nStarLev)
	if g_Cfg.Platform == kTargetWindows then
		return "UI/Common/FateBaseA"..nStarLev..".png"
	elseif g_Cfg.Platform == kTargetAndroid then
		return "UI/Common/FateBaseA"..nStarLev..".png"
	else
		return "UI/Common/FateBaseA"..nStarLev..".png"
	end 
end

--获取不同颜色的异兽玻璃罩
function getFateFrameImg(nStarLev)
	if g_Cfg.Platform == kTargetWindows then
		return "UI/Common/FateFrame"..nStarLev..".png"
	elseif g_Cfg.Platform == kTargetAndroid then
		return "UI/Common/FateFrame"..nStarLev..".png"
	else
		return "UI/Common/FateFrame"..nStarLev..".png"
	end 
end

--获取不同颜色的异兽玻璃罩
function getEquipLightImg(nColorType)
	if g_Cfg.Platform == kTargetWindows then
		return "UI/Common/FrameEquipLight"..nColorType..".png"
	elseif g_Cfg.Platform == kTargetAndroid then
		return "UI/Common/FrameEquipLight"..nColorType..".png"
	else
		return "UI/Common/FrameEquipLight"..nColorType..".png"
	end 
end

--获取不同颜色的血脉Icon
function getXianMai(nIndex)
	if g_Cfg.Platform == kTargetWindows then
		return "UI/XianMai/XueMai"..nIndex..".png"
	elseif g_Cfg.Platform == kTargetAndroid then
		return "UI/XianMai/XueMai"..nIndex..".png"
	else
		return "UI/XianMai/XueMai"..nIndex..".png"
	end 
end

--获取卡牌Icon
function getCardIconImg(CardID, nStarLevel)
	local CSV_Card = g_DataMgr:getCsvConfig_FirstAndSecondKeyData("CardBase", CardID, nStarLevel)
	return getIconImg(CSV_Card.SpineAnimation)
end

--获取副本星级图片
function getEctypeStarRecord(nStarRecourd)
	if g_Cfg.Platform == kTargetWindows then
		 return "UI/Ectype/Icon_Star"..nStarRecourd..".png"
	elseif g_Cfg.Platform == kTargetAndroid then
		return "UI/Ectype/Icon_Star"..nStarRecourd..".png"
	else
		 return "UI/Ectype/Icon_Star"..nStarRecourd..".png"
	end
end

function getEctypeIconResource(strName, nColorType)
    return getUIImg(strName..nColorType) 
end


--lua 报错 2015.10.20 lixu cocos2dx 在 spritecache中已优化。这个是多余的 还会引入bug
--封装创建CCSprite对象的方式，以方便资源读取
-- local instance = CCSprite
-- CCSprite = nil
-- CCSprite = class("CCSprite")
-- CCSprite.__index = CCSprite
-- function CCSprite:create(szPath)
--     local ccspriteCache = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(szPath)
--     if not ccspriteCache then
--         local sprite = instance:create(szPath)
--         return sprite
--     else
--     	cclog("CCSprite:create ---->"..tostring(ccspriteCache))
--         -- return instance:initWithSpriteFrameName(szPath)
--         local sprite = instance:createWithSpriteFrameName(szPath)
--         return sprite
--     end
-- end

-- function CCSprite:createWithTexture(tex)
--     return instance:createWithTexture(tex)
-- end

-- function CCSprite:createWithSpriteFrameName(szPath)
--     return self:create(szPath)
-- end

local tbSoundRelease = {}
function g_playSoundEffect(path)	--后面为了区分安卓和苹果的声音文件只传入文件名即可
	local _, nend = string.find(path, ".mp3")
	if nend == nil then
		return 
	end
	local IsMuteSoundEffet = CCUserDefault:sharedUserDefault():getBoolForKey("IsMuteSoundEffet", false)
	if g_Cfg.Platform == kTargetWindows then
		if IsMuteSoundEffet then
			cclog("IsMuteSoundEffet In Windows")
			return nil --静音模式不播放音效
		else
			tbSoundRelease[path] = true
			return SimpleAudioEngine:sharedEngine():playEffect(path)
		end
	else
		if IsMuteSoundEffet then
			return nil --静音模式不播放音效
		else
			tbSoundRelease[path] = true
			return SimpleAudioEngine:sharedEngine():playEffect(path)
		end
	end
end

function g_playSoundEffectBattle(path)
	local _, nend = string.find(path, ".mp3")
	if nend == nil then
		return 
	end
    local IsMuteBattleSound = CCUserDefault:sharedUserDefault():getBoolForKey("IsMuteBattleSound", false)
	if g_Cfg.Platform == kTargetWindows then
		if IsMuteBattleSound then
			return nil --战斗静音不播放音效
		else
			tbSoundRelease[path] = true
			return SimpleAudioEngine:sharedEngine():playEffect(path)
		end
	else
		if IsMuteBattleSound then
			return nil --战斗静音不播放音效
		else
			tbSoundRelease[path] = true
			return SimpleAudioEngine:sharedEngine():playEffect(path)
		end
	end
end

function g_unloadEffect()
	for key, value in pairs(tbSoundRelease) do
		SimpleAudioEngine:sharedEngine():unloadEffect(key)
	end
	
	tbSoundRelease = {}
end

function g_playSoundMusic(path, bLoop)
    local IsMuteSoundMusic = CCUserDefault:sharedUserDefault():getBoolForKey("IsMuteSoundMusic", false)
    if g_Cfg.Platform == kTargetWindows then
		if path then--表示重置音乐
            SimpleAudioEngine:sharedEngine():playBackgroundMusic(path, bLoop)
        end
        if IsMuteSoundMusic then
	   	   SimpleAudioEngine:sharedEngine():pauseBackgroundMusic()
        else
           SimpleAudioEngine:sharedEngine():resumeBackgroundMusic()
        end
    else
        if path then--表示重置音乐
            SimpleAudioEngine:sharedEngine():playBackgroundMusic(path, bLoop)
        end
        if IsMuteSoundMusic then
	   	   SimpleAudioEngine:sharedEngine():setBackgroundMusicVolume(0)
        else
           SimpleAudioEngine:sharedEngine():setBackgroundMusicVolume(1)
        end
    end
end

function g_playSoundMusicBattle(path, bLoop)
    local IsMuteBattleMusic = CCUserDefault:sharedUserDefault():getBoolForKey("IsMuteBattleMusic", false)
    if g_Cfg.Platform == kTargetWindows then
		if path then--表示重置音乐
            SimpleAudioEngine:sharedEngine():playBackgroundMusic(path, bLoop)
        end
        if IsMuteBattleMusic then
	   	   SimpleAudioEngine:sharedEngine():pauseBackgroundMusic()
        else
           SimpleAudioEngine:sharedEngine():resumeBackgroundMusic()
        end
    else
        if path then--表示重置音乐
            SimpleAudioEngine:sharedEngine():playBackgroundMusic(path, bLoop)
        end
        if IsMuteBattleMusic then
	   	   SimpleAudioEngine:sharedEngine():setBackgroundMusicVolume(0)
        else
           SimpleAudioEngine:sharedEngine():setBackgroundMusicVolume(1)
        end
    end
end

--GameUI\CocoAnimation 路径下面的资源
function getCocoAnimationImg(strName)
	if not strName then
		return ""
	end
	
	if g_Cfg.Platform == kTargetWindows then
		return "CocoAnimation/"..strName..".png"
	elseif g_Cfg.Platform == kTargetAndroid then
		return "CocoAnimation/"..strName..".png"
	else
		return "CocoAnimation/"..strName..".png"
	end 
end

--GameUI\CocoAnimation 路径下面的资源
function getCocoAnimationJson(strName)
	if not strName then
		return ""
	end
	
	if g_Cfg.Platform == kTargetWindows then
		return "CocoAnimation/"..strName..".ExportJson"
	elseif g_Cfg.Platform == kTargetAndroid then
		return "CocoAnimation/"..strName..".ExportJson"
	else
		return "CocoAnimation/"..strName..".ExportJson"
	end 
end

--GameUI\CocoAnimation 路径下面的资源
function getCocoAnimationPlist(strName)
	if not strName then
		return ""
	end
	
	if g_Cfg.Platform == kTargetWindows then
		return "CocoAnimation/"..strName..".plist"
	elseif g_Cfg.Platform == kTargetAndroid then
		return "CocoAnimation/"..strName..".plist"
	else
		return "CocoAnimation/"..strName..".plist"
	end 
end

function getBaXianGuoHai(strName)
	if not strName then
		return ""
	end
	
	if g_Cfg.Platform == kTargetWindows then
		return "UI/BaXianGuoHai/"..strName..".png"
	elseif g_Cfg.Platform == kTargetAndroid then
		return "UI/BaXianGuoHai/"..strName..".png"
	else
		return "UI/BaXianGuoHai/"..strName..".png"
	end 

end

