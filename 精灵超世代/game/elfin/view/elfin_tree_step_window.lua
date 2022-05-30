--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-08-20 14:06:52
-- @description    : 
		-- 精灵古树唤醒（进阶）界面
---------------------------------
local _controller = ElfinController:getInstance()
local _model = _controller:getModel()
local _table_insert = table.insert
local _string_format = string.format

ElfinTreeStepWindow = ElfinTreeStepWindow or BaseClass(BaseView)

function ElfinTreeStepWindow:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Mini   
    self.is_full_screen = false
    self.layout_name = "elfin/elfin_tree_step_window"

    self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("elfin", "elfin"), type = ResourcesType.plist},
        {path = PathTool.getPlistImgForDownLoad("bigbg","bigbg_3"), type = ResourcesType.single },
	}
	self.role_vo = RoleController:getInstance():getRoleVo()
	self.cost_item_list = {}
	self.cost_item_bid_list = {}
end

function ElfinTreeStepWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end

    self.main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(self.main_container, 2)

    self.main_container:getChildByName("win_title"):setString(TI18N("唤醒"))

    self.image_bg_pos = self.main_container:getChildByName("image_bg_pos")
    self.elfin_panel = self.main_container:getChildByName("elfin_panel")
    self.elfin_panel:getChildByName("label_title"):setString(TI18N("解锁槽位"))
    self.elfin_pos_txt = self.elfin_panel:getChildByName("pos_txt")
    self.pos_node = self.elfin_panel:getChildByName("pos_node")
    self.lock_txt = self.elfin_panel:getChildByName("lock_txt")

    local attr_panel = self.main_container:getChildByName("attr_panel")
    self.attr_objects = {}
    for i=1,5 do
    	local object = {}
    	object.attr_icon = attr_panel:getChildByName("attr_icon" .. i)
    	object.attr_name = attr_panel:getChildByName("attr_label_key" .. i)
    	object.attr_left_val = attr_panel:getChildByName("attr_label_left" .. i)
    	object.attr_right_val = attr_panel:getChildByName("attr_label_right" .. i)
    	_table_insert(self.attr_objects, object)
    end

    self.break_btn = self.main_container:getChildByName("break_btn")
	self.break_btn_lab = self.break_btn:getChildByName("label")
	self.break_btn_lab:setString(TI18N("唤醒"))
	
    self.get_egg_txt = createRichLabel(22, Config.ColorData.data_new_color4[6], cc.p(0.5, 0.5), cc.p(552, 100))
    self.main_container:addChild(self.get_egg_txt)
    self.get_egg_txt:setString(_string_format(TI18N("<div href=xxx >前往获取</div><img src='%s'/>"), PathTool.getResFrame("common","common_90017")))
    self.get_egg_txt:addTouchEventListener(function (  )
        local egg_buy_cfg = Config.SpriteData.data_const["awake_gain"]
		if egg_buy_cfg and egg_buy_cfg.val then
			local item_config = Config.ItemData.data_get_data(egg_buy_cfg.val)
			if item_config then
	            BackpackController:getInstance():openTipsOnlySource(true, item_config)
	        end
		end
    end)
end

function ElfinTreeStepWindow:register_event(  )
	registerButtonEventListener(self.background, function (  )
		_controller:openElfinTreeStepWindow(false)
	end, false, 2)

	registerButtonEventListener(self.break_btn, function (  )
		if self.open_lev and self.role_vo and self.open_lev > self.role_vo.lev then
			message(_string_format(TI18N("需要角色等级达到%d级"),self.open_lev))
			return
		end
		_controller:sender26512()
		_controller:openElfinTreeStepWindow(false)
	end, true)

	-- 物品数量变化
    self:addGlobalEvent(BackpackEvent.ADD_GOODS, function(bag_code, item_list)
    	if bag_code ~= BackPackConst.Bag_Code.BACKPACK then return end
		self:checkNeedUpdateItemNum(item_list)
    end)
    self:addGlobalEvent(BackpackEvent.DELETE_GOODS, function(bag_code, item_list)
    	if bag_code ~= BackPackConst.Bag_Code.BACKPACK then return end
		self:checkNeedUpdateItemNum(item_list)
    end)
    self:addGlobalEvent(BackpackEvent.MODIFY_GOODS_NUM, function(bag_code, item_list)
    	if bag_code ~= BackPackConst.Bag_Code.BACKPACK then return end
		self:checkNeedUpdateItemNum(item_list)
    end)
end

function ElfinTreeStepWindow:checkNeedUpdateItemNum( item_list )
	if item_list == nil or next(item_list) == nil then return end
	local is_have = false
    for k, v in pairs(item_list) do
        if v.config then
            for _,bid in pairs(self.cost_item_bid_list) do
            	if bid == v.config.id then
            		is_have = true
            		break
            	end
            end
        end
        if is_have then
        	break
        end
    end
    if is_have then
    	self:updateCostItemNum()
    end
end

function ElfinTreeStepWindow:openRootWnd(  )
	self:setData()

	local red_status = _model:getElfinRedStatusByRedBid(HeroConst.RedPointType.eElfin_tree_lvup)
	addRedPointToNodeByStatus(self.break_btn, red_status, 10, 10)
end

function ElfinTreeStepWindow:updateOpenLev(  )
	if not self.cur_step_cfg then
		return
	end

	local temp_list =  self.cur_step_cfg.step_cond
	for k,v in pairs(temp_list) do
		if v[1] == "role_lev" then
			self.open_lev = v[2]
		end
	end
	if self.open_lev and self.role_vo and self.open_lev > self.role_vo.lev then
		self.break_btn_lab:setString(_string_format( TI18N("%d级唤醒"),self.open_lev ))
		setChildUnEnabled(true, self.break_btn)
	else
		self.break_btn_lab:setString(TI18N("唤醒"))
		setChildUnEnabled(false, self.break_btn)
	end
	
end

function ElfinTreeStepWindow:setData(  )
	local elfin_tree_data = _model:getElfinTreeData()

	if not elfin_tree_data or next(elfin_tree_data) == nil then return end

	local cur_lev = elfin_tree_data.lev
	local cur_step = elfin_tree_data.break_lev
	local cur_step_cfg = Config.SpriteData.data_tree_step[cur_step]
	local next_step_cfg = Config.SpriteData.data_tree_step[cur_step+1]
	if not cur_step_cfg or not next_step_cfg then return end

	self.cur_step_cfg = cur_step_cfg

	for i=1,5 do
		local object = self.attr_objects[i]
		if object then
			if i == 1 then
				object.attr_name:setString(TI18N("等级上限:"))
				object.attr_left_val:setString(cur_step_cfg.lev_max)
				object.attr_right_val:setString(next_step_cfg.lev_max)
			else
				local attr_data = next_step_cfg.all_attr[i-1]
				if attr_data then
					local attr_key = attr_data[1]
					local attr_val = attr_data[2]
					local cur_attr_val = elfin_tree_data[attr_key] or 0
					local attr_icon = PathTool.getAttrIconByStr(attr_key)
					local attr_name = Config.AttrData.data_key_to_name[attr_key]
					loadSpriteTexture(object.attr_icon, PathTool.getResFrame("common", attr_icon), LOADTEXT_TYPE_PLIST)
					object.attr_name:setString(attr_name)
					object.attr_left_val:setString(cur_attr_val)
					local next_attr_val = _model:getElfinTreeNextAttrVal(attr_key, cur_lev, cur_step+1)
					object.attr_right_val:setString(next_attr_val)
				end
			end
		end
	end

	-- 是否有解锁空位
	if next_step_cfg.skill_num > cur_step_cfg.skill_num then
		self.elfin_panel:setVisible(true)
		self.elfin_pos_txt:setString(next_step_cfg.skill_num)
		self.lock_txt:setString(_string_format(TI18N("%s阶解锁"), StringUtil.numToChinese(next_step_cfg.count)))
		self:handleEffect(true)
		commonShowEmptyIcon(self.image_bg_pos, false)
	else
		self:handleEffect(false)
		self.elfin_panel:setVisible(false)
		commonShowEmptyIcon(self.image_bg_pos, true, {text=TI18N("什么都没有"), scale=0.6})
	end

	-- 消耗
	for i,v in ipairs(cur_step_cfg.expend) do
		_table_insert(self.cost_item_bid_list, v[1])
	end
	self:updateCostItemNum()
	self:updateOpenLev()
end

function ElfinTreeStepWindow:updateCostItemNum(  )
	if not self.cur_step_cfg then return end

	for k,item in pairs(self.cost_item_list) do
		item:setVisible(false)
	end
	for i,v in ipairs(self.cur_step_cfg.expend) do
		local item_bid = v[1]
		local item_num = v[2]
		local item_node = self.cost_item_list[i]
		if not item_node then
			item_node = BackPackItem.new(true, true, nil, 0.9, nil, true)
			self.main_container:addChild(item_node)
			self.cost_item_list[i] = item_node
		end
		item_node:setPosition(cc.p(100 + (i-1)*120, 70))
		local item_cfg = Config.ItemData.data_get_data(item_bid)
		item_node:setData(item_cfg)
		local have_num = BackpackController:getInstance():getModel():getBackPackItemNumByBid(v[1])
		item_node:setNeedNum(item_num, have_num)
		item_node:setVisible(true)
	end
end

function ElfinTreeStepWindow:handleEffect( status )
	if status == false then
        if self.pos_effect then
            self.pos_effect:clearTracks()
            self.pos_effect:removeFromParent()
            self.pos_effect = nil
        end
    else
        if not tolua.isnull(self.pos_node) and self.pos_effect == nil then
            self.pos_effect = createEffectSpine(Config.EffectData.data_effect_info[1351], cc.p(0, 0), cc.p(0.5, 0.5), true, PlayerAction.action)
            self.pos_node:addChild(self.pos_effect)
        end
    end
end

function ElfinTreeStepWindow:close_callback(  )
	for k,item in pairs(self.cost_item_list) do
		item:DeleteMe()
		item = nil
	end
	self:handleEffect(false)
	_controller:openElfinTreeStepWindow(false)
end
