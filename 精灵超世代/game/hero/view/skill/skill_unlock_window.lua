-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      技能解锁
-- <br/> 2018年11月20日
-- --------------------------------------------------------------------
-- --------------------------------------------------------------------
SkillUnlockWindow = SkillUnlockWindow or BaseClass(BaseView)


local controller = HeroController:getInstance()

function SkillUnlockWindow:__init(skill_bid, setting)
    self.is_full_screen = false
    self.layout_name = "hero/skill_unlock"
    self.res_list = {
       
    }
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Mini   
    self.skill_bid = skill_bid or 0

    self.setting = setting or {}
    --显示类型  1 表示原本技能 的  2 表示 天赋栏开锁
    self.show_type = self.setting.show_type or 1
    self.is_can_close = false
end

function SkillUnlockWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())
    self.background:setVisible(true)

    self.main_panel = self.root_wnd:getChildByName("main_container")
    self.main_panel:setTouchEnabled(false)


    self.title_panel = self.main_panel:getChildByName("title_panel")
    self.title = self.title_panel:getChildByName("title")
    self:createDesc()

    self:updateDesc()
end

function SkillUnlockWindow:register_event()
    self.background:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
            playCloseSound()
            if self.is_can_close == true then
                controller:openSkillUnlockWindow(false)
            end
        end
    end)
end

function SkillUnlockWindow:createDesc()
    local size = self.main_panel:getContentSize()
    self.head_icon = SkillItem.new(true)
    self.head_icon:setPosition(cc.p(size.width/2,530))
    self.head_icon:setAnchorPoint(cc.p(0.5,0.5))
    self.main_panel:addChild(self.head_icon)

    self.star_name = createLabel(26,Config.ColorData.data_color4[1],Config.ColorData.data_color4[9],size.width/2,430,"",self.main_panel,2,cc.p(0.5,0))

    self.star_desc =   createRichLabel(20,cc.c4b(0xff,0xd7,0x9b,0xff),cc.p(0.5,1),cc.p(size.width/2,415),nil,nil,570)
    self.main_panel:addChild(self.star_desc)
end

function SkillUnlockWindow:updateDesc()
    delayOnce(function ()
        self.is_can_close = true
    end,1)
    if self.show_type == 1 then
        if self.skill_bid == 0 then return end
        local bg_res = PathTool.getPlistImgForDownLoad("bigbg","txt_cn_bigbg_19")
        self.title_bg_load = loadSpriteTextureFromCDN(self.title, bg_res, ResourcesType.single, self.title_bg_load)

        local config = Config.SkillData.data_get_skill(self.skill_bid)
        if not config then return end
        local desc = config.des or ""
        local str = string.format( "<div outline=2,#000000>%s</div>",desc)
        self.star_desc:setString(str)

        local name = config.name or ""
        self.star_name:setString(name)
       
        self.head_icon:setData(config)

    elseif self.show_type == 2 then
        self.star_name:setString(TI18N("觉醒天赋栏"))
        self.star_desc:setString(TI18N("<div outline=2,#000000>已解锁13星专属天赋栏，可学习13星专属职业天赋</div>"))

        if self.head_icon and self.head_icon.item_icon then
            local skill_icon = PathTool.checkRes("resource/bigbg/hero/talent_pos.png")
            self.head_icon.item_icon:setVisible(true)
            loadSpriteTexture(self.head_icon.item_icon, skill_icon, LOADTEXT_TYPE)
        end

        local bg_res = PathTool.getPlistImgForDownLoad("bigbg/hero","hero_unlock_talent_bg")
        self.title_bg_load = loadSpriteTextureFromCDN(self.title, bg_res, ResourcesType.single, self.title_bg_load)
    end
   
end

function SkillUnlockWindow:openRootWnd()
    playOtherSound("c_get")
    self:handleEffect(true) 
end

--[[
    @desc: 设置标签页面板数据内容
    author:{author}
    time:2018-05-03 21:57:09
    return
]]
function SkillUnlockWindow:setPanelData()
end

function SkillUnlockWindow:handleEffect(status)
    if status == false then
        if self.play_effect then
            self.play_effect:clearTracks()
            self.play_effect:removeFromParent()
            self.play_effect = nil
        end
    else
        local size = self.main_panel:getContentSize() 
        if not tolua.isnull(self.main_panel) and self.play_effect == nil then
            self.play_effect = createEffectSpine(PathTool.getEffectRes(145), cc.p(size.width*0.5, size.height*0.5+40), cc.p(0.5, 0.5), true, PlayerAction.action)
            self.main_panel:addChild(self.play_effect, -1)
        end
    end
end 

function SkillUnlockWindow:close_callback()
    self:handleEffect(false)
    if self.bottom_head then 
        self.bottom_head:DeleteMe()
        self.bottom_head = nil
    end
    if self.head_icon then 
        self.head_icon:DeleteMe()
        self.head_icon = nil
    end

    if self.title_bg_load then
        self.title_bg_load:DeleteMe()
        self.title_bg_load = nil
    end
    --可能会有礼包触发
    GlobalEvent:getInstance():Fire(BattleEvent.NEXT_SHOW_RESULT_VIEW)

    controller:openSkillUnlockWindow(false)
end







