-- --------------------------------------------------------------------
-- 编辑弹幕面板
-- 
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @editor: shiraho@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2017-xx-xx
-- --------------------------------------------------------------------
BarrageEditView = BarrageEditView or BaseClass(BaseView)

local controller = BarrageController:getInstance()

function BarrageEditView:__init()
    self.win_type = WinType.Mini
    self.view_tag = ViewMgrTag.TOP_TAG
    self.layout_name = "barrage/barrage_edit_window"
end

function BarrageEditView:open_callback()
    local background = self.root_wnd:getChildByName("background")
    background:setScale(display.getMaxScale())
    
    self.container = self.root_wnd:getChildByName("container")
    self:playEnterAnimatianByObj(self.container, 2)

    self.close_btn = self.container:getChildByName("close_btn")
    self.send_btn = self.container:getChildByName("send_btn")
    self.send_btn:getChildByName("label"):setString(TI18N("发送"))
    self.send_btn:getChildByName("label"):enableOutline(Config.ColorData.data_color4[263], 2)

    local content_container = self.container:getChildByName("content_container")
    local size = cc.size(content_container:getContentSize().width-36, content_container:getContentSize().height-20)

    self.editbox = createEditBox(content_container, PathTool.getResFrame("common","common_99998"), size, Config.ColorData.data_color4[175], 20, Config.ColorData.data_color4[63], 20, TI18N("请输入内容"), nil, 40, LOADTEXT_TYPE_PLIST)
    self.editbox:setAnchorPoint(cc.p(0,1))
    self.editbox:setPosition(18,size.height + 10)

    self.container:getChildByName("notice_label"):setString(TI18N("限制40字以内"))
    self.container:getChildByName("desc_label"):setString(TI18N("消耗:"))
    self.container:getChildByName("win_title"):setString(TI18N("发送弹幕"))


end

function BarrageEditView:register_event()
    self.send_btn:addTouchEventListener(function(sender, event_type) 
        customClickAction(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            local str = self.editbox:getText()
            if str == "" then
            else
                controller:sendBarrageMsg(self.type, str)
            end
        end
    end)

    self.close_btn:addTouchEventListener(function(sender, event_type) 
        customClickAction(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playButtonSound2()
            controller:openEditView(false)
        end
    end)

    -- 进战斗要关闭这个界面
    self:addGlobalEvent(SceneEvent.ENTER_FIGHT, function (  )
        self:close(true)
    end)
end

function BarrageEditView:openRootWnd(type)
    self.type = type or 1

    if self.container then
        local cost = 500
        local config = Config.SubtitleData.data_list[self.type]
        if config and next(config.loss) ~= nil then
            cost = config.loss[1][2] or 500
        end
        self.container:getChildByName("desc_value"):setString(cost)
    end
end

function BarrageEditView:close_callback()
    controller:openEditView(false)
end