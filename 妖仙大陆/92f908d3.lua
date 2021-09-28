local _M = {}
_M.__index = _M


local Util          = require "Zeus.Logic.Util"
local SkillEquationUtil     = require "Zeus.UI.XmasterPet.SkillEquationUtil"


local self = {
    m_Root = nil,

}

local function InitData(data, baseData)
    
    if baseData.SkillType == 1 or baseData.SkillType == 2 or baseData.SkillType == 3 then
        
        
        if baseData.CDTime == 0 then
            self.tb_cd.Text = Util.GetText(TextConfig.Type.PET, 'skill_nocd')
        else
            self.tb_cd.Text = string.gsub(Util.GetText(TextConfig.Type.PET, 'skill_cd'), "|1|", baseData.CDTime / 1000)
        end
        
        self.tb_cd.Visible = true
        
    else
        
        self.tb_cd.Visible = false
        
    end

    MenuBaseU.SetImageBoxFroXmlKey(self.menu, "ib_icon", "#static_n/actskill_icon/skillicon.xml|skillicon|"..baseData.SkillIcon, LayoutStyle.IMAGE_STYLE_BACK_4, 8)
    
    self.lb_lv.Text = Util.GetText(TextConfig.Type.PUBLICCFG, 'Lv.n', data.lv)
    self.lb_name.Text = baseData.SkillName
    local str = baseData.SkillDesc
    for i = 1, 7 do
        if string.find(str,'<$'..i..'>') then
            local replaceStr = SkillEquationUtil.EquationType(baseData, i, data.lv)
            
            str = string.gsub(str,'<$'..i..'>', replaceStr)
            
        end
    end
    self.tb_des.Text = str
    

    self.tb_tips.Visible = data.unLock or false
    
end

function _M.SetPetInfo(data, baseData)
    
    self.curdata = data
    if baseData == nil then
        local search = {SkillID = data.id}

        local ret = GlobalHooks.DB.Find('PetSkill',search)
        if ret ~= nil and #ret > 0 then
            InitData(data, ret[1])
        end
    else
        InitData(data, baseData)
    end
    self.cvs_skill.Position2D = self.cvs_skillPosition2D
end

function _M.SetPetPos(pos)
    
    local v1 = self.cvs_skill.Parent:GlobalToLocal(pos,true)
    
    v1.y = v1.y + self.cvs_skill.Height
    
    if v1.x - self.cvs_skill.Width > 15 then
        
        self.cvs_skill.X = v1.x - self.cvs_skill.Width - 15
    else
        self.cvs_skill.X = v1.x
    end

    if v1.y - self.cvs_skill.Height > 15 then
        self.cvs_skill.Y = v1.y - self.cvs_skill.Height
    else
        self.cvs_skill.Y = v1.y
    end
end

local  function OnClickClose(displayNode)
    
    self.m_Root:Close()
end

local function OnEnter()
end

local function OnExit()
    
end

local function InitUI()
    
    local UIName = {
        "ib_icon",
        "lb_name",
        "lb_lv",
        "tb_des",
        "tb_cd",
        
        "cvs_skill",
        "tb_tips",
        
    }   

    for i = 1, #UIName do
        self[UIName[i]] = self.m_Root:GetComponent(UIName[i])
    end
end

local function InitCompnent()
    InitUI()

    self.cvs_skillPosition2D = self.cvs_skill.Position2D

    LuaUIBinding.HZPointerEventHandler({node = self.menu, click = OnClickClose})
    self.m_Root:SubscribOnEnter(OnEnter)
    self.m_Root:SubscribOnExit(OnExit)

    self.m_Root:SubscribOnDestory(function()
        self = nil
    end)
end

local function Init(tag,params)
    self.m_Root = LuaMenuU.Create("xmds_ui/pet/pet_skill.gui.xml", GlobalHooks.UITAG.GameUIPetSkillInfo)
    
    self.menu = self.m_Root
    InitCompnent()
    return self.m_Root
end

local function Create(tag,params)
    self = {}
    setmetatable(self, _M)
    local node = Init(tag, params)
    return self
end

return {Create = Create}
