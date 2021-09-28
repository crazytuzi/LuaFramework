local ServerLockLayer = class("ServerLockLayer",UFCCSModelLayer)
ServerLockLayer.cachePassword = ""
function ServerLockLayer.create(callback)
   local layer =  ServerLockLayer.new("ui_layout/login_ServerLockLayer.json", require("app.setting.Colors").modelColor)
   layer:setCallback(callback)
   return layer
end

function ServerLockLayer:ctor()
    self.super.ctor(self)
    
    self._callback = nil
    self:_initViews()
end

function ServerLockLayer:setCallback(callback)
    self._callback = callback
end
    

function ServerLockLayer:_onSelect(server)
    if self._callback ~= nil then
        self._callback(server)
    end
    self:animationToClose()
end
    
function ServerLockLayer:_addNum(n) 
    local str = self._labelPassword:getStringValue()

    if #str < 4 then
        str = str .. tostring(n)
        self._labelPassword:setText(str)
    end

   ServerLockLayer.cachePassword = str 

    if #str == 4 then
        if self._callback then
            self._callback(str)
        end
    end
end

function ServerLockLayer:_initViews() 
    self._labelPassword =  self:getLabelByName("Label_password")

    for num =1,9 do 
        self:registerBtnClickEvent("Button_" .. num,    
            function ()
                self:_addNum(num)
            end

        )

    end   

end


function ServerLockLayer:onLayerUnload()
    self._callback = nil
    uf_eventManager:removeListenerWithTarget(self)
end





return ServerLockLayer


