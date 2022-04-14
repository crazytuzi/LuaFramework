require("game.rank.RequireRank")
RankController = RankController or class("RankController", BaseController)

function RankController:ctor()
    RankController.Instance = self
    self.model = RankModel:GetInstance()
    self:AddEvents()
    self:RegisterAllProtocal()
end

function RankController:dctor()
end

function RankController:GetInstance()
    if not RankController.Instance then
        RankController.new()
    end
    return RankController.Instance
end

function RankController:RegisterAllProtocal()
    self.pb_module_name = "pb_1003_rank_pb"

    self:RegisterProtocal(proto.RANK_LIST, self.HandleRankListInfo);   --榜单列表



end

function RankController:AddEvents()
    GlobalEvent:AddListener(RankEvent.OpenRankPanel, handler(self, self.HandleOpenRankPanel))

    local function call_back(data)
        lua_panelMgr:GetPanelOrCreate(UpShelfTowPanel):Open(data)
    end
    GlobalEvent:AddListener(MarketEvent.OpenUpShelfTowPanel, call_back)
end

function RankController:HandleOpenRankPanel()
    lua_panelMgr:GetPanelOrCreate(RankPanel):Open()
end

-- 请求榜单列表
function RankController:RequestRankListInfo(id,page)
    local pb = self:GetPbObject("m_rank_list_tos")
    pb.id = id
    pb.page = page
    self:WriteMsg(proto.RANK_LIST,pb)
end
--返回榜单列表
function RankController:HandleRankListInfo(data)
    local data = self:ReadMsg("m_rank_list_toc")
    GlobalEvent:Brocast(RankEvent.RankReturnList,data)
end





