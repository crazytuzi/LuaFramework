--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-08-21 15:06:56
-- @description    : 
		-- 精灵tips
---------------------------------
ElfinTipsWindow = ElfinTipsWindow or BaseClass(BaseView)

local _string_format = string.format
local _controller = ElfinController:getInstance()
local _table_insert = table.insert

function ElfinTipsWindow:__init()
    self.is_full_screen = false
    self.title_str= ""
    self.layout_name = "tips/elfin_tips"
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("tips","tips"), type = ResourcesType.plist },
    }
    self.win_type = WinType.Tips   
    self.view_tag = ViewMgrTag.DIALOGUE_TAG 
end

function ElfinTipsWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end

    self.container = self.root_wnd:getChildByName("container")
    self.old_con_size = self.container:getContentSize()

    self.close_btn = self.container:getChildByName("close_btn")

    self.base_panel = self.container:getChildByName("base_panel")
    self.elfin_name = self.base_panel:getChildByName("name")
	self.base_panel:getChildByName("score_title"):setString(TI18N("评分："))
	self.power_label = CommonNum.new(1, self.base_panel, 1, - 2, cc.p(0, 0))
    self.power_label:setPosition(cc.p(230, 66))
    self.power_label:setNum(0)
	self.power_label:setScale(0.8)
	
    self.skill_panel = self.container:getChildByName("skill_panel")
    self.skill_panel:getChildByName("label"):setString(TI18N("精灵技能"))
    self.skill_icon = self.skill_panel:getChildByName("skill_icon")
    self.skill_name = self.skill_panel:getChildByName("name")
    self.skill_type = self.skill_panel:getChildByName("skill_type")
    self.skill_line = self.skill_panel:getChildByName("line")
    self.skill_line:setVisible(false)

    self.tab_panel = self.container:getChildByName("tab_panel")
    self.tab_list = {}
    for i=1,3 do
    	local tab_btn = self.tab_panel:getChildByName("tab_btn_" .. i)
    	if tab_btn then
    		_table_insert(self.tab_list, tab_btn)
    	end
    end
end

function ElfinTipsWindow:register_event(  )
	registerButtonEventListener(self.background, function (  )
		self:close()
	end, false, 2)

	registerButtonEventListener(self.close_btn, function (  )
		self:close()
	end, false, 2)

	for i,tab_btn in ipairs(self.tab_list) do
		registerButtonEventListener(tab_btn, function (  )
			self:onClickBtnByIndex(i)
		end, true)
	end
end

function ElfinTipsWindow:onClickBtnByIndex( index )
	if not self.elfin_bid then return end
	if index == 1 then -- 羽化
		local goods_vo = BackpackController:getModel():getBackPackItemByBid(self.elfin_bid)
		BackpackController:getInstance():openItemSellPanel(true, goods_vo, BackPackConst.Bag_Code.BACKPACK, 3)
	elseif index == 2 then -- 灵合
		ElfinController:getInstance():openElfinCompoundWindow(true, self.elfin_bid)
	elseif index == 3 then -- 附体
		MainuiController:getInstance():changeMainUIStatus(MainuiConst.btn_index.partner, HeroConst.BagTab.eElfin, ElfinConst.Tab_Index.Rouse)
	end
	self:close()
end

function ElfinTipsWindow:openRootWnd( elfin_bid, show_btn )
	self.elfin_bid = elfin_bid
	self.is_show_btn = show_btn or false
	self:setData(elfin_bid)
end

function ElfinTipsWindow:setData( elfin_bid )
	if not elfin_bid then return end

	local elfin_cfg = Config.SpriteData.data_elfin_data(elfin_bid)
	local elfin_item_cfg = Config.ItemData.data_get_data(elfin_bid)

	if not elfin_cfg or not elfin_item_cfg then return end

	self.power_label:setNum(elfin_cfg.power)

	-- 品质
	local quality = 0
    if elfin_item_cfg.quality >= 0 and elfin_item_cfg.quality <= 5 then
        quality = elfin_item_cfg.quality
    end
    local background_res = PathTool.getResFrame("tips", "tips_"..quality)
    loadSpriteTexture(self.base_panel, background_res, LOADTEXT_TYPE_PLIST)

    -- 名称
    local color = BackPackConst.getEquipTipsColor(quality)
    self.elfin_name:setTextColor(color) 
    self.elfin_name:setString(elfin_item_cfg.name)

    -- 图标
    if not self.elfin_item then
    	self.elfin_item = BackPackItem.new(false, false)
    	self.elfin_item:setPosition(cc.p(70, 69))
    	self.base_panel:addChild(self.elfin_item)
   	end
   	self.elfin_item:setData(elfin_item_cfg)

   	local new_height = self.old_con_size.height

   	-- 技能
   	if elfin_cfg.skill then
   		local skill_cfg = Config.SkillData.data_get_skill(elfin_cfg.skill)
   		if skill_cfg then
   			self.skill_name:setString(_string_format("%s Lv.%d", skill_cfg.name, skill_cfg.level))
   			if skill_cfg.type == "active_skill" then 
		        self.skill_type:setString(TI18N("类型：主动技能"))
		    else 
		        self.skill_type:setString(TI18N("类型：被动技能")) 
		    end
		    loadSpriteTexture(self.skill_icon, PathTool.getSkillRes(skill_cfg.icon), LOADTEXT_TYPE)

		    -- 技能描述
		   	local skill_start_pos_y = -85
		   	if not self.skill_desc then
		   		self.skill_desc = createRichLabel(22,cc.c4b(0xfe,0xee,0xba,0xff),cc.p(0,1),cc.p(22, skill_start_pos_y),4,nil,370)
		        self.skill_panel:addChild(self.skill_desc)
		   	end
		   	self.skill_desc:setString(skill_cfg.des)
		   	local skill_des_height = self.skill_desc:getContentSize().height
		   	new_height = new_height + skill_des_height + 10

		   	-- 冷却时间
		    if not self.extend_desc then
		    	self.extend_desc = createRichLabel(22,cc.c4b(0xff,0xee,0xdd,0xff),cc.p(0,1),cc.p(22,skill_start_pos_y-skill_des_height-10),nil,nil,370)
        		self.skill_panel:addChild(self.extend_desc)
		 	end
		 	local extend_str = ""
	        if skill_cfg.cd == 0 then
	            extend_str = TI18N("无冷却时间")
	        else
	            extend_str = _string_format("<div fontcolor=#ffeedd>%s</div><div fontcolor=#14ff32>%s</div><div fontcolor=#ffeedd>%s</div>", TI18N("冷却"),skill_cfg.cd, TI18N("回合") )
	        end
	        if skill_cfg.fire_cd ~= 0 then
	            extend_str = extend_str.._string_format("<div fontcolor=#ffeedd>%s</div><div fontcolor=#14ff32>%s</div><div fontcolor=#ffeedd>%s</div>", TI18N("，第"), skill_cfg.fire_cd, TI18N("回合释放")) 
	        end
	        self.extend_desc:setString(extend_str)
	        local extend_desc_height = self.extend_desc:getContentSize().height
	        new_height = new_height + extend_desc_height + 10

	        -- buff描述
	        local buff_desc_str = ""
		    if skill_cfg.buff_des ~= nil and skill_cfg.buff_des[1] and next(skill_cfg.buff_des[1]) then
		        local buff_config = Config.SkillData.data_get_buff 
		        for i, v in ipairs(skill_cfg.buff_des[1]) do
		            local config = buff_config[v]
		            if config then
		                if buff_desc_str ~= "" then
		                    buff_desc_str = buff_desc_str.."<div fontcolor=#a1978b>\n</div>"
		                end
		                local buff_desc = _string_format("<div fontcolor=#ffeedd>【%s】</div><div fontcolor=#a1978b>\n%s</div>", config.name, config.desc)
		                buff_desc_str = buff_desc_str..buff_desc
		            end
		        end
		    end
		    if buff_desc_str ~= "" then
		    	if self.buff_desc == nil then
		            self.buff_desc = createRichLabel(20,cc.c4b(0xff,0xee,0xdd,0xff),cc.p(0,1),cc.p(22,skill_start_pos_y-skill_des_height-extend_desc_height-20),4,nil,370)
		            self.skill_panel:addChild(self.buff_desc)
		        end
		        self.buff_desc:setString(buff_desc_str)
		        local buff_desc_height = self.buff_desc:getContentSize().height
		        new_height = new_height + buff_desc_height + 10

		        self.skill_line:setVisible(true)
		        self.skill_line:setPositionY(skill_start_pos_y-skill_des_height-extend_desc_height-15)
		    end
   		end
   	end

   	self.tab_panel:setVisible(self.is_show_btn)
   	if not self.is_show_btn then
   		new_height = new_height - 72
   	end

   	self.container:setContentSize(cc.size(self.old_con_size.width, new_height))
    self.base_panel:setPositionY(new_height-4)
    self.skill_panel:setPositionY(new_height-144)
    self.tab_panel:setPositionY(0)
    self.close_btn:setPositionY(new_height-15)

    -- 不可以合灵，按钮置灰
    if not Config.SpriteData.data_elfin_com[elfin_bid] and self.tab_list and self.tab_list[2] then
    	self.tab_list[2]:setTouchEnabled(false)
    	setChildUnEnabled(true, self.tab_list[2])
    end
end

function ElfinTipsWindow:close_callback(  )
	if self.power_label then
        self.power_label:DeleteMe()
        self.power_label = nil
	end
	
	if self.elfin_item then
		self.elfin_item:DeleteMe()
		self.elfin_item = nil
	end
end