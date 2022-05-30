-- --------------------------------------------------------------------
-- 竖版星命塔主界面
-- 
-- @author: cloud@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
StarTowerWindow = StarTowerWindow or BaseClass(BaseView)

function StarTowerWindow:__init()
    self.ctrl = StartowerController:getInstance()
    self.is_full_screen = true
    self.layout_name = "startower/star_tower_window"
    self.cur_type = 0
    self.win_type = WinType.Full  
    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("startower","startower"), type = ResourcesType.plist },
        { path = PathTool.getPlistImgForDownLoad("bigbg","bigbg_27",true), type = ResourcesType.single },
        { path = PathTool.getPlistImgForDownLoad("bigbg","bigbg_36",true), type = ResourcesType.single },
        { path = PathTool.getPlistImgForDownLoad("bigbg","bigbg_28"), type = ResourcesType.single },
        { path = PathTool.getPlistImgForDownLoad("bigbg","bigbg_29"), type = ResourcesType.single },
    }
    self.tab_list = {}
    self.select_type = 1 --伙伴类型选择,默认全部为1
    self.view_list = {}
    self.is_change = false
    self.top3_item_list = {}
end


function StarTowerWindow:open_callback()
    self.mainContainer = self.root_wnd:getChildByName("main_container")

    --对应主窗口.四面对应xy位置 ..相对位置是self.main_container左下角(0,0)
    local top_y = display.getTop(self.mainContainer)
    local bottom_y = display.getBottom(self.mainContainer)

     -- --主菜单 顶部底部的高度
    local top_height = MainuiController:getInstance():getMainUi():getTopViewHeight()
    local bottom_height = MainuiController:getInstance():getMainUi():getBottomHeight()

    self.mainContainer_size = self.mainContainer:getContentSize()
    self.bg = self.mainContainer:getChildByName("bg")
    if self.bg ~= nil then
        self.bg:setScale(display.getMaxScale())
        self.bg:setPositionY(top_y)
    end
    self.container = self.mainContainer:getChildByName("container")
    self.top_panel = self.mainContainer:getChildByName("top_panel")

    self.btnRule = self.top_panel:getChildByName("btnRule")
    self.top_panel:getChildByName("title"):setString(TI18N("天空之塔"))

    self.black_bg = self.mainContainer:getChildByName("black_bg")
    self.close_btn = self.mainContainer:getChildByName("close_btn")
   
    -- self.cost_panel =  self.black_bg:getChildByName("cost_panel")
    -- self.add_btn = self.cost_panel:getChildByName("add_btn")
    -- self.less_label =  createRichLabel(24,Config.ColorData.data_color4[1],cc.p(0,1),cc.p(0,65),nil,nil,500)
    -- self.cost_panel:addChild(self.less_label)

    local buy_panel = self.mainContainer:getChildByName("buy_panel")
    local buy_bg = buy_panel:getChildByName("buy_bg")
    local key_label = buy_panel:getChildByName("key")
    key_label:setString(TI18N("剩余挑战次数："))
    local key_size = key_label:getContentSize()
    local buy_bg_size = buy_bg:getContentSize()
    local add_width = key_size.width - 129      -- 129为中文宽度
    buy_bg:setContentSize(cc.size(buy_bg_size.width+add_width, buy_bg_size.height))

    self.buy_count = buy_panel:getChildByName("label")
    self.buy_btn = buy_panel:getChildByName("add_btn")

    self.buy_tips = createRichLabel(20, Config.ColorData.data_new_color4[15], cc.p(0.5,0.5), cc.p(85,-20), nil, nil, 600)
    buy_panel:addChild(self.buy_tips)

    self.award_btn = self.mainContainer:getChildByName("award_btn")
    local label = self.award_btn:getChildByName("label")
    label:setString(TI18N("奖励"))
   
    self.rank_btn = self.mainContainer:getChildByName("rank_btn")
    local label = self.rank_btn:getChildByName("label")
    label:setString(TI18N("排行"))


    self.rank_container = self.mainContainer:getChildByName("rank_container")
    self.rank_container:getChildByName("rank_desc_label"):setString(TI18N("排行前三"))

    self.rank_info_btn = createRichLabel(18, cc.c4b(0x83,0xe7,0x73,0xff), cc.p(0.5, 0.5), cc.p(74, 16))
    self.rank_info_btn:setString(string.format("<div href=xxx fontcolor=249003>%s</div>", TI18N("点击查看详情")))
    self.rank_info_btn:addTouchLinkListener(function(type, value, sender, pos)
        RankController:getInstance():openRankView(true,RankConstant.RankType.tower)
    end, { "click", "href" })
    self.rank_container:addChild(self.rank_info_btn)
    
    local tab_y = self.top_panel:getPositionY()
    local top_panel_y = top_y - (self.mainContainer_size.height - tab_y)
    self.top_panel:setPositionY(top_panel_y)
    local rank_y = self.rank_container:getPositionY()
    self.rank_container:setPositionY(top_y - (self.mainContainer_size.height - rank_y))

    self.black_bg:setPositionY(bottom_y)
    -- 滚动高度
    -- self.scroll_height = top_panel_y - 20 - bottom_y
    self.scroll_height = 1280 - bottom_y
    self:updateTowerList()

    -- local data = {}
    -- self.ctrl:openTipsWindow(true,data)
end

function StarTowerWindow:setRankShow()
    if RankController:getInstance():checkRankIsShow() then
        self.rank_container:setVisible(true)
        self.rank_btn:setVisible(true)
        self.ctrl:requestStarTowerRank()
    else
        self.rank_container:setVisible(false)
        self.rank_btn:setVisible(false)
    end
end

function StarTowerWindow:register_event()
    registerButtonEventListener(self.close_btn, function()
        self.ctrl:openMainView(false)
    end,true, 2)

    registerButtonEventListener(self.award_btn, function()
        self.ctrl:openAwardWindow(true)
    end,true, 1)

    registerButtonEventListener(self.rank_btn, function()
        RankController:getInstance():openRankView(true,RankConstant.RankType.tower)
    end,true, 1)

    registerButtonEventListener(self.rank_top3_btn, function()
        RankController:getInstance():openRankView(true,RankConstant.RankType.tower)
    end,true, 1)
    registerButtonEventListener(self.btnRule, function(param,sender, event_type)
        local config = Config.StarTowerData.data_tower_const.rule_desc
        TipsManager:getInstance():showCommonTips(config.desc, sender:getTouchBeganPosition())
    end,true, 1)

    registerButtonEventListener(self.buy_btn, function()
        local function fun()
            self.ctrl:sender11321()
        end
        local have_buycount = self.ctrl:getModel():getBuyCount() or 0
        local role_vo = RoleController:getInstance():getRoleVo()
        local config = Config.StarTowerData.data_tower_vip[role_vo.vip_lev]
       
        if config and config.buy_count then 
            if have_buycount >= config.buy_count then 
                message(TI18N("本日购买次数已达上限"))
            else
                local buy_config = Config.StarTowerData.data_tower_buy[have_buycount+1]
                if buy_config and buy_config.expend and buy_config.expend[1] and buy_config.expend[1][1] then 
                    local item_id = buy_config.expend[1][1]
                    local num = buy_config.expend[1][2] or 0
                    local item_config = Config.ItemData.data_get_data(item_id)
                    if item_config and item_config.icon then
                        local res = PathTool.getItemRes(item_config.icon)
                        local str = string.format( TI18N("是否花费<img src='%s' scale=0.25 />%s购买一次挑战次数？"),res, num)
                        CommonAlert.show(str,TI18N("确定"),fun,TI18N("取消"),nil,CommonAlert.type.rich,nil,nil,24)
                    end
                end
            end
        end
    end,true, 1)

    self:addGlobalEvent(StartowerEvent.Update_All_Data,function()
        self:updateTowerList(true)
        self:updateCount()
        self:updataRewardRedPoint()
    end)

    self:addGlobalEvent(StartowerEvent.Update_Top3_rank,function(list)
        self:updateTop3Info(list)
    end)

    self:addGlobalEvent(StartowerEvent.Update_First_Reward_Msg,function()
        self:updataRewardRedPoint()
    end)

    self:addGlobalEvent(StartowerEvent.Fight_Success_Event,function()
        if not self.select_vo then return end
        self.list_view:resetCurrentItems()
        self.list_view:moveToArrowNewPosition()
    end)

    self:addGlobalEvent(StartowerEvent.Count_Change_Event,function()
        self:updateCount()
        local index = self.ctrl:getModel():getNowTowerId() or 0

        local list = self.list_view:getActiveCellList()
        for i,v in ipairs(list) do
            if v.index == index then
                if v:getData() then
                    v:sweepCount(v:getData())
                end
                break
            end
        end
    end)

    -- 引导中不给滑动列表
    self:addGlobalEvent(GuideEvent.Update_Guide_Status_Event, function ( in_guide )
        if in_guide then
            self.list_view:setClickEnabled(false)
        else
            self.list_view:setClickEnabled(true)
        end
    end)
end

--奖励红点
function StarTowerWindow:updataRewardRedPoint()
    local data = self.ctrl:getModel():getRewardData()
    local status = false
    for i,v in pairs(data) do
        if v.status == 1 then
            status = true
            break
        end
    end
    addRedPointToNodeByStatus(self.award_btn, status)
    MainSceneController:getInstance():setBuildRedStatus(CenterSceneBuild.startower, {bid = 1, status = status})
end

function StarTowerWindow:updateCount()
    local count = self.ctrl:getModel():getTowerLessCount() or 0
    local all_count = Config.StarTowerData.data_tower_const["free_times"].val or 0
    local str = string.format("%s/%s",count,all_count)
    self.buy_count:setString(str)

    local have_buycount = self.ctrl:getModel():getBuyCount() or 0
    local role_vo = RoleController:getInstance():getRoleVo()
    local config = Config.StarTowerData.data_tower_vip[role_vo.vip_lev]
    if config and config.buy_count then 
        local count = config.buy_count - have_buycount
        if count < 0 then
            count = 0
        end
        local str = string.format(TI18N("<div outline=2,#3D5078>%s</div><div fontcolor=#0cff01 outline=2,#3D5078>%s</div><div outline=2,#3D5078></div>"),TI18N("剩余购买次数："), count)
        self.buy_tips:setString(str)
    end
end

function StarTowerWindow:openRootWnd()
    -- 请求排行榜数据,前3
    -- self.ctrl:requestStarTowerRank()
    self:setRankShow()
    if self.ctrl:getModel():isInitStarTowerData() then
        if self.list_view then
            local lev_id = self.ctrl:getModel():getNowTowerId()
            self.list_view:reloadData(lev_id)
        end
        self:updateCount()
        self:updataRewardRedPoint()
    else
        --请求塔数据
        self.ctrl:sender11320()
    end
end

--[[
    @desc: 设置标签页面板数据内容
    author:{author}
    time:2018-05-03 21:57:09
    return
]]
function StarTowerWindow:setPanelData()
end

function StarTowerWindow:updateTowerList(is_reload)
    --最大数量
    self.max_count = Config.StarTowerData.data_tower_base_length
    if not self.list_view then
        local scroll_view_size = cc.size(SCREEN_WIDTH,self.scroll_height)
        local bottom_y = display.getBottom(self.mainContainer)
        self.list_view = StarTowerList.new(self.container, cc.p(SCREEN_WIDTH/2, bottom_y), scroll_view_size)
        self.list_view:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.list_view:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.list_view:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
        self.list_view:registerScriptHandlerSingle(handler(self,self.onCellTouched), ScrollViewFuncType.OnCellTouched) --更新cell
        self.list_view:setInnerContainer()
        self.list_view:updateBgList()

        -- 引导中不给滑动列表
        if GuideController:getInstance():isInGuide() then
            self.list_view:setClickEnabled(false)
        end
    end
    if is_reload and not self.is_init_list then
        self.is_init_list = true 
        local lev_id = self.ctrl:getModel():getNowTowerId()
        self.list_view:reloadData(lev_id)
    end
end

--创建cell 
function StarTowerWindow:createNewCell()
    local cell = StarTowerItem.new(1, true)
    cell:addCallBack(function() self:onCellTouched(cell) end)
    return cell
end
--获取数据数量
function StarTowerWindow:numberOfCells()
    return self.max_count or 0
end
--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--inde :数据的索引
function StarTowerWindow:updateCellByIndex(cell, index)
    cell.index = index
    cell:setData(index)
end

--点击cell .需要在 createNewCell 设置点击事件
function StarTowerWindow:onCellTouched(cell)
    local index = cell.index
    local cur_lev = self.ctrl:getModel():getNowTowerId() + 1
    if index > cur_lev then
        message(TI18N("当前关卡未开启"))
        return
    end
    local config = Config.StarTowerData.data_tower_base[index]
    if config then
        self.select_vo = config
        self.select_item = cell
        self.data = config
        self:clickFun(config)
    end
end


function StarTowerWindow:clickFun(vo)
    if not vo then return end
    self.ctrl:openStarTowerMainView(true,vo)
end

function StarTowerWindow:updateTop3Info(rank_list)
    if rank_list == nil or next(rank_list) == nil then return end
    for i, v in ipairs(rank_list) do
        if not self.top3_item_list[v.rank] then
            local item = self:createSingleRankItem(v.rank)
            self.rank_container:addChild(item)
            self.top3_item_list[v.rank] = item
        end
        local item = self.top3_item_list[v.rank]
        if item then
            item:setPosition(0,170 - (v.rank-1) * item:getContentSize().height)
            item.label:setString(v.name)
            item.value:setString(string.format(TI18N("%d层"), (v.tower or 0)))
        end
    end
end

function StarTowerWindow:createSingleRankItem(i)
	local container = ccui.Layout:create()
	container:setAnchorPoint(cc.p(0,1))
	container:setContentSize(cc.size(180,50))
	-- local sp = createSprite(PathTool.getResFrame("common","common_rank_"..i),30,40/2,container)
    local sp = createSprite(PathTool.getResFrame("common","common_rank_"..i),15,40/2,container)
	-- sp:setScale(0.5)
	container.sp = sp
	-- local label = createLabel(20,1,nil,60,18,"",container)
    local label = createLabel(18,1,nil,30,32,"",container)
	label:setAnchorPoint(cc.p(0,0.5))
	label:setTextColor(Config.ColorData.data_new_color4[15])

	-- local value = createLabel(20,1,nil,188,18,"",container)
    local value = createLabel(18,1,nil,140,12,"",container)
	value:setAnchorPoint(cc.p(1,0.5))
	value:setTextColor(Config.ColorData.data_new_color4[15])
	container.label = label
    container.value = value
	return  container
end

function StarTowerWindow:close_callback()
    self.ctrl:openMainView(false)
    if self.list_view then 
        self.list_view:DeleteMe()
        self.list_view = nil
    end
    self.select_item = nil
    if self.lock_icon then 
        self.lock_icon:DeleteMe()
        self.lock_icon = nil
    end
end
