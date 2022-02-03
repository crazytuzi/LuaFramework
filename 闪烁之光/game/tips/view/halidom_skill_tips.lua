--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-03-10 21:06:23
-- @description    : 
		-- 圣物技能tips
---------------------------------
HalidomSkillTips = HalidomSkillTips or BaseClass(BaseView) 

local string_format = string.format

function HalidomSkillTips:__init( ... )
    self.is_full_screen = false
    self.title_str= ""
    self.layout_name = "tips/skill_tips"
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("tips","tips"), type = ResourcesType.plist },
    }
    self.win_type = WinType.Tips   
    self.view_tag = ViewMgrTag.DIALOGUE_TAG 
end

function HalidomSkillTips:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end
    self.main_panel = self.root_wnd:getChildByName("main_panel")

    self.container = self.main_panel:getChildByName("container")            -- 背景,需要动态设置尺寸
    self.container_init_size = self.container:getContentSize()

    self.base_panel = self.container:getChildByName("base_panel")
    self.base_panel_height = self.base_panel:getContentSize().height

    self.skill_icon = self.base_panel:getChildByName("skill_icon")
    self.skill_name = self.base_panel:getChildByName("name")
    self.skill_type = self.base_panel:getChildByName("skill_type")

    self.line = self.container:getChildByName("line")
end

function HalidomSkillTips:register_event(  )
	if self.background then 
        self.background:addTouchEventListener(function(sender, event_type) 
            if event_type == ccui.TouchEventType.ended then
                playCloseSound()
                self:close()
            end
        end)
    end
end

function HalidomSkillTips:setData( skill_id )
	local skill_config = Config.HalidomData.data_skill[skill_id]
	if not skill_config then return end

	self.skill_name:setString(skill_config.name.."  Lv.".. skill_config.lev)
	loadSpriteTexture(self.skill_icon, PathTool.getSkillRes(skill_config.res_id), LOADTEXT_TYPE)
	self.skill_type:setString(TI18N("类型：圣物被动"))

	-- 统计最大高度
    local total_height = 4 + self.base_panel_height

    local skill_des_height = 0
    if skill_config.desc ~= "" then
        if self.skill_desc == nil then
            self.skill_desc = createRichLabel(22,cc.c4b(0xfe,0xee,0xba,0xff),cc.p(0,1),cc.p(22,10),4,nil,370)
            self.container:addChild(self.skill_desc)
        end
        self.skill_desc:setString(skill_config.desc)
        skill_des_height = self.skill_desc:getContentSize().height 
        total_height  = total_height + skill_des_height + 2
    end

    total_height = total_height + 20
    
    self.container:setContentSize(cc.size(self.container_init_size.width, total_height))
    self.base_panel:setPositionY(total_height-4)
    self.line:setPositionY(total_height-4-self.base_panel_height)
    self.skill_desc:setPositionY(total_height-6-self.base_panel_height)
end

function HalidomSkillTips:openRootWnd( skill_id )
	self:setData(skill_id)

	delayRun(self.root_wnd, 114, function()
        TipsManager:getInstance():hideTips()
    end)
end

function HalidomSkillTips:close_callback(  )
	
end