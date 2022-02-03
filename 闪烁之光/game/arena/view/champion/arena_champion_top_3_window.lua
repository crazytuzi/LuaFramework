-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      冠军赛赛季前三的结算面板
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
ArenaChampionTop3Window = ArenaChampionTop3Window or BaseClass(BaseView)

local controller = ArenaController:getInstance()
local model = ArenaController:getInstance():getModel()
local table_insert = table.insert 

function ArenaChampionTop3Window:__init(view_type)
	self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.is_full_screen = false
    self.win_type = WinType.Mini
	self.is_csb_action = true
	self.layout_name = "arena/arena_champion_top_3_window"
	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("arena", "arenachampiontop3"), type = ResourcesType.plist},
	}

    self.view_type = view_type or ArenaConst.champion_type.normal
end 

function ArenaChampionTop3Window:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    self.main_container = self.root_wnd:getChildByName("main_container")

    local title_container = self.main_container:getChildByName("title_container")
    local title_sp = title_container:getChildByName("Sprite_13")
    if self.view_type == ArenaConst.champion_type.cross then
        loadSpriteTexture(title_sp, PathTool.getResFrame("arena","txt_cn_arenatop_104",false,"arenachampiontop3"), LOADTEXT_TYPE_PLIST)
    end

    self.role_name_1 = self.main_container:getChildByName("role_name_1")
    self.role_name_2 = self.main_container:getChildByName("role_name_2")
    self.role_name_3 = self.main_container:getChildByName("role_name_3")

    self.role_head_1 = PlayerHead.new(PlayerHead.type.circle)
    self.role_head_1:setHeadLayerScale(0.95)
    self.role_head_1:setPosition(360, 252)
    self.role_head_1:setLev(99)
    self.main_container:addChild(self.role_head_1)

    self.role_head_2 = PlayerHead.new(PlayerHead.type.circle)
    self.role_head_2:setHeadLayerScale(0.95)
    self.role_head_2:setPosition(121, 206)
    self.role_head_2:setLev(99)
    self.main_container:addChild(self.role_head_2)

    self.role_head_3 = PlayerHead.new(PlayerHead.type.circle)
    self.role_head_3:setHeadLayerScale(0.95)
    self.role_head_3:setPosition(599, 206)
    self.role_head_3:setLev(99)
    self.main_container:addChild(self.role_head_3)

    self.match_time = self.main_container:getChildByName("match_time")
end

function ArenaChampionTop3Window:register_event()
	self.background:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playCloseSound()
			controller:openArenaChampionTop3Window(false)
		end
	end)
end

function ArenaChampionTop3Window:openRootWnd(data)
    self.background:setTouchEnabled(false)
    delayRun(self.background, 0.3, function() 
        self.background:setTouchEnabled(true)
    end)

    if data then
        self.match_time:setString(string.format(TI18N("比赛时间:%s"), TimeTool.getYMDHMS(data.time)))

        if data.rank_list then
            for i,v in ipairs(data.rank_list) do
                if self["role_name_"..v.rank] then
                    self["role_name_"..v.rank]:setString(v.name)
                end
                if self["role_head_"..v.rank] then
                    self["role_head_"..v.rank]:setLev(v.lev)
                    self["role_head_"..v.rank]:setHeadRes(v.face, false, LOADTEXT_TYPE, v.face_file, v.face_update_time)
                end
            end
        end
    end
end

function ArenaChampionTop3Window:close_callback()
    controller:openArenaChampionTop3Window(false)
    self.role_head_1:DeleteMe()
    self.role_head_2:DeleteMe()
    self.role_head_3:DeleteMe()
end