-- --------------------------------------------------------------------
-- 这里填写简要说明(必填),
--
-- @author: xxx@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      这里填写详细说明,主要填写该模块的功能简要
-- <br/>Create: 2018-07-16
-- --------------------------------------------------------------------
RedbagModel = RedbagModel or BaseClass()

function RedbagModel:__init(ctrl)
    self.ctrl = ctrl
    self:config()
end

function RedbagModel:config()
    self.redbag_list = {}
    self.redbag_num = 0
    self.redbag_send_num = 0
    self.redbag_rec_num = 0
    self.is_get_redbag = 0
    self.red_bag_item_num = {}
    self.all_red_show = false
end

function RedbagModel:resetData()
    self:config()
end
function RedbagModel:__delete()
end

function RedbagModel:updateData(data)
    if not data then return end
    if data.type and data.type ==0 then 
        self.redbag_list = {}
    end
    local list = data.list or {}
    for i,v in pairs(list) do
        v.order = 0-v.time
        if v.flag ==0 and v.num <v.max_num and v.time-GameNet:getInstance():getTime()>=0 then
            v.order = GameNet:getInstance():getTime()-v.time
        end
        self.redbag_list[v.id] =v
    end
    GlobalEvent:getInstance():Fire(RedbagEvent.Get_Data_Event,data)
   
    if self.is_get_redbag ~= 0 then 
        self:checkRedBagRedPoint()
    else
        GuildController:getInstance():SendProtocal(13523, {}) 
    end
    self.is_get_redbag = 0
end

function RedbagModel:updateRedBagNum(send_num,rec_num)
    self.redbag_send_num = send_num or 0
    self.redbag_rec_num = rec_num or 0
    self.is_get_redbag = 1
    local max_rec_num = Config.GuildData.data_const["red_packet_get"].val
    if self.redbag_rec_num >= max_rec_num then 
        self.is_get_redbag = 2
    end
    self:checkRedBagRedPoint()
end
function RedbagModel:checkRedBagRedPoint( )
    --判断有没有没领取的红包，有就抛事件推送
    local vo
    self.is_have_red = false
    self.all_red_show = false
    self.redbag_num = 0
    for i,v in pairs(self.redbag_list) do
        self.redbag_num = self.redbag_num+1
        --没过期也没被领完的
        if v.num <v.max_num then 
            if v.time-GameNet:getInstance():getTime()>=0 then 
                if v.flag == 0 then
                    vo = v
                    self.is_have_red = true
                    self.all_red_show = true
                    break
                end
            end
        end
    end
    if self.is_get_redbag == 2 then 
        vo = nil
        self.is_have_red = false
        self.all_red_show = false
    end
    self:checkItemNumRedPoint()
    if self.red_bag_item_num and next(self.red_bag_item_num or {}) ~= nil then
        for i,v in ipairs(self.red_bag_item_num) do
            if v.status == true then
                self.all_red_show = true
                break
            end
        end
    end
    --抛去主界面播特效
    GlobalEvent:getInstance():Fire(RedbagEvent.Can_Get_Red_Bag,vo)
    --抛去公会界面红点
    GlobalEvent:getInstance():Fire(GuildEvent.UpdateGuildRedStatus,GuildConst.red_index.red_bag, self.all_red_show) 
    --更新场景红点
    local base_data = Config.FunctionData.data_base
    local bool = MainuiController:getInstance():checkIsOpenByActivate(base_data[6].activate)
    if bool == true then
        MainuiController:getInstance():setBtnRedPoint(MainuiConst.btn_index.guild, {bid = GuildConst.red_index.red_bag, status = self.all_red_show}) 
    end
end

--主要红包道具的数量判断
function RedbagModel:checkItemNumRedPoint()
    if Config.GuildData.data_guild_red_bag then
        self.red_bag_item_num = {}
       
        for i,v in ipairs(Config.GuildData.data_guild_red_bag) do
            if v and v.loss_item and v.loss_item[1] then
                local has_num = BackpackController:getInstance():getModel():getBackPackItemNumByBid(v.loss_item[1][1])
                local status = false
                if has_num >= v.loss_item[1][2] then
                    status = true
                end
                table.insert(self.red_bag_item_num,{id = v.id ,status = status,bid = v.loss_item[1][1]})
            end
        end
    end
end


function RedbagModel:getRedBagNum( )
    return self.redbag_num or 0
end
function RedbagModel:getIsHaveRedBag()
    return self.is_have_red or false
end

function RedbagModel:getAllRedBagStatus()
    return self.all_red_show or false
end

--每次打开获取拥有红包道具的的最少来ID来默认打开那个界面
function RedbagModel:getHaveItemID()
    if self.red_bag_item_num and next(self.red_bag_item_num or {}) ~= nil then
        local temp_id = 99
        for i, v in ipairs(self.red_bag_item_num) do
            if v.status == true and v.id <= temp_id then
                temp_id = v.id
            end
        end
        return temp_id
    end 
end

function RedbagModel:getSendRedBagStatue(id)
   local status = false
    if self.red_bag_item_num and next(self.red_bag_item_num or {}) ~= nil then
        for i, v in ipairs(self.red_bag_item_num) do
            if id then
                if v.id ~= id then
                    if v.status == true then
                        status = true
                        break
                    end
                end
            else
                if v.status == true then
                    status = true
                    break
                end
            end
        end
    end
    return status
end

function RedbagModel:getRebBagItemNumList()
    if self.red_bag_item_num and next(self.red_bag_item_num or {}) ~= nil then
        return self.red_bag_item_num
    end
end
function RedbagModel:getRedBagList()
    local redbag_list = {}
    for k,v in pairs(self.redbag_list) do
        table.insert(redbag_list, v)
    end
    return redbag_list 
end

function RedbagModel:getRedBagListById(id)
    return self.redbag_list[id]
end