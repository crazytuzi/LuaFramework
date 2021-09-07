RedBagModel = RedBagModel or BaseClass(BaseModel)

function RedBagModel:__init()
    self.red_bag_win = nil
    self.red_bag_unopen_win = nil
    self.red_bag_set_win = nil
    self.red_bag_money_win = nil
    self.world_red_bag_list_win = nil
    self.worldredbaginputwindow = nil
    
    self.current_red_bag = nil

    self.red_packet = {}
    self.is_over = true
end

function RedBagModel:__delete()
    
end

--打开世界红包面板
function RedBagModel:InitRedBagUI()
    if self.red_bag_win == nil then
        self.red_bag_win = WorldRedBagWindow.New(self)
        self.red_bag_win:Show()
    end
end

--关闭世界红包面板
function RedBagModel:CloseRedBagUI()
    if self.red_bag_win ~= nil then
        self.red_bag_win:DeleteMe()
        self.red_bag_win = nil
    end
end

--打开世界红包打开面板
function RedBagModel:InitUnRedBagUI()
    if self.red_bag_unopen_win == nil then
        self.red_bag_unopen_win = WorldRedBagUnOpenWindow.New(self)
        self.red_bag_unopen_win:Show()
    end
end

--关闭世界红包打开面板
function RedBagModel:CloseUnRedBagUI()
    if self.red_bag_unopen_win ~= nil then
        self.red_bag_unopen_win:DeleteMe()
        self.red_bag_unopen_win = nil
    end
end

--打开世界红包设置面板
function RedBagModel:InitRedBagSetUI()
    if self.red_bag_set_win == nil then
        self.red_bag_set_win = WorldRedBagSetWindow.New(self)
    end
    self.red_bag_set_win:Open()
end

--关闭世界红包设置面板
function RedBagModel:CloseRedBagSetUI()
    if self.red_bag_set_win ~= nil then
        self.red_bag_set_win:DeleteMe()
        self.red_bag_set_win = nil
    end
end

--打开世界红包设置选钱面板
function RedBagModel:InitRedBagMoneyUI(args)
    if self.red_bag_money_win == nil then
        self.red_bag_money_win = WorldRedBagMoneyWindow.New(self)
        self.red_bag_money_win:Show(args)
    end
end

--关闭世界红包设置选钱面板
function RedBagModel:CloseRedBagMoneyUI()
    if self.red_bag_money_win ~= nil then
        self.red_bag_money_win:DeleteMe()
        self.red_bag_money_win = nil
    end
end

--打开世界红包列表面板
function RedBagModel:InitRedBagListUI()
    if self.world_red_bag_list_win == nil then
        self.world_red_bag_list_win = WorldRedBagListWindow.New(self)
    end
    self.world_red_bag_list_win:Open()
end

--关闭世界红包列表面板
function RedBagModel:CloseRedBagListUI()
    if self.world_red_bag_list_win ~= nil then
        self.world_red_bag_list_win:OnClickClose()
        -- self.world_red_bag_list_win:DeleteMe()
        -- self.world_red_bag_list_win = nil
    end
end

--打开口令红包输入面板
function RedBagModel:InitRedBagInputUI()
    if self.worldredbaginputwindow == nil then
        self.worldredbaginputwindow = WorldRedBagInputWindow.New(self)
        self.worldredbaginputwindow:Show()
    end
end

--关闭口令红包输入面板
function RedBagModel:CloseRedBagInputUI()
    if self.worldredbaginputwindow ~= nil then
        self.worldredbaginputwindow:DeleteMe()
        self.worldredbaginputwindow = nil
    end
end

--更新发送红包界面
function RedBagModel:update_red_bag_set_win(_type)
    if self.red_bag_set_win ~= nil then
        self.red_bag_set_win:update_send_info(_type)
    end
end

-- 开启红包
function RedBagModel:OpenRedBag(rid, zone_id, platform)
    for _,value in pairs(self.red_packet) do
        if value.rid == rid and value.zone_id == zone_id and value.platform == platform then
            RedBagManager.Instance:Send18505(rid, platform, zone_id) 
        end
    end
end

--世界聊天匹配口令红包
function RedBagModel:CheckRedBagPassword(channel, str)
    if channel == MsgEumn.ChatChannel.World then
        for i=1, #self.red_packet do
            local redBagData = self.red_packet[i]
            if redBagData.type == 2 and redBagData.title == str then
                RedBagManager.Instance:Send18503(redBagData.rid, redBagData.platform, redBagData.zone_id)
            end
        end
    end
end