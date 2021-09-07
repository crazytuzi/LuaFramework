-- @author pwj
-- @date 2018年2月26日,星期一

ArborDayShakeModel = ArborDayShakeModel or BaseClass(BaseModel)

function ArborDayShakeModel:__init()
    self.returnRewardlist = { }    --协议返回奖励
    self.history = { }

    self.DrawEffectList = { }   --是否抽中组合道具
end

function ArborDayShakeModel:__delete()
end

--打开奖励面板
function ArborDayShakeModel:OpenRewardWindow(args)
    if self.RewardWin == nil then
        self.RewardWin = ArborDayRewardWin.New(self)
    end
    self.RewardWin:Open(args)
end

function ArborDayShakeModel:CloseWindow()
    WindowManager.Instance:CloseWindow(self.RewardWin)
end

function ArborDayShakeModel:OpenGiftShow(args)
    if self.giftShow ~= nil then
        self.giftShow:Close()
    end
    if self.giftShow == nil then
        self.giftShow = BackpackGiftShow.New(self)
    end
    self.giftShow:Show(args)
end

function ArborDayShakeModel:CloseGiftShow()
    if self.giftShow ~= nil then
        self.giftShow:DeleteMe()
        self.giftShow = nil
    end
end

function ArborDayShakeModel:GenerateNormalHistory(data)
    if data ~= nil then
        self.history = { }
        for i, v in pairs(data.reward_info) do
            if v.type == 0 then
                local str = string.format("恭喜{role_2, %s}获得{item_2, %d, 0, %d}", v.name, v.items[1].item_id, v.items[1].val )
                --local str = "瑞兔送福!{role_2, 曦の雨果}抽中了{item_2, 23740, 0, 1}"
                table.insert(self.history, str)
            elseif v.type == 1 then
                local str = string.format("恭喜{role_2, %s}额外获得{item_2, %d, 0, %d},可喜可贺!", v.name, v.items[1].item_id, v.items[1].val )
                table.insert(self.history, str)
            end
        end
    end
end


