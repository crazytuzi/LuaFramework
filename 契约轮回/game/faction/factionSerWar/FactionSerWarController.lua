---
--- Created by  Administrator
--- DateTime: 2020/5/14 13:58
---
FactionSerWarController = FactionSerWarController or class("FactionSerWarController", BaseController)
local FactionSerWarController = FactionSerWarController

require('game.faction.factionSerWar.RequireFactionSerWar')
function FactionSerWarController:ctor()
    FactionSerWarController.Instance = self
    self.model = FactionSerWarModel:GetInstance()
    self.events = {}
    self:AddEvents()
    self:RegisterAllProtocol()
end

function FactionSerWarController:dctor()
    GlobalEvent:RemoveTabListener(self.events)
end

function FactionSerWarController:GetInstance()
    if not FactionSerWarController.Instance then
        FactionSerWarController.new()
    end
    return FactionSerWarController.Instance
end

function FactionSerWarController:AddEvents()


    local function call_back(isShow,id)

        --if isShow and id == 12002 then --预约
        --    self.model:CheckRedPoint()
        --end

        if self.model:IsFactionSerMap() then
            return
        end
        local roleInfo = RoleInfoModel.GetInstance():GetMainRoleData()
        if roleInfo.guild and tostring(roleInfo.guild) == "0" then
            return
        end

        if id == 12003 and isShow and self.model.my_rank ~= 0 then --周对决开启
            local function call_back()
                SceneControler:GetInstance():RequestSceneChange(81000, enum.SCENE_CHANGE.SCENE_CHANGE_ACT, nil, nil, 12003);
            end
            Dialog.ShowTwo(FactionSerWarModel.desTab.Tips, FactionSerWarModel.desTab.open, FactionSerWarModel.desTab.ok, call_back, nil, FactionSerWarModel.desTab.center, nil, nil)
        end
    end
    GlobalEvent:AddListener(ActivityEvent.ChangeActivity,call_back)

    local function call_back()
        SceneControler:GetInstance():RequestSceneChange(81000, enum.SCENE_CHANGE.SCENE_CHANGE_ACT, nil, nil, 12003);
    end
    GlobalEvent:AddListener(FactionSerWarEvent.EnterDungeon, call_back)
    
    local function call_back()
        lua_panelMgr:GetPanelOrCreate(FactionPanel):Open(5, 3);
    end
    GlobalEvent:AddListener(FactionSerWarEvent.OpenFactionSerWarPanel, call_back)
end

function FactionSerWarController:RegisterAllProtocol()
    ---[[protobuff的模块名字，用到pb一定要写]]
    self.pb_module_name = "pb_1611_cross_guildwar_pb"
    self:RegisterProtocal(proto.CGW_PANEL, self.HandleMainPanelInfo);
    self:RegisterProtocal(proto.CGW_GUILDS, self.HandleGuildsInfo);
    self:RegisterProtocal(proto.CGW_BOOK, self.HandleBookInfo);
    self:RegisterProtocal(proto.CGW_RANKING, self.HandleRankInfo);
    self:RegisterProtocal(proto.CGW_MATCH, self.HandleMatchInfo);

    self:RegisterProtocal(proto.CGW_RESULT, self.HandleResultInfo);



end

-- overwrite
function FactionSerWarController:GameStart()
    local function step()
        self:RequstGuildsInfo()
    end
    GlobalSchedule:StartOnce(step, Constant.GameStartReqLevel.Super)
end



function FactionSerWarController:RequstMainPanelInfo()
    local pb = self:GetPbObject("m_cgw_panel_tos")
    --local data =
    --{
    --    period = 2
    --}
    --self.model:SetPeriod(data)
    --self.model:Brocast(FactionSerWarEvent.MainPanelInfo,data)
    self:WriteMsg(proto.CGW_PANEL,pb)
end


function FactionSerWarController:HandleMainPanelInfo()
    local data = self:ReadMsg("m_cgw_panel_toc")
    --logError("当前阶段：",data.period)
    self.model:SetPeriod(data)
    self.model:Brocast(FactionSerWarEvent.MainPanelInfo,data)
end

function FactionSerWarController:RequstGuildsInfo()
    local pb = self:GetPbObject("m_cgw_guilds_tos")
    --local data =
    --{
    --    guilds = {
    --        {id = 123,name = "uudy",chief = "asfg",score = 5000,book = 5151},
    --        {id = 5151,name = "42",chief = "114",score = 5000,book = 0},
    --        {id = 123,name = "yyy3",chief = "12456",score = 200,book = 0},
    --        {id = 3123,name = "asdfg",chief = "1234",score = 21,book = 123},
    --        {id = 14555,name = "sdghgh",chief = "123sdfsdf4",score = 1221,book = 0}
    --    },
    --    my_rank = 2,
    --    my_score = 2000,
    --    booktimes = 3,
    --}
    --self.model:DealGuildsInfo(data.guilds)
    --self.model.booktimes = data.booktimes
    --self.model.my_scroe = data.my_score
    --self.model:Brocast(FactionSerWarEvent.GuildsInfo,data)

    self:WriteMsg(proto.CGW_GUILDS,pb)
end

function FactionSerWarController:HandleGuildsInfo()
    local data = self:ReadMsg("m_cgw_guilds_toc")
    self.model:DealGuildsInfo(data.guilds)
    self.model.booktimes = data.booktimes
    self.model.my_scroe = data.my_score
    self.model.my_rank = data.my_rank
    self.model.my_book = data.my_book
    self.model:CheckRedPoint()
    self.model:Brocast(FactionSerWarEvent.GuildsInfo,data)
end



function FactionSerWarController:RequstBookInfo(guild_id)
    local pb = self:GetPbObject("m_cgw_book_tos")
    pb.guild_id = guild_id

    --self.model.booktimes = self.model.booktimes - 1
    --local data = {}
    --data.guild_id = guild_id
    --self.model:Brocast(FactionSerWarEvent.BookInfo,data)

    self:WriteMsg(proto.CGW_BOOK,pb)
end


function FactionSerWarController:HandleBookInfo()
    --logError("预约成功")
    local data = self:ReadMsg("m_cgw_book_toc")
    self.model.booktimes = self.model.booktimes + 1
    self.model:SetGuildsIsBook(data.guild_id)
    self.model.my_book = data.guild_id
    self.model:CheckRedPoint()
    self.model:Brocast(FactionSerWarEvent.BookInfo,data)
end

function FactionSerWarController:RequstRankInfo()
    local pb = self:GetPbObject("m_cgw_ranking_tos")
    --local data = {}
    --data.ranking =
    --{
    --    {id = 123,name = "uudy1",chief = "asfg1",score = 5000,rank = 1},
    --    {id = 1243,name = "uudy2",chief = "asfg2",score = 5000,rank = 2},
    --    {id = 1123,name = "uudy3",chief = "asfg3",score = 5000,rank = 3},
    --    {id = 124,name = "uudy4",chief = "asfg4",score = 5000,rank = 4},
    --    {id = 1445,name = "uudy5",chief = "asfg5",score = 5000,rank = 5},
    --    {id = 234411,name = "uudy6",chief = "asfg6",score = 5000,rank = 6},
    --    {id = 2,name = "uudy7",chief = "asfg7",score = 5000,rank = 7},
    --}
    --
    --
    --self.model:Brocast(FactionSerWarEvent.RankInfo,data)

    self:WriteMsg(proto.CGW_RANKING,pb)
end

function FactionSerWarController:HandleRankInfo()
    local data = self:ReadMsg("m_cgw_ranking_toc")
    self.model.ranking = data.ranking
    self.model:Brocast(FactionSerWarEvent.RankInfo,data)
end



function FactionSerWarController:RequstMatchInfo()
    local pb = self:GetPbObject("m_cgw_match_tos")
    --local data = {}
    --data.round1 =
    --{
    --    {atk_id = 1234124,atk_name = "123",def_id = 5451154,def_name = "1233",winner = 0},
    --    {atk_id = 1234125,atk_name = "124",def_id = 5451154,def_name = "1234",winner = 1234125},
    --    {atk_id = 1234126,atk_name = "125",def_id = 5451154,def_name = "1235",winner = 1234126},
    --    {atk_id = 1234127,atk_name = "126",def_id = 5451154,def_name = "1236",winner = 5451154},
    --}
    --data.round2 =
    --{
    --    {atk_id = 2234124,atk_name = "223",def_id = 2451154,def_name = "2233",winner = 0},
    --    {atk_id = 2234125,atk_name = "224",def_id = 2451154,def_name = "2234",winner = 2451154},
    --    {atk_id = 2234126,atk_name = "225",def_id = 2451154,def_name = "2235",winner = 2234126},
    --    {atk_id = 2234127,atk_name = "226",def_id = 2451154,def_name = "2236",winner = 2234127},
    --}
    --
    --self.model:Brocast(FactionSerWarEvent.MatchInfo,data)
    self:WriteMsg(proto.CGW_MATCH,pb)
end

function FactionSerWarController:HandleMatchInfo()
    local data = self:ReadMsg("m_cgw_match_toc")
    self.model:Brocast(FactionSerWarEvent.MatchInfo,data)
end

function FactionSerWarController:HandleResultInfo()
    local data = self:ReadMsg("m_cgw_result_toc")
    lua_panelMgr:GetPanelOrCreate(FactionSerWardDungeEndPanel):Open(data.result)
   -- self.model:Brocast(FactionSerWarEvent.MatchInfo,data)
end











