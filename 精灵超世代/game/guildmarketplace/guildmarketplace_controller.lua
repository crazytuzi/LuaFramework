-- --------------------------------------------------------------------

-- @author: lwc@syg.com(必填, 创建模块的人员)
-- @editor: xxx@syg.com(必填, 后续维护以及修改的人员)
-- @description:
--      公会宝库 后端 国辉 策划 松岳
-- <br/>Create: 2019-09-04
-- --------------------------------------------------------------------
GuildmarketplaceController = GuildmarketplaceController or BaseClass(BaseController)

function GuildmarketplaceController:config()
    self.model = GuildmarketplaceModel.New(self)
    self.dispather = GlobalEvent:getInstance()
end

function GuildmarketplaceController:getModel()
    return self.model
end

function GuildmarketplaceController:registerEvents()
end

function GuildmarketplaceController:registerProtocals()
    self:RegisterProtocal(26900, "handle26900")     --宝库信息
    self:RegisterProtocal(26901, "handle26901")     --出售商品
    self:RegisterProtocal(26902, "handle26902")     --购买商品
    self:RegisterProtocal(26903, "handle26903")     --公告信息

    self:RegisterProtocal(26904, "handle26904")     --增加
    self:RegisterProtocal(26905, "handle26905")     --变化
    self:RegisterProtocal(26906, "handle26906")     --删除
end

--宝库信息
function GuildmarketplaceController:sender26900()
    local protocal ={}
    self:SendProtocal(26900,protocal)
end

function GuildmarketplaceController:handle26900(data)
    GlobalEvent:getInstance():Fire(GuildmarketplaceEvent.GUILD_MARKET_PLACE_ITEM_EVENT, data)
end

function GuildmarketplaceController:handle26904(data)
    GlobalEvent:getInstance():Fire(GuildmarketplaceEvent.GUILD_MARKET_PLACE_ITEM_EVENT, data)
end

function GuildmarketplaceController:handle26905(data)
    GlobalEvent:getInstance():Fire(GuildmarketplaceEvent.GUILD_MARKET_PLACE_ITEM_EVENT, data)
end

function GuildmarketplaceController:handle26906(data)
    for i,v in ipairs(data.id_list) do
        v.num = 0
    end
    data.item_list = data.id_list
    GlobalEvent:getInstance():Fire(GuildmarketplaceEvent.GUILD_MARKET_PLACE_ITEM_EVENT, data)
end


--出售商品
function GuildmarketplaceController:sender26901(id, quantity, storage)
    local protocal = {}
    protocal.id = id
    protocal.quantity = quantity
    protocal.storage = storage
    self:SendProtocal(26901, protocal)
end

function GuildmarketplaceController:handle26901(data)
    message(data.msg)
    -- GlobalEvent:getInstance():Fire(GuildmarketplaceEvent.GUILD_MARKET_PLACE_PUT_ITEM_EVENT, data)
end

--购买商品
function GuildmarketplaceController:sender26902(id, quantity)
    local protocal = {}
    protocal.id = id
    protocal.quantity = quantity
    self:SendProtocal(26902, protocal)
end

function GuildmarketplaceController:handle26902(data)
    message(data.msg)
    -- GlobalEvent:getInstance():Fire(GuildmarketplaceEvent.GUILD_MARKET_PLACE_BUY_ITEM_EVENT, data)
end

--公告信息
function GuildmarketplaceController:sender26903(id, quantity, storage)
    local protocal = {}
    self:SendProtocal(26903, protocal)
end

function GuildmarketplaceController:handle26903(data)
    GlobalEvent:getInstance():Fire(GuildmarketplaceEvent.GUILD_MARKET_PLACE_MESSAGE_EVENT, data)
end

--打开公会宝库
function GuildmarketplaceController:openGuildmarketplaceMainWindow(status, setting)
    if RoleController:getInstance():getRoleVo():isHasGuild() == false then
        message(TI18N("您当前未加入任何公会，加入公会后才能参与该玩法！"))
        return
    end
    if status == false then
        if self.guildmarketplace_main_window ~= nil then
            self.guildmarketplace_main_window:close()
            self.guildmarketplace_main_window = nil
        end
    else
        if self.guildmarketplace_main_window == nil then
            self.guildmarketplace_main_window = GuildmarketplaceMainWindow.New()
        end
        self.guildmarketplace_main_window:open(setting)
    end
end
--打开放入道具界面
function GuildmarketplaceController:openGuildmarketplacePutItemWindow(status, setting)
    if status == false then
        if self.guildmarketplace_put_item_window ~= nil then
            self.guildmarketplace_put_item_window:close()
            self.guildmarketplace_put_item_window = nil
        end
    else
        if self.guildmarketplace_put_item_window == nil then
            self.guildmarketplace_put_item_window = GuildmarketplacePutItemWindow.New()
        end
        self.guildmarketplace_put_item_window:open(setting)
    end
end
--选择数量
function GuildmarketplaceController:openGuildmarketplaceBuyItemPanel(status, setting, show_type)
    if status == false then
        if self.guildmarketplace_buy_item_window ~= nil then
            self.guildmarketplace_buy_item_window:close()
            self.guildmarketplace_buy_item_window = nil
        end
    else
        if self.guildmarketplace_buy_item_window == nil then
            self.guildmarketplace_buy_item_window = GuildmarketplaceBuyItemPanel.New(show_type)
        end
        self.guildmarketplace_buy_item_window:open(setting)
    end
end
--打开记录
function GuildmarketplaceController:openGuildmarketplaceRecordInfoPanel(status, setting)
    if status == false then
        if self.guildmarketplace_record_info_panel ~= nil then
            self.guildmarketplace_record_info_panel:close()
            self.guildmarketplace_record_info_panel = nil
        end
    else
        if self.guildmarketplace_record_info_panel == nil then
            self.guildmarketplace_record_info_panel = GuildmarketplaceRecordInfoPanel.New()
        end
        self.guildmarketplace_record_info_panel:open(setting)
    end
end



function GuildmarketplaceController:__delete()
    if self.model ~= nil then
        self.model:DeleteMe()
        self.model = nil
    end
end