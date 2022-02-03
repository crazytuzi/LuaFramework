-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      是个漫画窗体
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
StoryMangaView = StoryMangaView or BaseClass(BaseView) 

local controller = StoryController:getInstance()
local story_view = controller:getView() 

function StoryMangaView:__init()
    self.is_use_csb = false
	self.win_type = WinType.Full
	self.is_full_screen = true
	self.view_tag = ViewMgrTag.MSG_TAG        	-- 父级层次
    self.can_click = false
    self.layout_name = "drama/drama_manga_view"
	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("bigbg", "bigbg_44", true), type = ResourcesType.single},
	}
end

function StoryMangaView:open_callback()
    self.container = self.root_wnd:getChildByName("container")
    self.container:setScale(display.getMaxScale())
end

function StoryMangaView:register_event()
    self.container:addTouchEventListener(function(sender,event_type)
        if event_type == ccui.TouchEventType.ended then
            GlobalEvent:getInstance():Fire(StoryEvent.PLAY_NEXT_ACT) 
        end
    end)
end

function StoryMangaView:openRootWnd(effect_id, action_num)
    -- self:setCanClickStatus()
    -- AudioManager:getInstance():playMusic(AudioManager.AUDIO_TYPE.BATTLE, "b_003", true) 
end

function StoryMangaView:setCanClickStatus()
    self.can_click = false
    delayRun(self.container, 2, function() 
        self.can_click = true
    end) 
end

--==============================--
--desc:下一波
--time:2018-07-14 09:31:15
--@force:
--@return 
--==============================--
function StoryMangaView:playNextManga(force)
    -- if force == true or self.can_click == true then
    --     self:setCanClickStatus()

    --     if not tolua.isnull(self.effect) then
    --         self.action_index = self.action_index + 1
    --         if self.action_index > self.action_sum then
    --             GlobalEvent:getInstance():Fire(StoryEvent.PLAY_NEXT_ACT)
    --         else
    --             self.effect:clearTracks()
    --             self.effect:setToSetupPose() 
    --             self.cur_action = string.format("action%s", self.action_index)
    --             self.effect:setAnimation(0, self.cur_action, false) 
    --         end
    --     end
    -- else
    -- end
end

function StoryMangaView:close_callback()
    doStopAllActions(self.container)
    story_view:playStartManga(false)
    -- 播放主城音效
    -- local music_name = RoleController:getInstance():getModel().city_music_name or "s_002"
    -- AudioManager:getInstance():playMusic(AudioManager.AUDIO_TYPE.SCENE, music_name, true) 
    -- if not tolua.isnull(self.effect) then
	-- 	self.effect:runAction(cc.RemoveSelf:create(true))
	-- 	self.effect:clearTracks()
    -- end
    -- self.effect = nil
end