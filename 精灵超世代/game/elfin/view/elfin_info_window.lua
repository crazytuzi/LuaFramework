--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-08-17 17:11:20
-- @description    : 
		-- 精灵展示
---------------------------------
local _controller = ElfinController:getInstance()
local _model = _controller:getModel()

ElfinInfoWindow = ElfinInfoWindow or BaseClass(BaseView)

function ElfinInfoWindow:__init()
	self.win_type = WinType.Mini
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.is_full_screen = false
	self.layout_name = "elfin/elfin_info_window"

	self.elfin_step_list = {}
	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("elfin", "elfin"), type = ResourcesType.plist},
		{ path = PathTool.getPlistImgForDownLoad("elfin","elfin_info_bg"), type = ResourcesType.single },
    }
end

function ElfinInfoWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end

	local container = self.root_wnd:getChildByName("container")
    self:playEnterAnimatianByObj(container, 2)
	self.con_size = container:getContentSize()
	self.container = container
	self.con_size = container:getContentSize()

	container:getChildByName("skill_title"):setString(TI18N("携带技能"))
	self.elfin_sp = container:getChildByName("elfin_sp")
	self.name_txt = container:getChildByName("name_txt")
	self.type_name = container:getChildByName("type_name")
	self.type_name:setZOrder(99)
	self.type_txt = container:getChildByName("type_txt")
	self.type_txt:setZOrder(100)
	self.stage_node = container:getChildByName("stage_node")
	self.skill_name_txt = container:getChildByName("skill_name_txt")
	self.skill_type_txt = container:getChildByName("skill_type_txt")
	self.close_btn = container:getChildByName("close_btn")
	container:getChildByName("score_title"):setString(TI18N("评分："))
	self.power_label = CommonNum.new(1, container, 1, - 2, cc.p(0, 0))
    self.power_label:setPosition(cc.p(290, 412))
    self.power_label:setNum(0)
	self.power_label:setScale(0.8)
	self.skill_desc_scroll = createScrollView(340, 200, 172, 250, container, ccui.ScrollViewDir.vertical)
	self.skill_desc_scroll:setAnchorPoint(cc.p(0, 1))
end

function ElfinInfoWindow:register_event(  )
	registerButtonEventListener(self.background, function (  )
		_controller:openElfinInfoWindow(false)
	end, false, 2)

	registerButtonEventListener(self.close_btn, function (  )
		_controller:openElfinInfoWindow(false)
	end, true, 1)
end

function ElfinInfoWindow:openRootWnd( data )
	self:setData(data)
end

function ElfinInfoWindow:setData( data )
	if not data then return end

	local elfin_cfg = Config.SpriteData.data_elfin_data(data.id)

	if not elfin_cfg then return end

	-- 名称
	self.name_txt:setString(data.name or "")
	self.power_label:setNum(changeBtValueForPower(elfin_cfg.power))
	-- 阶数
	local elfin_item_cfg = Config.ItemData.data_get_data(data.id)
	if elfin_item_cfg then
		self:showElfinStep(elfin_item_cfg.eqm_jie)
		self:showBottomEffect(true, elfin_item_cfg.quality)
		local color = cc.c4b(0x84,0xde,0xfc,0xff)
		local color2 = cc.c4b(0x1c,0x2d,0x5f,0xff)
		local type = TI18N("普通")
    	if elfin_item_cfg.quality >= BackPackConst.quality.orange then
			color = cc.c4b(0xff,0xef,0xb2,0xff)
			color2 = cc.c4b(0x84,0x3e,0x23,0xff)
			type = TI18N("稀有")
    	elseif elfin_item_cfg.quality == BackPackConst.quality.purple then
			color = cc.c4b(0xe2,0xcd,0xff,0xff)
			color2 = cc.c4b(0x51,0x35,0x7f,0xff)
			type = TI18N("优良")
		end
		self.type_txt:setString(type)
		self.type_name:setTextColor(color)
		self.type_name:enableOutline(color2, 2)
		self.type_name:setString("- "..elfin_item_cfg.use_desc)
	end

	-- 模型
	--local effect_id = elfin_cfg.effect_id or "E70001"
	--if not self.elfin_spine then
	--	local offset_y = tonumber(elfin_cfg.offset_y) or 0
	--	self.elfin_spine = createEffectSpine( effect_id, cc.p(self.con_size.width*0.5, 470+offset_y), cc.p(0.5, 0), true, PlayerAction.stand )
	--	self.container:addChild(self.elfin_spine)
	--end
	--if elfin_cfg.scale_val and elfin_cfg.scale_val > 0 then
	--	self.elfin_spine:setScale(elfin_cfg.scale_val)
	--end
	local res = PathTool.getElfinRes(elfin_cfg.res_id)
	loadSpriteTexture(self.elfin_sp, res, LOADTEXT_TYPE)

	-- 技能图标
	if not self.skill_item then
		self.skill_item = SkillItem.new(true, true, true, 0.8, true)
		self.skill_item:setPosition(cc.p(110, 255))
		self.container:addChild(self.skill_item)
	end
	if elfin_cfg.skill then
		local skill_cfg = Config.SkillData.data_get_skill(elfin_cfg.skill)
		if skill_cfg then
			self.skill_item:setData(skill_cfg)
			self.skill_name_txt:setString(skill_cfg.name .. "Lv." .. skill_cfg.level)
			if skill_cfg.type == "active_skill" then 
		        self.skill_type_txt:setString(TI18N("类型：主动"))
		    else 
		        self.skill_type_txt:setString(TI18N("类型：被动")) 
		    end

		    -- 描述
			if not self.desc_txt then
				self.desc_txt = createRichLabel(22, Config.ColorData.data_new_color4[6], cc.p(0, 1), cc.p(0, 0), 5, nil, 340)
				self.skill_desc_scroll:addChild(self.desc_txt)
			end
			self.desc_txt:setString(skill_cfg.des)
		    local desc_size = self.desc_txt:getSize()
		    local max_height = math.max(desc_size.height, 200)
		    self.desc_txt:setPositionY(max_height)
    		self.skill_desc_scroll:setInnerContainerSize(cc.size(self.skill_desc_scroll:getContentSize().width, max_height))
    		self.skill_desc_scroll:setTouchEnabled(desc_size.height > 100)
		end
	end
end

function ElfinInfoWindow:showElfinStep( step_num )
	local width = 25
    local x = self.con_size.width * 0.5 - step_num * width * 0.5 + width * 0.5
   
    for i=1,step_num do
        if not self.elfin_step_list[i] then 
        	local res = PathTool.getResFrame("common","common_90032")
            local step_icon = createImage(self.container,res,0,0,cc.p(0.5,0.5),true,0,false)
            self.elfin_step_list[i] = step_icon
        end
        self.elfin_step_list[i]:setVisible(true)
        self.elfin_step_list[i]:setPosition(x + (i-1) * width, 785)
    end
end

-- 底盘特效
function ElfinInfoWindow:showBottomEffect( status, quality )
	if status == false then
        if self.bottom_effect then
            self.bottom_effect:clearTracks()
            self.bottom_effect:removeFromParent()
            self.bottom_effect = nil
        end
    else
    	local action = PlayerAction.action_1
    	quality = quality or 0
    	if quality >= BackPackConst.quality.orange then
    		action = PlayerAction.action_3
    	elseif quality == BackPackConst.quality.purple then
    		action = PlayerAction.action_2
    	end
        if not tolua.isnull(self.stage_node) and self.bottom_effect == nil then
            --self.bottom_effect = createEffectSpine(Config.EffectData.data_effect_info[1354], cc.p(0, -40), cc.p(0.5, 0), true, action)
            --self.stage_node:addChild(self.bottom_effect)
        end
    end
end

function ElfinInfoWindow:close_callback(  )
	self:showBottomEffect(false)
	if self.power_label then
        self.power_label:DeleteMe()
        self.power_label = nil
	end
	
	if self.skill_item then
		self.skill_item:DeleteMe()
		self.skill_item = nil
	end
	--if self.elfin_spine then
	--	self.elfin_spine:clearTracks()
	--	self.elfin_spine:removeFromParent()
	--	self.elfin_spine = nil
	--end
	_controller:openElfinInfoWindow(false)
end