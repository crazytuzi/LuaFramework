GuildPrayModel = GuildPrayModel or BaseClass(BaseModel)

function GuildPrayModel:__init()
    self.guild_pray_win = nil
    self.pay_data = nil
end

function GuildPrayModel:__delete()
    self:ClosePrayUI()
end

--关闭公会祈祷界面
function GuildPrayModel:ClosePrayUI()
    WindowManager.Instance:CloseWindow(self.guild_pray_win)
    if self.guild_pray_win == nil then
        -- print("===================self.guild_pray_win is nil")
    else
        -- print("===================self.guild_pray_win is not nil")
    end

end


function GuildPrayModel:update_guild_assets()
    if self.guild_pray_win ~= nil then
        self.guild_pray_win:update_guild_assets()
    end
end

function GuildPrayModel:update_view()
    if self.guild_pray_win ~= nil then
        self.guild_pray_win:update_view()
    end
end
