-- @author hze
-- @date 2018/06/07

DragonPhoenixChessModel = DragonPhoenixChessModel or BaseClass(BaseModel)

function DragonPhoenixChessModel:__init()
	    self.mainPanel = nil
        self.matchWin = nil
        self.iconView = nil
        self.settlepanel = nil
        self.descpanel = nil 

        self.enemyInfo = {}
        self.myInfo = {}

	    self.chessInfoTab = {
            {{}, {}, {}, {}, {}, {}, {}, {}},
            {{}, {}, {}, {}, {}, {}, {}, {}},
            {{}, {}, {}, {}, {}, {}, {}, {}},
            {{}, {}, {}, {}, {}, {}, {}, {}},
            {{}, {}, {}, {}, {}, {}, {}, {}},
            {{}, {}, {}, {}, {}, {}, {}, {}},
            {{}, {}, {}, {}, {}, {}, {}, {}},
            {{}, {}, {}, {}, {}, {}, {}, {}},
        }

        self.last_round = nil 
end

function DragonPhoenixChessModel:__delete()
    if self.mainPanel ~= nil then 
        self.mainPanel:DeleteMe()
        self.mainPanel = nil 
    end

    if self.matchWin ~= nil then 
        self.matchWin:DeleteMe()
        self.matchWin = nil 
    end

    if self.iconView ~= nil then 
        self.iconView:DeleteMe()
        self.iconView = nil 
    end

    if self.settlepanel ~= nil then 
        self.settlepanel:DeleteMe()
        self.settlepanel = nil 
    end

    if self.descpanel ~= nil then 
        self.descpanel:DeleteMe()
        self.descpanel = nil 
    end
end

--龙凤棋主界面
function DragonPhoenixChessModel:OpenMain(args)
	if self.mainPanel == nil then
        self.mainPanel = DragonPhoenixChessMain.New(self)
    end
    self.mainPanel:Show(args)
end

function DragonPhoenixChessModel:CloseMain()
    if self.mainPanel ~= nil then
        self.mainPanel:DeleteMe()
        self.mainPanel = nil
    end
end

--匹配界面
function DragonPhoenixChessModel:OpenMatch(args)
    if self.matchWin == nil then
        self.matchWin = DragonChessMatch.New(self)
    end
    self.matchWin:Open(args)
end

function DragonPhoenixChessModel:OpenSettlePanel(data)
    if self.settlepanel == nil then
        self.settlepanel = DragonChessSettlePanel.New(self)
    end
    self.settlepanel:Open(data)
end

function DragonPhoenixChessModel:CloseSettlePanel()
    if self.settlepanel ~= nil then
        WindowManager.Instance:CloseWindow(self.settlepanel)
    end

    self:CloseMain()
end

function DragonPhoenixChessModel:OpenDescPanel()
    if self.descpanel == nil then
        self.descpanel = DragonChessDescPanel.New(self)
    end
    self.descpanel:Open()
end

function DragonPhoenixChessModel:CloseDescPanel()
    if self.descpanel ~= nil then
        self.descpanel:DeleteMe()
        self.descpanel = nil
    end
end

function DragonPhoenixChessModel:AnalyzeChessRole(data)
    --这数据格式是真的难受
    local roleData = RoleManager.Instance.RoleData
    self.myInfo.sex = roleData.sex
    self.myInfo.classes = roleData.classes
    self.myInfo.name = roleData.name
    self.myInfo.lev = roleData.lev
    self.myInfo.grade = data.self_grade
    self.myInfo.camp = data.self_color
    self.myInfo.looks = {}

    local mySceneData = SceneManager.Instance:MyData()
    if mySceneData ~= nil then
        for _,v in pairs(mySceneData.looks) do
          table.insert(self.myInfo.looks, {
                      looks_type = v.looks_type,
                      looks_mode = v.looks_mode,
                      looks_val = v.looks_val,
                      looks_str = v.looks_str,
                  })
        end
    end

    self.enemyInfo.sex = data.sex
    self.enemyInfo.classes = data.classes
    self.enemyInfo.name = data.name
    self.enemyInfo.lev = data.lev
    self.enemyInfo.grade = data.grade
    self.enemyInfo.camp = 3 - data.self_color
    self.enemyInfo.looks = {}
    for _,v in pairs(data.ops_looks) do
      table.insert(self.enemyInfo.looks, {
                  looks_type = v.looks_type,
                  looks_mode = v.looks_mode,
                  looks_val = v.looks_val,
                  looks_str = v.looks_str,
              })
    end

    self.chessType = data.self_color     --当前玩家所拿棋类型
end

function DragonPhoenixChessModel:AnalyzeChessBoard(data)
	self.who_turn = data.who_turn        --当前谁下
	self.next_time_step = data.end_time  --这个回合结束时间
	self.round = data.now_turn           --回合数
    self.playing = self.who_turn == self.chessType  --是否处于下棋状态

    --棋盘初始化
	for i = 1,8 do
	    for j = 1,8 do
	    	self.chessInfoTab[i][j] = 0
	    end
	end

    --棋盘龙凤棋子信息
	for _,v in ipairs(data.chess_list) do
        if v ~= nil then
            self.chessInfoTab[v.row][v.col] = v.color
        end
    end

    --棋盘可下位置信息
    self.no_free = true         --棋子无可下位置
    for _,v in ipairs(data.can_use_list) do
		if v ~= nil then
            self.no_free  = false
			self.chessInfoTab[v.row][v.col] = 3
		end
    end

    --棋盘变化位置信息
    self.chess_change_list = BaseUtils.copytab(data.chess_change_list)


    --统计棋盘龙凤棋子个数
    local dragon_count = 0
    local phoenix_count = 0

    for _,v in ipairs(self.chessInfoTab) do
        for __,vv in ipairs(v) do
    	    if vv == 1 then
                phoenix_count = phoenix_count + 1
            elseif vv == 2 then
                dragon_count = dragon_count + 1
            end
        end
    end

      --最后一回合不算无子可下
    -- if self.round == 60 then 
    if dragon_count + phoenix_count == 64 then
        self.no_free = false
    end  


    --当前为凤棋
    if self.chessType == 1 then
		self.myInfo.chess_count = phoenix_count
		self.enemyInfo.chess_count = dragon_count

        self.myInfo.backleadround = data.black_keep_ahead_round
        self.enemyInfo.backleadround = data.white_keep_ahead_round
    else
		self.myInfo.chess_count = dragon_count
		self.enemyInfo.chess_count = phoenix_count

        self.myInfo.backleadround = data.white_keep_ahead_round
        self.enemyInfo.backleadround = data.black_keep_ahead_round
    end

    --是否触发反超特效
    self.is_comeback = data.is_comeback

    --得到当前荣誉
    self.achievehonor = self:AchieveHonor()
end

function DragonPhoenixChessModel:OpenIconView()
    if self.iconView == nil then
        self.iconView = DragonChessIconView.New(self)
    end
    self.iconView:Show()
end


function DragonPhoenixChessModel:BrokenReconnection()
    local reconnection = false
    if self.last_round == self.round then
        reconnection = true
    else
        self.last_round = self.round
    end
    return reconnection
end

function DragonPhoenixChessModel:AchieveHonor()
    local honor = 0 
    
    --一次翻转超过5颗棋子
    if #self.chess_change_list > 5 then honor = 1 end
    --一次翻转超过8颗棋子
    if #self.chess_change_list > 8 then honor = 2 end
    --比分连续领先对方5回合/7回合（包括对方的回合在内）
    if self.myInfo.backleadround == 5 or self.myInfo.backleadround == 7 then honor = 3 end
    --比分连续领先对方11回合（包括对方的回合在内）
    if self.myInfo.backleadround == 11 then honor = 4 end
    --是否触发反超特效
    if self.is_comeback == 1 then honor = 5 end

    return honor
end


function DragonPhoenixChessModel:ShowMainView(st)
    if MainUIManager.Instance.mapInfoView ~= nil and not BaseUtils.isnull(MainUIManager.Instance.mapInfoView.gameObject) then
        MainUIManager.Instance.mapInfoView.gameObject:SetActive(st)
    end
    if MainUIManager.Instance.roleInfoView ~= nil and not BaseUtils.isnull(MainUIManager.Instance.roleInfoView.gameObject) then
        MainUIManager.Instance.roleInfoView.gameObject:SetActive(st)
    end
    if MainUIManager.Instance.petInfoView ~= nil and not BaseUtils.isnull(MainUIManager.Instance.petInfoView.gameObject) then
        MainUIManager.Instance.petInfoView.gameObject:SetActive(st)
    end
    if MainUIManager.Instance.MainUIIconView ~= nil and not BaseUtils.isnull(MainUIManager.Instance.MainUIIconView.gameObject) then
        MainUIManager.Instance.MainUIIconView.gameObject:SetActive(st)
    end
    if ChatManager.Instance.model.chatMini ~= nil and not BaseUtils.isnull(ChatManager.Instance.model.chatMini.gameObject) then
        ChatManager.Instance.model.chatMini.gameObject:SetActive(st)
    end
    if MainUIManager.Instance.noticeView ~= nil and not BaseUtils.isnull(MainUIManager.Instance.noticeView.gameObject) then
        MainUIManager.Instance.noticeView.gameObject:SetActive(st)
    end
    if MainUIManager.Instance.playerInfoView ~= nil and not BaseUtils.isnull(MainUIManager.Instance.playerInfoView.gameObject) then
        MainUIManager.Instance.playerInfoView.gameObject:SetActive(st)
    end

    if ChatManager.Instance.model.chatWindow ~= nil and not BaseUtils.isnull(ChatManager.Instance.model.chatWindow.gameObject) then
        ChatManager.Instance.model.chatWindow.gameObject:GetComponent(Canvas).overrideSorting = not st
    end

    if st then MainUIManager.Instance:HideSelectIcon() end
end