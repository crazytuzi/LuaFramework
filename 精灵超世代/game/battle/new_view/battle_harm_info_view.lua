--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2018-12-27 10:22:52
-- @description    : 
		-- 战斗伤害统计面板
---------------------------------
BattleHarmInfoView = BattleHarmInfoView or BaseClass(BaseView)

local _controller = BattleController:getInstance()

local Harm_Type = {
    Harm = 1,  -- 伤害
    Cure = 2   -- 治疗
}

local Dir_Type = {
	Left = 1,  -- 左边宝可梦
	Right = 2  -- 右边宝可梦
}

function BattleHarmInfoView:__init(data)
	self.win_type = WinType.Mini
	self.layout_name = "battle/battle_harm_info_view"
	self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.is_full_screen = false

	self.res_list = {
		{ path = PathTool.getPlistImgForDownLoad("battleharm", "battleharm"), type = ResourcesType.plist },
		{ path = PathTool.getPlistImgForDownLoad("battle", "battle"), type = ResourcesType.plist },
	}

	self.tab_list = {}
	self.left_role_list = {}
	self.right_role_list = {}
end

function BattleHarmInfoView:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    local container = self.root_wnd:getChildByName("container")

    self.left_name_label = container:getChildByName("left_name_label")
    self.right_name_label = container:getChildByName("right_name_label")
    self.left_role_panel = container:getChildByName("left_role_panel")
    self.right_role_panel = container:getChildByName("right_role_panel")

    self.close_btn = container:getChildByName("close_btn")
    local close_btn_label = self.close_btn:getChildByName("label")
    close_btn_label:setString(TI18N("确  定"))

    local tab_container = container:getChildByName("tab_container")
    for i=1,2 do
		local object = {}
        local tab_btn = tab_container:getChildByName("tab_btn_"..i)
        if tab_btn then
            local title = tab_btn:getChildByName("title")
            object.tab_btn = tab_btn
			object.label = title
			object.index = i
            self.tab_list[i] = object

            if i == 1 then
                title:setString(TI18N("伤害量"))
                self.tab_object = object
            elseif i == 2 then
                title:setString(TI18N("治疗量"))
            end
        end
    end


    local head_name_list ={
        [1] = TI18N("第1场"),
        [2] = TI18N("第2场"),
        [3] = TI18N("第3场"),
        [4] = TI18N("第4场"),
        [5] = TI18N("第5场")
    }
    self.tab_btn_obj = container:getChildByName("tab_btn")
    self.head_tab_list = {}
    for i=1,5 do
        local tab_btn = {}
        local item = self.tab_btn_obj:getChildByName("tab_btn_"..i)
        tab_btn.btn = item
        tab_btn.index = i
        tab_btn.select_bg = item:getChildByName("select_img")
        tab_btn.select_bg:setVisible(false)
        tab_btn.title = item:getChildByName("label")
        if head_name_list[i] then
            tab_btn.title:setString(head_name_list[i])
        end
        -- tab_btn.title:setTextColor(cc.c4b(0xf5, 0xe0, 0xb9, 0xff))
        tab_btn.is_hide = true
        tab_btn.btn:setVisible(false)
        
        self.head_tab_list[i] = tab_btn
    end

end

function BattleHarmInfoView:register_event(  )
	registerButtonEventListener(self.close_btn, handler(self, self._onClickCloseBtn), true, 2)
	registerButtonEventListener(self.background, handler(self, self._onClickCloseBtn), false, 2)

	for k, object in pairs(self.tab_list) do
		if object.tab_btn then
			object.tab_btn:addTouchEventListener(function(sender, event_type)
				if event_type == ccui.TouchEventType.ended then
					playTabButtonSound()
					self:changeSelectedTab(object.index)
				end
			end)
		end
    end

    for i,tab_btn in ipairs(self.head_tab_list) do
        registerButtonEventListener(tab_btn.btn, function() self:changeSelectedHeadTab(tab_btn.index) end, false, 2)
    end
end

--@is_show_tab 页签数量
function BattleHarmInfoView:openRootWnd( data, is_show_tab)
    
    if is_show_tab then
        self:initHeadTabInfo(data)
    else
    	self:setData(data)
        self.tab_btn_obj:setVisible(false)
    end
end

function BattleHarmInfoView:initHeadTabInfo(data)
    local tab_count = #data
    if tab_count > 1 then
        self.data_list = data
        self.tab_btn_obj:setVisible(true)
        for i=1,tab_count do
            if self.head_tab_list[i]  then
                self.head_tab_list[i].btn:setVisible(true)
                if data[i] and data[i].round then
                	self.head_tab_list[i].title:setString(string.format(TI18N("第%d场"), data[i].round))
                end
            end
        end
        self:changeSelectedHeadTab(1)
    else
        self.tab_btn_obj:setVisible(false)
        self:setData(data[1])
    end
end

function BattleHarmInfoView:setData( data )
	if data and data.hurt_statistics then
		self.data = data
		-- 名称
		local role_vo = RoleController:getInstance():getRoleVo()
		local left_name = data.atk_name or role_vo.name
		self.left_name_label:setString(left_name)
		self.right_name_label:setString(data.target_role_name or data.def_name or "")

		local left_hero_data = {}
		local right_hero_data = {}
		for k,v in pairs(data.hurt_statistics) do
			if v.type == 1 then
				left_hero_data = v.partner_hurts
			elseif v.type == 2 then
				right_hero_data = v.partner_hurts
			end
		end

		local left_max_harm = 0
		local left_max_cure = 0
		for k,v in pairs(left_hero_data) do
			if v.dps > left_max_harm then
				left_max_harm = v.dps
			end
			if v.cure > left_max_cure then
				left_max_cure = v.cure
			end
		end

		local right_max_harm = 0
		local right_max_cure = 0
		for k,v in pairs(right_hero_data) do
			if v.dps > right_max_harm then
				right_max_harm = v.dps
			end
			if v.cure > right_max_cure then
				right_max_cure = v.cure
			end
		end

		for k,v in pairs(self.left_role_list) do
			v:setVisible(false)
		end
		for k,v in pairs(self.right_role_list) do
			v:setVisible(false)
		end
		-- 宝可梦列表
		local start_y = self.left_role_panel:getContentSize().height
		local space_y = 0
		-- 左侧
		for i,l_data in ipairs(left_hero_data) do
			delayRun(
	            self.left_role_panel, i*4 / display.DEFAULT_FPS, function()
	                local role_item = self.left_role_list[i]
					if role_item == nil then
						role_item = BattleHarmInfoItem.new(Dir_Type.Left, data.vedio_id, data.srv_id, data.combat_type)
						self.left_role_list[i] = role_item
						self.left_role_panel:addChild(role_item)
					end
					role_item:setVisible(true)
					local item_size = role_item:getContentSize()
					role_item:setPosition(cc.p(0, start_y-(i-1)*(item_size.height+space_y)))
					role_item:setData(l_data, left_max_harm, left_max_cure)
	            end
	        )
		end

		-- 右侧
		for i,r_data in ipairs(right_hero_data) do
			delayRun(
	            self.right_role_panel, i*4 / display.DEFAULT_FPS, function()
	                local role_item = self.right_role_list[i]
					if role_item == nil then
						role_item = BattleHarmInfoItem.new(Dir_Type.Right, data.vedio_id, data.srv_id, data.combat_type)
						self.right_role_list[i] = role_item
						self.right_role_panel:addChild(role_item)
					end
					role_item:setVisible(true)
					local item_size = role_item:getContentSize()
					role_item:setPosition(cc.p(0, start_y-(i-1)*(item_size.height+space_y)))
					role_item:setData(r_data, right_max_harm, right_max_cure)
	            end
	        )
		end
	end
end

function BattleHarmInfoView:changeSelectedTab( index )
	if self.tab_object and self.tab_object.index == index then return end
	if self.tab_object then
		self.tab_object.tab_btn:loadTextures(PathTool.getResFrame("battleharm","battleharm_1004"), "", "", LOADTEXT_TYPE_PLIST)
		self.tab_object.tab_btn:setCapInsets(cc.rect(12, 20 ,1, 1))
		self.tab_object.label:setTextColor(cc.c4b(245, 224, 185))
		self.tab_object = nil
	end
	self.tab_object = self.tab_list[index]
	if self.tab_object then
		self.tab_object.tab_btn:loadTextures(PathTool.getResFrame("battleharm","battleharm_1003"), "", "", LOADTEXT_TYPE_PLIST)
		self.tab_object.tab_btn:setCapInsets(cc.rect(12, 20 ,1, 1))
		self.tab_object.label:setTextColor(cc.c4b(105, 55, 5))
	end

	for i,role_item in ipairs(self.left_role_list) do
		role_item:updateHarmType(index)
	end
	for i,role_item in ipairs(self.right_role_list) do
		role_item:updateHarmType(index)
	end
end

function BattleHarmInfoView:changeSelectedHeadTab(index)
    if self.cur_tab_index == index then return end

    if self.cur_tab ~= nil then
        -- self.cur_tab.label:setTextColor(Config.ColorData.data_color4[141])
        self.cur_tab.select_bg:setVisible(false)
    end
    self.cur_tab_index = index
    self.cur_tab = self.head_tab_list[self.cur_tab_index]

    if self.cur_tab ~= nil then
        -- self.cur_tab.label:setTextColor(Config.ColorData.data_color4[180])
        self.cur_tab.select_bg:setVisible(true)
    end

    if self.data_list and self.data_list[index] then
        self.left_role_panel:stopAllActions()
        self.right_role_panel:stopAllActions()
        self:setData(self.data_list[index])
    end
end

function BattleHarmInfoView:_onClickCloseBtn(  )
	_controller:openBattleHarmInfoView(false)
end

function BattleHarmInfoView:close_callback(  )
	for k,v in pairs(self.left_role_list) do
		v:DeleteMe()
		v = nil
	end
	for k,v in pairs(self.right_role_list) do
		v:DeleteMe()
		v = nil
	end
	_controller:openBattleHarmInfoView(false)
end

-------------------------@ item
BattleHarmInfoItem = class("BattleHarmInfoItem", function()
    return ccui.Widget:create()
end)

--==============================--
--desc:
--time:2019-02-16 11:32:41
--@dir:左边还是右边
--@vedio_id:vedio_id 由录像大厅过来的 查看宝可梦详细需要用到的录像id
--@srv_id:srv_id 由录像大厅过来的 查看宝可梦详细需要用到
--@combat_type:combat_type 由录像大厅过来的 查看宝可梦详细需要用到
--@return 
--==============================--
function BattleHarmInfoItem:ctor(dir, vedio_id, srv_id, combat_type)
	self.role_dir = dir or Dir_Type.Left
	self.vedio_id = vedio_id or 0
	self.srv_id = srv_id
	self.combat_type = combat_type

	self:configUI()
	self:register_event()
end

function BattleHarmInfoItem:configUI(  )
	self.size = cc.size(300,99)
	self:setTouchEnabled(false)
	self:setAnchorPoint(cc.p(0, 1))
    self:setContentSize(self.size)

	local csbPath = PathTool.getTargetCSB("battle/battle_harm_info_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    local container = self.root_wnd:getChildByName("container")

    self.progress_bg = container:getChildByName("progress_bg")
    self.progress = self.progress_bg:getChildByName("progress")
    self.progress:setScale9Enabled(true)
    self.progress:setPercent(0)
    self.progress_value = self.progress_bg:getChildByName("progress_value")
    self.progress_value:setString(0)

    self.image_mvp = container:getChildByName("image_mvp")
    self.image_mvp:setVisible(false)

    self.hero_head = HeroExhibitionItem.new(0.7, true)
    self.hero_head:addCallBack(handler(self, self._onClickHeroCallBack))
    container:addChild(self.hero_head)

    if self.role_dir == Dir_Type.Left then
    	self.hero_head:setPosition(cc.p(50, self.size.height/2))
    	self.image_mvp:setPosition(cc.p(270, 72))
    	self.progress_bg:setPosition(cc.p(100, 40))
    	self.progress_value:setAnchorPoint(cc.p(0, 0.5))
    	self.progress_value:setPositionX(0)
    	self.progress:setPositionX(0)
    	self.progress:setScaleX(1)
    else
    	self.hero_head:setPosition(cc.p(self.size.width - 50, self.size.height/2))
    	self.image_mvp:setPosition(cc.p(self.size.width - 254, 72))
    	self.progress_bg:setPosition(cc.p(self.size.width - 184 - 100, 40))
    	self.progress_value:setAnchorPoint(cc.p(1, 0.5))
    	self.progress_value:setPositionX(184)
    	self.progress:setPositionX(184)
    	self.progress:setScaleX(-1)
    end
end

function BattleHarmInfoItem:register_event(  )
end

function BattleHarmInfoItem:_onClickHeroCallBack(  )
	if self.data and self.data.id and self.vedio_id and self.vedio_id ~= 0 then
		VedioController:getInstance():requestVedioHeroData(self.vedio_id, self.data.id, self.role_dir, self.srv_id, self.combat_type)
	elseif self.data and self.data.rid and self.data.rid ~= 0 and self.data.srvid and self.data.srvid ~= "" and self.data.id then
		local role_vo = RoleController:getInstance():getRoleVo()
		if role_vo.rid == self.data.rid and role_vo.srv_id == self.data.srvid then
			local hero_vo = HeroController:getInstance():getModel():getHeroById(self.data.id)
			HeroController:getInstance():openHeroTipsPanel(true, hero_vo)
		else
			LookController:getInstance():sender11061(self.data.rid, self.data.srvid, self.data.id)
		end
	else
		message(TI18N("该宝可梦来自异域，无法查看"))
	end
end

function BattleHarmInfoItem:setData( data, max_harm, max_cure )
	self.data = data

	local vo = HeroVo.New()
	if Config.PartnerData.data_partner_base[data.bid] then
		vo.bid = data.bid
		vo.star = data.star
	else
		local unit_config = Config.UnitData.data_unit(data.bid)
		if unit_config then
			vo.bid = tonumber(unit_config.head_icon)
            vo.master_head_id = vo.bid
			if unit_config.star and unit_config.star > 0 then
				vo.star = unit_config.star
			else
				local base_config = Config.PartnerData.data_partner_base[vo.bid]
				if base_config then
					vo.star = base_config.init_star
				end
			end
		end

	end
	vo.camp_type = data.camp_type
	vo.lev = data.lev
    if data.ext_data then
        for i,v in ipairs(data.ext_data) do
            if v.key == 5 then
                vo.use_skin = v.val
            end
        end
    end

	self.hero_head:setData(vo)

	self.max_harm_val = max_harm
    self.max_cure_val = max_cure

	self:updateHarmType()
end

function BattleHarmInfoItem:updateHarmType( harm_type )
	if self.data then
		self.harm_type = harm_type or Harm_Type.Harm

		self.total_val = 0
		self.cur_val = 0
		if self.harm_type == Harm_Type.Harm then
			self.image_mvp:setVisible(self.data.dps > 0 and self.data.dps == self.max_harm_val)
			self.total_val = self.max_harm_val
			self.cur_val = self.data.dps
		else
			self.image_mvp:setVisible(self.data.cure > 0 and self.data.cure == self.max_cure_val)
			self.total_val = self.max_cure_val
			self.cur_val = self.data.cure
		end

		self.temp_add = (self.cur_val/50)
		self.temp_harm_val = 0
		self.progress:setPercent(0)
		self.progress_value:setString(self.cur_val)
        self:openProgressTimer(false)
		self:openProgressTimer(true)
	end
end

function BattleHarmInfoItem:openProgressTimer( status )
	if status == true then
		if self.progress_timer == nil then
			self.progress_timer = GlobalTimeTicket:getInstance():add(function ()
				self.temp_harm_val = self.temp_harm_val + self.temp_add
				if self.temp_harm_val < self.cur_val then
					self.progress:setPercent((self.temp_harm_val/self.total_val)*100)
				else
					self.progress:setPercent((self.cur_val/self.total_val)*100)
					GlobalTimeTicket:getInstance():remove(self.progress_timer)
            		self.progress_timer = nil
				end
			end, 0.01)
		end
	else
		if self.progress_timer ~= nil then
            GlobalTimeTicket:getInstance():remove(self.progress_timer)
            self.progress_timer = nil
        end
	end
end

function BattleHarmInfoItem:DeleteMe(  )
	if self.hero_head then
		self.hero_head:DeleteMe()
		self.hero_head = nil
	end
	self:openProgressTimer(false)
	self:removeAllChildren()
	self:removeFromParent()
end