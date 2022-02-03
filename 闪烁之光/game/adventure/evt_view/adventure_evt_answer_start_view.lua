-- --------------------------------------------------------------------
-- 
-- 
-- @author: mengjiabin@syg.com(必填, 创建模块的人员)
-- @editor: mengjiabin@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      答题开始提面板
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
AdventureEvtStartWindow = AdventureEvtStartWindow or BaseClass(BaseView)

local controller = AdventureController:getInstance() 

function AdventureEvtStartWindow:__init(data)
    self.win_type = WinType.Mini
    self.data = data
    self.config = data.config
    self.layout_name = "adventure/adventure_evt_answer_start_view"
    self.is_full_screen = false
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("adventure", "adventure"), type = ResourcesType.plist },
        { path = PathTool.getPlistImgForDownLoad("bigbg", "bigbg_47"), type = ResourcesType.single },
    }
    self.is_use_csb = false
end
function AdventureEvtStartWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())
    self.main_container = self.root_wnd:getChildByName("root")
    self:playEnterAnimatianByObj(self.main_container, 2)
    
    self.item_icon = self.main_container:getChildByName("item_icon")
    loadSpriteTexture(self.item_icon, PathTool.getPlistImgForDownLoad("bigbg", "bigbg_47"), LOADTEXT_TYPE)

    self.close_btn = self.main_container:getChildByName("close_btn")
    self.ack_button = self.main_container:getChildByName("ack_button")
    self.ack_button.label = self.ack_button:getTitleRenderer()
    self.ack_button:setTitleText(TI18N("开始答题"))
    self.ack_button.label:enableOutline(Config.ColorData.data_color4[264], 2)
    self.title_label = self.main_container:getChildByName("title_label")
    self.title_label:setString(TI18N("智力大乱斗"))
    self.swap_desc_label = createRichLabel(26, 175, cc.p(0.5, 0.5), cc.p(self.main_container:getContentSize().width / 2, 440), nil, nil, 600)
    self.main_container:addChild(self.swap_desc_label)
    self.swap_desc_label:setVisible(true)

    self:updatedata()
end

function AdventureEvtStartWindow:updatedata()
    if self.config then
        self.swap_desc_label:setString(self.config.desc)
    end
end

function AdventureEvtStartWindow:register_event()
    if self.background then
        self.background:addTouchEventListener(function(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                playButtonSound2()
                controller:openEvtViewByType(false) 
            end
        end)
    end
    if self.close_btn then
        self.close_btn:addTouchEventListener(function(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                playButtonSound2()
                controller:openEvtViewByType(false) 
            end
        end)
    end
    if self.ack_button then
        self.ack_button:addTouchEventListener(function(sender, event_type)
            if event_type == ccui.TouchEventType.ended then
                playButtonSound2()
                if self.config then
                    controller:openEvtViewByType(false)
                    controller:openAnswerView(true,self.data)
                end
            end
        end)
    end
end

function AdventureEvtStartWindow:openRootWnd(type)
end

function AdventureEvtStartWindow:close_callback()
    controller:openEvtViewByType(false)
end