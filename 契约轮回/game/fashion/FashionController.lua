-- @Author: lwj
-- @Date:   2018-12-26 15:44:11
-- @Last Modified time: 2019-11-16 16:02:35

require('game.fashion.RequireFashion')
FashionController = FashionController or class("FashionController", BaseController)
local FashionController = FashionController

function FashionController:ctor()
    FashionController.Instance = self
    self.model = FashionModel:GetInstance()
    self.model_event = {}
    self.global_event = {}
    self:AddEvents()
    self:RegisterAllProtocal()
end

function FashionController:dctor()
    if not table.isempty(self.model_event) then
        for i, v in pairs(self.model_event) do
            self.model:RemoveListener(v)
        end
        self.model_event = {}
    end
    if not table.isempty(self.global_event) then
        for i, v in pairs(self.global_event) do
            GlobalEvent:RemoveListener(v)
        end
        self.global_event = {}
    end
end

function FashionController:GetInstance()
    if not FashionController.Instance then
        FashionController.new()
    end
    return FashionController.Instance
end

function FashionController:RegisterAllProtocal()
    -- protobuff的模块名字，用到pb一定要写
    self.pb_module_name = "pb_1120_fashion_pb"
    self:RegisterProtocal(proto.FASHION_INFO, self.HandleInfoList)
    --self:RegisterProtocal(proto.FASHION_PUTOFF, self.HandlePutOff)
end

function FashionController:AddEvents()
    -- --请求基本信息
    local function callback(idx, fashion_id)
        self.model.is_open_panel = true
        self:RequestInfoList(idx, fashion_id)
    end
    self.global_event[#self.global_event + 1] = GlobalEvent:AddListener(FashionEvent.OpenFashionPanel, callback)
    self.global_event[#self.global_event + 1] = GlobalEvent:AddListener(BagEvent.UpdateGoods, handler(self, self.CheckRedDot))
    --self.global_event[#self.global_event + 1] = GlobalEvent:AddListener(GoodsEvent.DelItems, handler(self, self.CheckRedDot))
    --self.global_event[#self.global_event + 1] = GlobalEvent:AddListener(GoodsEvent.UpdateNum, handler(self, self.CheckRedDot))
    local function callback(side_idx, sel_id)
        local lv = RoleInfoModel.GetInstance():GetMainRoleLevel()
        if lv < 90 then
            return
        end

        side_idx = side_idx or 1
        lua_panelMgr:GetPanelOrCreate(DecoratePanel):Open(side_idx, sel_id)
    end
    self.global_event[#self.global_event + 1] = GlobalEvent:AddListener(FashionEvent.OpenDecoPanel, callback)

    self.model_event[#self.model_event + 1] = self.model:AddListener(FashionEvent.ActivateFashion, handler(self, self.RequestFashionActivate))
    self.model_event[#self.model_event + 1] = self.model:AddListener(FashionEvent.UpStarFashion, handler(self, self.RequestFashionUpStar))
    self.model_event[#self.model_event + 1] = self.model:AddListener(FashionEvent.PutOnFashion, handler(self, self.RequestFashionPutOn))
    self.model_event[#self.model_event + 1] = self.model:AddListener(FashionEvent.PutOff, handler(self, self.RequesetPutOff))
end

-- overwrite
function FashionController:GameStart()
    local function step()
        self:RequestInfoList()
    end
    GlobalSchedule:StartOnce(step, 2)
end

function FashionController:RequestInfoList(index, id)
    if self.model.is_openning_fashion_panel then
        self.model:Brocast(FashionEvent.CloseFashionPanel)
    end
    if index then
        self.model.side_index = index
    end
    if id then
        self.model.default_sel_id = id
        self.model.curItemId = id
    end
    self:WriteMsg(proto.FASHION_INFO)
end

function FashionController:HandleInfoList()
    local data = self:ReadMsg("m_fashion_info_toc")
    self.model:AddInfo(data)

    if self.model.isCanShowTips == true then
        local tips = ""
        local btnMode = self.model:GetNormalBtnMode()
        if btnMode == 0 then
            tips = ConfigLanguage.Fashion.SuccessActivate
            self.model:RemoveRedDotFromList()
        elseif btnMode == 1 then
            tips = ConfigLanguage.Fashion.SuccessUpStar
            self.model:RemoveRedDotFromList()
        elseif btnMode == 2 then
            tips = ConfigLanguage.Fashion.SuccessChange
        end
        Notify.ShowText(tips)
        self.model.isCanShowTips = false
    end
    if self.model.is_need_update_role_icon then
        if self.model.openning_index == 11 then
            --头像框
            local data_frame_id = data.puton_id[11]
            RoleInfoModel.GetInstance():GetMainRoleData().icon.frame = data_frame_id
            GlobalEvent:Brocast(RoleInfoEvent.UpdateRoleIconFrame, data_frame_id)
        else
            --气泡
            local data_bubble_id = data.puton_id[12]
            RoleInfoModel.GetInstance():GetMainRoleData().icon.frame = data_bubble_id
            GlobalEvent:Brocast(ChatEvent.UpdateChatFrame, data_bubble_id)
        end
        self.model.is_need_update_role_icon = false
    end
    self:CheckRedDot()
    if self.model.isGameStart then
        self.model.isGameStart = false
        self.model.is_can_click_activa = true
        self.model.is_can_click_dress = true
        return
    end
    if self.model.is_open_panel then
        lua_panelMgr:GetPanelOrCreate(FashionPanel):Open()
        self.model.is_open_panel = false
    end
    self.model.is_can_click_activa = true
    self.model.is_can_click_dress = true
    self.model:Brocast(FashionEvent.UpdatePanel)
end

function FashionController:RequestFashionActivate(id)
    local pb = self:GetPbObject("m_fashion_active_tos")
    pb.id = id or self.model.curItemId
    self:WriteMsg(proto.FASHION_ACTIVE, pb)
end

function FashionController:RequestFashionUpStar(id)
    local pb = self:GetPbObject("m_fashion_upstar_tos")
    pb.id = id or self.model.curItemId
    self:WriteMsg(proto.FASHION_UPSTAR, pb)
end

function FashionController:RequestFashionPutOn(id)
    local pb = self:GetPbObject("m_fashion_puton_tos")
    pb.id = id or self.model.curItemId
    self:WriteMsg(proto.FASHION_PUTON, pb)
end

function FashionController:CheckRedDot()
    local cf = Config.db_fashion_type
    --local len = #cf
    local is_show_rd = false
    local is_show_deco_rd = false
    for index, _ in pairs(cf) do
        local list = self.model:GetCueShowList(index)
        for ii = 1, #list do
            local is_add = false
            local tbl = clone(list[ii])
            if type(tbl) == "number" then
                list[ii] = { tbl }
            end
            local first = list[ii][1]
            local key = first .. "@" .. index
            local cf_info = Config.db_fashion[key]
         
            if cf_info.cost ~= "" then
                local cost_tbl = String2Table(cf_info.cost)
                local fItem = self.model:GetFashionInfoById(cost_tbl[1])
                if fItem then
                    --已激活
                    --可以升星
                    local star_max = Config.db_fashion_star[first .. "@" .. fItem.star].starmax
                    
                    if self.model:CheckIsCanUpStar(list[ii][1]) and star_max == 0 then
                        is_add = true
                    end
                else
                    local have_num = BagModel.GetInstance():GetItemNumByItemID(cost_tbl[1])
                    if have_num >= cost_tbl[2] then
                        is_add = true
                    end
                end
                if is_add then
                    self.model:AddRedDotToList(index, list[ii][1])
					if index <= 3 or index==5 then
                        is_show_rd = true
                    else
                        is_show_deco_rd = true
                    end
                else
                    self.model:RemoveRedDotFromList(index, list[ii][1])
                end
            end
        end
    end
    GlobalEvent:Brocast(MainEvent.ChangeSystemShowInStronger, 18, is_show_rd)
end

--function FashionController:RequesetPutOff(id)
--    local pb = self:GetPbObject("m_fashion_putoff_tos")
--    pb.id = id
--    self:WriteMsg(proto.FASHION_PUTOFF, pb)
--end

--function FashionController:HandlePutOff()
--    local data = self:ReadMsg("m_fashion_putoff_toc")
--    dump(data, "<color=#6ce19b>FashionController,HandlePutOff   FashionController,HandlePutOff  FashionController,HandlePutOff  FashionController,HandlePutOff</color>")
--
--    Notify.ShowText("卸下成功")
--end