---
---Author: wry
---Date: 2019/9/16 17:48:10
---
require('game.stigmata.RequireStigmata')
StigmataController = StigmataController or class('StigmataController', BaseController)
local this = StigmataController

function StigmataController:ctor()
    StigmataController.Instance = self
    self:RegisterAllProtocal()
    self.model = StigmataModel.GetInstance()

    self.loadItemsEvent = nil

    --自动分解圣痕设置
    self.setSoulDecomposeData = nil
    self.isOpenSellPanel = false
end

function StigmataController:dctor()
    self.setSoulDecomposeData = nil
end

function StigmataController:GetInstance()
    if StigmataController.Instance == nil then
        StigmataController.new()
    end
    return StigmataController.Instance
end

function StigmataController:RegisterAllProtocal()

    -- protobuff的模块名字，用到pb一定要写
    self.pb_module_name = "pb_1140_soul_pb"
    --圣痕卡槽信息
    self:RegisterProtocal(proto.SOUL_LIST,          self.HandleSoulList)
    --装备圣痕
    self:RegisterProtocal(proto.SOUL_PUTON,         self.HandleSoulPutOn)
    --取下圣痕
    self:RegisterProtocal(proto.SOUL_PUTOFF,        self.HandleSoulPutOff)
    --升级圣痕
    self:RegisterProtocal(proto.SOUL_UPLEVEL,       self.HandleSoulUpLevel)
    --分解圣痕
    self:RegisterProtocal(proto.SOUL_DECOMPOSE,     self.HandleSoulDecompose)
    --自动分解设置
    self:RegisterProtocal(proto.SOUL_DECOMPOSE_SET, self.HandleSetSoulDecompose)
    --获取自动分解的设置
    self:RegisterProtocal(proto.SOUL_GET_SET,       self.HandleGetSetSoulDecompose)
    --合成圣痕
    self:RegisterProtocal(proto.SOUL_COMBINE,       self.HandleSoulCombine)

end

--打开圣痕界面
function StigmataController:OpenStigmataPanel()
    lua_panelMgr:GetPanelOrCreate(StigmataPanel):Open()
end

--打开圣痕分解界面
function StigmataController:OpenStigmataSellPanel(data)
    lua_panelMgr:GetPanelOrCreate(StigmataSellPanel):Open(data)
end

--打开圣痕升级界面
function StigmataController:OpenStigmataLevelUpPanel(data)
    lua_panelMgr:GetPanelOrCreate(StigmataLevelUpPanel):Open(data)
end

--请求已佩戴圣痕信息
function StigmataController:RequestSoulList()
    local pb = self:GetPbObject("m_soul_list_tos")

    self:WriteMsg(proto.SOUL_LIST, pb)
end

--接收已佩戴圣痕信息
function StigmataController:HandleSoulList()
    local data = self:ReadMsg("m_soul_list_toc")

    self.model:SetMainPanelData(data.souls)

    self.model:Brocast(StigmataEvent.GetStigmataPanelData, data.souls)
    
end

--请求装备圣痕
function StigmataController:RequestSoulPutOn(uid, pos)
    local pb = self:GetPbObject("m_soul_puton_tos")

    pb.pos = pos
    pb.uid = uid

    --更新部分已佩戴圣痕信息
    self.model.IsUpdateMainData = true;
    self:WriteMsg(proto.SOUL_PUTON, pb)
end

--返回装备圣痕
function StigmataController:HandleSoulPutOn()
    local data = self:ReadMsg("m_soul_puton_toc")
end

--请求取下圣痕
function StigmataController:RequestSoulPutOff(pos)
    local pb = self:GetPbObject("m_soul_putoff_tos")
    pb.pos = pos

    self:WriteMsg(proto.SOUL_PUTOFF, pb)
end

--返回取下圣痕
function StigmataController:HandleSoulPutOff()
    local data = self:ReadMsg("m_soul_putoff_toc")

    self.model:Brocast(StigmataEvent.PutOffStigmata, data.pos)

    self:RequestSoulList()
end

--请求升级圣痕
function StigmataController:RequestSoulUpLevel(pos)
    local pb = self:GetPbObject("m_soul_uplevel_tos")
    pb.pos = pos

    self:WriteMsg(proto.SOUL_UPLEVEL, pb)
end

--返回升级圣痕
function StigmataController:HandleSoulUpLevel()
    local data = self:ReadMsg("m_soul_uplevel_toc")
    self.model:Brocast(StigmataEvent.UpdatePlayerConstant)
    
    --升级后不要刷新圣痕背包
    self.model.NeedRequestBagInfo = false
    self:RequestSoulList()
end

--请求分解圣痕
function StigmataController:RequestSoulDecompose(uidList)
    local pb = self:GetPbObject("m_soul_decompose_tos")
    for i, v in pairs(uidList) do
        pb.uid:append(i)
    end

    self:WriteMsg(proto.SOUL_DECOMPOSE, pb)
end

--返回分解圣痕
function StigmataController:HandleSoulDecompose()
    local data = self:ReadMsg("m_soul_decompose_toc")
    Notify.ShowText("Dismantled")
    self.model:Brocast(StigmataEvent.UpdatePlayerConstant)
    --刷新已佩戴圣痕
    self:RequestSoulList()
end

--请求自动分解圣痕设置
function StigmataController:RequestSetSoulDecompose(tData)
    local pb = self:GetPbObject("m_soul_decompose_set_tos")

    pb.auto = tData.auto
    pb.color = tData.color

    self:WriteMsg(proto.SOUL_DECOMPOSE_SET, pb)
end

--返回自动分解圣痕设置
function StigmataController:HandleSetSoulDecompose()
    local data = self:ReadMsg("m_soul_decompose_set_toc")
    
    self.isOpenSellPanel = false
    self:RequestGetSetSoulDecompose()
end

--请求获取自动分解圣痕设置
function StigmataController:RequestGetSetSoulDecompose()
    local pb = self:GetPbObject("m_soul_get_set_tos")
    self:WriteMsg(proto.SOUL_GET_SET, pb)
end

--返回获取自动分解圣痕设置
function StigmataController:HandleGetSetSoulDecompose()
    local data = self:ReadMsg("m_soul_get_set_toc")
    self.setSoulDecomposeData = data

    if self.isOpenSellPanel then
        self:OpenStigmataSellPanel(data)
    end
   
end

--请求合成圣痕
function StigmataController:RequestSoulCombine(target_item_id)
    local pb = self:GetPbObject("m_soul_combine_tos")
    pb.r_item_id = target_item_id
    self:WriteMsg(proto.SOUL_COMBINE, pb)
end

--返回合成圣痕
function StigmataController:HandleSoulCombine()
    local data = self:ReadMsg("m_soul_combine_toc")
    
    --刷新货币
    StigmataModel:GetInstance():Brocast(StigmataEvent.UpdatePlayerConstant)
end


--分解圣痕
function StigmataController:DecomposeSoul(param)
    local db_item = Config.db_item[param[1].id]
    local db_soul = Config.db_soul[param[1].id]
    local function ok_func()
        local dataList = {}

        dataList[param[1].uid] = true

        self:RequestSoulDecompose(dataList)
        GlobalEvent:Brocast(GoodsEvent.CloseTipView)
    end
    if db_item.color >= 4 and db_soul.slot ~= 0 then
        local message = "This is a rare Stigmata, dismantle?"
        Dialog.ShowTwo('Tip',message,'Confirm',ok_func,nil,'Cancel',nil,nil,nil)
    else
        ok_func()
    end
end

--拆解圣痕
function StigmataController:DismantleSoul(param)
    local db_item = Config.db_item[param[1].id]
    local db_soul = Config.db_soul[param[1].id]

    local disItem = String2Table(db_soul.gain)

    local db_item1 = Config.db_item[disItem[1][1]]
    local db_item2 = Config.db_item[disItem[2][1]]

    local thisSoulName = string.format("<color=#%s>%s</color>",ColorUtil.GetColor(db_item.color),db_item.name)
    local item1Name = string.format("<color=#%s>%s</color>",ColorUtil.GetColor(db_item1.color),db_item1.name)
    local item2Name = string.format("<color=#%s>%s</color>",ColorUtil.GetColor(db_item2.color),db_item2.name)

    --升级总消耗
    local total_cost = String2Table(Config.db_soul_level[param[1].id .."@".. param[1].extra].total_cost) 
    local cost_id = total_cost[1]
    local cost_num = total_cost[2]

    local showMessage

    local cost_num_message = ""
    if cost_num ~= 0 then
        --有返还的圣痕经验才显示
        cost_num_message = "and"..enumName.ITEM[cost_id].."*"..cost_num
    end

    if #disItem == 3 then
        showMessage = thisSoulName.."Dismantle to Lv.1"..item1Name.."and"..item2Name.."And return"..enumName.ITEM[disItem[3][1]].."Gem*"..disItem[3][2]..cost_num_message.."dismantle it?"
    else

        showMessage = thisSoulName.."Dismantle to Lv.1"..item1Name.."and"..item2Name.."And return"..enumName.ITEM[disItem[3][1]].."Gem*"..disItem[3][2]..
                "and"..enumName.ITEM[disItem[4][1]].."Gem*"..disItem[4][2]..cost_num_message.."dismantle it?"
    end

    local function ok_func()
        local dataList = {}

        dataList[param[1].uid] = true

        self:RequestSoulDecompose(dataList)
        GlobalEvent:Brocast(GoodsEvent.CloseTipView)
    end
    local message = showMessage
    Dialog.ShowTwo('Tip',message,'Confirm',ok_func,nil,'Cancel',nil,nil,nil)
end

-- overwrite
function StigmataController:GameStart()

    local function step()

        --请求已佩戴圣痕信息
        self:RequestSoulList()

        --获取分解设置
        self.isOpenSellPanel = false
        self:RequestGetSetSoulDecompose()
    end
    GlobalSchedule:StartOnce(step,Constant.GameStartReqLevel.Ordinary)
end


