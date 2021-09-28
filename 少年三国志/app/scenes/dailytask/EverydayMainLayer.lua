
local EverydayMainLayer = class("EverydayMainLayer",UFCCSNormalLayer)

function EverydayMainLayer.create(...)
    return require("app.scenes.dailytask.EverydayMainLayer").new("ui_layout/dailytask_MainLayer.json", ...)
end

--[[
    self._checkType 选中类型
    self._checkType = 1
    self._checkType = 2 
]]
function EverydayMainLayer:ctor(json,checkType,...)
    self._checkType = checkType and checkType or 1
    self._tasklistLayer = nil
    self.super.ctor(self, ...)
    self._tabs = require("app.common.tools.Tabs").new(2, self,self._checkedCallBack, self._uncheckedCallBack) 
    self:registerBtnClickEvent("Button_return", function()
         uf_sceneManager:replaceScene(require("app.scenes.mainscene.MainScene").new())
    end)
end

function EverydayMainLayer:onLayerEnter()

end
function EverydayMainLayer:onLayerLoad(...)
    self:registerKeypadEvent(true)

    self:_checkTaskTip(true)
    self:_checkAchieveTip(true)
end
function EverydayMainLayer:onBackKeyEvent()
    uf_sceneManager:replaceScene(require("app.scenes.mainscene.MainScene").new())
    return true
end

function EverydayMainLayer:_initTabs()
    self._tabs:add("CheckBox_list", self:getPanelByName("Panel_content1"), "Label_renwu") --delay load
    self._tabs:add("CheckBox_list2", self:getPanelByName("Panel_content2"), "Label_chengjiu")  -- delay load

    self._tabs:checked(self._checkType == 1 and "CheckBox_list" or "CheckBox_list2")
end




function EverydayMainLayer:_checkedCallBack(btnName)
    if btnName == "CheckBox_list" then
        self:_resetTaskListView()
        self:_checkTaskTip(false)
        self:_checkAchieveTip(true)
    elseif btnName == "CheckBox_list2" then
        self:_resetAchievementListView()
        self:_checkTaskTip(true)
        self:_checkAchieveTip(false)
    end
end

function EverydayMainLayer:_resetTaskListView()
    if self._tasklistLayer == nil then
        self._tasklistLayer = require("app.scenes.dailytask.DailytaskMainLayer").create()
        self:getPanelByName("Panel_content1"):addNode(self._tasklistLayer)
        local size = self:getPanelByName("Panel_content1"):getContentSize()
        self._tasklistLayer:adapterWithSize(CCSizeMake(size.width, size.height))
        self._tasklistLayer:adapterLayer()
    end 
end

function EverydayMainLayer:_resetAchievementListView()
    if self._achievementlistLayer == nil then
        self._achievementlistLayer = require("app.scenes.dailytask.AchievementLayer").create()
        self:getPanelByName("Panel_content2"):addNode(self._achievementlistLayer)
        local size = self:getPanelByName("Panel_content2"):getContentSize()
        self._achievementlistLayer:adapterWithSize(CCSizeMake(size.width, size.height))
--        self._achievementlistLayer:adapterLayer()
    end 
end

function EverydayMainLayer:_checkTaskTip(enable)
    local show = enable and G_Me.dailytaskData:hasNew()
    self:getImageViewByName("Image_composeTips1"):setVisible(show)
end

function EverydayMainLayer:_checkAchieveTip(enable)
    local show = enable and G_Me.achievementData:hasNew()
    self:getImageViewByName("Image_composeTips2"):setVisible(show)
end

function EverydayMainLayer:adapterLayer()

    self:adapterWidgetHeight("Panel_content1", "Panel_checkbox", "", 14, 0)
    self:adapterWidgetHeight("Panel_content2", "Panel_checkbox", "", 14, 0)
    -- self:adapterWidgetHeight("Panel_bg", "Panel_checkbox", "", 0, 0)

    if self._tasklistLayer ~= nil then
        self._tasklistLayer:adapterLayer()
    end
    
    if self._achievementlistLayer ~= nil then
        self._achievementlistLayer:adapterLayer()
    end
    
    if self._tabs:getCurrentTabName() == "" then
       self:_initTabs() 
    end
    
end


function EverydayMainLayer:onLayerExit()
    uf_eventManager:removeListenerWithTarget(self)
    self.super:onLayerExit()
end


return EverydayMainLayer
