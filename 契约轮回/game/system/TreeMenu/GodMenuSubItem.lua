GodMenuSubItem = GodMenuSubItem or class("GodMenuSubItem",BaseTreeTwoMenu)
local GodMenuSubItem = GodMenuSubItem

function GodMenuSubItem:ctor(parent_node,layer,first_menu_item)
    self.abName = "system"
    self.assetName = "GodMenuSubItem"
    --self.layer = layer
    self.index = 1
    self.events = {}
    self.layer = layer
    self.first_menu_item = first_menu_item
    GodMenuSubItem.super.Load(self)
end

function GodMenuSubItem:dctor()
    GlobalEvent:RemoveTabListener(self.events)
    if self.redPoint then
        self.redPoint:destroy()
        self.redPoint = nil
    end
end

function GodMenuSubItem:LoadCallBack()
    self.nodes = {
        "redParent","starObj/star1","starObj/star3","flag","starObj/star4","starObj/star2","starObj/star5",
        "starObj/staran3","starObj/staran5","starObj/staran4","starObj/staran2","starObj/staran1","unActiveObj","starObj"
    }
    self:GetChildren(self.nodes)
    GodMenuSubItem.super.LoadCallBack(self)
    self.redPoint = RedDot(self.redParent, nil, RedDot.RedDotType.Nor)
    self.redPoint:SetPosition(-11, 0)

end
--
function GodMenuSubItem:AddEvent()
    GodMenuSubItem.super.AddEvent(self)

    self.events[#self.events + 1]  = GlobalEvent:AddListener(MountEvent.MORPH_UPSTAR_DATA,handler(self,self.HandleUpStarData))
    self.events[#self.events + 1]  = GlobalEvent:AddListener(MountEvent.MOUNT_CHANGE_FIGURE,handler(self,self.HandleChangeFigure))
end
--
function GodMenuSubItem:SetData(first_menu_id,data, select_sub_id,menuSpan, index)
    GodMenuSubItem.super.SetData(self,first_menu_id,data, select_sub_id,menuSpan)
    self.group = first_menu_id
    self.godId = data[1]
    self.figureId = MountModel:GetInstance().pb_data[enum.TRAIN.TRAIN_GOD].used_id
    self:UpdateInfo()
    self:SetRedPoint()
end

function GodMenuSubItem:UpdateInfo()
    local info =  MountModel:GetInstance():GetMorphDataByType(enum.TRAIN.TRAIN_GOD,self.godId)
    SetVisible(self.flag,self.godId == self.figureId)
    local star = 0
    if not info  then --没激活
        --local key = tostring(self.godId).."@".."0"
        --local curCfg = Config.db_god_star[key]
        --star = curCfg.star_client
        SetVisible(self.flag,false)
        SetVisible(self.unActiveObj,true)
        SetVisible(self.starObj,false)
    else
        local key = tostring(self.godId).."@"..tostring(info.star)
        local curCfg = Config.db_god_star[key]
        if curCfg.star_client < 0 then
            SetVisible(self.unActiveObj,true)
            SetVisible(self.starObj,false)
            star = 0
        else
            star = curCfg.star_client
            SetVisible(self.unActiveObj,false)
            SetVisible(self.starObj,true)
        end
    end
    for i = 1, 5 do
        if star >= i then
            --self["start_"..i]
            SetVisible(self["star"..i],true)
            SetVisible(self["staran"..i],false)
          --  lua_resMgr:SetImageTexture(self, self["star"..i], "uicomponent_image", "lightstar", true, nil, false)
        else
            SetVisible(self["star"..i],false)
            SetVisible(self["staran"..i],true)
          --  lua_resMgr:SetImageTexture(self, self["star"..i], "uicomponent_image", "darkstar", true, nil, false)
        end
    end
end

function GodMenuSubItem:HandleUpStarData(data)
    if data.morph.id == self.godId then
        self:UpdateInfo()
    end
end

function GodMenuSubItem:HandleChangeFigure()
    self.figureId = MountModel:GetInstance().pb_data[enum.TRAIN.TRAIN_GOD].used_id
    SetVisible(self.flag,self.godId == self.figureId)
end


function GodMenuSubItem:SetRedPoint()
    local redPoints = GodModel:GetInstance().starRedPoints
    local isRed = false
    for id, reds in pairs(redPoints) do
        for i, v in pairs(reds) do
            if v == true and i == self.godId  then
                isRed = true
                break
            end
        end
    end
    self.redPoint:SetRedDotParam(isRed)
end

