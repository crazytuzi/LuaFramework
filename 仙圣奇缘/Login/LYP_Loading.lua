--------------------------------------------------------------------------------------
-- 文件名:	LYP_Loading.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	李玉平
-- 日  期:	2013-12-10 10:24
-- 版  本:	1.0
-- 描  述:	Loading界面
-- 应  用:  本例子使用一般方法的实现Scene
---------------------------------------------------------------------------------------
--[[
1、客户端启动的时候先进入loading界面 显示公司的logo
2、在loading界面去拉取最新的版本号，如果是最新版本则在loading界面加载资源，完毕之后直接进入login界面
3、如果有资源更新 等公司logo动画播放完跳转到download界面，下载完毕之后进入login界面
4、如果中间异常则直接跳到login界面，等待联网
]]
version = "/link_file.dat"
local Label_FileName  = nil
local LoadingBar_Loading = nil
local Label_LoadingPercent  = nil
local rootLayout = nil
rootURL = nil 
if g_Cfg.Platform  ~= kTargetWindows  then
	if kTargetAndroid == g_Cfg.Platform then
		--rootURL ="http://120.24.15.41/Android_Normal/"
        --rootURL ="http://dss-resources.gametaiwan.com/Version_new/" --台湾正式
        --rootURL ="http://dss-resources.gametaiwan.com/Version_test/" --台湾测试
        --rootURL ="http://dsx-test.xiaoao.com/AutoUpdate/" --XIAOAO测试服
        --rootURL ="http://dsxres.xiaoaohudong.com/AutoUpdate_1_/" --XIAOAO正式服
        rootURL ="http://192.168.200.128:81/AutoUpdate_iOS_1_/"--小奥IOS

        
	else
		--rootURL ="http://120.24.15.41/Android_Normal/"
        --rootURL ="http://dss-resources.gametaiwan.com/Version_new/" --台湾正式
        --rootURL ="http://dss-resources.gametaiwan.com/Version_test/" --台湾测试
        --rootURL ="http://dsx-test.xiaoao.com/AutoUpdate/" --XIAOAO测试服
        --rootURL ="http://dsxres.xiaoaohudong.com/AutoUpdate_1_/" --XIAOAO正式服
        rootURL ="http://192.168.200.128:81/AutoUpdate_iOS_1_/"--小奥IOS
        
     end
else
	--rootURL ="http://120.24.15.41/Android/"
    --rootURL ="http://dss-resources.gametaiwan.com/Version_new/" --台湾正式
    --rootURL ="http://dss-resources.gametaiwan.com/Version_test/" --台湾测试
    --rootURL ="http://dsx-test.xiaoao.com/AutoUpdate/" --XIAOAO测试服
    --rootURL ="http://dsxres.xiaoaohudong.com/AutoUpdate_1_/" --XIAOAO正式服
    rootURL ="http://192.168.200.128:81/AutoUpdate_iOS_1_/"--小奥IOS
end

--为替换资源服地址做准备
local userURL = CCUserDefault:sharedUserDefault():getStringForKey("UpaDataURL", "")
if userURL and userURL ~= "" then
	rootURL = userURL
end

--CJson = require "cjson"  不使用c++的json 而使用lua的json
g_LoadFile("LuaScripts/json")
g_LoadFile("LuaScripts/FrameWork/ccs")
g_LoadFile("LuaScripts/GameLogic/GlobalFunc/GFunc_Glittering")
g_LoadFile("LuaScripts/GameSDK/TalkingData/TalkingData")
g_LoadFile("LuaScripts/GameLogic/Class_DataMgr")
g_LoadFile("LuaScripts/GameLogic/WB_DictionarySys")
g_LoadFile("LuaScripts/GameLogic/GlobalFunc/GFunc_Function")
g_LoadFile("Config/Dialogue")
g_LoadFile("LuaScripts/GameLogic/WB_LanguageVersion")
--不需要包含该文件 因为有lua_setglobal(L, LFS_LIBNAME);
--require("lfs")

----------------------------------------------------------------------------------------------------------------
---------------强制更新跳转下载相关-------------------------------------------------------------------------------------------------
eForcedUpdateType = 
{   --linktype是打开连接的方式，1是应用商店，2是网页连接
    ["IOS_VIETAPPSTROE_chanlong"] = { linktype = 1, link = "itms-apps://itunes.apple.com/vn/app/chan-long/id1080871064?mt=8"},
    ["IOS_VIETAPPSTROE_chanlongmobile"] = { linktype = 1, link = "itms-apps://itunes.apple.com/vn/app/chan-long-mobile/id1101088168?ls=1&mt=8"},
    ["ANDROID_VIETGGPLAY_chanlong"] = { linktype = 1, link = ""},
    ["ANDROID_VIETANDROID_chanlongCard"] = { linktype = 2, link = "http://dl5.vtcgame.vn/chanlong/chanlong.apk"},

    ["IOS_TAIWAN_xyfml"] = { linktype = 1, link = "itms-apps:://itunes.apple.com/tw/app/id1121941737"},
    ["ANDROID_TAIWANGOOGLE_xyfml"] = { linktype = 1, link = ""},
    ["ANDROID_TAIWANTAIYOU_xyfml"] = { linktype = 2, link = "http://dss.gametaiwan.com/download/sul.apk"},

    ["IOS_XIAOAOAPPSTORE_dsx"] = { linktype = 1, link = "itms-apps://itunes.apple.com/cn/app/id1125303767"}, 
    ["ANDROID_XIAOAO_dsx"]     = { linktype = 2, link = "http://dsxres.xiaoao.com/ClientUpdate/xogame_xsqy_v.apk"},   

    ["NIL"] = nil,
}

g_eForcedUpdateType = eForcedUpdateType["IOS_XIAOAOAPPSTORE_dsx"]

function onClick_Button_LinkToStore()
--linktype是打开连接的方式，1是应用商店，2是网页连接
    if g_eForcedUpdateType.linktype == 1 and CGamePlatform:SharedInstance().OpenLinkToDownLoad ~= nil then
        CGamePlatform:SharedInstance():OpenLinkToDownLoad(g_eForcedUpdateType.link)
    elseif g_eForcedUpdateType.linktype == 2 and CGamePlatform:SharedInstance().OpenLinkOnWeb ~= nil then
        CGamePlatform:SharedInstance():OpenLinkOnWeb(g_eForcedUpdateType.link)
    end
end


function  ShowForcedUpdate(Loading1View)
    if Loading1View == nil or g_eForcedUpdateType == nil then return end

    local Image_Logo2 = tolua.cast(Loading1View:getChildByName("Image_Logo2"), "ImageView")
    local Button_LinkToStore = tolua.cast(Loading1View:getChildByName("Button_LinkToStore"), "Button")
    Image_Logo2:setVisible(false)
    Button_LinkToStore:setVisible(true)
    Button_LinkToStore:addTouchEventListener(onClick_Button_LinkToStore)
    
end
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
 
function os.exists(path)
    return CCFileUtils:sharedFileUtils():isFileExist(path)
end
 
function os.mkdir(path)
    if not os.exists(path) then
        return lfs.mkdir(path)
    end
    return true
end
 
function os.rmdir(path)
    cclog("os.rmdir:"..path)
    if os.exists(path) then
        local function _rmdir(path)
            local iter, dir_obj = lfs.dir(path)
            while true do
                local dir = iter(dir_obj)
                if dir == nil then break end
                if dir ~= "." and dir ~= ".." then
                    local curDir = path..dir
                    local mode = lfs.attributes(curDir, "mode") 
                    if mode == "directory" then
                        _rmdir(curDir.."/")
                    elseif mode == "file" then
                        local succ, des = os.remove(curDir)
						if des then 
							cclog("os.remove error："..des)
						else
							cclog("os.remove："..curDir)
						end
                    end
                end
            end
            local succ, des = os.remove(path)
            if des then cclog(des) end
            return succ
        end
        _rmdir(path)
    end
    return true
end

function loginGame()

	if(not rootLayout)then
	 	return 
	end

	CCDirector:sharedDirector():replaceScene(LYP_GetStartGameScene())

	return 
end

local function actionDelayToNextAction(func, nDelay)	
	nDelay = nDelay or 0.08
	--初始化一些数据
	local array = CCArray:create()
	array:addObject(CCDelayTime:create(nDelay))
	array:addObject(CCCallFuncN:create(func))
	local action = CCSequence:create(array)
	rootLayout:runAction(action)
end

local function connectToServerCallback(sender)
	Label_FileName:setText(_T("资源加载完成"))
	g_MsgMgr:create() --初始化网络,只有初始化网络成功之后才跳转
	--g_MsgMgr:connectToDir()
	loginGame()
end
		
local function beginToLoadGameFile()
    --最先加载Loading界面
    g_LoadFile("LuaScripts/init")
	--初始化一些数据
	local function loadGameFilesCallBack(nPercent, szFileName, bFinished)
		Label_LoadingPercent:setText(nPercent.."%")
		--Label_FileName:setText(szFileName) 不显示加载文件名字
		LoadingBar_Loading:setPercent(nPercent)
		if(bFinished)then
			actionDelayToNextAction(connectToServerCallback)
		end
	end
	
	local function delayShowLoading()
		LoadingBar_Loading:setVisible(true)
		LoadingBar_Loading:setPercent(0)
		Label_FileName:setText(_T("加载本地文件中, 请稍候 >>>"))
		loadGameFiles(loadGameFilesCallBack)
	end
	
	local function delayShowLoadText()
		Label_FileName:setText(_T("加载游戏文件中, 请稍候 >>>"))
		actionDelayToNextAction(delayShowLoading)
	end
	
	actionDelayToNextAction(delayShowLoadText)
	
	-- local TDdata =  CDataEvent:CteateDataEvent()
	-- TDdata:PushDataEvent("Step2", "S") --S or F, Success or Fail
	-- gTalkingData:onEvent(TDEvent_Type.StartGame, TDdata)
	
end

local function showDownLoadWnd(layoutParent, szMaxVersion)
	local rootWidget = GUIReader:shareReader():widgetFromJsonFile("Game_UpdateFile.json")
	rootWidget:setTouchEnabled(true)
	layoutParent:addWidget(rootWidget)
	
	local Image_LoadingFrame = tolua.cast(rootWidget:getChildByName("Image_LoadingFrame"), "ImageView")
	Label_FileName = tolua.cast(Image_LoadingFrame:getChildByName("Label_FileName"),"Label")
	LoadingBar_Loading = tolua.cast(Image_LoadingFrame:getChildByName("LoadingBar_Loading"), "LoadingBar")
	LoadingBar_Loading:setPercent(0)
	Label_LoadingPercent = tolua.cast(LoadingBar_Loading:getChildByName("Label_LoadingPercent"), "Label")
	
	local Image_SpeakerNPC = tolua.cast(rootWidget:getChildByName("Image_SpeakerNPC"), "ImageView")
	local Label_Tips =  tolua.cast(Image_SpeakerNPC:getChildByName("Label_Tips"),"Label")
	local CSV_Dialogue = g_DataMgr:getCsvConfigByOneKey("Dialogue", 1000000)
	local nMax = #CSV_Dialogue
	local index = math.random(nMax)
	local szText = CSV_Dialogue[index]
	Label_Tips:setText(szText.Context)
	
	local CCNode_Tips = tolua.cast(Label_Tips:getVirtualRenderer(), "CCLabelTTF")
	CCNode_Tips:disableShadow(true)
	
	local Label_Version =  tolua.cast(rootWidget:getChildByName("Label_Version"),"Label")
	Label_Version:setText(_T("Ver.")..szMaxVersion)
	
	local Image_NPC = tolua.cast(rootWidget:getChildByName("Image_NPC"), "ImageView")
	local CCNode_Skeleton = g_CocosSpineAnimation("XiaoXianTong", 1, true)
	Image_NPC:removeAllNodes()
	Image_NPC:addNode(CCNode_Skeleton)
	g_runSpineAnimation(CCNode_Skeleton, "idle", true)
	
	local function onClickTalk(pSender, eventType)
		if eventType == ccs.TouchEventType.ended then
			local CSV_Dialogue = g_DataMgr:getCsvConfigByOneKey("Dialogue", 1000000)
			local nMax = #CSV_Dialogue
			local index = math.random(nMax)
			local szText = CSV_Dialogue[index]
			Label_Tips:setText(szText.Context)
            if g_playSoundEffect then
			    g_playSoundEffect("Sound/ButtonClick.mp3")
            else
                SimpleAudioEngine:sharedEngine():playEffect("Sound/ButtonClick.mp3")
            end
		end
	end
	rootWidget:addTouchEventListener(onClickTalk)
	
	-- local TDdata =  CDataEvent:CteateDataEvent()
	-- TDdata:PushDataEvent("Step1", "S") --S or F, Success or Fail
	-- gTalkingData:onEvent(TDEvent_Type.Update, TDdata)
end

local function showLogoAnimation(parent)

end

function LYP_GetLoadingScene()
    local Scene = CCScene:create()
    
    local function RegisterLayer()
	
		local function verCompare(ver1,ver2)
			ver1 = ver1.."."
			ver2 = ver2.."."
			local func1 = string.gfind(ver1,"%d.")
			local func2 = string.gfind(ver2,"%d.")
			for i = 1,3 do
				local a,b = tonumber(func1()),tonumber(func2())
				if a ~= b then
					return a > b
				end
			end
			return false;
		end
		
        
		--local nAPKVer = "1.0.0"
		local nAPKVer = API_GetVersion()
        --local curVer = CCFileUtils:sharedFileUtils():getFileData(g_writepath.."XXZUpdateFile".."/version.dat","rb",0)
		local curVer = CCUserDefault:sharedUserDefault():getStringForKey("Version","0.0.0")
		-- if curVer then 
			-- curVer = string.sub(curVer,string.find(curVer,"%d.%d.%d"))
		-- else
			-- curVer = nAPKVer
		-- end
        if( nAPKVer ~= curVer )then
			if verCompare(nAPKVer,curVer) then 
				if CCFileUtils:sharedFileUtils():isFileExist(g_writepath) then
					os.rmdir(g_writepath)
				end
				curVer = nAPKVer;
			else
                if not CCFileUtils:sharedFileUtils():isFileExist(g_writepath) then
                    --如果客户端更新文件丢失，则重置当前版本号为初始包的版本号，重新下载更新文件
				    curVer = nAPKVer
                    CCUserDefault:sharedUserDefault():setStringForKey("Version",curVer)	
				end
            end
            CCFileUtils:sharedFileUtils():addSearchPath(g_writepath) --???????
            --CCFileUtils:sharedFileUtils():addSearchPath(g_writepath.."GameUI")
        end

		local layer = TouchGroup:create()
		rootLayout = GUIReader:shareReader():widgetFromJsonFile("Game_Loading1.json")
        layer:addWidget(rootLayout)  
		--rootLayout:setTouchEnabled(true)
		
		local Image_Logo1 = tolua.cast(rootLayout:getChildByName("Image_Logo1"), "ImageView")
		local Image_Logo3 = tolua.cast(rootLayout:getChildByName("Image_Logo3"), "ImageView")
		if g_Cfg.Platform  == kTargetWindows then --Windows
			if eLanguageVer.LANGUAGE_viet_VIET == g_LggV:getLanguageVer() then
				Image_Logo1:loadTexture(getStartGameImg("LoadingLogo_Viet"))
				Image_Logo1:setPositionXY(180, 625)
				Image_Logo1:setScale(0.9)
				Image_Logo3:setVisible(true)
			elseif eLanguageVer.LANGUAGE_cht_Taiwan == g_LggV:getLanguageVer() then
				local Image_Background = tolua.cast(rootLayout:getChildByName("Image_Background"), "ImageView")
				if g_IsShenYuLing ~= nil and g_IsShenYuLing == true then
					Image_Background:loadTexture(getStartGameImgJpg("StarGame_SYL"))
					Image_Logo1:loadTexture(getStartGameImg("LoadingLogo_ShenYuLing"))
					Image_Logo1:setPositionX(Image_Logo1:getPositionX() + 25)
					Image_Logo1:setPositionY(Image_Logo1:getPositionY() - 30)
					Image_Logo1:setScale(1.25)
					Image_Logo3:setVisible(false)
				else
					Image_Background:loadTexture(getStartGameImg("StarGame"))
					Image_Logo1:loadTexture(getStartGameImg("LoadingLogo_XYFML"))
					Image_Logo3:setVisible(false)
				end
			else
				Image_Logo3:setVisible(false)
				if g_IsXiaoXiaoXianSheng then
					Image_Logo1:loadTexture(getStartGameImg("LoadingLogo_XiaoXiaoXianSheng"))
				elseif g_IsXianJianQiTan then
					Image_Logo1:loadTexture(getStartGameImg("LoadingLogo_XianShengQiYuan"))
				else
					Image_Logo1:loadTexture(getStartGameImg("LoadingLogo_XianShengQiYuan"))
				end
			end
		elseif g_Cfg.Platform  == kTargetAndroid then --Android
			if eLanguageVer.LANGUAGE_viet_VIET == g_LggV:getLanguageVer() then
				Image_Logo1:loadTexture(getStartGameImg("LoadingLogo_Viet"))
				Image_Logo1:setPositionXY(180, 625)
				Image_Logo1:setScale(0.9)
				Image_Logo3:setVisible(true)
			elseif eLanguageVer.LANGUAGE_cht_Taiwan == g_LggV:getLanguageVer() then
				local Image_Background = tolua.cast(rootLayout:getChildByName("Image_Background"), "ImageView")
				if g_IsShenYuLing ~= nil and g_IsShenYuLing == true then
					Image_Background:loadTexture(getStartGameImgJpg("StarGame_SYL"))
					Image_Logo1:loadTexture(getStartGameImg("LoadingLogo_ShenYuLing"))
					Image_Logo1:setPositionX(Image_Logo1:getPositionX() + 25)
					Image_Logo1:setPositionY(Image_Logo1:getPositionY() - 30)
					Image_Logo1:setScale(1.25)
					Image_Logo3:setVisible(false)
				else
					Image_Background:loadTexture(getStartGameImg("StarGame"))
					Image_Logo1:loadTexture(getStartGameImg("LoadingLogo_XYFML"))
					Image_Logo3:setVisible(false)
				end
			else
				Image_Logo3:setVisible(false)
				if g_IsXiaoXiaoXianSheng then
					Image_Logo1:loadTexture(getStartGameImg("LoadingLogo_XiaoXiaoXianSheng"))
				elseif g_IsXianJianQiTan then
					Image_Logo1:loadTexture(getStartGameImg("LoadingLogo_XianShengQiYuan"))
				else
					Image_Logo1:loadTexture(getStartGameImg("LoadingLogo_XianShengQiYuan"))
				end
			end
		else --iOS越狱
			if eLanguageVer.LANGUAGE_viet_VIET == g_LggV:getLanguageVer() then
				Image_Logo1:loadTexture(getStartGameImg("LoadingLogo_Viet"))
				Image_Logo1:setPositionXY(180, 625)
				Image_Logo1:setScale(0.9)
				Image_Logo3:setVisible(true)
			elseif eLanguageVer.LANGUAGE_cht_Taiwan == g_LggV:getLanguageVer() then
				local Image_Background = tolua.cast(rootLayout:getChildByName("Image_Background"), "ImageView")
				if g_IsShenYuLing ~= nil and g_IsShenYuLing == true then
					Image_Background:loadTexture(getStartGameImgJpg("StarGame_SYL"))
					Image_Logo1:loadTexture(getStartGameImg("LoadingLogo_ShenYuLing"))
					Image_Logo1:setPositionX(Image_Logo1:getPositionX() + 25)
					Image_Logo1:setPositionY(Image_Logo1:getPositionY() - 30)
					Image_Logo1:setScale(1.25)
					Image_Logo3:setVisible(false)
				else
					Image_Background:loadTexture(getStartGameImg("StarGame"))
					Image_Logo1:loadTexture(getStartGameImg("LoadingLogo_XYFML"))
					Image_Logo3:setVisible(false)
				end
			else
				Image_Logo3:setVisible(false)
				if g_IsXiaoXiaoXianSheng then
					Image_Logo1:loadTexture(getStartGameImg("LoadingLogo_XiaoXiaoXianSheng"))
				elseif g_IsXianJianQiTan then
					Image_Logo1:loadTexture(getStartGameImg("LoadingLogo_XianShengQiYuan"))
				else
					Image_Logo1:loadTexture(getStartGameImg("LoadingLogo_XianShengQiYuan"))
				end
			end
		end
	
		Label_FileName = tolua.cast(rootLayout:getChildByName("Label_Bar"), "Label")
		Label_FileName:setText(_T("校验游戏版本中, 请稍候 >>>"))
		
        --启动客户端
		-- local TDdata =  CDataEvent:CteateDataEvent()
		-- TDdata:PushDataEvent("Step1", "S") --S or F, Success or Fail
		-- gTalkingData:onEvent(TDEvent_Type.StartGame, TDdata)
	
		local Image_Loading = rootLayout:getChildByName("Image_Loading")
		Image_Loading:setVisible(false)
		
		-- showLogoAnimation(rootLayout)

        local function loadWidget()
           Image_Loading:setVisible(true)
           --if not LoadingBar_Loading then
               LoadingBar_Loading = tolua.cast(Image_Loading:getChildByName("LoadingBar_Process"), "LoadingBar")
	           Label_LoadingPercent = tolua.cast(LoadingBar_Loading:getChildByName("Label_Percent"), "Label")
           --end
           Label_LoadingPercent:setText("0/100")
		   LoadingBar_Loading:setPercent(0)
        end

        local function processNoNetWork()
           Label_FileName:setText(_T("网络异常, 请检查网络环境"))
           loadWidget()
           beginToLoadGameFile()
        end

		local function processNewestVersion(pSender)
			pSender:release()  
			loadWidget()
			Label_FileName:setText(_T("已经是最新的资源"))
			beginToLoadGameFile()
		end
		
		local tbVersion = nil
		local tbAllVersion = nil
		local curVerIndex = 1
		local nErrorCount  = 0
		local updateResMgr = CResUpdateMgr:create()
		local packageURL = rootURL
		local endIndex = string.find(g_writepath, "XXZUpdateFile")
		local zipPath = string.sub(g_writepath,1,endIndex-1)
		updateResMgr:createDownloadedDir(zipPath)

        local function getCurVersionInfo(szText)
            local szMaxVersion = tbAllVersion[#tbAllVersion].ver
	        local szVersion = tbAllVersion[curVerIndex].ver
            local szTips = szText..szVersion.."/"..szMaxVersion
	        Label_FileName:setText(szTips)
            cclog(szTips)
            return szMaxVersion, szVersion
        end
	
		local function updateRes(pSender, nType, nData, nMax)
			if(nType == CResUpdateMgr.kVersion)then
				local bRet = string.find(nData, "Not Found")
				if(bRet)then    --未能取得版本文件
                    Label_FileName:setText(_T("网络异常, 请检查网络环境"))  
					return
				end
				
                if(string.len(nData) == 0 )then--没有放版本信息，或者版本信息是空
					processNewestVersion(pSender)
					return
				end
				
				local starIndex,endIndex = string.find(nData, "(v.+,)",-10)
                local newestVer = string.sub(nData,starIndex+1,endIndex-1)
				if newestVer == curVer then 
                    processNewestVersion(pSender)
                    CCUserDefault:sharedUserDefault():setStringForKey("Version",curVer)
					return
				end
	
				local _,endIndex = string.find(nData, curVer)
				if not endIndex then
                    Label_FileName:setText(_T("游戏安装包需更新, 请到应用商店下载最新版本"))
                    if ShowForcedUpdate~= nil then     ShowForcedUpdate(rootLayout)  end
					return
				end
				
				starIndex,endIndex = string.find(nData, "([^,]+,)",endIndex+2)
				endIndex = endIndex or 2
				local verUrl = string.sub(nData,starIndex,endIndex-1)
				starIndex,endIndex = string.find(nData, "(%d*.v)",endIndex+1)
				endIndex = endIndex or 2
				local zipSize = tonumber(string.sub(nData,starIndex,endIndex-2))
				
				local function delayShowDownLoad()
                    --local szMaxVersion,szVersion = getCurVersionInfo("正在更新:")

					showDownLoadWnd(layer, newestVer)
					updateResMgr:updatePackage(packageURL..verUrl, newestVer)
					LoadingBar_Loading:setVisible(true)
				end
				
				actionDelayToNextAction(delayShowDownLoad, 2)
			elseif(nType == CResUpdateMgr.kOnProgress)then
				if(nMax > 0)then
					local nPercent = nData*100/nMax
					Label_LoadingPercent:setText(string.format(_T("更新进度 %d%% (%.2fMB)"), nPercent, nMax/1024/1024))
					LoadingBar_Loading:setPercent(nPercent)
				else
					Label_LoadingPercent:setText(_T("更新进度 0% (0MB)"))	
				end
				
				--cclog(_("更新进度"))
			elseif(nType == CResUpdateMgr.kSucess )then --下载到最新资源
				--processNextVersionDownLoad(pSender)
                processNewestVersion(pSender)
				-- local TDdata =  CDataEvent:CteateDataEvent()
				-- TDdata:PushDataEvent("Step2", "S") --S or F, Success or Fail
				-- gTalkingData:onEvent(TDEvent_Type.Update, TDdata)
			elseif(nType == CResUpdateMgr.kNoNewVersion)then --无最新资源
				cclog("===CResUpdateMgr.kNoNewVersion===")
                --processNextVersionDownLoad(pSender)
                processNewestVersion(pSender)
            elseif(nType == CResUpdateMgr.kUncompress)then --解压出问题
				cclog("===CResUpdateMgr.kUncompress===")
			elseif(nType == CResUpdateMgr.kOnCheckMd5)then --检验文件的md5 	
				local filename = zipPath.."/xxz.zip"
				local szMd5 = API_GetFileMD5(filename)
				cclog("down file MD5 is==="..szMd5)
			elseif(nType == CResUpdateMgr.kNetwork)then --网络异常
				if(not tbAllVersion)then	
					local function connectToServer(sender) --断线重连 10次
						nErrorCount = nErrorCount + 1
						if(nErrorCount == 10)then
							processNoNetWork()
							pSender:release()  
							return
						end
						Label_FileName:setText(_T("网络异常, 服务器连接中 >>>")..nErrorCount)
						updateResMgr:init(rootURL..version)
					end
					
					actionDelayToNextAction(connectToServer, 0.8)
				else
					local szMaxVersion,szVersion = getCurVersionInfo(_T("网络异常, 最新版本是:"))
					local function connectToDownLoad(sender)
						updateResMgr:updatePackage(packageURL..szVersion..".zip",  szVersion)
					end

					actionDelayToNextAction(connectToDownLoad, 2)
				end
			end
		end
		
        if g_Cfg.Update == false then 
             loadWidget()
             beginToLoadGameFile()
             return layer
		end
		
		local function downLoadVersion()
			updateResMgr:setResponseScriptCallback(updateRes)
			updateResMgr:init(rootURL..version)
		end
		actionDelayToNextAction(downLoadVersion, 1.8)
		
		return layer
    end

	local function onEnterOrExit(tag)
		if tag == "enter" then
			Scene:addChild(RegisterLayer())
			--关闭所有的音效和音乐
			SimpleAudioEngine:sharedEngine():stopAllEffects()
			SimpleAudioEngine:sharedEngine():stopBackgroundMusic(true)
		elseif tag == "exit" then
			CCTextureCache:sharedTextureCache():removeUnusedTextures()
		end
	end
    Scene:registerScriptHandler(onEnterOrExit)
    return Scene
end

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