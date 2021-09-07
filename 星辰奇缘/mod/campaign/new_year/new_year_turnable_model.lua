-- @author author
-- @date 2018年1月20日,星期六

NewYearTurnableModel = NewYearTurnableModel or BaseClass(BaseModel)

function NewYearTurnableModel:__init()

    self.turnItems = { }   --items数据

    self.freeTime = 0
    self.todayDrawTime = 0    --今日抽奖次数
    self.currentGold = 0      --当前奖池
    self.recordExt = { }      --抽奖记录

    self.rewardList = { }     --物品列表{reward={分组id,奖励图标,奖励物品 ={}}}
    self.sortRewardList = { }

    self.DrawRewardList = { }     --抽奖物品列表

    self.MaxTime = 0
    self.NoticeTips = ""

    self.lossItemId = 20000
end

function NewYearTurnableModel:__delete()
end

function NewYearTurnableModel:OpenMainWindow(args)
    if self.mainWin == nil then
        self.mainWin = NewYearTurnableWindow.New(self)
    end
    self.mainWin:Open(args)
end

function NewYearTurnableModel:CloseWindow()
    WindowManager.Instance:CloseWindow(self.mainWin)
end

function NewYearTurnableModel:InitRewardList()
    self.sortRewardList = { }
    if next(self.rewardList) ~= nil then
       for i,v in ipairs(self.rewardList) do
           if self.sortRewardList[v.group_id] == nil then
               self.sortRewardList[v.group_id] = {}
               table.insert(self.sortRewardList[v.group_id],v)
           else
               table.insert(self.sortRewardList[v.group_id],v)
           end
       end
       -- table.sort( self.sortRewardList,function(a,b)
       --     if (a ~= b)

       --  end)
    end
    --BaseUtils.dump(self.sortRewardList,"sortRewardList数据：")
end


function NewYearTurnableModel:OpenGiftShow(args)
    if self.giftShow ~= nil then
        self.giftShow:Close()
    end
    if self.giftShow == nil then
        self.giftShow = BackpackGiftShow.New(self)
    end
    self.giftShow:Show(args)
end

function NewYearTurnableModel:CloseGiftShow()
    if self.giftShow ~= nil then
        self.giftShow:DeleteMe()
        self.giftShow = nil
    end
end


