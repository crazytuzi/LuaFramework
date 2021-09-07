

SignDrawModel = SignDrawModel or BaseClass(BaseModel)

function SignDrawModel:__init()
	self.mainWin = nil
    self.blessWin = nil                             -- 传递花语活动

    --签到抽奖活动数据
	self.questList = {}		                        --任务列表数据
	self.rewardData = {reward = {} , number = {}}   --奖励配置列表
	self.sign = { reward = {} }                     --签到数据
    self.markHide = false


    --传递花语活动数据
    self.flower_list = {flower_info = {}}

    --直购礼包数据
    self.data20479 = {}
    self.value = 0
    self.buy_time = 0

end

function SignDrawModel:__delete()
end

function SignDrawModel:OpenWindow(args)
    if self.mainWin == nil then
    	self.mainWin = SignDrawWindow.New(self)

    end
    self.mainWin:Open(args)
end

function SignDrawModel:CloseWindow()
	WindowManager.Instance:CloseWindow(self.mainWin)
end

function SignDrawModel:OpenGiftShow(args)
    if self.giftShow ~= nil then
        self.giftShow:Close()
    end
    if self.giftShow == nil then
        self.giftShow = BackpackGiftShow.New(self)
    end
    self.giftShow:Show(args)
end

function SignDrawModel:CloseGiftShow()
    if self.giftShow ~= nil then
        self.giftShow:DeleteMe()
        self.giftShow = nil
    end
end

function SignDrawModel:OpenPassBlessWindow(args)
    if self.blessWin == nil then
        self.blessWin = PassBlessWindow.New(self)
    end
    self.blessWin:Open(args)
end

function SignDrawModel:ClosePassBlessWindow(args)
    WindowManager.Instance:CloseWindow(self.blessWin)
end

function SignDrawModel:OpenPassBlessSubWindow(args)
    if self.blessSubWin == nil then
        self.blessSubWin = PassBlessSubWindow.New(self)
    end
    self.blessSubWin:Open(args)
end

function SignDrawModel:ClosePassBlessWindow(args)
    WindowManager.Instance:CloseWindow(self.blessSubWin)
end

function SignDrawModel:OpenDirectPackageWindow(args)
    if self.directPackageWin == nil then
        self.directPackageWin = DirectPackageWindow.New(self)
    end
    self.directPackageWin:Open(args)
end

function SignDrawModel:CloseDirectPackageWindow(args)
    WindowManager.Instance:CloseWindow(self.directPackageWin)
end

--检查是否购买直购礼包
function SignDrawModel:GetDirectPackageBuyStatus()
    local flag = false
    for k,v in ipairs(self.data20479) do
        if v.flag == 1 or v.flag == 2 then 
            flag = true
            break
        end
    end
    return flag
end

--检测直购7日礼包红点
function SignDrawModel:GetDirectPackageRedPointStatus()
    local red = false
    for k,v in ipairs(self.data20479) do
        if v.flag == 2 then 
            red = true
            break
        end
    end
    return red
end

