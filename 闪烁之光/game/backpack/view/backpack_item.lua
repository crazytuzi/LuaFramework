-- --------------------------------------------------------------------
-- 背包的通用物品 
-- 
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @editor: shiraho@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2017-xx-xx
-- --------------------------------------------------------------------
BackPackItem = class("BackPackItem", function() 
	return ccui.Layout:create()
end)

BackPackItem.Width = 119
BackPackItem.Height = 119

local role_vo = RoleController:getInstance():getRoleVo()

--==============================--
--desc:创建物品对象
--time:2018-06-05 04:41:34
--@is_other:是否是别人的,这个时候不需要处理宝石相关显示
--@click:是否可点击
--@show_red:这个参数废弃,现在红点显示主要是 setVisibleResPoint 这个函数
--@scale:缩放值
--@effect:点击时候是否要处理回弹效果
--@is_show_tips:是否显示tips
--@return 
--==============================--
function BackPackItem:ctor(is_other, click, show_red, scale, effect, is_show_tips, swallow_touch)
	self.is_other = is_other
	self.click = click
	if self.click == nil then -- 不传默认为可点击
		self.click = true
	end
	self.is_show_tips = is_show_tips or false
	self.scale = scale or 1
	self.swallow_touch = swallow_touch
	if effect == nil then
		effect = true
	end
	self.effect = effect
	self.show_check_box = false			-- 是否需要根据数据现在复选框
	self.forgehouse_select = false
	self.star_list = {}

	self.root_wnd = createCSBNote(PathTool.getTargetCSB("backpack/goods_item"))
    self.size = self.root_wnd:getContentSize()
    self:setAnchorPoint(cc.p(0.5, 0.5))
	self:setContentSize(self.size)
	self:setTouchEnabled(self.click)
	self:setCascadeOpacityEnabled(true)
	if self.scale ~= 1 then
		self:setScale(self.scale)
	end

	self.root_wnd:setAnchorPoint(0.5, 0.5)
	self.root_wnd:setPosition(self.size.width/2, self.size.height/2)
	self:addChild(self.root_wnd)

	self.main_container = self.root_wnd:getChildByName("main_container")
  	self.background = self.main_container:getChildByName("background")
	self.item_icon = self.main_container:getChildByName("icon")
	self.num_label = self.main_container:getChildByName("num")

	self.num_label:setString("")
	self.num_bg = self.main_container:getChildByName("num_bg")
	self.num_bg_size = self.num_bg:getContentSize()
	self.num_bg:setLocalZOrder(20)
	self.num_label:setLocalZOrder(21)

	self.background_res_id = PathTool.getQualityBg(0)

	self:registerEvent()
end

function BackPackItem:getBackground()
	return self.background
end
function BackPackItem:getRoot()
	return self.main_container
end

function BackPackItem:getSize()
	return self.size
end

function BackPackItem:getData()
	return self.data
end
--红点状态
function BackPackItem:createSpriteRedPoint()
	if not self.redpoint then
		local res = PathTool.getResFrame("common","common_1014")
		self.redpoint = createSprite(res,102,101,self.main_container,cc.p(0.5, 0.5),LOADTEXT_TYPE_PLIST,10)
		self.redpoint:setVisible(false)
	end
end
function BackPackItem:setVisibleResPoint(visible)
	if self.redpoint then
		self.redpoint:setVisible(visible)
	end
end

--选中
function BackPackItem:createSpriteMask()
	if not self.mask_imsge then
		local res = PathTool.getResFrame("common","common_90019")
		self.mask_imsge = createImage(self.main_container,res,self.main_container:getContentSize().width/2,self.main_container:getContentSize().height/2,
									  cc.p(0.5,0.5),true,10,true)
		self.mask_imsge:setVisible(false)
		self.mask_imsge:setContentSize(cc.size(BackPackItem.Width,BackPackItem.Height))

		-- local res = PathTool.getResFrame("common","common_1043")
		-- local sprite = createSprite(res,self.mask_imsge:getContentSize().width/2,self.mask_imsge:getContentSize().height/2,self.mask_imsge,cc.p(0.5, 0.5),LOADTEXT_TYPE_PLIST,10)
	end
end
function BackPackItem:setMaskVisible(visible)
	if self.mask_imsge then
		self.mask_imsge:setVisible(visible)
	end
end

--==============================--
--desc:设置选中状态
--time:2017-07-03 09:07:12
--@status:
--@return 
--==============================--
function BackPackItem:setSelected(status)
	if not self.select_bg and status == false then return end
	if not self.select_bg then 
		local res= PathTool.getSelectBg()
		self.select_bg = createImage(self.main_container, res, self.size.width/2,self.size.height/2, cc.p(0.5,0.5), true,nil,true)
		self.select_bg:setContentSize(cc.size(self.Width,self.Height))
	end
	self.select_bg:setVisible(status)
end

--==============================--
--desc:点击回调
--time:2017-07-03 08:02:23
--@callback:
--@return 
--==============================--
function BackPackItem:addCallBack(callback)
	self.callback = callback
end

function BackPackItem:updateScale(scale)
	self.scale = scale or 1
end

--添加长时间点击的回调
function BackPackItem:addLongTimeTouchCallback(callback)
    --默认有效果
    self:setLongTimeTouchEffect(true)
    self.long_time_callback = callback
end

--设置长时间点击的回调效果
function BackPackItem:setLongTimeTouchEffect(is_touch)
    self.have_long_time_effect = is_touch
end
--==============================--
--desc:注册相关事件
--time:2017-07-03 01:53:49
--@return 
--==============================--
function BackPackItem:registerEvent()
	if self.click == true then
		self:setTouchEnabled(true)
		self:addTouchEventListener(function(sender, event_type) 
			if self.effect == true then
				customClickAction_2(self.main_container, event_type)
			end
			if event_type == ccui.TouchEventType.ended then
				if self.have_long_time_effect then
                    if self.long_touch_type == LONG_TOUCH_BEGAN_TYPE then
                        doStopAllActions(self.background)
                        self.long_touch_type = LONG_TOUCH_CANCEL_TYPE
                    elseif self.long_touch_type == LONG_TOUCH_END_TYPE then
                        --事件触发了就不处理点击事件了
                        return
                    end
				end
				
				self.touch_end = sender:getTouchEndPosition()
				local is_click = true
				if self.touch_began ~= nil then
					is_click =
						math.abs(self.touch_end.x - self.touch_began.x) <= 20 and
						math.abs(self.touch_end.y - self.touch_began.y) <= 20
				end
				if is_click == true then
					playButtonSound2()
					if self.btn_call_fun then
						self:btn_call_fun()
					else
						if self.is_show_tips and self.data ~= nil then
							local bid = self.data.bid or self.data.base_id or self.data.id
							local type = 0
							if self.item_config then 
								type = self.item_config.type
							end
							if BackPackConst.checkIsEquip(type) then
								HeroController:getInstance():openEquipTips(true, self.data)
							elseif BackPackConst.checkoutIsWeekCard(type) then
								TipsManager:getInstance():showWeekCardTips(true,self.item_config)
							elseif BackPackConst.checkIsHeroSkin(type) then
								HeroController:getInstance():openHeroSkinTipsPanel(true, self.item_config)
							elseif BackPackConst.checkIsElfin(type) then -- 精灵
            					TipsManager:getInstance():showElfinTips(bid) 
							else
								local config
								if self.data.config then 
									config = self.data.config
								else
									config = Config.ItemData.data_get_data(bid)
								end
								-- 虽然显示物品来源,但是如果没有配置也不需要显示
								if self.is_show_source == true and config.source and next(config.source) then 
									BackpackController:getInstance():openTipsSource(true, config)
								elseif self.is_tips_source then
									TipsManager:getInstance():showGoodsTips(config, true, self.is_tips_source)
								else
									TipsManager:getInstance():showGoodsTips(config)
								end
								if self.source_callback then		-- 额外需求
									self:source_callback()
								end
							end
							return
						end
						if self.callback then
							self:callback(self)
						end
					end
					-- 引导需要
					if sender.guide_call_back ~= nil then
						sender.guide_call_back(sender)
					end
				end
			elseif event_type == ccui.TouchEventType.moved then
				if self.have_long_time_effect then
                    if self.long_touch_type == LONG_TOUCH_BEGAN_TYPE then
                        local touch_began = self.touch_began
                        local touch_move = sender:getTouchMovePosition()
                        if touch_began and touch_move and (math.abs(touch_move.x - touch_began.x) > 20 or math.abs(touch_move.y - touch_began.y) > 20) then 
                            --移动大于20了..表示取消长点击效果
                            doStopAllActions(self.background)
                            self.long_touch_type = LONG_TOUCH_CANCEL_TYPE
                        end 
                    end
                end
			elseif event_type == ccui.TouchEventType.began then
				self.touch_began = sender:getTouchBeganPosition()
				if self.have_long_time_effect then
                    --有长点击效果
                    doStopAllActions(self.background)
                    self.long_touch_type = LONG_TOUCH_BEGAN_TYPE
                    delayRun(self.background, 0.6, function ()
                        if self.long_touch_type == LONG_TOUCH_BEGAN_TYPE then
                            if self.long_time_callback then
                                self.long_time_callback()
                            end
                        end
                        self.long_touch_type = LONG_TOUCH_END_TYPE
                    end)
                end
			elseif event_type == ccui.TouchEventType.canceled then
				if self.have_long_time_effect then
                    if self.long_touch_type == LONG_TOUCH_BEGAN_TYPE then
                        doStopAllActions(self.background)
                        self.long_touch_type = LONG_TOUCH_CANCEL_TYPE
                    end
                end
			end
		end)
		if self.swallow_touch == false then
			self:setSwallowTouches(self.swallow_touch)
		end
	end

	-- 退出的时候移除一下吧.要不然可能有些人不会手动移除,就会报错
	self:registerScriptHandler(function(event)
		if "enter" == event then
		elseif "exit" == event then		
			if self.data then
				if self.item_update_event ~= nil then
					self.data:UnBind(self.item_update_event)
					self.item_update_event = nil
				end
				self.data = nil
			end
		end 
	end)
end

--[[
    @desc:扩展参数，现在只用于是否用于播放动效
    author:{author}
    time:2018-05-21 19:37:18
    --@data: 
    return
]]
function BackPackItem:setExtendData(data)
	if type(data) == "table" then
		if data.showCheckBox ~= nil then
			self.show_check_box = data.showCheckBox
		elseif data.scale ~= nil then			-- 设置缩放
			self:setScale(data.scale)
		end
		if data.adjustCheckBoxPos ~= nil then
			self.check_box_pos = data.adjustCheckBoxPos
		end
		if data.checkBoxClickCallBack ~= nil then
			self.click_check_callback = data.checkBoxClickCallBack
		end
		if data.red_point ~=nil then  --背包中某些特殊物品需要红点，现在只有2个神器
			self.is_check_red = true
			self:checkRedPoint()
		end
		if data.show_use_target ~= nil then
			self.show_use_target = data.show_use_target
		end
		if data.is_hide_effect then 
			self.is_hide_effect = data.is_hide_effect
		end
		if data.is_show_tips ~= nil then
			self.is_show_tips = data.is_show_tips
		end
		if data.show_extend_gemstone ~= nil then
			self.show_extend_gemstone = data.show_extend_gemstone
		end
		if data.is_other ~= nil then	-- 是都是其他玩家的物品,比如说查看别人的啊
			self.is_other = data.is_other
		end
		--背包是否显示星数
		if data.is_start ~= nil then
			self.is_start = data.is_start
		end
		--背包是否显示阵营
		if data.is_camptype ~= nil then
			self.is_camptype = data.is_camptype
		end
		if data.is_comp_num ~= nil then
			self.is_comp_num = data.is_comp_num
		end
	end
end

function BackPackItem:setSelfNum(num)
	--显示碎片个数英雄的
	if self.is_comp_num == true then
		local comp_num = Config.PartnerData.data_get_compound_info
		if comp_num[self.item_config.id] then
			if num >= comp_num[self.item_config.id].num then
				self:showRedPoint(true)
			else
				self:showRedPoint(false)
			end
			self:showCompNumber(num, comp_num[self.item_config.id].num)
		end
		--神器（特殊）
		local hallow_data = BackpackController:getModel():getHallowsCompData(self.item_config.id)
		if hallow_data.num then
			if num >= hallow_data.num then
				self:showRedPoint(true)
			else
				self:showRedPoint(false)
			end
			self:showCompNumber(num, hallow_data.num)
		end
	else --通用的
		num = num or 0
		self.num_label:setVisible(num >1)
		self.num_bg:setVisible(num > 1)
		if num > 1 then
			self.num_label:setString(MoneyTool.GetMoneyString(num))
			self:updateNumBGSize()
		end
	end
end

function BackPackItem:setSelfEquip(type, enchant, show_jie)
	local is_equip = self:checkIsEquip(type)
	if is_equip == true then
        self:setEquipJie(true)
		self:setEnchantLev(enchant)
    elseif self.data.type == BackPackConst.item_type.NORMAL and self.data.sub_type == BackPackConst.item_tab_type.HERO then
		self:setEquipJie(true)
	else
        self:setEquipJie(false)
		self:setEnchantLev(0)
    end
end

function BackPackItem:setSelfEffect(config)
	if not self.is_hide_effect == true then
		if config and config.is_effect and config.is_effect >= 1 then
			local effect_id = config.is_effect
			local action = PlayerAction.action
			local scale = 1
			--默认特效
			if config.is_effect == 1 then
				effect_id = 156
				action = PlayerAction.action_2
				if config.quality >= 4 then 
					action = PlayerAction.action_1
				end
			end
			self.item_icon:setVisible(true)
			if effect_id >= 1671 and effect_id <= 1674 then
				--这个几个是背景框的资源 因为 背景框是 138 这里是 105 为了不输出两份资源 通用的只有按比例缩放 暂时不改item表情况下写死  --by lwc
				--后面如果有比较多类似的特有特效 建议在item_data表加字段支持
				scale = 105/138
			elseif effect_id == 354 then--猫咪物语 --记得加字段支持了  --by lwc
				scale = 0.7
				self.item_icon:setVisible(false)
			end 
			self:showItemEffect(true, effect_id, action, true, scale)
		else
			self:showItemEffect(false)	
			self.item_icon:setVisible(true)
		end
	else
		self:showItemEffect(false)
		self.item_icon:setVisible(true)
	end
end

-- function BackPackItem:setSelfChips(config)
-- 	if config.type == BackPackConst.item_type.PARTNER_DEBRIS then
-- 		self.chips_icon:setVisible(true)
-- 		local index = config.quality or 1
-- 		local res = PathTool.getResFrame("common","common_9005"..(index-1))
-- 		loadSpriteTexture(self.chips_icon,res,LOADTEXT_TYPE_PLIST)
-- 	else
-- 		self.chips_icon:setVisible(false)
-- 	end
-- end

function BackPackItem:setItemIcon(head_icon)
	self.item_icon:setVisible(true)
	if self.record_head_icon == nil or self.record_head_icon ~= head_icon then
		self.record_head_icon = head_icon
		loadSpriteTexture(self.item_icon, head_icon, LOADTEXT_TYPE)
	end
end

function BackPackItem:setSelfBackground(quality)
	quality = quality or 0
	local res_id = PathTool.getQualityBg(quality)
	self:setBackgroundRes(res_id)
end

function BackPackItem:setBackgroundRes( res_id )
	if self.background_res_id ~= res_id then
		self.background_res_id = res_id
		self.background:loadTexture(self.background_res_id, LOADTEXT_TYPE_PLIST)
	end
end

--底图的透明度
function BackPackItem:setBackgroundOpacity(num)
	if self.background then
		self.background:setOpacity(num)
	end
end
--一些不是物品数据的也是用到的时候用这个接口吧
function BackPackItem:setBaseData(bid, num, is_spec)
	if bid == nil then 
		self:suspendAllActions()
		return 
	end
	local config = Config.ItemData.data_get_data(bid)
	if config == nil then return end
	self.data = config
	self.item_config = config 
	
	self.item_icon:setVisible(true)

	local head_icon = PathTool.getItemRes(config.icon, false)
	if self.record_head_icon == nil or self.record_head_icon ~= head_icon then
		self.record_head_icon = head_icon
		loadSpriteTexture(self.item_icon, head_icon, LOADTEXT_TYPE)
	end

	if self.item_config.type == BackPackConst.item_type.HOME_PET_TREASURE then
		--特产的图片是 128 .要变成 105 的
		self.item_icon:setScale(0.82)
	end

	-- 设置碎片
	-- self:setSelfChips(config)
	self:isChipSprite(config)

	--设置星数
	self:setEquipJie(true)

	-- 设置数量显示
	self:setSelfNum(num)

	-- 设置背景
	self:setSelfBackground(config.quality)

	-- 设置装备类的显示
	self:setSelfEquip(config.type, 0, true)

	-- 设置显示特效
	self:setSelfEffect(config)

	--碎片星数
	self:isShowStart(config.type, config.eqm_jie)

	-- 精灵显示阶数
	self:isShowStep(config.type)

	--显示阵营
	self:isShowCamp(config.sub_type, config.lev)

	--神装ui
	self:setGodHolyEquipmentUI(true, config)
end

--==============================--
--desc:设置显示数据,暂时支持的格式有item_data_config goods_vo, 以及 Config.PartnerEqmData.data_partner_set_attr
--time:2017-07-31 01:58:10
--@data:
--@return 
--==============================--
function BackPackItem:setData(data,is_hide_effect)
	if self.data and self.item_update_event ~= nil then
		self.data:UnBind(self.item_update_event)
		self.item_update_event = nil
		self.data = nil
	end
	self.data = data
	local id 
	self.is_hide_effect = is_hide_effect or false
	if self.data then
		id = self.data.id or self.data.bid
	end
	if self.camp_icom then
		self.camp_icom:setVisible(false)
	end

	if self.data == nil or id == nil then
		self:suspendAllActions()
	else
		local item_config = nil
		if self.data.config == nil then
			item_config = Config.ItemData.data_get_data(id)
		else
			item_config = self.data.config
		end
		if item_config == nil then return end
		self.item_config = item_config
		-- 引导需要
		self:setName("item_"..item_config.id)

        self.item_icon:setVisible(true)
		local head_icon = PathTool.getItemRes(item_config.icon, false)
		if self.record_head_icon == nil or self.record_head_icon ~= head_icon then
			self.record_head_icon = head_icon
			loadSpriteTexture(self.item_icon, head_icon, LOADTEXT_TYPE)
		end
		if self.item_config.type == BackPackConst.item_type.HOME_PET_TREASURE then
			--特产的图片是 128 .要变成 105 的
			self.item_icon:setScale(0.82)
		end

		-- 设置碎片
		-- self:setSelfChips(item_config)
		self:isChipSprite(item_config)

		-- 设置数量 
		self:setSelfNum(self.data.quantity)

		-- 设置背景
		self:setSelfBackground(item_config.quality)

		-- 设置装备类的显示
		self:setSelfEquip(item_config.type, data.enchant, true)

		-- 设置神器星数显示状态
		self:setArtifactStars()

		--碎片星数
		self:isShowStart(item_config.type, item_config.eqm_jie)

		-- 精灵显示阶数
		self:isShowStep(item_config.type)

		--显示阵营
		self:isShowCamp(item_config.sub_type,item_config.lev)

		--神装ui
		self:setGodHolyEquipmentUI(true,item_config)

		--显示锁定状态
		--self:setLockStatus(item_config.type)

		--这里判断一下状态，是否需要显示勾选框吧
		if self.data.showSellStatus ~= nil then
			self:setCheckBoxStatus(self.data.showSellStatus.status, self.data.showSellStatus.select)
		end

		-- 设置显示特效
		self:setSelfEffect(item_config)

		--增加红点判断
		if self.is_check_red == true then 
			self:checkRedPoint()
		end
		
		-- 使用类型
		self:showUseTag(false)

		--增加显示
		if self.show_use_target == true then
			if self.data and self.data.config and self.data.config.tips_btn then
				local show_type = self:checkIsUse(self.data.config.tips_btn)
				local less_time = self.data.expire_time or 0
				less_time = less_time - GameNet:getInstance():getTime()
				if show_type == 2 and less_time <= 0  then
					self:showUseTag(true,show_type)
				end
			end
		end
		if self.data and self.data.bid then
			self:setWeekCardData(self.data.bid)
		end
	end

	self:addVoBindEvent()
end

--周卡
function BackPackItem:setWeekCardData(bid)
	local item_config = Config.ItemData.data_get_data(bid)
	if item_config and item_config.tips_btn then
		local show_type = self:checkIsWeekCard(item_config.tips_btn)
		if show_type == 50 then
			self:showWeekCardTag(true)
		end
	end
end

function BackPackItem:setGodHolyEquipmentUI(status, config)
	if status then
	    if not config then return end
		--神装类型
		if config.sub_type == BackPackConst.item_tab_type.HOLYEQUIPMENT then
			if self.holy_equipment_bg == nil then
				local res_bg = PathTool.getResFrame("common","common_90085")
				local x = BackPackItem.Width * 0.5	
				local size = cc.size(109, 37) --res_bg 的图片大小
				self.holy_equipment_bg = cc.Layer:create()
				self.holy_equipment_bg:setContentSize(size)
				self.holy_equipment_bg:setAnchorPoint(cc.p(0.5,0.5))
				self.holy_equipment_bg:setPosition(x, size.height * 0.5)
				self.main_container:addChild(self.holy_equipment_bg, 0)
				self.holy_equipment_img = createImage(self.holy_equipment_bg, res_bg, 0, 0 , cc.p(0.5,0.5), true, 0, false)
				self.holy_equipment_star_label = createLabel(20, cc.c4b(0xf9,0xe8,0xce,0xff), cc.c4b(0x43,0x26,0x16,0xff),  - 1 , 0, "",self.holy_equipment_bg, 2, cc.p(0.5,0.5))
				self.holy_equipment_jie_label = createLabel(20, cc.c4b(0xf9,0xe8,0xce,0xff), cc.c4b(0x43,0x26,0x16,0xff), 50, 80, "",self.holy_equipment_bg, 2, cc.p(1,0.5))
				self.suit_icon = createImage(self.holy_equipment_bg, nil, -35, 76 , cc.p(0.5,0.5), true, 0, false)
			else
				self.holy_equipment_bg:setVisible(true)
			end
			if config.eqm_star > 5 then
				self.holy_equipment_img:setVisible(true)
				self.holy_equipment_star_label:setVisible(true)
				if self.holy_equipment_star_label then
					self.holy_equipment_star_label:setString(config.eqm_star)
				end
			else
				self.holy_equipment_img:setVisible(false)
				self.holy_equipment_star_label:setVisible(false)
				self:setStarCount(true, config.eqm_star)
			end
			
			if self.holy_equipment_jie_label then
				if BackPackConst.holyequip_jie_name[config.eqm_jie] then
					self.holy_equipment_jie_label:setString(BackPackConst.holyequip_jie_name[config.eqm_jie])
				else
					self.holy_equipment_jie_label:setString(BackPackConst.holyequip_jie_name[0])
				end 
			end
			
			if config.eqm_set then
				local id = math.floor(config.eqm_set/100)
				local config = Config.PartnerHolyEqmData.data_suit_res_prefix_fun(id)
				if config then
					local res = PathTool.getSuitRes(config.prefix)
					if self.suit_icon then
						self.suit_icon:loadTexture(res,LOADTEXT_TYPE)
					end
				end
			end
			
			
			
		elseif self.holy_equipment_bg then
			self.holy_equipment_bg:setVisible(false)
		end
	else
		if self.holy_equipment_bg then
			self.holy_equipment_bg:setVisible(false)
		end
		self:setStarCount(false)
	end
end

--神装商店的星数显示
function BackPackItem:setSuitShopStar(status, eqm_star)
	if status then
		if self.suit_shop_bg == nil then
			local res_bg = PathTool.getResFrame("common","common_90085")
			local x = BackPackItem.Width * 0.5	
			local size = cc.size(109, 37) --res_bg 的图片大小
			self.suit_shop_bg = createImage(self.main_container, res_bg, x, size.height * 0.5 , cc.p(0.5,0.5), true, 0, false)
			self.suit_shop_star_label = createLabel(20, cc.c4b(0xf9,0xe8,0xce,0xff), cc.c4b(0x43,0x26,0x16,0xff), size.width * 0.5 - 1 , size.height * 0.5, "",self.suit_shop_bg, 2, cc.p(0.5,0.5))
		end

		if eqm_star > 5 then
			self.suit_shop_bg:setVisible(true)
			self.suit_shop_star_label:setVisible(true)
			if self.suit_shop_star_label then
				self.suit_shop_star_label:setString(eqm_star)
			end
		else
			self.suit_shop_bg:setVisible(false)
			self.suit_shop_star_label:setVisible(false)
			self:setStarCount(true, eqm_star)
		end

	else
		if self.suit_shop_bg then
			self.suit_shop_bg:setVisible(false)
		end
		self:setStarCount(false)
	end

end

--碎片星数
function BackPackItem:isShowStart(type, start)
	if type == BackPackConst.item_type.PARTNER_DEBRIS and not self.is_start then
		self:setEquipJie(true)
	end
end

-- 精灵阶数
function BackPackItem:isShowStep( _type )
	if _type == BackPackConst.item_type.ELFIN then
		self:setElfinStep(true)
	else
		if self.elfin_step_list then
			for i,v in ipairs(self.elfin_step_list) do
				v:setVisible(false)
			end
		end
	end
end

--显示阵营
function BackPackItem:isShowCamp(type,lev)
	if type == 3 and not self.is_camptype and lev ~= 0 then
		self:initCamp(lev)
	else
		if self.camp_icom then
			self.camp_icom:setVisible(false)
		end
	end
end

function BackPackItem:initCamp(lev)
	if not self.camp_icom then
		self.camp_icom = createSprite("", 21, 97, self.main_container, cc.p(0.5,0.5), LOADTEXT_TYPE_PLIST, 1)
		self.camp_icom:setScale(0.6)
	end
	if self.camp_icom then
		self.camp_icom:setVisible(true)
		local res = PathTool.getHeroCampTypeIcon(lev)
		loadSpriteTexture(self.camp_icom, res, LOADTEXT_TYPE_PLIST)
	end
end
--显示碎片
function BackPackItem:isChipSprite(config)
	if config.type == BackPackConst.item_type.PARTNER_DEBRIS then
		if not self.chipSprite then
			self.chipSprite = createSprite("", 97, 97, self.main_container, cc.p(0.5,0.5), LOADTEXT_TYPE_PLIST, 1)
		end
		if self.chipSprite then
			self.chipSprite:setVisible(true)
			local res = PathTool.getResFrame("common","common_90055")
			loadSpriteTexture(self.chipSprite, res, LOADTEXT_TYPE_PLIST)
		end
	else
		if self.chipSprite then
			self.chipSprite:setVisible(false)
		end
	end
end

--显示碎片个数
function BackPackItem:createCompLayer()
	if not self.compLayer then
	    self.compLayer = cc.Layer:create()
	    self.compLayer:setContentSize(107, 19)
	    self.main_container:addChild(self.compLayer)
	    self.compLayer:setPosition(5,-24)
	    self.compLayer:setVisible(false)
	    local res = PathTool.getResFrame("common","common_90005")
	    local res1 = PathTool.getResFrame("common","common_90006")
	    local bg,comp_bar = createLoadingBar(res, res1, cc.size(107, 19), self.compLayer, cc.p(0,0.5), 0, self.compLayer:getContentSize().height/2, true, true)
	    self.camp_progress_bar = comp_bar

	    local text_bar = createLabel(18,Config.ColorData.data_color4[1],nil,self.compLayer:getContentSize().width/2,self.compLayer:getContentSize().height/2,"0/0",self.compLayer,nil, cc.p(0.5,0.5))
		self.text_bar = text_bar
	end
end

-- 锁定状态
function BackPackItem:setLockStatus( item_type )
	local lock_status = false
	if item_type == BackPackConst.item_type.ARTIFACTCHIPS then
		
	end

	if lock_status == true then
		if not self.lock_icon then
			self.lock_icon = createSprite(PathTool.getResFrame("common","common_lock"), self.size.width-5, self.size.height-5, self.main_container, cc.p(1, 1), LOADTEXT_TYPE_PLIST)
		end
		if self.lock_icon then
			self.lock_icon:setVisible(true)
		end
	elseif self.lock_icon then
		self.lock_icon:setVisible(false)
	end
end

-- 幻化标识
function BackPackItem:setMagicIcon( status )
	if status == true then
		if not self.magic_icon then
			self.magic_icon = createSprite(PathTool.getResFrame("common","txt_cn_common_90021"), 5, self.size.height-5, self.main_container, cc.p(0, 1), LOADTEXT_TYPE_PLIST)
		end
		if self.magic_icon then
			self.magic_icon:setVisible(true)
		end
	elseif self.magic_icon then
		self.magic_icon:setVisible(false)
	end
end

function BackPackItem:showCompNumber(cur,max)
	self:createCompLayer()

	self.compLayer:setVisible(true)
	self.camp_progress_bar:setPercent(math.floor(cur / max * 100))
	self.text_bar:setString(cur.."/"..max)
end
--==============================--
--desc:增加数据监听
--time:2018-08-01 02:35:23
--@return 
--==============================--
function BackPackItem:addVoBindEvent()
	-- 直接用数据去监听这样避免了刷新的频繁
	if self.data and self.data.config ~= nil and self.data.id ~= nil and self.data.Bind then
		if self.item_update_event == nil then
			self.item_update_event = self.data:Bind(GoodsVo.UPDATE_GOODS_ATTR, function(key, value) 
				if key == "showSellStatus" then
					local status = value.status or false
					local select = value.select or false
					self:setCheckBoxStatus(status,select)
				elseif key == "enchant" then
					local is_equip = self:checkIsEquip(self.data.config.type)
					if is_equip == true then
						self:setEnchantLev(value)
						self:setEquipJie(true)
					end
					self:setArtifactStars()
				elseif key == "quantity" then
					self:setSelfNum(self.data.quantity)
				end
				if self.is_check_red == true then 
					self:checkRedPoint()
				end
			end)
		end
	end
end

-- 真实物品变化的时候回调,有一些特殊地方需要,现在暂时只用在宝石这边回调
function BackPackItem:setChangeCallback(callback)
	self.change_callback = callback
end

function BackPackItem:checkIsUse(data)
	local show_type = 0 --表现不显示
	if data then
		for i,v in ipairs(data) do --先全部遍历判断使用是否存在
			if v == 2 then
				show_type = v
				break
			end
		end
	end
	return show_type
end

--周卡
function BackPackItem:checkIsWeekCard(data)
	local card_type = 0
	if data then
		for i,v in ipairs(data) do
			if v == 50 then
				card_type = v
				break
			end
		end
	end
	return card_type
end

function BackPackItem:checkRedPoint()
	--[[if not self.data then return end
	local artifact_const = Config.PartnerArtifactData.data_artifact_const 
    if not artifact_const then return end
    local bid_list = {}
    local bid_1 = artifact_const["main_shenqi"].val
	local bid_2 = artifact_const["assistant_shenqi"].val
	local bool = false
	local backpack_model = BackpackController:getInstance():getModel()
	if self.data.config and self.data.config.effect then
		local effect = self.data.config.effect
		if effect and effect[1] and effect[1].val and (effect[1].val == bid_1 or effect[1].val == bid_2) then
			local config = Config.PartnerArtifactData.data_artifact_data[effect[1].val]
			if config and config.compound_expend and  config.compound_expend[1] then 
				local bid = config.compound_expend[1][1]
				local num = config.compound_expend[1][2]
				local count = backpack_model:getBackPackItemNumByBid(self.data.base_id)
				if count >= num then 
					bool = true
				end
			end
		end
	end
	self:showRedPoint(bool)--]]
end

--空装备名字
function BackPackItem:showEquipName(index,bool)
	index = index or 0
	if index <=0 and not self.equip_name then return end

	if not self.equip_name then 
		self.equip_name = createLabel(24,cc.c4b(0xcf,0xbe,0xa9,0xff),cc.c4b(0x56,0x25,0x12,0xff),self.Width/2,self.Height/2,"",self.main_container,1, cc.p(0.5,0.5))
	end
	local name = Config.ItemData.data_item_type[index] or ""
	self.equip_name:setString(name)
	self.equip_name:setVisible(bool)
end

function BackPackItem:showNumLabel(bool)
	bool = bool or false 
	if self.num_label then 
		self.num_label:setVisible(bool)
		self.num_bg:setVisible(bool)
	end
end

function BackPackItem:setNumFontSize( font_size )
	if self.num_label and font_size then 
		self.num_label:setFontSize(font_size)
		self:updateNumBGSize()
	end
end

--判断是否是装备
function BackPackItem:checkIsEquip(item_type)
	item_type = item_type or 0
	if item_type >=1 and item_type <=4 then 
		return true
	end
	return false
end

--==============================--
--desc:理论上只用于 00/11 的格式，希望不要乱用
--time:2018-06-21 10:49:59
--@need_num:
--@num:
--@color:
--@return 
--==============================--
function BackPackItem:setNeedNum(need_num, num, color, force, outcolor)
	need_num = need_num or 0
	local status = false
	if need_num > 0 or force == true then 
		status = true
	end
	local str = need_num
	if num then 
		if need_num > num then
			color = 127
		else
			color = 1
		end 
		num = MoneyTool.GetMoneyString(num)
		need_num = MoneyTool.GetMoneyString(need_num)
		str = num .."/"..need_num
	end
	self.num_label:setString(str)
	if color and Config.ColorData.data_color4[color] then
		self.num_label:setTextColor(Config.ColorData.data_color4[color])
	end
	if outcolor and Config.ColorData.data_color4[outcolor] then
		self.num_label:enableOutline(Config.ColorData.data_color4[outcolor], 2)
	end

	self.num_label:setVisible(status)
	self.num_bg:setVisible(status)
	self:updateNumBGSize()
end

--==============================--
--desc:理论上只用于 00/11 的格式，希望不要乱用
--time:2018-06-21 10:49:59
--@need_num:
--@num:
--@color:
--@return 
--==============================--
function BackPackItem:setNeedNum2(need_num, num, color, pos, size)
	if not need_num then return end
	if not num then return end
	local x = 125
	local y = 35
	if pos then
		x = pos.x
		y = pos.y
	end
	if self.need_num_bg == nil  then
		local res = PathTool.getResFrame("common","common_90005")
	    self.need_num_bg = createImage(self.root_wnd, res, x, y, cc.p(0,0.5), true, 0, true)
	    local size = size or cc.size(170,36)
	    self.need_num_bg:setContentSize(size)
	    self.need_num_bg:setCapInsets(cc.rect(12, 10, 1, 1))
	    
	end
	if self.need_num_label == nil then
		self.need_num_label = createLabel(22, cc.c4b(0xff,0xf6,0xe4,0xff), nil, x + 10, y, "", self.root_wnd, nil, cc.p(0,0.5))
	end

	local str 
	local color = color
	if num then 
		if need_num > num then
			color = 127
		else
			color = nil
		end 
		num = MoneyTool.GetMoneyString(num)
		str = num .."/"..need_num
	else
		str = need_num
	end
	if color and Config.ColorData.data_color4[color] then
		self.need_num_label:setTextColor(Config.ColorData.data_color4[color])
	end
	self.need_num_label:setString(str)
end

--装备需要个强化等级显示
function BackPackItem:setEnchantLev(enchant)
	enchant = enchant or 0
	if enchant <= 0 then
		if not tolua.isnull(self.enchant_label) then 
			self.enchant_label:setVisible(false)
		end
		return 
	end

	if not self.enchant_label then 
		self.enchant_label = createLabel(24,cc.c4b(0xff,0xf4,0x75,0xff),cc.c4b(0x56,0x25,0x12,0xff),108,84,"",self.main_container,1, cc.p(1,0))
	end
	self.enchant_label:setString("+"..enchant)
	self.enchant_label:setVisible(enchant>0)
end

--在宝石界面装备需要额外显示宝石总等级 覆盖 强化等级
function BackPackItem:setGemstoneLev(lv)
	-- body
	self:setEnchantLev(0)
	if lv <= 0 then
		if not tolua.isnull(self.gemstone_label) then 
			self.gemstone_label:setVisible(false)
		end
	else
		if not self.gemstone_label then 
			self.gemstone_label = createLabel(22,Config.ColorData.data_color4[1],cc.c4b(0x00,0x00,0x00,0xff),108,34,"",self.main_container,1, cc.p(1,0))
		end
		self.gemstone_label:setString("Lv."..lv)
		self.gemstone_label:setVisible(true)
	end
end

--要显示装备等级,宝石也是需要显示
--装备阶级 删除 改成显示星数量
--字段 原本读 eqm_jie(目前保留字段) 现在读  eqm_star
function BackPackItem:setEquipJie(bool)
	if bool == false and not self.equip_star_list then return end
	local id 
	if self.data then
		id = self.data.id or self.data.bid
	end
	local item_config = nil
	if id then
		if self.data.config == nil then  -- 这个可能是物品配置,也可能是伙伴自身配置
			item_config = Config.ItemData.data_get_data(id)
		else
			item_config = self.data.config
		end
	end
	

	if not item_config then 
		return 
	end
	

	local eqm_star = 0
	if bool == true then
		local status = false
		status = self:checkIsEquip(item_config.type)
		if status == true then --装备的时候
			eqm_star = item_config.eqm_star
		else
			if item_config.type == BackPackConst.item_type.PARTNER_DEBRIS then --背包碎片的时候
				eqm_star = item_config.eqm_jie
			elseif item_config.type == BackPackConst.item_type.ARTIFACTCHIPS then --背包是神器
				eqm_star = self.data.enchant or 0
			elseif item_config.type == BackPackConst.item_type.NORMAL and item_config.sub_type == BackPackConst.item_tab_type.HERO then
				eqm_star = self.data.eqm_jie or item_config.eqm_jie or 0
			end
		end
	end
	self:setStarCount(true, eqm_star)
end

function BackPackItem:setStarCount(status, count)
	if self.equip_star_list then
		for i,v in ipairs(self.equip_star_list) do
			v:setVisible(false)
		end
	end

	if status then
		if self.equip_star_list == nil then
			self.equip_star_list = {}
		end

		local width = 12
	    local x = self.size.width * 0.5 - count * width * 0.5 + width * 0.5
	   
	    for i=1,count do
	        if not self.equip_star_list[i] then 
	        	local res = PathTool.getResFrame("common","common_90074")
	            local star = createImage(self.main_container,res,0,0,cc.p(0.5,0.5),true,0,false)
	            star:setScale(1)
	            self.equip_star_list[i] = star
	        end
	        self.equip_star_list[i]:setVisible(true)
	        self.equip_star_list[i]:setPosition(x + (i-1) * width, 15)
	    end
	end
end

-- 精灵阶数
function BackPackItem:setElfinStep( status )
	if status == false and not self.elfin_step_list then return end
	local id 
	if self.data then
		id = self.data.id or self.data.bid
	end
	local item_config = nil
	if id then
		if self.data.config == nil then  -- 这个可能是物品配置,也可能是伙伴自身配置
			item_config = Config.ItemData.data_get_data(id)
		else
			item_config = self.data.config
		end
	end
	if self.elfin_step_list then
		for i,v in ipairs(self.elfin_step_list) do
			v:setVisible(false)
		end
	end

	if not item_config then 
		return 
	end
	if self.elfin_step_list == nil then
		self.elfin_step_list = {}
	end

	local step_num = 0
	if status == true then
		step_num = item_config.eqm_jie or 0
	end

	local width = 15
    local x = self.size.width * 0.5 - step_num * width * 0.5 + width * 0.5
   
    for i=1,step_num do
        if not self.elfin_step_list[i] then 
        	local res = PathTool.getResFrame("common","common_90032")
            local step_icon = createImage(self.main_container,res,0,0,cc.p(0.5,0.5),true,0,false)
            self.elfin_step_list[i] = step_icon
        end
        self.elfin_step_list[i]:setVisible(true)
        self.elfin_step_list[i]:setPosition(x + (i-1) * width, 10)
    end
end

function BackPackItem:createStar(num)
	if self.star_node == nil then
		self.star_node = cc.Node:create()
		local x = self.size.width * 0.5
		self.star_node:setPosition(x, 20)
		self.main_container:addChild(self.star_node)
	end
	local num = num or 0
    local width = 17 
    self.star_setting = HeroController:getInstance():getModel():createStar(num, self.star_node, self.star_setting, width)
end

--穿戴等级
function BackPackItem:setEquipLev(lev,scale,font_size,pos)
	lev = lev or 0
	scale = scale or  1
	font_size = font_size or 20
	pos = pos or cc.p(60,-10)
    if lev <= 0 then
		if self.lev_label then
			self.lev_label:setVisible(false)
		end
		return 
	end

    if not self.lev_label then
		self.lev_label = createLabel(font_size, 175,nil,pos.x,pos.y,"", self.main_container, 1, cc.p(0.5, 0.5)) --cc.c4b(86, 37, 18, 255)
		self.lev_label:setScale(1/scale)
    end
    self.lev_label:setString("LV." .. lev)
	self.lev_label:setVisible(true)
end

--神器格子需要个锁
function BackPackItem:showArtifactLock(bool)
	if bool == false and not self.artifact_lock then return end
	if not self.artifact_lock then 
		local res = PathTool.getResFrame("common","common_90009")
		self.artifact_lock = createImage(self.root_wnd, res, 60,60, cc.p(0.5,0.5), true, 1, false)
	end
	self.artifact_lock:setVisible(bool)
end

--神器需要一个描述
function BackPackItem:showArtifactLabel(bool,str)
	str = str or ""
	if not self.lock_label then
		self.lock_label = createLabel(24,cc.c4b(0xcf,0xbe,0xa9,0xff),cc.c4b(0x56,0x25,0x12,0xff),60,12,"",self.main_container,1, cc.p(0.5,0))
	end
	self.lock_label:setString(str)
	self.lock_label:setVisible(bool)
end

--战令活动的个锁
function BackPackItem:showOrderWarLock(bool,pos)
	if bool == false and not self.order_war_lock then return end
	if not self.order_war_lock then 
		local temp_pos = pos or cc.p(7,97)
		self.order_war_lock = createSprite(PathTool.getResFrame("common","common_90009"), temp_pos.x,temp_pos.y, self.root_wnd, cc.p(0.5,0.5))
	end
	self.order_war_lock:setVisible(bool)
end
--战令活动 物品是否领取状态
function BackPackItem:IsGetStatus(bool,opacity,res)
	opacity = opacity or 150
	if bool == false and not self.is_get_select then return end
	if not self.is_get_select then
		self.is_get_select = ccui.Layout:create()
        self.is_get_select:setAnchorPoint(cc.p(0.5,0.5))
        self.is_get_select:setContentSize(self.size)
        self.is_get_select:setPosition(self.size.width/2, self.size.height/2) 
        self.is_get_select:setTouchEnabled(false)
        showLayoutRect(self.is_get_select, opacity)
		local temp_res = res or PathTool.getResFrame("common","common_1043")
		createSprite(temp_res, 60,60, self.is_get_select, cc.p(0.5,0.5))
		self:addChild(self.is_get_select)
	end
	self.is_get_select:setVisible(bool)
end

--加号
--锁
function BackPackItem:showAddIcon(bool)
	if bool == false and not self.add_btn then return end
	if not self.add_btn then 
		local res = PathTool.getResFrame("common","common_90026")
		self.add_btn = createSprite(res,60,60,self.main_container,cc.p(0.5, 0.5),LOADTEXT_TYPE_PLIST,10)
	end
	self.add_btn:setVisible(bool)
end

function BackPackItem:addBtnCallBack(call_fun)
	self.btn_call_fun = call_fun
end

--[[
    @desc:复选框，比如说背包可能需要
    author:{author}
    time:2018-05-21 09:37:00
    --@status:
	--@is_select: 
    return
]]
function BackPackItem:setCheckBoxStatus(status, is_select)
	if self.show_check_box == false then return end
	if status == false then
		if self.check_box ~= nil then
			self.check_box:setVisible(false)
		end
	else
		if self.check_box == nil then
			self.check_box =
				ccui.CheckBox:create(
					PathTool.getResFrame("common", "common_1044"),
					PathTool.getResFrame("common", "common_1044"),
					PathTool.getResFrame("common", "common_1043"),
					PathTool.getResFrame("common", "common_1044"),
					PathTool.getResFrame("common", "common_1043"),
					LOADTEXT_TYPE_PLIST
				)
			if self.check_box_pos then
				self.check_box:setPosition(self.check_box_pos)
			else
				self.check_box:setPosition(25, 25)
			end
			self.main_container:addChild(self.check_box)

			self.check_box:addTouchEventListener(
				function(sender, event_type)
					if event_type == ccui.TouchEventType.began then
						self.check_box_status = self.check_box:isSelected()
					elseif event_type == ccui.TouchEventType.ended then
						if self.data ~= nil and self.data.id ~= nil and self.data.showSellStatus then
							self.data:setGoodsAttr("showSellStatus", {status = true, select = self.check_box:isSelected()})
							if self.click_check_callback then
								self.click_check_callback(self.check_box:isSelected(), self)
							end
						end
					elseif event_type == ccui.TouchEventType.canceled then
						self.check_box:setSelected(self.check_box_status or false)
					end
				end
			)
		else
			self.check_box:setVisible(true)
		end
	end
	if is_select == nil then
		is_select = false
	end
	if not tolua.isnull(self.check_box) then
		self.check_box:setSelected(is_select)
	end
end

-- 修改勾选框的位置
function BackPackItem:adjustCheckBoxPos( pos )
	self.check_box:setPosition(pos)
end

--增加一个标签头
function BackPackItem:showBiaoQian(bool,str)
	if not self.qian_icon then 
		local res = PathTool.getResFrame("common","common_90015")
		self.qian_icon = createImage(self.main_container,res,37,86,cc.p(0.5,0.5),true,10,true)
		self.qian_label = createLabel(20,Config.ColorData.data_color4[1],Config.ColorData.data_color4[9],29,25,"",self.qian_icon,2, cc.p(0.5,0))
		self.qian_label:setRotation(-45)
	end
	self.qian_icon:setVisible(bool)
	str= str or ""
	self.qian_label:setString(str)
end
--物品右上角说明
function BackPackItem:showRightBiaoQian(bool,str)
	if not self.right_icon then 
		local res = PathTool.getResFrame("common","common_30013")
		self.right_icon = createImage(self.main_container,res,88,86,cc.p(0.5,0.5),true,10,true)
		self.right_icon:setRotation(90)
		self.right_label = createLabel(20,Config.ColorData.data_color4[1],Config.ColorData.data_color4[214],27,49,"",self.right_icon,2, cc.p(0.5,0.5))
		self.right_label:setRotation(-45)
	end
	self.right_icon:setVisible(bool)
	str= str or ""
	self.right_label:setString(str)
end

--物品右上角说明
function BackPackItem:showLeftBiaoQian(bool,str)
	if not self.left_icon then 
		local res = PathTool.getResFrame("common","common_30012")
		self.left_icon = createImage(self.main_container,res,30,88,cc.p(0.5,0.5),true,10,true)
		-- self.left_icon:setRotation(90)
		self.left_label = createLabel(20,cc.c4b(0xff,0xff,0xff,0xff),cc.c4b(0x8f,0x1d,0x0b,0xff),23,42,"",self.left_icon,2, cc.p(0.5,0.5))
		self.left_label:setRotation(-45)
	end
	self.left_icon:setVisible(bool)
	str= str or ""
	self.left_label:setString(str)
end

--增加一个名字，默认位置为底部
function BackPackItem:setGoodsName(name,pos,font_size,color,line_color,scale)
	if not name then return end
	font_size = font_size or 24
	color = color or 156
	local scale = scale or 1
	local item_color = Config.ColorData.data_color4[156] 
	if type(color) == "number" then 
		item_color = Config.ColorData.data_color4[color] 
	else
		item_color = color
	end
	if not self.goods_name  then 
		self.goods_name = createLabel(font_size,item_color,line_color,self.Width/2,-30,"",self.root_wnd,2, cc.p(0.5,0))
		self.goods_name:setScale(1 / scale)
	end
	name = name or ""
	self.goods_name:setString(name)
	if pos then 
		self.goods_name:setPosition(pos)
	end
end

-- 显示背景为 common_90010 ，颜色为品质色的物品名称
function BackPackItem:showItemQualityName( status )
	if status == true then
		if not self.quality_name_bg then 
			local res = PathTool.getResFrame("common","common_90010")
			self.quality_name_bg = createImage(self.main_container, res, self.size.width*0.5, -5, cc.p(0.5, 1), true, nil, true)
			self.quality_name_bg:setContentSize(cc.size(128, 37))
			self.quality_name_txt = createLabel(20, 1, nil, 128*0.5, 37*0.5, "", self.quality_name_bg, nil, cc.p(0.5, 0.5))
		end
		if self.item_config then
			self.quality_name_txt:setString(self.item_config.name)
			self.quality_name_txt:setTextColor(BackPackConst.getWhiteQualityColorC4B(self.item_config.quality))
		end
	elseif self.quality_name_bg then
		self.quality_name_bg:setVisible(false)
	end
end

function BackPackItem:setGrayIcon(bool)
	if bool == false and not self.gray_bg then return end
	if not self.gray_bg then 
		local res = PathTool.getResFrame("common","common_1073")
		self.gray_bg = createImage(self.main_container,res,self.size.width/2,self.size.height/2,cc.p(0.5,0.5),true,0,true)
		self.gray_bg:setContentSize(self.size.width,self.size.height)
	end
	self.gray_bg:setVisible(bool)
end

function BackPackItem:changeSelectStatus(bool,is_sell)
end

function BackPackItem:getSellSelectStatus()
	if not self.sell_select then return false end
	return self.sell_select:isVisible()
end

--[[
    @desc:这是现实红点或者是提升箭头
    author:{author}
    time:2018-08-13 21:58:16
    --@status:
	--@type: 
    @return:
]]
function BackPackItem:showNoticeTips(status, type)
	if status == false then
		self:showRedPoint(false)
		self:showUpgradeIcon(false)
	else
		self:showRedPoint(type == 1)
		self:showUpgradeIcon(type == 2)
	end
end

function BackPackItem:showRedPoint(status)
	if not self.red_point and status == false then 
        return 
    end

    if not self.red_point then 
        local res = PathTool.getResFrame("common","common_1014")
        self.red_point =createImage(self,res,84,84,cc.p(0,0),true,10,false)
    end
    self.red_point:setVisible(status)
end

function BackPackItem:showUpgradeIcon(status)
	if not self.upgrade_icon and status == false then 
        return 
    end

    if not self.upgrade_icon then 
        local res = PathTool.getResFrame("common","common_1086")
        self.upgrade_icon =createImage(self,res,84,8,cc.p(0,0),true,10,false)
    end
    self.upgrade_icon:setVisible(status)
	if status then
		breatheShineAction4(self.upgrade_icon)
	else
		doStopAllActions(self.upgrade_icon)
	end
end

--[[
    @desc: 设置双倍的戳
    author:{author}
    time:2018-08-09 20:50:27
    --@status: 
    @return:
]]
function BackPackItem:setDoubleIcon(status)
	if status == false then
		if self.double_icon then
			self.double_icon:setVisible(false)
		end
	else
		if self.double_icon == nil then
			self.double_icon = createSprite(PathTool.getResFrame("common","txt_cn_common_90008"),0,119,self,cc.p(0,1),LOADTEXT_TYPE_PLIST,20)
		end
		self.double_icon:setVisible(true)
	end
end

--显示必得
function BackPackItem:showGainTag(status,scale)
    if not self.tag_point and status == false then
        return
    end
	scale = scale or  1
    if not self.tag_point then
        local res = PathTool.getResFrame("common", "common_30012")
		self.tag_point = createImage(self, res,0,119, cc.p(0, 1), true, 10, false)
		self.tag_label = createLabel(18, 1, cc.c4b(0x87,0x18,0x00,0xff), 29, 32, TI18N("必得"), self.tag_point, 1, cc.p(0.5, 0))
		self.tag_label:setRotation(-45)
		self.tag_point:setScale(1 / scale)
	end
    self.tag_point:setVisible(status)
end

--[[
    @desc:设置首通标记
    author:{author}
    time:2018-08-14 14:04:29
    --@status: 
    @return:
]]
function BackPackItem:setFirstIcon(status,scale)
	if status == false then
		if self.first_icon then
			self.first_icon:setVisible(false)
		end
	else
		scale = scale or 1
		if self.first_icon == nil then
			self.first_icon = createSprite(PathTool.getResFrame("common","txt_cn_common_90018"),120,120,self,cc.p(1,1),LOADTEXT_TYPE_PLIST,20)
		end
		self.first_icon:setVisible(true)
		self.first_icon:setScale(1 / scale)
	end
end

-- 设置已领取标识
function BackPackItem:setReceivedIcon( status )
	if status == false then
		if self.received_icon then
			self.received_icon:setVisible(false)
		end
		self:setItemIconUnEnabled(false)
	else
		if self.received_icon == nil then
			self.received_icon = createSprite(PathTool.getResFrame("common","common_1000"),BackPackItem.Width/2,BackPackItem.Height/2,self,cc.p(0.5, 0.5),LOADTEXT_TYPE_PLIST,20)
		end
		self.received_icon:setVisible(true)
		self:setItemIconUnEnabled(true)
		setChildUnEnabled(false, self.received_icon)
	end
end

-- 设置已领取标识(嘉年华报告活动使用)
function BackPackItem:setReceivedIcon1( status )
	if status == false then
		if self.lay_received then
			self.lay_received:setVisible(false)
		end		
	else
		if self.lay_received == nil then
            self.lay_received = ccui.Layout:create()
            self.lay_received:setAnchorPoint(cc.p(0.5,0.5))
            self.lay_received:setContentSize(cc.size(self.size.width-4, self.size.height-4))
            self.lay_received:setPosition(self.size.width/2, self.size.height/2) 
            self.lay_received:setTouchEnabled(false)
            showLayoutRect(self.lay_received, 60)
            local res = PathTool.getResFrame("mainui","mainui_1037")
            createImage(self.lay_received,res,self.size.width/2,self.size.height/2,cc.p(0.5,0.5),true,0,false)
            self:addChild(self.lay_received)
        else
            self.lay_received:setVisible(true)
        end
	end

	
end

-- 已获得
function BackPackItem:setGotIcon( status )
	if status == false then
		if self.got_icon then
			self.got_icon:setVisible(false)
		end
	else
		if self.got_icon == nil then
			self.got_icon = createImage(self, PathTool.getResFrame("common","common_1074"),BackPackItem.Width/2,BackPackItem.Height/2, cc.p(0.5, 0.5), true, 20, true)
			self.got_icon:setContentSize(cc.size(BackPackItem.Width, BackPackItem.Height))
			local icon = createSprite(PathTool.getResFrame("common","txt_cn_common_get"),BackPackItem.Width/2,BackPackItem.Height/2,self.got_icon,cc.p(0.5, 0.5),LOADTEXT_TYPE_PLIST,20)
		end
		self.got_icon:setVisible(true)
	end
end

--显示使用或者可用
function BackPackItem:showUseTag(status,show_type,scale)
	if status == true then
		scale = scale or 1
		local res = PathTool.getResFrame("common","txt_cn_common_30015")
		-- if show_type == 2 then
		-- 	res = PathTool.getResFrame('common', 'txt_cn_common_30015')
		-- else
		-- 	res = PathTool.getResFrame('common', 'txt_cn_common_30014')
		-- end
		if not self.use_ponit then
			self.use_ponit = createImage(self.main_container, res,55, 122, cc.p(0, 1), true, 10, false)
		end
		if self.use_ponit and not tolua.isnull(self.use_ponit) then
			self.use_ponit:loadTexture(res,LOADTEXT_TYPE_PLIST)
			self.use_ponit:setVisible(status)
		end
	else
		if self.use_ponit and not tolua.isnull(self.use_ponit) then
			self.use_ponit:removeAllChildren()
			self.use_ponit:removeFromParent()
			self.use_ponit = nil
		end
	end
end

--显示周卡
function BackPackItem:showWeekCardTag(status)
	if status == true then
		local res = PathTool.getResFrame("common","txt_cn_common_90023")
		if not self.use_week_card then
			 self.use_week_card = createSprite(res, 0, 115, self.main_container, cc.p(0, 1), LOADTEXT_TYPE_PLIST, 10)
		end
		if self.use_week_card and not tolua.isnull(self.use_week_card) then
			loadSpriteTexture(self.use_week_card, res, LOADTEXT_TYPE_PLIST)
			self.use_week_card:setVisible(status)
		end
	else
		if self.use_week_card and not tolua.isnull(self.use_week_card) then
			self.use_week_card:removeAllChildren()
			self.use_week_card:removeFromParent()
			self.use_week_card = nil
		end
	end
end

function BackPackItem:showDoubleTag(status,num)
	if not self.double_ponit then
		local res = PathTool.getResFrame('common', 'common_30012')
		self.double_ponit = createImage(self.main_container, res, 0, 119, cc.p(0, 1), true, 10, false)
		self.use_ponit_label = createLabel(18, 1, cc.c4b(0x87,0x18,0x00,0xff), 29, 32, TI18N("双倍"), self.tag_point, 1, cc.p(0.5, 0))
		self.use_ponit_label:setRotation(-45)
	end
	if self.double_ponit and not tolua.isnull(self.double_ponit) then
		self.double_ponit:setVisible(status)
	end
	if self.num_label and not tolua.isnull(self.num_label) then
		if status == true then
			self.num_label:setVisible(true)
			self.num_label:setString(num * 2)
			self.num_bg:setVisible(true)
			self:updateNumBGSize()
		else
			if num <= 1 then
				self.num_label:setVisible(false)
				self.num_bg:setVisible(false)
			end
			self.num_label:setString(num)
			self:updateNumBGSize()
		end
	end
end

-- 给定资源路径显示标识
function BackPackItem:showFlagByRes( status, res, pos_x, pos_y )
	if status == true then
		if self.flag_icon == nil then
			self.flag_icon = createImage(self.main_container, res, pos_x or -9, pos_y or 126, cc.p(0, 1), true, 10, false)
		end
		if self.flag_icon and not tolua.isnull(self.flag_icon) then
			self.flag_icon:setVisible(status)
		end
	elseif self.flag_icon then
		self.flag_icon:setVisible(false)
	end
end

-- 左\右上角标识 dir:1左上角，2右上角
function BackPackItem:showTagIcon( status, tag_type, dir )
	if status == true then
		dir = dir or 1
		local tag_res = PathTool.getResFrame("common","common_30013")
		local tag_str = ""
		local outcolor = cc.c4b(0x8e,0x2b,0x00,0xff)
		if tag_type == 1 then
			tag_res = PathTool.getResFrame("common","common_30013")
			tag_str = TI18N("已领悟")
			outcolor = cc.c4b(0x8e,0x2b,0x00,0xff)
		end
		if not self.tag_icon then
			self.tag_icon = createSprite(tag_res,31,87,self.main_container,cc.p(0.5,0.5))
			self.tab_label = createLabel(18,Config.ColorData.data_color4[1],cc.c4b(0x95,0x0f,0x00,0xff),25,87,"",self.main_container,2,cc.p(0.5,0))
			if dir == 1 then
				self.tab_label:setRotation(-45)
				self.tag_icon:setPosition(cc.p(31,87))
				self.tab_label:setPosition(cc.p(25,87))
			elseif dir == 2 then
				self.tag_icon:setScaleX(-1)
				self.tab_label:setRotation(45)
				self.tag_icon:setPosition(cc.p(88,87))
				self.tab_label:setPosition(cc.p(91,89))
			end
		else
			loadSpriteTexture(self.tag_icon, tag_res, LOADTEXT_TYPE_PLIST)
		end
		self.tab_label:setString(tag_str)
		self.tab_label:enableOutline(outcolor, 2)
		self.tag_icon:setVisible(true)
		self.tab_label:setVisible(true)
	else
		if self.tag_icon then
			self.tag_icon:setVisible(false)
		end
		if self.tab_label then
			self.tab_label:setVisible(false)
		end
	end
end

--==============================--
--desc:设置左边斜角的一些戳
--time:2018-09-15 11:44:53
--@desc:
--@return 
--==============================--
function BackPackItem:showExtendTag(status, desc, extend)
	if not status then
		if self.extend_tag then
			self.extend_tag:setVisible(false)
		end
	else
		if self.extend_tag == nil then
			if extend == nil then
				self.extend_tag = createImage(self.main_container, PathTool.getResFrame('common', 'common_30012'), 0, 119, cc.p(0, 1), true, 10, false)
				self.extend_tag_desc = createLabel(18, 1, cc.c4b(0x87,0x18,0x00,0xff), 29, 32, "", self.extend_tag, 1, cc.p(0.5, 0))
			else
				self.extend_tag = createImage(self.main_container, PathTool.getResFrame('common', 'common_90016'), 0, 119, cc.p(0, 1), true, 10, false)
				self.extend_tag_desc = createLabel(18, 1, cc.c4b(0x02,0x6a,0x02,0xff), 26, 46, "", self.extend_tag, 1, cc.p(0.5, 0.5))
				self.extend_tag_desc:disableEffect(cc.LabelEffect.OUTLINE)
			end
			self.extend_tag_desc:setRotation(-45)
		end
		self.extend_tag:setVisible(true)
		self.extend_tag_desc:setString(desc)
	end
end

--活动时候远征的物品
function BackPackItem:holidHeroExpeditTag(status,desc)
	if status == false then
		if self.heroExpeditTag then
			self.heroExpeditTag:setVisible(status)
		end
	else
		if self.heroExpeditTag == nil then
			self.heroExpeditTag = createSprite(PathTool.getResFrame('common', 'common_90081'), 90, 88, self.main_container, cc.p(0.5, 0.5))
			self.heroExpeditTag_desc = createLabel(16, 1, cc.c4b(0xaf,0x23,0x3a,0xff), 46, 48, "", self.heroExpeditTag, 2, cc.p(0.5, 0.5))
			self.heroExpeditTag_desc:setRotation(45)
		end
		self.heroExpeditTag:setVisible(status)
		self.heroExpeditTag_desc:setString(desc)

	end
end

--- 设置宝石的显示状态
function BackPackItem:setGemStoneList(list)
	if list == nil then
		if self.gemstone_container then
			self.gemstone_container:setVisible(false)
		end
	else
		
	end
end

function BackPackItem:setNum(num)
	if num > 0 then
		self.num_label:setVisible(true)
		self.num_label:setString(num) 
		self.num_bg:setVisible(true)
		self:updateNumBGSize()
	else
		self.num_label:setVisible(false)
		self.num_bg:setVisible(false)
	end
end

-- 任意数量都显示
function BackPackItem:setNum2(num)
	self.num_label:setVisible(true)
	self.num_label:setString(num) 
	self.num_bg:setVisible(true)
	self:updateNumBGSize()
	local color = 1
	if num <= 0 then
		color = 127
	end
	if color and Config.ColorData.data_color4[color] then
		self.num_label:setTextColor(Config.ColorData.data_color4[color])
	end
	if outcolor and Config.ColorData.data_color4[outcolor] then
		self.num_label:enableOutline(Config.ColorData.data_color4[outcolor], 2)
	end
end

function BackPackItem:updateNumBGSize()
	local size = self.num_label:getContentSize()
	local width = size.width
	if width < 30 then
		width = 21
	end
	self.num_bg:setContentSize(cc.size(width+6, self.num_bg_size.height))
end

--==============================--
--desc:设置特殊的显示数字
--time:2018-06-15 10:12:24
--@return 
--==============================--
function BackPackItem:setSpecialNum(str)
	if not tolua.isnull(self.num_label) then
		self.num_label:setVisible(true)
		self.num_label:setString(str)
		self.num_bg:setVisible(true)
		self:updateNumBGSize()
	end
end
--改变字体的颜色值
function BackPackItem:setSpecialColor(_bool)
	if not tolua.isnull(self.num_label) then
		if _bool == true then
			self.num_label:setTextColor(Config.ColorData.data_color4[240])
		else
			self.num_label:setTextColor(Config.ColorData.data_color4[1])
		end
	end
end
--隐藏数字背景
function BackPackItem:setShowNumBg( status )
	self.num_bg:setVisible(status)
end

--==============================--
--desc:显示tips的开关
--time:2018-07-02 01:54:41
--@is_show_source:是否显示来源
--@return is_tips_source:物品信息界面，显示来源按钮（主要针对未获得的物品，却要显示来源的）
--==============================--
function BackPackItem:setDefaultTip(is_show_tips,is_show_source,source_callback,is_tips_source)
	if is_show_tips == nil then
		is_show_tips = true
	end
	self.is_show_tips = is_show_tips
	self.is_show_source = is_show_source or false
	self.source_callback = source_callback
	self.is_tips_source = is_tips_source 
end

function BackPackItem:update()
end

function BackPackItem:effectHandler()
end

function BackPackItem:showItemEffect(bool, effect_id, action,is_loop,scale)
	if bool == true then
		scale = scale or 1
		local res = Config.EffectData.data_effect_info[effect_id]
		if self.record_effect_res == nil or self.record_effect_res ~= res then
			self:clearPlayEffect()
			self.record_effect_res = res
			local x = BackPackItem.Width*0.5
			local y = BackPackItem.Height*0.5
			if effect_id == 354 then
				y = 51
			end
			self.play_effect = createEffectSpine(res, cc.p(x, y), cc.p(0.5, 0.5), is_loop, action)
			self.play_effect:setScale(scale)
			self.main_container:addChild(self.play_effect, 1)
		end
	else
		self:clearPlayEffect()	
	end
end

function BackPackItem:clearPlayEffect()
	if self.play_effect then 
		self.play_effect:setVisible(false)
		self.play_effect:removeFromParent()
		self.play_effect = nil
		self.record_effect_res = nil
	end
end
--设置特效层级
function BackPackItem:setEffectLocalZOrder(num)
	if self.play_effect then 
		self.play_effect:setLocalZOrder(num)
	end
end

--==============================--
--desc:是否在物品下方显示扩展描述字体
--time:2018-09-06 01:52:02
--@status:是否显示
--@desc:显示的描述,如果不填,则表示显示物品基础名字
--@color:文字颜色
--@outcolor:文字描边颜色
--@is_show_bg: 是否显示显示文本的
--@show_bg_name: 显示文本的底的名字, 默认
--@font_size 字体大小
--@return 
--==============================--
function BackPackItem:setExtendDesc(status, desc, color, outcolor, is_show_bg, font_size)
	if status == false then
		if self.extend_desc then
			self.extend_desc:setVisible(false)
		end
		if self.extend_bg then
			self.extend_bg:setVisible(false)
		end
	else
		local pos = cc.p(60, -5)
		if not self.extend_desc then
			self.extend_desc = createRichLabel(26, 178, cc.p(0.5, 1), pos)
			self.main_container:addChild(self.extend_desc,1)
		end

		if is_show_bg then
			if not self.extend_bg then
				local res = PathTool.getResFrame("common", "common_90003")
				self.extend_bg = createImage(self.main_container, res, 60, -18, cc.p(0.5, 0.5), true, 0, true)
				self.extend_bg:setCapInsets(cc.rect(20, 15, 1, 1))
				self.extend_bg:setContentSize(cc.size(177, 33))
			else
				self.extend_bg:setVisible(true)
			end
		else
			if self.extend_bg then
				self.extend_bg:setVisible(false)
			end
		end

		local item_color = nil
		if desc == nil then -- 如果不设置,默认是物品名字
			if self.data then
				if self.data.config then
					desc = self.data.config.name
					item_color = BackPackConst.quality_color_id[self.data.config.quality or 0]
				else
					desc = self.data.name
					item_color = BackPackConst.quality_color_id[self.data.quality or 0]
				end
			end
		end
		color = color or item_color or 178
		font_size =  font_size or 26
		local name_len = StringUtil.getStrLen(desc)
		if name_len > 14 then
			font_size = 20
		end
		if outcolor == nil then
			desc = string.format( "<div fontcolor=%s fontsize=%d >%s</div>", tranformC3bTostr(color), font_size, desc)
		else
			desc = string.format( "<div fontcolor=%s fontsize=%d outline=1,%s >%s</div>", tranformC3bTostr(color), font_size, tranformC3bTostr(outcolor), desc )
		end
		
		self.extend_desc:setString(desc)
		self.extend_desc:setVisible(true)
	end
end

-- 神器星数显示
function BackPackItem:setArtifactStars(  )
	local star_num = 0
	if self.data and self.data.config and self.data.config.type == BackPackConst.item_type.ARTIFACTCHIPS then
		if self.data.enchant and self.data.enchant > 0 then
			star_num = self.data.enchant or 0
		end
	end
	self:setEquipJie(true)
end

--提示音乐
function BackPackItem:playItemSound()
	if self.item_sound ~= nil then
		AudioManager:getInstance():removeEffectByData(self.item_sound)
	end
	self.item_sound = AudioManager:getInstance():playEffect(AudioManager.AUDIO_TYPE.COMMON, 'c_get02', false)
end

function BackPackItem:clearInfo()
	self:suspendAllActions()
	self:removeFromParent()
end

function BackPackItem:suspendAllActions()
	if self.data then
		if self.item_update_event ~= nil then
			self.data:UnBind(self.item_update_event)
			self.item_update_event = nil
		end
	end
	if self.use_ponit and not tolua.isnull(self.use_ponit) then
		self.use_ponit:removeAllChildren()
		self.use_ponit:removeFromParent()
		self.use_ponit = nil
	end

	self:showRedPoint(false)
	self:showAddIcon(false)
	self:setEnchantLev(0)
	self:setEquipJie(false)
	self:setElfinStep(false)
	self:showUseTag(false)
	self:showWeekCardTag(false)
	self:setSelfBackground(0)
	self:setMagicIcon(false)
	self:showItemQualityName(false)
	-- self.chips_icon:setVisible(false)
	self.num_label:setVisible(false)
	self.num_bg:setVisible(false)
	self.item_icon:setVisible(false)
	-- if self.artifact_container then
	-- 	self.artifact_container:setVisible(false)
	-- end
	if self.chipSprite then
		self.chipSprite:setVisible(false)
	end
	if self.camp_icom then
		self.camp_icom:setVisible(false)
	end
	if self.compLayer then
		self.compLayer:setVisible(false)
	end

	self:setGodHolyEquipmentUI(false)
	self:setSuitShopStar(false)

	self:clearPlayEffect()
	self:setCheckBoxStatus(false, false)
	self.data = nil
end

-- 除+号和数量以外都置灰
function BackPackItem:setItemIconUnEnabled( bool )
	setChildUnEnabled(bool, self.main_container)
	if self.num_label then
		setChildUnEnabled(false, self.num_label)
	end
	if self.add_btn then
		setChildUnEnabled(false, self.add_btn)
	end
end

-- 隐藏背景框
function BackPackItem:setIsShowBackground( status )
	self.background:setVisible(status)
end

--显示物品服数字（现在用到召唤的概率）
function BackPackItem:setSummonNumber(label)
	if not self.summon_text then
		self.summon_text = createLabel(22,cc.c4b(0xea,0xb5,0x50,0xff),nil,62,-15,"",self.main_container,nil, cc.p(0.5,0.5))
	end
	self.summon_text:setString(label.."%")
end

--灰化状态 上面加文本描述
function BackPackItem:grayStatus(bool,opacity,str)
	opacity = opacity or 150
	if bool == false and not self.gray_bg then return end
	if not self.gray_bg then
		self.gray_bg = ccui.Layout:create()
        self.gray_bg:setAnchorPoint(cc.p(0.5,0.5))
        self.gray_bg:setContentSize(self.size)
        self.gray_bg:setPosition(self.size.width/2, self.size.height/2) 
        self.gray_bg:setTouchEnabled(false)
		showLayoutRect(self.gray_bg, opacity)
		self.gray_text = createLabel(24,1,cc.c4b(0x85,0x14,0x14,0xff),self.gray_bg:getContentSize().width/2,self.gray_bg:getContentSize().height/2,str,self.gray_bg,2, cc.p(0.5,0.5))
		self:addChild(self.gray_bg)
	end
	self.gray_bg:setVisible(bool)
end

-- 第一种样式的选中状态
function BackPackItem:setBoxSelected( status )
    if status then
        if self.box_select == nil then
            local res = PathTool.getResFrame("stronger","stronger_3")
            self.box_select = createImage(self, res, self.size.width/2, self.size.height/2-10, cc.p(0.5, 0.5), true)
            self.box_select:setScale(1.25)
        else
            self.box_select:setVisible(true)
        end
    else
        if self.box_select then
            self.box_select:setVisible(false)
        end
    end
end

-- 中间显示文字 黑底 + 文字
--@setting 
--@setting.color 颜色 默认 00ff00
--@setting.font_size 大小  默认 26

function BackPackItem:showStrTips(status, str, setting)
    if status then
        if self.tips_img == nil then
			local size = cc.size(80, 33)
            local res = PathTool.getResFrame("common", "common_1035")
			self.tips_img = createImage(self.main_container, res, 60, 62, cc.p(0.5, 0.5), true, 0, true)
			self.tips_img:setCapInsets(cc.rect(20, 15, 1, 1))
			self.tips_img:setContentSize(size)
			local setting = setting or {}
			local color = setting.color or  cc.c3b(0x00,0xff,0x00)
            local font_size = setting.font_size or 26
            self.tips_text = createLabel(font_size, color,nil, size.width/2, size.height/2, str, self.tips_img, nil, cc.p(0.5, 0.5))

        else
            self.tips_img:setVisible(true)
            if self.tips_text and str then
            	self.tips_text:setString(str)
            end
        end
    else
        if self.tips_img then
            self.tips_img:setVisible(false)
        end
    end
end

function BackPackItem:DeleteMe()
	if self.data then
		if self.item_update_event ~= nil then
			self.data:UnBind(self.item_update_event)
			self.item_update_event = nil
		end
		self.data = nil
	end
	self:clearPlayEffect()
	self:removeAllChildren()
    self:removeFromParent()
end
