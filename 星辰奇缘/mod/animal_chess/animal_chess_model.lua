-- @author 黄耀聪
-- @date 2017年4月27日

AnimalChessModel = AnimalChessModel or BaseClass(BaseModel)

function AnimalChessModel:__init()
    self.myCamp = nil     --先手 or 后手
    self.enemyInfo = {}
    self.myInfo = {}
    self.chessList = {}
    self.positionTab = {{}, {}, {}, {}, {}, {}}
    self.drawTab = {{}, {}}
    self.chessLastTab = nil
    self.chessInfoTab = {
            {{}, {}, {}, {}, {}, {}},
            {{}, {}, {}, {}, {}, {}},
            {{}, {}, {}, {}, {}, {}},
            {{}, {}, {}, {}, {}, {}},
            {{}, {}, {}, {}, {}, {}},
            {{}, {}, {}, {}, {}, {}}
        }

    self.boxModel = {modelId = 40065, skinId = 40065, animationId = 4006501, scale = 90}
end

function AnimalChessModel:__delete()
end

function AnimalChessModel:OpenMain(args)
    if self.mainPanel == nil then
        self.mainPanel = AnimalChessMain.New(self)
    end
    self.mainPanel:Show(args)
end

function AnimalChessModel:CloseMain()
    if self.mainPanel ~= nil then
        self.mainPanel:DeleteMe()
        self.mainPanel = nil
    end
end

function AnimalChessModel:OpenMatch(args)
    if self.matchWin == nil then
        self.matchWin = AnimalChessMatch.New(self)
    end
    self.matchWin:Open(args)
end

function AnimalChessModel:OpenSettlePanel(data)
    if self.settlepanel == nil then
        self.settlepanel = AnimalChessSettlePanel.New(self)
    end
    self.settlepanel:Open(data)
end

function AnimalChessModel:CloseSettlePanel()
    if self.settlepanel ~= nil then
        WindowManager.Instance:CloseWindow(self.settlepanel)
    end
end

function AnimalChessModel:Analyze(data)
    local roleData = RoleManager.Instance.RoleData
    self.round = data.round
    self.next_time_stemp = data.time
    self.next_move = data.next_move

    self.drawTab[1] = {}
    self.drawTab[2] = {}
    for _,v in ipairs(data.draw_list) do
        BaseUtils.covertab(self.drawTab[v.camp],v)
    end
    if data.role_id1 == roleData.id and data.zone_id1 == roleData.zone_id and data.platform1 == roleData.platform then
        self.myCamp = 1

        self.myInfo.id = data.role_id1
        self.myInfo.platform = data.platform1
        self.myInfo.zone_id = data.zone_id1
        self.myInfo.sex = data.first_sex
        self.myInfo.classes = data.first_classes
        self.myInfo.name = data.first_name
        self.myInfo.lev = data.first_lev
        self.myInfo.looks = {}
        for _,v in pairs(data.first_looks) do
            table.insert(self.myInfo.looks, {
                    looks_type = v.looks_type1,
                    looks_mode = v.looks_mode1,
                    looks_val = v.looks_val1,
                    looks_str = v.looks_str1,
                })
        end
        self.myInfo.grade = data.first_grade
        self.myInfo.score = data.first_score

        self.enemyInfo.id = data.role_id2
        self.enemyInfo.platform = data.platform2
        self.enemyInfo.zone_id = data.zone_id2
        self.enemyInfo.sex = data.second_sex
        self.enemyInfo.classes = data.second_classes
        self.enemyInfo.name = data.second_name
        self.enemyInfo.lev = data.second_lev
        self.enemyInfo.looks = {}
        for _,v in pairs(data.second_looks) do
            table.insert(self.enemyInfo.looks, {
                    looks_type = v.looks_type2,
                    looks_mode = v.looks_mode2,
                    looks_val = v.looks_val2,
                    looks_str = v.looks_str2,
                })
        end
        self.enemyInfo.grade = data.second_grade
        self.enemyInfo.score = data.second_score
    else
        self.myCamp = 2

        self.enemyInfo.id = data.role_id1
        self.enemyInfo.platform = data.platform1
        self.enemyInfo.zone_id = data.zone_id1
        self.enemyInfo.sex = data.first_sex
        self.enemyInfo.classes = data.first_classes
        self.enemyInfo.name = data.first_name
        self.enemyInfo.lev = data.first_lev
        self.enemyInfo.looks = data.first_looks
        self.enemyInfo.looks = {}
        for _,v in pairs(data.first_looks) do
            table.insert(self.enemyInfo.looks, {
                    looks_type = v.looks_type1,
                    looks_mode = v.looks_mode1,
                    looks_val = v.looks_val1,
                    looks_str = v.looks_str1,
                })
        end
        self.enemyInfo.grade = data.first_grade
        self.enemyInfo.score = data.first_score

        self.myInfo.id = data.role_id2
        self.myInfo.platform = data.platform2
        self.myInfo.zone_id = data.zone_id2
        self.myInfo.sex = data.second_sex
        self.myInfo.classes = data.second_classes
        self.myInfo.name = data.second_name
        self.myInfo.lev = data.second_lev
        self.myInfo.looks = {}
        for _,v in pairs(data.second_looks) do
            table.insert(self.myInfo.looks, {
                    looks_type = v.looks_type2,
                    looks_mode = v.looks_mode2,
                    looks_val = v.looks_val2,
                    looks_str = v.looks_str2,
                })
        end
        self.myInfo.grade = data.second_grade
        self.myInfo.score = data.second_score
    end

    local isReconnected = false
    if self.chessLastTab == nil then
        -- 断线重连
        isReconnected = true
        self.chessLastTab = {{{}, {}, {}, {}, {}, {}}, {{}, {}, {}, {}, {}, {}}, {{}, {}, {}, {}, {}, {}}, {{}, {}, {}, {}, {}, {}}, {{}, {}, {}, {}, {}, {}}, {{}, {}, {}, {}, {}, {}}}
    else
        for i=1,6 do
            for j=1,6 do
                 BaseUtils.covertab(self.chessLastTab[i][j], self.chessInfoTab[i][j])
            end
        end
    end

    for _,v in ipairs(data.chesses) do
        if v ~= nil then
            BaseUtils.covertab(self.chessInfoTab[v.x][v.y], v)
        end
    end

    if isReconnected == false then
        local changeList = {}
        for i=1,6 do
            for j=1,6 do
                if self.chessLastTab[i][j].status ~= self.chessInfoTab[i][j].status or self.chessLastTab[i][j].camp ~= self.chessInfoTab[i][j].camp then
                    table.insert(changeList, {i, j})
                end
            end
        end

        if #changeList == 1 then
            -- 开箱子操作
            if AnimalChessManager.Instance.simulate then
                NoticeManager.Instance:FloatTipsByString("开箱子了！")
            end
            AnimalChessManager.Instance.onChessEvent:Fire(AnimalChessEumn.OperateType.Open, changeList[1])
        elseif #changeList == 2 then
            if self.chessLastTab[changeList[1][1]][changeList[1][2]].status ~= AnimalChessEumn.SlotStatus.Empty and self.chessLastTab[changeList[2][1]][changeList[2][2]].status ~= AnimalChessEumn.SlotStatus.Empty then
                -- 攻击
                if AnimalChessManager.Instance.simulate then
                    NoticeManager.Instance:FloatTipsByString("进攻！")
                end
                if self.chessInfoTab[changeList[1][1]][changeList[1][2]].status == AnimalChessEumn.SlotStatus.Empty then
                    AnimalChessManager.Instance.onChessEvent:Fire(AnimalChessEumn.OperateType.Attack, changeList[1], changeList[2])
                else
                    AnimalChessManager.Instance.onChessEvent:Fire(AnimalChessEumn.OperateType.Attack, changeList[2], changeList[1])
                end
            else
                -- 移动
                if AnimalChessManager.Instance.simulate then
                    NoticeManager.Instance:FloatTipsByString("我跑！")
                end
                if self.chessInfoTab[changeList[1][1]][changeList[1][2]].status == AnimalChessEumn.SlotStatus.Empty then
                    AnimalChessManager.Instance.onChessEvent:Fire(AnimalChessEumn.OperateType.Move, changeList[1], changeList[2])
                else
                    AnimalChessManager.Instance.onChessEvent:Fire(AnimalChessEumn.OperateType.Move, changeList[2], changeList[1])
                end
            end
        end
    else
        -- 刷新
        AnimalChessManager.Instance.onChessEvent:Fire()
    end
end

function AnimalChessModel:OpenIconView()
    if self.iconView == nil then
        self.iconView = AnimalChessIconView.New(self)
    end
    self.iconView:Show()
end

function AnimalChessModel:OpenOperation()
    if self.operation == nil then
        self.operation = AnimalChessOperation.New(self)
    end
    self.operation:Show()
end
