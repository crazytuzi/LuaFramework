-- --------------------------------------------------------------------
-- 技能tips
-- 
-- @author: cloud@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------

SkillTips = SkillTips or BaseClass(BaseView) 

local string_format = string.format

function SkillTips:__init( ... )
    self.is_full_screen = false
    self.title_str= ""
    self.layout_name = "tips/skill_tips"
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("tips","tips"), type = ResourcesType.plist },
    }
    self.win_type = WinType.Tips   
    self.view_tag = ViewMgrTag.DIALOGUE_TAG 
end

--[[
@功能:构建UI
@参数:
@返回值:
]]
function SkillTips:open_callback( ... )
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end
    self.main_panel = self.root_wnd:getChildByName("main_panel")

    self.container = self.main_panel:getChildByName("container")            -- 背景,需要动态设置尺寸
    self.container:setContentSize(cc.size(500, 398))
    self.container_init_size = self.container:getContentSize()

    self.base_panel = self.container:getChildByName("base_panel")
    self.base_panel_height = self.base_panel:getContentSize().height

    self.Sprite_3 = self.base_panel:getChildByName("Sprite_3")
    self.skill_icon = self.base_panel:getChildByName("skill_icon")
    self.Sprite_3:setVisible(false)
    self.skill_icon:setVisible(false)
    self.skill_item = SkillItem.new(false,false,false,nil,nil,false)
    self.skill_item:setPosition(76, 68)
    self.base_panel:addChild(self.skill_item)
    self.skill_name = self.base_panel:getChildByName("name")
    self.skill_type = self.base_panel:getChildByName("skill_type")

    self.line = self.container:getChildByName("line")
    self.line:setPositionX(self.container_init_size.width/2)
end

function SkillTips:register_event()
    if self.background then 
        self.background:addTouchEventListener(function(sender, event_type) 
            if event_type == ccui.TouchEventType.ended then
                playCloseSound()
                self:close()
            end
        end)
    end
end

--[[
@功能:设置技能信息
@参数:Config.Skill   ,  Config.RoleCareerSkill
@返回值:
]]
function SkillTips:updateVo( skill_vo, is_lock, not_show_next, hide_flag, fire_cd, hallows_atk_val )
    self.skill_vo = skill_vo
    local level = skill_vo.level or 1
    if skill_vo.client_lev and skill_vo.client_lev>0 then
        level = skill_vo.client_lev
    end
	-- 技能名字
    if not hide_flag then
        self.skill_name:setString(skill_vo.name.."  Lv."..level)
    else
        self.skill_name:setString(skill_vo.name)
    end
	-- self.skill_name:setString(skill_vo.name)
    -- loadSpriteTexture(self.skill_icon, PathTool.getSkillRes(skill_vo.icon), LOADTEXT_TYPE) 
    self.skill_item:setData(skill_vo)

    self.skill_type:setVisible(true)
    if skill_vo.type == "active_skill" then 
        self.skill_type:setString(TI18N("类型：主动技能"))
    else 
        self.skill_type:setString(TI18N("类型：被动技能")) 
    end

    -- 统计最大高度
    local head_space = 21
    local total_height = head_space + self.base_panel_height

    local skill_des_height = 0
    if self.skill_vo.des ~= "" then
        if self.skill_desc == nil then
            self.skill_desc = createRichLabel(22,cc.c4b(60,80,120,255),cc.p(0,1),cc.p(22,10),4,nil,460)
            self.container:addChild(self.skill_desc)
        end
        if self.skill_vo.hallows_atk and self.skill_vo.hallows_atk > 0 and hallows_atk_val then
            local skill_atk_val = self.skill_vo.hallows_atk
            local total_atk_val = skill_atk_val + hallows_atk_val
            local str = string.format(self.skill_vo.des, total_atk_val, hallows_atk_val)
            self.skill_desc:setString(str)
        else
            self.skill_desc:setString(self.skill_vo.des)
        end
        skill_des_height = self.skill_desc:getContentSize().height 
        total_height  = total_height + skill_des_height + 2
    end

    local extend_desc_height = 0
    if self.extend_desc == nil then
        self.extend_desc = createRichLabel(22,cc.c4b(60,80,120,255),cc.p(0,1),cc.p(22,10),nil,nil,460)
        self.container:addChild(self.extend_desc)
    end
    if not hide_flag then
        local extend_str = ""
        if self.skill_vo.cd == 0 then
            extend_str = TI18N("无冷却时间")
        else
            extend_str = string_format("<div fontcolor=#3d5078>%s</div><div fontcolor=#1db116>%s</div><div fontcolor=#3d5078>%s</div>", TI18N("冷却"),self.skill_vo.cd, TI18N("回合") )
        end
        if fire_cd and fire_cd ~= 0 then
            fire_cd = fire_cd
        else
            fire_cd = self.skill_vo.fire_cd or 0
        end
        if fire_cd ~= 0 then
            extend_str = extend_str..string_format("<div fontcolor=#3d5078>%s</div><div fontcolor=#1db116>%s</div><div fontcolor=#3d5078>%s</div>", TI18N("，第"), fire_cd, TI18N("回合释放"))
        end
        self.extend_desc:setString(extend_str)
    end

    extend_desc_height = self.extend_desc:getContentSize().height
    total_height  = total_height + extend_desc_height + 18

    local buff_desc_str = ""
    local buff_desc_height = 0
    if self.skill_vo.buff_des ~= nil and self.skill_vo.buff_des[1] and next(self.skill_vo.buff_des[1]) then
        self.line:setVisible(true)
        local buff_config = Config.SkillData.data_get_buff 
        for i, v in ipairs(self.skill_vo.buff_des[1]) do
            local config = buff_config[v]
            if config then
                if buff_desc_str ~= "" then
                    buff_desc_str = buff_desc_str.."<div fontcolor=#3d5078>\n</div>"
                end
                local buff_desc = string_format("<div fontcolor=#3d5078>【%s】</div><div fontcolor=#3d5078>\n%s</div>", config.name, config.desc)
                buff_desc_str = buff_desc_str..buff_desc
            end
        end
    end
    if buff_desc_str ~= "" then
        if self.buff_desc == nil then
            self.buff_desc = createRichLabel(20,cc.c4b(60,80,120,255),cc.p(0,1),cc.p(22,10),4,nil,460)
            self.container:addChild(self.buff_desc)
        end
        self.buff_desc:setString(buff_desc_str)
        buff_desc_height = self.buff_desc:getContentSize().height
        total_height  = total_height + self.buff_desc:getContentSize().height + 10
    end

    -- 下级描述
    if self.skill_vo.open_desc ~= "" and not not_show_next and not hide_flag then
        if self.line_2 == nil then
            self.line_2 = createSprite(PathTool.getResFrame("tips","tips_8"), self.container_init_size.width/2, 0, self.container, cc.p(0.5, 1), LOADTEXT_TYPE_PLIST)
            self.line_2:setScaleX(7.6)
        end
        local next_skill_des = ""
        if is_lock then -- 未开启
            next_skill_des = self.skill_vo.open_desc
        elseif self.skill_vo.next_id == 0 then -- 已满级
            next_skill_des = string_format(TI18N("<div fontcolor=#3d5078>技能已满级</div>"))
        else
            next_skill_des = self.skill_vo.skill_desc
        end
        if self.next_skill_txt == nil then
            self.next_skill_txt = createRichLabel(22,cc.c4b(60,80,120,255),cc.p(0,1),cc.p(22,10),4,nil,460)
            self.container:addChild(self.next_skill_txt)
        end
        self.next_skill_txt:setString(next_skill_des)
        total_height  = total_height + self.next_skill_txt:getContentSize().height + 25
    end

    total_height = total_height + 20
    
    self.container:setContentSize(cc.size(self.container_init_size.width, total_height))
    self.base_panel:setPositionY(total_height-head_space)
    self.skill_desc:setPositionY(total_height-head_space-self.base_panel_height)
    self.extend_desc:setPositionY(total_height-24-self.base_panel_height-skill_des_height)
    self.line:setPositionY(total_height-30-self.base_panel_height-skill_des_height-extend_desc_height)
    if self.buff_desc then
        self.buff_desc:setPositionY(total_height-38-self.base_panel_height-skill_des_height-extend_desc_height)
    end
    if self.line_2 then
        self.line_2:setPositionY(total_height-44-self.base_panel_height-skill_des_height-extend_desc_height-buff_desc_height)
    end
    if self.next_skill_txt then
        self.next_skill_txt:setPositionY(total_height-52-self.base_panel_height-skill_des_height-extend_desc_height-buff_desc_height)
    end
end

function SkillTips:updatePosition()
    self.root_wnd:setContentSize(cc.size(504,self.max_height))
    self.back:setContentSize(cc.size(504,self.max_height))
    self.skill_type:setPositionY(self.max_height-110)
    self.skill_back:setPositionY(self.max_height-145)
    self.skill_name:setPositionY(self.max_height-50)
    self.skill_lev:setPositionY(self.max_height-80)
    self.desc3:setPositionY(self.max_height-170)
    self.desc1:setPositionY(self.max_height-170)
    self.line1:setPositionY(self.max_height-155)
end

function SkillTips:setPosition(x, y)
    -- self.root_wnd:setAnchorPoint(cc.p(0, 1))
    -- self.root_wnd:setPosition(cc.p(x, y))
end


function SkillTips:setPos(x, y)
    -- self.root_wnd:setPosition(cc.p(x, y))
end

function SkillTips:getContentSize()
    return self.root_wnd:getContentSize()
end

--[[
@功能:打开技能tips
@参数:
@返回值:
]]
function SkillTips:openRootWnd( config, is_lock, not_show_next, hide_flag, fire_cd, hallows_atk_val )
    self:updateVo(config, is_lock, not_show_next, hide_flag, fire_cd, hallows_atk_val)

	-- ViewManager:getInstance():addToLayerByTag(self.root_root,ViewMgrTag.MSG_TAG)
    delayRun(self.root_wnd, 114, function()
        TipsManager:getInstance():hideTips()
    end)
end

function SkillTips:close_callback( ... )
    -- if self.root_root then
    --     self.root_root:removeAllChildren()
    --     self.root_root:removeFromParent()
    -- end
end
