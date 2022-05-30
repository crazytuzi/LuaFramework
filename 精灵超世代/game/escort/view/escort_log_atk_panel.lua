-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      掠夺日志
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
EscortLogAtkPanel = EscortLogAtkPanel or BaseClass()

local controller = EscortController:getInstance() 
local baseinfo_config = Config.EscortData.data_baseinfo 
local lev_config = Config.EscortData.data_rewards

function EscortLogAtkPanel:__init(parent)
    self.is_init = false
    self.parent = parent
    self:createRoorWnd()
end

function EscortLogAtkPanel:createRoorWnd()
    self.root_wnd = createCSBNote(PathTool.getTargetCSB("escort/escort_log_atk_panel"))
    if not tolua.isnull(self.parent) then
        self.parent:addChild(self.root_wnd)
    end

    self.item = self.root_wnd:getChildByName("item")
    self.item:setVisible(false)

    self.empty_tips = self.root_wnd:getChildByName("empty_tips")
    self.empty_tips:getChildByName("desc"):setString(TI18N("满载而归的雇佣兽，不去掠夺一发吗？"))

    self.main_panel = self.root_wnd:getChildByName("main_panel")
end

function EscortLogAtkPanel:addToParent(status)
    if not tolua.isnull(self.root_wnd) then
        self.root_wnd:setVisible(status)
    end
    
    if status == true then
        if self.is_init == false then
            self.is_init = true
            controller:requestLogByType(EscortConst.log_type.atk)
        end
    end
end

function EscortLogAtkPanel:refreshData(list)
end 

function EscortLogAtkPanel:setData(list)
    if list == nil or next(list) == nil then
        if self.scroll_view then
            self.scroll_view:setVisible(false)
        end
        if self.empty_tips then
            self.empty_tips:setVisible(true)
        end
    else
        if self.scroll_view == nil then
            local size = self.main_panel:getContentSize()
            local setting = {
                item_class = EscortLogAtkItem,
                start_x = 4,
                space_x = 0,
                start_y = 7,
                space_y = 0,
                item_width = 600,
                item_height = 156,
                row = 0,
                col = 1,
                need_dynamic = true
            }
            self.scroll_view = CommonScrollViewLayout.new(self.main_panel, nil, nil, nil, size, setting)
        end
        self.scroll_view:setData(list, nil, nil, self.item)
        self.scroll_view:setVisible(true)
        if self.empty_tips then
            self.empty_tips:setVisible(false)
        end
    end
end

function EscortLogAtkPanel:__delete()
    if self.scroll_view then
        self.scroll_view:DeleteMe()
        self.scroll_view = nil
    end
end


-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      被掠夺单列
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
EscortLogAtkItem = class("EscortLogAtkItem", function()
	return ccui.Layout:create()
end)

function EscortLogAtkItem:ctor()
	self.item_list = {}
	self.is_completed = false
end

function EscortLogAtkItem:setExtendData(node)
	if not tolua.isnull(node) and self.root_wnd == nil then
		self.is_completed = true
		local size = node:getContentSize()
		self:setAnchorPoint(cc.p(0.5, 0.5))
		self:setContentSize(size)

		self.root_wnd = node:clone()
		self.root_wnd:setVisible(true)
		self.root_wnd:setAnchorPoint(0.5, 0.5)
		self.root_wnd:setPosition(size.width * 0.5, size.height * 0.5) 
		self:addChild(self.root_wnd)

        self.root_wnd:getChildByName("item_title"):setString(TI18N("掠夺对象:"))
        self.root_wnd:getChildByName("role_title"):setString(TI18N("被掠玩家:"))
        self.root_wnd:getChildByName("get_title"):setString(TI18N("获得:"))
	    self.root_wnd:getChildByName("server_title"):setString(TI18N("服务器:"))

        self.role_name = self.root_wnd:getChildByName("role_name")
        self.item_name = self.root_wnd:getChildByName("item_name")
        self.time_label = self.root_wnd:getChildByName("time_label")
	    self.server_value = self.root_wnd:getChildByName("server_value")	-- 服务器名字

		self:registerEvent()
	end
end

function EscortLogAtkItem:registerEvent()
end

function EscortLogAtkItem:setData(data)
    if data then
        for i,item in ipairs(self.item_list) do
            if item.suspendAllActions then
                item:suspendAllActions()
                item:setVisible(false)
            end
        end
        self.role_name:setString(data.name or "")
		self.time_label:setString(TimeTool.getYMDHMS(data.time or 0))
	    self.server_value:setString(getServerName(data.srv_id))
        if data.quality then
			local config = baseinfo_config[data.quality]
			if config then
				local color = EscortConst.quality_color[data.quality]
				if color then
					self.item_name:setTextColor(color)
				end
				self.item_name:setString(config.title)
			end

            -- local plunder_conifg = lev_config(getNorKey(data.quality, data.lev))
            if data.items then
                local _x, _y = 362, 65
                for i,v in ipairs(data.items) do
                    if self.item_list[i] == nil then
                        self.item_list[i] = BackPackItem.new(false, true, false, 0.7, false, true)
                        self.root_wnd:addChild(self.item_list[i])
                    end
                    local item = self.item_list[i]
                    item:setVisible(true)
                    item:setBaseData(v.bid, v.num)
                    _x = 362 + (i - 1) * (BackPackItem.Width * 0.7 + 6)
                    item:setPosition(_x, _y)
                end
            end
		end
    end
end


function EscortLogAtkItem:suspendAllActions()
end

function EscortLogAtkItem:DeleteMe()
    for i,item in ipairs(self.item_list) do
        item:DeleteMe()
    end
    self.item_list = nil
	self:removeAllChildren()
	self:removeFromParent()
end 