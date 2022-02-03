-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      扫荡或者挑战伤害排行
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
GuildbossResultDpsRankWindow = GuildbossResultDpsRankWindow or BaseClass(BaseView)

local controller = GuildbossController:getInstance()
local model = GuildbossController:getInstance():getModel()
local string_format = string.format
local table_sort = table.sort


function GuildbossResultDpsRankWindow:__init()
	self.view_tag = ViewMgrTag.DIALOGUE_TAG
	self.win_type = WinType.Mini
	self.is_full_screen = false
	self.effect_cache_list = {}
	self.layout_name = "guildboss/guildboss_result_dpsrank_window"
	self.res_list = {
		{path = PathTool.getPlistImgForDownLoad("guildboss", "guildboss"), type = ResourcesType.plist}
	}
end

function GuildbossResultDpsRankWindow:open_callback() 
    local background = self.root_wnd:getChildByName("background")
    background:setScale(display.getMaxScale())

    local container = self.root_wnd:getChildByName("container")
    self:playEnterAnimatianByObj(container, 2)
    container:getChildByName("win_title"):setString(TI18N("伤害排行"))
    self.close_btn = container:getChildByName("close_btn")

    self.list_container = container:getChildByName("list_container")
    local size = self.list_container:getContentSize()
    local setting = {
        item_class = GuildbossResultDpsRankItem,
        start_x = 4,
        space_x = 4,
        start_y = 0,
        space_y = 0,
        item_width = 558,
        item_height = 135,
        row = 0,
        col = 1
    }
    self.scroll_view = CommonScrollViewLayout.new(self.list_container, nil, nil, nil, size, setting)
end

function GuildbossResultDpsRankWindow:register_event()
    self.close_btn:addTouchEventListener(function(sender, event_type)
        if event_type == ccui.TouchEventType.ended then
            playCloseSound()
            controller:openGuildbossResultDpsRankWindow(false)
        end
    end) 
end

function GuildbossResultDpsRankWindow:openRootWnd(data)
    if data and data.partner_dps_list and next(data.partner_dps_list) then
        local partner_dps_list = data.partner_dps_list
        local sort_func = SortTools.tableUpperSorter({"dps"})
        table_sort(partner_dps_list, sort_func)

        local item_list = {}
        local model = HeroController:getInstance():getModel()
        local vo = nil
        local index = 1
        for i,v in ipairs(data.partner_dps_list) do
            vo = model:getHeroById(v.p_id)
            if vo ~= nil then
                local object = {}
                object.rank = index
                object.vo = vo
                object.dps = v.dps
                object.total_dps = data.all_dps
                item_list[index] = object
                index = index + 1
            end
        end
        self.scroll_view:setData(item_list)
    end
end

function GuildbossResultDpsRankWindow:close_callback()
    if self.scroll_view then
        self.scroll_view:DeleteMe()
        self.scroll_view = nil
    end
    controller:openGuildbossResultDpsRankWindow(false)
end



-- --------------------------------------------------------------------
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @description:
--      伤害排行榜单元
-- <br/>Create: new Date().toISOString()
--
-- --------------------------------------------------------------------
GuildbossResultDpsRankItem = class("GuildbossResultDpsRankItem", function()
	return ccui.Layout:create()
end)

function GuildbossResultDpsRankItem:ctor()
	self.root_wnd = createCSBNote(PathTool.getTargetCSB("guildboss/guildboss_result_dpsrank_item"))
	self.size = self.root_wnd:getContentSize()
	self:setAnchorPoint(cc.p(0.5, 0.5))
	self:setContentSize(self.size)
	
	self.root_wnd:setAnchorPoint(0.5, 0.5)
	self.root_wnd:setPosition(self.size.width * 0.5, self.size.height * 0.5)
	self:addChild(self.root_wnd)
	
	self.rank_img = self.root_wnd:getChildByName("rank_img") -- common_3001 -3003
	self.rank_value = self.root_wnd:getChildByName("rank_value")
	self.dps = self.root_wnd:getChildByName("dps")
	self.role_name = self.root_wnd:getChildByName("role_name")
	self.best_img = self.root_wnd:getChildByName("best_img")

    self.progress_bar = self.root_wnd:getChildByName("progress_bar")
    self.progress_bar:setScale9Enabled(true)

    self.partner_item = HeroExhibitionItem.new(1, false)
    self.partner_item:setPosition(172, 68) 
    self.partner_item:setScale(0.9)
    self.root_wnd:addChild(self.partner_item) 
end

function GuildbossResultDpsRankItem:setData(data)
	if data and data.vo then
		if data.rank <= 3 then
			self.rank_value:setVisible(false)
			self.rank_img:setVisible(true)
			local res_id = PathTool.getResFrame("common", "common_300" .. data.rank)
			if self.res_id ~= res_id then
				self.res_id = res_id
				loadSpriteTexture(self.rank_img, res_id, LOADTEXT_TYPE_PLIST)
			end
		else
			self.rank_img:setVisible(false)
			self.rank_value:setVisible(true)
			self.rank_value:setString(data.rank)
		end
        self.partner_item:setData(data.vo) 
        self.best_img:setVisible(data.rank == 1)
        self.role_name:setString(data.vo.name or "")
        self.dps:setString(string_format(TI18N("伤害量：%s"), data.dps))
        self.progress_bar:setPercent(100*data.dps/data.total_dps)
	end
end

function GuildbossResultDpsRankItem:DeleteMe()
	if self.partner_item then
		self.partner_item:DeleteMe()
		self.partner_item = nil
	end
	self:removeAllChildren()
	self:removeFromParent()
end 