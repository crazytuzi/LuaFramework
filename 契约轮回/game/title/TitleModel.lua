-- @Author: lwj
-- @Date:   2018-12-16 16:50:38
-- @Last Modified time: 2018-12-16 16:50:42

TitleModel = TitleModel or class("TitleModel", BaseModel)
local TitleModel = TitleModel

function TitleModel:ctor()
    TitleModel.Instance = self
    self:Reset()
end

function TitleModel:Reset()
    self.titleInfoList = {}
    self.secItemList = {}
    self.curSub_id = nil
    self.curBtnMode = 0   --0:按钮隐藏     1：穿戴   2:卸下    3:激活
    self.curInfoListMode = 0    --0:全列表  1:单个称号信息  2：单个当前穿戴id
    self.titleItemList = {}
    self.curSubList = {}
    self.one_off_red_list = {}            --此次登陆不再显示的红点列表
    self.is_open_panel = true              --在请求信息的时候是否打开称号界面
    self.is_show_title_red = false          --打开时装界面时、是否显示称号的红点

    self.is_can_set = false
end

function TitleModel.GetInstance()
    if TitleModel.Instance == nil then
        TitleModel()
    end
    return TitleModel.Instance
end

function TitleModel:GetPTitleBySunId(sub_id)
    local result = nil
    if self.titleInfoList == nil or self.titleInfoList.titles == nil then
        return
    end
    for i, v in pairs(self.titleInfoList.titles) do
        if v.id == sub_id then
            result = v
            break
        end
    end
    return result
end

function TitleModel:AddSecItemToList(item, id)
    self.secItemList[#self.secItemList + 1] = item
end

function TitleModel:ClearSecItemList()
    if not table.isempty(self.secItemList) then
        for i, v in pairs(self.secItemList) do
            if v then
                v:destroy()
            end
        end
        self.secItemList = {}
    end
end

function TitleModel:AddSingleInfoToList(info, id)
    if info then
        self.titleInfoList.titles[self.curSub_id] = info
    end
    if id then
        self.titleInfoList.puton_id = id
    end
end

function TitleModel:CheckTitleExist()
    local list = {}
    for i, v in pairs(self.titleInfoList.titles) do
        if v.etime ~= 0 and v.etime - os.time() <= 0 then
            list[i] = v
        end
    end
    for i, v in pairs(list) do
        table.removebykey(self.titleInfoList.titles, i)
    end
end

function TitleModel:AddOneOffRedById(id)
    self.one_off_red_list[id] = true
end

function TitleModel:CheckIsShowedRedById(id)
    return self.one_off_red_list[id]
end

function TitleModel:IsTitleListEmpty()
    return table.isempty(self.titleInfoList.titles)
end

