-- @author 黄耀聪
-- @date 2016年10月22日

SwornModel = SwornModel or BaseClass(BaseModel)

function SwornModel:__init()
    -- 第i行第j列表示，结拜队伍中，排行i的人对排行j的人的称呼
    self.normalList = {TI18N("老大"),TI18N("老二"),TI18N("老三"),TI18N("老四"),TI18N("老五")}
    self.rankList = {TI18N("大"),TI18N("二"),TI18N("三"),TI18N("四"),TI18N("五"),TI18N("六"),TI18N("七"),TI18N("八"),TI18N("九"),TI18N("十")}
    self.numList = {TI18N("一"),TI18N("双"),TI18N("三"),TI18N("四"),TI18N("五"),TI18N("六"),TI18N("七"),TI18N("八"),TI18N("九"),TI18N("十")}
    self.nameTab = {
        [1] = {
            {TI18N("我"),TI18N("二弟"),TI18N("三弟"),TI18N("四弟"),TI18N("五弟"),TI18N("六弟"),TI18N("七弟"),TI18N("八弟"),TI18N("九弟"),TI18N("十弟")},
            {TI18N("大哥"),TI18N("我"),TI18N("三弟"),TI18N("四弟"),TI18N("五弟"),TI18N("六弟"),TI18N("七弟"),TI18N("八弟"),TI18N("九弟"),TI18N("十弟")},
            {TI18N("大哥"),TI18N("二哥"),TI18N("我"),TI18N("四弟"),TI18N("五弟"),TI18N("六弟"),TI18N("七弟"),TI18N("八弟"),TI18N("九弟"),TI18N("十弟")},
            {TI18N("大哥"),TI18N("二哥"),TI18N("三哥"),TI18N("我"),TI18N("五弟"),TI18N("六弟"),TI18N("七弟"),TI18N("八弟"),TI18N("九弟"),TI18N("十弟")},
            {TI18N("大哥"),TI18N("二哥"),TI18N("三哥"),TI18N("四哥"),TI18N("我"),TI18N("六弟"),TI18N("七弟"),TI18N("八弟"),TI18N("九弟"),TI18N("十弟")},
            {TI18N("大哥"),TI18N("二哥"),TI18N("三哥"),TI18N("四哥"),TI18N("五哥"),TI18N("我"),TI18N("七弟"),TI18N("八弟"),TI18N("九弟"),TI18N("十弟")},
            {TI18N("大哥"),TI18N("二哥"),TI18N("三哥"),TI18N("四哥"),TI18N("五哥"),TI18N("六哥"),TI18N("我"),TI18N("八弟"),TI18N("九弟"),TI18N("十弟")},
            {TI18N("大哥"),TI18N("二哥"),TI18N("三哥"),TI18N("四哥"),TI18N("五哥"),TI18N("六哥"),TI18N("七哥"),TI18N("我"),TI18N("九弟"),TI18N("十弟")},
            {TI18N("大哥"),TI18N("二哥"),TI18N("三哥"),TI18N("四哥"),TI18N("五哥"),TI18N("六哥"),TI18N("七哥"),TI18N("八哥"),TI18N("我"),TI18N("十弟")},
            {TI18N("大哥"),TI18N("二哥"),TI18N("三哥"),TI18N("四哥"),TI18N("四哥"),TI18N("六哥"),TI18N("七哥"),TI18N("八哥"),TI18N("九哥"),TI18N("我")},
        },
        [0] = {
            {TI18N("我"),TI18N("二妹"),TI18N("三妹"),TI18N("四妹"),TI18N("五妹"),TI18N("六妹"),TI18N("七妹"),TI18N("八妹"),TI18N("九妹"),TI18N("十妹")},
            {TI18N("大姐"),TI18N("我"),TI18N("三妹"),TI18N("四妹"),TI18N("五妹"),TI18N("六妹"),TI18N("七妹"),TI18N("八妹"),TI18N("九妹"),TI18N("十妹")},
            {TI18N("大姐"),TI18N("二姐"),TI18N("我"),TI18N("四妹"),TI18N("五妹"),TI18N("六妹"),TI18N("七妹"),TI18N("八妹"),TI18N("九妹"),TI18N("十妹")},
            {TI18N("大姐"),TI18N("二姐"),TI18N("三姐"),TI18N("我"),TI18N("五妹"),TI18N("六妹"),TI18N("七妹"),TI18N("八妹"),TI18N("九妹"),TI18N("十妹")},
            {TI18N("大姐"),TI18N("二姐"),TI18N("三姐"),TI18N("四姐"),TI18N("我"),TI18N("六妹"),TI18N("七妹"),TI18N("八妹"),TI18N("九妹"),TI18N("十妹")},
            {TI18N("大姐"),TI18N("二姐"),TI18N("三姐"),TI18N("四姐"),TI18N("五姐"),TI18N("我"),TI18N("七妹"),TI18N("八妹"),TI18N("九妹"),TI18N("十妹")},
            {TI18N("大姐"),TI18N("二姐"),TI18N("三姐"),TI18N("四姐"),TI18N("五姐"),TI18N("六姐"),TI18N("我"),TI18N("八妹"),TI18N("九妹"),TI18N("十妹")},
            {TI18N("大姐"),TI18N("二姐"),TI18N("三姐"),TI18N("四姐"),TI18N("五姐"),TI18N("六姐"),TI18N("七姐"),TI18N("我"),TI18N("九妹"),TI18N("十妹")},
            {TI18N("大姐"),TI18N("二姐"),TI18N("三姐"),TI18N("四姐"),TI18N("五姐"),TI18N("六姐"),TI18N("七姐"),TI18N("八姐"),TI18N("我"),TI18N("十妹")},
            {TI18N("大姐"),TI18N("二姐"),TI18N("三姐"),TI18N("四姐"),TI18N("五姐"),TI18N("六姐"),TI18N("七姐"),TI18N("八姐"),TI18N("九姐"),TI18N("我")},
        }
    }

    self.skillData = {
        {id = 83010},
        {id = 83011},
        {lev = 1, max_lev = 120, name = TI18N("专属称号"), icon = 10001, type = 0, sub_type = 0, study_lev = 1, cost = {{90000,10}}, attr = {}, cooldown = 0, cost_mp = 15, dmg = "102%物攻", about = TI18N("结拜自定义称号"), locate = "单体攻击", desc = TI18N("结拜后可自定义<color='#ffff00'>专属结拜称号</color>，保持队型，威风凛凛！"), lev_desc = ""},
    }

    self:InitData()
end

function SwornModel:__delete()
end

function SwornModel:OpenProgressWindow(args)
    if self.progressWin == nil then
        self.progressWin = SwornProgressWindow.New(self)
    end
    self.progressWin:Open(args)
end

function SwornModel:OpenLeaveWindow(args)
    if self.leaveWin == nil then
        self.leaveWin = SwornLeaveWindow.New(args)
    end
    self.leaveWin:Open(args)
end

function SwornModel:InitData()
    self.myPos = 0
    self.votePos = 1
    self.selectFriendTab = {}
    self.menberTab = {}
    self.memberUidList = {}
    self.voteUid = nil
    self.swornData = nil
end

function SwornModel:ShowStatusIcon()
    if self.iconView == nil then
        self.iconView = SwornStatusIcon.New(self)
    end
    self.iconView:Show()
end

function SwornModel:HideStatusIcon()
    if self.iconView ~= nil then
        self.iconView:DeleteMe()
        self.iconView = nil
    end
end

function SwornModel:OpenDescWindow()
    if self.descWin == nil then
        self.descWin = SwornDescWindow.New(self)
    end
    self.descWin:Open()
end

function SwornModel:OpenInvite()
    if self.inviteWin == nil then
        self.inviteWin = SwornFriendChooseWindow.New(self)
    end
    self.inviteWin:Open()
end

function SwornModel:OpenGetout(args)
    if self.getoutWin == nil then
        self.getoutWin = SwornGetoutWindow.New(self)
    end
    self.getoutWin:Open(args)
end

function SwornModel:OpenReason(args)
    if self.reasonWin == nil then
        self.reasonWin = SwornReasonWindow.New(self)
    end
    self.reasonWin:Open(args)
end

function SwornModel:OpenVote(args)
    if self.voteWin == nil then
        self.voteWin = SwornInviteWindow.New(self)
    end
    self.voteWin:Open(args)
end

function SwornModel:OpenModify(args)
    if self.modifyWin == nil then
        self.modifyWin = SwornEditWindow.New(self)
    end
    self.modifyWin:Open(args)
end

function SwornModel:OpenConfirm()
    if self.confirmWin == nil then
        self.confirmWin = SwornConfirmWindow.New(self)
    end
    self.confirmWin:Open()
end

function SwornModel:PlayPlot()
    if self.plot == nil then
        self.plot = SwornPlot.New(self)
        self.plot:Start()
    end
end

function SwornModel:EndPlot()
    if self.plot ~= nil then
        self.plot:DeleteMe()
        self.plot = nil

        WindowManager.Instance:OpenWindowById(WindowConfig.WinID.sworn_confirm_window)
    end
end

function SwornModel:ReadyFire()
    EffectBrocastManager.Instance:On9907({id = 30075, type = 0, map = 0, x = 0, y = 0})
end

