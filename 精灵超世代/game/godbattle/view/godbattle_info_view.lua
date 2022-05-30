-- --------------------------------------------------------------------
-- 众神之战战斗过程中的小详细面板
-- 
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @editor: shiraho@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2017-xx-xx
-- --------------------------------------------------------------------
GodBattleInfoView = GodBattleInfoView or BaseClass(BaseView) 

local controller = GodbattleController:getInstance()
local model = controller:getModel()
local role_vo = RoleController:getInstance():getRoleVo()

function GodBattleInfoView:__init()
    self.win_type = WinType.Mini
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.layout_name = "godbattle/godbattle_info_view"
    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad("godbattle", "godbattle_result"), type = ResourcesType.plist}
    }
    self.role_list = {}
end

function GodBattleInfoView:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    self.main_container = self.root_wnd:getChildByName("main_container")
    self.Sprite_6 = self.main_container:getChildByName("Sprite_6")
    if self.sprite_6_load == nil then
        local res = PathTool.getPlistImgForDownLoad("bigbg","bigbg_98")
        self.sprite_6_load = loadSpriteTextureFromCDN(self.Sprite_6, res, ResourcesType.single, self.sprite_6_load)
    end
    
    self.title_container = self.main_container:getChildByName("title_container")
    local label
    local label_tab = {TI18N("排名"), TI18N("名字"), TI18N("击杀"), TI18N("积分")}
    for i=1,4 do
        label = self.title_container:getChildByName("label_"..i)
        if label ~= nil then
            label:setString(label_tab[i])
        end
    end

    self.my_rank = self.main_container:getChildByName("my_rank")
    self.my_score = self.main_container:getChildByName("my_score")
    self.my_kill = self.main_container:getChildByName("my_kill")

    self.list_view = self.main_container:getChildByName("list_view")
    local size = self.list_view:getContentSize()
    local setting = {
        item_class = GodBattleInfoList,
        start_x = 0,
        space_x = 0,
        start_y = 7,
        space_y = 0,
        item_width = 720,
        item_height = 60,
        row = 0,
        col = 1,
        need_dynamic = true
    }
    self.scroll_view = CommonScrollViewLayout.new(self.list_view, nil, nil, nil, size, setting)

    self.item = self.root_wnd:getChildByName("item")
    self.item:setVisible(false)
end

function GodBattleInfoView:register_event()
    self.background:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
            controller:openGodBattleInfoView(false)
        end
    end)
end

function GodBattleInfoView:openRootWnd()   
    -- 复制数据
    local role_list = model:getGodBattleRoleList()
    role_list = role_list or {}
    for k,v in pairs(role_list) do
        table.insert( self.role_list, v)
    end

    -- 做个排序
    if self.role_list ~= nil and next(self.role_list) ~= nil then
        local sort_func = SortTools.tableUpperSorter({"score", "win_acc"})
		table.sort(self.role_list, sort_func)
    end

    local my_data = nil
    local rank_index = 0
    if self.role_list then
        for i, data in ipairs(self.role_list) do
            data.rank = i -- 设置排名
            if getNorKey(role_vo.rid, role_vo.srv_id) == getNorKey(data.rid, data.srv_id) then
                my_data = data
                rank_index = i
            end
        end
    end
    if my_data then
        self.my_rank:setString(TI18N("我的排名:")..rank_index)
        self.my_kill:setString(TI18N("击杀数:")..my_data.win_acc)
        self.my_score:setString(TI18N("积分:")..my_data.score)
    end

    -- 设置滚动数据
    self.scroll_view:setData(self.role_list, nil, nil, self.item)
end

function GodBattleInfoView:close_callback()
    if self.scroll_view then
        self.scroll_view:DeleteMe()
    end
    self.scroll_view = nil

    if self.sprite_6_load then
        self.sprite_6_load:DeleteMe()
        self.sprite_6_load = nil
    end
    
    controller:openGodBattleInfoView(false)
end

-- --------------------------------------------------------------------
-- 列表数据
-- 
-- @author: shiraho@syg.com(必填, 创建模块的人员)
-- @editor: shiraho@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2017-xx-xx
-- --------------------------------------------------------------------
GodBattleInfoList = GodBattleInfoList or class("GodBattleInfoList", function()
	return ccui.Widget:create()
end)

function GodBattleInfoList:ctor()
end

function GodBattleInfoList:setExtendData(node)
    if not tolua.isnull(node) and self.root_wnd == nil then
		local size = node:getContentSize()
		self:setAnchorPoint(cc.p(0.5, 0.5))
		self:setContentSize(size)
		self.root_wnd = node:clone()
		self.root_wnd:setVisible(true)
		self.root_wnd:setAnchorPoint(0.5, 0.5)
		self.root_wnd:setPosition(size.width * 0.5, size.height * 0.5) 
        self:addChild(self.root_wnd)

        self.rank = self.root_wnd:getChildByName("rank")
        self.rank_img = self.root_wnd:getChildByName("rank_img")
        self.role_name = self.root_wnd:getChildByName("role_name")
        self.kill = self.root_wnd:getChildByName("kill")
        self.score = self.root_wnd:getChildByName("score")
        self.rank_img:ignoreContentAdaptWithSize(true)
    end
end

function GodBattleInfoList:setData(data)
    if data == nil then return end
    self.rank:setString(data.rank)
    -- self.role_name:setString(transformNameByServ(data.name or "", data.srv_id))
    self.role_name:setString(controller:convertName(data))
    self.rank:setVisible(data.rank > 3)
    self.rank_img:setVisible(data.rank <= 3)
    if data.rank <= 3 then
        self.rank_img:loadTexture(PathTool.getResFrame("common", "common_300"..data.rank), LOADTEXT_TYPE_PLIST)
    end

    local config = nil
    local mvp_res = nil
    if data.camp == GodBattleConstants.camp.god then
        config = Config.ZsWarData.data_const["god_name"]
		self.role_name:setTextColor(cc.c4b(0x69,0xac,0xff,0xff))
    else
        config = Config.ZsWarData.data_const["imp_name"]
		self.role_name:setTextColor(cc.c4b(0xed,0x43,0x43,0xff))
    end

    self.score:setString(data.score or 0)
    self.kill:setString(data.win_acc or 0)
end

function GodBattleInfoList:DeleteMe()
	self:removeAllChildren()
	self:removeFromParent()
end
