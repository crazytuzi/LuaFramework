
local LoginMainLayer = class ("LoginMainLayer", UFCCSNormalLayer)
local storage = require("app.storage.storage")

local EffectNode = require "app.common.effects.EffectNode"

local showBrowsered = false;

function LoginMainLayer.create( )   
    return LoginMainLayer.new("ui_layout/login_LoginMainLayer.json") 
end


local function getUpgradeDir()

    local upgradeFolder = CCFileUtils:sharedFileUtils():getWritablePath()
    upgradeFolder = upgradeFolder.. "upgrade/"

    return upgradeFolder
end

function LoginMainLayer.remove_snz_file()
    local dir = getUpgradeDir()
    if G_NativeProxy.platform ~= "wp8" then
        require 'lfs'
        for file in lfs.dir(dir) do
            local fullfile = dir .. "/" .. file
            if lfs.attributes(fullfile,"mode") == "file"  and string.find(file, "sgz") == (#file - 2) then 
                os.remove(fullfile)
            end
        end
    else
        local tempDir = CCFileUtils:sharedFileUtils():getWritablePath().."/temp/"
        CCFileUtils:sharedFileUtils():removeDirectory(tempDir)
    end

end


function LoginMainLayer:ctor( ... )
    self.super.ctor(self, ...)
    if patchMe and patchMe("login", self) then return end  

    self:enableLabelStroke("Label_protocal_tip", Colors.strokeBrown, 1 )

    LoginMainLayer.remove_snz_file()

    GlobalFunc.uploadLog({{event_id="OpenLogin"}})
    GlobalFunc.save_event_log("OpenLogin")

    self:registerBtnClickEvent("Button_selectServer",function()

        G_ServerList:checkUpdateList(

            function() 
                local layer = require("app.scenes.login.ServerListLayer").create()
                layer:setCallback(
                    function(server)
                         G_PlatformProxy:setLoginServer(server)
                         self:onUpdateServer()
                         
                    end
                )
                self:addChild(layer)
                layer:showAtCenter(true)

            end
        )
        
    end)
    
 
    self:registerBtnClickEvent("Button_inputUser", G_PlatformProxy:createLockCall(  function () G_PlatformProxy:loginPlatform() end    ) )
    
    self:registerBtnClickEvent("Button_login",   function(...) self:_onClickEnterGame() end)



    
    self:registerCheckboxEvent("CheckBox_Protocol", function ( ... )
        self:_onProtocalCheck(...)
    end)
    self:registerWidgetClickEvent("Label_protocal_tip", function ( ... )
        self:_onShowProtocal(...)
    end)
    --self:getLabelByName("Label_serverName"):createStroke(Colors.strokeBrown,1)

    --self:getLabelByName("Label_userName"):createStroke(Colors.strokeBrown,1)
    --self:getLabelByName("Label_titleServer"):createStroke(Colors.strokeBrown,1)

    
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_UPDATE_UID, handler(self,self.onUpdateUserName), self)
    uf_eventManager:addEventListener(G_EVENTMSGID.EVENT_UPDATE_SERVER_LIST, handler(self,self.onUpdateServer), self)

    



    self:showWidgetByName("Panel_login", false)
    self:showWidgetByName("Label_init", false)
    


    self:getLabelByName("Label_init"):createStroke(Colors.strokeBrown,1)
    if not IS_HEXIE_VERSION then
        local effect =  EffectNode.new("effect_main3_interface")
                
        --local effect  = EffectNode.new("effect_main_interface")
        effect:play()
        effect:setPosition(ccp(display.cx, display.cy))
        self:getRootWidget():addNode(effect)
    end
    
    --用户名
    self:onUpdateUserName()
    
    --获取服务器列表
    G_ServerList:init()
    
    ----默认服务器名字
    self:onUpdateServer()


    local function showLogin() 
        self:showWidgetByName("Panel_login", true)


        local popupNotice = G_Setting:get("popupNotice")
        if popupNotice and popupNotice ~= "" then


            MessageBoxEx.showOkMessage("", popupNotice )
            
        else
        end

        G_PlatformProxy:beforeLogin()

    end



    self:_showGonggao(showLogin)
    
end

function LoginMainLayer:testAudio( ... )
    require("app.scenes.login.AudioTest")
    for key, value in pairs(AudioTestSrc) do 
        local name = "audio/"..(value)
        __Log("name=%s", name)
        G_SoundManager:playBackgroundMusic(name)

    end
end

function LoginMainLayer:_onClickEnterGame(  )
    --if 1 then 
      --  return G_SoundManager:playBackgroundMusic("voice/J3_nan_shaosha.mp3")
    --end
	
    local lastUserName = G_PlatformProxy:getDefaultRoleName()
	
	print("lastnamewwwwwwwwwwww=" .. lastUserName)
	if lastUserName == "" then
		G_PlatformProxy:loginPlatform()
	else
		local server = G_PlatformProxy:getLoginServer()
		if server and server.locked and require("app.scenes.login.ServerLockLayer").cachePassword ~=  G_Setting:get("server_lock_password") then
		 
			
			lockLayer = require("app.scenes.login.ServerLockLayer").create(function(password) 
				lockLayer:removeFromParentAndCleanup(true)
				if password == G_Setting:get("server_lock_password") then
				 
					G_PlatformProxy:enterGame()
				end

			end)
			self:addChild(lockLayer)
			lockLayer:showAtCenter(true)

		else
			local func = G_PlatformProxy:createLockCall(  function () G_PlatformProxy:enterGame() end    ) 
			func()
		end
	end
end

function LoginMainLayer:_onProtocalCheck( checkbox, checkType, isCheck )
    self:enableWidgetByName("Button_login", isCheck)
end

function LoginMainLayer:_onShowProtocal( ... )
    if G_NativeProxy.platform == "ios" then
        if G_NativeProxy.openURL then 
            G_NativeProxy.openURL(G_Setting:get("open_user_protocal"))
        end
    elseif G_NativeProxy.platform == "android" then
        if G_NativeProxy.openInnerUrl then 
            G_NativeProxy.openInnerUrl(G_Setting:get("open_user_protocal"),G_lang:get("LANG_USER_AGREEMENT"))
        end
    elseif G_NativeProxy.platform == "wp8" or G_NativeProxy.platform == "winrt" then
        if G_NativeProxy.openInnerUrl then 
            G_NativeProxy.openInnerUrl(G_Setting:get("open_user_protocal"),G_lang:get("LANG_USER_AGREEMENT"))
        end
    end
end

function LoginMainLayer:_showGonggao(callback)
    if showBrowsered then
        callback()
        return
    else
        showBrowsered = true
        
    end

    if G_PlatformProxy:showGonggao(callback) then
    else
        callback()
    end


end










function LoginMainLayer:onLayerEnter( ... )
    -- self:showWidgetByName("Panel_login", false)
    -- self:showWidgetByName("Label_init", true)
    



    local versionName = GAME_VERSION_NAME 
    local localVersionName = getLocalVersionName()
    if localVersionName ~= "" then
        versionName = versionName .."(".. localVersionName..")"
    end
    
    self:attachImageTextForBtn("Button_login", "Image_12")
    self:setSelectStatus("CheckBox_Protocol", true)

    self:showTextWithLabel("Label_version", versionName)
end

function LoginMainLayer:_clearUpdateTimer()
    if self._updateTimer then
        GlobalFunc.removeTimer(self._updateTimer )
        self._updateTimer = nil
    end

end
function LoginMainLayer:_addUpdatetimer()

    self:_clearUpdateTimer()
    self._updateTimer = GlobalFunc.addTimer(5, function() 
        self:onUpdateServer()
    end)
end
function LoginMainLayer:onUpdateServer()
    local server = G_PlatformProxy:getLoginServer()
    if server ~= nil then
        self:getLabelByName("Label_serverName"):setText(server.name)
        require("app.scenes.login.ServerListLayer").updateServerIcon(self:getImageViewByName("Image_icon"), server.status)

      
        self:_clearUpdateTimer()
    else
        self:getLabelByName("Label_serverName"):setText(G_Setting:get("no_server_txt"))
        self:getImageViewByName("Image_icon"):setVisible(false)

        self:_addUpdatetimer()
    end

    

end



function LoginMainLayer:onUpdateUserName()
   local lastUserName = G_PlatformProxy:getLoginUserName()
   print("lastname=" .. lastUserName)
   if lastUserName == "" then
       --不设置标题
       self:getLabelByName("Label_userName"):setText(G_lang:get("LANG_NOT_LOGINED"))

   else
       self:getLabelByName("Label_userName"):setText(lastUserName)
   end
end

function LoginMainLayer:onLayerUnload()
    uf_eventManager:removeListenerWithTarget(self)
    self:_clearUpdateTimer()
end
return LoginMainLayer
