-- @Author: lwj
-- @Date:   2018-12-16 19:34:26
-- @Last Modified time: 2018-12-16 19:34:39

require("game.title.RequireTitle")
TitleController = TitleController or class("TitleController", BaseController)
local TitleController = TitleController

function TitleController:ctor()
    TitleController.Instance = self
    self.model = TitleModel:GetInstance()
    self:AddEvents()
    self:RegisterAllProtocal()
end

function TitleController:dctor()
end

function TitleController:GetInstance()
    if not TitleController.Instance then
        TitleController.new()
    end
    return TitleController.Instance
end

function TitleController:RegisterAllProtocal()
    -- protobuff的模块名字，用到pb一定要写
    self.pb_module_name = "pb_1121_title_pb"
    self:RegisterProtocal(proto.TITLE_INFO, self.HandleTitleInfo)
    self:RegisterProtocal(proto.TITLE_PUTON, self.HandlePutOnTitle)
    self:RegisterProtocal(proto.TITLE_PUTOFF, self.HandlePutOffTitle)
end

function TitleController:AddEvents()
    self.model:AddListener(TitleEvent.PutOnTitle, handler(self, self.RequestPutOnTitle))
    self.model:AddListener(TitleEvent.PutOffTitle, handler(self, self.RequestPutOffTitle))
    self.model:AddListener(TitleEvent.ActivateTitle, handler(self, self.RequestActivateTitle))
    GlobalEvent:AddListener(TitleEvent.OpenTitlePanel, handler(self, self.RequestTitleInfo))
    GlobalEvent:AddListener(BagEvent.AddItems, handler(self, self.CheckRedDotExist))
    GlobalEvent:AddListener(GoodsEvent.DelItems, handler(self, self.CheckRedDotExist))
    GlobalEvent:AddListener(GoodsEvent.UpdateNum, handler(self, self.CheckRedDotExist))
end


-- overwrite
function TitleController:GameStart()
    local function step()
        self.model.is_open_panel = false
        self:RequestTitleInfo()
    end
    GlobalSchedule:StartOnce(step, Constant.GameStartReqLevel.Low)
end

function TitleController:CheckRedDotExist()
    local list = Config.db_title_menu
    local is_show = false
    for menu_id = 1, #list do
        local tbl = String2Table(list[menu_id].sub_id)
        for index = 1, #tbl do
            local id = tbl[index][1]
            local p_title = self.model:GetPTitleBySunId(id)
            if not p_title then
                --可激活
                local num = BagModel.GetInstance():GetItemNumByItemID(id)
                if num > 0 then
                    is_show = true
                    break
                end
            end
        end
    end
    GlobalEvent:Brocast(FashionEvent.ChangeSideRedDot, is_show, true)
    --在有 对应变强中的 需求的 红点的时候，广播一下这个事件，id:       db_stronger中的id,
    --                                                    is_show:  是否有db_stronger中的红点需求
    GlobalEvent:Brocast(MainEvent.ChangeSystemShowInStronger, 12, is_show)
    self.model.is_show_title_red = is_show
    if not is_show then
        if FashionModel.GetInstance().isShowRedInMain then
            return
        end
    end
    GlobalEvent:Brocast(MainEvent.ChangeRedDot, "fashion", is_show)
end

function TitleController:RequestTitleInfo()
    self:WriteMsg(proto.TITLE_INFO)
end

function TitleController:HandleTitleInfo()
    local data = self:ReadMsg("m_title_info_toc")
    if not self.model.is_open_panel then
        self.model.is_open_panel = true
        self.model.titleInfoList = data
        self:CheckRedDotExist()
        return
    end
    if self.model.curInfoListMode == 1 then
        self.model:AddSingleInfoToList(data.titles[self.model.curSub_id], data.puton_id)
        self:CheckRedDotExist()
    elseif self.model.curInfoListMode == 0 then
        self.model.titleInfoList = data
    elseif self.model.curInfoListMode == 2 then
        self.model.titleInfoList.puton_id = data.puton_id
    end
    self.model:CheckTitleExist()
    self.model:Brocast(TitleEvent.UpdateTitleInfoLIst)
    self.model.curInfoListMode = 0
    GlobalEvent:Brocast(TitleEvent.UpdateTitlePuton, self.model.titleInfoList.puton_id)
end

function TitleController:RequestPutOnTitle()
    local pb = self:GetPbObject("m_title_puton_tos")
    pb.id = self.model.curSub_id
    self:WriteMsg(proto.TITLE_PUTON, pb)
end

function TitleController:HandlePutOnTitle()
    local data = self:ReadMsg("m_title_puton_toc")
end

function TitleController:RequestPutOffTitle()
    local pb = self:GetPbObject("m_title_putoff_tos")
    pb.id = self.model.curSub_id
    self:WriteMsg(proto.TITLE_PUTOFF, pb)
end

function TitleController:HandlePutOffTitle()
    local data = self:ReadMsg("m_title_putoff_toc")
end

function TitleController:RequestActivateTitle(sel_title)
    local title = sel_title or self.model.curSub_id
    local pb = self:GetPbObject("m_title_active_tos")
    pb.id = title
    self:WriteMsg(proto.TITLE_ACTIVE, pb)
end

