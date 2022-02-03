-- --------------------------------------------------------------------
-- 竖版邮件/公告详情
-- 
-- @author: shuwen@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
MailInfoWindow = MailInfoWindow or BaseClass(BaseView)
local controller = MailController:getInstance()
function MailInfoWindow:__init()
    self.is_full_screen = false
    self.win_type = WinType.Big     
	self.view_tag = ViewMgrTag.DIALOGUE_TAG          	
    self.layout_name = "mail/mail_info_window"  
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("mail","mail"), type = ResourcesType.plist },
    }
    self.goods_list = {}
    self.is_costome = nil --是否评分过
    self.touch_reple_start = nil --评分星级
    self.scrollView_half_height = 330--一半的高度
    self.scrollView_half_y = 194 --一半的y位置
    self.scroview_notice_y = 0 --公告的时候位置回向下，，所以位置是不一样的 
    self.init_pos_y = 50 --邮件的初始化位置
end

function MailInfoWindow:open_callback()
 	self.background = self.root_wnd:getChildByName("background")
	self.background:setScale(display.getMaxScale())
	
	local main_container = self.root_wnd:getChildByName("main_container")
    self:playEnterAnimatianByObj(main_container , 1) 
    local main_panel = main_container:getChildByName("main_panel")

    self.win_title = main_panel:getChildByName("win_title")
    self.win_title:setString(TI18N("邮件"))

    self.title_container = main_panel:getChildByName("title_container")
    self.title = self.title_container:getChildByName("title")
    self.time = self.title_container:getChildByName("time")
    self.icon = self.title_container:getChildByName("icon")
    
    local info_container = main_panel:getChildByName("info_container")
    local ic_size = info_container:getContentSize()  
    self.info_container_size = cc.size(ic_size.width, ic_size.height - 8 )
    local width = self.info_container_size.width

    self.scrollView = createScrollView(width,self.scrollView_half_height,0,self.scrollView_half_y,info_container,ccui.ScrollViewDir.vertical)
    local height = self.scrollView:getContentSize().height
    self.content = createRichLabel(24,58,cc.p(0,1),cc.p(20,height-50),5,0,525)
    self.scrollView:addChild(self.content)
    info_container:getChildByName("youxiao"):setVisible(false)
    self.youxiao = createLabel(20,Config.ColorData.data_color4[178],nil,width - 20 ,height - 25,TI18N("有效期"),self.scrollView,nil, cc.p(1, 0.5))
    self.goods_container = info_container:getChildByName("goods_container")
    self.goods_scroll = createScrollView(info_container:getContentSize().width-10,120,5,35,self.goods_container,ccui.ScrollViewDir.horizontal)
    self.goods_scroll_size = self.goods_scroll:getContentSize()
    local goods_title = self.goods_container:getChildByName("goods_title")
    goods_title:setString(TI18N("领取奖励"))
    self.take_label = self.goods_container:getChildByName("take_label")
    self.take_label:setVisible(false)

    --玩家反馈
    self.goods_reple = main_panel:getChildByName("goods_reple")
    self.goods_reple:setVisible(false)
    self.costome_score = self.goods_reple:getChildByName("goods_title")
    self.costome_score:setString("")
    self.touch_start = {}
    for i=1,5 do
    	local btn = self.goods_reple:getChildByName("start_"..i)
    	btn.start_select = btn:getChildByName("start_select")
    	btn.start_select:setVisible(false)
    	btn.index = i
    	self.touch_start[i] = btn 
    end
    self.btn_del = self.goods_reple:getChildByName("btn_del")
    self.btn_del:getChildByName("Text_3"):setString(TI18N("删除"))
    self.btn_submit = self.goods_reple:getChildByName("btn_submit")
    self.btn_submit:getChildByName("Text_3"):setString(TI18N("提交评分"))

    self.btn = main_panel:getChildByName("btn")
    self.btn.label = self.btn:getTitleRenderer()
    self.close_btn = main_panel:getChildByName("close_btn")
end

function MailInfoWindow:register_event()
	registerButtonEventListener(self.btn,function()
    	if self.data and self.data["status"] then --邮件
    		if self.data.assets and self.data.items then 
            	if #self.data.assets>0 or #self.data.items>0 and self.data.type == 1 then --领取
                	controller:getGoods(self.data.id,self.data.srv_id)
                elseif #self.data.assets<=0 or #self.data.items<=0 and self.data.type == 1 then--删除
                	local ids = {[1]={id=self.data.id,srv_id=self.data.srv_id}}
                	controller:deletMailSend(ids)
                	controller:openMailInfo(false)
                end
            end
        end
    end,true,1)	
	registerButtonEventListener(self.close_btn,function()
		controller:openMailInfo(false)
	end,false,2)
	registerButtonEventListener(self.background,function()
		controller:openMailInfo(false)
	end,false,2)

	self:addGlobalEvent(MailEvent.GET_ITEM_ASSETS, function(key) 
		if self.data then
			local item_key = getNorKey(self.data.id or 0, self.data.srv_id or "")
			if key == item_key then
				self:removeAsset(key)
			end
		end
    end)


	-- self:addGlobalEvent(MailEvent.Customer_Service_Status,function(data)
	-- 	if not data or next(data) == nil then return end
	-- 	if data.status then
	-- 		self.goods_reple:setVisible(false)
	-- 		if data.status ~= 0 then
	-- 			if data.status == 1 then
	-- 				self.costome_score:setString(TI18N("您已对该回复进行评分，评分如下："))
	-- 			else
	-- 				self.goods_reple:setVisible(false)
	-- 			end
	-- 			for i=1,5 do
	-- 				self.touch_start[i]:setTouchEnabled(false)
	-- 				if i<= data.score then
	-- 					self.touch_start[i].start_select:setVisible(true)
	-- 				end
	-- 			end
	-- 		else
	-- 			self.is_costome = true
	-- 			self.costome_score:setString(TI18N("冒险者对该回复是否满意？请进行评分："))
	-- 		end
	-- 	end
	-- end)
    --玩家反馈
  --   for i, btn in pairs(self.touch_start) do
  --   	registerButtonEventListener(btn,function()
		-- 	self:playRepleTabView(btn.index)
		-- end,false,1)
  --   end
 --    registerButtonEventListener(self.btn_del,function()
	-- 	local ids = {[1]={id=self.data.id,srv_id=self.data.srv_id}}
 --    	controller:deletMailSend(ids)
 --    	controller:openMailInfo(false)
	-- end,true,1)
	-- registerButtonEventListener(self.btn_submit,function()
	-- 	if not self.touch_reple_start then
	-- 		if self.is_costome == true then
	-- 			message(TI18N("亲，需要评分之后才能提交哦~~~"))
	-- 		end
	-- 	else
	-- 		controller:sender10811(self.data.id,self.data.srv_id,tonumber(self.touch_reple_start))
	-- 	end
	-- end,true,1)
end
function MailInfoWindow:playRepleTabView(index)
	index = index or 0
	if self.touch_reple_start == index then return end
	self.touch_reple_start = index

	for i=1,5 do
		if i <= self.touch_reple_start then
			if self.touch_start[i] and self.touch_start[i].start_select then
				self.touch_start[i].start_select:setVisible(true)
			end
		else
			if self.touch_start[i] and self.touch_start[i].start_select then
				self.touch_start[i].start_select:setVisible(false)
			end
		end
	end
end
function MailInfoWindow:setData( data )
	if data == nil then return end
	self.data = data

	local str2 = data.content
    str2 = string.gsub(str2, "&lt;", "<")
    str2 = string.gsub(str2, "&gt;", ">")
    str2 = string.gsub(str2, "&#039;", "'")
    str2 = string.gsub(str2, "&quot;", '"')
    str2 = WordCensor:getInstance():relapceAssetsTag(str2)
    if self.content then
	    self.content:setString(str2)
	end
    
	if data["status"] then --邮件
		self.title:setString(data.subject)
		self.time:setVisible(true)
		self.youxiao:setVisible(true)
		if data.assets and data.items then
			if data.type == 3 then
				--controller:sender10812(data.id,data.srv_id)
				self.btn:setVisible(false)
				self.goods_container:setVisible(false)
			else
				self.goods_reple:setVisible(false)
				if #data.assets>0 or #data.items>0 and data.type == 1 then
					self.btn:setVisible(true)
					self:changeButtonStatus(true)
					self.goods_container:setVisible(true)
					self:createGoodsList()
	                self:setScrollViewSize(true)
	            elseif #data.assets<=0 or #data.items<=0 and data.type == 1 then
	                self.btn:setVisible(true)
	                self:changeButtonStatus(false)
	                self.goods_container:setVisible(false)
	                self:setScrollViewSize(false)
	            else
	                self.btn:setVisible(false)
	                self.goods_container:setVisible(false)
	                self:setScrollViewSize(false)
				end
			end
		end
		local show_time = TimeTool.getDayOrHour(GameNet:getInstance():getTime()-data.send_time)
		if show_time then
			self.time:setString(show_time..TI18N("前"))
		else
			self.time:setString("")
		end

		local show_time = TimeTool.getDayOrHour(data.time_out-GameNet:getInstance():getTime())
		if show_time then
			self.youxiao:setString(TI18N("有效期：")..show_time)
		else
			self.youxiao:setString("")
		end
		self:changeIcon(data.status)

		controller:read(data.id,data.srv_id)
	elseif data["flag"] then --公告
		self.scrollView_half_height = 470
		self.scroview_notice_y = 140
		self.init_pos_y = 5

		self.win_title:setString(TI18N("公告"))
		self.title:setString(data.title)
		self.btn:setVisible(false)
		self.goods_container:setVisible(false)
		self.time:setVisible(false) --时间
		self.youxiao:setVisible(false)
        self:setScrollViewSize(false)
		self:changeIcon(data.flag)
	end

	if self.content then
		self.content:addTouchLinkListener(function (type, value, sender)
			if type == "href" then
				if value == "charge" then
					VipController:getInstance():openVipMainWindow(true)
					--MallController:getInstance():openChargeShopWindow(true, MallConst.Charge_Shop_Type.Diamond)
				elseif value == "mail" then
					if not RoleController:getInstance():getRoleVo():isHasGuild() then
				        message(TI18N("您没有加入公会，不能进行次操作~~~~"))
				        return
				    end
					GuildController:getInstance():openGuildMemberWindow(true)
				elseif value == "weekly" then
					local  roleVo = RoleController:getInstance():getRoleVo()
					local str = ""
					if roleVo then
						local str_tab = StringUtil.splitByFormat(roleVo.srv_id, "_") or {}
						local server_time = GameNet:getInstance():getTime()
						if str_tab ~= nil and next(str_tab) ~= nil then
							local _str = table.concat({roleVo.rid,str_tab[1],str_tab[2], server_time,'He952ae2a6ea8cdG7410j6T42d7ce32'}, ".") or ""
  	     					local sign = cc.CCGameLib:getInstance():md5str(_str)
  	     					if sign ~= nil then
								str = string.format(("https://sszg.shiyue.com/m/weekly.html#/?role_id=%s&platform=%s&zone_id=%s&is_self=1&ctime=%s&flag=%s"),roleVo.rid,str_tab[1],str_tab[2], server_time, sign)
								if IS_IOS_PLATFORM == true then
					        		sdkCallFunc("openSyW", str)
						    	else
						        	sdkCallFunc("openUrl", str)
						    	end
						    end
						end
					end
				else
					if IS_IOS_PLATFORM == true then
				        sdkCallFunc("openSyW", value)
				    else
				        sdkCallFunc("openUrl", value)
				    end
				end
			end
		end,{"click","href"})
	end
end

function MailInfoWindow:setScrollViewSize(is_have_item)
    local max_heigt
    if is_have_item then
        --是否有道具 有道具就要显示 一半的
        self.scrollView:setContentSize(cc.size(self.info_container_size.width, self.scrollView_half_height))
        self.scrollView:setPositionY(self.scrollView_half_y)
        max_heigt = self.scrollView_half_height
    else
    	local temp = false
    	-- 反馈回复
    	if temp == true then
    		local num = 50
    		self.scrollView:setContentSize(cc.size(self.info_container_size.width, self.scrollView_half_height+num))
	        self.scrollView:setPositionY(self.scrollView_half_y - self.scroview_notice_y - num)
	        max_heigt = self.scrollView_half_height+num
    	else
	        self.scrollView:setContentSize(self.info_container_size)
	        self.scrollView:setPositionY(4)
	        max_heigt = self.info_container_size.height
	    end
    end

    local size = self.content:getContentSize()
    local scroll_heigt = math.max(max_heigt, size.height + 50) 
    self.scrollView:setInnerContainerSize(cc.size(self.scrollView:getContentSize().width, scroll_heigt))
    self.content:setPositionY(scroll_heigt - self.init_pos_y)
    self.youxiao:setPositionY(scroll_heigt - 25) 
end

function MailInfoWindow:createGoodsList(  )
	if self.data.status == 2 then return end --领了的就不创建了
	local show_list = {}
	for k,v in pairs(self.data.assets) do
		table.insert(show_list,v)
	end
	for k,v in pairs(self.data.items) do
		table.insert(show_list,v)
	end

	if #self.data.items > 0 then
		self.take_label:setString(TI18N("占用背包空间：").. #self.data.items)
		self.take_label:setVisible(true)
	end
	local is_two = #show_list%2 

	local max_width = math.max((BackPackItem.Width+10)*#show_list,self.goods_scroll_size.width) 
	self.goods_scroll:setInnerContainerSize(cc.size(max_width,self.goods_scroll_size.height))

	for k,v in ipairs(show_list) do
		local item = BackPackItem.new()
		local config = deepCopy(Config.ItemData.data_get_data(v.label or v.base_id))
		config.quantity = v.val or v.quantity
		item:setData(config)
		local middle = max_width/2
		local height = self.goods_scroll_size.height/2
		if is_two == 0 then
			if k%2 ~= 0 then
				item:setPosition(self.goods_scroll:getPositionX()+middle-(item:getContentSize().width/2+8)*k,height)
			else
				item:setPosition(self.goods_scroll:getPositionX()+middle+(item:getContentSize().width/2+8)*(k-1),height)
			end
		else
			if k==1 then
				item:setPosition(middle,height)
			else
				if self.goods_list[1] then
					if k%2 == 0 then
						item:setPosition(self.goods_list[1]:getPositionX()-item:getContentSize().width/2-8-(item:getContentSize().width/2+8)*(k-1),height)
					else
						item:setPosition(self.goods_list[1]:getPositionX()+item:getContentSize().width/2+8+(item:getContentSize().width/2+8)*(k-2),height)
					end
				end
			end
		end
		self.goods_scroll:addChild(item)
		self.goods_list[k] = item
	end
end

function MailInfoWindow:openRootWnd(data)
	self:setData(data)
end

--==============================--
--desc:提取物品之后移除
--time:2019-02-16 11:05:01
--@id:
--@return 
--==============================--
function MailInfoWindow:removeAsset( id)
	if self.goods_list then
		for k,v in pairs(self.goods_list) do 
			if v then
				v:DeleteMe()
			end
		end
		self.goods_list = {}
	end
	self.goods_container:setVisible(false)
	self.data.assets = {}
	self.data.items = {}
	self.data.status = 2
	self:changeIcon(self.data.status)
	self:changeButtonStatus(false)
	self:setScrollViewSize(false)
end

function MailInfoWindow:changeButtonStatus( status )
	if status then
		local res = PathTool.getResFrame("common","common_1017")
		self.btn:loadTextures(res, res, "", LOADTEXT_TYPE_PLIST)
		self.btn:setTitleText(TI18N("领取"))
		self.btn.label:enableOutline(Config.ColorData.data_color4[264], 2)
	else
		local res = PathTool.getResFrame("common","common_1018")
		self.btn:loadTextures(res, res, "", LOADTEXT_TYPE_PLIST)
		self.btn:setTitleText(TI18N("删除"))
		self.btn.label:enableOutline(Config.ColorData.data_color4[263], 2)
	end
end

function MailInfoWindow:changeIcon( status  )
	if status then
		if status == 1 then --已读
			if (self.data.assets and self.data.items) and (#self.data.assets>0 or #self.data.items>0) then --读了没领
				loadSpriteTexture(self.icon, PathTool.getResFrame("mail", "mail_icon4"), LOADTEXT_TYPE_PLIST)
			else --读了领了
				loadSpriteTexture(self.icon, PathTool.getResFrame("mail", "mail_icon3"), LOADTEXT_TYPE_PLIST)
			end

		elseif status == 2 then --领了
			loadSpriteTexture(self.icon, PathTool.getResFrame("mail", "mail_icon3"), LOADTEXT_TYPE_PLIST)
		elseif status == 0 then --未读
			if (self.data.assets and self.data.items) and (#self.data.assets>0 or #self.data.items>0) then --有物品
				loadSpriteTexture(self.icon, PathTool.getResFrame("mail", "mail_icon2"), LOADTEXT_TYPE_PLIST)
			else
				loadSpriteTexture(self.icon, PathTool.getResFrame("mail", "mail_icon1"), LOADTEXT_TYPE_PLIST)
			end
		end
	end
end

function MailInfoWindow:close_callback()
	if self.goods_list then
		for k,v in pairs(self.goods_list) do 
			if v then
				v:DeleteMe()
			end
		end
		self.goods_list = nil
	end
	controller:openMailInfo(false)
end

