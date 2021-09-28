
local TestProxyLayer = class("TestProxyLayer",UFCCSModelLayer)
local storage = require("app.storage.storage")


function TestProxyLayer.create()
   return TestProxyLayer.new("ui_layout/platform_TestProxyLayer.json", require("app.setting.Colors").modelColor)
end



function TestProxyLayer:ctor(json, color)
    self.super.ctor(self)
    self._loginCallback = nil
    self:_initViews()
end


 

function TestProxyLayer:setLoginCallback(callback)
    self._loginCallback = callback
end


function TestProxyLayer:_initViews()
  
    self:registerBtnClickEvent("Button_ok",  function() 
         local txt = self:getTextFieldByName("TextField_userName"):getStringValue()
		 if txt == "" then
			G_MovingTip:showMovingTip("用户名不能为空")
			return
		 end
         if txt ~= "" then

            -- local badchar = string.match(txt,"([^%w]+)")
            -- if badchar ~= nil then
            --     G_MovingTip:showMovingTip("请只输入英文和数字,不超过10个字符")
            --     return
            -- end

            -- if string.len(txt) > 10 then
            --     G_MovingTip:showMovingTip("请只输入英文和数字,不超过10个字符")
            --     return
            -- end
            local params = {}
            local userName = txt
            local password = self:getTextFieldByName("TextField_pwd"):getStringValue()
			if userName == "" then
				G_MovingTip:showMovingTip("用户名不能为空")
				return
			end
			if password == "" then
				G_MovingTip:showMovingTip("密码不能为空！")
				return
			end
			
			if string.len(userName) < 6 then
				G_MovingTip:showMovingTip("账号长度不符合")
				return
			end
			if string.len(password) < 6 then
				G_MovingTip:showMovingTip("密码长度不符合")
				return
			end
			
            if #txt > 50 then
                local tokenDataStr = require("framework.crypto").decodeBase64(txt)
                local tokenData = json.decode(tokenDataStr)
                if tokenData ~= nil then
                    --uuid
                    params.uuid = tokenData.uuid 
                    local ps = string.split(tokenData.uuid, "_")
                    
                    params.opId = table.remove(ps,1)
                    params.uid = table.concat(ps, "_")

                    params.serverId = tokenData.serverId 
                    params.serverName = tokenData.serverName 
                    params.gateway = tokenData.gateway
                end
            else
                params.uid = txt 
                params.uuid = G_PlatformProxy:getOpId() .. "_" .. txt
            end
            
			
			local request=uf_netManager:createHTTPRequestGet("http://192.168.221.128:3880/account.php?userName=" .. userName.. "&password=" .. password,function(event)
				local request = event.request
				
				local servers = request:getResponseString()
				print("servers:" .. servers)
				local tables=json.decode(servers)
				
				G_MovingTip:showMovingTip(tables.msg)
				if tables.errorCode == 0 then
					self:startLoginPlatform(params)
				end
				end
			)
			request:start()
         end
    end)

end

function TestProxyLayer:onUpdateUserName()
    local lastUserName = G_PlatformProxy:getLoginUserName()
    if lastUserName == "" then
        --不设置标题
        self:getTextFieldByName("TextField_userName"):setText("u" .. tostring(math.random(1, 9999999)))
    else
        self:getTextFieldByName("TextField_userName"):setText(lastUserName)
    end
end

function TestProxyLayer:startLoginPlatform( params )
    --不需要跟服务器交互...因为这个是假平台, 直接认为登陆成功
    self:onUpdateUserName()
    --G_PlatformProxy:setUid(params.uid)
    if self._loginCallback ~= nil then
		print("直接认为登陆成功")
        G_PlatformProxy:setUid(params.uid)
        G_PlatformProxy:setYzuid(params.uuid)
        self._loginCallback(params)
    end
    self:close()
end


---销毁函数
function TestProxyLayer:onLayerUnload( ... )
    -- uf_eventManager:dispatchEvent(G_EVENTMSGID.EVENT_UPDATE_UID, nil, false) 

    uf_eventManager:removeListenerWithTarget(self)
end


return TestProxyLayer
