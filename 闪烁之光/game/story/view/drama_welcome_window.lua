-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      首次登陆游戏的欢迎界面
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
DramaWelcommeWindow = DramaWelcommeWindow or BaseClass(BaseView)

local controller = StoryController:getInstance()
local story_view = controller:getView() 

function DramaWelcommeWindow:__init()
	self.win_type = WinType.Mini
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.is_full_screen     = false
	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("welcome", "welcome"), type = ResourcesType.plist},
		{path = PathTool.getPlistImgForDownLoad("bigbg", "bigbg_49"), type = ResourcesType.single}
	}
    self.can_click = false
	self.layout_name = "drama/drama_welcome_window"
end 

function DramaWelcommeWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    self.container = self.root_wnd:getChildByName("container")

    self.container:getChildByName("item_1"):getChildByName("label"):setString(TI18N("冒险者大人,欢迎踏上冒险之旅"))

    local label = self.container:getChildByName("item_2"):getChildByName("label")
    label:setTextAreaSize(cc.size(374, 100))
    local real_label = label:getVirtualRenderer()
    if real_label then
        real_label:setLineSpacing(10)
    end
    label:setString(TI18N("游戏将一直自动战斗,无论是否在线,都可以持续获得奖励!"))

    self.container:getChildByName("item_3"):getChildByName("label"):setString(TI18N("记得经常上线领取装备和经验噢~"))
    -- self.title:setString(string.format(TI18N("欢迎来到%s哟"), GAME_NAME))
end

function DramaWelcommeWindow:register_event()
	self.background:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
            self:playNextAct()
		end
	end)
end

function DramaWelcommeWindow:playNextAct()
    if self.can_click == false then return end
    playCloseSound()
    GlobalEvent:getInstance():Fire(StoryEvent.PLAY_NEXT_ACT) 
end

function DramaWelcommeWindow:openRootWnd(msg)
    self.can_click = false
    delayRun(self.container, 2, function() 
        self.can_click = true
    end)
end

function DramaWelcommeWindow:close_callback()
    story_view:playWelcom(false)
end
