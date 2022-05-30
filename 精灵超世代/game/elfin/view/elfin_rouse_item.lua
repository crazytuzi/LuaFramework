--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2019-08-19 19:36:56
-- @description    : 
		-- 功能描述
---------------------------------
local _controller = ElfinController:getInstance()
local _model = _controller:getModel()
local _string_format = string.format

ElfinRouseItem = class("ElfinRouseItem", function()
    return ccui.Widget:create()
end)

function ElfinRouseItem:ctor()
	self:configUI()
	self:register_event()

	self.elfin_step_list = {}
end

function ElfinRouseItem:configUI(  )
	self.size = cc.size(80, 80)
	self:setTouchEnabled(false)
    self:setContentSize(self.size)

	local csbPath = PathTool.getTargetCSB("elfin/elfin_rouse_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)

    local container = self.root_wnd:getChildByName("container")
    self.container = container

    self.pos_node = container:getChildByName("pos_node")
    self.pos_icon = container:getChildByName("pos_icon")
    self.image_bottom = container:getChildByName("image_bottom")
    self.pos_bg_sp = container:getChildByName("pos_bg_sp")
    self.lock_sp = container:getChildByName("lock_sp")

    self.add_btn = container:getChildByName("add_btn")

    self.pos_txt = container:getChildByName("pos_txt")
	self.lock_txt = container:getChildByName("lock_txt")
end

function ElfinRouseItem:register_event(  )
	registerButtonEventListener(self.add_btn, function (  )
		self:onClickAddBtn()
	end, true)

	registerButtonEventListener(self.container, function (  )
		self:onClickItem()
	end, true)
end

function ElfinRouseItem:onClickAddBtn(  )
	_controller:openElfinChooseWindow(true, {elfin_pos = self.elfin_pos})
end

function ElfinRouseItem:onClickItem(  )
	if self.is_lock and self.need_step then
		message(_string_format(TI18N("古树达到%s阶解锁"), StringUtil.numToChinese(self.need_step)))
		return
	end
	-- 当前位置没放精灵，或者精灵不可合灵（达到最大等级）时，直接打开精灵选择界面
	if self.elfin_bid == 0 or not Config.SpriteData.data_elfin_com[self.elfin_bid] then
		local setting = {}
		setting.elfin_pos = self.elfin_pos
		if self.elfin_bid ~= 0 then
			setting.elfin_bid = self.elfin_bid
		end
		_controller:openElfinChooseWindow(true, setting)
		
	else
		_controller:openElfinCompoundWindow(true, self.elfin_bid, self.elfin_pos)
	end
end

function ElfinRouseItem:setData( data )
	if not data then return end

	local elfin_bid = data.elfin_bid
	local elfin_pos = data.elfin_pos or 1
	local need_step = data.need_step or 1

	self:checkShowHigherEffect(elfin_bid)

	self.elfin_bid = elfin_bid
	self.elfin_pos = elfin_pos
	self.need_step = need_step

	self.is_lock = true
	if elfin_bid then
		self.is_lock = false
	end
	self:handleEffect(not self.is_lock)
	self:showElfinStep(false)

	if not elfin_bid then -- 未解锁
		if self.icon_clipNode then
			self.icon_clipNode:setVisible(false)
		end
		self.pos_bg_sp:setVisible(false)
		self.add_btn:setVisible(false)
		self.pos_txt:setVisible(false)
		self.image_bottom:setVisible(true)
		self.lock_sp:setVisible(true)
		self.lock_txt:setVisible(true)
		self.lock_txt:setString(_string_format(TI18N("%s阶解锁"), StringUtil.numToChinese(need_step)))
	else
		self.pos_txt:setString(elfin_pos)
		self.lock_sp:setVisible(false)
		self.pos_bg_sp:setVisible(true)
		self.pos_txt:setVisible(true)

		local elfin_cfg = Config.SpriteData.data_elfin_data(elfin_bid)
		if elfin_bid == 0 or not elfin_cfg then -- 已解锁，但未放置
			self.add_btn:setVisible(true)
			self.image_bottom:setVisible(false)
			self.lock_txt:setVisible(false)
			if self.icon_clipNode then
				self.icon_clipNode:setVisible(false)
			end
		else
			self.cur_elfin_cfg = elfin_cfg
			self.add_btn:setVisible(false)
			local item_cfg = Config.ItemData.data_get_data(elfin_bid)
			if item_cfg then
				-- 遮罩
				if not self.icon_clipNode then
					local mask_bg = createSprite(PathTool.getResFrame("elfin", "elfin_1012"), 40, 40, nil, cc.p(0.5, 0.5))
					self.icon_clipNode = cc.ClippingNode:create(mask_bg)
					self.icon_clipNode:setAnchorPoint(cc.p(0.5,0.5))
					self.icon_clipNode:setContentSize(cc.size(80, 80))
					self.icon_clipNode:setCascadeOpacityEnabled(true)
					self.icon_clipNode:setAlphaThreshold(0)
					self.pos_icon:addChild(self.icon_clipNode)

					self.image_icon = createImage(self.icon_clipNode, nil, 40, 40, cc.p(0.5, 0.5), false)
					self.image_icon:setScale(0.7)
				end
				self.icon_clipNode:setVisible(true)
				local item_res = PathTool.getItemRes(item_cfg.icon)
				self.image_icon:loadTexture(item_res, LOADTEXT_TYPE)
				self:showElfinStep(true, item_cfg.eqm_jie)
				self.lock_txt:setString(item_cfg.name)
				self.image_bottom:setVisible(true)
				self.lock_txt:setVisible(true)
			end
		end
	end

	self:updateResStatus()
end

function ElfinRouseItem:updateResStatus(  )
	local red_status = false
	if self.elfin_bid and self.elfin_bid == 0 and _model:getElfinRedStatusByRedBid(HeroConst.RedPointType.eElfin_empty_pos) then
		red_status = true
	elseif self.elfin_bid and self.cur_elfin_cfg then
		-- 是否可以合成
		local elfin_com_cfg = Config.SpriteData.data_elfin_com[self.elfin_bid]
		if elfin_com_cfg and elfin_com_cfg.expend and next(elfin_com_cfg.expend) ~= nil then
			red_status = true
			for _,v in pairs(elfin_com_cfg.expend) do
				local need_num = v[2]
				local have_num = BackpackController:getInstance():getModel():getItemNumByBid(v[1])
				if have_num < need_num then
					red_status = false
				end
			end
		end
		if red_status == false then
			-- 是否有更高阶的同类精灵
			local all_elfin_data = BackpackController:getInstance():getModel():getAllBackPackArray(BackPackConst.item_tab_type.ELFIN) or {}
			for k,v in pairs(all_elfin_data) do
				local elfin_cfg = Config.SpriteData.data_elfin_data(v.base_id)
				if elfin_cfg then
					if elfin_cfg.sprite_type == self.cur_elfin_cfg.sprite_type and elfin_cfg.step > self.cur_elfin_cfg.step then
						red_status = true
						break
					end
				end
			end
		end
	end
	addRedPointToNodeByStatus(self.container, red_status)
end

function ElfinRouseItem:showElfinStep( status, step_num )
	for k,v in pairs(self.elfin_step_list) do
		v:setVisible(false)
	end
	if status == true then
		local width = 15
	    local x = self.size.width * 0.5 - step_num * width * 0.5 + width * 0.5
	   
	    for i=1,step_num do
	        if not self.elfin_step_list[i] then 
	        	local res = PathTool.getResFrame("common","common_90032")
	            local step_icon = createImage(self.container,res,0,0,cc.p(0.5,0.5),true,0,false)
	            self.elfin_step_list[i] = step_icon
	        end
	        self.elfin_step_list[i]:setVisible(true)
	        self.elfin_step_list[i]:setPosition(x + (i-1) * width, 5)
	    end
	end
end

function ElfinRouseItem:handleEffect( status )
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

function ElfinRouseItem:checkShowHigherEffect( bid )
	if not bid or bid == 0 then return end

	if self.elfin_bid and self.elfin_bid == 0 then
		self:showHigherEffect(true)
	else
		local new_elfin_cfg = Config.SpriteData.data_elfin_data(bid)
		local old_elfin_cfg = Config.SpriteData.data_elfin_data(self.elfin_bid)
		if new_elfin_cfg and old_elfin_cfg and new_elfin_cfg.step > old_elfin_cfg.step then
			self:showHigherEffect(true)
		end
	end
end

function ElfinRouseItem:showHigherEffect( status )
	if status == false then
        if self.higher_effect then
            self.higher_effect:clearTracks()
            self.higher_effect:removeFromParent()
            self.higher_effect = nil
        end
    else
        if not tolua.isnull(self.container) and self.higher_effect == nil then
            self.higher_effect = createEffectSpine(PathTool.getEffectRes(185), cc.p(self.size.width*0.5, self.size.height*0.5), cc.p(0.5, 0.5), false, PlayerAction.action)
            self.higher_effect:setScale(0.5)
            self.container:addChild(self.higher_effect)
        elseif self.higher_effect then
        	self.higher_effect:setToSetupPose()
        	self.higher_effect:setAnimation(0, PlayerAction.action, false)
        end
        playOtherSound("c_levelup")
    end
end

function ElfinRouseItem:DeleteMe(  )
	self:handleEffect(false)
	self:showHigherEffect(false)
	self:removeAllChildren()
	self:removeFromParent()
end