-- --------------------------------------------------------------------
-- 
-- 
-- @author: mengjiabin@syg.com(必填, 创建模块的人员)
-- @editor: mengjiabin@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      解锁章节
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------

BattleDramaUnlockChapterView = BattleDramaUnlockChapterView or BaseClass(BaseView)

local controller = BattleDramaController:getInstance()

function BattleDramaUnlockChapterView:__init()
    self.is_full_screen = false
    self.layout_name = "battledrama/battle_drama_unlock_view"
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("battle", "battle"), type = ResourcesType.plist },
        { path = PathTool.getPlistImgForDownLoad("bigbg/battledrama", "battledrama_unlock_icon"), type = ResourcesType.single },
        { path = PathTool.getPlistImgForDownLoad("bigbg/battledrama", "txt_cn_battledrama_unlock_title"), type = ResourcesType.single },

    }
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Mini
    self.is_can_close = false
end

function BattleDramaUnlockChapterView:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())
    self.background:setVisible(true)

    self.main_panel = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_panel, 2)
    self.main_panel:setTouchEnabled(true)
    self.main_panel:setScale(display.getMaxScale())
    self.image_container = self.main_panel:getChildByName("image_container")
    self.Sprite_1 = self.image_container:getChildByName("icon_0")
    if self.sprite_1_load == nil then
        local res = PathTool.getPlistImgForDownLoad("bigbg","bigbg_98")
        self.sprite_1_load = loadSpriteTextureFromCDN(self.Sprite_1, res, ResourcesType.single, self.sprite_1_load)
    end

    self.Sprite_2 = self.image_container:getChildByName("icon_0_0")
    if self.sprite_2_load == nil then
        local res = PathTool.getPlistImgForDownLoad("bigbg","bigbg_98")
        self.sprite_2_load = loadSpriteTextureFromCDN(self.Sprite_2, res, ResourcesType.single, self.sprite_2_load)
    end
    
    self.title_panel = self.main_panel:getChildByName("title_panel")
    self.title_sp = self.title_panel:getChildByName("title_sp")
    self.icon = self.main_panel:getChildByName("icon")
    self.time_label = createRichLabel(22, 1, cc.p(0.5, 0.5), cc.p(self.root_wnd:getContentSize().width / 2 + 5, 355), nil, nil, 1000)
    self.time_label:setString(TI18N("10秒后关闭"))
    self.main_panel:addChild(self.time_label)
    self.star_name = createLabel(40, Config.ColorData.data_color4[197], Config.ColorData.data_color4[196], self.main_panel:getContentSize().width / 2, 360, "", self.main_panel, 2, cc.p(0.5, 0), "fonts/title.ttf")
    self:handleEffect(true)
end

function BattleDramaUnlockChapterView:register_event()
    self.main_panel:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            if self.is_can_close == true then
                playCloseSound()
                controller:openBattleDramaUnlockChapterView(false) 
            end
        end
    end)
end

function BattleDramaUnlockChapterView:updateDesc(config)
    self.config = config
    if config then
        loadSpriteTexture(self.title_sp, PathTool.getPlistImgForDownLoad("bigbg/battledrama", "txt_cn_battledrama_unlock_title"), LOADTEXT_TYPE)
        loadSpriteTexture(self.icon, PathTool.getPlistImgForDownLoad("bigbg/battledrama", "battledrama_unlock_icon"), LOADTEXT_TYPE)
        self.star_name:setString(config.name)
    end
    delayOnce(function ()
        self.is_can_close = true
    end,1)
    self:updateTimer()
end


function BattleDramaUnlockChapterView:updateTimer()
    local time = 10
    local call_back = function()
        time = time - 1
        local new_time = math.ceil(time)
        local str = string.format(TI18N("%s秒后关闭"), new_time)
        if self.time_label and not tolua.isnull(self.time_label) then
            self.time_label:setString(str)
        end
        if new_time <= 0 then
            controller:openBattleDramaUnlockChapterView(false)
            GlobalTimeTicket:getInstance():remove("close_unlock_view")
        end
    end
    GlobalTimeTicket:getInstance():add(call_back, 1, 0, "close_unlock_view")
end

function BattleDramaUnlockChapterView:openRootWnd(data)
    self:updateDesc(data)
end

function BattleDramaUnlockChapterView:handleEffect(status)
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
			self.main_panel:addChild(self.play_effect, - 1)
		end
	end
end 

function BattleDramaUnlockChapterView:close_callback()
    GlobalEvent:getInstance():Fire(Battle_dramaEvent.BattleDrama_Drama_Unlock_View, self.config)
    controller:openBattleDramaUnlockChapterView(false)
    GlobalTimeTicket:getInstance():remove("close_unlock_view")
    self:handleEffect(false)
    if self.item_load_1 then
        self.item_load_1:DeleteMe()
        self.item_load_1 = nil
    end

    if self.sprite_1_load then
        self.sprite_1_load:DeleteMe()
        self.sprite_1_load = nil
    end

    if self.sprite_2_load then
        self.sprite_2_load:DeleteMe()
        self.sprite_2_load = nil
	end
end