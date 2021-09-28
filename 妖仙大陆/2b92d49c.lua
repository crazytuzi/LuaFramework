local _M = { }
_M.__index = _M

local Util  = require 'Zeus.Logic.Util'
local gradeList = {}

function _M:onExit()
    
    if self.root ~= nil then
        self.root:RemoveFromParent(true)
        self.root = nil
    end
end

local ui_names = {
    "cvs_channelbg",
    "sp_see",
}

local function InitItemUI(ui, uinames, node)
    for i = 1, #uinames do
        ui[uinames[i]] = node:FindChildByEditName(uinames[i], true)
    end
    if #gradeList == 0 then
        table.insert(gradeList,Util.GetText(TextConfig.Type.PET, "one"))
        table.insert(gradeList,Util.GetText(TextConfig.Type.PET, "two"))
        table.insert(gradeList,Util.GetText(TextConfig.Type.PET, "three"))
        table.insert(gradeList,Util.GetText(TextConfig.Type.PET, "four"))
        table.insert(gradeList,Util.GetText(TextConfig.Type.PET, "five"))
        table.insert(gradeList,Util.GetText(TextConfig.Type.PET, "six"))
        table.insert(gradeList,Util.GetText(TextConfig.Type.PET, "seven"))
        table.insert(gradeList,Util.GetText(TextConfig.Type.PET, "eight"))
        table.insert(gradeList,Util.GetText(TextConfig.Type.PET, "nine"))
        table.insert(gradeList,Util.GetText(TextConfig.Type.PET, "ten"))
    end

end

local function IsGetGrade(dataList,id,level)
    for k,v in pairs(dataList) do
        if k == id and v.upLevel >= level then
            return true
        end
    end
    return false
end


function _M.CreateAssociateUI(parent,petList)
    local self = { }
    setmetatable(self, _M)
    self.root = XmdsUISystem.CreateFromFile("xmds_ui/pet/associate.gui.xml")
    InitItemUI(self, ui_names, self.root)
    if (parent) then
        parent:AddChild(self.root)
    end

    local infoData = GlobalHooks.DB.Find('PetAssociate',{})

	self.sp_see:Initialize(self.cvs_channelbg.Width, self.cvs_channelbg.Height+5, #infoData, 1, self.cvs_channelbg, 
    function(x, y, cell)
        local index = y+1
        local rewardGrade = string.split(infoData[index].PetID,";")
        local addPro = string.split(infoData[index].AddPro,";")
        local cvsList = {}
        local flag = 0
        local attr = ""
        local isActivite = false
            table.insert(cvsList,cell:FindChildByEditName("cvs_pc1",true))
            table.insert(cvsList,cell:FindChildByEditName("cvs_pc2",true))
            table.insert(cvsList,cell:FindChildByEditName("cvs_pc3",true))
            table.insert(cvsList,cell:FindChildByEditName("cvs_pc4",true))
            table.insert(cvsList,cell:FindChildByEditName("cvs_pc5",true))
            table.insert(cvsList,cell:FindChildByEditName("cvs_pc6",true))
        local lb_pro1 = cell:FindChildByEditName("lb_pro1",true)
        local ib_not_active = cell:FindChildByEditName("ib_not_active",true)
        local ib_active = cell:FindChildByEditName("ib_active",true)
        for i=1,#cvsList do
            if i <= #rewardGrade then
                local cvs_icon = cvsList[i]:FindChildByEditName("cvs_icon",true)
                local lb_jinjie =  cvsList[i]:FindChildByEditName("lb_jinjie",true)
                local ib_suo = cvsList[i]:FindChildByEditName("ib_suo",true)
                local rewards = string.split(rewardGrade[i],":")
                lb_jinjie.Text = gradeList[tonumber(rewards[2])]
                isActivite = IsGetGrade(petList,tonumber(rewards[1]),tonumber(rewards[2]))
                ib_suo.Visible = not isActivite
                if isActivite then 
                    flag = flag + 1
                    lb_jinjie.FontColorRGBA = 0x00ff00ff
                else
                    lb_jinjie.FontColorRGBA = 0xff0000ff
                end
    
                if i <= #addPro then   
                    local addProAttr = string.split(addPro[i],":")
                    local Data = GlobalHooks.DB.Find('Attribute',{ID = tonumber(addProAttr[1])})[1].attDesc
                    attr = attr .. string.gsub(Data, '{A}', tostring(addProAttr[2])).."    "
                end
                lb_pro1.Text = attr
    
                if flag >= #rewardGrade then
                    ib_active.Visible = true
                    ib_not_active.Visible = false
                    lb_pro1.FontColorRGBA = 0x00ff00ff
                else
                    ib_active.Visible = false
                    ib_not_active.Visible = true
                    lb_pro1.FontColorRGBA = 0xff0000ff
                end
    
                local code = string.format("pet%s",rewards[1])
                Util.HZSetImage(cvs_icon, "static_n/hud/target/" .. code .. ".png", false)
                cvsList[i].Visible = true
            else
                cvsList[i].Visible = false
            end
        end
    end,
     function()
       
     end
  	)
    return self
end

return _M
