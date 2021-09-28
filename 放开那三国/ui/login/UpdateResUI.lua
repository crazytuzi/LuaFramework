-- Filename: 	UpdateResUI.lua
-- Author: 		chengliang
-- Date: 		2014-5-04
-- Purpose: 	更新包下载界面


module("UpdateResUI", package.seeall)


-- check的URL
local g_download_url = ""
if(g_debug_mode == true)then
	-- g_download_url = "http://192.168.221.130/static/tmp/"
	g_download_url = "http://192.168.221.130/static/"
else
	g_download_url = Platform.getDownUrl()
end



local _nLoadingTimerValue	= 0.02 	-- 检查进度的时间间隔

local _bgLayer 				= nil
local _versionInfos			= nil  	-- 版本信息
local _loading_count 		= 1 	-- 资源加载的小点(.)的个数
local _csProgressBarBg 		= nil 	-- 进度条背景
local _csProgressBar 		= nil 	-- 进度条进度
local _percentSprite 		= nil 	-- 图片数字进度(90%)

local _oResManager 			= nil 	-- 下载管理

local _curVersionIndex 		= 1 	-- 当前下载第几个版本
local _totalSizeSvr 		= 0 	-- 服务器端返回的总大小
local _hadDownloadSize 		= 0 	-- 已经下载下来的总大小
local _curSigleSizeSvr 		= 0 	-- 当前正在下载的单个版本的大小

local _loadingTipLabel		= nil 	-- 提示

local _curLoginStatus 		= nil 	-- 状态，是第一次登录还是短线重连


function init()
	_versionInfos 			= nil  	-- 版本信息
	_bgLayer 				= nil
	_csProgressBarBg 		= nil 	-- 进度条背景
	_csProgressBar 			= nil 	-- 进度条进度
	_loading_count 			= 1 	-- 资源加载的小点(.)的个数
	_percentSprite 			= nil 	-- 图片数字进度(90%)
	_oResManager 			= nil 	-- 下载管理

	_totalSizeSvr 			= 0 	-- 服务器端返回的总大小
	_loadingTipLabel		= nil 	-- 提示
	_hadDownloadSize 		= 0 	-- 已经下载下来的总大小
	_curSigleSizeSvr 		= 0 	-- 当前正在下载的单个版本的大小
	_curVersionIndex 		= 1 	-- 当前下载第几个版本
	_curLoginStatus 		= nil 	-- 状态，是第一次登录还是短线重连
end

-- 清理LUA内存  先清理已经加载的LUA文件，然后再重新加载删掉的LUA文件
function fnReleaseLogicMods()

	CCFileUtils:sharedFileUtils():purgeCachedEntries()
	BTUtil:unscheduleAll()

	local releaseFileArr = {}

	for k, v in pairs(package.loaded) do
		local status = false
		if string.find(k, "db/") == 1 then
			status = true
		elseif string.find(k, "script/") == 1 then
			if string.find(k, "script/ui/login/") == 1 then
				status = false
			elseif string.find(k, "script/platform/Platform") == 1 then
				status = false
			elseif string.find(k, "script/platform/config/") == 1 then
				status = false
			elseif string.find(k, "script/Platform") == 1 then
				status = false
			elseif string.find(k, "script/config/") == 1 then
				status = false
			elseif string.find(k, "script/main") == 1 then
				status = false
			-- elseif string.find(k, "script/Logger") == 1 then
			-- 	status = false
			else
				status = true
			end
		end
		if status then
	
			-- local arrModNames=string.split(k, "/")
			-- local modName=arrModNames[#arrModNames]
			-- package.loaded[modName]=nil
			-- _G[modName]=nil
			-- package.loaded[k]=nil

			table.insert(releaseFileArr, k)
		end
	end

	for _, m_name in pairs(releaseFileArr) do

		package.loaded[m_name]=nil
		local arrModNames=string.split(m_name, "/")
		local modName=arrModNames[#arrModNames]
		package.loaded[modName]=nil
		_G[modName]=nil
		
	end

	collectgarbage("collect")
	require "script/ui/network/LoadingUI"
	require "script/GlobalVars"
	require "script/localized/LocalizedUtil"

end

-- 解压资源
function uncompressAndCopyRes( ... )
	print("uncompressAndCopyRes _curVersionIndex==", _curVersionIndex)
	local bResult=_oResManager:uncompressAndCopy()
	if bResult then
		print("over _curVersionIndex==", _curVersionIndex)
	else
		_oResManager:cleanup()
		BTUtil:unscheduleAll()
		require "script/ui/tip/AlertTip"
	   	AlertTip.showAlert(GetLocalizeStringBy("key_1380"), function ( ... )
            Platform.quit()
	    end)
	end

	return bResult
end

-- 是否需要退出游戏
local function isExitGame()
	local isForceExit = false
	for k,v_info in pairs(_versionInfos) do
		if(v_info.forceExit == 1)then
			isForceExit = true
			break
		end
	end
	return isForceExit
end

-- 下载完成后处理
function overAllDownload()
	
	
	if(isExitGame() == true)then
		_bgLayer:removeFromParentAndCleanup(true)
		_bgLayer = nil
		require "script/ui/tip/AlertTip"
	   	AlertTip.showAlert(GetLocalizeStringBy("key_1793"), function ( ... )
            Platform.quit()
	    end)
	else
		-- 清理LUA内存
		fnReleaseLogicMods()
		-- 直接进游戏
		require "script/ui/login/LoginScene"
		LoginScene.loginGame()
		if( _curLoginStatus and _curLoginStatus == LoginScene._nIndexOfReconn )then
			
		else
			_bgLayer:removeFromParentAndCleanup(true)
			_bgLayer = nil
		end
	end
end


--清理旧文件
function rmOldZip( ... )
	printR("rmOldZip begin")
	local zip = CCFileUtils:sharedFileUtils():getWritablePath() .. "cocos2dx-update-temp-package.zip"
	os.remove(zip)
	printR("rmOldZip end")
end

-- 开启当前包得下载
function startDownloadCurIndexVersion()
	print("start download index ==", _curVersionIndex)
	_oResManager:cleanup()
	local files = _versionInfos[_curVersionIndex].files
	_curSigleSizeSvr = _versionInfos[_curVersionIndex].total_size
	for i=1, #files do
		_oResManager:addPackage(files[i])
	end
	local pacakgeUrl = g_download_url .._versionInfos[_curVersionIndex].path.."/"
	_oResManager:setPackageUrl(pacakgeUrl)
	_oResManager:update()

	fnResLoading()
end

-- 将版本号转成整 格式必须是“x.x.x<=>1.2.0”
local function versionToInt(v_str)
	local v_int = string.gsub(v_str, "%.", "")
	v_int = tonumber(v_int)
	return v_int
end

-- 比较版本号 格式必须是 1.2.0 <==> xx.xx.xx return 1/0/-1 <==> >/=/<
function checkScriptVersion( newVersion, oldVersion )
	
	local n_version_arr = string.splitByChar(newVersion, ".")
	local o_version_arr = string.splitByChar(oldVersion, ".")

	if( tonumber(n_version_arr[1]) > tonumber(o_version_arr[1]) )then
		return 1
	elseif( tonumber(n_version_arr[2]) > tonumber(o_version_arr[2]) and tonumber(n_version_arr[1]) == tonumber(o_version_arr[1]))then
		return 1
	elseif( tonumber(n_version_arr[3]) > tonumber(o_version_arr[3]) and tonumber(n_version_arr[2]) == tonumber(o_version_arr[2]) and  tonumber(n_version_arr[1]) == tonumber(o_version_arr[1]))then
		return 1
	elseif( tonumber(n_version_arr[3]) == tonumber(o_version_arr[3]) and tonumber(n_version_arr[2]) == tonumber(o_version_arr[2]) and  tonumber(n_version_arr[1]) == tonumber(o_version_arr[1]))then
		return 0
	else
		return -1
	end

end

-- 检查当前的下载状态是否合法 兼容之前的版本
local function getRightStatus()
	local isRightStatus = true

	local status = _oResManager:getStatus()

	if (status == ResManager.kSuccess or status == ResManager.kDownloadFinish) then
		isRightStatus = true
	else
		isRightStatus = false
	end

	if( isRightStatus == false )then
		_loadingTipLabel:stopAllActions()
		_csProgressBar:stopAllActions()
		require "script/ui/tip/AlertTip"
		AlertTip.showAlert(GetLocalizeStringBy("key_1257"), function ( ... )
            Platform.quit()
	    end)
	end

	return isRightStatus
end

-- 当前的单个version是否下载完成
local function isCurVersionOver( ... )
	local isOver = true

	local status = _oResManager:getStatus()
	if( status == ResManager.kDownloadFinish )then
		isOver = true
	else
		isOver = false
	end

	return isOver
end



-- 下载
function fnResLoading( ... )
	if (getRightStatus() == false) then
		-- 检查当前状态
		print("getRightStatus() == false")
		return
	end
	if( isCurVersionOver() == true )then
		-- 当前单个版本已经下载完毕
		-- local isUncompressSuc = uncompressAndCopyRes()
		-- if( isUncompressSuc ~= true)then
		-- 	-- 出错
		-- 	return
		-- end
		function callBack( ... )
			print("callBack")
			_hadDownloadSize = _hadDownloadSize + _curSigleSizeSvr
			if(_curVersionIndex >= #_versionInfos)then
				-- 所有下载完成
				refreshPercent(100)
				_loadingTipLabel:stopAllActions()
				_loadingTipLabel:setString(GetLocalizeStringBy("key_1585"))
				overAllDownload()
			else
				_curVersionIndex = _curVersionIndex + 1
				-- 继续下载一个包
				startDownloadCurIndexVersion()
			end
		end
		print("pre uncompress")
		local damageActionArray = CCArray:create()
        damageActionArray:addObject(CCDelayTime:create(0.2))
        damageActionArray:addObject(CCCallFuncN:create(uncompressAndCopyRes))
        damageActionArray:addObject(CCCallFuncN:create(callBack))
        _bgLayer:runAction(CCSequence:create(damageActionArray))

		
	else
		-- 刷新进度UI
		local sigleDownloadSize = _oResManager:getDownloadedNum()
		if(sigleDownloadSize>0)then
			local per = math.floor((sigleDownloadSize+_hadDownloadSize)/_totalSizeSvr * 100 )
			refreshPercent(per)
		end

		local actionArray = CCArray:create()
		actionArray:addObject(CCDelayTime:create(_nLoadingTimerValue))
		actionArray:addObject(CCCallFunc:create(fnResLoading))
		_bgLayer:runAction(CCSequence:create(actionArray))
	end

end


-- 确认更新Action
function confirmUpdateAction( tag, itemBtn )
	_oResManager = ResManager:sharedManager()
	_oResManager:setConnectionTimeout(30)
	-- 开启当前包得下载
	_curVersionIndex = 1 
	rmOldZip()
	startDownloadCurIndexVersion()
end

-- 计算资源的大小
function calTotalSize()
	_totalSizeSvr = 0
	for i=1, #_versionInfos do
    	local versionInfo = _versionInfos[i]
    	_totalSizeSvr = _totalSizeSvr + versionInfo.total_size
    end
end

-- 获得大小的显示文字
function getSizeDisplayString( m_size )
	local displayString = "0B"
	if(m_size<1024)then
		displayString = m_size .. "B"
	elseif(m_size<1024 * 1024)then
		displayString = string.format("%.1fKB", m_size/1024)

	else
		displayString = string.format("%.1fMB", m_size/(1024*1024) )
	end

	return displayString
end


-- 创建确认对话框
function createConfirmTipLayer()
	-- 创建灰色摭罩层
	local cclMask = CCLayerColor:create(ccc4(10,10,10, 180))
	cclMask:setTouchEnabled(true)
	cclMask:registerScriptTouchHandler(function ( ... )
		return true
	end, false, -6000, true)
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	runningScene:addChild(cclMask, 3000)

	-- 主体背景框
	local tBgPreferredSize=CCSizeMake(490, 266)
	local cs9Bg=CCScale9Sprite:create("images/common/bg/9s_view_bg2.png", CCRectMake(0,0,213,171), CCRectMake(50,50,113,71))
	cs9Bg:setPreferredSize(tBgPreferredSize)
	cs9Bg:setScale(g_fElementScaleRatio)
	cs9Bg:setPosition(g_winSize.width/2-20*g_fElementScaleRatio, g_winSize.height/2)
	cs9Bg:setAnchorPoint(ccp(0.5,0.5))
	cclMask:addChild(cs9Bg)

	local flowerSprite = CCSprite:create("images/login/flower.png")
	flowerSprite:setAnchorPoint(ccp(0.5,0))
	flowerSprite:setPosition(ccp(tBgPreferredSize.width/2-30, -30))
	cs9Bg:addChild(flowerSprite)

	local csGuideGirl = CCSprite:create("images/login/rw.png")
	local tSizeGuideGirl = csGuideGirl:getContentSize()
	csGuideGirl:setPosition(tBgPreferredSize.width+120, tBgPreferredSize.height/2)
	csGuideGirl:setAnchorPoint(ccp(1, 0.5))
	cs9Bg:addChild(csGuideGirl)
	

	-- 计算总大小
	calTotalSize()
	local displayString = getSizeDisplayString(_totalSizeSvr)
	require "script/libs/LuaCCLabel"
	local tRichTextInfo = {}
	tRichTextInfo.width = 370
    tRichTextInfo[1] = {content=GetLocalizeStringBy("key_2228"),ntype="label",font=g_sFontPangWa,color=ccc3(0x63,0,0),fontSize=30}
    tRichTextInfo[2] = {content=displayString,ntype="label",font=g_sFontPangWa,color=ccc3(1,0x75,0x0c),fontSize=30}
    tRichTextInfo[3] = {content=GetLocalizeStringBy("key_2851"),ntype="label",font=g_sFontPangWa,color=ccc3(0x63,0,0),fontSize=30}
    local clRichText = LuaCCLabel.createRichText(tRichTextInfo)
    clRichText:setPosition(50, 180)
    cs9Bg:addChild(clRichText)
    LuaCCLabel.release()

    -- 按钮菜单栏
	local menuBar = CCMenu:create()
	menuBar:setPosition(ccp(0,0))
	menuBar:setTouchPriority(-6100)
	cs9Bg:addChild(menuBar)

	local fullRect = CCRectMake(0, 0, 119, 64)
	local insetRect = CCRectMake(56, 29, 10, 1)
	local preferredSize = CCSizeMake(126, 64)

	local cs9BgN01 = CCScale9Sprite:create("images/common/btn/btn_blue_n.png", fullRect, insetRect)
	cs9BgN01:setPreferredSize(preferredSize)
	local cs9BgH01 = CCScale9Sprite:create("images/common/btn/btn_blue_h.png", fullRect, insetRect)
	cs9BgH01:setPreferredSize(preferredSize)
	local cmisConfirm = CCMenuItemSprite:create(cs9BgN01, cs9BgH01)
	cmisConfirm:registerScriptTapHandler(function ( ... )
		cclMask:removeFromParentAndCleanup(true)
		confirmUpdateAction()
	end)
	cmisConfirm:setPosition(tBgPreferredSize.width*0.35, 35)
	menuBar:addChild(cmisConfirm)

	local cs9BgN02 = CCScale9Sprite:create("images/common/btn/btn_blue_n.png", fullRect, insetRect)
	cs9BgN02:setPreferredSize(preferredSize)
	local cs9BgH02 = CCScale9Sprite:create("images/common/btn/btn_blue_h.png", fullRect, insetRect)
	cs9BgH02:setPreferredSize(preferredSize)
	local cmisGiveup = CCMenuItemSprite:create(cs9BgN02, cs9BgH02)
	cmisGiveup:registerScriptTapHandler(function ( ... )
		cclMask:removeFromParentAndCleanup(true)
        Platform.quit()
	end)
	cmisGiveup:setPosition(tBgPreferredSize.width*0.6, 28)
	-- menuBar:addChild(cmisGiveup)

	local crlConfirm = CCRenderLabel:create(GetLocalizeStringBy("cl_1024"), g_sFontPangWa, 30, 1, ccc3(0, 0, 0), type_stroke)
	crlConfirm:setColor(ccc3(0xfe, 0xdb, 0x1c))
	cmisConfirm:addChild(crlConfirm)
	crlConfirm:setAnchorPoint(ccp(0.5, 0.5))
	crlConfirm:setPosition(cmisConfirm:getContentSize().width/2, cmisConfirm:getContentSize().height/2)

	local crlGiveup = CCRenderLabel:create(GetLocalizeStringBy("key_2816"), g_sFontPangWa, 30, 1, ccc3(0, 0, 0), type_stroke)
	crlGiveup:setColor(ccc3(0xfe, 0xdb, 0x1c))
	-- cmisGiveup:addChild(crlGiveup)
	crlGiveup:setAnchorPoint(ccp(0.5, 0.5))
	crlGiveup:setPosition(cmisConfirm:getContentSize().width/2, cmisConfirm:getContentSize().height/2)
end

-- 刷新图片数字进度(90%)
function refreshPercent(pPercent)
	if _percentSprite then
		_percentSprite:removeFromParentAndCleanup(true)
		_percentSprite = nil
	end
	local tSizeSword = _csSword:getContentSize()
	require "script/libs/LuaCC"
	local sPercent = pPercent .. "%"
	_percentSprite = LuaCC.createNumberSprite("images/login/numbers", sPercent)
	_percentSprite:setPosition(tSizeSword.width, tSizeSword.height-10)
	_percentSprite:setAnchorPoint(ccp(0, 1))
	_csSword:addChild(_percentSprite)


	local tSizeProgressBg = _csProgressBarBg:getContentSize()
	local tSizeSword = _csSword:getContentSize()
	local ratio = pPercent/100.0
	local nRatioWidth = math.floor(ratio*tSizeProgressBg.width)
	if nRatioWidth > tSizeSword.width/2 and (tSizeProgressBg.width-nRatioWidth) >= tSizeSword.width/2 then
		_csProgressBar:setTextureRect(CCRectMake(0, 0, nRatioWidth, tSizeProgressBg.height))
		_csSword:setPositionX(nRatioWidth-tSizeSword.width/2)
	end


end

-- 显示进度条等UI
function createProgressUI()
	-- 进度条背景
	local y_progress = 200
	_csProgressBarBg = CCSprite:create("images/login/progress_bar_bg.png")
	_csProgressBarBg:setScale(g_fScaleX)
	_csProgressBarBg:setAnchorPoint(ccp(0.5, 0))
	_csProgressBarBg:setPosition(g_winSize.width/2, y_progress*g_fScaleX)
	local tSizeProgressBg = _csProgressBarBg:getContentSize()
	_bgLayer:addChild(_csProgressBarBg)

	_csProgressBar = CCSprite:create("images/login/progress_bar.png")
	_csSword = CCSprite:create("images/login/sword.png")
	_csSword:setAnchorPoint(ccp(0, 0))
	_csSword:setPosition(0, tSizeProgressBg.height*0.36)
	local tSizeSword = _csSword:getContentSize()
	
	
	_csProgressBar:setTextureRect(CCRectMake(0, 0, tSizeSword.width/2, tSizeProgressBg.height))
	_csProgressBarBg:addChild(_csProgressBar)
	_csProgressBarBg:addChild(_csSword)

	_loadingTipLabel = CCLabelTTF:create(GetLocalizeStringBy("key_2238"), g_sFontName, 24)
	_loadingTipLabel:setScale(g_fScaleX)
	_loadingTipLabel:setAnchorPoint(ccp(0.5, 0))
	_loadingTipLabel:setPosition(g_winSize.width/2, (y_progress-100)*g_fScaleX)
	_bgLayer:addChild(_loadingTipLabel)

	local function fnLoadingLabelSchedule( ... )
		local text = GetLocalizeStringBy("key_2238")
		if _loading_count > 6 then
			_loading_count = 1
		end
		for i=1, _loading_count do
			text = text .. "."
		end
		_loadingTipLabel:setString(text)
		_loading_count = _loading_count + 1
	end

	require "script/utils/extern"
	schedule(_loadingTipLabel, fnLoadingLabelSchedule, 0.1)

	-- 初始图片数字进度(0%)
	refreshPercent("0")
end

-- 进入
function showUI(pVersionInfo, loginStatus, static_url)
	init()
	-- 先释放内存资源，防止大数据解压内存不足
	CCFileUtils:sharedFileUtils():purgeCachedEntries()
	BTUtil:unscheduleAll()

	

	_versionInfos 	= pVersionInfo
	_curLoginStatus = loginStatus

	if( not string.isEmpty(static_url) ) then

		g_download_url = static_url
		print("g_download_url==", g_download_url)
	end


	print("_versionInfos_versionInfos_versionInfos, _curLoginStatus=", _curLoginStatus)
	print_t(_versionInfos)

	-- 创建背景
	_bgLayer = CCLayer:create()
	_bgLayer:setTouchEnabled(true)
	_bgLayer:registerScriptTouchHandler(function ( ... )
		return true
	end, false, -5600, true)
	
	local bg = CCSprite:create("images/login/bg.jpg")
	bg:setPosition(ccp(g_winSize.width/2, g_winSize.height/2))
	bg:setAnchorPoint(ccp(0.5, 0.5))
	_bgLayer:addChild(bg)
	bg:setScale(g_fBgScaleRatio)

	local logoSprite = CCSprite:create("images/login/logo.png")
	logoSprite:setAnchorPoint(ccp(0.5, 0.5))
	logoSprite:setPosition(ccp(_bgLayer:getContentSize().width/2, _bgLayer:getContentSize().height*0.8))
	logoSprite:setScale(g_fElementScaleRatio)
	_bgLayer:addChild(logoSprite,6)

	local effectSprite = XMLSprite:create("images/login/denglujiemian_zhulin_luoye/denglujiemian_zhulin_luoye")
	effectSprite:setScale(g_fElementScaleRatio)
	effectSprite:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.5))
	effectSprite:setAnchorPoint(ccp(0.5,0.5))
	_bgLayer:addChild(effectSprite,5)

	local effectSprite2 = XMLSprite:create("images/login/denglujiemian_zhulin/denglujiemian_zhulin")
	-- effectSprite2:setScale(g_fElementScaleRatio)
	effectSprite2:setPosition(ccp(bg:getContentSize().width*0.5,bg:getContentSize().height*0.5))
	effectSprite2:setAnchorPoint(ccp(0.5,0.5))
	bg:addChild(effectSprite2,5)

	local effectSprite3 = XMLSprite:create("images/login/denglujiemian_3nian_tubiao/denglujiemian_3nian_tubiao")
	effectSprite3:setScale(g_fElementScaleRatio)
	effectSprite3:setPosition(ccp(_bgLayer:getContentSize().width*0.5,_bgLayer:getContentSize().height*0.8))
	effectSprite3:setAnchorPoint(ccp(0.5,0.5))
	_bgLayer:addChild(effectSprite3,7)

	-- local bg2 = CCSprite:create("images/login/bg2.png")
	-- bg2:setPosition(ccps(0.5, 0.5))
	-- bg2:setAnchorPoint(ccp(0.5, 0.5))
	-- bg2:setScale(g_fElementScaleRatio)
	-- _bgLayer:addChild(bg2)
	
	-- 添加到runningScene上
	local runningScene = CCDirector:sharedDirector():getRunningScene()
	runningScene:addChild(_bgLayer)

	-- 显示进度条等UI
	createProgressUI()

	-- 创建确认对话框
	createConfirmTipLayer()


end
