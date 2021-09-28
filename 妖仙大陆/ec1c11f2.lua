local _M = { }
_M.__index = _M

local PetModel      = require 'Zeus.Model.Pet'

local ui_names = {
	"tb_speciality_detail",
	"lb_attributename",
	"lb_attributename1",
	"lb_attributename2",
	"lb_attributename3",
	"lb_attributenum",
	"lb_attributenum1",
	"lb_attributenum2",
	"lb_attributenum3",
	"lb_attributebonus1",
	"lb_attributebonus2",
	"lb_attributebonus3",
	"lb_attributebonus4",
	"lb_additionnum1",
	"lb_additionnum2",
	"lb_additionnum3",
	"lb_additionnum4",
	"cvs_skillall",
	"cvs_skill_single",
	"cvs_information",
}

local ui_skill_names = {
	"ib_skill_icon",
	"ib_skill_type",
	"ib_zhu",
	"ib_bei",
}

local function InitItemUI(ui,uinames,node)
    
    for i = 1, #uinames do
        ui[uinames[i]] = node:FindChildByEditName(uinames[i], true)
    end
end

function _M:onExit()
	
	if self.root ~= nil then
		self.root:RemoveFromParent(true)
		self.root = nil
	end
end

function _M:initUI()
	

	self.cvs_skill_single.Visible = false
    self.skills = { }
    local posx = self.cvs_skill_single.X
    local posy = self.cvs_skill_single.Y

    for i=1,8 do
    	local  skill = self.cvs_skill_single:Clone()
    	skill.Visible = false
    	if i<5 then
    		skill.X = posx + (i - 1)*(skill.Width + 5)
    		skill.Y = posy
    	else
    		skill.X = posx + (i - 5)*(skill.Width + 5)
    		skill.Y = posy + skill.Height
    	end
    	self.skills[i] = skill
    	self.cvs_skillall:AddChild(skill)
    end
end

function _M.CreateCultureUI(parent)
	local ret = { }
    setmetatable(ret, _M)
    ret.root = XmdsUISystem.CreateFromFile("xmds_ui/pet/culture.gui.xml")
    InitItemUI(ret,ui_names,ret.root)
    if (parent) then
        parent:AddChild(ret.root)
    end

	ret:initUI();

    ret.root.Visible = false

    return ret
end



function _M:setPetInfo(petData)
	
	if self.root == nil then
		return
	end
	self.petData = petData
	self.root.Visible = true
	self.tb_speciality_detail.Text = petData.Desc
	
	local skills = {}
	local  serverData = PetModel.getPetData(petData.PetID)
	local  lv = 1
	
	if serverData == nil then
		local datas = string.split(petData.InitSkill,'|')
		for _,v in ipairs(datas) do
			local temps = string.split(v,':')
			table.insert(skills,{id=temps[1],level=temps[2]})
		end

		self.lb_attributenum.Text = petData.BasePhyDamage or ""
		self.lb_attributenum1.Text = petData.BaseMagDamage or ""
    	self.lb_attributenum2.Text = petData.initHit or ""
    	self.lb_attributenum3.Text = petData.initCrit or ""

    	serverData = {upLevel = 0}
	else
		skills = serverData.skills
		
		lv = serverData.level
		local attrs = {}
		for _,v in ipairs(serverData.attrs_final) do
			attrs[v.id] = v.value
		end

		self.lb_attributenum.Text = attrs[5] or ""
    	self.lb_attributenum1.Text = attrs[7] or ""
    	self.lb_attributenum2.Text = attrs[9] or ""
    	self.lb_attributenum3.Text = attrs[15] or ""
	end

	
	local masterdata = GlobalHooks.DB.Find('MasterProp',{PropID = petData.PetID})[1]
	local masterdataEx = GlobalHooks.DB.Find('MasterUpgradeProp',{PetID = petData.PetID, UpLevel = serverData.upLevel})[1]
	if masterdata ~= nil then
    	for i=1,4 do
    		self['lb_attributebonus' .. i].Text = masterdata['Prop' .. i] .. ':'
    		local value = math.floor( math.pow(masterdata['Grow' ..i ],lv - 1)*masterdata['Min' .. i] + 0.5)
    		if masterdataEx then
    			value = value + masterdataEx['PetMin' ..i ]
    		end
    		self['lb_additionnum' .. i].Text = value
    	end
    else
    	for i=1,4 do
    		self['lb_attributebonus' .. i].Visible = false
    		self['lb_additionnum' .. i].Visible = false
    	end
	end

    
    for i=1,8 do
    	if i<=#skills then
	    	local ui = {}
	    	InitItemUI(ui,ui_skill_names,self.skills[i])

	    	local ret = GlobalHooks.DB.Find('PetSkill',{SkillID = tonumber(skills[i].id)})
	    	self.skills[i].Visible = true
	    	self.skills[i].IsGray = tonumber(skills[i].level) == 0 or serverData == nil
	    	ui.ib_skill_type.Visible = false
	    	MenuBaseU.SetImageBoxFroXmlKey(self.skills[i], "ib_skill_icon", "#static_n/actskill_icon/skillicon.xml|skillicon|"..ret[1].SkillIcon, LayoutStyle.IMAGE_STYLE_BACK_4, 8)
    		
    		ui.ib_zhu.Visible = ret.SkillType == 1
    		ui.ib_bei.Visible = ret.SkillType == 0

    		self.skills[i].Enable = true
            self.skills[i].event_PointerDown = function (sender)
                local cdata = {}
                cdata.id = tonumber(skills[i].id)
                cdata.lv = tonumber(skills[i].level) == 0 and 1 or tonumber(skills[i].level)
                cdata.unLock = tonumber(skills[i].level) == 0 or serverData == nil
                local menu, ui = GlobalHooks.OpenUI(GlobalHooks.UITAG.GameUIPetSkillInfo, 0)
                ui.SetPetInfo(cdata)
                ui.SetPetPos(self.skills[i]:LocalToGlobal())
            end

            self.skills[i].event_PointerUp = function (sender)
                GlobalHooks.CloseUI(GlobalHooks.UITAG.GameUIPetSkillInfo)
            end

    	else
    		self.skills[i].Visible = false
    	end
    end
end

return _M
