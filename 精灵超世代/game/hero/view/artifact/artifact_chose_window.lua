--------------------------------------------
-- @Author  : htp
-- @Editor  : htp
-- @Date    : 2018-11-12 20:45:58
-- @description    : 
		-- 神器选择
---------------------------------
ArtifactChoseWindow = ArtifactChoseWindow or BaseClass(BaseView)

local controller = HeroController:getInstance()

function ArtifactChoseWindow:__init(  )
	self.win_type = WinType.Mini
	self.is_full_screen = false
    self.view_tag = ViewMgrTag.DIALOGUE_TAG  

	self.layout_name = "hero/artifact_chose_window"

    self.res_list = {
        {path = PathTool.getPlistImgForDownLoad('bigbg', 'bigbg_3'), type = ResourcesType.single},
    }

	self.chose_num = 0
end

function ArtifactChoseWindow:open_callback(  )
	self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())

    local main_container = self.root_wnd:getChildByName("main_container")
    self.main_container = main_container
    self:playEnterAnimatianByObj(self.main_container , 2) 

    local title_con = main_container:getChildByName("title_con")
    local title_label = title_con:getChildByName("title_label")
    title_label:setString(TI18N("符文选择"))

    self.chose_label = main_container:getChildByName("chose_label")
    self.chose_label:setString(string.format(TI18N("(已选择:%d)"), self.chose_num))
    self.ok_btn = main_container:getChildByName("ok_btn")
    local ok_btn_label = self.ok_btn:getChildByName("label")
    ok_btn_label:setString(TI18N("确定"))
    self.close_btn = main_container:getChildByName("close_btn")

    self.goods_con = main_container:getChildByName("goods_con")
    local bgSize = self.goods_con:getContentSize()
	local scroll_view_size = cc.size(bgSize.width, bgSize.height-10)
    local setting = {
        item_class = BackPackItem,      -- 单元类
        start_x = 15,                  -- 第一个单元的X起点
        space_x = 20,                    -- x方向的间隔
        start_y = 0,                    -- 第一个单元的Y起点
        space_y = 10,                   -- y方向的间隔
        item_width = BackPackItem.Width,               -- 单元的尺寸width
        item_height = BackPackItem.Height,              -- 单元的尺寸height
        row = 0,                        -- 行数，作用于水平滚动类型
        col = 4,                         -- 列数，作用于垂直滚动类型
        need_dynamic = true
    }

    self.item_scrollview = CommonScrollViewLayout.new(self.goods_con, cc.p(0,5) , ScrollViewDir.vertical, ScrollViewStartPos.top, scroll_view_size, setting)
    self.item_scrollview:setSwallowTouches(false)
end

function ArtifactChoseWindow:setData( data )
	self.artifact_bid = data.bid -- 合成的目标符文bid（0表示暂无）
	self.max_num = data.max_num or 0
	self.chose_list = data.chose_list or {}

	self.chose_num = #self.chose_list
	self.chose_label:setString(string.format(TI18N("(已选择:%d/%d)"), self.chose_num, self.max_num))

	local item_data = BackpackController:getInstance():getModel():getAllBackPackArray(BackPackConst.item_tab_type.SPECIAL)    

    local list = {}
    local index = 1
    for i,v in pairs(item_data) do
        if v and v.config and v.config.type == BackPackConst.item_type.ARTIFACTCHIPS then
        	local artifact_cfg = Config.PartnerArtifactData.data_artifact_data[v.config.id]
            if artifact_cfg and artifact_cfg.com_artifact ~= 0 then
                local is_select = false
                for _,n in pairs(self.chose_list) do
                    if n == v.id then
                        is_select = true
                        break
                    end
                end
                v:setGoodsAttr("showSellStatus", {status = true, select = is_select})
                list[index] = v
                index = index+1
            end
        end
    end
    -- 品质低的放前面
    table.sort(list, SortTools.tableLowerSorter({"quality", "id"}))
    self.item_data = list
    self.item_scrollview:setData(list, nil ,nil,{showCheckBox=true, checkBoxClickCallBack = handler(self, self._onCheckBoxCallBack), adjustCheckBoxPos=cc.p(BackPackItem.Width-25, BackPackItem.Height-25)})
    if next(list) ~= nil then
        self.item_scrollview:addEndCallBack(function (  )
            local item_list = self.item_scrollview:getItemList()
            for k,item in pairs(item_list) do
                local function onClickItemCallBack(  )
                    local item_vo = item:getData()
                    controller:openArtifactTipsWindow(true, item_vo, PartnerConst.ArtifactTips.normal)
                end
                item:addCallBack(onClickItemCallBack)
            end
        end)
        commonShowEmptyIcon(self.main_container, false)
    else
        local setting = {}
        setting.text = TI18N("暂时没有可合成的符文")
        setting.label_color = Config.ColorData.data_color4[175]
        setting.pos = cc.p(self.main_container:getContentSize().width/2, self.main_container:getContentSize().height/2+30)
        setting.offset_y = 0
        setting.font_size = 24
        commonShowEmptyIcon(self.main_container, true, setting)
    end
end

function ArtifactChoseWindow:_onCheckBoxCallBack( flag, itemnode )
    local item_vo = itemnode:getData()
    if flag == true then
        if not self:checkItemIsCanChose(item_vo.config.id) then
            item_vo:setGoodsAttr("showSellStatus", {status = true, select = false})
            itemnode:setData(item_vo)
            message(TI18N("请选择同类型符文"))
            return
        elseif self.chose_num >= self.max_num then
            item_vo:setGoodsAttr("showSellStatus", {status = true, select = false})
            itemnode:setData(item_vo)
            message(TI18N("已达最大选择数量"))
            return
        end
    end

	if flag == true then
		self.chose_num = self.chose_num + 1
        local artifact_cfg = Config.PartnerArtifactData.data_artifact_data[item_vo.config.id]
        if artifact_cfg and artifact_cfg.com_artifact then
            self.artifact_bid = artifact_cfg.com_artifact
        end
	else
		self.chose_num = self.chose_num - 1
        if self.chose_num <= 0 then
            self.artifact_bid = 0
        end
	end
	self.chose_label:setString(string.format(TI18N("(已选择:%d/%d)"), self.chose_num, self.max_num))
end

-- 检测是否可以选择
function ArtifactChoseWindow:checkItemIsCanChose( bid )
    local is_can_chose = false
    if self.artifact_bid and self.artifact_bid ~= 0 then
        local artifact_cfg = Config.PartnerArtifactData.data_artifact_data[bid]
        if artifact_cfg and artifact_cfg.com_artifact == self.artifact_bid then
            is_can_chose = true
        end
    else
        is_can_chose = true
    end
    return is_can_chose
end

function ArtifactChoseWindow:register_event(  )
    registerButtonEventListener(self.background, handler(self, self._onClickBtnClose), false, 2)
	registerButtonEventListener(self.close_btn, handler(self, self._onClickBtnClose), false, 2)
	registerButtonEventListener(self.ok_btn, handler(self, self._onClickBtnOk))
end

function ArtifactChoseWindow:_onClickBtnClose(  )
	controller:openArtifactChoseWindow(false)
end

function ArtifactChoseWindow:_onClickBtnOk(  )
    local is_have_special = false
	local item_list = {}
	for k,v in pairs(self.item_data) do
		if v.showSellStatus ~= nil and v.showSellStatus.select == true then
            if v.enchant >= 3 then -- 所选材料中有三星以上的符文
                is_have_special = true
            end
            table.insert(item_list, v.id)
        end
	end
    local function sureToChoseFunc(  )
        GlobalEvent:getInstance():Fire(HeroEvent.Artifact_Chose_Event, item_list)
        controller:openArtifactChoseWindow(false)
    end
    if is_have_special then
        local str = TI18N("您选择了高星级的符文作为升星材料，是否继续？")
        CommonAlert.show( str, TI18N("确定"), function()
            sureToChoseFunc()
        end, TI18N("取消"))
    else
        sureToChoseFunc()
    end
end

function ArtifactChoseWindow:openRootWnd( data )
	self:setData(data)
end

function ArtifactChoseWindow:close_callback(  )
    if self.item_scrollview then
        self.item_scrollview:DeleteMe()
        self.item_scrollview = nil
    end
    if self.item_data and next(self.item_data) ~= nil then
        for i,v in pairs(self.item_data) do
            v:setGoodsAttr("showSellStatus", {status = false, select = false})
        end
    end
	controller:openArtifactChoseWindow(false)
end