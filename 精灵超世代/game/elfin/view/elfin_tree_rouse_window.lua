--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-08-20 16:28:05
-- @description    : 
		-- 精灵古树唤醒成功
---------------------------------
local _controller = ElfinController:getInstance()
local _model = _controller:getModel()
local _table_insert = table.insert
local _string_format = string.format

ElfinTreeRouseWindow = ElfinTreeRouseWindow or BaseClass(BaseView)

function ElfinTreeRouseWindow:__init()
	self.win_type = WinType.Tips
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.is_full_screen = false
	self.layout_name = "elfin/elfin_tree_rouse_window"
end

function ElfinTreeRouseWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end

	self.container = self.root_wnd:getChildByName("container")
    self:playEnterAnimatianByObj(self.container, 2)
	--self.success_bg = self.container:getChildByName("success_bg")
	--self.Sprite_1 = self.success_bg:getChildByName("Sprite_1")
	--if self.sprite_1_load == nil then
    --    local res = PathTool.getPlistImgForDownLoad("bigbg","bigbg_97")
    --    self.sprite_1_load = loadSpriteTextureFromCDN(self.Sprite_1, res, ResourcesType.single, self.sprite_1_load)
    --end
    --
    --self.Sprite_2 = self.success_bg:getChildByName("Sprite_2")
    --if self.sprite_2_load == nil then
    --    local res = PathTool.getPlistImgForDownLoad("bigbg","bigbg_98")
    --    self.sprite_2_load = loadSpriteTextureFromCDN(self.Sprite_2, res, ResourcesType.single, self.sprite_2_load)
    --end


	self.container:getChildByName("step_title"):setString(TI18N("唤醒阶段："))
	self.image_tree_icon = self.container:getChildByName("image_tree_icon")
	self.image_tree_icon:ignoreContentAdaptWithSize(true)
	self.image_tree_icon:setScale(0.35)
	self.step_txt = self.container:getChildByName("step_txt")

	local attr_panel = self.container:getChildByName("attr_panel")
	self.attr_objects = {}
	for i=1,5 do
		local object = {}
		object.attr_name = attr_panel:getChildByName("attr_label_key" .. i)
		object.attr_right_val = attr_panel:getChildByName("attr_label_right" .. i)
		_table_insert(self.attr_objects, object)
	end
end

function ElfinTreeRouseWindow:register_event(  )
	registerButtonEventListener(self.background, function (  )
		_controller:openElfinTreeRouseWindow(false)
	end, false, 2)
end

function ElfinTreeRouseWindow:openRootWnd( data, new_data )
	self:handleEffect(true)
	self:setData(data, new_data)
	playOtherSound("c_get")
end

function ElfinTreeRouseWindow:setData( old_data, new_data )
	if not old_data or not new_data then return end

	local cur_step = old_data.break_lev
	local cur_step_cfg = Config.SpriteData.data_tree_step[cur_step]
	local next_step_cfg = Config.SpriteData.data_tree_step[cur_step+1]
	if not cur_step_cfg or not next_step_cfg then return end

	local tree_bg_res = PathTool.getElfinTreeBgRes(next_step_cfg.res_id)
	self.tree_bg_load = loadImageTextureFromCDN(self.image_tree_icon, tree_bg_res, ResourcesType.single, self.tree_bg_load)

	self.step_txt:setString(StringUtil.numToChinese(next_step_cfg.count) .. TI18N("阶"))

	for i=1,5 do
		local object = self.attr_objects[i]
		if object then
			if i == 1 then
				object.attr_name:setString(TI18N("等级上限： ") .. cur_step_cfg.lev_max)
				object.attr_right_val:setString(next_step_cfg.lev_max)
			else
				local attr_data = next_step_cfg.all_attr[i-1]
				if attr_data then
					local attr_key = attr_data[1]
					local next_attr_val = new_data[attr_key] or 0
					local cur_attr_val = old_data[attr_key] or 0
					local attr_name = Config.AttrData.data_key_to_name[attr_key]
					object.attr_name:setString(_string_format(TI18N("%s： %s"), attr_name, cur_attr_val))
					object.attr_right_val:setString(next_attr_val)
				end
			end
		end
	end
end

-- 播放特效
function ElfinTreeRouseWindow:handleEffect(status)
    if status == false then
        if self.play_effect then
            self.play_effect:clearTracks()
            self.play_effect:removeFromParent()
            self.play_effect = nil
        end
    else
        if not tolua.isnull(self.container) and self.play_effect == nil then
            self.play_effect = createEffectSpine(PathTool.getEffectRes(103), cc.p(360, 500), cc.p(0.5, 0.5), false, PlayerAction.action_6)
            self.container:addChild(self.play_effect, 99)
        end
    end
end 

function ElfinTreeRouseWindow:close_callback(  )
	if self.tree_bg_load then
		self.tree_bg_load:DeleteMe()
		self.tree_bg_load = nil
	end

	if self.sprite_1_load then
        self.sprite_1_load:DeleteMe()
        self.sprite_1_load = nil
    end

    if self.sprite_2_load then
        self.sprite_2_load:DeleteMe()
        self.sprite_2_load = nil
	end
	
	self:handleEffect(false)
	_controller:openElfinTreeRouseWindow(false)
end