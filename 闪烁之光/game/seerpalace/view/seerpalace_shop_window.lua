--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2018-11-21 10:32:10
-- @description    : 
		-- 先知商店
---------------------------------
SeerpalaceShopWindow = SeerpalaceShopWindow or BaseClass(BaseView)

local controller = SeerpalaceController:getInstance()
local model = controller:getModel()

function SeerpalaceShopWindow:__init()
	self.win_type = WinType.Big
	self.is_full_screen = false
	self.layout_name = "seerpalace/seerpalace_shop_window"
	self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("mall", "mall"), type = ResourcesType.plist },
    }
	self.role_vo = RoleController:getInstance():getRoleVo()
	self.camp_list = {}
	self.cur_index = 1
	self.cur_camp_type = HeroConst.CampType.eNone

	self.role_vo = RoleController:getInstance():getRoleVo()
end

function SeerpalaceShopWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
	if self.background then
		self.background:setScale(display.getMaxScale())
	end

	local container = self.root_wnd:getChildByName("container")
	self.container = container
    self:playEnterAnimatianByObj(container , 2)

	local win_title = container:getChildByName("win_title")
	win_title:setString(TI18N("先知商店"))

	self.close_btn = container:getChildByName("close_btn")

	for i=1,6 do
    	local camp_btn = container:getChildByName("camp_btn_" .. i)
    	if camp_btn then
    		local camp_data = {}
    		camp_data.camp_btn = camp_btn
    		camp_data.select_image = camp_btn:getChildByName("select_image")
    		camp_data.select_image:setVisible(self.cur_index == i)
    		self.camp_list[i] = camp_data
    	end
    end

	local res_icon = container:getChildByName("res_icon")
	local item_config = Config.ItemData.data_get_data(SeerpalaceConst.Good_JieJing)
	if item_config then
		res_icon:loadTexture(PathTool.getItemRes(item_config.icon), LOADTEXT_TYPE)
	end
	self.res_label = container:getChildByName("res_label")
	self.res_label:setString(self.role_vo.recruithigh_hero)

	self.list_panel = container:getChildByName("list_panel")

	local setting = {
        item_class = MallItem,
        start_x = 2, -- 第一个单元的X起点
        space_x = 2, -- x方向的间隔
        start_y = 8, -- 第一个单元的Y起点
        space_y = 2, -- y方向的间隔
        item_width = 306, -- 单元的尺寸width
        item_height = 143, -- 单元的尺寸height
        row = 0, -- 行数，作用于水平滚动类型
        col = 2,                         -- 列数，作用于垂直滚动类
    	need_dynamic = true
    }
    self.item_scroll_view = CommonScrollViewLayout.new(self.list_panel, nil, nil, nil, cc.size(self.list_panel:getContentSize().width, self.list_panel:getContentSize().height), setting)
    self.item_scroll_view:setPosition(0, 0)
end

function SeerpalaceShopWindow:openRootWnd(  )
	MallController:getInstance():sender13401(MallConst.MallType.Seerpalace)
end

function SeerpalaceShopWindow:register_event(  )
	registerButtonEventListener(self.close_btn, handler(self, self._onClickBtnClose), false, 2)
	registerButtonEventListener(self.background, handler(self, self._onClickBtnClose), false, 2)

	for index,object in ipairs(self.camp_list) do
		if object.camp_btn then
			registerButtonEventListener(object.camp_btn, handler(self, self._onClickCampBtn), nil, nil, index)
		end
	end

	if not self.update_have_count then
        self.update_have_count = GlobalEvent:getInstance():Bind(MallEvent.Open_View_Event, function(data)
            self.srv_data = data or {}
            local list = self:getConfig()
            self.item_scroll_view:setData(list, function(cell)
                MallController:getInstance():openMallBuyWindow(true, cell:getData())
            end)
        end)
    end

	-- 积分资产更新
    if self.role_vo ~= nil then
        if self.role_assets_event == nil then
            self.role_assets_event = self.role_vo:Bind(RoleEvent.UPDATE_ROLE_ATTRIBUTE, function(key, value)
                if key == "recruithigh_hero" then
                    self.res_label:setString(value)
                end
            end)
        end
    end
end

function SeerpalaceShopWindow:getConfig(  )
	local item_list = {}
    local config = Config.ExchangeData.data_shop_exchage_seer
    if config and self.srv_data then
        local list = deepCopy(self.srv_data.item_list)
        for a, j in pairs(config) do
        	local item_config = Config.ItemData.data_get_data(j.item_bid)
        	if item_config and (self.cur_camp_type == HeroConst.CampType.eNone or item_config.lev == self.cur_camp_type) then -- 碎片阵营限制
        		if list and next(list or {}) ~= nil  then
	                for k, v in pairs(list) do --已经买过的限购物品
	                    if j.id == v.item_id then
	                        if v.ext[1].val then --不管是什么限购 赋值已购买次数就好了。。
	                            j.has_buy = v.ext[1].val
	                            table.remove(list, k)
	                        end
	                        break
	                    else
	                        j.has_buy = 0
	                    end
	                end
	            else
	                j.has_buy = 0
	            end
	            table.insert(item_list, j)
        	end
        end
    end
    table.sort(item_list ,function (a,b)
        if a.limit_count and a.limit_count > 0 and a.has_buy >= a.limit_count and (not b.limit_count or b.limit_count == 0 or b.has_buy < b.limit_count) then
            return false
        elseif b.limit_count and b.limit_count > 0 and b.has_buy >= b.limit_count and (not a.limit_count or a.limit_count == 0 or a.has_buy < a.limit_count) then
            return true
        else
            return  a.order < b.order
        end
    end)
    return item_list
end

function SeerpalaceShopWindow:_onClickBtnClose(  )
	controller:openSeerpalaceShopWindow(false)
end

function SeerpalaceShopWindow:_onClickCampBtn( index )
	if self.cur_index == index then return end

	if self.cur_index then
		local old_camp_data = self.camp_list[self.cur_index]
		if old_camp_data and old_camp_data.select_image then
			old_camp_data.select_image:setVisible(false)
		end
	end

	local cur_camp_data = self.camp_list[index]
	if cur_camp_data and cur_camp_data.select_image then
		cur_camp_data.select_image:setVisible(true)
	end

	self.cur_index = index
	if index == 1 then
		self.cur_camp_type = HeroConst.CampType.eNone
	elseif index == 2 then
		self.cur_camp_type = HeroConst.CampType.eWater
	elseif index == 3 then
		self.cur_camp_type = HeroConst.CampType.eFire
	elseif index == 4 then
		self.cur_camp_type = HeroConst.CampType.eWind
	elseif index == 5 then
		self.cur_camp_type = HeroConst.CampType.eLight
	elseif index == 6 then
		self.cur_camp_type = HeroConst.CampType.eDark
	end

	local list = self:getConfig()
    self.item_scroll_view:setData(list, function(cell)
        MallController:getInstance():openMallBuyWindow(true, cell:getData())
    end)
end

function SeerpalaceShopWindow:close_callback(  )
	controller:openSeerpalaceShopWindow(false)

	if self.role_vo ~= nil then
        if self.role_assets_event ~= nil then
            self.role_vo:UnBind(self.role_assets_event)
            self.role_assets_event = nil
        end
    end

    if self.update_have_count then
        GlobalEvent:getInstance():UnBind(self.update_have_count)
        self.update_have_count = nil
    end

    if self.item_scroll_view then
        self.item_scroll_view:DeleteMe()
        self.item_scroll_view = nil
    end
end