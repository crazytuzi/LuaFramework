require('TFFramework.utils.TFStringUtils')
require('TFFramework.utils.TFTableUtils')

local ccp = function(x, y) return {x=x, y=y} end
local ccs = function(width, height) return {width=width, height=height} end
local ccc3 = function(r, g, b) return {r=r, g=g, b=b} end
UpdateScene = class("UpdateScene")

function UpdateScene:initUI(panel)

    TF_DEBUG_UPDATE_FLAG = 1
    local winSize = CCDirector:sharedDirector():getWinSize()
    local img = TFImage:create("TFFramework/res/img/DemoBg.png")
    img:setSizeType(TF_SIZE_PERCENT)
    img:setSizePercent(ccp(1, 1))
    img:setAnchorPoint(ccp(0, 0))
    panel:addChild(img, -1024)

	local nInputSize = 60;
	
	local nButtonSize= 60;
    local ipLabel = TFLabel:create()
    ipLabel:setText("ip:")
    ipLabel:setFontSize(nInputSize)
    ipLabel:setPositionType(TF_POSITION_PERCENT)
    ipLabel:setPositionPercent(ccp(0.25, 0.85))
    --panel:addChild(ipLabel)

    local ipTextField = TFTextField:create()
    ipTextField:setPlaceHolder("input ip")
    ipTextField:setPositionType(TF_POSITION_PERCENT)
    ipTextField:setPositionPercent(ccp(0.5, 0.75))
    ipTextField:setFontSize(nInputSize)
    ipTextField:setCursorEnabled(true)
    ipTextField:setCursorColor(ccc3(0xFF, 0, 0))
    if self.resourceUpdate.serverIp then
        ipTextField:setText(self.resourceUpdate.serverIp)
    end
    panel:addChild(ipTextField)


    local portLabel = TFLabel:create()
    portLabel:setText("port:")
    portLabel:setFontSize(nInputSize)
    portLabel:setPositionType(TF_POSITION_PERCENT)
    portLabel:setPositionPercent(ccp(0.6, 0.75))
    --panel:addChild(portLabel)

    local portTextField = TFTextField:create()
    portTextField:setPlaceHolder("input port")
    portTextField:setPositionType(TF_POSITION_PERCENT)
    portTextField:setPositionPercent(ccp(0.5, 0.65))
    portTextField:setFontSize(nInputSize)
    portTextField:setCursorEnabled(true)
    portTextField:setCursorColor(ccc3(0xFF, 0, 0))
    if self.resourceUpdate.serverPort then
        portTextField:setText(self.resourceUpdate.serverPort)
    end
    panel:addChild(portTextField)


    local versionLabel = TFLabel:create()
    versionLabel:setText("svn")
    versionLabel:setFontSize(nInputSize)
    versionLabel:setPositionType(TF_POSITION_PERCENT)
    versionLabel:setPositionPercent(ccp(0.8, 0.65))
    --panel:addChild(versionLabel)

    self.versionTextField = TFTextField:create()
    self.versionTextField:setPlaceHolder("input svn version")
    self.versionTextField:setPositionType(TF_POSITION_PERCENT)
    self.versionTextField:setPositionPercent(ccp(0.5, 0.55))
    self.versionTextField:setFontSize(nInputSize)
    self.versionTextField:setCursorEnabled(true)
    self.versionTextField:setCursorColor(ccc3(0xFF, 0, 0))
    self.versionTextField:setText('0')
    panel:addChild(self.versionTextField)

    self.nowVersionLabel = TFLabel:create()
    self.nowVersionLabel:setText(self.resourceUpdate.clientVersion)
    self.nowVersionLabel:setFontSize(nInputSize)
    self.nowVersionLabel:setPositionType(TF_POSITION_PERCENT)
    self.nowVersionLabel:setPositionPercent(ccp(0.5, 0.4))
    panel:addChild(self.nowVersionLabel)
    self.updateBtn = TFLabel:create()
    self.updateBtn:setTouchEnabled(true)
    self.updateBtn:setText("Update")
    self.updateBtn:setFontSize(nButtonSize + 15)
    self.updateBtn:setPositionType(TF_POSITION_PERCENT)
    self.updateBtn:setPositionPercent(ccp(0.2, 0.3))
    self.updateBtn:setClickScaleEnabled(true)
    panel:addChild(self.updateBtn)
    self.updateBtn:addMEListener(TFWIDGET_CLICK, function()
        self.updating = true
        self.updateBtn:setShaderProgram("GrayShader", true)
        self.updateBtn:setTouchEnabled(false)

        self.resourceUpdate.serverIp        = ipTextField:getText()
        self.resourceUpdate.serverPort      = portTextField:getText()
        self.resourceUpdate.updateVersion   = self.versionTextField:getText()
        self.resourceUpdate.updateFinishCallBack = function( ... )
            self.resourceUpdate:writeVersionInfoToFile()
            self:leave()
        end
        self.resourceUpdate:run()
    end)

    local clearBtn = TFLabel:create()
    clearBtn:setAnchorPoint(ccp(1, 0.5))
    clearBtn:setTouchEnabled(true)
    clearBtn:setPositionType(TF_POSITION_PERCENT)
    clearBtn:setPositionPercent(ccp(1, 0.92))
    clearBtn:setText("Clear")
    clearBtn:setFontSize(nButtonSize + 5)
    clearBtn:setClickScaleEnabled(true)
    panel:addChild(clearBtn)
    clearBtn:addMEListener(TFWIDGET_CLICK, function()
        self.nowVersionLabel:setText(0)
        self.resourceUpdate:clearAllResouces()

        if not self.resourceUpdate:writeVersionInfoToFile() then
            CCMessageBox("fullPath error ","svnConfigFile error")
        end
    end)

    local cancelBtn = TFLabel:create()
    cancelBtn:setTouchEnabled(true)
    cancelBtn:setPositionType(TF_POSITION_PERCENT)
    cancelBtn:setPositionPercent(ccp(0.8, 0.3))
    cancelBtn:setText("Cancel")
    cancelBtn:setFontSize(nButtonSize + 15)
    cancelBtn:setClickScaleEnabled(true)
    panel:addChild(cancelBtn)
    cancelBtn:addMEListener(TFWIDGET_CLICK, function()
        self:leave()
    end)

    local loadBarBgImg = TFImage:create()
    loadBarBgImg:setTexture("TFFramework/res/img/loadingBar.png")
    loadBarBgImg:setPositionType(TF_POSITION_PERCENT)
    loadBarBgImg:setPositionPercent(ccp(0.5, 0.07))
    loadBarBgImg:setSizeType(TF_SIZE_RELATIVE)
    loadBarBgImg:setSizeRelative({width = 0, height = 0.995})
    panel:addChild(loadBarBgImg)

    self.loadBar = TFLoadingBar:create()
    self.loadBar:setTexture("TFFramework/res/img/looding.png")
    self.loadBar:setPositionType(TF_POSITION_PERCENT)
    self.loadBar:setPositionPercent(ccp(0.5, 0.07))
    self.loadBar:setPercent(0)
    self.loadBar:setScale9Enabled(true)
    self.loadBar:setSizeType(TF_SIZE_RELATIVE)
    self.loadBar:setSizeRelative({width = 0, height = 0.995})
    panel:addChild(self.loadBar)

    local percentLabel = TFLabel:create()
    percentLabel:setColor(ccc3(0, 255, 0))
    percentLabel:setAnchorPoint(ccp(1, 0))
    percentLabel:setPositionType(TF_POSITION_PERCENT)
    percentLabel:setPositionPercent(ccp(1, 0.075))
    percentLabel:setText("%0")
    percentLabel:addMEListener(TFWIDGET_ENTERFRAME, function()
        local p = self.loadBar:getPercent()
        percentLabel:setText("%" .. p)          
    end)
    percentLabel:setFontSize(30)
    panel:addChild(percentLabel)

    self.loadingFile = TFLabel:create()
    self.loadingFile:setAnchorPoint(ccp(0.5, 0))
    self.loadingFile:setTextAreaSize({width = winSize.width - 100, height = 30 * 4 + 10})
    self.loadingFile:setTextHorizontalAlignment(kCCTextAlignmentCenter)
    self.loadingFile:setTextVerticalAlignment(kCCVerticalTextAlignmentBottom)
    self.loadingFile:setText("")
    self.loadingFile:setFontSize(30)
    self.loadingFile:setPositionType(TF_POSITION_PERCENT)
    self.loadingFile:setPositionPercent(ccp(0.5, 0.08))
    panel:addChild(self.loadingFile)
    self.updating = false


	if(TFFileUtil:existFile('TFFramework/TFVersion.lua')) then
		local msg = require('TFFramework.TFVersion')
		if msg then
	    	local verLabel = TFLabel:create()
	    	verLabel:setText("©"..msg.__ENGINE_VERSION__)
	    	verLabel:setPositionType(TF_POSITION_PERCENT)
	    	verLabel:setPositionPercent(ccp(0.5, 0))
	    	verLabel:setAnchorPoint(ccp(0.5,0.0))
	    	verLabel:setFontSize(nInputSize/2)
	    	panel:addChild(verLabel)
    	end
    end

    DEBUG = DEBUG or 0
    self.logSwitch = TFLabel:create()
    self.logSwitch:setAnchorPoint(ccp(0, 0.5))
    self.logSwitch:setFontSize(nButtonSize + 5)
    if DEBUG == 0 then 
        self.logSwitch:setText("Debug面板: 关闭")
    else 
        self.logSwitch:setText("Debug面板: 开启")
    end
    self.logSwitch:setPositionType(TF_POSITION_PERCENT)
    self.logSwitch:setPositionPercent(ccp(0, 0.92))
    self.logSwitch:setTouchEnabled(true)
    self.logSwitch:addMEListener(TFWIDGET_CLICK, function()
        if DEBUG == 1 then
            self.logSwitch:setText("Debug面板: 关闭")
            DEBUG = 0
        else
            self.logSwitch:setText("Debug面板: 开启")
            DEBUG = 1
        end
    end)
    panel:addChild(self.logSwitch)

    local inputVersion = 0
    if tblSvn then
        inputVersion  = tblSvn.inputVersion or "0"
        self.versionTextField:setText(inputVersion)
    end

    self.resourceUpdate.updateFileCallBack = function(filepath, percent)
        local perCent = 100 * percent
        self.loadingFile:setText(filepath)
        self.loadBar:setPercent(perCent)
    end
    TFLuaOcJava.disableDeviceSleep(true)
end

function UpdateScene:run(callBackFunc)
    print("run")
    self.callBackFunc = callBackFunc
    self.scene = CCScene:create()
    CCDirector:sharedDirector():replaceScene(self.scene)
    self.mainPanel  = TFPanel:create()
    self.mainPanel:setSizeType(TF_SIZE_PERCENT)
    self.mainPanel:setSizePercent(ccp(1.0,1.0))
    self.scene:addChild(self.mainPanel)

    self.resourceUpdate = require('TFFramework.update.ResourceUpdate')
    self.resourceUpdate:init()

    self:initUI(self.mainPanel)
    if not self.resourceUpdate.needShow then 
        self:leave()
    end
end


function UpdateScene:leave()
    TFLuaOcJava.disableDeviceSleep(false)
    self.callBackFunc()
end


return UpdateScene
