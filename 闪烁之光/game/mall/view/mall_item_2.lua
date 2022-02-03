-- --------------------------------------------------------------------
-- 竖版商城单个item
-- 
-- @author: shuwen@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
MallItem2 = class("MallItem2", function()
	return ccui.Widget:create()
end)

function MallItem2:ctor()
   	self.is_limit = false
	self.limit_have_num = 0
	self.lock_desc = ""
    self.ctrl = MallController:getInstance()
    self.role_vo = RoleController:getInstance():getRoleVo()
	self:configUI()
end

function MallItem2:configUI( ... )
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("mall/mall_item_2"))
	
    self:setAnchorPoint(cc.p(0, 1))
    self:addChild(self.root_wnd)
	self:setCascadeOpacityEnabled(true)
	self:setContentSize(cc.size(306,143))
	self:setTouchEnabled(true)

    self.main_container = self.root_wnd:getChildByName("main_container")
	self.main_container:setTouchEnabled(true)
	self.main_container:setSwallowTouches(false)

	self.name_panel = self.main_container:getChildByName("name_panel")
	self.name = self.name_panel:getChildByName("name")
	local count_bg = self.main_container:getChildByName("count_bg")
	self.coin = count_bg:getChildByName("coin")
	self.price = count_bg:getChildByName("price")

	self.goods_item = BackPackItem.new(true,true)
	self.goods_item:setPosition(20+self.goods_item:getContentSize().width/2,self:getContentSize().height/2 +4)
	self.main_container:addChild(self.goods_item)

	self.discount = self.main_container:getChildByName("discount")
	self.discount:setLocalZOrder(20)
	self.discount_num = self.discount:getChildByName("discount_num")
	self.discount:setVisible(false)

	self.discount_label = createRichLabel(20,cc.c3b(64, 32, 23),cc.p(0,0),cc.p(151,65))
	self.discount_label:setString(TI18N("限购xxx个"))
	self.main_container:addChild(self.discount_label)
	self.discount_label:setVisible(false)

	self.sold = self.main_container:getChildByName("sold")
	self.sold:setLocalZOrder(20)
	self.sold:setVisible(false)

	self.grey = self.main_container:getChildByName("grey")
	self.grey:setVisible(false)

	self.need_icon = self.main_container:getChildByName("need_icon")
	self.need_label = self.main_container:getChildByName("need_label")
	self.need_icon:setVisible(false)
	self.need_label:setVisible(false)

	self:setSellAll( false )

	self:registerEvent()
end

function MallItem2:setData( data )
	local shop_num --商城类型
	if data.shop_type then 
		shop_num = data.shop_type
	else
		shop_num = data.type
	end 
	self.data = data
	
	local pay_config
	local pay_type 
	if type(data.pay_type) == "number" then
		pay_config = Config.ItemData.data_get_data(data.pay_type)
		pay_type = Config.ItemData.data_assets_id2label[data.pay_type]
	else
		pay_config = Config.ItemData.data_get_data(Config.ItemData.data_assets_label2id[data.pay_type])
		pay_type = data.pay_type
	end
	if not pay_config then return end

	self.pay_type = pay_type
	
	self.goods_item:setDefaultTip()
	self.goods_item:showTagIcon(false)

	local item_id = data.item_bid or data.item_id
	local count = data.item_num or 1
	self.goods_item:setBaseData(item_id, count)
	if self.goods_item.data then
		-- local setting = {}
		-- setting.content = self.goods_item.data.name
		-- setting.max_width = 162
		-- setting.start_x = 0
		-- commonShowRollStr(self.name, setting)
		self.name:setString(self.goods_item.data.name)
	end

	-- 技能商店，判断符石是否被上阵英雄领悟
	if shop_num == MallConst.MallType.SkillShop then
		local is_learn = HeroController:getInstance():getModel():checkTalentIsLearnByBid(item_id)
		self.goods_item:showTagIcon(is_learn, 1, 2)
	end

	self.price:setString(data.price)
	loadSpriteTexture(self.coin, PathTool.getItemRes(pay_config.icon), LOADTEXT_TYPE)
	
	--限购
	self.str = ""
	local limit_num = 0
	local limit_rank = 0
	local limit_vip = 0
	local is_show_limit_label = false

	-- 天梯排名限购
	self.rank_limit_flag = false
	if data["limit_rank"] and data.limit_rank > 0 then
		if shop_num == MallConst.MallType.Ladder then
			local ladder_data = LadderController:getInstance():getModel():getLadderMyBaseInfo()
			if ladder_data and ladder_data.best_rank == 0 or ladder_data.best_rank > data.limit_rank then
				limit_rank = data.limit_rank
				is_show_limit_label = true
			end
		end
	end

	-- vip等级限购
	self.vip_limit_flag = 0
	if data["limit_vip"] and data.limit_vip > 0 then
		if self.role_vo and self.role_vo.vip_lev < data.limit_vip then
			is_show_limit_label = true
			limit_vip = data.limit_vip
		end
	end

	if is_show_limit_label == false then
		if data["limit_count"] and data.limit_count>0 then
			self.str = "限购"
			limit_num = data.limit_count
			is_show_limit_label = true
		elseif data["limit_month"] and data.limit_month>0 then
			self.str = "每月限购"
			limit_num = data.limit_month
			is_show_limit_label = true
		elseif data["limit_week"] and data.limit_week>0 then
			self.str = "每周限购"
			limit_num = data.limit_week
			is_show_limit_label = true
		elseif data["limit_day"] and data.limit_day>0 then
			self.str = "每日限购"
			limit_num = data.limit_day
			is_show_limit_label = true
		else
			if data.shop_type==4 or data.shop_type == 2 then
				limit_num = 1
				is_show_limit_label = false
			else
				--print("========pay_type===",pay_type)
				if pay_type ~= "red_gold_or_gold" then
					if self.role_vo[pay_type] and self.role_vo[pay_type]<(20*data.price) then --取资产最大可买
						local temp = math.floor(self.role_vo[pay_type]/data.price)
						if temp >= 1 then 
							limit_num = temp
						else
							limit_num = 1
						end
					else
						limit_num = 20 --无限制购买的物品 一次购买上限20
						is_show_limit_label = false
					end
				else
					local own = self.role_vo["gold"] + self.role_vo["red_gold"]
					--print("=====own====",own)
					if own and own <(20*data.price) then --取资产最大可买
						--limit_num = math.floor(own/data.price)
						local temp = math.floor(own/data.price)
						if temp >= 1  then 
							limit_num = temp
						else
							limit_num = 1
						end
					else
						limit_num = 20 --无限制购买的物品 一次购买上限20
						is_show_limit_label = false
					end
				end
			end
			--self.data.shop_type = 4
		end
	end

	if limit_vip > 0 and is_show_limit_label then
		self.discount_label:setVisible(true)
		self.discount_label:setString(string.format(TI18N("<div fontcolor=#289b14>      VIP%d</div>专属"),limit_vip))
		self:setSellAll( false )
		self.vip_limit_flag = limit_vip
	elseif limit_num>0 and is_show_limit_label then
		self.discount_label:setVisible(true)
		self.discount_label:setString(string.format(TI18N("%s <div fontcolor=#289b14>%s/%s</div> 个"),self.str,data.has_buy,limit_num))
		if data.has_buy == limit_num then
			--self.sold:setVisible(true)
			self:setSellAll( true )
		else
			--self.sold:setVisible(false)
			self:setSellAll( false )
		end
	elseif limit_rank>0 and is_show_limit_label then
		self.discount_label:setVisible(true)
		self.discount_label:setString(string.format(TI18N("<div fontcolor=#ff1f0e>需达到%d名</div>"),limit_rank))
		self:setSellAll( false )
		self.rank_limit_flag = true
	else
		self.discount_label:setVisible(false)
		if data.has_buy==1 then
			--self.sold:setVisible(true)
			self:setSellAll( true )
		else
			--self.sold:setVisible(false)
			self:setSellAll( false )
		end
	end
	-- print("====limit_num===",limit_num)
	self.data.limit_num = limit_num
	self.data.is_show_limit_label = is_show_limit_label

	--折扣标签和折扣价格
	if data["label"] and data.label>0 then --表里的
		self.discount:setVisible(true)
		self.discount_num:setString(data.label..TI18N("折"))
	elseif data["discount_type"] and data.discount_type>0 then --服务器的信息
		self.discount:setVisible(true)
		self.discount_num:setString(data.discount_type..TI18N("折"))
	else
		self.discount:setVisible(false)
	end

	if data["discount"] and data.discount>0 then
		self.price:setString(data.discount)
		self.price:setTextColor(Config.ColorData.data_color4[1])
	else
		self.price:setTextColor(Config.ColorData.data_color4[1])
	end
	if self.data.type == 10 or self.data.type == 11 or self.data.type == 12 or self.data.type == 13 then --装备特殊处理显示等级显示
		self:isShowLevLimit(true, self.data.lev)
	else
		self:isShowLevLimit(false)
	end
    if self.data.type == 5 and self.data.glev then
        self:isShowGLevLimit(true, self.data.glev)
    else
		self:isShowGLevLimit(false, 0)
    end

	local bid = self.ctrl:getNeedBid()
	if bid~=nil and (bid==data.item_id or bid==data.item_bid) then 
		self.need_icon:setVisible(true)
		self.need_label:setVisible(true)
	else
		self.need_icon:setVisible(false)
		self.need_label:setVisible(false)
	end
	if self.data.type == 3 then --神格商店
		local is_show = self.ctrl:getModel():checkHeroChips(data.item_id)
		self:showChipTag(is_show)
	else
		self:showChipTag(false)
	end
end

function MallItem2:showChipTag(status)
	if not self.tag_point and status == false then
		return
	end
	if not self.tag_point then
		local res = PathTool.getResFrame('common', 'txt_cn_common_30016')
		self.tag_point = createImage(self.main_container, res,8,132, cc.p(0, 1), true, 10, false)
		-- self.tag_label = createLabel(18, 1, cc.c4b(197, 102, 25, 255), 24, 28, TI18N('上阵中'), self.tag_point, 1, cc.p(0.5, 0))
		-- self.tag_label:setRotation(-45)
		self.tag_point:setScale(1)
	end
	self.tag_point:setVisible(status)
end

function MallItem2:isShowLevLimit(status,lev)
	if not self.limit_lev_label then
		self.limit_lev_label = createRichLabel(20, 58, cc.p(0, 0), cc.p(133, 25))
		self.limit_lev_label:setString(TI18N("xx级可购买"))
		self.main_container:addChild(self.limit_lev_label)
	end
	local role_lev = RoleController:getInstance():getRoleVo().lev
	self.limit_lev_label:setVisible(status)
	if status == true then
		local min_lev =  0
		if lev[1] and lev[1] then
			min_lev = lev[1] or 0
		end
		if self.limit_lev_label then
			if role_lev < min_lev then
				self.limit_lev_label:setString(string.format(TI18N("<div fontcolor=#289b14>%s</div>级可购买"),min_lev))
			else
				self.limit_lev_label:setString("")
			end
		end
	end
end

function MallItem2:isShowGLevLimit(status, glev)
	local guild_lev = RoleController:getInstance():getRoleVo().guild_lev
    if guild_lev >= glev then
        status = false
    end
    self.limit_glev_status = status
    if self.limit_glev_layer == nil and status == false then 
        return
    end
	if not self.limit_glev_layer then
        self.limit_glev_layer = createSprite(PathTool.getResFrame("common","common_90056"), 211, 30, self.main_container)
        self.limit_glev_layer:setLocalZOrder(9999)
        self.limit_glev_layer:setScaleX(0.5)
        self.limit_glev_layer:setScaleY(0.6)
		self.limit_glev_label = createRichLabel(20, 58, cc.p(0, 0), cc.p(155, 17))
		self.main_container:addChild(self.limit_glev_label, 9999)
	end
    self.limit_glev_layer:setVisible(status)
    self.limit_glev_label:setVisible(status)
    self.limit_glev_label:setString(string.format(TI18N("<div fontcolor=#ffffff outline=2,#d95014>公会%s级解锁</div>"), glev))
	self.grey:setVisible(status)
    self.limit_glev_status = status
end

function MallItem2:setSellAll( bool )
	self.sold:setVisible(bool)
	--setChildUnEnabled(bool,self)
	self.grey:setVisible(bool)
	self:setTouchEnabled(not bool)
end

function MallItem2:addCallBack( value )
	self.callback =  value
end

function MallItem2:registerEvent()
	self:addTouchEventListener(function(sender, event_type) 
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
					if self.vip_limit_flag > 0 then
						message(string.format(TI18N("VIP%d以上可购买"), self.vip_limit_flag))
						return
					end
					if self.rank_limit_flag then
						message(TI18N("未满足购买条件"))
                        return
					end
                    if self.limit_glev_status then
                        message(TI18N("该商品暂未达解锁条件哦，请努力提高公会等级"))
                        return
                    end
					if self.callback then
						self:callback()
					end
				end
			elseif event_type == ccui.TouchEventType.moved then
			elseif event_type == ccui.TouchEventType.began then
				self.touch_began = sender:getTouchBeganPosition()
			elseif event_type == ccui.TouchEventType.canceled then
			end
	end)

	--除神秘商城以外的购买成功
	if not self.buy_success_event then
		self.buy_success_event = GlobalEvent:getInstance():Bind(MallEvent.Buy_Success_Event,function ( data )
			if not data or not self.data then return end
			
			if self.data["id"] and data.eid == self.data.id and next(data.ext or {}) ~= nil then
				self.data.has_buy = data.ext[1].val
				self.discount_label:setString(string.format(TI18N("%s <div fontcolor=#289b14>%s/%s</div> 个"),self.str,self.data.has_buy,self.data.limit_num))
				if self.data.has_buy == self.data.limit_num then
					--self.sold:setVisible(true)
					self:setSellAll( true )
				end
			end
		end)
	end

	--神秘/神格商城购买成功
	if not self.buy_success_shenmi then
		self.buy_success_shenmi = GlobalEvent:getInstance():Bind(MallEvent.Buy_One_Success,function ( data )
			if not data or not self.data then return end
			self:buyOneSuccess(data)
		end)
	end

	if self.role_vo then
        if self.role_update_event == nil then
            self.role_update_event = self.role_vo:Bind(RoleEvent.UPDATE_ROLE_ATTRIBUTE,function(key,value)
            	if not self.data then return end
                if key == "gold" or key == "red_gold" or key =="hero_soul" or key == "arena_cent" or key == "friend_point" or key == "guild" then
                    if self.data["limit_day"]==0 and self.data["limit_month"]==0 and self.data["limit_week"]==0 and self.data["limit_count"]==0 then 
						--不限购的非神秘神格商店物品
                    	if self.data.shop_type~=4 and self.data.shop_type~=2 then
                    		if self.pay_type ~= "red_gold_or_gold" then
	                    		if self.role_vo[self.pay_type] and self.role_vo[self.pay_type]<(20*self.data.price) then --取资产最大可买
	                    			local temp = math.floor(self.role_vo[self.pay_type]/self.data.price)
	                    			if temp>=1 then
										self.data.limit_num = temp
									else
										self.data.limit_num = 1 
									end
								else
									self.data.limit_num = 20 --无限制购买的物品 一次购买上限20	
								end
							else
								local own = self.role_vo["gold"] + self.role_vo["red_gold"]
								if own and own <(20*self.data.price) then --取资产最大可买
									-- self.data.limit_num = math.floor(own/self.data.price)
									local temp = math.floor(own/self.data.price)
	                    			if temp>=1 then
										self.data.limit_num = temp
									else
										self.data.limit_num = 1 
									end
								else
									self.data.limit_num = 20 --无限制购买的物品 一次购买上限20
								end
							end
                    	end
                    end
                end
            end)
        end
    end
end

function MallItem2:buyOneSuccess(data)
	local shop_num --商城类型
	if self.data.shop_type then 
		shop_num = self.data.shop_type
	else
		shop_num = self.data.type
	end
	if shop_num == nil then return end

	if shop_num == data.type and self.data["order"] and data.order == self.data.order then
		if not self.data.has_buy then
			self.data.has_buy = data.num or 1
		else
			self.data.has_buy = self.data.has_buy + (data.num or 1)
		end
		self.discount_label:setString(string.format(TI18N("%s <div fontcolor=#289b14>%s/%s</div> 个"),self.str,self.data.has_buy,self.data.limit_num))
		local limit_num = self.data.limit_count
		if not limit_num or limit_num == 0 then
			limit_num = self.data.limit_num
		end
		if limit_num and self.data.has_buy >= limit_num then
			self:setSellAll( true )
		end
	end
end

function MallItem2:getData( )
	return self.data
end

function MallItem2:DeleteMe()
	if self.buy_success_event then 
        GlobalEvent:getInstance():UnBind(self.buy_success_event)
        self.buy_success_event = nil
    end

    if self.buy_success_shenmi then 
        GlobalEvent:getInstance():UnBind(self.buy_success_shenmi)
        self.buy_success_shenmi = nil
    end

	if self.goods_item then 
		self.goods_item:DeleteMe()
	end

	if self.role_vo then
        if self.role_update_event ~= nil then
            self.role_vo:UnBind(self.role_update_event)
            self.role_update_event = nil
        end
        self.role_vo = nil
    end
    doStopAllActions(self.name)
	self:removeAllChildren()
	self:removeFromParent()
end
