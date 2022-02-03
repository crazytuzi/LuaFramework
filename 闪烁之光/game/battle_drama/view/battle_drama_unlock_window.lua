-- --------------------------------------------------------------------
-- 
-- 
-- @author: mengjiabin@syg.com(必填, 创建模块的人员)
-- @editor: mengjiabin@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      功能解锁界面
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
BattleDramaUnlockWindow = BattleDramaUnlockWindow or BaseClass(BaseView)

function BattleDramaUnlockWindow:__init()
    self.ctrl = BattleDramaController:getInstance()
    self.is_full_screen = false
    self.layout_name = "battledrama/battle_drama_unlock_window"
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("battleunlock","battleunlock"), type = ResourcesType.plist },
    }
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Mini
    self.is_can_close = false
end

function BattleDramaUnlockWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())
    self.background:setVisible(true)

    self.main_panel = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_panel, 2)
    self.main_panel:setTouchEnabled(false)
    self.main_panel:setScale(display.getMaxScale())
    self.ok_btn = self.main_panel:getChildByName("ok_btn")
    self.ok_btn:setTitleText(TI18N("知道了"))
    local title = self.ok_btn:getTitleRenderer()
    title:enableOutline(cc.c4b(196, 90, 20, 255), 2)

    self.time_label = createRichLabel(22, 1, cc.p(0.5, 0.5), cc.p(self.root_wnd:getContentSize().width / 2 + 5, 125), nil, nil, 1000)
    self.time_label:setString(TI18N("10秒后关闭"))
    self.main_panel:addChild(self.time_label)

    self.head_icon = self.main_panel:getChildByName("head_icon")
    self.star_name  = self.main_panel:getChildByName("star_name")
    self.star_desc = createRichLabel(26, Config.ColorData.data_color4[1], cc.p(0.5, 1), cc.p(360, 360), nil, nil, 500)
    self.main_panel:addChild(self.star_desc)

    self:handleEffect(true)

end

function BattleDramaUnlockWindow:register_event()
    self.ok_btn:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playCloseSound()
            if self.is_can_close == true then
                self.ctrl:openBattleDramaUnlockWindow(false)
            end
        end
    end)
end

function BattleDramaUnlockWindow:updateDesc(data)
    if data then
        local title_id = PathTool.getPlistImgForDownLoad("bigbg/battledrama",data.unlock_icon)
        if self.res_id_2 ~= title_id then
            self.res_id_2 = title_id
            self.item_load_1 = createResourcesLoad(self.res_id_2, ResourcesType.single, function()
                if not tolua.isnull(self.head_icon) then
                    loadSpriteTexture(self.head_icon, self.res_id_2, LOADTEXT_TYPE)
                end
            end, self.item_load_1)
        end
        self.star_name:setString(data.unlock_name)
        self.star_desc:setString(data.unlock_desc)
    end
    self.is_can_close = true
    self:updateTimer()
end


function BattleDramaUnlockWindow:updateTimer()
    local time = 10
    local call_back = function()
        time = time - 1
        local new_time = math.ceil(time)
		local str = new_time..TI18N("秒后关闭")
		if self.time_label and not tolua.isnull(self.time_label) then
			self.time_label:setString(str)
		end
        if new_time <= 0 then
            self.ctrl:openBattleDramaUnlockWindow(false)
            GlobalTimeTicket:getInstance():remove("close_unlock_view")
        end
    end
    GlobalTimeTicket:getInstance():add(call_back,1, 0, "close_unlock_view")
end

function BattleDramaUnlockWindow:openRootWnd(data)
    self:updateDesc(data)
end

function BattleDramaUnlockWindow:handleEffect(status)
	if status == false then
		if self.play_effect then
			self.play_effect:clearTracks()
			self.play_effect:removeFromParent()
			self.play_effect = nil
		end
	else
        local size = self.main_panel:getContentSize() 
		if not tolua.isnull(self.main_panel) and self.play_effect == nil then
			self.play_effect = createEffectSpine(PathTool.getEffectRes(145), cc.p(size.width * 0.5, size.height * 0.5 + 10), cc.p(0.5, 0.5), true, PlayerAction.action)
			self.main_panel:addChild(self.play_effect, -1)
		end
	end
end

function BattleDramaUnlockWindow:close_callback()
    self.ctrl:openBattleDramaUnlockWindow(false)
    GlobalTimeTicket:getInstance():remove("close_unlock_view")
    -- 关闭面板的时候做一次事件,允许可以播放剧情或者引导
	GlobalEvent:getInstance():Fire(BattleEvent.CLOSE_RESULT_VIEW)
    self:handleEffect(false)
    if self.item_load_1 then
        self.item_load_1:DeleteMe()
        self.item_load_1 = nil
    end
end