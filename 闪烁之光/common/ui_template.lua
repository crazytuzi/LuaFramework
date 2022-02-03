-- Created by IntelliJ IDEA.
-- User: lfl 1204825992@qq.com
-- Date: 2014/6/24
-- Time: 12:22
-- 文件功能：作为模板使用

UITemplate = UITemplate or BaseClass()

function UITemplate:__init()
    self.template_name = ""
    self.resource_path = nil --要释放的资源路径
    self.is_opening = false
    self.___enabled = true
    self.___visible = true
end

function UITemplate:__delete()
    if self.root_wnd and (not tolua.isnull(self.root_wnd)) then
        self.root_wnd:removeAllChildren()
        self.root_wnd:removeFromParent()
        if self:getReferenceCount() > 1 then
            self.root_wnd:release()
        end
        self.root_wnd = nil
    end
    self.is_opening = false

    self:removeTemplate()
end

function UITemplate:InitTemplateInfo(parent_wnd, template_name)
    self.is_opening = true
    if template_name ~= nil then
       self.template_name = template_name
    end

    local clone_temp
    if not self:__isClone() then  --不可克隆
        clone_temp = ccs.GUIReader:getInstance():widgetFromJsonFile(self.template_name)
        self:addTemplate(clone_temp)
    end
    self.root_wnd = self:__clone() --ccs.GUIReader:getInstance():widgetFromJsonFile(self.template_name)
    self.root_wnd:retain()
    self:registerNodeScriptHandler()

    self:setParent( parent_wnd )
end


function UITemplate:registerNodeScriptHandler()
    local function onNodeEvent(event)
        if "enter" == event then
            if self["onEnter"] then
                self:onEnter()
            end
        elseif "exit" == event then
            if self["onExit"] then
                self:onExit()
            end
        end
    end
    self.root_wnd:registerScriptHandler(onNodeEvent)
end

function UITemplate:setParent( parent )
    if self.root_wnd and (not tolua.isnull(self.root_wnd)) and self.root_wnd:getParent()then
       self.root_wnd:removeFromParent()
    end
    if parent ~= nil and self.root_wnd ~= nil then
        parent:addChild(self.root_wnd)
    end
end

function UITemplate:setEnabled( bool )
    if self.___enabled == bool or self.root_wnd == nil then return end
    self.root_wnd:setEnabled(bool)
    self.___enabled = bool
end

function UITemplate:setVisible( bool )
    if self.___visible == bool or self.root_wnd == nil then return end
    self.root_wnd:setVisible(bool)
    if bool == false then
        self.___enabled = self.root_wnd:isEnabled()
        self.root_wnd:setEnabled(false)
    else
        self.root_wnd:setEnabled(self.___enabled)
    end
end

function UITemplate:getVisible( )
    return self.___visible
end

function UITemplate:getEnabled( )
    return self.___enabled
end


function UITemplate:getReferenceCount()
    return self.root_wnd:getReferenceCount()
end

UITemplate.template_list = {} --保存template的ui部分
UITemplate.template_count = {}
function UITemplate:addTemplate(root)
    if not UITemplate.template_count[self.template_name] then
        UITemplate.template_count[self.template_name] = 1
        UITemplate.template_list[self.template_name] = root
        root:retain()
    else
        UITemplate.template_count[self.template_name] = UITemplate.template_count[self.template_name] + 1
    end
end

function UITemplate:removeTemplate()
    if UITemplate.template_count[self.template_name] then
        UITemplate.template_count[self.template_name] = UITemplate.template_count[self.template_name] - 1
        if UITemplate.template_count[self.template_name] <= 0 then
            local item = UITemplate.template_list[self.template_name]
            if item and (not tolua.isnull(item)) then
                if item["getReferenceCount"] and item:getReferenceCount() > 1 then
                    UITemplate.template_list[self.template_name]:release()
                end
            end
            UITemplate.template_list[self.template_name] = nil
            UITemplate.template_count[self.template_name] = nil
        end
    end
end

function UITemplate:__clone()
    return UITemplate.template_list[self.template_name]:clone()
end

function UITemplate:__isClone()
    if not UITemplate.template_list[self.template_name] then
        return false
    end
    if not UITemplate.template_count[self.template_name] then
        return false
    end
    return true
end

function UITemplate:addChild( diplayerObj )
    self.root_wnd:addChild(diplayerObj)
end

function UITemplate:removeChild( diplayerObj )
    self.root_wnd:removeChild(diplayerObj)
end

function UITemplate:removeAllChildren()
    self.root_wnd:removeAllChildren()
end

function UITemplate:setPosition(pos)
    self.root_wnd:setPosition(pos)
end

function UITemplate:getPosition()
    self.root_wnd:getPosition()
end
