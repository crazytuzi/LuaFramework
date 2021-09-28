-- Filename: UpgradeUI.lua
-- Author: fang
-- Date: 2013-11-08
-- Purpose: 该文件用于显示更新包下载界面

module("UpgradeUI", package.seeall)
require "script/utils/SupportUtil"
-- 正在加载资源......
local _loading_count=1

local _nTotalToDownload=0
local _nSingleDataSize=0
local _nPreviousVersionDownloadedSize=0

local _csProgressBarBg
local _csProgressBar=nil
local _cltCheckVersion
local _tVersionInfo
local _nExitFlag=false

local _oResManager

local _nLastDownloadedNum=0
local _nLoadingTimerValue=0.02
local _nLoadingTimerCount=0
local _ConnectTimeOut = 5
local _nCurrentIndex=1

local _csPercent

local function init( ... )
	_csPercent=nil
	_csProgressBarBg=nil
	_csProgressBar=nil
	_cltCheckVersion=nil
	_tVersionInfo=nil
	_nCurrentIndex=1
	_nPrevVerDownloadedSize=0
	_nSingleDataSize=0
end

function fnReleaseLogicMods()
	local status
	for k, v in pairs(package.loaded) do
		status = false
		if string.find(k, "db/") == 1 then
			status = true
		elseif string.find(k, "script/") == 1 then
			if string.find(k, "script/ui/login/") == 1 then
				status = false
			elseif string.find(k, "script/Platform") == 1 then
				status = false
			elseif string.find(k, "script/config/") == 1 then
				status = false
			elseif string.find(k, "script/main") == 1 then
				status = false
			else
				status = true
			end
		end
		if status then
			require "script/utils/LuaUtil"
			package.loaded[k]=nil
			local arrModNames=string.split(k, "/")
			local modName=arrModNames[#arrModNames]
			package.loaded[modName]=nil
			_G[modName]=nil
		end
	end
	collectgarbage("collect")
	require "script/GlobalVars"
end

local function fnUncompressAndCopy( ... )
	local bResult=_oResManager:uncompressAndCopy()
	if bResult then
		local tmpVersionInfo = _tVersionInfo[_nCurrentIndex]

		CCUserDefault:sharedUserDefault():setStringForKey("GameVersion", tmpVersionInfo.tar_version)
		CCUserDefault:sharedUserDefault():flush()
		if tmpVersionInfo.exit == 1 then
			_nExitFlag = true
		end
	else
		_oResManager:cleanup()
		require "script/ui/tip/AlertTip"
	   	AlertTip.showAlert(GetLocalizeStringBy("key_1380"), function ( ... )
	    	CCDirector:sharedDirector():endToLua()
	    	os.exit()
	    end)
	end
end

local function fnFinalHandler( ... )
	fnUncompressAndCopy()
	if _nExitFlag == true then
		require "script/ui/tip/AlertTip"
		AlertTip.showAlert(GetLocalizeStringBy("key_1793"), function ( ... )
			CCDirector:sharedDirector():endToLua()
			os.exit()
		end)
	else
	    fnReleaseLogicMods()
	    require "script/ui/login/LoginScene"
	    LoginScene.loginGame()
	end
end


local function fnRefreshPercent(pPercent)
	if _csPercent then
		_csPercent:removeFromParentAndCleanup(true)
	end
	local tSizeSword = _csSword:getContentSize()
	require "script/libs/LuaCC"
	local sPercent = pPercent .. "%"
	_csPercent = LuaCC.createNumberSprite("images/login/numbers", sPercent)
	_csPercent:setPosition(tSizeSword.width, tSizeSword.height-10)
	_csPercent:setAnchorPoint(ccp(0, 1))
	_csSword:addChild(_csPercent)
end

local function fnResLoading( ... )
	local status = _oResManager:getStatus()
print(".............................................................status: ", status)
	if status ~= ResManager.kSuccess then
		_cltCheckVersion:stopAllActions()
		_csProgressBar:stopAllActions()
		require "script/ui/tip/AlertTip"
		AlertTip.showAlert(GetLocalizeStringBy("key_1380"), function ( ... )
	    	CCDirector:sharedDirector():endToLua()
	    	os.exit()
	    end)
	end
	local nCurrNum = _oResManager:getDownloadedNum()
print(".............................................................nCurrNum: ", nCurrNum, ", _nSingleDataSize: ", _nSingleDataSize)
	if nCurrNum + _nPreviousVersionDownloadedSize >= _nTotalToDownload then
		_cltCheckVersion:setString(GetLocalizeStringBy("key_1585"))
		_cltCheckVersion:stopAllActions()
		_csProgressBar:stopAllActions()
		fnRefreshPercent("100")
		local tSizeProgressBg = _csProgressBarBg:getContentSize()
		local tSizeSword = _csSword:getContentSize()
		_csProgressBar:setTextureRect(CCRectMake(0, 0, tSizeProgressBg.width, tSizeProgressBg.height))
		performWithDelay(_csSword, fnFinalHandler, 0.1)
	elseif nCurrNum >= _nSingleDataSize then
		fnUncompressAndCopy()
		_nLastDownloadedNum = nCurrNum
		_nLoadingTimerCount = 0
		_nPreviousVersionDownloadedSize = _nPreviousVersionDownloadedSize + _nSingleDataSize
		if _nCurrentIndex < #_tVersionInfo then
			_nCurrentIndex = _nCurrentIndex + 1
			_oResManager:cleanup()
			local files = _tVersionInfo[_nCurrentIndex].files
    		_nSingleDataSize = _tVersionInfo[_nCurrentIndex].total_size
			for i=1, #files do
				_oResManager:addPackage(files[i])
			end
			local pacakgeUrl = "http://static1.zuiyouxi.com/sanguo/".._tVersionInfo[_nCurrentIndex].path.."/"
			if SupportUtil.isSupportHttps() then
				pacakgeUrl = "https://static1.zuiyouxi.com/sanguo/".._tVersionInfo[_nCurrentIndex].path.."/"
			end
			_oResManager:setPackageUrl(pacakgeUrl)
			_oResManager:setResMd5(_tVersionInfo[_nCurrentIndex].md5)
			_oResManager:update()
		end
	elseif nCurrNum ~= _nLastDownloadedNum then
		local tSizeProgressBg = _csProgressBarBg:getContentSize()
		local tSizeSword = _csSword:getContentSize()
		local ratio = (nCurrNum+_nPreviousVersionDownloadedSize)/_nTotalToDownload
		local nRatioWidth = math.floor(ratio*tSizeProgressBg.width)
		fnRefreshPercent(math.ceil(ratio*100))
		if nRatioWidth > tSizeSword.width/2 and (tSizeProgressBg.width-nRatioWidth) >= tSizeSword.width/2 then
			_csProgressBar:setTextureRect(CCRectMake(0, 0, nRatioWidth, tSizeProgressBg.height))
			_csSword:setPositionX(nRatioWidth-tSizeSword.width/2)
		end
		_nLastDownloadedNum = nCurrNum
		_nLoadingTimerCount=0
	elseif _nLoadingTimerCount > 15/_nLoadingTimerValue then
		_cltCheckVersion:stopAllActions()
		_csProgressBar:stopAllActions()
		require "script/ui/tip/AlertTip"
	    AlertTip.showAlert(GetLocalizeStringBy("key_2847"), function ( ... )
	    	CCDirector:sharedDirector():endToLua()
	    	os.exit()
	    end)
	else
		_nLoadingTimerCount = _nLoadingTimerCount + 1
	end
end

local function fnUpdateConfirm( ... )
	_oResManager = ResManager:sharedManager()
	_oResManager:update()
	_nLoadingTimerCount=0
	_nLastDownloadedNum=0
	schedule(_csProgressBar, fnResLoading, _nLoadingTimerValue)
end

function addUpdateTipLayer(tParam)
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
	local cs9Bg=CCScale9Sprite:create("images/common/viewbg1.png", CCRectMake(0,0,213,171), CCRectMake(50,50,113,71))
	cs9Bg:setPreferredSize(tBgPreferredSize)

	local csGuideGirl = CCSprite:create("images/guide/guideGirl.png")
	local tSizeGuideGirl = csGuideGirl:getContentSize()
	local x_left = (g_winSize.width-(tSizeGuideGirl.width/2+tBgPreferredSize.width+12)*g_fElementScaleRatio)/2

	local x_girl=x_left
	csGuideGirl:setPosition(x_girl, g_winSize.height/2)
	csGuideGirl:setAnchorPoint(ccp(0, 0.5))
	csGuideGirl:setScale(g_fElementScaleRatio)
	
	local x_bg = x_girl + tSizeGuideGirl.width/2
	local y_bg = g_winSize.height/2 - 26*g_fElementScaleRatio
	cs9Bg:setPosition(tSizeGuideGirl.width/2+8, tSizeGuideGirl.height/2-26)
	cs9Bg:setAnchorPoint(ccp(0, 0.5))
	csGuideGirl:addChild(cs9Bg, -1)
	cclMask:addChild(csGuideGirl)

	require "script/libs/LuaCCLabel"
	local tRichTextInfo = {}
	tRichTextInfo.width = 330
    tRichTextInfo[1] = {content=GetLocalizeStringBy("key_2228"),ntype="label",font=g_sFontPangWa,color=ccc3(0x63,0,0),fontSize=24}
    tRichTextInfo[2] = {content=tParam.text,ntype="label",font=g_sFontPangWa,color=ccc3(1,0x75,0x0c),fontSize=24}
    tRichTextInfo[3] = {content=GetLocalizeStringBy("key_2851"),ntype="label",font=g_sFontPangWa,color=ccc3(0x63,0,0),fontSize=24}
    local clRichText = LuaCCLabel.createRichText(tRichTextInfo)
    clRichText:setPosition(csGuideGirl:getContentSize().width/2, 218)
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
		fnUpdateConfirm()
	end)
	cmisConfirm:setPosition(tBgPreferredSize.width*0.2, 28)
	menuBar:addChild(cmisConfirm)

	local cs9BgN02 = CCScale9Sprite:create("images/common/btn/btn_blue_n.png", fullRect, insetRect)
	cs9BgN02:setPreferredSize(preferredSize)
	local cs9BgH02 = CCScale9Sprite:create("images/common/btn/btn_blue_h.png", fullRect, insetRect)
	cs9BgH02:setPreferredSize(preferredSize)
	local cmisGiveup = CCMenuItemSprite:create(cs9BgN02, cs9BgH02)
	cmisGiveup:registerScriptTapHandler(function ( ... )
		cclMask:removeFromParentAndCleanup(true)
		CCDirector:sharedDirector():endToLua()
		os.exit()
	end)
	cmisGiveup:setPosition(tBgPreferredSize.width*0.6, 28)
	menuBar:addChild(cmisGiveup)

	local crlConfirm = CCRenderLabel:create(GetLocalizeStringBy("key_1985"), g_sFontPangWa, 30, 1, ccc3(0, 0, 0), type_stroke)
	crlConfirm:setColor(ccc3(0xfe, 0xdb, 0x1c))
	cmisConfirm:addChild(crlConfirm)
	crlConfirm:setAnchorPoint(ccp(0.5, 0.5))
	crlConfirm:setPosition(cmisConfirm:getContentSize().width/2, cmisConfirm:getContentSize().height/2)

	local crlGiveup = CCRenderLabel:create(GetLocalizeStringBy("key_2816"), g_sFontPangWa, 30, 1, ccc3(0, 0, 0), type_stroke)
	crlGiveup:setColor(ccc3(0xfe, 0xdb, 0x1c))
	cmisGiveup:addChild(crlGiveup)
	crlGiveup:setAnchorPoint(ccp(0.5, 0.5))
	crlGiveup:setPosition(cmisConfirm:getContentSize().width/2, cmisConfirm:getContentSize().height/2)
end

local function fnDownloadRes( ... )
    _loading_count=0
    for i=1, #_tVersionInfo do
    	local versionInfo = _tVersionInfo[i]
    	_nTotalToDownload = _nTotalToDownload + versionInfo.total_size
    end

    _oResManager = ResManager:sharedManager()
    local files = _tVersionInfo[_nCurrentIndex].files
    _nSingleDataSize = _tVersionInfo[_nCurrentIndex].total_size
    _oResManager:setResMd5(_tVersionInfo[_nCurrentIndex].md5)

	for i=1, #files do
		_oResManager:addPackage(files[i])
	end

	local pacakgeUrl = "http://static1.zuiyouxi.com/sanguo/".._tVersionInfo[_nCurrentIndex].path.."/"
	if SupportUtil.isSupportHttps() then
		pacakgeUrl = "https://static1.zuiyouxi.com/sanguo/".._tVersionInfo[_nCurrentIndex].path.."/"
	end
	_oResManager:setPackageUrl(pacakgeUrl)
    local nDownloadedNum = _oResManager:getDownloadedNum()
--    _nTotalToDownload = nDataSize - nDownloadedNum
    local tSizeProgressBg = _csProgressBarBg:getContentSize()
	local tSizeSword = _csSword:getContentSize()
	local ratio = nDownloadedNum/_nTotalToDownload
	fnRefreshPercent(math.ceil(ratio*100))
	local nRatioWidth = math.floor(ratio*tSizeProgressBg.width)
	if nRatioWidth > tSizeSword.width/2 then
		_csProgressBar:setTextureRect(CCRectMake(0, 0, nRatioWidth, tSizeProgressBg.height))
		_csSword:setPositionX(nRatioWidth-tSizeSword.width/2)
	end
	local sSizeText
	local nLeftSize = _nTotalToDownload - nDownloadedNum
	if nLeftSize < 10000 then
		sSizeText = "0.01"
	else
		sSizeText = nLeftSize/1000000.0 .. ""
	end
    local nRadixPointNum=0
    local bRadixPointStatus=false
    local sDataSizeText = ""
    for i=1, #sSizeText do
    	local curChar = string.char(string.byte(sSizeText, i))
    	if bRadixPointStatus then
    		nRadixPointNum = nRadixPointNum + 1
    	end
    	if curChar == "." then
    		bRadixPointStatus = true
    	end
    	sDataSizeText = sDataSizeText .. curChar
    	if nRadixPointNum >= 2 then
    		break
    	end
    end
    sDataSizeText = sDataSizeText .. "MB"
    local tArgs={}
    tArgs.text = sDataSizeText
    if nDownloadedNum ~= _nTotalToDownload then
    	addUpdateTipLayer(tArgs)
    else
    	local tSizeProgressBg = _csProgressBarBg:getContentSize()
		local tSizeSword = _csSword:getContentSize()
		_csProgressBar:setTextureRect(CCRectMake(0, 0, tSizeProgressBg.width, tSizeProgressBg.height))
		_csSword:setPositionX(tSizeProgressBg.width-tSizeSword.width/2)
	    fnRefreshPercent("100")
	    _cltCheckVersion:stopAllActions()
		_csProgressBar:stopAllActions()
		local oResManager = ResManager:sharedManager()
    	oResManager:uncompressAndCopy()
    	LoginScene.loginGame()
    end
end

local function fnCheckGameVersionLayer( ... )
	local layer = CCLayer:create()
	local bg = CCSprite:create("images/login/bg.jpg")
	bg:setPosition(ccp(g_winSize.width/2, g_winSize.height/2))
	bg:setAnchorPoint(ccp(0.5, 0.5))
	layer:addChild(bg)
	bg:setScale(g_fBgScaleRatio)

	local logoSprite = CCSprite:create("images/login/logo.png")
	logoSprite:setAnchorPoint(ccp(0.5, 0.5))
	logoSprite:setPosition(ccp(layer:getContentSize().width/2, layer:getContentSize().height*0.8))
	logoSprite:setScale(g_fElementScaleRatio)
	layer:addChild(logoSprite,6)

	local effectSprite = XMLSprite:create("images/login/denglujiemian_zhulin_luoye/denglujiemian_zhulin_luoye")
	effectSprite:setScale(g_fElementScaleRatio)
	effectSprite:setPosition(ccp(layer:getContentSize().width*0.5,layer:getContentSize().height*0.5))
	effectSprite:setAnchorPoint(ccp(0.5,0.5))
	layer:addChild(effectSprite,5)

	local effectSprite2 = XMLSprite:create("images/login/denglujiemian_zhulin/denglujiemian_zhulin")
	-- effectSprite2:setScale(g_fElementScaleRatio)
	effectSprite2:setPosition(ccp(bg:getContentSize().width*0.5,bg:getContentSize().height*0.5))
	effectSprite2:setAnchorPoint(ccp(0.5,0.5))
	bg:addChild(effectSprite2,5)

	local effectSprite3 = XMLSprite:create("images/login/denglujiemian_3nian_tubiao/denglujiemian_3nian_tubiao")
	effectSprite3:setScale(g_fElementScaleRatio)
	effectSprite3:setPosition(ccp(layer:getContentSize().width*0.5,layer:getContentSize().height*0.8))
	effectSprite3:setAnchorPoint(ccp(0.5,0.5))
	layer:addChild(effectSprite3,7)

	-- local bg2 = CCSprite:create("images/login/bg2.png")
	-- bg2:setPosition(ccps(0.5, 0.5))
	-- bg2:setAnchorPoint(ccp(0.5, 0.5))
	-- layer:addChild(bg2)
	-- setAdaptNode(bg2)

-- 进度条背景
	local y_progress = 200
	local csProgressBarBg = CCSprite:create("images/login/progress_bar_bg.png")
	_csProgressBarBg = csProgressBarBg
	csProgressBarBg:setScale(g_fScaleX)
	csProgressBarBg:setAnchorPoint(ccp(0.5, 0))
	csProgressBarBg:setPosition(g_winSize.width/2, y_progress*g_fScaleX)
	local tSizeProgressBg = csProgressBarBg:getContentSize()
	layer:addChild(csProgressBarBg)

	_csProgressBar = CCSprite:create("images/login/progress_bar.png")
	_csSword = CCSprite:create("images/login/sword.png")
	_csSword:setAnchorPoint(ccp(0, 0))
	_csSword:setPosition(0, tSizeProgressBg.height*0.36)
	local tSizeSword = _csSword:getContentSize()
	
	fnRefreshPercent("0")
	_csProgressBar:setTextureRect(CCRectMake(0, 0, tSizeSword.width/2, tSizeProgressBg.height))
	csProgressBarBg:addChild(_csProgressBar)
	csProgressBarBg:addChild(_csSword)

	local cltCheckVersion = CCLabelTTF:create("", g_sFontName, 24)
	_cltCheckVersion = cltCheckVersion
	cltCheckVersion:setScale(g_fScaleX)
	cltCheckVersion:setAnchorPoint(ccp(0.5, 0))
	cltCheckVersion:setPosition(g_winSize.width/2, (y_progress-100)*g_fScaleX)
	layer:addChild(cltCheckVersion)

	fnDownloadRes()
	local function fnLoadingLabelSchedule( ... )
		local text = GetLocalizeStringBy("key_2238")
		if _loading_count > 6 then
			_loading_count = 1
		end
		for i=1, _loading_count do
			text = text .. "."
		end
		cltCheckVersion:setString(text)
		_loading_count = _loading_count + 1
	end

	require "script/utils/extern"
	schedule(cltCheckVersion, fnLoadingLabelSchedule, 0.1)

	return layer
end

function showLoadingLayer(sceneGame)
    if(sceneGame==nil) then
        sceneGame = CCDirector:sharedDirector():getRunningScene()
    else
    	sceneGame:removeFromParentAndCleanup(true)
    end
	local clLoading = fnCheckGameVersionLayer()
	sceneGame:addChild(clLoading)
end

-- 进入装载场景
function enter(pVersionInfo)
	init()
-- 先释放内存资源，防止大数据解压内存不足
	CCFileUtils:sharedFileUtils():purgeCachedEntries()
	BTUtil:unscheduleAll()
	fnReleaseLogicMods()
	
	_tVersionInfo = pVersionInfo
	_oResManager = ResManager:sharedManager()
	
	local sceneGame = CCDirector:sharedDirector():getRunningScene()
    showLoadingLayer(sceneGame)
end


