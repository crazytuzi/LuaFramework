-- --------------------------------------------------------------------
-- tips来源
-- 
-- @author: shuwen@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
TipsSource = TipsSource or BaseClass(BaseView)

local controller = BackpackController:getInstance()
local model = BackpackController:getInstance():getModel()

function TipsSource:__init()
    self.is_full_screen = false
    self.title_str= ""
    self.layout_name = "tips/tips_source"
    self.win_type = WinType.Mini   
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.item_list = {}
end

function TipsSource:open_callback()
	self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end

	self.main_container = self.root_wnd:getChildByName("main_container")
	self:playEnterAnimatianByObj(self.main_container, 2)
    local title_con = self.main_container:getChildByName("title_con")
    local title_label = title_con:getChildByName("title_label")
    title_label:setString(TI18N("获取途径"))

    self.name = self.main_container:getChildByName("name")
    self.own_label = self.main_container:getChildByName("own_label")

    self.goods_item = BackPackItem.new()
    self.goods_item:setPosition(100,445)
    self.main_container:addChild(self.goods_item)

    self.desc_scroll = createScrollView(400,70,180,380,self.main_container,ccui.ScrollViewDir.vertical)

    self.desc = createRichLabel(24, 179, cc.p(0,1), cc.p(0,self.desc_scroll:getContentSize().height), 0, 0, 400)
	self.desc_scroll:addChild(self.desc)

    self.scrollCon = self.main_container:getChildByName("scrollCon")
    self.scroll_size = self.scrollCon:getContentSize()
    self.scrollView = createScrollView(self.scroll_size.width,self.scroll_size.height-3,-6,2,self.scrollCon,ccui.ScrollViewDir.vertical)

    self.close_btn = self.main_container:getChildByName("close_btn")

end

function TipsSource:register_event()
	self.background:addTouchEventListener(function(sender, event_type)
		if event_type == ccui.TouchEventType.ended then
			playCloseSound()
			controller:openTipsSource(false)
		end
	end)
	if self.close_btn then
		self.close_btn:addTouchEventListener(function(sender, event_type)
			if event_type == ccui.TouchEventType.ended then
				playCloseSound()
				controller:openTipsSource(false)
			end
		end)
	end
end

function TipsSource:openRootWnd(data,extend_data, item_list)
	self.data = data
	self.extend_data = extend_data
	self.need_item_list = item_list
	self:setData()
	self:createSourceList()
end

function TipsSource:setData(  )
	self.goods_item:setData(self.data)--(Config.ItemData.data_get_data(self.data.base_id))
	local config 
	if self.data.config then 
		config = self.data.config
	else
		config = self.data
	end
	if not config then return end
	local quality = config.quality or 0
    local color = BackPackConst.quality_color[quality]
    self.name:setTextColor(color)
	self.name:setString(config.name)
	local bid = self.data.base_id or self.data.id
	local num = model:getBackPackItemNumByBid(bid)
	if CommonGoodsType.isAsset(bid) == true then 
		local role_vo = RoleController:getInstance():getRoleVo()
		local asset_name = Config.ItemData.data_assets_id2label[bid] or ""
		num = role_vo[asset_name] or 0
	end
	self.own_label:setString(string.format(TI18N("拥有%s个"),num))
	self.desc:setString(config.desc)
	local max_height = math.max(self.desc:getContentSize().height,self.desc_scroll:getContentSize().height)
	self.desc_scroll:setInnerContainerSize(cc.size(self.desc_scroll:getContentSize().width,max_height))
	self.desc:setPositionY(max_height)
end

function TipsSource:createSourceList(  )
	if self.data == nil then return end
	local config 
	if self.data.config then 
		config = self.data.config
	else
		config = self.data
	end
	if not config then return end

	local source_list = config.source
	if source_list and next(source_list)~=nil then
		local list = {}
		for k,v in pairs(source_list) do
			local data = Config.SourceData.data_source_data[v[1]]
			if data.evt_type ~= "evt_league_help" then --帮内求助特殊处理下 只出现在特定场合 
				if data.evt_type == "evt_festival_feather" then --先知豪礼
					local tab_vo = ActionController:getInstance():getActionSubTabVo(ActionRankCommonType.recruit_luxury)
			        if tab_vo then
			        	table.insert(list,v)
			        end
			    elseif data.evt_type == "evt_summon_feather" then --召唤豪礼
			    	local tab_vo = ActionController:getInstance():getActionSubTabVo(ActionRankCommonType.summon_luxury)
			        if tab_vo then
			        	table.insert(list,v)
			        end
			    else
					table.insert(list,v)
				end		        
			else
				if self.extend_data and next(self.extend_data)~=nil then 
					if self.extend_data[1] == "evt_league_help" and self.extend_data[2] then
						table.insert(list,v)
					end
				end
			end
		end
		local max_height = math.max(self.scroll_size.height,(SourceItem.HEIGHT)*#list)
		self.scrollView:setInnerContainerSize(cc.size(self.scroll_size.width,max_height))
		local final_list = {}
		for k,v in pairs(list) do
			local data = Config.SourceData.data_source_data[v[1]]
			local is_lock ,str = self:checIsOpen(data.lev_limit)
			v.id = data.id
			v.infon_data = data
			v.is_lock  = is_lock
			v.str = str
			table.insert(final_list,v)
		end
		local sort_func = SortTools.tableLowerSorter({"is_lock"})
		table.sort(final_list,sort_func)
		if final_list and next(final_list or {}) ~= nil then
			for i,v in ipairs(final_list) do
				local item = SourceItem.new(config.id, self.need_item_list)
				self.item_list[i] = item
				self.scrollView:addChild(item)
				item:setData(v)
				item:setPosition(10,max_height-6-(SourceItem.HEIGHT+1)*(i-1))
			end
		end
	end
end


function TipsSource:checIsOpen(data)
    if data then
        local not_is_lock = TRUE --默认都锁
        local str = ''
        -- 时间紧，暂时这样蛋疼的处理，后续优化
        local con_list = {}
        if data[1] then
        	con_list[1] = {data[1], data[2]}
        end
        if data[3] then
        	con_list[2] = {data[3], data[4]}
        end

        for i,v in ipairs(con_list) do
        	local con_name = v[1]
        	local con_val = v[2]
        	if not_is_lock == TRUE and con_name == 'dungeon' then --关卡的
	            local drama_data = BattleDramaController:getInstance():getModel():getDramaData()
	            if drama_data and con_val then
					local dungeon_id = con_val
					if drama_data.max_dun_id >= dungeon_id then
						not_is_lock = FALSE
					end
	                local config = Config.DungeonData.data_drama_dungeon_info(dungeon_id)
	                if config then
	                    str = TI18N('通关') .. config.name .. TI18N('解锁')
	                end
	            end
	        elseif not_is_lock == TRUE and con_name == 'lev' then -- 等级的
	            local role_vo = RoleController:getInstance():getRoleVo()
	            if role_vo and con_val then
					local lev = con_val
					if role_vo.lev >= lev then
						not_is_lock = FALSE
					end
					str = lev .. TI18N('级解锁')
				end
			elseif not_is_lock == TRUE and con_name == 'world_lev' then -- 世界等级
				local world_lev = RoleController:getInstance():getModel():getWorldLev()
				if world_lev and con_val then
					if world_lev >= con_val then
						not_is_lock = FALSE
					end
					str = TI18N('世界等级') .. con_val .. TI18N('级解锁')
				end
			elseif not_is_lock == TRUE and con_name == 'guild' then --公会等级
				local role_vo = RoleController:getInstance():getRoleVo()
				if role_vo and role_vo.gid ~= 0 and role_vo.gsrv_id ~= "" then --表示有公会
					local guild_info = GuildController:getInstance():getModel():getMyGuildInfo()
					if guild_info then
						local lev = con_val
						if guild_info.lev >= lev then
							not_is_lock = FALSE
						else
							not_is_lock = TRUE
							str = TI18N('公会')..lev .. TI18N('级解锁')
						end
					end
				else
					not_is_lock = TRUE
					str = TI18N("尚未加入公会")
				end
	        end
        end
        return not_is_lock, str
    end
end


function TipsSource:close_callback()
	for k,v in pairs(self.item_list) do
		if v and v["DeleteMe"] then
			v:DeleteMe()
		end
	end
	if self.goods_item then 
        self.goods_item:DeleteMe()
    end
    self.goods_item = nil
	controller:openTipsSource(false)
end
