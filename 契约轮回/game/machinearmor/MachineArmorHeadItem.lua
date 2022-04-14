---
--- Created by  Administrator
--- DateTime: 2019/12/23 14:54
---
MachineArmorHeadItem = MachineArmorHeadItem or class("MachineArmorHeadItem", BaseCloneItem)
local this = MachineArmorHeadItem

function MachineArmorHeadItem:ctor(parent_node, layer)
    --self.abName = "machinearmor"
    --self.assetName = "MachineArmorHeadItem"
    --self.layer = layer
    self.events = {}
    self.model = MachineArmorModel:GetInstance()
    MachineArmorHeadItem.super.Load(self)
end

function MachineArmorHeadItem:dctor()
    self.model:RemoveTabListener(self.events)
    if self.red then
        self.red:destroy()
        self.red = nil
    end
end

function MachineArmorHeadItem:LoadCallBack()
    self.nodes = {
        "bg","select","stateImg","head","grade","lvBg/level",
    }
    self:GetChildren(self.nodes)
    self.level = GetText(self.level)
    self.stateImg = GetImage(self.stateImg)
    self.head = GetImage(self.head)
    self.grade = GetText(self.grade)
    self.bg = GetImage(self.bg)
    self:InitUI()
    self:AddEvent()
    if self.is_need_setData then
        self:SetData(self.data)
    end
    if self.is_need_setShow then
        self:SetShow(self.isShow)
    end
    if self.is_need_setRedPoint then
        self:UpdateRedPoint(self.isRed)
    end

end

function MachineArmorHeadItem:InitUI()

end

function MachineArmorHeadItem:AddEvent()

    local function call_back()
        self.model:Brocast(MachineArmorEvent.HeadItemClick,self.data)
    end
    AddClickEvent(self.bg.gameObject,call_back)
    self.events[#self.events + 1] = self.model:AddListener(MachineArmorEvent.MechaUpStarInfo,handler(self,self.MechaUpStarInfo))
    self.events[#self.events + 1] = self.model:AddListener(MachineArmorEvent.MechaUpGradeInfo,handler(self,self.MechaUpStarInfo))
    self.events[#self.events + 1] = self.model:AddListener(MachineArmorEvent.MechaSelectInfo,handler(self,self.MechaSelectInfo))
end




function MachineArmorHeadItem:SetData(data)
    self.data = data
  --  self.serInfo = self.model:GetMecha(self.data.id)
    if not self.data then
        return
    end
    if not self.is_loaded then
        self.is_need_setData = true
        return
    end
    lua_resMgr:SetImageTexture(self,self.bg,"machinearmor_image","MachineArmor_itemBg_"..self.data.color, true)
    lua_resMgr:SetImageTexture(self,self.head,"iconasset/icon_mecha",self.data.id, false)
    self:UpdateInfo()
end
function MachineArmorHeadItem:UpdateInfo()
    self.serInfo = self.model:GetMecha(self.data.id)
    if not self.serInfo then --没有信息
        SetVisible(self.stateImg,true)
        self.grade.text = "0j"
        self.level.text = "Lv.0"
        lua_resMgr:SetImageTexture(self, self.stateImg, "machinearmor_image", "MachineArmor_state2", false)
        ShaderManager.GetInstance():SetImageGray(self.bg)
        ShaderManager.GetInstance():SetImageGray(self.head)
    else
        local key = tostring(self.data.id).."@"..self.serInfo.star
        local cfg  = Config.db_mecha_star[key]
        if cfg.star_client < 0 then --未激活
            self.grade.text = "0j"
            self.level.text = "Lv.0"
            SetVisible(self.stateImg,true)
            ShaderManager.GetInstance():SetImageGray(self.bg)
            ShaderManager.GetInstance():SetImageGray(self.head)
            lua_resMgr:SetImageTexture(self, self.stateImg, "machinearmor_image", "MachineArmor_state2", false)
        else --已经激活了
            self.grade.text = cfg.star_client.."j"
            self.level.text = "Lv."..self.serInfo.level
            ShaderManager.GetInstance():SetImageNormal(self.bg)
            ShaderManager.GetInstance():SetImageNormal(self.head)
            if self.data.id == self.model.usedMecha then
                lua_resMgr:SetImageTexture(self, self.stateImg, "machinearmor_image", "MachineArmor_state1", false)
                SetVisible(self.stateImg,true)
            else
                SetVisible(self.stateImg,false)
            end
        end
    end

end

function MachineArmorHeadItem:SetShow(isShow)
    self.isShow = isShow
    if not self.is_loaded then
        self.is_need_setShow = true
        return
    end
    SetVisible(self.select,isShow)
end

function MachineArmorHeadItem:MechaSelectInfo(data)

    self:UpdateInfo()

end


function MachineArmorHeadItem:MechaUpStarInfo(data)
    if data.mecha.id == self.data.id then
        self:UpdateInfo()
    end
end

function MachineArmorHeadItem:UpdateRedPoint(isRed)
    self.isRed = isRed
    if not self.is_loaded then
        self.is_need_setRedPoint = true
        return
    end
    if not self.red then
        self.red = RedDot(self.transform, nil, RedDot.RedDotType.Nor)
        self.red:SetPosition(65, 28)
    end
    if self.isRed ~= nil then
        self.red:SetRedDotParam(self.isRed)
    else
        self.red:SetRedDotParam(false)
    end

end