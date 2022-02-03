--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-03-11 15:15:09
-- @description    : 
		-- 圣物进阶
---------------------------------
HalidomUpStepWindow = HalidomUpStepWindow or BaseClass(BaseView)

local _controller = HalidomController:getInstance()
local _model = _controller:getModel()

function HalidomUpStepWindow:__init()
    self.is_full_screen = false
    self.layout_name = "hero/skill_unlock"
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Mini   
    
    self.res_list = {
       {path = PathTool.getPlistImgForDownLoad("bigbg","txt_cn_bigbg_28"), type = ResourcesType.single },
    }

    self.is_can_close = false
end

function HalidomUpStepWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())
    self.background:setVisible(true)

    self.main_panel = self.root_wnd:getChildByName("main_container")
    self.main_panel:setTouchEnabled(false)

    local title_panel = self.main_panel:getChildByName("title_panel")
    local title = title_panel:getChildByName("title")
    local res = PathTool.getPlistImgForDownLoad("bigbg","txt_cn_bigbg_28")
    loadSpriteTexture(title, res, LOADTEXT_TYPE)
    
    local size = self.main_panel:getContentSize()

    self.icon_kuang = createSprite(PathTool.getResFrame("common", "common_1005"), size.width/2, 530, self.main_panel, cc.p(0.5, 0.5))
    self.skill_icon = createSprite(nil, 119/2, 119/2, self.icon_kuang, cc.p(0.5, 0.5), LOADTEXT_TYPE)
    self.level_bg = createSprite(PathTool.getResFrame("common", "common_2018"), 119, 119, self.icon_kuang, cc.p(0.5, 0.5))
    self.level_txt = createLabel(20,cc.c4b(0x64,0x32,0x23,0xff),nil,16,16,"1",self.level_bg,nil,cc.p(0.5,0.5))
    self.name_txt = createLabel(26,Config.ColorData.data_color4[1],Config.ColorData.data_color4[9],size.width/2,430,"",self.main_panel,2,cc.p(0.5,0))
    self.desc_txt = createRichLabel(20, cc.c4b(0xff,0xd7,0x9b,0xff), cc.p(0.5,1), cc.p(size.width/2,415), nil, nil, 570)
    self.main_panel:addChild(self.desc_txt)
end

function HalidomUpStepWindow:register_event(  )
	self.background:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
            playCloseSound()
            if self.is_can_close == true then
                _controller:openHalidomUpStepWindow(false)
            end
        end
    end)
end

function HalidomUpStepWindow:setData()
    if not self.halidom_id then return end
    local all_step_cfg = Config.HalidomData.data_step[self.halidom_id]
    if not all_step_cfg then return end
    local halidom_vo = _model:getHalidomDataById(self.halidom_id)
    local step_cfg = all_step_cfg[halidom_vo.step]
    if not step_cfg then return end
    
    local config = Config.HalidomData.data_skill[step_cfg.skill_icon]
    if not config then return end

    if self.skill_icon then
    	loadSpriteTexture(self.skill_icon, PathTool.getSkillRes(config.res_id), LOADTEXT_TYPE)
    end

    if self.level_txt then
    	self.level_txt:setString(config.lev)
    end

    if self.name_txt then
    	self.name_txt:setString(config.name)
    end

    if self.desc_txt then
        local attr_list = {}
        for i,v in ipairs(step_cfg.dynamic_attr) do
            table.insert(attr_list, v)
        end
        for i,v in ipairs(step_cfg.fixed_attr) do
            table.insert(attr_list, v)
        end
        local desc_str = ""
        for i,v in ipairs(attr_list) do
            local attr_key = v[1]
            local attr_val = v[2] or 0
            local attr_name = Config.AttrData.data_key_to_name[attr_key]
            if attr_name then
                local is_per = PartnerCalculate.isShowPerByStr(attr_key)
                if is_per == true then
                    attr_val = (attr_val/10) .."%"
                end
                if desc_str == "" then
                    desc_str = string.format(TI18N("%s的%s属性额外提升%s"), config.name, attr_name, tostring(attr_val))
                else
                    desc_str = desc_str .. "\n" .. string.format(TI18N("%s的%s属性额外提升%s"), config.name, attr_name, tostring(attr_val))
                end
            end
        end
        
    	desc_str = string.format( "<div outline=2,#000000>%s</div>", desc_str)
    	self.desc_txt:setString(desc_str)
    end
end

function HalidomUpStepWindow:openRootWnd( id )
	self.halidom_id = id
    playOtherSound("c_get")
    self:handleEffect(true) 
    self:setData()

    delayOnce(function ()
        self.is_can_close = true
    end,1)
end

function HalidomUpStepWindow:handleEffect(status)
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

function HalidomUpStepWindow:close_callback()
    self:handleEffect(false)
    _controller:openHalidomUpStepWindow(false)
end