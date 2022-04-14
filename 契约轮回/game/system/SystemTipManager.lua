-- 
-- @Author: LaoY
-- @Date:   2018-07-13 16:14:30
-- 

require('game.system.RequireSystem')
SystemTipManager = SystemTipManager or class("SystemTipManager", BaseManager)
local SystemTipManager = SystemTipManager

function SystemTipManager:ctor()
    SystemTipManager.Instance = self
    self.notify_layer = panelMgr:GetLayer("Top")

    self.text_cache_list = list()
    self.goods_cache_list = list()
    self.exp_cache_list = list()

    self.text_ref = Ref()
    self.show_text_max_count = 6
    self.show_text_count = 0
    self.show_text_time_list = {}

    self.goods_sort_index = 0
    self:Reset()

    UpdateBeat:Add(self.Update, self)
end

function SystemTipManager:Reset()
    if self.text_list then
        local item = self.text_list:shift()
        while (item) do
            item:destroy()
            item = self.text_list:shift()
        end
    else
        self.text_list = list()
    end

    if self.text_cache_list then
        self.text_cache_list:clear()
    else
        self.text_cache_list = list()
    end

    self.last_add_text_time = Time.time
    self.last_add_goods_time = Time.time
    self.last_add_exp_time = Time.time

    if self.goods_cache_list then
        self.goods_cache_list:clear()
    else
        self.goods_cache_list = list()
    end

    if self.exp_list then
        local exp_item = self.exp_list:shift()
        while (exp_item) do
            exp_item:destroy()
            exp_item = self.exp_list:shift()
        end
    else
        self.exp_list = list()
    end

    if self.exp_cache_list then
        self.exp_cache_list:clear()
    else
        self.exp_cache_list = list()
    end
end

function SystemTipManager.GetInstance()
    if SystemTipManager.Instance == nil then
        SystemTipManager()
    end
    return SystemTipManager.Instance
end

function SystemTipManager:Update()
    -- 文字飘窗提示
    if self.text_cache_list.length > 0 and self:IsCanAddTextAction() then
        local str = self.text_cache_list:shift()
        self:AddTextAction(str)
    end

    -- 物品飘窗提示

    if self.goods_cache_list.length > 0 and self:IsCanAddGoodAction() then
        local info = self.goods_cache_list:shift()
        self:AddGoodsAction(info.goods_id, info.number)
    end

    --经验获飘字提示
    if self.exp_cache_list.length > 0 and self:IsCanAddExpAction() then
        local str = self.exp_cache_list:shift()
        self:AddExpAction(str)
    end
end

-----------------经验获飘字提示相关---------------
function SystemTipManager:ShowExpNotify(str)
    if self:IsCanAddExpAction() then
        self:AddExpAction(str)
    else
        self.exp_cache_list:push(str)
    end
end

function SystemTipManager:IsCanAddExpAction()
    return Time.time - self.last_add_exp_time > 0.3
end

function SystemTipManager:AddExpAction(str)
    self.last_add_exp_time = Time.time
    local item = ExpNotify(self.notify_layer)
    item:DoAction(str)
    self.exp_list:push(item)
end


function SystemTipManager:RemoveExpNotify(item)
    self.exp_list:erase(item)
end
--------------------------------------------------

-- 文字飘窗
function SystemTipManager:ShowTextNotify(str)
    if self:IsCanAddTextAction() then
        self:AddTextAction(str)
    else
        self.text_cache_list:push(str)
    end
end

function SystemTipManager:AddTextAction(str)
    self.last_add_text_time = Time.time
    local item = TextNotify(self.notify_layer)
    item:DoAction(str)
    self.text_list:push(item)
end
-- function SystemTipManager:AddTextAction(str)
--     self.last_add_text_time = Time.time
--     local item = NotifyText(self.notify_layer)
--     local delta_time
--     local last_item = self.text_list:prev(self.text_list)
--     if last_item then
--         delta_time = last_item.value:GetDelayTime()
--     end
--     local index = 1
--     local max_lenght = math.min(NotifyText.MaxCount, self.text_list.length)
--     Yzprint('--LaoY SystemTipManager.lua,line 141-- data=', self.text_list.length, delta_time)
--     for k, list_item in rilist(self.text_list) do
--         index = index + 1
--         if index > NotifyText.MaxCount then
--             list_item:destroy()
--         elseif index > max_lenght + 1 then
--             -- break
--         else
--             list_item:StartAction(index, delta_time, (max_lenght - index + 1))
--         end
--     end
--     item:SetData(str)
--     item:StartAction(nil, nil, max_lenght)
--     self.text_list:push(item)
-- end

function SystemTipManager:IsCanAddTextAction()
    return Time.time - self.last_add_text_time > 0.6
end

function SystemTipManager:RemoveTextNotify(item)
    self.text_list:erase(item)
end

-- 获取物品提示
function SystemTipManager:ShowGoodsNotify(goods_id, number)
    if self:IsCanAddGoodAction() then
        self:AddGoodsAction(goods_id, number)
    else
        local info = { goods_id = goods_id, number = number }
        self.goods_cache_list:push(info)
    end
end

function SystemTipManager:AddGoodsAction(goods_id, number)
    self.last_add_goods_time = Time.time
    local item = NotifyGoods(self.notify_layer)
    item:SetData(goods_id, number)
    item:StartAction()
    --test
    self.goods_sort_index = self.goods_sort_index + 1
    item:SetSiblingIndex(self.goods_sort_index)
end

function SystemTipManager:IsCanAddGoodAction()
    return Time.time - self.last_add_goods_time > 1.1
end

function SystemTipManager:GetGoodsNotify()

end

function SystemTipManager:CacheGoodsNotify()
end
