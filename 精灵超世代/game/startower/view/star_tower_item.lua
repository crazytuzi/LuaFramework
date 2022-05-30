-- --------------------------------------------------------------------
-- 竖版伙伴主界面的子项
-- 
-- @author: cloud@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-xx-xx
-- --------------------------------------------------------------------
StarTowerItem = class("StarTowerItem", function()
    return ccui.Widget:create()
end)

local _config = Config.StarTowerData.data_tower_base

function StarTowerItem:ctor()
    self:config()
    self:layoutUI()
    self:registerEvents()
end
function StarTowerItem:config()
    self.ctrl = StartowerController:getInstance()
    self.size = cc.size(392,153)
    self:setTouchEnabled(true)
    self:setContentSize(self.size)
    self.is_lock = false
    self:retain()
    self.is_open_tower = true
    self.star_list = {}
end
function StarTowerItem:layoutUI()
    local csbPath = PathTool.getTargetCSB("startower/star_tower_item")
    self.root_wnd = cc.CSLoader:createNode(csbPath)
    self:addChild(self.root_wnd)
    self.main_panel = self.root_wnd:getChildByName("main_panel")
    --背景
    self.background = self.main_panel:getChildByName("bg")
    --选中背景
    self.select_bg = self.main_panel:getChildByName("select_bg")
    self.select_bg:setVisible(false)

    self.tower_name = self.main_panel:getChildByName("name")
    --锁
    self.lock_icon = self.main_panel:getChildByName("lock")
    --通关图标
    self.pass_icon = self.main_panel:getChildByName("pass_icon")
    self.pass_icon:setVisible(false)
    --关键层奖励
    self._floorAward = self.main_panel:getChildByName("floorAward")
    self._firstAward = self._floorAward:getChildByName("firstAward")
    self._floorAward:setVisible(false)
    --扫荡次数
    self:countVisible(false)
    --点击进入
    self.come_label =self.main_panel:getChildByName("Image_4")
    self.come_label:setVisible(false) 
end
function StarTowerItem:countVisible(visible)
    local countBG = self.main_panel:getChildByName("countBG")
    countBG:setVisible(visible)
    self._textCount = countBG:getChildByName("textCount")
    self._textCount:setVisible(visible)
    self._dianmond = countBG:getChildByName("dianmond")
    self._dianmond:setVisible(false)
end

function StarTowerItem:setData(index)
    if not index then return end
    local data = _config[index]
    self.data = data
    local name = data.name or ""
    self.tower_name:setString(name)

    -- 引导需要
    self:setName("guildsign_startower_"..data.lev)

    self:updateMessage()
end
function StarTowerItem:sweepCount(data)
    self.pass_icon:setVisible(false)
    self:countVisible(false)
    local max_tower = self.ctrl:getModel():getNowTowerId() or 0
    if data and data.lev == max_tower then
        local count = self.ctrl:getModel():getTowerLessCount() or 0
        local buyCount = self.ctrl:getModel():getBuyCount()

        if count <= 0 then
            if buyCount >= 0 then
                self:countVisible(true)
                self._dianmond:setVisible(true)
                local have_buycount = self.ctrl:getModel():getBuyCount() or 0
                if Config.StarTowerData.data_tower_buy[have_buycount+1] then
                    local num = Config.StarTowerData.data_tower_buy[have_buycount+1].expend[1][2] or 0
                    local str = string.format(TI18N("   %d扫荡"),num)
                    self._textCount:setString(str)
                else
                    self:countVisible(false)
                    self._dianmond:setVisible(false)
                    self.pass_icon:setVisible(true)
                end
            else
                self:countVisible(false)
                self._dianmond:setVisible(false)
                self.pass_icon:setVisible(true)
            end
        else
            local str = string.format(TI18N("可扫荡%d次"),count)
            self._textCount:setString(str)
            self:countVisible(true)
            self._dianmond:setVisible(false)
            self.pass_icon:setVisible(false)
        end
    end

    if data.lev ~= max_tower and data.lev < max_tower then
        self.pass_icon:setVisible(true)
    end

    --层级奖励
    local max = max_tower
    local itemNum = 6 --写死显示6层的奖励

    if max_tower + itemNum >= #_config then 
        max = #_config
    else 
        max = max_tower + itemNum 
    end
    
    local current = max_tower
    if max_tower+1 >= #_config then 
        current = #_config
    else 
        current = max_tower+1
    end

    if self.data.lev > current and self.data.lev <= max then
        local item_show = _config[self.data.lev].item_show[1]
        if item_show then
            local baseid = item_show[1]
            local num = item_show[2]
            local item = BackPackItem.new(nil,true,nil,0.7)
            item:setDefaultTip()
            self._floorAward:addChild(item)
            self._firstAward:setZOrder(10)
            item:setPosition(cc.p(46,42))
            item:setBaseData(baseid, num)
            self._floorAward:setVisible(true)
        else
            self._floorAward:setVisible(false)    
        end
    else
        self._floorAward:setVisible(false)
    end
end

function StarTowerItem:updateMessage()
    if not self.data then return end
    local max_tower = self.ctrl:getModel():getNowTowerId() or 0

    local bool = false
    if self.data.lev <= max_tower then
        bool = true
    end
    self.is_pass = bool
    self:sweepCount(self.data)

    self.is_lock = self.data.lev > max_tower+1
    self.lock_icon:setVisible(self.is_lock)
    self.come_label:setVisible(false)
    doStopAllActions(self.come_label)
    
    self.is_open_tower = true
    if self.is_pass == false and self.is_lock == false then
        local limit_dun_id = self.data.limit_dun_id or 0
        local data = BattleDramaController:getInstance():getModel():getDramaData()
        if limit_dun_id~=0 and data and data.max_dun_id and data.max_dun_id < limit_dun_id then 
           self.is_open_tower = false
           return
        end
        if self.data.lev == max_tower+1 then
            self.come_label:setVisible(true)
            breatheShineAction(self.come_label,1,1)
            self:setSelectStatus(true)
        else
            self:setSelectStatus(false)
        end
    else
        self:setSelectStatus(false)
    end
end

--事件
function StarTowerItem:registerEvents()
    self:addTouchEventListener(function(sender, event_type) 
        if event_type == ccui.TouchEventType.ended then
            self.touch_end = sender:getTouchEndPosition()
            local is_click = true
            if self.touch_began ~= nil then
                is_click =
                    math.abs(self.touch_end.x - self.touch_began.x) <= 20 and
                    math.abs(self.touch_end.y - self.touch_began.y) <= 20
            end
            if is_click == true then
                playButtonSound2()
                self:clickHandler()
				if sender.guide_call_back ~= nil then
					sender.guide_call_back(sender)
				end
            end
        elseif event_type == ccui.TouchEventType.began then
            self.touch_began = sender:getTouchBeganPosition()
        end
    end)
end

function StarTowerItem:clickHandler()
    if self.call_fun then 
        self:call_fun(self.data)
    end
end
function StarTowerItem:addCallBack(call_fun)
    self.call_fun =call_fun
end

function StarTowerItem:setSelectStatus(bool)
    self.select_bg:setVisible(bool)
end

function StarTowerItem:setVisibleStatus(bool)
    self:setVisible(bool)
end
function StarTowerItem:getData()
    return self.data
end

function StarTowerItem:clearInfo()
    self:setSelectStatus(false)
    self:removeFromParent()
end


function StarTowerItem:DeleteMe()
    self:removeFromParent()
    self:removeAllChildren()
    self:release()
end



