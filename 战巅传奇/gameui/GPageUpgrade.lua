GPageUpgrade = class("GPageUpgrade", function()
    return display.newScene("GPageUpgrade")
end)


function requireAll()
   -- print("开始引用游戏内的文件")
    package.loaded["gameui.LoadScript"] = nil
    require("gameui.LoadScript")
end

function GPageUpgrade:ctor()

end

function GPageUpgrade:onEnter()
	print("GPageUpgrade:onEnter() start")
    --加载texture和plist， 第一个场景不能异步加载， 否则会有黑屏
    cc.CacheManager:getInstance():loadImage("ui/sprite/GPageUpgrade.png")
    cc.SpriteFrameCache:getInstance():addSpriteFrames("ui/sprite/GPageUpgrade.plist")
	print("GPageUpgrade:onEnter() addSpriteFrames end")


    self._widgetUI = GUIAnalysis.load("ui/layout/GPageUpgrade.uif")
    if self._widgetUI then
        self._widgetUI:size(cc.size(display.width, display.height)):align(display.CENTER, display.cx, display.cy)
        self:addChild(self._widgetUI)

		local startNum = 1
		local function startShowBg()
			local imgBg = self._widgetUI:getWidgetByName("Image_Bg"):align(display.CENTER, display.cx, display.cy)
			imgBg:loadTexture("ui/image/img_welcome_bg_"..startNum..".png"):scale(cc.MAX_SCALE)
			startNum= startNum+1
			if startNum >=1 then
				startNum =1
			end
		end
		startShowBg()  --先显示一下，否则会黑屏一下
		--self._widgetUI:runAction(cca.repeatForever(cca.seq({cca.delay(0.25),cca.cb(startShowBg)}),tonumber(4)))

        self.panelBar = self._widgetUI:getWidgetByName("Panel_1"):align(display.CENTER, display.cx, display.height * 0.12)
        self.labLoading = self._widgetUI:getWidgetByName("Text_Loading")
        self.loadingBar = self.panelBar:getWidgetByName("LoadingBar")
        self.loadingBar:setPercent(0)
        self.panelBar:setVisible(false)

        self.labInit = self._widgetUI:getWidgetByName("Text_Init"):align(display.CENTER, display.cx, display.height * 0.12):setVisible(true)
        self.labInit:setString("正在初始化，若持续30秒无反应请重启...")
		
		self._widgetUI:getWidgetByName("Image_Bg"):runAction(cca.repeatForever(cca.seq({cca.delay(5),cca.cb(GameCCBridge.setPlatfromListener)}),tonumber(1)))

    end

    --self:checkUpdate()

    if device.platform=="windows" then
        self:successCallBack()
        -- local url = "http://192.168.231.89/";
        -- local platformid = 888;
        -- local zipfilename = "update";
        -- local versionname = "version2018.manifest";
        -- local projectname = "project2018.manifest";
        -- self:updateGame(url, platformid, zipfilename, versionname, projectname);
    else
        --self:checkUpdate()
    end
end

function GPageUpgrade:onExit()
	
end

function GPageUpgrade:checkUpdate(  )
    if (device.platform=="android" or device.platform=="ios") then
        self:getUpdateVersion()
    else
        self:successCallBack()
    end
end

function GPageUpgrade:getUpdateVersion( )
	print("GPageUpgrade:getUpdateVersion() start")
	self._widgetUI:getWidgetByName("Image_Bg"):stopAllActions()
    local update_url=""
    if device.platform=="android" or device.platform=="ios" then
        update_url=GameCCBridge.getCenterUrl().."getVersion?platform="..GameCCBridge.getPlatformId()
    end
    print("--------------------更新地址:", update_url)

    if self.labInit then self.labInit:setString("正在获取版本更新.") end
    local http=cc.XMLHttpRequest:new()
    http.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    http:open("GET", update_url)
    local function callback()
		if self.labInit then self.labInit:setString("正在获取版本更新..") end
        local state=http.status
        --print("-------state = "..state.."  data: "..http.response)
        if state==200 then
            local response=http.response
            local json=string.gsub(GameUtilBase.unicode_to_utf8(response),"\\","")
            json=GameUtilBase.decode(json)
            if type(json)=="table" and json.result and GameCCBridge then
                if tonumber(json.status) == 1 then
                    local info = json.result
                    if (device.platform=="android" or device.platform=="ios") then
                        self:updateGame(info[1]['url'], info[1]['platformid'], info[1]['zipfilename'], info[1]['versionname'], info[1]['projectname'])
                    end
                else
                    self:successCallBack()
                end
			else
				self.labInit:setString("检查更新失败,请重试..")
            end
        else
            print("获取包体下载路径失败")
            if self.labInit then self.labInit:setString("获取版本更新失败") end
            self:getUpdateVersion()
        end
    end
    http:registerScriptHandler(callback)
    http:send()
end

function GPageUpgrade:updateGame( url, platformid, zip_file_name, version_file_name, project_file_name )
	if self.labInit then self.labInit:setString("正在获取版本更新...") end
    local params = {}

    params.onFindNewVersion = function ( am )
		if self.labInit then self.labInit:setString("正在获取版本更新....") end
        self:findNewVersionCallBack(am)
    end

    params.onProgress = function (per)
		if self.labInit then self.labInit:setString("正在获取版本更新....") end
       self:progressCallBack(per)
    end

    params.onSuccess = function ()
		if self.labInit then self.labInit:setString("正在获取版本更新....") end
        self:successCallBack()
    end

    params.onAlreadyUpdate = function ()
		if self.labInit then self.labInit:setString("正在获取版本更新....") end
        self:successCallBack()
    end

    params.onError = function (msg)
		if self.labInit then self.labInit:setString(msg) end
		if self.labInit then self.labInit:setString(msg) end
       self:errorCallBack(msg);
    end

    local rootpath = "legend";
    local appVersion = GameCCBridge.getConfigString("version");
    if (appVersion) then
        rootpath = rootpath..appVersion.."/";
    end

    local packageUrl = url..platformid.."/"
    params.rootPath = rootpath;
    params.packageUrl = packageUrl
    params.updateName = zip_file_name   -- 解压后的文件夹名称
    params.versionFileName = version_file_name
    params.projectFileName = project_file_name;
    params.localManifest = "resource/config/update.manifest"
    GameUpdate.create():update(params)
end

function GPageUpgrade:findNewVersionCallBack( am, totalSize )
    print("-----------findNewVersionCallBack--------------")
    --发现有新版本
    am:update();
    self.panelBar:setVisible(true)
    self.labInit:setVisible(false)
end
------------------------------------------
-------        加载进度条      --------
------------------------------------------
function GPageUpgrade:progressCallBack( per )
    local currPer = math.floor(per)
    self.loadingBar:setPercent(currPer)

    if (math.floor(currPer) ~= 100) then
        local str = string.format("%.2f", per)
        self.labLoading:setString("正在下载文件 "..str..'%')
    else
        self.labLoading:setString("正在解压文件...");
    end
end
------------------------------------------
-------        加载完成部分      ---------
------------------------------------------
function GPageUpgrade:successCallBack( )
	if self.labInit then self.labInit:setString("正在初始化客户端脚本....") end
    requireAll()
	if self.labInit then self.labInit:setString("正在设置网关....") end
    if GameCCBridge then
        GameBaseLogic.gameKey=GameCCBridge.getAccount()
        GameBaseLogic.loginKey=GameCCBridge.getToken()
        local centerurl=GameCCBridge.getCenterUrl()
        if centerurl then --这个地方防止getCenterUrl获取为空（某些渠道的init可能漏加这个）
            GameBaseLogic.centerUrl=centerurl.."/"
        end
    end
	if self.labInit then self.labInit:setString("正在加载列表资源....") end

    -- asyncload_frames("ui/sprite/GPageAnnounce",".png",function ()
    --     display.replaceScene(GPageAnnounce.new())
    -- end,self)

    asyncload_frames("ui/sprite/GPageServerList",".png",function ()
		if self.labInit then self.labInit:setString("正在加载公共资源....") end
		
		asyncload_frames("ui/sprite/GUINewCommon",".png",function ()
			self.labInit:setString("即将进入切换登录....")
			display.replaceScene(GPageSignIn.new()) --登陆流程
		end)
		
    end)

end
------------------------------------------
-------        加载出错部分      ----------
------------------------------------------
function GPageUpgrade:errorCallBack( msg )
    self.labLoading:setString(msg)
end


return GPageUpgrade
