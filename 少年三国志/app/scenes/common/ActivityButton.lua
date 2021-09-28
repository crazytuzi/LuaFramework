local ActivityButton = class("ActivityButton",function()
    return Button:create()
end)

--@fileName,图片文件
--@fileNameDown Button按下效果,可以不传
--@name 用来regisgerBtnClickEvent(name,func() end)
--parentLayer 父layer
function ActivityButton:ctor(name,parentLayer,fileName,fileNameDown,...)
    self._parentLayer = parentLayer
    self:loadTextureNormal(fileName,UI_TEX_TYPE_LOCAL)
    if fileNameDown ~= nil then
        self:loadTexturePressed(fileNameDown,UI_TEX_TYPE_LOCAL)
    end
    self:setName(name)
    self:setTouchEnabled(true)
end

function ActivityButton:setOnClickEvent(func)
    if self._parentLayer ~= nil then
        self._parentLayer:registerBtnClickEvent(self:getName(),function(widget,event)
           if func ~= nil then
               func(widget)
           end
        end)
    end
end


return ActivityButton

