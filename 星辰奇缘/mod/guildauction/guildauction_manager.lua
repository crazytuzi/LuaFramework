-- ----------------------------------------------------------
-- 逻辑模块 - 工会拍卖
-- ----------------------------------------------------------
GuildAuctionManager = GuildAuctionManager or BaseClass(BaseManager)

function GuildAuctionManager:__init()
    if GuildAuctionManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
    end

    GuildAuctionManager.Instance = self
    self.specialtime = 1492351200
    self.model = GuildAuctionModel.New()
    self.assetWrapper = nil

    self.likeList = {}
    self.itemList = {}
    self.olditemList = {}
    self.status = 0
    self.timeout = 0
    self.endtime = 0
    self:InitHandler()
    self.OnGoodsUpdate = EventLib.New() -- 拍卖商品更新
    self.OnOldGoodsUpdate = EventLib.New() -- 拍卖商品更新
    self.OnOneGoodsUpdate = EventLib.New() -- 单个拍卖商品更新
    -- PlayerPrefs.GetInt("AuctionNotice") == "1"
    self.actIcon = nil
end

function GuildAuctionManager:__delete()

end

function GuildAuctionManager:InitHandler()
    -- 最好是把所有的回调函数在连接之前全部添加
    -- 除非你很确定那些协议不会在连接后立即发送过来
    self:AddNetHandler(19700, self.on19700)
    self:AddNetHandler(19701, self.on19701)
    self:AddNetHandler(19702, self.on19702)
    self:AddNetHandler(19703, self.on19703)
    self:AddNetHandler(19704, self.on19704)
    self:AddNetHandler(19705, self.on19705)
    self:AddNetHandler(19706, self.on19706)
    self:AddNetHandler(19707, self.on19707)
end

function GuildAuctionManager:ReqOnConnect()
    self:send19700()
    -- self:send19701()
    self:send19704()
    self.model:ReadFilter()
end

function GuildAuctionManager:on19700(data)
    -- BaseUtils.dump(data, "on19700............")
    self.status = data.status
    self.timeout = data.timeout
    self.endtime = BaseUtils.BASE_TIME + data.timeout
    self.OnGoodsUpdate:Fire()
    self:CheckActIcon()
end

function GuildAuctionManager:send19700()
    Connection.Instance:send(19700, {})
end

function GuildAuctionManager:on19701(data)
    -- BaseUtils.dump(data, "on19701............")
    self.itemList = data.guild_auction_goods
    self.OnGoodsUpdate:Fire()
    self:CheckActIcon()
end

function GuildAuctionManager:send19701()
    Connection.Instance:send(19701, {})
end

function GuildAuctionManager:on19702(data)
    -- BaseUtils.dump(data, "on19702............")
    for i,goods in ipairs(data.guild_auction_goods) do
        local oldindex = nil
        for i,olditem in ipairs(self.itemList) do
            if olditem.id == goods.id then
                oldindex = i
                break
            end
        end
        if oldindex == nil then
            table.insert(self.itemList, goods)
            self.OnGoodsUpdate:Fire()
        else
            for k,v in pairs(goods) do
                self.itemList[oldindex][k] = v
            end
            self.OnOneGoodsUpdate:Fire(self.itemList[oldindex])
        end
    end
    self:CheckActIcon()
end

function GuildAuctionManager:send19702()
    Connection.Instance:send(19702, {})
end

function GuildAuctionManager:on19703(data)
    -- BaseUtils.dump(data, "on19703............")
    NoticeManager.Instance:FloatTipsByString(data.msg)
    -- if data.flag == 0 then
        self.model:ClosePanel()
    -- end
end

function GuildAuctionManager:send19703(id, price)
    -- BaseUtils.dump({id = id, price = price}, "拍卖商品")
    Connection.Instance:send(19703, {id = id, price = price})
end

function GuildAuctionManager:on19704(data)
    -- BaseUtils.dump(data, "on19704............")
    self.likeList = {}
    for i,v in ipairs(data.subscriptions) do
        self.likeList[v.id] = true
    end
    self.OnGoodsUpdate:Fire()
end

function GuildAuctionManager:send19704(id)
    Connection.Instance:send(19704, {id = id})
end

function GuildAuctionManager:on19705(data)
    -- BaseUtils.dump(data, "on19705............")
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.flag == 1 then
        self.likeList[data.id] = true
        self.OnGoodsUpdate:Fire()
    end
end

function GuildAuctionManager:send19705(id)
    Connection.Instance:send(19705, {id = id})
end

function GuildAuctionManager:on19706(data)
    -- BaseUtils.dump(data, "on19706............")
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.flag == 1 then
        self.likeList[data.id] = nil
        self.OnGoodsUpdate:Fire()
    end
end

function GuildAuctionManager:send19706(id)
    Connection.Instance:send(19706, {id = id})
end

function GuildAuctionManager:on19707(data)
    -- BaseUtils.dump(data, "on19707............")
    self.olditemList = data.guild_auction_goods
    self.OnOldGoodsUpdate:Fire()
end

function GuildAuctionManager:send19707()
    Connection.Instance:send(19707, {})
end

function GuildAuctionManager:CheckRedPonint(islocalcfg)
    self:CheckActIcon()
    if self.status == 0 then
        return false
    elseif self.status == 1 then
        if islocalcfg then
            return true and PlayerPrefs.GetInt("AuctionNotice") == 1
        else
            return true
        end
    else
        for k,v in pairs(self.itemList) do
            if v.status == 0 then
                if islocalcfg then
                    return true and PlayerPrefs.GetInt("AuctionNotice") == 1
                else
                    return true
                end
            end
        end
        return false
    end
end

function GuildAuctionManager:CheckActIcon()
    local cfg_data = DataSystem.data_daily_icon[331]
    if cfg_data.lev > RoleManager.Instance.RoleData.lev then
        return
    end
    if PlayerPrefs.GetInt("AuctionNotice") == 0 then
        MainUIManager.Instance:DelAtiveIcon(331)
        self.actIcon = nil
        return
    end

    if self.status == 0 then
        MainUIManager.Instance:DelAtiveIcon(331)
        self.actIcon = nil
    elseif self.status == 1 and self.actIcon == nil then
        local iconData = AtiveIconData.New()
        iconData.id = cfg_data.id
        iconData.iconPath = cfg_data.res_name
        iconData.clickCallBack = function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.guildauctionwindow) end
        iconData.sort = cfg_data.sort
        iconData.lev = cfg_data.lev
        -- iconData.timestamp = self.timeout + Time.time
        -- iconData.text = ""
        -- iconData.effectId = 20256
        -- iconData.effectPos = Vector3(0, 32, -400)
        -- iconData.effectScale = Vector3(1, 1, 1)
        self.actIcon = MainUIManager.Instance:AddAtiveIcon(iconData)
    elseif self.status == 2 then
        local has = false
        for k,v in pairs(self.itemList) do
            if v.status == 0 then
                has = true
                break
            end
        end
        if has then
            MainUIManager.Instance:DelAtiveIcon(331)
            local iconData = AtiveIconData.New()
            iconData.id = cfg_data.id
            iconData.iconPath = cfg_data.res_name
            iconData.clickCallBack = function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.guildauctionwindow) end
            iconData.sort = cfg_data.sort
            iconData.lev = cfg_data.lev
            -- iconData.timestamp = self.timeout + Time.time
            -- iconData.text = ""
            -- iconData.effectId = 20256
            -- iconData.effectPos = Vector3(0, 32, -400)
            -- iconData.effectScale = Vector3(1, 1, 1)
            self.actIcon = MainUIManager.Instance:AddAtiveIcon(iconData)
        else
            MainUIManager.Instance:DelAtiveIcon(331)
            self.actIcon = nil
        end
    end
end

function GuildAuctionManager:GetEndTime(starttime, last_bidden, timeout)

    if starttime > BaseUtils.BASE_TIME then
        return BaseUtils.BASE_TIME + 86400*2
    end
    local week = tonumber(os.date("%w", starttime))
    local year = tonumber(os.date("%Y", starttime))
    local month = tonumber(os.date("%m", starttime))
    local day = tonumber(os.date("%d", starttime))
    local today = tonumber(os.date("%d", BaseUtils.BASE_TIME))
    local endtime = BaseUtils.BASE_TIME
    if last_bidden ~= 0 or tonumber(os.date("%w", BaseUtils.BASE_TIME)) == 0 then
        endtime = os.time{year=year, month=month, day=day, hour=23}
    -- else
        -- endtime = os.time{year=year, month=month, day=day, hour=23}
    end
    if day ~= today then
        endtime = os.time{year=year, month=month, day=day+1, hour=23}
    end
    if timeout > 0 then
        endtime = timeout
    end
    -- if self.status == 1 then
    --     endtime = BaseUtils.BASE_TIME
    -- end
    return endtime
end
