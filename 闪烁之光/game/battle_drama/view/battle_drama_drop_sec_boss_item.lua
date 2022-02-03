-- --------------------------------------------------------------------
--
--
-- @author: mengjiabin@syg.com(必填, 创建模块的人员)
-- @editor: mengjiabin@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      主界面小地图
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
BattleDramaDropSecBossItem =
    class(
    'BattleDramaDropSecBossItem',
    function()
        return ccui.Layout:create()
    end
)
BattleDramaDropSecBossItem.WIDTH = 600
BattleDramaDropSecBossItem.HEIGHT = 168
function BattleDramaDropSecBossItem:ctor()
    self:retain()
    self.size = size or cc.size(BattleDramaDropSecBossItem.WIDTH, BattleDramaDropSecBossItem.HEIGHT)
    self:setContentSize(self.size)
    -- self:setTouchEnabled(true)
    self.root_wnd = cc.CSLoader:createNode(PathTool.getTargetCSB('battledrama/battle_drama_drop_sec_item'))
    self:addChild(self.root_wnd)
    self.container = self.root_wnd:getChildByName('root')
    self.name_label = self.container:getChildByName("name_label")
    self.item_scrollview = self.container:getChildByName("item_scrollview")
    self.item_scrollview:setScrollBarEnabled(false)
    self.item_scrollview:setSwallowTouches(false)
    self.item_list = {}
    -- self.reset_btn = createButton(self.container, TI18N(''), 495, 70, cc.size(145, 62), PathTool.getResFrame('common', 'common_1017'), 24)
    -- self.reset_btn:setVisible(false)
    -- self.reset_btn:setRichText(TI18N('<div fontColor=#ffffff fontsize=24 outline=2,#C45A14>扫荡</div>'))
    -- self.unlock_label = self.container:getChildByName("unlock_label")
    -- self.unlock_label:setString(TI18N("通关后可进行扫荡"))
    -- self.unlock_label:setVisible(false)
    self.swap_label = createRichLabel(24, 117, cc.p(0, 0.5), cc.p(420, 140), nil, nil, 1000)
    self.swap_label:setVisible(false)
    self.container:addChild(self.swap_label)

    self:registerEvent()
end

function BattleDramaDropSecBossItem:registerEvent()
    -- if self.reset_btn then
    --     self.reset_btn:addTouchEventListener(function (sender,event_type)
    --         if event_type == ccui.TouchEventType.ended then
    --             if self.reset_btn and self.reset_btn.status ~= 3 then
    --                 self:checkSwapAlert()
    --             else
    --                 message(TI18N("扫荡次数已满"))
    --             end
    --         end
    --     end)
    -- end
end

function BattleDramaDropSecBossItem:checkSwapAlert()
    -- local num = BackpackController:getInstance():getModel():getBackPackItemNumByBid(Config.DungeonData.data_drama_const['swap_item'].val)
    -- if self.reset_btn.status == 4 then
    --     if self.data then
    --         BattleDramaController:getInstance():send13005(self.data.dungeon_id, 1)
    --     end
    -- else
    --     if num <= 0 then --扫荡券不足
    --         local drama_data = BattleDramaController:getInstance():getModel():getDramaData()
    --         if drama_data then
    --             local swap_num = math.min(drama_data.auto_num + 1, tableLen(Config.DungeonData.data_swap_data))
    --             -- mjb("@@@@@@",swap_num)
    --             local loss = Config.DungeonData.data_swap_data[swap_num].loss

    --             local str =
    --                 string.format(
    --                 TI18N('扫荡券不足,是否使用<img src=%s visible=true scale=0.5 /><div fontColor=#289b14 fontsize= 26>%s</div>扫荡关卡?'),
    --                 PathTool.getItemRes(loss[1][1]),
    --                 loss[1][2]
    --             )
    --             local call_back = function()
    --                 if self.data and self.data.dungeon_id then
    --                     BattleDramaController:getInstance():send13005(self.data.dungeon_id, 1)
    --                 end
    --             end
    --             CommonAlert.show(str, TI18N('确定'), call_back, TI18N('取消'), nil, CommonAlert.type.rich)
    --         end
    --     else
    --         if self.data then
    --             BattleDramaController:getInstance():openDramSwapView(true, self.data.dungeon_id)
    --         end
    --     end
    -- end
end


function BattleDramaDropSecBossItem:setBossData(data)
    if not data then return  end
    self.data  = data
    local config = Config.DungeonData.data_drama_dungeon_info(data.dungeon_id)
    if config then
        self.name_label:setString(config.name)
    end
    self:updateItem(data.items)
    self:updateBtnStatus()
end

--更新扫荡按钮状态
function BattleDramaDropSecBossItem:updateBtnStatus()
    -- if self.data then
    --     local cur_dungeon_info = BattleDramaController:getInstance():getModel():getSingleBossData(self.data.dungeon_id)
    --     local free_num = Config.DungeonData.data_drama_const["free_swap"].val
    --     local drama_data = BattleDramaController:getInstance():getModel():getDramaData()
    --     local is_free = drama_data.auto_num - free_num < 0 
    --     if cur_dungeon_info and cur_dungeon_info.v_data then
    --         local dungeon_info = cur_dungeon_info.v_data
    --         if dungeon_info and dungeon_info.status == 3 then --表现已通关
    --             -- self.reset_btn:setVisible(true)
    --             -- self.unlock_label:setVisible(false)

    --             local num = BackpackController:getInstance():getModel():getBackPackItemNumByBid(Config.DungeonData.data_drama_const['swap_item'].val)
    --             local item_icon = Config.ItemData.data_get_data(Config.DungeonData.data_drama_const['swap_item'].val).icon
    --             local offset_num = Config.DungeonData.data_drama_const["swap_time"].val - drama_data.auto_num
    --             local str = ""
    --             local cost = 1
    --             if offset_num <= 0 then --证明扫荡完了
    --                 -- self.reset_btn.status = 3
    --                 -- str = TI18N('<div fontColor=#ffffff fontsize=24>已扫荡</div>')
    --                 -- self.reset_btn:setRichText(str)
    --                 -- self.reset_btn:setGrayAndUnClick(true)
    --             else
    --                 -- self.reset_btn:setGrayAndUnClick(false)
    --                 if not is_free then
    --                     if num > 0 then --如果有扫荡券
    --                         self.reset_btn.status = 2
    --                         str = string.format(TI18N("<img src=%s visible=true scale=0.35 /><div div fontColor=#ffffff fontsize=24 outline=2,#C45A14>*%s</div><div fontColor=#ffffff fontsize=24 outline=2,#C45A14>扫荡</div>"),PathTool.getItemRes(item_icon),1)
    --                     else --没有就是显示钻石了
    --                         local swap_num = math.min(drama_data.auto_num + 1, tableLen(Config.DungeonData.data_swap_data))
    --                         -- mjb("@@@@@@",swap_num)
    --                         local loss = Config.DungeonData.data_swap_data[swap_num].loss
    --                         self.reset_btn.status = 1
    --                         str = string.format(TI18N("<img src=%s visible=true scale=0.35 /> <div div fontColor=#ffffff fontsize=24 outline=2,#C45A14>%s</div><div fontColor=#ffffff fontsize=24 outline=2,#C45A14>扫荡</div>"),PathTool.getItemRes(loss[1][1]),loss[1][2])
    --                     end
    --                 else
    --                     self.reset_btn.status = 4
    --                     str = TI18N('<div fontColor=#ffffff fontsize=24>免费扫荡</div>')    
    --                 end
    --                 self.reset_btn:setRichText(str)
    --             end
    --             local str = string.format("<div fontColor=#764519>扫荡次数: </div><div fontColor=#289b14>%s</div>/%s",dungeon_info.auto_num, Config.DungeonData.data_drama_const["swap_time"].val)
    --             if dungeon_info.auto_num >= Config.DungeonData.data_drama_const["swap_time"].val then
    --                 str = string.format(TI18N("<div fontColor=#764519>扫荡次数: </div> <div fontColor=#249003>%s</div><div fontColor=#249003>/%s</div>"),dungeon_info.auto_num, Config.DungeonData.data_drama_const["swap_time"].val)
    --             end
    --             self.swap_label:setString(str)
    --         else
    --             self.reset_btn:setVisible(false)
    --             -- self.unlock_label:setVisible(true)
    --             self.swap_label:setVisible(false)
    --         end
    --     end
    -- end
end

function BattleDramaDropSecBossItem:updateItem(data)
    if not data then
        return
    end
    local scale = 0.8
    local item = nil
    local item_width = BackPackItem.Width * scale * #data

    local total_width = #data * BackPackItem.Width * scale + #data * 10
    local max_width = math.max(self.item_scrollview:getContentSize().width, total_width)
    self.item_scrollview:setInnerContainerSize(cc.size(max_width, self.item_scrollview:getContentSize().height))
    self.start_x = (self.item_scrollview:getContentSize().width - total_width) * 0.5
    for i, v in ipairs(data) do
        delayRun(self.item_scrollview,i / display.DEFAULT_FPS,function ()
            if not self.item_list[i] then
                item = BackPackItem.new(true, true)
                item:setAnchorPoint(0, 0.5)
                item:setScale(scale)
                --item:setVisible(false)
                self.item_scrollview:addChild(item)
                self.item_list[i] = item
            end
            item = self.item_list[i]
            if item then
                item:setPosition(0 + (i - 1) * (BackPackItem.Width * scale + 10), self.item_scrollview:getContentSize().height / 2 )
                local data = {bid = v[1], num = v[2]}
                item:setBaseData(v[1], v[2],true)
                --item:setIsShowName()
                item:setDefaultTip()
            end

        end)

    end

end


function BattleDramaDropSecBossItem:DeleteMe()
    if self.item_list and next(self.item_list or {}) ~= nil then
        for i, v in ipairs(self.item_list) do
            if v.DeleteMe then
                v:DeleteMe()
            end
        end
    end
    self:removeAllChildren()
    self:removeFromParent()
    self:release()
end
