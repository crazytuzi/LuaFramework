-- -------------------
--  物品（圆形的）
-- -------------------
RoundItem = class("RoundItem", function() 
	return ccui.Layout:create()
end)

RoundItem.Width = 92
RoundItem.Height = 93

--==============================--
--desc:创建物品对象
-- click:是否可点击
-- scale: 框
-- scale1:里面的物品
--==============================--
function RoundItem:ctor(click,scale, scale1)
	self.click = click
	self.scale = scale or 1
	self.scale1 = scale1 or 1
	
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("backpack/round_item"))
    self.size = self.root_wnd:getContentSize()
    self:setAnchorPoint(cc.p(0.5, 0.5))
	self:setContentSize(self.size)
	self:setTouchEnabled(true)
	self:setCascadeOpacityEnabled(true)
	if self.scale ~= 1 then
		self:setScale(self.scale)
	end

	self.root_wnd:setAnchorPoint(0.5, 0.5)
	self.root_wnd:setPosition(self.size.width/2, self.size.height/2)
	self:addChild(self.root_wnd)

	self.main_container = self.root_wnd:getChildByName("main_container")
  	self.background = self.main_container:getChildByName("background")
  	self.round_bg = self.background:getChildByName("round_bg")
  	
  	self.item_icon = self.main_container:getChildByName("icon")
  	self.item_icon:setScale(self.scale1)
  	self.num_label = self.main_container:getChildByName("num")
  	self.num_label:setString("")
  	self.num_bg = self.main_container:getChildByName("num_bg")
	self.num_bg_size = self.num_bg:getContentSize()

	self.redpoint = self.main_container:getChildByName("redpoint")
	self.redpoint:setVisible(false)

	self.round_res_id = PathTool.getRoundQualityBg(1)

	self:registerEvent()
end

--红点
function RoundItem:setVisibleRedPoint(visible)
	visible = visible or false
	if self.redpoint then
		self.redpoint:setVisible(visible)
	end
end
--物品
function RoundItem:setVisibleIcon(visible)
	visible = visible or false
	if self.item_icon then
		self.item_icon:setVisible(visible)
	end
end
--物品框颜色
function RoundItem:setSelfBackground(quality)
	quality = quality or 1
	local res_id = PathTool.getRoundQualityBg(quality)
	if self.round_res_id ~= res_id then
		self.round_res_id = res_id
		self.background:loadTexture(self.round_res_id, LOADTEXT_TYPE_PLIST)
	end
end
--光圈
function RoundItem:setVisibleRoundBG(visible)
	visible = visible or false
	if self.round_bg then
		self.round_bg:setVisible(visible)
	end
end

function RoundItem:getData()
	return self.data
end
--desc:点击回调
--time:2017-07-03 08:02:23
--@callback:
--@return 
--==============================--
function RoundItem:addCallBack(callback)
	self.callback = callback
end

function RoundItem:registerEvent()
	if self.click == true then
		self:addTouchEventListener(function(sender, event_type) 
			if self.effect == true then
				customClickAction(self.main_container, event_type)
			end
			if event_type == ccui.TouchEventType.ended then
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
							if self.data then
								if self.data.config and self.data.config.type then
									type = self.data.config.type
								elseif self.data.type then
									type = self.data.type
								end
							end
							if BackPackConst.checkIsEquip(type) and (not self.is_spec) then
								HeroController:getInstance():openEquipTips(true, self.data)
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
								else
									TipsManager:getInstance():showGoodsTips(config)
								end
							end
							return
						end
						if self.callback then
							self:callback()
						end
					end
					
				end
			elseif event_type == ccui.TouchEventType.moved then
			elseif event_type == ccui.TouchEventType.began then
				self.touch_began = sender:getTouchBeganPosition()
			elseif event_type == ccui.TouchEventType.canceled then
			end
		end)
	end

end	

--desc:显示tips的开关
--time:2018-07-02 01:54:41
--@is_show_source:是否显示来源
--@return 
--==============================--
function RoundItem:setDefaultTip(is_show_tips)
	if is_show_tips == nil then
		is_show_tips = true
	end
	self.is_show_tips = is_show_tips
end
--物品数据
function RoundItem:setBaseData(bid, num)
	local config = Config.ItemData.data_get_data(bid)
	if config == nil then return end
	self.data = config 


	self.item_icon:setVisible(true)
	local head_icon = PathTool.getItemRes(config.icon, false)
	loadSpriteTexture(self.item_icon, head_icon, LOADTEXT_TYPE)

	-- 设置数量显示
	self:setSelfNum(num)

	-- 设置背景
	self:setSelfBackground(config.quality)

end

function RoundItem:setSelfNum(num)
	num = num or 0
	self.num_label:setVisible(num >1)
	self.num_bg:setVisible(num > 1)
	if num > 1 then
		self.num_label:setString(num)
		self:updateNumBGSize()
	end
end

function RoundItem:updateNumBGSize()
	local size = self.num_label:getContentSize()
	local width = size.width
	if width < 50 then
		width = 50
	end
	self.num_bg:setContentSize(cc.size(width+6, self.num_bg_size.height))
end


function RoundItem:DeleteMe()
	self:removeAllChildren()
    self:removeFromParent()
end