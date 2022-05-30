-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      冠军赛最佳玩家信息提示面板
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------

ArenaChampionBestInfoWindow = ArenaChampionBestInfoWindow or BaseClass(BaseView)

local controller = ArenaController:getInstance()
local model = ArenaController:getInstance():getModel()

function ArenaChampionBestInfoWindow:__init(view_type)
	self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.win_type = WinType.Big
	self.is_full_screen = false
	self.layout_name = "arena/arena_champion_best_info_window"
	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("arena", "arenachampion"), type = ResourcesType.plist},
        {path = PathTool.getPlistImgForDownLoad("bigbg", "bigbg_46"), type = ResourcesType.single}
	}

    -- 冠军赛类型（本服和跨服）
    self.view_type = view_type or ArenaConst.champion_type.normal
end 

function ArenaChampionBestInfoWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    local container = self.root_wnd:getChildByName("container")
    self.container = container
    self:playEnterAnimatianByObj(self.container, 2)

    local image_1 = container:getChildByName("Image_1")
    -- local image_2 = container:getChildByName("Image_2")
    image_1:ignoreContentAdaptWithSize(true)
    -- image_2:ignoreContentAdaptWithSize(true)
    if self.view_type == ArenaConst.champion_type.normal then
        image_1:loadTexture(PathTool.getPlistImgForDownLoad("bigbg", "bigbg_46") ,LOADTEXT_TYPE)
        -- image_2:loadTexture(PathTool.getPlistImgForDownLoad("bigbg", "bigbg_46") ,LOADTEXT_TYPE)
        image_1:setVisible(true)
        -- image_2:setVisible(true)
        self:handleFlagEffect(false)
    else
        image_1:setVisible(false)
        -- image_2:setVisible(false)
        self:handleFlagEffect(true)
    end

    local info_panel = container:getChildByName("info_panel")
    info_panel:getChildByName("title"):setString(TI18N("上期冠军赛结算"))
    info_panel:setLocalZOrder(1)
    info_panel:getChildByName("rank_title"):setString(TI18N("排名:"))
    info_panel:getChildByName("times_title"):setString(TI18N("比赛场数:"))
    info_panel:getChildByName("win_title"):setString(TI18N("获胜场数:"))
    info_panel:getChildByName("desc_label"):setString(TI18N("获得以上成就"))
    -- local image_3 = info_panel:getChildByName("Image_3")
    if self.view_type == ArenaConst.champion_type.cross then
        info_panel:getChildByName("title"):setString(TI18N("上期周冠军赛结算"))
        -- image_3:loadTexture(PathTool.getResFrame("arena","txt_cn_arenachampion_1002",false,"arenachampion"), LOADTEXT_TYPE_PLIST)
    end

    self.rank_value = info_panel:getChildByName("rank_value")
    self.times_value = info_panel:getChildByName("times_value")
    self.win_value = info_panel:getChildByName("win_value")

    self.notice_label = createRichLabel(26, 1, cc.p(0.5, 1), cc.p(224, 230), 10, nil, 278)
    info_panel:addChild(self.notice_label)
end

function ArenaChampionBestInfoWindow:handleFlagEffect( status )
    if status == false then
        if self.flag_effect then
            self.flag_effect:clearTracks()
            self.flag_effect:removeFromParent()
            self.flag_effect = nil
        end
    else
        if not tolua.isnull(self.container) and self.flag_effect == nil then
            self.flag_effect = createEffectSpine(Config.EffectData.data_effect_info[1321], cc.p(222, 0), cc.p(0.5, 0.5), true, PlayerAction.action)
            self.container:addChild(self.flag_effect)
        end
    end
end

function ArenaChampionBestInfoWindow:register_event()
	self.background:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playCloseSound()
			controller:openArenaChampionBestInfoWindow(false)
		end
	end)
end

function ArenaChampionBestInfoWindow:openRootWnd(data)
    self.background:setTouchEnabled(false)
    delayRun(self.background, 1, function() 
        self.background:setTouchEnabled(true)
    end) 

    local role_vo = RoleController:getInstance():getRoleVo()
    if role_vo then
        -- local str = string.format("<div fontColor=#ffffff outline=1,#5d140b >恭喜</div><div fontColor=#FFC000 outline=1,#5d140b >%s</div>", role_vo.name)
        -- local str = string.format(TI18N("恭喜<div fontColor=#FFC000 outline=1,#5d140b >%s</div>"), role_vo.name)
        local str = string.format(TI18N("恭喜\n<div fontColor=%s>%s</div>"), Config.ColorData.data_new_color_str[17], role_vo.name)
        self.notice_label:setString(str)
    end
    if data then
        self.rank_value:setString(data.rank or 0)
        self.times_value:setString(data.cnum or 0)
        self.win_value:setString(data.win or 0)
    end
end

function ArenaChampionBestInfoWindow:close_callback()
    self:handleFlagEffect(false)
    controller:openArenaChampionBestInfoWindow(false)
end