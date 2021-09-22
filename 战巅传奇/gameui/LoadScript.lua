function reload( moduleName ,rt)
    package.loaded[moduleName] = nil
    if rt then
	 	return require(moduleName)
    end
    require(moduleName)
end


GameLogin = reload("base.GameLogin", true)
GUICenterBottom = reload("gameui.GUICenterBottom", true)

GameMessageID = reload("base.GameMessageID", true)
GameSocket = reload("base.GameSocket", true)
GameMessageCode = reload("base.GameMessageCode", true)
GUIFocusPoint=reload("gameui.GUIFocusPoint", true)
GameMusic=reload("base.GameMusic", true)

GUIMain=reload("gameui.GUIMain", true)
GUILeftTop=reload("gameui.GUILeftTop", true)
GUILeftBottom=reload("gameui.GUILeftBottom", true)
GUILeftCenter=reload("gameui.GUILeftCenter", true)
GUIRightBottom=reload("gameui.GUIRightBottom", true)
GUIRightCenter=reload("gameui.GUIRightCenter", true)
GUIRightTop=reload("gameui.GUIRightTop", true)
GUITopCenter=reload("gameui.GUITopCenter", true)
GUILeftHuoDongAnNiu=reload("gameui.GUILeftHuoDongAnNiu", true)
GUIMessageAnimation=reload("gameui.GUIMessageAnimation", true)
GUIInfo = reload("gameui.GUIInfo", true)
GUIAttackType = reload("gameui.GUIAttackType", true)
GUISkill = reload("gameui.GUISkill", true)
GUIFastMenu = reload("gameui.GUIFastMenu", true)
GUIFunctionList = reload("gameui.GUIFunctionList", true)
GUIMapMin = reload("gameui.GUIMapMin", true)
GUITaskView = reload("gameui.GUITaskView", true)
GUIItemUsage = reload("gameui.GUIItemUsage", true)
GUIExtendEquipAttr = reload("gameui.GUIExtendEquipAttr", true)
GUIFocusDot = reload("gameui.GUIFocusDot", true)
GUIFunctionBeta = reload("gameui.GUIFunctionBeta", true)

GUIRecyle = reload("gameui.GUIRecyle", true)
GUIPageView = reload("gameui.GUIPageView", true)
GUIFunctionExtra = reload("gameui.GUIFunctionExtra", true)
GUIMinTipsManager = reload("gameui.GUIMinTipsManager", true)

GUIPixesObject = reload("gameui.GUIPixesObject", true)
GUIItem=reload("gameui.GUIItem", true)
GUIList=reload("gameui.GUIList", true)

GUIMinTips = reload("gameui.GUIMinTips", true)
GUIRichLabel = reload("gameui.GUIRichLabel", true)
GUIConfirm = reload("gameui.GUIConfirm", true)
GUILoaderBar = reload("gameui.GUILoaderBar", true)
GUIRollWar=reload("gameui.GUIRollWar", true)
GameCharacter=reload("base.GameCharacter", true)
GameSkill = reload("base.GameSkill", true)
GDivSkill=reload("gameui.GDivSkill", true)
GameHttp = reload("base.GameHttp", true)



reload("gameui.GUIProgressBar")
reload("gameui.GUINumToast")
reload("gameui.GUITable")
reload("gameui.GUITabView")
reload("gameui.GUIFloatTipsManager")
reload("gameui.GDivToast")
reload("gameui.GDivControl")
reload("gameui.GDivRecord")

reload("gameui.GUIFloatTips")


--相关场景
reload("gameui.GPageResourceLoad")
reload("gameui.GPageReEnter")
-- require("gameui.GPageAcrossServer")
reload("gameui.GPageCharacterCreate")
reload("gameui.GPageCharacterSelect")
reload("gameui.GPageSignIn")
reload("gameui.GPageAnnounce")
reload("gameui.GPageServerList")
reload("gameui.GDivDialog")
reload("gameui.GDivWheel")
reload("gameui.GDivTask")

reload("base.GameUtilSenior")



GameCharacter.initVar()