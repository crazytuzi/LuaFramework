-- @Author: lwj
-- @Date:   2018-11-29 17:55:48
-- @Last Modified time: 2019-11-13 14:39:09

VipIntroPanel = VipIntroPanel or class("VipIntroPanel", BaseItem)
local VipIntroPanel = VipIntroPanel

function VipIntroPanel:ctor(parent_node, layer)
    self.abName = "vip"
    self.assetName = "VipIntroPanel"
    self.layer = layer

    self.tog_List = {}
    self.page_List = {}
    self.vipCard_List = {}
    self.comTitleItemList = {}
    self.comDesItemList = {}
    self.grayAreaList = {}
    self.model = VipModel.GetInstance()
    self.introl_item_height = 43
    BaseItem.Load(self)
end

function VipIntroPanel:dctor()
    if self.CDT then
        self.CDT:StopSchedule()
        self.CDT:destroy()
        self.CDT = nil
    end
    self:DestroyLeftModel()
    self.tog_List = {}
    self.page_List = {}

    if self.vipCard_List then
        for i, v in pairs(self.vipCard_List) do
            if v then
                v:destroy()
            end
        end
    end
    self.vipCard_List = {}

    if self.comTitleItemList then
        for i, v in pairs(self.comTitleItemList) do
            if v then
                v:destroy()
            end
        end
    end
    self.comTitleItemList = {}

    if self.grayAreaList then
        for i, v in pairs(self.grayAreaList) do
            if v then
                v:destroy()
            end
        end
    end
    self.grayAreaList = {}
end

function VipIntroPanel:LoadCallBack()
    self.nodes = {
        "RightContain/tog_Group/compa_Tog",
        "RightContain/tog_Group/ab_Tog",
        "RightContain/abstract",
        "RightContain/compareRight",
        "RightContain/StraightCardGroup",
        "RightContain/compare",
        "RightContain/top_IntroSel", "RightContain/top_CompareT", "RightContain/top_IntroT",
        "RightContain/ComDesItem", "RightContain/IntroGrayArea", "RightContain/compare/compareRight/Viewport/Content/ComSumItem/grayContainer", "RightContain/ComTitleItem",
        "RightContain/compare/compareRight/Viewport/Content/ComSumItem/titleConrainer", "RightContain/compare/compareRight/Viewport/Content", "RightContain/compare/compareRight/Viewport/Content/ComSumItem/desContainer",
        "LeftBg/leftPic", "LeftBg/left_con", "LeftBg/cd_con",
    }
    self:GetChildren(self.nodes)
    self.gridGroup = self.Content:GetComponent('GridLayoutGroup')
    self.compaT = self.compa_Tog:GetComponent('Toggle')
    self.abT = self.ab_Tog:GetComponent('Toggle')
    self.title_gameObject = self.ComTitleItem.gameObject
    self.des_gameObject = self.ComDesItem.gameObject
    self.gray_gameObject = self.IntroGrayArea.gameObject
    self.introT = self.top_IntroT:GetComponent('Text')
    self.compareT = self.top_CompareT:GetComponent('Text')
    self.leftPicI = self.leftPic:GetComponent('Image')

    SetLocalPosition(self.left_con, -2.35, 27.8, 0)

    self:AddToggle()
    self:AddEvent()
    self:LoadVipCard()
    self:SwitchTopTColor(1)
    self:InitLeft()
    self:LoadCompareItem()
end

function VipIntroPanel:AddToggle()
    self.tog_List[1] = self.abT
    self.tog_List[2] = self.compaT

    self.page_List[1] = self.abstract
    self.page_List[2] = self.compare

end

function VipIntroPanel:AddEvent()
    local function call_back()
        for i = 1, table.nums(self.tog_List) do
            if self.tog_List[i].isOn == false then
                SetVisible(self.page_List[i], false)
                self:SwitchTopTColor(1)
            else
                SetVisible(self.page_List[i], true)
                self:SwitchTopTColor(2)
            end
        end
    end
    for i = 1, table.nums(self.tog_List) do
        AddClickEvent(self.tog_List[i].gameObject, call_back)
    end
end

function VipIntroPanel:SwitchTopTColor(index)
    if index == 1 then
        SetColor(self.introT, 109, 136, 187, 255)
        SetColor(self.compareT, 228, 243, 253, 255)
        SetVisible(self.top_IntroSel, true)
    elseif index == 2 then
        SetColor(self.introT, 228, 243, 253, 255)
        SetColor(self.compareT, 109, 136, 187, 255)
        SetVisible(self.top_IntroSel, false)
    end
end

function VipIntroPanel:InitLeft()
    --local id = Config.db_vip_show[4].chartlet
    --lua_resMgr:SetImageTexture(self, self.leftPicI, "iconasset/icon_vip", tostring(id), true, nil, false)

    self:DestroyLeftModel()
    local tbl = [[{model,5,20005}]]
    local res = String2Table(tbl)
    if res[1] == "model" then
        SetVisible(self.left_con, true)
        SetVisible(self.leftPic, false)
        --local model_data = {}
        -- local pet_id = tonumber(Config.db_pet[40400503].model)
        -- if res[2] == enum.MODEL_TYPE.MODEL_TYPE_PET and res[3] == pet_id then
        -- model_data.effect_id = 10312
        -- end
        --self.left_model = UIModelManager:GetInstance():InitModel(res[2], res[3], self.left_con, handler(self, self.LoadLeftModelCB), nil, 4, model_data)
        self.left_model = UIPetCamera(self.left_con, nil, 20005, 8, nil, nil)
    elseif res[1] == "texture" then
        SetVisible(self.left_con, false)
        SetVisible(self.leftPic, true)
        local res_tbl = string.split(res[2], ":")
        lua_resMgr:SetImageTexture(self, self.leftPicI, res_tbl[1], res_tbl[2], false, nil, false)
    end

    local day_sec = TimeManager.GetInstance().DaySec
    if self.model.taste_etime + day_sec > os.time() then

        local day_sec = TimeManager.GetInstance().DaySec
        local end_time = self.model.taste_etime + day_sec
        local param = {}
        param.isShowMin = true
        param.isShowHour = true
        param.nodes = { "cd" }
        param.formatText = "Countdown: %s"
        local function call_back()
            self.CDT:StopSchedule()
            SetVisible(self.CDT, false)
        end
        if not self.CDT then
            self.CDT = CountDownText(self.cd_con, param)
        else
            self.CDT:StopSchedule()
        end
        self.CDT:StartSechudle(end_time, call_back)
        SetVisible(self.CDT, true)
    elseif self.CDT then
        SetVisible(self.CDT, false)
    end
end
function VipIntroPanel:LoadLeftModelCB()
    SetLocalPosition(self.left_model.transform, 7, -200, -400)
    SetLocalRotation(self.left_model.transform, 10, 180, 0)
    SetLocalScale(self.left_model.transform, 200, 200, 200)
end

function VipIntroPanel:DestroyLeftModel()
    if self.left_model then
        self.left_model:destroy()
        self.left_model = nil
    end
end

function VipIntroPanel:LoadVipCard()
    local item = nil
    local data = {}
    local mallId = nil
    local id = nil
    local config = nil
    for i = 1, 4 do
        data = {}
        mallId = nil
        id = nil
        config = nil
        if i ~= 1 then
            --if i == 4 then
            --    mallId = Config.db_vip_card[i].goods
            --    data.limitDate = Config.db_vip_card[i].last
            --    data.typeId = i
            --else
            --mallId = Config.db_vip_card[i + 1].goods
            --data.limitDate = Config.db_vip_card[i + 1].last

            mallId = Config.db_vip_card[i].goods
            data.limitDate = Config.db_vip_card[i].last
            data.typeId = i
            --end
            data.mallId = mallId
            data.level = i
            id = String2Table(Config.db_mall[mallId].item)[1]
            data.name = Config.db_item[id].name
            data.id = id
            config = Config.db_mall[mallId]
            data.originalPrice = String2Table(config.original_price)[2]
            data.curPrice = String2Table(config.price)[2]
            data.price_type = String2Table(config.price[1])
            item = VipUICard(self.StraightCardGroup, "UI")
            item:SetData(data)
            table.insert(self.vipCard_List, item)
        end
    end
end

function VipIntroPanel:LoadCompareItem()
    local tabNums = table.nums(Config.db_vip_rights)
    self.gridGroup.cellSize = Vector2(self.gridGroup.cellSize.x, self.introl_item_height * (tabNums))
    local name = nil
    local titleItem = nil
    local desItem = nil
    local type = 0
    local data = {}
    local des = nil
    local cf = self.model:GetVipRightsCf()
    for i = 1, tabNums do
        titleItem = nil
        name = cf[i].compare
        titleItem = ComTitleItem(self.title_gameObject, self.titleConrainer)
        titleItem:SetData(name)
        table.insert(self.comTitleItemList, titleItem)

        local grayItem = nil
        for ii = 1, 4 do
            data = {}
            des = nil
            if ii==1 then
                des = cf[i]["vip"..ii-1]
            else 
                des = cf[i]["vip" .. ii]
            end
            type = cf[i].type
            if type == 0 then
                data.value = des
                data.isHave = false
            elseif type == 1 then
                if tonumber(des) == 0 then
                    data.value = des
                else
                    data.value = des / 100 .. "%"
                end
                data.isHave = false
            elseif type == 2 then
                data.value = des
                data.isHave = true
            end
            if ii == 4 then
                data.isSpecial = true
            end
            desItem = ComDesItem(self.des_gameObject, self.desContainer)
            desItem:SetData(data)
            table.insert(self.comDesItemList, desItem)
        end
        if i % 2 == 0 then
            grayItem = IntroGrayArea(self.gray_gameObject, self.grayContainer)
            SetAnchoredPosition(grayItem.transform, 0, (-(i - 1) * self.introl_item_height) + 5)
        end
    end
end

