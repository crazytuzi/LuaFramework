--******** 文件说明 ********
-- @Author:      hyxing 
-- @description: 远征录像
-- @DateTime:    2019-07-17 14:51:45
-- *******************************
HeroexpeditVideoWindow = HeroexpeditVideoWindow or BaseClass(BaseView)

local controller = HeroExpeditController:getInstance()
local sign_info = Config.ExpeditionData.data_sign_info
function HeroexpeditVideoWindow:__init()
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.win_type = WinType.Big   
    self.is_full_screen = false
    self.layout_name = "elitematch/elitematch_fight_vedio_panel"

    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("vedio","vedio"), type = ResourcesType.plist },
    }
end

function HeroexpeditVideoWindow:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    if self.background ~= nil then
        self.background:setScale(display.getMaxScale())
    end

    local main_container = self.root_wnd:getChildByName("main_container")
    local main_panel = main_container:getChildByName("main_panel")

    main_panel:getChildByName("win_title"):setString(TI18N("录像列表"))
    local centre_label = main_panel:getChildByName("centre_label")
    centre_label:setVisible(false)
    self.left_name = main_panel:getChildByName("left_label")
    self.left_name:setString("")
    self.right_name = main_panel:getChildByName("right_label")
    self.right_name:setString("")
    self.scroll_container = main_panel:getChildByName("scroll_container")
    self.close_btn = main_panel:getChildByName("close_btn")

    self:creatVideoItemList()
end

function HeroexpeditVideoWindow:creatVideoItemList()
    if self.item_scrollview == nil then
        local scroll_view_size = self.scroll_container:getContentSize()
        local setting = {
            start_x = 0,                     -- 第一个单元的X起点
            space_x = 0,                     -- x方向的间隔
            start_y = 0,                     -- 第一个单元的Y起点
            space_y = 0,                     -- y方向的间隔
            item_width = 628,                -- 单元的尺寸width
            item_height = 335,               -- 单元的尺寸height
            row = 1,                         -- 行数，作用于水平滚动类型
            col = 1,                         -- 列数，作用于垂直滚动类型
            once_num = 1,                    -- 每次创建的数量
        }
        self.item_scrollview = CommonScrollViewSingleLayout.new(self.scroll_container, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting, cc.p(0, 0))

        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.item_scrollview:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
    end
end
-- 创建cell 
function HeroexpeditVideoWindow:createNewCell(width, height)
   local cell = HeroexpeditVideoItem.new()
    return cell
end
--获取数据数量
function HeroexpeditVideoWindow:numberOfCells()
    if not self.show_list then return 0 end
    return #self.show_list
end
--更新cell(拖动的时候.刷新数据时候会执行次方法)
function HeroexpeditVideoWindow:updateCellByIndex(cell, index)
    local cell_data = self.show_list[index]
    if not cell_data then return end
    cell:setData(cell_data)
end

function HeroexpeditVideoWindow:setVideoData(data)
	if self.item_scrollview then
		self.show_list = {}
		if next(data.replay_infos) ~= nil then
            local diff_model = controller:getModel():getDifferentChoose()
			for i,v in pairs(data.replay_infos) do
                if diff_model == v.difficulty then
    				table.insert(self.show_list,v)
                end
			end
            if next(self.show_list) ~= nil then
                table.sort(self.show_list, function(a,b) return a.time > b.time end)
                self.item_scrollview:reloadData()
            else
                commonShowEmptyIcon(self.scroll_container, true, {text = TI18N("暂无录像，努力通关吧")})
            end
        else
            commonShowEmptyIcon(self.scroll_container, true, {text = TI18N("暂无录像，努力通关吧")})   
		end
	end
end
function HeroexpeditVideoWindow:register_event()
    registerButtonEventListener(self.background, function()
    	controller:openHeroexpeditVideoView(false)
	end,false, 1)
    registerButtonEventListener(self.close_btn, function()
    	controller:openHeroexpeditVideoView(false)
	end,true, 2)

    self:addGlobalEvent(HeroExpeditEvent.Expedit_Video_Event, function(data)
        if not data then return end
        self:setVideoData(data)
    end)
end
function HeroexpeditVideoWindow:openRootWnd(cur_grard_id)
	controller:sender24415(cur_grard_id)
end
function HeroexpeditVideoWindow:close_callback()
	if self.item_scrollview then
        self.item_scrollview:DeleteMe()
    end
    self.item_scrollview = nil
    controller:openHeroexpeditVideoView(false)
end

------------------------------------------
-- 子项
HeroexpeditVideoItem = class("HeroexpeditVideoItem", function()
    return ccui.Widget:create()
end)

function HeroexpeditVideoItem:ctor()
    self:configUI()
    self:register_event()
end

function HeroexpeditVideoItem:configUI(  )
    self:setContentSize(cc.size(628,335))

    self.root_wnd = cc.CSLoader:createNode(PathTool.getTargetCSB("elitematch/elitematch_fight_vedio_item"))
    self:addChild(self.root_wnd)

    self.container = self.root_wnd:getChildByName("container")
    --左边
    self.left_name = self.container:getChildByName("left_name")
    self.left_name:setString("")
    self.left_team_name = self.container:getChildByName("left_team_name")
    self.left_team_name:setString("")
    self.left_fight_count = self.container:getChildByName("left_fight_count")
    self.left_fight_count:setString("")
    --右边
    self.right_name = self.container:getChildByName("right_name")
    self.right_name:setString("")
    self.right_team_name = self.container:getChildByName("right_team_name")
    self.right_team_name:setString("")
    self.right_fight_count = self.container:getChildByName("right_fight_count")
    self.right_fight_count:setString("")
    --公共
    self.play_btn = self.container:getChildByName("play_btn")
    self.play_btn:setPositionY(167)
    local info_btn = self.container:getChildByName("info_btn")
    info_btn:setVisible(false)

    self.diff_text = createRichLabel(18, cc.c4b(0x98,0x55,0x21,0xff), cc.p(0.5, 0.5), cc.p(313, 127), nil, nil, 250)
    self.container:addChild(self.diff_text)

    --回合数
    self.centre_war_name = self.container:getChildByName("centre_war_name")
    self.centre_war_name:setString("")
    --时间
    self.centre_time = self.container:getChildByName("centre_time")
    self.centre_time:setString("")
    --胜利
    self.result_win = self.container:getChildByName("result_win")
    self.result_win:setVisible(false)
    self.win_posX = self.result_win:getPositionX()
    self.result_loss = self.container:getChildByName("result_loss")
    self.result_loss:setVisible(false)
    self.loss_posX = self.result_loss:getPositionX()

    local _getItem = function(prefix)
        local item = {}
        item.pos_list = {}
        item.hero_item_list = {}
        for i=1,9 do
            local item_bg = self.container:getChildByName(prefix.."hero_bg_"..i)
            local x, y = item_bg:getPosition()
            item.pos_list[i] = cc.p(x, y)
        end
        return item
    end
    self.left_item = _getItem("left_")
    self.right_item = _getItem("right_")
end
local model_name = {TI18N("(普通)"),TI18N("(困难)"),TI18N("(地狱)")}
function HeroexpeditVideoItem:setData(data)
    self.data = data

    local str = string.format(TI18N("英雄远征%s-%d关"),model_name[data.difficulty],sign_info[data.guard_id].floor)
    self.diff_text:setString(str)

	self.left_name:setString(data.a_name)
	self.left_fight_count:setString(data.a_power)

	self.right_name:setString(data.b_name)
	self.right_fight_count:setString(data.b_power)
	--1:胜利 2:失败(看本人的)
	if data.ret == 1 then
		self.result_win:setPositionX(self.win_posX)
		self.result_loss:setPositionX(self.loss_posX)
	elseif data.ret == 2 then
		self.result_win:setPositionX(self.loss_posX)
		self.result_loss:setPositionX(self.win_posX)
	end
	self.result_win:setVisible(true)
	self.result_loss:setVisible(true)

	self.centre_war_name:setString(data.round.."/20"..TI18N("回合"))
    self.centre_time:setString(TimeTool.getYMDHM(data.time))

    local rid = data.rid
    local srv_id = data.srv_id

    local pos_info_a = data.a_plist 
    local formation_type_a = data.a_formation_type
    self:updateHeroInfo(self.left_item, pos_info_a, formation_type_a, rid, srv_id)

    local pos_info_b = data.b_plist 
    local formation_type_b = data.b_formation_type
    self:updateHeroInfo(self.right_item, pos_info_b, formation_type_b, rid, srv_id)
end

function HeroexpeditVideoItem:updateHeroInfo(item, pos_info, formation_type, rid, srv_id)
    if not item then return end
    --队伍位置
    local formation_config = Config.FormationData.data_form_data[formation_type]
    if formation_config then

        --转换位置信息
        local dic_pos_info = {}
        for k,v in pairs(pos_info) do
            dic_pos_info[v.pos] = v
        end

        for k,item in pairs(item.hero_item_list) do
            item:setVisible(false)
        end

        for i,v in ipairs(formation_config.pos) do
            local index = v[1] 
            local pos = v[2] 
            local hero_vo = dic_pos_info[pos]
            if hero_vo and hero_vo.ext then
                for i,v in ipairs(hero_vo.ext) do
                    if v.key == 5 then
                        hero_vo.use_skin = v.val
                    end
                end
            end
            --更新位置
            if item.hero_item_list[index] == nil then
                item.hero_item_list[index] = HeroExhibitionItem.new(0.5, false)
                self.container:addChild(item.hero_item_list[index])
            else
                item.hero_item_list[index]:setVisible(true)
            end
            item.hero_item_list[index]:setPosition(item.pos_list[pos])
            
            if hero_vo then
                item.hero_item_list[index]:setData(hero_vo)
                item.hero_item_list[index]:addCallBack(function()
                    if rid and srv_id then
                        ArenaController:getInstance():requestRabotInfo(rid, srv_id, index)
                    end
                end)
            else
                item.hero_item_list[index]:setData(nil)
            end
        end
    end
end
function HeroexpeditVideoItem:register_event( )
	registerButtonEventListener(self.play_btn, function()
        if self.data then
    		BattleController:getInstance():csRecordBattle(self.data.id,self.data.srv_id)
        end
	end,true)
end
function HeroexpeditVideoItem:DeleteMe( )
    
    self:removeAllChildren()
    self:removeFromParent()
end