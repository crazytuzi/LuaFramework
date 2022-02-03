-- --------------------------------------------------------------------
-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: lwc@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--  公会讨伐成功失败界面
-- <br/>Create: 2019年9月16日 
------------------------------------------------------------------------------
GuildsecretareaEndCrusadePanel = GuildsecretareaEndCrusadePanel or BaseClass(BaseView)


local controller = GuildsecretareaController:getInstance()
local model = controller:getModel()
local table_insert = table.insert

function GuildsecretareaEndCrusadePanel:__init(result)
    self.win_type = WinType.Mini
    self.layout_name = "guildsecretarea/guildsecretarea_end_crusade_panel"
    self.view_tag = ViewMgrTag.DIALOGUE_TAG
    self.is_full_screen = false

    self.res_list = {
        { path = PathTool.getPlistImgForDownLoad("guildsecretarea_result", "guildsecretarea_result"), type = ResourcesType.plist },
    }

    --成功失败标志
    self.result = result
    self.fight_type = BattleConst.Fight_Type.GuildSecretArea
end


--初始化
function GuildsecretareaEndCrusadePanel:open_callback()
    self.background = self.root_wnd:getChildByName("background")
    self.background:setScale(display.getMaxScale())
    self.container = self.root_wnd:getChildByName("container")
    self:playEnterAnimatianByObj(self.container, 2)
    self.container_size = self.container:getContentSize()
    --self.container:setScale(display.getMaxScale())

    self.fight_text = self.container:getChildByName("fight_text")
    self.pass_time = self.container:getChildByName("pass_time")

    self.comfirm_btn = self.container:getChildByName("comfirm_btn")
    self.comfirm_btn:getChildByName("label"):setString(TI18N("前往宝库"))

    self.cancel_btn = self.container:getChildByName("cancel_btn")
    self.cancel_btn:getChildByName("label"):setString(TI18N("取 消"))

    self.boss_icon = self.container:getChildByName("boss_icon")
    local bg_res = PathTool.getPlistImgForDownLoad("bigbg/guildsecretarea", "secret_area_result_bg", false)
    self.item_load_bg = loadSpriteTextureFromCDN(self.boss_icon, bg_res, ResourcesType.single, self.item_load_bg) 

    self.result_icon = self.container:getChildByName("result_icon")

    --宝库奖励
    self.reward_panel = self.container:getChildByName("reward_panel")

    self.market_scroll_view = self.reward_panel:getChildByName("scroll_view")
    --个人排名奖励
    self.reward_panel_1 = self.container:getChildByName("reward_panel_1")
    self.reward_panel_1:getChildByName("title_name"):setString(TI18N("个人排名奖励"))
    self.scroll_view = self.reward_panel_1:getChildByName("scroll_view")

    local name = Config.BattleBgData.data_fight_name[self.fight_type] or TI18N("公会秘境")
    if self.result == 1 then
        self.container:setPositionY(640 + 90)
        self.fight_text:setString(name..TI18N("讨伐成功!"))

        local path = PathTool.getResFrame("guildsecretarea_result","txt_cn_guildsecretarea_result_6")
        loadSpriteTexture(self.result_icon, path, LOADTEXT_TYPE_PLIST)
        self.reward_panel:getChildByName("title_name"):setString(TI18N("公会宝库奖励"))
        self.reward_panel:getChildByName("title_tips"):setString(TI18N("(以下物品已放入公会宝库)"))
    else
        self.fight_text:setString(name..TI18N("讨伐失败!"))
        
        local path = PathTool.getResFrame("guildsecretarea_result","txt_cn_guildsecretarea_result_5")
        loadSpriteTexture(self.result_icon, path, LOADTEXT_TYPE_PLIST)

        self.reward_panel:setVisible(false)
        self.pass_time:setVisible(false)
        self.comfirm_btn:setVisible(false)
        self.cancel_btn:setVisible(false)

        self.reward_panel_1:setPositionY(438)
        self.scroll_view:setContentSize(cc.size(414, 342))
    end
end

function GuildsecretareaEndCrusadePanel:playEnterAnimatian()
    if not self.container then return end
    commonOpenActionCentreScale(self.container)
end

function GuildsecretareaEndCrusadePanel:register_event()
    registerButtonEventListener(self.background, handler(self, self.onClickCloseBtn) ,false, REGISTER_BUTTON_SOUND_CLOSED_TYPY)
    registerButtonEventListener(self.cancel_btn, handler(self, self.onClickCloseBtn), true, REGISTER_BUTTON_SOUND_CLOSED_TYPY)

    registerButtonEventListener(self.comfirm_btn, handler(self, self.onClickComfirmBtn), true, REGISTER_BUTTON_SOUND_BUTTON_TYPY)
end

--关闭
function GuildsecretareaEndCrusadePanel:onClickCloseBtn()
    controller:openGuildsecretareaEndCrusadePanel(false)
end
--前往宝库
function GuildsecretareaEndCrusadePanel:onClickComfirmBtn()
    GuildmarketplaceController:getInstance():openGuildmarketplaceMainWindow(true)
    controller:openGuildsecretareaEndCrusadePanel(false)
end

function GuildsecretareaEndCrusadePanel:openRootWnd(data)
    if not data then return end
    
    if data.flag == 1 then
        playOtherSound("b_win", AudioManager.AUDIO_TYPE.BATTLE) 
        --宝库奖励
        self.market_reward_list = data.market_reward
        self:updateMarketRewardlist()

        self.pass_time:setString(TI18N("通关时间：")..TimeTool.GetTimeFormatDayIIIIIIII(data.time))
    else
        AudioManager:getInstance():playMusic(AudioManager.AUDIO_TYPE.BATTLE, "b_lose", false)
    end

    --讨伐奖励
    self.reward_list = data.boss_reward
    self:updateRewardlist()
end

--个人奖励
function GuildsecretareaEndCrusadePanel:updateRewardlist()
    if not self.reward_list then return end
    if self.scrollview_list == nil then
        local scrollview_size = self.scroll_view:getContentSize()
        
        local setting = {
            start_x = 0,                     -- 第一个单元的X起点
            space_x = 0,                     -- x方向的间隔
            start_y = 0,                     -- 第一个单元的Y起点
            space_y = 0,                     -- y方向的间隔
            item_width = 100,                -- 单元的尺寸width
            item_height = 100,               -- 单元的尺寸height
            row = 1,                         -- 行数，作用于水平滚动类型
            col = 4,                         -- 列数，作用于垂直滚动类型
            delay = 1,                       -- 创建延迟时间
            once_num = 1,                    -- 每次创建的数量
        }
        self.scrollview_list = CommonScrollViewSingleLayout.new(self.scroll_view, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scrollview_size, setting, cc.p(0, 0))

        self.scrollview_list:registerScriptHandlerSingle(handler(self,self.createNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.scrollview_list:registerScriptHandlerSingle(handler(self,self.numberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.scrollview_list:registerScriptHandlerSingle(handler(self,self.updateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
    end
    self.scrollview_list:reloadData()

    if #self.reward_list == 0 then
        commonShowEmptyIcon(self.scroll_view, true, {font_size = 22,scale = 0.5, offset_y = 36, text = TI18N("暂无奖励")})
    else
        commonShowEmptyIcon(self.scroll_view, false)
    end
end

--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function GuildsecretareaEndCrusadePanel:createNewCell(width, height)
    local cell = BackPackItem.new(true, true, false, 0.7)
    cell:setSwallowTouches(false)
    cell:setDefaultTip()
    return cell
end

--获取数据数量
function GuildsecretareaEndCrusadePanel:numberOfCells()
    if not self.reward_list then return 0 end
    return #self.reward_list
end

--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--index :数据的索引
function GuildsecretareaEndCrusadePanel:updateCellByIndex(cell, index)
    -- cell.index = index
    local data = self.reward_list[index]
    if data then
        cell:setBaseData(data.bid, data.num)
    end
end

--宝库奖励
function GuildsecretareaEndCrusadePanel:updateMarketRewardlist()
    if not self.market_reward_list then return end
    if self.scrollview_list1 == nil then
        local scrollview_size = self.market_scroll_view:getContentSize()
        
        local setting = {
            start_x = 0,                     -- 第一个单元的X起点
            space_x = 0,                     -- x方向的间隔
            start_y = 0,                     -- 第一个单元的Y起点
            space_y = 0,                     -- y方向的间隔
            item_width = 100,                -- 单元的尺寸width
            item_height = 100,               -- 单元的尺寸height
            row = 1,                         -- 行数，作用于水平滚动类型
            col = 4,                         -- 列数，作用于垂直滚动类型
            delay = 1,                       -- 创建延迟时间
            once_num = 1,                    -- 每次创建的数量
        }
        self.scrollview_list1 = CommonScrollViewSingleLayout.new(self.market_scroll_view, cc.p(0,0) , ScrollViewDir.vertical, ScrollViewStartPos.top, scrollview_size, setting, cc.p(0, 0))

        self.scrollview_list1:registerScriptHandlerSingle(handler(self,self.marketcreateNewCell), ScrollViewFuncType.CreateNewCell) --创建cell
        self.scrollview_list1:registerScriptHandlerSingle(handler(self,self.marketnumberOfCells), ScrollViewFuncType.NumberOfCells) --获取数量
        self.scrollview_list1:registerScriptHandlerSingle(handler(self,self.marketupdateCellByIndex), ScrollViewFuncType.UpdateCellByIndex) --更新cell
    end
    self.scrollview_list1:reloadData()

    if #self.market_reward_list == 0 then
        commonShowEmptyIcon(self.market_scroll_view, true, {font_size = 22,scale = 0.5, offset_y = 36, text = TI18N("暂无奖励")})
    else
        commonShowEmptyIcon(self.market_scroll_view, false)
    end
end

--创建cell 
--@width 是setting.item_width
--@height 是setting.item_height
function GuildsecretareaEndCrusadePanel:marketcreateNewCell(width, height)
    local cell = BackPackItem.new(true, true, false, 0.7)
    cell:setSwallowTouches(false)
    cell:setDefaultTip()
    return cell
end

--获取数据数量
function GuildsecretareaEndCrusadePanel:marketnumberOfCells()
    if not self.market_reward_list then return 0 end
    return #self.market_reward_list
end

--更新cell(拖动的时候.刷新数据时候会执行次方法)
--cell :createNewCell的返回的对象
--index :数据的索引
function GuildsecretareaEndCrusadePanel:marketupdateCellByIndex(cell, index)
    -- cell.index = index
    local data = self.market_reward_list[index]
    if data then
        cell:setBaseData(data.id, data.num)
    end
end


--清理
function GuildsecretareaEndCrusadePanel:close_callback()
    if self.scrollview_list then
        self.scrollview_list:DeleteMe()
    end
    self.scrollview_list = nil

    if self.scrollview_list1 then
        self.scrollview_list1:DeleteMe()
    end
    self.scrollview_list1 = nil

    controller:openGuildsecretareaEndCrusadePanel(false)
end
