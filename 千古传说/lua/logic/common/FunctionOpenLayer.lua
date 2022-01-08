
--功能开放

local FunctionOpenLayer = class("FunctionOpenLayer", BaseLayer)

function FunctionOpenLayer:ctor(data)
    self.super.ctor(self, data)
    self.data = data
    self:init("lua.uiconfig_mango_new.common.FunctionOpenLayerNew")
    self.first = true
    -- self.textLabel:setText(data.name.."已解锁,点击跳转将会引导您熟悉该玩法。")
end

function FunctionOpenLayer:initUI(ui)
	self.super.initUI(self, ui)

    self.okBtn = TFDirector:getChildByPath(ui, 'okBtn')
    self.cancelBtn = TFDirector:getChildByPath(ui, 'cancelBtn')
    self.txt_meitubiao = TFDirector:getChildByPath(ui, 'txt_meitubiao')
    self.txt_youtubiao = TFDirector:getChildByPath(ui, 'txt_youtubiao')
    self.icon_main = TFDirector:getChildByPath(ui, 'icon_main')
    self.img_biaoti = TFDirector:getChildByPath(ui, 'Img_biaoti')
end

function FunctionOpenLayer:onShow()
    local data = self.data
    if data.pic then
        self.txt_meitubiao:setVisible(false)
        self.txt_youtubiao:setVisible(true)
        self.icon_main:setVisible(true)
        self.txt_youtubiao:setText(data.des)
        self.icon_main:setTexture(data.pic)
    else
        self.txt_meitubiao:setVisible(true)
        self.txt_youtubiao:setVisible(false)
        self.icon_main:setVisible(false)
        self.txt_meitubiao:setText(data.des)
    end
    data.title_id = data.title_id or 0
    self.img_biaoti:setTexture("ui_new/guide/"..data.title_id..".png")
    if self.first == true then
        self.ui:runAnimation("zhushijianzhou",1)
        self.first = false
    end
end
function FunctionOpenLayer:registerEvents()
    self.super.registerEvents(self)
    self.okBtn:addMEListener(TFWIDGET_CLICK, audioClickfun(function() PlayerGuideManager:BeginFunctionOpenGuide() end), 1)
    self.cancelBtn:addMEListener(TFWIDGET_CLICK, audioClickfun(function()
        PlayerGuideManager:saveFunctionOpenGuide(self.data.id)
        AlertManager:close()
        end), 1)

    self.ui:setAnimationCallBack("zhushijianzhou", TFANIMATION_END, function()
        self.ui:runAnimation("hushan",-1)
        end)
end

function FunctionOpenLayer:removeUI()
	self.super.removeUI(self)
    self.first = true
end

return FunctionOpenLayer
